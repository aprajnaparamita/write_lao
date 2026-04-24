/**
 * Auth utilities for teacher authentication
 */

import { getCookie, setCookie } from 'hono/cookie';

export interface TokenPayload {
  teacherId: string;
  email: string;
  name: string;
  iat: number;
  exp: number;
}

// Simple base64url encoding (no external deps needed)
function base64urlEncode(data: Uint8Array): string {
  const base64 = btoa(String.fromCharCode(...data));
  return base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

// Simple HMAC-like signature using Web Crypto API in Workers
export async function createTokens(
  payload: TokenPayload,
  secret: string
): Promise<{ accessToken: string; refreshToken: string }> {
  const encoder = new TextEncoder();
  const secretKey = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );

  const now = Math.floor(Date.now() / 1000);
  const accessPayload = { ...payload, iat: now, exp: now + 3600 }; // 1 hour
  const refreshPayload = { ...payload, iat: now, exp: now + 604800 }; // 7 days

  // Create JWT-like tokens (header.payload.signature)
  const header = base64urlEncode(encoder.encode(JSON.stringify({ alg: 'HS256', typ: 'JWT' })));
  
  const accessPayloadB64 = base64urlEncode(encoder.encode(JSON.stringify(accessPayload)));
  const refreshPayloadB64 = base64urlEncode(encoder.encode(JSON.stringify(refreshPayload)));

  // For simplicity, using a deterministic signature (in production, use proper JWT library)
  const accessSig = base64urlEncode(new Uint8Array(await crypto.subtle.sign('HMAC', secretKey, encoder.encode(`${header}.${accessPayloadB64}`))));
  const refreshSig = base64urlEncode(new Uint8Array(await crypto.subtle.sign('HMAC', secretKey, encoder.encode(`${header}.${refreshPayloadB64}`))));

  return {
    accessToken: `${header}.${accessPayloadB64}.${accessSig}`,
    refreshToken: `${header}.${refreshPayloadB64}.${refreshSig}`,
  };
}

export async function verifyToken(token: string, secret: string): Promise<TokenPayload | null> {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;

    const [headerB64, payloadB64, signatureB64] = parts;
    
    // Verify signature
    const encoder = new TextEncoder();
    const secretKey = await crypto.subtle.importKey(
      'raw',
      encoder.encode(secret),
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['verify']
    );

    const signature = Uint8Array.from(atob(signatureB64.replace(/-/g, '+').replace(/_/g, '/')), c => c.charCodeAt(0));
    const data = encoder.encode(`${headerB64}.${payloadB64}`);
    
    const valid = await crypto.subtle.verify('HMAC', secretKey, signature, data);
    if (!valid) return null;

    // Parse payload
    const payloadJson = atob(payloadB64.replace(/-/g, '+').replace(/_/g, '/'));
    const payload = JSON.parse(payloadJson) as TokenPayload;

    // Check expiration
    const now = Math.floor(Date.now() / 1000);
    if (payload.exp < now) return null;

    return payload;
  } catch {
    return null;
  }
}

export function authMiddleware() {
  return async (c: any, next: () => Promise<void>) => {
    const secret = c.env.TEACHER_JWT_SECRET || 'development-secret-change-in-production';
    const token = getCookie(c, 'auth_token');
    const refreshToken = getCookie(c, 'refresh_token');

    if (!token && !refreshToken) {
      c.set('teacher', null);
      // Allow access to login page without redirect
      if (c.req.path === '/admin/login') {
        await next();
        return;
      }
      return c.redirect('/admin/login');
    }

    // Try access token first
    let payload = token ? await verifyToken(token, secret) : null;

    // If expired, try refresh token
    if (!payload && refreshToken) {
      payload = await verifyToken(refreshToken, secret);
      if (payload) {
        // Generate new access token
        const tokens = await createTokens(payload, secret);
        setCookie(c, 'auth_token', tokens.accessToken, {
          httpOnly: true,
          secure: true,
          sameSite: 'Strict',
          maxAge: 3600,
          path: '/admin',
        });
      }
    }

    c.set('teacher', payload);

    if (!payload && c.req.path !== '/admin/login') {
      return c.redirect('/admin/login');
    }

    await next();
  };
}
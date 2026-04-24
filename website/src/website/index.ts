/**
 * Write Lao Website - Cloudflare Workers Entry Point
 * 
 * Routes:
 *   /           -> Public landing page (website/)
 *   /admin/*    -> Teacher admin dashboard
 *   /api/*      -> API endpoints for admin
 */

import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { compress } from 'hono/compress';
import { logger } from 'hono/logger';
import { landingPageHTML, landingPageCSS, landingPageJS } from './landing-page';
import { createAdminRouter } from '../admin/router';

type Env = {
  ASSETS: KVNamespace;
  DB: D1Database;
  COURSE_DATA: R2Bucket;
  TEACHER_JWT_SECRET: string;
  ADMIN_EMAIL: string;
  GOOGLE_CLIENT_ID: string;
  GOOGLE_CLIENT_SECRET: string;
  ENVIRONMENT: string;
};

const app = new Hono<{ Bindings: Env }>();

// Global middleware
app.use('*', logger());
app.use('*', cors({
  origin: ['https://writelao.xyz', 'https://www.writelao.xyz', 'http://localhost:8787', 'http://127.0.0.1:8787'],
  credentials: true,
}));

// Health check
app.get('/health', (c) => c.json({ status: 'ok', timestamp: new Date().toISOString() }));

// Public landing page (matches website/index.html content)
app.get('/', (c) => {
  const env = c.env?.ENVIRONMENT || 'development';
  return c.html(landingPageHTML, 200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'public, max-age=3600, stale-while-revalidate=86400',
    'X-Environment': env,
  });
});

// Static assets (CSS, JS from embedded strings for simplicity)
app.get('/styles.css', (c) => {
  return c.body(landingPageCSS, 200, {
    'Content-Type': 'text/css; charset=utf-8',
    'Cache-Control': 'public, max-age=86400, immutable',
  });
});

app.get('/script.js', (c) => {
  return c.body(landingPageJS, 200, {
    'Content-Type': 'application/javascript; charset=utf-8',
    'Cache-Control': 'public, max-age=86400, immutable',
  });
});

// Favicon
app.get('/favicon.svg', (c) => {
  return c.body(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="6" fill="#C8573F"/>
  <text x="16" y="24" font-family="serif" font-size="22" font-weight="bold" fill="#faf6ef" text-anchor="middle">ຂ</text>
</svg>`, 200, {
    'Content-Type': 'image/svg+xml',
    'Cache-Control': 'public, max-age=604800, immutable',
  });
});

// Admin routes (protected)
app.route('/admin', createAdminRouter());

// 404 handler
app.notFound((c) => {
  return c.html(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Page Not Found - Write Lao</title>
  <style>
    body { font-family: system-ui, sans-serif; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; background: #faf6ef; color: #1a1511; }
    main { text-align: center; padding: 2rem; }
    h1 { font-size: 3rem; color: #c8573f; margin: 0 0 1rem; }
    a { color: #c8573f; }
  </style>
</head>
<body>
  <main>
    <h1>404</h1>
    <p>The page you're looking for doesn't exist.</p>
    <a href="/">← Back to home</a>
  </main>
</body>
</html>`, 404);
});

export default app;
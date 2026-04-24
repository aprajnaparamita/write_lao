/**
 * Write Lao Website - Cloudflare Workers Entry Point
 * 
 * Routes:
 *   /           -> Public landing page (website/)
 *   /admin/*    -> Teacher admin dashboard
 *   /api/*      -> API endpoints for admin
 *   /assets/*   -> Static assets (images)
 */

import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { landingPageHTML, landingPageCSS, landingPageJS, i18nScript } from './landing-page';
import { heroScreenshotBase64 } from './hero-image';
import { thumbnailBase64 } from './thumbnail-image';
import { heroScreenshotBase64 as shot1Base64 } from './hero-image';
import { shot2Base64 } from './shot2-image';
import { shot3Base64 } from './shot3-image';
import { shot4Base64 } from './shot4-image';
import { faviconBase64 } from './favicon-image';
import { translations } from './translations';
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

// Hero screenshot
app.get('/assets/hero-screenshot.png', (c) => {
  if (heroScreenshotBase64) {
    return c.body(Buffer.from(heroScreenshotBase64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=86400, immutable',
    });
  }
  return c.text('Image not found', 404);
});

// Video thumbnail
app.get('/assets/thumbnail.png', (c) => {
  if (thumbnailBase64) {
    return c.body(Buffer.from(thumbnailBase64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=86400, immutable',
    });
  }
  return c.text('Image not found', 404);
});

// Screenshot images for screenshots section
app.get('/assets/shot-01.png', (c) => {
  if (shot1Base64) {
    return c.body(Buffer.from(shot1Base64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=86400, immutable',
    });
  }
  return c.text('Image not found', 404);
});

app.get('/assets/shot-02.png', (c) => {
  if (shot2Base64) {
    return c.body(Buffer.from(shot2Base64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=86400, immutable',
    });
  }
  return c.text('Image not found', 404);
});

app.get('/assets/shot-03.png', (c) => {
  if (shot3Base64) {
    return c.body(Buffer.from(shot3Base64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=86400, immutable',
    });
  }
  return c.text('Image not found', 404);
});

app.get('/assets/shot-04.png', (c) => {
  if (shot4Base64) {
    return c.body(Buffer.from(shot4Base64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=86400, immutable',
    });
  }
  return c.text('Image not found', 404);
});

// Favicon
app.get('/favicon.png', (c) => {
  if (faviconBase64) {
    return c.body(Buffer.from(faviconBase64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=604800, immutable',
    });
  }
  return c.text('Image not found', 404);
});

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
  // Combine main JS with i18n script
  return c.body(landingPageJS + '\n' + i18nScript, 200, {
    'Content-Type': 'application/javascript; charset=utf-8',
    'Cache-Control': 'public, max-age=86400, immutable',
  });
});

// i18n translation endpoint - serves JSON for specific locale
app.get('/i18n/:locale{.+\.json$}', (c) => {
  const locale = c.req.param('locale')?.replace('.json', '') || '';
  const localeTranslations = translations[locale];
  
  if (localeTranslations) {
    return c.json(localeTranslations, 200, {
      'Cache-Control': 'public, max-age=3600, stale-while-revalidate=86400',
    });
  }
  return c.json({ error: 'Locale not found' }, 404);
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
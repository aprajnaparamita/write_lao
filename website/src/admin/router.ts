/**
 * Admin Router - Teacher Dashboard for Write Lao
 * 
 * Features:
 * - Teacher authentication (JWT-based)
 * - Course content review and editing
 * - Audio recording and management
 * - Example sentence editing
 */

import { Hono } from 'hono';
import { getCookie, setCookie, deleteCookie } from 'hono/cookie';
import { adminHTML, loginHTML } from './admin-page';
import { authMiddleware, createTokens, verifyToken, TokenPayload } from '../lib/auth';
import { courseHandlers } from './course-handlers';
import { createTesterAdminRouter } from './tester-admin';

type Env = {
  ASSETS: KVNamespace;
  DB: D1Database;
  COURSE_DATA: R2Bucket;
  TEACHER_JWT_SECRET: string;
  ADMIN_EMAIL: string;
  ADMIN_PASSWORD: string;
  GOOGLE_CLIENT_ID: string;
  GOOGLE_CLIENT_SECRET: string;
  ENVIRONMENT: string;
  SENTRY_DSN: string;
};

type Variables = {
  teacher: {
    id: string;
    email: string;
    name: string;
  } | null;
};

export function createAdminRouter() {
  const admin = new Hono<{ Bindings: Env; Variables: Variables }>();

  // Global error handler
  admin.onError((err, c) => {
    console.error('Admin uncaught error:', err);
    return c.text('Internal Server Error: ' + (err as Error).message, 500);
  });

  // Auth middleware for all admin routes
  admin.use('/*', authMiddleware());

  // Login page
  admin.get('/login', (c) => {
    const teacher = c.get('teacher');
    if (teacher) {
      return c.redirect('/admin');
    }
    return c.html(loginHTML());
  });

  // Handle login
  admin.post('/login', async (c) => {
    const body = await c.req.parseBody();
    const email = body.email as string;
    const password = body.password as string;
    const adminEmail = c.env.ADMIN_EMAIL || 'admin@writelao.xyz';
    const adminPassword = c.env.ADMIN_PASSWORD || 'admin123';
    const secret = c.env.TEACHER_JWT_SECRET || 'dev-secret-change-me';

    // Simple auth - in production, check against D1 database with hashed passwords
    if (email === adminEmail && password === adminPassword) {
      const tokens = await createTokens({
        teacherId: '1',
        email,
        name: 'Teacher Admin',
      } as TokenPayload, secret);

      setCookie(c, 'auth_token', tokens.accessToken, {
        httpOnly: true,
        secure: true,
        sameSite: 'Strict',
        maxAge: 3600,
        path: '/admin',
      });
      setCookie(c, 'refresh_token', tokens.refreshToken, {
        httpOnly: true,
        secure: true,
        sameSite: 'Strict',
        maxAge: 604800,
        path: '/admin',
      });

      return c.redirect('/admin');
    }

    return c.html(loginHTML('Invalid credentials'), 401);
  });

  // Dashboard home
  admin.get('/', (c) => {
    const teacher = c.get('teacher');
    
    const content = `
      <div class="admin-header">
        <h1>Course Dashboard</h1>
        <p class="subtitle">Review and manage Write Lao course content</p>
      </div>
      
      <div class="dashboard-grid">
        <a href="/admin/words" class="dash-card">
          <div class="dash-icon">📚</div>
          <h2>Vocabulary</h2>
          <p>Review and edit 500 essential words with examples and audio</p>
        </a>
        
        <a href="/admin/lessons" class="dash-card">
          <div class="dash-icon">📖</div>
          <h2>Lessons</h2>
          <p>Manage alphabet lessons and lesson structure</p>
        </a>
        
        <a href="/admin/audio" class="dash-card">
          <div class="dash-icon">🎤</div>
          <h2>Audio</h2>
          <p>Record and manage native speaker audio recordings</p>
        </a>
        
        <a href="/admin/examples" class="dash-card">
          <div class="dash-icon">✏️</div>
          <h2>Examples</h2>
          <p>Edit example sentences for vocabulary words</p>
        </a>
        
        <a href="/admin/export" class="dash-card">
          <div class="dash-icon">📦</div>
          <h2>Export</h2>
          <p>Export course data bundle for app integration</p>
        </a>
        
        <a href="/admin/settings" class="dash-card">
          <div class="dash-icon">⚙️</div>
          <h2>Settings</h2>
          <p>Account settings and preferences</p>
        </a>
        
        <a href="/admin/tester" class="dash-card">
          <div class="dash-icon">🧪</div>
          <h2>Tester Videos</h2>
          <p>View and download tester video submissions by device</p>
        </a>
      </div>
      
      <script>
        // Update user info in sidebar
        document.getElementById('userName').textContent = '${teacher?.name || 'Teacher'}';
        document.getElementById('userEmail').textContent = '${teacher?.email || ''}';
        document.getElementById('userAvatar').textContent = '${teacher?.name?.charAt(0) || 'T'}';
      </script>
    `;
    
    return c.html(adminHTML(content));
  });

  // Course data routes
  admin.route('/words', courseHandlers.words);
  admin.route('/lessons', courseHandlers.lessons);
  admin.route('/audio', courseHandlers.audio);
  admin.route('/examples', courseHandlers.examples);
  admin.route('/export', courseHandlers.export);
  admin.route('/settings', courseHandlers.settings);

  // Tester video dashboard
  admin.route('/tester', createTesterAdminRouter());

  // Logout
  admin.post('/logout', (c) => {
    deleteCookie(c, 'auth_token');
    deleteCookie(c, 'refresh_token');
    return c.redirect('/admin/login');
  });

  return admin;
}

export const adminRouter = createAdminRouter();
export { authMiddleware, createTokens, verifyToken } from '../lib/auth';
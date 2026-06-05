/**
 * Tester Admin Dashboard — Video Submission Reports
 * 
 * Admin interface for viewing tester submissions, downloading videos
 * by device, and generating combined video compilations.
 */

import { Hono } from 'hono';
import { html } from 'hono/html';
import { captureException } from '@sentry/cloudflare';

type Env = {
  ASSETS: Fetcher;
  DB: D1Database;
  COURSE_DATA: R2Bucket;
  TEACHER_JWT_SECRET: string;
  ADMIN_EMAIL: string;
  ADMIN_PASSWORD: string;
  GOOGLE_CLIENT_ID: string;
  GOOGLE_CLIENT_SECRET: string;
  ENVIRONMENT: string;
  BREVO_API_KEY: string;
  SENTRY_DSN: string;
};

function errorPage(message: string) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Error — Tester Admin</title>
  <style>
    body { font-family: system-ui, sans-serif; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; background: #faf6ef; }
    .error-box { background: #fff; padding: 2rem; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); width: 100%; max-width: 500px; }
    h1 { margin: 0 0 0.5rem; color: #dc2626; font-size: 1.5rem; }
    p { color: #6b5a4a; margin: 0 0 1.5rem; }
    .message { background: #fee2e2; border: 1px solid #fca5a5; border-radius: 8px; padding: 1rem; font-family: monospace; font-size: 0.875rem; color: #991b1b; word-break: break-all; }
    a { color: #c8573f; }
  </style>
</head>
<body>
  <div class="error-box">
    <h1>Server Error</h1>
    <p>Something went wrong. The error has been logged.</p>
    <div class="message">${escapeHtml(message)}</div>
    <p style="margin-top: 1.5rem;"><a href="/admin/tester">Try again</a></p>
  </div>
</body>
</html>`;
}

function isToday(dateStr: string | null): boolean {
  if (!dateStr) return false;
  const date = new Date(dateStr);
  const today = new Date();
  return date.toDateString() === today.toDateString();
}

function formatDate(dateStr: string | null): string {
  if (!dateStr) return 'Unknown';
  return new Date(dateStr).toLocaleString();
}

function groupByDevice(submissions: any[]) {
  const groups: Record<string, any> = {};
  
  for (const sub of submissions) {
    const key = sub.device_model + '-' + sub.os_version;
    if (!groups[key]) {
      groups[key] = {
        model: sub.device_model,
        os: sub.os_version,
        appVersion: sub.app_version,
        tester: sub.tester_name,
        videos: [],
      };
    }
    groups[key].videos.push({
      id: sub.id,
      filename: sub.filename,
      section: sub.section,
      testerName: sub.tester_name,
      uploadedAt: sub.uploaded_at,
    });
  }
  
  return Object.values(groups);
}

function escapeHtml(str: string): string {
  return str.replace(/&/g, '&').replace(/</g, '<').replace(/>/g, '>').replace(/"/g, '"');
}

// Dashboard page
function dashboardPage(submissions: any[], devices: any[]) {
  const groups = groupByDevice(submissions);
  const totalVideos = submissions.length;
  const todayCount = submissions.filter((s: any) => isToday(s.uploaded_at)).length;
  const deviceCount = devices.length;
  
  let submissionsHtml = '';
  
  if (submissions.length === 0) {
    submissionsHtml = `<div class="empty">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
      <p>No video submissions yet.</p>
      <p>Share the <a href="/tester-guide">Tester Guide</a> with your team.</p>
    </div>`;
  } else {
    const deviceGroupsHtml = groups.map((device: any) => {
      const videosHtml = device.videos.map((v: any) => {
        return `<div class="video-item" data-section="${escapeHtml(v.section)}">
          <span class="section-badge">${escapeHtml(v.section)}</span>
          <div class="info">
            <div class="tester">${escapeHtml(v.testerName)}</div>
            <div class="date">${formatDate(v.uploadedAt)}</div>
          </div>
          <div class="actions">
            <a href="/api/tester/video/${encodeURIComponent(v.filename)}" target="_blank">View</a>
            <button class="download-all" onclick="downloadSingle('${encodeURIComponent(v.filename)}')">Download</button>
            <button class="delete" onclick="deleteVideo(${v.id}, this)">Delete</button>
          </div>
        </div>`;
      }).join('');
      
      return `<div class="device-group" data-device="${escapeHtml(device.model)}">
        <div class="device-header" onclick="toggleDevice(this)">
          <div>
            <h3>${escapeHtml(device.model)}</h3>
            <div class="meta">${escapeHtml(device.os)} \u00b7 App v${escapeHtml(device.appVersion)} \u00b7 ${escapeHtml(device.tester)}</div>
          </div>
          <div style="display: flex; align-items: center; gap: 1rem;">
            <span class="count">${device.videos.length} videos</span>
            <svg class="chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
          </div>
        </div>
        <div class="device-content">
          <div class="video-list">
            ${videosHtml}
          </div>
          <button class="download-zip" style="margin-top: 1rem;" onclick="downloadDeviceZip('${escapeHtml(device.model).replace(/'/g, "\\'")}')">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            Download All for ${escapeHtml(device.model)}
          </button>
        </div>
      </div>`;
    }).join('');
    
    submissionsHtml = `
      <div class="section-tabs">
        <button class="section-tab active" onclick="filterBySection(null)">All</button>
        <button class="section-tab" onclick="filterBySection('launch')">Launch</button>
        <button class="section-tab" onclick="filterBySection('lessons')">Lessons</button>
        <button class="section-tab" onclick="filterBySection('practice')">Practice</button>
        <button class="section-tab" onclick="filterBySection('test')">Test</button>
        <button class="section-tab" onclick="filterBySection('vocab')">Vocab</button>
        <button class="section-tab" onclick="filterBySection('review')">Review</button>
        <button class="section-tab" onclick="filterBySection('progress')">Progress</button>
        <button class="section-tab" onclick="filterBySection('settings')">Settings</button>
        <button class="section-tab" onclick="filterBySection('iap')">IAP</button>
        <button class="section-tab" onclick="filterBySection('offline')">Offline</button>
      </div>
 ${deviceGroupsHtml}
    `;
  }
  
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tester Video Dashboard — Write Lao</title>
  <style>
    :root { --cream: #faf6ef; --cream-2: #f2ebdd; --ink: #1a1511; --muted: #6b5a4a; --saffron: #c8573f; --saffron-dark: #a8432e; --line: #e6ddcd; --success: #16a34a; --error: #dc2626; }
    * { box-sizing: border-box; }
    body { margin: 0; font-family: system-ui, sans-serif; font-size: 1rem; background: var(--cream); color: var(--ink); }
    header { background: var(--ink); color: #fff; padding: 1rem 1.5rem; display: flex; justify-content: space-between; align-items: center; }
    header h1 { margin: 0; font-size: 1.125rem; }
    header a { color: rgba(255,255,255,0.8); text-decoration: none; }
    header a:hover { color: #fff; }
    .container { max-width: 1400px; margin: 0 auto; padding: 1.5rem; }
    .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 1rem; margin-bottom: 2rem; }
    .stat-card { background: #fff; padding: 1.25rem; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
    .stat-card .label { font-size: 0.8125rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.5px; }
    .stat-card .value { font-size: 2rem; font-weight: 700; color: var(--saffron); }
    .section-tabs { display: flex; gap: 0.5rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
    .section-tab { padding: 0.5rem 1rem; background: #fff; border: 1.5px solid var(--line); border-radius: 20px; cursor: pointer; font-size: 0.875rem; font-weight: 600; }
    .section-tab:hover { border-color: var(--saffron); }
    .section-tab.active { background: var(--saffron); color: #fff; border-color: var(--saffron); }
    .device-group { background: #fff; border-radius: 12px; margin-bottom: 1.5rem; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
    .device-header { background: var(--cream-2); padding: 1rem 1.25rem; display: flex; justify-content: space-between; align-items: center; cursor: pointer; }
    .device-header:hover { background: #ebe5d8; }
    .device-header h3 { margin: 0; font-size: 1rem; }
    .device-header .meta { font-size: 0.8125rem; color: var(--muted); }
    .device-header .count { background: var(--saffron); color: #fff; padding: 0.25rem 0.75rem; border-radius: 12px; font-size: 0.8125rem; font-weight: 600; }
    .device-content { display: none; padding: 1rem 1.25rem; }
    .device-group.open .device-content { display: block; }
    .video-list { display: grid; gap: 0.75rem; }
    .video-item { display: flex; align-items: center; gap: 1rem; padding: 0.75rem; background: var(--cream); border-radius: 8px; }
    .video-item .section-badge { background: var(--ink); color: #fff; padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; min-width: 80px; text-align: center; }
    .video-item .info { flex: 1; }
    .video-item .tester { font-weight: 600; font-size: 0.875rem; }
    .video-item .date { font-size: 0.75rem; color: var(--muted); }
    .video-item .actions { display: flex; gap: 0.5rem; }
    .video-item a, .video-item button { padding: 0.4rem 0.75rem; font: inherit; font-size: 0.8125rem; font-weight: 600; border-radius: 6px; cursor: pointer; text-decoration: none; border: none; }
    .video-item a { background: var(--saffron); color: #fff; }
    .video-item a:hover { background: var(--saffron-dark); }
    .video-item button.download-all { background: var(--success); color: #fff; }
    .video-item button.download-all:hover { background: #15803d; }
    .video-item button.delete { background: #fee2e2; color: var(--error); }
    .video-item button.delete:hover { background: #fecaca; }
    .empty { text-align: center; padding: 3rem; color: var(--muted); }
    .empty svg { width: 64px; height: 64px; opacity: 0.5; margin-bottom: 1rem; }
    .empty a { color: var(--saffron); }
    .download-zip { display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.75rem 1.5rem; background: var(--success); color: #fff; border: none; border-radius: 8px; font-weight: 700; cursor: pointer; margin-bottom: 1.5rem; }
    .download-zip:hover { background: #15803d; }
    .download-zip svg { width: 20px; height: 20px; }
    .chevron { width: 20px; height: 20px; transition: transform 0.2s; }
    .device-group.open .chevron { transform: rotate(180deg); }
    @media print { header, .section-tabs, .actions, .download-zip { display: none; } .device-content { display: block !important; } }
  </style>
</head>
<body>
  <header>
    <h1>Tester Video Dashboard</h1>
    <a href="/admin">← Back to Admin</a>
  </header>
  
  <div class="container">
    <div class="stats">
      <div class="stat-card">
        <div class="label">Total Videos</div>
        <div class="value">${totalVideos}</div>
      </div>
      <div class="stat-card">
        <div class="label">Devices</div>
        <div class="value">${deviceCount}</div>
      </div>
      <div class="stat-card">
        <div class="label">Submissions Today</div>
        <div class="value">${todayCount}</div>
      </div>
    </div>
    
    <button class="download-zip" onclick="downloadAllAsZip()">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
      Download All Videos
    </button>
    
    ${submissionsHtml}
  </div>
  
  <script>
    function toggleDevice(header) {
      header.closest('.device-group').classList.toggle('open');
    }
    
    function filterBySection(section) {
      document.querySelectorAll('.section-tab').forEach(tab => {
        tab.classList.toggle('active', !section || tab.textContent.toLowerCase() === section.toLowerCase());
      });
      
      document.querySelectorAll('.video-item').forEach(item => {
        if (!section) {
          item.style.display = '';
        } else {
          item.style.display = item.dataset.section === section ? '' : 'none';
        }
      });
    }
    
    async function deleteVideo(id, btn) {
      if (!confirm('Delete this video submission?')) return;
      
      try {
        const res = await fetch('/api/tester/submission/' + id, { method: 'DELETE' });
        if (res.ok) {
          btn.closest('.video-item').remove();
        } else {
          alert('Failed to delete');
        }
      } catch (err) {
        alert('Error: ' + err.message);
      }
    }
    
    function downloadSingle(filename) {
      window.open('/api/tester/video/' + filename, '_blank');
    }
    
    async function downloadDeviceZip(deviceModel) {
      const items = document.querySelectorAll('.device-group[data-device="' + deviceModel + '"] .video-item');
      for (const item of items) {
        const link = item.querySelector('a[href*="/api/tester/video/"]');
        if (link) {
          window.open(link.href, '_blank');
          await new Promise(r => setTimeout(r, 500));
        }
      }
    }
    
    async function downloadAllAsZip() {
      const items = document.querySelectorAll('.video-item');
      for (const item of items) {
        const link = item.querySelector('a[href*="/api/tester/video/"]');
        if (link) {
          window.open(link.href, '_blank');
          await new Promise(r => setTimeout(r, 300));
        }
      }
    }
    
    // Open first device group by default
    document.querySelector('.device-group')?.classList.add('open');
  </script>
</body>
</html>`;
}

export function createTesterAdminRouter() {
  const app = new Hono<{ Bindings: Env }>();
  
  // Global error handler - catch ALL errors
  app.onError((err, c) => {
    console.error('Tester admin uncaught error:', err);
    try {
      captureException(err);
    } catch (_) {}
    return c.html(errorPage('Uncaught error: ' + (err as Error).message), 500);
  });
  
  // Dashboard (no extra auth — main admin middleware already protects /admin/*)
  app.get('/', async (c) => {
    try {
      const db = c.env.DB;
      
      const submissions = await db.prepare(`
        SELECT id, filename, section, device_model, os_version, app_version, tester_name, uploaded_at
        FROM tester_submissions
        ORDER BY uploaded_at DESC
      `).all();
      
      const devices = await db.prepare(`
        SELECT DISTINCT device_model, os_version, app_version
        FROM tester_submissions
        ORDER BY device_model, os_version
      `).all();
      
      return c.html(dashboardPage(submissions.results, devices.results));
    } catch (err) {
      console.error('Tester admin error:', err);
      try {
        captureException(err);
      } catch (_) {}
      return c.html(errorPage('Failed to load submissions: ' + (err as Error).message), 500);
    }
  });
  
  return app;
}

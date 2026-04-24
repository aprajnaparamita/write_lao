/**
 * Admin page HTML template
 * Teacher dashboard for course content management
 */

export function adminHTML(content: string, title = 'Admin Dashboard - Write Lao'): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Noto+Sans+Lao:wght@500;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg: #0f1419;
      --surface: #1a1f2e;
      --surface-2: #252d3d;
      --border: #2d3748;
      --text: #e8ecf0;
      --text-muted: #8899a6;
      --saffron: #c8573f;
      --saffron-dark: #a8432e;
      --saffron-tint: #f5e4de;
      --teal: #1e3a3a;
      --gold: #d4a574;
      --success: #00c853;
      --error: #ff5252;
      --font-body: "Inter", system-ui, sans-serif;
      --font-lao: "Noto Sans Lao", var(--font-body);
    }
    
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: var(--font-body);
      background: var(--bg);
      color: var(--text);
      min-height: 100vh;
      line-height: 1.5;
    }
    
    /* Layout */
    .admin-layout {
      display: flex;
      min-height: 100vh;
    }
    
    .sidebar {
      width: 260px;
      background: var(--surface);
      border-right: 1px solid var(--border);
      padding: 1.5rem;
      position: fixed;
      height: 100vh;
      overflow-y: auto;
    }
    
    .sidebar-brand {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding-bottom: 1.5rem;
      border-bottom: 1px solid var(--border);
      margin-bottom: 1.5rem;
    }
    
    .brand-mark {
      font-family: var(--font-lao);
      font-size: 1.75rem;
      color: var(--saffron);
      font-weight: 700;
    }
    
    .brand-name {
      font-weight: 700;
      font-size: 1.125rem;
    }
    
    .brand-sub {
      font-size: 0.75rem;
      color: var(--text-muted);
    }
    
    .nav-section {
      margin-bottom: 1.5rem;
    }
    
    .nav-section-title {
      font-size: 0.6875rem;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      color: var(--text-muted);
      margin-bottom: 0.75rem;
      font-weight: 600;
    }
    
    .nav-link {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0.625rem 0.875rem;
      border-radius: 8px;
      color: var(--text-muted);
      text-decoration: none;
      font-size: 0.9375rem;
      font-weight: 500;
      transition: all 0.15s ease;
    }
    
    .nav-link:hover {
      background: var(--surface-2);
      color: var(--text);
    }
    
    .nav-link.active {
      background: var(--saffron);
      color: white;
    }
    
    .nav-link-icon {
      font-size: 1.25rem;
      width: 24px;
      text-align: center;
    }
    
    .sidebar-footer {
      margin-top: auto;
      padding-top: 1.5rem;
      border-top: 1px solid var(--border);
    }
    
    .user-info {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0.75rem;
      background: var(--surface-2);
      border-radius: 8px;
      margin-bottom: 1rem;
    }
    
    .user-avatar {
      width: 36px;
      height: 36px;
      border-radius: 50%;
      background: var(--saffron);
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 0.875rem;
    }
    
    .user-details {
      flex: 1;
      min-width: 0;
    }
    
    .user-name {
      font-weight: 600;
      font-size: 0.875rem;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    
    .user-email {
      font-size: 0.75rem;
      color: var(--text-muted);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    
    .logout-btn {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.625rem 0.875rem;
      border-radius: 8px;
      color: var(--text-muted);
      text-decoration: none;
      font-size: 0.875rem;
      font-weight: 500;
      background: none;
      border: none;
      cursor: pointer;
      width: 100%;
      transition: all 0.15s ease;
    }
    
    .logout-btn:hover {
      background: var(--error);
      color: white;
    }
    
    /* Main content */
    .main-content {
      flex: 1;
      margin-left: 260px;
      padding: 2rem;
    }
    
    .admin-header {
      margin-bottom: 2rem;
    }
    
    .admin-header h1 {
      font-size: 1.75rem;
      font-weight: 700;
      margin-bottom: 0.5rem;
    }
    
    .admin-header .subtitle {
      color: var(--text-muted);
    }
    
    /* Dashboard grid */
    .dashboard-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 1rem;
    }
    
    .dash-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 1.5rem;
      text-decoration: none;
      color: inherit;
      transition: all 0.2s ease;
    }
    
    .dash-card:hover {
      border-color: var(--saffron);
      transform: translateY(-2px);
    }
    
    .dash-icon {
      font-size: 2rem;
      margin-bottom: 1rem;
    }
    
    .dash-card h2 {
      font-size: 1.125rem;
      font-weight: 600;
      margin-bottom: 0.5rem;
    }
    
    .dash-card p {
      color: var(--text-muted);
      font-size: 0.875rem;
    }
    
    /* Cards and panels */
    .panel {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 1.5rem;
      margin-bottom: 1.5rem;
    }
    
    .panel-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 1rem;
      padding-bottom: 1rem;
      border-bottom: 1px solid var(--border);
    }
    
    .panel-title {
      font-size: 1.125rem;
      font-weight: 600;
    }
    
    /* Buttons */
    .btn {
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.625rem 1rem;
      border-radius: 8px;
      font-weight: 500;
      font-size: 0.875rem;
      border: none;
      cursor: pointer;
      text-decoration: none;
      transition: all 0.15s ease;
    }
    
    .btn-primary {
      background: var(--saffron);
      color: white;
    }
    
    .btn-primary:hover {
      background: var(--saffron-dark);
    }
    
    .btn-secondary {
      background: var(--surface-2);
      color: var(--text);
    }
    
    .btn-secondary:hover {
      background: var(--border);
    }
    
    .btn-success {
      background: var(--success);
      color: white;
    }
    
    .btn-danger {
      background: var(--error);
      color: white;
    }
    
    /* Forms */
    .form-group {
      margin-bottom: 1rem;
    }
    
    .form-label {
      display: block;
      font-size: 0.875rem;
      font-weight: 500;
      margin-bottom: 0.5rem;
      color: var(--text-muted);
    }
    
    .form-input {
      width: 100%;
      padding: 0.75rem 1rem;
      border: 1px solid var(--border);
      border-radius: 8px;
      background: var(--surface-2);
      color: var(--text);
      font-size: 0.9375rem;
      font-family: inherit;
    }
    
    .form-input:focus {
      outline: none;
      border-color: var(--saffron);
    }
    
    .form-textarea {
      min-height: 120px;
      resize: vertical;
    }
    
    /* Tables */
    .table-container {
      overflow-x: auto;
    }
    
    table {
      width: 100%;
      border-collapse: collapse;
    }
    
    th, td {
      padding: 0.875rem 1rem;
      text-align: left;
      border-bottom: 1px solid var(--border);
    }
    
    th {
      font-size: 0.75rem;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--text-muted);
      font-weight: 600;
    }
    
    td {
      font-size: 0.9375rem;
    }
    
    tr:hover {
      background: var(--surface-2);
    }
    
    /* Badges */
    .badge {
      display: inline-flex;
      align-items: center;
      padding: 0.25rem 0.625rem;
      border-radius: 9999px;
      font-size: 0.75rem;
      font-weight: 500;
    }
    
    .badge-success {
      background: rgba(0, 200, 83, 0.15);
      color: var(--success);
    }
    
    .badge-warning {
      background: rgba(255, 193, 7, 0.15);
      color: #ffc107;
    }
    
    .badge-error {
      background: rgba(255, 82, 82, 0.15);
      color: var(--error);
    }
    
    .badge-neutral {
      background: var(--surface-2);
      color: var(--text-muted);
    }
    
    /* Laoword display */
    .lao-text {
      font-family: var(--font-lao);
      font-size: 1.5rem;
      color: var(--saffron);
    }
    
    /* Audio recorder */
    .audio-recorder {
      background: var(--surface-2);
      border-radius: 12px;
      padding: 1.5rem;
      text-align: center;
    }
    
    .record-btn {
      width: 80px;
      height: 80px;
      border-radius: 50%;
      background: var(--saffron);
      border: 4px solid var(--surface);
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      font-size: 2rem;
      transition: all 0.2s ease;
    }
    
    .record-btn:hover {
      transform: scale(1.05);
    }
    
    .record-btn.recording {
      background: var(--error);
      animation: pulse 1s infinite;
    }
    
    @keyframes pulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.05); }
    }
    
    .waveform {
      height: 60px;
      background: var(--surface);
      border-radius: 8px;
      margin: 1rem 0;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 2px;
    }
    
    .waveform-bar {
      width: 3px;
      height: 20px;
      background: var(--saffron);
      border-radius: 2px;
      animation: wave 0.5s ease-in-out infinite;
    }
    
    @keyframes wave {
      0%, 100% { height: 10px; }
      50% { height: 40px; }
    }
    
    /* Pagination */
    .pagination {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
      margin-top: 1.5rem;
    }
    
    .page-btn {
      width: 36px;
      height: 36px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border-radius: 8px;
      background: var(--surface-2);
      border: none;
      color: var(--text);
      cursor: pointer;
      font-weight: 500;
    }
    
    .page-btn:hover {
      background: var(--border);
    }
    
    .page-btn.active {
      background: var(--saffron);
      color: white;
    }
    
    .page-btn:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
    
    /* Status messages */
    .toast {
      position: fixed;
      bottom: 2rem;
      right: 2rem;
      padding: 1rem 1.5rem;
      border-radius: 8px;
      background: var(--surface);
      border: 1px solid var(--border);
      color: var(--text);
      font-weight: 500;
      z-index: 1000;
      animation: slideIn 0.3s ease;
    }
    
    .toast.success {
      border-color: var(--success);
    }
    
    .toast.error {
      border-color: var(--error);
    }
    
    @keyframes slideIn {
      from { transform: translateX(100%); opacity: 0; }
      to { transform: translateX(0); opacity: 1; }
    }
    
    /* Loading spinner */
    .spinner {
      width: 24px;
      height: 24px;
      border: 3px solid var(--border);
      border-top-color: var(--saffron);
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }
    
    @keyframes spin {
      to { transform: rotate(360deg); }
    }
    
    /* Responsive */
    @media (max-width: 900px) {
      .sidebar {
        width: 100%;
        position: relative;
        height: auto;
        border-right: none;
        border-bottom: 1px solid var(--border);
      }
      
      .admin-layout {
        flex-direction: column;
      }
      
      .main-content {
        margin-left: 0;
      }
    }
  </style>
</head>
<body>
  <div class="admin-layout">
    <aside class="sidebar">
      <a href="/admin" class="sidebar-brand">
        <span class="brand-mark">&#3585;</span>
        <div>
          <div class="brand-name">Write Lao</div>
          <div class="brand-sub">Admin Dashboard</div>
        </div>
      </a>
      
      <nav class="nav-section">
        <div class="nav-section-title">Content</div>
        <a href="/admin/words" class="nav-link">
          <span class="nav-link-icon">📚</span>
          Vocabulary
        </a>
        <a href="/admin/lessons" class="nav-link">
          <span class="nav-link-icon">📖</span>
          Lessons
        </a>
        <a href="/admin/examples" class="nav-link">
          <span class="nav-link-icon">✏️</span>
          Examples
        </a>
      </nav>
      
      <nav class="nav-section">
        <div class="nav-section-title">Media</div>
        <a href="/admin/audio" class="nav-link">
          <span class="nav-link-icon">🎤</span>
          Audio Recordings
        </a>
      </nav>
      
      <nav class="nav-section">
        <div class="nav-section-title">System</div>
        <a href="/admin/export" class="nav-link">
          <span class="nav-link-icon">📦</span>
          Export Bundle
        </a>
        <a href="/admin/settings" class="nav-link">
          <span class="nav-link-icon">⚙️</span>
          Settings
        </a>
      </nav>
      
      <div class="sidebar-footer">
        <div class="user-info">
          <div class="user-avatar" id="userAvatar">T</div>
          <div class="user-details">
            <div class="user-name" id="userName">Teacher</div>
            <div class="user-email" id="userEmail">teacher@email.com</div>
          </div>
        </div>
        <form action="/admin/logout" method="POST">
          <button type="submit" class="logout-btn">
            <span>🚪</span> Sign out
          </button>
        </form>
      </div>
    </aside>
    
    <main class="main-content">
      ${content}
    </main>
  </div>
  
  <script>
    // Toast notifications
    function showToast(message, type = 'success') {
      const toast = document.createElement('div');
      toast.className = \`toast \${type}\`;
      toast.textContent = message;
      document.body.appendChild(toast);
      setTimeout(() => toast.remove(), 3000);
    }
    
    // Audio recorder
    class AudioRecorder {
      constructor(onDataAvailable) {
        this.onDataAvailable = onDataAvailable;
        this.mediaRecorder = null;
        this.audioChunks = [];
      }
      
      async start() {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        this.mediaRecorder = new MediaRecorder(stream);
        this.audioChunks = [];
        
        this.mediaRecorder.ondataavailable = (e) => {
          this.audioChunks.push(e.data);
        };
        
        this.mediaRecorder.onstop = () => {
          const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
          this.onDataAvailable(audioBlob);
          stream.getTracks().forEach(track => track.stop());
        };
        
        this.mediaRecorder.start();
      }
      
      stop() {
        if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
          this.mediaRecorder.stop();
        }
      }
      
      isRecording() {
        return this.mediaRecorder && this.mediaRecorder.state === 'recording';
      }
    }
    
    // Pagination helper
    function updatePagination(current, total, onPageChange) {
      const container = document.querySelector('.pagination');
      if (!container) return;
      
      container.innerHTML = '';
      
      const prevBtn = document.createElement('button');
      prevBtn.className = 'page-btn';
      prevBtn.textContent = '◀';
      prevBtn.disabled = current === 1;
      prevBtn.onclick = () => onPageChange(current - 1);
      container.appendChild(prevBtn);
      
      const maxPages = 7;
      let start = Math.max(1, current - 3);
      let end = Math.min(total, start + maxPages - 1);
      if (end - start < maxPages - 1) {
        start = Math.max(1, end - maxPages + 1);
      }
      
      if (start > 1) {
        const firstBtn = document.createElement('button');
        firstBtn.className = 'page-btn';
        firstBtn.textContent = '1';
        firstBtn.onclick = () => onPageChange(1);
        container.appendChild(firstBtn);
        if (start > 2) {
          container.appendChild(Object.assign(document.createElement('span'), { textContent: '...' }));
        }
      }
      
      for (let i = start; i <= end; i++) {
        const btn = document.createElement('button');
        btn.className = \`page-btn \${i === current ? 'active' : ''}\`;
        btn.textContent = String(i);
        btn.onclick = () => onPageChange(i);
        container.appendChild(btn);
      }
      
      if (end < total) {
        if (end < total - 1) {
          container.appendChild(Object.assign(document.createElement('span'), { textContent: '...' }));
        }
        const lastBtn = document.createElement('button');
        lastBtn.className = 'page-btn';
        lastBtn.textContent = String(total);
        lastBtn.onclick = () => onPageChange(total);
        container.appendChild(lastBtn);
      }
      
      const nextBtn = document.createElement('button');
      nextBtn.className = 'page-btn';
      nextBtn.textContent = '▶';
      nextBtn.disabled = current === total;
      nextBtn.onclick = () => onPageChange(current + 1);
      container.appendChild(nextBtn);
    }
  </script>
</body>
</html>`;
}

export function loginHTML(error = ''): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sign In - Write Lao Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg: #0f1419;
      --surface: #1a1f2e;
      --border: #2d3748;
      --text: #e8ecf0;
      --text-muted: #8899a6;
      --saffron: #c8573f;
      --saffron-dark: #a8432e;
      --error: #ff5252;
    }
    
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: "Inter", system-ui, sans-serif;
      background: var(--bg);
      color: var(--text);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    }
    
    .login-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 2.5rem;
      width: 100%;
      max-width: 400px;
    }
    
    .brand {
      text-align: center;
      margin-bottom: 2rem;
    }
    
    .brand-mark {
      font-family: "Noto Sans Lao", serif;
      font-size: 3rem;
      color: var(--saffron);
      font-weight: 700;
    }
    
    .brand-name {
      font-size: 1.5rem;
      font-weight: 700;
      margin-top: 0.5rem;
    }
    
    .brand-sub {
      color: var(--text-muted);
      font-size: 0.875rem;
      margin-top: 0.25rem;
    }
    
    .form-group {
      margin-bottom: 1.25rem;
    }
    
    .form-label {
      display: block;
      font-size: 0.875rem;
      font-weight: 500;
      margin-bottom: 0.5rem;
      color: var(--text-muted);
    }
    
    .form-input {
      width: 100%;
      padding: 0.875rem 1rem;
      border: 1px solid var(--border);
      border-radius: 8px;
      background: var(--bg);
      color: var(--text);
      font-size: 1rem;
      font-family: inherit;
    }
    
    .form-input:focus {
      outline: none;
      border-color: var(--saffron);
    }
    
    .btn {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
      width: 100%;
      padding: 0.875rem;
      border-radius: 8px;
      font-weight: 600;
      font-size: 1rem;
      border: none;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    
    .btn-primary {
      background: var(--saffron);
      color: white;
      margin-top: 0.5rem;
    }
    
    .btn-primary:hover {
      background: var(--saffron-dark);
    }
    
    .error-msg {
      background: rgba(255, 82, 82, 0.1);
      border: 1px solid var(--error);
      color: var(--error);
      padding: 0.75rem 1rem;
      border-radius: 8px;
      margin-bottom: 1.5rem;
      font-size: 0.875rem;
    }
    
    .footer {
      text-align: center;
      margin-top: 2rem;
      padding-top: 1.5rem;
      border-top: 1px solid var(--border);
      color: var(--text-muted);
      font-size: 0.875rem;
    }
  </style>
</head>
<body>
  <div class="login-card">
    <div class="brand">
      <span class="brand-mark">&#3585;</span>
      <div class="brand-name">Write Lao</div>
      <div class="brand-sub">Teacher Dashboard</div>
    </div>
    
    ${error ? `<div class="error-msg">${error}</div>` : ''}
    
    <form action="/admin/login" method="POST">
      <div class="form-group">
        <label class="form-label" for="email">Email</label>
        <input type="email" id="email" name="email" class="form-input" required autocomplete="email">
      </div>
      
      <div class="form-group">
        <label class="form-label" for="password">Password</label>
        <input type="password" id="password" name="password" class="form-input" required autocomplete="current-password">
      </div>
      
      <button type="submit" class="btn btn-primary">Sign In</button>
    </form>
    
    <div class="footer">
      <a href="/" style="color: var(--saffron);">← Back to website</a>
    </div>
  </div>
</body>
</html>`;
}
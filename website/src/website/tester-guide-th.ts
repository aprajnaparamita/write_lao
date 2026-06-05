/**
 * Manual App Tester Guide — Write Lao (Thai)
 * 
 * A simplified, step-by-step guide for manual testers to quickly test
 * each feature and submit video evidence. Thai version.
 */

// ── Tester Guide HTML (Thai) ──────────────────────────────────────────
export const testerGuideHTMLThai = `<!DOCTYPE html>
<html lang="th">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>คู่มือทดสอบแอป — Write Lao</title>
  <style>
    :root {
      --cream: #faf6ef;
      --cream-2: #f2ebdd;
      --ink: #1a1511;
      --ink-soft: #3a312a;
      --muted: #6b5a4a;
      --saffron: #c8573f;
      --saffron-dark: #a8432e;
      --saffron-tint: #f5e4de;
      --teal: #1e3a3a;
      --line: #e6ddcd;
      --success: #16a34a;
      --warning: #ca8a04;
      --error: #dc2626;
    }
    *, *::before, *::after { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: system-ui, -apple-system, sans-serif;
      font-size: 1rem;
      line-height: 1.65;
      color: var(--ink);
      background: var(--cream);
      -webkit-font-smoothing: antialiased;
    }
    .container { max-width: 900px; margin: 0 auto; padding: 2rem 1.5rem 4rem; }
    .back {
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      color: var(--saffron);
      font-weight: 600;
      font-size: 0.9375rem;
      text-decoration: none;
      margin-bottom: 2rem;
    }
    .back:hover { text-decoration: underline; }
    h1 { font-size: 2rem; font-weight: 700; margin: 0 0 0.5rem; color: var(--ink); }
    .subtitle { color: var(--muted); font-size: 1.0625rem; margin-bottom: 2.5rem; }
    
    /* Device Info Setup Visual Guide */
    .setup-guide {
      background: #fff;
      border: 2px solid var(--teal);
      border-radius: 16px;
      margin-bottom: 1.5rem;
      overflow: hidden;
    }
    .setup-guide-header {
      background: var(--teal);
      color: #fff;
      padding: 1rem 1.25rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
      cursor: pointer;
    }
    .setup-guide-header:hover { background: #163535; }
    .setup-guide-header h3 { margin: 0; font-size: 1rem; display: flex; align-items: center; gap: 0.5rem; }
    .setup-guide-header svg { width: 20px; height: 20px; }
    .setup-guide-header .completed-badge {
      background: #fff;
      color: var(--teal);
      padding: 0.25rem 0.75rem;
      border-radius: 20px;
      font-size: 0.75rem;
      font-weight: 700;
      text-transform: uppercase;
    }
    .setup-guide-content {
      display: none;
      padding: 1.5rem;
    }
    .setup-guide.open .setup-guide-content { display: block; }
    .setup-guide.open .setup-guide-header { border-radius: 0; }
    
    /* Step cards */
    .step-card {
      background: var(--cream);
      border: 1px solid var(--line);
      border-radius: 12px;
      padding: 1rem;
      margin-bottom: 1rem;
    }
    .step-card:last-child { margin-bottom: 0; }
    .step-card-header {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      margin-bottom: 0.75rem;
    }
    .step-card-header .step-num {
      width: 28px;
      height: 28px;
      border-radius: 50%;
      background: var(--teal);
      color: #fff;
      font-weight: 700;
      font-size: 0.875rem;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }
    .step-card-header h4 { margin: 0; font-size: 0.9375rem; }
    .step-card p { margin: 0 0 0.75rem; font-size: 0.875rem; color: var(--ink-soft); }
    .step-card img {
      width: 100%;
      max-width: 320px;
      border-radius: 8px;
      border: 2px solid var(--line);
      margin: 0.5rem 0;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    
    /* Device fields in setup guide - LARGE inputs */
    .device-fields-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 1rem;
      margin-bottom: 1rem;
    }
    @media (max-width: 640px) {
      .device-fields-grid { grid-template-columns: 1fr; }
    }
    .device-field-input label {
      display: block;
      font-weight: 600;
      font-size: 1rem;
      margin-bottom: 0.5rem;
      color: var(--ink);
    }
    .device-field-input input {
      width: 100%;
      padding: 1rem 1.25rem;
      font: inherit;
      font-size: 1.125rem;
      border: 2px solid var(--line);
      border-radius: 12px;
      background: #fff;
      color: var(--ink);
      transition: border-color 0.15s, box-shadow 0.15s;
    }
    .device-field-input input:focus {
      outline: none;
      border-color: var(--teal);
      box-shadow: 0 0 0 3px rgba(30,90,90,0.15);
    }
    .device-field-input input::placeholder { color: var(--muted); }
    
    /* Save settings button */
    .save-settings-btn {
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
      padding: 1rem 2rem;
      background: var(--teal);
      color: #fff;
      border: none;
      border-radius: 12px;
      font: inherit;
      font-size: 1.125rem;
      font-weight: 700;
      cursor: pointer;
      transition: background 0.15s, transform 0.1s;
    }
    .save-settings-btn:hover { background: #163535; transform: translateY(-1px); }
    .save-settings-btn svg { width: 22px; height: 22px; }
    
    /* Saved settings bar */
    .saved-settings-bar {
      background: #fff;
      border: 2px solid var(--success);
      border-radius: 12px;
      padding: 1rem 1.25rem;
      margin-bottom: 1.5rem;
      display: flex;
      flex-wrap: wrap;
      gap: 1rem;
      align-items: center;
    }
    .saved-settings-bar .saved-item {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.4rem 0.75rem;
      background: var(--cream);
      border-radius: 20px;
      font-size: 0.8125rem;
    }
    .saved-settings-bar .saved-item strong { color: var(--ink); }
    .saved-settings-bar .edit-btn {
      margin-left: auto;
      padding: 0.4rem 1rem;
      background: var(--teal);
      color: #fff;
      border: none;
      border-radius: 20px;
      font-size: 0.8125rem;
      font-weight: 600;
      cursor: pointer;
    }
    .saved-settings-bar .edit-btn:hover { background: #163535; }
    
    /* Intro box */
    .intro-box {
      background: var(--saffron-tint);
      border: 1.5px solid var(--saffron);
      border-radius: 12px;
      padding: 1.25rem 1.5rem;
      margin-bottom: 2.5rem;
    }
    .intro-box p { margin: 0; color: var(--ink-soft); }
    .intro-box strong { color: var(--saffron-dark); }
    
    /* Screen Recording Guide */
    .screen-record-guide {
      background: #fff;
      border: 2px solid var(--teal);
      border-radius: 16px;
      padding: 1.5rem;
      margin-bottom: 1.5rem;
      box-shadow: 0 4px 12px rgba(30,58,58,0.1);
    }
    .screen-record-guide .guide-header {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      margin-bottom: 1rem;
      padding-bottom: 0.75rem;
      border-bottom: 1px solid var(--line);
    }
    .screen-record-guide .guide-header svg {
      width: 28px;
      height: 28px;
      color: var(--teal);
      flex-shrink: 0;
    }
    .screen-record-guide .guide-header h3 {
      margin: 0;
      font-size: 1.125rem;
      color: var(--teal);
    }
    .screen-record-guide .guide-steps {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 1.5rem;
    }
    @media (max-width: 640px) {
      .screen-record-guide .guide-steps { grid-template-columns: 1fr; }
    }
    .screen-record-guide .guide-os {
      font-size: 0.875rem;
    }
    .screen-record-guide .guide-os strong {
      display: block;
      color: var(--ink);
      margin-bottom: 0.5rem;
      font-size: 0.9375rem;
    }
    .screen-record-guide .guide-os ol {
      margin: 0;
      padding-left: 1.25rem;
      color: var(--ink-soft);
    }
    .screen-record-guide .guide-os li {
      margin-bottom: 0.35rem;
    }
    .screen-record-guide .guide-note {
      margin-top: 1rem;
      padding-top: 1rem;
      border-top: 1px dashed var(--line);
      font-size: 0.9375rem;
      color: var(--muted);
    }
    .screen-record-guide .guide-note strong {
      color: var(--teal);
    }
    
    /* Section styling */
    .section {
      background: #fff;
      border: 1px solid var(--line);
      border-radius: 16px;
      margin-bottom: 1.5rem;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(26,21,17,0.05);
    }
    .section-header {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 1.25rem 1.5rem;
      background: var(--cream-2);
      border-bottom: 1px solid var(--line);
      cursor: pointer;
      user-select: none;
    }
    .section-header:hover { background: #ebe5d8; }
    .section-number {
      width: 36px;
      height: 36px;
      border-radius: 50%;
      background: var(--saffron);
      color: #fff;
      font-weight: 700;
      font-size: 1rem;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }
    .section-title { flex: 1; }
    .section-title h2 {
      margin: 0;
      font-size: 1.125rem;
      font-weight: 700;
      color: var(--ink);
    }
    .section-title p {
      margin: 0.15rem 0 0;
      font-size: 0.875rem;
      color: var(--muted);
    }
    .section-toggle {
      width: 28px;
      height: 28px;
      border-radius: 6px;
      background: var(--line);
      display: flex;
      align-items: center;
      justify-content: center;
      transition: transform 0.2s;
    }
    .section-toggle svg { width: 16px; height: 16px; color: var(--muted); }
    .section.open .section-toggle { transform: rotate(180deg); }
    
    .section-content {
      display: none;
      padding: 1.5rem;
    }
    .section.open .section-content { display: block; }
    
    /* Video upload area */
    .video-upload {
      background: var(--cream);
      border: 2px dashed var(--line);
      border-radius: 12px;
      padding: 2rem;
      text-align: center;
      margin-top: 1.5rem;
      transition: border-color 0.2s, background 0.2s;
    }
    .video-upload:hover {
      border-color: var(--saffron);
      background: var(--saffron-tint);
    }
    .video-upload.dragover {
      border-color: var(--saffron);
      background: var(--saffron-tint);
    }
    .video-upload.has-video {
      border-style: solid;
      border-color: var(--success);
      background: #dcfce7;
    }
    .video-upload input[type="file"] {
      display: none;
    }
    .video-upload-label {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 0.75rem;
      cursor: pointer;
    }
    .video-upload-label svg { width: 48px; height: 48px; color: var(--muted); }
    .video-upload-label p { margin: 0; color: var(--muted); }
    .video-upload-label strong { color: var(--saffron); }
    .video-upload-label .hint { font-size: 0.8125rem; opacity: 0.7; }
    
    /* Video preview */
    .video-preview {
      display: none;
      flex-direction: column;
      align-items: center;
      gap: 1rem;
    }
    .video-upload.has-video .video-preview { display: flex; }
    .video-upload.has-video .video-upload-label { display: none; }
    .video-preview video {
      max-width: 100%;
      max-height: 300px;
      border-radius: 8px;
      background: #000;
    }
    .video-preview .video-info {
      display: flex;
      align-items: center;
      gap: 1rem;
      flex-wrap: wrap;
      justify-content: center;
    }
    .video-preview .video-name {
      font-weight: 600;
      font-size: 0.875rem;
      color: var(--ink);
      max-width: 200px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    .video-preview .video-size {
      font-size: 0.8125rem;
      color: var(--muted);
    }
    .video-preview .btn-remove {
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      padding: 0.5rem 1rem;
      font: inherit;
      font-size: 0.875rem;
      font-weight: 600;
      color: var(--error);
      background: #fee2e2;
      border: 1px solid #fca5a5;
      border-radius: 20px;
      cursor: pointer;
      transition: background 0.15s;
    }
    .video-preview .btn-remove:hover { background: #fecaca; }
    .video-preview .btn-upload {
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      padding: 0.5rem 1rem;
      font: inherit;
      font-size: 0.875rem;
      font-weight: 600;
      color: #fff;
      background: var(--saffron);
      border: none;
      border-radius: 20px;
      cursor: pointer;
      transition: background 0.15s;
    }
    .video-preview .btn-upload:hover { background: var(--saffron-dark); }
    .video-preview .btn-upload:disabled { opacity: 0.6; cursor: not-allowed; }
    
    /* Upload progress */
    .upload-progress {
      display: none;
      flex-direction: column;
      align-items: center;
      gap: 0.75rem;
      margin-top: 1rem;
    }
    .upload-progress.active { display: flex; }
    .progress-bar {
      width: 100%;
      max-width: 300px;
      height: 8px;
      background: var(--line);
      border-radius: 4px;
      overflow: hidden;
    }
    .progress-bar-fill {
      height: 100%;
      background: var(--saffron);
      border-radius: 4px;
      transition: width 0.2s;
    }
    .upload-status { font-size: 0.875rem; color: var(--muted); }
    
    /* Upload success */
    .upload-success {
      display: none;
      align-items: center;
      gap: 0.5rem;
      padding: 0.75rem 1rem;
      background: #dcfce7;
      border: 1px solid #6ee7b7;
      border-radius: 8px;
      color: #166534;
      font-weight: 600;
      font-size: 0.9375rem;
      margin-top: 1rem;
    }
    .upload-success.active { display: inline-flex; }
    .upload-success svg { width: 20px; height: 20px; }
    
    /* Steps */
    .step {
      display: flex;
      gap: 1rem;
      margin-bottom: 1.25rem;
    }
    .step:last-child { margin-bottom: 0; }
    .step-marker {
      width: 28px;
      height: 28px;
      border-radius: 50%;
      background: var(--teal);
      color: #fff;
      font-weight: 600;
      font-size: 0.8125rem;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }
    .step-content { flex: 1; padding-top: 3px; }
    .step-content p { margin: 0 0 0.35rem; }
    .step-content code {
      background: var(--cream-2);
      padding: 0.15rem 0.4rem;
      border-radius: 4px;
      font-size: 0.875em;
      font-family: ui-monospace, monospace;
    }
    
    /* Checkboxes */
    .checklist {
      margin-top: 1.25rem;
      padding-top: 1.25rem;
      border-top: 1px dashed var(--line);
    }
    .checklist-label {
      font-weight: 700;
      font-size: 0.875rem;
      color: var(--muted);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 0.75rem;
    }
    .check-item {
      display: flex;
      align-items: flex-start;
      gap: 0.5rem;
      margin-bottom: 0.5rem;
      font-size: 0.9375rem;
    }
    .check-item input[type="checkbox"] {
      width: 18px;
      height: 18px;
      margin-top: 3px;
      accent-color: var(--saffron);
      cursor: pointer;
    }
    
    /* Quick tips */
    .tip {
      background: #fef9c3;
      border-left: 4px solid var(--warning);
      border-radius: 0 8px 8px 0;
      padding: 0.75rem 1rem;
      margin-top: 1rem;
      font-size: 0.9375rem;
    }
    .tip strong { color: #854d0e; }
    
    .tip-success {
      background: #dcfce7;
      border-left-color: var(--success);
    }
    .tip-success strong { color: #166534; }
    
    .tip-error {
      background: #fee2e2;
      border-left-color: var(--error);
    }
    .tip-error strong { color: #991b1b; }
    
    /* Footer */
    .guide-footer {
      text-align: center;
      padding-top: 2rem;
      border-top: 1px solid var(--line);
      margin-top: 2rem;
    }
    .guide-footer p { color: var(--muted); font-size: 0.875rem; margin: 0 0 0.5rem; }
    .guide-footer a { color: var(--saffron); }
    
    /* Print styles */
    @media print {
      .section-content { display: block !important; }
      .section-toggle { display: none; }
      .check-item input[type="checkbox"] { appearance: none; width: 16px; height: 16px; border: 2px solid #999; border-radius: 3px; }
      .check-item input[type="checkbox"]:checked { background: var(--saffron); border-color: var(--saffron); }
      .video-upload { display: none; }
    }
  </style>
</head>
<body>
  <div class="container">
    <a href="/" class="back">← กลับสู่ Write Lao</a>
    
    <h1>คู่มือทดสอบแอป</h1>
    <p class="subtitle">บันทึกวิดีโอสำหรับแต่ละหัวข้อและส่งหลักฐานการทดสอบของคุณ</p>
    
    <!-- Saved Settings Bar (shows when settings are already saved) -->
    <div class="saved-settings-bar" id="savedSettingsBar" style="display: none;">
      <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="var(--success)" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
      <span class="saved-item"><strong>อุปกรณ์:</strong> <span id="savedDevice"></span></span>
      <span class="saved-item"><strong>ระบบ:</strong> <span id="savedOS"></span></span>
      <span class="saved-item"><strong>แอป:</strong> <span id="savedApp"></span></span>
      <span class="saved-item"><strong>ผู้ทดสอบ:</strong> <span id="savedTester"></span></span>
      <button class="edit-btn" onclick="showSetupGuide()">แก้ไขการตั้งค่า</button>
    </div>
    
    <!-- Device Setup Visual Guide -->
    <div class="setup-guide open" id="setupGuide">
      <div class="setup-guide-header" onclick="toggleSetupGuide()">
        <h3>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>
          การตั้งค่าอุปกรณ์ (จำเป็นสำหรับการส่ง)
        </h3>
        <span class="completed-badge" id="setupCompleted" style="display: none;">เสร็จสิ้น</span>
      </div>
      <div class="setup-guide-content">
        
        <!-- Step 1: Find Settings App -->
        <div class="step-card">
          <div class="step-card-header">
            <span class="step-num">1</span>
            <h4>ค้นหาแอปการตั้งค่าบนอุปกรณ์ของคุณ</h4>
          </div>
          <p>เปิดแอปการตั้งค่าของอุปกรณ์ มองหาไอคอนเกียร์สีเทา</p>
          <img src="/assets/testing/find_settings_app.jpg" alt="ค้นหาแอปการตั้งค่า" loading="lazy">
        </div>
        
        <!-- Step 2: Find iOS Version -->
        <div class="step-card">
          <div class="step-card-header">
            <span class="step-num">2</span>
            <h4>ค้นหาเวอร์ชัน iOS ของคุณ</h4>
          </div>
          <p>เลื่อนลงในการตั้งค่าและแตะ "เกี่ยวกับ" (ด้านบน) เวอร์ชัน iOS จะแสดงที่ด้านบน</p>
          <img src="/assets/testing/find_ios_version_in_settings.jpg" alt="ค้นหาเวอร์ชัน iOS" loading="lazy">
        </div>
        
        <!-- Step 3: Find Model Name -->
        <div class="step-card">
          <div class="step-card-header">
            <span class="step-num">3</span>
            <h4>ค้นหาชื่อรุ่นอุปกรณ์ของคุณ</h4>
          </div>
          <p>ในหน้าเกี่ยวกับเดียวกัน มองหา "ชื่อรุ่น" (ไม่ใช่หมายเลขรุ่น) นี่คืออุปกรณ์ที่แน่นอนของคุณ</p>
          <img src="/assets/testing/find_model_name_in_settings.jpg" alt="ค้นหาชื่อรุ่น" loading="lazy">
        </div>
        
        <!-- Step 4: Enter Settings -->
        <div class="step-card">
          <div class="step-card-header">
            <span class="step-num">4</span>
            <h4>กรอกการตั้งค่าของคุณด้านล่าง</h4>
          </div>
          <p>กรอกข้อมูลด้านล่าง การตั้งค่าของคุณจะถูกบันทึกโดยอัตโนมัติสำหรับครั้งหน้า!</p>
          <div class="device-fields-grid">
            <div class="device-field-input">
              <label>รุ่นอุปกรณ์ <span style="color: var(--error);">*</span></label>
              <input type="text" id="deviceModel" placeholder="เช่น iPhone 15 Pro Max" required>
            </div>
            <div class="device-field-input">
              <label>ระบบปฏิบัติการ / เวอร์ชัน <span style="color: var(--error);">*</span></label>
              <input type="text" id="osVersion" placeholder="เช่น iOS 18.2" required>
            </div>
            <div class="device-field-input">
              <label>เวอร์ชันแอป</label>
              <input type="text" id="appVersion" placeholder="เช่น 1.2.0">
            </div>
            <div class="device-field-input">
              <label>ชื่อของคุณ</label>
              <input type="text" id="testerName" placeholder="ชื่อผู้ทดสอบ">
            </div>
          </div>
          <button class="save-settings-btn" onclick="saveAndVerifySettings()">
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            บันทึกการตั้งค่า
          </button>
        </div>
        
      </div>
    </div>
    
    <!-- Screen Recording Instructions -->
    <div class="screen-record-guide">
      <div class="guide-header">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
        <h3>วิธีบันทึกหน้าจอ</h3>
      </div>
      <div class="guide-steps">
        <div class="guide-os">
          <strong>iPhone / iPad (iOS 11+):</strong>
          <ol>
            <li>ไปที่ <strong>การตั้งค่า → ศูนย์ควบคุม</strong></li>
            <li>แตะ <strong>+</strong> ข้าง "บันทึกหน้าจอ"</li>
            <li>เปิดศูนย์ควบคุม (ปาดลงจากมุมขวาบนบน Face ID หรือปาดขึ้นจากด้านล่างบน Touch ID)</li>
            <li>แตะ<strong>ปุ่มบันทึก</strong> (วงกลมมีจุด)</li>
            <li>รอ 3 วินาที — การบันทึกเริ่ม</li>
            <li>บันทึกการทดสอบ แล้วแตะแถบสีแดงด้านบนเพื่อหยุด</li>
            <li>วิดีโอจะบันทึกไปที่รูปภาพ → การบันทึกหน้าจอ</li>
          </ol>
        </div>
        <div class="guide-os">
          <strong>Android (Android 10+):</strong>
          <ol>
            <li>ปาดลงจากด้านบนเพื่อเปิด Quick Settings</li>
            <li>มองหา "บันทึกหน้าจอ" หรือแตะ<strong>แก้ไข</strong>เพื่อเพิ่ม</li>
            <li>แตะ<strong>บันทึกหน้าจอ</strong>และเลือกการตั้งค่า</li>
            <li>แตะ<strong>เริ่ม</strong></li>
            <li>บันทึกการทดสอบ แล้วปาดลงและแตะ<strong>หยุด</strong></li>
            <li>วิดีโอจะบันทึกไปที่ Movies หรือแกลเลอรีของคุณ</li>
          </ol>
        </div>
      </div>
      <div class="guide-note">
        <strong>จากนั้น:</strong> กลับมาที่นี่แตะ "เลือกวิดีโอ" สำหรับแต่ละหัวข้อ แล้วเลือกวิดีโอบันทึกหน้าจอจากแกลเลอรี
      </div>
    </div>
    
    <div class="intro-box">
      <p><strong>วิธีใช้:</strong> กรอกข้อมูลอุปกรณ์ของคุณด้านบน จากนั้นสำหรับแต่ละหัวข้อ: (1) อ่านขั้นตอน (2) ติ๊กถูกรายการที่ทำเสร็จ (3) บันทึก/อัปโหลดวิดีโอแสดงฟีเจอร์ที่ทำงาน (4) ส่ง สามารถส่งทีละหัวข้อหรือทั้งหมดในครั้งเดียว</p>
    </div>
    
    <!-- ──────────────────── SECTION 1: APP LAUNCH ──────────────────── -->
    <section class="section open" id="launch" data-section="launch">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">1</div>
        <div class="section-title">
          <h2>เปิดแอปและหน้าจอหลัก</h2>
          <p>ตรวจสอบว่าแอปเปิดได้ถูกต้องและแสดงหน้าจอหลัก</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>เปิดแอป</strong> — แตะไอคอน Write Lao บนอุปกรณ์ของคุณ</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>สังเกตหน้าจอเปิดแอป</strong> — ไอคอนแอปและตัวบอกสถานะการโหลดควรปรากฏสั้นๆ</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>ตรวจสอบหน้าจอหลัก</strong> — คุณควรเห็น:</p>
            <ul style="margin: 0.5rem 0 0 1.25rem;">
              <li>ชื่อแอป "Write Lao" ในแถบด้านบน</li>
              <li>สองแท็บ: "ตัวอักษร" และ "คำศัพท์"</li>
              <li>การ์ดแสดงความก้าวหน้าแสดงบทเรียนที่ทำเสร็จและดาวที่ได้รับ</li>
              <li>รายการบทเรียนพร้อมตัวอย่างตัวอักษร</li>
            </ul>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>ตรวจสอบการนำทางด้านล่าง</strong> — ไอคอนสามอัน: บทเรียน, ทบทวน, ความก้าวหน้า</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">รายการตรวจสอบ</div>
          <label class="check-item"><input type="checkbox" data-section="launch"> หน้าจอเปิดแอปปรากฏ</label>
          <label class="check-item"><input type="checkbox" data-section="launch"> แถบด้านบนแสดง "Write Lao"</label>
          <label class="check-item"><input type="checkbox" data-section="launch"> แท็บแสดง "ตัวอักษร" และ "คำศัพท์"</label>
          <label class="check-item"><input type="checkbox" data-section="launch"> การ์ดแสดงความก้าวหน้าแสดง</label>
          <label class="check-item"><input type="checkbox" data-section="launch"> การนำทางด้านล่างแสดง</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-launch" data-section="launch">
          <input type="file" id="video-launch">
          <div class="video-upload-label" onclick="document.getElementById('video-launch').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>คลิกเพื่อบันทึกหรืออัปโหลดวิดีโอ</strong></p>
            <p class="hint">บันทึกหน้าจอก่อน จากนั้นแตะเลือกจากแกลเลอรี • สูงสุด 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-launch" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-launch"></span>
              <span class="video-size" id="size-launch"></span>
              <button class="btn-remove" onclick="removeVideo('launch')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                ลบ
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-launch">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-launch" style="width: 0%"></div></div>
            <div class="upload-status" id="status-launch">กำลังอัปโหลด...</div>
          </div>
          <div class="upload-success" id="success-launch">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            อัปโหลดวิดีโอสำเร็จ!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 2: CHARACTER LESSONS ──────────────────── -->
    <section class="section" id="lessons" data-section="lessons">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">2</div>
        <div class="section-title">
          <h2>บทเรียนตัวอักษร</h2>
          <p>นำทางและเริ่มบทเรียนตัวอักษร</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>ดูรายการบทเรียน</strong> — บนหน้าจอหลัก เลื่อนผ่านแท็บ "ตัวอักษร" การ์ดแต่ละบทแสดง:</p>
            <ul style="margin: 0.5rem 0 0 1.25rem;">
              <li>ชื่อบทเรียน (เช่น "พยัญชนะ 1")</li>
              <li>ตัวอย่างตัวอักษร (ตัวอักษรลาวเล็กๆ)</li>
              <li>การให้ดาว (0-3 ดาว)</li>
            </ul>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>แตะบทเรียน</strong> — เปิดหน้าจอรายละเอียดบทเรียน</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>ตรวจสอบรายละเอียด</strong> — แสดงตัวอักษรทั้งหมดในบทพร้อมชื่อและคำอ่าน</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>เริ่มฝึกฝน</strong> — แตะปุ่ม "ฝึกฝน" เพื่อเริ่มการฝึกแบบมีคำแนะนำ</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">รายการตรวจสอบ</div>
          <label class="check-item"><input type="checkbox" data-section="lessons"> การ์ดบทเรียนแสดงถูกต้อง</label>
          <label class="check-item"><input type="checkbox" data-section="lessons"> การให้ดาวแสดง (0-3)</label>
          <label class="check-item"><input type="checkbox" data-section="lessons"> แตะบทเรียนเปิดหน้าจอรายละเอียด</label>
          <label class="check-item"><input type="checkbox" data-section="lessons"> รายละเอียดแสดงตัวอักษรทั้งหมด</label>
          <label class="check-item"><input type="checkbox" data-section="lessons"> ปุ่มฝึกฝนไปยังหน้าจอฝึกฝน</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-lessons" data-section="lessons">
          <input type="file" id="video-lessons">
          <div class="video-upload-label" onclick="document.getElementById('video-lessons').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>คลิกเพื่อบันทึกหรืออัปโหลดวิดีโอ</strong></p>
            <p class="hint">บันทึกหน้าจอก่อน จากนั้นแตะเลือกจากแกลเลอรี • สูงสุด 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-lessons" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-lessons"></span>
              <span class="video-size" id="size-lessons"></span>
              <button class="btn-remove" onclick="removeVideo('lessons')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                ลบ
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-lessons">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-lessons" style="width: 0%"></div></div>
            <div class="upload-status" id="status-lessons">กำลังอัปโหลด...</div>
          </div>
          <div class="upload-success" id="success-lessons">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            อัปโหลดวิดีโอสำเร็จ!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 3: PRACTICE MODE ──────────────────── -->
    <section class="section" id="practice" data-section="practice">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">3</div>
        <div class="section-title">
          <h2>โหมดฝึกฝน</h2>
          <p>การฝึกเขียนแบบมีคำแนะนำทีละเส้น</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>ระบุพื้นที่วาด</strong> — สี่เหลี่ยมขาวใหญ่ตรงกลาง ตัวอักษรลาวแสดงด้านบน</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>วาดเส้น</strong> — ทำตามคำแนะนำเส้น หรือเส้นประแอปจะประเมินขณะที่คุณวาด</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>ทำเส้นครบ</strong> — แถบแสดงความก้าวหน้าแสดงตำแหน่งปัจจุบัน ปุ่ม "ถัดไป" ปรากฏเมื่อเสร็จ</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>ทดสอบปุ่มควบคุม</strong> — ปุ่มด้านล่าง:</p>
            <ul style="margin: 0.5rem 0 0 1.25rem;">
              <li><strong>ลบ</strong> — ล้างการวาดของคุณ</li>
              <li><strong>เสียง</strong> —เล่นเสียงออกเสียง</li>
              <li><strong>ไอคอนตา</strong> — เปิด/ปิดคำแนะนำเส้น</li>
            </ul>
          </div>
        </div>
        
        <div class="tip">
          <strong>เคล็ดลับ:</strong> ปุ่มเปิด/ปิดคำแนะนำมีประโยชน์สำหรับทดสอบประสบการณ์ "โหมดทดสอบ"ในโหมดฝึกฝน
        </div>
        
        <div class="checklist">
          <div class="checklist-label">รายการตรวจสอบ</div>
          <label class="check-item"><input type="checkbox" data-section="practice"> พื้นที่วาดแสดง</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> คำแนะนำเส้นประมองเห็น</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> การวาดถูกจดจำ</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> แถบความก้าวหน้าอัปเดต</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> ปุ่มลบล้างพื้นที่วาด</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> ปุ่มเสียงเล่นเสียง</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> ปุ่มเปิด/ปิดคำแนะนำทำงาน</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> ปุ่มถัดไปปรากฏเมื่อเสร็จ</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-practice" data-section="practice">
          <input type="file" id="video-practice">
          <div class="video-upload-label" onclick="document.getElementById('video-practice').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>คลิกเพื่อบันทึกหรืออัปโหลดวิดีโอ</strong></p>
            <p class="hint">บันทึกหน้าจอก่อน จากนั้นแตะเลือกจากแกลเลอรี • สูงสุด 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-practice" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-practice"></span>
              <span class="video-size" id="size-practice"></span>
              <button class="btn-remove" onclick="removeVideo('practice')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                ลบ
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-practice">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-practice" style="width: 0%"></div></div>
            <div class="upload-status" id="status-practice">กำลังอัปโหลด...</div>
          </div>
          <div class="upload-success" id="success-practice">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            อัปโหลดวิดีโอสำเร็จ!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 4: TEST MODE ──────────────────── -->
    <section class="section" id="test" data-section="test">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">4</div>
        <div class="section-title">
          <h2>โหมดทดสอบ</h2>
          <p>การทดสอบแบบจับเวลาโดยไม่มีคำแนะนำเส้น</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>เริ่มทดสอบจากรายละเอียดบทเรียน</strong> — แตะปุ่ม "ทดสอบ" บนหน้าจอรายละเอียดบทเรียน</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>สังเกตนาฬิกา</strong> — นาฬิกาในแถบด้านบนนับขึ้น ไม่มีคำแนะนำเส้น</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>เขียนจากความจำ</strong> — วาดแต่ละตัวอักษรโดยไม่มีคำแนะนำ หลังล้มเหลว 3 ครั้ง คำแนะนำจะปรากฏ</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>ทำทดสอบเสร็จ</strong> — หลังตัวอักษรทั้งหมด ดูหน้าจอผลลัพธ์พร้อมการให้ดาว (1-3)</p>
          </div>
        </div>
        
        <div class="tip tip-success">
          <strong>ผลลัพธ์ที่ดี:</strong> 3 ดาว = เร็ว + แม่นยำ2 ดาว = มีข้อผิดพลาดบ้าง 1 ดาว = มีปัญหามาก
        </div>
        
        <div class="checklist">
          <div class="checklist-label">รายการตรวจสอบ</div>
          <label class="check-item"><input type="checkbox" data-section="test"> นาฬิกาเริ่มและนับขึ้น</label>
          <label class="check-item"><input type="checkbox" data-section="test"> ไม่มีคำแนะนำเส้นตอนแรก</label>
          <label class="check-item"><input type="checkbox" data-section="test"> คำแนะนำปรากฏหลังล้มเหลว 3 ครั้ง</label>
          <label class="check-item"><input type="checkbox" data-section="test"> หน้าจอผลลัพธ์แสดงดาว</label>
          <label class="check-item"><input type="checkbox" data-section="test"> การให้ดาวตรงกับประสิทธิภาพ</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-test" data-section="test">
          <input type="file" id="video-test">
          <div class="video-upload-label" onclick="document.getElementById('video-test').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>คลิกเพื่อบันทึกหรืออัปโหลดวิดีโอ</strong></p>
            <p class="hint">บันทึกหน้าจอก่อน จากนั้นแตะเลือกจากแกลเลอรี • สูงสุด 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-test" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-test"></span>
              <span class="video-size" id="size-test"></span>
              <button class="btn-remove" onclick="removeVideo('test')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                ลบ
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-test">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-test" style="width: 0%"></div></div>
            <div class="upload-status" id="status-test">กำลังอัปโหลด...</div>
          </div>
          <div class="upload-success" id="success-test">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            อัปโหลดวิดีโอสำเร็จ!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 5: VOCABULARY ──────────────────── -->
    <section class="section" id="vocab" data-section="vocab">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">5</div>
        <div class="section-title">
          <h2>บทเรียนคำศัพท์</h2>
          <p>เรียนคำศัพท์พร้อมเสียงและการทบทวนแบบห่างๆ</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>สลับไปแท็บ "คำศัพท์"</strong> — แตะแท็บที่สองบนหน้าจอหลัก</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>ดูรายการหน่วย</strong> — แสดงหน่วยคำศัพท์พร้อมสถานะความสำเร็จ หน่วยแรกฟรี</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>เปิดหน่วย</strong> — แตะหน่วยที่ปลดล็อกเพื่อดูบทเรียน</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>เริ่มบทเรียน</strong> — แตะบทเรียนเพื่อเริ่ม การ์ดคำแสดง:</p>
            <ul style="margin: 0.5rem 0 0 1.25rem;">
              <li>คำศัพท์ลาวตัวใหญ่</li>
              <li>คำแปลภาษาอังกฤษ</li>
              <li>ปุ่มเสียงออกเสียง</li>
              <li>ประโยคตัวอย่าง</li>
            </ul>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">5</div>
          <div class="step-content">
            <p><strong>ฝึกคำศัพท์</strong> — เขียนคำบนพื้นที่วาด จากนั้นทำแบบฝึก "ฟังและระบุ"</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">รายการตรวจสอบ</div>
          <label class="check-item"><input type="checkbox" data-section="vocab"> แท็บ "คำศัพท์" เข้าถึงได้</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> รายการหน่วยแสดงถูกต้อง</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> หน่วยที่ล็อกแสดงไอคอนล็อก</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> การ์ดคำแสดงลาว + อังกฤษ</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> เสียงเล่นถูกต้อง</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> การฝึกเขียนทำงาน</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> แบบฝึก "ฟังและระบุ" ทำงาน</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-vocab" data-section="vocab">
          <input type="file" id="video-vocab">
          <div class="video-upload-label" onclick="document.getElementById('video-vocab').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>คลิกเพื่อบันทึกหรืออัปโหลดวิดีโอ</strong></p>
            <p class="hint">บันทึกหน้าจอก่อน จากนั้นแตะเลือกจากแกลเลอรี • สูงสุด 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-vocab" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-vocab"></span>
              <span class="video-size" id="size-vocab"></span>
              <button class="btn-remove" onclick="removeVideo('vocab')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                ลบ
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-vocab">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-vocab" style="width: 0%"></div></div>
            <div class="upload-status" id="status-vocab">กำลังอัปโหลด...</div>
          </div>
          <div class="upload-success" id="success-vocab">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            อัปโหลดวิดีโอสำเร็จ!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 6: REVIEW MODE ──────────────────── -->
    <section class="section" id="review" data-section="review">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">6</div>
        <div class="section-title">
          <h2>โหมดทบทวน</h2>
          <p>ฝึกฝนแบบกำหนดเองสำหรับตัวอักษรหรือคำศัพท์ที่เลือก</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>ไปที่ทบทวน</strong> — แตะไอคอนทบทวนในการนำทางด้านล่าง</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>เลือกตัวอักษร</strong> — สองแท็บ: "ตัวอักษร" และ "คำศัพท์" เลือกตัวอักษรโดยแตะ</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>ใช้ตัวกรองด่วน</strong> — "ตัวอักษรที่อ่อน" เลือกอัตโนมัติสำหรับตัวที่ลำบาก "ทั้งหมด" เลือกทุกตัว</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>เริ่มฝึกแบบกำหนดเอง</strong> — แตะปุ่ม "ฝึกที่เลือก" เพื่อเริ่มกับตัวอักษรที่เลือก</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">รายการตรวจสอบ</div>
          <label class="check-item"><input type="checkbox" data-section="review"> หน้าจอทบทวนเข้าถึงได้</label>
          <label class="check-item"><input type="checkbox" data-section="review"> การเลือกตัวอักษรทำงาน</label>
          <label class="check-item"><input type="checkbox" data-section="review"> ตัวกรอง "ตัวอักษรที่อ่อน" ทำงาน</label>
          <label class="check-item"><input type="checkbox" data-section="review"> ปุ่ม "ฝึกที่เลือก" เริ่มฝึก</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-review" data-section="review">
          <input type="file" id="video-review">
          <div class="video-upload-label" onclick="document.getElementById('video-review').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>คลิกเพื่อบันทึกหรืออัปโหลดวิดีโอ</strong></p>
            <p class="hint">บันทึกหน้าจอก่อน จากนั้นแตะเลือกจากแกลเลอรี • สูงสุด 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-review" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-review"></span>
              <span class="video-size" id="size-review"></span>
              <button class="btn-remove" onclick="removeVideo('review')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                ลบ
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-review">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-review" style="width: 0%"></div></div>
            <div class="upload-status" id="status-review">กำลังอัปโหลด...</div>
          </div>
          <div class="upload-success" id="success-review">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            อัปโหลดวิดีโอสำเร็จ!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 7: PROGRESS ──────────────────── -->
    <section class="section" id="progress" data-section="progress">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">7</div>
        <div class="section-title">
          <h2>ติดตามความก้าวหน้า</h2>
          <p>ดูความก้าวหน้าการเรียนโดยรวม</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>ไปที่ความก้าวหน้า</strong> — แตะไอคอนความก้าวหน้าในการนำทางด้านล่าง</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>ตรวจสอบสถิติ</strong> — แสดงบทเรียนที่ทำเสร็จและดาวที่ได้รับ</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>ดูความก้าวหน้าแต่ละระยะ</strong> — แถบแสดงสำหรับแต่ละระยะ (พยัญชนะ, สระ, วรรณยุกต์, ตัวเลข, อักษรเชื่อม)</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>ตรวจสอบข้อเสนอแนะถัดไป</strong> — การ์ด "ถัดไป" แนะนำบทเรียนถัดไปที่จะเริ่ม</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">รายการตรวจสอบ</div>
          <label class="check-item"><input type="checkbox" data-section="progress"> หน้าจอความก้าวหน้าเข้าถึงได้</label>
          <label class="check-item"><input type="checkbox" data-section="progress"> สถิติแสดงถูกต้อง</label>
          <label class="check-item"><input type="checkbox" data-section="progress"> แถบความก้าวหน้าแสดง</label>
          <label class="check-item"><input type="checkbox" data-section="progress"> บทเรียนถัดไปที่แนะนำแสดง</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-progress" data-section="progress">
          <input type="file" id="video-progress">
          <div class="video-upload-label" onclick="document.getElementById('video-progress').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>คลิกเพื่อบันทึกหรืออัปโหลดวิดีโอ</strong></p>
            <p class="hint">บันทึกหน้าจอก่อน จากนั้นแตะเลือกจากแกลเลอรี • สูงสุด 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-progress" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-progress"></span>
              <span class="video-size" id="size-progress"></span>
              <button class="btn-remove" onclick="removeVideo('progress')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                ลบ
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-progress">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-progress" style="width: 0%"></div></div>
            <div class="upload-status" id="status-progress">กำลังอัปโหลด...</div>
          </div>
          <div class="upload-success" id="success-progress">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            อัปโหลดวิดีโอสำเร็จ!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 8: SETTINGS ──────────────────── -->
    <section class="section" id="settings" data-section="settings">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">8</div>
        <div class="section-title">
          <h2>การตั้งค่า</h2>
          <p>ปรับการตั้งค่าแอป</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>เปิดการตั้งค่า</strong> — แตะไอคอนเฟืองในแถบด้านบน</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>ปรับความเข้มงวดเส้น</strong> — ปรับจาก "ยืดหยุ่น" ถึง "เข้มงวด" ทดสอบด้วยการตั้งค่าต่างๆ</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>เปิด/ปิดเอฟเฟกต์เสียง</strong> — สลับเปิด/ปิด ทดสอบโดยทำตัวอักษรเสร็จ</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>เปิด/ปิดการสั่นสะเทือน</strong> — สลับเปิด/ปิด ทดสอบโดยวาดบนพื้นที่วาด</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">5</div>
          <div class="step-content">
            <p><strong>รีเซ็ตความก้าวหน้า</strong> — ทดสอบฟังก์ชันรีเซ็ต (พร้อมกล่องยืนยัน)</p>
          </div>
        </div>
        
        <div class="tip tip-error">
          <strong>คำเตือน:</strong> รีเซ็ตความก้าวหน้าเป็นการลบข้อมูลถาวร ทดสอบเฉพาะถ้าคุณสามารถกู้คืนหรือไม่รังเกียจที่จะสูญเสียข้อมูล
        </div>
        
        <div class="checklist">
          <div class="checklist-label">รายการตรวจสอบ</div>
          <label class="check-item"><input type="checkbox" data-section="settings"> หน้าจอการตั้งค่าเปิด</label>
          <label class="check-item"><input type="checkbox" data-section="settings"> ตัวเลื่อนความเข้มงวดเส้นทำงาน</label>
          <label class="check-item"><input type="checkbox" data-section="settings"> สลับเอฟเฟกต์เสียงทำงาน</label>
          <label class="check-item"><input type="checkbox" data-section="settings"> สลับการสั่นสะเทือนทำงาน</label>
          <label class="check-item"><input type="checkbox" data-section="settings"> รีเซ็ตแสดงการยืนยัน</label>
          <label class="check-item"><input type="checkbox" data-section="settings"> รีเซ็ตล้างความก้าวหน้าจริง</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-settings" data-section="settings">
          <input type="file" id="video-settings">
          <div class="video-upload-label" onclick="document.getElementById('video-settings').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>คลิกเพื่อบันทึกหรืออัปโหลดวิดีโอ</strong></p>
            <p class="hint">บันทึกหน้าจอก่อน จากนั้นแตะเลือกจากแกลเลอรี • สูงสุด 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-settings" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-settings"></span>
              <span class="video-size" id="size-settings"></span>
              <button class="btn-remove" onclick="removeVideo('settings')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                ลบ
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-settings">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-settings" style="width: 0%"></div></div>
            <div class="upload-status" id="status-settings">กำลังอัปโหลด...</div>
          </div>
          <div class="upload-success" id="success-settings">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            อัปโหลดวิดีโอสำเร็จ!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 9: IN-APP PURCHASE ──────────────────── -->
    <section class="section" id="iap" data-section="iap">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">9</div>
        <div class="section-title">
          <h2>การซื้อในแอป</h2>
          <p>ปลดล็อกคอร์สคำศัพท์</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>หาข้อความอัปเกรด</strong> — แบนเนอร์ปรากฏบนหน้าจอหลักถ้ายังไม่ซื้อคำศัพท์</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>แตะอัปเกรด</strong> — เปิดหน้าจอซื้อ/อัปเกรด</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>ตรวจสอบตัวเลือกกู้คืน</strong> — ปุ่ม "กู้คืนการซื้อ" ควรแสดง</p>
          </div>
        </div>
        
        <div class="tip">
          <strong>หมายเหตุ:</strong> ทดสอบการซื้อจริงเฉพาะถ้าคุณมีบัญชี sandbox มิฉะนั้นโฟกัสที่ UI และการกู้คืน
        </div>
        
        <div class="checklist">
          <div class="checklist-label">รายการตรวจสอบ</div>
          <label class="check-item"><input type="checkbox" data-section="iap"> แบนเกอร์อัปเกรดแสดง (ถ้ายังไม่ซื้อ)</label>
          <label class="check-item"><input type="checkbox" data-section="iap"> ปุ่มอัปเกรดไปยังหน้าจอซื้อ</label>
          <label class="check-item"><input type="checkbox" data-section="iap"> ปุ่มกู้คืนการซื้อมี</label>
          <label class="check-item"><input type="checkbox" data-section="iap"> ราคาแสดงถูกต้อง</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-iap" data-section="iap">
          <input type="file" id="video-iap">
          <div class="video-upload-label" onclick="document.getElementById('video-iap').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>คลิกเพื่อบันทึกหรืออัปโหลดวิดีโอ</strong></p>
            <p class="hint">บันทึกหน้าจอก่อน จากนั้นแตะเลือกจากแกลเลอรี • สูงสุด 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-iap" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-iap"></span>
              <span class="video-size" id="size-iap"></span>
              <button class="btn-remove" onclick="removeVideo('iap')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                ลบ
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-iap">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-iap" style="width: 0%"></div></div>
            <div class="upload-status" id="status-iap">กำลังอัปโหลด...</div>
          </div>
          <div class="upload-success" id="success-iap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            อัปโหลดวิดีโอสำเร็จ!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 10: OFFLINE ──────────────────── -->
    <section class="section" id="offline" data-section="offline">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">10</div>
        <div class="section-title">
          <h2>การทำงานออฟไลน์</h2>
          <p>ตรวจสอบว่าแอปทำงานโดยไม่มีอินเทอร์เน็ต</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>เปิดโหมดเครื่องบิน</strong> — เปิดโหมดเครื่องบินหรือปิด WiFi/เซลลูลาร์</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>เปิดแอป</strong> — แอปควรเปิดปกติและแสดงหน้าจอหลัก</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>ทดสอบฟีเจอร์หลัก</strong> — โหมดฝึกฝน ทดสอบ และทบทวนควรทำงานทั้งหมด</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>ตรวจสอบว่าความก้าวหน้าบันทึก</strong> — ทำบทเรียนเสร็จ ตรวจสอบว่าความก้าวหน้าอัปเดต (อาจต้องรีสตาร์ทแอป)</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">รายการตรวจสอบ</div>
          <label class="check-item"><input type="checkbox" data-section="offline"> แอปเปิดในโหมดเครื่องบิน</label>
          <label class="check-item"><input type="checkbox" data-section="offline"> หน้าจอหลักโหลด</label>
          <label class="check-item"><input type="checkbox" data-section="offline"> โหมดฝึกฝนทำงานออฟไลน์</label>
          <label class="check-item"><input type="checkbox" data-section="offline"> โหมดทดสอบทำงานออฟไลน์</label>
          <label class="check-item"><input type="checkbox" data-section="offline"> ความก้าวหน้าคงอยู่หลังใช้ออฟไลน์</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-offline" data-section="offline">
          <input type="file" id="video-offline">
          <div class="video-upload-label" onclick="document.getElementById('video-offline').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>คลิกเพื่อบันทึกหรืออัปโหลดวิดีโอ</strong></p>
            <p class="hint">บันทึกหน้าจอก่อน จากนั้นแตะเลือกจากแกลเลอรี • สูงสุด 500MB</p>
          </div>
          <div class="video-preview">
<video id="preview-offline" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-offline"></span>
              <span class="video-size" id="size-offline"></span>
              <button class="btn-remove" onclick="removeVideo('offline')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                ลบ
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-offline">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-offline" style="width: 0%"></div></div>
            <div class="upload-status" id="status-offline">กำลังอัปโหลด...</div>
          </div>
          <div class="upload-success" id="success-offline">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            อัปโหลดวิดีโอสำเร็จ!
          </div>
        </div>
      </div>
    </section>
    
    <button class="submit-all" id="submitAllBtn" onclick="submitAllVideos()">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
      ส่งวิดีโอทั้งหมด
    </button>
    
    <div class="guide-footer">
      <p>มีคำถาม? ส่งอีเมล<a href="mailto:help@maitrigroup.co">help@maitrigroup.co</a></p>
      <p>Write Lao v1.0 · คู่มือทดสอบแอป</p>
    </div>
  </div>
  
  <script src="https://unpkg.com/smart-browser-detection@1.0.3/dist/smart-browser-detection.min.js"></script>
  <script>
    // ═══════════════════════════════════════════════════════════════════════
    // LOCALSTORAGE — Sticky device settings
    // ═══════════════════════════════════════════════════════════════════════
    
    const STORAGE_KEY = 'tester_guide_settings';
    
    function loadSettings() {
      try {
        const saved = localStorage.getItem(STORAGE_KEY);
        if (saved) {
          return JSON.parse(saved);
        }
      } catch (err) {
        console.error('Failed to load settings:', err);
      }
      return null;
    }
    
    function saveSettings(settings) {
      try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(settings));
      } catch (err) {
        console.error('Failed to save settings:', err);
      }
    }
    
    function getSettings() {
      const dom = {
        deviceModel: document.getElementById('deviceModel')?.value || '',
        osVersion: document.getElementById('osVersion')?.value || '',
        appVersion: document.getElementById('appVersion')?.value || '',
        testerName: document.getElementById('testerName')?.value || ''
      };
      
      if (!dom.deviceModel || !dom.osVersion) {
        const saved = loadSettings();
        if (saved) {
          dom.deviceModel = dom.deviceModel || saved.deviceModel || '';
          dom.osVersion = dom.osVersion || saved.osVersion || '';
          dom.appVersion = dom.appVersion || saved.appVersion || '';
          dom.testerName = dom.testerName || saved.testerName || '';
        }
      }
      
      return dom;
    }
    
    function populateSettingsFromStorage() {
      const settings = loadSettings();
      if (settings) {
        if (settings.deviceModel) document.getElementById('deviceModel').value = settings.deviceModel;
        if (settings.osVersion) document.getElementById('osVersion').value = settings.osVersion;
        if (settings.appVersion) document.getElementById('appVersion').value = settings.appVersion;
        if (settings.testerName) document.getElementById('testerName').value = settings.testerName;
        return true;
      }
      return false;
    }
    
    function showSavedSettingsBar() {
      const settings = loadSettings();
      if (settings && settings.deviceModel && settings.osVersion) {
        document.getElementById('savedDevice').textContent = settings.deviceModel;
        document.getElementById('savedOS').textContent = settings.osVersion;
        document.getElementById('savedApp').textContent = settings.appVersion || 'ไม่ได้ตั้ง';
        document.getElementById('savedTester').textContent = settings.testerName || 'ไม่ระบุชื่อ';
        document.getElementById('savedSettingsBar').style.display = 'flex';
        document.getElementById('setupGuide').classList.remove('open');
        document.getElementById('setupCompleted').style.display = 'inline-block';
        return true;
      }
      return false;
    }
    
    function showSetupGuide() {
      document.getElementById('savedSettingsBar').style.display = 'none';
      document.getElementById('setupGuide').classList.add('open');
      document.getElementById('setupCompleted').style.display = 'none';
    }
    
    function toggleSetupGuide() {
      const guide = document.getElementById('setupGuide');
      guide.classList.toggle('open');
    }
    
    function saveAndVerifySettings() {
      const deviceModel = document.getElementById('deviceModel').value.trim();
      const osVersion = document.getElementById('osVersion').value.trim();
      const appVersion = document.getElementById('appVersion').value.trim();
      const testerName = document.getElementById('testerName').value.trim();
      
      if (!deviceModel) {
        alert('กรุณากรอกรุ่นอุปกรณ์ (เช่น iPhone 15 Pro Max)');
        document.getElementById('deviceModel').focus();
        return;
      }
      if (!osVersion) {
        alert('กรุณากรอกเวอร์ชันระบบปฏิบัติการ (เช่น iOS 18.2)');
        document.getElementById('osVersion').focus();
        return;
      }
      
      saveSettings({
        deviceModel,
        osVersion,
        appVersion,
        testerName
      });
      
      showSavedSettingsBar();
    }
    
    function initPage() {
      if (showSavedSettingsBar()) {
        console.log('โหลดการตั้งค่าจาก localStorage');
        return;
      }
      showSetupGuide();
      console.log('แสดงคำแนะนำการตั้งค่า');
    }
    
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', initPage);
    } else {
      initPage();
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // VIDEO STORAGE AND UPLOAD
    // ═══════════════════════════════════════════════════════════════════════
    
    const videoFiles = {};
    
    function toggleSection(header) {
      const section = header.closest('.section');
      section.classList.toggle('open');
    }
    
    const sections = ['launch', 'lessons', 'practice', 'test', 'vocab', 'review', 'progress', 'settings', 'iap', 'offline'];
    
    sections.forEach(section => {
      const input = document.getElementById('video-' + section);
      if (input) {
        input.addEventListener('change', function(e) {
          const file = e.target.files[0];
          if (file) handleVideoSelect(section, file);
        });
      }
    });
    
    sections.forEach(section => {
      const uploadArea = document.getElementById('upload-' + section);
      if (uploadArea) {
        uploadArea.addEventListener('dragover', function(e) {
          e.preventDefault();
          this.classList.add('dragover');
        });
        uploadArea.addEventListener('dragleave', function(e) {
          e.preventDefault();
          this.classList.remove('dragover');
        });
        uploadArea.addEventListener('drop', function(e) {
          e.preventDefault();
          this.classList.remove('dragover');
          const file = e.dataTransfer.files[0];
          if (file && file.type.startsWith('video/')) {
            handleVideoSelect(section, file);
          }
        });
      }
    });
    
    function handleVideoSelect(section, file) {
      const maxSize = 500 * 1024 * 1024;
      if (file.size > maxSize) {
        alert('วิดีโอใหญ่เกินไป ขนาดสูงสุดคือ 500MB');
        return;
      }
      
      videoFiles[section] = file;
      
      const uploadArea = document.getElementById('upload-' + section);
      const video = document.getElementById('preview-' + section);
      const nameEl = document.getElementById('name-' + section);
      const sizeEl = document.getElementById('size-' + section);
      
      uploadArea.classList.add('has-video');
      video.src = URL.createObjectURL(file);
      nameEl.textContent = file.name;
      sizeEl.textContent = formatSize(file.size);
      
      // Add upload button if not already there
      const infoDiv = document.querySelector('#upload-' + section + ' .video-info');
      if (infoDiv && !document.getElementById('upload-btn-' + section)) {
        const uploadBtn = document.createElement('button');
        uploadBtn.id = 'upload-btn-' + section;
        uploadBtn.className = 'btn-upload';
        uploadBtn.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg> อัปโหลด';
        uploadBtn.onclick = function() { uploadSingleVideo(section); };
        infoDiv.appendChild(uploadBtn);
      }
    }
    
    async function uploadSingleVideo(section) {
      const btn = document.getElementById('upload-btn-' + section);
      if (btn) { btn.disabled = true; btn.textContent = 'กำลังอัปโหลด...'; }
      
      const success = await uploadVideo(section);
      
      if (btn) {
        if (success) {
          btn.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg> เสร็จ';
          btn.disabled = true;
          btn.style.opacity = '0.6';
          btn.style.cursor = 'not-allowed';
        } else {
          btn.disabled = false;
          btn.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg> อัปโหลด';
        }
      }
    }
    
    function removeVideo(section) {
      videoFiles[section] = null;
      const uploadArea = document.getElementById('upload-' + section);
      const input = document.getElementById('video-' + section);
      uploadArea.classList.remove('has-video');
      input.value = '';
      
      // Remove upload button
      const btn = document.getElementById('upload-btn-' + section);
      if (btn) btn.remove();
    }
    
    function formatSize(bytes) {
      if (bytes < 1024) return bytes + ' B';
      if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
      return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
    }
    
    async function uploadVideo(section) {
      const file = videoFiles[section];
      if (!file) return null;
      
      const settings = getSettings();
      const deviceModel = settings.deviceModel || 'Unknown Device';
      const osVersion = settings.osVersion || 'Unknown OS';
      const appVersion = settings.appVersion || 'Unknown Version';
      const testerName = settings.testerName || 'Anonymous';
      
      const progressEl = document.getElementById('progress-' + section);
      const fillEl = document.getElementById('progress-fill-' + section);
      const statusEl = document.getElementById('status-' + section);
      const successEl = document.getElementById('success-' + section);
      
      progressEl.classList.add('active');
      statusEl.textContent = 'กำลังอัปโหลด...';
      
      const formData = new FormData();
      formData.append('video', file);
      formData.append('section', section);
      formData.append('deviceModel', deviceModel);
      formData.append('osVersion', osVersion);
      formData.append('appVersion', appVersion);
      formData.append('testerName', testerName);
      
      try {
        const xhr = new XMLHttpRequest();
        
        await new Promise((resolve, reject) => {
          xhr.upload.addEventListener('progress', (e) => {
            if (e.lengthComputable) {
              const percent = Math.round((e.loaded / e.total) * 100);
              fillEl.style.width = percent + '%';
              statusEl.textContent = 'กำลังอัปโหลด... ' + percent + '%';
            }
          });
          
          xhr.addEventListener('load', () => {
            if (xhr.status >= 200 && xhr.status < 300) {
              resolve(xhr.response);
            } else {
              reject(new Error('อัปโหลดล้มเหลว: ' + xhr.status));
            }
          });
          
          xhr.addEventListener('error', () => reject(new Error('อัปโหลดล้มเหลว')));
          
          xhr.open('POST', '/api/tester/video');
          xhr.send(formData);
        });
        
        progressEl.classList.remove('active');
        successEl.classList.add('active');
        return true;
      } catch (err) {
        progressEl.classList.remove('active');
        statusEl.textContent = 'อัปโหลดล้มเหลว: ' + err.message;
        return false;
      }
    }
    
    async function submitAllVideos() {
      const deviceModel = document.getElementById('deviceModel').value;
      const osVersion = document.getElementById('osVersion').value;
      
      if (!deviceModel || !osVersion) {
        alert('กรุณากรอกรุ่นอุปกรณ์และระบบปฏิบัติการก่อนส่ง');
        return;
      }
      
      const btn = document.getElementById('submitAllBtn');
      btn.disabled = true;
      btn.innerHTML = '<svg class="spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg> กำลังอัปโหลด...';
      
      let successCount = 0;
      let failCount = 0;
      
      for (const section of sections) {
        if (videoFiles[section]) {
          const result = await uploadVideo(section);
          if (result) {
            successCount++;
          } else {
            failCount++;
          }
        }
      }
      
      btn.disabled = false;
      btn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg> ส่งวิดีโอทั้งหมด';
      
      if (failCount === 0) {
        alert('อัปโหลดวิดีโอ ' + successCount + ' วิดีโอสำเร็จ!');
      } else {
        alert('อัปโหลด ' + successCount + ' วิดีโอ ล้มเหลว ' + failCount + ' วิดีโอ');
      }
    }
    
    document.querySelectorAll('input[type="checkbox"]').forEach(cb => {
      cb.addEventListener('change', () => {
        const checked = document.querySelectorAll('input[type="checkbox"]:checked').length;
        const total = document.querySelectorAll('input[type="checkbox"]').length;
        console.log('ความก้าวหน้า: ' + checked + '/' + total + ' รายการ');
      });
    });
  </script>
  
  <style>
    .spin { animation: spin 1s linear infinite; }
    @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
  </style>
</body>
</html>`;

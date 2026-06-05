/**
 * Manual App Tester Guide — Write Lao
 * 
 * A simplified, step-by-step guide for manual testers to quickly test
 * each feature and submit video evidence.
 */

// ── Tester Guide HTML ──────────────────────────────────────────────────
export const testerGuideHTML = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Manual Tester Guide — Write Lao</title>
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
    
    /* Device info bar */
    .device-bar {
      background: var(--teal);
      color: #fff;
      padding: 1rem 1.25rem;
      border-radius: 12px;
      margin-bottom: 2rem;
      display: flex;
      flex-wrap: wrap;
      gap: 1rem;
      align-items: center;
    }
    .device-bar h3 { margin: 0 0 0.25rem; font-size: 0.9375rem; opacity: 0.9; }
    .device-bar .device-info { display: flex; flex-wrap: wrap; gap: 1rem; flex: 1; }
    .device-bar .device-field { min-width: 140px; }
    .device-bar label { display: block; font-size: 0.75rem; opacity: 0.7; text-transform: uppercase; letter-spacing: 0.5px; }
    .device-bar .device-value { font-weight: 600; font-size: 0.9375rem; }
    .device-bar input {
      width: 100%;
      padding: 0.4rem 0.6rem;
      font: inherit;
      font-size: 0.875rem;
      border: 1px solid rgba(255,255,255,0.3);
      border-radius: 6px;
      background: rgba(255,255,255,0.15);
      color: #fff;
    }
    .device-bar input::placeholder { color: rgba(255,255,255,0.5); }
    .device-bar input:focus { outline: none; border-color: #fff; background: rgba(255,255,255,0.25); }
    .device-bar input.detected { background: rgba(22, 163, 74, 0.3); border-color: #16a34a; }
    .device-bar .detected-badge {
      display: none;
      font-size: 0.625rem;
      background: #16a34a;
      color: #fff;
      padding: 0.1rem 0.35rem;
      border-radius: 4px;
      margin-left: 0.35rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .device-bar .detected-badge.show { display: inline-block; }
    .device-bar .detecting {
      font-size: 0.75rem;
      opacity: 0.7;
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }
    .device-bar .detecting .spinner {
      width: 14px;
      height: 14px;
      border: 2px solid rgba(255,255,255,0.3);
      border-top-color: #fff;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
    .device-bar .manual-note { font-size: 0.6875rem; opacity: 0.6; margin-top: 0.25rem; }
    
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
    
    /* Submitted section styling */
    .section.submitted .section-header {
      background: #dcfce7;
      border-bottom: 1px solid #6ee7b7;
    }
    .section.submitted .section-header:hover { background: #c9f2d6; }
    .section.submitted .section-number {
      background: var(--success);
    }
    .section.submitted .section-number::after {
      content: ' ✓';
      font-size: 0.65rem;
    }
    .section.submitted .section-title h2 { color: #166534; }
    .section.submitted .section-title p { color: #166534; }
    
    /* Previous submission row inside a section */
    .past-submission-row {
      background: #f0fdf4;
      border: 1px solid #6ee7b7;
      border-radius: 10px;
      padding: 1rem 1.25rem;
      margin-bottom: 1rem;
      display: flex;
      align-items: center;
      gap: 1rem;
      flex-wrap: wrap;
    }
    .past-submission-row .past-info {
      flex: 1;
      min-width: 200px;
    }
    .past-submission-row .past-name {
      font-weight: 600;
      font-size: 0.875rem;
      color: var(--ink);
      word-break: break-all;
    }
    .past-submission-row .past-date {
      font-size: 0.75rem;
      color: var(--muted);
    }
    .past-submission-row .past-actions {
      display: flex;
      gap: 0.5rem;
    }
    .btn-outline-sm {
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      padding: 0.4rem 0.9rem;
      font: inherit;
      font-size: 0.8125rem;
      font-weight: 600;
      border-radius: 20px;
      cursor: pointer;
      border: 1.5px solid var(--line);
      background: #fff;
      color: var(--ink);
      transition: background 0.15s, border-color 0.15s;
    }
    .btn-outline-sm:hover { background: var(--cream-2); border-color: var(--muted); }
    .btn-outline-sm.danger { color: var(--error); border-color: #fca5a5; }
    .btn-outline-sm.danger:hover { background: #fee2e2; border-color: #f87171; }
    
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
    
    /* Submit all button */
    .submit-all {
      background: var(--saffron);
      color: #fff;
      border: none;
      border-radius: 12px;
      padding: 1rem 2rem;
      font: inherit;
      font-size: 1rem;
      font-weight: 700;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
      width: 100%;
      max-width: 400px;
      margin: 2rem auto;
      transition: background 0.15s, transform 0.1s;
    }
    .submit-all:hover { background: var(--saffron-dark); transform: translateY(-1px); }
    .submit-all:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
    .submit-all svg { width: 20px; height: 20px; }
    
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
    .step-card .field-result {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.5rem 0.75rem;
      background: #fff;
      border: 1px solid var(--success);
      border-radius: 6px;
      font-size: 0.875rem;
      font-weight: 600;
      color: var(--success);
    }
    .step-card .field-result svg { width: 18px; height: 18px; }
    
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
      .setup-guide-content { display: block !important; }
    }
  </style>
</head>
<body>
  <div class="container">
    <a href="/" class="back">← Back to Write Lao</a>
    
    <h1>Manual Tester Guide</h1>
    <p class="subtitle">Record a video for each section and submit your testing evidence</p>
    
    <!-- Saved Settings Bar (shows when settings are already saved) -->
    <div class="saved-settings-bar" id="savedSettingsBar" style="display: none;">
      <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="var(--success)" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
      <span class="saved-item"><strong>Device:</strong> <span id="savedDevice"></span></span>
      <span class="saved-item"><strong>OS:</strong> <span id="savedOS"></span></span>
      <span class="saved-item"><strong>App:</strong> <span id="savedApp"></span></span>
      <span class="saved-item"><strong>Tester:</strong> <span id="savedTester"></span></span>
      <button class="edit-btn" onclick="showSetupGuide()">Edit Settings</button>
    </div>
    
    <!-- Previous Submissions (shows when returning tester has past uploads) -->
    <div class="section" id="previousSubmissions" style="display:none; margin-bottom:2rem;">
      <div class="section-header" onclick="toggleSection(this)" style="cursor:pointer; background:#dcfce7; border-bottom:1px solid #6ee7b7;">
        <div class="section-number" style="background:var(--success);">✓</div>
        <div class="section-title">
          <h2 style="color:#166534;">Previously Submitted</h2>
          <p style="color:#166534;">You've already submitted these sections</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content" style="padding:1rem 1.5rem;"></div>
    </div>
    
    <!-- Device Setup Visual Guide -->
    <div class="setup-guide open" id="setupGuide">
      <div class="setup-guide-header" onclick="toggleSetupGuide()">
        <h3>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>
          Device Setup (Required for submission)
        </h3>
        <span class="completed-badge" id="setupCompleted" style="display: none;">Completed</span>
      </div>
      <div class="setup-guide-content">
        
        <!-- Step 1: Find Settings App -->
        <div class="step-card">
          <div class="step-card-header">
            <span class="step-num">1</span>
            <h4>Find the Settings App on your device</h4>
          </div>
          <p>Open your device's Settings app. Look for the gray gear icon.</p>
          <img src="/assets/testing/find_settings_app.jpg" alt="Find Settings App" loading="lazy">
        </div>
        
        <!-- Step 2: Find iOS Version -->
        <div class="step-card">
          <div class="step-card-header">
            <span class="step-num">2</span>
            <h4>Find your iOS Version</h4>
          </div>
          <p>Scroll down in Settings and tap "About" (at the top). Your iOS version is shown at the top.</p>
          <img src="/assets/testing/find_ios_version_in_settings.jpg" alt="Find iOS Version" loading="lazy">
        </div>
        
        <!-- Step 3: Find Model Name -->
        <div class="step-card">
          <div class="step-card-header">
            <span class="step-num">3</span>
            <h4>Find your Device Model Name</h4>
          </div>
          <p>In the same About screen, look for "Model Name" (not Model Number). This shows your exact device.</p>
          <img src="/assets/testing/find_model_name_in_settings.jpg" alt="Find Model Name" loading="lazy">
        </div>
        
        <!-- Step 4: Enter Your Settings -->
        <div class="step-card">
          <div class="step-card-header">
            <span class="step-num">4</span>
            <h4>Enter Your Settings Below</h4>
          </div>
          <p>Fill in the fields below. Your settings will be saved automatically for next time!</p>
          <div class="device-fields-grid">
            <div class="device-field-input">
              <label>Device Model <span style="color: var(--error);">*</span></label>
              <input type="text" id="deviceModel" placeholder="e.g. iPhone 15 Pro Max" required>
            </div>
            <div class="device-field-input">
              <label>OS / Version <span style="color: var(--error);">*</span></label>
              <input type="text" id="osVersion" placeholder="e.g. iOS 18.2" required>
            </div>
            <div class="device-field-input">
              <label>App Version</label>
              <input type="text" id="appVersion" placeholder="e.g. 1.2.0">
            </div>
            <div class="device-field-input">
              <label>Your Name</label>
              <input type="text" id="testerName" placeholder="Your name">
            </div>
          </div>
          <button class="save-settings-btn" onclick="saveAndVerifySettings()">
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Save Settings
          </button>
        </div>
        
      </div>
    </div>
    
    <!-- Screen Recording Instructions -->
    <div class="screen-record-guide">
      <div class="guide-header">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
        <h3>How to Record Your Screen</h3>
      </div>
      <div class="guide-steps">
        <div class="guide-os">
          <strong>iPhone / iPad (iOS 11+):</strong>
          <ol>
            <li>Go to <strong>Settings → Control Center</strong></li>
            <li>Tap the <strong>+</strong> next to "Screen Recording"</li>
            <li>Open Control Center (swipe down from top-right on Face ID, or up from bottom on Touch ID)</li>
            <li>Tap the <strong>record button</strong> (circle with dot)</li>
            <li>Wait 3 seconds — recording starts</li>
            <li>Record your test, then tap the red bar at top to stop</li>
 <li>Video saves to Photos → your screen recordings</li>
          </ol>
        </div>
        <div class="guide-os">
          <strong>Android (Android 10+):</strong>
          <ol>
            <li>Swipe down from top of screen to open Quick Settings</li>
            <li>Look for "Screen Record" or tap <strong>edit</strong> to add it</li>
            <li>Tap<strong>Screen Record</strong> and choose settings</li>
            <li>Tap <strong>Start</strong></li>
            <li>Record your test, then swipe down and tap <strong>Stop</strong></li>
            <li>Video saves to Movies or your gallery</li>
          </ol>
        </div>
      </div>
      <div class="guide-note">
        <strong>Then:</strong> Come back here, tap "Select Video" for each section, and choose your screen recording from the gallery.
      </div>
    </div>
    
    <div class="intro-box">
      <p><strong>How it works:</strong> Fill in your device info above, then for each section: (1) read the steps, (2) check the boxes, (3) record/upload a video showing the feature working, (4) submit. You can submit section-by-section or all at once at the end.</p>
    </div>
    
    <!-- ──────────────────── SECTION 1: APP LAUNCH ──────────────────── -->
    <section class="section open" id="launch" data-section="launch">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">1</div>
        <div class="section-title">
          <h2>App Launch & Home Screen</h2>
          <p>Verify app loads correctly and shows the home screen</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>Launch the app</strong> — Tap the Write Lao icon on your device.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>Watch for splash screen</strong> — App icon and loading indicator should appear briefly.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>Verify home screen loads</strong> — You should see:</p>
            <ul style="margin: 0.5rem 0 0 1.25rem;">
              <li>App title "Write Lao" in the app bar</li>
              <li>Two tabs: "CHARACTERS" and "VOCABULARY"</li>
              <li>Progress card showing lessons completed and stars earned</li>
              <li>List of lessons with character previews</li>
            </ul>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>Check bottom navigation</strong> — Three icons: Lessons, Review, Progress.</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">Checklist</div>
          <label class="check-item"><input type="checkbox" data-section="launch"> Splash screen appears</label>
          <label class="check-item"><input type="checkbox" data-section="launch"> App bar shows "Write Lao"</label>
          <label class="check-item"><input type="checkbox" data-section="launch"> Tab bar shows CHARACTERS and VOCABULARY</label>
          <label class="check-item"><input type="checkbox" data-section="launch"> Progress card visible</label>
          <label class="check-item"><input type="checkbox" data-section="launch"> Bottom navigation visible</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-launch" data-section="launch">
          <input type="file" id="video-launch">
          <div class="video-upload-label" onclick="document.getElementById('video-launch').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m1510-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 511.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>Click to record or upload video</strong></p>
            <p class="hint">Record your screen first, then tap to select from gallery • Max 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-launch" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-launch"></span>
              <span class="video-size" id="size-launch"></span>
              <button class="btn-remove" onclick="removeVideo('launch')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                Remove
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-launch">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-launch" style="width: 0%"></div></div>
            <div class="upload-status" id="status-launch">Uploading...</div>
          </div>
          <div class="upload-success" id="success-launch">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Video uploaded successfully!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 2: CHARACTER LESSONS ──────────────────── -->
    <section class="section" id="lessons" data-section="lessons">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">2</div>
        <div class="section-title">
          <h2>Character Lessons</h2>
          <p>Navigate and start a character lesson</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>View lesson list</strong> — On home screen, scroll through the CHARACTERS tab. Each lesson card shows:</p>
            <ul style="margin: 0.5rem 0 0 1.25rem;">
              <li>Lesson title (e.g., "Consonants 1")</li>
              <li>Character previews (small Lao letters)</li>
              <li>Star rating (0-3 stars)</li>
            </ul>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>Tap a lesson</strong> — This opens the Lesson Detail screen.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>Verify lesson detail</strong> — Shows all characters in the lesson with names and romanization.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>Start practice</strong> — Tap "Practice" button to begin guided practice.</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">Checklist</div>
          <label class="check-item"><input type="checkbox" data-section="lessons"> Lesson cards display correctly</label>
          <label class="check-item"><input type="checkbox" data-section="lessons"> Star ratings show (0-3)</label>
          <label class="check-item"><input type="checkbox" data-section="lessons"> Tapping lesson opens detail screen</label>
          <label class="check-item"><input type="checkbox" data-section="lessons"> Lesson detail shows all characters</label>
          <label class="check-item"><input type="checkbox" data-section="lessons"> Practice button navigates to practice screen</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-lessons" data-section="lessons">
          <input type="file" id="video-lessons">
          <div class="video-upload-label" onclick="document.getElementById('video-lessons').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>Click to record or upload video</strong></p>
            <p class="hint">Record your screen first, then tap to select from gallery • Max 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-lessons" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-lessons"></span>
              <span class="video-size" id="size-lessons"></span>
              <button class="btn-remove" onclick="removeVideo('lessons')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                Remove
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-lessons">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-lessons" style="width: 0%"></div></div>
            <div class="upload-status" id="status-lessons">Uploading...</div>
          </div>
          <div class="upload-success" id="success-lessons">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Video uploaded successfully!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 3: PRACTICE MODE ──────────────────── -->
    <section class="section" id="practice" data-section="practice">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">3</div>
        <div class="section-title">
          <h2>Practice Mode</h2>
          <p>Stroke-by-stroke guided writing practice</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>Identify the canvas</strong> — Large white square in the center. Lao character displayed above.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>Draw the stroke</strong> — Follow the ghost stroke hint. The app evaluates as you draw.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>Complete all strokes</strong> — Progress bar shows current position. "Next" button appears when done.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>Test the controls</strong> — Bottom buttons:</p>
            <ul style="margin: 0.5rem 0 0 1.25rem;">
              <li><strong>Delete</strong> — Clears your drawing</li>
              <li><strong>Volume</strong> — Plays pronunciation audio</li>
              <li><strong>Eye icon</strong> — Toggles stroke hints on/off</li>
            </ul>
          </div>
        </div>
        
        <div class="tip">
          <strong>Tip:</strong> The hint toggle is useful for testing the "test mode" experience within practice.
        </div>
        
        <div class="checklist">
          <div class="checklist-label">Checklist</div>
          <label class="check-item"><input type="checkbox" data-section="practice"> Writing canvas renders</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> Ghost stroke hints visible</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> Drawing is recognized</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> Progress bar updates</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> Delete button clears canvas</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> Volume button plays audio</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> Hint toggle works</label>
          <label class="check-item"><input type="checkbox" data-section="practice"> Next button appears when complete</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-practice" data-section="practice">
          <input type="file" id="video-practice">
          <div class="video-upload-label" onclick="document.getElementById('video-practice').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>Click to record or upload video</strong></p>
            <p class="hint">Record your screen first, then tap to select from gallery • Max 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-practice" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-practice"></span>
              <span class="video-size" id="size-practice"></span>
              <button class="btn-remove" onclick="removeVideo('practice')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                Remove
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-practice">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-practice" style="width: 0%"></div></div>
            <div class="upload-status" id="status-practice">Uploading...</div>
          </div>
          <div class="upload-success" id="success-practice">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Video uploaded successfully!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 4: TEST MODE ──────────────────── -->
    <section class="section" id="test" data-section="test">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">4</div>
        <div class="section-title">
          <h2>Test Mode</h2>
          <p>Timed test without stroke hints</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>Start test from lesson detail</strong> — Tap "Test" button on the lesson detail screen.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>Observe timer</strong> — Timer in app bar counts up. No stroke hints shown.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>Write from memory</strong> — Draw each character without guidance. After 3 failed attempts, hint appears.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>Complete test</strong> — After all characters, see results screen with star rating (1-3).</p>
          </div>
        </div>
        
        <div class="tip tip-success">
          <strong>Good result:</strong> 3 stars = fast + accurate. 2 stars = some mistakes. 1 star = significant issues.
        </div>
        
        <div class="checklist">
          <div class="checklist-label">Checklist</div>
          <label class="check-item"><input type="checkbox" data-section="test"> Timer starts and counts up</label>
          <label class="check-item"><input type="checkbox" data-section="test"> No stroke hints initially</label>
          <label class="check-item"><input type="checkbox" data-section="test"> Hint appears after 3 failures</label>
          <label class="check-item"><input type="checkbox" data-section="test"> Results screen shows stars</label>
          <label class="check-item"><input type="checkbox" data-section="test"> Star rating matches performance</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-test" data-section="test">
          <input type="file" id="video-test">
          <div class="video-upload-label" onclick="document.getElementById('video-test').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>Click to record or upload video</strong></p>
            <p class="hint">Record your screen first, then tap to select from gallery • Max 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-test" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-test"></span>
              <span class="video-size" id="size-test"></span>
              <button class="btn-remove" onclick="removeVideo('test')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                Remove
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-test">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-test" style="width: 0%"></div></div>
            <div class="upload-status" id="status-test">Uploading...</div>
          </div>
          <div class="upload-success" id="success-test">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Video uploaded successfully!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 5: VOCABULARY ──────────────────── -->
    <section class="section" id="vocab" data-section="vocab">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">5</div>
        <div class="section-title">
          <h2>Vocabulary Lessons</h2>
          <p>Learn words with audio and spaced repetition</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>Switch to VOCABULARY tab</strong> — Tap the second tab on the home screen.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>View unit list</strong> — Shows vocabulary units with completion status. First unit is free.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>Open a unit</strong> — Tap an unlocked unit to see its lessons.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>Start a lesson</strong> — Tap a lesson to begin. Word card shows:</p>
            <ul style="margin: 0.5rem 0 0 1.25rem;">
              <li>Lao word in large text</li>
              <li>English translation</li>
              <li>Audio pronunciation button</li>
              <li>Example sentence</li>
            </ul>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">5</div>
          <div class="step-content">
            <p><strong>Practice the word</strong> — Write the word on canvas, then see "Hear & Identify" listening exercise.</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">Checklist</div>
          <label class="check-item"><input type="checkbox" data-section="vocab"> VOCABULARY tab accessible</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> Unit list displays correctly</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> Locked units show lock icon</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> Word card shows Lao + English</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> Audio plays correctly</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> Writing practice works</label>
          <label class="check-item"><input type="checkbox" data-section="vocab"> Hear & Identify exercise works</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-vocab" data-section="vocab">
          <input type="file" id="video-vocab">
          <div class="video-upload-label" onclick="document.getElementById('video-vocab').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>Click to record or upload video</strong></p>
            <p class="hint">Record your screen first, then tap to select from gallery • Max 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-vocab" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-vocab"></span>
              <span class="video-size" id="size-vocab"></span>
              <button class="btn-remove" onclick="removeVideo('vocab')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                Remove
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-vocab">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-vocab" style="width: 0%"></div></div>
            <div class="upload-status" id="status-vocab">Uploading...</div>
          </div>
          <div class="upload-success" id="success-vocab">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Video uploaded successfully!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 6: REVIEW MODE ──────────────────── -->
    <section class="section" id="review" data-section="review">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">6</div>
        <div class="section-title">
          <h2>Review Mode</h2>
          <p>Custom practice for selected characters or vocab</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>Navigate to Review</strong> — Tap the Review icon in bottom navigation.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>Select characters</strong> — Two tabs: "CHARACTERS" and "VOCAB". Choose characters by tapping them.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>Use quick filters</strong> — "Weak Characters" auto-selects struggling ones. "All" selects everything.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>Start custom practice</strong> — Tap "Practice Selected" button to begin with chosen characters.</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">Checklist</div>
          <label class="check-item"><input type="checkbox" data-section="review"> Review screen accessible</label>
          <label class="check-item"><input type="checkbox" data-section="review"> Character selection works</label>
          <label class="check-item"><input type="checkbox" data-section="review"> Weak Characters filter works</label>
          <label class="check-item"><input type="checkbox" data-section="review"> Practice Selected starts practice</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-review" data-section="review">
          <input type="file" id="video-review">
          <div class="video-upload-label" onclick="document.getElementById('video-review').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>Click to record or upload video</strong></p>
            <p class="hint">Record your screen first, then tap to select from gallery • Max 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-review" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-review"></span>
              <span class="video-size" id="size-review"></span>
              <button class="btn-remove" onclick="removeVideo('review')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                Remove
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-review">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-review" style="width: 0%"></div></div>
            <div class="upload-status" id="status-review">Uploading...</div>
          </div>
          <div class="upload-success" id="success-review">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Video uploaded successfully!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 7: PROGRESS ──────────────────── -->
    <section class="section" id="progress" data-section="progress">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">7</div>
        <div class="section-title">
          <h2>Progress Tracking</h2>
          <p>View overall learning progress</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>Go to Progress</strong> — Tap the Progress icon in bottom navigation.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>Check stats</strong> — Shows lessons completed and stars earned.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>View phase progress</strong> — Bar charts for each phase (Consonants, Vowels, Tone Marks, Numerals, Ligatures).</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>Check suggested next</strong> — "Up Next" card suggests the next lesson to start.</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">Checklist</div>
          <label class="check-item"><input type="checkbox" data-section="progress"> Progress screen accessible</label>
          <label class="check-item"><input type="checkbox" data-section="progress"> Stats display correctly</label>
          <label class="check-item"><input type="checkbox" data-section="progress"> Phase progress bars render</label>
          <label class="check-item"><input type="checkbox" data-section="progress"> Suggested next lesson shown</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-progress" data-section="progress">
          <input type="file" id="video-progress">
          <div class="video-upload-label" onclick="document.getElementById('video-progress').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>Click to record or upload video</strong></p>
            <p class="hint">Record your screen first, then tap to select from gallery • Max 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-progress" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-progress"></span>
              <span class="video-size" id="size-progress"></span>
              <button class="btn-remove" onclick="removeVideo('progress')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                Remove
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-progress">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-progress" style="width: 0%"></div></div>
            <div class="upload-status" id="status-progress">Uploading...</div>
          </div>
          <div class="upload-success" id="success-progress">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Video uploaded successfully!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 8: SETTINGS ──────────────────── -->
    <section class="section" id="settings" data-section="settings">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">8</div>
        <div class="section-title">
          <h2>Settings</h2>
          <p>Adjust app preferences</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>Open Settings</strong> — Tap the gear icon in the app bar.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>Adjust stroke tolerance</strong> — Slider from "Forgiving" to "Strict". Test with different settings.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>Toggle sound effects</strong> — Switch on/off. Test by completing a character.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>Toggle haptic feedback</strong> — Switch on/off. Test by drawing on canvas.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">5</div>
          <div class="step-content">
            <p><strong>Reset progress</strong> — Test the reset function (with confirmation dialog).</p>
          </div>
        </div>
        
        <div class="tip tip-error">
          <strong>Warning:</strong> Reset progress is destructive. Only test if you can restore or don't mind losing data.
        </div>
        
        <div class="checklist">
          <div class="checklist-label">Checklist</div>
          <label class="check-item"><input type="checkbox" data-section="settings"> Settings screen opens</label>
          <label class="check-item"><input type="checkbox" data-section="settings"> Stroke tolerance slider works</label>
          <label class="check-item"><input type="checkbox" data-section="settings"> Sound toggle works</label>
          <label class="check-item"><input type="checkbox" data-section="settings"> Haptic toggle works</label>
          <label class="check-item"><input type="checkbox" data-section="settings"> Reset shows confirmation</label>
          <label class="check-item"><input type="checkbox" data-section="settings"> Reset actually clears progress</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-settings" data-section="settings">
          <input type="file" id="video-settings">
          <div class="video-upload-label" onclick="document.getElementById('video-settings').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>Click to record or upload video</strong></p>
            <p class="hint">Record your screen first, then tap to select from gallery • Max 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-settings" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-settings"></span>
              <span class="video-size" id="size-settings"></span>
              <button class="btn-remove" onclick="removeVideo('settings')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                Remove
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-settings">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-settings" style="width: 0%"></div></div>
            <div class="upload-status" id="status-settings">Uploading...</div>
          </div>
          <div class="upload-success" id="success-settings">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Video uploaded successfully!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 9: IN-APP PURCHASE ──────────────────── -->
    <section class="section" id="iap" data-section="iap">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">9</div>
        <div class="section-title">
          <h2>In-App Purchase</h2>
          <p>Unlock vocabulary course</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>Find upsell prompt</strong> — Banner appears on home screen if vocabulary not purchased.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>Tap Upgrade</strong> — Opens the upsell/purchase screen.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>Check restore option</strong> — "Restore Purchases" button should be visible.</p>
          </div>
        </div>
        
        <div class="tip">
          <strong>Note:</strong> Only test actual purchase flow if you have a sandbox account. Focus on UI and restore flow otherwise.
        </div>
        
        <div class="checklist">
          <div class="checklist-label">Checklist</div>
          <label class="check-item"><input type="checkbox" data-section="iap"> Upsell banner visible (if not purchased)</label>
          <label class="check-item"><input type="checkbox" data-section="iap"> Upgrade button navigates to purchase screen</label>
          <label class="check-item"><input type="checkbox" data-section="iap"> Restore Purchases button present</label>
          <label class="check-item"><input type="checkbox" data-section="iap"> Price displayed correctly</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-iap" data-section="iap">
          <input type="file" id="video-iap">
          <div class="video-upload-label" onclick="document.getElementById('video-iap').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>Click to record or upload video</strong></p>
            <p class="hint">Record your screen first, then tap to select from gallery • Max 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-iap" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-iap"></span>
              <span class="video-size" id="size-iap"></span>
              <button class="btn-remove" onclick="removeVideo('iap')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                Remove
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-iap">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-iap" style="width: 0%"></div></div>
            <div class="upload-status" id="status-iap">Uploading...</div>
          </div>
          <div class="upload-success" id="success-iap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Video uploaded successfully!
          </div>
        </div>
      </div>
    </section>
    
    <!-- ──────────────────── SECTION 10: OFFLINE ──────────────────── -->
    <section class="section" id="offline" data-section="offline">
      <div class="section-header" onclick="toggleSection(this)">
        <div class="section-number">10</div>
        <div class="section-title">
          <h2>Offline Functionality</h2>
          <p>Verify app works without internet</p>
        </div>
        <div class="section-toggle">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </div>
      <div class="section-content">
        <div class="step">
          <div class="step-marker">1</div>
          <div class="step-content">
            <p><strong>Enable airplane mode</strong> — Turn on airplane mode or disable WiFi/cellular.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">2</div>
          <div class="step-content">
            <p><strong>Launch app</strong> — App should launch normally and show home screen.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">3</div>
          <div class="step-content">
            <p><strong>Test core features</strong> — Practice, test, and review modes should all work.</p>
          </div>
        </div>
        <div class="step">
          <div class="step-marker">4</div>
          <div class="step-content">
            <p><strong>Verify progress saves</strong> — Complete a lesson, check progress updates (may need to restart app).</p>
          </div>
        </div>
        
        <div class="checklist">
          <div class="checklist-label">Checklist</div>
          <label class="check-item"><input type="checkbox" data-section="offline"> App launches in airplane mode</label>
          <label class="check-item"><input type="checkbox" data-section="offline"> Home screen loads</label>
          <label class="check-item"><input type="checkbox" data-section="offline"> Practice mode works offline</label>
          <label class="check-item"><input type="checkbox" data-section="offline"> Test mode works offline</label>
          <label class="check-item"><input type="checkbox" data-section="offline"> Progress persists after offline use</label>
        </div>
        
        <!-- Video Upload -->
        <div class="video-upload" id="upload-offline" data-section="offline">
          <input type="file" id="video-offline">
          <div class="video-upload-label" onclick="document.getElementById('video-offline').click()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m15 10-4.5 3V8a3 3 0 0 0-5.12-2.13A3 3 0 0 0 2.73 8.5 3 3 0 0 0 5 11.62V14.5l4.5 3 4.5-3V11.62a3 3 0 0 0-1.65-2.63A3 3 0 0 0 7.5 10"/><path d="M18 12a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"/></svg>
            <p><strong>Click to record or upload video</strong></p>
            <p class="hint">Record your screen first, then tap to select from gallery • Max 500MB</p>
          </div>
          <div class="video-preview">
            <video id="preview-offline" controls></video>
            <div class="video-info">
              <span class="video-name" id="name-offline"></span>
              <span class="video-size" id="size-offline"></span>
              <button class="btn-remove" onclick="removeVideo('offline')">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                Remove
              </button>
            </div>
          </div>
          <div class="upload-progress" id="progress-offline">
            <div class="progress-bar"><div class="progress-bar-fill" id="progress-fill-offline" style="width: 0%"></div></div>
            <div class="upload-status" id="status-offline">Uploading...</div>
          </div>
          <div class="upload-success" id="success-offline">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Video uploaded successfully!
          </div>
        </div>
      </div>
    </section>
    
    <button class="submit-all" id="submitAllBtn" onclick="submitAllVideos()">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
      Submit All Videos
    </button>
    
    <div class="guide-footer">
      <p>Questions? Email <a href="mailto:help@maitrigroup.co">help@maitrigroup.co</a></p>
      <p>Write Lao v1.0 · Manual Tester Guide</p>
    </div>
  </div>
  
  <script src="https://unpkg.com/smart-browser-detection@1.0.3/dist/smart-browser-detection.min.js"></script>
  <script>
    // ═══════════════════════════════════════════════════════════════════════
    // LOCALSTORAGE — Sticky device settings
    // ═══════════════════════════════════════════════════════════════════════
    
    const STORAGE_KEY = 'tester_guide_settings';
    let currentTesterId = null;
    
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
      // Read from DOM first, fall back to localStorage
      const dom = {
        deviceModel: document.getElementById('deviceModel')?.value || '',
        osVersion: document.getElementById('osVersion')?.value || '',
        appVersion: document.getElementById('appVersion')?.value || '',
        testerName: document.getElementById('testerName')?.value || ''
      };
      
      // If DOM fields are empty, try localStorage
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
    
    function getOrComputeTesterId() {
      if (currentTesterId) return currentTesterId;
      const settings = loadSettings();
      if (settings && settings.testerId) {
        currentTesterId = settings.testerId;
        return currentTesterId;
      }
      return null;
    }
    
    function populateSettingsFromStorage() {
      const settings = loadSettings();
      if (settings) {
        if (settings.deviceModel) document.getElementById('deviceModel').value = settings.deviceModel;
        if (settings.osVersion) document.getElementById('osVersion').value = settings.osVersion;
        if (settings.appVersion) document.getElementById('appVersion').value = settings.appVersion;
        if (settings.testerName) document.getElementById('testerName').value = settings.testerName;
        if (settings.testerId) currentTesterId = settings.testerId;
        return true;
      }
      return false;
    }
    
    function showSavedSettingsBar() {
      const settings = loadSettings();
      if (settings && settings.deviceModel && settings.osVersion) {
        document.getElementById('savedDevice').textContent = settings.deviceModel;
        document.getElementById('savedOS').textContent = settings.osVersion;
        document.getElementById('savedApp').textContent = settings.appVersion || 'Not set';
        document.getElementById('savedTester').textContent = settings.testerName || 'Anonymous';
        document.getElementById('savedSettingsBar').style.display = 'flex';
        document.getElementById('setupGuide').classList.remove('open');
        document.getElementById('setupCompleted').style.display = 'inline-block';
        return true;
      }
      return false;
    }
    
    // ── Fetch and display previous submissions ──────────────────────────
    var allSubmissions = []; // cached from last fetch
    
    async function loadPreviousSubmissions() {
      const tid = getOrComputeTesterId();
      if (!tid) return;
      
      try {
        const res = await fetch('/api/tester/my-submissions?tester_id=' + encodeURIComponent(tid));
        if (!res.ok) return;
        const data = await res.json();
        if (data.submissions && data.submissions.length > 0) {
          allSubmissions = data.submissions;
          applySubmissionsToPage(data.submissions);
        }
      } catch (err) {
        console.error('Failed to load previous submissions:', err);
      }
    }
    
    var sectionLabels = {
      launch: '1. App Launch & Home Screen',
      lessons: '2. Character Lessons',
      practice: '3. Practice Mode',
      test: '4. Test Mode',
      vocab: '5. Vocabulary Lessons',
      review: '6. Review Mode',
      progress: '7. Progress Tracking',
      settings: '8. Settings',
      iap: '9. In-App Purchase',
      offline: '10. Offline Functionality'
    };
    
    var allSectionKeys = ['launch','lessons','practice','test','vocab','review','progress','settings','iap','offline'];
    
    function applySubmissionsToPage(submissions) {
      // Build map: section → latest submission
      var latestBySection = {};
      submissions.forEach(function(sub) {
        if (!latestBySection[sub.section] || sub.id > latestBySection[sub.section].id) {
          latestBySection[sub.section] = sub;
        }
      });
      
      // Update the global "Previously Submitted" summary container
      var container = document.getElementById('previousSubmissions');
      if (container) {
        var contentEl = container.querySelector('.section-content');
        var html = '<div class="checklist-label">Previously Submitted Videos</div>';
        var count = 0;
        allSectionKeys.forEach(function(key) {
          var sub = latestBySection[key];
          if (sub) {
            count++;
            html += '<div class="check-item past-submission" style="justify-content:space-between">' +
              '<span><span style="color:var(--success);font-weight:700;">&#10003;</span> ' +
              (sectionLabels[key] || key) +
              ' — ' + (sub.tester_name || '') + '</span>' +
              '<span style="font-size:0.75rem;color:var(--muted)">' +
              (sub.uploaded_at ? new Date(sub.uploaded_at + 'Z').toLocaleDateString() : '') +
              '</span></div>';
          }
        });
        if (count > 0) {
          contentEl.innerHTML = html;
          container.style.display = 'block';
        } else {
          container.style.display = 'none';
        }
      }
      
      // Update each section in the DOM
      var firstUnsubmitted = null;
      allSectionKeys.forEach(function(key) {
        var sectionEl = document.getElementById(key);
        if (!sectionEl) return;
        
        var sub = latestBySection[key];
        if (sub) {
          // Mark section as submitted and collapse it
          sectionEl.classList.add('submitted');
          sectionEl.classList.remove('open');
          
          // Change section number to checkmark
          var numEl = sectionEl.querySelector('.section-number');
          if (numEl) {
            numEl.textContent = '✓';
            numEl.style.background = '#16a34a';
          }
          
          // Inject previous-submission row into section content
          var contentEl = sectionEl.querySelector('.section-content');
          if (contentEl) {
            // Remove any existing past row
            var existing = contentEl.querySelector('.past-submission-row');
            if (existing) existing.remove();
            
            var dateStr = sub.uploaded_at
              ? new Date(sub.uploaded_at + 'Z').toLocaleString()
              : 'Unknown date';
            var shortName = sub.filename ? sub.filename.split('/').pop() : 'video';
            
            var row = document.createElement('div');
            row.className = 'past-submission-row';
            row.innerHTML =
              '<div class="past-info">' +
                '<div class="past-name" title="' + (sub.filename || '') + '">📹 ' + shortName + '</div>' +
                '<div class="past-date">Uploaded ' + dateStr + '</div>' +
              '</div>' +
              '<div class="past-actions">' +
                '<button class="btn-outline-sm" onclick="viewPastVideo(\\'' + key + '\\',' + sub.id + ')">' +
                  '<svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2"><polygon points="5 3 19 12 5 21 5 3"/></svg> View' +
                '</button>' +
                '<button class="btn-outline-sm danger" onclick="deletePastSubmission(\\'' + key + '\\',' + sub.id + ')">' +
                  '<svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg> Delete' +
                '</button>' +
              '</div>';
            contentEl.insertBefore(row, contentEl.firstChild);
          }
        } else {
          // Not submitted — keep normal styling
          sectionEl.classList.remove('submitted');
          var numEl = sectionEl.querySelector('.section-number');
          if (numEl) {
            // Restore original number
            var originalNum = allSectionKeys.indexOf(key) + 1;
            numEl.textContent = String(originalNum);
            numEl.style.background = '#c8573f';
          }
          // Remove any past row
          var contentEl = sectionEl.querySelector('.section-content');
          if (contentEl) {
            var existing = contentEl.querySelector('.past-submission-row');
            if (existing) existing.remove();
          }
          
          // Track first unsubmitted
          if (!firstUnsubmitted) firstUnsubmitted = key;
        }
      });
      
      // Auto-open the first unsubmitted section
      if (firstUnsubmitted) {
        var el = document.getElementById(firstUnsubmitted);
        if (el && !el.classList.contains('open')) {
          el.classList.add('open');
        }
        // Scroll to it
        setTimeout(function() {
          var target = document.getElementById(firstUnsubmitted);
          if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }, 200);
      }
      
      // Make view/delete functions globally accessible
      window.viewPastVideo = viewPastVideo;
      window.deletePastSubmission = deletePastSubmission;
    }
    
    function viewPastVideo(section, submissionId) {
      // Find the submission
      var sub = null;
      for (var i = 0; i < allSubmissions.length; i++) {
        if (allSubmissions[i].id === submissionId) { sub = allSubmissions[i]; break; }
      }
      if (!sub || !sub.filename) return;
      
      var videoUrl = '/api/tester/video/' + encodeURIComponent(sub.filename);
      window.open(videoUrl, '_blank');
    }
    
    async function deletePastSubmission(section, submissionId) {
      if (!confirm('Delete this submission? The video will be permanently removed.')) return;
      
      try {
        var res = await fetch('/api/tester/submission/' + submissionId, { method: 'DELETE' });
        if (res.ok) {
          // Remove from local cache
          allSubmissions = allSubmissions.filter(function(s) { return s.id !== submissionId; });
          // Re-apply to page
          applySubmissionsToPage(allSubmissions);
          // If all submissions gone, hide the summary
          if (allSubmissions.length === 0) {
            var container = document.getElementById('previousSubmissions');
            if (container) container.style.display = 'none';
          }
        } else {
          alert('Failed to delete submission.');
        }
      } catch (err) {
        alert('Error deleting: ' + err.message);
      }
    }
    
    function showSetupGuide() {
      document.getElementById('savedSettingsBar').style.display = 'none';
      document.getElementById('setupGuide').classList.add('open');
      document.getElementById('setupCompleted').style.display = 'none';
      var prev = document.getElementById('previousSubmissions');
      if (prev) prev.style.display = 'none';
      // Clear submitted styling from sections (they'll be re-applied on save)
      allSectionKeys.forEach(function(key) {
        var el = document.getElementById(key);
        if (el) {
          el.classList.remove('submitted');
          var numEl = el.querySelector('.section-number');
          if (numEl) {
            numEl.textContent = String(allSectionKeys.indexOf(key) + 1);
            numEl.style.background = '#c8573f';
          }
          var contentEl = el.querySelector('.section-content');
          if (contentEl) {
            var existing = contentEl.querySelector('.past-submission-row');
            if (existing) existing.remove();
          }
        }
      });
    }
    
    function toggleSetupGuide() {
      const guide = document.getElementById('setupGuide');
      guide.classList.toggle('open');
    }
    
    async function saveAndVerifySettings() {
      const deviceModel = document.getElementById('deviceModel').value.trim();
      const osVersion = document.getElementById('osVersion').value.trim();
      const appVersion = document.getElementById('appVersion').value.trim();
      const testerName = document.getElementById('testerName').value.trim();
      
      // Validation
      if (!deviceModel) {
        alert('Please enter your Device Model (e.g., iPhone 15 Pro Max)');
        document.getElementById('deviceModel').focus();
        return;
      }
      if (!osVersion) {
        alert('Please enter your OS Version (e.g., iOS 18.2)');
        document.getElementById('osVersion').focus();
        return;
      }
      
      // Register tester — get deterministic ID from server
      var testerId = null;
      try {
        var regRes = await fetch('/api/tester/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            deviceModel: deviceModel,
            osVersion: osVersion,
            appVersion: appVersion,
            testerName: testerName
          })
        });
        if (regRes.ok) {
          var regData = await regRes.json();
          testerId = regData.testerId;
          currentTesterId = testerId;
        }
      } catch (err) {
        console.error('Failed to register tester:', err);
      }
      
      // Save to localStorage (include testerId)
      saveSettings({
        deviceModel,
        osVersion,
        appVersion,
        testerName,
        testerId: testerId
      });
      
      // Show success and switch to saved bar
      showSavedSettingsBar();
      
      // Load previous submissions for this tester
      loadPreviousSubmissions();
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════
    
    function initPage() {
      // First try to load from localStorage
      if (showSavedSettingsBar()) {
        console.log('Loaded settings from localStorage');
        // Also load previous submissions for this tester
        loadPreviousSubmissions();
        return;
      }
      
      // Otherwise show setup guide
      showSetupGuide();
      console.log('Showing setup guide');
    }
    
    // Run on page load
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', initPage);
    } else {
      initPage();
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // VIDEO STORAGE AND UPLOAD
    // ═══════════════════════════════════════════════════════════════════════
    
    // Video storage per section
    const videoFiles = {};
    
    // Toggle section expand/collapse
    function toggleSection(header) {
      const section = header.closest('.section');
      section.classList.toggle('open');
    }
    
    // Handle file input changes
    const sections = ['launch', 'lessons', 'practice', 'test', 'vocab', 'review', 'progress', 'settings', 'iap', 'offline'];
    
    sections.forEach(section => {
      const input = document.getElementById('video-' + section);
      if (input) {
        input.addEventListener('change', function(e) {
          const file = e.target.files[0];
          if (file) {
            handleVideoSelect(section, file);
          }
        });
      }
    });
    
    // Drag and drop
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
      // Check file size (500MB limit)
      const maxSize = 500 * 1024 * 1024;
      if (file.size > maxSize) {
        alert('Video too large. Maximum size is 500MB.');
        return;
      }
      
      videoFiles[section] = file;
      
      // Show preview
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
        uploadBtn.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg> Upload';
        uploadBtn.onclick = function() { uploadSingleVideo(section); };
        infoDiv.appendChild(uploadBtn);
      }
    }
    
    async function uploadSingleVideo(section) {
      const btn = document.getElementById('upload-btn-' + section);
      if (btn) { btn.disabled = true; btn.textContent = 'Uploading...'; }
      
      const success = await uploadVideo(section);
      
      if (btn) {
        if (success) {
          btn.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg> Done';
          btn.disabled = true;
          btn.style.opacity = '0.6';
          btn.style.cursor = 'not-allowed';
        } else {
          btn.disabled = false;
          btn.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg> Upload';
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
    
    // Upload a single video — uses direct-to-R2 for files > 100 MB
    async function uploadVideo(section) {
      const file = videoFiles[section];
      if (!file) return null;
      
      // Get settings from form (for immediate upload) or localStorage
      const settings = getSettings();
      const deviceModel = settings.deviceModel || 'Unknown Device';
      const osVersion = settings.osVersion || 'Unknown OS';
      const appVersion = settings.appVersion || 'Unknown Version';
      const testerName = settings.testerName || 'Anonymous';
      const testerId = getOrComputeTesterId() || '';
      
      const progressEl = document.getElementById('progress-' + section);
      const fillEl = document.getElementById('progress-fill-' + section);
      const statusEl = document.getElementById('status-' + section);
      const successEl = document.getElementById('success-' + section);
      
      progressEl.classList.add('active');
      
      // ═══════════════════════════════════════════════════════════════
      // PATH A: Chunked upload (for files > 100 MB)
      // Splits file into 50MB chunks, each under the Worker body limit.
      // ═══════════════════════════════════════════════════════════════
      if (file.size > 100 * 1024 * 1024) {
        var CHUNK_SIZE = 50 * 1024 * 1024; // 50 MB per chunk
        var totalChunks = Math.ceil(file.size / CHUNK_SIZE);
        statusEl.textContent = 'Preparing upload (' + totalChunks + ' chunks)...';
        fillEl.style.width = '5%';
        
        var sessionId = null;
        var r2Key = null;
        
        try {
          // Step 1: Start multipart upload
          var startRes = await fetch('/api/tester/upload/start', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              section: section,
              deviceModel: deviceModel,
            }),
          });
          
          if (!startRes.ok) {
            var startErr = await startRes.json().catch(function() { return {}; });
            throw new Error(startErr.error || 'Failed to start upload (HTTP ' + startRes.status + ')');
          }
          
          var startData = await startRes.json();
          sessionId = startData.sessionId;
          r2Key = startData.key;
          
          // Step 2: Upload chunks
          for (var i = 0; i < totalChunks; i++) {
            var start = i * CHUNK_SIZE;
            var end = Math.min(start + CHUNK_SIZE, file.size);
            var chunk = file.slice(start, end);
            
            var chunkForm = new FormData();
            chunkForm.append('sessionId', sessionId);
            chunkForm.append('partNumber', String(i + 1));
            chunkForm.append('chunk', chunk, 'chunk');
            
            statusEl.textContent = 'Uploading chunk ' + (i + 1) + ' of ' + totalChunks + '...';
            fillEl.style.width = Math.round(5 + (i / totalChunks) * 85) + '%';
            
            var partRes = await fetch('/api/tester/upload/part', {
              method: 'POST',
              body: chunkForm,
            });
            
            if (!partRes.ok) {
              var partErr = await partRes.json().catch(function() { return {}; });
              // Try to abort
              try { await fetch('/api/tester/upload/abort', { method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify({sessionId:sessionId}) }); } catch(e) {}
              throw new Error(partErr.error || 'Chunk ' + (i+1) + ' failed (HTTP ' + partRes.status + ')');
            }
          }
          
          // Step 3: Complete upload
          fillEl.style.width = '92%';
          statusEl.textContent = 'Finalizing...';
          
          var completeRes = await fetch('/api/tester/upload/complete', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              sessionId: sessionId,
              section: section,
              deviceModel: deviceModel,
              osVersion: osVersion,
              appVersion: appVersion,
              testerName: testerName,
              testerId: testerId,
            }),
          });
          
          if (!completeRes.ok) {
            var completeErr = await completeRes.json().catch(function() { return {}; });
            throw new Error(completeErr.error || 'Failed to finalize upload');
          }
          
          fillEl.style.width = '100%';
          progressEl.classList.remove('active');
          successEl.classList.add('active');
          loadPreviousSubmissions();
          return true;
        } catch (err) {
          // Clean up on failure
          if (sessionId) {
            try { await fetch('/api/tester/upload/abort', { method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify({sessionId:sessionId}) }); } catch(e) {}
          }
          progressEl.classList.remove('active');
          statusEl.textContent = 'Upload failed: ' + err.message;
          return false;
        }
      }
      
      // ═══════════════════════════════════════════════════════════════
      // PATH B: Legacy Worker-proxied upload (for files ≤ 100 MB)
      // ═══════════════════════════════════════════════════════════════
      statusEl.textContent = 'Uploading...';
      
      const formData = new FormData();
      formData.append('video', file);
      formData.append('section', section);
      formData.append('deviceModel', deviceModel);
      formData.append('osVersion', osVersion);
      formData.append('appVersion', appVersion);
      formData.append('testerName', testerName);
      formData.append('testerId', testerId);
      
      try {
        const xhr = new XMLHttpRequest();
        
        await new Promise((resolve, reject) => {
          xhr.upload.addEventListener('progress', function(e) {
            if (e.lengthComputable) {
              var pct = Math.round((e.loaded / e.total) * 100);
              fillEl.style.width = pct + '%';
              statusEl.textContent = 'Uploading... ' + pct + '%';
            }
          });
          
          xhr.addEventListener('load', function() {
            if (xhr.status >= 200 && xhr.status < 300) {
              resolve(xhr.response);
            } else {
              // Try to parse error from response
              var msg = 'Upload failed: HTTP ' + xhr.status;
              try {
                var errData = JSON.parse(xhr.responseText);
                if (errData.error) msg = errData.error;
              } catch(e) {}
              reject(new Error(msg));
            }
          });
          
          xhr.addEventListener('error', function() { reject(new Error('Upload failed')); });
          
          xhr.open('POST', '/api/tester/video');
          xhr.send(formData);
        });
        
        progressEl.classList.remove('active');
        successEl.classList.add('active');
        // Refresh submission display
        loadPreviousSubmissions();
        return true;
      } catch (err) {
        progressEl.classList.remove('active');
        statusEl.textContent = 'Upload failed: ' + err.message;
        return false;
      }
    }
    
    // Submit all videos
    async function submitAllVideos() {
      const deviceModel = document.getElementById('deviceModel').value;
      const osVersion = document.getElementById('osVersion').value;
      
      if (!deviceModel || !osVersion) {
        alert('Please fill in Device Model and OS Version before submitting.');
        return;
      }
      
      const btn = document.getElementById('submitAllBtn');
      btn.disabled = true;
      btn.innerHTML = '<svg class="spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg> Uploading...';
      
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
      btn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg> Submit All Videos';
      
      if (failCount === 0) {
        alert('All ' + successCount + ' videos uploaded successfully!');
      } else {
        alert('Uploaded ' + successCount + ' videos. ' + failCount + ' failed.');
      }
    }
    
    // Print checkbox state summary
    document.querySelectorAll('input[type="checkbox"]').forEach(cb => {
      cb.addEventListener('change', () => {
        const checked = document.querySelectorAll('input[type="checkbox"]:checked').length;
        const total = document.querySelectorAll('input[type="checkbox"]').length;
        console.log(\`Progress: \${checked}/\${total} items checked\`);
      });
    });
  </script>
  
  <style>
    .spin { animation: spin 1s linear infinite; }
    @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
  </style>
</body>
</html>`;

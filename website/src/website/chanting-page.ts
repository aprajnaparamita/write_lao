export const chantingPageHTML = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<title>Pali Chanting Review</title>
<style>
:root {
  --saffron: #c8573f; --saffron-d: #a8432e; --saffron-t: #fdf0ec;
  --green: #16a34a;  --green-t: #dcfce7;
  --red: #dc2626;    --red-t: #fee2e2;
  --amber: #d97706;  --amber-t: #fef3c7;
  --blue: #2563eb;   --blue-t: #dbeafe;
  --cream: #faf6ef;  --ink: #1a1511; --muted: #6b5a4a; --line: #e6ddcd;
  --card: #fff;
  --safe-b: env(safe-area-inset-bottom, 0px);
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { height: 100%; }
body {
  height: 100%; background: var(--cream); color: var(--ink);
  font-family: system-ui, -apple-system, sans-serif;
  -webkit-font-smoothing: antialiased; overscroll-behavior: none;
  -webkit-tap-highlight-color: transparent;
}

/* ── Screens ─────────────────────────────────────────────────────── */
.screen { display: none; flex-direction: column; height: 100dvh; height: 100vh; overflow: hidden; }
.screen.active { display: flex; }

/* ── Shared header ───────────────────────────────────────────────── */
.top-bar {
  flex: 0 0 auto; display: flex; align-items: center; gap: 0.75rem;
  padding: 0.75rem 1rem; padding-top: calc(0.75rem + env(safe-area-inset-top, 0px));
  background: var(--cream); border-bottom: 1px solid var(--line);
  min-height: 56px;
}
.top-bar h1 { flex: 1; font-size: 1.0625rem; font-weight: 700; }
.top-bar .sub { flex: 1; font-size: 0.875rem; color: var(--muted); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.icon-btn {
  flex: 0 0 auto; background: none; border: none; cursor: pointer;
  font-size: 1.25rem; padding: 0.375rem; border-radius: 8px; color: var(--ink);
  display: flex; align-items: center; justify-content: center;
  min-width: 40px; min-height: 40px;
}
.icon-btn:active { background: var(--line); }
.back-pill {
  display: flex; align-items: center; gap: 0.25rem;
  background: #f0ebe4; border: none; border-radius: 20px;
  padding: 0.375rem 0.75rem 0.375rem 0.5rem;
  font: inherit; font-size: 0.875rem; font-weight: 600; color: var(--ink);
  cursor: pointer; white-space: nowrap;
}
.back-pill:active { background: var(--line); }
.back-arrow { font-size: 1rem; line-height: 1; }

/* ── Scroll body ─────────────────────────────────────────────────── */
.scroll-body {
  flex: 1 1 auto; overflow-y: auto; -webkit-overflow-scrolling: touch;
}
.inner { padding: 1.25rem 1rem calc(1.5rem + var(--safe-b)); max-width: 600px; margin: 0 auto; }

/* ══════════════════════════════════════════════════════════════════
   INTRO SCREEN
══════════════════════════════════════════════════════════════════ */
#introScreen .scroll-body { background: var(--cream); }

.intro-hero {
  text-align: center; padding: 2rem 1rem 1.5rem;
}
.intro-icon { font-size: 3rem; margin-bottom: 0.75rem; }
.intro-hero h1 { font-size: 1.5rem; font-weight: 800; margin-bottom: 0.5rem; }
.intro-hero p { font-size: 0.9375rem; color: var(--muted); line-height: 1.6; }

.intro-steps {
  margin: 1.25rem 0; display: flex; flex-direction: column; gap: 0.875rem;
}
.intro-step {
  display: flex; align-items: flex-start; gap: 0.875rem;
  background: var(--card); border-radius: 14px; padding: 0.875rem 1rem;
  border: 1.5px solid var(--line);
}
.step-num {
  flex: 0 0 32px; height: 32px; border-radius: 50%;
  background: var(--saffron); color: #fff;
  display: flex; align-items: center; justify-content: center;
  font-weight: 700; font-size: 0.875rem;
}
.step-body h3 { font-size: 0.9375rem; font-weight: 700; margin-bottom: 0.2rem; }
.step-body p  { font-size: 0.8125rem; color: var(--muted); line-height: 1.5; }

.intro-commands {
  background: var(--card); border-radius: 14px; border: 1.5px solid var(--line);
  padding: 1rem; margin: 1rem 0 1.5rem;
}
.intro-commands h3 { font-size: 0.875rem; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: 0.04em; margin-bottom: 0.75rem; }
.cmd-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; }
.cmd { display: flex; align-items: center; gap: 0.5rem; font-size: 0.8125rem; }
.cmd-key {
  background: #f0ebe4; border: 1px solid var(--line); border-radius: 6px;
  padding: 0.2rem 0.5rem; font-size: 0.75rem; font-weight: 600; white-space: nowrap;
  color: var(--ink); flex: 0 0 auto;
}

.name-section { margin-bottom: 1.5rem; }
.name-section label { display: block; font-size: 0.875rem; font-weight: 600; margin-bottom: 0.5rem; color: var(--muted); }
.name-input {
  width: 100%; padding: 0.875rem 1rem; font: inherit; font-size: 1rem;
  border: 1.5px solid var(--line); border-radius: 12px; background: var(--card);
  outline: none; transition: border-color 0.15s;
}
.name-input:focus { border-color: var(--saffron); }
.primary-btn {
  width: 100%; padding: 1rem; font: inherit; font-size: 1.0625rem;
  font-weight: 700; background: var(--saffron); color: #fff; border: 0;
  border-radius: 16px; cursor: pointer; transition: background 0.15s;
}
.primary-btn:active { background: var(--saffron-d); }
.primary-btn:disabled { opacity: 0.5; cursor: default; }

/* ══════════════════════════════════════════════════════════════════
   DASHBOARD SCREEN
══════════════════════════════════════════════════════════════════ */
.dash-greeting {
  font-size: 1.25rem; font-weight: 800; margin-bottom: 0.25rem;
}
.dash-greeting span { color: var(--saffron); }
.dash-sub { font-size: 0.875rem; color: var(--muted); margin-bottom: 1.5rem; }

.my-progress-card {
  background: var(--card); border-radius: 16px; border: 1.5px solid var(--line);
  padding: 1rem 1.125rem 1.25rem; margin-bottom: 1.25rem;
}
.progress-header { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 0.875rem; }
.progress-header h2 { font-size: 0.875rem; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: 0.04em; }
.progress-header .change-name { font: inherit; font-size: 0.8125rem; color: var(--saffron); background: none; border: none; cursor: pointer; text-decoration: underline; padding: 0; }
.progress-bar-wrap { height: 8px; background: #f0ebe4; border-radius: 4px; margin-bottom: 0.875rem; overflow: hidden; }
.progress-bar { height: 100%; background: var(--saffron); border-radius: 4px; transition: width 0.4s; }
.progress-stats { display: flex; gap: 1rem; flex-wrap: wrap; }
.pstat { display: flex; align-items: center; gap: 0.375rem; font-size: 0.875rem; }
.pstat-dot { width: 10px; height: 10px; border-radius: 50%; flex: 0 0 auto; }
.pstat-dot.ok { background: var(--green); }
.pstat-dot.prob { background: var(--red); }
.pstat-dot.none { background: #ccc; }

.review-cta {
  display: flex; align-items: center; justify-content: space-between;
  background: var(--saffron); color: #fff; border: none; border-radius: 14px;
  padding: 1rem 1.25rem; width: 100%; font: inherit; font-size: 1rem;
  font-weight: 700; cursor: pointer; margin-bottom: 1.5rem;
  text-decoration: none;
}
.review-cta:active { background: var(--saffron-d); }
.review-cta .cta-arrow { font-size: 1.25rem; }

.section-title {
  font-size: 0.8125rem; font-weight: 700; color: var(--muted); text-transform: uppercase;
  letter-spacing: 0.05em; margin-bottom: 0.75rem;
}
.reviewer-cards { display: flex; flex-direction: column; gap: 0.5rem; }
.reviewer-card {
  background: var(--card); border: 1.5px solid var(--line); border-radius: 14px;
  padding: 0.75rem 1rem; display: flex; align-items: center; gap: 0.75rem;
  cursor: pointer; transition: border-color 0.15s;
}
.reviewer-card:active { background: #f7f2eb; }
.reviewer-card.is-me { border-color: var(--saffron); background: #fffbf2; }
.reviewer-card.rank-1 .reviewer-rank { color: #b8860b; }
.reviewer-card.rank-2 .reviewer-rank { color: #888; }
.reviewer-card.rank-3 .reviewer-rank { color: #a0522d; }
.reviewer-rank {
  font-size: 0.75rem; font-weight: 800; color: #bbb; width: 18px;
  text-align: center; flex: 0 0 auto;
}
.reviewer-avatar {
  width: 38px; height: 38px; border-radius: 50%; background: var(--saffron-t);
  display: flex; align-items: center; justify-content: center;
  font-size: 1rem; font-weight: 700; color: var(--saffron); flex: 0 0 auto;
}
.reviewer-info { flex: 1; min-width: 0; }
.reviewer-name { font-size: 0.9375rem; font-weight: 700; }
.reviewer-stats { font-size: 0.8125rem; color: var(--muted); margin-top: 0.1rem; }
.reviewer-bar-wrap { height: 4px; background: var(--line); border-radius: 2px; margin-top: 0.375rem; }
.reviewer-bar { height: 4px; background: var(--saffron); border-radius: 2px; transition: width 0.4s; }
.reviewer-arrow { color: #ccc; font-size: 1.125rem; }
.badge-row { display: flex; gap: 0.375rem; flex-wrap: wrap; margin-top: 0.375rem; }
.badge {
  font-size: 0.6875rem; font-weight: 700; padding: 0.125rem 0.5rem;
  border-radius: 20px; white-space: nowrap;
}
.badge.ok   { background: var(--green-t); color: var(--green); }
.badge.prob { background: var(--red-t);   color: var(--red); }
.badge.none { background: #f0ebe4;        color: var(--muted); }

.empty-reviewers { text-align: center; padding: 2rem 1rem; color: var(--muted); font-size: 0.9375rem; }
.loading-row { text-align: center; padding: 2rem; }
.spinner { width: 32px; height: 32px; border: 3px solid #e6ddcd; border-top-color: var(--saffron); border-radius: 50%; animation: spin 0.7s linear infinite; display: inline-block; }
@keyframes spin { to { transform: rotate(360deg); } }

/* ══════════════════════════════════════════════════════════════════
   USER DETAIL SCREEN
══════════════════════════════════════════════════════════════════ */
.user-summary {
  background: var(--card); border: 1.5px solid var(--line); border-radius: 14px;
  padding: 1rem 1.125rem; margin-bottom: 1.25rem; display: flex; gap: 1rem;
  flex-wrap: wrap;
}
.u-stat { text-align: center; flex: 1; min-width: 60px; }
.u-stat .val { font-size: 1.5rem; font-weight: 800; }
.u-stat .lbl { font-size: 0.75rem; color: var(--muted); }
.u-stat.ok .val { color: var(--green); }
.u-stat.prob .val { color: var(--red); }

.review-list { display: flex; flex-direction: column; gap: 0.75rem; }
.review-item {
  background: var(--card); border: 1.5px solid var(--line); border-radius: 14px;
  display: flex; gap: 0.875rem; padding: 0.75rem; align-items: flex-start;
  cursor: pointer;
}
.review-item:active { background: #f7f2eb; }
.review-item.status-ok   { border-left: 4px solid var(--green); }
.review-item.status-problem { border-left: 4px solid var(--red); }
.review-thumb {
  flex: 0 0 56px; height: 72px; object-fit: cover; border-radius: 8px;
  background: #f0ebe4;
}
.review-body { flex: 1; min-width: 0; }
.review-page-title { font-size: 0.875rem; font-weight: 700; margin-bottom: 0.25rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.review-verdict { font-size: 0.8125rem; margin-bottom: 0.375rem; }
.review-verdict .ok-chip   { color: var(--green); font-weight: 700; }
.review-verdict .prob-chip { color: var(--red); font-weight: 700; }
.review-note { font-size: 0.75rem; color: var(--muted); line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.review-flags { font-size: 0.75rem; color: var(--amber); margin-bottom: 0.25rem; }
.no-reviews { text-align: center; padding: 3rem 1rem; color: var(--muted); font-size: 0.9375rem; }

/* ══════════════════════════════════════════════════════════════════
   GRID SCREEN
══════════════════════════════════════════════════════════════════ */
.grid-stats-bar {
  display: flex; gap: 0.75rem; flex-wrap: wrap; font-size: 0.8125rem; color: var(--muted);
  padding: 0.625rem 1rem; background: #f5f0e8; border-bottom: 1px solid var(--line);
}
.gstat { display: flex; align-items: center; gap: 0.3rem; }
.gstat-dot { width: 8px; height: 8px; border-radius: 50%; }
.gstat-dot.ok { background: var(--green); }
.gstat-dot.prob { background: var(--red); }
.gstat-dot.none { background: #ccc; }

.grid-scroll-body {
  flex: 1 1 auto; overflow-y: auto; -webkit-overflow-scrolling: touch;
}
#pageGrid {
  padding: 0.75rem; display: grid; gap: 0.75rem;
  grid-template-columns: repeat(2, 1fr);
  padding-bottom: calc(0.75rem + var(--safe-b));
}
@media (min-width: 480px) { #pageGrid { grid-template-columns: repeat(3, 1fr); } }
@media (min-width: 700px) { #pageGrid { grid-template-columns: repeat(4, 1fr); } }
@media (min-width: 900px) { #pageGrid { grid-template-columns: repeat(5, 1fr); } }

.page-card {
  background: var(--card); border-radius: 12px; overflow: hidden;
  border: 2.5px solid var(--line); cursor: pointer; position: relative;
}
.page-card:active { opacity: 0.85; }
.page-card.status-ok      { border-color: var(--green); }
.page-card.status-problem { border-color: var(--red); }
.card-img-wrap { position: relative; width: 100%; padding-top: 133.33%; overflow: hidden; border-radius: 10px 10px 0 0; background: #f0ebe4; }
.card-img-wrap img { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; display: block; }
.page-card .card-label { padding: 0.4rem 0.5rem; font-size: 0.6875rem; color: var(--muted); line-height: 1.3; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.status-badge {
  position: absolute; top: 6px; right: 6px; width: 22px; height: 22px;
  border-radius: 50%; display: flex; align-items: center; justify-content: center;
  font-size: 11px; font-weight: 700; color: #fff;
}
.page-card.status-ok      .status-badge { background: var(--green); }
.page-card.status-problem .status-badge { background: var(--red); }
.page-card:not(.status-ok):not(.status-problem) .status-badge { display: none; }
.note-indicator {
  position: absolute; bottom: 28px; right: 6px;
  font-size: 10px; background: var(--amber-t); color: var(--amber);
  border-radius: 4px; padding: 1px 4px; font-weight: 700;
}

/* ══════════════════════════════════════════════════════════════════
   DETAIL SCREEN
══════════════════════════════════════════════════════════════════ */
#detailScreen .top-bar { background: #111; border-bottom: 1px solid #2a2a2a; }
#detailScreen .top-bar .back-pill { background: #2a2a2a; color: #fff; }
#detailScreen .top-bar .sub { color: #999; }
#detailScreen .top-bar .counter { color: #777; font-size: 0.8125rem; white-space: nowrap; }

.detail-stage {
  flex: 1 1 auto; background: #0a0a0a;
  display: flex; align-items: center; justify-content: center;
  position: relative; overflow: hidden;
}
#detailInner { position: relative; line-height: 0; flex-shrink: 0; }
#detailImg {
  display: block; max-width: 100vw; max-height: calc(100dvh - 140px);
  width: auto; height: auto; user-select: none; pointer-events: none;
}
#detailSvg { position: absolute; inset: 0; width: 100%; height: 100%; overflow: hidden; }
.detail-spinner { position: absolute; }

.detail-footer {
  flex: 0 0 auto; background: #111; border-top: 1px solid #222;
  padding: 0.75rem 1rem calc(0.75rem + var(--safe-b));
  display: flex; flex-direction: column; gap: 0.5rem;
}
.verdict-row { display: flex; gap: 0.5rem; }
.verdict-btn {
  flex: 1; padding: 0.8125rem 0.5rem; font: inherit; font-size: 0.9375rem;
  font-weight: 700; border: 0; border-radius: 12px; cursor: pointer;
  transition: opacity 0.15s;
}
.verdict-btn:active { opacity: 0.8; }
.verdict-btn.ok-btn   { background: var(--green); color: #fff; }
.verdict-btn.prob-btn { background: var(--red);   color: #fff; }
.verdict-btn.inactive { opacity: 0.3; }

/* ── Floating toolbar ────────────────────────────────────────────── */
.detail-tools {
  flex: 1; display: flex; align-items: center; justify-content: center; gap: 2px;
}
.ft-btn {
  width: 36px; height: 36px; border-radius: 8px; background: transparent;
  border: none; color: #666; cursor: pointer; font-size: 1rem;
  display: flex; align-items: center; justify-content: center;
  transition: background 0.12s, color 0.12s; position: relative;
  -webkit-tap-highlight-color: transparent; flex-shrink: 0;
}
.ft-btn:active { background: rgba(255,255,255,0.1); }
.ft-btn.active { background: rgba(255,255,255,0.15); color: #fff; }
.ft-btn.mode-amber { background: rgba(245,158,11,0.22); color: #f59e0b; }
.ft-btn:disabled { opacity: 0.3; cursor: default; }
.ft-btn .ft-dot {
  position: absolute; top: 5px; right: 5px; width: 6px; height: 6px;
  border-radius: 50%; background: var(--saffron); border: 1.5px solid #111;
  display: none;
}
.ft-btn.has-note .ft-dot { display: block; }
.ft-sep { width: 1px; height: 20px; background: rgba(255,255,255,0.15); margin: 0 2px; flex-shrink: 0; }
.zoom-badge {
  position: absolute; top: 10px; right: 10px; z-index: 21;
  background: rgba(0,0,0,0.6); color: #fff; font-size: 0.6875rem; font-weight: 700;
  padding: 3px 7px; border-radius: 6px; pointer-events: none; display: none;
  backdrop-filter: blur(4px);
}
.zoom-badge.visible { display: block; }
#detailInner { transform-origin: center center; will-change: transform; }

.nav-row { display: flex; gap: 0.5rem; }
.nav-btn {
  flex: 0 0 48px; padding: 0.75rem 0; font: inherit; font-size: 1.25rem;
  font-weight: 700; background: #2a2a2a; color: #fff; border: 0;
  border-radius: 12px; cursor: pointer; text-align: center;
}
.nav-btn:disabled { opacity: 0.25; cursor: default; }
#saveBtn {
  flex: 1; padding: 0.75rem; font: inherit; font-size: 0.9375rem;
  font-weight: 700; background: var(--saffron); color: #fff; border: 0;
  border-radius: 12px; cursor: pointer;
}
#saveBtn:disabled { opacity: 0.45; cursor: default; }
#saveBtn:not(:disabled):active { background: var(--saffron-d); }



/* ── Run note modal extras ───────────────────────────────────────── */
.rn-header { display: flex; align-items: center; justify-content: space-between; }
.rn-run-preview {
  background: #111; border-radius: 8px; padding: 0.5rem 0.75rem;
  font-family: 'Noto Sans Lao', 'Lao MN', sans-serif;
  font-size: 1rem; color: #ddd; line-height: 1.6; margin-top: -0.25rem;
  min-height: 2rem; border-left: 3px solid var(--amber);
}
.rn-remove-btn {
  background: none; border: none; color: #dc2626; font: inherit;
  font-size: 0.8125rem; cursor: pointer; padding: 0.25rem 0.5rem;
  border-radius: 6px; white-space: nowrap;
}
.rn-remove-btn:active { background: rgba(220,38,38,0.15); }
#rnInput {
  width: 100%; min-height: 90px; max-height: 35vh;
  background: #111; border: 1.5px solid #333; border-radius: 12px;
  color: #fff; font: inherit; font-size: 1rem; padding: 0.75rem;
  outline: none; resize: none; line-height: 1.5;
}
#rnInput:focus { border-color: var(--amber); }
#rnInput::placeholder { color: #444; }

/* ── SVG run interaction ──────────────────────────────────────────── */
#detailSvg .run-hit { cursor: default; pointer-events: none; }
#detailSvg.problem-mode .run-hit,
#detailSvg.note-mode .run-hit { cursor: pointer; pointer-events: all; }

/* ══════════════════════════════════════════════════════════════════
   NOTES MODAL
══════════════════════════════════════════════════════════════════ */
.modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.55); z-index: 300;
  display: flex; align-items: flex-end; padding: 0;
}
.modal-overlay.hidden { display: none; }
.notes-sheet {
  background: #1c1c1c; border-radius: 20px 20px 0 0; width: 100%;
  padding: 1rem 1.25rem calc(1.25rem + var(--safe-b));
  display: flex; flex-direction: column; gap: 0.875rem;
}
.notes-sheet-handle { width: 36px; height: 4px; background: #444; border-radius: 2px; margin: 0 auto -0.25rem; }
.notes-sheet h3 { font-size: 1rem; font-weight: 700; color: #fff; }
.notes-page-sub { font-size: 0.8125rem; color: #888; margin-top: -0.5rem; }
#notesInput {
  width: 100%; min-height: 120px; max-height: 40vh;
  background: #111; border: 1.5px solid #333; border-radius: 12px;
  color: #fff; font: inherit; font-size: 1rem; padding: 0.875rem;
  outline: none; resize: none; line-height: 1.5;
}
#notesInput:focus { border-color: var(--saffron); }
#notesInput::placeholder { color: #555; }
.notes-actions { display: flex; gap: 0.625rem; }
.notes-cancel {
  flex: 0 0 auto; padding: 0.75rem 1.25rem; font: inherit; font-size: 0.9375rem;
  font-weight: 600; background: #2a2a2a; color: #ccc; border: 0;
  border-radius: 12px; cursor: pointer;
}
.notes-save {
  flex: 1; padding: 0.75rem; font: inherit; font-size: 0.9375rem;
  font-weight: 700; background: var(--saffron); color: #fff; border: 0;
  border-radius: 12px; cursor: pointer;
}
.notes-save:active { background: var(--saffron-d); }
.notes-clear {
  flex: 0 0 auto; padding: 0.75rem; font: inherit; font-size: 0.9375rem;
  background: #2a2a2a; color: #888; border: 0; border-radius: 12px; cursor: pointer;
}

/* ══════════════════════════════════════════════════════════════════
   TOAST
══════════════════════════════════════════════════════════════════ */
#toast {
  position: fixed; bottom: calc(120px + var(--safe-b));
  left: 50%; transform: translateX(-50%);
  background: rgba(0,0,0,0.82); color: #fff;
  padding: 0.5rem 1.125rem; border-radius: 20px; font-size: 0.875rem;
  z-index: 400; pointer-events: none; white-space: nowrap;
  opacity: 0; transition: opacity 0.2s;
}
#toast.show { opacity: 1; }
</style>
</head>
<body>

<!-- ══ INTRO SCREEN ══════════════════════════════════════════════ -->
<div id="introScreen" class="screen">
  <div class="scroll-body">
    <div class="inner">
      <div class="intro-hero">
        <div class="intro-icon">📖</div>
        <h1>Pali Chanting Review</h1>
        <p>Help verify that the OCR text matches this Lao Pali chanting book — 136 pages to review.</p>
      </div>

      <div class="intro-steps">
        <div class="intro-step">
          <div class="step-num">1</div>
          <div class="step-body">
            <h3>Browse pages</h3>
            <p>Tap any page thumbnail in the grid to open it for review.</p>
          </div>
        </div>
        <div class="intro-step">
          <div class="step-num">2</div>
          <div class="step-body">
            <h3>Judge the text</h3>
            <p>Tap <strong>✓ OK</strong> if the OCR text matches the original. Tap <strong>⚠ Has Problem</strong> if something looks wrong.</p>
          </div>
        </div>
        <div class="intro-step">
          <div class="step-num">3</div>
          <div class="step-body">
            <h3>Flag bad runs</h3>
            <p>In problem mode, tap individual text runs on the image to mark exactly which ones are incorrect.</p>
          </div>
        </div>
        <div class="intro-step">
          <div class="step-num">4</div>
          <div class="step-body">
            <h3>Add notes</h3>
            <p>Tap the note button to explain the problem in words. Then tap <strong>Save</strong>.</p>
          </div>
        </div>
      </div>

      <div class="intro-commands">
        <h3>Controls</h3>
        <div class="cmd-grid">
          <div class="cmd"><span class="cmd-key">‹ ›</span>Previous / Next page</div>
          <div class="cmd"><span class="cmd-key">✓</span>Mark OK</div>
          <div class="cmd"><span class="cmd-key">⚠</span>Mark problem</div>
          <div class="cmd"><span class="cmd-key">📝</span>Add / edit note</div>
          <div class="cmd"><span class="cmd-key">Tap run</span>Flag bad text</div>
          <div class="cmd"><span class="cmd-key">Save</span>Save review</div>
        </div>
      </div>

      <div class="name-section">
        <label for="introNameInput">Your name</label>
        <input type="text" id="introNameInput" class="name-input" placeholder="e.g. Daisy"
          maxlength="60" autocomplete="given-name" autocorrect="off">
      </div>
      <button id="introStartBtn" class="primary-btn">Start Reviewing →</button>
    </div>
  </div>
</div>

<!-- ══ DASHBOARD SCREEN ══════════════════════════════════════════ -->
<div id="dashScreen" class="screen">
  <div class="top-bar">
    <h1>Dashboard</h1>
  </div>
  <div class="scroll-body">
    <div class="inner">
      <div class="dash-greeting">Hi, <span id="dashName">there</span>!</div>
      <p class="dash-sub" id="dashSub">Ready to help verify the chanting book?</p>

      <!-- My progress card -->
      <div class="my-progress-card">
        <div class="progress-header">
          <h2>My Progress</h2>
          <button class="change-name" id="changeNameBtn">Change name</button>
        </div>
        <div class="progress-bar-wrap"><div class="progress-bar" id="myProgressBar" style="width:0%"></div></div>
        <div class="progress-stats" id="myProgressStats">
          <div class="pstat"><span class="pstat-dot none"></span>0 reviewed</div>
        </div>
      </div>

      <!-- Continue button -->
      <button class="review-cta" id="reviewCtaBtn">
        <span>Continue Reviewing</span>
        <span class="cta-arrow">→</span>
      </button>

      <!-- Leaderboard -->
      <div class="section-title">Leaderboard</div>
      <div class="reviewer-cards" id="reviewerCards">
        <div class="loading-row"><div class="spinner"></div></div>
      </div>
    </div>
  </div>
</div>

<!-- ══ USER DETAIL SCREEN ════════════════════════════════════════ -->
<div id="userScreen" class="screen">
  <div class="top-bar">
    <button class="back-pill" id="userBackBtn"><span class="back-arrow">‹</span> Dashboard</button>
    <h1 id="userScreenName" style="flex:1;font-size:1rem;"></h1>
  </div>
  <div class="scroll-body">
    <div class="inner">
      <div class="user-summary" id="userSummary">
        <div class="loading-row"><div class="spinner"></div></div>
      </div>
      <div class="review-list" id="userReviewList">
        <!-- items injected -->
      </div>
    </div>
  </div>
</div>

<!-- ══ GRID SCREEN ═══════════════════════════════════════════════ -->
<div id="gridScreen" class="screen">
  <div class="top-bar">
    <button class="back-pill" id="gridBackBtn"><span class="back-arrow">‹</span> Dashboard</button>
    <span class="sub" id="gridTitle">My Reviews</span>
  </div>
  <div class="grid-stats-bar" id="gridStatsBar">
    <span class="gstat"><span class="gstat-dot none"></span><span id="gStatNone">—</span></span>
    <span class="gstat"><span class="gstat-dot ok"></span><span id="gStatOk">—</span></span>
    <span class="gstat"><span class="gstat-dot prob"></span><span id="gStatProb">—</span></span>
  </div>
  <div class="grid-scroll-body">
    <div id="pageGrid"></div>
  </div>
</div>

<!-- ══ DETAIL SCREEN ═════════════════════════════════════════════ -->
<div id="detailScreen" class="screen">
  <div class="top-bar">
    <button class="back-pill" id="detailBackBtn"><span class="back-arrow">‹</span> Grid</button>
    <div class="detail-tools">
      <button class="ft-btn active" id="vtScan" title="Original scan">🖼</button>
      <button class="ft-btn" id="vtText" title="OCR text overlay">字</button>
      <span class="ft-sep"></span>
      <button class="ft-btn" id="noteRunsBtn" title="Annotate runs (Text mode only)" disabled>✎</button>
      <button class="ft-btn" id="noteBtn" title="Page note"><span>📝</span><span class="ft-dot"></span></button>
    </div>
    <span class="counter" id="detailCounter"></span>
  </div>
  <div class="detail-stage" id="detailStage">
    <div id="detailInner">
      <img id="detailImg" alt="page">
      <svg id="detailSvg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"></svg>
    </div>
    <div class="spinner detail-spinner" id="detailSpinner" style="display:none"></div>
    <!-- Zoom level badge -->
    <div class="zoom-badge" id="zoomBadge">1×</div>
  </div>
  <div class="detail-footer">
    <div class="verdict-row">
      <button class="verdict-btn ok-btn"   id="okBtn">✓ OK</button>
      <button class="verdict-btn prob-btn" id="probBtn">⚠ Problem</button>
    </div>
    <div class="nav-row">
      <button class="nav-btn" id="navPrev">‹</button>
      <button id="saveBtn">Save</button>
      <button class="nav-btn" id="navNext">›</button>
    </div>
  </div>
</div>

<!-- ══ NOTES MODAL ═══════════════════════════════════════════════ -->
<div id="notesModal" class="modal-overlay hidden">
  <div class="notes-sheet">
    <div class="notes-sheet-handle"></div>
    <h3>Note</h3>
    <p class="notes-page-sub" id="notesPageSub"></p>
    <textarea id="notesInput" placeholder="Describe the problem, e.g. 'Left column text is garbled on lines 3-5'…" rows="5"></textarea>
    <div class="notes-actions">
      <button class="notes-cancel" id="notesCancelBtn">Cancel</button>
      <button class="notes-clear"  id="notesClearBtn">Clear</button>
      <button class="notes-save"   id="notesSaveBtn">Save Note</button>
    </div>
  </div>
</div>

<!-- ══ RUN NOTE MODAL ════════════════════════════════════════════ -->
<div id="runNoteModal" class="modal-overlay hidden">
  <div class="notes-sheet">
    <div class="notes-sheet-handle"></div>
    <div class="rn-header">
      <h3>Run <span id="rnIdxLabel"></span></h3>
      <button class="rn-remove-btn" id="rnRemoveBtn" style="display:none">✕ Remove note</button>
    </div>
    <div class="rn-run-preview" id="rnRunPreview"></div>
    <textarea id="rnInput" placeholder="What's wrong with this text, or any observation…" rows="3"></textarea>
    <div class="notes-actions">
      <button class="notes-cancel" id="rnCancelBtn">Cancel</button>
      <button class="notes-save"   id="rnSaveBtn">Save Note</button>
    </div>
  </div>
</div>

<div id="toast"></div>

<script>
// ══════════════════════════════════════════════════════════════════
// State
// ══════════════════════════════════════════════════════════════════
const DATA_BASE = '/chanting/data';

const local = {
  get reviewer() { return localStorage.getItem('chanting_reviewer') || ''; },
  set reviewer(v) { localStorage.setItem('chanting_reviewer', v); },
  getReviews() {
    try { return JSON.parse(localStorage.getItem('chanting_revs') || '{}'); } catch { return {}; }
  },
  setReview(pageId, rev) {
    const all = this.getReviews(); all[pageId] = rev;
    localStorage.setItem('chanting_revs', JSON.stringify(all));
  },
  getReview(pageId) { return this.getReviews()[pageId] || null; },
};

let manifest = null;
let currentIdx = 0;
let currentOcr = null;
let currentVerdict = null;
let currentNote = '';
let flaggedRuns = new Set();
let runNotes = {};      // { [runIdx]: noteText }
let noteMode = false;
let dirty = false;
let viewingUser = '';
let viewMode = 'scan'; // 'scan' | 'txt'
let zoom = 1, panX = 0, panY = 0;
let zoomBadgeTimer = null;

// ══════════════════════════════════════════════════════════════════
// Screen navigation
// ══════════════════════════════════════════════════════════════════
function showScreen(id) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  document.getElementById(id).classList.add('active');
}

// ══════════════════════════════════════════════════════════════════
// Toast
// ══════════════════════════════════════════════════════════════════
const toastEl = document.getElementById('toast');
let toastTimer;
function toast(msg, ms = 1800) {
  toastEl.textContent = msg;
  toastEl.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toastEl.classList.remove('show'), ms);
}

// ══════════════════════════════════════════════════════════════════
// Helpers
// ══════════════════════════════════════════════════════════════════
function esc(s) { return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
function escXml(s) { return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&apos;'}[c])); }
function initials(name) { return (name || '?').split(/\\s+/).map(w => w[0]).join('').slice(0,2).toUpperCase(); }
function pluralPages(n) { return n + ' page' + (n === 1 ? '' : 's'); }

// ══════════════════════════════════════════════════════════════════
// INTRO SCREEN
// ══════════════════════════════════════════════════════════════════
const introNameInput = document.getElementById('introNameInput');
const introStartBtn  = document.getElementById('introStartBtn');

introNameInput.addEventListener('input', () => {
  introStartBtn.disabled = !introNameInput.value.trim();
});
introNameInput.addEventListener('keydown', e => { if (e.key === 'Enter') introStartBtn.click(); });
introStartBtn.addEventListener('click', () => {
  const name = introNameInput.value.trim();
  if (!name) return;
  local.reviewer = name;
  loadDashboard();
});
introStartBtn.disabled = true;

// ══════════════════════════════════════════════════════════════════
// DASHBOARD SCREEN
// ══════════════════════════════════════════════════════════════════
document.getElementById('changeNameBtn').addEventListener('click', () => {
  introNameInput.value = local.reviewer;
  introStartBtn.disabled = false;
  showScreen('introScreen');
});
document.getElementById('reviewCtaBtn').addEventListener('click', () => {
  showGrid();
});

async function loadDashboard() {
  showScreen('dashScreen');
  const name = local.reviewer;
  document.getElementById('dashName').textContent = name;

  // My stats from local + server
  const revs = local.getReviews();
  const nTotal = manifest ? manifest.pages.length : 136;
  const nDone = Object.keys(revs).length;
  const nOk = Object.values(revs).filter(r => r.status === 'ok').length;
  const nProb = Object.values(revs).filter(r => r.status === 'problem').length;
  const pct = Math.round(nDone / nTotal * 100);

  document.getElementById('myProgressBar').style.width = pct + '%';
  document.getElementById('myProgressStats').innerHTML =
    '<div class="pstat"><span class="pstat-dot ok"></span>' + nOk + ' OK</div>' +
    '<div class="pstat"><span class="pstat-dot prob"></span>' + nProb + ' problems</div>' +
    '<div class="pstat"><span class="pstat-dot none"></span>' + (nTotal - nDone) + ' remaining</div>';

  document.getElementById('dashSub').textContent =
    nDone === 0 ? 'No pages reviewed yet — tap below to start!'
    : nDone === nTotal ? 'All ' + nTotal + ' pages reviewed — great work!'
    : pct + '% done — ' + (nTotal - nDone) + ' pages left.';

  // Reviewers from server
  const cardsEl = document.getElementById('reviewerCards');
  cardsEl.innerHTML = '<div class="loading-row"><div class="spinner"></div></div>';
  try {
    const res = await fetch('/api/chanting/reviewers', { cache: 'no-cache' });
    const data = await res.json();
    const reviewers = data.reviewers || [];

    if (reviewers.length === 0) {
      cardsEl.innerHTML = '<div class="empty-reviewers">No reviews saved to the server yet.</div>';
      return;
    }

    cardsEl.innerHTML = reviewers.map((r, i) => {
      const isMe = r.reviewer_name === name;
      const total = r.total || 0;
      const ok = r.ok_count || 0;
      const prob = r.problem_count || 0;
      const pct = Math.min(100, Math.round(total / nTotal * 100));
      const rank = i + 1;
      const rankLabel = rank === 1 ? '🥇' : rank === 2 ? '🥈' : rank === 3 ? '🥉' : '#' + rank;
      return \`<div class="reviewer-card\${isMe ? ' is-me' : ''} rank-\${rank}" data-user="\${esc(r.reviewer_name)}">
        <div class="reviewer-rank">\${rankLabel}</div>
        <div class="reviewer-avatar">\${esc(initials(r.reviewer_name))}</div>
        <div class="reviewer-info">
          <div class="reviewer-name">\${esc(r.reviewer_name)}\${isMe ? ' <span style="color:var(--saffron);font-weight:600;font-size:0.8rem">(you)</span>' : ''}</div>
          <div class="reviewer-stats">\${pluralPages(total)} · \${pct}% done</div>
          <div class="reviewer-bar-wrap"><div class="reviewer-bar" style="width:\${pct}%"></div></div>
        </div>
        <span class="reviewer-arrow">›</span>
      </div>\`;
    }).join('');

    cardsEl.querySelectorAll('.reviewer-card').forEach(card => {
      card.addEventListener('click', () => loadUserDetail(card.dataset.user));
    });
  } catch {
    cardsEl.innerHTML = '<div class="empty-reviewers">Could not load reviewer stats.</div>';
  }
}

// ══════════════════════════════════════════════════════════════════
// USER DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════
document.getElementById('userBackBtn').addEventListener('click', () => loadDashboard());

async function loadUserDetail(username) {
  viewingUser = username;
  document.getElementById('userScreenName').textContent = username;
  document.getElementById('userSummary').innerHTML = '<div class="loading-row"><div class="spinner"></div></div>';
  document.getElementById('userReviewList').innerHTML = '';
  showScreen('userScreen');

  try {
    const res = await fetch('/api/chanting/reviews?reviewer=' + encodeURIComponent(username), { cache: 'no-cache' });
    const data = await res.json();
    const reviews = data.reviews || [];

    const nOk = reviews.filter(r => r.status === 'ok').length;
    const nProb = reviews.filter(r => r.status === 'problem').length;
    const nTotal = reviews.length;

    document.getElementById('userSummary').innerHTML =
      '<div class="u-stat"><div class="val">' + nTotal + '</div><div class="lbl">Reviewed</div></div>' +
      '<div class="u-stat ok"><div class="val">' + nOk + '</div><div class="lbl">OK</div></div>' +
      '<div class="u-stat prob"><div class="val">' + nProb + '</div><div class="lbl">Problems</div></div>';

    const listEl = document.getElementById('userReviewList');
    if (reviews.length === 0) {
      listEl.innerHTML = '<div class="no-reviews">No pages reviewed yet.</div>';
      return;
    }

    // Build a page-id → page index lookup
    const pageIdx = {};
    if (manifest) manifest.pages.forEach((p, i) => { pageIdx[p.id] = i; });

    listEl.innerHTML = reviews.map(rev => {
      const pi = pageIdx[rev.page_id];
      const page = manifest && pi !== undefined ? manifest.pages[pi] : null;
      const thumbSrc = page ? DATA_BASE + '/' + page.orig : '';
      const isOk = rev.status === 'ok';
      const flags = JSON.parse(rev.flagged_runs || '[]');
      const note = rev.notes || '';
      return \`<div class="review-item status-\${rev.status}" data-page-idx="\${pi !== undefined ? pi : -1}">
        \${thumbSrc ? '<img class="review-thumb" src="' + esc(thumbSrc) + '" loading="lazy" alt="">' : ''}
        <div class="review-body">
          <div class="review-page-title">\${esc(rev.page_title || rev.page_id)}</div>
          <div class="review-verdict">
            \${isOk
              ? '<span class="ok-chip">✓ OK</span>'
              : '<span class="prob-chip">⚠ Has Problem</span>'}
          </div>
          \${flags.length ? '<div class="review-flags">🚩 ' + flags.length + ' run' + (flags.length>1?'s':'') + ' flagged</div>' : ''}
          \${note ? '<div class="review-note">' + esc(note) + '</div>' : ''}
        </div>
      </div>\`;
    }).join('');

    // If viewing own reviews, make items tappable to edit
    if (username === local.reviewer && manifest) {
      listEl.querySelectorAll('.review-item').forEach(item => {
        const idx = parseInt(item.dataset.pageIdx, 10);
        if (idx >= 0) {
          item.addEventListener('click', () => {
            showGrid();
            openDetail(idx);
          });
        }
      });
    }
  } catch {
    document.getElementById('userSummary').innerHTML = '<div class="no-reviews">Failed to load reviews.</div>';
  }
}

// ══════════════════════════════════════════════════════════════════
// GRID SCREEN
// ══════════════════════════════════════════════════════════════════
document.getElementById('gridBackBtn').addEventListener('click', () => loadDashboard());

function showGrid() {
  showScreen('gridScreen');
  document.getElementById('gridTitle').textContent = local.reviewer + "’s Reviews";
  buildGrid();
}

function buildGrid() {
  if (!manifest) return;
  const revs = local.getReviews();
  let nOk = 0, nProb = 0;
  const grid = document.getElementById('pageGrid');
  grid.innerHTML = '';

  manifest.pages.forEach((p, i) => {
    const rev = revs[p.id];
    const status = rev ? rev.status : null;
    if (status === 'ok') nOk++;
    else if (status === 'problem') nProb++;

    const card = document.createElement('div');
    card.className = 'page-card' + (status ? ' status-' + status : '');
    const hasNote = rev && rev.note && rev.note.trim();
    card.innerHTML =
      '<div class="card-img-wrap"><img loading="lazy" src="' + DATA_BASE + '/' + esc(p.orig) + '" alt="page ' + (i+1) + '"></div>' +
      '<div class="card-label">' + (i+1) + '. ' + esc(p.title || p.id) + '</div>' +
      '<div class="status-badge">' + (status === 'ok' ? '✓' : status === 'problem' ? '!' : '') + '</div>' +
      (hasNote ? '<div class="note-indicator">📝</div>' : '');
    card.addEventListener('click', () => openDetail(i));
    grid.appendChild(card);
  });

  const nNone = manifest.pages.length - nOk - nProb;
  document.getElementById('gStatOk').textContent   = nOk   + ' OK';
  document.getElementById('gStatProb').textContent = nProb + ' problem' + (nProb === 1 ? '' : 's');
  document.getElementById('gStatNone').textContent = nNone + ' not reviewed';
}

// ══════════════════════════════════════════════════════════════════
// DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════
document.getElementById('detailBackBtn').addEventListener('click', () => {
  showGrid();
});

// ── View toggle ──────────────────────────────────────────────────
function setViewMode(mode) {
  viewMode = mode;
  document.getElementById('vtScan').classList.toggle('active', mode === 'scan');
  document.getElementById('vtText').classList.toggle('active', mode === 'txt');
  const noteRunsBtn = document.getElementById('noteRunsBtn');
  if (mode === 'scan') {
    noteRunsBtn.disabled = true;
    noteRunsBtn.classList.remove('active', 'mode-amber');
    if (noteMode) { noteMode = false; }
  } else {
    noteRunsBtn.disabled = false;
  }
  renderRuns();
}
document.getElementById('vtScan').addEventListener('click', () => setViewMode('scan'));
document.getElementById('vtText').addEventListener('click', () => setViewMode('txt'));

// ── Annotate-runs mode ────────────────────────────────────────────
function setNoteMode(on) {
  noteMode = on;
  const btn = document.getElementById('noteRunsBtn');
  btn.classList.toggle('active', on);
  btn.classList.toggle('mode-amber', on);
  renderRuns();
}
document.getElementById('noteRunsBtn').addEventListener('click', () => setNoteMode(!noteMode));

// ── Zoom / pan ────────────────────────────────────────────────────
// transform: translate(panX,panY) scale(zoom) with transform-origin:center center
// Screen pos of content point (x,y) from element center = (panX + x*zoom, panY + y*zoom)
// relative to stage center. Zoom-to-point formula: panNew = pivot - (pivot - pan) * newZ / oldZ

function applyZoom() {
  document.getElementById('detailInner').style.transform =
    'translate(' + panX + 'px, ' + panY + 'px) scale(' + zoom + ')';
  const badge = document.getElementById('zoomBadge');
  if (zoom > 1.01) {
    badge.textContent = Math.round(zoom * 100) + '%';
    badge.classList.add('visible');
    clearTimeout(zoomBadgeTimer);
    zoomBadgeTimer = setTimeout(() => badge.classList.remove('visible'), 1500);
  } else {
    badge.classList.remove('visible');
  }
}

function constrainPan() {
  if (zoom <= 1) { panX = 0; panY = 0; return; }
  const stage = document.getElementById('detailStage');
  const inner = document.getElementById('detailInner');
  const maxX = Math.max(0, (inner.offsetWidth  * zoom - stage.offsetWidth)  / 2);
  const maxY = Math.max(0, (inner.offsetHeight * zoom - stage.offsetHeight) / 2);
  panX = Math.max(-maxX, Math.min(maxX, panX));
  panY = Math.max(-maxY, Math.min(maxY, panY));
}

function resetZoom() {
  zoom = 1; panX = 0; panY = 0;
  applyZoom();
}

// Wheel zoom — toward cursor position
document.getElementById('detailStage').addEventListener('wheel', function(e) {
  e.preventDefault();
  const rect = this.getBoundingClientRect();
  const cx = e.clientX - rect.left - rect.width  / 2;
  const cy = e.clientY - rect.top  - rect.height / 2;
  const delta = e.ctrlKey ? -e.deltaY * 0.01 : -e.deltaY * 0.003;
  const newZoom = Math.min(5, Math.max(1, zoom + delta));
  if (newZoom !== zoom) {
    panX = cx - (cx - panX) * newZoom / zoom;
    panY = cy - (cy - panY) * newZoom / zoom;
    zoom = newZoom;
  }
  constrainPan();
  applyZoom();
}, { passive: false });

// Pinch-zoom — toward pinch midpoint
(function() {
  const stage = document.getElementById('detailStage');
  let pinchDist = 0, pinchZoom = 1, pinchPanX = 0, pinchPanY = 0, pinchMidX = 0, pinchMidY = 0;
  stage.addEventListener('touchstart', function(e) {
    if (e.touches.length === 2) {
      const dx = e.touches[0].clientX - e.touches[1].clientX;
      const dy = e.touches[0].clientY - e.touches[1].clientY;
      pinchDist = Math.hypot(dx, dy);
      pinchZoom = zoom; pinchPanX = panX; pinchPanY = panY;
      const rect = stage.getBoundingClientRect();
      pinchMidX = (e.touches[0].clientX + e.touches[1].clientX) / 2 - rect.left - rect.width  / 2;
      pinchMidY = (e.touches[0].clientY + e.touches[1].clientY) / 2 - rect.top  - rect.height / 2;
      e.preventDefault();
    }
  }, { passive: false });
  stage.addEventListener('touchmove', function(e) {
    if (e.touches.length === 2) {
      const dx = e.touches[0].clientX - e.touches[1].clientX;
      const dy = e.touches[0].clientY - e.touches[1].clientY;
      const newZoom = Math.min(5, Math.max(1, pinchZoom * Math.hypot(dx, dy) / pinchDist));
      panX = pinchMidX - (pinchMidX - pinchPanX) * newZoom / pinchZoom;
      panY = pinchMidY - (pinchMidY - pinchPanY) * newZoom / pinchZoom;
      zoom = newZoom;
      constrainPan();
      applyZoom();
      e.preventDefault();
    }
  }, { passive: false });
})();

// Drag to pan (pointer events — works for mouse and single-touch)
(function() {
  const stage = document.getElementById('detailStage');
  let active = false, didPan = false, captured = false;
  let startX = 0, startY = 0, startPanX = 0, startPanY = 0, capturedId = -1;
  stage.addEventListener('pointerdown', function(e) {
    if (!e.isPrimary) return;
    active = true; didPan = false; captured = false;
    startX = e.clientX; startY = e.clientY;
    startPanX = panX; startPanY = panY;
    capturedId = e.pointerId;
  });
  stage.addEventListener('pointermove', function(e) {
    if (!active || !e.isPrimary || zoom <= 1) return;
    const dx = e.clientX - startX, dy = e.clientY - startY;
    if (Math.abs(dx) < 5 && Math.abs(dy) < 5) return;
    if (!captured) { stage.setPointerCapture(capturedId); captured = true; }
    didPan = true;
    panX = startPanX + dx;
    panY = startPanY + dy;
    constrainPan();
    applyZoom();
  });
  stage.addEventListener('pointerup', function(e) {
    if (!e.isPrimary) return;
    const wasPan = didPan;
    active = false; didPan = false; captured = false;
    if (wasPan) {
      // suppress click so a pan doesn't accidentally trigger run annotation
      stage.addEventListener('click', function stopClick(ev) {
        ev.stopPropagation(); ev.preventDefault();
        stage.removeEventListener('click', stopClick, true);
      }, true);
    }
  });
  stage.addEventListener('pointercancel', function(e) { active = false; didPan = false; captured = false; });
})();

// ── Run note modal ────────────────────────────────────────────────
let editingRunIdx = null;

function openRunNote(ri) {
  editingRunIdx = ri;
  const run = currentOcr && currentOcr.runs ? currentOcr.runs[ri] : null;
  const text = run ? (run.text || '').replace(/<[^>]+>/g, '').replace(/\\n/g, ' ').trim() : '';
  const existing = runNotes[ri] || '';
  document.getElementById('rnIdxLabel').textContent = ri + 1;
  document.getElementById('rnRunPreview').textContent = text || '—';
  document.getElementById('rnInput').value = existing;
  document.getElementById('rnRemoveBtn').style.display = existing ? 'block' : 'none';
  document.getElementById('runNoteModal').classList.remove('hidden');
  setTimeout(() => document.getElementById('rnInput').focus(), 80);
}
function closeRunNote() {
  document.getElementById('runNoteModal').classList.add('hidden');
  document.getElementById('rnInput').blur();
  editingRunIdx = null;
}
document.getElementById('rnCancelBtn').addEventListener('click', closeRunNote);
document.getElementById('runNoteModal').addEventListener('click', e => {
  if (e.target === document.getElementById('runNoteModal')) closeRunNote();
});
function persistRunNotes() {
  const p = manifest && manifest.pages[currentIdx];
  if (!p) return;
  const existing = local.getReview(p.id) || {};
  local.setReview(p.id, Object.assign({}, existing, { runNotes: Object.assign({}, runNotes) }));
}

document.getElementById('rnRemoveBtn').addEventListener('click', () => {
  if (editingRunIdx !== null) {
    delete runNotes[editingRunIdx];
    persistRunNotes();
    dirty = true; updateSaveBtn();
    renderRuns(); closeRunNote(); toast('Note removed');
  }
});
document.getElementById('rnSaveBtn').addEventListener('click', () => {
  const note = document.getElementById('rnInput').value.trim();
  if (editingRunIdx !== null) {
    if (note) runNotes[editingRunIdx] = note;
    else delete runNotes[editingRunIdx];
    persistRunNotes();
    dirty = true; updateSaveBtn();
    renderRuns(); closeRunNote();
    toast(note ? 'Run note saved' : 'Note removed');
  }
});

async function openDetail(idx) {
  currentIdx = idx;
  flaggedRuns = new Set();
  currentOcr = null;
  dirty = false;

  const p = manifest.pages[idx];
  const rev = local.getReview(p.id);
  currentVerdict = rev ? rev.status : null;
  currentNote = (rev && rev.note) || '';
  if (rev && rev.flaggedRuns) rev.flaggedRuns.forEach(i => flaggedRuns.add(i));

  showScreen('detailScreen');

document.getElementById('detailCounter').textContent = (idx+1) + ' / ' + manifest.pages.length;
  document.getElementById('navPrev').disabled = idx === 0;
  document.getElementById('navNext').disabled = idx === manifest.pages.length - 1;

  // Reset state for new page
  viewMode = 'scan';
  noteMode = false;
  runNotes = {};
  resetZoom();
  setViewMode('scan');
  setNoteMode(false);
  // Load saved run notes
  const savedRev = local.getReview(manifest.pages[idx].id);
  if (savedRev && savedRev.runNotes) runNotes = Object.assign({}, savedRev.runNotes);
  applyVerdict(currentVerdict, false);
  updateNoteBtn();

  const img = document.getElementById('detailImg');
  const svg = document.getElementById('detailSvg');
  const spinner = document.getElementById('detailSpinner');

  spinner.style.display = 'block';
  img.style.opacity = '0';
  svg.innerHTML = '';
  svg.setAttribute('viewBox', '0 0 100 100');

  img.src = DATA_BASE + '/' + p.orig;
  await new Promise(res => {
    if (img.complete && img.naturalWidth) { res(); return; }
    img.onload = img.onerror = res;
  });
  spinner.style.display = 'none';
  img.style.opacity = '1';

  try {
    const r = await fetch(DATA_BASE + '/' + p.ocr, { cache: 'no-cache' });
    if (r.ok) { currentOcr = await r.json(); renderRuns(); }
  } catch {}

  updateSaveBtn();
}

function renderRuns() {
  if (!currentOcr) return;
  const { width, height, runs = [] } = currentOcr;
  const svg = document.getElementById('detailSvg');
  const isProblem = currentVerdict === 'problem';
  const svgModes = (isProblem ? 'problem-mode' : '') + (noteMode ? ' note-mode' : '');
  svg.setAttribute('viewBox', '0 0 ' + width + ' ' + height);
  svg.setAttribute('class', svgModes.trim());

  const showText = (viewMode === 'txt');
  const maxLineH = height * 0.03;
  const parts = [];

  runs.forEach((run, ri) => {
    const isFlagged = flaggedRuns.has(ri);
    const hasNote = !!runNotes[ri];
    const lines = (run.text || '').replace(/<[^>]+>/g, '').split('\\n').filter(l => l.trim());
    const lc = Math.max(lines.length, 1);
    const rawLineH = run.h / lc;
    const lineH = Math.min(
      (run.h_norm && rawLineH < run.h_norm) ? run.h_norm : rawLineH,
      maxLineH
    );
    const fs = Math.round(lineH * 0.663);

    // ── Text overlay (Text mode) ──────────────────────────────────
    if (showText) {
      const cardH = lineH * lc;
      parts.push(
        '<rect x="' + (run.x-4) + '" y="' + (run.y-4) + '" width="' + (run.w+8) + '" height="' + (cardH+8) + '" ' +
        'fill="white" fill-opacity="0.92" rx="4" pointer-events="none"/>'
      );
      lines.forEach((line, li) => {
        const ty = run.y + lineH * (li + 0.82);
        parts.push(
          '<text x="' + (run.x+8) + '" y="' + ty + '" font-size="' + fs + '" fill="#111" fill-opacity="0.9" ' +
          'font-family="\\'Noto Sans Lao\\',\\'Lao MN\\',sans-serif" pointer-events="none">' +
          escXml(line) + '</text>'
        );
      });
    }

    // ── Invisible hit-target (always covers the run) ──────────────
    parts.push(
      '<rect class="run-hit" data-run="' + ri + '" ' +
      'x="' + run.x + '" y="' + run.y + '" width="' + run.w + '" height="' + run.h + '" ' +
      'fill="transparent" stroke="none"/>'
    );

    // ── Problem mode: flag overlay ────────────────────────────────
    if (isProblem) {
      if (isFlagged) {
        parts.push(
          '<rect x="' + run.x + '" y="' + run.y + '" width="' + run.w + '" height="' + run.h + '" ' +
          'fill="rgba(220,38,38,0.28)" stroke="#dc2626" stroke-width="26" rx="6" pointer-events="none"/>' +
          '<line x1="' + (run.x+22) + '" y1="' + (run.y+22) + '" x2="' + (run.x+run.w-22) + '" y2="' + (run.y+run.h-22) + '" stroke="#dc2626" stroke-width="26" stroke-linecap="round" pointer-events="none"/>' +
          '<line x1="' + (run.x+run.w-22) + '" y1="' + (run.y+22) + '" x2="' + (run.x+22) + '" y2="' + (run.y+run.h-22) + '" stroke="#dc2626" stroke-width="26" stroke-linecap="round" pointer-events="none"/>'
        );
      } else {
        parts.push(
          '<rect x="' + run.x + '" y="' + run.y + '" width="' + run.w + '" height="' + run.h + '" ' +
          'fill="rgba(255,220,0,0.05)" stroke="#f59e0b" stroke-width="16" stroke-dasharray="26,16" rx="6" ' +
          'stroke-opacity="0.65" pointer-events="none"/>'
        );
      }
    }

    // ── Note mode: annotated-run highlights ───────────────────────
    if (noteMode) {
      if (hasNote) {
        // Already has a note: amber solid border + pencil badge
        parts.push(
          '<rect x="' + run.x + '" y="' + run.y + '" width="' + run.w + '" height="' + run.h + '" ' +
          'fill="rgba(245,158,11,0.15)" stroke="#f59e0b" stroke-width="20" rx="6" pointer-events="none"/>'
        );
        const bx = run.x + run.w - 30, by = run.y + 6;
        parts.push(
          '<rect x="' + bx + '" y="' + by + '" width="52" height="42" rx="10" fill="#f59e0b" pointer-events="none"/>' +
          '<text x="' + (bx+26) + '" y="' + (by+30) + '" text-anchor="middle" font-size="28" fill="#fff" pointer-events="none">✎</text>'
        );
      } else {
        // Tappable but no note yet: subtle dashed outline
        parts.push(
          '<rect x="' + run.x + '" y="' + run.y + '" width="' + run.w + '" height="' + run.h + '" ' +
          'fill="rgba(255,255,255,0.03)" stroke="#555" stroke-width="14" stroke-dasharray="20,14" rx="6" ' +
          'stroke-opacity="0.5" pointer-events="none"/>'
        );
      }
    }
  });

  svg.innerHTML = parts.join('');

  if (isProblem) {
    svg.querySelectorAll('.run-hit').forEach(el => {
      el.addEventListener('click', () => {
        const ri = parseInt(el.getAttribute('data-run'), 10);
        if (flaggedRuns.has(ri)) { flaggedRuns.delete(ri); toast('Unflagged'); }
        else { flaggedRuns.add(ri); toast('Flagged — ' + flaggedRuns.size + ' run' + (flaggedRuns.size > 1 ? 's' : '')); }
        dirty = true; updateSaveBtn(); renderRuns();
      });
    });
  } else if (noteMode) {
    svg.querySelectorAll('.run-hit').forEach(el => {
      el.addEventListener('click', () => openRunNote(parseInt(el.getAttribute('data-run'), 10)));
    });
  }
}

function applyVerdict(v, rerender = true) {
  currentVerdict = v;
  document.getElementById('okBtn').classList.toggle('inactive', v !== 'ok');
  document.getElementById('probBtn').classList.toggle('inactive', v !== 'problem');
  if (v !== 'problem') flaggedRuns.clear();
  if (rerender && currentOcr) renderRuns();
  dirty = true; updateSaveBtn();
}

function updateSaveBtn() {
  document.getElementById('saveBtn').disabled = !currentVerdict;
}

function updateNoteBtn() {
  document.getElementById('noteBtn').classList.toggle('has-note', !!currentNote);
}

document.getElementById('okBtn').addEventListener('click',   () => applyVerdict('ok'));
document.getElementById('probBtn').addEventListener('click', () => applyVerdict('problem'));
document.getElementById('navPrev').addEventListener('click', () => { if (currentIdx > 0) openDetail(currentIdx - 1); });
document.getElementById('navNext').addEventListener('click', () => { if (currentIdx < manifest.pages.length - 1) openDetail(currentIdx + 1); });

document.addEventListener('keydown', e => {
  if (!document.getElementById('detailScreen').classList.contains('active')) return;
  if (e.key === 'ArrowLeft')  document.getElementById('navPrev').click();
  if (e.key === 'ArrowRight') document.getElementById('navNext').click();
  if (e.key === 'Escape') {
    if (!document.getElementById('runNoteModal').classList.contains('hidden')) { closeRunNote(); return; }
    if (!document.getElementById('notesModal').classList.contains('hidden'))   { closeNotesModal(); return; }
    document.getElementById('detailBackBtn').click();
  }
});

// ══════════════════════════════════════════════════════════════════
// SAVE
// ══════════════════════════════════════════════════════════════════
document.getElementById('saveBtn').addEventListener('click', async () => {
  if (!currentVerdict) return;
  const p = manifest.pages[currentIdx];
  const reviewer = local.reviewer;
  const flaggedArr = Array.from(flaggedRuns);
  const flaggedTexts = flaggedArr.map(ri => {
    const run = (currentOcr && currentOcr.runs) ? currentOcr.runs[ri] : null;
    return run ? (run.text || '').slice(0, 80) : '';
  });

  // Save locally
  local.setReview(p.id, {
    status: currentVerdict, flaggedRuns: flaggedArr,
    note: currentNote, runNotes: Object.assign({}, runNotes),
    savedAt: new Date().toISOString(),
  });
  dirty = false;

  const btn = document.getElementById('saveBtn');
  btn.textContent = 'Saving…'; btn.disabled = true;
  try {
    await fetch('/api/chanting/review', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        reviewer_name: reviewer, page_id: p.id, page_title: p.title || '',
        status: currentVerdict, flagged_runs: flaggedArr,
        flagged_run_texts: flaggedTexts, notes: currentNote,
        run_notes: runNotes,
      }),
    });
    toast('Saved ✓');
  } catch { toast('Saved locally — no connection'); }

  btn.textContent = 'Save'; btn.disabled = !currentVerdict;
  buildGrid();
});

// ══════════════════════════════════════════════════════════════════
// NOTES MODAL
// ══════════════════════════════════════════════════════════════════
const notesModal  = document.getElementById('notesModal');
const notesInput  = document.getElementById('notesInput');

document.getElementById('noteBtn').addEventListener('click', openNotesModal);
document.getElementById('notesCancelBtn').addEventListener('click', closeNotesModal);
document.getElementById('notesClearBtn').addEventListener('click', () => { notesInput.value = ''; });
notesModal.addEventListener('click', e => { if (e.target === notesModal) closeNotesModal(); });

document.getElementById('notesSaveBtn').addEventListener('click', async () => {
  const newNote = notesInput.value.trim();
  currentNote = newNote;
  updateNoteBtn();
  dirty = true;
  updateSaveBtn();
  closeNotesModal();

  // Persist note independently if page already has a verdict saved
  const p = manifest.pages[currentIdx];
  const existing = local.getReview(p.id);
  if (existing) {
    existing.note = newNote;
    local.setReview(p.id, existing);
    try {
      await fetch('/api/chanting/note', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reviewer_name: local.reviewer, page_id: p.id, notes: newNote }),
      });
      toast('Note saved ✓');
    } catch { toast('Note saved locally'); }
  } else {
    toast('Note added — tap Save to record your verdict');
  }
});

function openNotesModal() {
  const p = manifest.pages[currentIdx];
  document.getElementById('notesPageSub').textContent = (currentIdx+1) + '. ' + (p.title || p.id);
  notesInput.value = currentNote;
  notesModal.classList.remove('hidden');
  setTimeout(() => notesInput.focus(), 100);
}

function closeNotesModal() {
  notesModal.classList.add('hidden');
  notesInput.blur();
}

// ══════════════════════════════════════════════════════════════════
// INIT
// ══════════════════════════════════════════════════════════════════
(async function init() {
  try {
    const r = await fetch(DATA_BASE + '/manifest.json', { cache: 'no-cache' });
    if (!r.ok) throw new Error('manifest.json not found');
    manifest = await r.json();
  } catch (e) {
    document.body.innerHTML =
      '<div style="padding:2rem;font-family:system-ui;max-width:500px;margin:0 auto">' +
      '<h2 style="color:#c00;margin-bottom:0.5rem">Data not yet uploaded</h2>' +
      '<p style="color:#555">Upload manifest, images, and OCR JSONs to R2 first.</p>' +
      '<pre style="margin-top:1rem;font-size:0.8rem;color:#888">' + e.message + '</pre></div>';
    return;
  }

  if (!local.reviewer) {
    showScreen('introScreen');
  } else {
    await loadDashboard();
  }
})();
</script>
</body>
</html>`;

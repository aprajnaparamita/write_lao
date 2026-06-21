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
import { translations } from './translations';
import { testerGuideHTML } from './tester-guide';
import { testerGuideHTMLThai } from './tester-guide-th';
import { chantingPageHTML } from './chanting-page';
import { createAdminRouter } from '../admin/router';
import { startMultipartUpload, uploadPart, completeMultipartUpload, abortMultipartUpload } from '../lib/r2-direct-upload';
import { generateTesterId } from '../lib/tester-id';
import {
  DOMAIN,
  LANGUAGES,
  renderPage,
  buildSitemap,
  buildRobotsTxt,
  buildLlmsTxt,
  detectLanguage,
} from './seo';

type Env = {
  ASSETS: Fetcher;
  DB: D1Database;
  COURSE_DATA: R2Bucket;
  TEACHER_JWT_SECRET: string;
  ADMIN_EMAIL: string;
  GOOGLE_CLIENT_ID: string;
  GOOGLE_CLIENT_SECRET: string;
  ENVIRONMENT: string;
  BREVO_API_KEY: string; // Secret: wrangler secret put BREVO_API_KEY
  ACCOUNT_ID?: string;
  R2_ACCESS_KEY_ID?: string;
  R2_SECRET_ACCESS_KEY?: string;
};

// ── Privacy Policy HTML ──────────────────────────────────────────────
const privacyPolicyHTML = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Privacy Policy — Write Lao</title>
  <style>
    :root { --cream: #faf6ef; --ink: #1a1511; --muted: #6b5a4a; --saffron: #c8573f; --line: #e6ddcd; }
    *, *::before, *::after { box-sizing: border-box; }
    body { margin: 0; font-family: system-ui, -apple-system, sans-serif; font-size: 1rem; line-height: 1.65; color: var(--ink); background: var(--cream); -webkit-font-smoothing: antialiased; }
    .container { max-width: 760px; margin: 0 auto; padding: 3rem 1.5rem 5rem; }
    .back { display: inline-flex; align-items: center; gap: 0.35rem; color: var(--saffron); font-weight: 600; font-size: 0.9375rem; text-decoration: none; margin-bottom: 2rem; }
    .back:hover { text-decoration: underline; }
    h1 { font-size: 1.75rem; font-weight: 700; margin: 0 0 0.25rem; }
    .effective { color: var(--muted); font-size: 0.875rem; margin-bottom: 2rem; }
    h2 { font-size: 1.2rem; font-weight: 700; margin: 2rem 0 0.75rem; padding-top: 1.5rem; border-top: 1px solid var(--line); }
    h2:first-of-type { border-top: 0; padding-top: 0; }
    p { margin: 0 0 1rem; color: var(--ink); }
    ul { margin: 0 0 1.25rem; padding-left: 1.25rem; }
    li { margin-bottom: 0.35rem; }
    a { color: var(--saffron); }
    hr { border: 0; border-top: 1px solid var(--line); margin: 2rem 0; }
    .generator { color: var(--muted); font-size: 0.8125rem; }
    .generator a { color: var(--muted); }
  </style>
</head>
<body>
  <div class="container">
    <a href="/" class="back">← Back to Write Lao</a>
    <h1>Privacy Policy</h1>
    <p class="effective">Effective as of 2026-04-29</p>

    <p>This privacy policy applies to the Write Lao app (hereby referred to as "Application") for mobile devices that was created by Janet Jeffus (hereby referred to as "Service Provider") as a Commercial service. This service is intended for use "AS IS".</p>

    <h2>Information Collection and Use</h2>
    <p>The Application collects information when you download and use it. This information may include information such as:</p>
    <ul>
      <li>Your device's Internet Protocol address (e.g. IP address)</li>
      <li>The pages of the Application that you visit, the time and date of your visit, the time spent on those pages</li>
      <li>The time spent on the Application</li>
      <li>The operating system you use on your mobile device</li>
    </ul>
    <p>The Application does not gather precise information about the location of your mobile device.</p>
    <p>The Application does not use Artificial Intelligence (AI) technologies to process your data or provide features.</p>
    <p>The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices and marketing promotions.</p>
    <p>For a better experience, while using the Application, the Service Provider may require you to provide us with certain personally identifiable information. The information that the Service Provider request will be retained by them and used as described in this privacy policy.</p>

    <h2>Third Party Access</h2>
    <p>Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may share your information with third parties in the ways that are described in this privacy statement.</p>
    <p>Please note that the Application utilizes third-party services that have their own Privacy Policy about handling data. Below are the links to the Privacy Policy of the third-party service providers used by the Application:</p>
    <ul>
      <li><a href="https://www.google.com/policies/privacy/" target="_blank" rel="noopener noreferrer">Google Play Services</a></li>
      <li><a href="https://sentry.io/privacy/" target="_blank" rel="noopener noreferrer">Sentry</a></li>
    </ul>
    <p>The Service Provider may disclose User Provided and Automatically Collected Information:</p>
    <ul>
      <li>as required by law, such as to comply with a subpoena, or similar legal process;</li>
      <li>when they believe in good faith that disclosure is necessary to protect their rights, protect your safety or the safety of others, investigate fraud, or respond to a government request;</li>
      <li>with their trusted services providers who work on their behalf, do not have an independent use of the information we disclose to them, and have agreed to adhere to the rules set forth in this privacy statement.</li>
    </ul>

    <h2>Opt-Out Rights</h2>
    <p>You can stop all collection of information by the Application easily by uninstalling it. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.</p>

    <h2>Data Retention Policy</h2>
    <p>The Service Provider will retain User Provided data for as long as you use the Application and for a reasonable time thereafter. If you'd like them to delete User Provided Data that you have provided via the Application, please contact them at <a href="mailto:help@maitrigroup.co">help@maitrigroup.co</a> and they will respond in a reasonable time.</p>

    <h2>Children</h2>
    <p>The Service Provider does not use the Application to knowingly solicit data from or market to children under the age of 13.</p>
    <p>The Application does not address anyone under the age of 13. The Service Provider does not knowingly collect personally identifiable information from children under 13 years of age. In the case the Service Provider discover that a child under 13 has provided personal information, the Service Provider will immediately delete this from their servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact the Service Provider (<a href="mailto:help@maitrigroup.co">help@maitrigroup.co</a>) so that they will be able to take the necessary actions.</p>

    <h2>Security</h2>
    <p>The Service Provider is concerned about safeguarding the confidentiality of your information. The Service Provider provides physical, electronic, and procedural safeguards to protect information the Service Provider processes and maintains.</p>

    <h2>Changes</h2>
    <p>This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to the Privacy Policy by updating this page with the new Privacy Policy. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.</p>

    <h2>Your Consent</h2>
    <p>By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by us.</p>

    <h2>Contact Us</h2>
    <p>If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at <a href="mailto:help@maitrigroup.co">help@maitrigroup.co</a>.</p>

    <hr>
    <p class="generator">This privacy policy page was generated by <a href="https://app-privacy-policy-generator.nisrulz.com/" target="_blank" rel="noopener noreferrer">App Privacy Policy Generator</a></p>
  </div>
</body>
</html>`;

// ── Terms of Service HTML ────────────────────────────────────────────
const tosHTML = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Terms &amp; Conditions — Write Lao</title>
  <style>
    :root { --cream: #faf6ef; --ink: #1a1511; --muted: #6b5a4a; --saffron: #c8573f; --line: #e6ddcd; }
    *, *::before, *::after { box-sizing: border-box; }
    body { margin: 0; font-family: system-ui, -apple-system, sans-serif; font-size: 1rem; line-height: 1.65; color: var(--ink); background: var(--cream); -webkit-font-smoothing: antialiased; }
    .container { max-width: 760px; margin: 0 auto; padding: 3rem 1.5rem 5rem; }
    .back { display: inline-flex; align-items: center; gap: 0.35rem; color: var(--saffron); font-weight: 600; font-size: 0.9375rem; text-decoration: none; margin-bottom: 2rem; }
    .back:hover { text-decoration: underline; }
    h1 { font-size: 1.75rem; font-weight: 700; margin: 0 0 0.25rem; }
    .effective { color: var(--muted); font-size: 0.875rem; margin-bottom: 2rem; }
    h2 { font-size: 1.2rem; font-weight: 700; margin: 2rem 0 0.75rem; padding-top: 1.5rem; border-top: 1px solid var(--line); }
    h2:first-of-type { border-top: 0; padding-top: 0; }
    p { margin: 0 0 1rem; color: var(--ink); }
    ul { margin: 0 0 1.25rem; padding-left: 1.25rem; }
    li { margin-bottom: 0.35rem; }
    a { color: var(--saffron); }
    hr { border: 0; border-top: 1px solid var(--line); margin: 2rem 0; }
    .generator { color: var(--muted); font-size: 0.8125rem; }
    .generator a { color: var(--muted); }
  </style>
</head>
<body>
  <div class="container">
    <a href="/" class="back">← Back to Write Lao</a>
    <h1>Terms &amp; Conditions</h1>
    <p class="effective">Effective as of 2026-04-29</p>

    <p>These terms and conditions apply to the Write Lao app (hereby referred to as "Application") for mobile devices that was created by Janet Jeffus (hereby referred to as "Service Provider") as a Commercial service.</p>
    <p>Upon downloading or utilizing the Application, you are automatically agreeing to the following terms. It is strongly advised that you thoroughly read and understand these terms prior to using the Application.</p>

    <h2>Intellectual Property</h2>
    <p>Unauthorized copying, modification of the Application, any part of the Application, or our trademarks is strictly prohibited. Any attempts to extract the source code of the Application, translate the Application into other languages, or create derivative versions are not permitted. All trademarks, copyrights, database rights, and other intellectual property rights related to the Application remain the property of the Service Provider.</p>

    <h2>Changes and Charges</h2>
    <p>The Service Provider is dedicated to ensuring that the Application is as beneficial and efficient as possible. As such, they reserve the right to modify the Application or charge for their services at any time and for any reason. The Service Provider assures you that any charges for the Application or its services will be clearly communicated to you.</p>

    <h2>Device Security</h2>
    <p>The Application stores and processes personal data that you have provided to the Service Provider in order to provide the Service. It is your responsibility to maintain the security of your phone and access to the Application. The Service Provider strongly advise against jailbreaking or rooting your phone, which involves removing software restrictions and limitations imposed by the official operating system of your device. Such actions could expose your phone to malware, viruses, malicious programs, compromise your phone's security features, and may result in the Application not functioning correctly or at all.</p>

    <h2>Third-Party Services</h2>
    <p>Please note that the Application utilizes third-party services that have their own Terms and Conditions. Below are the links to the Terms and Conditions of the third-party service providers used by the Application:</p>
    <ul>
      <li><a href="https://policies.google.com/terms" target="_blank" rel="noopener noreferrer">Google Play Services</a></li>
      <li><a href="https://sentry.io/terms/" target="_blank" rel="noopener noreferrer">Sentry</a></li>
    </ul>

    <h2>Connectivity</h2>
    <p>Please be aware that the Service Provider does not assume responsibility for certain aspects. Some functions of the Application require an active internet connection, which can be Wi-Fi or provided by your mobile network provider. The Service Provider cannot be held responsible if the Application does not function at full capacity due to lack of access to Wi-Fi or if you have exhausted your data allowance.</p>
    <p>If you are using the application outside of a Wi-Fi area, please be aware that your mobile network provider's agreement terms still apply. Consequently, you may incur charges from your mobile provider for data usage during the connection to the application, or other third-party charges. By using the application, you accept responsibility for any such charges, including roaming data charges if you use the application outside of your home territory (i.e., region or country) without disabling data roaming. If you are not the bill payer for the device on which you are using the application, they assume that you have obtained permission from the bill payer.</p>
    <p>Similarly, the Service Provider cannot always assume responsibility for your usage of the application. For instance, it is your responsibility to ensure that your device remains charged. If your device runs out of battery and you are unable to access the Service, the Service Provider cannot be held responsible.</p>

    <h2>Limitation of Liability</h2>
    <p>In terms of the Service Provider's responsibility for your use of the application, it is important to note that while they strive to ensure that it is updated and accurate at all times, they do rely on third parties to provide information to them so that they can make it available to you. The Service Provider accepts no liability for any loss, direct or indirect, that you experience as a result of relying entirely on this functionality of the application.</p>

    <h2>Updates and Termination</h2>
    <p>The Service Provider may wish to update the application at some point. The application is currently available as per the requirements for the operating system (and for any additional systems they decide to extend the availability of the application to) may change, and you will need to download the updates if you want to continue using the application. The Service Provider does not guarantee that it will always update the application so that it is relevant to you and/or compatible with the particular operating system version installed on your device. However, you agree to always accept updates to the application when offered to you. The Service Provider may also wish to cease providing the application and may terminate its use at any time without providing termination notice to you. Unless they inform you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must cease using the application, and (if necessary) delete it from your device.</p>

    <h2>Changes to These Terms and Conditions</h2>
    <p>The Service Provider may periodically update their Terms and Conditions. Therefore, you are advised to review this page regularly for any changes. The Service Provider will notify you of any changes by posting the new Terms and Conditions on this page.</p>

    <h2>Contact Us</h2>
    <p>If you have any questions or suggestions about the Terms and Conditions, please do not hesitate to contact the Service Provider at <a href="mailto:help@maitrigroup.co">help@maitrigroup.co</a>.</p>

    <hr>
    <p class="generator">This Terms and Conditions page was generated by <a href="https://app-privacy-policy-generator.nisrulz.com/" target="_blank" rel="noopener noreferrer">App Privacy Policy Generator</a></p>
  </div>
</body>
</html>`;

// ── Shared page styles ───────────────────────────────────────────────
const pageStyles = `
  :root { --cream: #faf6ef; --cream-2: #f2ebdd; --ink: #1a1511; --ink-soft: #3a312a; --muted: #6b5a4a; --saffron: #c8573f; --saffron-dark: #a8432e; --saffron-tint: #f5e4de; --teal: #1e3a3a; --line: #e6ddcd; }
  *, *::before, *::after { box-sizing: border-box; }
  body { margin: 0; font-family: system-ui, -apple-system, sans-serif; font-size: 1rem; line-height: 1.65; color: var(--ink); background: var(--cream); -webkit-font-smoothing: antialiased; }
  .container { max-width: 800px; margin: 0 auto; padding: 3rem 1.5rem 5rem; }
  .back { display: inline-flex; align-items: center; gap: 0.35rem; color: var(--saffron); font-weight: 600; font-size: 0.9375rem; text-decoration: none; margin-bottom: 2rem; }
  .back:hover { text-decoration: underline; }
  h1 { font-size: 1.875rem; font-weight: 700; margin: 0 0 0.5rem; }
  .subtitle { color: var(--muted); font-size: 1rem; margin-bottom: 2.5rem; }
  h2 { font-size: 1.2rem; font-weight: 700; margin: 2.5rem 0 1rem; padding-top: 2rem; border-top: 1px solid var(--line); }
  h2:first-of-type { border-top: 0; padding-top: 0; }
  p { margin: 0 0 1rem; }
  a { color: var(--saffron); }
  a:hover { text-decoration: underline; }
  .card { background: #fff; border: 1px solid var(--line); border-radius: 14px; padding: 1.75rem; margin-bottom: 1.5rem; box-shadow: 0 2px 8px rgba(26,21,17,0.06); }
  .qr-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 1.5rem; margin: 1.5rem 0; }
  .qr-card { background: #fff; border: 1px solid var(--line); border-radius: 14px; padding: 1.5rem; text-align: center; box-shadow: 0 2px 8px rgba(26,21,17,0.06); }
  .qr-card img { width: 220px; height: 220px; object-fit: contain; margin: 0 auto 1rem; border-radius: 8px; }
  .qr-card .qr-label { font-weight: 700; font-size: 1.0625rem; margin-bottom: 0.25rem; }
  .qr-card .qr-sub { color: var(--muted); font-size: 0.875rem; }
  .bank-table { width: 100%; border-collapse: collapse; font-size: 0.9375rem; }
  .bank-table tr { border-bottom: 1px solid var(--line); }
  .bank-table tr:last-child { border-bottom: 0; }
  .bank-table td { padding: 0.6rem 0.5rem; vertical-align: top; }
  .bank-table td:first-child { color: var(--muted); font-weight: 600; white-space: nowrap; padding-right: 1.25rem; width: 40%; }
  label { display: block; font-weight: 600; font-size: 0.9375rem; margin-bottom: 0.375rem; }
  input, textarea, select { width: 100%; padding: 0.625rem 0.875rem; font: inherit; font-size: 0.9375rem; color: var(--ink); background: var(--cream); border: 1.5px solid var(--line); border-radius: 8px; outline: none; transition: border-color 0.15s; margin-bottom: 1.25rem; }
  input:focus, textarea:focus { border-color: var(--saffron); background: #fff; }
  textarea { min-height: 140px; resize: vertical; }
  .btn { display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.75rem 1.75rem; font: inherit; font-weight: 700; font-size: 1rem; border-radius: 32px; border: 0; cursor: pointer; text-decoration: none; transition: background 0.15s, transform 0.1s; }
  .btn-primary { background: var(--saffron); color: #fff; }
  .btn-primary:hover { background: var(--saffron-dark); transform: translateY(-1px); }
  .success-msg { display: none; background: #ecfdf5; border: 1.5px solid #6ee7b7; border-radius: 8px; padding: 1rem 1.25rem; color: #065f46; font-weight: 600; margin-bottom: 1.25rem; }
  .error-msg { display: none; background: #fef2f2; border: 1.5px solid #fca5a5; border-radius: 8px; padding: 1rem 1.25rem; color: #991b1b; font-weight: 600; margin-bottom: 1.25rem; }
`;

// ── Support page ─────────────────────────────────────────────────────
const supportHTML = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Support — Write Lao</title>
  <style>${pageStyles}</style>
</head>
<body>
  <div class="container">
    <a href="/" class="back">← Back to Write Lao</a>
    <h1>Support</h1>
    <p class="subtitle">Spotted a bug or have a question? We'd love to hear from you.</p>

    <h2>Report a Bug by Email</h2>
    <div class="card">
      <div id="successMsg" class="success-msg">✓ Your report was sent! We'll be in touch soon.</div>
      <div id="errorMsg" class="error-msg">Something went wrong. Please email us directly at <a href="mailto:help@maitrigroup.co">help@maitrigroup.co</a>.</div>
      <form id="bugForm">
        <label for="name">Your name</label>
        <input type="text" id="name" name="name" placeholder="Janet" required>

        <label for="email">Your email</label>
        <input type="email" id="email" name="email" placeholder="you@example.com" required>

        <label for="device">Device &amp; OS</label>
        <input type="text" id="device" name="device" placeholder="e.g. iPhone 15, iOS 18.2">

        <label for="version">App version (if known)</label>
        <input type="text" id="version" name="version" placeholder="e.g. 1.0.1">

        <label for="description">Describe the issue</label>
        <textarea id="description" name="description" placeholder="What happened? What did you expect to happen? Steps to reproduce…" required></textarea>

        <button type="submit" class="btn btn-primary" id="submitBtn">Send Bug Report</button>
      </form>
      <p style="margin-top:1.25rem; font-size:0.875rem; color:var(--muted);">
        Or email us directly: <a href="mailto:help@maitrigroup.co">help@maitrigroup.co</a>
      </p>
    </div>

    <h2>Chat with Us Directly</h2>
    <p>Prefer to message in real time? Scan a QR code to reach Janet on LINE or WeChat.</p>
    <div class="qr-grid">
      <div class="qr-card">
        <img src="/assets/qr-line.jpg" alt="LINE QR code">
        <div class="qr-label">LINE</div>
        <div class="qr-sub">Scan to add Janet on LINE</div>
      </div>
      <div class="qr-card">
        <img src="/assets/qr-wechat.jpg" alt="WeChat QR code">
        <div class="qr-label">WeChat</div>
        <div class="qr-sub">Scan to add 嘉琳 on WeChat</div>
      </div>
    </div>
  </div>

  <script>
    document.getElementById('bugForm').addEventListener('submit', async function(e) {
      e.preventDefault();
      const btn = document.getElementById('submitBtn');
      const successMsg = document.getElementById('successMsg');
      const errorMsg = document.getElementById('errorMsg');
      btn.textContent = 'Sending…';
      btn.disabled = true;
      successMsg.style.display = 'none';
      errorMsg.style.display = 'none';

      const data = {
        name: document.getElementById('name').value,
        email: document.getElementById('email').value,
        device: document.getElementById('device').value,
        version: document.getElementById('version').value,
        description: document.getElementById('description').value,
      };

      try {
        const res = await fetch('/api/support', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data),
        });
        if (res.ok) {
          successMsg.style.display = 'block';
          document.getElementById('bugForm').reset();
        } else {
          errorMsg.style.display = 'block';
        }
      } catch {
        errorMsg.style.display = 'block';
      } finally {
        btn.textContent = 'Send Bug Report';
        btn.disabled = false;
      }
    });
  </script>
</body>
</html>`;

// ── Donations page ───────────────────────────────────────────────────
const donationsHTML = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Support the Project — Write Lao</title>
  <style>${pageStyles}</style>
</head>
<body>
  <div class="container">
    <a href="/" class="back">← Back to Write Lao</a>
    <h1>Support the Project</h1>
    <p class="subtitle">Write Lao is lovingly dedicated to the preservation of Lao language and culture. Every contribution helps keep it free and growing.</p>

    <h2>Thailand — PromptPay (Thai Baht)</h2>
    <div class="qr-card" style="max-width:340px;">
      <img src="/assets/qr-thai.jpg" alt="Thai QR Payment — PromptPay">
      <div class="qr-label">PromptPay / Thai QR Payment</div>
      <div class="qr-sub">MS. JANET EVELYN BRASWELL-JEFFUS<br>Accepts all Thai banks · รับเงินได้จากทุกธนาคาร</div>
    </div>

    <h2>International — Revolut</h2>
    <div class="qr-card" style="max-width:340px;">
      <img src="/assets/qr-revolut.jpg" alt="Revolut QR code">
      <div class="qr-label">Revolut</div>
      <div class="qr-sub">Scan to send via Revolut (multi-currency)</div>
    </div>

    <h2>United States — Bank Transfer (USD)</h2>
    <div class="card">
      <table class="bank-table">
        <tr><td>Beneficiary</td><td>Janet Braswell-Jeffus</td></tr>
        <tr><td>Account number</td><td>218735908884</td></tr>
        <tr><td>ACH routing</td><td>101019644</td></tr>
        <tr><td>Wire routing</td><td>101019644</td></tr>
        <tr><td>Bank</td><td>Lead Bank</td></tr>
        <tr><td>Bank address</td><td>1801 Main Street, Kansas City, MO 64108, United States</td></tr>
      </table>
    </div>

    <p style="color:var(--muted); font-size:0.875rem; margin-top:2rem;">
      Questions about donating? Email <a href="mailto:help@maitrigroup.co">help@maitrigroup.co</a>
    </p>
  </div>
</body>
</html>`;

const app = new Hono<{ Bindings: Env }>();

// Global middleware
app.use('*', logger());
app.use('*', cors({
  origin: ['https://writelao.xyz', 'https://www.writelao.xyz', 'http://localhost:8787', 'http://127.0.0.1:8787'],
  credentials: true,
}));

// Health check
app.get('/health', (c) => c.json({ status: 'ok', timestamp: new Date().toISOString() }));

// ── Landing page: English default + Accept-Language redirect ────────────
app.get('/', (c) => {
  // Redirect first-time visitors to their language version (JS will handle
  // subsequent language switching client-side via the /i18n/*.json endpoint)
  const acceptLang = c.req.header('Accept-Language') ?? null;
  const detected   = detectLanguage(acceptLang);
  if (detected) {
    // Temporary redirect so browsers re-check language prefs on next visit
    return c.redirect(`/${detected}`, 302);
  }

  const baseUrl = DOMAIN;
  // English page: SSR with English defaults (no translations object needed,
  // but we still inject hreflang / canonical / JSON-LD into the head)
  const html = renderPage(landingPageHTML, 'en', {}, baseUrl);
  return c.html(html, 200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'public, max-age=3600, stale-while-revalidate=86400',
  });
});

// ── Per-language SSR pages ───────────────────────────────────────────────
for (const lang of LANGUAGES.filter(l => l.code !== 'en')) {
  app.get(lang.path, (c) => {
    const t    = translations[lang.code] ?? {};
    const html = renderPage(landingPageHTML, lang.code, t, DOMAIN);
    return c.html(html, 200, {
      'Content-Type': 'text/html; charset=utf-8',
      'Cache-Control': 'public, max-age=3600, stale-while-revalidate=86400',
      'Vary': 'Accept-Language',
    });
  });
}

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

// ── SEO / crawler files ──────────────────────────────────────────────────

app.get('/sitemap.xml', (c) =>
  c.body(buildSitemap(DOMAIN), 200, {
    'Content-Type': 'application/xml; charset=utf-8',
    'Cache-Control': 'public, max-age=3600',
  }),
);

app.get('/robots.txt', (c) =>
  c.body(buildRobotsTxt(DOMAIN), 200, {
    'Content-Type': 'text/plain; charset=utf-8',
    'Cache-Control': 'public, max-age=3600',
  }),
);

// llms.txt — machine-readable site description for AI/LLM crawlers
app.get('/llms.txt', (c) =>
  c.body(buildLlmsTxt(DOMAIN), 200, {
    'Content-Type': 'text/plain; charset=utf-8',
    'Cache-Control': 'public, max-age=3600',
  }),
);

// ── Admin routes (protected) ─────────────────────────────────────────────
app.route('/admin', createAdminRouter());

// Privacy Policy page
app.get('/privacy_policy.html', (c) => {
  return c.html(privacyPolicyHTML, 200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'public, max-age=86400',
  });
});

// Terms of Service page
app.get('/tos.html', (c) => {
  return c.html(tosHTML, 200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'public, max-age=86400',
  });
});

// Support page
app.get('/support', (c) => {
  return c.html(supportHTML, 200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'public, max-age=3600',
  });
});

// Manual Tester Guide page (with language detection)
app.get('/tester-guide', (c) => {
  // Detect language from Accept-Language header
  const acceptLang = c.req.header('Accept-Language') || '';
  const isThai = /th(?:-TH|$|,\s*th)/i.test(acceptLang);
  
  if (isThai) {
    return c.html(testerGuideHTMLThai, 200, {
      'Content-Type': 'text/html; charset=utf-8',
      'Cache-Control': 'public, max-age=3600',
      'Vary': 'Accept-Language',
    });
  }
  
  return c.html(testerGuideHTML, 200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'public, max-age=3600',
    'Vary': 'Accept-Language',
  });
});

// Thai-specific tester guide route (explicit)
app.get('/th/tester-guide', (c) => {
  return c.html(testerGuideHTMLThai, 200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'public, max-age=3600',
  });
});

// English explicit route
app.get('/en/tester-guide', (c) => {
  return c.html(testerGuideHTML, 200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'public, max-age=3600',
  });
});

// Donations page
app.get('/donations', (c) => {
  return c.html(donationsHTML, 200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'public, max-age=3600',
  });
});

// Support form API — sends bug report email via Resend
app.post('/api/support', async (c) => {
  try {
    const body = await c.req.json<{
      name: string;
      email: string;
      device?: string;
      version?: string;
      description: string;
    }>();

    if (!body.name || !body.email || !body.description) {
      return c.json({ error: 'Missing required fields' }, 400);
    }

    const emailBody = [
      `Bug Report from Write Lao Website`,
      ``,
      `Name:        ${body.name}`,
      `Email:       ${body.email}`,
      `Device / OS: ${body.device || '(not provided)'}`,
      `App version: ${body.version || '(not provided)'}`,
      ``,
      `Description:`,
      body.description,
    ].join('\n');

    const res = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'api-key': c.env.BREVO_API_KEY,
      },
      body: JSON.stringify({
        sender: { name: 'Write Lao Support', email: 'noreply@writelao.xyz' },
        to: [{ email: 'help@dharmaprotectors.org', name: 'Write Lao Support' }],
        replyTo: { email: body.email, name: body.name },
        subject: `[Bug Report] from ${body.name} — Write Lao`,
        textContent: emailBody,
      }),
    });

    if (res.ok) {
      return c.json({ success: true }, 200);
    }
    const errText = await res.text();
    console.error('Brevo error:', res.status, errText);
    return c.json({ error: 'Email delivery failed' }, 500);
  } catch (err) {
    console.error('Support form error:', err);
    return c.json({ error: 'Internal error' }, 500);
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// CHANTING BOOK OCR REVIEW  /chanting
//
// To set up:
//   1. Run the D1 migration:  wrangler d1 execute writelao-db --file=migrations/0005_create_chanting_reviews.sql
//   2. Upload assets to R2:
//        wrangler r2 object put writelao-course-data/chanting/manifest.json --file=<path>/web/manifest.json
//        for f in <thumbs_orig>/*.jpg; do
//          wrangler r2 object put writelao-course-data/chanting/orig/$(basename $f) --file=$f
//        done
//        for f in <ocr_json>/*.json; do
//          wrangler r2 object put writelao-course-data/chanting/ocr/$(basename $f) --file=$f
//        done
// ═══════════════════════════════════════════════════════════════════════════

// Chanting review app page
app.get('/chanting', (c) => {
  return c.html(chantingPageHTML, 200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'no-cache',
  });
});

// Proxy chanting data files from R2  (manifest, images, OCR JSONs)
app.get('/chanting/data/*', async (c) => {
  const path = c.req.path.replace('/chanting/data/', '');
  const key = 'chanting/' + path;
  const obj = await c.env.COURSE_DATA.get(key);
  if (!obj) return c.json({ error: 'Not found: ' + key }, 404);

  const ct = obj.httpMetadata?.contentType
    || (path.endsWith('.json') ? 'application/json'
      : path.endsWith('.jpg') || path.endsWith('.jpeg') ? 'image/jpeg'
      : path.endsWith('.png') ? 'image/png'
      : 'application/octet-stream');

  return c.body(obj.body, 200, {
    'Content-Type': ct,
    'Cache-Control': path.endsWith('.json') ? 'no-cache' : 'public, max-age=86400',
  });
});

// Save a page review (verdict + flagged runs + notes)
app.post('/api/chanting/review', async (c) => {
  try {
    const body = await c.req.json<{
      reviewer_name: string;
      page_id: string;
      page_title?: string;
      status: 'ok' | 'problem';
      flagged_runs?: number[];
      flagged_run_texts?: string[];
      notes?: string;
      run_notes?: Record<string, string>;
    }>();

    if (!body.reviewer_name || !body.page_id || !body.status) {
      return c.json({ error: 'Missing required fields' }, 400);
    }
    if (!['ok', 'problem'].includes(body.status)) {
      return c.json({ error: 'status must be ok or problem' }, 400);
    }

    await c.env.DB.prepare(`
      INSERT INTO chanting_reviews
        (reviewer_name, page_id, page_title, status, flagged_runs, flagged_run_texts, notes, run_notes, reviewed_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
    `).bind(
      body.reviewer_name,
      body.page_id,
      body.page_title || '',
      body.status,
      JSON.stringify(body.flagged_runs || []),
      JSON.stringify(body.flagged_run_texts || []),
      body.notes || '',
      JSON.stringify(body.run_notes || {}),
    ).run();

    return c.json({ success: true }, 200);
  } catch (err) {
    console.error('Chanting review save error:', err);
    return c.json({ error: 'Failed to save review' }, 500);
  }
});

// Save / update a note without changing the verdict
app.post('/api/chanting/note', async (c) => {
  try {
    const body = await c.req.json<{
      reviewer_name: string;
      page_id: string;
      notes: string;
    }>();
    if (!body.reviewer_name || !body.page_id) {
      return c.json({ error: 'Missing required fields' }, 400);
    }
    await c.env.DB.prepare(`
      UPDATE chanting_reviews SET notes = ?, reviewed_at = datetime('now')
      WHERE reviewer_name = ? AND page_id = ?
    `).bind(body.notes || '', body.reviewer_name, body.page_id).run();
    return c.json({ success: true }, 200);
  } catch (err) {
    console.error('Chanting note save error:', err);
    return c.json({ error: 'Failed to save note' }, 500);
  }
});

// Per-reviewer aggregate stats for the dashboard
app.get('/api/chanting/reviewers', async (c) => {
  try {
    const result = await c.env.DB.prepare(`
      SELECT
        reviewer_name,
        COUNT(*) AS total,
        SUM(CASE WHEN status = 'ok' THEN 1 ELSE 0 END) AS ok_count,
        SUM(CASE WHEN status = 'problem' THEN 1 ELSE 0 END) AS problem_count,
        MAX(reviewed_at) AS last_reviewed_at
      FROM chanting_reviews
      GROUP BY reviewer_name
      ORDER BY total DESC
    `).all();
    return c.json({ reviewers: result.results }, 200, { 'Cache-Control': 'no-cache' });
  } catch (err) {
    console.error('Chanting reviewers fetch error:', err);
    return c.json({ error: 'Failed to fetch reviewers' }, 500);
  }
});

// Get all reviews — for LLM export / dashboard detail
// Usage: GET /api/chanting/reviews
//        GET /api/chanting/reviews?reviewer=Daisy
//        GET /api/chanting/reviews?status=problem
app.get('/api/chanting/reviews', async (c) => {
  try {
    const reviewer = c.req.query('reviewer');
    const status   = c.req.query('status');

    let sql = 'SELECT * FROM chanting_reviews WHERE 1=1';
    const binds: string[] = [];
    if (reviewer) { sql += ' AND reviewer_name = ?'; binds.push(reviewer); }
    if (status)   { sql += ' AND status = ?';        binds.push(status); }
    sql += ' ORDER BY reviewed_at DESC';

    const result = await c.env.DB.prepare(sql).bind(...binds).all();
    const rows = result.results.map((r: any) => ({
      ...r,
      flagged_runs:      JSON.parse(r.flagged_runs || '[]'),
      flagged_run_texts: JSON.parse(r.flagged_run_texts || '[]'),
      run_notes:         JSON.parse(r.run_notes || '{}'),
    }));

    return c.json({ reviews: rows, total: rows.length }, 200, {
      'Cache-Control': 'no-cache',
    });
  } catch (err) {
    console.error('Chanting reviews fetch error:', err);
    return c.json({ error: 'Failed to fetch reviews' }, 500);
  }
});

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

// ═══════════════════════════════════════════════════════════════════════════
// TESTER IDENTITY — Deterministic ID from device info
// ═══════════════════════════════════════════════════════════════════════════

// Register a tester — returns a deterministic ID based on device info.
// Re-entering the same details on any device produces the same ID.
app.post('/api/tester/register', async (c) => {
  try {
    const body = await c.req.json<{
      deviceModel: string;
      osVersion: string;
      appVersion?: string;
      testerName?: string;
    }>();

    if (!body.deviceModel || !body.osVersion) {
      return c.json({ error: 'Missing deviceModel or osVersion' }, 400);
    }

    const testerId = await generateTesterId(
      body.deviceModel,
      body.osVersion,
      body.appVersion || '',
      body.testerName || '',
    );

    return c.json({ testerId }, 200);
  } catch (err) {
    console.error('Register tester error:', err);
    return c.json({ error: 'Failed to register tester' }, 500);
  }
});

// Get a tester's previous submissions
app.get('/api/tester/my-submissions', async (c) => {
  try {
    const testerId = c.req.query('tester_id');
    if (!testerId) {
      return c.json({ error: 'Missing tester_id' }, 400);
    }

    const db = c.env.DB;
    const results = await db.prepare(`
      SELECT id, filename, section, device_model, os_version, app_version, tester_name, uploaded_at
      FROM tester_submissions
      WHERE tester_id = ?
      ORDER BY uploaded_at DESC
    `).bind(testerId).all();

    return c.json({ submissions: results.results, testerId }, 200);
  } catch (err) {
    console.error('My submissions error:', err);
    return c.json({ error: 'Failed to fetch submissions' }, 500);
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// VIDEO UPLOAD API — Tester Guide
//
// Three upload paths:
//   1. POST /api/tester/upload/start     — start multipart upload (chunked)
//   2. POST /api/tester/upload/part      — upload a chunk
//   3. POST /api/tester/upload/complete  — finalize + record in D1
//   4. POST /api/tester/video            — legacy single-request upload
//      (for files ≤ 100 MB; stays as a simple fallback).
// ═══════════════════════════════════════════════════════════════════════════

// In-memory session store (per-Worker, ephemeral — lost on cold start,
// but sessions are short-lived so this is acceptable)
const uploadSessions = new Map<string, {
  key: string;
  uploadId: string;
  parts: { partNumber: number; etag: string }[];
}>();

// ── Start multipart upload ───────────────────────────────────────────
app.post('/api/tester/upload/start', async (c) => {
  try {
    const body = await c.req.json<{
      section: string;
      deviceModel?: string;
    }>();

    if (!body.section) {
      return c.json({ error: 'Missing section' }, 400);
    }

    const session = await startMultipartUpload(
      c.env.COURSE_DATA,
      body.deviceModel || 'unknown',
      body.section,
    );

    // Store session in memory
    uploadSessions.set(session.uploadId, {
      key: session.key,
      uploadId: session.uploadId,
      parts: [],
    });

    return c.json({
      success: true,
      sessionId: session.uploadId,
      key: session.key,
      filename: session.filename,
    }, 200);
  } catch (err) {
    console.error('Upload start error:', err);
    const message = err instanceof Error ? err.message : 'Failed to start upload';
    return c.json({ error: message }, 500);
  }
});

// ── Upload a chunk ───────────────────────────────────────────────────
app.post('/api/tester/upload/part', async (c) => {
  try {
    const formData = await c.req.formData();
    const sessionId = formData.get('sessionId') as string | null;
    const partNumberStr = formData.get('partNumber') as string | null;
    const chunk = formData.get('chunk') as File | null;

    if (!sessionId || !partNumberStr || !chunk) {
      return c.json({ error: 'Missing sessionId, partNumber, or chunk' }, 400);
    }

    const partNumber = parseInt(partNumberStr, 10);
    const session = uploadSessions.get(sessionId);
    if (!session) {
      return c.json({ error: 'Session not found (may have expired)' }, 404);
    }

    const result = await uploadPart(
      c.env.COURSE_DATA,
      session.key,
      session.uploadId,
      partNumber,
      chunk,
    );

    // Track the part
    session.parts.push({ partNumber: result.partNumber, etag: result.etag });

    return c.json({ success: true, partNumber: result.partNumber, etag: result.etag }, 200);
  } catch (err) {
    console.error('Upload part error:', err);
    const message = err instanceof Error ? err.message : 'Failed to upload chunk';
    return c.json({ error: message }, 500);
  }
});

// ── Complete multipart upload ────────────────────────────────────────
app.post('/api/tester/upload/complete', async (c) => {
  try {
    const body = await c.req.json<{
      sessionId: string;
      section: string;
      deviceModel?: string;
      osVersion?: string;
      appVersion?: string;
      testerName?: string;
      testerId?: string;
    }>();

    const { sessionId, section } = body;
    if (!sessionId || !section) {
      return c.json({ error: 'Missing sessionId or section' }, 400);
    }

    const session = uploadSessions.get(sessionId);
    if (!session) {
      return c.json({ error: 'Session not found (may have expired)' }, 404);
    }

    // Complete the multipart upload
    await completeMultipartUpload(
      c.env.COURSE_DATA,
      session.key,
      session.uploadId,
      session.parts,
    );

    // Compute tester_id
    const tid = body.testerId || await generateTesterId(
      body.deviceModel || 'Unknown',
      body.osVersion || 'Unknown',
      body.appVersion || '',
      body.testerName || 'Anonymous',
    );

    // Store metadata in D1
    const db = c.env.DB;
    await db.prepare(`
      INSERT INTO tester_submissions (filename, section, device_model, os_version, app_version, tester_name, tester_id, uploaded_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))
    `).bind(
      session.key,
      section,
      body.deviceModel || 'Unknown',
      body.osVersion || 'Unknown',
      body.appVersion || 'Unknown',
      body.testerName || 'Anonymous',
      tid,
    ).run();

    // Clean up session
    uploadSessions.delete(sessionId);

    return c.json({ success: true, filename: session.key, testerId: tid }, 200);
  } catch (err) {
    console.error('Upload complete error:', err);
    const message = err instanceof Error ? err.message : 'Failed to complete upload';
    return c.json({ error: message }, 500);
  }
});

// ── Abort a failed upload ────────────────────────────────────────────
app.post('/api/tester/upload/abort', async (c) => {
  try {
    const body = await c.req.json<{ sessionId: string }>();
    const { sessionId } = body;
    if (!sessionId) {
      return c.json({ error: 'Missing sessionId' }, 400);
    }

    const session = uploadSessions.get(sessionId);
    if (session) {
      await abortMultipartUpload(c.env.COURSE_DATA, session.key, session.uploadId);
      uploadSessions.delete(sessionId);
    }

    return c.json({ success: true }, 200);
  } catch (err) {
    console.error('Upload abort error:', err);
    const message = err instanceof Error ? err.message : 'Failed to abort upload';
    return c.json({ error: message }, 500);
  }
});

// ── Legacy worker-proxied upload (for files ≤ 100 MB) ────────────────
app.post('/api/tester/video', async (c) => {
  try {
    const formData = await c.req.formData();
    const video = formData.get('video') as File | null;
    const section = formData.get('section') as string | null;
    const deviceModel = formData.get('deviceModel') as string | null;
    const osVersion = formData.get('osVersion') as string | null;
    const appVersion = formData.get('appVersion') as string | null;
    const testerName = formData.get('testerName') as string | null;
    const testerId = formData.get('testerId') as string | null;

    if (!video || !section) {
      return c.json({ error: 'Missing video or section' }, 400);
    }

    // Enforce 100 MB Worker limit
    if (video.size > 100 * 1024 * 1024) {
      return c.json({
        error: 'File too large for direct upload. Use the pre-signed URL flow instead.',
        maxSize: 100 * 1024 * 1024,
      }, 413);
    }

    // Compute tester_id if not provided
    const tid = testerId || await generateTesterId(
      deviceModel || 'Unknown',
      osVersion || 'Unknown',
      appVersion || '',
      testerName || 'Anonymous',
    );

    // Generate unique filename
    const timestamp = Date.now();
    const sanitizedModel = (deviceModel || 'unknown').replace(/[^a-zA-Z0-9 ]/g, '').replace(/\s+/g, '_');
    const filename = `${timestamp}_${sanitizedModel}_${section}.mp4`;

    // Store in R2 bucket
    const r2Key = `tester-videos/${filename}`;
    await c.env.COURSE_DATA.put(r2Key, video, {
      httpMetadata: {
        contentType: video.type || 'video/mp4',
      },
      customMetadata: {
        section,
        deviceModel: deviceModel || 'Unknown',
        osVersion: osVersion || 'Unknown',
        appVersion: appVersion || 'Unknown',
        testerName: testerName || 'Anonymous',
        testerId: tid,
        uploadedAt: new Date().toISOString(),
      },
    });

    // Store metadata in D1
    const db = c.env.DB;
    await db.prepare(`
      INSERT INTO tester_submissions (filename, section, device_model, os_version, app_version, tester_name, tester_id, uploaded_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))
    `).bind(
      r2Key, section,
      deviceModel || 'Unknown', osVersion || 'Unknown',
      appVersion || 'Unknown', testerName || 'Anonymous',
      tid,
    ).run();

    return c.json({ success: true, filename: r2Key, testerId: tid }, 200);
  } catch (err) {
    console.error('Video upload error:', err);
    return c.json({ error: 'Upload failed' }, 500);
  }
});

// Get all tester submissions (for admin)
app.get('/api/tester/submissions', async (c) => {
  try {
    const db = c.env.DB;
    const results = await db.prepare(`
      SELECT id, filename, section, device_model, os_version, app_version, tester_name, uploaded_at
      FROM tester_submissions
      ORDER BY uploaded_at DESC
    `).all();

    return c.json({ submissions: results.results }, 200);
  } catch (err) {
    console.error('Submissions fetch error:', err);
    return c.json({ error: 'Failed to fetch submissions' }, 500);
  }
});

// Get submissions grouped by device
app.get('/api/tester/devices', async (c) => {
  try {
    const db = c.env.DB;
    const results = await db.prepare(`
      SELECT DISTINCT device_model, os_version, app_version
      FROM tester_submissions
      ORDER BY device_model, os_version
    `).all();

    return c.json({ devices: results.results }, 200);
  } catch (err) {
    console.error('Devices fetch error:', err);
    return c.json({ error: 'Failed to fetch devices' }, 500);
  }
});

// Get filter options for drill-down dropdowns
app.get('/api/tester/filters', async (c) => {
  try {
    const db = c.env.DB;
    const [versions, testers, devices, osList] = await Promise.all([
      db.prepare(`SELECT DISTINCT app_version FROM tester_submissions ORDER BY app_version DESC`).all(),
      db.prepare(`SELECT DISTINCT tester_name FROM tester_submissions ORDER BY tester_name`).all(),
      db.prepare(`SELECT DISTINCT device_model FROM tester_submissions ORDER BY device_model`).all(),
      db.prepare(`SELECT DISTINCT os_version FROM tester_submissions ORDER BY os_version`).all(),
    ]);

    return c.json({
      appVersions: versions.results.map((r: any) => r.app_version),
      testerNames: testers.results.map((r: any) => r.tester_name),
      deviceModels: devices.results.map((r: any) => r.device_model),
      osVersions: osList.results.map((r: any) => r.os_version),
    }, 200);
  } catch (err) {
    console.error('Filters fetch error:', err);
    return c.json({ error: 'Failed to fetch filters' }, 500);
  }
});

// Get video file from R2
app.get('/api/tester/video/:key', async (c) => {
  try {
    const key = c.req.param('key');
    const video = await c.env.COURSE_DATA.get(key);
    
    if (!video) {
      return c.json({ error: 'Video not found' }, 404);
    }

    return c.body(video.body, 200, {
      'Content-Type': video.httpMetadata?.contentType || 'video/mp4',
      'Content-Disposition': `inline; filename="${key.split('/').pop()}"`,
    });
  } catch (err) {
    console.error('Video fetch error:', err);
    return c.json({ error: 'Failed to fetch video' }, 500);
  }
});

// Delete a submission
app.delete('/api/tester/submission/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const db = c.env.DB;
    
    // Get the filename first
    const result = await db.prepare('SELECT filename FROM tester_submissions WHERE id = ?').bind(id).first();
    if (result && result.filename) {
      // Delete from R2
      await c.env.COURSE_DATA.delete(result.filename as string);
    }
    
    // Delete from D1
    await db.prepare('DELETE FROM tester_submissions WHERE id = ?').bind(id).run();
    
    return c.json({ success: true }, 200);
  } catch (err) {
    console.error('Delete error:', err);
    return c.json({ error: 'Failed to delete' }, 500);
  }
});

export default app;
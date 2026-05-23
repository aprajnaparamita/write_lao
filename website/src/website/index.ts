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
import { favicon32Base64 } from './favicon32-image';
import { favicon16Base64 } from './favicon16-image';
import { appleTouchIconBase64 } from './apple-touch-icon-image';
import { androidChrome192Base64 } from './android-chrome-192-image';
import { androidChrome512Base64 } from './android-chrome-512-image';
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

// Site icons
app.get('/icons/favicon-32.png', (c) => {
  if (favicon32Base64) {
    return c.body(Buffer.from(favicon32Base64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=604800, immutable',
    });
  }
  return c.text('Image not found', 404);
});

app.get('/icons/favicon-16.png', (c) => {
  if (favicon16Base64) {
    return c.body(Buffer.from(favicon16Base64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=604800, immutable',
    });
  }
  return c.text('Image not found', 404);
});

app.get('/icons/apple-touch-icon.png', (c) => {
  if (appleTouchIconBase64) {
    return c.body(Buffer.from(appleTouchIconBase64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=604800, immutable',
    });
  }
  return c.text('Image not found', 404);
});

app.get('/icons/android-chrome-192x192.png', (c) => {
  if (androidChrome192Base64) {
    return c.body(Buffer.from(androidChrome192Base64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=604800, immutable',
    });
  }
  return c.text('Image not found', 404);
});

app.get('/icons/android-chrome-512x512.png', (c) => {
  if (androidChrome512Base64) {
    return c.body(Buffer.from(androidChrome512Base64, 'base64'), 200, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=604800, immutable',
    });
  }
  return c.text('Image not found', 404);
});

app.get('/icons/favicon.svg', (c) => {
  // SVG favicon - use the main favicon
  if (faviconBase64) {
    return c.body(Buffer.from(faviconBase64, 'base64'), 200, {
      'Content-Type': 'image/svg+xml',
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
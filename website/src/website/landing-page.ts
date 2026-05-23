/**
 * Embedded landing page content
 * Copy of website/index.html converted to template string
 */

// CSS embedded as string for worker
export const landingPageCSS = `.container{width:100%;max-width:1180px;margin:0 auto;padding:0 1.5rem}:root{--cream:#faf6ef;--cream-2:#f2ebdd;--ink:#1a1511;--ink-soft:#3a312a;--muted:#6b5a4a;--line:#e6ddcd;--saffron:#c8573f;--saffron-dark:#a8432e;--saffron-tint:#f5e4de;--teal:#1e3a3a;--gold:#d4a574;--gold-tint:#f0dfc4;--font-display:"Fraunces","Iowan Old Style",Georgia,serif;--font-body:"Inter",-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;--font-lao:"Noto Sans Lao","Lao UI",var(--font-display);--fs-display-xl:clamp(2.25rem,6vw,4.25rem);--fs-display-lg:clamp(1.75rem,4.5vw,3rem);--fs-h2:clamp(1.5rem,3.5vw,2.25rem);--fs-lede:clamp(1.0625rem,2vw,1.1875rem);--fs-body:1rem;--fs-small:0.875rem;--sp-1:0.25rem;--sp-2:0.5rem;--sp-3:0.75rem;--sp-4:1rem;--sp-6:1.5rem;--sp-8:2rem;--sp-12:3rem;--sp-16:4rem;--sp-24:6rem;--r-sm:8px;--r-md:14px;--r-lg:22px;--r-xl:32px;--r-phone:36px;--shadow-1:0 1px 2px rgba(26,21,17,0.04),0 1px 4px rgba(26,21,17,0.06);--shadow-2:0 6px 20px rgba(26,21,17,0.08),0 2px 8px rgba(26,21,17,0.05);--shadow-3:0 20px 60px rgba(26,21,17,0.16),0 8px 24px rgba(26,21,17,0.08)}*,*::before,*::after{box-sizing:border-box}html{-webkit-text-size-adjust:100%;text-size-adjust:100%;scroll-behavior:smooth;scroll-padding-top:72px}body{margin:0;font-family:var(--font-body);font-size:var(--fs-body);line-height:1.6;color:var(--ink);background:var(--cream);-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale;text-rendering:optimizeLegibility}img,svg,video{display:block;max-width:100%}h1,h2,h3,h4{margin:0;line-height:1.15;letter-spacing:-0.01em}p{margin:0}ul{margin:0;padding:0;list-style:none}a{color:inherit;text-decoration:none}button{font:inherit;cursor:pointer;background:none;border:0;color:inherit}.skip-link{position:absolute;left:-9999px;top:0;background:var(--ink);color:var(--cream);padding:0.5rem 0.75rem;border-radius:0 0 8px 0;z-index:100}.skip-link:focus{left:0}.visually-hidden{position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0}.display{font-family:var(--font-display);font-weight:500;letter-spacing:-0.02em}.display em{font-style:italic;font-weight:500}.ink{color:var(--saffron);font-style:italic}.eyebrow{font-family:var(--font-body);font-size:0.8125rem;text-transform:uppercase;letter-spacing:0.14em;color:var(--saffron);font-weight:600;margin-bottom:var(--sp-4)}.section-h{font-size:var(--fs-display-lg);max-width:22ch}.section-sub{font-size:var(--fs-lede);color:var(--muted);max-width:60ch;margin-top:var(--sp-4);line-height:1.55}.btn{display:inline-flex;align-items:center;justify-content:center;gap:0.5rem;padding:0.75rem 1.25rem;border-radius:999px;font-weight:600;font-size:0.9375rem;transition:transform .15s ease,background-color .15s ease,color .15s ease,box-shadow .15s ease;white-space:nowrap;border:1.5px solid transparent}.btn:active{transform:translateY(1px)}.btn-sm{padding:0.5rem 0.95rem;font-size:0.875rem}.btn-lg{padding:1rem 1.5rem;font-size:1rem}.btn-primary{background:var(--saffron);color:#fff;box-shadow:0 6px 16px rgba(200,87,63,0.28)}.btn-primary:hover{background:var(--saffron-dark)}.btn-ghost{color:var(--ink);border-color:var(--line);background:transparent}.btn-ghost:hover{border-color:var(--ink);background:rgba(26,21,17,0.03)}.site-header{position:sticky;top:0;z-index:40;background:rgba(250,246,239,0.8);backdrop-filter:saturate(140%) blur(12px);-webkit-backdrop-filter:saturate(140%) blur(12px);border-bottom:1px solid transparent;transition:border-color .2s ease,background-color .2s ease}.site-header.is-scrolled{border-bottom-color:var(--line);background:rgba(250,246,239,0.92)}.header-inner{display:flex;align-items:center;justify-content:space-between;padding-top:var(--sp-3);padding-bottom:var(--sp-3);gap:var(--sp-4)}.brand{display:inline-flex;align-items:center;gap:0.5rem;font-weight:700;font-size:1rem}.brand-mark{font-family:var(--font-lao);font-size:1.75rem;line-height:1;color:var(--saffron);font-weight:700;transform:translateY(-2px)}.nav{display:none;gap:var(--sp-6);font-weight:500;font-size:0.9375rem;color:var(--ink-soft)}.nav a:hover{color:var(--ink)}.nav-cta{display:none}@media(min-width:760px){.nav,.nav-cta{display:inline-flex}}.hero{position:relative;padding:var(--sp-16) 0 var(--sp-12);overflow:hidden}.hero::before{content:"";position:absolute;inset:-10% -10% auto auto;width:70%;height:70%;background:radial-gradient(closest-side,var(--gold-tint),transparent 70%);z-index:0;filter:blur(20px);opacity:0.7}.hero-grid{position:relative;z-index:1;display:grid;gap:var(--sp-12);align-items:center}.hero-copy h1.display{font-size:var(--fs-display-xl);line-height:1.02;margin-bottom:var(--sp-6)}.lede{font-size:var(--fs-lede);color:var(--ink-soft);max-width:54ch;line-height:1.55;margin-bottom:var(--sp-8)}.hero-ctas{display:flex;flex-wrap:wrap;gap:var(--sp-3);margin-bottom:var(--sp-8)}.hero-trust{display:flex;flex-wrap:wrap;gap:var(--sp-4) var(--sp-6);color:var(--muted);font-size:var(--fs-small)}.hero-trust li{position:relative;padding-left:1.25rem}.hero-trust li::before{content:"";position:absolute;left:0;top:0.45em;width:10px;height:10px;border-radius:50%;background:var(--gold);box-shadow:0 0 0 3px var(--gold-tint)}.hero-visual{position:relative;display:flex;justify-content:center;align-items:center;min-height:420px}.hero-glow{position:absolute;inset:10% 10%;background:radial-gradient(closest-side,var(--saffron-tint),transparent 70%);filter:blur(40px);z-index:-1}@media(min-width:900px){.hero{padding:var(--sp-24) 0}.hero-grid{grid-template-columns:1.1fr 0.9fr;gap:var(--sp-16)}.hero-visual{min-height:560px}}.phone{position:relative;width:260px;aspect-ratio:9/19.5;border-radius:var(--r-phone);background:#111;padding:10px;box-shadow:var(--shadow-3);transform:rotate(-2deg)}.phone-hero{width:280px}.phone::before,.phone::after{content:"";position:absolute;left:50%;transform:translateX(-50%)}.phone::before{top:8px;width:40%;height:18px;background:#000;border-radius:999px}.phone-screen{width:100%;height:100%;border-radius:calc(var(--r-phone) - 10px);overflow:hidden;position:relative}.placeholder-tint{background:linear-gradient(135deg,var(--saffron-tint),var(--gold-tint) 55%,var(--cream-2)),var(--cream-2);display:flex;align-items:center;justify-content:center}.placeholder-tint::after{content:"ຂ";font-family:var(--font-lao);font-size:5rem;color:rgba(200,87,63,0.25);position:absolute;inset:auto 0 10% 0;text-align:center;pointer-events:none}.placeholder-label{position:relative;z-index:1;text-align:center;padding:1rem;color:var(--ink-soft);font-size:0.875rem;line-height:1.35}.placeholder-label strong{display:block;font-family:var(--font-display);font-size:1.25rem;font-weight:600;margin-bottom:0.25rem;color:var(--saffron-dark)}.why{padding:var(--sp-16) 0;border-top:1px solid var(--line)}.why .section-h{max-width:26ch}.features{padding:var(--sp-16) 0;background:var(--cream-2)}.feature-grid{display:grid;grid-template-columns:1fr;gap:var(--sp-6);margin-top:var(--sp-12)}@media(min-width:640px){.feature-grid{grid-template-columns:repeat(2,1fr)}}@media(min-width:960px){.feature-grid{grid-template-columns:repeat(3,1fr)}}.feature{background:#fff;padding:var(--sp-8);border-radius:var(--r-lg);border:1px solid var(--line);transition:transform .2s ease,box-shadow .2s ease}.feature:hover{transform:translateY(-2px);box-shadow:var(--shadow-2)}.feature-icon{display:inline-flex;align-items:center;justify-content:center;width:48px;height:48px;border-radius:14px;background:var(--saffron-tint);color:var(--saffron-dark);margin-bottom:var(--sp-4)}.feature h3{font-family:var(--font-display);font-size:1.35rem;font-weight:600;margin-bottom:var(--sp-2)}.feature p{color:var(--muted);line-height:1.55}.demo{padding:var(--sp-16) 0}.demo-card{position:relative;max-width:960px;margin:0 auto;border-radius:var(--r-xl);overflow:hidden;aspect-ratio:16/9;box-shadow:var(--shadow-3);background:var(--ink)}.demo-thumb{position:absolute;inset:0;width:100%;height:100%;display:flex;align-items:center;justify-content:center;cursor:pointer;color:#fff;text-align:center;padding:var(--sp-4)}.demo-thumb-bg{position:absolute;inset:0;background:linear-gradient(135deg,rgba(200,87,63,0.65),rgba(30,58,58,0.8)),var(--cream-2)}.demo-play{position:relative;z-index:1;display:inline-flex;align-items:center;justify-content:center;width:84px;height:84px;border-radius:50%;background:rgba(255,255,255,0.95);color:var(--saffron);box-shadow:0 20px 40px rgba(0,0,0,0.3);transition:transform .2s ease}.demo-thumb:hover .demo-play{transform:scale(1.05)}.demo-caption{position:absolute;left:0;right:0;bottom:var(--sp-8);display:flex;flex-direction:column;gap:0.25rem;color:#fff;z-index:1}.demo-caption strong{font-family:var(--font-display);font-size:1.25rem;font-weight:600}.demo-caption span{color:rgba(255,255,255,0.8);font-size:0.95rem}.screenshots{padding:var(--sp-16) 0;background:radial-gradient(60% 40% at 50% 0%,var(--gold-tint),transparent 70%),var(--cream)}.shot-reel{margin-top:var(--sp-12);display:flex;gap:var(--sp-6);overflow-x:auto;scroll-snap-type:x mandatory;padding:var(--sp-4) var(--sp-6) var(--sp-12);margin-left:calc(var(--sp-6) * -1);margin-right:calc(var(--sp-6) * -1);scrollbar-width:none}.shot-reel::-webkit-scrollbar{display:none}.shot{flex:0 0 auto;width:240px;margin:0;scroll-snap-align:center;display:flex;flex-direction:column;align-items:center;gap:var(--sp-4)}.shot .phone{transform:rotate(0);width:240px}.shot figcaption{color:var(--muted);font-size:0.9375rem;text-align:center;max-width:22ch}@media(min-width:1100px){.shot-reel{justify-content:center;overflow-x:visible;padding-bottom:var(--sp-4)}}.social-proof{padding:var(--sp-16) 0;background:var(--cream-2)}.quote-grid{display:grid;gap:var(--sp-6);grid-template-columns:1fr}@media(min-width:800px){.quote-grid{grid-template-columns:1fr 1fr}}.quote{margin:0;background:#fff;padding:var(--sp-8);border-radius:var(--r-lg);border:1px solid var(--line);position:relative}.quote::before{content:"\\201C";position:absolute;top:-0.25rem;left:1rem;font-family:var(--font-display);font-size:4rem;color:var(--gold);line-height:1}.quote p{font-family:var(--font-display);font-size:1.125rem;font-weight:500;line-height:1.5;color:var(--ink-soft);margin-bottom:var(--sp-4)}.quote cite{font-style:normal;color:var(--muted);font-size:var(--fs-small)}.ratings{display:flex;flex-wrap:wrap;gap:var(--sp-6);justify-content:center;margin-top:var(--sp-12);color:var(--muted)}.stars{color:var(--gold);letter-spacing:2px}.rating-label em{font-style:normal;color:var(--saffron);font-weight:600}.pricing{padding:var(--sp-16) 0}.pricing-card{max-width:780px;margin:0 auto;background:#fff;border:1px solid var(--line);border-radius:var(--r-xl);padding:var(--sp-12) var(--sp-8);box-shadow:var(--shadow-1);text-align:center}.pricing-card h2{font-size:var(--fs-h2);margin-bottom:var(--sp-8)}.price-rows{display:flex;flex-direction:column;gap:var(--sp-6);margin-bottom:var(--sp-8)}.price-row{display:flex;flex-direction:column;gap:var(--sp-2);padding:var(--sp-6);border:1px solid var(--line);border-radius:var(--r-md);text-align:left;background:var(--cream)}@media(min-width:640px){.price-row{flex-direction:row;justify-content:space-between;align-items:center;gap:var(--sp-6)}}.price-row h3{font-family:var(--font-display);font-size:1.2rem;font-weight:600;margin-bottom:0.25rem}.price-row p{color:var(--muted);font-size:var(--fs-small)}.price{font-family:var(--font-display);font-size:1.75rem;font-weight:600;color:var(--saffron);white-space:nowrap}.price strong{font-weight:700}.price span{display:block;font-family:var(--font-body);font-size:0.8125rem;color:var(--muted);font-weight:400;margin-top:0.1rem}.fine-print{color:var(--muted);font-size:var(--fs-small);max-width:56ch;margin:0 auto;line-height:1.55}.download{padding:var(--sp-16) 0;background:var(--teal);color:#fff}.download .section-h{color:#fff}.download .section-sub{color:rgba(255,255,255,0.75)}.download-grid{margin-top:var(--sp-12);display:grid;grid-template-columns:1fr;gap:var(--sp-3)}@media(min-width:560px){.download-grid{grid-template-columns:1fr 1fr}}@media(min-width:960px){.download-grid{grid-template-columns:repeat(5,1fr);gap:var(--sp-4)}}.dl-btn{display:flex;align-items:center;gap:0.75rem;padding:0.9rem 1.1rem;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.14);border-radius:var(--r-md);color:#fff;transition:background-color .15s ease,transform .15s ease,border-color .15s ease}.dl-btn:hover{background:rgba(255,255,255,0.12);border-color:rgba(255,255,255,0.3);transform:translateY(-1px)}.dl-btn svg{flex-shrink:0}.dl-text{display:flex;flex-direction:column;line-height:1.2;text-align:left}.dl-text small{font-size:0.6875rem;opacity:0.75;text-transform:uppercase;letter-spacing:0.08em}.dl-text strong{font-size:1rem;font-weight:600}.install-note{margin-top:var(--sp-8);color:rgba(255,255,255,0.6);font-size:var(--fs-small);text-align:center;max-width:52ch;margin-left:auto;margin-right:auto}.faq{padding:var(--sp-16) 0}.faq .section-h{margin-bottom:var(--sp-12)}.faq details{border-bottom:1px solid var(--line);padding:var(--sp-4) 0}.faq details[open] summary{color:var(--saffron)}.faq summary{list-style:none;cursor:pointer;font-family:var(--font-display);font-size:1.125rem;font-weight:600;padding:var(--sp-2) 0;display:flex;justify-content:space-between;align-items:center;gap:var(--sp-4);transition:color .15s ease}.faq summary::-webkit-details-marker{display:none}.faq summary::after{content:"+";font-size:1.5rem;font-weight:300;color:var(--saffron);transition:transform .2s ease}.faq details[open] summary::after{transform:rotate(45deg)}.faq details p{color:var(--muted);line-height:1.65;padding:var(--sp-2) 0 var(--sp-4);max-width:66ch}.final-cta{padding:var(--sp-24) 0;background:radial-gradient(80% 60% at 50% 0%,var(--saffron-tint),transparent 70%),var(--cream);text-align:center}.final-cta h2{font-size:var(--fs-display-lg);margin-bottom:var(--sp-4)}.final-cta p{color:var(--muted);font-size:var(--fs-lede);max-width:48ch;margin:0 auto var(--sp-8)}.site-footer{background:var(--ink);color:rgba(255,255,255,0.75);padding:var(--sp-16) 0 var(--sp-8)}.footer-inner{display:flex;flex-direction:column;gap:var(--sp-6);margin-bottom:var(--sp-8)}@media(min-width:760px){.footer-inner{flex-direction:row;justify-content:space-between;align-items:flex-start}}.site-footer .brand{color:#fff}.site-footer .brand-mark{color:var(--gold)}.footer-tag{color:rgba(255,255,255,0.6);font-size:var(--fs-small);margin-top:var(--sp-2)}.footer-nav{display:flex;flex-wrap:wrap;gap:var(--sp-4) var(--sp-6);font-size:var(--fs-small)}.footer-nav a:hover{color:#fff}.footer-bottom{border-top:1px solid rgba(255,255,255,0.08);padding-top:var(--sp-6);color:rgba(255,255,255,0.4);font-size:0.8125rem}.video-modal{position:fixed;inset:0;z-index:100;display:flex;align-items:center;justify-content:center;padding:var(--sp-4)}.video-modal[hidden]{display:none}.video-modal-backdrop{position:absolute;inset:0;background:rgba(26,21,17,0.85);backdrop-filter:blur(6px);-webkit-backdrop-filter:blur(6px);animation:fade-in .2s ease forwards}.video-modal-panel{position:relative;width:100%;max-width:1000px;border-radius:var(--r-lg);background:#000;box-shadow:var(--shadow-3);overflow:hidden;animation:lift-in .25s ease forwards}.video-close{position:absolute;top:0.75rem;right:0.75rem;z-index:2;width:40px;height:40px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;background:rgba(0,0,0,0.7);color:#fff;border:1px solid rgba(255,255,255,0.2)}.video-close:hover{background:rgba(0,0,0,0.9)}.video-embed{aspect-ratio:16/9;width:100%}.video-embed iframe{width:100%;height:100%;border:0}@keyframes fade-in{from{opacity:0}to{opacity:1}}@keyframes lift-in{from{opacity:0;transform:translateY(10px) scale(0.98)}to{opacity:1;transform:translateY(0) scale(1)}}@media(prefers-reduced-motion:reduce){*,*::before,*::after{animation-duration:0.01ms!important;animation-iteration-count:1!important;transition-duration:0.01ms!important;scroll-behavior:auto!important}}`;

// JS embedded as string for worker
export const landingPageJS = `const YOUTUBE_ID = "M_bXTZhfl3I";
(function headerShadow() {
  const header = document.getElementById("site-header");
  if (!header) return;
  const onScroll = () => { header.classList.toggle("is-scrolled", window.scrollY > 8); };
  onScroll();
  window.addEventListener("scroll", onScroll, { passive: true });
})();
(function videoModal() {
  const modal = document.getElementById("video-modal");
  if (!modal) return;
  const embed = modal.querySelector(".video-embed");
  const opens = document.querySelectorAll("[data-open-video]");
  const closes = modal.querySelectorAll("[data-close-video]");
  let lastFocused = null;
  function open() {
    lastFocused = document.activeElement;
    // Use regular youtube.com for shorts
    const src = \`https://www.youtube.com/embed/\${YOUTUBE_ID}?autoplay=1&rel=0&modestbranding=1\`;
    embed.innerHTML = \`<iframe src="\${src}" title="Write Lao demo" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen referrerpolicy="strict-origin-when-cross-origin"></iframe>\`;
    modal.hidden = false;
    document.documentElement.style.overflow = "hidden";
    const closeBtn = modal.querySelector(".video-close");
    if (closeBtn) closeBtn.focus();
  }
  function close() {
    modal.hidden = true;
    embed.innerHTML = "";
    document.documentElement.style.overflow = "";
    if (lastFocused && typeof lastFocused.focus === "function") { lastFocused.focus(); }
  }
  opens.forEach((el) => el.addEventListener("click", (e) => { e.preventDefault(); open(); }));
  closes.forEach((el) => el.addEventListener("click", close));
  document.addEventListener("keydown", (e) => { if (e.key === "Escape" && !modal.hidden) close(); });
})();
(function footerYear() {
  const y = document.getElementById("year");
  if (y) y.textContent = new Date().getFullYear();
})();`;

// HTML template as string
export const landingPageHTML = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
  <meta name="theme-color" content="#C8573F" />
  <meta name="description" content="Write Lao — stroke-by-stroke handwriting practice for the full Lao alphabet, plus 500 essential words with native audio and spaced repetition. Works offline on every device." />
  <title>Write Lao — Master Lao, one stroke at a time.</title>
  <meta property="og:title" content="Write Lao — Master Lao, one stroke at a time." />
  <meta property="og:description" content="Stroke-by-stroke handwriting practice for the full Lao alphabet. Plus 500 essential words with native audio and smart review." />
  <meta property="og:image" content="/assets/og-image.png" />
  <meta property="og:type" content="website" />
  <meta name="twitter:card" content="summary_large_image" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,700&family=Inter:wght@400;500;600;700&family=Noto+Sans+Lao:wght@500;700&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="/styles.css" />
  
  <!-- Favicon -->
  <link rel="icon" type="image/png" sizes="32x32" href="/icons/favicon-32.png" />
  <link rel="icon" type="image/png" sizes="16x16" href="/icons/favicon-16.png" />
  
  <!-- Apple Touch Icon -->
  <link rel="apple-touch-icon" href="/icons/apple-touch-icon.png" />
  
  <!-- Android Chrome -->
  <link rel="icon" type="image/png" sizes="192x192" href="/icons/android-chrome-192x192.png" />
  <link rel="icon" type="image/png" sizes="512x512" href="/icons/android-chrome-512x512.png" />
  
  <!-- Safari Pinned Tab -->
  <link rel="mask-icon" href="/icons/favicon.svg" color="#C8573F" />
</head>
<body>
  <a class="skip-link" href="#main">Skip to content</a>

  <header class="site-header" id="site-header">
    <div class="container header-inner">
      <a href="#top" class="brand" aria-label="Write Lao — home">
        <img class="brand-mark" src="/icons/apple-touch-icon.png" alt="Write Lao" width="32" height="32" />
        <span class="brand-name">Write Lao</span>
      </a>
      <nav class="nav" aria-label="Primary">
        <a href="#features" data-i18n="nav.features">Features</a>
        <a href="#demo" data-i18n="nav.demo">Demo</a>
        <a href="#pricing" data-i18n="nav.pricing">Pricing</a>
        <a href="#faq" data-i18n="nav.faq">FAQ</a>
      </nav>
      <a href="#download" class="btn btn-primary btn-sm nav-cta" data-i18n="nav.get_app">Get the app</a>
    </div>
  </header>

  <main id="main">
    <section class="hero" id="top">
      <div class="container hero-grid">
        <div class="hero-copy">
          <p class="eyebrow" data-i18n="hero.eyebrow">A handwriting-first Lao course</p>
          <h1 class="display" data-i18n-html="hero.headline">
            Master Lao,<br />
            <span class="ink">one stroke</span> at a time.
          </h1>
          <p class="lede" data-i18n="hero.lede">
            Guided stroke-by-stroke practice for all 58 Lao characters —
            plus 500 essential words with native audio and spaced repetition.
            Built for daily progress, on every device you own.
          </p>
          <div class="hero-ctas">
            <a href="#download" class="btn btn-primary btn-lg" data-i18n="hero.download">
              Download — it's free
            </a>
            <a href="https://www.youtube.com/shorts/M_bXTZhfl3I" target="_blank" rel="noopener noreferrer" class="btn btn-ghost btn-lg" data-i18n="hero.watch">
              <svg aria-hidden="true" viewBox="0 0 24 24" width="20" height="20"><path fill="currentColor" d="M8 5v14l11-7z"/></svg>
              Watch the 2-min demo
            </a>
          </div>
          <ul class="hero-trust">
            <li data-i18n="hero.trust1">Free alphabet course</li>
            <li data-i18n="hero.trust2">One-time unlock, no subscription</li>
            <li data-i18n="hero.trust3">Works offline · No account</li>
          </ul>
        </div>

        <div class="hero-visual" aria-hidden="true">
          <div class="phone phone-hero">
            <div class="phone-screen">
              <img src="/assets/hero-screenshot.png" alt="Write Lao writing canvas" style="width:100%;height:100%;object-fit:cover;border-radius:calc(var(--r-phone) - 10px);" />
            </div>
          </div>
          <div class="hero-glow"></div>
        </div>
      </div>
    </section>

    <section class="why">
      <div class="container">
        <h2 class="section-h display" data-i18n="why.title">
          Most apps teach you to <em>recognize</em> Lao.<br />
          We teach your <span class="ink">hand to write it.</span>
        </h2>
        <p class="section-sub" data-i18n="why.subtitle">
          Reading a script is one thing. Writing it builds the muscle memory
          that makes a new language stick — and Lao script is written one
          stroke at a time, in a specific order, for a reason. Write Lao
          guides every stroke, so you're not just tracing. You're learning
          the way Lao kids do in school.
        </p>
      </div>
    </section>

    <section class="features" id="features">
      <div class="container">
        <h2 class="section-h display" data-i18n="features.title">Everything you need, nothing you don't.</h2>

        <div class="feature-grid">
          <article class="feature">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="m3 21 3-1 13-13-2-2L4 18l-1 3z"/><path d="m14 6 4 4"/></svg>
            </div>
            <h3 data-i18n="features.stroke.title">Stroke-by-stroke guidance</h3>
            <p data-i18n="features.stroke.desc">Every character broken into ordered strokes with live direction hints. Draw it right, earn your stars, move on.</p>
          </article>

          <article class="feature">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
            </div>
            <h3 data-i18n="features.vocab.title">500 essential words</h3>
            <p data-i18n="features.vocab.desc">The vocabulary that actually appears in everyday Lao conversation. Curated, categorized, and taught in the order that makes them stick.</p>
          </article>

          <article class="feature">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
            <h3 data-i18n="features.spaced.title">Spaced repetition</h3>
            <p data-i18n="features.spaced.desc">Reviews surface the moment you're about to forget. Twenty minutes a day is enough to lock a word in for life.</p>
          </article>

          <article class="feature">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5 6 9H2v6h4l5 4z"/><path d="M15.5 8.5a5 5 0 0 1 0 7"/><path d="M19 5a9 9 0 0 1 0 14"/></svg>
            </div>
            <h3 data-i18n="features.audio.title">Native audio</h3>
            <p data-i18n="features.audio.desc">Every word and example sentence voiced by a native speaker. Hear the tones — don't just read about them.</p>
          </article>

          <article class="feature">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="14" height="16" rx="2"/><rect x="14" y="9" width="7" height="11" rx="1.5"/><line x1="10" y1="17" x2="10" y2="17.01"/></svg>
            </div>
            <h3 data-i18n="features.offline.title">Works everywhere</h3>
            <p data-i18n="features.offline.desc">iPhone, Android, Mac, Windows, Linux. Learn on the couch, review on the train, practice at your desk.</p>
          </article>

          <article class="feature">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            </div>
            <h3 data-i18n="features.privacy.title">No account. No cloud. No ads.</h3>
            <p data-i18n="features.privacy.desc">Everything runs on your device. Your progress never leaves. One tiny purchase, forever.</p>
          </article>
        </div>
      </div>
    </section>

    <section class="demo" id="demo">
      <div class="container">
        <div class="demo-card" style="aspect-ratio: 9/16; max-height: 500px;">
          <button type="button" class="demo-thumb" data-open-video aria-label="Play the Write Lao demo video" style="background: #000;">
            <img src="/assets/thumbnail.png" alt="Video thumbnail" style="width:100%;height:100%;object-fit:cover;" />
            <span class="demo-play" aria-hidden="true" style="position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);z-index:1;">
              <svg viewBox="0 0 24 24" width="48" height="48" fill="currentColor" style="filter:drop-shadow(0 2px 8px rgba(0,0,0,0.5));"><path d="M8 5v14l11-7z"/></svg>
            </span>
            <span class="demo-caption" style="bottom: 1.5rem;">
              <strong data-i18n="demo.caption1">See it in 2 minutes</strong>
              <span data-i18n="demo.caption2">From your first stroke to your first 10 words.</span>
            </span>
          </button>
        </div>
      </div>
    </section>

    <section class="screenshots" id="screenshots">
      <div class="container">
        <h2 class="section-h display" data-i18n="screenshots.title">A gentler way to practice.</h2>
        <p class="section-sub" data-i18n="screenshots.subtitle">
          Calm, focused screens designed for daily ten-minute sessions.
          No streak guilt. No confetti explosions. Just the next stroke.
        </p>

        <div class="shot-reel" role="list">
          <figure class="shot" role="listitem">
            <div class="phone">
              <div class="phone-screen">
                <img src="/assets/shot-01.png" alt="Alphabet lessons" style="width:100%;height:100%;object-fit:cover;" />
              </div>
            </div>
            <figcaption data-i18n="screenshots.fig1">Structured path through all 58 characters.</figcaption>
          </figure>

          <figure class="shot" role="listitem">
            <div class="phone">
              <div class="phone-screen">
                <img src="/assets/shot-02.png" alt="Video lesson" style="width:100%;height:100%;object-fit:cover;" />
              </div>
            </div>
            <figcaption>Live stroke guidance with forgiving scoring.</figcaption>
          </figure>

          <figure class="shot" role="listitem">
            <div class="phone">
              <div class="phone-screen">
                <img src="/assets/shot-03.png" alt="Writing canvas" style="width:100%;height:100%;object-fit:cover;" />
              </div>
            </div>
            <figcaption>New word, native audio, example sentence, picture.</figcaption>
          </figure>

          <figure class="shot" role="listitem">
            <div class="phone">
              <div class="phone-screen">
                <img src="/assets/shot-04.png" alt="Spaced review" style="width:100%;height:100%;object-fit:cover;" />
              </div>
            </div>
            <figcaption>Only the words you're about to forget, surfaced daily.</figcaption>
          </figure>
        </div>
      </div>
    </section>

    <section class="social-proof">
      <div class="container">
        <div class="quote-grid">
          <blockquote class="quote">
            <p>"PLACEHOLDER — drop a real review or two here once the app is live. Something specific: what they were stuck on, what clicked, how many weeks in."</p>
            <footer><cite>— First name · City</cite></footer>
          </blockquote>
          <blockquote class="quote">
            <p>"PLACEHOLDER — a second testimonial, ideally from someone with a different goal (traveler vs. heritage learner vs. language nerd)."</p>
            <footer><cite>— First name · City</cite></footer>
          </blockquote>
        </div>
        <div class="ratings">
          <div class="rating">
            <span class="stars" aria-hidden="true">★★★★★</span>
            <span class="rating-label">App Store · <em>coming soon</em></span>
          </div>
          <div class="rating">
            <span class="stars" aria-hidden="true">★★★★★</span>
            <span class="rating-label">Google Play · <em>coming soon</em></span>
          </div>
        </div>
      </div>
    </section>

    <section class="pricing" id="pricing">
      <div class="container">
        <div class="pricing-card">
          <h2 class="display" data-i18n="pricing.title">One app. Two courses. One price.</h2>
          <div class="price-rows">
            <div class="price-row">
              <div>
                <h3 data-i18n="pricing.alphabet.title">The Lao alphabet</h3>
                <p data-i18n="pricing.alphabet.desc">All 58 characters · 21 lessons · stroke-by-stroke practice.</p>
              </div>
              <div class="price"><span data-i18n="pricing.free">Free</span> <span data-i18n="pricing.forever">forever</span></div>
            </div>
            <div class="price-row">
              <div>
                <h3 data-i18n="pricing.vocab.title">The 500-word vocabulary course</h3>
                <p data-i18n="pricing.vocab.desc">Curated words · native audio · spaced repetition · unlock forever.</p>
              </div>
              <div class="price"><strong data-i18n="pricing.price">$0.99</strong> <span data-i18n="pricing.one_time">one-time</span></div>
            </div>
          </div>
          <p class="fine-print" data-i18n="pricing.fine_print">
            No subscriptions. No ads. Try the first lesson free — pay only if
            you want the full 500 words. Purchase restores across devices on
            the same app store account.
          </p>
        </div>
      </div>
    </section>

    <section class="download" id="download">
      <div class="container">
        <h2 class="section-h display" data-i18n="download.title">Get Write Lao</h2>
        <p class="section-sub" data-i18n="download.subtitle">Pick your platform. Every version is the same app, fully featured, fully offline.</p>

        <div class="download-grid">
          <a class="dl-btn" href="#" data-platform="ios" aria-label="Download for iPhone and iPad">
            <svg viewBox="0 0 24 24" width="28" height="28" fill="currentColor" aria-hidden="true"><path d="M16.365 1.43c0 1.14-.48 2.23-1.27 3.04-.9.91-2.36 1.62-3.6 1.53-.16-1.18.45-2.39 1.22-3.19.87-.89 2.44-1.54 3.65-1.38zm4.36 16.4c-.58 1.31-1.22 2.62-2.31 4.17-.97 1.37-1.74 2.3-3.12 2.32-1.3 0-1.73-.78-3.25-.77-1.53 0-2 .76-3.23.79-1.34.04-2.21-1.1-3.17-2.47-2.02-2.8-3.56-7.92-1.49-11.38 1.02-1.72 2.85-2.8 4.83-2.83 1.31-.02 2.55.88 3.35.88.8 0 2.32-1.09 3.91-.93.67.03 2.53.27 3.73 2.01-.1.06-2.24 1.32-2.22 3.93.03 3.12 2.74 4.15 2.77 4.17-.02.06-.4 1.38-1.33 2.93z"/></svg>
            <span class="dl-text"><small data-i18n="download.ios.small">Download on the</small><strong data-i18n="download.ios">App Store</strong></span>
          </a>

          <a class="dl-btn" href="#" data-platform="android" aria-label="Get it on Google Play">
            <svg viewBox="0 0 24 24" width="28" height="28" fill="currentColor" aria-hidden="true"><path d="M3.6 1.98C3.23 2.28 3 2.82 3 3.52v16.96c0 .7.23 1.24.6 1.54l.08.06L13 12.08v-.17L3.68 1.92l-.08.06zm10.72 11.22L4.55 22.9l.01.01c.55.32 1.28.28 2.06-.16l10.63-6.04-2.93-3.51zm6.79-5.93L17.4 5.22 6.56 11.3l7.75 7.76 3.82-2.17c.92-.52 1.46-1.29 1.46-2.07 0-.78-.54-1.56-1.46-2.08-.44-.25-4.32-2.46-4.32-2.46z"/></svg>
            <span class="dl-text"><small data-i18n="download.android.small">Get it on</small><strong data-i18n="download.android">Google Play</strong></span>
          </a>

          <a class="dl-btn" href="#" data-platform="mac" aria-label="Download for macOS">
            <svg viewBox="0 0 24 24" width="28" height="28" fill="currentColor" aria-hidden="true"><path d="M16.365 1.43c0 1.14-.48 2.23-1.27 3.04-.9.91-2.36 1.62-3.6 1.53-.16-1.18.45-2.39 1.22-3.19.87-.89 2.44-1.54 3.65-1.38zm4.36 16.4c-.58 1.31-1.22 2.62-2.31 4.17-.97 1.37-1.74 2.3-3.12 2.32-1.3 0-1.73-.78-3.25-.77-1.53 0-2 .76-3.23.79-1.34.04-2.21-1.1-3.17-2.47-2.02-2.8-3.56-7.92-1.49-11.38 1.02-1.72 2.85-2.8 4.83-2.83 1.31-.02 2.55.88 3.35.88.8 0 2.32-1.09 3.91-.93.67.03 2.53.27 3.73 2.01-.1.06-2.24 1.32-2.22 3.93.03 3.12 2.74 4.15 2.77 4.17-.02.06-.4 1.38-1.33 2.93z"/></svg>
            <span class="dl-text"><small data-i18n="download.mac.small">Download for</small><strong data-i18n="download.mac">macOS</strong></span>
          </a>

          <a class="dl-btn" href="#" data-platform="windows" aria-label="Download for Windows">
            <svg viewBox="0 0 24 24" width="28" height="28" fill="currentColor" aria-hidden="true"><path d="M3 5.5 11 4v7.5H3V5.5zm0 8h8V21l-8-1.4v-6.1zm9-9.6L22 2v9.5H12V3.9zM12 12.5h10V22l-10-1.6v-7.9z"/></svg>
            <span class="dl-text"><small data-i18n="download.windows.small">Download for</small><strong data-i18n="download.windows">Windows</strong></span>
          </a>

          <a class="dl-btn" href="#" data-platform="linux" aria-label="Download for Linux">
            <svg viewBox="0 0 24 24" width="28" height="28" fill="currentColor" aria-hidden="true"><path d="M12 2c-2.3 0-4 2.4-4 5.5 0 1.3.3 2.5.9 3.5-.6.6-1.2 1.2-1.8 1.9-1.3 1.6-2.6 3.5-2.6 5.6 0 1 .5 1.8 1.4 2.2.3.2.6.4.8.7.2.3.2.6.2.9 0 .5.4.7.8.7h8.6c.4 0 .8-.2.8-.7 0-.3 0-.6.2-.9.2-.3.5-.5.8-.7.9-.4 1.4-1.2 1.4-2.2 0-2.1-1.3-4-2.6-5.6-.6-.7-1.2-1.3-1.8-1.9.6-1 .9-2.2.9-3.5C16 4.4 14.3 2 12 2zm-1.5 4.5c.4 0 .7.5.7 1s-.3 1-.7 1-.7-.5-.7-1 .3-1 .7-1zm3 0c.4 0 .7.5.7 1s-.3 1-.7 1-.7-.5-.7-1 .3-1 .7-1zM12 10c.9 0 1.8.3 2.5.8-.7.9-1.6 1.5-2.5 1.5s-1.8-.6-2.5-1.5c.7-.5 1.6-.8 2.5-.8z"/></svg>
            <span class="dl-text"><small data-i18n="download.linux.small">Download for</small><strong data-i18n="download.linux">Linux</strong></span>
          </a>
        </div>

        <p class="install-note" data-i18n="download.note">
          On a mobile device? The store button launches the right app.
          On desktop? Pick your OS and download the installer.
        </p>
      </div>
    </section>

    <section class="faq" id="faq">
      <div class="container">
        <h2 class="section-h display" data-i18n="faq.title">Questions people ask.</h2>

        <details>
          <summary data-i18n="faq.q1.title">Do I need to know any Lao already?</summary>
          <p data-i18n="faq.q1.answer">No. The alphabet course starts from zero — every character, every sound, every stroke. The 500-word course builds on the alphabet, so there's no prerequisite beyond finishing (or previewing) the first lessons.</p>
        </details>

        <details>
          <summary data-i18n="faq.q2.title">Does it work offline?</summary>
          <p data-i18n="faq.q2.answer">Yes, fully. Once the app is installed, everything — lessons, audio, your progress — runs on your device. No internet needed after download. No account to create.</p>
        </details>

        <details>
          <summary data-i18n="faq.q3.title">Will my progress sync between devices?</summary>
          <p data-i18n="faq.q3.answer">By design, no. Your learning data never leaves your device. We treat this as a privacy feature, not a limitation: there's no account to get hacked, no server to outlive us. The IAP entitlement does follow your app store account, so purchasing once on iPhone unlocks iPad automatically.</p>
        </details>

        <details>
          <summary data-i18n="faq.q4.title">Is the audio actually from a native speaker?</summary>
          <p data-i18n="faq.q4.answer">Yes. Every headword and example sentence in the 500-word course is recorded by a native Lao speaker. You'll hear the real tones, not synthesized approximations.</p>
        </details>

        <details>
          <summary data-i18n="faq.q5.title">How long until I see real progress?</summary>
          <p data-i18n="faq.q5.answer">Ten minutes a day for two weeks is enough to write most of the alphabet from memory. The 500-word course is paced for daily sessions — you'll add 3 to 5 new words a day and review older ones via spaced repetition. Most learners hit 100 mastered words in a month.</p>
        </details>

        <details>
          <summary data-i18n="faq.q6.title">Why is the 500-word course a paid upgrade?</summary>
          <p data-i18n="faq.q6.answer">Because curating, recording, and tagging 500 words (plus 1,000+ example sentences with audio) is real work. The alphabet course is free forever so you can see the teaching style before spending anything. If it's not for you, you've lost nothing.</p>
        </details>

        <details>
          <summary data-i18n="faq.q7.title">Can I get a refund?</summary>
          <p data-i18n="faq.q7.answer">Refunds go through your app store (Apple, Google) per their normal policy. On desktop, contact us and we'll sort it out.</p>
        </details>
      </div>
    </section>

    <section class="final-cta">
      <div class="container">
        <h2 class="display" data-i18n="cta.title">Start with your first stroke.</h2>
        <p data-i18n="cta.subtitle">The alphabet course is free. The first vocabulary lesson is free. See for yourself.</p>
        <a href="#download" class="btn btn-primary btn-lg" data-i18n="cta.button">Download Write Lao</a>
      </div>
    </section>
  </main>

  <footer class="site-footer">
    <div class="container footer-inner">
      <div>
        <a href="#top" class="brand">
          <img class="brand-mark" src="/icons/apple-touch-icon.png" alt="Write Lao" width="32" height="32" />
          <span class="brand-name">Write Lao</span>
        </a>
        <p class="footer-tag" data-i18n="footer.tagline">A handwriting-first Lao course.</p>
      </div>
      <nav class="footer-nav" aria-label="Footer">
        <a href="#features" data-i18n="nav.features">Features</a>
        <a href="#pricing" data-i18n="nav.pricing">Pricing</a>
        <a href="#faq" data-i18n="nav.faq">FAQ</a>
        <a href="mailto:help@dharmaprotectors.org">Contact</a>
        <a href="/privacy_policy.html">Privacy</a>
        <a href="/tos.html">Terms</a>
      </nav>
    </div>
    <div class="container footer-bottom">
      <small data-i18n="footer.copyright">© <span id="year">2026</span> Write Lao. Made with care for learners of Lao.</small>
    </div>
  </footer>

  <div class="video-modal" id="video-modal" role="dialog" aria-modal="true" aria-labelledby="video-modal-title" hidden>
    <div class="video-modal-backdrop" data-close-video></div>
    <div class="video-modal-panel">
      <button type="button" class="video-close" data-close-video aria-label="Close video">
        <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
      <h2 id="video-modal-title" class="visually-hidden">Write Lao demo video</h2>
      <div class="video-embed"></div>
    </div>
  </div>

  <script src="/script.js" defer></script>
</body>
</html>`;

// i18n script - loads translations lazily based on browser locale
export const i18nScript = `
/**
 * i18n Script for Write Lao Landing Page
 * 
 * This script detects the browser locale and loads translations only if needed.
 * The page defaults to English, and translations are applied lazily.
 */

// Supported locales
const SUPPORTED_LOCALES = ['lo', 'zh', 'th', 'vi', 'ja', 'ko', 'fr', 'de', 'es', 'ru', 'id', 'ms'];

// Get the best matching locale from browser
function getBrowserLocale() {
  if (typeof navigator === 'undefined') return null;
  
  const languages = navigator.languages || [navigator.language || ''];
  
  for (const lang of languages) {
    const normalized = lang.toLowerCase().split('-')[0].trim();
    
    // Check exact match
    if (SUPPORTED_LOCALES.includes(normalized)) {
      return normalized;
    }
    
    // Check partial match (e.g., 'zh-cn' -> 'zh')
    for (const supported of SUPPORTED_LOCALES) {
      if (normalized.startsWith(supported) || supported.startsWith(normalized)) {
        return supported;
      }
    }
  }
  return null;
}

// Apply translations to the page
function applyTranslations(trans) {
  // Handle plain text translations
  const elements = document.querySelectorAll('[data-i18n]');
  elements.forEach((el) => {
    const key = el.getAttribute('data-i18n');
    if (key && trans[key]) {
      el.textContent = trans[key];
    }
  });
  
  // Handle HTML translations (use innerHTML for elements with HTML content)
  const htmlElements = document.querySelectorAll('[data-i18n-html]');
  htmlElements.forEach((el) => {
    const key = el.getAttribute('data-i18n-html');
    if (key && trans[key]) {
      el.innerHTML = trans[key];
    }
  });
  
  // Also handle placeholders
  const placeholders = document.querySelectorAll('[data-i18n-placeholder]');
  placeholders.forEach((el) => {
    const key = el.getAttribute('data-i18n-placeholder');
    if (key && trans[key] && el instanceof HTMLInputElement) {
      el.placeholder = trans[key];
    }
  });
}

// Initialize i18n
async function initI18n() {
  const locale = getBrowserLocale();
  
  // Only load translations if non-English locale detected
  if (locale) {
    try {
      const response = await fetch('/i18n/' + locale + '.json');
      if (response.ok) {
        const translations = await response.json();
        applyTranslations(translations);
        
        // Add RTL support for certain languages if needed
        if (locale === 'ar' || locale === 'he') {
          document.documentElement.dir = 'rtl';
        }
      }
    } catch (error) {
      console.warn('Failed to load translations for locale: ' + locale, error);
    }
  }
}

// Start initialization when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initI18n);
} else {
  initI18n();
}

// Export for manual triggering if needed
window.writeLaoI18n = {
  getLocale: getBrowserLocale,
  loadLocale: async function(locale) {
    try {
      const response = await fetch('/i18n/' + locale + '.json');
      if (response.ok) {
        const translations = await response.json();
        applyTranslations(translations);
        return true;
      }
    } catch (error) {
      console.warn('Failed to load locale: ' + locale, error);
    }
    return false;
  },
  getTranslations: function() { return window._writelao_translations || {}; }
};
`;
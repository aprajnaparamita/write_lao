/* Write Lao — landing page behavior.
   Zero dependencies. Handles:
   - Sticky header shadow on scroll
   - Video modal (lazy-inserts the YouTube iframe on open,
     removes it on close so nothing loads until the user asks)
   - Current-year footer
*/

// ────────────────────────────────────────────────────────
// CONFIG — replace with the real YouTube video ID before ship.
// Example: if the video URL is https://youtu.be/abc123XYZ_0
// then set YOUTUBE_ID = "abc123XYZ_0".
// ────────────────────────────────────────────────────────
const YOUTUBE_ID = "REPLACE_WITH_YOUTUBE_VIDEO_ID";

// ────────────────────────────────────────────────────────
// Sticky header — add a bottom border once the user scrolls.
// ────────────────────────────────────────────────────────
(function headerShadow() {
  const header = document.getElementById("site-header");
  if (!header) return;
  const onScroll = () => {
    header.classList.toggle("is-scrolled", window.scrollY > 8);
  };
  onScroll();
  window.addEventListener("scroll", onScroll, { passive: true });
})();

// ────────────────────────────────────────────────────────
// Video modal
// ────────────────────────────────────────────────────────
(function videoModal() {
  const modal = document.getElementById("video-modal");
  if (!modal) return;
  const embed = modal.querySelector(".video-embed");
  const opens = document.querySelectorAll("[data-open-video]");
  const closes = modal.querySelectorAll("[data-close-video]");

  let lastFocused = null;

  function open() {
    lastFocused = document.activeElement;
    const src = `https://www.youtube-nocookie.com/embed/${YOUTUBE_ID}?autoplay=1&rel=0&modestbranding=1`;
    embed.innerHTML = `<iframe
        src="${src}"
        title="Write Lao demo"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        allowfullscreen
        referrerpolicy="strict-origin-when-cross-origin"></iframe>`;
    modal.hidden = false;
    document.documentElement.style.overflow = "hidden";
    const closeBtn = modal.querySelector(".video-close");
    if (closeBtn) closeBtn.focus();
  }

  function close() {
    modal.hidden = true;
    embed.innerHTML = ""; // stop playback, free the iframe
    document.documentElement.style.overflow = "";
    if (lastFocused && typeof lastFocused.focus === "function") {
      lastFocused.focus();
    }
  }

  opens.forEach((el) => el.addEventListener("click", (e) => {
    e.preventDefault();
    open();
  }));
  closes.forEach((el) => el.addEventListener("click", close));
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && !modal.hidden) close();
  });
})();

// ────────────────────────────────────────────────────────
// Footer year
// ────────────────────────────────────────────────────────
(function footerYear() {
  const y = document.getElementById("year");
  if (y) y.textContent = new Date().getFullYear();
})();

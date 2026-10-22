/* The campus film keeps its shape and slides down as the visitor scrolls. */
(() => {
  const hero = document.querySelector('.hero-scroll-stage');
  const film = document.querySelector('.hero-film');
  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  if (!hero || !film) return;
  let frame = 0;
  function draw() {
    frame = 0;
    const box = hero.getBoundingClientRect();
    const progress = reduced.matches ? 0 : Math.max(0, Math.min(1, -box.top / Math.max(1, hero.offsetHeight - innerHeight)));
    const smooth = progress * progress * (3 - 2 * progress);
    film.style.setProperty('--film-slide-y', `${smooth * innerHeight * .22}px`);
  }
  function queue() { if (!frame) frame = requestAnimationFrame(draw); }
  addEventListener('scroll', queue, { passive: true }); addEventListener('resize', queue); reduced.addEventListener('change', queue); draw();
})();

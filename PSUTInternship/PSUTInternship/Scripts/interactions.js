/* Pointer dragging keeps clicks intact until a real horizontal drag begins. */
(() => {
  function attach(rail) {
    let drag = null, velocity = 0, frame = 0, suppressClick = false;
    const reduced = matchMedia('(prefers-reduced-motion: reduce)');
    if (rail.classList.contains('experience-facts')) {
      let cardFrame = 0, entered = false, onScreen = false, positioned = false;
      const animations = new Set();
      const updateCards = () => {
        cardFrame = 0;
        // Layout coordinates stay stable while the cards themselves rotate.
        const center = rail.scrollLeft + rail.clientWidth / 2;
        const radius = Math.max(950, rail.clientWidth * 1.45);
        const cards = [...rail.querySelectorAll('.mosaic-card')];
        if (!positioned && cards.length > 1) {
          positioned = true;
          rail.scrollLeft = cards[1].offsetLeft + cards[1].offsetWidth / 2 - rail.clientWidth / 2;
          queueCards();
          return;
        }
        // Recycle an offscreen card at either end, preserving its screen position.
        // Moving the actual nodes keeps a single set of links and database records.
        if (positioned && cards.length > 2) {
          const step = cards[1].offsetLeft - cards[0].offsetLeft;
          const firstCenter = cards[0].offsetLeft + cards[0].offsetWidth / 2 - rail.clientWidth / 2;
          const lastCenter = cards.at(-1).offsetLeft + cards.at(-1).offsetWidth / 2 - rail.clientWidth / 2;
          let shift = 0;
          if (rail.scrollLeft < firstCenter + step * .5 && !cards.at(-1).contains(document.activeElement)) {
            rail.prepend(cards.at(-1));
            shift = step;
          } else if (rail.scrollLeft > lastCenter - step * .5 && !cards[0].contains(document.activeElement)) {
            rail.append(cards[0]);
            shift = -step;
          }
          if (shift) {
            rail.scrollLeft += shift;
            if (drag) drag.scroll += shift;
            queueCards();
            return;
          }
        }
        cards.forEach(card => {
          const distance = card.offsetLeft + card.offsetWidth / 2 - center;
          const angle = Math.asin(Math.max(-.62, Math.min(.62, distance / radius)));
          card.style.setProperty('--card-angle', reduced.matches ? '0deg' : `${angle * 180 / Math.PI}deg`);
          card.style.setProperty('--card-lift', reduced.matches ? '0px' : `${radius * (1 - Math.cos(angle))}px`);
          card.style.setProperty('--card-scale', '1');
          card.style.setProperty('--card-opacity', '1');
        });
        if (onScreen && cards.length && !entered) {
          entered = true;
          if (!reduced.matches) cards.forEach((card, i) => {
            const resting = getComputedStyle(card).transform;
            const angle = parseFloat(card.style.getPropertyValue('--card-angle'));
            const animation = card.animate([
              { transform: `translateY(150px) rotate(${angle * 1.65}deg) scale(.88)`, opacity: .15 },
              { transform: resting, opacity: 1 }
            ], { duration: 950, delay: Math.min(i * 65, 260), easing: 'cubic-bezier(.16,1,.3,1)', fill: 'backwards' });
            animations.add(animation);
            animation.onfinish = () => animations.delete(animation);
          });
        }
      };
      const queueCards = () => { if (!cardFrame) cardFrame = requestAnimationFrame(updateCards); };
      const cancelEntrance = () => { animations.forEach(a => a.cancel()); animations.clear(); };
      rail.addEventListener('pointerdown', cancelEntrance);
      rail.addEventListener('keydown', cancelEntrance);
      rail.addEventListener('scroll', queueCards, { passive: true });
      new IntersectionObserver(entries => {
        onScreen = entries[0].isIntersecting;
        if (onScreen) queueCards();
      }, { threshold: .18 }).observe(rail);
      new MutationObserver(queueCards).observe(rail, { childList: true });
      new ResizeObserver(queueCards).observe(rail);
      reduced.addEventListener('change', () => { cancelEntrance(); queueCards(); });
      queueCards();

      // A decorative cursor never intercepts a click or appears on touch screens.
      const finePointer = matchMedia('(hover: hover) and (pointer: fine)');
      const cursor = document.createElement('div');
      cursor.className = 'opportunity-drag-cursor';
      cursor.textContent = 'Drag';
      cursor.setAttribute('aria-hidden', 'true');
      document.body.append(cursor);
      const hideCursor = () => { cursor.classList.remove('is-visible'); rail.classList.remove('has-drag-cursor'); };
      rail.addEventListener('pointermove', event => {
        if (!finePointer.matches || event.pointerType === 'touch' || event.target.closest('a,button')) { hideCursor(); return; }
        cursor.style.setProperty('--cursor-x', `${event.clientX}px`);
        cursor.style.setProperty('--cursor-y', `${event.clientY}px`);
        cursor.classList.add('is-visible');
        rail.classList.add('has-drag-cursor');
      });
      rail.addEventListener('pointerleave', hideCursor);
      rail.addEventListener('pointerdown', () => cursor.classList.add('is-pressed'));
      window.addEventListener('pointerup', () => cursor.classList.remove('is-pressed'));
      rail.addEventListener('pointercancel', () => { cursor.classList.remove('is-pressed'); hideCursor(); });
      window.addEventListener('blur', hideCursor);
      window.addEventListener('scroll', hideCursor, { passive: true });
      document.addEventListener('visibilitychange', hideCursor);
      finePointer.addEventListener('change', hideCursor);
    }
    function stop() { cancelAnimationFrame(frame); frame = 0; }
    function settle() {
      if (reduced.matches) { rail.classList.remove('is-dragging'); return; }
      const tick = () => {
        const before = rail.scrollLeft;
        rail.scrollLeft += velocity;
        velocity *= .91;
        if (Math.abs(velocity) > .4 && rail.scrollLeft !== before) frame = requestAnimationFrame(tick);
        else { frame = 0; rail.classList.remove('is-dragging'); }
      };
      frame = requestAnimationFrame(tick);
    }
    rail.addEventListener('pointerdown', e => {
      if (e.button !== 0 || e.pointerType === 'touch' || e.target.closest('input,textarea,select,button')) return;
      stop(); rail.classList.remove('is-dragging');
      drag = { id: e.pointerId, x: e.clientX, y: e.clientY, scroll: rail.scrollLeft, lastX: e.clientX, lastTime: performance.now(), moved: false };
      velocity = 0; suppressClick = false;
    });
    rail.addEventListener('pointermove', e => {
      if (!drag || drag.id !== e.pointerId) return;
      const dx = e.clientX - drag.x;
      if (!drag.moved && Math.abs(dx) > 6 && Math.abs(dx) > Math.abs(e.clientY - drag.y)) {
        drag.moved = true; rail.classList.add('is-dragging'); rail.setPointerCapture(e.pointerId);
      }
      if (!drag.moved) return;
      e.preventDefault();
      const now = performance.now(), elapsed = Math.max(1, now - drag.lastTime);
      velocity = Math.max(-45, Math.min(45, (drag.lastX - e.clientX) / elapsed * 16));
      rail.scrollLeft = drag.scroll - dx;
      drag.lastX = e.clientX; drag.lastTime = now;
    });
    function end(e) {
      if (!drag || (e.pointerId != null && e.pointerId !== drag.id)) return;
      const moved = drag.moved, id = drag.id;
      if (performance.now() - drag.lastTime > 100) velocity = 0;
      drag = null;
      if (rail.hasPointerCapture(id)) rail.releasePointerCapture(id);
      if (moved) { suppressClick = true; settle(); setTimeout(() => { suppressClick = false; }, 0); }
      else rail.classList.remove('is-dragging');
    }
    rail.addEventListener('pointerup', end);
    rail.addEventListener('pointercancel', e => { velocity = 0; end(e); });
    rail.addEventListener('lostpointercapture', end);
    window.addEventListener('pointerup', end);
    rail.addEventListener('click', e => { if (suppressClick) { e.preventDefault(); e.stopImmediatePropagation(); } }, true);
    rail.addEventListener('dragstart', e => e.preventDefault());
    rail.addEventListener('keydown', e => {
      if (e.target !== rail) return;
      const amount = Math.min(420, rail.clientWidth * .8);
      if (e.key === 'ArrowRight' || e.key === 'ArrowLeft') { e.preventDefault(); stop(); rail.scrollBy({ left: e.key === 'ArrowRight' ? amount : -amount, behavior: reduced.matches ? 'instant' : 'smooth' }); }
      if (e.key === 'Home' || e.key === 'End') { e.preventDefault(); stop(); rail.scrollTo({ left: e.key === 'Home' ? 0 : rail.scrollWidth, behavior: reduced.matches ? 'instant' : 'smooth' }); }
    });
    rail.addEventListener('wheel', stop, { passive: true });
    reduced.addEventListener('change', () => { stop(); rail.classList.remove('is-dragging'); });
  }
  document.querySelectorAll('[data-drag-rail]').forEach(attach);
})();

/* Bootstrap handles the mobile dropdown; links and Escape close it cleanly. */
(() => {
  const menu = document.getElementById('mobilePrimaryNav');
  const toggle = document.querySelector('[data-bs-target="#mobilePrimaryNav"]');
  if (!menu || !toggle || !window.bootstrap?.Collapse) return;
  const collapse = bootstrap.Collapse.getOrCreateInstance(menu, { toggle: false });
  menu.addEventListener('show.bs.collapse', () => { toggle.textContent = 'Close'; });
  menu.addEventListener('hide.bs.collapse', () => { toggle.textContent = 'Menu'; });
  menu.querySelectorAll('a').forEach(link => link.addEventListener('click', () => collapse.hide()));
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && menu.classList.contains('show')) {
      collapse.hide();
      toggle.focus();
    }
  });
  addEventListener('resize', () => { if (innerWidth >= 992) collapse.hide(); });
})();

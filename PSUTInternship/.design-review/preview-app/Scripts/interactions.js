/* Pointer dragging keeps clicks intact until a real horizontal drag begins. */
(() => {
  function attach(rail) {
    let drag = null, velocity = 0, frame = 0, suppressClick = false;
    const reduced = matchMedia('(prefers-reduced-motion: reduce)');
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

/* Shared navigation and accessible, non-blocking messages for every portal role. */
(() => {
  'use strict';
  const queue = [];
  let active = null;
  let dialog;
  function buildDialog() {
    if (dialog) return;
    dialog = document.createElement('dialog');
    dialog.className = 'portal-popup';
    dialog.setAttribute('aria-labelledby', 'portal-popup-title');
    dialog.setAttribute('aria-describedby', 'portal-popup-text');
    dialog.innerHTML = '<div class="portal-popup-body"><span class="portal-popup-mark" aria-hidden="true"></span><h2 id="portal-popup-title"></h2><p id="portal-popup-text"></p></div><div class="portal-popup-actions"><button type="button" data-popup-cancel>Cancel</button><button type="button" data-popup-accept>OK</button></div>';
    document.body.append(dialog);
    dialog.querySelector('[data-popup-cancel]').addEventListener('click', () => finish(false));
    dialog.querySelector('[data-popup-accept]').addEventListener('click', () => finish(true));
    dialog.addEventListener('cancel', event => { event.preventDefault(); finish(false); });
    dialog.addEventListener('click', event => { if (event.target === dialog && !active?.confirmation) { const r = dialog.getBoundingClientRect(); if (event.clientX < r.left || event.clientX > r.right || event.clientY < r.top || event.clientY > r.bottom) finish(false); } });
  }
  function next() {
    if (active || !queue.length || !document.body) return;
    buildDialog();
    active = queue.shift();
    active.previous = document.activeElement;
    dialog.querySelector('h2').textContent = active.title || (active.confirmation ? 'Confirm your action' : 'Workspace message');
    dialog.querySelector('p').textContent = active.message;
    dialog.querySelector('.portal-popup-mark').innerHTML = active.confirmation || active.kind === 'error' ? '<svg viewBox="0 0 24 24"><path d="M12 5v9m0 4h.01"/></svg>' : '<svg viewBox="0 0 24 24"><path d="m5 12 4 4L19 6"/></svg>';
    const cancel = dialog.querySelector('[data-popup-cancel]');
    cancel.hidden = !active.confirmation;
    dialog.querySelector('[data-popup-accept]').textContent = active.confirmation ? (active.acceptLabel || 'Confirm') : 'Got it';
    dialog.showModal();
    (active.confirmation ? cancel : dialog.querySelector('[data-popup-accept]')).focus();
  }
  function finish(accepted) {
    if (!active) return;
    const current = active;
    dialog.close();
    active = null;
    if (current.previous?.isConnected) current.previous.focus({ preventScroll: true });
    current.resolve(accepted);
    next();
  }
  function enqueue(message, options = {}) {
    return new Promise(resolve => { queue.push({ ...options, message: String(message), resolve }); next(); });
  }
  window.PortalUI = {
    message: (message, options) => enqueue(message, options),
    confirm: (message, options) => enqueue(message, { ...options, confirmation: true })
  };
  // Return false immediately. Replay the original control once, after explicit confirmation,
  // preserving ASP.NET validation, link destinations and the original postback event target.
  window.portalConfirmAction = (control, message) => {
    if (control.dataset.portalConfirmed === 'true') { delete control.dataset.portalConfirmed; return true; }
    if (control.dataset.portalConfirmPending) return false;
    control.dataset.portalConfirmPending = 'true';
    window.PortalUI.confirm(message).then(confirmed => {
      delete control.dataset.portalConfirmPending;
      if (confirmed && control.isConnected && !control.disabled) { control.dataset.portalConfirmed = 'true'; control.click(); }
    });
    return false;
  };
  function init() {
    const menu = document.querySelector('.portal-menu');
    const sidebar = document.querySelector('.portal-sidebar');
    const railToggle = document.querySelector('.portal-rail-toggle');
    function setRail(collapsed, persist = false) {
      document.documentElement.classList.toggle('portal-rail-collapsed', collapsed);
      railToggle?.setAttribute('aria-expanded', String(!collapsed));
      railToggle?.setAttribute('aria-label', collapsed ? 'Expand navigation' : 'Collapse navigation');
      if (persist) { try { localStorage.setItem('psut.sidebar.collapsed', String(collapsed)); } catch (e) { } }
    }
    setRail(document.documentElement.classList.contains('portal-rail-collapsed'));
    railToggle?.addEventListener('click', () => setRail(!document.documentElement.classList.contains('portal-rail-collapsed'), true));
    const backdrop = document.createElement('button');
    backdrop.type = 'button'; backdrop.className = 'portal-nav-backdrop'; backdrop.hidden = true;
    backdrop.setAttribute('aria-label', 'Close navigation'); document.body.append(backdrop);
    const setMenu = open => {
      document.body.classList.toggle('portal-nav-open', open);
      menu?.setAttribute('aria-expanded', String(open));
      menu?.setAttribute('aria-label', open ? 'Close navigation' : 'Open navigation');
      backdrop.hidden = !open;
      if (open) setTimeout(() => { if (document.body.classList.contains('portal-nav-open')) sidebar?.querySelector('.portal-nav a')?.focus(); }, 220); else menu?.focus();
    };
    menu?.addEventListener('click', () => setMenu(!document.body.classList.contains('portal-nav-open')));
    backdrop.addEventListener('click', () => setMenu(false));
    const media = matchMedia('(max-width:1100px)');
    media.addEventListener('change', () => { if (!media.matches && document.body.classList.contains('portal-nav-open')) setMenu(false); });
    document.addEventListener('keydown', event => {
      if (event.key === 'Escape' && document.body.classList.contains('portal-nav-open')) setMenu(false);
      if (event.key === 'Tab' && document.body.classList.contains('portal-nav-open') && !dialog?.open) {
        const items = [...sidebar.querySelectorAll('a,input,button')].filter(node => !node.closest('[hidden]'));
        if (event.shiftKey && document.activeElement === items[0]) { event.preventDefault(); items.at(-1)?.focus(); }
        else if (!event.shiftKey && document.activeElement === items.at(-1)) { event.preventDefault(); items[0]?.focus(); }
      }
    });
    document.querySelector('[data-portal-refresh]')?.addEventListener('click', () => location.reload());
    // Keep wide data tables in their own scroll region at phone and tablet widths.
    document.querySelectorAll('.portal-content table').forEach(table => {
      if (table.parentElement.matches('.table-wrap,.tableWrap,.table-responsive,.table-wrapper,.table-container,.wd-table-scroll')) return;
      const scroll = document.createElement('div'); scroll.className = 'table-responsive';
      table.before(scroll); scroll.append(table);
    });
    // Master pages prefix server IDs. Keep existing field labels connected to their controls.
    let fieldIndex = 0;
    document.querySelectorAll('.portal-content label').forEach(label => {
      let field;
      if (label.htmlFor) {
        if (document.getElementById(label.htmlFor)) return;
        field = [...document.querySelectorAll('.portal-content input,.portal-content textarea,.portal-content select')].find(control => control.id.endsWith('_' + label.htmlFor));
      } else if (label.nextElementSibling?.matches('input:not([type=hidden]),textarea,select')) {
        field = label.nextElementSibling;
      }
      if (field) { if (!field.id) field.id = 'portal-field-' + (++fieldIndex); label.htmlFor = field.id; }
    });
    // Animate each outer card once, including cards refreshed by Web Forms.
    const cardSelector = '.card,.panel,.stat,.stat-card,.meeting-stat,.task-card,.account-section,.meeting-panel,.evaluation-card,.student-card,.report-box,.summary-card,.wd-metrics article,.wd-status-panel,.wd-activity-panel,.wd-report-note,.wd-feature,.wd-action-tile,.wd-opening,.wd-person,.sd-application-card,.sd-opportunity-card,.portal-task-stats>div';
    const animatedCards = new WeakSet();
    const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
    function animateCards() {
      let index = 0;
      document.querySelectorAll('.portal-content :is(' + cardSelector + ')').forEach(card => {
        if (animatedCards.has(card) || card.parentElement.closest(cardSelector) || card.closest('.modal,.portal-popup,[role="dialog"]') || !card.getClientRects().length) return;
        animatedCards.add(card);
        card.classList.add('portal-motion-card');
        if (reducedMotion.matches || !card.animate) return;
        const entrance = card.animate([
          { opacity: 0, transform: 'translateY(38px)' },
          { opacity: 1, transform: 'translateY(0)' }
        ], { duration: 700, delay: Math.min(index++ * 85, 425), easing: 'cubic-bezier(.22,1,.36,1)', fill: 'backwards' });
        const stopForReducedMotion = event => { if (event.matches) entrance.cancel(); };
        reducedMotion.addEventListener('change', stopForReducedMotion);
        entrance.finished.catch(() => {}).finally(() => reducedMotion.removeEventListener('change', stopForReducedMotion));
      });
    }
    animateCards();
    // Server-rendered outcomes remain inline and also receive a dismissible popup.
    const messages = new WeakMap();
    const selector = '[data-popup-message],.message,.reply-notice,.error-banner,.msg-error,.msg-ok,.notice.error,.notice.ok,.form-feedback,[id$="MessageLabel"],[id$="messageLabel"],[id$="lblMessage"],[id$="PageMessage"],[id$="notice"],.wd-notice,.sd-status,.notice[role="status"],[role="status"]:not([aria-live])';
    function scanMessages() {
      document.querySelectorAll('.portal-content ' + selector.split(',').join(',.portal-content ')).forEach(node => {
        const text = node.textContent.trim();
        if (!text || !node.getClientRects().length || messages.get(node) === text || node.closest('.portal-popup')) return;
        messages.set(node, text);
        // Nested role=status and message classes should announce the same outcome only once.
        if (node.parentElement.closest(selector)) return;
        const error = node.matches('.error,.error-banner,.msg-error') || /unable|could not|couldn't|cannot|failed|please enter|invalid|must |not match|expired/i.test(text);
        window.PortalUI.message(text, { title: error ? 'Please check this' : 'Workspace update', kind: error ? 'error' : 'success' });
      });
    }
    scanMessages();
    const content = document.querySelector('.portal-content');
    if (content) new MutationObserver(() => { scanMessages(); animateCards(); }).observe(content, { subtree: true, childList: true, characterData: true });
    if (window.Sys?.WebForms?.PageRequestManager) window.Sys.WebForms.PageRequestManager.getInstance().add_endRequest(() => { scanMessages(); animateCards(); });
    next();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})();

document.addEventListener('DOMContentLoaded',function(){
    document.querySelectorAll('dialog.profile-dialog').forEach(function(dialog){
        if (!dialog.open) dialog.showModal();
        dialog.addEventListener('cancel',function(event){event.preventDefault();dialog.querySelector('[data-profile-cancel]').click();});
    });
});

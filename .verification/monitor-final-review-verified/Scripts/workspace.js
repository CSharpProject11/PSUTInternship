(() => {
  const panels = [...document.querySelectorAll('[data-panel]')];
  const activity = document.getElementById('activity');
  function setView(name, moveFocus = false) {
    if (!['overview', 'workspace', 'activity', 'reports'].includes(name)) name = 'overview';
    panels.forEach(panel => { panel.hidden = panel.dataset.panel !== name; });
    activity.hidden = !['overview', 'activity', 'reports'].includes(name) && document.body.dataset.role !== 'student';
    document.querySelector('[data-student-openings]').hidden = name !== 'overview' || document.body.dataset.role !== 'student';
    document.querySelectorAll('[data-view]').forEach(link => {
      const active = link.dataset.view === name;
      link.classList.toggle('is-active', active);
      if (active) link.setAttribute('aria-current', 'page'); else link.removeAttribute('aria-current');
    });
    if (document.body.dataset.role === 'student') {
      const reportsLink = document.querySelector('.sd-nav a[href$="#reports"]');
      const dashboardLink = document.querySelector('.sd-nav a[href$="/Dashboard.aspx"]');
      if (reportsLink && dashboardLink) {
        reportsLink.classList.toggle('is-current', name === 'reports');
        dashboardLink.classList.toggle('is-current', name !== 'reports');
        if (name === 'reports') { reportsLink.setAttribute('aria-current', 'page'); dashboardLink.removeAttribute('aria-current'); }
        else { dashboardLink.setAttribute('aria-current', 'page'); reportsLink.removeAttribute('aria-current'); }
      }
    }
    document.body.classList.remove('wd-nav-open');
    document.querySelector('.wd-menu-toggle')?.setAttribute('aria-expanded', 'false');
    if (moveFocus) { document.getElementById('workspace-main').focus({ preventScroll: true }); window.scrollTo({ top: 0, behavior: 'instant' }); }
  }
  document.querySelectorAll('[data-view]').forEach(link => link.addEventListener('click', e => {
    e.preventDefault(); history.replaceState(null, '', '#' + link.dataset.view); setView(link.dataset.view, true);
  }));
  document.querySelectorAll('a[href="#workspace"]').forEach(link => { if (!link.dataset.view) link.addEventListener('click', e => { e.preventDefault(); history.replaceState(null, '', '#workspace'); setView('workspace', true); }); });
  window.addEventListener('hashchange', () => setView(location.hash.slice(1)));
  setView(location.hash.slice(1));
  const menu = document.querySelector('.wd-menu-toggle');
  menu?.addEventListener('click', () => { const open = document.body.classList.toggle('wd-nav-open'); menu.setAttribute('aria-expanded', String(open)); if (open) document.querySelector('.wd-side-nav a').focus(); });
  document.addEventListener('keydown', e => { if (e.key === 'Escape' && menu) { const wasOpen = document.body.classList.contains('wd-nav-open'); document.body.classList.remove('wd-nav-open'); menu.setAttribute('aria-expanded', 'false'); document.querySelector('.wd-account').open = false; if (wasOpen) menu.focus(); } });
  document.querySelector('[data-refresh]')?.addEventListener('click', () => location.reload());
  const search = document.getElementById('activitySearch'), status = document.getElementById('activityStatus');
  const rows = [...document.querySelectorAll('#activityTable tbody tr')];
  function filter() {
    let count = 0;
    rows.forEach(row => { row.hidden = !(row.textContent.toLowerCase().includes(search.value.toLowerCase()) && (status.value === 'all' || row.dataset.status === status.value)); if (!row.hidden) count++; });
    document.getElementById('visibleCount').textContent = count;
    document.querySelector('.wd-filter-empty').hidden = count !== 0 || rows.length === 0;
  }
  search.addEventListener('input', filter); status.addEventListener('change', filter);
  document.querySelector('[data-export]').addEventListener('click', () => {
    const escape = value => '"' + (/^[=+\-@\t\r\n]/.test(value) ? "'" : '') + value.replaceAll('"', '""') + '"';
    const visible = rows.filter(row => !row.hidden);
    const head = [...document.querySelectorAll('#activityTable thead th')].slice(0, 4).map(cell => escape(cell.textContent.trim()));
    const data = [head, ...visible.map(row => [...row.cells].slice(0, 4).map(cell => escape(cell.textContent.trim())))].map(row => row.join(',')).join('\r\n');
    const url = URL.createObjectURL(new Blob(['\uFEFF' + data], { type: 'text/csv;charset=utf-8;' }));
    const link = document.createElement('a'); link.href = url; link.download = 'psut-' + document.body.dataset.role + '-applications.csv'; link.click(); setTimeout(() => URL.revokeObjectURL(url), 1000);
    const toast = document.querySelector('.wd-toast'); toast.textContent = 'Application report downloaded.'; toast.hidden = false; setTimeout(() => { toast.hidden = true; }, 3000);
  });
})();

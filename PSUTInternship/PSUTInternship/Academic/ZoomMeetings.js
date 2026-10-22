"use strict";
// LOCAL DEMO ONLY. The Firebase REST URL is not a secret; database Rules govern access.
// For real student records, use a server API with authenticated identity and private Rules.
window.MeetingFirebase = (() => {
    const base = 'https://project-d2551-default-rtdb.firebaseio.com';
    const supervisorId = '9A8jqXmuQthnfld1A9Lonba3QTI3';
    const supervisorName = 'Sara Sawalmeh'; // local demo; use verified server identity for multiple supervisors
    function pathUrl(path) { return `${base}/${path}.json`; }
    async function api(path, method = 'GET', data = undefined) {
        const opt = { method, headers: { 'Content-Type': 'application/json' }, cache: 'no-store' };
        if (data !== undefined) opt.body = JSON.stringify(data);
        const response = await fetch(pathUrl(path), opt);
        if (!response.ok) throw new Error('Firebase HTTP ' + response.status + '. Check Realtime Database Rules and connection.');
        return response.json();
    }
    function values(x) { return x && typeof x === 'object' ? Object.entries(x).filter(([, v]) => v && typeof v === 'object') : []; }
    async function students() {
        const [profile, all] = await Promise.all([
            api('academicSupervisors/' + supervisorId), api('students')
        ]);
        const assigned = new Set();
        for (const [, g] of values(profile?.groups)) {
            for (const [id, flag] of Object.entries(g.assignedStudentIds || {})) if (flag === true) assigned.add(id);
        }
        return values(all).filter(([id, s]) => s.academicSupervisorId === supervisorId || assigned.has(id))
            .filter(([, s]) => s.isActive !== false)
            .map(([id, s]) => ({ id, name: s.fullName || id, studentNumber: s.studentNumber || '' }))
            .sort((a, b) => a.name.localeCompare(b.name));
    }
    async function meetings() {
        const raw = await api('meetings');
        return values(raw).map(([id, m]) => ({ ...m, id })).filter(m => m.supervisorId === supervisorId)
            .sort((a, b) => (b.createdAt || '').localeCompare(a.createdAt || ''));
    }
    async function create(meeting) { return api('meetings', 'POST', meeting); }
    async function setStatus(id, previous, next) {
        if (!/^[a-zA-Z0-9_-]+$/.test(id)) throw new Error('Invalid meeting ID');
        // ETag conditional write so two browsers cannot overwrite simultaneous status changes.
        const url = pathUrl('meetings/' + id);
        const current = await fetch(url, { headers: { 'X-Firebase-ETag': 'true' }, cache: 'no-store' });
        if (!current.ok) throw new Error('Could not read meeting. HTTP ' + current.status);
        const etag = current.headers.get('ETag');
        const old = await current.json();
        if (!old || old.supervisorId !== supervisorId || old.status !== previous)
            throw new Error('Meeting was already updated. Refresh the page.');
        if (!etag) throw new Error('Firebase ETag not available for safe update.');
        const response = await fetch(url, { method: 'PUT', headers: { 'Content-Type': 'application/json', 'if-match': etag }, body: JSON.stringify({ ...old, status: next, respondedAt: new Date().toISOString() }) });
        if (response.status === 412) throw new Error('Meeting changed in another browser. Refresh.');
        if (!response.ok) throw new Error('Unable to update meeting: HTTP ' + response.status);
        return response.json();
    }
    function safe(s) { return String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c])); }
    function roomLink(item) {
        const r = item.roomName || '';
        return item.status === 'Accepted' && /^UIMS-[a-z0-9-]{8,100}$/i.test(r) ? 'https://meet.jit.si/' + encodeURIComponent(r) : '';
    }
    function dateLabel(m) { return safe(m.date || '') + ' · ' + safe(m.time || '') + ' · ' + safe(m.duration || 30) + ' min'; }
    function card(m, buttons) {
        return `<article class="meeting-card"><div class="card-top"><div class="meeting-avatar"><i class="bi bi-camera-video"></i></div><span class="status-badge ${safe((m.status || '').toLowerCase())}">${safe(m.status)}</span></div><h3>${safe(m.studentName)}</h3><p class="meeting-card-title">${safe(m.title)}</p><div class="meeting-details"><p><i class="bi bi-calendar3"></i>${dateLabel(m)}</p><p><i class="bi bi-clipboard-check"></i>${safe(m.purpose)}</p><p><i class="bi bi-person"></i>${safe(m.supervisorName)}</p></div>${m.notes ? `<p class="meeting-notes">${safe(m.notes)}</p>` : ''}<div class="card-actions">${buttons}</div></article>`;
    }
    const empty = '<div class="empty-state">No meetings to display.</div>';
    return { supervisorId, supervisorName, students, meetings, create, setStatus, safe, roomLink, card, empty };
})();

"use strict";
const F = window.MeetingFirebase;
const $ = id => document.getElementById(id);
let roster = [], all = [];
function message(s, ok = false) { const e = $('formMessage'); e.textContent = s; e.className = 'form-feedback ' + (ok ? 'success' : 'error'); }
async function loadStudents() { roster = await F.students(); $('studentSelect').innerHTML = '<option value="">Select Student</option>' + roster.map(s => `<option value="${F.safe(s.id)}">${F.safe(s.name)} — ${F.safe(s.studentNumber)}</option>`).join(''); if (!roster.length) message('No assigned students found for ' + F.supervisorName + '. Check Firebase data and read permissions.'); }
function render() {
    $('totalCount').textContent = all.length;
    for (const [id, status] of [['pendingCount', 'Pending'], ['acceptedCount', 'Accepted'], ['rejectedCount', 'Rejected']]) $(id).textContent = all.filter(m => m.status === status).length;
    const filter = $('statusFilter').value;
    // Keep accepted meetings in Upcoming only to avoid duplicate cards.
    const invitations = all.filter(m => filter === 'all' ? m.status === 'Pending' : m.status === filter && m.status !== 'Accepted');
    $('invitationsList').innerHTML = invitations.map(m => F.card(m, (m.status === 'Pending' ? '<p class="waiting-note">Waiting for student response</p>' : '') + (m.status === 'Pending' ? `<button class="cancel-button" data-cancel="${F.safe(m.id)}">Cancel Invitation</button>` : ''))).join('') || F.empty;
    $('upcomingList').innerHTML = all.filter(m => m.status === 'Accepted').map(m => F.card(m, `<a class="join-button" target="_blank" rel="noopener noreferrer" href="${F.roomLink(m)}"><i class="bi bi-camera-video"></i> Join Meeting</a><button class="cancel-button" data-cancel="${F.safe(m.id)}">Cancel Invitation</button>`)).join('') || F.empty;
    $('activityList').innerHTML = all.slice(0, 5).map(m => `<div class="activity-item"><strong>${F.safe(m.studentName)} · ${F.safe(m.status)}</strong><small>${F.safe(m.createdAt || '')}</small></div>`).join('') || F.empty;
}
async function refresh() { try { all = await F.meetings(); render(); } catch (e) { message(e.message); } }
$('meetingForm').addEventListener('submit', async event => {
    event.preventDefault(); const btn = event.submitter || $('meetingForm').querySelector('button[type="submit"]');
    const student = roster.find(x => x.id === $('studentSelect').value);
    const title = $('meetingTitle').value.trim(), purpose = $('meetingPurpose').value.trim();
    const date = $('meetingDate').value, time = $('meetingTime').value;
    const duration = Number($('meetingDuration').value), notes = $('meetingNotes').value.trim();
    if (!student || !title || !purpose || !date || !time || ![30, 45, 60].includes(duration)) { message('Fill all required fields.'); return; }
    if (new Date(date + 'T' + time + ':00') <= new Date()) { message('Meeting must be in the future.'); return; }
    if (all.some(m => m.studentId === student.id && m.date === date && m.time === time && ['Pending', 'Accepted'].includes(m.status))) { message('This student already has a meeting at this time.'); return; }
    const bytes = new Uint8Array(16); crypto.getRandomValues(bytes); const roomName = 'UIMS-' + Array.from(bytes, x => x.toString(16).padStart(2, '0')).join('');
    btn.disabled = true;
    try {
        await F.create({ studentId: student.id, studentName: student.name, supervisorId: F.supervisorId, supervisorName: F.supervisorName, title, purpose, date, time, duration, notes, status: 'Pending', roomName, createdAt: new Date().toISOString() });
        $('meetingForm').reset(); await refresh(); message('Meeting invitation saved to Firebase.', true);
    } catch (e) { message(e.message); } finally { btn.disabled = false; }
});
document.addEventListener('click', async e => { const b = e.target.closest('[data-cancel]'); if (!b) return; const m = all.find(x => x.id === b.dataset.cancel); if (!m || !confirm('Cancel invitation?')) return; b.disabled = true; try { await F.setStatus(m.id, m.status, 'Cancelled'); await refresh(); } catch (err) { message(err.message); } finally { b.disabled = false; } });
$('statusFilter').addEventListener('change', render);
(async () => { try { $('supervisorChip').textContent = '● ' + F.supervisorName; await loadStudents(); await refresh(); } catch (e) { message('Firebase loading error: ' + e.message); $('studentSelect').innerHTML = '<option value="">Unable to load students</option>'; } })();
window.addEventListener('focus', refresh);

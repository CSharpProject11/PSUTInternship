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
const F = window.MeetingFirebase; const $ = id => document.getElementById(id);
let meetings = [];
function note(s, ok = false) { const e = $('studentMessage'); e.textContent = s; e.className = 'form-feedback ' + (ok ? 'success' : 'error'); }
function chosen() { return $('studentAccount').value; }
function render() {
    const list = meetings.filter(m => m.studentId === chosen());
    $('studentChip').textContent = '● ' + ($('studentAccount').selectedOptions[0]?.textContent || 'Student');
    $('studentTotal').textContent = list.length;
    for (const [id, status] of [['studentPending', 'Pending'], ['studentAccepted', 'Accepted']]) $(id).textContent = list.filter(m => m.status === status).length;
    $('studentInvitations').innerHTML = list.filter(m => m.status === 'Pending').map(m => F.card(m, `<div class="card-actions"><button class="accept-button" data-reply="Accepted" data-id="${F.safe(m.id)}"><i class="bi bi-check-circle"></i> Accept</button></div>`)).join('') || F.empty;
    $('studentUpcoming').innerHTML = list.filter(m => m.status === 'Accepted').map(m => F.card(m, `<a class="join-button" href="${F.roomLink(m)}" target="_blank" rel="noopener noreferrer"><i class="bi bi-camera-video"></i> Join Meeting</a>`)).join('') || F.empty;
}
async function refresh() { try { meetings = await F.meetings(); render(); } catch (e) { note(e.message); } }
document.addEventListener('click', async e => {
    const b = e.target.closest('[data-reply]'); if (!b) return;
    const m = meetings.find(x => x.id === b.dataset.id && x.studentId === chosen() && x.status === 'Pending'); if (!m) return;
    b.disabled = true; try { await F.setStatus(m.id, 'Pending', b.dataset.reply); await refresh(); note('Response saved to Firebase.', true); } catch (err) { note(err.message); } finally { b.disabled = false; }
});
$('studentAccount').addEventListener('change', render);
$('refreshMeetings').addEventListener('click', refresh);
(async () => { try { const list = await F.students(); $('studentAccount').innerHTML = '<option value="">Select Student</option>' + list.map(s => `<option value="${F.safe(s.id)}">${F.safe(s.name)} — ${F.safe(s.studentNumber)}</option>`).join(''); if (list.length === 0) note('No students assigned to Sara in Firebase.'); await refresh(); } catch (e) { note('Cannot load students from Firebase: ' + e.message); } })();
window.addEventListener('focus', refresh);

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
    $('invitationsList').innerHTML = invitations.map(m => F.card(m, (m.status === 'Pending' ? '<p class="waiting-note">Waiting for student response</p>' : '') + (m.status === 'Pending' ? `<button type="button" class="cancel-button" data-cancel="${F.safe(m.id)}">Cancel Invitation</button>` : ''))).join('') || F.empty;
    $('upcomingList').innerHTML = all.filter(m => m.status === 'Accepted').map(m => F.card(m, `<a class="join-button" target="_blank" rel="noopener noreferrer" href="${F.roomLink(m)}"><i class="bi bi-camera-video"></i> Join Meeting</a><button type="button" class="cancel-button" data-cancel="${F.safe(m.id)}">Cancel Invitation</button>`)).join('') || F.empty;
    $('activityList').innerHTML = [...all].sort((a,b)=>String(b.respondedAt||b.updatedAt||b.createdAt).localeCompare(String(a.respondedAt||a.updatedAt||a.createdAt))).slice(0, 5).map(m => `<div class="activity-item"><strong>${F.safe(m.studentName)} · ${F.safe(m.status)}</strong><small>${F.safe(F.formatActivityDate(m.respondedAt || m.updatedAt || m.createdAt))}</small></div>`).join('') || F.empty;
}
async function refresh() { try { all = await F.meetings(); render(); } catch (e) { message(e.message); } }
$('portalForm').addEventListener('submit', async event => {
    event.preventDefault(); const btn = event.submitter || $('portalForm').querySelector('button[type="submit"]');
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
        $('portalForm').reset(); await refresh(); message('Meeting invitation saved to Firebase.', true);
    } catch (e) { message(e.message); } finally { btn.disabled = false; }
});
document.addEventListener('click', async e => { const b = e.target.closest('[data-cancel]'); if (!b) return; e.preventDefault(); const m = all.find(x => x.id === b.dataset.cancel); if (!m || !await PortalUI.confirm('Cancel this meeting invitation?', { acceptLabel: 'Cancel invitation' })) return; b.disabled = true; try { await F.setStatus(m.id, m.status, 'Cancelled'); await refresh(); } catch (err) { message(err.message); } finally { b.disabled = false; } });
$('statusFilter').addEventListener('change', render);
(async () => { try { await F.ready; $('supervisorChip').textContent = '● ' + F.supervisorName; await loadStudents(); await refresh(); } catch (e) { message('Firebase loading error: ' + e.message); $('studentSelect').innerHTML = '<option value="">Unable to load students</option>'; } })();
window.addEventListener('focus', refresh);

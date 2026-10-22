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
    $('studentInvitations').innerHTML = list.filter(m => m.status === 'Pending').map(m => F.card(m, `<div class="card-actions"><button type="button" class="accept-button" data-reply="Accepted" data-id="${F.safe(m.id)}"><i class="bi bi-check-circle"></i> Accept</button></div>`)).join('') || F.empty;
    $('studentUpcoming').innerHTML = list.filter(m => m.status === 'Accepted').map(m => F.card(m, `<a class="join-button" href="${F.roomLink(m)}" target="_blank" rel="noopener noreferrer"><i class="bi bi-camera-video"></i> Join Meeting</a>`)).join('') || F.empty;
}
async function refresh() { try { meetings = await F.meetings(); render(); } catch (e) { note(e.message); } }
document.addEventListener('click', async e => {
    const b = e.target.closest('[data-reply]'); if (!b) return;
    e.preventDefault();
    const m = meetings.find(x => x.id === b.dataset.id && x.studentId === chosen() && x.status === 'Pending'); if (!m) return;
    b.disabled = true; try { await F.setStatus(m.id, 'Pending', b.dataset.reply); await refresh(); note('Response saved to Firebase.', true); } catch (err) { note(err.message); } finally { b.disabled = false; }
});
$('studentAccount').addEventListener('change', render);
$('refreshMeetings').addEventListener('click', refresh);
(async () => { try { await F.ready; const list = await F.students(); $('studentAccount').innerHTML = list.map(s => `<option value="${F.safe(s.id)}">${F.safe(s.name)} — ${F.safe(s.studentNumber)}</option>`).join(''); if (list.length === 0) note('No students are available for this account.'); await refresh(); } catch (e) { note('Cannot load students from Firebase: ' + e.message); } })();
window.addEventListener('focus', refresh);

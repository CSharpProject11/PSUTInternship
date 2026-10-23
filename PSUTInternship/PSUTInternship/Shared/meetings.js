"use strict";
window.MeetingFirebase=(()=>{
    let identity={};
    async function request(action,data){const response=await fetch('../MeetingApi.aspx?action='+action,data===undefined?{}:{method:'POST',headers:{'Content-Type':'application/json','X-CSRF-Token':identity.token},body:JSON.stringify(data)});if(response.redirected)throw Error('Sign in to the portal first.');const result=await response.json();if(!response.ok)throw Error(result.error||'Unable to load meetings.');return result;}
    const ready=request('identity').then(value=>{identity=value;});
    async function students(){await ready;return request('students');}
    async function meetings(){await ready;const rows=await request('meetings');return Object.entries(rows||{}).map(([id,m])=>({...m,id}));}
    async function create(meeting){await ready;return request('create',meeting);}
    async function setStatus(id,previous,next){await ready;return request('status',{id,previous,next});}
    function safe(s) { return String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c])); }
    function roomLink(item) {
        if(item.status!=='Accepted')return '';
        const original=item.meetingLink||item.meetingUrl||item.joinUrl||'';
        try{const url=new URL(original);if(url.protocol==='https:')return url.href;}catch{}
        const r = item.roomName || '';
        return item.status === 'Accepted' && /^UIMS-[a-z0-9-]{8,100}$/i.test(r) ? 'https://meet.jit.si/' + encodeURIComponent(r) : '';
    }
    function formatActivityDate(value) {
        const date = new Date(value); if (!value || Number.isNaN(date.getTime())) return 'Date not recorded';
        const parts = new Intl.DateTimeFormat('en-GB',{timeZone:'Asia/Amman',day:'2-digit',month:'2-digit',year:'numeric',hour:'2-digit',hourCycle:'h23'}).formatToParts(date);
        const get = key => parts.find(x=>x.type===key)?.value || '';
        return get('day')+'-'+get('month')+'-'+get('year')+' '+get('hour');
    }
    function dateLabel(m) { return safe(m.date || '') + ' · ' + safe(m.time || '') + ' · ' + safe(m.duration || 30) + ' min'; }
    function card(m, buttons) {
        return `<article class="meeting-card"><div class="card-top"><div class="meeting-avatar"><i class="bi bi-camera-video"></i></div><span class="status-badge ${safe((m.status || '').toLowerCase())}">${safe(m.status)}</span></div><h3>${safe(m.studentName)}</h3><p class="meeting-card-title">${safe(m.title)}</p><div class="meeting-details"><p><i class="bi bi-calendar3"></i>${dateLabel(m)}</p><p><i class="bi bi-clipboard-check"></i>${safe(m.purpose)}</p><p><i class="bi bi-person"></i>${safe(m.supervisorName)}</p></div>${m.notes ? `<p class="meeting-notes">${safe(m.notes)}</p>` : ''}<div class="card-actions">${buttons}</div></article>`;
    }
    const empty = '<div class="empty-state">No meetings to display.</div>';

    return {ready,get supervisorId(){return identity.supervisorId;},get supervisorName(){return identity.supervisorName||'Academic supervisor';},students,meetings,create,setStatus,safe,roomLink,card,empty,formatActivityDate};
})();

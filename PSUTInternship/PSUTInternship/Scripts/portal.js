
let opportunities=[];
function portalEscape(value){return String(value??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}
function renderCards(list=opportunities){
 const cards=document.getElementById('publicCards');if(!cards)return;
 cards.innerHTML=list.map((o,i)=>`<article class="card"><img class="opportunity-thumbnail" src="${PSUT.root}Assets/${['psut-students.jpeg','psut-community.jpeg','psut-welcome.jpeg'][i%3]}" alt="PSUT students"><h3>${portalEscape(o.title)}</h3><div class="company">${portalEscape(o.company)}</div><div class="meta">${portalEscape(o.seats)} seats · ${portalEscape(o.deadline)}</div><div class="foot"><span>${portalEscape(o.major)}</span><button class="btn outline" data-preview="${portalEscape(o.id)}">View preview</button></div></article>`).join('')||'<p>No open opportunities match your search.</p>';
 const status=document.getElementById('searchStatus');if(status)status.textContent=list.length+' opportunities available';
}
function searchOpps(){const q=document.getElementById('heroSearch').value.trim().toLowerCase();renderCards(opportunities.filter(o=>(o.title+' '+o.company+' '+o.major).toLowerCase().includes(q)));}
function showDetail(id){const o=opportunities.find(x=>x.id===id);if(!o)return;document.getElementById('detailContent').innerHTML=`<div class="modalhead"><h2>${portalEscape(o.title)}</h2><button class="close" aria-label="Close preview" onclick="closeModal('detail')">×</button></div><p>${portalEscape(o.company)}</p><p>${portalEscape(o.major)} · ${portalEscape(o.seats)} seats</p><p>Application deadline: ${portalEscape(o.deadline)}</p><a class="btn" href="${PSUT.root}Login.aspx">Sign in for full details and applications</a>`;openModal('detail');}
document.addEventListener('click',event=>{const button=event.target.closest('[data-preview]');if(button)showDetail(button.dataset.preview);});
async function loadPublicOpportunities(){
 if(!document.getElementById('publicCards'))return;document.getElementById('publicCards').textContent='Loading opportunities…';
 try{const response=await fetch(PSUT.root+'PublicData.aspx');if(!response.ok)throw Error();opportunities=await response.json();renderCards();}
 catch{document.getElementById('publicCards').textContent='Opportunities could not be loaded. Please refresh to try again.';}
}
function openModal(id){if(id==='login'){window.location.assign(PSUT.root+'Login.aspx');return;}document.getElementById(id).classList.add('show')}function closeModal(id){document.getElementById(id).classList.remove('show')}
function toast(s){let t=document.getElementById('toast');t.textContent=s;t.classList.add('show');setTimeout(()=>t.classList.remove('show'),2600)}

loadPublicOpportunities();

function clearOpportunitySearch(){document.getElementById('heroSearch').value='';renderCards();document.getElementById('heroSearch').focus()}

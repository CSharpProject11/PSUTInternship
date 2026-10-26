
let opportunities=[];
function portalEscape(value){return String(value??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}
function renderCards(list=opportunities,unavailable=false){
 const cards=document.getElementById('publicCards');if(!cards)return;
 const visible=list.slice(0,6);
 cards.innerHTML=Array.from({length:6},(_,i)=>{
  const o=visible[i],theme=['sky','navy','pale','navy','sky','pale'][i];
  if(!o)return `<article class="fact-card mosaic-card ${theme} coming-soon"><span class="fact-mark" aria-hidden="true">${i+1}</span><div><h3>Coming soon.</h3><p>${unavailable?'Live previews are temporarily unavailable. Please try again later.':'More internship opportunities will appear here when available.'}</p></div><span class="opportunity-card-note">${unavailable?'Previews unavailable':'Watch this space'}</span></article>`;
  return `<article class="fact-card mosaic-card ${theme}"><span class="fact-mark" aria-hidden="true">${i+1}</span><div><p class="opportunity-card-company">${portalEscape(o.company)}</p><h3>${portalEscape(o.title)}</h3><p>${portalEscape(o.major||'Open to relevant specializations')}</p><p class="opportunity-card-meta">${portalEscape(o.seats)} seats · ${portalEscape(o.deadline||'Deadline to be confirmed')}</p></div><a href="${PSUT.root}Login.aspx">Sign in for details &amp; apply <span aria-hidden="true">↗</span></a></article>`;
 }).join('');
 cards.setAttribute?.('aria-busy','false');
 const status=document.getElementById('searchStatus');if(status)status.textContent=unavailable?'Live opportunity previews could not be loaded. Please try again later.':`${visible.length} ${visible.length===1?'opportunity':'opportunities'} available${visible.length<6?' · More coming soon':''}`;
 if(cards.dispatchEvent)cards.dispatchEvent(new Event('scroll'));
}
function searchOpps(){const q=document.getElementById('heroSearch').value.trim().toLowerCase();renderCards(opportunities.filter(o=>(o.title+' '+o.company+' '+o.major).toLowerCase().includes(q)));}
function showDetail(id){const o=opportunities.find(x=>x.id===id);if(!o)return;document.getElementById('detailContent').innerHTML=`<div class="modalhead"><h2>${portalEscape(o.title)}</h2><button class="close" aria-label="Close preview" onclick="closeModal('detail')">×</button></div><p>${portalEscape(o.company)}</p><p>${portalEscape(o.major)} · ${portalEscape(o.seats)} seats</p><p>Application deadline: ${portalEscape(o.deadline)}</p><a class="btn" href="${PSUT.root}Login.aspx">Sign in for full details and applications</a>`;openModal('detail');}
document.addEventListener('click',event=>{const button=event.target.closest('[data-preview]');if(button)showDetail(button.dataset.preview);});
async function loadPublicOpportunities(){
 if(!document.getElementById('publicCards')||document.getElementById('publicCards').getAttribute?.('data-server-rendered')==='true')return;document.getElementById('publicCards').textContent='Loading opportunities…';
 try{const response=await fetch(PSUT.root+'PublicData.aspx');if(!response.ok)throw Error();const data=await response.json();if(!Array.isArray(data))throw Error();opportunities=data;renderCards();}
 catch{opportunities=[];renderCards([],true);}
}
function openModal(id){if(id==='login'){window.location.assign(PSUT.root+'Login.aspx');return;}document.getElementById(id).classList.add('show')}function closeModal(id){document.getElementById(id).classList.remove('show')}
function toast(s){let t=document.getElementById('toast');t.textContent=s;t.classList.add('show');setTimeout(()=>t.classList.remove('show'),2600)}

loadPublicOpportunities();

function clearOpportunitySearch(){document.getElementById('heroSearch').value='';renderCards();document.getElementById('heroSearch').focus()}

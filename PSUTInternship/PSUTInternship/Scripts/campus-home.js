/* Homepage presentation only. Authentication and role routes stay in Web Forms. */
(()=>{
 'use strict';
 const reduced=matchMedia('(prefers-reduced-motion: reduce)');
 const video=document.getElementById('introVideo');
 let visible=true,scrollFrame=0;
 function syncFilm(){if(!reduced.matches&&visible&&!document.hidden&&!document.body.classList.contains('dialog-open'))video.play().catch(()=>{});else video.pause();}
 video.addEventListener('playing',()=>video.classList.add('video-ready'));
 video.addEventListener('error',()=>video.classList.remove('video-ready'));
 new IntersectionObserver(entries=>{visible=entries[0].isIntersecting;syncFilm()},{threshold:.05}).observe(video);
 document.addEventListener('visibilitychange',syncFilm);reduced.addEventListener('change',syncFilm);syncFilm();
 const poster=document.querySelector('.film-frame'),opening=document.querySelector('.campus-opening'),panorama=document.querySelector('.campus-panorama');
 const gallery=document.querySelector('.discovery-gallery');
 const filmCopy=[...document.querySelectorAll('.opening-copy h1,.opening-description p')];
 let filmTravel=0,lastFilmTime=0,galleryProgress=0,lastGalleryTime=0;
 function draw(time=performance.now()){
  scrollFrame=0;
  let gallerySettling=false;
  if(gallery){
   const bounds=gallery.getBoundingClientRect();
   const progress=Math.min(1,Math.max(0,-bounds.top/Math.max(1,bounds.height-innerHeight)));
   const elapsed=lastGalleryTime?Math.min(64,time-lastGalleryTime):16;
   lastGalleryTime=time;
   // Let the whole collage catch up together, with a gentle 320ms response.
   galleryProgress+= (progress-galleryProgress)*(1-Math.exp(-elapsed/320));
   gallerySettling=!reduced.matches&&Math.abs(progress-galleryProgress)>.0002;
   if(!gallerySettling){galleryProgress=progress;lastGalleryTime=0;}
   const start=innerWidth<768?58:34;
   gallery.style.setProperty('--gallery-center',`${reduced.matches?48:start+(96-start)*galleryProgress}vw`);
  }
  if(reduced.matches){
   filmTravel=0;lastFilmTime=0;
   poster.style.removeProperty('--film-scale');poster.style.removeProperty('--film-radius');poster.style.removeProperty('--film-travel');
   panorama.style.removeProperty('--panorama-scale');
   filmCopy.forEach(el=>el.style.removeProperty('--film-cover'));
   opening.classList.remove('film-over-copy');return;
  }
  const section=opening.getBoundingClientRect();
  // Move the entire film down in its parent, clamping travel to the copy height.
  const travel=Math.max(1,opening.offsetHeight-poster.offsetHeight);
  const target=Math.min(travel,Math.max(0,-section.top));
  // A short, frame-rate-independent catch-up makes both directions feel fluid.
  const elapsed=lastFilmTime?Math.min(64,time-lastFilmTime):16;
  lastFilmTime=time;
  filmTravel=Math.min(travel,Math.max(0,filmTravel+(target-filmTravel)*(1-Math.exp(-elapsed/180))));
  const settling=Math.abs(target-filmTravel)>.1;
  if(!settling){filmTravel=target;lastFilmTime=0;}
  const progress=filmTravel/travel;
  poster.style.setProperty('--film-travel',`${filmTravel}px`);
  poster.style.setProperty('--film-radius',`${(1-progress)*Math.min(140,innerWidth*.09)}px`);
  poster.style.setProperty('--film-scale',(1.025+progress*.025).toFixed(3));
  const frame=poster.getBoundingClientRect();
  // The color boundary follows the actual film edge in both scroll directions.
  filmCopy.forEach(el=>{
   const box=el.getBoundingClientRect();
   el.style.setProperty('--film-cover',`${Math.min(box.height,Math.max(0,frame.bottom-box.top))}px`);
  });
  opening.classList.toggle('film-over-copy',progress>.75);
  const box=panorama.getBoundingClientRect();
  const p=Math.min(1,Math.max(0,(innerHeight-box.top)/(innerHeight+box.height)));
  panorama.style.setProperty('--panorama-scale',(1.08-p*.08).toFixed(3));
  if(settling||gallerySettling)queue();
 }
 function queue(){if(!scrollFrame)scrollFrame=requestAnimationFrame(draw);}
 addEventListener('scroll',queue,{passive:true});addEventListener('resize',queue);
 reduced.addEventListener('change',queue);
 new ResizeObserver(queue).observe(opening);
 document.fonts?.ready.then(queue);draw();
 const reveal=new IntersectionObserver(entries=>entries.forEach(entry=>{if(!entry.isIntersecting)return;entry.target.classList.add('arriving');reveal.unobserve(entry.target);}),{threshold:.12});
 document.querySelectorAll('[data-reveal]').forEach((el,index)=>{el.style.setProperty('--reveal-delay',`${index%3*70}ms`);reveal.observe(el);});
 document.querySelectorAll('[data-rail][data-direction]').forEach(button=>button.addEventListener('click',()=>{const rail=document.getElementById(button.dataset.rail);rail.scrollBy({left:Number(button.dataset.direction)*Math.min(rail.clientWidth*.8,450),behavior:reduced.matches?'instant':'smooth'});}));
 document.querySelectorAll('[data-progress]').forEach(progress=>{const rail=document.getElementById(progress.dataset.progress);const update=()=>{const total=rail.scrollWidth-rail.clientWidth;const fraction=total>0?rail.scrollLeft/total:0;progress.style.setProperty('--rail-travel',`${fraction*233.33}%`);};rail.addEventListener('scroll',update,{passive:true});addEventListener('resize',update);update();});
 /* Native Bootstrap collapse, plus Escape and focus restoration. */
 const menu=document.getElementById('mobilePrimaryNav'),trigger=document.querySelector('.menu-toggle');
 menu.addEventListener('show.bs.collapse',()=>{document.querySelector('.campus-header').classList.add('menu-expanded')});menu.addEventListener('hidden.bs.collapse',()=>document.querySelector('.campus-header').classList.remove('menu-expanded'));
 /* A modal film is paused on closing, and keyboard focus stays inside its dialog. */
 const baseOpen=window.openModal,baseClose=window.closeModal,states=new Map();
 window.watchCampus=function(){document.getElementById('detailContent').innerHTML='<div class="modalhead"><h2>Discover PSUT</h2><button type="button" class="close" onclick="closeModal(\'detail\')" aria-label="Close film">×</button></div><video class="campus-player" id="campusPlayer" src="'+PSUT.root+'Assets/psut-campus-film.mp4" poster="'+PSUT.root+'Assets/psut-rooftop.jpg" controls autoplay playsinline></video><p class="small muted">Princess Sumaya University for Technology · Campus film</p>';document.querySelector('#detail .modalbox').style.width='min(1100px, 100%)';openModal('detail');document.getElementById('campusPlayer').play().catch(()=>{});};
 window.openModal=function(id){if(id==='login'){baseOpen(id);return;}const el=document.getElementById(id);if(!el||el.classList.contains('show'))return;document.querySelectorAll('.psut-modal.show').forEach(m=>window.closeModal(m.id));const state={focus:document.activeElement,inert:new Map()};for(const sibling of document.body.children){if(sibling===el||sibling.tagName==='SCRIPT'||sibling.classList.contains('toast'))continue;state.inert.set(sibling,sibling.inert);sibling.inert=true;}states.set(id,state);el.inert=false;baseOpen(id);document.body.classList.add('dialog-open');el.setAttribute('role','dialog');el.setAttribute('aria-modal','true');el.setAttribute('aria-label',el.querySelector('h2')?.textContent||'Portal dialog');focusableWithin(el)[0]?.focus();syncFilm();};
 window.closeModal=function(id){const el=document.getElementById(id);if(!el)return;el.querySelectorAll('video').forEach(v=>v.pause());baseClose(id);const state=states.get(id);if(state){state.inert.forEach((value,sibling)=>sibling.inert=value);states.delete(id);document.body.classList.remove('dialog-open');state.focus?.isConnected&&state.focus.focus();}if(id==='detail')el.querySelector('.modalbox').style.width='';syncFilm();};
 document.addEventListener('keydown',event=>{const modal=document.querySelector('.psut-modal.show');if(modal){if(event.key==='Escape'){event.preventDefault();closeModal(modal.id);}if(event.key==='Tab'){const f=focusableWithin(modal);if(!f.length)return;if(event.shiftKey&&document.activeElement===f[0]){event.preventDefault();f.at(-1).focus();}else if(!event.shiftKey&&document.activeElement===f.at(-1)){event.preventDefault();f[0].focus();}}}else if(event.key==='Escape'&&menu.classList.contains('show')){bootstrap.Collapse.getOrCreateInstance(menu).hide();trigger.focus();}});
 document.querySelectorAll('.psut-modal').forEach(modal=>modal.addEventListener('click',event=>{if(event.target===modal)closeModal(modal.id);}));
})();

/* Start the process film once in view; native controls own subsequent play/pause. */
(()=>{
 const film=document.getElementById('internshipProcessVideo');
 if(!film)return;
 const reduced=matchMedia('(prefers-reduced-motion: reduce)');
 if(reduced.matches){film.autoplay=false;film.pause();return;}
 const observer=new IntersectionObserver(entries=>{
  if(!entries[0].isIntersecting)return;
  film.play().catch(()=>{});
  observer.disconnect();
 },{threshold:.25});
 film.autoplay=false;
 observer.observe(film);
})();

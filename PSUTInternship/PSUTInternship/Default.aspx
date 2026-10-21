<%@ Page Language="C#" MasterPageFile="~/Public.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PSUTInternship._Default" %>
<asp:Content ID="PageBody" ContentPlaceHolderID="MainContent" runat="server">
<a class="skip-link" href="#main-content">Skip to content</a>
<header class="well-header" id="top">
<a class="well-logo" href="#home" aria-label="PSUT Internship Portal home"><img src="<%= ResolveUrl("~/Assets/") %>psut-logo.jpg" alt="Princess Sumaya University for Technology"><span>INTERNSHIP<br>PORTAL</span></a>
<nav class="desktop-nav" aria-label="Primary navigation"><a href="#opportunities">Opportunities</a><a href="#journey">Your journey</a><a href="#our-psut">Life at PSUT</a></nav>
<div class="well-actions"><button class="header-contact" onclick="showContact()">Contact</button><button class="header-signin" onclick="openModal('login')">Sign in <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button><button class="well-menu-button" id="wellMenuButton" aria-label="Open menu" aria-expanded="false" aria-controls="wellMenu" onclick="toggleWellMenu()"><i></i><i></i></button></div>
</header>
<div class="well-menu-scrim" onclick="toggleWellMenu(false)"></div>
<aside id="wellMenu" class="well-menu" role="dialog" aria-modal="true" aria-label="Main navigation" inert>
<button class="menu-close" onclick="toggleWellMenu(false)" aria-label="Close menu"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button><nav>
<details>
<summary>About PSUT</summary>
<a href="#welcome" onclick="toggleWellMenu(false)">Our internship purpose</a>
<a href="#community" onclick="toggleWellMenu(false)">King Hussein School of Computing Sciences</a>
<a href="#values" onclick="toggleWellMenu(false)">Placement principles</a>
</details>
<details>
<summary>Internship opportunities</summary>
<a href="#opportunities" onclick="toggleWellMenu(false)">Explore openings</a>
<a href="#journey" onclick="toggleWellMenu(false)">How applications work</a>
</details>
<details>
<summary>Students</summary>
<button onclick="previewRole('student')">Student dashboard</button>
<a href="#journey" onclick="toggleWellMenu(false)">Tasks, hours & feedback</a>
<a href="#where-next" onclick="toggleWellMenu(false)">Your next step</a>
</details>
<details>
<summary>Company supervisors</summary>
<button onclick="previewRole('company')">Company workspace</button>
<a href="#journey" onclick="toggleWellMenu(false)">Opportunities & evaluations</a>
</details>
<details>
<summary>College supervisors</summary>
<button onclick="previewRole('academic')">Academic workspace</button>
<a href="#journey" onclick="toggleWellMenu(false)">Monitor student progress</a>
</details>
<details>
<summary>Internship coordinator</summary>
<button onclick="previewRole('admin')">Coordinator workspace</button>
<a href="#journey" onclick="toggleWellMenu(false)">Accounts & completion review</a>
</details>
<a href="#our-psut" onclick="toggleWellMenu(false)">Campus life</a>
<a href="#opportunities" onclick="toggleWellMenu(false)">What’s new</a>
<button onclick="toggleWellMenu(false);showContact()">Contact</button>
</nav>
<div class="well-menu-secondary">
<button onclick="toggleWellMenu(false);watchCampus()">Watch the campus film</button>
<a href="#journey" onclick="toggleWellMenu(false)">Internship process</a>
<a href="#community" onclick="toggleWellMenu(false)">Our community</a>
<a href="#opportunities" onclick="toggleWellMenu(false)">Available opportunities</a>
</div>
<form class="menu-search" role="search" onsubmit="event.preventDefault();menuSearch()">
<input aria-label="Search opportunities in menu" placeholder="Search opportunities" id="menuSearch">
<button type="submit" aria-label="Search"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg></button></form>
</aside><main id="main-content" tabindex="-1"><div id="landing"><section class="well-home" id="home" aria-labelledby="hero-title">
<div class="hero-film"><video id="introVideo" muted loop playsinline preload="metadata" poster="<%= ResolveUrl("~/Assets/") %>psut-rooftop.jpg" aria-label="PSUT campus film"><source src="<%= ResolveUrl("~/Assets/") %>psut-2025.mp4" type="video/mp4"></video><div class="hero-shade"></div></div>

<button class="film-toggle" id="introPlayback" onclick="toggleIntroPlayback()" aria-label="Play campus background film"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 6 10 6-10 6Z"/></svg><span>Play film</span></button>
<a class="hero-scroll" href="#welcome" aria-label="Explore your internship portal">Scroll to explore <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></a>
<div class="hero-copy"><h1 id="hero-title">Realise your<br>potential.</h1><div class="hero-bottom"><p>We believe your potential grows through real experience,<br class="well-desktop"> meaningful challenges, and the right support.</p><div class="hero-buttons"><a class="well-pill" href="#opportunities">Explore opportunities <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></a><a class="hero-secondary" href="#where-next">Find your workspace <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></a></div></div></div></section><section class="well-welcome" id="welcome">
<h2>Your next <br><em>chapter.</em></h2>
<div class="welcome-content">
<p class="huge-statement">Bring your ambition. Build your experience. Become who you are ready to be.</p>


</div>
</section><section class="well-experience" id="experience"><div class="collage-scroll"><div class="campus-collage"><div class="collage-side"><article class="mosaic-photo">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-students.jpeg" alt="PSUT students and staff gathered in a university auditorium">
<span>Learn by doing.</span>
</article><article class="mosaic-photo">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-walkway.jpg" alt="A tree-lined walkway on the PSUT campus">
<span>Your ambition.<br>Your direction.</span>
</article></div><figure class="collage-center"><img src="<%= ResolveUrl("~/Assets/") %>psut-aerial.jpg" alt="An elevated view of the PSUT campus gardens and entrance" loading="lazy"><figcaption>Princess Sumaya University for Technology</figcaption></figure><div class="collage-side"><article class="mosaic-photo">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-community.jpeg" alt="Students taking part in a PSUT welcome event">
<span>Think creatively.<br>Make an impact.</span>
</article><div class="collage-note">Real tasks.<br>Useful feedback.<br>Skills that grow.</div></div></div></div><div class="experience-caption"><div><p class="welcome-description">Your PSUT internship connects what you learn with what you can do. Discover a placement, receive guidance from your company and college supervisors, and follow every step of your training in one place.</p></div><div class="welcome-attribution">
<div class="coordinator-avatar">PSUT</div>
<div>
<b>Your internship office</b>
<span>King Hussein School of Computing Sciences</span>
</div>
<a class="well-pill" href="#journey">Meet your journey <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</a>
</div></div></section><section class="well-next" id="where-next">
<div class="section-heading"><h2>Where next?</h2><p>One team. Four connected roles.</p></div>
<div class="role-tabs" role="tablist" aria-label="Choose your workspace"><button id="role-tab-student" role="tab" aria-selected="true" aria-controls="role-student" tabindex="0" onclick="selectRole(0)">Students</button><button id="role-tab-company" role="tab" aria-selected="false" aria-controls="role-company" tabindex="-1" onclick="selectRole(1)">Company supervisors</button><button id="role-tab-academic" role="tab" aria-selected="false" aria-controls="role-academic" tabindex="-1" onclick="selectRole(2)">College supervisors</button><button id="role-tab-admin" role="tab" aria-selected="false" aria-controls="role-admin" tabindex="-1" onclick="selectRole(3)">Internship coordinator</button></div><div class="next-grid" aria-live="polite">
<article class="next-panel" id="role-student" role="tabpanel" aria-labelledby="role-tab-student">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-walkway.jpg" alt="A tree-lined walkway on the PSUT campus">
<div class="next-content">
<h3>Students </h3><p>Discover a placement, receive guidance from your company and college supervisors, and follow every step of your training in one place.</p>
<div class="next-links">
<button onclick="previewRole('student')">My dashboard ›</button>
<a href="#opportunities">Explore opportunities ›</a>
<a href="#journey">Tasks, hours & feedback ›</a>
</div>
</div>
</article>
<article class="next-panel" id="role-company" role="tabpanel" aria-labelledby="role-tab-company" hidden>
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-students.jpeg" alt="PSUT students and staff gathered in a university auditorium">
<div class="next-content">
<h3>Company supervisors </h3><p>Company supervisors manage opportunities and work.</p>
<div class="next-links">
<button onclick="previewRole('company')">Company workspace ›</button>
<a href="#journey">Guide your trainees ›</a>
</div>
</div>
</article>
<article class="next-panel" id="role-academic" role="tabpanel" aria-labelledby="role-tab-academic" hidden>
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-community.jpeg" alt="Students taking part in a PSUT welcome event">
<div class="next-content">
<h3>College supervisors </h3><p>The college supervisor monitors tasks, submissions, feedback, training hours, and progress. Academic comments help you develop.</p>
<div class="next-links">
<button onclick="previewRole('academic')">Academic workspace ›</button>
<a href="#journey">Monitor student progress ›</a>
</div>
</div>
</article>
<article class="next-panel" id="role-admin" role="tabpanel" aria-labelledby="role-tab-admin" hidden>
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-aerial.jpg" alt="The PSUT campus gardens and entrance">
<div class="next-content">
<h3>Internship coordinator </h3><p>One internship coordinator creates accounts, assigns supervisors, and approves final completion.</p>
<div class="next-links">
<button onclick="previewRole('admin')">Coordinator workspace ›</button>
<a href="#journey">Verify completion ›</a>
</div>
</div>
</article>
</div>
</section><section class="well-news" id="opportunities">
<div class="section-heading"><h2 class="oversize-title">What’s next</h2><a class="text-link" href="#opportunity-search">Explore openings <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></a></div>
<div class="news-heading">
<h3>Your next opportunity.</h3>
<p>Illustrative openings · Sign in to view full details and apply.</p>
</div>
<div class="news-feature-grid">
<article class="opportunity-carousel">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-students.jpeg" alt="PSUT students and staff gathered in a university auditorium" id="opportunityImage">
<div class="opportunity-gradient">
</div>
<div class="opportunity-copy">
<h3 id="featuredOppTitle">Software Engineering Intern</h3>
<p id="featuredOppMeta">ProgressSoft · Amman · Hybrid</p>
<button class="well-pill" onclick="showDetail(featuredOppId)">View opportunity <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</button>
</div>
<div class="carousel-dots" aria-label="Choose featured opportunity">
<button class="active" aria-pressed="true" aria-label="Opportunity 1" onclick="setFeaturedOpportunity(0)">
</button>
<button aria-pressed="false" aria-label="Opportunity 2" onclick="setFeaturedOpportunity(1)">
</button>
<button aria-pressed="false" aria-label="Opportunity 3" onclick="setFeaturedOpportunity(2)">
</button>
</div>
</article>
<article class="news-side">
<h3>Ready for your<br> next chapter?</h3>
<p>Your internship coordinator creates your account and assigns your college supervisor.</p>
<ul>
<li>Browse opportunities publicly</li>
<li>Sign in to see details and apply</li>
<li>Choose one accepted offer</li>
</ul>
<button class="well-pill" onclick="openModal('login')">Sign in to your portal <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</button>
</article>
</div>
<form class="opportunity-tools" id="opportunity-search" role="search" onsubmit="event.preventDefault();searchOpps()">
<input id="heroSearch" placeholder="Search opportunities" aria-label="Search opportunities">
<button type="submit" aria-label="Search internships"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg></button></form><p id="searchStatus" class="search-status" role="status" aria-live="polite"></p>
<div class="cards" id="publicCards">
</div>

</section><section class="facts-section" aria-labelledby="facts-title"><div class="section-heading"><div><h2 id="facts-title">The internship experience.</h2><p>One shared goal. A clear process.</p></div><div class="rail-controls"><button onclick="scrollFacts(-1)" aria-label="Previous internship facts"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button><button onclick="scrollFacts(1)" aria-label="Next internship facts"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button></div></div><div id="internship-facts" class="experience-facts" tabindex="0" role="region" aria-label="Internship facts; scroll horizontally to explore"><article class="mosaic-card sky">
<strong>4</strong>
<p>roles connected around<br>your internship journey</p>
<button class="well-pill" onclick="document.getElementById('roleStory').open=true;document.getElementById('roleStory').scrollIntoView({behavior:'smooth'})">One community <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</button>
</article><article class="mosaic-card pale">
<strong class="outline-number">1</strong>
<p>internship offer<br>you choose and confirm</p>
<a class="well-pill" href="#opportunities">Your next opportunity <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</a>
</article><article class="mosaic-card navy">
<p class="mosaic-quote">Real tasks.<br>Useful feedback.<br>Skills that grow.</p>
<a class="well-pill" href="#journey">Your training <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</a>
</article><article class="mosaic-card blue">
<strong>2</strong>
<p>supervisor evaluations<br>before the coordinator’s<br>completion review</p>
<a class="well-pill" href="#values">A clear process <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</a>
</article><article class="mosaic-card pale">
<strong>5</strong>
<p>computing specializations.<br>Many possibilities.</p>
<a class="well-pill" href="#community">Explore your college <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</a>
</article><article class="mosaic-card sky">
<p class="mosaic-quote">A company mentor.<br>An academic guide.<br>One shared goal.</p>
<a class="well-pill" href="#where-next">Find your workspace <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</a>
</article></div><p class="rail-hint">Drag to explore <span aria-hidden="true">↔</span></p></section><section class="well-community" id="our-psut">
<div class="section-heading"><h2>The PSUT experience.</h2><a href="https://www.psut.edu.jo/ar/media" target="_blank" rel="noopener" class="text-link">Official photo gallery <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></a></div><h3 class="campus-tag">#OurPSUT</h3>
<button class="community-feature" onclick="watchCampus()" aria-label="Watch PSUT campus film">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-entrance.jpg" alt="The illuminated PSUT campus entrance at night">
<span class="well-play"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 5 12 7-12 7Z"/></svg></span>
<span class="feature-caption">Discover everyday life at PSUT.</span>
</button>
<div class="community-clips">
<button onclick="watchCampus(4)">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-walkway.jpg" alt="A tree-lined walkway on the PSUT campus">
<span class="well-play small-play"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 5 12 7-12 7Z"/></svg></span>
<b>Finding your way</b>
</button>
<button onclick="watchCampus(9)">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-students.jpeg" alt="PSUT students and staff gathered in a university auditorium">
<span class="well-play small-play"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 5 12 7-12 7Z"/></svg></span>
<b>Making connections</b>
</button>
<button onclick="watchCampus(20)">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-community.jpeg" alt="Students taking part in a PSUT welcome event">
<span class="well-play small-play"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 5 12 7-12 7Z"/></svg></span>
<b>Building your future</b>
</button>
</div>
<div class="photo-strip">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-walkway.jpg" alt="A tree-lined walkway on the PSUT campus">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-students.jpeg" alt="PSUT students and staff gathered in a university auditorium">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-welcome.jpeg" alt="A welcome gathering in a PSUT auditorium">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-community.jpeg" alt="Students taking part in a PSUT welcome event">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-graduation.jpg" alt="Graduation celebrations at PSUT">
</div>
<a class="community-label" href="#our-psut">#OurPSUT <span>Explore the campus ↑</span>
</a></section><section class="well-stories" id="journey"><div class="section-heading"><h2>Your training journey.</h2><p>Big ambitions. Personal guidance.</p></div>
<details>
<summary>
<b>Your support system</b><span class="story-original">Big. Small.</span><span class="story-description">Big ambitions. Personal guidance.</span>
<i aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 4v16M4 12h16"/></svg></i>
</summary>
<div class="story-expanded">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-walkway.jpg" alt="A tree-lined walkway on the PSUT campus">
<div>
<h3>Your journey has a clear support system.</h3>
<p>The coordinator assigns your student group to a college supervisor from account setup. Once your placement is confirmed, you can see your company supervisor and academic supervisor throughout your training.</p>
<button class="well-pill" onclick="previewRole('student')">Student workspace <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</button>
</div>
</div>
</details>
<details>
<summary>
<b>Find your placement</b><span class="story-original">Everything. Anything.</span><span class="story-description">Your skills. Your possibilities.</span>
<i aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 4v16M4 12h16"/></svg></i>
</summary>
<div class="story-expanded">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-students.jpeg" alt="PSUT students and staff gathered in a university auditorium">
<div>
<h3>Find a placement that fits your specialization.</h3>
<p>Browse public opportunity summaries. Sign in to view full details and apply. Companies review applications, provide decisions, and explain rejections. You can apply to more than one opportunity, then confirm only one accepted offer.</p>
<a class="well-pill" href="#opportunities">Explore opportunities <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</a>
</div>
</div>
</details>
<details>
<summary>
<b>Track training hours</b><span class="story-original">Time. Space.</span><span class="story-description">Your hours. Your progress.</span>
<i aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 4v16M4 12h16"/></svg></i>
</summary>
<div class="story-expanded">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-welcome.jpeg" alt="A welcome gathering in a PSUT auditorium">
<div>
<h3>Make every approved training hour count.</h3>
<p>Follow your tasks, deadlines and placement progress. Training hours follow supervisor approval; completing a task does not automatically approve hours. Your college’s official requirements determine the hours needed for completion.</p>
<button class="well-pill" onclick="previewRole('student')">Track your progress <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</button>
</div>
</div>
</details>
<details>
<summary>
<b>Tasks and feedback</b><span class="story-original">Human. Intelligence.</span><span class="story-description">Learn. Apply. Improve.</span>
<i aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 4v16M4 12h16"/></svg></i>
</summary>
<div class="story-expanded">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-community.jpeg" alt="Students taking part in a PSUT welcome event">
<div>
<h3>Learning becomes experience through action.</h3>
<p>Your company supervisor assigns tasks with deadlines and evaluation criteria. Submit a description, file, or link. Review your grade and feedback, respond to revision requests, and keep a clear history of your work.</p>
<button class="well-pill" onclick="previewRole('company')">Company workspace <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</button>
</div>
</div>
</details>
<details>
<summary>
<b>Supervisor evaluations</b><span class="story-original">Perspective. Purpose.</span><span class="story-description">Feedback that moves you forward.</span>
<i aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 4v16M4 12h16"/></svg></i>
</summary>
<div class="story-expanded">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-students.jpeg" alt="PSUT students and staff gathered in a university auditorium">
<div>
<h3>Support from both sides of your placement.</h3>
<p>The college supervisor monitors tasks, submissions, feedback, training hours, and progress. Academic comments help you develop. The company and college supervisors submit their final evaluations for the coordinator’s review.</p>
<button class="well-pill" onclick="previewRole('academic')">College workspace <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</button>
</div>
</div>
</details>
<details id="roleStory">
<summary>
<b>Your connected team</b><span class="story-original">All. Together.</span><span class="story-description">One team. Four connected roles.</span>
<i aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 4v16M4 12h16"/></svg></i>
</summary>
<div class="story-expanded">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-graduation.jpg" alt="Graduation celebrations at PSUT">
<div>
<h3>Every step has a person responsible for it.</h3>
<p>Students apply and train. Company supervisors manage opportunities and work. College supervisors provide academic oversight. One internship coordinator creates accounts, assigns supervisors, and approves final completion.</p>
<a class="well-pill" href="#where-next">Choose your workspace <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</a>
</div>
</div>
</details>
<details>
<summary>
<b>Completion and reports</b><span class="story-original">Above. Beyond.</span><span class="story-description">Experience that carries you forward.</span>
<i aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 4v16M4 12h16"/></svg></i>
</summary>
<div class="story-expanded">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-rooftop.jpg" alt="PSUT campus buildings and Amman skyline">
<div>
<h3>A completion report with a verified process.</h3>
<p>After both final evaluations are received and the university requirements are verified, the coordinator approves completion and releases your official report for download and printing. Submitted supervisor final evaluations remain confidential.</p>
<button class="well-pill" onclick="previewRole('admin')">Completion review <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</button>
</div>
</div>
</details>
</section><section class="well-values" id="values">
<h2>Our principles.</h2>
<div class="values-content">
<h3>A successful placement grows through clear responsibilities and a shared commitment to learning.</h3>
<div class="values-list">
<span>Integrity.</span>
<span>Responsibility.</span>
<span>Curiosity.</span>
<span>Collaboration.</span>
<span>Growth.</span>
</div>
<p>Know who guides you, what you need to complete, and how your work is reviewed. Your learning stays at the heart of the experience.</p>
<a class="well-pill" href="#journey">How your journey works <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</a>
</div>
</section><section class="well-college" id="community">

<h2>King Hussein School<br>of Computing Sciences</h2>
<div class="major-list">
<span>Computer Science</span>
<span>Software Engineering</span>
<span>Computer Graphics & Animation</span>
<span>Data Science & Artificial Intelligence</span>
<span>Cybersecurity</span>
</div>
</section></div></main><footer class="well-footer" id="contact">
<div class="footer-grid">
<div class="footer-mission">
<h3>
<span>Learning with purpose.</span>
<br>
<span>Experience that opens</span>
<br>
<span>your next chapter.</span>
</h3>
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-logo.jpg" alt="Princess Sumaya University for Technology">
</div>
<div>
<h3>Get in touch</h3>
<p>Princess Sumaya University<br>for Technology<br>Khalil Saket Street<br>Al-Jubeiha, Amman<br>Jordan</p>
<a href="mailto:info@psut.edu.jo">info@psut.edu.jo</a>
<a href="tel:+96265359949">+962 6 535 9949</a>
<button class="well-pill" onclick="showContact()">Contact the office <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</button>
</div>
<div>
<h3>Helpful links</h3>
<div class="footer-useful">
<a href="#opportunities">Internship opportunities</a>
<a href="#journey">The training journey</a>
<button onclick="openModal('login')">Portal sign in</button>
<a href="#community">Our college</a>
<a href="#values">Placement principles</a>
<button onclick="watchCampus()">Campus film</button>
</div>
<div class="footer-identity">جامعة الأميرة سمية للتكنولوجيا<br>
<b>PSUT</b>
<span>INTERNSHIP PORTAL</span>
</div>
</div>
</div>
<div class="footer-wordmark" aria-hidden="true">PSUT</div><div class="well-fineprint">
<span>© 2026 PSUT Internship Portal · Academic project prototype</span>
<span>Sample openings and training figures are illustrative. Official requirements are configured by the internship office.</span>
<a href="#home">Back to top ↑</a>
</div>
</footer>
<nav class="mobile-dock" aria-label="Quick navigation"><a href="#opportunities" aria-label="Internship opportunities"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><rect x="4" y="7" width="16" height="13" rx="2"/><path d="M9 7V4h6v3M4 12h16M10 12v3h4v-3"/></svg></a><a href="#opportunity-search" aria-label="Search opportunities"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg></a><button class="dock-menu" aria-label="Open menu" aria-controls="wellMenu" aria-expanded="false" onclick="toggleWellMenu()"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M3 7h18M3 17h18"/></svg></button><a href="#where-next" aria-label="Your workspace"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg></a><button onclick="watchCampus()" aria-label="Watch campus film"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="m10 8 6 4-6 4Z"/></svg></button></nav>
</asp:Content>

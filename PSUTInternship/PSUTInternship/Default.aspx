<%@ Page Language="C#" MasterPageFile="~/Public.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PSUTInternship._Default" %>
<asp:Content ID="PageBody" ContentPlaceHolderID="MainContent" runat="server">
<a class="skip-link" href="#main-content">Skip to content</a>
<header class="well-header" id="top">
<a class="well-logo" href="#home" aria-label="PSUT Internship Portal home"><img src="<%= ResolveUrl("~/Assets/") %>psut-logo.jpg" alt="Princess Sumaya University for Technology"><span>INTERNSHIP<br>PORTAL</span></a>
<nav class="desktop-nav d-none d-lg-flex" aria-label="Primary navigation"><a href="#opportunities">Opportunities</a><a href="#where-next">Your workspace</a><a href="#our-psut">Life at PSUT</a></nav>
<div class="well-actions"><button class="header-contact" onclick="showContact()">Contact</button><button class="header-signin" onclick="openModal('login')">Sign in <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button><button class="mobile-nav-toggle d-lg-none" type="button" data-bs-toggle="collapse" data-bs-target="#mobilePrimaryNav" aria-controls="mobilePrimaryNav" aria-expanded="false">Menu</button></div>
<div class="collapse site-mobile-nav d-lg-none" id="mobilePrimaryNav"><nav class="container-fluid py-3" aria-label="Mobile primary navigation"><a href="#opportunities">Opportunities</a><a href="#where-next">Your workspace</a><a href="#our-psut">Life at PSUT</a><a href="#contact-us">Contact us</a></nav></div>
</header>
<main id="main-content" tabindex="-1"><div id="landing"><section class="well-home" id="home" aria-label="PSUT campus film">
<div class="hero-scroll-stage position-relative"><div class="hero-sticky position-sticky top-0 min-vh-100 overflow-hidden"><div class="hero-film position-absolute top-0 start-0 w-100 h-100 overflow-hidden bg-dark"><video class="position-absolute top-0 start-0 w-100 h-100 object-fit-cover" id="introVideo" autoplay muted loop playsinline preload="metadata" poster="<%= ResolveUrl("~/Assets/") %>psut-rooftop.jpg" aria-label="PSUT campus film"><source src="<%= ResolveUrl("~/Assets/") %>psut-2025.mp4" type="video/mp4"></video></div>
</div></div>
</section><section class="well-welcome" id="welcome">
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
<a class="well-pill" href="#where-next">Find your workspace <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
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
<a href="#where-next">Tasks, hours & feedback ›</a>
</div>
</div>
</article>
<article class="next-panel" id="role-company" role="tabpanel" aria-labelledby="role-tab-company" hidden>
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-students.jpeg" alt="PSUT students and staff gathered in a university auditorium">
<div class="next-content">
<h3>Company supervisors </h3><p>Company supervisors manage opportunities and work.</p>
<div class="next-links">
<button onclick="previewRole('company')">Company workspace ›</button>
<a href="#where-next">Guide your trainees ›</a>
</div>
</div>
</article>
<article class="next-panel" id="role-academic" role="tabpanel" aria-labelledby="role-tab-academic" hidden>
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-community.jpeg" alt="Students taking part in a PSUT welcome event">
<div class="next-content">
<h3>College supervisors </h3><p>The college supervisor monitors tasks, submissions, feedback, training hours, and progress. Academic comments help you develop.</p>
<div class="next-links">
<button onclick="previewRole('academic')">Academic workspace ›</button>
<a href="#where-next">Monitor student progress ›</a>
</div>
</div>
</article>
<article class="next-panel" id="role-admin" role="tabpanel" aria-labelledby="role-tab-admin" hidden>
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-aerial.jpg" alt="The PSUT campus gardens and entrance">
<div class="next-content">
<h3>Internship coordinator </h3><p>One internship coordinator creates accounts, assigns supervisors, and approves final completion.</p>
<div class="next-links">
<button onclick="previewRole('admin')">Coordinator workspace ›</button>
<a href="#where-next">Verify completion ›</a>
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
<div class="rail-hint"><span>Drag to explore opportunities</span><button type="button" aria-label="Previous opportunities" onclick="scrollOpportunityCards(-1)"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button><button type="button" aria-label="Next opportunities" onclick="scrollOpportunityCards(1)"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button></div><div class="cards" id="publicCards" data-drag-rail tabindex="0" role="region" aria-label="Opportunity cards; drag or use arrow keys to explore">
</div>

</section><section class="facts-section" aria-labelledby="facts-title"><div class="section-heading"><div><h2 id="facts-title">The internship experience.</h2><p>One shared goal. A clear process.</p></div><div class="rail-controls"><button onclick="scrollFacts(-1)" aria-label="Previous internship facts"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button><button onclick="scrollFacts(1)" aria-label="Next internship facts"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button></div></div><div id="internship-facts" data-drag-rail class="experience-facts" tabindex="0" role="region" aria-label="Internship facts; scroll horizontally to explore"><article class="mosaic-card sky">
<strong>4</strong>
<p>roles connected around<br>your internship journey</p>
<button class="well-pill" onclick="document.getElementById('where-next').scrollIntoView({behavior:'smooth'})">One community <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</button>
</article><article class="mosaic-card pale">
<strong class="outline-number">1</strong>
<p>internship offer<br>you choose and confirm</p>
<a class="well-pill" href="#opportunities">Your next opportunity <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
</a>
</article><article class="mosaic-card navy">
<p class="mosaic-quote">Real tasks.<br>Useful feedback.<br>Skills that grow.</p>
<a class="well-pill" href="#where-next">Your training <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
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
<div class="photo-strip" data-drag-rail tabindex="0" role="region" aria-label="PSUT photo gallery; drag or use arrow keys to explore">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-walkway.jpg" alt="A tree-lined walkway on the PSUT campus">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-students.jpeg" alt="PSUT students and staff gathered in a university auditorium">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-welcome.jpeg" alt="A welcome gathering in a PSUT auditorium">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-community.jpeg" alt="Students taking part in a PSUT welcome event">
<img loading="lazy" src="<%= ResolveUrl("~/Assets/") %>psut-graduation.jpg" alt="Graduation celebrations at PSUT">
</div>
<a class="community-label" href="#our-psut">#OurPSUT <span>Explore the campus ↑</span>
</a></section><section class="well-values" id="values">
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
<a class="well-pill" href="#where-next">Explore the workspaces <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>
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
</section></div><section class="contact-feature position-relative overflow-hidden text-white" id="contact-us" aria-labelledby="contact-feature-title">
<img class="contact-feature-image position-absolute top-0 start-0 w-100 h-100 object-fit-cover" src="<%= ResolveUrl("~/Assets/") %>psut-aerial.jpg" alt="" aria-hidden="true" loading="lazy">
<div class="contact-feature-shade position-absolute top-0 start-0 w-100 h-100 bg-dark bg-opacity-50" aria-hidden="true"></div>
<div class="container position-relative py-5">
<div class="row align-items-center justify-content-between gy-5 py-lg-5">
<div class="col-lg-6">
<span class="badge rounded-pill text-bg-light text-primary mb-4 px-3 py-2">PSUT Internship Office</span>
<h2 class="display-4 fw-bold lh-sm mb-4" id="contact-feature-title">Questions about your internship?</h2>
<p class="fs-5 text-white-50 mb-0">From applications to training hours and supervisor support, our team can help you find your next step.</p>
</div>
<div class="col-lg-6 col-xl-5">
<div class="card contact-feature-card border-0 rounded-4 shadow-lg text-dark">
<div class="card-body p-4 p-xl-5">
<p class="text-uppercase text-primary fw-bold small mb-2">Get in touch</p>
<h3 class="h2 fw-bold mb-4">We’re here to help.</h3>
<div class="d-grid gap-4">
<div class="d-flex align-items-center gap-3"><span class="contact-feature-icon rounded-circle bg-primary-subtle text-primary d-inline-flex align-items-center justify-content-center flex-shrink-0"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 6h16v12H4zM4 7l8 6 8-6"/></svg></span><div><span class="d-block text-secondary small">Email</span><a class="fw-semibold text-decoration-none" href="mailto:info@psut.edu.jo">info@psut.edu.jo</a></div></div>
<div class="d-flex align-items-center gap-3"><span class="contact-feature-icon rounded-circle bg-primary-subtle text-primary d-inline-flex align-items-center justify-content-center flex-shrink-0"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M7 3h3l2 5-2 2a14 14 0 0 0 4 4l2-2 5 2v3a2 2 0 0 1-2 2A16 16 0 0 1 5 5a2 2 0 0 1 2-2Z"/></svg></span><div><span class="d-block text-secondary small">Call the office</span><a class="fw-semibold text-decoration-none" href="tel:+96265359949">+962 6 535 9949</a></div></div>
<div class="d-flex align-items-center gap-3"><span class="contact-feature-icon rounded-circle bg-primary-subtle text-primary d-inline-flex align-items-center justify-content-center flex-shrink-0"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M20 10c0 5-8 11-8 11S4 15 4 10a8 8 0 1 1 16 0Z"/><circle cx="12" cy="10" r="2.5"/></svg></span><div><span class="d-block text-secondary small">Visit us</span><span class="fw-semibold">Khalil Saket Street, Al-Jubeiha, Amman</span></div></div>
</div>
<button class="btn btn-primary btn-lg rounded-pill w-100 mt-4" type="button" onclick="showContact()">Send a message <svg class="ms-2" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button>
<p class="small text-secondary mt-3 mb-0">Messages are saved in this browser prototype. For a direct reply, email or call the office.</p>
</div></div>
</div></div></div>
</section><div class="contact-feature-helper position-fixed bottom-0 end-0 p-3 p-md-4"><button class="btn btn-primary btn-lg rounded-pill shadow" type="button" onclick="showContact()">Questions? <span class="ms-1">Contact us</span><span class="contact-status-dot ms-2" aria-hidden="true"></span></button></div></main><footer class="well-footer" id="contact">
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
<a href="#where-next">Choose your workspace</a>
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
</asp:Content>

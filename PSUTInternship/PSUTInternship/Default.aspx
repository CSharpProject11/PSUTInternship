<%@ Page Language="C#" Async="true" MasterPageFile="~/Public.Master" AutoEventWireup="true" ClientIDMode="Static" CodeBehind="Default.aspx.cs" Inherits="PSUTInternship._Default" %>

<asp:Content ID="PageBody" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HyperLink runat="server" ID="HomeLink1" CssClass="skip-link" NavigateUrl="#main-content">Skip to content</asp:HyperLink>
    <header class="campus-header" id="top">
        <asp:HyperLink runat="server" ID="HomeLink2" NavigateUrl="#home" CssClass="campus-brand" aria-label="PSUT Internship Portal home">
            <asp:Image runat="server" ID="HomeImage1" ImageUrl="~/Assets/psut-logo-bilingual.png" AlternateText="Princess Sumaya University for Technology" /></asp:HyperLink>
        <nav class="campus-nav d-none d-lg-flex" aria-label="Main navigation"><asp:HyperLink runat="server" ID="HomeLink3" NavigateUrl="#discover">About PSUT</asp:HyperLink><asp:HyperLink runat="server" ID="HomeLink4" NavigateUrl="#opportunities">Opportunities</asp:HyperLink><asp:HyperLink runat="server" ID="HomeLink5" NavigateUrl="#our-psut">Internship process</asp:HyperLink></nav>
        <div class="header-actions"><asp:HyperLink runat="server" ID="HomeLink6" CssClass="header-login" NavigateUrl="~/Login.aspx">Portal sign in <span aria-hidden="true">↗</span></asp:HyperLink>
            <button runat="server" ID="HomeButton1" type="button" class="menu-toggle d-lg-none" data-bs-toggle="collapse" data-bs-target="#mobilePrimaryNav" aria-controls="mobilePrimaryNav" aria-expanded="false">Menu <span class="menu-lines" aria-hidden="true"></span></button>
        </div>
        <div class="collapse mobile-primary" id="mobilePrimaryNav">
            <nav aria-label="Mobile navigation"><asp:HyperLink runat="server" ID="HomeLink7" NavigateUrl="#discover">About PSUT</asp:HyperLink><asp:HyperLink runat="server" ID="HomeLink8" NavigateUrl="#opportunities">Opportunities</asp:HyperLink><asp:HyperLink runat="server" ID="HomeLink9" NavigateUrl="#our-psut">Internship process</asp:HyperLink><asp:HyperLink runat="server" ID="HomeLink10" NavigateUrl="#contact">Contact</asp:HyperLink></nav>
        </div>
    </header>
    <main id="main-content" tabindex="-1">
        <section class="campus-opening" id="home" aria-labelledby="HomeTitle">
            <div class="film-frame">
                <asp:Image runat="server" ID="HomeImage2" CssClass="film-poster" ImageUrl="~/Assets/psut-rooftop.jpg" AlternateText="PSUT campus in Al-Jubeiha, Amman" fetchpriority="high" /><video id="introVideo" class="campus-film" autoplay muted loop playsinline preload="metadata" poster="<%= ResolveUrl("~/Assets/psut-rooftop.jpg") %>" aria-label="A film of the Princess Sumaya University for Technology campus">
                    <source src="<%= ResolveUrl("~/Assets/psut-campus-loop.mp4") %>" type="video/mp4"></video>
                <div class="film-shade" aria-hidden="true"></div>
            </div>
            <div class="opening-copy page-frame">
                <h1 runat="server" id="HomeTitle" data-reveal="">Your next chapter.</h1>
                <div class="opening-description">
                    <p runat="server" ID="HomeHeading2" data-reveal="">Your internship at Princess Sumaya University for Technology. Find your opportunity and follow your next chapter.</p>
                    <asp:HyperLink runat="server" ID="HomeLink11" CssClass="round-link" NavigateUrl="#opportunities" data-reveal="">Find your opportunity <span aria-hidden="true">↗</span></asp:HyperLink></div>
                <asp:HyperLink runat="server" ID="HomeLink12" NavigateUrl="#discover" CssClass="scroll-cue" aria-label="Scroll to About PSUT"><span aria-hidden="true">↓</span></asp:HyperLink></div>
        </section>
        <section class="discovery" id="discover" aria-labelledby="DiscoverTitle">
            <div class="discovery-intro page-frame">
                <h2 runat="server" id="DiscoverTitle" data-reveal="">About PSUT.</h2>
                <p runat="server" ID="HomeHeading4" data-reveal="">Founded in 1991 in Amman, Princess Sumaya University for Technology is the academic arm of the Royal Scientific Society, bringing education, research and technology together.</p>
            </div>
            <div class="about-psut-details page-frame">
                <div data-reveal="">
                    <h3>A foundation in technology.</h3>
                    <p>PSUT began with a single bachelor’s degree in Computer Science. It has since grown to offer undergraduate and postgraduate study across computing, engineering and business.</p>
                </div>
                <div data-reveal="">
                    <h3>Learning that looks ahead.</h3>
                    <p>From software engineering and communications to data science, artificial intelligence and cyber security, the university’s development reflects the changing world of technology.</p>
                </div>
                <div data-reveal="">
                    <h3>Knowledge with purpose.</h3>
                    <p>As part of the Royal Scientific Society’s academic mission, PSUT connects scientific knowledge with technical skills, research and innovation, preparing graduates to contribute in Jordan and beyond.</p>
                </div>
            </div>
            <div class="discovery-gallery" aria-label="Life at PSUT in photographs">
                <div class="discovery-gallery-stage">
                    <div class="discovery-photo-column gallery-outer gallery-left"><asp:Image runat="server" ID="HomeImage3" ImageUrl="~/Assets/psut-rooftop.jpg" AlternateText="PSUT rooftops overlooking Amman" loading="lazy" /></div>
                    <div class="discovery-photo-column gallery-inner gallery-left"><asp:Image runat="server" ID="HomeImage4" ImageUrl="~/Assets/psut-walkway.jpg" AlternateText="Sunlight through the trees along the campus walkway" loading="lazy" /><asp:Image runat="server" ID="HomeImage5" ImageUrl="~/Assets/psut-entrance.jpg" AlternateText="The campus entrance illuminated at night" loading="lazy" /></div>
            <figure class="campus-panorama">
                <asp:Image runat="server" ID="HomeImage6" ImageUrl="~/Assets/psut-aerial.jpg" AlternateText="Palm trees, gardens, and the entrance road at the PSUT campus" loading="lazy" /><figcaption><span>A campus full of possibility.</span>
                    <asp:HyperLink runat="server" ID="AboutPanoramaLink" NavigateUrl="https://www.psut.edu.jo/en/about-psut2" target="_blank" rel="noopener" CssClass="light-link">More about PSUT <span aria-hidden="true">↗</span></asp:HyperLink></figcaption></figure>
                    <div class="discovery-photo-column gallery-inner gallery-right"><asp:Image runat="server" ID="HomeImage7" ImageUrl="~/Assets/learning.jpg" AlternateText="Bookshelves in the university library" loading="lazy" /><asp:Image runat="server" ID="HomeImage8" ImageUrl="~/Assets/psut-graduation.jpg" AlternateText="Graduation celebrations in the PSUT courtyard" loading="lazy" /></div>
                    <div class="discovery-photo-column gallery-outer gallery-right"><asp:Image runat="server" ID="HomeImage9" ImageUrl="~/Assets/psut-walkway.jpg" AlternateText="Green gardens and benches on campus" loading="lazy" /></div>
                </div>
            </div>
            <div class="discovery-bottom page-frame">
                <p runat="server" ID="HomeHeading5" data-reveal="">A university in the heart of Jordan.<br>
                    A community looking ahead.</p></div>
        </section>
        <section class="facts-section opportunity-deck-section" id="opportunities" aria-labelledby="OpportunitiesTitle">
            <div class="section-heading page-frame">
                <div><h2 runat="server" id="OpportunitiesTitle" data-reveal="">Find your next opportunity.</h2><p runat="server" ID="HomeHeading7" data-reveal="">Explore internship summaries. Sign in for full details and to apply.</p></div>
                <div class="rail-controls">
                    <button runat="server" ID="HomeButton3" type="button" data-rail="publicCards" data-direction="-1" aria-label="Previous opportunities">←</button>
                    <button runat="server" ID="HomeButton4" type="button" data-rail="publicCards" data-direction="1" aria-label="Next opportunities">→</button>
                </div>
            </div>
            <div runat="server" class="fact-deck experience-facts" id="publicCards" data-drag-rail tabindex="0" role="region" aria-label="Six internship opportunity previews. Drag or use arrow keys." aria-busy="true"></div>
            <p runat="server" class="page-frame opportunity-deck-status" id="searchStatus" role="status" aria-live="polite"></p>
            <p runat="server" ID="HomeHeading9" class="drag-note">Drag to explore opportunities. <span aria-hidden="true">↔</span></p>
        </section>
        <section class="life-section page-frame" id="our-psut" aria-labelledby="LifeTitle">
            <div class="section-heading">
                <div>
                    <h2 runat="server" id="LifeTitle" data-reveal="">Your internship process.</h2>
                    <p runat="server" ID="HomeHeading11" data-reveal="">See how to start and follow your internship journey.</p>
                </div>
                <asp:HyperLink runat="server" ID="HomeLink14" CssClass="plain-link" NavigateUrl="https://www.psut.edu.jo/ar/media" target="_blank" rel="noopener">Explore the gallery <span aria-hidden="true">↗</span></asp:HyperLink></div>
            <video class="internship-process-video" id="internshipProcessVideo" autoplay muted loop controls playsinline preload="metadata" aria-label="PSUT internship process video">
                <source src="<%= ResolveUrl("~/Assets/psut-campus-film.mp4") %>" type="video/mp4">
                Your browser does not support this video. <a href="<%= ResolveUrl("~/Assets/psut-campus-film.mp4") %>">Download the internship process video</a>.
            </video>
        </section>
    </main>
    <footer class="campus-footer" id="contact">
        <div class="footer-top page-frame">
            <div>
                <h2 runat="server" ID="HomeHeading14">Your next chapter.<br>
                    Made at PSUT.</h2>
                <asp:HyperLink runat="server" ID="HomeLink18" NavigateUrl="https://www.psut.edu.jo/en" target="_blank" rel="noopener">Princess Sumaya University for Technology <span aria-hidden="true">↗</span></asp:HyperLink></div>
            <div>
                <h3 runat="server" ID="HomeHeading15">Let’s connect.</h3>
                <asp:HyperLink runat="server" ID="HomeLink19" NavigateUrl="mailto:info@psut.edu.jo">info@psut.edu.jo</asp:HyperLink>
                <button runat="server" ID="HomeButton6" class="plain-link" type="button" onclick="showContact()">Contact the internship coordinator</button><asp:HyperLink runat="server" ID="HomeLink20" NavigateUrl="tel:+96265359949">+962 6 535 9949</asp:HyperLink><p runat="server" ID="HomeHeading16">Khalil Saket Street, Al-Jubeiha<br>
                    Amman, Jordan</p>
            </div>
            <div>
                <h3 runat="server" ID="HomeHeading17">Your next step.</h3>
                <asp:HyperLink runat="server" ID="HomeLink21" NavigateUrl="#opportunities">Explore opportunities</asp:HyperLink><asp:HyperLink runat="server" ID="HomeLink22" NavigateUrl="~/Login.aspx">Sign in to the portal</asp:HyperLink><asp:HyperLink runat="server" ID="HomeLink23" NavigateUrl="#our-psut">Internship process</asp:HyperLink></div>
            <div class="footer-map">
                <h3>Find us.</h3>
                <iframe title="Map of Princess Sumaya University for Technology, Amman" src="https://www.google.com/maps?q=Princess%20Sumaya%20University%20for%20Technology%20Khalil%20Al-Saket%20St%2C%20Amman%2C%20Jordan&amp;output=embed" loading="lazy" referrerpolicy="no-referrer-when-downgrade" allowfullscreen></iframe>
                <a href="https://www.google.com/maps/search/?api=1&amp;query=Princess%20Sumaya%20University%20for%20Technology%20Khalil%20Al-Saket%20St%2C%20Amman%2C%20Jordan" target="_blank" rel="noopener noreferrer">Open in Google Maps <span aria-hidden="true">↗</span></a>
            </div>
        </div>
        <div class="footer-signature page-frame"><span class="footer-psut" aria-hidden="true">PSUT</span><div>جامعة الأميرة سمية للتكنولوجيا<br>
            Learning with purpose.<br>
            Experience for what comes next.</div>
        </div>
        <div class="footer-bottom page-frame"><span>© 2026 PSUT Internship Portal · Academic project</span><asp:HyperLink runat="server" ID="HomeLink24" NavigateUrl="https://www.psut.edu.jo/ar/media" target="_blank" rel="noopener">Photography: PSUT Media Gallery</asp:HyperLink><asp:HyperLink runat="server" ID="HomeLink25" NavigateUrl="#home">Back to top ↑</asp:HyperLink></div>
        <img class="footer-mosaic" src="<%= ResolveUrl("~/Assets/psut-footer-mosaic.png") %>" alt="" aria-hidden="true" loading="lazy" width="1893" height="160">
    </footer>
</asp:Content>

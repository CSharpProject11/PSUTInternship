from pathlib import Path
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
web = root / 'PSUTInternship'
for folder in ['Student', 'Company', 'Academic', 'Admin']:
    (web / folder / 'Dashboard.aspx').write_text(
        '<%@ Page Language="C#" Async="true" AutoEventWireup="true" MasterPageFile="~/Workspace.Master" '
        f'CodeBehind="Dashboard.aspx.cs" Inherits="PSUTInternship.{folder}.Dashboard" %>\n'
        '<asp:Content ID="DashboardContent" ContentPlaceHolderID="WorkspaceContent" runat="server" />\n', encoding='utf-8-sig')

page = (web / 'Default.aspx').read_text(encoding='utf-8-sig')
page = page.replace('<div class="hero-film">', '<div class="hero-scroll-stage"><div class="hero-sticky"><div class="hero-film">', 1)
needle = '<a class="hero-scroll"'
at = page.index(needle)
page = page[:at] + '<div class="hero-scroll-progress" aria-hidden="true">Scroll to discover</div></div></div>\n' + page[at:]
page = page.replace('id="internship-facts"', 'id="internship-facts" data-drag-rail')
page = page.replace('id="publicCards"', 'id="publicCards" data-drag-rail tabindex="0" role="region" aria-label="Opportunity cards; drag or use arrow keys to explore"')
page = page.replace('class="photo-strip"', 'class="photo-strip" data-drag-rail tabindex="0" role="region" aria-label="PSUT photo gallery; drag or use arrow keys to explore"')
arrow = '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6"/></svg>'
hint = '<div class="rail-hint"><span>Drag to explore opportunities</span><button type="button" aria-label="Previous opportunities" onclick="scrollOpportunityCards(-1)">' + arrow + '</button><button type="button" aria-label="Next opportunities" onclick="scrollOpportunityCards(1)">' + arrow + '</button></div>'
page = re.sub(r'(<div[^>]*id="publicCards")', hint + r'\1', page)
(web / 'Default.aspx').write_text(page, encoding='utf-8-sig')

master = (web / 'Public.Master').read_text(encoding='utf-8-sig')
master = master.replace('</head>', '<link rel="stylesheet" href="<%= ResolveUrl("~/Content/homepage-interactions.css") %>">\n</head>')
master = master.replace('</body>', '<script src="<%= ResolveUrl("~/Scripts/interactions.js") %>"></script>\n<script src="<%= ResolveUrl("~/Scripts/hero.js") %>"></script>\n</body>')
(web / 'Public.Master').write_text(master, encoding='utf-8-sig')

well = (web / 'Scripts/wellington.js').read_text(encoding='utf-8-sig')
well = '\n'.join(line for line in well.splitlines() if not line.startswith("(()=>{const rail=document.getElementById('internship-facts');"))
well += "\nfunction scrollOpportunityCards(direction){const rail=document.getElementById('publicCards');rail.scrollBy({left:direction*Math.min(rail.clientWidth*.8,440),behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'instant':'smooth'})}\n"
(web / 'Scripts/wellington.js').write_text(well, encoding='utf-8-sig')

# Ensure login redirects happen before the dialog wrapper makes the page inert.
motion = (web / 'Scripts/motion.js').read_text(encoding='utf-8-sig')
motion = motion.replace("window.openModal=function(id){", "window.openModal=function(id){if(id==='login'){window.location.assign(PSUT.root+'Login.aspx');return;}")
(web / 'Scripts/motion.js').write_text(motion, encoding='utf-8-sig')

login = (web / 'Login.aspx.cs').read_text(encoding='utf-8-sig')
login = login.replace('Response.Redirect("~/Student/MyApplications.aspx", false);', '''string dashboard;
                        switch (role.ToLowerInvariant())
                        {
                            case "student": dashboard = "~/Student/Dashboard.aspx"; break;
                            case "company": dashboard = "~/Company/Dashboard.aspx"; break;
                            case "academic": dashboard = "~/Academic/Dashboard.aspx"; break;
                            case "admin": dashboard = "~/Admin/Dashboard.aspx"; break;
                            default:
                                Session.Clear();
                                messageLabel.Text = "Your account role is not recognized. Contact the internship coordinator.";
                                return;
                        }
                        Response.Redirect(dashboard, false);''')
(web / 'Login.aspx.cs').write_text(login, encoding='utf-8-sig')

for filename in ['Student/Opportunities.aspx', 'Student/MyApplications.aspx', 'Student/Apply.aspx']:
    path = web / filename
    text = path.read_text(encoding='utf-8-sig')
    text = text.replace('<form id="form1" runat="server">', '<form id="form1" runat="server">\n<a href="Dashboard.aspx" style="display:inline-flex;margin:16px 20px;color:#003e73;font:600 14px Manrope,Arial,sans-serif">Back to my dashboard</a>', 1)
    path.write_text(text, encoding='utf-8-sig')

config = (web / 'Web.config').read_text(encoding='utf-8-sig')
config = config.replace('<system.web>', '<system.web>\n    <globalization fileEncoding="utf-8" requestEncoding="utf-8" responseEncoding="utf-8" />', 1)
(web / 'Web.config').write_text(config, encoding='utf-8-sig')

proj = web / 'PSUTInternship.csproj'
ns = 'http://schemas.microsoft.com/developer/msbuild/2003'
ET.register_namespace('', ns)
tree = ET.parse(proj)
existing = {node.attrib.get('Include') for node in tree.getroot().iter()}
group = ET.SubElement(tree.getroot(), '{'+ns+'}ItemGroup')
for name in ['Workspace.Master','Logout.aspx','Content/workspace.css','Content/homepage-interactions.css','Scripts/workspace.js','Scripts/interactions.js','Scripts/hero.js']:
    name = name.replace('/', '\\')
    if name not in existing: ET.SubElement(group, '{'+ns+'}Content', Include=name)
if 'Workspace.Master.cs' not in existing:
    item = ET.SubElement(group, '{'+ns+'}Compile', Include='Workspace.Master.cs')
    ET.SubElement(item, '{'+ns+'}DependentUpon').text = 'Workspace.Master'
ET.indent(tree, space='  ')
tree.write(proj, encoding='utf-8', xml_declaration=True)
print('Integrated four dashboard routes, homepage motion, draggable rails and role-based login routing.')

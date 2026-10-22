from pathlib import Path
import shutil

root = Path(__file__).resolve().parents[1]
web = root / 'PSUTInternship'
preview = root / '.design-review' / 'preview-app'
preview.mkdir(exist_ok=True)
master = (web / 'Workspace.Master').read_text(encoding='utf-8-sig')
master = master.replace('AutoEventWireup="true" CodeBehind="Workspace.Master.cs" Inherits="PSUTInternship.WorkspaceLayout"', 'AutoEventWireup="false" CodeFile="TestLayout.cs" Inherits="Preview.TestLayout"')
(preview / 'Workspace.Master').write_text(master, encoding='utf-8-sig')
(preview / 'Default.aspx').write_text('<%@ Page Language="C#" Async="true" MasterPageFile="~/Workspace.Master" %><asp:Content ID="PreviewContent" ContentPlaceHolderID="WorkspaceContent" runat="server" />', encoding='utf-8-sig')
import re
runtime = re.search(r'<runtime>.*?</runtime>', (web/'Web.config').read_text(encoding='utf-8-sig'), re.S).group()
(preview / 'Web.config').write_text('''<?xml version="1.0"?><configuration><system.web><compilation debug="true" targetFramework="4.7.2"/><httpRuntime targetFramework="4.7.2"/><globalization fileEncoding="utf-8" responseEncoding="utf-8"/></system.web>''' + runtime + '</configuration>', encoding='utf-8')
(preview / 'TestLayout.cs').write_text('''using System;
using System.Reflection;
using PSUTInternship;
namespace Preview {
 public partial class TestLayout : WorkspaceLayout {
  private void Set(string key, object value) { typeof(WorkspaceLayout).GetProperty(key).SetValue(this,value,null); }
  protected override void OnLoad(EventArgs e) {
   string role = Request.QueryString["role"] ?? "student";
   if (role != "company" && role != "academic" && role != "admin") role = "student";
   Set("Role",role); Set("Name","Sample student");
   typeof(WorkspaceLayout).GetMethod("ConfigureRole",BindingFlags.NonPublic|BindingFlags.Instance).Invoke(this,null);
   Notices.Add("Design preview — illustrative records for visual verification only.");
   Set("ApplicationsAvailable",true); Set("PendingCount",2); Set("ApprovedCount",1); Set("RejectedCount",0);
   Metrics.Add(new WorkspaceMetric(role=="company"?"My opportunities":role=="student"?"Applications":"Students","3","Illustrative preview records"));
   Metrics.Add(new WorkspaceMetric("Awaiting review","2","Illustrative pending decisions"));
   Metrics.Add(new WorkspaceMetric("Approved placements","1","Illustrative approved application"));
   Metrics.Add(new WorkspaceMetric("Open opportunities","3","Illustrative internship listings"));
   for (int i=0;i<3;i++) {
    string[] titles={"Software Engineering Intern","Cybersecurity Analyst Trainee","Data Science Intern"};
    Rows.Add(new WorkspaceRow {Title=titles[i],Person=role=="student"?"Example organization":"Sample student",Status=i==1?"Approved":"Pending",Date="21 Oct 2026",Url="#activity"});
    Openings.Add(new WorkspaceOpening {Title=titles[i],Location="Amman",Mode="Hybrid",Deadline="08 Nov 2026",Status="Open",Url="#workspace"});
    People.Add(new WorkspaceRow {Title="Sample student "+(i+1),Person="Computer Science",Status="Active"});
   }
  }
 }
}''', encoding='utf-8')
for folder in ['Content','Scripts','bin']:
    (preview / folder).mkdir(exist_ok=True)
for name in ['workspace.css']:
    shutil.copy2(web/'Content'/name, preview/'Content'/name)
for name in ['workspace.js','interactions.js']:
    shutil.copy2(web/'Scripts'/name, preview/'Scripts'/name)
for file in (web/'bin').glob('*.dll'):
    shutil.copy2(file,preview/'bin'/file.name)
(preview/'Assets').mkdir(exist_ok=True)
for name in ['psut-logo.jpg','psut-rooftop.jpg','psut-walkway.jpg','psut-students.jpeg','manrope-variable.ttf']:
    shutil.copy2(web/'Assets'/name,preview/'Assets'/name)
print(preview)

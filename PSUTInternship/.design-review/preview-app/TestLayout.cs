using System;
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
}
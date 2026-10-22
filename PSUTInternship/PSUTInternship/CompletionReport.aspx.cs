using System;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;
namespace PSUTInternship
{
    public class CompletionReport:PortalPage
    {
        protected async void Page_Load(object sender,EventArgs e)
        {
            string role=PortalRoles.Normalize(Convert.ToString(Session["userRole"]));
            string uid=role=="admin"?PortalRepository.Key(Request.QueryString["studentId"]):PortalRepository.UserId;
            if(role!="admin"&&role!="student")throw new System.Web.HttpException(403,"Report access denied.");
            var report=await PortalRepository.CompletionForStudent(uid);
            if(!DatabaseSchema.ReportApproved(report))throw new System.Web.HttpException(404,"No approved completion report is available.");
            byte[] pdf=CompletionReportPdf.Create(report);Response.Clear();Response.ContentType="application/pdf";Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.AddHeader("Content-Disposition","attachment; filename=InternshipCompletion.pdf");Response.BinaryWrite(pdf);Context.ApplicationInstance.CompleteRequest();
        }
    }
}

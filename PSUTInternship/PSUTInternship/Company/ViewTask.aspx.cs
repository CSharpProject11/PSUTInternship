using System;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;
namespace PSUTInternship.Company
{
    public partial class ViewTask : PortalPage
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            try
            {
                string id = Request.QueryString["id"];
                var task = await PortalRepository.CompanyTask(id);
                Describtion.InnerHtml = "<h2>" + H((string)task["title"]) + "</h2><p>" + H((string)task["description"]) + "</p><p>Due: " + H((string)task["dueDate"]) + " | " + H((string)task["status"]) + "</p><p>" + H((string)task["feedback"]) + "</p>";
                var submission = await PortalRepository.SubmissionForTask(id, (string)task["studentId"]);
                solution.InnerHtml = submission == null ? "<p>No work submitted yet.</p>" : "<h2>Submitted work</h2><p>" + H((string)submission["answer"]) + "</p>";
                Uri url;
                if (Uri.TryCreate((string)submission?["attachmentUrl"], UriKind.Absolute, out url) && url.Scheme == "https")
                    solution.InnerHtml += "<p><a target='_blank' rel='noopener' href='" + System.Web.HttpUtility.HtmlAttributeEncode(url.AbsoluteUri) + "'>Open submitted file or link</a></p>";
                solution.InnerHtml += "<p><a href='EditTask.aspx?id=" + System.Web.HttpUtility.UrlEncode(id) + "'>Review submission</a> | <a href='Tasks.aspx'>All tasks</a></p>";
            }
            catch (Exception ex) { Describtion.InnerText = ex.Message; }
        }
        protected void Cansle_Click(object sender, EventArgs e) { Response.Redirect("Tasks.aspx", false); Context.ApplicationInstance.CompleteRequest(); }
        private string H(string value) { return Server.HtmlEncode(value ?? ""); }
    }
}

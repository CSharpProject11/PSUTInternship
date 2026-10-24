using System;
using System.IO;
using System.Web;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;
namespace PSUTInternship {
    public class TaskSolution : PortalPage {
        protected async void Page_Load(object sender, EventArgs e) {
            try {
                if (string.IsNullOrEmpty(PortalRepository.UserId) || string.IsNullOrEmpty(PortalRepository.Token)) throw new HttpException(401, "Sign in to download work.");
                string id = PortalRepository.Key(Request.QueryString["taskId"]);
                var task = await PortalRepository.Get<JObject>("tasks/" + id);
                if (task == null) throw new HttpException(404, "Task not found.");
                var placement = await PortalRepository.PlacementForRecord(task);
                string role = PortalRoles.Normalize(Convert.ToString(Session["userRole"]));
                bool allowed = role == "admin" || role == "student" && (string)task["studentId"] == PortalRepository.UserId
                    || role == "company" && ((string)placement?["companyId"] == PortalRepository.CompanyId || (string)placement?["companySupervisorId"] == PortalRepository.ProfileId)
                    || role == "academic" && (string)placement?["academicSupervisorId"] == PortalRepository.ProfileId;
                if (!allowed) throw new HttpException(403, "This solution is not available to your account.");
                var submission = await PortalRepository.SubmissionForTask(id, (string)task["studentId"]);
                var file = submission?["uploadedFile"] as JObject;
                if (file == null) {
                    Uri link;
                    if (Uri.TryCreate(DatabaseSchema.FirstText(submission, "attachmentUrl", "fileUrl", "submissionLink"), UriKind.Absolute, out link) && link.Scheme == "https") {
                        Response.Redirect(link.AbsoluteUri, false); Context.ApplicationInstance.CompleteRequest(); return;
                    }
                    throw new HttpException(404, "No solution file has been submitted.");
                }
                string path = TaskFileStore.FilePath((string)file["id"], id, (string)task["studentId"]);
                if (!File.Exists(path)) throw new HttpException(404, "The solution file is unavailable. Contact the administrator.");
                Response.Clear(); Response.ContentType = "application/octet-stream";
                Response.Cache.SetCacheability(HttpCacheability.NoCache); Response.Cache.SetNoStore();
                Response.AddHeader("X-Content-Type-Options", "nosniff");
                Response.AddHeader("Content-Disposition", "attachment; filename=solution; filename*=UTF-8''" + Uri.EscapeDataString((string)file["name"] ?? "solution"));
                Response.AddHeader("Content-Length", new FileInfo(path).Length.ToString());
                Response.TransmitFile(path); Context.ApplicationInstance.CompleteRequest();
            } catch (Exception ex) {
                Response.Clear(); Response.StatusCode = ex is HttpException ? ((HttpException)ex).GetHttpCode() : 400;
                Response.ContentType = "text/plain"; Response.Write(ex is HttpException || ex is ArgumentException ? ex.Message : "The solution could not be downloaded. Please retry.");
            }
        }
    }
}
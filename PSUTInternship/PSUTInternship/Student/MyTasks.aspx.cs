using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using PSUTInternship.Models;
using PSUTInternship.Shared;
namespace PSUTInternship.Student
{
    public partial class MyTasks : PortalPage
    {
        protected void Page_Load(object sender, EventArgs e)
        { if (!IsPostBack) RegisterAsyncTask(new PageAsyncTask(LoadTasks)); }
        private async Task LoadTasks()
        {
            try
            {
                var tasks = await PortalRepository.Collection("tasks");
                var submissions = await PortalRepository.Collection("submissions");
                DateTime today = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Jordan Standard Time")).Date;
                var rows = tasks.Select(item =>
                {
                    var task = item.Value.ToObject<StudentTask>(); task.TaskId = item.Key;
                    var submission = submissions.Values.Where(x => (string)x["taskId"] == item.Key && (string)x["studentId"] == PortalRepository.UserId)
                        .OrderByDescending(x => (string)x["updatedAt"]).FirstOrDefault();
                    task.HasSubmission = submission != null;
                    var work = submission == null ? null : submission.ToObject<TaskSubmission>();
                    task.StudentAnswer = work == null ? null : work.Answer;
                    task.StudentPdfUrl = work == null ? null : work.AttachmentUrl;
                    Uri url; task.HasPdfLink = Uri.TryCreate(task.StudentPdfUrl, UriKind.Absolute, out url) && url.Scheme == "https";
                    DateTime due; bool validDate = DateTime.TryParse(task.DueDate, out due);
                    task.CanSubmit = validDate && task.Status != "Reviewed" && (today <= due.Date || task.Status == "Revision Requested");
                    task.ButtonText = task.CanSubmit ? (task.HasSubmission ? "Update Submission" : "Submit Task") : "Submission Closed";
                    return task;
                }).Where(x => x.Active && x.StudentId == PortalRepository.UserId).ToList();
                rptTasks.DataSource = rows; rptTasks.DataBind();
            }
            catch (Exception ex) { lblMessage.Text = Server.HtmlEncode(ex.Message); }
        }
        protected void rptTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "SubmitTask") return;
            var answer = e.Item.FindControl("txtAnswer") as TextBox;
            var file = e.Item.FindControl("txtPdfUrl") as TextBox;
            if (answer == null || file == null) { lblMessage.Text = "Submission fields not found."; return; }
            RegisterAsyncTask(new PageAsyncTask(async () =>
            {
                try { await TaskWorkflow.Submit(Convert.ToString(e.CommandArgument), answer.Text.Trim(), file.Text.Trim()); await LoadTasks(); lblMessage.Text = "Task submitted successfully."; }
                catch (Exception ex) { lblMessage.Text = Server.HtmlEncode(ex.Message); }
            }));
        }
    }
}

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
        { if (Form != null) Form.Enctype = "multipart/form-data"; if (!IsPostBack) RegisterAsyncTask(new PageAsyncTask(LoadTasks)); }
        protected void Filter_Changed(object sender, EventArgs e) { RegisterAsyncTask(new PageAsyncTask(LoadTasks)); }
        private async Task LoadTasks()
        {
            try
            {
                var tasks = await PortalRepository.Collection("tasks");
                var submissions = await PortalRepository.Collection("submissions");
                DateTime today = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Jordan Standard Time")).Date;
                var placement = await PortalRepository.PlacementForStudent(PortalRepository.UserId);
                var rows = tasks.Select(item =>
                {
                    var task = item.Value.ToObject<StudentTask>(); task.TaskId = item.Key;
                    var submission = submissions.Values.Where(x => (string)x["taskId"] == item.Key && (string)x["studentId"] == PortalRepository.UserId)
                        .OrderByDescending(PortalRepository.SubmissionTime).ThenByDescending(x => DatabaseSchema.Id(x), StringComparer.Ordinal).FirstOrDefault();
                    task.HasSubmission = submission != null;
                    var work = submission == null ? null : submission.ToObject<TaskSubmission>();
                    task.StudentAnswer = work == null ? null : work.Answer;
                    task.StudentPdfUrl = submission == null ? null : ResolveUrl("~/TaskSolution.aspx?taskId=" + System.Web.HttpUtility.UrlEncode(item.Key));
                    task.HasPdfLink = submission != null && (submission["uploadedFile"] != null || !string.IsNullOrWhiteSpace(work.AttachmentUrl));
                    DateTime due; bool validDate = DateTime.TryParse(task.DueDate, out due);
                    task.CanSubmit = validDate && task.Status != "Reviewed" && today <= due.Date;
                    task.ButtonText = task.CanSubmit ? (task.HasSubmission ? "Update Submission" : "Submit Task") : "Submission Closed";
                    return task;
                }).Where(x => x.Active && x.StudentId == PortalRepository.UserId && placement != null && x.InternshipId == DatabaseSchema.Id(placement))
                    .Where(x => string.IsNullOrEmpty(StatusFilter.SelectedValue) || x.Status == StatusFilter.SelectedValue)
                    .Where(x => ((x.Title ?? "") + " " + (x.Description ?? "")).IndexOf(Search.Text.Trim(), StringComparison.OrdinalIgnoreCase) >= 0).ToList();
                EmptyTasks.Text = rows.Count == 0 ? "<tr><td colspan='4'>No new tasks available yet.</td></tr>" : "";
                rptTasks.DataSource = rows; rptTasks.DataBind();
            }
            catch (Exception ex) { lblMessage.Text = Server.HtmlEncode(ex.Message); }
        }
        protected void rptTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "SubmitTask") return;
            var answer = e.Item.FindControl("txtAnswer") as TextBox;
            var file = e.Item.FindControl("txtPdfUrl") as TextBox;
            var upload = e.Item.FindControl("SolutionFile") as FileUpload;
            var error = e.Item.FindControl("SubmissionError") as Label;
            if (answer == null || file == null) { lblMessage.Text = "Submission fields not found."; return; }
            RegisterAsyncTask(new PageAsyncTask(async () =>
            {
                Newtonsoft.Json.Linq.JObject stored = null;
                try {
                    if (upload != null && upload.HasFile && !string.IsNullOrWhiteSpace(file.Text)) throw new ArgumentException("Choose an upload or a work link, not both.");
                    if (upload != null && upload.HasFile) stored = TaskFileStore.Save(upload.PostedFile, Convert.ToString(e.CommandArgument), PortalRepository.UserId);
                    await TaskWorkflow.Submit(Convert.ToString(e.CommandArgument), answer.Text.Trim(), file.Text.Trim(), stored);
                } catch (Exception ex) {
                    // A timeout may occur after Firebase committed the metadata. Keep the private file in
                    // that ambiguous case, so a successful submission can never point at deleted bytes.
                    if (ex is ArgumentException || ex is InvalidOperationException)
                        TaskFileStore.Delete(stored, Convert.ToString(e.CommandArgument), PortalRepository.UserId);
                    error.Text = Server.HtmlEncode(ex.Message); return;
                }
                await LoadTasks(); lblMessage.Text = "Task submitted successfully.";
            }));
        }
    }
}

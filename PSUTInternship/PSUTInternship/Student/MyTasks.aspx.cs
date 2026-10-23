
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
        {
            if (Form != null)
                Form.Enctype = "multipart/form-data";

            if (!IsPostBack)
                RegisterAsyncTask(new PageAsyncTask(LoadTasks));
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(LoadTasks));
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            Search.Text = "";
            StatusFilter.SelectedIndex = 0;
            SortBy.SelectedIndex = 0;

            RegisterAsyncTask(new PageAsyncTask(LoadTasks));
        }

        private static DateTime ParseDeadline(string value)
        {
            DateTime date;
            return DateTime.TryParse(value, out date)
                ? date
                : DateTime.MaxValue;
        }

        private async Task LoadTasks()
        {
            try
            {
                var tasks = await PortalRepository.Collection("tasks");
                var submissions = await PortalRepository.Collection("submissions");

                var supervisors = await PortalRepository.Collection("companySupervisors");

                DateTime today = TimeZoneInfo.ConvertTimeFromUtc(
                    DateTime.UtcNow,
                    TimeZoneInfo.FindSystemTimeZoneById("Jordan Standard Time")
                ).Date;

                var placement = await PortalRepository.PlacementForStudent(
                    PortalRepository.UserId
                );

                var rows = tasks.Select(item =>
                {
                    var task = item.Value.ToObject<StudentTask>();
                    task.TaskId = item.Key;

                    string supervisorId = task.AssignedBy;

                    System.Diagnostics.Debug.WriteLine(
                        "TASK: " + task.Title +
                        " | Supervisor ID: " + supervisorId
                    );

                    if (!string.IsNullOrWhiteSpace(supervisorId) &&
                        supervisors.TryGetValue(supervisorId, out var supervisor))
                    {
                        string supervisorName = (string)supervisor["fullName"];

                        System.Diagnostics.Debug.WriteLine(
                            "SUPERVISOR FOUND: " + supervisorName
                        );

                        task.AssignedBy = !string.IsNullOrWhiteSpace(supervisorName)
                            ? supervisorName
                            : "Company Supervisor";
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine(
                            "SUPERVISOR NOT FOUND: " + supervisorId
                        );

                        task.AssignedBy = "Company Supervisor";
                    }


                    var submission = submissions.Values
                        .Where(x =>
                            (string)x["taskId"] == item.Key &&
                            (string)x["studentId"] == PortalRepository.UserId)
                        .OrderByDescending(PortalRepository.SubmissionTime)
                        .ThenByDescending(
                            x => DatabaseSchema.Id(x),
                            StringComparer.Ordinal)
                        .FirstOrDefault();

                    task.HasSubmission = submission != null;

                    var work = submission == null
                        ? null
                        : submission.ToObject<TaskSubmission>();

                    task.StudentAnswer = work == null
                        ? null
                        : work.Answer;

                    task.StudentPdfUrl = submission == null
                        ? null
                        : ResolveUrl(
                            "~/TaskSolution.aspx?taskId=" +
                            System.Web.HttpUtility.UrlEncode(item.Key)
                        );

                    task.HasPdfLink = submission != null &&
                        (submission["uploadedFile"] != null ||
                         !string.IsNullOrWhiteSpace(work.AttachmentUrl));

                    DateTime due;
                    bool validDate = DateTime.TryParse(task.DueDate, out due);

                    task.CanSubmit =
                        validDate &&
                        task.Status != "Reviewed" &&
                        today <= due.Date;

                    task.ButtonText = task.CanSubmit
                        ? (task.HasSubmission
                            ? "Update Submission"
                            : "Submit Task")
                        : "Submission Closed";

                    return task;
                })
                .Where(x =>
                    x.Active &&
                    x.StudentId == PortalRepository.UserId &&
                    placement != null &&
                    x.InternshipId == DatabaseSchema.Id(placement))
                .Where(x =>
                    string.IsNullOrEmpty(StatusFilter.SelectedValue) ||
                    x.Status == StatusFilter.SelectedValue)
                .Where(x =>
                    ((x.Title ?? "") + " " + (x.Description ?? ""))
                    .IndexOf(
                        Search.Text.Trim(),
                        StringComparison.OrdinalIgnoreCase
                    ) >= 0)
                .ToList();

                switch (SortBy.SelectedValue)
                {
                    case "Latest":
                        rows = rows
                            .OrderByDescending(x => ParseDeadline(x.DueDate))
                            .ToList();
                        break;

                    case "Title":
                        rows = rows
                            .OrderBy(
                                x => x.Title,
                                StringComparer.OrdinalIgnoreCase
                            )
                            .ToList();
                        break;

                    default:
                        rows = rows
                            .OrderBy(x => ParseDeadline(x.DueDate))
                            .ToList();
                        break;
                }

                TaskCount.Text = rows.Count + (
                    rows.Count == 1 ? " task found" : " tasks found"
                );

                EmptyTasks.Text = rows.Count == 0
                    ? "No tasks match your search or filters."
                    : "";

                EmptyTasksContainer.Visible = rows.Count == 0;

                rptTasks.DataSource = rows;
                rptTasks.DataBind();
            }
            catch (Exception ex)
            {
                lblMessage.Text = Server.HtmlEncode(ex.Message);
            }
        }

        protected void rptTasks_ItemCommand(
            object source,
            RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "SubmitTask")
                return;

            var answer = e.Item.FindControl("txtAnswer") as TextBox;
            var file = e.Item.FindControl("txtPdfUrl") as TextBox;
            var upload = e.Item.FindControl("SolutionFile") as FileUpload;
            var error = e.Item.FindControl("SubmissionError") as Label;

            if (answer == null || file == null)
            {
                lblMessage.Text = "Submission fields not found.";
                return;
            }

            RegisterAsyncTask(new PageAsyncTask(async () =>
            {
                Newtonsoft.Json.Linq.JObject stored = null;

                try
                {
                    if (upload != null &&
                        upload.HasFile &&
                        !string.IsNullOrWhiteSpace(file.Text))
                    {
                        throw new ArgumentException(
                            "Choose an upload or a work link, not both."
                        );
                    }

                    if (upload != null && upload.HasFile)
                    {
                        stored = TaskFileStore.Save(
                            upload.PostedFile,
                            Convert.ToString(e.CommandArgument),
                            PortalRepository.UserId
                        );
                    }

                    await TaskWorkflow.Submit(
                        Convert.ToString(e.CommandArgument),
                        answer.Text.Trim(),
                        file.Text.Trim(),
                        stored
                    );
                }
                catch (Exception ex)
                {
                    // Preserve uploaded bytes if a network timeout
                    // might have occurred after Firebase committed.
                    if (ex is ArgumentException ||
                        ex is InvalidOperationException)
                    {
                        TaskFileStore.Delete(
                            stored,
                            Convert.ToString(e.CommandArgument),
                            PortalRepository.UserId
                        );
                    }

                    if (error != null)
                        error.Text = Server.HtmlEncode(ex.Message);
                    else
                        lblMessage.Text = Server.HtmlEncode(ex.Message);

                    return;
                }

                await LoadTasks();
                lblMessage.Text = "Task submitted successfully.";
            }));
        }
    }
}

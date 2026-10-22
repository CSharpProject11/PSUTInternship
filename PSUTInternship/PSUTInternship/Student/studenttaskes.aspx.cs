

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebApplication1;

namespace Student
{
    public partial class MyTasks : Page
    {
        private readonly string databaseUrl =
            "https://teacher-124b2-default-rtdb.firebaseio.com";

        // For testing only
        private readonly string studentId = "student1";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(
                    new PageAsyncTask(LoadTasks));
            }
        }

        // Get current date in Jordan
        private DateTime GetJordanToday()
        {
            TimeZoneInfo zone =
                TimeZoneInfo.FindSystemTimeZoneById(
                    "Jordan Standard Time");

            return TimeZoneInfo.ConvertTimeFromUtc(
                DateTime.UtcNow, zone).Date;
        }

        // True if due date has passed
        private bool IsDeadlinePassed(string dueDate)
        {
            DateTime date;

            if (!DateTime.TryParseExact(
                dueDate,
                "yyyy-MM-dd",
                CultureInfo.InvariantCulture,
                DateTimeStyles.None,
                out date))
            {
                throw new Exception(
                    "Invalid due date. Expected yyyy-MM-dd.");
            }

            return GetJordanToday() > date.Date;
        }

        // Check HTTPS URL
        private bool IsValidPdfUrl(string url)
        {
            Uri uri;

            return Uri.TryCreate(
                url,
                UriKind.Absolute,
                out uri)
                && uri.Scheme == Uri.UriSchemeHttps;
        }

        // Load tasks and previous submissions
        private async Task LoadTasks()
        {
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    string tasksUrl =
                        databaseUrl + "/tasks.json";

                    string submissionsUrl =
                        databaseUrl + "/taskSubmissions.json";

                    string tasksJson =
                        await client.GetStringAsync(tasksUrl);

                    string submissionsJson =
                        await client.GetStringAsync(submissionsUrl);

                    List<StudentTask> myTasks =
                        new List<StudentTask>();

                    if (string.IsNullOrWhiteSpace(tasksJson)
                        || tasksJson == "null")
                    {
                        rptTasks.DataSource = myTasks;
                        rptTasks.DataBind();
                        return;
                    }

                    JObject tasks =
                        JObject.Parse(tasksJson);

                    JObject submissions = null;

                    if (!string.IsNullOrWhiteSpace(submissionsJson)
                        && submissionsJson != "null")
                    {
                        submissions =
                            JObject.Parse(submissionsJson);
                    }

                    foreach (var item in tasks.Properties())
                    {
                        StudentTask task =
                            item.Value.ToObject<StudentTask>();

                        if (task == null)
                            continue;

                        task.TaskId = item.Name;

                        if (task.StudentId != studentId)
                            continue;

                        JToken submission =
                            submissions == null
                            ? null
                            : submissions[task.TaskId];

                        bool hasSubmission =
                            submission != null
                            && submission.Type == JTokenType.Object;

                        task.HasSubmission = hasSubmission;

                        if (hasSubmission)
                        {
                            task.StudentAnswer =
                                (string)submission["answer"];

                            task.StudentPdfUrl =
                                (string)submission["attachmentUrl"];
                        }

                        task.HasPdfLink =
                            !string.IsNullOrWhiteSpace(
                                task.StudentPdfUrl)
                            && IsValidPdfUrl(task.StudentPdfUrl);

                        bool deadlinePassed =
                            IsDeadlinePassed(task.DueDate);

                        task.CanSubmit = !deadlinePassed;

                        if (deadlinePassed)
                        {
                            task.ButtonText = "Submission Closed";

                            // Mark only unsubmitted tasks as overdue
                            if (!hasSubmission &&
                                string.Equals(
                                    task.Status,
                                    "assigned",
                                    StringComparison.OrdinalIgnoreCase))
                            {
                                await UpdateTaskStatus(
                                    client,
                                    task.TaskId,
                                    "Deadline Passed");

                                task.Status = "Deadline Passed";
                            }
                        }
                        else
                        {
                            task.ButtonText = hasSubmission
                                ? "Update Submission"
                                : "Submit Task";
                        }

                        myTasks.Add(task);
                    }

                    rptTasks.DataSource = myTasks;
                    rptTasks.DataBind();
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text =
                    Server.HtmlEncode(ex.Message);
            }
        }

        // Update task status in Firebase
        private async Task UpdateTaskStatus(
            HttpClient client,
            string taskId,
            string status)
        {
            string taskUrl =
                databaseUrl + "/tasks/"
                + Uri.EscapeDataString(taskId)
                + ".json";

            string json =
                JsonConvert.SerializeObject(
                    new { status = status });

            using (HttpRequestMessage request =
                new HttpRequestMessage(
                    new HttpMethod("PATCH"),
                    taskUrl))
            {
                request.Content = new StringContent(
                    json,
                    Encoding.UTF8,
                    "application/json");

                using (HttpResponseMessage response =
                    await client.SendAsync(request))
                {
                    response.EnsureSuccessStatusCode();
                }
            }
        }

        // Save or update text answer and PDF URL
        private async Task SubmitTask(
            string taskId,
            string answer,
            string pdfUrl)
        {
            using (HttpClient client = new HttpClient())
            {
                string taskUrl =
                    databaseUrl + "/tasks/"
                    + Uri.EscapeDataString(taskId)
                    + ".json";

                string submissionUrl =
                    databaseUrl + "/taskSubmissions/"
                    + Uri.EscapeDataString(taskId)
                    + ".json";

                string taskJson =
                    await client.GetStringAsync(taskUrl);

                if (taskJson == "null")
                    throw new Exception("Task not found.");

                StudentTask currentTask =
                    JsonConvert.DeserializeObject<StudentTask>(
                        taskJson);

                if (currentTask == null ||
                    currentTask.StudentId != studentId)
                {
                    throw new Exception(
                        "Task not assigned to this student.");
                }

                // Deadline validation
                if (IsDeadlinePassed(currentTask.DueDate))
                {
                    throw new Exception(
                        "Deadline passed. You cannot submit or edit.");
                }

                // At least one answer type is required
                if (string.IsNullOrWhiteSpace(answer) &&
                    string.IsNullOrWhiteSpace(pdfUrl))
                {
                    throw new Exception(
                        "Please write an answer or provide a PDF link.");
                }

                // Validate PDF URL if provided
                if (!string.IsNullOrWhiteSpace(pdfUrl)
                    && !IsValidPdfUrl(pdfUrl))
                {
                    throw new Exception(
                        "Please provide a valid HTTPS PDF link.");
                }

                // Read previous submission
                string previousJson =
                    await client.GetStringAsync(submissionUrl);

                TaskSubmission previousSubmission = null;

                if (!string.IsNullOrWhiteSpace(previousJson)
                    && previousJson != "null")
                {
                    previousSubmission =
                        JsonConvert.DeserializeObject<TaskSubmission>(
                            previousJson);

                    if (previousSubmission != null &&
                        previousSubmission.StudentId != studentId)
                    {
                        throw new Exception(
                            "Submission belongs to another student.");
                    }
                }

                string now =
                    DateTime.UtcNow.ToString("o");

                // Keep first submission date
                string submittedAt =
                    previousSubmission != null &&
                    !string.IsNullOrWhiteSpace(
                        previousSubmission.SubmittedAt)
                    ? previousSubmission.SubmittedAt
                    : now;

                // Save submission and task status together
                var update =
                    new Dictionary<string, object>
                {
                    {
                        "taskSubmissions/" + taskId,
                        new
                        {
                            taskId = taskId,
                            studentId = studentId,
                            answer = answer,
                            attachmentUrl = pdfUrl,
                            submittedAt = submittedAt,
                            updatedAt = now
                        }
                    },
                    {
                        "tasks/" + taskId + "/status",
                        "Submitted"
                    }
                };

                string updateJson =
                    JsonConvert.SerializeObject(update);

                string rootUrl =
                    databaseUrl + "/.json";

                using (HttpRequestMessage request =
                    new HttpRequestMessage(
                        new HttpMethod("PATCH"),
                        rootUrl))
                {
                    request.Content = new StringContent(
                        updateJson,
                        Encoding.UTF8,
                        "application/json");

                    using (HttpResponseMessage response =
                        await client.SendAsync(request))
                    {
                        response.EnsureSuccessStatusCode();
                    }
                }
            }
        }

        // Repeater submit event

        protected void rptTasks_ItemCommand(
            object source,
            RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "SubmitTask")
                return;

            string taskId = Convert.ToString(e.CommandArgument);

            TextBox txtAnswer =
                (TextBox)e.Item.FindControl("txtAnswer");

            TextBox txtPdfUrl =
                (TextBox)e.Item.FindControl("txtPdfUrl");

            if (txtAnswer == null || txtPdfUrl == null)
            {
                lblMessage.Text = "Submission fields not found.";
                return;
            }

            string answer = txtAnswer.Text.Trim();
            string pdfUrl = txtPdfUrl.Text.Trim();

            if (string.IsNullOrWhiteSpace(answer) &&
                string.IsNullOrWhiteSpace(pdfUrl))
            {
                lblMessage.Text =
                    "Please write an answer or provide a PDF link.";
                return;
            }

            RegisterAsyncTask(new PageAsyncTask(async () =>
            {
                try
                {
                    await SubmitTask(taskId, answer, pdfUrl);

                    await LoadTasks();

                    lblMessage.Text = "Task submitted successfully!";
                }
                catch (Exception ex)
                {
                    lblMessage.Text = Server.HtmlEncode(ex.Message);
                }
            }));
        }

    }
}

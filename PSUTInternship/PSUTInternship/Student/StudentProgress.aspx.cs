using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication1
{
    public partial class StudentProgress : System.Web.UI.Page
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                await LoadTotalTasks();
                await LoadSubmittedTasks();
                await LoadTaskProgress();
                await LoadFeedback();
                await LoadTrainingProgress();
                await LoadCompletionReport();
                await LoadEvaluations();
            }
        }

            private async Task LoadTotalTasks()
        {
            string studentId = "student1"; //for test
            HttpClient client = new HttpClient();

            string url = "https://teacher-124b2-default-rtdb.firebaseio.com/tasks.json";

            string json = await client.GetStringAsync(url);

            if (json == "null")
            {
                lblTotalTasks.Text = "0";
                return;
            }

            JObject tasks = JObject.Parse(json);

            int totalTasks = 0;

            foreach (var task in tasks.Properties())
            {
                string taskStudentId = (string)task.Value["studentId"];

                if (taskStudentId == studentId)
                {
                    totalTasks++;
                }
            }

            lblTotalTasks.Text = totalTasks.ToString();
        
        }

        private async Task LoadSubmittedTasks()
        {
            string studentId = "student1"; //for test

            HttpClient client = new HttpClient();

            string url = "https://teacher-124b2-default-rtdb.firebaseio.com/taskSubmissions.json";

            string json = await client.GetStringAsync(url);

            if (json == "null")
            {
                lblSubmittedTasks.Text = "0";
                return;
            }

            JObject submissions = JObject.Parse(json);

            int submittedTasks = 0;

            foreach (var submission in submissions.Properties())
            {
                string submissionStudentId =
                    (string)submission.Value["studentId"];

                if (submissionStudentId == studentId)
                {
                    submittedTasks++;
                }
            }

            lblSubmittedTasks.Text = submittedTasks.ToString();
        }

        private async Task LoadTaskProgress()
        {
            string studentId = "student1";

            HttpClient client = new HttpClient();

            string tasksUrl =
                "https://teacher-124b2-default-rtdb.firebaseio.com/tasks.json";

            string submissionsUrl =
                "https://teacher-124b2-default-rtdb.firebaseio.com/taskSubmissions.json";
            string feedbackUrl =
    "https://teacher-124b2-default-rtdb.firebaseio.com/taskFeedback.json";

            string tasksJson = await client.GetStringAsync(tasksUrl);
            string submissionsJson = await client.GetStringAsync(submissionsUrl);
            string feedbackJson = await client.GetStringAsync(feedbackUrl);

            if (tasksJson == "null")
            {
                lblNoTasks.Visible = true;
                return;
            }

            JObject tasks = JObject.Parse(tasksJson);

            JObject submissions = submissionsJson == "null"
                ? new JObject()
                : JObject.Parse(submissionsJson);

            JObject feedback = feedbackJson == "null"
    ? new JObject()
    : JObject.Parse(feedbackJson);

            var taskList = new List<object>();

            foreach (var task in tasks.Properties())
            {
                string taskId = task.Name;
                string taskStudentId = (string)task.Value["studentId"];

                if (taskStudentId != studentId)
                {
                    continue;
                }

                JToken submission = submissions[taskId];

                bool isSubmitted =
                    submission != null &&
                    (string)submission["studentId"] == studentId;
                JToken taskFeedback = feedback[taskId];

                string status = isSubmitted ? "Submitted" : "Pending";

                if (taskFeedback != null &&
                    (string)taskFeedback["studentId"] == studentId &&
                    (string)taskFeedback["status"] == "Revision Requested")
                {
                    status = "Revision Requested";
                }

                taskList.Add(new
                {
                    Title = (string)task.Value["title"] ?? "Untitled Task",
                    SubmissionDate = isSubmitted
                        ? (string)submission["submittedAt"] ?? "—"
                        : "—",
                    Status = status
                });
            }

            rptTasks.DataSource = taskList;
            rptTasks.DataBind();

            lblNoTasks.Visible = taskList.Count == 0;
        }

        private async Task LoadFeedback()
        {
            string studentId = "student1";

            HttpClient client = new HttpClient();

            string url = "https://teacher-124b2-default-rtdb.firebaseio.com/taskFeedback.json";

            string json = await client.GetStringAsync(url);

            if (json == "null")
            {
                lblNoEvaluations.Visible = true;
                lblRevisions.Text = "0";
                return;
            }

            JObject feedback = JObject.Parse(json);

            var feedbackList = new List<object>();

            int revisions = 0;

            foreach (var item in feedback.Properties())
            {
                string feedbackStudentId = (string)item.Value["studentId"];

                if (feedbackStudentId != studentId)
                {
                    continue;
                }

                string status = (string)item.Value["status"];

                if (status == "Revision Requested")
                {
                    revisions++;
                }

                feedbackList.Add(new
                {
                    Title = "Task Feedback - " + item.Name,
                    Comments = (string)item.Value["comments"]
                });
            }

            rptEvaluations.DataSource = feedbackList;
            rptEvaluations.DataBind();

            lblNoEvaluations.Visible = feedbackList.Count == 0;
            lblRevisions.Text = revisions.ToString();
        }

        private async Task LoadTrainingProgress()
        {
            string studentId = "student1";

            HttpClient client = new HttpClient();

            string url = "https://teacher-124b2-default-rtdb.firebaseio.com/trainingProgress/"
                         + studentId + ".json";

            string json = await client.GetStringAsync(url);

            if (json == "null")
            {
                lblApprovedHours.Text = "0";
                lblHoursProgress.Text = "No training hours available";
                return;
            }

            JObject data = JObject.Parse(json);

            int requiredHours = (int)data["requiredHours"];
            int approvedHours = (int)data["approvedHours"];

            lblApprovedHours.Text = approvedHours.ToString();

            lblHoursProgress.Text =
                approvedHours + " / " + requiredHours + " hours";

            double percentage = 0;

            if (requiredHours > 0)
            {
                percentage = (double)approvedHours / requiredHours * 100;
            }
            lblPercentage.Text = percentage.ToString("0.0") + "%";
            progressFill.Style["width"] =
                Math.Min(percentage, 100).ToString(
                    System.Globalization.CultureInfo.InvariantCulture) + "%";
        }

        private async Task LoadCompletionReport()
        {
            string studentId = "student1";

            HttpClient client = new HttpClient();

            string url = "https://teacher-124b2-default-rtdb.firebaseio.com/completionReports/"
                         + studentId + ".json";

            string json = await client.GetStringAsync(url);

            if (json == "null")
            {
                lblReportStatus.Text = "No completion report available";
                lnkReport.Visible = false;
                return;
            }

            JObject data = JObject.Parse(json);

            bool approved = (bool?)data["approvedByCoordinator"] ?? false;
            string reportUrl = (string)data["reportUrl"];

            Uri pdfLink;

            bool validUrl = Uri.TryCreate(reportUrl, UriKind.Absolute, out pdfLink)
                && pdfLink.Scheme == Uri.UriSchemeHttps;

            if (approved && validUrl)
            {
                lblReportStatus.Text = "Approved by Coordinator";

                lnkReport.NavigateUrl = pdfLink.AbsoluteUri;
                lnkReport.Visible = true;
            }
            else
            {
                lblReportStatus.Text = approved
                    ? "Approved - Report not available yet"
                    : "Awaiting Coordinator Approval";

                lnkReport.Visible = false;
            }
        }

        private async Task LoadEvaluations()
        {
            string studentId = "student1";

            HttpClient client = new HttpClient();

            string url =
                "https://teacher-124b2-default-rtdb.firebaseio.com/evaluations.json";

            string json = await client.GetStringAsync(url);

            if (json == "null")
            {
                lblNoInternshipEvaluations.Visible = true;
                return;
            }

            JObject evaluations = JObject.Parse(json);

            var evaluationList = new List<object>();

            foreach (var item in evaluations.Properties())
            {
                string evaluationStudentId =
                    (string)item.Value["studentId"];

                string status =
                    (string)item.Value["status"];

                // عرض تقييمات الطالب الجاهزة فقط
                if (evaluationStudentId == studentId &&
                    status == "submitted")
                {
                    evaluationList.Add(new
                    {
                        Title = (string)item.Value["evaluationType"]
                                ?? "Internship Evaluation",

                        Comments = (string)item.Value["comments"]
                                   ?? "No comments provided."
                    });
                }
            }

            rptInternshipEvaluations.DataSource = evaluationList;
            rptInternshipEvaluations.DataBind();

            lblNoInternshipEvaluations.Visible =
                evaluationList.Count == 0;
        }




    }
}
     
    



using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using Newtonsoft.Json.Linq;
using PSUTInternship.Models;
using PSUTInternship.Shared;

namespace PSUTInternship.Student
{
    public partial class MyProgress : PortalPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(
                    new PageAsyncTask(LoadProgress)
                );
            }
        }

        private static bool IsCompleted(string status)
        {
            return IsStatus(status, "Completed", "Complete", "Reviewed");
        }

        private static bool IsSubmitted(string status)
        {
            return IsStatus(status, "Submitted");
        }

        private static bool IsReassigned(string status)
        {
            return IsStatus(
                status,
                "Reassign",
                "Reassigned",
                "Revision Requested"
            );
        }

        private static bool IsStatus(
            string status,
            params string[] allowed)
        {
            return allowed.Any(value =>
                string.Equals(
                    status?.Trim(),
                    value,
                    StringComparison.OrdinalIgnoreCase
                ));
        }

        private static DateTime ParseDate(string value)
        {
            DateTime date;

            return DateTime.TryParse(value, out date)
                ? date
                : DateTime.MaxValue;
        }

        private static string ReadText(
            JObject source,
            params string[] keys)
        {
            if (source == null)
                return "";

            foreach (string key in keys)
            {
                var token = source[key];

                if (token != null &&
                    token.Type != JTokenType.Null)
                {
                    string value = token.ToString().Trim();

                    if (!string.IsNullOrWhiteSpace(value))
                        return value;
                }
            }

            return "";
        }

        private async Task LoadProgress()
        {
            try
            {
                lblMessage.Text = "";

                var tasks =
                    await PortalRepository.Collection("tasks");

                var placement =
                    await PortalRepository.PlacementForStudent(
                        PortalRepository.UserId
                    );

                string internshipId = placement == null
                    ? ""
                    : DatabaseSchema.Id(placement);

                var studentTasks = tasks
                    .Select(item =>
                    {
                        StudentTask task =
                            item.Value.ToObject<StudentTask>();

                        task.TaskId = item.Key;

                        return new
                        {
                            Task = task,
                            Data = item.Value
                        };
                    })
                    .Where(item =>
                        item.Task.Active &&
                        item.Task.StudentId == PortalRepository.UserId &&
                        !string.IsNullOrWhiteSpace(internshipId) &&
                        item.Task.InternshipId == internshipId)
                    .ToList();

                // TASK STATISTICS
                int total = studentTasks.Count;

                int completed = studentTasks.Count(item =>
                    IsCompleted(item.Task.Status));

                int submitted = studentTasks.Count(item =>
                    IsSubmitted(item.Task.Status));

                int reassigned = studentTasks.Count(item =>
                    IsReassigned(item.Task.Status));

                double percentage = total == 0
                    ? 0
                    : (double)completed / total * 100;

                // UPDATE DASHBOARD
                litTotal.Text = total.ToString();

                litCompleted.Text = completed.ToString();

                litSubmitted.Text = submitted.ToString();

                litReassigned.Text = reassigned.ToString();

                litPercentage.Text =
                    Math.Round(percentage).ToString("0") + "%";

                litProgressDescription.Text =
                    completed + " of " + total + " tasks completed";

                // CIRCULAR PROGRESS
                progressRing.Style["--progress"] =
                    percentage.ToString(
                        "0.##",
                        CultureInfo.InvariantCulture
                    );

                // TASK TRACKING
                var taskRows = studentTasks
                    .OrderBy(item =>
                        ParseDate(item.Task.DueDate))
                    .Select(item => new
                    {
                        Title = item.Task.Title,
                        Status = item.Task.Status,
                        DueDate = item.Task.DueDate
                    })
                    .ToList();

                rptProgressTasks.DataSource = taskRows;
                rptProgressTasks.DataBind();

                pnlNoTasks.Visible = taskRows.Count == 0;

                // SUPERVISOR FEEDBACK
                var feedbackRows = studentTasks
                    .Select(item => new
                    {
                        Title = item.Task.Title,
                        Status = item.Task.Status,

                        Feedback = ReadText(
                            item.Data,
                            "supervisorFeedback",
                            "feedback",
                            "revisionNotes"
                        )
                    })
                    .Where(item =>
                        !string.IsNullOrWhiteSpace(item.Feedback))
                    .Select(item => new
                    {
                        item.Title,
                        item.Status,
                        item.Feedback
                    })
                    .ToList();

                rptFeedback.DataSource = feedbackRows;
                rptFeedback.DataBind();

                pnlNoFeedback.Visible =
                    feedbackRows.Count == 0;
            }
            catch (Exception ex)
            {
                lblMessage.Text =
                    "<pre style='white-space:pre-wrap;direction:ltr'>" +
                    Server.HtmlEncode(ex.ToString()) +
                    "</pre>";
            }

        }
        protected string GetStatusText(object status)
        {
            string value = Convert.ToString(status)?.Trim();

            switch (value?.ToLowerInvariant())
            {
                case "reviewed":
                case "complete":
                case "completed":
                    return "Completed";

                case "revision requested":
                case "reassigned":
                case "reassign":
                    return "Reassign";

                case "submitted":
                    return "Submitted";

                case "assigned":
                case "pending":
                    return "Assigned";

                default:
                    return value ?? "";
            }
        }

        protected string GetStatusClass(object status)
        {
            string value = GetStatusText(status);

            switch (value)
            {
                case "Completed": return "completed";
                case "Submitted": return "submitted";
                case "Reassign": return "reassign";
                default: return "assigned";
            }
        }
    }
}

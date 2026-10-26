using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using PSUTInternship.Models;

namespace PSUTInternship.Shared
{
    public static class TaskWorkflow
    {
        public static DateTime Today { get { return TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Jordan Standard Time")).Date; } }
        public static bool ValidText(string value, int minimum, int maximum)
        {
            return System.Text.RegularExpressions.Regex.IsMatch(value ?? "", @"\A[^\x00-\x08\x0B\x0C\x0E-\x1F]{" + minimum + "," + maximum + @"}\z") && (value ?? "").Trim().Length >= minimum;
        }
        public static async Task ConfigureMaximum(string id, decimal maximum)
        {
            var task = await PortalRepository.CompanyTask(id);
            if (maximum <= 0) throw new ArgumentException("Enter a positive task maximum score.");
            if ((decimal?)task["maximumScore"] == maximum) return;
            if ((decimal?)task["maximumScore"] > 0 || (decimal?)task["score"] != null)
                throw new InvalidOperationException("The maximum for an existing graded task cannot be changed here.");
            await PortalRepository.Patch("tasks/" + id, new { maximumScore=maximum });
        }
        public static async Task Submit(string taskId, string answer, string fileUrl, JObject uploadedFile = null)
        {
            var task = await PortalRepository.Get<JObject>("tasks/" + PortalRepository.Key(taskId));
            if (task == null || (string)task["studentId"] != PortalRepository.UserId || (bool?)task["active"] == false)
                throw new InvalidOperationException("Task not assigned to this student.");
            string state = DatabaseSchema.WorkflowStatus((string)task["status"]);
            DateTime deadline;
            if (!DateTime.TryParse((string)task["dueDate"], CultureInfo.InvariantCulture, DateTimeStyles.None, out deadline))
                throw new InvalidOperationException("This task has an invalid due date. Ask your company supervisor to correct it.");
            DateTime today = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Jordan Standard Time")).Date;
            if (state == "Reviewed" || today > deadline.Date)
                throw new InvalidOperationException("The submission deadline has passed or the task has already been reviewed.");
            if ((answer ?? "").Length > 10000 || (fileUrl ?? "").Length > 2048) throw new ArgumentException("Use at most 10,000 answer characters and 2,048 link characters.");
            Uri uri;
            if (!string.IsNullOrWhiteSpace(fileUrl) && (!Uri.TryCreate(fileUrl, UriKind.Absolute, out uri) || uri.Scheme != "https"))
                throw new ArgumentException("Provide a valid HTTPS file link.");
            var placement = await PortalRepository.PlacementForRecord(task);
            if ((string)placement["status"] != "active") throw new InvalidOperationException("Only active internships accept submissions.");
            var previous = await PortalRepository.SubmissionForTask(taskId, PortalRepository.UserId);
            // An update without a replacement keeps the student's previously uploaded work.
            if (uploadedFile == null && string.IsNullOrWhiteSpace(fileUrl)) uploadedFile = previous?["uploadedFile"] as JObject;
            if (uploadedFile == null && string.IsNullOrWhiteSpace(fileUrl)) fileUrl = DatabaseSchema.FirstText(previous, "fileUrl", "attachmentUrl", "submissionLink");
            if (string.IsNullOrWhiteSpace(answer) && string.IsNullOrWhiteSpace(fileUrl) && uploadedFile == null) throw new ArgumentException("Write an answer, upload a solution or provide a file link.");
            string id = previous == null ? Guid.NewGuid().ToString("N") : DatabaseSchema.Id(previous);
            string now = DateTime.UtcNow.ToString("o");
            var changes = new Dictionary<string, object>
            {
                { "submissions/" + id, new {
                    taskId=taskId, studentId=PortalRepository.UserId, internshipId=(string)task["internshipId"],
                    companyId=(string)placement["companyId"], academicSupervisorId=(string)placement["academicSupervisorId"],
                    answer=answer ?? "", fileUrl=fileUrl ?? "", uploadedFile=uploadedFile, submissionLink="", status="Submitted", feedback="", reviewedAt="",
                    submittedAt=DatabaseSchema.FirstText(previous, "submittedAt").Length > 0 ? (string)previous["submittedAt"] : now, updatedAt=now } },
                { "tasks/" + taskId + "/status", "Submitted" }
            };
            if (previous != null) changes["submissionHistory/" + taskId + "/" + Guid.NewGuid().ToString("N")] = previous;
            await PortalRepository.Patch("", changes);
        }
        public static Task Create(string title, string description, string criteria, string priority, DateTime deadline, IEnumerable<string> students, string opportunityId)
        {
            return Create(title, description, criteria, priority, 0, deadline, students, opportunityId);
        }
        public static async Task Create(string title, string description, string criteria, string priority, decimal maximum, DateTime deadline, IEnumerable<string> students, string opportunityId = null, decimal trainingHours = 0)
        {
            var ids = students.Distinct().ToList();
            if (!ValidText(title, 3, 150) || !ValidText(description, 10, 5000) || !ValidText(criteria, 5, 3000) || maximum < 0 || trainingHours < 0 || deadline.Date <= Today || ids.Count == 0)
                throw new ArgumentException("Enter valid task details, a future deadline and at least one trainee.");
            if (!new[] { "Low", "Medium", "High", "Normal" }.Contains(priority)) throw new ArgumentException("Choose a valid priority.");
            if (opportunityId != null) PortalRepository.Key(opportunityId);
            var changes = new Dictionary<string, object>();
            foreach (string studentId in ids)
            {
                var placement = await PortalRepository.PlacementForStudent(studentId);
                if (placement == null || (string)placement["companyId"] != PortalRepository.CompanyId || (string)placement["status"] != "active")
                    throw new InvalidOperationException("Tasks can only be assigned to your confirmed active trainees.");
                if (opportunityId != null && (string)placement["opportunityId"] != opportunityId) throw new InvalidOperationException("The selected trainee does not belong to this opportunity.");
                string id = Guid.NewGuid().ToString("N");
                changes["tasks/" + id] = new
                {
                    taskId = id, title = title.Trim(), description = description.Trim(), evaluationCriteria = criteria.Trim(),
                    trainingHours = trainingHours, priority = priority, maximumScore = maximum > 0 ? (decimal?)maximum : null, dueAt = new DateTimeOffset(deadline.Date.AddDays(1), TimeSpan.FromHours(3)).ToUnixTimeMilliseconds() - 1, opportunityId = (string)placement["opportunityId"], dueDate = deadline.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                    studentId = studentId, companyId = PortalRepository.CompanyId, assignedBy = PortalRepository.UserId,
                    academicSupervisorId = (string)placement["academicSupervisorId"], internshipId = DatabaseSchema.Id(placement), companySupervisorId = PortalRepository.ProfileId,
                    status = "Pending", active = true, createdAt = DateTime.UtcNow.ToString("o")
                };
            }
            await PortalRepository.Patch("", changes);
        }
        public static async Task Review(string id, string state, string feedback, decimal? score, DateTime? newDeadline = null)
        {
            var task = await PortalRepository.CompanyTask(id);
            var submission = await PortalRepository.SubmissionForTask(id, (string)task["studentId"]);
            if (submission == null || (string)submission["studentId"] != (string)task["studentId"])
                throw new InvalidOperationException("The student must submit work before it can be reviewed.");
            if (state != "Reviewed" && state != "Revision Requested") throw new ArgumentException("Choose a review status.");
            decimal max = (decimal?)task["maximumScore"] ?? 0;
            var placement = await PortalRepository.PlacementForRecord(task);
            if ((string)placement["status"] != "active") throw new InvalidOperationException("Only active internships can be reviewed.");
            if (state == "Revision Requested" && (!newDeadline.HasValue || newDeadline.Value.Date <= Today)) throw new ArgumentException("Set a future deadline for resubmission.");
            if (score.HasValue && max <= 0) throw new InvalidOperationException("Set a positive maximum score for this task before grading it.");
            string submissionId = DatabaseSchema.Id(submission);
            if (!ValidText(feedback, 1, 3000)) throw new ArgumentException("Enter feedback of 1â€“3,000 characters.");
            if (score.HasValue && (score < 0 || score > max)) throw new ArgumentException("The awarded score must be within this task's maximum.");
            string now = DateTime.UtcNow.ToString("o");
            var review = new
            {
                studentId = (string)task["studentId"], companyId = PortalRepository.CompanyId,
                academicSupervisorId = (string)task["academicSupervisorId"], internshipId = (string)task["internshipId"],
                title = (string)task["title"], status = state, comments = feedback.Trim(), score = score, maximumScore = max, reviewedAt = now
            };
            var changes = new Dictionary<string, object>
            {
                { "tasks/" + id + "/status", state }, { "tasks/" + id + "/score", score }, { "tasks/" + id + "/feedback", feedback.Trim() },
                { "taskFeedback/" + id, review }, { "submissions/" + submissionId + "/status", state },
                { "submissions/" + submissionId + "/feedback", feedback.Trim() }, { "submissions/" + submissionId + "/reviewedAt", now },
                { "reviewHistory/" + id + "/" + Guid.NewGuid().ToString("N"), review }
            };
            decimal trainingHours = (decimal?)task["trainingHours"] ?? 0;
            if (trainingHours > 0) {
                // One deterministic credit per task: repeated reviews replace it, never append hours.
                changes["trainingHours/task_" + PortalRepository.Key(id)] = new {
                    taskId = id, studentId = (string)task["studentId"], internshipId = (string)task["internshipId"],
                    companyId = (string)placement["companyId"], academicSupervisorId = (string)placement["academicSupervisorId"],
                    hours = trainingHours, description = "Completed task: " + (string)task["title"],
                    date = Today.ToString("yyyy-MM-dd"), status = state == "Reviewed" ? "Approved" : "Rejected",
                    reviewedBy = PortalRepository.UserId, reviewedAt = now, source = "task" };
            }
            if (state == "Revision Requested") {
                changes["tasks/" + id + "/dueDate"] = newDeadline.Value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
                changes["tasks/" + id + "/dueAt"] = new DateTimeOffset(newDeadline.Value.Date.AddDays(1),TimeSpan.FromHours(3)).ToUnixTimeMilliseconds() - 1;
            }
            if (max <= 0) changes["tasks/" + id + "/maximumScore"] = null;
            changes["tasks/" + id + "/updatedAt"] = now;
            await PortalRepository.Patch("", changes);
            if (trainingHours > 0) await TrainingHoursWorkflow.Recalculate((string)task["studentId"]);
        }
    }
}

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
        public static async Task ConfigureMaximum(string id, decimal maximum)
        {
            var task = await PortalRepository.CompanyTask(id);
            if (maximum <= 0) throw new ArgumentException("Enter a positive task maximum score.");
            if ((decimal?)task["maximumScore"] == maximum) return;
            if ((decimal?)task["maximumScore"] > 0 || (decimal?)task["score"] != null)
                throw new InvalidOperationException("The maximum for an existing graded task cannot be changed here.");
            await PortalRepository.Patch("tasks/" + id, new { maximumScore=maximum });
        }
        public static async Task Submit(string taskId, string answer, string fileUrl)
        {
            var task = await PortalRepository.Get<JObject>("tasks/" + PortalRepository.Key(taskId));
            if (task == null || (string)task["studentId"] != PortalRepository.UserId || (bool?)task["active"] == false)
                throw new InvalidOperationException("Task not assigned to this student.");
            string state = DatabaseSchema.WorkflowStatus((string)task["status"]);
            DateTime deadline;
            if (!DateTime.TryParse((string)task["dueDate"], CultureInfo.InvariantCulture, DateTimeStyles.None, out deadline))
                throw new InvalidOperationException("This task has an invalid due date. Ask your company supervisor to correct it.");
            DateTime today = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Jordan Standard Time")).Date;
            if (state == "Reviewed" || (today > deadline.Date && state != "Revision Requested"))
                throw new InvalidOperationException("The submission deadline has passed or the task has already been reviewed.");
            if (string.IsNullOrWhiteSpace(answer) && string.IsNullOrWhiteSpace(fileUrl)) throw new ArgumentException("Write an answer or provide a file link.");
            Uri uri;
            if (!string.IsNullOrWhiteSpace(fileUrl) && (!Uri.TryCreate(fileUrl, UriKind.Absolute, out uri) || uri.Scheme != "https"))
                throw new ArgumentException("Provide a valid HTTPS file link.");
            var placement = await PortalRepository.PlacementForRecord(task);
            if ((string)placement["status"] != "active") throw new InvalidOperationException("Only active internships accept submissions.");
            var previous = await PortalRepository.SubmissionForTask(taskId, PortalRepository.UserId);
            string id = previous == null ? Guid.NewGuid().ToString("N") : DatabaseSchema.Id(previous);
            string now = DateTime.UtcNow.ToString("o");
            var changes = new Dictionary<string, object>
            {
                { "submissions/" + id, new {
                    taskId=taskId, studentId=PortalRepository.UserId, internshipId=(string)task["internshipId"],
                    companyId=(string)placement["companyId"], academicSupervisorId=(string)placement["academicSupervisorId"],
                    answer=answer ?? "", fileUrl=fileUrl ?? "", submissionLink="", status="Submitted", feedback="", reviewedAt="",
                    submittedAt=DatabaseSchema.FirstText(previous, "submittedAt").Length > 0 ? (string)previous["submittedAt"] : now, updatedAt=now } },
                { "tasks/" + taskId + "/status", "Submitted" }
            };
            if (previous != null) changes["submissionHistory/" + taskId + "/" + Guid.NewGuid().ToString("N")] = previous;
            await PortalRepository.Patch("", changes);
        }
        public static async Task Create(string title, string description, string criteria, string priority, decimal maximum, DateTime deadline, IEnumerable<string> students)
        {
            var ids = students.Distinct().ToList();
            if (title.Trim().Length < 3 || description.Trim().Length < 10 || criteria.Trim().Length < 5 || maximum <= 0 || deadline.Date <= DateTime.Today || ids.Count == 0)
                throw new ArgumentException("Enter task details, a positive maximum score, a future deadline and at least one trainee.");
            var changes = new Dictionary<string, object>();
            foreach (string studentId in ids)
            {
                var placement = await PortalRepository.PlacementForStudent(studentId);
                if (placement == null || (string)placement["companyId"] != PortalRepository.CompanyId || (string)placement["status"] != "active")
                    throw new InvalidOperationException("Tasks can only be assigned to your confirmed active trainees.");
                string id = Guid.NewGuid().ToString("N");
                changes["tasks/" + id] = new
                {
                    taskId = id, title = title.Trim(), description = description.Trim(), evaluationCriteria = criteria.Trim(),
                    priority = priority, maximumScore = maximum, dueDate = deadline.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                    studentId = studentId, companyId = PortalRepository.CompanyId, assignedBy = PortalRepository.UserId,
                    academicSupervisorId = (string)placement["academicSupervisorId"], internshipId = DatabaseSchema.Id(placement), companySupervisorId = PortalRepository.ProfileId,
                    status = "Assigned", active = true, createdAt = DateTime.UtcNow.ToString("o")
                };
            }
            await PortalRepository.Patch("", changes);
        }
        public static async Task Review(string id, string state, string feedback, decimal? score)
        {
            var task = await PortalRepository.CompanyTask(id);
            var submission = await PortalRepository.SubmissionForTask(id, (string)task["studentId"]);
            if (submission == null || (string)submission["studentId"] != (string)task["studentId"])
                throw new InvalidOperationException("The student must submit work before it can be reviewed.");
            if (state != "Reviewed" && state != "Revision Requested") throw new ArgumentException("Choose a review status.");
            decimal max = (decimal?)task["maximumScore"] ?? 0;
            if (state == "Reviewed" && max <= 0) throw new InvalidOperationException("Set a positive maximum score for this task before grading it.");
            string submissionId = DatabaseSchema.Id(submission);
            if (feedback.Trim().Length == 0 || (state == "Reviewed" && (!score.HasValue || score < 0 || score > max)))
                throw new ArgumentException("Enter feedback and a score within this task's maximum.");
            string now = DateTime.UtcNow.ToString("o");
            var review = new
            {
                studentId = (string)task["studentId"], companyId = PortalRepository.CompanyId,
                academicSupervisorId = (string)task["academicSupervisorId"], internshipId = (string)task["internshipId"],
                title = (string)task["title"], status = state, comments = feedback.Trim(), score = score, maximumScore = max, reviewedAt = now
            };
            await PortalRepository.Patch("", new Dictionary<string, object>
            {
                { "tasks/" + id + "/status", state }, { "tasks/" + id + "/score", score }, { "tasks/" + id + "/feedback", feedback.Trim() },
                { "taskFeedback/" + id, review }, { "submissions/" + submissionId + "/status", state },
                { "submissions/" + submissionId + "/feedback", feedback.Trim() }, { "submissions/" + submissionId + "/reviewedAt", now },
                { "reviewHistory/" + id + "/" + Guid.NewGuid().ToString("N"), review }
            });
        }
    }
}

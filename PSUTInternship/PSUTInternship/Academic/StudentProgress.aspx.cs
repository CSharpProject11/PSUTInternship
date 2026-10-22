using PSUTInternship.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json.Linq;
using System.Net.Http;
using System.Threading.Tasks;

namespace PSUTInternship.Academic
{
    public partial class StudentProgress : PSUTInternship.Shared.PortalPage
    {
        // Direct REST access through HttpClient. No extra service class.
        private static readonly HttpClient Http = PSUTInternship.Shared.FirebaseConfig.CreateClient();
        private static readonly string DatabaseUrl = PSUTInternship.Shared.FirebaseConfig.DatabaseUrl.TrimEnd('/');
        private string CurrentSupervisorId { get { return CurrentProfileId; } }

        private async Task<Dictionary<string, JObject>> ReadAsync(string collection)
        {
            return await PSUTInternship.Shared.PortalRepository.Collection(collection).ConfigureAwait(false);
        }

        private static string S(JToken item, string field, string fallback = "")
        {
            var token = item == null || item.Type != JTokenType.Object ? null : item[field];
            return token == null || token.Type == JTokenType.Null
                ? fallback : Convert.ToString(token);
        }
        private static int N(JToken item, string field)
        {
            int n;
            return int.TryParse(S(item, field), out n) ? n : 0;
        }
        private Dictionary<string, JObject> Read(string name)
        {
            // Cache Firebase reads per request, including calls from modal buttons.
            string key = "FirebaseStudentProgress:" + name;
            var cached = Context.Items[key] as Dictionary<string, JObject>;
            if (cached != null) return cached;
            var value = ReadAsync(name).GetAwaiter().GetResult();
            Context.Items[key] = value;
            return value;
        }
        private string SupervisorId { get { return CurrentSupervisorId; } }
        private string SupervisorName
        {
            get
            {
                var people = Read("academicSupervisors");
                JObject record;
                return people.TryGetValue(SupervisorId ?? "", out record)
                    ? S(record, "fullName", "Academic Supervisor") : "Academic Supervisor";
            }
        }
        private List<AcademicStudentRow> AssignedStudents()
        {
            var people = Read("academicSupervisors");
            var students = Read("students");
            var internships = Read("internships");
            var companies = Read("companies");
            var tasks = Read("tasks");
            var rootGroups = Read("studentGroups");
            JObject supervisor;
            if (!people.TryGetValue(SupervisorId, out supervisor))
                throw new InvalidOperationException("Supervisor profile was not found.");

            var allowed = new HashSet<string>(StringComparer.Ordinal);
            var groupKeys = new HashSet<string>(StringComparer.Ordinal);

            // Real data: nested academicSupervisors/{id}/groups/{groupId}/assignedStudentIds.
            var nested = supervisor["groups"] as JObject;
            if (nested != null)
                foreach (var group in nested.Properties())
                {
                    groupKeys.Add(group.Name);
                    var ids = group.Value["assignedStudentIds"] as JObject;
                    if (ids != null)
                        foreach (var id in ids.Properties())
                            if (id.Value.Type == JTokenType.Boolean && id.Value.Value<bool>())
                                allowed.Add(id.Name);
                }

            // Also support the original studentGroups collection.
            foreach (var group in rootGroups.Where(g => S(g.Value, "academicSupervisorId") == SupervisorId))
            {
                groupKeys.Add(group.Key);
                var ids = group.Value["studentIds"] as JObject;
                if (ids != null)
                    foreach (var id in ids.Properties())
                        if (id.Value.Type == JTokenType.Boolean && id.Value.Value<bool>())
                            allowed.Add(id.Name);
            }
            foreach (var student in students)
                if (S(student.Value, "academicSupervisorId") == SupervisorId ||
                    groupKeys.Contains(S(student.Value, "groupId")))
                    allowed.Add(student.Key);

            var result = new List<AcademicStudentRow>();
            foreach (string id in allowed)
            {
                JObject student;
                if (!students.TryGetValue(id, out student)) continue;
                if (!string.IsNullOrWhiteSpace(S(student, "academicSupervisorId")) && S(student, "academicSupervisorId") != SupervisorId) continue;
                if (string.Equals(S(student, "isActive"), "false", StringComparison.OrdinalIgnoreCase)) continue;
                var placement = internships
                    .Where(x => S(x.Value, "studentId") == id && S(x.Value, "academicSupervisorId") == SupervisorId)
                    .OrderByDescending(x => S(x.Value, "startDate")).FirstOrDefault();
                JObject internship = placement.Value;
                JObject company = null;
                if (internship != null) companies.TryGetValue(S(internship, "companyId"), out company);
                string companyName = S(company, "name", S(student, "company", "Not assigned"));
                int required = internship != null ? N(internship, "requiredHours") : 0;
                if (required <= 0) required = N(student, "requiredHours");
                if (required <= 0) required = N(student, "requiredTrainingHours");
                decimal approved = (decimal?)internship?["approvedHours"] ?? 0;
                int progress = required > 0 ? (int)Math.Round(100m * approved / required) : 0;
                progress = Math.Max(0, Math.Min(100, progress));
                string state = internship == null ? "Not Started" :
                    (string.Equals(S(internship, "status"), "completed", StringComparison.OrdinalIgnoreCase)
                        ? "Completed" : (tasks.Values.Any(t => S(t, "studentId") == id && S(t, "status") != "Reviewed" && DateTime.TryParse(S(t, "dueDate"), out DateTime due) && due.Date < DateTime.Today) ? "At Risk" : "On Track"));
                result.Add(new AcademicStudentRow
                {
                    StudentId = id,
                    StudentName = S(student, "fullName", "Unknown student"),
                    Company = companyName,
                    ApprovedHours = approved,
                    RequiredHours = required,
                    Progress = progress,
                    Status = state,
                    TaskCount = tasks.Count(t => S(t.Value, "studentId") == id &&
                        (internship == null || S(t.Value, "internshipId") == placement.Key)),
                    InternshipId = internship == null ? "" : placement.Key
                });
            }
            return result.OrderBy(x => x.StudentName).ToList();
        }
        private static string ProgressStatus(string status)
        {
            switch ((status ?? "").Trim().ToLowerInvariant())
            {
                case "on_track": case "on track": return "On Track";
                case "at_risk": case "at risk": case "delayed": case "needs_follow_up": return "At Risk";
                case "completed": return "Completed";
                default: return string.IsNullOrWhiteSpace(status) ? "Not Started" : status.Replace('_', ' ');
            }
        }
        private AcademicStudentRow FindAssignedStudent(string studentId)
        {
            // Verify the signed-in supervisor assignment before showing student details.
            return AssignedStudents().FirstOrDefault(x => x.StudentId == studentId);
        }
        private void HandleError(Exception ex)
        {
            CloseAllModals();
            lblPageError.Text = HttpUtility.HtmlEncode("Unable to load student data from Firebase. Check database read access.");
            lblPageError.Visible = true;
            System.Diagnostics.Trace.TraceError(ex.ToString());
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try { ddlStatus.SelectedValue = "All"; RefreshPage(); }
                catch (Exception ex) { HandleError(ex); }
            }
        }
        private void RefreshPage()
        {
            var all = AssignedStudents();
            lblPageError.Visible = false;
            lblSupervisorName.Text = HttpUtility.HtmlEncode(SupervisorName);
            lblTotal.Text = all.Select(x => x.StudentId).Distinct().Count().ToString();
            lblOnTrack.Text = all.Count(x => x.Status == "On Track").ToString();
            lblAttention.Text = all.Count(x => x.Status == "At Risk").ToString();
            string search = (txtSearch.Text ?? "").Trim();
            string status = ddlStatus.SelectedValue;
            var filtered = all.Where(x =>
                (string.IsNullOrEmpty(search) ||
                 x.StudentName.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0 ||
                 x.StudentId.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0 ||
                 x.Company.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0) &&
                (status == "All" || x.Status.Equals(status, StringComparison.OrdinalIgnoreCase))).ToList();
            gvStudents.DataSource = filtered;
            gvStudents.DataBind();
            btnOnTrack.CssClass = "stat-card-hit" + (status == "On Track" ? " selected" : "");
            btnAttention.CssClass = "stat-card-hit" + (status == "At Risk" ? " selected" : "");
        }
        protected void btnFilter_Click(object sender, EventArgs e) { try { RefreshPage(); } catch (Exception ex) { HandleError(ex); } }
        protected void btnReset_Click(object sender, EventArgs e)
        { txtSearch.Text = ""; ddlStatus.SelectedValue = "All"; btnFilter_Click(sender, e); }
        protected void btnOnTrack_Click(object sender, EventArgs e)
        { ddlStatus.SelectedValue = ddlStatus.SelectedValue == "On Track" ? "All" : "On Track"; btnFilter_Click(sender, e); }
        protected void btnAttention_Click(object sender, EventArgs e)
        { ddlStatus.SelectedValue = ddlStatus.SelectedValue == "At Risk" ? "All" : "At Risk"; btnFilter_Click(sender, e); }
        protected void btnTasks_Command(object sender, CommandEventArgs e)
        {
            try
            {
                var student = FindAssignedStudent(Convert.ToString(e.CommandArgument));
                if (student == null) throw new InvalidOperationException("Student is not assigned to this supervisor.");
                lblTaskStudent.Text = HttpUtility.HtmlEncode(student.StudentName);
                lblTaskCompany.Text = HttpUtility.HtmlEncode(student.Company);
                lblTaskSupervisor.Text = HttpUtility.HtmlEncode(SupervisorName);
                lblTaskHours.Text = student.ApprovedHours + " / " + student.RequiredHours + " hrs";
                var tasks = Read("tasks");
                var submissions = Read("submissions");
                var output = new List<AcademicTaskRow>();
                foreach (var t in tasks.Where(t => S(t.Value, "studentId") == student.StudentId && S(t.Value, "internshipId") == student.InternshipId))
                {
                    var matches = submissions.Values.Where(s => S(s, "studentId") == student.StudentId &&
                        S(s, "taskId") == t.Key && S(s, "internshipId") == student.InternshipId).ToList();
                    if (matches.Count == 0) matches.Add(null);
                    foreach (var submission in matches)
                    {
                        output.Add(new AcademicTaskRow
                        {
                            Title = S(t.Value, "title"),
                            Description = S(t.Value, "description"),
                            CreatedAt = S(t.Value, "createdAt", "Not recorded"),
                            DueDate = S(t.Value, "dueDate", "Not recorded"),
                            Status = S(t.Value, "status", "Unknown"),
                            SubmissionStatus = S(submission, "status", "Not submitted"),
                            SubmittedAt = S(submission, "submittedAt", "Not submitted"),
                            FileName = S(submission, "fileName", "No file uploaded"),
                            FileUrl = SafeHttps(S(submission, "fileUrl")),
                            SubmissionLink = SafeHttps(S(submission, "attachmentUrl")),
                            Score = S(t.Value, "score", "—") + " / " + S(t.Value, "maximumScore", "—"),
                            Feedback = S(submission, "feedback", "No feedback yet"),
                            ReviewedAt = S(submission, "reviewedAt", "Not reviewed")
                        });
                    }
                }
                rptTasks.DataSource = output.OrderBy(x => x.DueDate).ToList();
                rptTasks.DataBind();
                lblTasksCount.Text = tasks.Count(x => S(x.Value, "studentId") == student.StudentId &&
                    S(x.Value, "internshipId") == student.InternshipId) + " Tasks";
                pnlNoTasks.Visible = output.Count == 0;
                lblPageError.Visible = false;
                pnlEvaluationModal.Visible = false;
                pnlTasksModal.Visible = true;
            }
            catch (Exception ex) { HandleError(ex); }
        }
        protected void btnEvaluation_Command(object sender, CommandEventArgs e)
        {
            try
            {
                var student = FindAssignedStudent(Convert.ToString(e.CommandArgument));
                if (student == null) throw new InvalidOperationException("Student is not assigned to this supervisor.");
                var matches = Read("evaluations").Values
                    .Where(x => S(x, "studentId") == student.StudentId &&
                        S(x, "internshipId") == student.InternshipId &&
                        S(x, "evaluatorRole") == "academicSupervisor" &&
                        S(x, "evaluatorId") == SupervisorId).ToList();
                var evaluation = matches.OrderByDescending(x => S(x, "submittedAt")).FirstOrDefault();
                lblEvaluationStudent.Text = HttpUtility.HtmlEncode(student.StudentName);
                lblEvaluationCompany.Text = HttpUtility.HtmlEncode(student.Company);
                lblEvaluationSupervisor.Text = HttpUtility.HtmlEncode(SupervisorName);
                lblEvaluationHours.Text = student.ApprovedHours + " / " + student.RequiredHours + " hrs";
                lblEvaluationRecommendation.Text = HttpUtility.HtmlEncode(S(evaluation, "recommendation", "No evaluation available").Replace('_', ' '));
                lblEvaluationComments.Text = HttpUtility.HtmlEncode(S(evaluation, "comments", "No academic evaluation recorded."));
                lblEvaluationScore.Text = HttpUtility.HtmlEncode(S(evaluation, "overallScore", "Not finalized"));
                lblEvaluationDate.Text = HttpUtility.HtmlEncode(S(evaluation, "submittedAt", "Not submitted"));
                string state = S(evaluation, "status", "Not available");
                lblEvaluationStatus.Text = HttpUtility.HtmlEncode(state);
                lblEvaluationStatus.CssClass = "status " + GetEvaluationStatusClass(state);
                lblPageError.Visible = false;
                pnlTasksModal.Visible = false;
                pnlEvaluationModal.Visible = true;
            }
            catch (Exception ex) { HandleError(ex); }
        }
        private static string SafeHttps(string value)
        {
            Uri uri;
            return Uri.TryCreate(value, UriKind.Absolute, out uri) && uri.Scheme == Uri.UriSchemeHttps
                ? uri.AbsoluteUri : "";
        }
        protected bool HasUrl(object value) { return !string.IsNullOrEmpty(SafeHttps(Convert.ToString(value))); }
        protected void btnCloseModal_Click(object sender, EventArgs e) { CloseAllModals(); }
        private void CloseAllModals() { pnlTasksModal.Visible = false; pnlEvaluationModal.Visible = false; }
        protected string GetStatusClass(object x)
        {
            switch (ProgressStatus(Convert.ToString(x)))
            { case "On Track": return "ontrack"; case "At Risk": return "atrisk"; case "Completed": return "completed"; default: return "pending"; }
        }
        protected string GetTaskStatusClass(object x)
        {
            switch ((Convert.ToString(x) ?? "").Trim().ToLowerInvariant())
            { case "successful": return "ontrack"; case "failed": return "failed"; case "submitted": return "submitted"; default: return "assigned"; }
        }
        protected string GetEvaluationStatusClass(string x)
        { return string.Equals(x, "submitted", StringComparison.OrdinalIgnoreCase) ? "submitted" : "pending"; }
        protected string GetInitials(object x)
        {
            var parts = (Convert.ToString(x) ?? "").Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 0) return "?";
            return (parts[0].Substring(0, 1) + (parts.Length > 1 ? parts[parts.Length - 1].Substring(0, 1) : "")).ToUpperInvariant();
        }
    }
}

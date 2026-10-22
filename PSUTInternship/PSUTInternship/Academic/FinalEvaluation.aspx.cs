using PSUTInternship.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PSUTInternship.Academic
{
    public partial class FinalEvaluation : PSUTInternship.Shared.PortalPage
    {
        // Final evaluations are scoped to the signed-in academic supervisor.
        private static readonly string DatabaseUrl = PSUTInternship.Shared.FirebaseConfig.DatabaseUrl.TrimEnd('/');
        private string SupervisorId { get { return CurrentProfileId; } }
        private static readonly HttpClient Http = PSUTInternship.Shared.FirebaseConfig.CreateClient();





        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                RegisterAsyncTask(new PageAsyncTask(InitializeAsync));
        }

        private async Task InitializeAsync()
        {
            try
            {
                var supervisor = await ReadAsync("academicSupervisors/" + SupervisorId);
                var name = Val(supervisor, "fullName", "Academic Supervisor");
                lblSupervisor.Text = H(name);
                lblSupervisorPrint.Text = H(name);
                txtScore.Attributes["max"] = PSUTInternship.Shared.EvaluationPolicy.AcademicMaximum.ToString(System.Globalization.CultureInfo.InvariantCulture);
                lblInitials.Text = H(Initials(name));
                var ids = await AssignedStudentIdsAsync(supervisor);
                var students = Children(await ReadAsync("students"));
                ddlStudent.Items.Clear();
                ddlStudent.Items.Add(new ListItem("Select assigned student", ""));
                foreach (var x in students.Where(x => ids.Contains(x.Key))
                             .OrderBy(x => Val(x.Value, "fullName")))
                {
                    string label = Val(x.Value, "fullName", x.Key) + " — " + Val(x.Value, "studentNumber", "No number");
                    ddlStudent.Items.Add(new ListItem(label, x.Key));
                }
                pnlReport.Visible = false;
                if (ids.Count == 0) Message("No students are assigned to this supervisor.", true);
            }
            catch (Exception ex) { HandleFailure(ex); }
        }

        private async Task<HashSet<string>> AssignedStudentIdsAsync(JToken supervisor)
        {
            return new HashSet<string>((await PSUTInternship.Shared.PortalRepository.Collection("students")).Keys, StringComparer.Ordinal);
        }

        protected void ddlStudent_SelectedIndexChanged(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(LoadSelectedAsync));
        }

        private async Task LoadSelectedAsync()
        {
            pnlReport.Visible = false;
            lblMessage.Visible = false;
            if (string.IsNullOrWhiteSpace(ddlStudent.SelectedValue)) return;
            try
            {
                var report = await BuildReportAsync(ddlStudent.SelectedValue);
                BindReport(report);
            }
            catch (Exception ex) { HandleFailure(ex); }
        }

        private async Task<AcademicReportData> BuildReportAsync(string studentId)
        {
            var supervisor = await ReadAsync("academicSupervisors/" + SupervisorId);
            var assigned = await AssignedStudentIdsAsync(supervisor);
            if (!assigned.Contains(studentId))
                throw new InvalidOperationException("The selected student is not assigned to this supervisor.");
            var student = await ReadAsync("students/" + Uri.EscapeDataString(studentId));
            if (student == null) throw new InvalidOperationException("Student record not found.");

            // Parallel independent reads; no fictitious data is inserted.
            var iTask = ReadAsync("internships");
            var companyTask = ReadAsync("companies");
            var tasksTask = ReadAsync("tasks");
            var submissionsTask = ReadAsync("submissions");
            var evaluationsTask = ReadAsync("evaluations");
            var reportsTask = Task.FromResult<JToken>(null);
            await Task.WhenAll(iTask, companyTask, tasksTask, submissionsTask, evaluationsTask, reportsTask);

            var internship = Children(iTask.Result)
                .Where(x => Val(x.Value, "studentId") == studentId && Val(x.Value, "academicSupervisorId") == SupervisorId)
                .OrderByDescending(x => Val(x.Value, "startDate"))
                .FirstOrDefault();
            var report = new AcademicReportData
            {
                StudentId = studentId,
                StudentName = Val(student, "fullName", "Unknown"),
                StudentNumber = Val(student, "studentNumber", "Not recorded"),
                InternshipId = internship.Key,
                ApprovedHours = Number(internship.Value, "approvedHours"),
                RequiredHours = Number(internship.Value, "requiredHours")
            };
            if (report.RequiredHours <= 0) report.RequiredHours = Number(student, "requiredHours");
            if (report.RequiredHours <= 0) report.RequiredHours = Number(student, "requiredTrainingHours");
            var company = Children(companyTask.Result).FirstOrDefault(x => x.Key == Val(internship.Value, "companyId"));
            report.Company = Val(company.Value, "name", Val(student, "company", "Not assigned"));

            if (!string.IsNullOrWhiteSpace(report.InternshipId))
            {
                var taskRecords = Children(tasksTask.Result)
                    .Where(x => Val(x.Value, "studentId") == studentId && Val(x.Value, "internshipId") == report.InternshipId).ToList();
                var submissionRecords = Children(submissionsTask.Result)
                    .Where(x => Val(x.Value, "studentId") == studentId &&
                        (string.IsNullOrEmpty(Val(x.Value, "internshipId")) || Val(x.Value, "internshipId") == report.InternshipId)).ToList();
                foreach (var task in taskRecords)
                {
                    var match = submissionRecords.Where(x => Val(x.Value, "taskId") == task.Key)
                        .OrderByDescending(x => Val(x.Value, "submittedAt")).FirstOrDefault();
                    report.Tasks.Add(new EvaluationTaskRow
                    {
                        Title = Val(task.Value, "title", "Untitled task"),
                        Status = Val(task.Value, "status", "Unknown"),
                        Submission = Val(match.Value, "status", "Not submitted"),
                        Feedback = Val(match.Value, "feedback", "Not provided")
                    });
                }
                var companyEvaluation = Children(evaluationsTask.Result)
                    .Where(x => Val(x.Value, "studentId") == studentId && Val(x.Value, "internshipId") == report.InternshipId &&
                        string.Equals(Val(x.Value, "evaluatorRole"), "companySupervisor", StringComparison.OrdinalIgnoreCase))
                    .OrderByDescending(x => Val(x.Value, "submittedAt")).FirstOrDefault();
                report.CompanyEvaluation = companyEvaluation.Value;
                report.AcademicEvaluation = Children(evaluationsTask.Result)
                    .Where(x => Val(x.Value, "studentId") == studentId && Val(x.Value, "internshipId") == report.InternshipId &&
                        Val(x.Value, "evaluatorId") == SupervisorId &&
                        string.Equals(Val(x.Value, "evaluatorRole"), "academicSupervisor", StringComparison.OrdinalIgnoreCase))
                    .OrderByDescending(x => Val(x.Value, "submittedAt")).Select(x => x.Value).FirstOrDefault();
                var completion = Children(reportsTask.Result)
                    .Where(x => Val(x.Value, "studentId") == studentId && Val(x.Value, "internshipId") == report.InternshipId)
                    .FirstOrDefault();
                report.CompanyFileUrl = Val(completion.Value, "pdfUrl");
            }
            report.CompanyResult = Val(report.CompanyEvaluation, "result", Val(report.CompanyEvaluation, "finalResult", "Not recorded"));
            report.CompanyFeedback = Val(report.CompanyEvaluation, "feedback", Val(report.CompanyEvaluation, "comments", "No company supervisor feedback recorded."));
            return report;
        }

        private void BindReport(AcademicReportData report)
        {
            pnlReport.Visible = true;
            lblStudent.Text = H(report.StudentName);
            lblStudentNumber.Text = H(report.StudentNumber);
            lblCompany.Text = H(report.Company);
            lblInternship.Text = H(string.IsNullOrWhiteSpace(report.InternshipId) ? "No internship record" : report.InternshipId);
            lblTaskTotal.Text = report.Tasks.Count.ToString();
            lblTaskCompleted.Text = report.Tasks.Count(x => Completed(x.Status)).ToString();
            lblHours.Text = report.ApprovedHours.ToString("0.##", CultureInfo.InvariantCulture) + " / " + report.RequiredHours.ToString("0.##", CultureInfo.InvariantCulture);
            lblCompanyResult.Text = H(report.CompanyResult);
            lblCompanyStatus.Text = H(Val(report.CompanyEvaluation, "status", "Not submitted"));
            lblCompanyScore.Text = H(Val(report.CompanyEvaluation, "overallScore", "Not recorded") + " / " + Val(report.CompanyEvaluation, "totalMaximum", "—"));
            lblCompanyFeedback.Text = H(report.CompanyFeedback);
            lblCompanyRecommendation.Text = H(Val(report.CompanyEvaluation, "recommendation", "Not recorded"));
            lblAcademicStatus.Text = H(Val(report.AcademicEvaluation, "status", "Not submitted"));
            gvTasks.DataSource = report.Tasks;
            gvTasks.DataBind();
            Uri uri;
            lnkCompanyFile.Visible = Uri.TryCreate(report.CompanyFileUrl, UriKind.Absolute, out uri) && uri.Scheme == Uri.UriSchemeHttps;
            if (lnkCompanyFile.Visible) lnkCompanyFile.NavigateUrl = uri.AbsoluteUri;
            bool hasInternship = !string.IsNullOrWhiteSpace(report.InternshipId);
            bool companySubmitted = string.Equals(Val(report.CompanyEvaluation, "status"), "submitted", StringComparison.OrdinalIgnoreCase);
            bool alreadySubmitted = string.Equals(Val(report.AcademicEvaluation, "status"), "submitted", StringComparison.OrdinalIgnoreCase);
            btnSubmit.Enabled = hasInternship && companySubmitted && !alreadySubmitted;
            lblReportNotice.Text = !hasInternship
                ? "No internship record exists for this student. You can review the profile, but submission is unavailable."
                : !companySubmitted ? "The company's evaluation has not been submitted. Academic forwarding is unavailable until it is completed."
                : alreadySubmitted ? "Your evaluation has already been submitted to the coordinator queue."
                : "Company evaluation submitted. You can complete the academic assessment and forward it to the coordinator queue.";
            txtScore.Text = Val(report.AcademicEvaluation, "overallScore");
            txtComments.Text = Val(report.AcademicEvaluation, "comments");
            string recommendation = Val(report.AcademicEvaluation, "recommendation");
            ddlRecommendation.ClearSelection();
            var item = ddlRecommendation.Items.FindByValue(recommendation);
            if (item != null) item.Selected = true;
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(SubmitAsync));
        }

        private async Task SubmitAsync()
        {
            string studentId = ddlStudent.SelectedValue;
            string comments = (txtComments.Text ?? "").Trim();
            string recommendation = ddlRecommendation.SelectedValue;
            decimal score;
            if (string.IsNullOrEmpty(studentId)) { Message("Please select a student.", true); return; }
            if (!decimal.TryParse(txtScore.Text, NumberStyles.Number, CultureInfo.InvariantCulture, out score) || score < 0 || score > PSUTInternship.Shared.EvaluationPolicy.AcademicMaximum)
            { Message("Enter an academic score within the configured maximum.", true); return; }
            if (comments.Length < 10 || comments.Length > 3000) { Message("Academic feedback must contain 10 to 3000 characters.", true); return; }
            if (string.IsNullOrWhiteSpace(recommendation)) { Message("Select an academic recommendation.", true); return; }
            try
            {
                // Re-read on submission; do not trust the UI or previously loaded data.
                var report = await BuildReportAsync(studentId);
                if (string.IsNullOrWhiteSpace(report.InternshipId))
                    throw new InvalidOperationException("Cannot submit without an internship record.");
                if (!string.Equals(Val(report.CompanyEvaluation, "status"), "submitted", StringComparison.OrdinalIgnoreCase))
                    throw new InvalidOperationException("The company evaluation must be submitted first.");
                if (string.Equals(Val(report.AcademicEvaluation, "status"), "submitted", StringComparison.OrdinalIgnoreCase))
                    throw new InvalidOperationException("Academic evaluation already submitted.");

                // Unique, stable key per internship; company supervisor evaluation is never overwritten.
                var savedEvaluation = await PSUTInternship.Shared.PortalRepository.EvaluationForPlacement(studentId, report.InternshipId, "academicSupervisor");
                string academicId = savedEvaluation == null ? "academic_" + report.InternshipId : PSUTInternship.Shared.DatabaseSchema.Id(savedEvaluation);
                var companyEvaluation = await PSUTInternship.Shared.PortalRepository.EvaluationForPlacement(studentId, report.InternshipId, "companySupervisor");
                var fields = new JObject
                {
                    ["companyEvaluationId"] = PSUTInternship.Shared.DatabaseSchema.Id(companyEvaluation),
                    ["evaluationType"] = "final",
                    ["academicSupervisorId"] = SupervisorId,
                    ["companyId"] = (string)report.CompanyEvaluation?["companyId"],
                    ["evaluatorRole"] = "academicSupervisor",
                    ["evaluatorId"] = SupervisorId,
                    ["studentId"] = studentId,
                    ["internshipId"] = report.InternshipId,
                    ["overallScore"] = score,
                    ["comments"] = comments,
                    ["recommendation"] = recommendation,
                    ["status"] = "submitted",
                    ["coordinatorStatus"] = "pending",
                    ["submittedAt"] = DateTime.UtcNow.ToString("o", CultureInfo.InvariantCulture)
                };
                // Save the exact combined report snapshot for the coordinator, not just an ID.
                // No fabricated company result is inserted: values come from the company evaluation.
                var reportSnapshot = new JObject
                {
                    ["studentId"] = studentId,
                    ["studentName"] = report.StudentName,
                    ["studentNumber"] = report.StudentNumber,
                    ["company"] = report.Company,
                    ["internshipId"] = report.InternshipId,
                    ["requiredHours"] = report.RequiredHours,
                    ["approvedHours"] = report.ApprovedHours,
                    ["totalTasks"] = report.Tasks.Count,
                    ["completedTasks"] = report.Tasks.Count(x => Completed(x.Status)),
                    ["tasks"] = JArray.FromObject(report.Tasks),
                    ["companyEvaluation"] = report.CompanyEvaluation == null ? JValue.CreateNull() : report.CompanyEvaluation.DeepClone(),
                    ["companyResult"] = report.CompanyResult,
                    ["companyFeedback"] = report.CompanyFeedback,
                    ["companyReportUrl"] = report.CompanyFileUrl ?? "",
                    ["academicEvaluation"] = fields.DeepClone(),
                    ["academicSupervisorId"] = SupervisorId,
                    ["generatedAt"] = DateTime.UtcNow.ToString("o", CultureInfo.InvariantCulture)
                };
                // One atomic multipath PATCH updates the academic evaluation and its coordinator queue.
                var changes = new JObject
                {
                    ["evaluations/" + academicId] = fields,
                    ["coordinatorReviewQueue/" + academicId] = new JObject
                    {
                        ["academicEvaluationId"] = academicId,
                        ["studentId"] = studentId,
                        ["internshipId"] = report.InternshipId,
                        ["academicSupervisorId"] = SupervisorId,
                        ["status"] = "pending",
                        ["submittedAt"] = fields["submittedAt"].DeepClone(),
                        ["combinedReport"] = reportSnapshot
                    }
                };
                await PatchAsync("", changes);
                Message("Evaluation saved in Firebase and added to the coordinator review queue. The coordinator can review it in Final Completion Review.", false);
                await LoadReportAfterSubmitAsync(studentId);
            }
            catch (Exception ex) { HandleFailure(ex); }
        }

        private async Task LoadReportAfterSubmitAsync(string studentId)
        {
            var report = await BuildReportAsync(studentId);
            BindReport(report);
        }

        private static bool Completed(string status)
        {
            var s = (status ?? "").Trim().ToLowerInvariant();
            return s == "reviewed" || s == "completed" || s == "successful" || s == "approved" || s == "done";
        }
        private static string H(string text) { return HttpUtility.HtmlEncode(text ?? ""); }
        private static string Initials(string name)
        {
            var p = (name ?? "").Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            return p.Length == 0 ? "AS" : (p[0].Substring(0, 1) + (p.Length > 1 ? p[p.Length - 1].Substring(0, 1) : "")).ToUpperInvariant();
        }
        private static string Val(JToken token, string field, string fallback = "")
        {
            if (token == null || token.Type != JTokenType.Object) return fallback;
            var value = token[field];
            return value == null || value.Type == JTokenType.Null || value.Type == JTokenType.Object || value.Type == JTokenType.Array
                ? fallback : value.ToString();
        }
        private static double Number(JToken token, string field)
        {
            double n;
            return double.TryParse(Val(token, field), NumberStyles.Any, CultureInfo.InvariantCulture, out n) ? n : 0;
        }
        private static IEnumerable<KeyValuePair<string, JToken>> Children(JToken node)
        {
            var obj = node as JObject;
            return obj == null ? Enumerable.Empty<KeyValuePair<string, JToken>>() :
                obj.Properties().Select(p => new KeyValuePair<string, JToken>(p.Name, p.Value));
        }
        private static async Task<JToken> ReadAsync(string path)
        {
            return await PSUTInternship.Shared.PortalRepository.ReadObject(path);
        }
        private static async Task PatchAsync(string path, JObject body)
        {
            string url = DatabaseUrl.TrimEnd('/') + "/" + (string.IsNullOrEmpty(path) ? "" : path.Trim('/') + "/") + ".json";
            using (var request = new HttpRequestMessage(new HttpMethod("PATCH"), url))
            {
                request.Content = new StringContent(body.ToString(Formatting.None), Encoding.UTF8, "application/json");
                using (var response = await Http.SendAsync(request))
                {
                    if (!response.IsSuccessStatusCode)
                        throw new HttpRequestException("Firebase save failed (HTTP " + (int)response.StatusCode + ").");
                }
            }
        }
        private void Message(string message, bool error)
        {
            lblMessage.Text = H(message);
            lblMessage.CssClass = error ? "message msg-error no-print" : "message msg-ok no-print";
            lblMessage.Visible = true;
        }
        private void HandleFailure(Exception ex)
        {
            System.Diagnostics.Trace.TraceError("FinalEvaluation: " + ex);
            Message(ex is InvalidOperationException ? ex.Message :
                "Firebase request failed. Check database connection, permissions and server logs.", true);
        }
    }
}

using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI.WebControls;
namespace PSUTInternship.Admin
{
    public partial class CompletionReview : PortalPage
    {
        protected async void Page_Load(object sender, EventArgs e) { if (!IsPostBack) await LoadReviews(); }
        protected async void applyFilters_Click(object sender, EventArgs e)
        {
            await LoadReviews();
        }
        private async Task LoadReviews()
        {
            try
            {
                var queue = await PortalRepository.Collection("coordinatorReviewQueue");
                var hours = await PortalRepository.Collection("trainingHours");
                var tasks = await PortalRepository.Collection("tasks");
                var evaluations = await PortalRepository.Collection("evaluations");
                var placements = await PortalRepository.Collection("internships");
                var students = await PortalRepository.Collection("students");
                var hourRecords = Newtonsoft.Json.Linq.JObject.FromObject(hours);
                var rows = queue.Select(x =>
                {
                    var saved = x.Value["combinedReport"] as Newtonsoft.Json.Linq.JObject ?? new Newtonsoft.Json.Linq.JObject();
                    string uid = (string)x.Value["studentId"] ?? (string)saved["studentId"] ?? "";
                    string placementId = (string)x.Value["internshipId"] ?? (string)saved["internshipId"] ?? "";
                    Newtonsoft.Json.Linq.JObject placement;
                    placements.TryGetValue(placementId, out placement);
                    Newtonsoft.Json.Linq.JObject student;
                    students.TryGetValue(uid, out student);
                    var companyEval = evaluations.Values.Where(e => (string)e["studentId"] == uid && (string)e["internshipId"] == placementId &&
                        string.Equals((string)e["evaluatorRole"], "companySupervisor", StringComparison.OrdinalIgnoreCase))
                        .OrderByDescending(e => (string)e["submittedAt"]).FirstOrDefault();
                    var academicEval = evaluations.Values.Where(e => (string)e["studentId"] == uid && (string)e["internshipId"] == placementId &&
                        string.Equals((string)e["evaluatorRole"], "academicSupervisor", StringComparison.OrdinalIgnoreCase))
                        .OrderByDescending(e => (string)e["submittedAt"]).FirstOrDefault();
                    decimal approved = CoordinatorData.ApprovedHours(hourRecords, placementId, uid);
                    decimal required = (decimal?)student?["requiredHours"] ?? (decimal?)student?["requiredTrainingHours"] ??
                        (decimal?)placement?["requiredHours"] ?? (decimal?)saved["requiredHours"] ?? 0;
                    var activeTasks = tasks.Values.Where(t => (string)t["studentId"] == uid && (string)t["internshipId"] == placementId && (bool?)t["active"] != false).ToList();
                    int completedTasks = activeTasks.Count(t => string.Equals(DatabaseSchema.WorkflowStatus((string)t["status"]), "Reviewed", StringComparison.OrdinalIgnoreCase));
                    var liveReport = (Newtonsoft.Json.Linq.JObject)saved.DeepClone();
                    liveReport["studentId"] = uid; liveReport["requiredHours"] = required; liveReport["approvedHours"] = approved;
                    liveReport["totalTasks"] = activeTasks.Count; liveReport["completedTasks"] = completedTasks;
                    liveReport["companyEvaluation"] = companyEval == null ? Newtonsoft.Json.Linq.JValue.CreateNull() : companyEval.DeepClone();
                    liveReport["academicEvaluation"] = academicEval == null ? Newtonsoft.Json.Linq.JValue.CreateNull() : academicEval.DeepClone();
                    var current = new Newtonsoft.Json.Linq.JObject { ["status"] = (string)x.Value["status"], ["combinedReport"] = liveReport };
                    return new
                    {
                        Id = x.Key,
                        StudentId = uid,
                        Name = (string)student?["fullName"] ?? (string)saved["studentName"],
                        StudentNumber = (string)student?["studentNumber"] ?? (string)saved["studentNumber"] ?? "Not available",
                        Ready = Ready(current),
                        TasksReady = TasksReady(current) ? "Met" : "Pending",
                        Hours = approved + " / " + required,
                        CompanyScore = (string)companyEval?["overallScore"] + " / " + (string)companyEval?["totalMaximum"],
                        AcademicResult = CoordinatorData.AcademicResult(academicEval),
                        CompanyComments = (string)companyEval?["comments"],
                        AcademicComments = (string)academicEval?["comments"],
                        Recommendation = CoordinatorData.AcademicResult(academicEval),
                        Status = (string)x.Value["status"],
                        Placement = (string)placement?["opportunityTitle"] ?? (string)saved["company"] ?? "Not available",
                        Percent = Percent(current),
                        HoursReady = required > 0 && approved >= required ? "Met" : "Pending",
                        CompanyReady = (string)companyEval?["status"] ?? "Pending",
                        AcademicReady = (string)academicEval?["status"] ?? "Pending"
                    };
                }).ToList();
                string search = (reviewSearch.Text ?? "").Trim();
                string filter = reviewFilter.SelectedValue;
                var filtered = rows.Where(x =>
                    (search.Length == 0 || new[] { x.Name, x.StudentNumber, x.Placement }.Any(value =>
                        (value ?? "").IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0)) &&
                    (filter == "All" ||
                     (filter == "Approved" && x.Status == "approved") ||
                     (filter == "Ready" && x.Status != "approved" && x.Ready) ||
                     (filter == "Pending" && x.Status != "approved" && !x.Ready))).ToList();
                reviews.DataSource = filtered;
                reviews.DataBind();
                resultCount.Text = filtered.Count + " of " + rows.Count + " reviews";
                empty.Visible = filtered.Count == 0;
                empty.Text = rows.Count == 0 ? "No evaluations have been forwarded for review yet." : "No reviews match your search and filters. Try another name or reset the filters.";
            }
            catch (Exception ex) { notice.Text = Server.HtmlEncode(ex.Message); }
        }
        private static bool TasksReady(Newtonsoft.Json.Linq.JObject row)
        {
            return ((int?)row["combinedReport"]?["completedTasks"] ?? 0) >= ((int?)row["combinedReport"]?["totalTasks"] ?? 0);
        }
        private static bool Ready(Newtonsoft.Json.Linq.JObject row)
        {
            var report = row == null ? null : row["combinedReport"] as Newtonsoft.Json.Linq.JObject;
            if (report == null || Percent(row) < 100 || !TasksReady(row)) return false;

            var company = report["companyEvaluation"] as Newtonsoft.Json.Linq.JObject;
            var academic = report["academicEvaluation"] as Newtonsoft.Json.Linq.JObject;
            if (company == null || academic == null) return false;

            string companyStatus = Convert.ToString(company["status"]);
            string academicStatus = Convert.ToString(academic["status"]);
            string recommendation = Convert.ToString(academic["recommendation"]);
            string evaluatorId = Convert.ToString(academic["evaluatorId"]);
            string supervisorId = Convert.ToString(report["academicSupervisorId"]);

            return companyStatus == "submitted"
                && academicStatus == "submitted"
                && recommendation == "Pass"
                && evaluatorId == supervisorId
                && FinalGradeReady(report);
        }
        private static bool FinalGradeReady(Newtonsoft.Json.Linq.JObject report)
        {
            try
            {
                if (report == null) return false;
                var company = report["companyEvaluation"] as Newtonsoft.Json.Linq.JObject;
                var academic = report["academicEvaluation"] as Newtonsoft.Json.Linq.JObject;
                if (company == null || academic == null) return false;
                decimal companyScore = company["overallScore"] == null ? -1 : company["overallScore"].Value<decimal>();
                decimal companyMaximum = company["totalMaximum"] == null ? 0 : company["totalMaximum"].Value<decimal>();
                decimal academicScore = academic["overallScore"] == null ? -1 : academic["overallScore"].Value<decimal>();
                decimal grade = EvaluationPolicy.FinalGrade(companyScore, companyMaximum, academicScore);
                return grade >= EvaluationPolicy.PassGrade;
            }
            catch { return false; }
        }
        private static decimal Percent(Newtonsoft.Json.Linq.JObject row) { decimal approved = (decimal?)row["combinedReport"]?["approvedHours"] ?? 0, required = (decimal?)row["combinedReport"]?["requiredHours"] ?? 0; return required > 0 ? Math.Min(100, Math.Round(approved * 100 / required, 1)) : 0; }
        protected async void reviews_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Approve") return;
            try { await CompletionWorkflow.Approve(Convert.ToString(e.CommandArgument)); notice.Text = "Certificate created. The student can download it from My Progress & Evaluation."; await LoadReviews(); }
            catch (Exception ex) { notice.Text = Server.HtmlEncode(ex.Message); }
        }
    }
}

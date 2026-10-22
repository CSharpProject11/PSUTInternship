using PSUTInternship.Shared;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Net.Mail;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PSUTInternship.Company
{
    public partial class ReportsAndEvaluation : PSUTInternship.Shared.PortalPage
    {
        private static readonly string DatabaseUrl = PSUTInternship.Shared.FirebaseConfig.DatabaseUrl.TrimEnd('/') + "/";

        protected async void Page_Load(object sender, EventArgs e)
        {
            try { if (!IsPostBack)
            {
                await LoadDashboard();

                string evaluationId = Request.QueryString["evaluation"];
                if (!string.IsNullOrWhiteSpace(evaluationId))
                    await OpenEvaluation(evaluationId);

                string reportId = Request.QueryString["report"];
                if (!string.IsNullOrWhiteSpace(reportId))
                    await OpenReport(reportId);
            } } catch (Exception ex) { ShowMessage(ex.Message); }
        }

        private async System.Threading.Tasks.Task LoadDashboard()
        {
            using (HttpClient client = PSUTInternship.Shared.FirebaseConfig.CreateClient())
            {
                Dictionary<string, JObject> reports = await ReadCollection(client, "reports.json");
                Dictionary<string, JObject> evaluations = (await ReadCollection(client, "evaluations.json")).Where(x => (string)x.Value["evaluatorRole"] == "companySupervisor").ToDictionary(x => x.Key, x => x.Value);

                Opportunity.Items.Clear(); Opportunity.Items.Add(new ListItem("Select opportunity", ""));
                var placements = await PortalRepository.Collection("internships");
                foreach (var group in placements.Values.Where(x => (string)x["companyId"] == PortalRepository.CompanyId ).Where(x => !string.IsNullOrWhiteSpace((string)x["opportunityId"])).GroupBy(x => (string)x["opportunityId"]))
                    Opportunity.Items.Add(new ListItem(((string)group.First()["opportunityTitle"] ?? group.Key) + " (" + group.Key + ")", group.Key));
                EvaluationStudent.Items.Clear(); EvaluationStudent.Items.Add(new ListItem("Select opportunity first", ""));
                RenderEvaluations(evaluations);
                RenderReports(reports);

                ReportsSubmittedCount.Text = reports.Values.Count(x => x != null).ToString();
                AwaitingReviewCount.Text = reports.Values.Count(x => x != null && IsAwaitingReview(Read(x, "Status", "status", "state"))).ToString();
                DraftedCount.Text = evaluations.Values.Count(x => x != null && IsDraft(Read(x, "Status", "status"))).ToString();
                SentCount.Text = evaluations.Values.Count(x => x != null && IsSent(Read(x, "Status", "status"))).ToString();
            }
        }

        private async System.Threading.Tasks.Task<Dictionary<string, JObject>> ReadCollection(HttpClient client, string path)
        {
            return await PortalRepository.Collection(path.Replace(".json", ""));
        }

        private void LoadStudents(Dictionary<string, JObject> users)
        {
            string selected = EvaluationStudent.SelectedValue;
            EvaluationStudent.Items.Clear();
            foreach (KeyValuePair<string, JObject> item in users)
            {
                if (item.Value == null) continue;
                string name = Read(item.Value, "fullName", "Name", "name");
                if (string.IsNullOrWhiteSpace(name)) continue;
                EvaluationStudent.Items.Add(new ListItem(name, item.Key));
            }
            if (EvaluationStudent.Items.FindByValue(selected) != null)
                EvaluationStudent.SelectedValue = selected;
            if (EvaluationStudent.Items.Count == 0)
                EvaluationStudent.Items.Add(new ListItem("No students found", ""));
        }

        private void RenderEvaluations(Dictionary<string, JObject> evaluations)
        {
            EvaluationRows.Controls.Clear();
            if (evaluations.Count == 0)
            {
                AddEmptyRow(EvaluationRows, 5, "No company evaluations have been created yet.");
                return;
            }

            foreach (KeyValuePair<string, JObject> item in evaluations.OrderByDescending(x => Read(x.Value, "SentAtUtc", "DraftedAtUtc", "UpdatedAtUtc")))
            {
                if (item.Value == null) continue;
                string student = Read(item.Value, "studentName", "StudentName", "studentId", "Student", "student");
                string period = Read(item.Value, "EvaluationPeriod", "Period", "period");
                string supervisor = Read(item.Value, "AcademicSupervisor", "AcademicSupervisorName", "academicSupervisor", "AcademicSupervisorEmail");
                string status = Read(item.Value, "Status", "status");

                HtmlTableRow row = new HtmlTableRow();
                row.Cells.Add(MakeCell(student));
                row.Cells.Add(MakeCell(period));
                row.Cells.Add(MakeCell(supervisor));
                row.Cells.Add(MakeStatusCell(status));

                HtmlTableCell action = new HtmlTableCell();
                HtmlAnchor open = new HtmlAnchor
                {
                    HRef = "reportsAndEvaluation.aspx?evaluation=" + HttpUtility.UrlEncode(item.Key),
                    InnerText = IsDraft(status) ? "Edit" : "View"
                };
                open.Attributes["class"] = "button small-button";
                action.Controls.Add(open);
                row.Cells.Add(action);
                EvaluationRows.Controls.Add(row);
            }
        }

        private void RenderReports(Dictionary<string, JObject> reports)
        {
            ReportRows.Controls.Clear();
            if (reports.Count == 0)
            {
                AddEmptyRow(ReportRows, 5, "No submitted internship reports were found.");
                return;
            }

            foreach (KeyValuePair<string, JObject> item in reports.OrderByDescending(x => Read(x.Value, "SubmittedAt", "submittedAt", "CreatedAt", "Date")))
            {
                if (item.Value == null) continue;
                HtmlTableRow row = new HtmlTableRow();
                row.Cells.Add(MakeCell(GetStudentName(item.Value)));
                row.Cells.Add(MakeCell(Read(item.Value, "Title", "title", "ReportName", "name")));
                row.Cells.Add(MakeCell(FormatDate(Read(item.Value, "SubmittedAt", "submittedAt", "CreatedAt", "Date"))));
                row.Cells.Add(MakeStatusCell(Read(item.Value, "Status", "status", "state")));

                HtmlTableCell action = new HtmlTableCell();
                HtmlAnchor open = new HtmlAnchor
                {
                    HRef = "reportsAndEvaluation.aspx?report=" + HttpUtility.UrlEncode(item.Key),
                    InnerText = "Review"
                };
                open.Attributes["class"] = "button small-button";
                action.Controls.Add(open);
                row.Cells.Add(action);
                ReportRows.Controls.Add(row);
            }
        }

        protected async void NewEvaluation_Click(object sender, EventArgs e)
        {
            try {
            await LoadDashboard(); SaveDraft.Enabled = SendEvaluation.Enabled = true;
            OpportunityError.Text = StudentError.Text = PeriodError.Text = SupervisorError.Text = EmailError.Text = FeedbackError.Text = CriteriaError.Text = "";
            string opportunityId = Request.QueryString["opportunityId"];
            if (Opportunity.Items.FindByValue(opportunityId ?? "") != null) { Opportunity.SelectedValue = opportunityId ?? ""; await LoadOpportunityStudents(); }
            EvaluationId.Value = "";
            EvaluationModal.Visible = true; DashboardContent.Visible = false;
            OverallFeedback.Text = "";
            EvaluationPeriod.Text = "";
            AcademicSupervisor.Text = "";
            AcademicSupervisorEmail.Text = "";
            SelectedStudentName.Text = EvaluationStudent.SelectedItem == null ? "" : HttpUtility.HtmlEncode(EvaluationStudent.SelectedItem.Text);
            RegisterClientScript("newCriteria", "document.getElementById('criteriaList').innerHTML='';addCriterion('','');");
            } catch (Exception ex) { ShowMessage(ex.Message); }
        }

        protected void CloseEvaluation_Click(object sender, EventArgs e)
        {
            EvaluationModal.Visible = false; DashboardContent.Visible = true;
        }

        private async System.Threading.Tasks.Task LoadOpportunityStudents() {
            var placements = await PortalRepository.Collection("internships");
            var ids = new HashSet<string>(placements.Values.Where(x => (string)x["companyId"] == PortalRepository.CompanyId && (string)x["status"] == "active" && (string)x["opportunityId"] == Opportunity.SelectedValue).Select(x => (string)x["studentId"]));
            LoadStudents((await PortalRepository.Collection("students")).Where(x => ids.Contains(x.Key)).ToDictionary(x => x.Key, x => x.Value));
            EvaluationStudent.Items.Insert(0, new ListItem("Select trainee", "")); EvaluationStudent.SelectedIndex = 0;
        }
        protected async void Opportunity_Changed(object sender, EventArgs e) {
            try { await LoadOpportunityStudents(); } catch (Exception ex) { ShowMessage(ex.Message); }
            RestoreCriteriaEditor(); EvaluationModal.Visible = true; DashboardContent.Visible = false;
        }
        protected async void SaveEvaluation_Click(object sender, EventArgs e) {
            EvaluationModal.Visible = true; DashboardContent.Visible = false;
            OpportunityError.Text = string.IsNullOrEmpty(Opportunity.SelectedValue) ? "Select an opportunity." : "";
            StudentError.Text = string.IsNullOrEmpty(EvaluationStudent.SelectedValue) ? "Select a trainee from this opportunity." : "";
            PeriodError.Text = TaskWorkflow.ValidText(EvaluationPeriod.Text, 3, 100) ? "" : "Enter a period of 3–100 characters.";
            SupervisorError.Text = System.Text.RegularExpressions.Regex.IsMatch(AcademicSupervisor.Text.Trim(), @"\A[\p{L} .'-]{3,150}\z") ? "" : "Enter a supervisor name of 3–150 letters, spaces or name punctuation.";
            EmailError.Text = System.Text.RegularExpressions.Regex.IsMatch(AcademicSupervisorEmail.Text.Trim(), @"\A[^\s@]+@[^\s@]+\.[^\s@]+\z") && IsValidEmail(AcademicSupervisorEmail.Text.Trim()) ? "" : "Enter a valid supervisor email.";
            FeedbackError.Text = TaskWorkflow.ValidText(OverallFeedback.Text, 10, 3000) ? "" : "Enter feedback of 10–3,000 characters.";
            string[] names = Request.Form.GetValues("CriterionName") ?? new string[0];
            string[] percentages = Request.Form.GetValues("CriterionPercentage") ?? new string[0];
            JArray criteria = new JArray(); decimal total = 0; CriteriaError.Text = "";
            if (names.Length == 0 || names.Length > 50 || names.Length != percentages.Length) CriteriaError.Text = "Add 1–50 complete criteria.";
            else for (int i = 0; i < names.Length; i++) {
                decimal percent;
                if (!TaskWorkflow.ValidText(names[i], 3, 150) || !PercentageRules.TryParse(percentages[i], out percent)) {
                    CriteriaError.Text = "Each criterion needs a name of 3–150 characters and a percentage from 0–100 with at most two decimals."; break;
                }
                total += percent; criteria.Add(new JObject { ["Name"] = names[i].Trim(), ["percentage"] = percent });
            }
            if (total > 100) CriteriaError.Text = "The total percentage cannot exceed 100%.";
            if (new[] { OpportunityError, StudentError, PeriodError, SupervisorError, EmailError, FeedbackError, CriteriaError }.Any(x => x.Text.Length > 0)) { RestoreCriteriaEditor(); return; }
            try {
                string studentId = EvaluationStudent.SelectedValue;
                var placement = await PortalRepository.PlacementForStudent(studentId);
                if (placement == null || (string)placement["companyId"] != PortalRepository.CompanyId || (string)placement["status"] != "active" || (string)placement["opportunityId"] != Opportunity.SelectedValue)
                    throw new InvalidOperationException("Select a confirmed trainee from this opportunity.");
                var existing = await PortalRepository.EvaluationForPlacement(studentId, DatabaseSchema.Id(placement), "companySupervisor");
                if (string.Equals((string)existing?["status"], "submitted", StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("This final evaluation has already been sent.");
                string id = existing == null ? "company_" + DatabaseSchema.Id(placement) : DatabaseSchema.Id(existing);
                bool send = IsSent(((Button)sender).CommandArgument);
                var evaluation = new JObject {
                    ["studentId"] = studentId, ["studentName"] = EvaluationStudent.SelectedItem.Text,
                    ["companyId"] = PortalRepository.CompanyId, ["academicSupervisorId"] = (string)placement["academicSupervisorId"],
                    ["internshipId"] = DatabaseSchema.Id(placement), ["opportunityId"] = Opportunity.SelectedValue,
                    ["evaluationType"] = "final", ["evaluatorId"] = PortalRepository.UserId, ["evaluatorRole"] = "companySupervisor",
                    ["Status"] = send ? "submitted" : "draft", ["status"] = send ? "submitted" : "draft", ["TotalScore"] = total, ["TotalMaximum"] = 100, ["overallScore"] = total, ["totalMaximum"] = 100, ["totalPercentage"] = total,
                    ["comments"] = OverallFeedback.Text.Trim(), ["OverallFeedback"] = OverallFeedback.Text.Trim(),
                    ["EvaluationPeriod"] = EvaluationPeriod.Text.Trim(), ["AcademicSupervisor"] = AcademicSupervisor.Text.Trim(),
                    ["AcademicSupervisorEmail"] = AcademicSupervisorEmail.Text.Trim(), ["Criteria"] = criteria,
                    ["UpdatedAtUtc"] = DateTime.UtcNow.ToString("o"), ["updatedAt"] = DateTime.UtcNow.ToString("o"), ["submittedAt"] = send ? (JToken)DateTime.UtcNow.ToString("o") : null
                };
                await PortalRepository.Patch("evaluations/" + PortalRepository.Key(id), evaluation);
                EvaluationModal.Visible = false; DashboardContent.Visible = true;
                await LoadDashboard(); ShowMessage(send ? "Evaluation saved and sent to the academic supervisor." : "Evaluation draft saved.");
            } catch (Exception ex) { ShowMessage(ex.Message); RestoreCriteriaEditor(); }
        }

        private async System.Threading.Tasks.Task OpenEvaluation(string id)
        {
            using (HttpClient client = PSUTInternship.Shared.FirebaseConfig.CreateClient())
            {
                string json = await client.GetStringAsync(DatabaseUrl + "evaluations/" + HttpUtility.UrlEncode(id) + ".json");
                if (json == "null")
                {
                    ShowMessage("Evaluation was not found.");
                    return;
                }

                JObject evaluation = JObject.Parse(json);
                var placement = await PortalRepository.PlacementForRecord(evaluation);
                if ((string)placement["companyId"] != PortalRepository.CompanyId || (string)evaluation["evaluatorRole"] != "companySupervisor") throw new System.Web.HttpException(403, "Evaluation access denied.");
                EvaluationId.Value = id;
                EvaluationPeriod.Text = Read(evaluation, "EvaluationPeriod", "Period", "period");
                AcademicSupervisor.Text = Read(evaluation, "AcademicSupervisor", "AcademicSupervisorName");
                AcademicSupervisorEmail.Text = Read(evaluation, "AcademicSupervisorEmail");
                OverallFeedback.Text = Read(evaluation, "OverallFeedback", "Comments", "comments");

                Opportunity.SelectedValue = (string)placement["opportunityId"] ?? "";
                await LoadOpportunityStudents();
                string studentId = Read(evaluation, "studentId", "StudentId");
                if (EvaluationStudent.Items.FindByValue(studentId) != null)
                    EvaluationStudent.SelectedValue = studentId;
                else { EvaluationStudent.Items.Add(new ListItem(Read(evaluation,"studentName","StudentName","studentId"),studentId)); EvaluationStudent.SelectedValue=studentId; }
                SaveDraft.Enabled = SendEvaluation.Enabled = !IsSent(Read(evaluation,"status","Status")) && (string)placement["status"] == "active";
                SelectedStudentName.Text = EvaluationStudent.SelectedItem == null ? "" : HttpUtility.HtmlEncode(EvaluationStudent.SelectedItem.Text);
                EvaluationModal.Visible = true; DashboardContent.Visible = false;

                JArray criteria = evaluation["Criteria"] as JArray;
                if (criteria != null && criteria.Count > 0)
                {
                    StringBuilder script = new StringBuilder("document.getElementById('criteriaList').innerHTML='';");
                    decimal rawTotal = 0, roundedTotal = 0;
                    foreach (JObject item in criteria.OfType<JObject>())
                    {
                        string name = HttpUtility.JavaScriptStringEncode(Read(item, "Name", "name"));
                        decimal legacyTotal = (decimal?)evaluation["totalMaximum"] ?? (decimal?)evaluation["TotalMaximum"] ?? 100;
                        decimal percentage = (decimal?)item["percentage"] ?? (legacyTotal > 0 ? ((decimal?)item["Score"] ?? (decimal?)item["score"] ?? 0) / legacyTotal * 100 : 0);
                        percentage = PercentageRules.RoundedContribution(percentage, ref rawTotal, ref roundedTotal);
                        string score = percentage.ToString("0.##", CultureInfo.InvariantCulture);
                        script.Append("addCriterion('").Append(name).Append("','").Append(score).Append("');");
                    }
                    RegisterClientScript("loadCriteria", script.ToString());
                }
                else
                {
                    RegisterClientScript("emptyCriteria", "document.getElementById('criteriaList').innerHTML='';addCriterion('','','');");
                }
            }
        }

        private async System.Threading.Tasks.Task OpenReport(string id)
        {
            using (HttpClient client = PSUTInternship.Shared.FirebaseConfig.CreateClient())
            {
                string json = await client.GetStringAsync(DatabaseUrl + "reports/" + HttpUtility.UrlEncode(id) + ".json");
                if (json == "null")
                {
                    ShowMessage("Report was not found.");
                    return;
                }
                JObject report = JObject.Parse(json);
                if ((string)report["companyId"] != PSUTInternship.Shared.PortalRepository.CompanyId) throw new System.Web.HttpException(403, "Report access denied.");
                ReportId.Value = id;
                ReportScore.Text = Read(report, "Score", "score");
                ReportFeedback.Text = Read(report, "Feedback", "feedback");
                string submissionUrl = GetSubmissionUrl(report);
                ReportSubmissionLink.Visible = IsWebUrl(submissionUrl);
                if (ReportSubmissionLink.Visible) ReportSubmissionLink.NavigateUrl = submissionUrl;
                ReportReview.Visible = true;
            }
        }

        protected async void SaveReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(ReportId.Value) || string.IsNullOrWhiteSpace(ReportScore.Text.Trim()))
            {
                ShowMessage("Select a report and enter its score using the university criteria.");
                return;
            }

            var existingReport = await PSUTInternship.Shared.PortalRepository.Get<JObject>("reports/" + PSUTInternship.Shared.PortalRepository.Key(ReportId.Value));
            if ((string)existingReport?["companyId"] != PSUTInternship.Shared.PortalRepository.CompanyId) throw new System.Web.HttpException(403, "Report access denied.");
            JObject update = new JObject();
            update["Score"] = ReportScore.Text.Trim();
            update["Feedback"] = ReportFeedback.Text.Trim();
            update["Status"] = "Reviewed";
            using (HttpClient client = PSUTInternship.Shared.FirebaseConfig.CreateClient())
            using (StringContent content = new StringContent(update.ToString(Formatting.None), Encoding.UTF8, "application/json"))
            {
                HttpRequestMessage request = new HttpRequestMessage(new HttpMethod("PATCH"), DatabaseUrl + "reports/" + HttpUtility.UrlEncode(ReportId.Value) + ".json");
                request.Content = content;
                HttpResponseMessage response = await client.SendAsync(request);
                if (!response.IsSuccessStatusCode)
                {
                    ShowMessage("Could not save the report evaluation. Please try again.");
                    return;
                }
            }
            ShowMessage("Report evaluation saved.");
            await LoadDashboard();
            await OpenReport(ReportId.Value);
        }

        private static bool IsDraft(string status)
        {
            return status.Equals("draft", StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsSent(string status)
        {
            return status.Equals("sent to academic supervisor", StringComparison.OrdinalIgnoreCase) ||
                status.Equals("submitted", StringComparison.OrdinalIgnoreCase) ||
                status.Equals("sent", StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsAwaitingReview(string status)
        {
            return status.Equals("pending", StringComparison.OrdinalIgnoreCase) ||
                status.Equals("pending review", StringComparison.OrdinalIgnoreCase) ||
                status.Equals("submitted", StringComparison.OrdinalIgnoreCase);
        }

        private static string GetStudentName(JObject item)
        {
            return Read(item, "StudentName", "Student", "student", "studentName");
        }

        private static string FormatDate(string value)
        {
            DateTime date;
            if (DateTime.TryParse(value, out date)) return date.ToString("dd MMM yyyy", CultureInfo.InvariantCulture);
            return value;
        }

        private static string GetSubmissionUrl(JObject report)
        {
            JToken submission = report["Submission"] ?? report["submission"] ?? report["url"] ?? report["link"];
            if (submission == null || submission.Type == JTokenType.Null) return "";
            if (submission.Type == JTokenType.Object)
                return Read((JObject)submission, "url", "downloadUrl", "fileUrl");
            return submission.ToString();
        }

        private static bool IsWebUrl(string value)
        {
            Uri uri;
            return Uri.TryCreate(value, UriKind.Absolute, out uri) &&
                (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps);
        }

        private static string Read(JObject item, params string[] names)
        {
            if (item == null) return "";
            foreach (string name in names)
                if (item[name] != null && item[name].Type != JTokenType.Null) return item[name].ToString();
            return "";
        }

        private static HtmlTableCell MakeCell(string text)
        {
            return new HtmlTableCell { InnerText = text ?? "" };
        }

        private static HtmlTableCell MakeStatusCell(string text)
        {
            HtmlTableCell cell = new HtmlTableCell();
            HtmlGenericControl badge = new HtmlGenericControl("span");
            badge.Attributes["class"] = "status";
            if (IsAwaitingReview(text)) badge.Attributes["class"] += " status-pending";
            else if (IsSent(text)) badge.Attributes["class"] += " status-sent";
            else if (text.Equals("reviewed", StringComparison.OrdinalIgnoreCase)) badge.Attributes["class"] += " status-reviewed";
            badge.InnerText = string.IsNullOrWhiteSpace(text) ? "Draft" : text;
            cell.Controls.Add(badge);
            return cell;
        }

        private static void AddEmptyRow(HtmlGenericControl tbody, int columns, string message)
        {
            HtmlTableRow row = new HtmlTableRow();
            HtmlTableCell cell = new HtmlTableCell { ColSpan = columns, InnerText = message };
            cell.Attributes["class"] = "empty";
            row.Cells.Add(cell);
            tbody.Controls.Add(row);
        }

        private void RegisterClientScript(string key, string script)
        {
            ClientScript.RegisterStartupScript(GetType(), key, script, true);
        }

        private void RestoreCriteriaEditor()
        {
            string[] names = Request.Form.GetValues("CriterionName") ?? new string[0];
            string[] scores = Request.Form.GetValues("CriterionPercentage") ?? new string[0];
            int count = Math.Min(names.Length, scores.Length);
            StringBuilder script = new StringBuilder("document.getElementById('criteriaList').innerHTML='';");
            for (int i = 0; i < count; i++) script.Append("addCriterion('").Append(HttpUtility.JavaScriptStringEncode(names[i] ?? ""))
                .Append("','").Append(HttpUtility.JavaScriptStringEncode(scores[i] ?? "")).Append("');");
            if (count == 0) script.Append("addCriterion('','');");
            script.Append("document.querySelectorAll('#criteriaList .criterion').forEach(function(row){row.validateTitle();});");
            RegisterClientScript("restoreCriteria", script.ToString());
        }

        private static bool IsValidEmail(string value)
        {
            try { return new MailAddress(value).Address == value; }
            catch (FormatException) { return false; }
        }

        private void ShowMessage(string text)
        {
            PageMessage.Text = HttpUtility.HtmlEncode(text);
        }
    }
}

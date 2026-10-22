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
            if (!IsPostBack)
            {
                await LoadDashboard();

                string evaluationId = Request.QueryString["evaluation"];
                if (!string.IsNullOrWhiteSpace(evaluationId))
                    await OpenEvaluation(evaluationId);

                string reportId = Request.QueryString["report"];
                if (!string.IsNullOrWhiteSpace(reportId))
                    await OpenReport(reportId);
            }
        }

        private async System.Threading.Tasks.Task LoadDashboard()
        {
            using (HttpClient client = PSUTInternship.Shared.FirebaseConfig.CreateClient())
            {
                Dictionary<string, JObject> reports = await ReadCollection(client, "reports.json");
                Dictionary<string, JObject> evaluations = (await ReadCollection(client, "evaluations.json")).Where(x => (string)x.Value["evaluatorRole"] == "companySupervisor").ToDictionary(x => x.Key, x => x.Value);
                Dictionary<string, JObject> users = await ReadCollection(client, "students.json");

                LoadStudents(users);
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

        protected void NewEvaluation_Click(object sender, EventArgs e)
        {
            EvaluationId.Value = "";
            EvaluationModal.Visible = true;
            OverallFeedback.Text = "";
            EvaluationPeriod.Text = "";
            AcademicSupervisor.Text = "";
            AcademicSupervisorEmail.Text = "";
            SelectedStudentName.Text = EvaluationStudent.SelectedItem == null ? "" : HttpUtility.HtmlEncode(EvaluationStudent.SelectedItem.Text);
            RegisterClientScript("newCriteria", "document.getElementById('criteriaList').innerHTML='';addCriterion('','','');");
        }

        protected void CloseEvaluation_Click(object sender, EventArgs e)
        {
            EvaluationModal.Visible = false;
        }

        protected async void SaveEvaluation_Click(object sender, EventArgs e)
        {
            Button button = sender as Button;
            string status = button == null ? "Draft" : button.CommandArgument;
            if (string.IsNullOrWhiteSpace(EvaluationStudent.SelectedValue) ||
                string.IsNullOrWhiteSpace(EvaluationPeriod.Text.Trim()) ||
                string.IsNullOrWhiteSpace(AcademicSupervisor.Text.Trim()) ||
                !IsValidEmail(AcademicSupervisorEmail.Text.Trim()))
            {
                ShowMessage("Choose a student, enter the evaluation period and supervisor name, and provide a valid supervisor email.");
                EvaluationModal.Visible = true;
                RestoreCriteriaEditor();
                return;
            }

            string[] names = Request.Form.GetValues("CriterionName") ?? new string[0];
            string[] scores = Request.Form.GetValues("CriterionScore") ?? new string[0];
            string[] maximums = Request.Form.GetValues("CriterionMax") ?? new string[0];
            if (names.Length == 0 || names.Length != scores.Length || names.Length != maximums.Length)
            {
                ShowMessage("Add at least one complete evaluation criterion.");
                EvaluationModal.Visible = true;
                RestoreCriteriaEditor();
                return;
            }

            JArray criteria = new JArray();
            decimal totalScore = 0;
            decimal totalMaximum = 0;
            for (int i = 0; i < names.Length; i++)
            {
                decimal score;
                decimal maximum;
                if (string.IsNullOrWhiteSpace(names[i]) ||
                    !decimal.TryParse(scores[i], NumberStyles.Number, CultureInfo.InvariantCulture, out score) ||
                    !decimal.TryParse(maximums[i], NumberStyles.Number, CultureInfo.InvariantCulture, out maximum) ||
                    maximum <= 0 || score < 0 || score > maximum)
                {
                    ShowMessage("Each criterion needs a name, a valid score, and a maximum greater than zero. Scores must be within their maximum.");
                    EvaluationModal.Visible = true;
                    RestoreCriteriaEditor();
                    return;
                }

                JObject criterion = new JObject();
                criterion["Name"] = names[i].Trim();
                criterion["Score"] = score;
                criterion["MaxPoints"] = maximum;
                criteria.Add(criterion);
                totalScore += score;
                totalMaximum += maximum;
            }

            string studentId = EvaluationStudent.SelectedValue;
            string studentName = EvaluationStudent.SelectedItem.Text;
            var placement = await PortalRepository.PlacementForStudent(studentId);
            if (placement == null || (string)placement["companyId"] != PSUTInternship.Shared.PortalRepository.CompanyId)
            { ShowMessage("Select one of your confirmed trainees."); return; }
            JObject evaluation = new JObject();
            evaluation["studentId"] = studentId;
            evaluation["companyId"] = PSUTInternship.Shared.PortalRepository.CompanyId;
            evaluation["academicSupervisorId"] = (string)placement["academicSupervisorId"];
            evaluation["internshipId"] = DatabaseSchema.Id(placement);
            evaluation["evaluationType"] = "final";
            evaluation["evaluatorId"] = PSUTInternship.Shared.PortalRepository.UserId;
            evaluation["evaluatorRole"] = "companySupervisor";
            evaluation["status"] = IsSent(status) ? "submitted" : "draft";
            evaluation["overallScore"] = totalScore;
            evaluation["totalMaximum"] = totalMaximum;
            evaluation["comments"] = OverallFeedback.Text.Trim();
            evaluation["submittedAt"] = DateTime.UtcNow.ToString("o");
            var savedEvaluation = await PortalRepository.EvaluationForPlacement(studentId, DatabaseSchema.Id(placement), "companySupervisor");
            if (string.Equals((string)savedEvaluation?["status"], "submitted", StringComparison.OrdinalIgnoreCase)) { ShowMessage("This final evaluation has already been submitted."); return; }
            EvaluationId.Value = savedEvaluation == null ? "company_" + DatabaseSchema.Id(placement) : DatabaseSchema.Id(savedEvaluation);
            evaluation["StudentId"] = studentId;
            evaluation["StudentName"] = studentName;
            evaluation["EvaluationPeriod"] = EvaluationPeriod.Text.Trim();
            evaluation["AcademicSupervisor"] = AcademicSupervisor.Text.Trim();
            evaluation["AcademicSupervisorEmail"] = AcademicSupervisorEmail.Text.Trim();
            evaluation["Criteria"] = criteria;
            evaluation["TotalScore"] = totalScore;
            evaluation["TotalMaximum"] = totalMaximum;
            evaluation["OverallFeedback"] = OverallFeedback.Text.Trim();
            evaluation["Status"] = status;
            evaluation["UpdatedAtUtc"] = DateTime.UtcNow.ToString("o");
            if (IsSent(status)) evaluation["SentAtUtc"] = DateTime.UtcNow.ToString("o");
            else evaluation["DraftedAtUtc"] = DateTime.UtcNow.ToString("o");

            using (HttpClient client = PSUTInternship.Shared.FirebaseConfig.CreateClient())
            using (StringContent content = new StringContent(evaluation.ToString(Formatting.None), Encoding.UTF8, "application/json"))
            {
                HttpResponseMessage response;
                string url = DatabaseUrl + "evaluations";
                if (string.IsNullOrWhiteSpace(EvaluationId.Value))
                {
                    response = await client.PostAsync(url + ".json", content);
                }
                else
                {
                    HttpRequestMessage request = new HttpRequestMessage(new HttpMethod("PATCH"), url + "/" + HttpUtility.UrlEncode(EvaluationId.Value) + ".json");
                    request.Content = content;
                    response = await client.SendAsync(request);
                }

                if (!response.IsSuccessStatusCode)
                {
                    ShowMessage("Could not save the evaluation to Firebase. Please try again.");
                    EvaluationModal.Visible = true;
                    RestoreCriteriaEditor();
                    return;
                }
            }

            EvaluationModal.Visible = false;
            ShowMessage(IsSent(status) ? "Evaluation saved and sent to the academic supervisor." : "Evaluation draft saved to Firebase.");
            await LoadDashboard();
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

                string studentId = Read(evaluation, "studentId", "StudentId");
                if (EvaluationStudent.Items.FindByValue(studentId) != null)
                    EvaluationStudent.SelectedValue = studentId;
                else
                {
                    string studentName = Read(evaluation, "StudentName", "Student", "student");
                    ListItem student = EvaluationStudent.Items.FindByText(studentName);
                    if (student != null) EvaluationStudent.SelectedValue = student.Value;
                }
                SelectedStudentName.Text = EvaluationStudent.SelectedItem == null ? "" : HttpUtility.HtmlEncode(EvaluationStudent.SelectedItem.Text);
                EvaluationModal.Visible = true;

                JArray criteria = evaluation["Criteria"] as JArray;
                if (criteria != null && criteria.Count > 0)
                {
                    StringBuilder script = new StringBuilder("document.getElementById('criteriaList').innerHTML='';");
                    foreach (JObject item in criteria.OfType<JObject>())
                    {
                        string name = HttpUtility.JavaScriptStringEncode(Read(item, "Name", "name"));
                        string score = HttpUtility.JavaScriptStringEncode(Read(item, "Score", "score"));
                        string maximum = HttpUtility.JavaScriptStringEncode(Read(item, "MaxPoints", "maxPoints"));
                        script.Append("addCriterion('").Append(name).Append("','").Append(score).Append("','").Append(maximum).Append("');");
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
            string[] scores = Request.Form.GetValues("CriterionScore") ?? new string[0];
            string[] maximums = Request.Form.GetValues("CriterionMax") ?? new string[0];
            int count = Math.Min(names.Length, Math.Min(scores.Length, maximums.Length));
            if (count == 0) return;

            StringBuilder script = new StringBuilder("document.getElementById('criteriaList').innerHTML='';");
            for (int i = 0; i < count; i++)
            {
                script.Append("addCriterion('").Append(HttpUtility.JavaScriptStringEncode(names[i] ?? ""))
                    .Append("','").Append(HttpUtility.JavaScriptStringEncode(scores[i] ?? ""))
                    .Append("','").Append(HttpUtility.JavaScriptStringEncode(maximums[i] ?? "")).Append("');");
            }
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

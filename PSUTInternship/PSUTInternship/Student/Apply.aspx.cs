using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;
using PSUTInternship.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Globalization;
using System.Text;
using System.Net;
using System.Net.Mail;

namespace PSUTInternship.Student
{
    public partial class Apply : System.Web.UI.Page
    {
        private const string FirebaseUrl =
            "https://csharp-e078c-default-rtdb.firebaseio.com/";

        private static readonly HttpClient Client =
            new HttpClient();

        protected override void OnInit(EventArgs e)
        {
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["idToken"] == null)
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            if (!IsPostBack)
            {
                RegisterAsyncTask(
                    new PageAsyncTask(LoadOpportunity));
                RegisterAsyncTask(new PageAsyncTask(LoadStudentInformation));
            }
        }

        protected void SubmitApplication_Click(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["idToken"] == null) return;
            RegisterAsyncTask(new PageAsyncTask(SubmitApplication));
        }

        private string Field(string name)
        {
            return (Request.Form[name] ?? "").Trim();
        }

        private async Task LoadStudentInformation()
        {
            var values = new Dictionary<string, string>
            {
                { "studentEmail", Convert.ToString(Session["userEmail"]) },
                { "applicationDate", TimeZoneInfo.ConvertTimeBySystemTimeZoneId(DateTime.UtcNow, "Jordan Standard Time").ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) }
            };
            try
            {
                string profileId = Convert.ToString(Session["profileId"]);
                if (string.IsNullOrWhiteSpace(profileId)) profileId = Convert.ToString(Session["userId"]);
                string url = FirebaseConfig.DatabaseUrl.TrimEnd('/') + "/students/"
                    + Uri.EscapeDataString(profileId) + ".json?auth="
                    + Uri.EscapeDataString(Convert.ToString(Session["idToken"]));
                var profile = JsonConvert.DeserializeObject<JObject>(await Client.GetStringAsync(url));
                if (profile != null)
                {
                    var fields = new Dictionary<string, string[]>
                    {
                        { "studentName", new[] { "fullName", "studentName" } },
                        { "universityId", new[] { "studentNumber", "universityId", "studentId" } },
                        { "studentEmail", new[] { "email" } },
                        { "studentPhone", new[] { "phone", "phoneNumber" } },
                        { "alternativePhone", new[] { "alternativePhone" } },
                        { "faculty", new[] { "college", "faculty" } },
                        { "department", new[] { "department" } },
                        { "program", new[] { "program", "major" } },
                        { "semester", new[] { "semester" } },
                        { "academicYear", new[] { "academicYear" } },
                        { "completedCreditHours", new[] { "completedCreditHours" } }
                    };
                    foreach (var field in fields)
                        foreach (string alias in field.Value)
                        {
                            JToken value = profile.GetValue(alias, StringComparison.OrdinalIgnoreCase);
                            if (!(value is JValue) || value.Type == JTokenType.Null || string.IsNullOrWhiteSpace(value.ToString())) continue;
                            values[field.Key] = value.ToString();
                            break;
                        }
                }
            }
            catch (Exception ex) when (ex is HttpRequestException || ex is JsonException || ex is TaskCanceledException)
            {
                MessageLabel.Text = "Your saved student information could not be loaded. Enter it in the application form or sign in again.";
            }
            string defaults = JsonConvert.SerializeObject(values, new JsonSerializerSettings { StringEscapeHandling = StringEscapeHandling.EscapeHtml });
            ClientScript.RegisterStartupScript(GetType(), "studentInformation", "document.addEventListener('DOMContentLoaded', function () { var values = " + defaults
                + "; Object.keys(values).forEach(function (key) { var field = document.getElementById(key); if (field && !field.value) field.value = values[key]; }); });", true);
        }

        private async Task SubmitApplication()
        {
            await LoadOpportunity();
            try
            {
                string id = Request.QueryString["id"];
                string uid = Convert.ToString(Session["userId"]);
                string token = Convert.ToString(Session["idToken"]);
                if (!DetailsPanel.Visible) throw new ArgumentException("Choose a valid opportunity before applying.");
                if (!string.Equals(Convert.ToString(Session["userRole"]), "student", StringComparison.OrdinalIgnoreCase))
                    throw new ArgumentException("Only student accounts can submit applications.");

                string[] required = { "faculty", "department", "program", "semester", "academicYear",
                    "applicationDate", "studentName", "universityId", "completedCreditHours", "studentPhone",
                    "studentEmail", "organizationName", "organizationPhone", "mailingAddress", "organizationEmail",
                    "trainingAddress", "trainingStartDate", "trainingEndDate", "trainingField", "applicationReason" };
                foreach (string name in required)
                    if (string.IsNullOrWhiteSpace(Field(name)) || Field(name).Length > 10000)
                        throw new ArgumentException("Complete all required fields. Each response must be under 10,000 characters.");

                DateTime applicationDate, start, end;
                if (!DateTime.TryParseExact(Field("applicationDate"), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out applicationDate)
                    || !DateTime.TryParseExact(Field("trainingStartDate"), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out start)
                    || !DateTime.TryParseExact(Field("trainingEndDate"), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out end)
                    || end < start)
                    throw new ArgumentException("Enter valid dates. Training end date must be on or after its start date.");
                int credits;
                if (!int.TryParse(Field("completedCreditHours"), out credits) || credits < 0)
                    throw new ArgumentException("Completed credit hours must be a non-negative whole number.");
                foreach (string name in new[] { "studentEmail", "organizationEmail" })
                {
                    MailAddress email;
                    try { email = new MailAddress(Field(name)); }
                    catch (FormatException) { throw new ArgumentException("Enter valid student and organization email addresses."); }
                    if (email.Address != Field(name)) throw new ArgumentException("Enter valid email addresses without display names.");
                }
                Uri website;
                if (Field("organizationWebsite") != "" && (!Uri.TryCreate(Field("organizationWebsite"), UriKind.Absolute, out website)
                    || (website.Scheme != "https" && website.Scheme != "http")))
                    throw new ArgumentException("Enter a valid website URL starting with https:// or http://.");

                string auth = "?auth=" + Uri.EscapeDataString(token);
                using (var response = await Client.GetAsync(FirebaseUrl + "opportunities/" + Uri.EscapeDataString(id) + ".json" + auth))
                {
                    response.EnsureSuccessStatusCode();
                    var opportunity = JsonConvert.DeserializeObject<Opportunity>(await response.Content.ReadAsStringAsync());
                    if (opportunity == null || !opportunity.Status || (opportunity.DeadLine != DateTime.MinValue && opportunity.DeadLine.Date < DateTime.UtcNow.Date))
                        throw new ArgumentException("This opportunity is closed or its application deadline has passed.");
                }

                var application = new PSUTInternship.Models.Application
                {
                    Id = id, StudentId = uid, OpportunityId = id, Reason = Field("applicationReason"),
                    Details = new TrainingApplicationDetails
                    {
                        Faculty = Field("faculty"), Department = Field("department"), Program = Field("program"),
                        Semester = Field("semester"), AcademicYear = Field("academicYear"), ApplicationDate = applicationDate,
                        StudentName = Field("studentName"), UniversityId = Field("universityId"), CompletedCreditHours = credits,
                        StudentPhone = Field("studentPhone"), StudentEmail = Field("studentEmail"), AlternativePhone = Field("alternativePhone"),
                        OrganizationName = Field("organizationName"), OrganizationPhone = Field("organizationPhone"),
                        MailingAddress = Field("mailingAddress"), OrganizationEmail = Field("organizationEmail"),
                        OrganizationWebsite = Field("organizationWebsite"), TrainingAddress = Field("trainingAddress"),
                        TrainingStartDate = start, TrainingEndDate = end, TrainingField = Field("trainingField")
                    }
                };
                // One record per student/opportunity; conditional write prevents duplicate submissions and overwriting reviews.
                string url = FirebaseUrl + "applications/" + Uri.EscapeDataString(uid) + "/" + Uri.EscapeDataString(id) + ".json" + auth;
                using (var request = new HttpRequestMessage(HttpMethod.Put, url))
                {
                    request.Headers.TryAddWithoutValidation("if-match", "null_etag");
                    request.Content = new StringContent(JsonConvert.SerializeObject(application), Encoding.UTF8, "application/json");
                    using (var response = await Client.SendAsync(request))
                    {
                        if (response.StatusCode == HttpStatusCode.PreconditionFailed)
                            throw new ArgumentException("You have already applied to this opportunity.");
                        response.EnsureSuccessStatusCode();
                    }
                }
                MessageLabel.CssClass = "alert alert-success d-block";
                MessageLabel.Text = "Application submitted successfully. Your status is Pending.";
            }
            catch (ArgumentException ex) { ShowSubmissionError(ex.Message); }
            catch (HttpRequestException) { ShowSubmissionError("Unable to save your application. Your login may have expired or database rules may deny access. Sign in again and retry."); }
            catch (JsonException) { ShowSubmissionError("Unable to read the opportunity. Please try again later."); }
            catch (TaskCanceledException) { ShowSubmissionError("The request timed out. Retry to check whether your application was saved."); }
        }

        private void ShowSubmissionError(string message)
        {
            MessageLabel.CssClass = "alert alert-danger d-block";
            MessageLabel.Text = HttpUtility.HtmlEncode(message);
            var values = Request.Form.AllKeys.Where(k => k != null && !k.StartsWith("__"))
                .ToDictionary(k => k, k => Request.Form[k]);
            string json = JsonConvert.SerializeObject(values, new JsonSerializerSettings { StringEscapeHandling = StringEscapeHandling.EscapeHtml });
            ClientScript.RegisterStartupScript(GetType(), "restoreApplication", "document.addEventListener('DOMContentLoaded', function () { var values = " + json
                + "; Object.keys(values).forEach(function (key) { var field = document.getElementById(key); if (field && /^(INPUT|TEXTAREA)$/.test(field.tagName)) field.value = values[key]; }); new bootstrap.Modal(document.getElementById('applicationModal')).show(); });", true);
        }
        private async Task LoadOpportunity()
        {
            string id = Request.QueryString["id"];

            if (string.IsNullOrWhiteSpace(id) ||
                id.IndexOfAny(
                    new[] { '.', '#', '$', '[', ']', '/', '\\' }) >= 0)
            {
                MessageLabel.Text = "Invalid opportunity.";
                return;
            }

            try
            {
                string url = FirebaseUrl
                    + "opportunities/"
                    + Uri.EscapeDataString(id)
                    + ".json?auth=" + Uri.EscapeDataString(Convert.ToString(Session["idToken"]));

                string json = await Client.GetStringAsync(url);

                Opportunity opportunity =
                    JsonConvert.DeserializeObject<Opportunity>(json);

                if (opportunity == null)
                {
                    MessageLabel.Text = "Opportunity not found.";
                    return;
                }

                opportunity.Id = id;

                OpportunityDetails.DataSource =
                    new[] { opportunity };

                OpportunityDetails.DataBind();
                DetailsPanel.Visible = true;
            }
            catch (HttpRequestException)
            {
                MessageLabel.Text =
                    "Unable to load this opportunity. Please try again.";
            }
            catch (JsonException)
            {
                MessageLabel.Text =
                    "The opportunity details could not be read.";
            }
        }
    }
}

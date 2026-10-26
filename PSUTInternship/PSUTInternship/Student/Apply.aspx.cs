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
    public partial class Apply : PSUTInternship.Shared.PortalPage
    {
        private static readonly string FirebaseUrl =
            PSUTInternship.Shared.FirebaseConfig.DatabaseUrl.TrimEnd('/') + "/";

        private static readonly HttpClient Client =
            PSUTInternship.Shared.FirebaseConfig.CreateClient();

        protected override void OnInit(EventArgs e)
        {
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["idToken"] == null || !string.Equals(Convert.ToString(Session["userRole"]), "student", StringComparison.OrdinalIgnoreCase))
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

        protected string FormatCreatedDate(object value)
        {
            DateTime date;
            return DateTime.TryParse(Convert.ToString(value), out date) ? date.ToString("dd MMM yyyy", CultureInfo.InvariantCulture) : "Not specified";
        }
        protected string ApplicationImage(object value) { Uri image; return Uri.TryCreate(Convert.ToString(value),UriKind.Absolute,out image) && image.Scheme == "https" ? image.AbsoluteUri : ResolveUrl("~/Assets/technology.jpg"); }
        private string Field(string name) {
            string[] aliases = name == "studentName" ? new[] { "fullName" } : name == "studentEmail" ? new[] { "email" } : name == "universityId" ? new[] { "studentNumber", "studentId" } : name == "program" ? new[] { "major", "program" } : name == "faculty" ? new[] { "college", "faculty" } : name == "university" ? new[] { "university" } : null;
            return aliases != null && AuthoritativeProfile != null ? DatabaseSchema.FirstText(AuthoritativeProfile, aliases) : (Request.Form[name] ?? "").Trim();
        }

        protected bool CanApply { get; private set; }
        protected string ApplicationAvailability { get; private set; }
        private JObject AuthoritativeProfile;
        private async Task LoadStudentInformation()
        {
            var values = new Dictionary<string, string>
            {
                { "studentEmail", Convert.ToString(Session["userEmail"]) }
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
                        { "university", new[] { "university" } },
                        { "studentPhone", new[] { "phone", "phoneNumber" } },
                        { "alternativePhone", new[] { "alternativePhone" } },
                        { "faculty", new[] { "college", "faculty" } },
                        { "department", new[] { "department" } },
                        { "program", new[] { "program", "major" } },
                        { "semester", new[] { "academicSemester", "semester" } },
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
                MessageLabel.Text = "Your saved student information could not be loaded. Sign in again or ask the coordinator to complete your profile.";
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
                AuthoritativeProfile = await PortalRepository.Get<JObject>("students/" + PortalRepository.Key(CurrentProfileId));
                if (AuthoritativeProfile == null) throw new ArgumentException("Your student profile could not be loaded.");
                string id = Request.QueryString["id"];
                string uid = Convert.ToString(Session["userId"]);
                string token = Convert.ToString(Session["idToken"]);
                if (!DetailsPanel.Visible) throw new ArgumentException("Choose a valid opportunity before applying.");
                if (!CanApply) throw new ArgumentException(ApplicationAvailability ?? "This opportunity is unavailable.");
                if (!string.Equals(Convert.ToString(Session["userRole"]), "student", StringComparison.OrdinalIgnoreCase))
                    throw new ArgumentException("Only student accounts can submit applications.");

                string[] required = { "faculty", "department", "program", "semester", "academicYear",
                    "studentName", "universityId", "completedCreditHours", "studentPhone",
                    "studentEmail",
                    "applicationReason" };
                foreach (string name in required)
                    if (string.IsNullOrWhiteSpace(Field(name)) || Field(name).Length > 10000)
                        throw new ArgumentException("Complete all required fields. Each response must be under 10,000 characters.");

                DateTime applicationDate = TimeZoneInfo.ConvertTimeBySystemTimeZoneId(DateTime.UtcNow, "Jordan Standard Time").Date;
                int credits;
                if (!int.TryParse(Field("completedCreditHours"), out credits) || credits < 0)
                    throw new ArgumentException("Completed credit hours must be a non-negative whole number.");
                foreach (string name in new[] { "studentEmail" })
                {
                    MailAddress email;
                    try { email = new MailAddress(Field(name)); }
                    catch (FormatException) { throw new ArgumentException("Enter a valid student email address."); }
                    if (email.Address != Field(name)) throw new ArgumentException("Enter valid email addresses without display names.");
                }
                var placement = await PortalRepository.PlacementForStudent(uid);
                if (placement != null) throw new ArgumentException("You already have a confirmed internship.");
                var existingApplications = await PortalRepository.Collection(PortalRepository.Query("applications", "studentId", uid));
                if (existingApplications.Values.Any(x => (string)x["opportunityId"] == id)) throw new ArgumentException("You have already applied to this opportunity.");
                var confirmation = await FirebaseRestClient.GetAsync<JObject>("internshipConfirmations/" + uid, token);
                if (confirmation != null) throw new ArgumentException("You have already confirmed an internship.");
                string auth = "?auth=" + Uri.EscapeDataString(token);
                using (var response = await Client.GetAsync(FirebaseUrl + "opportunities/" + Uri.EscapeDataString(id) + ".json" + auth))
                {
                    response.EnsureSuccessStatusCode();
                    var opportunity = JsonConvert.DeserializeObject<Opportunity>(await response.Content.ReadAsStringAsync());
                    if (opportunity == null || !opportunity.IsAccepting)
                        throw new ArgumentException("This opportunity is closed or its application deadline has passed.");
                }

                var savedOpportunity = await FirebaseRestClient.GetAsync<Opportunity>("opportunities/" + id, token);
                var studentProfile = await FirebaseRestClient.GetAsync<JObject>("students/" + PortalRepository.Key(PortalRepository.ProfileId), token);
                if (!OpportunityEligibility.Matches(savedOpportunity, studentProfile)) throw new ArgumentException("This opportunity does not match your college or major.");
                var application = new PSUTInternship.Models.Application
                {
                    CvUrl = (string)studentProfile?["cvUrl"], Id = uid + "_" + id, CompanyId = savedOpportunity.CompanyId, AcademicSupervisorId = (string)studentProfile?["academicSupervisorId"], StudentId = uid, OpportunityId = id, Reason = Field("applicationReason"),
                    Details = new TrainingApplicationDetails
                    {
                        Faculty = Field("faculty"), University = Field("university"), Department = Field("department"), Program = Field("program"),
                        Semester = Field("semester"), AcademicYear = Field("academicYear"), ApplicationDate = applicationDate,
                        StudentName = Field("studentName"), UniversityId = Field("universityId"), CompletedCreditHours = credits,
                        StudentPhone = Field("studentPhone"), StudentEmail = Field("studentEmail"), AlternativePhone = Field("alternativePhone")
                    }
                };
                // One record per student/opportunity. Database create-only rules prevent overwriting reviews.
                string url = FirebaseUrl + "applications/" + Uri.EscapeDataString(uid + "_" + id) + ".json" + auth;
                using (var request = new HttpRequestMessage(HttpMethod.Put, url))
                {
                    // Ownership rules cannot authorize a conditional read of a missing record.
                    // Preserve legacy readers while omitting obsolete fields from new records.
                    var payload = JObject.FromObject(application);
                    var details = (JObject)payload["details"];
                    foreach (string obsolete in new[] { "organizationName", "organizationPhone", "mailingAddress",
                        "organizationEmail", "organizationWebsite", "trainingAddress", "trainingStartDate",
                        "trainingEndDate", "trainingField" })
                        details.Remove(obsolete);
                    request.Content = new StringContent(payload.ToString(Formatting.None), Encoding.UTF8, "application/json");
                    using (var response = await Client.SendAsync(request))
                    {
                        if (response.StatusCode == HttpStatusCode.PreconditionFailed)
                            throw new ArgumentException("You have already applied to this opportunity.");
                        response.EnsureSuccessStatusCode();
                    }
                }
                await LoadOpportunity();
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
            if (!CanApply) return;
            var values = Request.Form.AllKeys.Where(k => k != null && !k.StartsWith("__"))
                .ToDictionary(k => k, k => Request.Form[k]);
            if (AuthoritativeProfile != null) foreach (string field in new[] {"studentName","studentEmail","universityId","university","faculty","program"}) values[field] = Field(field);
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
                await OpportunityPresentation.Populate(new[] { opportunity });
                CanApply = opportunity.IsAccepting && !opportunity.HasApplied && !opportunity.HasConfirmedInternship;
                ApplicationAvailability = opportunity.HasConfirmedInternship ? "You have already confirmed an internship. Further applications are disabled." : opportunity.IsFull ? "All seats have been filled. This opportunity is closed." : opportunity.HasApplied ? "You have already applied to this opportunity." : !opportunity.IsAccepting ? "Applications are closed for this opportunity." : "";


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

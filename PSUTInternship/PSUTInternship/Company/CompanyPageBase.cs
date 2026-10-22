using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using PSUTInternship.Firebase;
using PSUTInternship.Models;

namespace PSUTInternship.Company
{
    // Shared Firebase loading, saving, and navigation for supervisor pages.
    public class CompanyPageBase : Page
    {
        protected List<CompanyOpportunity> OpportunityRows = new List<CompanyOpportunity>();
        protected List<CompanyApplication> ApplicationRows = new List<CompanyApplication>();
        protected List<CompanyTrainee> TraineeRows = new List<CompanyTrainee>();
        protected List<CompanyTaskSubmission> SubmissionRows = new List<CompanyTaskSubmission>();
        protected CompanyAccount CompanyProfile = new CompanyAccount { Name = "Company Supervisor", CompanyName = "Company" };
        protected string FirebaseError = "";
        protected string IdToken { get { return Session["FirebaseIdToken"] as string; } }
        protected string CompanyId { get { return ConfigurationManager.AppSettings["FirebaseCompanyId"] ?? "ofuqTechnology"; } }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (Session["FirebaseIdToken"] == null)
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected bool LoadCompanyData()
        {
            if (string.IsNullOrWhiteSpace(IdToken)) return false;
            try
            {
                // Start all five network requests before waiting for any result.
                Task<List<CompanyOpportunity>> opportunitiesTask = ReadCollectionAsync<CompanyOpportunity>("opportunities");
                Task<List<CompanyApplication>> applicationsTask = ReadCollectionAsync<CompanyApplication>("applications");
                Task<List<CompanyTrainee>> traineesTask = ReadCollectionAsync<CompanyTrainee>("trainees");
                Task<List<CompanyTaskSubmission>> submissionsTask = ReadCollectionAsync<CompanyTaskSubmission>("taskSubmissions");
                Task<CompanyAccount> profileTask = FirebaseRestClient.GetAsync<CompanyAccount>("companyAccounts/" + CompanyId, IdToken);

                OpportunityRows = opportunitiesTask.GetAwaiter().GetResult()
                    .Where(x => x.CompanyId == CompanyId).ToList();
                ApplicationRows = applicationsTask.GetAwaiter().GetResult()
                    .Where(x => x.CompanyId == CompanyId).ToList();
                TraineeRows = traineesTask.GetAwaiter().GetResult()
                    .Where(x => x.CompanyId == CompanyId).ToList();
                SubmissionRows = submissionsTask.GetAwaiter().GetResult()
                    .Where(x => x.CompanyId == CompanyId).ToList();
                CompanyProfile = profileTask.GetAwaiter().GetResult() ?? CompanyProfile;
                return true;
            }
            catch (Exception)
            {
                FirebaseError = "Could not load Firebase data. Check your database URL and Realtime Database rules.";
                return false;
            }
        }

        private async Task<List<T>> ReadCollectionAsync<T>(string path) where T : class
        {
            string query = "?orderBy=%22companyId%22&equalTo=%22" + Uri.EscapeDataString(CompanyId) + "%22";
            Dictionary<string, T> records = await FirebaseRestClient
                .GetAsync<Dictionary<string, T>>(path + query, IdToken).ConfigureAwait(false);
            if (records == null) return new List<T>();

            foreach (KeyValuePair<string, T> record in records)
            {
                CompanyOpportunity opportunity = record.Value as CompanyOpportunity;
                if (opportunity != null) { opportunity.Id = record.Key; continue; }
                CompanyApplication application = record.Value as CompanyApplication;
                if (application != null)
                {
                    application.Id = record.Key;
                    application.Status = FormatStatus(application.Status);
                    continue;
                }
                CompanyTrainee trainee = record.Value as CompanyTrainee;
                if (trainee != null) trainee.Id = record.Key;
                CompanyTaskSubmission submission = record.Value as CompanyTaskSubmission;
                if (submission != null) submission.Id = record.Key;
            }
            return records.Values.ToList();
        }
        private string FormatStatus(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return "Pending";
            return char.ToUpperInvariant(value[0]) + value.Substring(1).ToLowerInvariant();
        }

        protected string CreateOpportunity(CompanyOpportunity opportunity)
        {
            opportunity.CompanyId = CompanyId;
            opportunity.Status = opportunity.IsOpen ? "open" : "closed";
            string result = FirebaseRestClient.PostAsync("opportunities", opportunity, IdToken).GetAwaiter().GetResult();
            string id = JObject.Parse(result)["name"].Value<string>();
            opportunity.Id = id;
            return id;
        }

        protected void UpdateOpportunity(CompanyOpportunity opportunity)
        {
            opportunity.CompanyId = CompanyId;
            opportunity.Status = opportunity.IsOpen ? "open" : "closed";
            FirebaseRestClient.PutAsync("opportunities/" + opportunity.Id, opportunity, IdToken).GetAwaiter().GetResult();
        }

        protected void UpdateOpportunityStatus(string id, bool isOpen)
        {
            var update = new Dictionary<string, object>
            {
                { "isOpen", isOpen }, { "status", isOpen ? "open" : "closed" }
            };
            FirebaseRestClient.PatchAsync("opportunities/" + id, update, IdToken).GetAwaiter().GetResult();
        }

        protected void UpdateApplication(string id, string status, string rejectionReason)
        {
            var update = new Dictionary<string, object>
            {
                { "status", status.ToLowerInvariant() }, { "rejectionReason", rejectionReason ?? "" }
            };
            FirebaseRestClient.PatchAsync("applications/" + id, update, IdToken).GetAwaiter().GetResult();
        }

        protected void ConfirmStudentPlacement(CompanyApplication application)
        {
            CompanyTrainee trainee = TraineeRows.FirstOrDefault(x =>
                x.ApplicationId == application.Id || x.StudentId == application.StudentId);
            string traineeId = trainee != null ? trainee.Id :
                (string.IsNullOrWhiteSpace(application.StudentId) ? application.Id : application.StudentId);

            if (trainee == null)
            {
                trainee = new CompanyTrainee
                {
                    StudentId = application.StudentId,
                    StudentName = application.Student,
                    ApplicationId = application.Id,
                    OpportunityId = application.OpportunityId,
                    OpportunityTitle = application.Opportunity,
                    CompanyId = CompanyId,
                    TasksCompleted = 0,
                    TasksTotal = 6,
                    ApprovedTrainingHours = 0,
                    HoursPendingApproval = 0
                };
            }
            trainee.Status = "active";

            var updates = new Dictionary<string, object>
            {
                { "applications/" + application.Id + "/studentConfirmed", true },
                { "trainees/" + traineeId, trainee }
            };
            FirebaseRestClient.PatchAsync("", updates, IdToken).GetAwaiter().GetResult();
        }
        protected void UpdateCompanyProfile(CompanyAccount profile)
        {
            var update = new Dictionary<string, string>
            {
                { "displayName", profile.Name },
                { "phone", profile.Phone ?? "" },
                { "contactInfo", profile.ContactInfo ?? "" }
            };
            FirebaseRestClient.PatchAsync("companyAccounts/" + CompanyId, update, IdToken).GetAwaiter().GetResult();
        }

        protected bool TryFirebase(Action action)
        {
            try { action(); return true; }
            catch (Exception)
            {
                FirebaseError = "Firebase could not save the change. Check the user login and database rules.";
                return false;
            }
        }

        protected string H(string value) { return HttpUtility.HtmlEncode(value ?? ""); }

        protected string PageHeader(string activePage, string title, string subtitle)
        {
            string[] names = { "Dashboard", "Opportunities", "Applications", "My Trainees" };
            string[] links = { "Dashboard.aspx", "Opportunities.aspx", "Applications.aspx", "Trainees.aspx" };
            string[] keys = { "dashboard", "opportunities", "applications", "trainees" };
            string menu = "";
            for (int i = 0; i < names.Length; i++)
            {
                string active = keys[i] == activePage ? "active" : "";
                menu += "<a class='nav-link " + active + "' href='" + links[i] + "'>" + names[i] + "</a>";
            }
            menu += "<a class='nav-link' href='Applications.aspx'>Tasks &amp; Submissions</a>";
            menu += "<a class='nav-link' href='Trainees.aspx'>Training hours</a>";
            menu += "<a class='nav-link' href='Trainees.aspx'>Final evaluation</a>";
            string error = string.IsNullOrEmpty(FirebaseError) ? "" : "<div class='notice'>" + H(FirebaseError) + "</div>";
            return "<aside class='sidebar'><div class='brand'><span class='logo'>PSUT</span><span>Internship Portal</span></div>" +
                "<div class='role'>COMPANY SUPERVISOR</div>" + menu +
                "<div class='side-bottom'><a href='Account.aspx'>♙ &nbsp; Account settings</a><a href='Logout.aspx'>⇥ &nbsp; Logout</a></div></aside>" +
                "<main class='main'><header class='topbar'><input class='search-top' placeholder='⌕  Search your workspace' />" +
                "<span class='user'>◉ &nbsp; " + H(CompanyProfile.Name) + "<small>Company Supervisor</small></span></header>" +
                "<div class='content'><div class='crumb'>Workspace / " + H(title) + "</div><h1>" + H(title) + "</h1><p class='subtitle'>" + H(subtitle) + "</p>" + error;
        }
        protected string PageFooter() { return "<footer>Firebase data • Academic rules and evaluation scales require university verification.</footer></div></main>"; }
        protected void GoTo(string page) { Response.Redirect(page, false); Context.ApplicationInstance.CompleteRequest(); }
        protected string PostedValue(string key) { return Request.Form[key] ?? ""; }
        protected int PostedNumber(string key) { int number; return int.TryParse(PostedValue(key), out number) ? number : 0; }
    }
}










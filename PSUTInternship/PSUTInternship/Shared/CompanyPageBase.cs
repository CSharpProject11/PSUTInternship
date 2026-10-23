using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;
using PSUTInternship.Models;

namespace PSUTInternship.Shared
{
    // Shared Firebase loading, saving, and navigation for supervisor pages.
    public class CompanyPageBase : PSUTInternship.Shared.PortalPage
    {
        protected List<CompanyOpportunity> OpportunityRows = new List<CompanyOpportunity>();
        protected List<CompanyApplication> ApplicationRows = new List<CompanyApplication>();
        protected List<CompanyTrainee> TraineeRows = new List<CompanyTrainee>();
        protected List<CompanyTaskSubmission> SubmissionRows = new List<CompanyTaskSubmission>();
        protected CompanyAccount CompanyProfile = new CompanyAccount { Name = "Company Supervisor", CompanyName = "Company" };
        protected string FirebaseError = "";
        protected string IdToken { get { return Session["idToken"] as string; } }
        protected string CompanyId { get { return PortalRepository.CompanyId; } }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (Session["idToken"] == null)
            {
                Response.Redirect("~/Login.aspx", false);
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
                Task<List<CompanyTrainee>> traineesTask = ReadCollectionAsync<CompanyTrainee>("internships");
                Task<List<CompanyTaskSubmission>> submissionsTask = ReadCollectionAsync<CompanyTaskSubmission>("submissions");
                var taskRows = PortalRepository.Collection("tasks");
                Task<CompanyAccount> profileTask = FirebaseRestClient.GetAsync<CompanyAccount>("companySupervisors/" + CurrentProfileId, IdToken);

                OpportunityRows = opportunitiesTask.GetAwaiter().GetResult()
                    .Where(x => x.CompanyId == CompanyId).ToList();
                ApplicationRows = applicationsTask.GetAwaiter().GetResult()
                    .Where(x => x.CompanyId == CompanyId).ToList();
                TraineeRows = traineesTask.GetAwaiter().GetResult()
                    .Where(x => x.CompanyId == CompanyId).ToList();
                SubmissionRows = submissionsTask.GetAwaiter().GetResult()
                    .Where(x => x.CompanyId == CompanyId).ToList();
                CompanyProfile = profileTask.GetAwaiter().GetResult() ?? CompanyProfile;
                var tasks = taskRows.GetAwaiter().GetResult();
                foreach(var trainee in TraineeRows){trainee.TasksTotal=tasks.Values.Count(x=>(string)x["studentId"]==trainee.StudentId&&(bool?)x["active"]!=false);trainee.TasksCompleted=tasks.Values.Count(x=>(string)x["studentId"]==trainee.StudentId&&(bool?)x["active"]!=false&&(string)x["status"]=="Reviewed");}
                foreach(var app in ApplicationRows){var opening=OpportunityRows.FirstOrDefault(x=>x.Id==app.OpportunityId);if(opening!=null)app.Opportunity=opening.Title;
                    if (app.Details == null || string.IsNullOrWhiteSpace(app.Details.StudentName)) { var student = PortalRepository.Get<JObject>("students/"+PortalRepository.Key(app.StudentId)).GetAwaiter().GetResult(); app.Student = (string)student?["fullName"]; }}
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
            var raw = await PortalRepository.Collection(path).ConfigureAwait(false);
            var records = raw.ToDictionary(x => x.Key, x => x.Value.ToObject<T>());
            foreach (KeyValuePair<string, T> record in records)
            {
                CompanyOpportunity opportunity = record.Value as CompanyOpportunity;
                if (opportunity != null) { opportunity.Id = record.Key; continue; }
                CompanyApplication application = record.Value as CompanyApplication;
                if (application != null)
                {
                    application.Id = record.Key;
                    application.Status = FormatStatus(application.Status);
                    if (application.Status == "Approved") application.Status = "Accepted";
                    continue;
                }
                CompanyTrainee trainee = record.Value as CompanyTrainee;
                if (trainee != null) { trainee.Id = record.Key; var student = await PortalRepository.Get<JObject>("students/"+PortalRepository.Key(trainee.StudentId)).ConfigureAwait(false); trainee.StudentName = trainee.StudentName ?? (string)student?["fullName"]; var opening = await PortalRepository.Get<JObject>("opportunities/"+PortalRepository.Key(trainee.OpportunityId)).ConfigureAwait(false); trainee.OpportunityTitle = trainee.OpportunityTitle ?? (string)opening?["title"]; }
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
            opportunity.Id=Guid.NewGuid().ToString("N"); opportunity.CompanyId=CompanyId;
            UpdateOpportunity(opportunity); return opportunity.Id;
        }
        protected void UpdateOpportunity(CompanyOpportunity opportunity)
        {
            opportunity.CompanyId=CompanyId;
            var fields = JObject.FromObject(opportunity); fields.Remove("Id");
            var changes = fields.Properties().ToDictionary(x => "opportunities/"+opportunity.Id+"/"+x.Name, x => (object)x.Value);
            FirebaseRestClient.PatchAsync("",changes,IdToken).GetAwaiter().GetResult();
        }
        protected void UpdateOpportunityStatus(string id,bool isOpen)
        {
            var row=OpportunityRows.First(x=>x.Id==id);row.IsOpen=isOpen;UpdateOpportunity(row);
        }
        protected void UpdateApplication(string id, string status, string rejectionReason)
        {
            var existing = FirebaseRestClient.GetAsync<CompanyApplication>("applications/" + PortalRepository.Key(id), IdToken).GetAwaiter().GetResult();
            if (existing == null || existing.CompanyId != CompanyId || !string.Equals(existing.Status, "Pending", StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Only pending applications belonging to your company can be reviewed.");
            var update = new Dictionary<string, object>
            {
                { "status", status.Equals("Accepted", StringComparison.OrdinalIgnoreCase) ? "Approved" : "Rejected" }, { "rejectionReason", rejectionReason ?? "" }
            };
            FirebaseRestClient.PatchAsync("applications/" + id, update, IdToken).GetAwaiter().GetResult();
        }

        protected void UpdateCompanyProfile(CompanyAccount profile)
        {
            var update = new Dictionary<string, string>
            {
                { "fullName", profile.Name },
                { "phoneNumber", profile.Phone ?? "" },
                { "contactInfo", profile.ContactInfo ?? "" }
            };
            FirebaseRestClient.PatchAsync("companySupervisors/" + CurrentProfileId, update, IdToken).GetAwaiter().GetResult();
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

        // Navigation and form chrome are owned by Portal.Master for all company screens.
        protected string PageHeader(string activePage, string title, string subtitle)
        {
            string error = string.IsNullOrEmpty(FirebaseError) ? "" : "<div class='notice error' data-popup-message>" + H(FirebaseError) + "</div>";
            return "<div class='content'><h1>" + H(title) + "</h1><p class='subtitle'>" + H(subtitle) + "</p>" + error;
        }
        protected string PageFooter() { return "</div>"; }
        protected void GoTo(string page) { Response.Redirect(page, false); Context.ApplicationInstance.CompleteRequest(); }
        protected string PostedValue(string key) { return Request.Form[key] ?? ""; }
        protected int PostedNumber(string key) { int number; return int.TryParse(PostedValue(key), out number) ? number : 0; }
    }
}

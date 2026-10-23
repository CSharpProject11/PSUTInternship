using PSUTInternship.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.UI;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;

namespace PSUTInternship
{
    public partial class WorkspaceLayout : MasterPage
    {
        public string Role { get; private set; }
        public string RoleName { get; private set; }
        public string Name { get; private set; }
        public string Initials { get { return string.Join("", Name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries).Take(2).Select(s => s.Substring(0, 1))).ToUpperInvariant(); } }
        public string Heading { get; private set; }
        public string Description { get; private set; }
        public string FocusTitle { get; private set; }
        public string FocusText { get; private set; }
        public string WorkLabel { get; private set; }
        public string DateLabel { get { return TimeZoneInfo.ConvertTimeBySystemTimeZoneId(DateTime.UtcNow, "Jordan Standard Time").ToString("dddd, dd MMM yyyy", CultureInfo.InvariantCulture); } }
        public string PrimaryUrl { get { return Role == "student" ? ResolveUrl("~/Student/Opportunities.aspx") : Role == "company" ? ResolveUrl("~/Company/Applications.aspx") : "#workspace"; } }
        public string PrimaryLabel { get { return Role == "student" ? "Find an opportunity" : Role == "company" ? "Review applications" : "Open workspace"; } }
        public List<WorkspaceMetric> Metrics { get; private set; } = new List<WorkspaceMetric>();
        public List<WorkspaceRow> Rows { get; private set; } = new List<WorkspaceRow>();
        public List<WorkspaceOpening> Openings { get; private set; } = new List<WorkspaceOpening>();
        public List<WorkspaceRow> People { get; private set; } = new List<WorkspaceRow>();
        public List<string> Notices { get; private set; } = new List<string>();
        public int PendingCount { get; private set; }
        public int ApprovedCount { get; private set; }
        public int RejectedCount { get; private set; }
        public bool ApplicationsAvailable { get; private set; }
        public string ActivityLabel { get { return Role == "student" ? "Your applications" : Role == "company" ? "Candidate activity" : Role == "academic" ? "Student activity" : "Placement activity"; } }
        public string EmptyTitle { get { if (Role == "company" && ApplicationsAvailable) return "Nothing to review at the moment."; return ApplicationsAvailable ? "Your next chapter starts here" : "No activity available yet"; } }
        public string EmptyDescription { get { return ApplicationsAvailable ? "Applications will appear here as students begin their placement journey." : "The current database permissions do not provide application activity for this workspace. Contact the internship coordinator for access."; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            Role = Page.AppRelativeVirtualPath.Split('/')[1].ToLowerInvariant();
            Name = "PSUT member";
            ConfigureRole();
            if (Session["userId"] == null || Session["idToken"] == null)
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            if (!string.Equals(PortalRoles.Normalize(Convert.ToString(Session["userRole"])), Role, StringComparison.OrdinalIgnoreCase))
            {
                Response.StatusCode = 403;
                Response.TrySkipIisCustomErrors = true;
                Notices.Add("This workspace is available only to " + RoleName.ToLowerInvariant() + " accounts. Return to your own dashboard from the portal.");
                return;
            }
            Page.RegisterAsyncTask(new PageAsyncTask(LoadWorkspace));
        }

        private void ConfigureRole()
        {
            switch (Role)
            {
                case "company":
                    RoleName = "Company supervisor"; Heading = "Company dashboard";
                    Description = "Your opportunities, candidates and the next generation of talent.";
                    FocusTitle = "Keep your placements moving";
                    FocusText = "Keep your placements in view and help students take their next step."; WorkLabel = "My opportunities"; break;
                case "academic":
                    RoleName = "Academic supervisor"; Heading = "Academic dashboard";
                    Description = "A clear view of your students and their placement journey.";
                    FocusTitle = "Follow your students’ progress";
                    FocusText = "Follow your assigned students, their applications and their progress toward a placement."; WorkLabel = "My students"; break;
                case "admin":
                    RoleName = "Internship coordinator"; Heading = "Coordinator dashboard";
                    Description = "Students, supervisors and placements. One connected overview.";
                    FocusTitle = "People, placements and progress";
                    FocusText = "See the people and placements that connect learning with real experience."; WorkLabel = "People & placements"; break;
                default:
                    RoleName = "Student"; Heading = "Student dashboard";
                    Description = "A little closer to the experience that shapes what comes next.";
                    FocusTitle = "Your next placement starts here";
                    FocusText = "Discover an opportunity, make your application and find the right place to grow."; WorkLabel = "My applications"; break;
            }
        }

        private async Task<JObject> Read(string path)
        {
            return await PortalRepository.ReadObject(path) ?? new JObject();
        }

        private static string Value(JObject item, params string[] keys)
        {
            foreach (string key in keys)
            {
                var token = item.GetValue(key, StringComparison.OrdinalIgnoreCase);
                if (token is JValue && !string.IsNullOrWhiteSpace(token.ToString())) return token.ToString();
            }
            return "";
        }

        private async Task LoadWorkspace()
        {
            JObject people = null, opportunities = null, applications = null, currentProfile = null, accounts = null;
            var uid = Convert.ToString(Session["userId"]);
            var profileId = Convert.ToString(Session["profileId"]);
            if (string.IsNullOrWhiteSpace(profileId)) profileId = uid;
            try
            {
                string profileCollection = Role == "student" ? "students" : Role == "company" ? "companySupervisors" : Role == "academic" ? "academicSupervisors" : "users";
                var profile = await Read(profileCollection + "/" + Uri.EscapeDataString(profileId));
                currentProfile = profile;
                string fullName = Value(profile, "fullName", "name");
                if (!string.IsNullOrWhiteSpace(fullName)) Name = fullName;
            }
            catch (Exception ex) when (IsDataError(ex)) { Notices.Add("Your profile could not be loaded. Sign in again if this continues."); }

            if (Role == "student")
            {
                Heading = "Student dashboard";
                Description = "Stay on top of your applications, discover opportunities, and take your next step.";
            }

            try { opportunities = await Read("opportunities"); }
            catch (Exception ex) when (IsDataError(ex)) { Notices.Add("Opportunities could not be loaded. Refresh to try again."); }

            if (Role == "academic" || Role == "admin")
            {
                try { people = await Read("students"); }
                catch (Exception ex) when (IsDataError(ex)) { Notices.Add("Student records are unavailable with the current database permissions."); }
            }

            try
            {
                applications = await Read("applications");
                ApplicationsAvailable = true;
            }
            catch (Exception ex) when (IsDataError(ex)) { Notices.Add("Application activity is unavailable. Your session may have expired or your database role may not have read access."); }

            if (Role == "admin")
            {
                try { accounts = await Read("users"); }
                catch (Exception ex) when (IsDataError(ex)) { Notices.Add("Supervisor account totals could not be loaded."); }
            }
            var ownedOpportunityIds = new HashSet<string>();
            int opportunityCount = 0;
            if (opportunities != null)
            {
                foreach (var property in opportunities.Properties())
                {
                    var item = property.Value as JObject;
                    if (item == null) continue;
                    bool owned = Value(item, "companyId") == Convert.ToString(Session["companyId"]);
                    if (owned) ownedOpportunityIds.Add(property.Name);
                    if (Role == "company" && !owned) continue;
                    opportunityCount++;
                    bool open = DatabaseSchema.IsOpen(Value(item, "status"));
                    DateTime deadline;
                    if (DateTime.TryParse(Value(item, "deadline"), CultureInfo.InvariantCulture, DateTimeStyles.RoundtripKind, out deadline) && deadline.Date < DateTime.UtcNow.Date) open = false;
                    if (Role == "student" && (!open || !OpportunityEligibility.Matches(item.ToObject<PSUTInternship.Models.Opportunity>(), currentProfile))) continue;
                    Openings.Add(new WorkspaceOpening {
                        Id = property.Name, Title = Value(item, "title"), Location = Value(item, "location"),
                        Mode = Value(item, "workMode"), Status = open ? "Open" : "Closed",
                        Deadline = deadline == DateTime.MinValue ? "No deadline listed" : deadline.ToString("dd MMM yyyy", CultureInfo.InvariantCulture),
                        Url = ResolveUrl("~/Student/Apply.aspx?id=" + Uri.EscapeDataString(property.Name))
                    });
                }
            }
            var assignedStudentIds = new HashSet<string>();
            int studentCount = 0, supervisorCount = 0;
            if (people != null)
            {
                foreach (var person in people.Properties())
                {
                    var item = person.Value as JObject;
                    if (item == null) continue;
                    string role = Value(item, "role");

                    if (PortalRoles.Normalize(role) != "student") continue;
                    assignedStudentIds.Add(person.Name);
                    string studentUid = Value(item, "uid", "userId");
                    if (studentUid != "") assignedStudentIds.Add(studentUid);
                    studentCount++;
                    People.Add(new WorkspaceRow { Title = Value(item, "fullName", "name"), Person = Value(item, "major", "program", "email"), Status = Value(item, "isActive").Equals("true", StringComparison.OrdinalIgnoreCase) ? "Active" : "Inactive" });
                }
            }
            if (accounts != null) supervisorCount = accounts.Properties().Count(x => x.Value is JObject && new[] { "academic", "company" }.Contains(PortalRoles.Normalize(Value((JObject)x.Value, "role"))));
            var relevant = new List<JObject>();
            if (applications != null)
            {
                foreach(var entry in applications.Properties())
                {
                    var app=entry.Value as JObject;
                    if(app==null)continue;
                    if(Role=="student"&&Value(app,"studentId")!=uid)continue;
                    if(Role=="company"&&!ownedOpportunityIds.Contains(Value(app,"opportunityId")))continue;
                    if(Role=="academic"&&!assignedStudentIds.Contains(Value(app,"studentId")))continue;
                    relevant.Add(app);
                }
            }
            foreach (var app in relevant)
            {
                string status = Value(app, "status");
                if (status == "Pending") PendingCount++;
                if (status == "Approved") ApprovedCount++;
                if (status == "Rejected") RejectedCount++;
                var details = app["details"] as JObject ?? new JObject();
                string opportunityId = Value(app, "opportunityId");
                var opportunity = opportunities?[opportunityId] as JObject ?? new JObject();
                DateTime date;
                DateTime.TryParse(Value(app, "appliedAt"), CultureInfo.InvariantCulture, DateTimeStyles.RoundtripKind, out date);
                Rows.Add(new WorkspaceRow {
                    Title = Value(opportunity, "title") == "" ? Value(details, "trainingField", "organizationName") : Value(opportunity, "title"),
                    Person = Role == "student" ? Value(details, "organizationName") : Value(details, "studentName"),
                    Status = status == "" ? "Pending" : status,
                    Date = date == DateTime.MinValue ? "Date unavailable" : date.ToString("dd MMM yyyy", CultureInfo.InvariantCulture),
                    SortDate = date, Url = Role == "student" ? ResolveUrl("~/Student/MyApplications.aspx") : "#workspace"
                });
            }
            Rows = Rows.OrderByDescending(r => r.SortDate).ToList();
            if (Role == "student")
            {
                Metrics.Add(new WorkspaceMetric("Applications", ApplicationsAvailable ? Rows.Count.ToString() : "—", "Your submitted placements"));
                Metrics.Add(new WorkspaceMetric("Awaiting review", ApplicationsAvailable ? PendingCount.ToString() : "—", "Applications with a pending decision"));
                Metrics.Add(new WorkspaceMetric("Offers received", ApplicationsAvailable ? ApprovedCount.ToString() : "—", "Review offers in My applications"));
                Metrics.Add(new WorkspaceMetric("Open opportunities", opportunities == null ? "—" : Openings.Count.ToString(), "Explore your next step"));
            }
            else
            {
                Metrics.Add(new WorkspaceMetric(Role == "company" ? "My opportunities" : "Students", (Role == "company" ? opportunities != null : people != null) ? (Role == "company" ? opportunityCount : studentCount).ToString() : "—", Role == "academic" ? "Assigned to your supervision" : "Connected to your workspace"));
                Metrics.Add(new WorkspaceMetric("Applications", ApplicationsAvailable ? Rows.Count.ToString() : "—", "Placement applications in your scope"));
                Metrics.Add(new WorkspaceMetric("Awaiting review", ApplicationsAvailable ? PendingCount.ToString() : "—", "Pending application decisions"));
                Metrics.Add(new WorkspaceMetric(Role == "admin" ? "Supervisors" : "Approved placements", Role == "admin" ? (people == null ? "—" : supervisorCount.ToString()) : (ApplicationsAvailable ? ApprovedCount.ToString() : "—"), Role == "admin" ? "Company and academic accounts" : "Applications marked approved"));
            }
        }

        private static bool IsDataError(Exception ex) { return ex is HttpRequestException || ex is JsonException || ex is TaskCanceledException; }
    }

}

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
        public string PrimaryUrl { get { return Role == "student" ? ResolveUrl("~/Student/Opportunities.aspx") : "#workspace"; } }
        public string PrimaryLabel { get { return Role == "student" ? "Find an opportunity" : "Open workspace"; } }
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
        public string EmptyTitle { get { return ApplicationsAvailable ? "Your next chapter starts here" : "No activity available yet"; } }
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
            if (!string.Equals(Convert.ToString(Session["userRole"]), Role, StringComparison.OrdinalIgnoreCase))
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
                    RoleName = "Company supervisor"; Heading = "Make room for potential.";
                    Description = "Your opportunities, candidates and the next generation of talent.";
                    FocusTitle = "Great experience starts with great guidance.";
                    FocusText = "Keep your placements in view and help students take their next step."; WorkLabel = "My opportunities"; break;
                case "academic":
                    RoleName = "Academic supervisor"; Heading = "Guide their next chapter.";
                    Description = "A clear view of your students and their placement journey.";
                    FocusTitle = "A little guidance. A lasting difference.";
                    FocusText = "Follow your assigned students, their applications and their progress toward a placement."; WorkLabel = "My students"; break;
                case "admin":
                    RoleName = "Internship coordinator"; Heading = "Bring every journey together.";
                    Description = "Students, supervisors and placements. One connected overview.";
                    FocusTitle = "One community. Every opportunity.";
                    FocusText = "See the people and placements that connect learning with real experience."; WorkLabel = "People & placements"; break;
                default:
                    RoleName = "Student"; Heading = "Your potential. In progress.";
                    Description = "A little closer to the experience that shapes what comes next.";
                    FocusTitle = "Your next chapter is out there.";
                    FocusText = "Discover an opportunity, make your application and find the right place to grow."; WorkLabel = "My applications"; break;
            }
        }

        private async Task<JObject> Read(string path)
        {
            string url = FirebaseConfig.DatabaseUrl.TrimEnd('/') + "/" + path + ".json?auth="
                + Uri.EscapeDataString(Convert.ToString(Session["idToken"]));
            using (var response = await FirebaseConfig.Client.GetAsync(url))
            {
                response.EnsureSuccessStatusCode();
                return JsonConvert.DeserializeObject<JObject>(await response.Content.ReadAsStringAsync()) ?? new JObject();
            }
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

        private bool IsMine(string id)
        {
            return !string.IsNullOrEmpty(id) && (id == Convert.ToString(Session["userId"]) || id == Convert.ToString(Session["profileId"]));
        }

        private bool Assigned(JObject student)
        {
            return IsMine(Value(student, "academicSupervisorId", "collegeSupervisorId", "supervisorId"));
        }

        private async Task LoadWorkspace()
        {
            JObject people = null, opportunities = null, applications = null;
            var uid = Convert.ToString(Session["userId"]);
            var profileId = Convert.ToString(Session["profileId"]);
            if (string.IsNullOrWhiteSpace(profileId)) profileId = uid;
            try
            {
                var profile = await Read("students/" + Uri.EscapeDataString(profileId));
                string fullName = Value(profile, "fullName", "name");
                if (!string.IsNullOrWhiteSpace(fullName)) Name = fullName;
            }
            catch (Exception ex) when (IsDataError(ex)) { Notices.Add("Your profile could not be loaded. Sign in again if this continues."); }

            if (Role == "student")
            {
                int hour = TimeZoneInfo.ConvertTimeBySystemTimeZoneId(DateTime.UtcNow, "Jordan Standard Time").Hour;
                string greeting = hour < 12 ? "Good morning" : hour < 18 ? "Good afternoon" : "Good evening";
                string firstName = Name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries).FirstOrDefault() ?? "student";
                Heading = greeting + ", " + firstName + ".";
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
                applications = await Read(Role == "student" ? "applications/" + Uri.EscapeDataString(uid) : "applications");
                ApplicationsAvailable = true;
            }
            catch (Exception ex) when (IsDataError(ex)) { Notices.Add("Application activity is unavailable. Your session may have expired or your database role may not have read access."); }

            var ownedOpportunityIds = new HashSet<string>();
            int opportunityCount = 0;
            if (opportunities != null)
            {
                foreach (var property in opportunities.Properties())
                {
                    var item = property.Value as JObject;
                    if (item == null) continue;
                    bool owned = IsMine(Value(item, "companyId"));
                    if (owned) ownedOpportunityIds.Add(property.Name);
                    if (Role == "company" && !owned) continue;
                    opportunityCount++;
                    bool open = string.Equals(Value(item, "status"), "true", StringComparison.OrdinalIgnoreCase);
                    DateTime deadline;
                    if (DateTime.TryParse(Value(item, "deadline"), CultureInfo.InvariantCulture, DateTimeStyles.RoundtripKind, out deadline) && deadline.Date < DateTime.UtcNow.Date) open = false;
                    if (Role == "student" && !open) continue;
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
                    if (role == "academic" || role == "company") supervisorCount++;
                    if (role != "student" || (Role == "academic" && !Assigned(item))) continue;
                    assignedStudentIds.Add(person.Name);
                    string studentUid = Value(item, "uid", "userId");
                    if (studentUid != "") assignedStudentIds.Add(studentUid);
                    studentCount++;
                    People.Add(new WorkspaceRow { Title = Value(item, "fullName", "name"), Person = Value(item, "major", "program", "email"), Status = Value(item, "isActive").Equals("true", StringComparison.OrdinalIgnoreCase) ? "Active" : "Inactive" });
                }
            }
            var relevant = new List<JObject>();
            if (applications != null)
            {
                if (Role == "student") relevant.AddRange(applications.Properties().Select(p => p.Value as JObject).Where(a => a != null && Value(a, "studentId") == uid));
                else foreach (var group in applications.Properties())
                {
                    var collection = group.Value as JObject;
                    if (collection == null) continue;
                    foreach (var entry in collection.Properties())
                    {
                        var app = entry.Value as JObject;
                        if (app == null) continue;
                        if (Role == "company" && !ownedOpportunityIds.Contains(Value(app, "opportunityId"))) continue;
                        if (Role == "academic" && !assignedStudentIds.Contains(Value(app, "studentId"))) continue;
                        relevant.Add(app);
                    }
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

    public class WorkspaceMetric
    {
        public string Label, Value, Hint;
        public WorkspaceMetric(string label, string value, string hint) { Label = label; Value = value; Hint = hint; }
    }
    public class WorkspaceRow { public string Title, Person, Status, Date, Url; public DateTime SortDate; }
    public class WorkspaceOpening { public string Id, Title, Location, Mode, Status, Deadline, Url; }
}

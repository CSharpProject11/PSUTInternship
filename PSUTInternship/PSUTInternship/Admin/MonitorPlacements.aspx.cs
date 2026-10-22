using PSUTInternship.Shared;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

using System;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Collections.Generic;

public partial class MonitorPlacements : PortalPage
{
    public class InternshipTask
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public string Deadline { get; set; }
        public string Status { get; set; }
    }

    public class HourLog
    {
        public string Date { get; set; }
        public decimal Hours { get; set; }
        public string Description { get; set; }
        public string Status { get; set; }
    }

    public class Placement
    {
        public string Id { get; set; }
        public string Student { get; set; }
        public string Company { get; set; }
        public string Supervisor { get; set; }
        public decimal Hours { get; set; }
        public decimal Required { get; set; }
        public string Status { get; set; }
        public string EvaluationStatus { get; set; }
        public string AcademicEvaluation { get; set; }
        public string AcademicFeedback { get; set; }
        public string CompanyEvaluation { get; set; }
        public string CompanyFeedback { get; set; }
        public string CompanyScore { get; set; }
        public string AcademicScore { get; set; }
        public List<HourLog> HourLogs { get; set; }
        public List<InternshipTask> Tasks { get; set; }
    }

    private List<Placement> Data = new List<Placement>();
    protected string FirebaseError = "";
    private async Task LoadFirebase()
    {
        CoordinatorData.RequireCoordinator();
        var internships = await CoordinatorData.Read("internships");
        var users = await CoordinatorData.Read("users");
        var students = await CoordinatorData.Read("students");
        var companies = await CoordinatorData.Read("companies");
        var academic = await CoordinatorData.Read("academicSupervisors");
        var tasks = await CoordinatorData.Read("tasks");
        
        var hours = await CoordinatorData.Read("trainingHours");
        var evaluations = await CoordinatorData.Read("evaluations");
        foreach(var item in CoordinatorData.Items(internships))
        {
            var i=item.Value;
            string studentId=CoordinatorData.Str(i,"studentId");
            var st=CoordinatorData.FindStudent(students,users,studentId);
            var company=CoordinatorData.Get(companies,CoordinatorData.Str(i,"companyId"));
            var supervisor=CoordinatorData.Get(academic,CoordinatorData.Str(i,"academicSupervisorId"));
            decimal required=CoordinatorData.Number(st,"requiredHours",CoordinatorData.Number(st,"requiredTrainingHours",CoordinatorData.Number(i,"requiredHours")));
            decimal approved=CoordinatorData.ApprovedHours(hours,item.Key,studentId);
            var associated=CoordinatorData.Items(tasks).Where(t=>CoordinatorData.BelongsTo(t.Value,item.Key,studentId)).ToList();
            var taskModels=associated.Select(t=> {
                string state=CoordinatorData.TaskStatus(t.Value);
                return new InternshipTask {Name=CoordinatorData.Str(t.Value,"title"),Description=CoordinatorData.Str(t.Value,"description"),Deadline=CoordinatorData.Str(t.Value,"dueDate"),Status=state};
            }).ToList();
            var ev=CoordinatorData.Evaluation(evaluations,item.Key,studentId,"academicSupervisor");
            var companyEvaluation=CoordinatorData.Evaluation(evaluations,item.Key,studentId,"companySupervisor");
            var hourLogs=CoordinatorData.Items(hours).Select(x=>x.Value).Where(x=>CoordinatorData.BelongsTo(x,item.Key,studentId)).OrderByDescending(x=>CoordinatorData.Str(x,"date")).Select(x=>new HourLog { Date=CoordinatorData.Str(x,"date"),Hours=CoordinatorData.Number(x,"hours"),Description=CoordinatorData.Str(x,"description"),Status=CoordinatorData.Str(x,"status") }).ToList();
            string internshipStatus=CoordinatorData.Str(i,"status");
            string displayStatus=internshipStatus=="completed" ? "Completed" : (required>0 && approved<required && !string.IsNullOrEmpty(CoordinatorData.Str(i,"endDate")) && string.CompareOrdinal(CoordinatorData.Str(i,"endDate"),TimeZoneInfo.ConvertTimeBySystemTimeZoneId(DateTime.UtcNow,"Jordan Standard Time").ToString("yyyy-MM-dd"))<0 ? "At Risk" : "On Track");
            Data.Add(new Placement { Id=item.Key, Student=CoordinatorData.Str(st,"fullName","Unknown student"), Company=CoordinatorData.Str(company,"name",CoordinatorData.Str(st,"company","Unassigned")), Supervisor=CoordinatorData.Str(supervisor,"fullName",CoordinatorData.Str(st,"academicSupervisorName","Unassigned")), Hours=approved,Required=required,Status=displayStatus, EvaluationStatus=CoordinatorData.EvaluationStatus(ev),AcademicEvaluation=CoordinatorData.EvaluationStatus(ev),AcademicFeedback=CoordinatorData.Str(ev,"comments"),CompanyEvaluation=CoordinatorData.EvaluationStatus(companyEvaluation),CompanyFeedback=CoordinatorData.Str(companyEvaluation,"comments"),CompanyScore=Score(companyEvaluation),AcademicScore=Score(ev),HourLogs=hourLogs,Tasks=taskModels });
        }
    }

    // Page variables
    protected string Search = "";
    protected string Status = "All";
    protected string ViewMode = "";

    protected int Total = 0;
    protected int OnTrack = 0;
    protected int AtRisk = 0;

    protected Placement SelectedPlacement = null;
    protected bool HasManyTasks = false;

    protected async void Page_Load(object sender, EventArgs e)
    {
        Search = (Request.Form["search"] ?? Request.QueryString["search"] ?? "").Trim();
        Status = Request.Form["status"] ?? Request.QueryString["status"] ?? "All";

        if (Status != "All" &&
            Status != "On Track" &&
            Status != "At Risk" &&
            Status != "Completed")
        {
            Status = "All";
        }

        CoordinatorData.RequireCoordinator();
        try { await LoadFirebase(); }
        catch(Exception ex) { FirebaseError = ex.Message; }
        Total = Data.Count;
        OnTrack = Data.Count(x => x.Status == "On Track");
        AtRisk = Data.Count(x => x.Status == "At Risk");

        string studentId = Request.QueryString["id"];

        if (!string.IsNullOrEmpty(studentId))
        {
            SelectedPlacement =
                Data.FirstOrDefault(x => x.Id == studentId);
        }

        if (SelectedPlacement != null)
        {
            string requestedView =
                Request.QueryString["view"] ?? "";

            if (requestedView == "tasks" ||
                requestedView == "evaluation" || requestedView == "hours")
            {
                ViewMode = requestedView;
            }

            HasManyTasks =
                SelectedPlacement.Tasks != null &&
                SelectedPlacement.Tasks.Count > 5;




        }
    }

    private static string Score(JObject evaluation)
    {
        if(evaluation==null) return "Not recorded";
        string maximum=PortalRoles.Normalize(CoordinatorData.Str(evaluation,"evaluatorRole"))=="academic" ? EvaluationPolicy.AcademicMaximum.ToString(System.Globalization.CultureInfo.InvariantCulture) : CoordinatorData.Str(evaluation,"totalMaximum","—");
        return CoordinatorData.Str(evaluation,"overallScore","—")+" / "+maximum;
    }

    // Encode text to prevent HTML injection
    protected string H(string value)
    {
        return HttpUtility.HtmlEncode(value ?? "");
    }

    // Keep selected status after filtering
    protected string Selected(string value)
    {
        return Status == value
            ? "selected=\"selected\""
            : "";
    }

    // Calculate approved training hours percentage
    protected int GetProgress(Placement student)
    {
        if (student.Required <= 0)
            return 0;

        double percentage =
            (double)student.Hours / (double)student.Required * 100;

        percentage =
            Math.Max(0, Math.Min(100, percentage));

        return (int)Math.Round(percentage);
    }

    // Format task status
    protected string TaskBadge(string status)
    {
        string badgeClass = "warn";

        if (status == "Reviewed")
            badgeClass = "ok";
        else if (status == "Rejected" || status == "Revision Requested")
            badgeClass = "bad";

        return "<span class='tag " + badgeClass + "'>" +
               H(status) +
               "</span>";
    }

    // Main student table
    protected string Rows()
    {
        var filteredStudents = Data.Where(x =>
            (Status == "All" || x.Status == Status) &&
            (
                x.Student.IndexOf(
                    Search,
                    StringComparison.OrdinalIgnoreCase
                ) >= 0
                ||
                x.Company.IndexOf(
                    Search,
                    StringComparison.OrdinalIgnoreCase
                ) >= 0
            )
        ).ToList();

        if (filteredStudents.Count == 0)
        {
            return "<tr><td colspan='8' class='empty-cell'>" +
                   H(string.IsNullOrEmpty(FirebaseError) ? "No internship records found." : FirebaseError) +
                   "</td></tr>";
        }

        return string.Join("", filteredStudents.Select(student =>
        {
            int progress = GetProgress(student);

            int totalTasks = student.Tasks == null
                ? 0
                : student.Tasks.Count;

            string statusClass =
                student.Status == "At Risk" ? "bad" :
                student.Status == "Completed" ? "ok" : "warn";

            string progressHtml =
                "<div class='progress-cell'>" +
                    "<span class='progress-number'>" +
                        progress + "%" +
                    "</span>" +
                    "<div class='progress-bar'>" +
                        "<div class='progress-fill' style='width:" +
                            progress + "%'></div>" +
                    "</div>" +
                "</div>";

            string actions =
                "<div class='student-actions'>" +

                    "<a class='btn secondary' href='MonitorPlacements.aspx?id=" +
                        HttpUtility.UrlEncode(student.Id) +
                        "&amp;view=tasks'>" +
                        "View Tasks" +
                    "</a>" +

                    "<a class='btn' href='MonitorPlacements.aspx?id=" +
                        HttpUtility.UrlEncode(student.Id) +
                        "&amp;view=evaluation'>" +
                        "View Evaluations" +
                    "</a>" +
                    "<a class='btn secondary' href='MonitorPlacements.aspx?id="+HttpUtility.UrlEncode(student.Id)+"&amp;view=hours'>View Hours</a>" +
                "</div>";

            return
                "<tr>" +
                    "<td>" + H(student.Student) + "</td>" +
                    "<td>" + H(student.Company) + "</td>" +
                    "<td>" + H(student.Supervisor) + "</td>" +
                    "<td>" + totalTasks + " Tasks</td>" +
                    "<td>" + student.Hours + " / " +
                        student.Required + " hrs</td>" +
                    "<td>" + progressHtml + "</td>" +
                    "<td><span class='tag " + statusClass + "'>" +
                        H(student.Status) + "</span></td>" +
                    "<td>" + actions + "</td>" +
                "</tr>";
        }));
    }

    // Task cards inside Tasks popup
    protected string TaskRows()
    {
        if (SelectedPlacement == null ||
            SelectedPlacement.Tasks == null ||
            SelectedPlacement.Tasks.Count == 0)
        {
            return "<div class='popup-task-empty'>" +
                   "No tasks assigned to this student." +
                   "</div>";
        }

        return string.Join("",
            SelectedPlacement.Tasks.Select(task =>
            {
                return
                    "<div class='popup-task-item'>" +

                        "<div class='popup-task-content'>" +
                            "<strong>" + H(task.Name) + "</strong>" +
                            "<p>" + H(task.Description) + "</p>" +
                            "<small>Deadline: " +
                                H(task.Deadline) +
                            "</small>" +
                        "</div>" +

                        TaskBadge(task.Status) +

                    "</div>";
            })
        );
    }
}

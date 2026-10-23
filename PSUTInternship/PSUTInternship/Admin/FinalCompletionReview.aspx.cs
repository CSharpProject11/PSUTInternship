using PSUTInternship.Shared;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;

public partial class FinalCompletionReview : PortalPage
{
    // ==================================
    // Student Internship Record
    // ==================================

    public class FinalStudent
    {
        public string Id { get; set; }
        public string StudentId { get; set; }
        public string Name { get; set; }

        public string University { get; set; }
        public string Major { get; set; }

        public string Company { get; set; }
        public string TrainingField { get; set; }

        public string CompanySupervisor { get; set; }
        public string AcademicSupervisor { get; set; }

        public string StartDate { get; set; }
        public string EndDate { get; set; }

        public decimal CompletedHours { get; set; }
        public decimal RequiredHours { get; set; }

        public string CompanyEvaluation { get; set; }
        public string AcademicEvaluation { get; set; }

        // Company evaluation details
        public string TechnicalPerformance { get; set; }
        public string WorkCommitment { get; set; }
        public string ProfessionalConduct { get; set; }
        public string TaskPerformance { get; set; }
        public string CompanyFeedback { get; set; }

        // Academic evaluation details
        public string ReportAssessment { get; set; }
        public string AcademicFollowup { get; set; }
        public string LearningObjectives { get; set; }
        public string AcademicRequirements { get; set; }
        public string AcademicFeedback { get; set; }

        public bool RequirementsMet { get; set; }
        public string GainedSkills { get; set; }
        public string UserId { get; set; }
        public string ReviewId { get; set; }
        public bool Approved { get; set; }
        public bool ReadyForApproval { get; set; }
    }

    // ==================================
    private List<FinalStudent> Data = new List<FinalStudent>();
    protected string FirebaseError = "";
    protected string Notice = "";
    private async Task LoadFirebase()
    {
        CoordinatorData.RequireCoordinator();
        var internships=await CoordinatorData.Read("internships");
        var reports=await CoordinatorData.Read("completionReports");
        var queue=await CoordinatorData.Read("coordinatorReviewQueue");
        var tasks=await CoordinatorData.Read("tasks");
        var students=await CoordinatorData.Read("students");
        var users=await CoordinatorData.Read("users");
        var companies=await CoordinatorData.Read("companies");
        var companySupervisors=await CoordinatorData.Read("companySupervisors");
        var academic=await CoordinatorData.Read("academicSupervisors");
        var evaluations=await CoordinatorData.Read("evaluations");
        var hours=await CoordinatorData.Read("trainingHours");
        foreach(var row in CoordinatorData.Items(internships))
        {
            var i=row.Value;
            string sid=CoordinatorData.Str(i,"studentId");
            var st=CoordinatorData.FindStudent(students,users,sid);
            var company=CoordinatorData.Get(companies,CoordinatorData.Str(i,"companyId"));
            var cs=CoordinatorData.Get(companySupervisors,CoordinatorData.Str(i,"companySupervisorId"));
            var ac=CoordinatorData.Get(academic,CoordinatorData.Str(i,"academicSupervisorId"));
            var ce=CoordinatorData.Evaluation(evaluations,row.Key,sid,"companySupervisor");
            var ae=CoordinatorData.Evaluation(evaluations,row.Key,sid,"academicSupervisor");
            var report=CoordinatorData.Items(reports).Select(x=>x.Value).Where(x=>CoordinatorData.Str(x,"internshipId")==row.Key && CoordinatorData.Str(x,"studentId")==sid).OrderByDescending(DatabaseSchema.ReportApproved).FirstOrDefault();
            var review=CoordinatorData.Items(queue).FirstOrDefault(x=>CoordinatorData.Str(x.Value,"studentId")==sid && evaluations[x.Key] == ae);
            var ceStatus=CoordinatorData.EvaluationStatus(ce);
            var aeStatus=CoordinatorData.EvaluationStatus(ae);
            decimal required=CoordinatorData.Number(st,"requiredHours",CoordinatorData.Number(st,"requiredTrainingHours",CoordinatorData.Number(i,"requiredHours")));
            decimal approved=CoordinatorData.ApprovedHours(hours,row.Key,sid);
            bool tasksReviewed=!CoordinatorData.Items(tasks).Any(x=>CoordinatorData.BelongsTo(x.Value,row.Key,sid) && ((bool?)x.Value["active"] ?? true) && CoordinatorData.TaskStatus(x.Value)!="Reviewed");
            bool passingGrade=false;
            try { passingGrade=EvaluationPolicy.FinalGrade(CoordinatorData.Number(ce,"overallScore",-1),CoordinatorData.Number(ce,"totalMaximum"),CoordinatorData.Number(ae,"overallScore",-1))>=EvaluationPolicy.PassGrade; }
            catch(InvalidOperationException) { }
            // Eligibility requires both passing evaluations AND verified training hours.
            Data.Add(new FinalStudent {Id=row.Key,UserId=sid,ReviewId=review.Key,Approved=DatabaseSchema.ReportApproved(report),ReadyForApproval=review.Key!=null && passingGrade && tasksReviewed && required>0 && approved>=required && CoordinatorData.Str(ce,"status")=="submitted" && CoordinatorData.Str(ae,"status")=="submitted" && CoordinatorData.Str(ae,"recommendation")=="Pass" && CoordinatorData.Str(ae,"evaluatorId")==CoordinatorData.Str(i,"academicSupervisorId"),StudentId=CoordinatorData.Str(st,"studentNumber",sid),Name=CoordinatorData.Str(st,"fullName","Unknown student"),University=CoordinatorData.Str(st,"university","Princess Sumaya University for Technology"),Major=CoordinatorData.Str(st,"major"),Company=CoordinatorData.Str(company,"name",CoordinatorData.Str(st,"company")),TrainingField=CoordinatorData.Str(st,"major"),CompanySupervisor=CoordinatorData.Str(cs,"fullName"),AcademicSupervisor=CoordinatorData.Str(ac,"fullName",CoordinatorData.Str(st,"academicSupervisorName")),StartDate=CoordinatorData.Str(i,"startDate"),EndDate=CoordinatorData.Str(i,"endDate"),CompletedHours=approved,RequiredHours=required,CompanyEvaluation=ceStatus,AcademicEvaluation=aeStatus,TechnicalPerformance=CoordinatorData.Str(ce,"technicalPerformance","Pending"),WorkCommitment=CoordinatorData.Str(ce,"workCommitment","Pending"),ProfessionalConduct=CoordinatorData.Str(ce,"professionalConduct","Pending"),TaskPerformance=CoordinatorData.Str(ce,"taskPerformance","Pending"),CompanyFeedback=CoordinatorData.Str(ce,"comments"),ReportAssessment=CoordinatorData.Str(ae,"reportAssessment","Pending"),AcademicFollowup=CoordinatorData.Str(ae,"academicFollowup","Pending"),LearningObjectives=CoordinatorData.Str(ae,"learningObjectives","Pending"),AcademicRequirements=CoordinatorData.Str(ae,"academicRequirements","Pending"),AcademicFeedback=CoordinatorData.Str(ae,"comments"),RequirementsMet=required>0 && approved>=required && tasksReviewed,GainedSkills=CoordinatorData.Str(report,"gainedSkills")});
        }
    }

    protected string Search = "";
    protected string Filter = "All";
    protected string Mode = "";

    protected string CertificateSkills = "";
    protected string CertificateSignatory = "Internship Coordinator";

    protected int Total;
    protected int EligibleCount;
    protected int PendingCount;

    protected FinalStudent SelectedStudent = null;

    // ==================================
    // Page Load
    // ==================================

    protected async void Page_Load(object sender, EventArgs e)
    {
        Search = (Request.Form["search"] ??
                  Request.QueryString["search"] ??
                  "").Trim();

        Filter = Request.Form["filter"] ??
                 Request.QueryString["filter"] ??
                 "All";

        if (Filter != "All" &&
            Filter != "Pass" &&
            Filter != "Failed" &&
            Filter != "Pending")
        {
            Filter = "All";
        }

        CoordinatorData.RequireCoordinator();
        try
        {
            if(IsPostBack && !string.IsNullOrEmpty(Request.Form["approveCompletion"]))
            {
                try { await CompletionWorkflow.Approve(Request.Form["approveCompletion"]); Notice="Completion approved and certificate created. The official report is available to download."; }
                catch(Exception ex) { FirebaseError=ex.Message; }
            }
            await LoadFirebase();
        }
        catch(Exception ex) { FirebaseError = ex.Message; }
        Total = Data.Count;

        EligibleCount =
            Data.Count(x => CanCreateCertificate(x));

        PendingCount =
            Data.Count(x =>
                !CanCreateCertificate(x) &&
                !HasFailedEvaluation(x));

        string studentId = Request.QueryString["id"];

        if (!string.IsNullOrEmpty(studentId))
        {
            SelectedStudent =
                Data.FirstOrDefault(x => x.Id == studentId);

            Mode = Request.QueryString["mode"] ?? "review";
        }

        // Read-only certificate preview processing.
        string action = Request.Form["certificateAction"] ?? "";

        if (IsPostBack && action.StartsWith("preview:"))
        {
            string previewStudentId = action.Substring(8);

            if (!string.IsNullOrEmpty(previewStudentId))
            {
                FinalStudent student =
                    Data.FirstOrDefault(x => x.Id == previewStudentId);

                if (student != null && CanCreateCertificate(student))
                {
                    SelectedStudent = student;

                    CertificateSkills =
                        (Request.Form["certificateSkills"] ?? "").Trim();

                    CertificateSignatory =
                        (Request.Form["certificateSignatory"] ?? "").Trim();

                    // Input length limits.
                    if (CertificateSkills.Length > 500)
                    {
                        CertificateSkills =
                            CertificateSkills.Substring(0, 500);
                    }

                    if (CertificateSignatory.Length > 100)
                    {
                        CertificateSignatory =
                            CertificateSignatory.Substring(0, 100);
                    }

                    Mode =
                        !string.IsNullOrWhiteSpace(CertificateSkills) &&
                        !string.IsNullOrWhiteSpace(CertificateSignatory)
                        ? "preview"
                        : "certificate";
                }
            }
        }

        if (SelectedStudent != null)
        {
            if (string.IsNullOrEmpty(CertificateSkills))
            {
                CertificateSkills = SelectedStudent.GainedSkills;
            }

            if (string.IsNullOrEmpty(CertificateSignatory))
            {
                CertificateSignatory = "Internship Coordinator";
            }

            if ((Mode == "certificate" || Mode == "preview") &&
                !CanCreateCertificate(SelectedStudent))
            {
                Mode = "review";
            }

            if (Mode != "review" &&
                Mode != "certificate" &&
                Mode != "preview")
            {
                Mode = "review";
            }
        }
    }

    // ==================================
    // Helpers
    // ==================================

    protected string H(string value)
    {
        return HttpUtility.HtmlEncode(value ?? "");
    }

    protected string Selected(string value)
    {
        return Filter == value
            ? "selected=\"selected\""
            : "";
    }

    protected string Initials(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
            return "ST";

        string[] words =
            name.Split(new[] { ' ' },
                StringSplitOptions.RemoveEmptyEntries);

        if (words.Length == 1)
            return words[0].Substring(0, 1).ToUpperInvariant();

        return (
            words[0].Substring(0, 1) +
            words[words.Length - 1].Substring(0, 1)
        ).ToUpperInvariant();
    }

    // ==================================
    // Evaluation Logic
    // ==================================

    protected bool HasFailedEvaluation(FinalStudent student)
    {
        if (student == null)
            return false;

        return student.CompanyEvaluation == "Not Pass" ||
               student.AcademicEvaluation == "Not Pass";
    }

    protected string GetEvaluationStatus(FinalStudent student)
    {
        if (student == null)
            return "Pending";

        if (HasFailedEvaluation(student))
            return "Failed";

        if (student.CompanyEvaluation == "Pass" &&
            student.AcademicEvaluation == "Pass")
            return "Pass";

        return "Pending";
    }


    protected bool CanCreateCertificate(FinalStudent student)
    {
        return student != null && student.Approved;
    }


    // ==================================
    // Progress Calculation
    // ==================================

    protected int Progress(FinalStudent student)
    {
        if (student == null || student.RequiredHours <= 0)
            return 0;

        double value =
            (double)student.CompletedHours /
            (double)student.RequiredHours * 100;

        return (int)Math.Round(
            Math.Max(0, Math.Min(100, value)));
    }

    // ==================================
    // Evaluation Badges
    // ==================================

    protected string Badge(string status)
    {
        string css = "warn";

        if (status == "Pass")
        {
            css = "ok";
        }
        else if (status == "Not Pass" || status == "Failed")
        {
            css = "bad";
        }

        return "<span class='tag " + css + "'>" +
               H(status) + "</span>";
    }

    protected string RequirementBadge(bool completed)
    {
        return completed
            ? "<span class='tag ok'>Completed</span>"
            : "<span class='tag bad'>Not Completed</span>";
    }

    // ==================================
    // Certificate Data
    // ==================================

    protected string CertificateReference(FinalStudent student)
    {
        // Preview reference only; not a registered certificate.
        return "PREVIEW-" + student.StudentId;
    }

    protected string PopupUrl(string id, string mode)
    {
        return "FinalCompletionReview.aspx?id=" +
               HttpUtility.UrlEncode(id) +
               "&mode=" +
               HttpUtility.UrlEncode(mode);
    }

    // ==================================
    // Main Table
    // ==================================

    protected string Rows()
    {
        var students = Data.Where(x =>
            (
                Filter == "All" ||
                GetEvaluationStatus(x) == Filter
            )
            &&
            (
                x.Name.IndexOf(
                    Search,
                    StringComparison.OrdinalIgnoreCase) >= 0
                ||
                x.Company.IndexOf(
                    Search,
                    StringComparison.OrdinalIgnoreCase) >= 0
                ||
                x.StudentId.IndexOf(
                    Search,
                    StringComparison.OrdinalIgnoreCase) >= 0
            )
        ).ToList();

        if (students.Count == 0)
        {
            return "<tr><td colspan='6' " +
                   "style='text-align:center;padding:25px;'>" +
                   H(string.IsNullOrEmpty(FirebaseError) ? "No students found." : FirebaseError) +
                   "</td></tr>";
        }

        return string.Join("", students.Select(student =>
        {
            string actions =
                "<div class='fcr-actions'>" +

                    "<a class='btn secondary' href='" +
                    H(PopupUrl(student.Id, "review")) +
                    "'>Review</a>";

            if (CanCreateCertificate(student))
            {
                actions +=
                    "<a class='btn green' href='../CompletionReport.aspx?studentId=" +
                    H(HttpUtility.UrlEncode(student.UserId)) + "'>Download Report</a>";
            }

            if (!student.Approved && student.ReadyForApproval)
                actions += "<button class='btn' type='submit' name='approveCompletion' value='" + H(student.ReviewId) + "'>Approve &amp; Create Certificate</button>";
            actions += "</div>";

            string hours =
                student.CompletedHours +
                " / " +
                student.RequiredHours +
                " hrs";

            return
                "<tr>" +

                    "<td><strong>" +
                    H(student.Name) +
                    "</strong><small class='fcr-student-id'>" +
                    H(student.StudentId) +
                    "</small></td>" +

                    "<td>" + H(student.Company) + "</td>" +

                    "<td>" +
                    Badge(student.CompanyEvaluation) +
                    "</td>" +

                    "<td>" +
                    Badge(student.AcademicEvaluation) +
                    "</td>" +

                    "<td>" + hours + "</td>" +

                    "<td>" + actions + "</td>" +

                "</tr>";
        }));
    }
}

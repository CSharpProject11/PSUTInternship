using System;
using System.Linq;
using System.Globalization;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;
namespace PSUTInternship.Student
{
    public partial class StudentProgress : PortalPage
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            try
            {
                string uid = PortalRepository.UserId;
                var tasks = await PortalRepository.Collection(PortalRepository.Query("tasks", "studentId", uid));
                var submissions = await PortalRepository.Collection(PortalRepository.Query("submissions", "studentId", uid));
                var feedback = await PortalRepository.Collection(PortalRepository.Query("taskFeedback", "studentId", uid));
                var placement = await PortalRepository.PlacementForStudent(uid);
                var completion = await PortalRepository.CompletionForStudent(uid);
                lblTotalTasks.Text = tasks.Count.ToString(); lblSubmittedTasks.Text = submissions.Count.ToString();
                lblRevisions.Text = tasks.Values.Count(x => (string)x["status"] == "Revision Requested").ToString();
                rptTasks.DataSource = tasks.Select(x => new { Title = (string)x.Value["title"], Status = (string)x.Value["status"], SubmissionDate = submissions.Values.Where(r => (string)r["taskId"] == x.Key).Select(r => (string)r["updatedAt"]).OrderByDescending(d => d).FirstOrDefault() ?? "—" }).ToList();
                rptTasks.DataBind(); lblNoTasks.Visible = tasks.Count == 0;
                rptEvaluations.DataSource = feedback.Select(x => new { Title = (string)x.Value["title"], Comments = (string)x.Value["comments"] + " (" + (string)x.Value["score"] + " / " + (string)x.Value["maximumScore"] + ")" }).ToList();
                rptEvaluations.DataBind(); lblNoEvaluations.Visible = feedback.Count == 0;
                decimal approved = (decimal?)placement?["approvedHours"] ?? 0, required = (decimal?)placement?["requiredHours"] ?? 0;
                lblApprovedHours.Text = approved.ToString(CultureInfo.InvariantCulture);
                lblHoursProgress.Text = approved + " / " + required + " hours";
                decimal percent = required > 0 ? Math.Min(100, approved * 100 / required) : 0;
                lblPercentage.Text = percent.ToString("0.0", CultureInfo.InvariantCulture) + "%";
                progressFill.Style["width"] = percent.ToString(CultureInfo.InvariantCulture) + "%";
                bool completed = DatabaseSchema.ReportApproved(completion);
                lblReportStatus.Text = completed ? "Approved by coordinator" : "Awaiting coordinator approval";
                lnkReport.Visible = completed; lnkReport.NavigateUrl = "~/CompletionReport.aspx";
                rptInternshipEvaluations.DataSource = completed ? new[] { new { Title = "Final result", Comments = "Final grade: " + (string)completion["finalGrade"] } } : new object[0];
                rptInternshipEvaluations.DataBind(); lblNoInternshipEvaluations.Visible = !completed;
            }
            catch (Exception ex) { lblReportStatus.Text = Server.HtmlEncode(ex.Message); }
        }
    }
}

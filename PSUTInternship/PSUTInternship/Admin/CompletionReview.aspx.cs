using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI.WebControls;
using PSUTInternship.Shared;
namespace PSUTInternship.Admin
{
    public partial class CompletionReview : PortalPage
    {
        protected async void Page_Load(object sender,EventArgs e){if(!IsPostBack)await LoadReviews();}
        protected async void applyFilters_Click(object sender, EventArgs e)
        {
            await LoadReviews();
        }
        private async Task LoadReviews()
        {
            try
            {
                var queue=await PortalRepository.Collection("coordinatorReviewQueue");
                var rows=queue.Select(x=>new {Id=x.Key,StudentId=(string)x.Value["studentId"],Name=(string)x.Value["combinedReport"]?["studentName"],StudentNumber=(string)x.Value["combinedReport"]?["studentNumber"]??"Not available",Ready=Ready(x.Value),TasksReady=TasksReady(x.Value)?"Met":"Pending",
                    Hours=(string)x.Value["combinedReport"]?["approvedHours"]+" / "+(string)x.Value["combinedReport"]?["requiredHours"],
                    CompanyScore=(string)x.Value["combinedReport"]?["companyEvaluation"]?["overallScore"]+" / "+(string)x.Value["combinedReport"]?["companyEvaluation"]?["totalMaximum"],
                    AcademicResult=CoordinatorData.AcademicResult(x.Value["combinedReport"]?["academicEvaluation"] as Newtonsoft.Json.Linq.JObject),
                    CompanyComments=(string)x.Value["combinedReport"]?["companyEvaluation"]?["comments"],AcademicComments=(string)x.Value["combinedReport"]?["academicEvaluation"]?["comments"],
                    Recommendation=CoordinatorData.AcademicResult(x.Value["combinedReport"]?["academicEvaluation"] as Newtonsoft.Json.Linq.JObject),Status=(string)x.Value["status"],Placement=(string)x.Value["combinedReport"]?["company"]??"Not available",
                    Percent=Percent(x.Value), HoursReady=Percent(x.Value)>=100?"Met":"Pending",
                    CompanyReady=(string)x.Value["combinedReport"]?["companyEvaluation"]?["status"]??"Pending",AcademicReady=(string)x.Value["combinedReport"]?["academicEvaluation"]?["status"]??"Pending"}).ToList();
                string search = (reviewSearch.Text ?? "").Trim();
                string filter = reviewFilter.SelectedValue;
                var filtered = rows.Where(x =>
                    (search.Length == 0 || new[] { x.Name, x.StudentNumber, x.Placement }.Any(value =>
                        (value ?? "").IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0)) &&
                    (filter == "All" ||
                     (filter == "Approved" && x.Status == "approved") ||
                     (filter == "Ready" && x.Status != "approved" && x.Ready) ||
                     (filter == "Pending" && x.Status != "approved" && !x.Ready))).ToList();
                reviews.DataSource = filtered;
                reviews.DataBind();
                resultCount.Text = filtered.Count + " of " + rows.Count + " reviews";
                empty.Visible = filtered.Count == 0;
                empty.Text = rows.Count == 0 ? "No evaluations have been forwarded for review yet." : "No reviews match your search and filters. Try another name or reset the filters.";
            }
            catch(Exception ex){notice.Text=Server.HtmlEncode(ex.Message);}
        }
        private static bool TasksReady(Newtonsoft.Json.Linq.JObject row) {
            return ((int?)row["combinedReport"]?["completedTasks"]??0)>=((int?)row["combinedReport"]?["totalTasks"]??0);
        }
        private static bool Ready(Newtonsoft.Json.Linq.JObject row) {
            var report=row["combinedReport"];
            return Percent(row)>=100 && TasksReady(row) && (string)report?["companyEvaluation"]?["status"]=="submitted"
                && (string)report?["academicEvaluation"]?["status"]=="submitted" && (string)report?["academicEvaluation"]?["recommendation"]=="Pass";
        }
        private static decimal Percent(Newtonsoft.Json.Linq.JObject row) {decimal approved=(decimal?)row["combinedReport"]?["approvedHours"]??0,required=(decimal?)row["combinedReport"]?["requiredHours"]??0;return required>0?Math.Min(100,Math.Round(approved*100/required,1)):0;}
        protected async void reviews_ItemCommand(object sender,RepeaterCommandEventArgs e)
        {
            if(e.CommandName!="Approve")return;
            try{await CompletionWorkflow.Approve(Convert.ToString(e.CommandArgument));notice.Text="Certificate created. The student can download it from My Progress & Evaluation.";await LoadReviews();}
            catch(Exception ex){notice.Text=Server.HtmlEncode(ex.Message);}
        }
    }
}

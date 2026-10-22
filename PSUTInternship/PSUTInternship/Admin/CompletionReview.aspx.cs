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
        private async Task LoadReviews()
        {
            try
            {
                var queue=await PortalRepository.Collection("coordinatorReviewQueue");
                reviews.DataSource=queue.Select(x=>new {Id=x.Key,StudentId=(string)x.Value["studentId"],Name=(string)x.Value["combinedReport"]?["studentName"],
                    Hours=(string)x.Value["combinedReport"]?["approvedHours"]+" / "+(string)x.Value["combinedReport"]?["requiredHours"],
                    CompanyScore=(string)x.Value["combinedReport"]?["companyEvaluation"]?["overallScore"]+" / "+(string)x.Value["combinedReport"]?["companyEvaluation"]?["totalMaximum"],
                    AcademicScore=(string)x.Value["combinedReport"]?["academicEvaluation"]?["overallScore"],
                    CompanyComments=(string)x.Value["combinedReport"]?["companyEvaluation"]?["comments"],AcademicComments=(string)x.Value["combinedReport"]?["academicEvaluation"]?["comments"],
                    Recommendation=(string)x.Value["combinedReport"]?["academicEvaluation"]?["recommendation"],Status=(string)x.Value["status"]}).ToList();
                reviews.DataBind();empty.Visible=queue.Count==0;
            }
            catch(Exception ex){notice.Text=Server.HtmlEncode(ex.Message);}
        }
        protected async void reviews_ItemCommand(object sender,RepeaterCommandEventArgs e)
        {
            if(e.CommandName!="Approve")return;
            try{await CompletionWorkflow.Approve(Convert.ToString(e.CommandArgument));notice.Text="Completion approved. The student can download the official report.";await LoadReviews();}
            catch(Exception ex){notice.Text=Server.HtmlEncode(ex.Message);}
        }
    }
}

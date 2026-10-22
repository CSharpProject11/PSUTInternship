using System;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI.WebControls;
using PSUTInternship.Shared;
namespace PSUTInternship
{
    public partial class TrainingHours : PortalPage
    {
        protected bool CanReview { get { return PortalRoles.Normalize(Convert.ToString(Session["userRole"])) == "company"; } }
        protected async void Page_Load(object sender, EventArgs e)
        {
            entry.Visible = PortalRoles.Normalize(Convert.ToString(Session["userRole"])) == "student";
            if (!IsPostBack) await LoadHours();
        }
        private async Task LoadHours()
        {
            try
            {
                var rows = await PortalRepository.Collection("trainingHours");
                records.DataSource = rows.Select(x => new { Id=x.Key, Student=(string)x.Value["studentId"], Date=(string)x.Value["date"], Hours=(decimal?)x.Value["hours"], Description=(string)x.Value["description"], Status=(string)x.Value["status"] }).ToList(); records.DataBind();
            }
            catch (Exception ex) { notice.Text=Server.HtmlEncode(ex.Message); }
        }
        protected async void submit_Click(object sender, EventArgs e)
        {
            try
            {
                if (!entry.Visible) throw new InvalidOperationException("Only students submit hours.");
                DateTime date; decimal quantity;
                if (!DateTime.TryParse(day.Text,out date)||!decimal.TryParse(hours.Text,NumberStyles.Number,CultureInfo.InvariantCulture,out quantity)) throw new ArgumentException("Enter a valid date and number of hours.");
                await TrainingHoursWorkflow.Submit(date,quantity,description.Text); notice.Text="Hours submitted for approval."; await LoadHours();
            }
            catch(Exception ex){notice.Text=Server.HtmlEncode(ex.Message);}
        }
        protected async void records_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!CanReview || (e.CommandName!="ApproveHours" && e.CommandName!="RejectHours"))return;
            try { await TrainingHoursWorkflow.Review(Convert.ToString(e.CommandArgument),e.CommandName=="ApproveHours");notice.Text="Training hours reviewed.";await LoadHours(); }
            catch(Exception ex){notice.Text=Server.HtmlEncode(ex.Message);}
        }
    }
}

using System;
using System.Globalization;
using PSUTInternship.Shared;
namespace PSUTInternship.Company
{
    public partial class EditTask : PortalPage
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            try
            {
                var task = await PortalRepository.CompanyTask(Request.QueryString["id"]);
                TaskDetails.Text = "<h1>" + Server.HtmlEncode((string)task["title"]) + "</h1><p>Maximum score: " + Server.HtmlEncode((string)task["maximumScore"]) + "</p><p>" + Server.HtmlEncode((string)task["evaluationCriteria"]) + "</p>";
                maximumInput.Text = (string)task["maximumScore"] ?? "";
                Feedbackinput.Value = (string)task["feedback"] ?? "";
                scoreInput.Text = (string)task["score"] ?? "";
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }
        protected async void Save_Click(object sender, EventArgs e)
        {
            try
            {
                if (stateDrop.SelectedIndex == 0) throw new ArgumentException("Select a review status.");
                decimal score;
                decimal? grade = decimal.TryParse(scoreInput.Text, NumberStyles.Number, CultureInfo.InvariantCulture, out score) ? (decimal?)score : null;
                decimal maximum;
                if (!decimal.TryParse(maximumInput.Text, NumberStyles.Number, CultureInfo.InvariantCulture, out maximum) || maximum <= 0) throw new ArgumentException("Enter a positive task maximum score.");
                await TaskWorkflow.ConfigureMaximum(Request.QueryString["id"], maximum);
                await TaskWorkflow.Review(Request.QueryString["id"], stateDrop.SelectedValue == "Resolve" ? "Revision Requested" : "Reviewed", Feedbackinput.Value, grade);
                ShowMessage("Review saved. The student and academic supervisor can now see your feedback.");
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }
        protected void Cansale_Click(object sender, EventArgs e) { Response.Redirect("Tasks.aspx", false); Context.ApplicationInstance.CompleteRequest(); }
        private void ShowMessage(string value) { subject.Text = Server.HtmlEncode(value); }
    }
}

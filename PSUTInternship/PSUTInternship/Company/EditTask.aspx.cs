using System;
using System.Globalization;
using PSUTInternship.Shared;
namespace PSUTInternship.Company {
    public partial class EditTask : PortalPage {
        protected async void Page_Load(object sender, EventArgs e) {
            if (IsPostBack) return;
            try {
                var task = await PortalRepository.CompanyTask(Request.QueryString["id"]);
                TaskDetails.Text = "<h2>" + Server.HtmlEncode((string)task["title"]) + "</h2><p>" + Server.HtmlEncode((string)task["evaluationCriteria"]) + "</p>";
                Feedbackinput.Value = (string)task["feedback"] ?? "";
                var item = stateDrop.Items.FindByValue((string)task["status"]);
                if (item != null) item.Selected = true;
                NewDeadline.Text = (string)task["dueDate"];
                DeadlinePanel.Visible = stateDrop.SelectedValue == "Revision Requested";
            } catch (Exception ex) { subject.Text = Server.HtmlEncode(ex.Message); Save.Enabled = false; }
        }
        protected void State_Changed(object sender, EventArgs e) { DeadlinePanel.Visible = stateDrop.SelectedValue == "Revision Requested"; }
        protected async void Save_Click(object sender, EventArgs e) {
            StateError.Text = stateDrop.SelectedIndex == 0 ? "Select Resolve or Complete." : "";
            FeedbackError.Text = TaskWorkflow.ValidText(Feedbackinput.Value, 1, 3000) ? "" : "Enter feedback of 1–3,000 characters.";
            DateTime deadline;
            bool valid = DateTime.TryParseExact(NewDeadline.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out deadline) && deadline.Date > TaskWorkflow.Today;
            DeadlineError.Text = stateDrop.SelectedValue == "Revision Requested" && !valid ? "Choose a future resubmission deadline." : "";
            if (StateError.Text.Length + FeedbackError.Text.Length + DeadlineError.Text.Length > 0) return;
            try {
                await TaskWorkflow.Review(Request.QueryString["id"], stateDrop.SelectedValue, Feedbackinput.Value, null, stateDrop.SelectedValue == "Revision Requested" ? (DateTime?)deadline : null);
                subject.Text = "Review saved. The student can see the status, deadline and feedback.";
                ClientScript.RegisterStartupScript(GetType(), "reviewSaved", "if(window.parent!==window){window.parent.location.reload();}", true);
            } catch (Exception ex) { subject.Text = Server.HtmlEncode(ex.Message); }
        }
        protected void Cansale_Click(object sender, EventArgs e) {
            ClientScript.RegisterStartupScript(GetType(), "cancelReview", "if(window.parent!==window){window.parent.document.getElementById('taskReviewDialog').close();}else{location.href='Tasks.aspx';}",true);
        }
    }
}
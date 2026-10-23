using System;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI.WebControls;
using PSUTInternship.Shared;
namespace PSUTInternship.Company
{
    public partial class CreateTask : PortalPage
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            try {
                Opportunity.Items.Add(new ListItem("Select opportunity", ""));
                var placements = await PortalRepository.Collection("internships");
                var openings = await PortalRepository.Collection("opportunities");
                foreach (var group in placements.Values.Where(x => (string)x["status"] == "active" && (string)x["companyId"] == PortalRepository.CompanyId)
                    .Where(x => !string.IsNullOrWhiteSpace((string)x["opportunityId"])).GroupBy(x => (string)x["opportunityId"]))
                    Opportunity.Items.Add(new ListItem(((openings.ContainsKey(group.Key) ? (string)openings[group.Key]["title"] : (string)group.First()["opportunityTitle"]) ?? "Training opportunity"), group.Key));
                var selected = Opportunity.Items.FindByValue(Request.QueryString["opportunityId"] ?? "");
                if (selected != null) { Opportunity.SelectedValue = selected.Value; await LoadTrainees(); }
            } catch (Exception ex) { PageMessage.Text = Server.HtmlEncode(ex.Message); }
        }
        private async Task LoadTrainees() {
            cblStudents.Items.Clear();
            var placements = await PortalRepository.Collection("internships");
            foreach (var item in placements.Values.Where(x => (string)x["status"] == "active" && (string)x["companyId"] == PortalRepository.CompanyId && (string)x["opportunityId"] == Opportunity.SelectedValue).GroupBy(x => (string)x["studentId"])) {
                var student = await PortalRepository.Get<Newtonsoft.Json.Linq.JObject>("students/" + PortalRepository.Key(item.Key));
                cblStudents.Items.Add(new ListItem(DatabaseSchema.FirstText(student, "fullName"), item.Key));
            }
        }
        protected async void Opportunity_Changed(object sender, EventArgs e) {
            try { await LoadTrainees(); } catch (Exception ex) { PageMessage.Text = Server.HtmlEncode(ex.Message); }
        }
        protected void txtassingeto_TextChanged(object sender, EventArgs e) { }
        protected void Cancel_Click(object sender, EventArgs e) { Response.Redirect("Tasks.aspx", false); Context.ApplicationInstance.CompleteRequest(); }
        protected async void CreateTask_Click(object sender, EventArgs e)
        {
            DateTime deadline;
            ErrorTitel.Text = TaskWorkflow.ValidText(Titelinput.Value, 3, 150) ? "" : "Enter a title of 3–150 characters without control characters.";
            ErorrDescreption.Text = TaskWorkflow.ValidText(Descriptioniput.Value, 10, 5000) ? "" : "Enter a description of 10–5,000 characters.";
            ErorrEvaluation.Text = TaskWorkflow.ValidText(EvaluationCriteriainput.Value, 5, 3000) ? "" : "Enter criteria of 5–3,000 characters.";
            OpportunityError.Text = string.IsNullOrEmpty(Opportunity.SelectedValue) ? "Select a training opportunity." : "";
            var ids = cblStudents.Items.Cast<ListItem>().Where(x => x.Selected).Select(x => x.Value).ToList();
            ErorrAssign.Text = ids.Count == 0 ? "Select at least one trainee from this opportunity." : "";
            ErorrDeadline.Text = DateTime.TryParseExact(Deadlineinput.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out deadline) && deadline.Date > TaskWorkflow.Today ? "" : "Choose a future deadline.";
            if (new[] { ErrorTitel, ErorrDescreption, ErorrEvaluation, OpportunityError, ErorrAssign, ErorrDeadline }.Any(x => x.Text.Length > 0)) return;
            try {
                await TaskWorkflow.Create(Titelinput.Value, Descriptioniput.Value, EvaluationCriteriainput.Value, prorityinput.SelectedValue, deadline, ids, Opportunity.SelectedValue);
                Response.Redirect("Tasks.aspx", false); Context.ApplicationInstance.CompleteRequest();
            } catch (Exception ex) { PageMessage.Text = Server.HtmlEncode(ex.Message); }
        }
    }
}

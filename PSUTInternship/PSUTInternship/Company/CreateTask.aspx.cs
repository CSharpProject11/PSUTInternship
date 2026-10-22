using System;
using System.Globalization;
using System.Linq;
using System.Web.UI.WebControls;
using PSUTInternship.Shared;
namespace PSUTInternship.Company
{
    public partial class CreateTask : PortalPage
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            try
            {
                var placements = await PortalRepository.Collection("internships");
                foreach (var p in placements.Where(p => (string)p.Value["status"] == "active"))
                    cblStudents.Items.Add(new ListItem((string)p.Value["studentName"] ?? (string)p.Value["studentId"], (string)p.Value["studentId"]));
            }
            catch (Exception ex) { ErorrAssign.Text = Server.HtmlEncode(ex.Message); }
        }
        protected void txtassingeto_TextChanged(object sender, EventArgs e) { }
        protected void Cancel_Click(object sender, EventArgs e) { Response.Redirect("Tasks.aspx", false); Context.ApplicationInstance.CompleteRequest(); }
        protected async void CreateTask_Click(object sender, EventArgs e)
        {
            try
            {
                decimal maximum;
                DateTime deadline;
                if (!decimal.TryParse(Scoreinput.Value, NumberStyles.Number, CultureInfo.InvariantCulture, out maximum) || !DateTime.TryParse(Deadlineinput.Text, out deadline))
                    throw new ArgumentException("Enter a valid maximum score and deadline.");
                await TaskWorkflow.Create(Titelinput.Value, Descriptioniput.Value, EvaluationCriteriainput.Value, prorityinput.SelectedValue,
                    maximum, deadline, cblStudents.Items.Cast<ListItem>().Where(x => x.Selected).Select(x => x.Value));
                Response.Redirect("Tasks.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex) { ErorrAssign.Text = Server.HtmlEncode(ex.Message); }
        }
    }
}

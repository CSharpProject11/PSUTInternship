using System;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using PSUTInternship.Shared;
namespace PSUTInternship.Company
{
    public partial class Tasks : PortalPage
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            try
            {
                var tasks = await PortalRepository.Collection("tasks");
                string archive = Request.Form["archive"];
                if (Request.HttpMethod == "POST" && !string.IsNullOrWhiteSpace(archive))
                {
                    var task = await PortalRepository.CompanyTask(archive);
                    await PortalRepository.Patch("tasks/" + archive, new { active = !((bool?)task["active"] ?? true) });
                    Response.Redirect("Tasks.aspx", false); Context.ApplicationInstance.CompleteRequest(); return;
                }
                TaskTablebody.Controls.Clear();
                countTotal.Text = tasks.Count.ToString();
                countPending.Text = tasks.Values.Count(x => (string)x["status"] == "Submitted").ToString();
                countProgress.Text = tasks.Values.Count(x => (string)x["status"] != "Reviewed" && (string)x["status"] != "Submitted").ToString();
                countReviewed.Text = tasks.Values.Count(x => (string)x["status"] == "Reviewed").ToString();
                foreach (var p in tasks)
                {
                    var t = p.Value;
                    string state = DatabaseSchema.WorkflowStatus((string)t["status"]) ?? "Assigned";
                    if (DropDownList1.SelectedIndex > 0 && !string.Equals(DropDownList1.SelectedValue, state, StringComparison.OrdinalIgnoreCase)) continue;
                    string title = (string)t["title"] ?? "";
                    if (search.Text.Trim().Length > 0 && (title + " " + (string)t["studentId"]).IndexOf(search.Text.Trim(), StringComparison.OrdinalIgnoreCase) < 0) continue;
                    var row = new HtmlTableRow();
                    foreach (string value in new[] { title, (string)t["studentId"], (string)t["dueDate"], CreatedDate((string)t["createdAt"]), (string)t["priority"], state == "Reviewed" ? "Complete" : state == "Revision Requested" ? "Resolve" : state })
                        row.Cells.Add(new HtmlTableCell { InnerText = value ?? "" });
                    var action = new HtmlTableCell();
                    action.Controls.Add(new HtmlAnchor { HRef = "ViewTask.aspx?id=" + HttpUtility.UrlEncode(p.Key), InnerText = "View submission" });
                    action.Controls.Add(new LiteralControl(" | "));
                    action.Controls.Add(new HtmlAnchor { HRef = "EditTask.aspx?id=" + HttpUtility.UrlEncode(p.Key), InnerText = "Review" });
                    action.Controls.Add(new LiteralControl(" <button type='submit' name='archive' value='" + HttpUtility.HtmlAttributeEncode(p.Key) + "'>" + (((bool?)t["active"] ?? true) ? "Archive" : "Restore") + "</button>"));
                    row.Cells.Add(action); TaskTablebody.Controls.Add(row);
                }
                if (TaskTablebody.Controls.Count == 0) TaskTablebody.Controls.Add(new LiteralControl("<tr><td colspan='7'>No tasks match your filters.</td></tr>"));
            }
            catch (Exception ex) { TaskTablebody.Controls.Add(new LiteralControl("<tr><td colspan='7'>" + Server.HtmlEncode(ex.Message) + "</td></tr>")); }
        }
        private static string CreatedDate(string value) {
            DateTimeOffset date;
            return DateTimeOffset.TryParse(value, out date) ? TimeZoneInfo.ConvertTime(date, TimeZoneInfo.FindSystemTimeZoneById("Jordan Standard Time")).ToString("dddd, dd-MM-yyyy") : "Not recorded";
        }
        protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e) { }
        protected void Create_Click(object sender, EventArgs e) { Response.Redirect("CreateTask.aspx", false); Context.ApplicationInstance.CompleteRequest(); }
        protected void search_TextChanged(object sender, EventArgs e) { }
    }
}

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
                foreach (var p in tasks)
                {
                    var t = p.Value;
                    string state = (string)t["status"] ?? "Assigned";
                    if (DropDownList1.SelectedIndex > 0 && !string.Equals(DropDownList1.SelectedValue, state, StringComparison.OrdinalIgnoreCase)) continue;
                    string title = (string)t["title"] ?? "";
                    if (search.Text.Trim().Length > 0 && title.IndexOf(search.Text.Trim(), StringComparison.OrdinalIgnoreCase) < 0) continue;
                    var row = new HtmlTableRow();
                    foreach (string value in new[] { title, (string)t["studentId"], (string)t["dueDate"], (string)t["priority"], state,
                        Convert.ToString(t["score"]) + " / " + Convert.ToString(t["maximumScore"]) })
                        row.Cells.Add(new HtmlTableCell { InnerText = value ?? "" });
                    var action = new HtmlTableCell();
                    action.Controls.Add(new HtmlAnchor { HRef = "ViewTask.aspx?id=" + HttpUtility.UrlEncode(p.Key), InnerText = "View submission" });
                    action.Controls.Add(new LiteralControl(" | "));
                    action.Controls.Add(new HtmlAnchor { HRef = "EditTask.aspx?id=" + HttpUtility.UrlEncode(p.Key), InnerText = "Review" });
                    action.Controls.Add(new LiteralControl(" <button type='submit' name='archive' value='" + HttpUtility.HtmlAttributeEncode(p.Key) + "'>" + (((bool?)t["active"] ?? true) ? "Archive" : "Restore") + "</button>"));
                    row.Cells.Add(action); TaskTablebody.Controls.Add(row);
                }
            }
            catch (Exception ex) { TaskTablebody.Controls.Add(new LiteralControl("<tr><td colspan='7'>" + Server.HtmlEncode(ex.Message) + "</td></tr>")); }
        }
        protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e) { }
        protected void Create_Click(object sender, EventArgs e) { Response.Redirect("CreateTask.aspx", false); Context.ApplicationInstance.CompleteRequest(); }
        protected void search_TextChanged(object sender, EventArgs e) { }
    }
}

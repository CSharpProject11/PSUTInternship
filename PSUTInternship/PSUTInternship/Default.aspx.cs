using System;
using System.Text;
using System.Web;
using System.Web.UI;
using Newtonsoft.Json.Linq;

namespace PSUTInternship
{
    public partial class _Default : PSUTInternship.Shared.PortalPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] != null && Session["idToken"] != null)
            {
                string dashboard = Shared.PortalRoles.Dashboard(Convert.ToString(Session["userRole"]));
                HomeLink6.NavigateUrl = dashboard;
                HomeLink6.Text = "My workspace <span aria-hidden=\"true\">↗</span>";
                HomeLink22.NavigateUrl = dashboard;
                HomeLink22.Text = "Return to my workspace";
            }
            RegisterAsyncTask(new PageAsyncTask(LoadOpportunitiesAsync));
        }

        private async System.Threading.Tasks.Task LoadOpportunitiesAsync()
        {
            var rows = new JArray();
            bool unavailable = false;
            try { rows = await PublicData.LoadOpportunityPreviewsAsync(); }
            catch (Exception ex)
            {
                unavailable = true;
                System.Diagnostics.Trace.TraceError("Homepage opportunity previews: {0}", ex.GetType().Name);
            }

            var html = new StringBuilder();
            string[] themes = { "sky", "navy", "pale", "navy", "sky", "pale" };
            for (int i = 0; i < 6; i++)
            {
                var row = i < rows.Count ? rows[i] : null;
                html.Append("<article class=\"fact-card mosaic-card ").Append(themes[i]);
                if (row == null) html.Append(" coming-soon");
                html.Append("\"><span class=\"fact-mark\" aria-hidden=\"true\">").Append(i + 1).Append("</span><div>");
                if (row == null)
                {
                    html.Append("<h3>Coming soon.</h3><p>").Append(unavailable
                        ? "Live previews are temporarily unavailable. Please try again later."
                        : "More internship opportunities will appear here when available.");
                    html.Append("</p></div><span class=\"opportunity-card-note\">").Append(unavailable ? "Previews unavailable" : "Watch this space").Append("</span>");
                }
                else
                {
                    html.Append("<p class=\"opportunity-card-company\">").Append(Encode(row, "company"));
                    html.Append("</p><h3>").Append(Encode(row, "title")).Append("</h3><p>");
                    html.Append(Encode(row, "major", "Open to relevant specializations"));
                    html.Append("</p><p class=\"opportunity-card-meta\">").Append(Encode(row, "seats"));
                    html.Append(" seats · ").Append(Encode(row, "deadline", "Deadline to be confirmed"));
                    html.Append("</p></div><a href=\"").Append(HttpUtility.HtmlAttributeEncode(ResolveUrl("~/Login.aspx")));
                    html.Append("\">Sign in for details &amp; apply <span aria-hidden=\"true\">↗</span></a>");
                }
                html.Append("</article>");
            }
            publicCards.InnerHtml = html.ToString();
            publicCards.Attributes["aria-busy"] = "false";
            publicCards.Attributes["data-server-rendered"] = "true";
            searchStatus.InnerText = unavailable ? "Live opportunity previews could not be loaded. Please try again later."
                : rows.Count + (rows.Count == 1 ? " opportunity available" : " opportunities available") + (rows.Count < 6 ? " · More coming soon" : "");
        }

        private static string Encode(JToken row, string field, string fallback = "")
        {
            string value = (string)row[field];
            return HttpUtility.HtmlEncode(string.IsNullOrWhiteSpace(value) ? fallback : value);
        }
    }
}

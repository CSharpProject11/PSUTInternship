using PSUTInternship.Shared;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using System.Net.Http;
using System.Threading.Tasks;
using PSUTInternship.Models;

namespace PSUTInternship.Student
{
    public partial class Opportunities : PSUTInternship.Shared.PortalPage
    {

        private static readonly string FirebaseUrl =
            PSUTInternship.Shared.FirebaseConfig.DatabaseUrl.TrimEnd('/') + "/";

        private static readonly HttpClient Client = PSUTInternship.Shared.FirebaseConfig.CreateClient();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["idToken"] == null || !string.Equals(Convert.ToString(Session["userRole"]), "student", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(loadOpportunities));
            }
        }

        public async Task loadOpportunities()
        {
            var records = (await PortalRepository.Collection("opportunities"))
                .Where(x => x.Value != null).ToDictionary(x => x.Key, x => x.Value.ToObject<Opportunity>());

            foreach (var record in records)
            {
                if (record.Value != null) record.Value.Id = record.Key;
            }

            var profile = await PortalRepository.Get<JObject>("students/" + PortalRepository.ProfileId);
            var eligible = records.Values.Where(x => x != null && OpportunityEligibility.Matches(x, profile)).ToList();
            await OpportunityPresentation.Populate(eligible);
            OpportunitiesRepeater.DataSource = eligible;
            OpportunitiesRepeater.DataBind();
            EmptyMessage.Visible = eligible.Count == 0;
        }
        protected string OpportunityImage(object value) {
            Uri image; string text = Convert.ToString(value);
            return Uri.TryCreate(text,UriKind.Absolute,out image) && image.Scheme == "https" ? image.AbsoluteUri : ResolveUrl("~/Assets/technology.jpg");
        }
        protected void OpportunitiesRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ViewApply")
            {
                string id = Convert.ToString(e.CommandArgument);

                Response.Redirect(
                    "Apply.aspx?id=" + HttpUtility.UrlEncode(id));
            }
        }
    }
}






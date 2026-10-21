using Newtonsoft.Json;
using PSUTInternship.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PSUTInternship.Student
{
    public partial class Apply : System.Web.UI.Page
    {
        private const string FirebaseUrl =
            "https://csharp-e078c-default-rtdb.firebaseio.com/";

        private static readonly HttpClient Client =
            new HttpClient();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(
                    new PageAsyncTask(LoadOpportunity));
            }
        }
        private async Task LoadOpportunity()
        {
            string id = Request.QueryString["id"];

            if (string.IsNullOrWhiteSpace(id) ||
                id.IndexOfAny(
                    new[] { '.', '#', '$', '[', ']', '/', '\\' }) >= 0)
            {
                MessageLabel.Text = "Invalid opportunity.";
                return;
            }

            try
            {
                string url = FirebaseUrl
                    + "opportunities/"
                    + Uri.EscapeDataString(id)
                    + ".json";

                string json = await Client.GetStringAsync(url);

                Opportunity opportunity =
                    JsonConvert.DeserializeObject<Opportunity>(json);

                if (opportunity == null)
                {
                    MessageLabel.Text = "Opportunity not found.";
                    return;
                }

                opportunity.Id = id;

                OpportunityDetails.DataSource =
                    new[] { opportunity };

                OpportunityDetails.DataBind();
                DetailsPanel.Visible = true;
            }
            catch (HttpRequestException)
            {
                MessageLabel.Text =
                    "Unable to load this opportunity. Please try again.";
            }
            catch (JsonException)
            {
                MessageLabel.Text =
                    "The opportunity details could not be read.";
            }
        }
    }
}
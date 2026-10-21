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
    public partial class Opportunities : System.Web.UI.Page
    {
        private const string FirebaseUrl =
            "https://csharp-e078c-default-rtdb.firebaseio.com/";

        private static readonly HttpClient Client = new HttpClient();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(loadOpportunities));
            }
        }

        public async Task loadOpportunities()
        {
            string json = await Client.GetStringAsync(
                FirebaseUrl + "opportunities.json");

            var records = JsonConvert.DeserializeObject<Dictionary<string, Opportunity>>(json)
                ?? new Dictionary<string, Opportunity>();

            foreach (var record in records)
            {
                record.Value.Id = record.Key;
            }

            OpportunitiesRepeater.DataSource = records.Values.ToList();
            OpportunitiesRepeater.DataBind();
            EmptyMessage.Visible = records.Count == 0;
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






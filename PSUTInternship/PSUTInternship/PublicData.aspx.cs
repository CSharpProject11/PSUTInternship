using System;
using System.Linq;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;
namespace PSUTInternship
{
    public class PublicData:PortalPage
    {
        private static readonly HttpClient PublicListingsClient = new HttpClient { Timeout = TimeSpan.FromSeconds(25) };

        private static bool IsOpen(JObject item)
        {
            DateTime deadline;
            return DatabaseSchema.IsOpen((string)item["status"]) && (!DateTime.TryParse((string)item["deadline"], out deadline) || deadline.Date >= DateTime.Today);
        }
        internal static async System.Threading.Tasks.Task<JArray> LoadOpportunityPreviewsAsync()
        {
            // Use the public transport for every visitor. The workspace transport adds
            // company ownership filters and session credentials to database requests.
            Dictionary<string, JObject> records;
            using (var response = await PublicListingsClient.GetAsync(FirebaseConfig.DatabaseUrl + "opportunities.json"))
            {
                response.EnsureSuccessStatusCode();
                records = JsonConvert.DeserializeObject<Dictionary<string, JObject>>(await response.Content.ReadAsStringAsync())
                    ?? new Dictionary<string, JObject>();
            }
            return JArray.FromObject(records.Where(x=>x.Value != null && IsOpen(x.Value))
                .OrderBy(x=>(string)x.Value["deadline"]).ThenBy(x=>x.Key).Take(6).Select(x=> {
                return new {id=x.Key,title=(string)x.Value["title"],company=(string)x.Value["companyName"] ?? "Company",major=(string)x.Value["specialization"],seats=(int?)x.Value["availableSeats"]??0,deadline=(string)x.Value["deadline"]};
            }));
        }
        protected async void Page_Load(object sender,EventArgs e)
        {
            Response.ContentType="application/json";Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            try
            {
                if(Request.HttpMethod=="GET")
                {
                    if(Request.QueryString["action"]=="contactToken") { Response.Write(JsonConvert.SerializeObject(new {token=CsrfToken}));return; }
                    Response.Write(await LoadOpportunityPreviewsAsync());
                    return;
                }
                if(Request.HttpMethod!="POST"||Request.QueryString["action"]!="contact")throw new ArgumentException("Unsupported request.");
                if(Session["lastContactAt"] is DateTime && (DateTime)Session["lastContactAt"]>DateTime.UtcNow.AddSeconds(-30))throw new ArgumentException("Please wait before sending another message.");
                JObject data;using(var reader=new StreamReader(Request.InputStream))data=JObject.Parse(await reader.ReadToEndAsync());
                foreach(string field in new[]{"name","email","subject","message"})if(string.IsNullOrWhiteSpace((string)data[field])||((string)data[field]).Length>2000)throw new ArgumentException("Complete every field using at most 2,000 characters.");
                var email=new System.Net.Mail.MailAddress((string)data["email"]);
                var payload=new {name=(string)data["name"],email=email.Address,subject=(string)data["subject"],message=(string)data["message"],status="new",createdAt=DateTime.UtcNow.ToString("o")};
                using(var content=new StringContent(JsonConvert.SerializeObject(payload),Encoding.UTF8,"application/json"))
                using(var response=await FirebaseConfig.Client.PostAsync(FirebaseConfig.DatabaseUrl+"contactMessages.json",content))response.EnsureSuccessStatusCode();
                Session["lastContactAt"]=DateTime.UtcNow;Response.Write("{\"saved\":true}");
            }
            catch(Exception ex){Response.StatusCode=ex is ArgumentException?400:503;Response.TrySkipIisCustomErrors=true;Response.Write(JsonConvert.SerializeObject(new {error=ex is ArgumentException?ex.Message:"Unable to access the portal data. Please try again."}));}
        }
    }
}

using System;
using System.Linq;
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
        private static bool IsOpen(JObject item)
        {
            DateTime deadline;
            return DatabaseSchema.IsOpen((string)item["status"]) && (!DateTime.TryParse((string)item["deadline"], out deadline) || deadline.Date >= DateTime.Today);
        }
        protected async void Page_Load(object sender,EventArgs e)
        {
            Response.ContentType="application/json";Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            try
            {
                if(Request.HttpMethod=="GET")
                {
                    if(Request.QueryString["action"]=="contactToken") { Response.Write(JsonConvert.SerializeObject(new {token=CsrfToken}));return; }
                    string json=await FirebaseConfig.Client.GetStringAsync(FirebaseConfig.DatabaseUrl+"publicOpportunities.json");
                    var records=JsonConvert.DeserializeObject<System.Collections.Generic.Dictionary<string,JObject>>(json)??new System.Collections.Generic.Dictionary<string,JObject>();
                    Response.Write(JsonConvert.SerializeObject(records.Where(x=>IsOpen(x.Value)).Select(x=>new {id=x.Key,title=(string)x.Value["title"],company=(string)x.Value["companyName"],major=(string)x.Value["specialization"],seats=(int?)x.Value["availableSeats"]??0,deadline=(string)x.Value["deadline"]})));
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
            catch(Exception ex){Response.StatusCode=400;Response.TrySkipIisCustomErrors=true;Response.Write(JsonConvert.SerializeObject(new {error=ex is ArgumentException?ex.Message:"Unable to access the portal data. Please try again."}));}
        }
    }
}

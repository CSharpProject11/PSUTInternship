using System;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;
namespace PSUTInternship
{
    public class MeetingApi:PortalPage
    {
        protected async void Page_Load(object sender,EventArgs e)
        {
            Response.ContentType="application/json";Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            string role=PortalRoles.Normalize(Convert.ToString(Session["userRole"]));
            if(role!="academic"&&role!="student")throw new System.Web.HttpException(403,"Meeting access denied.");
            try
            {
                string action=Request.QueryString["action"];
                if(Request.HttpMethod=="GET")
                {
                    if(action=="identity")
                    {
                        string path=(role=="academic"?"academicSupervisors/":"students/")+PortalRepository.ProfileId;
                        var profile=await PortalRepository.Get<JObject>(path);
                        Response.Write(JsonConvert.SerializeObject(new {uid=PortalRepository.UserId,supervisorId=role=="academic"?PortalRepository.ProfileId:(string)profile?["academicSupervisorId"],supervisorName=role=="academic"?(string)profile?["fullName"]:(string)profile?["academicSupervisorName"],token=CsrfToken}));return;
                    }
                    if(action=="students")
                    {
                        var students=await PortalRepository.Collection("students");
                        Response.Write(JsonConvert.SerializeObject(students.Where(x=>(bool?)x.Value["isActive"]==true).Select(x=>new {id=x.Key,name=(string)x.Value["fullName"],studentNumber=(string)x.Value["studentNumber"]})));return;
                    }
                    var meetings=await PortalRepository.Collection("meetings");Response.Write(JsonConvert.SerializeObject(meetings));return;
                }
                if(Request.HttpMethod!="POST")throw new ArgumentException("Unsupported request.");
                JObject body;using(var reader=new StreamReader(Request.InputStream))body=JObject.Parse(await reader.ReadToEndAsync());
                if(action=="create")
                {
                    if(role!="academic")throw new ArgumentException("Only academic supervisors create invitations.");
                    string uid=PortalRepository.Key((string)body["studentId"]);
                    var student=await PortalRepository.Get<JObject>("students/"+uid);
                    if((string)student?["academicSupervisorId"]!=PortalRepository.ProfileId)throw new ArgumentException("This student is not assigned to you.");
                    DateTime scheduled;
                    if(!DateTime.TryParse((string)body["date"]+"T"+(string)body["time"],out scheduled)||scheduled<=DateTime.Now||string.IsNullOrWhiteSpace((string)body["title"])||string.IsNullOrWhiteSpace((string)body["purpose"])||!new[]{30,45,60}.Contains((int?)body["duration"]??0))throw new ArgumentException("Enter meeting details and a future date and time.");
                    body["supervisorId"]=PortalRepository.ProfileId;body["studentName"]=(string)student["fullName"];body["status"]="Pending";body["createdAt"]=DateTime.UtcNow.ToString("o");body["roomName"]="UIMS-"+Guid.NewGuid().ToString("N");
                    var supervisor=await PortalRepository.Get<JObject>("academicSupervisors/"+PortalRepository.ProfileId);body["supervisorName"]=(string)supervisor?["fullName"];
                    string saved=await FirebaseRestClient.PostAsync("meetings",body,CurrentToken);Response.Write(saved);return;
                }
                if(action!="status")throw new ArgumentException("Unsupported request.");
                string id=PortalRepository.Key((string)body["id"]), next=(string)body["next"],previous=(string)body["previous"];
                string url=FirebaseConfig.DatabaseUrl+"meetings/"+id+".json?auth="+Uri.EscapeDataString(CurrentToken);
                using(var read=new HttpRequestMessage(HttpMethod.Get,url))
                {
                    read.Headers.TryAddWithoutValidation("X-Firebase-ETag","true");
                    using(var response=await FirebaseConfig.Client.SendAsync(read))
                    {
                        response.EnsureSuccessStatusCode();var meeting=JObject.Parse(await response.Content.ReadAsStringAsync());
                        if((string)meeting["status"]!=previous)throw new ArgumentException("The meeting changed. Refresh and retry.");
                        bool allowed=role=="student"?(string)meeting["studentId"]==PortalRepository.UserId&&previous=="Pending"&&(next=="Accepted"||next=="Rejected")
                            :(string)meeting["supervisorId"]==PortalRepository.ProfileId&&(previous=="Pending"||previous=="Accepted")&&next=="Cancelled";
                        if(!allowed)throw new ArgumentException("This meeting cannot be changed by your account.");
                        meeting["status"]=next;meeting["respondedAt"]=DateTime.UtcNow.ToString("o");
                        using(var save=new HttpRequestMessage(HttpMethod.Put,url))
                        {
                            save.Headers.TryAddWithoutValidation("if-match",response.Headers.ETag.ToString());save.Content=new StringContent(meeting.ToString(Formatting.None),Encoding.UTF8,"application/json");
                            using(var saved=await FirebaseConfig.Client.SendAsync(save))saved.EnsureSuccessStatusCode();
                        }
                    }
                }
                Response.Write("{\"saved\":true}");
            }
            catch(Exception ex){Response.StatusCode=400;Response.TrySkipIisCustomErrors=true;Response.Write(JsonConvert.SerializeObject(new {error=ex is ArgumentException?ex.Message:"The meeting request failed. Refresh and retry."}));}
        }
    }
}

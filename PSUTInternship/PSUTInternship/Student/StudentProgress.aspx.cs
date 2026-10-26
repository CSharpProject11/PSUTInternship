using System;
using System.Linq;
using System.Globalization;
using System.Text;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;
namespace PSUTInternship.Student {
 public partial class StudentProgress : PortalPage {
  protected string TaskPercentage="0";
  protected int PendingCount,InProgressCount,ReviewedCount;
  protected async void Page_Load(object sender,EventArgs e) {
   if(IsPostBack)return;
   try {
    string uid=PortalRepository.UserId;
    var tasks=await PortalRepository.Collection(PortalRepository.Query("tasks","studentId",uid));
    var submissions=await PortalRepository.Collection(PortalRepository.Query("submissions","studentId",uid));
    var feedback=await PortalRepository.Collection(PortalRepository.Query("taskFeedback","studentId",uid));
    var summary=TaskProgressSummary.Calculate(uid,tasks,submissions.Values);
    TaskPercentage=summary.Percentage.ToString(CultureInfo.InvariantCulture);lblPercentage.Text=TaskPercentage+"%";
    lblTotalTasks.Text=summary.Total.ToString();lblSubmittedTasks.Text=summary.Submitted.ToString();lblRevisions.Text=summary.Revisions.ToString();PendingCount=summary.Pending;InProgressCount=summary.InProgress;ReviewedCount=summary.Reviewed;
    var rows=new System.Collections.Generic.List<object>();
    foreach(var task in tasks.Where(x=>(string)x.Value["studentId"]==uid&&(bool?)x.Value["active"]!=false&&(bool?)x.Value["deleted"]!=true)) {
     var submission=submissions.Values.Where(x=>(string)x["taskId"]==task.Key&&(string)x["studentId"]==uid).OrderByDescending(PortalRepository.SubmissionTime).FirstOrDefault();
     var review=feedback.Values.Where(x=>(string)x["studentId"]==uid&&((string)x["taskId"]==task.Key||feedback.ContainsKey(task.Key)&&ReferenceEquals(x,feedback[task.Key]))).OrderByDescending(x=>Timestamp(x,"reviewedAt")).FirstOrDefault();
     var history=new StringBuilder();
     var events=new System.Collections.Generic.List<System.Tuple<DateTimeOffset,string,string,string>>();
     foreach(string collection in new[]{"submissionHistory","reviewHistory"}) {
      var entries=await PortalRepository.Collection(collection+"/"+PortalRepository.Key(task.Key));
      foreach(var entry in entries.Values.Where(x=>(string)x["studentId"]==uid).OrderBy(x=>Timestamp(x,collection=="reviewHistory"?"reviewedAt":"updatedAt","submittedAt"))) {
       string kind=collection=="reviewHistory"?"Supervisor review":"Submission";
       string state=DatabaseSchema.FirstText(entry,"status");
       string comment=DatabaseSchema.FirstText(entry,"comments","feedback");
       var when=Timestamp(entry,collection=="reviewHistory"?"reviewedAt":"updatedAt","submittedAt");
       events.Add(System.Tuple.Create(when,kind,state,comment));
      }
     }
     if(events.Count==0) history.Append("<p class='progress-empty'>No activity recorded yet.</p>");
     else {
      history.Append("<ol class='progress-timeline'>");
      foreach(var item in events.Distinct().OrderBy(x=>x.Item1)) {
       history.Append("<li><div class='progress-event-heading'><strong>").Append(Server.HtmlEncode(item.Item2)).Append("</strong><span>").Append(Server.HtmlEncode(item.Item3=="Reviewed"?"Completed":item.Item3)).Append("</span></div><time>").Append(Server.HtmlEncode(item.Item1==DateTimeOffset.MinValue?"Date not recorded":Date(new JValue(item.Item1.ToString("o"))))).Append("</time>");
       if(!string.IsNullOrWhiteSpace(item.Item4)) history.Append("<p>").Append(Server.HtmlEncode(item.Item4)).Append("</p>");
       history.Append("</li>");
      }
      history.Append("</ol>");
     }
     rows.Add(new {Title=(string)task.Value["title"],Status=DatabaseSchema.WorkflowStatus((string)task.Value["status"])??"Pending",SubmissionDate=Date(submission?["submittedAt"]),UpdatedDate=Date(submission?["updatedAt"]),Comments=DatabaseSchema.FirstText(review,"comments","feedback"),Score=review?["score"]!=null&&review["score"].Type!=JTokenType.Null?"Score: "+review["score"]+(((decimal?)review["maximumScore"]??0)>0?" / "+review["maximumScore"]:""):"No score recorded",ReviewDate=Date(review?["reviewedAt"]),History=history.ToString()});
    }
    rptTasks.DataSource=rows;rptTasks.DataBind();lblNoTasks.Visible=rows.Count==0;
    var completion=await PortalRepository.CompletionForStudent(uid);lnkReport.Visible=DatabaseSchema.ReportApproved(completion);lnkReport.NavigateUrl="~/CompletionReport.aspx";
    lblReportStatus.Text="";
   }catch(Exception){lblReportStatus.Text="Progress could not be loaded. Refresh or sign in again.";}
  }
  private static DateTimeOffset Timestamp(JObject row,params string[] fields) {
   DateTimeOffset value;
   return DateTimeOffset.TryParse(DatabaseSchema.FirstText(row,fields),CultureInfo.InvariantCulture,DateTimeStyles.AssumeUniversal,out value)?value:DateTimeOffset.MinValue;
  }
  private static string Date(JToken value) {
   DateTimeOffset date;
   return DateTimeOffset.TryParse((string)value,CultureInfo.InvariantCulture,DateTimeStyles.AssumeUniversal,out date)
    ? TimeZoneInfo.ConvertTime(date,TimeZoneInfo.FindSystemTimeZoneById("Jordan Standard Time")).ToString("dd MMM yyyy HH:mm",CultureInfo.InvariantCulture)
    : "Not available";
  }
 }
}
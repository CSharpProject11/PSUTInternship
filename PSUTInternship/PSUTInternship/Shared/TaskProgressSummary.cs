using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Shared {
 public sealed class TaskProgressSummary {
  public int Total, Submitted, Pending, InProgress, Revisions, Reviewed;
  public decimal Percentage { get { return Total == 0 ? 0 : Math.Round(Submitted * 100m / Total, 1); } }
  public static TaskProgressSummary Calculate(string studentId, IDictionary<string,JObject> tasks, IEnumerable<JObject> submissions) {
   var assigned=tasks.Where(x=>x.Value!=null&&(string)x.Value["studentId"]==studentId&&(bool?)x.Value["active"]!=false&&(bool?)x.Value["deleted"]!=true).ToList();
   var submitted=new HashSet<string>(submissions.Where(x=>x!=null&&(string)x["studentId"]==studentId).Select(x=>(string)x["taskId"]));
   return new TaskProgressSummary { Total=assigned.Count,Submitted=assigned.Count(x=>submitted.Contains(x.Key)),
    Pending=assigned.Count(x=>new[]{"Pending","Assigned"}.Contains((string)x.Value["status"])),InProgress=assigned.Count(x=>(string)x.Value["status"]=="In Progress"),
    Revisions=assigned.Count(x=>DatabaseSchema.WorkflowStatus((string)x.Value["status"])=="Revision Requested"),Reviewed=assigned.Count(x=>DatabaseSchema.WorkflowStatus((string)x.Value["status"])=="Reviewed") };
  }
 }
}

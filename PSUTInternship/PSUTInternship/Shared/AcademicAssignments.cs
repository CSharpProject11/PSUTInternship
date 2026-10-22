using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Shared
{
    public static class AcademicAssignments
    {
        public static async Task Synchronize(string uid,string supervisor)
        {
            var changes=new Dictionary<string,object>();
            await AddChanges(uid,supervisor,changes);
            if(changes.Count>0)await PortalRepository.Patch("",changes);
        }
        public static async Task AddChanges(string uid,string supervisor,Dictionary<string,object> changes) {
            var placement=await PortalRepository.PlacementForStudent(uid);
            bool active = placement != null && (string)placement["status"] == "active";
            string placementId = placement == null ? "" : DatabaseSchema.Id(placement);
            if(active)changes["internships/"+placementId+"/academicSupervisorId"]=supervisor;
            foreach(string collection in new[]{"applications","tasks","submissions","taskFeedback","trainingHours","evaluations"})
            {
                var rows=await PortalRepository.Collection(PortalRepository.Query(collection,"studentId",uid));
                foreach(var row in rows)
                {
                    if (collection == "applications") {
                        if (placement != null && (string)row.Value["opportunityId"] != (string)placement["opportunityId"]) continue;
                        if (placement != null && !active) continue;
                    } else {
                        if (!active) continue;
                        string recordPlacement = (string)row.Value["internshipId"];
                        if (string.IsNullOrWhiteSpace(recordPlacement) && collection == "submissions" && !string.IsNullOrWhiteSpace((string)row.Value["taskId"])) {
                            var task = await PortalRepository.Get<JObject>("tasks/"+PortalRepository.Key((string)row.Value["taskId"])); recordPlacement = (string)task?["internshipId"];
                        }
                        if (recordPlacement != placementId) continue;
                    }
                    changes[collection+"/"+row.Key+"/academicSupervisorId"]=supervisor;
                    if(collection=="evaluations" && (string)row.Value["evaluatorRole"]=="academicSupervisor" && (string)row.Value["evaluatorId"]!=supervisor)
                    { changes[collection+"/"+row.Key+"/evaluatorId"]=supervisor;changes[collection+"/"+row.Key+"/status"]="draft";changes["coordinatorReviewQueue/"+row.Key]=null; }
                }
            }
        }
    }
}

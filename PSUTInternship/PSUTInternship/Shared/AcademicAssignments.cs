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
            var placement=await PortalRepository.PlacementForStudent(uid);
            if(placement!=null)changes["internships/"+DatabaseSchema.Id(placement)+"/academicSupervisorId"]=supervisor;
            foreach(string collection in new[]{"applications","tasks","submissions","taskFeedback","trainingHours","evaluations"})
            {
                var rows=await PortalRepository.Collection(PortalRepository.Query(collection,"studentId",uid));
                foreach(var row in rows)
                {
                    changes[collection+"/"+row.Key+"/academicSupervisorId"]=supervisor;
                    if(collection=="evaluations" && (string)row.Value["evaluatorRole"]=="academicSupervisor" && (string)row.Value["evaluatorId"]!=supervisor)
                    { changes[collection+"/"+row.Key+"/evaluatorId"]=supervisor;changes[collection+"/"+row.Key+"/status"]="draft";changes["coordinatorReviewQueue/"+row.Key]=null; }
                }
            }
            if(changes.Count>0)await PortalRepository.Patch("",changes);
        }
    }
}

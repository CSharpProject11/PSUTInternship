using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Shared
{
    public static class CompletionWorkflow
    {
        public static async Task Approve(string academicId)
        {
            if (PortalRoles.Normalize(Convert.ToString(PortalRepository.RequestSession["userRole"])) != "admin")
                throw new UnauthorizedAccessException("Only the coordinator approves completion.");
            var queue = await PortalRepository.Get<JObject>("coordinatorReviewQueue/" + PortalRepository.Key(academicId));
            if (queue == null) throw new InvalidOperationException("Review record not found.");
            string uid = (string)queue["studentId"];
            var placement = await PortalRepository.PlacementForStudent(uid);
            if (placement == null) throw new InvalidOperationException("Internship not found.");
            string placementId = DatabaseSchema.Id(placement);
            var company = await PortalRepository.EvaluationForPlacement(uid, placementId, "companySupervisor");
            var academic = await PortalRepository.EvaluationForPlacement(uid, placementId, "academicSupervisor");
            if (academic != null && DatabaseSchema.Id(academic) != academicId) throw new InvalidOperationException("The queued academic evaluation does not match this internship.");
            var student = await PortalRepository.Get<JObject>("students/" + uid);
            if ((string)company?["status"] != "submitted" || (string)academic?["status"] != "submitted" || (string)academic?["recommendation"] != "Pass")
                throw new InvalidOperationException("Both final evaluations must be submitted and the academic recommendation must be Pass.");
            if (placement == null || student == null || (string)placement["academicSupervisorId"] != (string)academic["evaluatorId"])
                throw new InvalidOperationException("The placement and assigned academic evaluation must match.");
            var hours = await PortalRepository.Collection(PortalRepository.Query("trainingHours", "internshipId", placementId));
            decimal approved = CoordinatorData.ApprovedHours(Newtonsoft.Json.Linq.JObject.FromObject(hours), placementId, uid);
            decimal required = (decimal?)student["requiredHours"] ?? (decimal?)student["requiredTrainingHours"] ?? (decimal?)placement["requiredHours"] ?? 0;
            if (required <= 0 || approved < required) throw new InvalidOperationException("The required training hours have not been approved.");
            var tasks = await PortalRepository.Collection(PortalRepository.Query("tasks", "studentId", uid));
            if (tasks.Values.Any(x => (string)x["internshipId"] == placementId && ((bool?)x["active"] ?? true) && !string.Equals((string)x["status"], "Reviewed", StringComparison.OrdinalIgnoreCase)))
                throw new InvalidOperationException("All active tasks must be reviewed before completion.");
            decimal grade = EvaluationPolicy.FinalGrade((decimal?)company["overallScore"] ?? -1, (decimal?)company["totalMaximum"] ?? 0, (decimal?)academic["overallScore"] ?? -1);
            if (grade < EvaluationPolicy.PassGrade) throw new InvalidOperationException("The final grade is below the configured passing grade.");
            var existingReport = await PortalRepository.CompletionForStudent(uid);
            string reportId = existingReport == null ? placementId : DatabaseSchema.Id(existingReport);
            if (DatabaseSchema.ReportApproved(existingReport)) throw new InvalidOperationException("This internship has already been approved.");
            var report = new
            {
                studentId = uid,
                studentName = (string)student["fullName"],
                studentNumber = (string)student["studentNumber"],
                company = (string)placement["opportunityTitle"],
                startDate = (string)placement["startDate"],
                endDate = (string)placement["endDate"],
                certificateDesignVersion = 2,
                status = "approved",
                internshipId = placementId,
                companyEvaluationId = DatabaseSchema.Id(company),
                academicEvaluationId = academicId,
                requiredHours = required,
                totalApprovedHours = approved,
                reviewedBy = PortalRepository.UserId,
                reviewedAt = DateTime.UtcNow.ToString("o"),
                approvedHours = approved,
                finalGrade = grade,
                approvedByCoordinator = true,
                approvedBy = PortalRepository.UserId,
                approvedAt = DateTime.UtcNow.ToString("o")
            };
            var reportRecord = JObject.FromObject(report);
            reportRecord["certificateId"] = CompletionCertificateStore.Save(reportRecord);
            await PortalRepository.Patch("", new Dictionary<string, object> {
                {"completionReports/"+reportId,reportRecord},{"internships/"+placementId+"/status","completed"},{"internships/"+placementId+"/completionApproved",true},{"internships/"+placementId+"/approvedHours",approved},
                {"coordinatorReviewQueue/"+academicId+"/status","approved"}
            });
        }
    }
}

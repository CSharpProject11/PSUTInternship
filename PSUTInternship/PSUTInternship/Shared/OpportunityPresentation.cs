using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using PSUTInternship.Models;

namespace PSUTInternship.Shared
{
    public static class OpportunityPresentation
    {
        public static async Task<bool> HasConfirmedInternship(string studentId)
        {
            if (await PortalRepository.PlacementForStudent(studentId) != null) return true;
            return await PortalRepository.Get<JObject>("internshipConfirmations/" + PortalRepository.Key(studentId)) != null;
        }

        public static async Task Populate(IEnumerable<Opportunity> opportunities)
        {
            bool confirmed = await HasConfirmedInternship(PortalRepository.UserId);
            var companies = await PortalRepository.Collection("companies");
            var applications = await PortalRepository.Collection(PortalRepository.Query("applications", "studentId", PortalRepository.UserId));
            var applied = new HashSet<string>(applications.Values.Where(x => x != null).Select(x => (string)x["opportunityId"]));
            var opportunityList = opportunities.ToList();
            foreach (var group in opportunityList.Where(x => x.AvailableSeats.HasValue).GroupBy(x => x.CompanyId))
            {
                try
                {
                    // Use the current user's authorized reads only. Render aggregate counts, never other students' records.
                    var companyApplications = await PortalRepository.Collection(PortalRepository.Query("applications", "companyId", group.Key));
                    var companyPlacements = await PortalRepository.Collection(PortalRepository.Query("internships", "companyId", group.Key));
                    foreach (var opening in group)
                    {
                        var students = new HashSet<string>(companyApplications.Values.Where(x => (string)x["opportunityId"] == opening.Id && DatabaseSchema.WorkflowStatus((string)x["status"]) == "Approved").Select(x => (string)x["studentId"]).Where(x => !string.IsNullOrEmpty(x)));
                        foreach (var placement in companyPlacements.Values.Where(x => (string)x["opportunityId"] == opening.Id && !string.Equals((string)x["status"], "cancelled", System.StringComparison.OrdinalIgnoreCase)))
                            if (!string.IsNullOrEmpty((string)placement["studentId"])) students.Add((string)placement["studentId"]);
                        opening.OccupiedSeats = System.Math.Max(opening.OccupiedSeats, students.Count);
                    }
                }
                catch (System.Net.Http.HttpRequestException)
                {
                    foreach (var opening in group) opening.CapacityUnavailable = !opening.HasStoredSeatCount;
                }
            }
            foreach (var opportunity in opportunityList)
            {
                JObject company;
                companies.TryGetValue(opportunity.CompanyId ?? "", out company);
                if (string.IsNullOrWhiteSpace(opportunity.CompanyName))
                    opportunity.CompanyName = company == null ? "Company not specified" : DatabaseSchema.FirstText(company, "name", "companyName");
                if (string.IsNullOrWhiteSpace(opportunity.CompanyName)) opportunity.CompanyName = "Company not specified";
                if (string.IsNullOrWhiteSpace(opportunity.Location) && company != null)
                    opportunity.Location = DatabaseSchema.FirstText(company, "location", "city", "address");
                opportunity.HasApplied = applied.Contains(opportunity.Id);
                opportunity.HasConfirmedInternship = confirmed;
            }
        }
    }
}

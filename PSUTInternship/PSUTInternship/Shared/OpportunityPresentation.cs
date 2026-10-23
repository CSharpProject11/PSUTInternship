using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using PSUTInternship.Models;

namespace PSUTInternship.Shared
{
    public static class OpportunityPresentation
    {
        public static async Task Populate(IEnumerable<Opportunity> opportunities)
        {
            var companies = await PortalRepository.Collection("companies");
            var applications = await PortalRepository.Collection(PortalRepository.Query("applications", "studentId", PortalRepository.UserId));
            var applied = new HashSet<string>(applications.Values.Where(x => x != null).Select(x => (string)x["opportunityId"]));
            foreach (var opportunity in opportunities)
            {
                JObject company;
                companies.TryGetValue(opportunity.CompanyId ?? "", out company);
                if (string.IsNullOrWhiteSpace(opportunity.CompanyName))
                    opportunity.CompanyName = company == null ? "Company not specified" : DatabaseSchema.FirstText(company, "name", "companyName");
                if (string.IsNullOrWhiteSpace(opportunity.CompanyName)) opportunity.CompanyName = "Company not specified";
                if (string.IsNullOrWhiteSpace(opportunity.Location) && company != null)
                    opportunity.Location = DatabaseSchema.FirstText(company, "location", "city", "address");
                opportunity.HasApplied = applied.Contains(opportunity.Id);
            }
        }
    }
}

using System;
using Newtonsoft.Json.Linq;
using PSUTInternship.Models;
namespace PSUTInternship.Shared
{
    public static class OpportunityEligibility
    {
        public static bool Matches(Opportunity opportunity, JObject student)
        {
            if (opportunity == null || student == null) return false;
            bool college = string.IsNullOrWhiteSpace(opportunity.College) || string.Equals(opportunity.College, (string)student["college"], StringComparison.OrdinalIgnoreCase);
            // Specialization describes the role; it is not a student degree identifier.
            return college;
        }
    }
}

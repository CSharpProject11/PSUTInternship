using PSUTInternship.Shared;
using System;
using System.Linq;
namespace PSUTInternship.Company
{
    public partial class Dashboard : CompanyPageBase
    {
        protected int ActiveTrainees { get { return TraineeRows.Count(x => x.Status == "active"); } }
        protected int PendingApplications { get { return ApplicationRows.Count(x => x.Status == "Pending"); } }
        protected int OpenOpportunities { get { return OpportunityRows.Count(x => x.IsOpen); } }
        protected int PendingSubmissions { get { return SubmissionRows.Count(x => string.Equals(x.Status, "Submitted", StringComparison.OrdinalIgnoreCase) || string.Equals(x.Status, "pending", StringComparison.OrdinalIgnoreCase)); } }
        protected void Page_Load(object sender, EventArgs e) { LoadCompanyData(); }
    }
}


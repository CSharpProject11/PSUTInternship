using PSUTInternship.Shared;
using System;
using System.Linq;
using PSUTInternship.Models;
namespace PSUTInternship.Company
{
    public partial class Opportunities : CompanyPageBase
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadCompanyData();
            if (!IsPostBack && Request.HttpMethod != "POST") return;
            if (Request.HttpMethod != "POST" || string.IsNullOrWhiteSpace(PostedValue("closeOpportunity"))) return;
            CompanyOpportunity row = OpportunityRows.FirstOrDefault(x => x.Id == PostedValue("closeOpportunity"));
            if (row != null && TryFirebase(() => UpdateOpportunityStatus(row.Id, false))) GoTo("Opportunities.aspx");
        }
    }
}

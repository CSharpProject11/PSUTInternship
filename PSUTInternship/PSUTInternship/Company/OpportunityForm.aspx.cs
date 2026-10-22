using System;
using System.Linq;
using PSUTInternship.Models;
namespace PSUTInternship.Company
{
    public partial class OpportunityForm : CompanyPageBase
    {
        protected CompanyOpportunity Opportunity { get; private set; }
        protected bool IsEdit { get; private set; }
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadCompanyData();
            IsEdit = !string.IsNullOrEmpty(Request.QueryString["id"]);
            Opportunity = OpportunityRows.FirstOrDefault(x => x.Id == Request.QueryString["id"]);
            if (IsEdit && Opportunity == null) { GoTo("Opportunities.aspx"); return; }
            if (Request.HttpMethod == "POST") SaveOpportunity();
        }
        private void SaveOpportunity()
        {
            string title = PostedValue("title").Trim();
            int seats = PostedNumber("seats");
            if (title.Length == 0 || seats < 0) return;
            CompanyOpportunity row = Opportunity ?? new CompanyOpportunity();
            row.Title = title;
            row.Specialization = PostedValue("specialization").Trim();
            row.Description = PostedValue("description").Trim();
            row.Requirements = PostedValue("requirements").Trim();
            row.Seats = seats;
            row.Deadline = PostedValue("deadline").Trim();
            row.IsOpen = true;
            bool saved = TryFirebase(() => { if (IsEdit) UpdateOpportunity(row); else CreateOpportunity(row); });
            if (saved) GoTo("Opportunities.aspx");
            Opportunity = row;
        }
    }
}

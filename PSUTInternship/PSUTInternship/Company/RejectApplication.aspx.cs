using PSUTInternship.Shared;
using System;
using System.Linq;
using PSUTInternship.Models;
namespace PSUTInternship.Company
{
    public partial class RejectApplication : CompanyPageBase
    {
        protected CompanyApplication StudentApplication { get; private set; }
        protected string ErrorMessage = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadCompanyData();
            StudentApplication = ApplicationRows.FirstOrDefault(x => x.Id == Request.QueryString["id"]);
            if (StudentApplication == null) return;
            if (Request.HttpMethod == "POST") Reject();
        }
        private void Reject()
        {
            string reason = PostedValue("reason").Trim();
            if (reason.Length == 0) { ErrorMessage = "Please enter a reason for rejection."; return; }
            if (TryFirebase(() => UpdateApplication(StudentApplication.Id, "rejected", reason))) GoTo("Applications.aspx");
        }
    }
}

using System;
using System.Linq;
using System.Web;
using PSUTInternship.Models;
namespace PSUTInternship.Company
{
    public partial class Application : CompanyPageBase
    {
        protected CompanyApplication StudentApplication { get; private set; }
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadCompanyData();
            StudentApplication = ApplicationRows.FirstOrDefault(x => x.Id == Request.QueryString["id"]);
            if (StudentApplication == null) return;
            if (Request.HttpMethod == "POST") SaveDecision();
        }
        private void SaveDecision()
        {
            string action = PostedValue("action");
            if (action == "accept")
            {
                if (TryFirebase(() => UpdateApplication(StudentApplication.Id, "accepted", ""))) GoTo("Applications.aspx");
            }
            else if (action == "confirm" && StudentApplication.Status == "Accepted")
            {
                if (TryFirebase(() => ConfirmStudentPlacement(StudentApplication))) GoTo("Trainees.aspx");
            }
            else if (action == "reject") GoTo("RejectApplication.aspx?id=" + HttpUtility.UrlEncode(StudentApplication.Id));
        }
    }
}



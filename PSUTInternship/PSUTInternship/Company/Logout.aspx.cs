using PSUTInternship.Shared;
using System;
using System.Web.UI;
namespace PSUTInternship.Company
{
    public partial class Logout : PSUTInternship.Shared.PortalPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}

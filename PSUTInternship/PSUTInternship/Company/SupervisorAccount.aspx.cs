using PSUTInternship.Shared;
using System; namespace PSUTInternship.Company { public partial class SupervisorAccount : PSUTInternship.Shared.PortalPage {
protected void Page_Load(object sender, EventArgs e) { Response.Redirect("Account.aspx", false); Context.ApplicationInstance.CompleteRequest(); }
} }

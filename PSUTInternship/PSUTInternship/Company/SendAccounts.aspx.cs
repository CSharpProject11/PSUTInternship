using PSUTInternship.Shared;
using System; namespace PSUTInternship.Company { public partial class SendAccounts : PSUTInternship.Shared.PortalPage {
protected void Page_Load(object sender, EventArgs e) { throw new System.Web.HttpException(403, "Only the coordinator creates accounts."); }
} }

using PSUTInternship.Shared;
using System; namespace PSUTInternship.Company { public partial class Login : System.Web.UI.Page {
protected void Page_Load(object sender, EventArgs e) { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); }
protected void SignIn_Click(object sender, EventArgs e) { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); }
} }

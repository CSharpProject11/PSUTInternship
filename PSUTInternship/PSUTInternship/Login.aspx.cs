using System;
using System.Threading.Tasks;
using System.Web;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;

namespace PSUTInternship
{
    public partial class Login : PortalPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            if (!IsPostBack && Request.QueryString["expired"] == "1")
                messageLabel.Text = "Your sign-in form expired. Please enter your details again.";
        }

        protected async void loginButton_Click(object sender, EventArgs e)
        {
            string email = emailTextBox.Text.Trim();
            if (email.Length == 0 || passwordTextBox.Text.Length == 0)
            { messageLabel.Text = "Enter your email and password."; return; }
            try
            {
                Session.Clear();
                Session["csrfToken"] = Guid.NewGuid().ToString("N");
                var auth = await FirebaseAuthClient.SignInAsync(email, passwordTextBox.Text, FirebaseConfig.ApiKey);
                var user = await FirebaseRestClient.GetAsync<JObject>("users/" + Uri.EscapeDataString(auth.UserId), auth.IdToken);
                if (user == null || !((bool?)user["isActive"] ?? false))
                    throw new InvalidOperationException("This account has no active profile. Contact the coordinator.");
                string role = PortalRoles.SessionRole((string)user["role"]);
                if (role.Length == 0) throw new InvalidOperationException("The account role is not recognized.");
                Session["userId"] = auth.UserId;
                Session["profileId"] = (string)user["profileId"] ?? auth.UserId;
                Session["userEmail"] = auth.Email ?? email;
                Session["userRole"] = role;
                Session["companyId"] = await PortalRepository.ResolveCompanyId(user, auth.UserId, auth.IdToken);
                Session["idToken"] = auth.IdToken;
                Session["refreshToken"] = auth.RefreshToken;
                Session["tokenExpiresUtc"] = DateTime.UtcNow.AddSeconds(auth.ExpiresIn > 0 ? auth.ExpiresIn : 3600);
                if (PortalRoles.Normalize(role) == "admin") await DatabaseSchema.SynchronizeLinks();
                bool changePassword = (bool?)user["mustChangePassword"] ?? false;
                Session["mustChangePassword"] = changePassword;
                Response.Redirect(changePassword ? "~/ChangePassword.aspx" : PortalRoles.Dashboard(role), false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                Session.Clear();
                Session["csrfToken"] = Guid.NewGuid().ToString("N");
                messageLabel.Text = HttpUtility.HtmlEncode(ex.Message);
            }
        }
        protected async void resetPassword_Click(object sender, EventArgs e)
        {
            try
            {
                var email = new System.Net.Mail.MailAddress(emailTextBox.Text.Trim());
                await FirebaseAuthClient.SendPasswordResetAsync(email.Address);
            }
            catch (Exception) { }
            messageLabel.Text = "If this email has an account, Firebase will send password reset instructions.";
        }
    }
}

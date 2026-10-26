using System;
using System.Web;
using PSUTInternship.Shared;
namespace PSUTInternship
{
    public partial class ChangePassword : PortalPage
    {
        protected void Page_Load(object sender, EventArgs e) { }
        protected async void savePassword_Click(object sender, EventArgs e)
        {
            if (newPassword.Text.Length < 8 || newPassword.Text != confirmPassword.Text)
            { passwordMessage.Text = "Enter matching passwords of at least 8 characters."; return; }
            if (string.IsNullOrEmpty(currentPassword.Text) || currentPassword.Text == newPassword.Text) { passwordMessage.Text = "Enter your current password and choose a different new password."; return; }
            try
            {
                var user = await PortalRepository.Get<Newtonsoft.Json.Linq.JObject>("users/" + PortalRepository.Key(PortalRepository.UserId));
                var signedIn = await FirebaseAuthClient.SignInAsync((string)user["email"], currentPassword.Text, FirebaseConfig.ApiKey);
                if (signedIn.UserId != PortalRepository.UserId) throw new UnauthorizedAccessException("Account mismatch.");
                var auth = await FirebaseAuthClient.ChangePasswordAsync(signedIn.IdToken, newPassword.Text);
                if (string.IsNullOrWhiteSpace(auth.IdToken) || string.IsNullOrWhiteSpace(auth.RefreshToken))
                    throw new InvalidOperationException("The password was updated, but your session could not be renewed. Please sign in again.");
                Session["idToken"] = auth.IdToken;
                Session["refreshToken"] = auth.RefreshToken;
                Session["tokenExpiresUtc"] = DateTime.UtcNow.AddSeconds(auth.ExpiresIn > 0 ? auth.ExpiresIn : 3600);
                await FirebaseRestClient.PatchAsync("users/" + Convert.ToString(Session["userId"]), new { mustChangePassword = false }, auth.IdToken);
                Session["mustChangePassword"] = false;
                if (Request.QueryString["embedded"] == "1")
                {
                    currentPassword.Text = newPassword.Text = confirmPassword.Text = "";
                    passwordMessage.Text = "Password changed successfully.";
                    savePassword.Enabled = false;
                    ClientScript.RegisterStartupScript(GetType(), "passwordChanged",
                        "window.parent.postMessage('password-settings-saved',location.origin);", true);
                    return;
                }
                Response.Redirect(PortalRoles.Dashboard(Convert.ToString(Session["userRole"])), false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex) { passwordMessage.Text = HttpUtility.HtmlEncode(ex.Message); }
        }
    }
}

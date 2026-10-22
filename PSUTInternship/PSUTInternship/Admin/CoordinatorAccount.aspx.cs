using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using PSUTInternship.Shared;

public partial class CoordinatorAccount : PortalPage
{
    protected string FullName = "Coordinator";
    protected string Email = "";
    protected string Phone = "";
    protected string Notice = "";

    protected async void Page_Load(object sender, EventArgs e)
    {
        CoordinatorData.RequireCoordinator();
        try
        {
            var user = await CoordinatorData.Read("users/" + PortalRepository.Key(PortalRepository.UserId));
            FullName = CoordinatorData.Str(user, "fullName", "Coordinator");
            Email = CoordinatorData.Str(user, "email");
            Phone = CoordinatorData.Str(user, "phoneNumber");
            if (!IsPostBack) return;
            string action = Request.Form["accountAction"] ?? "";
            if (action == "saveContact") await SaveContactInformation();
            else if (action == "changePassword") await ChangePassword();
        }
        catch (Exception ex) { Notice = ex.Message; }
    }

    private async Task SaveContactInformation()
    {
        string newEmail = (Request.Form["email"] ?? "").Trim();
        string newPhone = (Request.Form["phone"] ?? "").Trim();
        Phone = newPhone;
        if (!string.Equals(newEmail, Email, StringComparison.OrdinalIgnoreCase))
        {
            Notice = "Email changes require Firebase Authentication re-verification; email was not changed.";
            return;
        }
        if (newPhone.Length > 0 && !Regex.IsMatch(newPhone, @"^[+0-9()\s-]{7,25}$"))
        {
            Notice = "Please enter a valid phone number.";
            return;
        }
        await PortalRepository.Patch("users/" + PortalRepository.Key(PortalRepository.UserId), new { phoneNumber = newPhone });
        Notice = "Contact information saved.";
    }

    private async Task ChangePassword()
    {
        string currentPassword = Request.Form["currentPassword"] ?? "";
        string newPassword = Request.Form["newPassword"] ?? "";
        string confirmation = Request.Form["confirmPassword"] ?? "";
        if (currentPassword.Length == 0) { Notice = "Please enter your current password."; return; }
        if (newPassword.Length < 8) { Notice = "New password must contain at least 8 characters."; return; }
        if (newPassword != confirmation) { Notice = "New password and confirmation do not match."; return; }
        if (currentPassword == newPassword) { Notice = "New password must be different from the current password."; return; }

        var signIn = await FirebaseAuthClient.SignInAsync(Email, currentPassword, FirebaseConfig.ApiKey);
        if (signIn.UserId != PortalRepository.UserId) throw new UnauthorizedAccessException("Account mismatch.");
        var updated = await FirebaseAuthClient.ChangePasswordAsync(signIn.IdToken, newPassword);
        Session["idToken"] = updated.IdToken;
        Session["refreshToken"] = updated.RefreshToken;
        Session["tokenExpiresUtc"] = DateTime.UtcNow.AddSeconds(updated.ExpiresIn > 0 ? updated.ExpiresIn : 3600);
        Notice = "Password updated successfully.";
    }

    protected string H(string value) { return HttpUtility.HtmlEncode(value ?? ""); }
}

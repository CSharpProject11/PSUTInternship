using System;
using System.Configuration;
using System.Web;
using System.Web.UI;
using PSUTInternship.Firebase;

namespace PSUTInternship.Company
{
    public partial class Login : Page
    {
        protected string ErrorMessage = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.HttpMethod != "POST") return;

            string email = Request.Form["email"] ?? "";
            string password = Request.Form["password"] ?? "";
            string apiKey = ConfigurationManager.AppSettings["FirebaseWebApiKey"];

            try
            {
                FirebaseSignInResult user = FirebaseAuthClient
                    .SignInAsync(email, password, apiKey).GetAwaiter().GetResult();
                Session["FirebaseIdToken"] = user.IdToken;
                Session["FirebaseRefreshToken"] = user.RefreshToken;
                Session["FirebaseUserId"] = user.UserId;
                Session["FirebaseUserEmail"] = user.Email;
                Response.Redirect("Dashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (InvalidOperationException ex)
            {
                ErrorMessage = ex.Message;
            }
            catch (Exception)
            {
                ErrorMessage = "Could not reach Firebase. Check your internet connection, project API key, and network access.";
            }
        }

        protected string H(string value) { return HttpUtility.HtmlEncode(value ?? ""); }
    }
}


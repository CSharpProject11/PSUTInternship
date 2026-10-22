using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace PSUTInternship
{

    public class Global : HttpApplication
    {
        void Application_AcquireRequestState(object sender, EventArgs e)
        {
            if (Context.Session == null) return;
            string path = Request.AppRelativeCurrentExecutionFilePath;
            if (!path.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase)) return;
            string[] segments = path.Split('/');
            string area = segments.Length > 2 ? segments[1].ToLowerInvariant() : "";
            bool protectedPage = area == "student" || area == "company" || area == "academic" || area == "admin"
                || path.Equals("~/ChangePassword.aspx", StringComparison.OrdinalIgnoreCase) || path.Equals("~/CompletionReport.aspx", StringComparison.OrdinalIgnoreCase) || path.Equals("~/MeetingApi.aspx", StringComparison.OrdinalIgnoreCase);
            if (!protectedPage || path.Equals("~/Company/Login.aspx", StringComparison.OrdinalIgnoreCase)) return;
            try
            {
                if (Session["userId"] == null || Session["idToken"] == null) { RedirectLogin(); return; }
                if (!(Session["tokenExpiresUtc"] is DateTime) || (DateTime)Session["tokenExpiresUtc"] <= DateTime.UtcNow.AddMinutes(2))
                {
                    var token = Shared.FirebaseAuthClient.RefreshAsync(Convert.ToString(Session["refreshToken"])).GetAwaiter().GetResult();
                    Session["idToken"] = (string)token["id_token"];
                    Session["refreshToken"] = (string)token["refresh_token"];
                    Session["tokenExpiresUtc"] = DateTime.UtcNow.AddSeconds((int?)token["expires_in"] ?? 3600);
                }
                var user = Shared.FirebaseRestClient.GetAsync<Newtonsoft.Json.Linq.JObject>("users/" + Convert.ToString(Session["userId"]), Convert.ToString(Session["idToken"])).GetAwaiter().GetResult();
                if (user == null || !((bool?)user["isActive"] ?? false)) { RedirectLogin(); return; }
                Session["userRole"] = Shared.PortalRoles.SessionRole((string)user["role"]);
                Session["companyId"] = Shared.PortalRepository.ResolveCompanyId(user, Convert.ToString(Session["userId"]), Convert.ToString(Session["idToken"])).GetAwaiter().GetResult();
                if (area.Length > 0 && area != Shared.PortalRoles.Normalize((string)user["role"]))
                    throw new HttpException(403, "This page belongs to another role.");
                if (((bool?)user["mustChangePassword"] ?? false) && !path.Equals("~/ChangePassword.aspx", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("~/ChangePassword.aspx", false);
                    CompleteRequest();
                }
            }
            catch (HttpException) { throw; }
            catch (Exception) { RedirectLogin(); }
        }
        private void RedirectLogin()
        {
            Session.Clear();
            Response.Redirect("~/Login.aspx", false);
            CompleteRequest();
        }

        void Application_Error(object sender, EventArgs e)
        {
            if (!Request.AppRelativeCurrentExecutionFilePath.Equals("~/Login.aspx", StringComparison.OrdinalIgnoreCase)) return;
            for (Exception error = Server.GetLastError(); error != null; error = error.InnerException)
            {
                if (!(error is System.Web.UI.ViewStateException)) continue;
                // Reject the POST and issue a fresh form; never replay submitted credentials.
                Server.ClearError();
                Response.Clear();
                Response.Redirect("~/Login.aspx?expired=1", false);
                CompleteRequest();
                return;
            }
        }

        void Application_Start(object sender, EventArgs e)
        {
            System.Net.ServicePointManager.SecurityProtocol |= System.Net.SecurityProtocolType.Tls12;
            System.Net.ServicePointManager.DefaultConnectionLimit = 20;
            RouteConfig.RegisterRoutes(RouteTable.Routes);
        }
    }
}

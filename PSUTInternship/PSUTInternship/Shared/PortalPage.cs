using System;
using System.Web.UI;

namespace PSUTInternship.Shared
{
    public class PortalPage : Page
    {

        protected string CsrfToken { get { if(Session["csrfToken"]==null)Session["csrfToken"]=Guid.NewGuid().ToString("N");return Convert.ToString(Session["csrfToken"]); } }
        protected override void OnInit(EventArgs e)
        {
            if(Request.HttpMethod=="POST" && Request.Form["__VIEWSTATE"]==null && !string.Equals(Request.Form["csrfToken"] ?? Request.Headers["X-CSRF-Token"],CsrfToken,StringComparison.Ordinal))
                throw new System.Web.HttpException(400,"The form has expired. Refresh and retry.");
            base.OnInit(e);
        }
        protected override void OnPreInit(EventArgs e)
        {
            PortalRepository.Bind(Context);
            // Persist an anonymous session before signing viewstate with its ID.
            // Merely reading SessionID leaves an empty session free to change on POST.
            if (Session["csrfToken"] == null) Session["csrfToken"] = Guid.NewGuid().ToString("N");
            ViewStateUserKey = Session.SessionID;
            base.OnPreInit(e);
        }
        protected string CurrentProfileId { get { return Convert.ToString(Session["profileId"] ?? Session["userId"]); } }
        protected string CurrentToken { get { return Convert.ToString(Session["idToken"]); } }
    }
    public static class PortalRoles
    {
        public static string Normalize(string role)
        {
            switch ((role ?? "").Replace(" ", "").Replace("_", "").ToLowerInvariant())
            {
                case "coordinator": case "admin": return "admin";
                case "company": case "companysupervisor": return "company";
                case "academic": case "academicsupervisor": case "collegesupervisor": return "academic";
                case "student": return "student";
                default: return "";
            }
        }
        public static string SessionRole(string role)
        {
            switch (Normalize(role))
            {
                case "admin": return "coordinator";
                case "company": return "Company Supervisor";
                case "academic": return "Academic Supervisor";
                case "student": return "student";
                default: return "";
            }
        }
        public static string Dashboard(string role)
        {
            switch (Normalize(role))
            {
                case "admin": return "~/Admin/Dashboard.aspx";
                case "company": return "~/Company/Dashboard.aspx";
                case "academic": return "~/Academic/Dashboard.aspx";
                default: return "~/Student/Dashboard.aspx";
            }
        }
    }
}

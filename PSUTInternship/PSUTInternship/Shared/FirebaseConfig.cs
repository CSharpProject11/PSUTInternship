using System;
using System.Configuration;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Web;

namespace PSUTInternship.Shared
{
    public static class FirebaseConfig
    {
        public static string DatabaseUrl
        {
            get
            {
                Uri uri;
                string value = Required("FirebaseDatabaseUrl");
                if (!Uri.TryCreate(value, UriKind.Absolute, out uri) || uri.Scheme != "https")
                    throw new ConfigurationErrorsException("FirebaseDatabaseUrl must be an HTTPS database URL.");
                return value.TrimEnd('/') + "/";
            }
        }
        public static string ApiKey { get { return Required("FirebaseWebApiKey"); } }
        private static readonly HttpMessageHandler Transport = new SessionTokenHandler();
        public static readonly HttpClient Client = CreateClient();
        private static string Required(string name)
        {
            string value = ConfigurationManager.AppSettings[name];
            if (string.IsNullOrWhiteSpace(value)) throw new ConfigurationErrorsException(name + " is missing from Web.config.");
            return value;
        }
        public static HttpClient CreateClient()
        {
            return new HttpClient(Transport, false) { Timeout = TimeSpan.FromSeconds(25) };
        }
        private sealed class SessionTokenHandler : DelegatingHandler
        {
            public SessionTokenHandler() : base(new HttpClientHandler()) { }
            protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
            {
                // Never forward database credentials to authentication endpoints or another host.
                if (request.RequestUri.Host == new Uri(DatabaseUrl).Host)
                {
                    var query = HttpUtility.ParseQueryString(request.RequestUri.Query);
                    string token = Convert.ToString(PortalRepository.RequestContext == null || PortalRepository.RequestContext.Session == null
                        ? null : PortalRepository.RequestContext.Session["idToken"]);

                    var session = PortalRepository.RequestContext == null ? null : PortalRepository.RequestContext.Session;
                    string collection = request.RequestUri.AbsolutePath.Trim('/');
                    if (collection.EndsWith(".json")) collection = collection.Substring(0, collection.Length - 5);
                    string role = session == null ? "" : PortalRoles.Normalize(Convert.ToString(session["userRole"]));
                    string field = null, value = null;
                    if (request.Method == HttpMethod.Get && !collection.Contains("/") && role != "admin" && role.Length > 0)
                    {
                        if (new[] { "tasks", "submissions", "taskFeedback", "internships", "trainingHours", "applications", "evaluations", "reports", "students", "meetings" }.Contains(collection))
                        {
                            field = role == "student" ? "studentId" : role == "company" ? "companyId" : "academicSupervisorId";
                            if (collection == "students" && role == "student") field = "$key";
                            if (collection == "meetings" && role == "academic") field = "supervisorId";
                            value = Convert.ToString(role == "company" ? session["companyId"] : role == "academic" ? session["profileId"] ?? session["userId"] : session["userId"]);
                        }
                        if (collection == "academicSupervisors" || collection == "companySupervisors")
                        { field = "$key"; value = Convert.ToString(session["profileId"] ?? session["userId"]); }
                        if (field != null && string.IsNullOrEmpty(query["orderBy"]))
                        { query["orderBy"] = Newtonsoft.Json.JsonConvert.SerializeObject(field); query["equalTo"] = Newtonsoft.Json.JsonConvert.SerializeObject(value); }
                        // The company workspace can only read its own openings.
                        if(collection == "opportunities" && role == "company" && string.IsNullOrEmpty(query["orderBy"]))
                        { query["orderBy"] = "\"companyId\""; query["equalTo"] = Newtonsoft.Json.JsonConvert.SerializeObject(Convert.ToString(session["companyId"])); }
                    }
                    if (string.IsNullOrWhiteSpace(query["auth"]) && !string.IsNullOrWhiteSpace(token))
                    {
                        query["auth"] = token;

                    }
                    request.RequestUri = new UriBuilder(request.RequestUri) { Query = query.ToString() }.Uri;
                }
                return base.SendAsync(request, cancellationToken);
            }
        }
    }
}

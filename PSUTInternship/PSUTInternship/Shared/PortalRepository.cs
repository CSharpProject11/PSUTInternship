using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PSUTInternship.Shared
{
    public static class PortalRepository
    {
        private sealed class RequestState
        {
            public HttpContext Context;
            public System.Web.SessionState.HttpSessionState Session;
        }
        private static readonly System.Threading.AsyncLocal<RequestState> Request = new System.Threading.AsyncLocal<RequestState>();
        public static HttpContext RequestContext
        {
            get
            {
                var current = HttpContext.Current;
                if (current != null && current.Session != null) { Bind(current); return current; }
                return Request.Value == null ? current : Request.Value.Context;
            }
        }
        public static void Bind(HttpContext context)
        {
            Request.Value = context == null ? null : new RequestState { Context = context, Session = context.Session };
        }
        public static System.Web.SessionState.HttpSessionState RequestSession
        {
            get
            {
                var context = HttpContext.Current;
                if (context != null && context.Session != null) Bind(context);
                var state = Request.Value;
                if (state == null || state.Session == null)
                    throw new HttpException(401, "Your session is unavailable. Please sign in again.");
                return state.Session;
            }
        }
        public static string UserId { get { return Convert.ToString(RequestSession["userId"]); } }
        public static string ProfileId { get { var session = RequestSession; return Convert.ToString(session["profileId"] ?? session["userId"]); } }
        public static string CompanyId { get { var session = RequestSession; return Convert.ToString(session["companyId"] ?? session["userId"]); } }
        public static string Token { get { return Convert.ToString(RequestSession["idToken"]); } }
        public static async Task<string> ResolveCompanyId(JObject user, string uid, string token)
        {
            string companyId = (string)user["companyId"];
            if (PortalRoles.Normalize((string)user["role"]) == "company" && string.IsNullOrWhiteSpace(companyId))
            {
                string profileId = (string)user["profileId"] ?? uid;
                var profile = await FirebaseRestClient.GetAsync<JObject>("companySupervisors/" + Key(profileId), token).ConfigureAwait(false);
                companyId = (string)profile?["companyId"];
            }
            return string.IsNullOrWhiteSpace(companyId) ? uid : companyId;
        }
        public static Task<T> Get<T>(string path) { return FirebaseRestClient.GetAsync<T>(path, Token); }
        public static Task Patch(string path, object value) { return FirebaseRestClient.PatchAsync(path, value, Token); }
        public static string Key(string value)
        {
            if (string.IsNullOrWhiteSpace(value) || value.IndexOfAny(new[] { '.', '#', '$', '[', ']', '/', '\\' }) >= 0)
                throw new ArgumentException("Invalid record identifier.");
            return value;
        }
        public static string Query(string path, string field, string value)
        {
            return path + "?orderBy=" + Uri.EscapeDataString(JsonConvert.SerializeObject(field)) + "&equalTo=" + Uri.EscapeDataString(JsonConvert.SerializeObject(value));
        }
        public static Task<Dictionary<string, JObject>> Collection(string path)
        {
            // Bind in the caller's execution context before creating the async operation.
            // A binding made only inside a child async method does not flow back to its caller.
            var session = RequestSession;
            return CollectionCore(path);
        }
        private static async Task<Dictionary<string, JObject>> CollectionCore(string path)
        {
            if (!path.Contains("?") && !path.Contains("/")) return await DatabaseSchema.Scoped(path).ConfigureAwait(false);
            return DatabaseSchema.Normalize(path.Split('?')[0], await Get<Dictionary<string, JObject>>(path).ConfigureAwait(false) ?? new Dictionary<string, JObject>());
        }
        public static Task<JObject> ReadObject(string path)
        {
            var session = RequestSession;
            return ReadObjectCore(path);
        }
        private static async Task<JObject> ReadObjectCore(string path)
        {
            if (path.Contains("/")) return await Get<JObject>(path).ConfigureAwait(false);
            return JObject.FromObject(await Collection(path).ConfigureAwait(false));
        }
        public static async Task<JObject> SubmissionForTask(string taskId, string studentId)
        {
            var rows = await Collection(Query("submissions", "taskId", Key(taskId))).ConfigureAwait(false);
            return rows.Values.Where(x => (string)x["studentId"] == studentId)
                .OrderByDescending(x => DatabaseSchema.FirstText(x, "updatedAt", "submittedAt")).FirstOrDefault();
        }
        public static async Task<JObject> EvaluationForPlacement(string studentId, string internshipId, string role)
        {
            var rows = await Collection(Query("evaluations", "internshipId", Key(internshipId))).ConfigureAwait(false);
            return rows.Values.Where(x => (string)x["studentId"] == studentId && (string)x["evaluatorRole"] == role)
                .OrderByDescending(x => string.Equals((string)x["status"], "submitted", StringComparison.OrdinalIgnoreCase))
                .ThenByDescending(x => (string)x["submittedAt"]).FirstOrDefault();
        }
        public static async Task<JObject> CompletionForStudent(string uid)
        {
            var placement = await PlacementForStudent(uid).ConfigureAwait(false);
            if (placement == null) return null;
            var rows = await Collection(Query("completionReports", "internshipId", DatabaseSchema.Id(placement))).ConfigureAwait(false);
            return rows.Values.Where(x => (string)x["studentId"] == uid).OrderByDescending(DatabaseSchema.ReportApproved).FirstOrDefault();
        }
        public static async Task<JObject> PlacementForRecord(JObject record)
        {
            string id = (string)record?["internshipId"];
            var placement = !string.IsNullOrWhiteSpace(id) ? await Get<JObject>("internships/" + Key(id)).ConfigureAwait(false)
                : await PlacementForStudent((string)record?["studentId"]).ConfigureAwait(false);
            if (placement == null || (string)placement["studentId"] != (string)record?["studentId"])
                throw new InvalidOperationException("This record has no matching internship.");
            return placement;
        }
        public static async Task<JObject> CompanyTask(string id)
        {
            string companyId = CompanyId;
            var task = await Get<JObject>("tasks/" + Key(id)).ConfigureAwait(false);
            if (task == null) throw new InvalidOperationException("Task not found.");
            var placement = await PlacementForRecord(task).ConfigureAwait(false);
            if ((string)placement["companyId"] != companyId && (string)placement["companySupervisorId"] != ProfileId)
                throw new InvalidOperationException("This task does not belong to your company.");
            foreach (string field in new[] { "companyId", "academicSupervisorId" }) task[field] = (string)placement[field];
            task["status"] = DatabaseSchema.WorkflowStatus((string)task["status"]);
            return task;
        }
        public static async Task<JObject> PlacementForStudent(string studentId)
        {
            string role = PortalRoles.Normalize(Convert.ToString(RequestSession["userRole"]));
            var placements = role == "company" || role == "academic" ? await Collection("internships").ConfigureAwait(false)
                : await Collection(Query("internships", "studentId", studentId)).ConfigureAwait(false);
            placements = placements.Where(x => (string)x.Value["studentId"] == studentId).ToDictionary(x => x.Key, x => x.Value);
            var active = placements.Values.Where(x => string.Equals((string)x["status"], "active", StringComparison.OrdinalIgnoreCase)).ToList();
            if (active.Count > 1) throw new InvalidOperationException("More than one active internship exists for this student. Ask the coordinator to correct the duplicate placements.");
            return active.SingleOrDefault() ?? placements.Values.Where(x => string.Equals((string)x["status"], "completed", StringComparison.OrdinalIgnoreCase)).OrderByDescending(x => (string)x["endDate"]).FirstOrDefault();
        }
        public static async Task EnsurePlacement(string studentId, string applicationId)
        {
            // The immutable confirmation is the lock. Retrying this projection is safe after a network failure.
            var confirmation = await Get<JObject>("internshipConfirmations/" + Key(studentId));
            if ((string)confirmation?["applicationId"] != applicationId)
                throw new InvalidOperationException("Confirm this internship offer first.");
            var app = await Get<JObject>("applications/" + Key(applicationId));
            if (app == null || (string)app["studentId"] != studentId || !string.Equals((string)app["status"], "Approved", StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("The company has not approved this application.");
            var existing = await PlacementForStudent(studentId);
            if (existing != null) { if ((string)existing["opportunityId"] != (string)app["opportunityId"]) throw new InvalidOperationException("A different internship is already confirmed."); return; }
            var student = await Get<JObject>("students/" + studentId) ?? new JObject();
            var opportunity = await Get<JObject>("opportunities/" + (string)app["opportunityId"]) ?? new JObject();
            string companyId = (string)app["companyId"];
            string academicId = (string)student["academicSupervisorId"] ?? "";
            var placement = new JObject
            {
                ["studentId"] = studentId, ["studentName"] = (string)student["fullName"],
                ["applicationId"] = applicationId, ["opportunityId"] = (string)app["opportunityId"],
                ["opportunityTitle"] = (string)opportunity["title"], ["companyId"] = companyId,
                ["academicSupervisorId"] = academicId, ["requiredHours"] = (int?)student["requiredHours"] ?? (int?)student["requiredTrainingHours"] ?? 0,
                ["approvedHours"] = 0, ["status"] = "active", ["startDate"] = (string)app["details"]?["trainingStartDate"],
                ["endDate"] = (string)app["details"]?["trainingEndDate"], ["createdAt"] = DateTime.UtcNow.ToString("o")
            };
            await Patch("", new Dictionary<string, object>
            {
                { "internships/" + studentId, placement },
                { "applications/" + applicationId + "/studentResponse", new { decision = "Accepted", respondedAt = DateTime.UtcNow } },
                { "applications/" + applicationId + "/studentConfirmed", true },
                { "applications/" + applicationId + "/isOfferConfirmed", true },
                { "students/" + studentId + "/companyId", companyId },
                { "students/" + studentId + "/internshipId", studentId }
            });
        }
    }
}

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using Newtonsoft.Json.Linq;

namespace PSUTInternship.Shared
{
    // Coordinator pages use the same authenticated transport and normalized records as the portal.
    public static class CoordinatorData
    {
        public static void RequireCoordinator()
        {
            var session = PortalRepository.RequestSession;
            if (string.IsNullOrEmpty(PortalRepository.UserId) || string.IsNullOrEmpty(PortalRepository.Token) ||
                PortalRoles.Normalize(Convert.ToString(session["userRole"])) != "admin")
                throw new HttpException(403, "Coordinator access required.");
        }

        public static async Task<JObject> Read(string path)
        {
            RequireCoordinator();
            try { return await PortalRepository.ReadObject(path) ?? new JObject(); }
            catch (System.Net.Http.HttpRequestException ex)
            {
                throw new InvalidOperationException("Could not load " + path.Split('/')[0] + ". " + ex.Message, ex);
            }
        }

        public static IEnumerable<KeyValuePair<string, JObject>> Items(JObject rows)
        {
            return (rows ?? new JObject()).Properties().Where(x => x.Value is JObject)
                .Select(x => new KeyValuePair<string, JObject>(x.Name, (JObject)x.Value));
        }
        public static JObject Get(JObject rows, string id) { return rows?[id ?? ""] as JObject ?? new JObject(); }
        public static string Str(JObject row, string field, string fallback = "")
        { return string.IsNullOrWhiteSpace((string)row?[field]) ? fallback : (string)row[field]; }
        public static decimal Number(JObject row, string field, decimal fallback = 0)
        {
            decimal value;
            return decimal.TryParse((string)row?[field], NumberStyles.Number, CultureInfo.InvariantCulture, out value) ? value : fallback;
        }
        public static JObject FindStudent(JObject students, JObject users, string uid)
        {
            var result = (JObject)Get(users, uid).DeepClone();
            result.Merge(Get(students, uid));
            return result;
        }
        public static bool BelongsTo(JObject row, string internshipId, string studentId)
        {
            string assigned = Str(row, "internshipId");
            return assigned.Length > 0 ? assigned == internshipId : Str(row, "studentId") == studentId;
        }
        public static decimal ApprovedHours(JObject hours, string internshipId, string studentId)
        {
            return Items(hours).Where(x => BelongsTo(x.Value, internshipId, studentId) &&
                string.Equals(Str(x.Value, "status"), "Approved", StringComparison.OrdinalIgnoreCase))
                .Sum(x => Number(x.Value, "hours"));
        }
        public static JObject Evaluation(JObject evaluations, string internshipId, string studentId, string role)
        {
            return Items(evaluations).Select(x => x.Value).Where(x => BelongsTo(x, internshipId, studentId) &&
                Str(x, "studentId") == studentId && PortalRoles.Normalize(Str(x, "evaluatorRole")) == PortalRoles.Normalize(role))
                .OrderByDescending(x => string.Equals(Str(x, "status"), "submitted", StringComparison.OrdinalIgnoreCase))
                .ThenByDescending(x => Str(x, "submittedAt")).FirstOrDefault();
        }
        public static string EvaluationStatus(JObject evaluation)
        {
            if (!string.Equals(Str(evaluation, "status"), "submitted", StringComparison.OrdinalIgnoreCase)) return "Pending";
            string recommendation = Str(evaluation, "recommendation");
            if (recommendation.Equals("Not Pass", StringComparison.OrdinalIgnoreCase) || recommendation.Equals("Fail", StringComparison.OrdinalIgnoreCase)) return "Not Pass";
            decimal maximum = PortalRoles.Normalize(Str(evaluation, "evaluatorRole")) == "academic"
                ? EvaluationPolicy.AcademicMaximum : Number(evaluation, "totalMaximum");
            decimal score = Number(evaluation, "overallScore", -1);
            if (maximum <= 0 || score < 0 || score > maximum) return "Pending";
            return score / maximum * 100 >= EvaluationPolicy.PassGrade ? "Pass" : "Not Pass";
        }
        public static string TaskStatus(JObject task)
        {
            string status = DatabaseSchema.WorkflowStatus(Str(task, "status"));
            return status == "Reviewed" ? "Reviewed" : string.IsNullOrEmpty(status) ? "Assigned" : status;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PSUTInternship.Shared
{
    // Read the supplied Firebase schema without changing record IDs or rewriting existing data.
    public static class DatabaseSchema
    {
        private sealed class RecordIdentity { public string Id; }
        public static string Id(JObject record)
        {
            var identity = record == null ? null : record.Annotation<RecordIdentity>();
            if (identity == null) throw new InvalidOperationException("The database record identifier is missing.");
            return identity.Id;
        }
        public static bool IsOpen(string value)
        {
            return new[] { "true", "active", "open" }.Contains((value ?? "").Trim().ToLowerInvariant());
        }
        public static string WorkflowStatus(string value)
        {
            switch ((value ?? "").Trim().ToLowerInvariant().Replace('_', ' '))
            {
                case "assigned": return "Assigned";
                case "pending": return "Pending";
                case "submitted": return "Submitted";
                case "complete": case "completed": case "reviewed": return "Reviewed";
                case "resolve": case "revision requested": case "revisionrequested": return "Revision Requested";
                case "accepted": case "approved": return "Approved";
                case "rejected": return "Rejected";
                default: return value;
            }
        }
        public static bool ReportApproved(JObject report)
        {
            return report != null && ((bool?)report["approvedByCoordinator"] == true ||
                string.Equals((string)report["status"], "approved", StringComparison.OrdinalIgnoreCase));
        }
        public static Dictionary<string, JObject> Normalize(string collection, Dictionary<string, JObject> records)
        {
            foreach (var item in records)
            {
                var row = item.Value;
                row.RemoveAnnotations<RecordIdentity>();
                row.AddAnnotation(new RecordIdentity { Id = item.Key });
                if (new[] { "tasks", "submissions", "taskFeedback", "trainingHours", "applications" }.Contains(collection) && row["status"] != null)
                    row["status"] = WorkflowStatus((string)row["status"]);
                if (collection == "tasks") {
                    string status = ((string)row["status"] ?? "").Trim().ToLowerInvariant();
                    if (status == "pending" || status == "in progress") row["status"] = "Assigned";
                    if (status == "pending review") row["status"] = "Submitted";
                }
                if (collection == "students")
                {
                    if (row["role"] == null) row["role"] = "student";
                    if (row["requiredHours"] == null && row["requiredTrainingHours"] != null) row["requiredHours"] = row["requiredTrainingHours"].DeepClone();
                }
                if (collection == "submissions")
                {
                    if (string.IsNullOrWhiteSpace((string)row["attachmentUrl"]))
                        row["attachmentUrl"] = FirstText(row, "fileUrl", "submissionLink");
                    if (string.IsNullOrWhiteSpace((string)row["updatedAt"])) row["updatedAt"] = (string)row["submittedAt"];
                }
            }
            return records;
        }
        public static string FirstText(JObject row, params string[] names)
        {
            return names.Select(n => (string)row?[n]).FirstOrDefault(x => !string.IsNullOrWhiteSpace(x)) ?? "";
        }
        internal static async Task<Dictionary<string, JObject>> Raw(string collection, string field = null, string value = null)
        {
            string path = field == null ? collection : PortalRepository.Query(collection, field, value);
            return Normalize(collection, await PortalRepository.Get<Dictionary<string, JObject>>(path).ConfigureAwait(false) ?? new Dictionary<string, JObject>());
        }
        private static void Merge(Dictionary<string, JObject> target, Dictionary<string, JObject> source)
        { foreach (var row in source) target[row.Key] = row.Value; }

        // These reverse links let database rules authorize individual profile reads.
        // Only the coordinator fills missing fields; existing assignments are never overwritten.
        public static async Task SynchronizeLinks()
        {
            if (PortalRoles.Normalize(Convert.ToString(PortalRepository.RequestSession["userRole"])) != "admin")
                throw new UnauthorizedAccessException("Only the coordinator can connect existing records.");
            var students = await Raw("students").ConfigureAwait(false);
            var placements = await Raw("internships").ConfigureAwait(false);
            var changes = new Dictionary<string, object>();
            foreach (var group in placements.Where(x => string.Equals((string)x.Value["status"], "active", StringComparison.OrdinalIgnoreCase)).GroupBy(x => (string)x.Value["studentId"]))
            {
                if (group.Count() != 1 || !students.ContainsKey(group.Key)) continue;
                var placement = group.Single(); var student = students[group.Key];
                if (string.IsNullOrWhiteSpace((string)student["internshipId"])) changes["students/" + Key(group.Key) + "/internshipId"] = placement.Key;
                foreach (string field in new[] { "companyId", "academicSupervisorId" })
                    if (string.IsNullOrWhiteSpace((string)student[field]) && !string.IsNullOrWhiteSpace((string)placement.Value[field]))
                        changes["students/" + Key(group.Key) + "/" + field] = (string)placement.Value[field];
            }
            if (changes.Count > 0) await PortalRepository.Patch("", changes).ConfigureAwait(false);
        }
        private static string Key(string value) { return PortalRepository.Key(value); }

        public static async Task<Dictionary<string, JObject>> Scoped(string collection)
        {
            string role = PortalRoles.Normalize(Convert.ToString(PortalRepository.RequestSession["userRole"]));
            if (role == "admin") return await Raw(collection).ConfigureAwait(false);
            if (role == "student" && new[] { "tasks", "submissions", "taskFeedback", "internships", "trainingHours", "applications", "evaluations", "reports", "completionReports" }.Contains(collection))
                return await Raw(collection, "studentId", PortalRepository.UserId).ConfigureAwait(false);
            if (collection == "studentGroups") return await Raw(collection, "academicSupervisorId", PortalRepository.ProfileId).ConfigureAwait(false);
            if (collection == "internships")
            {
                var placements = await Raw(collection, role == "company" ? "companyId" : "academicSupervisorId", role == "company" ? PortalRepository.CompanyId : PortalRepository.ProfileId).ConfigureAwait(false);
                if (role == "company") Merge(placements, await Raw(collection, "companySupervisorId", PortalRepository.ProfileId).ConfigureAwait(false));
                return placements;
            }
            if (collection == "students")
            {
                var students = new Dictionary<string, JObject>();
                if (role == "student")
                {
                    var own = await PortalRepository.Get<JObject>("students/" + PortalRepository.Key(PortalRepository.UserId)).ConfigureAwait(false);
                    if (own != null) students[PortalRepository.UserId] = own;
                }
                else if (role == "company")
                {
                    foreach (var placement in (await Scoped("internships").ConfigureAwait(false)).Values)
                    {
                        string uid = (string)placement["studentId"];
                        var student = await PortalRepository.Get<JObject>("students/" + PortalRepository.Key(uid)).ConfigureAwait(false);
                        if (student != null) students[uid] = student;
                    }
                }
                else
                {
                    Merge(students, await Raw("students", "academicSupervisorId", PortalRepository.ProfileId).ConfigureAwait(false));
                    var groups = await Scoped("studentGroups").ConfigureAwait(false);
                    var supervisor = await PortalRepository.Get<JObject>("academicSupervisors/" + PortalRepository.Key(PortalRepository.ProfileId)).ConfigureAwait(false);
                    var members = groups.Values.SelectMany(g => (g["studentIds"] as JObject ?? new JObject()).Properties());
                    var nested = (supervisor?["groups"] as JObject ?? new JObject()).Properties()
                        .SelectMany(g => (g.Value["assignedStudentIds"] as JObject ?? new JObject()).Properties());
                    foreach (var uid in members.Concat(nested).Where(x => x.Value.Type == JTokenType.Boolean && (bool)x.Value).Select(x => x.Name).Distinct())
                    {
                        JObject student;
                        try { student = await PortalRepository.Get<JObject>("students/" + PortalRepository.Key(uid)).ConfigureAwait(false); }
                        catch (System.Net.Http.HttpRequestException ex) when (ex.Message.Contains("403")) { continue; }
                        if (student != null && (string.IsNullOrEmpty((string)student["academicSupervisorId"]) || (string)student["academicSupervisorId"] == PortalRepository.ProfileId)) students[uid] = student;
                    }
                }
                return Normalize(collection, students);
            }
            if (new[] { "tasks", "trainingHours", "evaluations", "taskFeedback", "reports", "completionReports" }.Contains(collection))
            {
                var rows = new Dictionary<string, JObject>();
                foreach (var placement in await Scoped("internships").ConfigureAwait(false))
                {
                    var related = await Raw(collection, "internshipId", placement.Key).ConfigureAwait(false);
                    foreach (var item in related.Values)
                    {
                        if (item["companyId"] == null) item["companyId"] = (string)placement.Value["companyId"];
                        if (item["academicSupervisorId"] == null) item["academicSupervisorId"] = (string)placement.Value["academicSupervisorId"];
                    }
                    Merge(rows, related);
                }
                return rows;
            }
            if (collection == "submissions")
            {
                var submissions = new Dictionary<string, JObject>();
                foreach (var task in await Scoped("tasks").ConfigureAwait(false))
                {
                    var related = await Raw(collection, "taskId", task.Key).ConfigureAwait(false);
                    foreach (var row in related.Values)
                        foreach (string field in new[] { "companyId", "academicSupervisorId", "internshipId" })
                            if (row[field] == null) row[field] = (string)task.Value[field];
                    Merge(submissions, related);
                }
                return submissions;
            }
            if (collection == "applications" && role == "academic")
            {
                var rows = new Dictionary<string, JObject>();
                foreach (string uid in (await Scoped("students").ConfigureAwait(false)).Keys)
                    Merge(rows, await Raw(collection, "studentId", uid).ConfigureAwait(false));
                return rows;
            }
            // The transport applies direct ownership filters to opportunities and profile lists.
            return await Raw(collection).ConfigureAwait(false);
        }
    }

    public sealed class OpportunityStatusConverter : JsonConverter
    {
        public override bool CanConvert(Type objectType) { return objectType == typeof(bool); }
        public override object ReadJson(JsonReader reader, Type type, object existing, JsonSerializer serializer)
        {
            string value = Convert.ToString(reader.Value, CultureInfo.InvariantCulture);
            if (DatabaseSchema.IsOpen(value)) return true;
            if (new[] { "false", "inactive", "closed", "" }.Contains((value ?? "").ToLowerInvariant())) return false;
            throw new JsonSerializationException("Unknown opportunity status: " + value);
        }
        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        { writer.WriteValue((bool)value ? "active" : "closed"); }
    }
}

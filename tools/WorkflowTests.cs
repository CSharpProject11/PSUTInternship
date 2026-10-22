// Offline workflow tests. Firebase operations use the in-memory adapter below.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSUTInternship.Models;
using PSUTInternship.Shared;

public static class WorkflowTests
{
    private static int passed;
    static void Assert(bool condition, string description)
    { if (!condition) throw new Exception(description); passed++; Console.WriteLine("PASS " + description); }
    static async Task Reject(Func<Task> operation, string description)
    { bool rejected = false; try { await operation(); } catch (Exception) { rejected = true; } Assert(rejected, description); }
    static void Identity(string uid, string role, string company = null)
    {
        var context = new HttpContext(new HttpRequest("", "http://localhost/", ""), new HttpResponse(new StringWriter()));
        SessionStateUtility.AddHttpSessionStateToContext(context, new HttpSessionStateContainer("offline-tests", new SessionStateItemCollection(), new HttpStaticObjectsCollection(), 20, true, HttpCookieMode.UseCookies, SessionStateMode.InProc, false));
        HttpContext.Current = context;
        PortalRepository.Bind(context);
        context.Session["userId"] = uid; context.Session["profileId"] = uid; context.Session["userRole"] = role;
        context.Session["companyId"] = company ?? uid; context.Session["idToken"] = "offline-test-token";
    }
    static void Set(string path, object value) { FirebaseRestClient.Set(path, value); }
    public static int Main(string[] args)
    {
        try { if (args.Length > 1 && !string.IsNullOrWhiteSpace(args[1])) ValidateExport(args[1]); Run(args.Length > 0 ? args[0] : ".").GetAwaiter().GetResult(); Console.WriteLine(passed + " assertions passed; no network requests were made."); return 0; }
        catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
    }
    private static void ValidateExport(string path)
    {
        var data = JObject.Parse(File.ReadAllText(path));
        foreach (var item in (data["opportunities"] as JObject ?? new JObject()).Properties())
        { item.Value.ToObject<Opportunity>(); item.Value.ToObject<CompanyOpportunity>(); }
        foreach (var item in (data["applications"] as JObject ?? new JObject()).Properties())
        { item.Value.ToObject<PSUTInternship.Models.Application>(); item.Value.ToObject<CompanyApplication>(); }
        foreach (var item in (data["students"] as JObject ?? new JObject()).Properties()) item.Value.ToObject<StudentInfo>();
        foreach (var item in (data["internships"] as JObject ?? new JObject()).Properties()) item.Value.ToObject<CompanyTrainee>();
        foreach (var item in (data["tasks"] as JObject ?? new JObject()).Properties()) item.Value.ToObject<StudentTask>();
        foreach (var item in (data["submissions"] as JObject ?? new JObject()).Properties()) item.Value.ToObject<TaskSubmission>();
        Assert(true, "all supplied export records deserialize using the actual application models");
    }
    private static async Task Run(string output)
    {
        Assert(PortalRoles.Normalize("Academic Supervisor") == "academic" && PortalRoles.Normalize("coordinator") == "admin", "legacy role names use the same authorization roles");
        Identity("coordinator-check", "coordinator");
        CoordinatorData.RequireCoordinator();
        var logs = JObject.Parse("{ 'a':{'internshipId':'current','studentId':'s','hours':2.5,'status':'approved'},'b':{'internshipId':'old','studentId':'s','hours':90,'status':'Approved'},'c':{'internshipId':'current','studentId':'s','hours':3,'status':'Pending'}}");
        Assert(CoordinatorData.ApprovedHours(logs, "current", "s") == 2.5m, "monitor totals preserve fractional hours and exclude other placements and pending logs");
        Assert(!CoordinatorData.BelongsTo(JObject.Parse("{'internshipId':'old','studentId':'s'}"), "current", "s"), "a student match cannot override an explicit different placement");
        Assert(CoordinatorData.TaskStatus(JObject.Parse("{'status':'reviewed'}")) == "Reviewed", "monitor displays the actual reviewed task state");
        Assert(CoordinatorData.EvaluationStatus(JObject.Parse("{'status':'draft','overallScore':100,'totalMaximum':100}")) == "Pending", "draft evaluations cannot appear as passing");
        Identity("student-check", "student");
        await Reject(() => Task.Run(() => CoordinatorData.RequireCoordinator()), "coordinator data rejects student access");
        await Task.Run(async () =>
        {
            Identity("async-user", "coordinator");
            var context = HttpContext.Current;
            context.Session["profileId"] = "async-profile";
            context.Session["companyId"] = "async-company";
            // Reproduce a fresh ASP.NET callback where the earlier page binding is absent.
            PortalRepository.Bind(null);
            await PortalRepository.Collection("internships");
            await Task.Delay(1).ConfigureAwait(false);
            HttpContext.Current = null;
            Assert(PortalRepository.ProfileId == "async-profile" && PortalRepository.CompanyId == "async-company" && PortalRepository.Token == "offline-test-token", "async collection callers retain profile, company and token without HttpContext.Current");
            HttpContext.Current = new HttpContext(new HttpRequest("", "http://localhost/", ""), new HttpResponse(new StringWriter()));
            Assert(PortalRepository.ProfileId == "async-profile", "a sessionless ambient context does not override the bound request session");
        });
        await Task.WhenAll(new[] { "parallel-a", "parallel-b" }.Select(uid => Task.Run(async () =>
        {
            Identity(uid, "coordinator");
            await Task.Delay(5).ConfigureAwait(false);
            HttpContext.Current = null;
            if (PortalRepository.ProfileId != uid) throw new Exception("Cross-request session leak.");
        })));
        Assert(true, "parallel requests retain separate user sessions");
        await Task.Run(() =>
        {
            HttpContext.Current = null;
            PortalRepository.Bind(null);
            bool expired = false;
            try { var profile = PortalRepository.ProfileId; }
            catch (HttpException ex) { expired = ex.GetHttpCode() == 401; }
            Assert(expired, "missing sessions return an explicit authentication error instead of a null reference");
        });
        var opportunity = new CompanyOpportunity { Title = "Software internship", IsOpen = true, Deadline = "2026-11-30", Seats = 2, Specialization = "Software Engineering" };
        var studentOpportunity = JsonConvert.DeserializeObject<Opportunity>(JsonConvert.SerializeObject(opportunity));
        Assert(studentOpportunity.Status && studentOpportunity.DeadLine.Year == 2026, "company opportunities deserialize in student pages");
        Assert(OpportunityEligibility.Matches(studentOpportunity, JObject.FromObject(new { major = "Software Engineering" })), "matching major is eligible");
        Assert(OpportunityEligibility.Matches(studentOpportunity, JObject.FromObject(new { major = "Accounting" })), "role specialization does not hide opportunities from other majors");
        var backend = JsonConvert.DeserializeObject<Opportunity>("{\"title\":\"backend\",\"specialization\":\"developer\",\"status\":\"active\",\"deadline\":\"2026-10-24\"}");
        Assert(backend.Status && OpportunityEligibility.Matches(backend, JObject.FromObject(new { major = "Software Engineering" })), "backend with developer specialization remains visible and eligible");
        backend.College = "Engineering";
        Assert(!OpportunityEligibility.Matches(backend, JObject.FromObject(new { college = "Business" })), "explicit college restrictions remain enforced");
        Assert(EvaluationPolicy.FinalGrade(16, 20, 90) == 84, "weighted results normalize different grading scales");
        await Reject(() => Task.Run(() => EvaluationPolicy.FinalGrade(21, 20, 90)), "scores above a criterion maximum are rejected");

        Identity("student-a", "student");
        Set("students/student-a", new { fullName = "Student A", studentNumber = "20260001", requiredHours = 8, academicSupervisorId = "academic-a" });
        Set("opportunities/opening-a", new { title = "Software internship", companyId = "company-a" });
        Set("applications/student-a_opening-a", new { studentId = "student-a", opportunityId = "opening-a", companyId = "company-a", status = "Approved", details = new { trainingStartDate = "2026-10-01", trainingEndDate = "2026-12-01" } });
        await Reject(() => PortalRepository.EnsurePlacement("student-a", "student-a_opening-a"), "approval alone does not create a placement");
        Set("internshipConfirmations/student-a", new { applicationId = "student-a_opening-a", confirmedAt = DateTime.UtcNow });
        await PortalRepository.EnsurePlacement("student-a", "student-a_opening-a");
        Assert((string)FirebaseRestClient.Data["internships"]["student-a"]["companyId"] == "company-a", "student confirmation connects the placement to the company");
        Set("internships/student-a/approvedHours", 4);
        await PortalRepository.EnsurePlacement("student-a", "student-a_opening-a");
        Assert((int)FirebaseRestClient.Data["internships"]["student-a"]["approvedHours"] == 4, "confirmation retries preserve existing placement progress");
        await Reject(() => PortalRepository.EnsurePlacement("student-a", "another-offer"), "a different offer cannot replace the confirmed placement");

        Identity("company-a", "Company Supervisor");
        await Reject(() => TaskWorkflow.Create("Task one", "A meaningful task description", "Quality of work", "Normal", 20, DateTime.Today.AddDays(2), new[] { "other-student" }), "companies cannot assign tasks to unrelated students");
        await TaskWorkflow.Create("Task one", "A meaningful task description", "Quality of work", "Normal", 20, DateTime.Today.AddDays(2), new[] { "student-a", "student-a" });
        var tasks = (JObject)FirebaseRestClient.Data["tasks"];
        Assert(tasks.Count == 1, "duplicate trainee selections create only one assignment");
        string taskId = tasks.Properties().Single().Name;
        Assert((string)tasks[taskId]["academicSupervisorId"] == "academic-a", "assignments carry the academic supervisor and placement identity");
        await Reject(() => TaskWorkflow.Review(taskId, "Reviewed", "Good work", 15), "unsubmitted tasks cannot be graded");
        Set("submissions/" + taskId, new { taskId = taskId, studentId = "student-a", companyId = "company-a", academicSupervisorId = "academic-a", status = "Submitted", answer = "Completed work" });
        await Reject(() => TaskWorkflow.Review(taskId, "Reviewed", "Good work", 21), "task review enforces the task's own maximum score");
        await TaskWorkflow.Review(taskId, "Revision Requested", "Please provide more detail", null);
        Assert((string)FirebaseRestClient.Data["tasks"][taskId]["status"] == "Revision Requested", "revision requests reach the student's task");
        await TaskWorkflow.Review(taskId, "Reviewed", "Complete and correct", 18);
        Assert((int)FirebaseRestClient.Data["tasks"][taskId]["score"] == 18 && ((JObject)FirebaseRestClient.Data["reviewHistory"][taskId]).Count == 2, "grading stores the score and preserves review history");
        Assert((int)FirebaseRestClient.Data["internships"]["student-a"]["approvedHours"] == 4, "task completion does not approve training hours");
        Identity("company-b", "Company Supervisor");
        await Reject(() => TaskWorkflow.Review(taskId, "Reviewed", "Foreign access", 10), "another company cannot review the task");

        Identity("student-a", "student");
        await TrainingHoursWorkflow.Submit(DateTime.Today, 8, "Training activities");
        await Reject(() => TrainingHoursWorkflow.Submit(DateTime.Today, 25, "Invalid day"), "a student cannot log more than 24 hours in one entry");
        string hourId = ((JObject)FirebaseRestClient.Data["trainingHours"]).Properties().Single().Name;
        Identity("company-a", "Company Supervisor");
        await TrainingHoursWorkflow.Review(hourId, true);
        Assert((decimal)FirebaseRestClient.Data["internships"]["student-a"]["approvedHours"] == 8, "approved hour logs update training progress");
        await TrainingHoursWorkflow.Review(hourId, true);
        Assert((decimal)FirebaseRestClient.Data["internships"]["student-a"]["approvedHours"] == 8, "repeated hour approval cannot count the same hours twice");

        Set("coordinatorReviewQueue/academic_student-a", new { studentId = "student-a", status = "pending" });
        await Reject(() => CompletionWorkflow.Approve("academic_student-a"), "a supervisor cannot approve internship completion");
        Identity("coordinator-a", "coordinator");
        await Reject(() => CompletionWorkflow.Approve("academic_student-a"), "completion requires both final evaluations");
        Set("evaluations/company_student-a", new { studentId="student-a", internshipId="student-a", evaluatorRole="companySupervisor", status = "submitted", overallScore = 16, totalMaximum = 20 });
        Set("evaluations/academic_student-a", new { studentId="student-a", internshipId="student-a", evaluatorRole="academicSupervisor", status = "submitted", overallScore = 90, evaluatorId = "academic-a", recommendation = "Pass" });
        Set("students/student-a/requiredHours", 9);
        await Reject(() => CompletionWorkflow.Approve("academic_student-a"), "insufficient approved hours prevent completion");
        Set("students/student-a/requiredHours", 8);
        Set("tasks/" + taskId + "/status", "Revision Requested");
        await Reject(() => CompletionWorkflow.Approve("academic_student-a"), "outstanding task revisions prevent completion");
        Set("tasks/" + taskId + "/status", "Reviewed");
        await CompletionWorkflow.Approve("academic_student-a");
        var report = (JObject)FirebaseRestClient.Data["completionReports"]["student-a"];
        Assert((decimal)report["finalGrade"] == 84 && (string)FirebaseRestClient.Data["internships"]["student-a"]["status"] == "completed", "coordinator approval publishes the report and completes the placement");
        await Reject(() => CompletionWorkflow.Approve("academic_student-a"), "approved completion reports cannot be overwritten");
        await Reject(() => TrainingHoursWorkflow.Review(hourId, false), "approved completion freezes the training hours");
        await SuppliedShape();
        report["studentName"] = "أحمد الطالب — Unicode verification";
        byte[] pdf = CompletionReportPdf.Create(report);
        Directory.CreateDirectory(output); File.WriteAllBytes(Path.Combine(output, "completion-report.pdf"), pdf);
        Assert(Encoding.ASCII.GetString(pdf, 0, 8).StartsWith("%PDF-1.4") && pdf.Length > 10000, "approved reports generate a printable PDF with Unicode names");
    }
    private static async Task SuppliedShape()
    {
        FirebaseRestClient.Data = JObject.Parse(File.ReadAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "database-shape.json")));
        var opening = FirebaseRestClient.Data["opportunities"]["opp1"].ToObject<Opportunity>();
        Assert(opening.Duration == "3 months" && opening.DurationDisplay == "3 months" && opening.Status, "text duration and active opportunity status deserialize from the supplied schema");
        Assert(FirebaseRestClient.Data["opportunities"]["opp1"].ToObject<CompanyOpportunity>().IsOpen, "both company and student models accept active openings");
        Assert(JsonConvert.DeserializeObject<Opportunity>("{\"duration\":3,\"status\":true}").DurationDisplay == "3 months", "numeric durations and boolean statuses remain compatible");
        var app = FirebaseRestClient.Data["applications"]["app1"].ToObject<CompanyApplication>();
        Assert(app.Cv == "https://example.test/cv.pdf" && app.Reason == "Application message" && !app.StudentConfirmed, "flat application fields map to the company view");
        Identity("student1", "student");
        var placement = await PortalRepository.PlacementForStudent("student1");
        Assert(DatabaseSchema.Id(placement) == "internship1", "placements retain arbitrary Firebase record keys");
        Assert(!DatabaseSchema.ReportApproved(await PortalRepository.CompletionForStudent("student1")), "pending reports with arbitrary keys are not downloadable");
        Assert(FirebaseRestClient.Data["submissions"]["submission1"].ToObject<TaskSubmission>().AttachmentUrl == "https://example.test/solution", "the submission model understands existing submissionLink values directly");
        var submission = await PortalRepository.SubmissionForTask("task1", "student1");
        Assert(DatabaseSchema.Id(submission) == "submission1" && (string)submission["attachmentUrl"] == "https://example.test/solution", "submissions resolve by taskId and support submissionLink");
        Set("tasks/task1/dueDate", DateTime.Today.AddDays(2).ToString("yyyy-MM-dd"));
        await TaskWorkflow.Submit("task1", "Updated solution", "https://example.test/new.pdf");
        Assert(((JObject)FirebaseRestClient.Data["submissions"]).Count == 1 && (string)FirebaseRestClient.Data["submissions"]["submission1"]["answer"] == "Updated solution", "resubmission updates the existing submission ID instead of creating a duplicate");
        Assert(await PortalRepository.ResolveCompanyId(JObject.FromObject(new { role="Company Supervisor" }), "superC1", "offline-test-token") == "company1", "a missing users.companyId resolves from the supervisor profile consistently");
        Identity("superC1", "Company Supervisor", "company1");
        var tasks = await PortalRepository.Collection("tasks");
        Assert(tasks.ContainsKey("task1") && (string)tasks["task1"]["companyId"] == "company1", "company task queries join internships when companyId is absent");
        Assert((await PortalRepository.Collection("trainingHours")).ContainsKey("hour1"), "legacy hour logs appear in the company workspace through internshipId");
        await Reject(() => TaskWorkflow.Review("task1", "Reviewed", "Good solution", 0), "a task with no maximum cannot silently receive a zero grade");
        await TaskWorkflow.ConfigureMaximum("task1", 10);
        await TaskWorkflow.Review("task1", "Reviewed", "Good solution", 8);
        Assert((string)FirebaseRestClient.Data["submissions"]["submission1"]["status"] == "Reviewed", "company review updates the linked submission rather than submissions/taskId");
        await TrainingHoursWorkflow.Review("hour1", true);
        Assert((decimal)FirebaseRestClient.Data["internships"]["internship1"]["approvedHours"] == 6 && FirebaseRestClient.Data["internships"]["student1"] == null, "approved hours update internship1 without creating an internship at the student's UID");
        await TaskWorkflow.Create("Second task", "A meaningful task description", "Quality of work", "Normal", 20, DateTime.Today.AddDays(2), new[] { "student1" });
        Assert(((JObject)FirebaseRestClient.Data["tasks"]).Properties().All(x => (string)x.Value["internshipId"] == "internship1"), "new assignments reference the existing internship ID");
        var evaluation = await PortalRepository.EvaluationForPlacement("student1", "internship1", "companySupervisor");
        Assert(DatabaseSchema.Id(evaluation) == "evaluation1" && (string)evaluation["status"] == "draft", "existing draft evaluations retain their actual Firebase keys");
        Identity("superA1", "Academic Supervisor");
        var students = await PortalRepository.Collection("students");
        Assert(students.ContainsKey("student1") && !students.ContainsKey("conflicting-student"), "root studentGroups assign students without overriding an explicit different supervisor");
        Assert((await PortalRepository.Collection("submissions")).ContainsKey("submission1"), "academic supervisors see submissions linked through internship and task relationships");
        Identity("unrelated", "Company Supervisor", "other-company");
        Assert((await PortalRepository.Collection("tasks")).Count == 0, "scoped relationship queries do not expose another company's tasks");
        await Reject(() => TaskWorkflow.Review("task1", "Reviewed", "Foreign review", 5), "legacy records still enforce company ownership during review");
        Identity("coordinator", "coordinator");
        await DatabaseSchema.SynchronizeLinks();
        Assert((string)FirebaseRestClient.Data["students"]["student1"]["internshipId"] == "internship1" && (string)FirebaseRestClient.Data["students"]["student1"]["companyId"] == "company1", "coordinator backfills missing reverse profile links from existing placements");
        Assert(FirebaseRestClient.Data["publicOpportunities"] == null, "schema preparation does not create duplicate opportunity previews");
        Assert((string)FirebaseRestClient.Data["students"]["conflicting-student"]["academicSupervisorId"] == "another-supervisor", "relationship synchronization preserves existing supervisor assignments");
        Set("students/student1/requiredTrainingHours", 6);
        foreach (var row in ((JObject)FirebaseRestClient.Data["tasks"]).Properties()) Set("tasks/"+row.Name+"/status", "reviewed");
        Set("evaluations/evaluation1/status", "submitted"); Set("evaluations/evaluation1/overallScore", 16); Set("evaluations/evaluation1/totalMaximum", 20);
        Set("evaluations/evaluation2", new { studentId="student1", internshipId="internship1", evaluatorRole="academicSupervisor", evaluatorId="superA1", status="submitted", recommendation="Pass", overallScore=90 });
        Set("coordinatorReviewQueue/evaluation2", new { studentId="student1", internshipId="internship1", status="pending" });
        await CompletionWorkflow.Approve("evaluation2");
        Assert(((JObject)FirebaseRestClient.Data["completionReports"]).Count == 1 && (string)FirebaseRestClient.Data["completionReports"]["report1"]["status"] == "approved", "completion promotes the existing pending report rather than creating a duplicate");
        Assert((string)FirebaseRestClient.Data["completionReports"]["report1"]["companyEvaluationId"] == "evaluation1", "completion follows the existing company evaluation ID");
    }

}

namespace PSUTInternship.Shared
{
    // This adapter is compiled only into the test executable, never into the website.
    public static class FirebaseRestClient
    {
        public static JObject Data = new JObject();
        public static void Set(string path, object value)
        {
            string[] parts = path.Trim('/').Split('/'); JObject node = Data;
            for (int i = 0; i < parts.Length - 1; i++) { if (!(node[parts[i]] is JObject)) node[parts[i]] = new JObject(); node = (JObject)node[parts[i]]; }
            node[parts.Last()] = value == null ? JValue.CreateNull() : JToken.FromObject(value);
        }
        public static Task<T> GetAsync<T>(string path, string token)
        {
            string[] split = path.Split('?'); JToken node = Data;
            foreach (string segment in split[0].Trim('/').Split('/')) if (segment.Length > 0) node = node == null ? null : node[segment];
            if (split.Length > 1 && node is JObject)
            {
                var query = HttpUtility.ParseQueryString(split[1]); string field = JsonConvert.DeserializeObject<string>(query["orderBy"]);
                string value = JsonConvert.DeserializeObject<string>(query["equalTo"]);
                node = new JObject(((JObject)node).Properties().Where(x => (field == "$key" ? x.Name : (string)x.Value[field]) == value).Select(x => new JProperty(x.Name, x.Value.DeepClone())));
            }
            return Task.FromResult(node == null ? default(T) : node.ToObject<T>());
        }
        public static Task PatchAsync<T>(string path, T value, string token)
        {
            var obj = JObject.FromObject(value);
            foreach (var item in obj.Properties()) Set((path.Length > 0 ? path.Trim('/') + "/" : "") + item.Name, item.Value);
            return Task.CompletedTask;
        }
        public static Task<string> PostAsync<T>(string path, T value, string token)
        { string id = Guid.NewGuid().ToString("N"); Set(path + "/" + id, value); return Task.FromResult("{\"name\":\"" + id + "\"}"); }
    }
    public static class FirebaseConfig
    {
        public static string DatabaseUrl = "https://offline.invalid/";
        public static HttpClient Client = new HttpClient(new MemoryHttp());
        private class MemoryHttp : HttpMessageHandler
        {
            protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellation)
            {
                string path = request.RequestUri.AbsolutePath.Trim('/').Replace(".json", "");
                if (request.Method == HttpMethod.Put) FirebaseRestClient.Set(path, JToken.Parse(request.Content.ReadAsStringAsync().GetAwaiter().GetResult()));
                var value = FirebaseRestClient.GetAsync<JToken>(path, "test").GetAwaiter().GetResult();
                var response = new HttpResponseMessage(HttpStatusCode.OK) { Content = new StringContent(value == null ? "null" : value.ToString(Formatting.None)) };
                response.Headers.ETag = new System.Net.Http.Headers.EntityTagHeaderValue("\"test-etag\"");
                return Task.FromResult(response);
            }
        }
    }
}

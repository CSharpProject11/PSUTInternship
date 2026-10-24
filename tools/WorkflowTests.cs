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
    private sealed class BlockedRequestContext : SynchronizationContext
    {
        public override void Post(SendOrPostCallback callback, object state) { /* Request thread is synchronously waiting, like Web Forms. */ }
    }
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
        byte[] workbook = SpreadsheetExport.Create(new[] { "Student ID", "Student", "Hours" }, new[] { new object[] { "00123", "مرحبا & <student>", 2.5m }, new object[] { "=1+1", "Example", 0 } });
        using (var archive = new System.IO.Compression.ZipArchive(new MemoryStream(workbook), System.IO.Compression.ZipArchiveMode.Read))
        {
            Assert(archive.GetEntry("[Content_Types].xml") != null && archive.GetEntry("xl/workbook.xml") != null, "placement export is a real XLSX package");
            var sheet = System.Xml.Linq.XDocument.Load(archive.GetEntry("xl/worksheets/sheet1.xml").Open());
            System.Xml.Linq.XNamespace sheetNs = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
            Assert(sheet.Descendants(sheetNs + "row").Count() == 3 && sheet.Descendants(sheetNs + "v").Any(x => x.Value == "2.5"), "Excel export preserves all rows and fractional hours as numbers");
            Assert(sheet.Descendants(sheetNs + "t").Any(x => x.Value == "00123") && sheet.Descendants(sheetNs + "t").Any(x => x.Value == "مرحبا & <student>") && !sheet.Descendants(sheetNs + "f").Any(), "Excel export preserves IDs and Unicode while treating formula-looking input as text");
            Assert((string)sheet.Descendants(sheetNs + "autoFilter").Single().Attribute("ref") == "A1:C3" && (string)sheet.Descendants(sheetNs + "pane").Single().Attribute("state") == "frozen", "Excel export has complete filters and a frozen header");
        }
        File.WriteAllBytes(Path.Combine(output, "placements-export-fixture.xlsx"), workbook);
        string draft = ContactReplyMailer.DraftUri("student+intern@example.com", "Hours & progress? #1", "Hello & welcome\r\nمرحبا");
        Assert(draft.StartsWith("https://mail.google.com/mail/?view=cm&fs=1&to=student%2Bintern%40example.com&su="), "contact reply recipient comes from the stored email and preserves plus addressing");
        var draftQuery = HttpUtility.ParseQueryString(draft.Substring(draft.IndexOf('?') + 1));
        Assert(draftQuery["su"] == "Re: Hours & progress? #1" && draftQuery["body"] == "Hello & welcome\r\nمرحبا" && draftQuery.Count == 5, "Gmail draft escapes subject, multiline Unicode body and header-like punctuation");
        bool invalidEmail = false;
        try { ContactReplyMailer.DraftUri("person@example.com\r\nBcc:other@example.com", "Subject", "Body"); } catch (FormatException) { invalidEmail = true; }
        Assert(invalidEmail, "Gmail draft rejects a recipient containing injected headers");
        Assert(ContactReplyMailer.ResolveSetting("mail-test", (name, scope) => scope == EnvironmentVariableTarget.User ? "saved-user-value" : null) == "saved-user-value", "SMTP reads saved user settings when the server inherited an empty environment");
        Assert(ContactReplyMailer.ResolveSetting("mail-test", (name, scope) => scope == EnvironmentVariableTarget.Process ? "process-override" : "saved-value") == "process-override", "explicit server SMTP settings take priority over saved settings");
        Assert(ContactReplyMailer.ResolveSetting("mail-test", (name, scope) => scope == EnvironmentVariableTarget.Machine ? "machine-value" : " ") == "machine-value", "SMTP supports machine configuration when other scopes are empty");
        Assert(ContactReplyMailer.ResolveSetting("mail-test", (name, scope) => null) == null, "SMTP still reports missing configuration instead of inventing credentials");
        Assert(PortalRoles.Normalize("Academic Supervisor") == "academic" && PortalRoles.Normalize("coordinator") == "admin", "legacy role names use the same authorization roles");
        Identity("coordinator-check", "coordinator");
        CoordinatorData.RequireCoordinator();
        var logs = JObject.Parse("{ 'a':{'internshipId':'current','studentId':'s','hours':2.5,'status':'approved'},'b':{'internshipId':'old','studentId':'s','hours':90,'status':'Approved'},'c':{'internshipId':'current','studentId':'s','hours':3,'status':'Pending'}}");
        Assert(CoordinatorData.ApprovedHours(logs, "current", "s") == 2.5m, "monitor totals preserve fractional hours and exclude other placements and pending logs");
        Assert(!CoordinatorData.BelongsTo(JObject.Parse("{'internshipId':'old','studentId':'s'}"), "current", "s"), "a student match cannot override an explicit different placement");
        Assert(CoordinatorData.TaskStatus(JObject.Parse("{'status':'reviewed'}")) == "Reviewed", "monitor displays the actual reviewed task state");
        Assert(CoordinatorData.EvaluationStatus(JObject.Parse("{'status':'draft','overallScore':100,'totalMaximum':100}")) == "Pending", "draft evaluations cannot appear as passing");
        Assert(CoordinatorData.AcademicResult(null) == "—", "a missing academic review is not presented as a failure");
        Assert(CoordinatorData.AcademicResult(JObject.Parse("{'status':'draft','recommendation':'Pass'}")) == "—", "a draft recommendation is not a final academic result");
        Assert(CoordinatorData.AcademicResult(JObject.Parse("{'status':'submitted','recommendation':'Pass','overallScore':85}")) == "Pass", "academic display uses the submitted Pass recommendation");
        Assert(CoordinatorData.AcademicResult(JObject.Parse("{'status':'submitted','recommendation':'Not Pass','overallScore':85}")) == "Fail", "legacy Not Pass recommendations display consistently as Fail");
        Assert(CoordinatorData.AcademicResult(JObject.Parse("{'status':'submitted','recommendation':'More information required'}")) == "—", "an undecided legacy review is not relabeled as Fail");
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
        await Task.Run(async () =>
        {
            var originalData = FirebaseRestClient.Data;
            try
            {
                Identity("download-student", "student");
                FirebaseRestClient.Data = JObject.Parse("{'internships':{'download-placement':{'studentId':'download-student','status':'completed'}},'completionReports':{'download-report':{'studentId':'download-student','internshipId':'download-placement','status':'approved','approvedByCoordinator':true}}}");
                PortalRepository.Bind(null);
                var lookup = PortalRepository.CompletionForStudent("download-student");
                // The page callback can lose its ambient HttpContext after starting an async lookup.
                HttpContext.Current = null;
                Assert(PortalRepository.Token == "offline-test-token", "certificate lookup binds the signed-in session in the caller before async work");
                var approvedReport = await lookup.ConfigureAwait(false);
                Assert(DatabaseSchema.ReportApproved(approvedReport), "certificate lookup returns the approved report using the retained session");
            }
            finally { FirebaseRestClient.Data = originalData; }
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
        var progressTasks = new Dictionary<string,JObject> {
          {"one",JObject.FromObject(new {studentId="progress-student",status="Revision Requested",active=true})},
          {"two",JObject.FromObject(new {studentId="progress-student",status="Reviewed",active=true})},
          {"three",JObject.FromObject(new {studentId="progress-student",status="Pending",active=true})},
          {"archived",JObject.FromObject(new {studentId="progress-student",status="Reviewed",active=false})},
          {"foreign",JObject.FromObject(new {studentId="another-student",status="Submitted",active=true})}
        };
        var progressSubmissions = new[] { JObject.FromObject(new {taskId="one",studentId="progress-student"}), JObject.FromObject(new {taskId="one",studentId="progress-student"}), JObject.FromObject(new {taskId="two",studentId="progress-student"}), JObject.FromObject(new {taskId="three",studentId="another-student"}) };
        var taskProgress=TaskProgressSummary.Calculate("progress-student",progressTasks,progressSubmissions);
        Assert(taskProgress.Total==3&&taskProgress.Submitted==2&&taskProgress.Percentage==66.7m,"task progress counts unique owned submissions and excludes archived and foreign tasks");
        Assert(taskProgress.Revisions==1&&taskProgress.Reviewed==1&&taskProgress.Pending==1,"progress status totals preserve revision credit and pending work");
        Assert(TaskProgressSummary.Calculate("nobody",progressTasks,progressSubmissions).Percentage==0,"zero assigned tasks have zero progress");
        progressTasks["one"]["status"]="Reviewed";
        Assert(TaskProgressSummary.Calculate("progress-student",progressTasks,progressSubmissions).Submitted==2,"reviewing and resubmitting never inflate submission progress");
        Assert(DatabaseSchema.WorkflowStatus("Pending")=="Pending","Pending remains a distinct task status");
        foreach(string extension in new[]{".png",".pdf"}) {
            var fileId=Guid.NewGuid().ToString("N");var fileMeta=new JObject { ["id"]=fileId,["name"]="student-solution"+extension };
            string filePath=TaskFileStore.FilePath(fileId,"download-test","student-download");Directory.CreateDirectory(Path.GetDirectoryName(filePath));
            byte[] bytes=extension==".png"?new byte[]{137,80,78,71,13,10,26,10}:Encoding.ASCII.GetBytes("%PDF-1.4 sample");
            File.WriteAllBytes(filePath,bytes);
            Assert(TaskFileStore.Read(fileMeta,"download-test","student-download").SequenceEqual(bytes),"solution downloads preserve "+extension+" binary data and original metadata");
            bool missing=false;try{TaskFileStore.Read(fileMeta,"different-task","student-download");}catch(HttpException){missing=true;}
            Assert(missing,"solution file scope prevents downloading "+extension+" under another task");
            File.Delete(filePath);
        }
        Assert(AcademicCatalog.MatchesSupervisor("Software Engineering","Department of Software Engineering","Software Engineering"),"supervisor filtering accepts canonical department and specialization matches");
        Assert(!AcademicCatalog.MatchesSupervisor("Software Engineering","Software Engineering","Cyber Security"),"supervisor filtering excludes unrelated specializations");
        Assert(!AcademicCatalog.MatchesSupervisor("Software Engineering","","Software Engineering"),"supervisor filtering excludes missing departments");
        var beforeLoginData = FirebaseRestClient.Data;
        FirebaseRestClient.Data = JObject.Parse("{'opportunities':{'login-opening':{'companyId':'login-company','title':'Intern','availableSeats':5,'status':true}},'applications':{},'internships':{}}");
        FirebaseConfig.DelayResponses = true;
        var companyDashboardLoad = Task.Run(() => {
            Identity("login-company", "company", "login-company");
            SynchronizationContext.SetSynchronizationContext(new BlockedRequestContext());
            try { OpportunityCapacity.Synchronize().GetAwaiter().GetResult(); }
            finally { SynchronizationContext.SetSynchronizationContext(null); }
        });
        Assert(await Task.WhenAny(companyDashboardLoad, Task.Delay(2000)) == companyDashboardLoad, "company dashboard capacity loading completes without deadlocking its Web Forms request context");
        await companyDashboardLoad;
        var companyApproval = Task.Run(() => {
            Identity("login-company", "company", "login-company");
            Set("applications/login-app",new {companyId="login-company",studentId="login-student",opportunityId="login-opening",status="Pending"});
            SynchronizationContext.SetSynchronizationContext(new BlockedRequestContext());
            try { OpportunityCapacity.Reserve("login-app").GetAwaiter().GetResult(); }
            finally { SynchronizationContext.SetSynchronizationContext(null); }
        });
        Assert(await Task.WhenAny(companyApproval, Task.Delay(2000)) == companyApproval, "company approval completes without deadlocking its Web Forms request context");
        await companyApproval;
        FirebaseConfig.DelayResponses = false;
        FirebaseRestClient.Data = beforeLoginData;
        var capacityData = FirebaseRestClient.Data;
        Identity("seat-company", "company", "seat-company");
        FirebaseRestClient.Data = JObject.Parse("{'opportunities':{'seat-opening':{'companyId':'seat-company','title':'Intern','availableSeats':1,'status':true}},'applications':{'seat-one':{'studentId':'one','companyId':'seat-company','opportunityId':'seat-opening','status':'Pending'},'seat-two':{'studentId':'two','companyId':'seat-company','opportunityId':'seat-opening','status':'Pending'}}}");
        await OpportunityCapacity.Reserve("seat-one");
        Assert((int)FirebaseRestClient.Data["opportunities"]["seat-opening"]["occupiedSeats"] == 1 && !(bool)FirebaseRestClient.Data["opportunities"]["seat-opening"]["status"], "the final seat closes the opportunity immediately");
        await OpportunityCapacity.Reserve("seat-one");
        Assert((int)FirebaseRestClient.Data["opportunities"]["seat-opening"]["occupiedSeats"] == 1, "retrying the same approval does not allocate another seat");
        await Reject(() => OpportunityCapacity.Reserve("seat-two"), "approval cannot exceed the opportunity seat limit");
        var fullOpening = FirebaseRestClient.Data["opportunities"]["seat-opening"].ToObject<Opportunity>();
        Assert(fullOpening.IsFull && !fullOpening.IsAccepting && fullOpening.SeatsLabel == "0 of 1 seats available", "student details show full capacity and disable applications");
        Assert(JsonConvert.DeserializeObject<Opportunity>("{'status':true,'availableSeats':0}").IsFull && !JsonConvert.DeserializeObject<Opportunity>("{'status':true}").IsFull, "explicit zero seats closes applications while missing legacy capacity remains unspecified");
        Set("opportunities/seat-opening", new { companyId="seat-company",title="Intern",availableSeats=2,status=true });
        Set("applications/seat-one/status", "Approved");
        await OpportunityCapacity.Reserve("seat-two");
        Assert((int)FirebaseRestClient.Data["opportunities"]["seat-opening"]["occupiedSeats"] == 2 && !(bool)FirebaseRestClient.Data["opportunities"]["seat-opening"]["status"], "seat allocation accounts for pre-existing approved applications before reserving the last seat");
        FirebaseRestClient.Data = JObject.Parse("{'opportunities':{'orange':{'companyId':'seat-company','title':'Android Training','availableSeats':5,'status':true}},'applications':{'older-app':{'studentId':'one','companyId':'seat-company','opportunityId':'orange','status':'Approved'}},'internships':{'first':{'studentId':'one','companyId':'seat-company','opportunityId':'orange','applicationId':'older-app','status':'active'},'second':{'studentId':'two','companyId':'seat-company','opportunityId':'orange','status':'active'},'third':{'studentId':'three','companyId':'seat-company','opportunityId':'orange','status':'active'}}}");
        await OpportunityCapacity.Synchronize();
        var reconciledOpening = FirebaseRestClient.Data["opportunities"]["orange"].ToObject<Opportunity>();
        Assert(reconciledOpening.OccupiedSeats == 3 && reconciledOpening.SeatsLabel == "2 of 5 seats available", "legacy placements backfill three occupied seats without double-counting their approved application");
        await OpportunityCapacity.Synchronize();
        Assert((int)FirebaseRestClient.Data["opportunities"]["orange"]["occupiedSeats"] == 3, "repeated reconciliation does not inflate the existing student count");
        ((JObject)FirebaseRestClient.Data["opportunities"]["orange"]).Remove("occupiedSeats");
        ((JObject)FirebaseRestClient.Data["opportunities"]["orange"]).Remove("seatReservations");
        Identity("seat-student", "student");
        var liveCountOpening=FirebaseRestClient.Data["opportunities"]["orange"].ToObject<Opportunity>(); liveCountOpening.Id="orange";
        await OpportunityPresentation.Populate(new[]{liveCountOpening});
        Assert(liveCountOpening.SeatsLabel=="2 of 5 seats available", "student view derives the real seat count even when the saved counter is missing");
        Assert(new Opportunity {Status=true,AvailableSeats=5,CapacityUnavailable=true}.SeatsLabel=="Availability unavailable", "unverified capacity never renders a fabricated five free seats");
        await Reject(() => OpportunityCapacity.Synchronize(), "students cannot read other students or write opportunity capacity");
        FirebaseRestClient.Data = capacityData;
        var previousData = FirebaseRestClient.Data;
        Identity("preview-student", "student");
        FirebaseRestClient.Data = JObject.Parse(@"{ 'companies': { 'acme': { 'name': 'Acme', 'location': 'Amman' } }, 'applications': { 'legacy-random-id': { 'studentId': 'preview-student', 'opportunityId': 'one' } } }");
        var previews = new[] {
            new Opportunity { Id = "one", CompanyId = "acme", Status = true, DeadLine = DateTime.UtcNow.AddDays(1) },
            new Opportunity { Id = "two", CompanyId = "missing", Status = true, DeadLine = DateTime.UtcNow.AddDays(-1) },
            new Opportunity { Id = "three", CompanyId = "acme", Status = false }
        };
        await OpportunityPresentation.Populate(previews);
        Assert(previews[0].HasApplied && !previews[1].HasApplied, "legacy application IDs still mark the correct opportunity as applied");
        Assert(previews[0].CompanyName == "Acme" && previews[0].LocationDisplay == "Amman", "opportunity previews resolve company names and locations");
        Assert(previews[1].CompanyName == "Company not specified", "missing company data never displays a database ID");
        Assert(previews[0].IsAccepting && !previews[1].IsAccepting && !previews[2].IsAccepting, "expired and explicitly closed opportunities cannot accept applications");
        Assert(JsonConvert.DeserializeObject<Opportunity>(@"{ 'workType': 'Remote' }").WorkModeDisplay == "Remote", "legacy work type is shown in student opportunities");
        Assert(!previews.Any(x => x.HasConfirmedInternship), "an application without student confirmation does not lock further applications");
        Set("internshipConfirmations/preview-student", new { applicationId = "legacy-random-id", opportunityId = "one" });
        await OpportunityPresentation.Populate(previews);
        Assert(previews.All(x => x.HasConfirmedInternship), "immutable internship confirmation locks every opportunity before opening an application form");
        FirebaseRestClient.Data.Remove("internshipConfirmations");
        Set("internships/confirmed-placement", new { studentId = "preview-student", status = "active" });
        Assert(await OpportunityPresentation.HasConfirmedInternship("preview-student"), "existing active placements also disable new applications");
        FirebaseRestClient.Data = previousData;
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
        await TaskWorkflow.Review(taskId, "Revision Requested", "Please provide more detail", null, TaskWorkflow.Today.AddDays(3));
        Assert((string)FirebaseRestClient.Data["tasks"][taskId]["status"] == "Revision Requested", "revision requests reach the student's task");
        await TaskWorkflow.Review(taskId, "Reviewed", "Complete and correct", 18);
        Assert((int)FirebaseRestClient.Data["tasks"][taskId]["score"] == 18 && ((JObject)FirebaseRestClient.Data["reviewHistory"][taskId]).Count == 2, "grading stores the score and preserves review history");
        Assert((int)FirebaseRestClient.Data["internships"]["student-a"]["approvedHours"] == 4, "task completion does not approve training hours");
        FirebaseRestClient.Data["tasks"][taskId]["trainingHours"] = 30;
        await TaskWorkflow.Review(taskId, "Reviewed", "Training complete", 18);
        Assert((decimal)FirebaseRestClient.Data["internships"]["student-a"]["approvedHours"] == 30, "completed task credits 30 training hours");
        await TaskWorkflow.Review(taskId, "Reviewed", "Training complete again", 18);
        Assert((decimal)FirebaseRestClient.Data["internships"]["student-a"]["approvedHours"] == 30, "repeated task completion does not double count training hours");
        await TaskWorkflow.Review(taskId, "Revision Requested", "Further work required", null, TaskWorkflow.Today.AddDays(3));
        Assert((decimal)FirebaseRestClient.Data["internships"]["student-a"]["approvedHours"] == 0, "reopening a task removes its completion hours");
        FirebaseRestClient.Data["tasks"][taskId]["trainingHours"] = 130.5m;
        await TaskWorkflow.Review(taskId, "Reviewed", "All work complete", 18);
        Assert((decimal)FirebaseRestClient.Data["internships"]["student-a"]["approvedHours"] == 130.5m, "task training credits permit fractional hours and exceed daily log limits");
        ((JObject)FirebaseRestClient.Data["trainingHours"]).Remove("task_" + taskId);
        FirebaseRestClient.Data["tasks"][taskId]["trainingHours"] = 0;
        Set("internships/student-a/approvedHours", 4);

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
        await NewTaskRequirements();
        await SuppliedShape();
        report["studentName"] = "أحمد الطالب — Unicode verification";
        byte[] pdf = CompletionReportPdf.Create(report);
        Directory.CreateDirectory(output); File.WriteAllBytes(Path.Combine(output, "completion-report.pdf"), pdf);
        Assert(Encoding.ASCII.GetString(pdf, 0, 8).StartsWith("%PDF-1.4") && pdf.Length > 10000, "approved reports generate a printable PDF with Unicode names");
    }
    private static async Task NewTaskRequirements() {
        Identity("company-new", "Company Supervisor");
        Set("students/student-new", new { fullName="New trainee", academicSupervisorId="academic-new" });
        Set("internships/placement-new", new { studentId="student-new",companyId="company-new",academicSupervisorId="academic-new",opportunityId="opening-new",status="active" });
        await Reject(() => TaskWorkflow.Create("New task", "A valid description here", "Clear requirements", "Medium",TaskWorkflow.Today.AddDays(2),new[]{"student-new"},"wrong-opening"), "task assignment rejects a trainee from another opportunity");
        await TaskWorkflow.Create("New task", "A valid description here", "Clear requirements", "Medium",TaskWorkflow.Today.AddDays(2),new[]{"student-new"},"opening-new");
        var task = ((JObject)FirebaseRestClient.Data["tasks"]).Properties().Single(x=>(string)x.Value["studentId"]=="student-new");
        string id=task.Name;
        Assert(task.Value["maximumScore"].Type==JTokenType.Null && (string)task.Value["opportunityId"]=="opening-new" && DateTimeOffset.Parse((string)task.Value["createdAt"]).Year>2020, "score-free tasks persist opportunity and full creation date");
        Identity("student-new","student");
        await TaskWorkflow.Submit(id,"First solution","https://example.test/first.pdf");
        var first = await PortalRepository.SubmissionForTask(id,"student-new");
        Assert((string)first["fileUrl"]=="https://example.test/first.pdf", "student solution is retrievable for the exact task and student");
        Identity("company-new","Company Supervisor");
        await Reject(()=>TaskWorkflow.Review(id,"Revision Requested","Try again",null),"Resolve requires a new deadline");
        await Reject(()=>TaskWorkflow.Review(id,"Revision Requested","Try again",null,TaskWorkflow.Today),"Resolve rejects a deadline that is not in the future");
        await TaskWorkflow.Review(id,"Revision Requested","Please revise the document",null,TaskWorkflow.Today.AddDays(4));
        Assert((string)FirebaseRestClient.Data["tasks"][id]["dueDate"]==TaskWorkflow.Today.AddDays(4).ToString("yyyy-MM-dd"),"Resolve saves the new deadline with the status and feedback");
        Identity("student-new","student");
        await TaskWorkflow.Submit(id,"Updated solution","");
        Assert((string)(await PortalRepository.SubmissionForTask(id,"student-new"))["fileUrl"]=="https://example.test/first.pdf", "answer-only resubmission retains the existing solution file");
        Set("tasks/"+id+"/dueDate",TaskWorkflow.Today.AddDays(-1).ToString("yyyy-MM-dd")); Set("tasks/"+id+"/status","Resolve");
        await Reject(()=>TaskWorkflow.Submit(id,"Late revision","https://example.test/late.pdf"),"expired Resolve tasks cannot bypass the new deadline");
        Set("tasks/"+id+"/dueDate",TaskWorkflow.Today.AddDays(4).ToString("yyyy-MM-dd"));
        Identity("company-new","Company Supervisor");
        await TaskWorkflow.Review(id,"Reviewed","Complete without grading",null);
        Assert((string)FirebaseRestClient.Data["tasks"][id]["feedback"]=="Complete without grading" && (string)FirebaseRestClient.Data["submissions"][DatabaseSchema.Id(first)]["status"]=="Reviewed", "Complete without score persists feedback and updates the same student's submission");
        Identity("student-new","student");
        await Reject(()=>TaskWorkflow.Submit(id,"Closed answer","https://example.test/closed.pdf"),"Complete blocks further student submissions");
        Set("submissions/newer-own",new { taskId=id,studentId="student-new",updatedAt="2026-10-23T13:00:00+03:00",fileUrl="https://example.test/new.pdf" });
        Set("submissions/older-offset",new { taskId=id,studentId="student-new",updatedAt="2026-10-23T11:00:00+02:00",fileUrl="https://example.test/old.pdf" });
        Set("submissions/foreign-newest",new { taskId=id,studentId="another-student",updatedAt="2099-01-01T00:00:00Z",fileUrl="https://example.test/foreign.pdf" });
        // Isolate timestamp selection from the current-time submission generated above.
        Set("submissions/"+DatabaseSchema.Id(first)+"/updatedAt","2020-01-01T00:00:00Z");
        Assert(DatabaseSchema.Id(await PortalRepository.SubmissionForTask(id,"student-new"))=="newer-own", "latest solution compares actual instants and excludes another student's newer file");
        Identity("coordinator-new","coordinator");
        Set("internships/historical-placement",new {studentId="student-new",companyId="company-new",academicSupervisorId="original-supervisor",opportunityId="old-opening",status="completed"});
        Set("tasks/historical-task",new {studentId="student-new",internshipId="historical-placement",academicSupervisorId="original-supervisor",status="Reviewed"});
        Set("evaluations/historical-evaluation",new {studentId="student-new",internshipId="historical-placement",evaluatorRole="academicSupervisor",evaluatorId="original-supervisor",status="submitted"});
        var reassign=new Dictionary<string,object>(); await AcademicAssignments.AddChanges("student-new","replacement-supervisor",reassign);
        Assert(reassign.ContainsKey("internships/placement-new/academicSupervisorId") && !reassign.Keys.Any(x=>x.Contains("historical")),"supervisor reassignment updates current placement without rewriting historical tasks or evaluations");
        decimal percentage;
        decimal rawTotal = 0, roundedTotal = 0, roundedSum = 0;
        for (int i = 0; i < 6; i++) roundedSum += PercentageRules.RoundedContribution(100m/6,ref rawTotal,ref roundedTotal);
        Assert(roundedSum == 100m, "legacy percentage conversion cannot introduce a total above 100 through rounding");
        Assert(PercentageRules.TryParse("100",out percentage) && percentage==100 && PercentageRules.TryParse("0.01",out percentage), "percentage validation accepts exact bounds and hundredths");
        Assert(new[]{"100.01","-1","1e2","1,00","NaN","99.999",""}.All(x=>!PercentageRules.TryParse(x,out percentage)), "percentage regex rejects overflow, signs, exponent notation and excess precision");
        Assert(AcademicCatalog.SameDepartment("Cybersecurity","Cyber Security") && !AcademicCatalog.SameDepartment("Software Engineering","Computer Science"), "department aliases match without permitting unrelated assignments");
        Assert(DatabaseSchema.WorkflowStatus("Complete")=="Reviewed" && DatabaseSchema.WorkflowStatus("Resolve")=="Revision Requested", "legacy and requested status labels share one workflow");
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
        Assert(CompletionCertificateStore.Read((JObject)FirebaseRestClient.Data["completionReports"]["report1"]).Take(4).SequenceEqual(Encoding.ASCII.GetBytes("%PDF")),"approved certificate is stored and can be read using the student completion record");
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
        public static bool DelayResponses;
        public static HttpClient Client = new HttpClient(new MemoryHttp());
        private class MemoryHttp : HttpMessageHandler
        {
            protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellation)
            {
                if (DelayResponses) await Task.Delay(10).ConfigureAwait(false);
                string path = request.RequestUri.AbsolutePath.Trim('/').Replace(".json", "");
                if (request.Method == HttpMethod.Put) FirebaseRestClient.Set(path, JToken.Parse(request.Content.ReadAsStringAsync().GetAwaiter().GetResult()));
                var value = FirebaseRestClient.GetAsync<JToken>(path, "test").GetAwaiter().GetResult();
                var response = new HttpResponseMessage(HttpStatusCode.OK) { Content = new StringContent(value == null ? "null" : value.ToString(Formatting.None)) };
                response.Headers.ETag = new System.Net.Http.Headers.EntityTagHeaderValue("\"test-etag\"");
                return response;
            }
        }
    }
}

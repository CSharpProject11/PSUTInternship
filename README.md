# PSUT Internship Portal

ASP.NET Web Forms on .NET Framework 4.7.2, Firebase Authentication and Firebase Realtime Database. Students, company supervisors, academic supervisors and the internship coordinator share one connected workflow.

## Run locally

1. Install Visual Studio with **ASP.NET and web development** and the **.NET Framework 4.7.2 targeting pack**.
2. Open `PSUTInternship/PSUTInternship.slnx`, restore NuGet packages and select the web project as the startup project.
3. Set `FirebaseDatabaseUrl` and `FirebaseWebApiKey` in `PSUTInternship/PSUTInternship/Web.config`. Both must belong to the **same Firebase project**. These are the only runtime database URL and API key settings. The configured database is `https://uims-database-32b4f-default-rtdb.firebaseio.com/`, with the supplied Firebase Auth web API key.
4. Enable Email/Password sign-in in that Firebase project's Authentication settings. Review and deploy `PSUTInternship/PSUTInternship/Firebase/database.rules.example.json` to its Realtime Database. The source changes do not deploy rules or migrate any live database.
5. Bootstrap the first coordinator manually in Firebase Authentication, then create `/users/{AUTH_UID}` with `role: "coordinator"`, `isActive: true`, `mustChangePassword: true`, `profileId: "AUTH_UID"`, `fullName` and `email`. Keep one coordinator account for the college.
6. Start the project through IIS Express and open `Default.aspx`. After deploying the updated rules, sign in as coordinator once: the app fills missing reverse profile links for existing active internships and creates limited public previews for existing opportunities. Existing IDs and explicit supervisor assignments are preserved. All roles use `Login.aspx`; a temporary password must be changed before the workspace opens.
7. The coordinator creates academic and company supervisors, then student accounts. A student needs an academic supervisor during account creation. Use **Assign supervisors** to organize or reassign groups.

The web API key identifies the Firebase application; never put service-account credentials, database admin secrets or account passwords in source control.

## Connected workflow

1. A company supervisor publishes an opportunity. The public homepage shows its limited preview; students sign in for the description and application form.
2. A student applies. The company's application review records approval or rejection with a reason.
3. The student confirms one approved offer in **My applications**. An immutable confirmation and a retryable placement projection connect the student, company and academic supervisor. Company approval alone does not activate a trainee.
4. The company selects an opportunity and assigns tasks to its confirmed trainees, with a deadline and evaluation criteria. Tasks do not require scores. Resolve requires a new future deadline; Complete closes submission. Students can upload solution files, write an answer or provide an HTTPS work link. Submission and review histories are retained.
5. Students log training hours. The company approves or rejects individual logs; approved totals are recalculated with conditional writes. Completing a task never approves hours automatically.
6. The company submits its final evaluation. The assigned academic supervisor monitors the work, adds academic comments to the final assessment, and forwards the evaluation to the coordinator.
7. The coordinator reviews both evaluations, approved hours and outstanding tasks. Approval publishes the student's final result and enables an authenticated PDF completion-report download. Confidential supervisor final evaluations are not exposed to students.

Optional academic meeting invitations use the same authenticated session and database. The existing meeting screens use Jitsi meeting links; they are not an integration with the Zoom API.

## Structure

| Folder | Responsibility |
| --- | --- |
| `Shared` | Firebase settings and HTTP transport, authentication, role/session handling, account creation, application placement, tasks, hours, evaluation policy, completion/PDF services and reusable navigation |
| `Models` | Domain records and page view models; no page or HTTP implementations |
| `Student` | Student opportunities, applications, profile, tasks and progress |
| `Company` | Company opportunities, application review, trainees, task review and company evaluations |
| `Academic` | Assigned students, progress, academic evaluation and account |
| `Admin` | Accounts, group assignment, contact messages and final completion review |
| `Firebase` | The single database-rules template and setup notes |
| `tools` | Offline workflow/policy checks and an anonymized database fixture |

Task pages now use `Student/MyTasks.aspx`, `Company/Tasks.aspx` and `Company/CreateTask.aspx`. Old misspelled URLs redirect to these pages. The old company login and account URLs lead to the shared login/current account page. Company-side account creation is disabled; the coordinator owns provisioning.

## Workspace interface

All four roles use the shared PSUT navy and blue workspace in `Portal.Master`, with a collapsible curved sidebar, responsive role navigation and in-app popup messages/confirmations. See [workspace design and verification](docs/workspace-design.md) for page coverage, shared UI files and local validation results.

## Database contract

Profile keys must be Firebase Authentication UIDs. `profileId` uses that same UID. A company supervisor's profile stores `companyId`; accounts created by the coordinator use the supervisor UID as the company ID. No company ID is hardcoded in the application.

| Path | Record key and purpose |
| --- | --- |
| `users/{uid}` | Login role, active flag, initial password flag and profile identity |
| `students/{uid}` | Academic/personal information, required hours and assigned academic supervisor. Missing reverse internship/company links are filled by coordinator sign-in. |
| `academicSupervisors/{uid}` / `companySupervisors/{uid}` | Supervisor profile; academic groups can be in `studentGroups` or nested under the academic profile |
| `companies/{companyId}` | Company name and supervisor directory entry |
| `opportunities/{id}` | Private details; `duration` accepts text (e.g. `3 months`) or a number. `status` accepts active/open/closed/inactive text or legacy booleans. Seat counts and specialization may be absent. |
| `opportunities/{id}` | Single source for company editing, student browsing/applications, and signed-in homepage previews |
| `applications/{applicationId}` | Existing flat records retain their IDs. `coverLetter`, `cvUrl`, `isOfferConfirmed` and optional full application `details` are supported. New applications use a stable student/opportunity key. |
| `internshipConfirmations/{studentUid}` | One immutable selected application |
| `internships/{internshipId}` | Placement found through `studentId`; its key does not have to equal the student UID. |
| `tasks/{taskId}` | One student's assignment with opportunity/student/company/academic IDs, deadline, criteria and creation timestamp; legacy grades remain readable |
| `submissions/{submissionId}` / `taskFeedback/{taskId}` | Submissions join by `taskId` and retain their existing keys; `fileUrl`, `submissionLink` and older `attachmentUrl` are understood. |
| `submissionHistory/{taskId}/{id}` / `reviewHistory/{taskId}/{id}` | Previous submissions and reviews |
| `trainingHours/{id}` | Dated hour log, description and supervisor approval |
| `evaluations/{evaluationId}` | Confidential final assessments found by `internshipId`, `studentId` and `evaluatorRole`; existing IDs and draft records are retained. |
| `coordinatorReviewQueue/{academicEvaluationId}` | Forwarded assessments and review snapshot |
| `completionReports/{reportId}` | Existing pending records are promoted to approved using their real IDs. PDF downloads require coordinator approval. |
| `contactMessages/{id}` | Public contact form submissions and coordinator responses saved in the system |

Coordinator contact responses are sent through a server-configured SMTP provider and recorded after delivery is accepted. Configure `UIMS_SMTP_HOST`, `UIMS_SMTP_FROM`, `UIMS_SMTP_PORT` (default 587), `UIMS_SMTP_USERNAME` and `UIMS_SMTP_PASSWORD` in the server environment; TLS is required. Missing configuration or failed delivery produces an error rather than a success message. Uploaded solutions (up to 10 MB) are stored privately in `App_Data/TaskSolutions`, scoped to the task and student; Firebase stores their metadata. Grant the application identity write access and preserve this folder across deployments/backups. The authenticated `TaskSolution.aspx` endpoint downloads the latest solution. Existing HTTPS work links remain supported and redirect to their original provider. The completion PDF renders a high-resolution page to preserve Unicode names; it is printable but its text is not selectable.

## Existing Firebase data

The supplied export is supported directly; it does not need its record keys renamed or its text values converted. `Shared/DatabaseSchema.cs` handles format differences and joins tasks, submissions, hour logs, evaluations and reports to their actual internship IDs. Existing `requiredTrainingHours` is accepted alongside `requiredHours`. New tasks and Complete reviews do not require grades. Historic scores and review histories remain readable; no grade is invented for a task without a score.

The updated rules template uses scoped queries and relationship lookups for these records. Deploy it to the configured database before a live walkthrough. The template includes indexes for `studentId`, `internshipId`, `taskId` and supervisor queries. Signing in as coordinator fills only missing reverse links/previews; it does not overwrite explicit assignments or create fictitious accounts. Resolve conflicting assignments through the coordinator's assignment screen.

Authentication accounts must exist in this same Firebase project and profile keys must match their Auth UIDs. A database export does not transfer passwords or Authentication accounts from another project.

## Evaluation policy

The default **proposed project policy** is 60% company evaluation, 40% academic evaluation, an academic maximum of 100 and a passing final grade of 50. These values are configurable in `Web.config`; they are **not a verified official PSUT grading scheme**. New company evaluations use criterion percentages whose combined total cannot exceed 100%; academic assessments also accept 0–100%. Existing point-based final evaluations remain readable and continue to normalize against their recorded maximum. Task review is independent of final evaluation percentages. Required training hours are set per student by the coordinator. Confirm the college's official policy before operational use.

## Verification

Build the web project, then run:

```powershell
.\tools\verify-workflows.ps1
node tools/verify-firebase-rules.mjs
node tools/verify-public.mjs
# Optional: also deserialize every record in a supplied export (read-only).
.\tools\verify-workflows.ps1 -ExportPath "C:\path\to\firebase-export.json"
```

The workflow suite runs the actual shared services against an in-memory adapter and creates a sample completion PDF under the ignored `.verification` directory. The policy checks evaluate local rule expressions; they are not the official Firebase Emulator Suite. Validate the rules in Firebase's emulator before production deployment.

Full Web Forms markup compilation can also be checked with the .NET Framework `aspnet_compiler.exe`, using the web project directory as `-p` and a separate output directory. The local verification covered C# build, all ASP.NET page/control bindings, workflow assertions, local policy assertions, PDF rendering, public page rendering and unauthenticated redirects. A live signed-in walkthrough still requires the target project's deployed rules and valid accounts/data; no live Firebase writes were performed during the refactor.

### Opportunity collection cleanup

`opportunities` is the only opportunity collection used by the application. The old `publicOpportunities` collection is no longer read, written or generated. After deploying the application and `Firebase/database.rules.example.json`, the obsolete `publicOpportunities` node can be deleted from Firebase Console; retain `opportunities` and its IDs so existing applications remain linked. No live records are deleted by this code update.

Anonymous homepage requests return no opportunity previews; authenticated requests project preview fields from `opportunities`. Full opportunity records remain protected by the active-user Firebase read rule. Specialization is descriptive text, not an exact student-major restriction. Explicit college restrictions, active status and deadlines still apply.

## UIMS improvement verification (23 October 2026)

See [the requirement coverage and deployment checklist](docs/uims-improvements.md) for the text/PDF changes, local verification evidence and the live checks left to the project owner. The source changes do not deploy Firebase rules, configure SMTP credentials or alter live records.

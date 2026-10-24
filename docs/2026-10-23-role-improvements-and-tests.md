# Role improvements and verification — 23 October 2026

This report covers the six latest supplied documents: `raghadupdates.docx`, `message (3).txt`, `Acadimic cycle.pdf`, `update cycle company.docx`, `edit In the Company code.docx`, and `Admin Cycle UI and Functionality Improvements.pdf`. It supplements the older `uims-improvements.md`; its live-test results supersede that older report's statement that live testing was deferred.

## Implemented changes

| Area | Result | Main files |
| --- | --- | --- |
| Student task progress | Task Progress is unique submitted tasks divided by active assigned tasks, independent of training hours. Resubmissions do not inflate progress; revisions retain credit. Includes status metrics, real feedback/scores, readable submission/review history, accessible percentage and reduced-motion support. | `Student/StudentProgress.aspx`, its code-behind, `Shared/TaskProgressSummary.cs`, `Content/task-progress.css` |
| Company tasks | Student names replace IDs; dates are Create Date then Due Date in yyyy-MM-dd format. New tasks persist Pending. Actions align horizontally, rows alternate, and review opens in a dialog. Successful save refreshes the task list; errors retain fields. | `Company/Tasks.aspx`, code-behind, `Company/EditTask.aspx.cs`, `Shared/TaskWorkflow.cs`, `Shared/DatabaseSchema.cs` |
| Task forms and details | Opportunity/trainee names appear without IDs. Buttons are compact, details/solution sections have separate surfaces. Existing review status/deadline/feedback updates remain atomic. | `Company/CreateTask.aspx.cs`, `Company/ViewTask.aspx`, `Content/portal-workspace.css` |
| Downloads | Uploaded image/document bytes retain original filenames and metadata through the protected download endpoint. Missing placements fail authorization safely. Legacy external HTTPS links retain the provider's own behavior. | `Shared/TaskFileStore.cs`, `TaskSolution.aspx.cs` |
| Company trainees/evaluation | Trainee task totals derive from active assignments and reviewed work. Approved Hours display column removed without deleting hour data. Internship Reports table removed from the final-evaluation screen; other evaluation functionality retained. Company views use Inter and consistent status colors. | `Shared/CompanyPageBase.cs`, `Company/Trainees.aspx`, `Company/ReportsAndEvaluation.aspx`, code-behind, shared CSS |
| Academic dashboard/navigation | Quick Actions contains two equal cards, My Students and View Activity. Workspace Reports card/section removed. Non-dashboard academic pages have Back to dashboard. | `Workspace.Master`, `Portal.Master`, shared CSS |
| Meetings | Conditional update uses the raw Firebase ETag with explicit missing-version/concurrency/permission errors. Same-owner repeat responses are idempotent. Join appears only after acceptance and preserves an original HTTPS meeting URL or the existing room name. | `MeetingApi.aspx.cs`, `Shared/meetings.js`, academic/student meeting pages and scripts |
| Coordinator management | Student table contains university ID/name/college/actions; academic table contains name/email/college/actions. Full details remain behind View. Actions stay in one row inside scrolling wrappers. Supervisor selection matches both department and specialization and is revalidated on save. | `Admin/ManageStudents.aspx`, `Admin/ManageAcademic.aspx`, code-behinds, `Shared/AcademicCatalog.cs`, `Admin/Coordinator.css` |
| Groups and monitor | Department headings are more prominent; list shows actual student counts. Group editing retains its existing behavior. Monitor has Tasks/Evaluation actions side by side, no Hours action, nowrap task counts and flexible filters. | `Admin/AssignSuper.aspx`, code-behind, `Admin/MonitorPlacements.aspx.cs`, `Admin/Coordinator.css` |
| Coordinator profile | Read-only stacked profile/contact values; Edit opens a contact dialog with Save/Cancel and existing permissions. Security items stack. | `Admin/CoordinatorAccount.aspx`, code-behind |
| Completion certificate | Final review dialog uses actual hours, evaluations and completion checklist. Create Certificate requires existing approval conditions; only approved records expose downloads. PDF is stored under protected App_Data/Certificates and linked by certificate ID. Download remains restricted to the owner/coordinator. | `Admin/CompletionReview.aspx`, code-behind, `Shared/CompletionWorkflow.cs`, `Shared/CompletionCertificateStore.cs`, `Shared/CompletionReportPdf.cs`, `CompletionReport.aspx.cs` |
| Contact replies | Existing SMTP implementation sends to the inquiry's stored email, then records the reply after provider acceptance. Configuration failures remain explicit. | Existing `Shared/ContactReplyMailer.cs` and contact page logic were inspected and preserved. |

ManageCompanies was not edited. Existing homepage/login/student opportunity changes were preserved. No live Firebase rules or credentials were changed. Stored certificate and solution directories are excluded from Git.

## Live authenticated tour

The actual IIS Express app at `http://localhost:55571` was tested with the supplied accounts. Passwords were used only for sign-in and were not saved in this report or test scripts.

| Role | Verified with actual Firebase data |
| --- | --- |
| Coordinator | Dashboard; simplified student/academic tables; Add Student supervisor filtering after choosing Software Engineering; group counts/headings; account Edit/Cancel dialog; placement monitor actions; completion-review dialog and incomplete requirements; contact-message screen. Homepage → My workspace retained authentication. No student decisions, certificate approvals, profile changes or email sends were performed. |
| Student | Dashboard; 13 opportunity results; search reduced results to 1; Already applied filter showed 3; previously applied details displayed the duplicate warning and disabled submission. My Tasks showed actual completed task and feedback. Progress showed 1 assigned/1 submitted/1 reviewed, 100%, and real revision/review history. No certificate appeared for an unapproved completion. |
| Student meeting write | Accepted the existing test student's pending invitation. Firebase reported success; pending count became 0 and accepted count became 1. A Join Meeting link appeared without creating a duplicate invitation. This is the intentional live data change made during the tour. |
| Company supervisor | Dashboard, Tasks, Trainees, Create Task, evaluation list/editor, and account loaded successfully. Task and trainee lists correctly showed empty states. The supplied company has no confirmed active trainees, so a live task create/resolve/complete cycle and evaluation submission could not be exercised with this account. |
| Academic supervisor | Dashboard has exactly two quick actions; My Students opens the actual assigned-student view; Student Progress, Meetings, Final Evaluation, and account loaded. The same accepted test invitation and room link appeared on the academic side. Back to dashboard worked. Homepage navigation retained the academic session. |

All supplied accounts signed in successfully. No server/compilation error appeared on the checked pages. The final student progress page had no page-wide horizontal overflow at the live browser width. Test sessions were logged out at the end.

Evidence (local, ignored by Git): `.verification/live-student-meeting.png` and `.verification/live-student-progress.png`.

## Automated verification

| Check | Result |
| --- | --- |
| Debug build with installed Visual Studio MSBuild | Passed |
| Full ASP.NET page/control precompilation | Passed |
| `tools/verify-workflows.ps1` | **102 assertions passed**, actual shared services with an isolated in-memory repository; no network requests |
| `node tools/verify-firebase-rules.mjs` | **83 assertions passed**, local rule evaluation including meeting ownership/acceptance; this is not the official Firebase Emulator Suite |
| `node tools/verify-meetings.mjs` | Passed five checks for accepted-only links, original HTTPS URL, unsafe scheme rejection, original room fallback and escaping |
| `node tools/verify-public.mjs` | Passed public opportunity rendering/escaping/empty-state checks |
| Modified meeting JavaScript syntax checks | Passed |
| Four-role isolated browser layout tour at 1440px and 390px | Passed for student, company, academic and coordinator; no page-wide overflow or uncaught page errors in the fixture states |
| `git diff --check` | Passed |

Workflow assertions include duplicate/foreign task protection, Pending creation, submission-only progress, revisions and resubmission credit, Resolve deadlines, Complete propagation, feedback preservation, image/PDF byte preservation and task scope, supervisor filtering, evaluation limits, certificate persistence, completion prerequisites and report immutability.

The isolated browser tour uses source markup and fixture identities. It is responsive-layout evidence, separate from the real-account tour above. Edge initially failed to launch inside the Windows sandbox; the isolated tour passed after running outside that sandbox. ASP.NET precompilation also passed outside the sandbox.

## Limits and deployment requirements

- **SMTP is not configured in the current server environment.** Set `UIMS_SMTP_HOST`, `UIMS_SMTP_FROM`, and provider credentials (`UIMS_SMTP_USERNAME`, `UIMS_SMTP_PASSWORD`; port defaults to 587), restart the app, then verify actual receipt. No email delivery was claimed or attempted.
- A complete live company task/evaluation cycle needs a company account with an existing confirmed active trainee. Unit tests cover these transitions, but they do not replace live persistence and file-download testing across a matching student/company pair.
- Certificate generation/storage and authorization passed isolated service tests. No real student's completion was approved for testing; a live issuance/download remains untested.
- The historical meeting failure was not reproduced before the fix, so its original cause cannot be proven from a trace. The unsafe typed ETag dereference was removed, specific failure handling was added, and actual acceptance was verified on both roles afterward.
- Preserve and back up `App_Data/TaskSolutions` and `App_Data/Certificates` with database metadata. The application identity needs write access. Multiple app instances require shared persistent storage.
- Local rule tests do not verify deployed rules comprehensively; use the official Firebase Emulator Suite before a production rules rollout.
- The tour verifies the named flows and observed states. It does not establish that every possible state of every page is defect-free.

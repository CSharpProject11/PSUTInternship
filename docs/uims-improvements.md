# UIMS improvements and verification

Reviewed 23 October 2026. Scope: the user's written task/evaluation requirements and all 11 pages of `UIMS.pdf`. The project owner elected to finish local verification and run the live Firebase checks separately.

## Written requirements

| Area | Result |
| --- | --- |
| New evaluation | Opportunity selection scopes students on both company and academic evaluation pages. The company editor hides the background tables. Close dismisses the editor without saving, deleting or changing saved records. |
| Percentages | Score/maximum criterion inputs are replaced by percentage inputs. Each value accepts 0–100 with at most two decimal places. Decimal server arithmetic rejects a combined total above 100. Browser validation gives immediate field feedback; database validation caps the persisted percentage result. Existing point-based evaluations remain readable. |
| Send and draft | Both validate their inputs and persist all evaluation fields. Drafts reopen with their saved percentages and feedback. Submitted assessments cannot be sent again. Academic forwarding saves the assessment and coordinator queue together. |
| Create task | No score field. The opportunity selector lists the company's placements; Assign trainees lists only confirmed active trainees for that opportunity. The server checks the relationship again. Title, description, criteria, assignment and deadline errors appear beneath their fields. Creation saves an ISO timestamp, opportunity and placement IDs. |
| Task management | Score column removed. Created Date appears beside Deadline and includes the weekday in Jordan time. Counts, search and status filters use the stored states. |
| View and download | Download resolves the latest submission for the selected task and its assigned student, comparing actual timestamp instants. Uploaded bytes are downloaded through an authenticated endpoint. Another student's task is denied. Private uploaded bytes are retained if a network failure leaves the database commit uncertain, preventing a saved reference from pointing at a deleted file. |
| Resolve | A new deadline appears and must be in the future. Status, deadline, feedback and review history save together. Expired revision deadlines block uploads. |
| Complete | Completion requires feedback and no score. It updates the task and linked submission together and closes student submission. Legacy status spellings remain supported. |
| Student tasks | Tasks are restricted to the signed-in student and placement. The table, search and filter stay visible when empty. Students see the current deadline, status, answer, file and supervisor feedback. Uploaded files, replacement uploads and answer-only updates are supported. |

“Assign To” is implemented as the opportunity's trainees: students complete these assignments. Accepted applicants appear separately while awaiting confirmation; only confirmed placements receive tasks.

## PDF coverage

| PDF section | Work and checks |
| --- | --- |
| Student/general appearance | Shared card contrast, section spacing and navy button states updated. Global refresh buttons removed. Quick-action cards use the same resting state and hover behavior. |
| Opportunities/application | Missing card/detail images use a bundled technology image. Application identity, email, student ID, major, faculty and university load from Firebase and are read-only. Submission re-reads these fields server-side, so forged posted identity values are ignored. Opportunity details retain the responsive layout and readable palette. |
| My applications | Responsive three-column desktop grid, two columns on intermediate widths and one on phones. Pending, approved and rejected states have distinct text colors. Rows remain database-driven. |
| My tasks/progress | Persistent task table and empty state. Feedback remains visible without displaying a nonexistent score. Existing progress, hour, evaluation and completion-report information remains. |
| Student profile | Personal and academic cards sit beside each other on desktop and stack on phones. View mode uses text. Personal, academic and professional editors use populated dialogs, validation and explicit field whitelists. The six identity fields are protected by both application code and database rules. Existing professional links remain usable. |
| Academic design/evaluations | Existing shared PSUT layout retained. Evaluation selection is scoped by opportunity; percentage and feedback errors are inline. The complete Web Forms markup compiles. Academic task views retrieve the latest matching submission, including new uploaded files. |
| Meetings | Existing acceptance and cancellation handlers exercised across roles. Recent activity uses Jordan time in `dd-MM-yyyy HH` format, including response times. Cards use distinct blue shades; action labels are centered. |
| Academic profile/password | Personal/academic editors now open as populated dialogs and report save failures. The previously inert password button leads to the shared re-authenticated Firebase password-change flow. |
| Company review queue | Empty queues show a message. Existing application/trainee views retain their shared layout. |
| Company opportunities | Invalid submissions retain their entered values. Close posts the selected row's ID rather than duplicate hidden fields. Form Close returns without saving. Missing close icons have a CSS-drawn cross. |
| Applications/trainees | Application identity and decisions use the associated records. Accepted applicants appear immediately awaiting student confirmation. Confirmation activates the existing placement workflow without duplicate trainee records. |
| Coordinator student/supervisor forms | College, major, department and specialization use the PSUT computing catalogue. Selects align with the other fields. Student creation checks the supervisor's department server-side. |
| Assignment view | Same-department supervisor selection is available in View. One multipath update moves the group and updates the current placement/work records. Completed historical placements and evaluations are preserved. |
| Placement monitor | Tables retain their columns and actions, with internal horizontal scrolling and wider cell spacing. |
| Completion review/account | Existing data-driven completion and coordinator account workflows preserved. Compilation, relevant policy/workflow checks and responsive rendering cover the requested areas. |
| Contact replies | Replies use a TLS SMTP integration with server environment credentials. Only provider acceptance is followed by recording a resolved message. Missing configuration reports failure. If delivery succeeds but database recording fails, the UI reports that partial result and advises against blind resending. |
| End-to-end testing | Local regression evidence is below. Live Firebase/authentication/mail verification is intentionally left to the project owner, as requested. Local fixtures are not evidence of successful live Firebase operations. |

Programme choices were checked against [PSUT's King Hussein School of Computing Sciences catalogue](https://www.psut.edu.jo/en/about-khscs): Computer Science, Computer Graphics and Animation, Software Engineering, Data Science and Artificial Intelligence, and Cyber Security.

## Verification results

- C# Debug build: passed.
- Full ASP.NET page/control markup compilation: passed.
- 84 workflow assertions: passed against the actual shared services with an in-memory database adapter.
- 76 local database-policy assertions: passed. These evaluate the rules locally; they are not the official Firebase Emulator Suite.
- 6 public-page assertions: passed.
- 32 task/evaluation/profile browser-action assertions: passed.
- 15 broader PDF-flow browser-action assertions: passed.
- 14 pages checked at desktop and phone widths; 10 additional final layout captures. No server error or page-wide horizontal overflow in the captured states.
- `git diff --check`: passed.

The 213 automated assertions include creation, cross-opportunity rejection, exact solution download bytes, replacement-file selection, foreign-task denial, Resolve deadlines, Complete propagation, draft persistence, harmless Close, both server percentage caps, protected profile fields, application identity tampering, company acceptance, student confirmation, meetings, opportunity validation/Close, assignment synchronization and email-configuration failure.

Local browser evidence is under `.verification/uims-browser/`: `routes.json`, `interactions.json`, `pdf-interactions.json`, `final-layouts.json` and screenshots. These ignored files use isolated fixture identities and never call the production Firebase host. No live database records, rules or authentication credentials were changed.

## Deployment and owner-run live checks

1. Deploy the application and `Firebase/database.rules.example.json` to the intended Firebase project. Run its rules through the official Firebase Emulator Suite before production use. Existing records keep their IDs; no bulk migration is required.
2. Give the application identity write access to `App_Data/TaskSolutions`. Preserve and back up this folder with the Firebase submission metadata. On multiple application instances, mount the same persistent folder. Uploaded files are private and limited to 10 MB; existing HTTPS links redirect to the original provider, whose access/download behavior remains under that provider's control.
3. Configure the SMTP provider through server environment variables: `UIMS_SMTP_HOST`, `UIMS_SMTP_FROM`, `UIMS_SMTP_PORT` (587 by default), `UIMS_SMTP_USERNAME`, `UIMS_SMTP_PASSWORD`. TLS is enabled. Do not store provider passwords in frontend code or source control. Restart the application after configuring the environment, then verify actual receipt and the correct reply recipient.
4. Sign in with actual Student, Company Supervisor and Academic Supervisor test accounts. Create an opportunity/application; approve and confirm the offer; verify the same placement across roles and Firebase. Create a task for that opportunity and confirm another opportunity's student cannot see it.
5. Upload a solution, download it as the supervisor, upload a replacement and verify its bytes. Resolve with a new deadline, resubmit, then Complete and verify the student and management table. Reopen feedback and evaluation drafts; check that Close leaves saved Firebase data unchanged and totals above 100 cannot save.
6. Accept and cancel a meeting, edit permitted profile fields and verify that all six identity fields are unchanged. Reassign a group to a same-department supervisor and verify current work moves while historical completions remain unchanged.
7. Change a test account password through each role's account flow. Verify the old password fails and the new password works on the next login. These real authentication checks and actual SMTP delivery were not performed locally.

The existing configurable 60/40 final-evaluation weighting remains a proposed project policy, not a verified official university grading scheme.

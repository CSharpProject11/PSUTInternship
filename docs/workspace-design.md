# Four-role workspace redesign

The student, company supervisor, academic supervisor and coordinator workspaces use the homepage's PSUT navy, blue, sky and pale blue palette. The supplied sidebar reference sets the compact icon rail, expanded navigation and curved active tab that joins the canvas. Manrope is served locally.

`Portal.Master` owns the responsive shell and server form. `Shared/PortalNavigation.ascx` supplies role-specific links and current-page states. `Content/portal-workspace.css` supplies shared tokens and content styles. `Scripts/portal-ui.js` owns mobile navigation, field-label connections and popup messages. Existing Web Forms controls, event handlers, validation and data services remain in use.

## Coverage

| Role | Screens |
| --- | --- |
| Student | Dashboard, opportunities, opportunity/application form, applications and offer responses, tasks, progress/report, profile, meetings |
| Company | Dashboard, opportunities, create/edit opportunity, applications, application detail/rejection, trainees, tasks, create task, task detail/review, reports/final evaluations, account |
| Academic | Dashboard, student progress, final evaluation, account, meetings |
| Coordinator | Dashboard, students, company supervisors, academic supervisors, group assignments, placement monitoring, completion review (both existing routes), contact messages, account |
| Shared | Initial password change |

Old meeting HTML URLs redirect to authenticated meeting pages in the appropriate role area. Existing task/account aliases retain their redirects. Disabled company account provisioning remains disabled.

## PSUT branding and navigation

- Expanded navigation shows the existing full PSUT wordmark. Compact navigation shows the supplied PSUT emblem.
- The supplied `favicon.ico` contains a 32×32 PNG. Its original image bytes are saved as `Assets/psut-emblem.png` and used for both the compact brand mark and the workspace/homepage favicon.
- The desktop toggle switches between a 240px labelled sidebar and an 80px icon rail. Its preference persists across pages; each compact destination retains an accessible name and tooltip.
- The active tab joins the canvas without a gap or nested navigation scrollbar. Workspace/search and bottom identity blocks are omitted across every role.
- Tablet and phone views keep a full labelled menu regardless of the saved desktop preference. Existing popup behavior remains in use.

## Popups

- Messages render in a native HTML `dialog`, styled to match the workspace. Message content is assigned as text.
- Confirmations initially focus Cancel. Cancel and Escape stop the action; Confirm replays the original control once, preserving its Web Forms postback or link behavior.
- Server-rendered action messages remain inline and also open a popup. Routine record counts do not open popups.
- Coordinator validation, student offer responses, coordinator account-status changes and meeting cancellations use the shared popup API instead of browser alerts/confirmations.
- Keyboard focus returns to the invoking control. Mobile navigation supports Escape and keeps keyboard focus inside its menu.

## Design direction

The design-taste-frontend app-screen direction remains **Framed sheet**, seed **228910398**, keeping Manrope and adopting the existing homepage palette: navy `#003e73`, blue `#0078b5`, sky `#76c8ec`, pale `#d7ecf6`, night `#071f32`, ink `#102838` and ground `#f7f8f8`. No redraws. The user's sidebar reference supplies the curved selected tab and icon-rail geometry; its green color is replaced by the homepage blue. Flat fills retain readable contrast.

Each role's main question remains operational: students track their next requirement; companies review applicants and trainee work; academics monitor assigned students; coordinators manage assignments and completion decisions. The placement workflow and real decision mix supply the product-specific content. No new production sample statistics or charts were introduced.

## Verification

- C# project build and ASP.NET markup compilation passed.
- 65 offline workflow assertions, 55 local database-rule assertions and 6 public-page assertions passed.
- Browser walkthrough covered 38 distinct working pages, including create/edit variants and shared pages under all roles, at 1440, 768 and 390 pixels. No page-wide horizontal overflow or JavaScript exceptions remained in the checked views.
- 20 browser interaction checks passed, including Cancel/Escape, exactly-once confirmation, safe text rendering, mobile navigation/search, password validation, profile editing, student creation and evaluation-editor postbacks. No native alert/confirm dialogs appeared in these checks.
- The original four-role redesign passed its dashboard inspections. The PSUT palette revision adds a deliberate color-share warning because the requested navy sidebar occupies about 20% of the first desktop screen; that follows the user reference. The company dashboard also retains a small-text warning for 12px secondary descriptions. Data and navigation remain larger and nothing is below 11px.
- New shared CSS/JavaScript lint: zero failures. Warnings refer to selectors that hide old labels, normal form labels, and shadows on actual modal dialogs.

Browser checks used isolated, read-only local copies and fixture data. Fixture names include Lina Haddad, Dr. Rania Nasser, Omar Khalil and Cedar Technology; these are not production records. No live Firebase data, authentication settings or rules were changed. A signed-in walkthrough against the deployed Firebase project was not performed.

PSUT palette/sidebar verification adds 31 browser assertions covering all four roles at 1440, 768 and 390 pixels, actual logo loading, compact mode, persistence, accessible names, search and mobile behavior. The 20 existing popup/form browser checks were rerun successfully. Current dashboard inspection reports have zero failures at all three widths; the student run was split into desktop/tablet and phone after a screenshot timeout. These checks used the same isolated fixture setup. Current screenshots and critique are in the ignored `.taste-skill/psut-sidebar` directory; the earlier redesign evidence remains in `.taste-skill/workspace`. The final visual self-review scored design 8, usability 8, creativity 6.5 and content 8, weighted overall 7.7/10. Existing broad tables retain internal horizontal scrolling on phones; converting every table to a compact row layout is a possible later refinement.

Latest navigation simplification: 24 browser checks pass across all four roles at desktop, tablet and phone sizes, covering removed blocks, a zero-gap active tab, no nested navigation scrolling, mobile open/Escape and page overflow. Screenshots are saved as .taste-skill/psut-sidebar/after/*-connected.jpg.

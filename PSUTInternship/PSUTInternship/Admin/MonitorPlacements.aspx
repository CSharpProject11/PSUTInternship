<%@ Page Title="Monitor Placements & Progress | UIMS" MasterPageFile="~/Portal.Master" Language="C#" Async="true" AutoEventWireup="true" CodeBehind="MonitorPlacements.aspx.cs" Inherits="MonitorPlacements" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="Coordinator.css?v=5" rel="stylesheet" />
<style>
.portal-app .portal-content .coordinator-placement-dialog{width:min(820px,calc(100vw - 40px))!important;display:flex;flex-direction:column;overflow:hidden!important;max-height:88dvh!important;border-radius:18px!important}
.portal-app .portal-content .coordinator-placement-dialog .student-popup-header{padding:22px 28px!important;flex-shrink:0;background:#fff!important}
.portal-app .portal-content .coordinator-placement-dialog .student-popup-header h2{font-size:22px!important;letter-spacing:-.03em}
.portal-app .portal-content .coordinator-placement-dialog .student-popup-header p{font-size:13px!important;margin-top:5px!important}
.portal-app .portal-content .coordinator-placement-dialog .student-popup-info{display:grid!important;grid-template-columns:1fr 1fr 1fr;gap:20px!important;padding:18px 28px!important;background:#f3f6f9!important;border-bottom:1px solid #e1e8ee;flex-shrink:0}
.portal-app .portal-content .coordinator-placement-dialog .student-popup-info span{display:block;font-size:11px!important;font-weight:500!important;color:#607283!important;margin-bottom:5px}
.portal-app .portal-content .coordinator-placement-dialog .student-popup-info strong{display:block;font-size:14px!important;font-weight:650!important;line-height:1.5;color:#18354b}
.portal-app .portal-content .coordinator-placement-dialog .popup-section-title{display:flex!important;align-items:center!important;justify-content:space-between!important;gap:12px;padding:20px 28px 12px!important;flex-shrink:0}
.portal-app .portal-content .coordinator-placement-dialog .popup-section-title h3{margin:0!important;font-size:14px!important;font-weight:700!important}
.portal-app .portal-content .coordinator-placement-dialog .popup-section-title .tag{font-size:11px!important;font-weight:600;padding:4px 9px;border-radius:5px;background:#eaf0f5;color:#496175}
.portal-app .portal-content .coordinator-placement-dialog .popup-tasks-scroll{padding:0 28px 24px!important;overflow-y:auto!important;min-height:0;max-height:none!important;scrollbar-width:thin;background:#fff;overscroll-behavior:contain}
.portal-app .portal-content .coordinator-placement-dialog .popup-task-item{display:grid!important;grid-template-columns:minmax(0,1fr) auto;align-items:start!important;gap:18px!important;padding:18px!important;margin:10px 0 0!important;border:1px solid #e1e8ee!important;border-radius:10px;background:#fff}
.portal-app .portal-content .coordinator-placement-dialog .popup-task-content>strong{display:block;font-size:14px!important;font-weight:700!important;line-height:1.5!important;color:#19364c}
.portal-app .portal-content .coordinator-placement-dialog .popup-task-content>p{font-size:13px!important;font-weight:400!important;line-height:1.7!important;color:#5a6f80!important;margin:6px 0 12px!important;white-space:pre-wrap;overflow-wrap:anywhere;word-break:break-word}
.portal-app .portal-content .coordinator-placement-dialog .popup-task-content>small{display:inline-block;font-size:11px!important;font-weight:500!important;color:#526b7d!important;background:#f3f6f8;padding:3px 7px;border-radius:4px;font-variant-numeric:tabular-nums}
.portal-app .portal-content .coordinator-placement-dialog .popup-task-item>.tag{font-size:10px!important;line-height:1.5!important;font-weight:600!important;padding:4px 8px!important;margin:0!important}
.portal-app .portal-content .coordinator-placement-dialog .student-popup-footer{flex-shrink:0;padding:14px 28px!important}.portal-app .portal-content .coordinator-placement-dialog .student-popup-footer .btn{font-size:12px;padding:9px 16px;border-radius:7px;min-height:36px}
@media(max-width:600px){.portal-app .portal-content .coordinator-placement-dialog .student-popup-info{grid-template-columns:1fr;gap:12px!important}.portal-app .portal-content .coordinator-placement-dialog .student-popup-info>div{display:flex;justify-content:space-between;gap:12px}.portal-app .portal-content .coordinator-placement-dialog .popup-tasks-scroll{padding:0 16px 16px!important}.portal-app .portal-content .coordinator-placement-dialog .popup-task-item{padding:14px!important;gap:10px!important}}
/* Evaluation comparison uses its own content hierarchy. */
.portal-app .portal-content .coordinator-placement-dialog .placement-evaluations{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px;padding:24px 28px;overflow-y:auto;min-height:0;scrollbar-width:thin}
.portal-app .portal-content .coordinator-placement-dialog .placement-evaluation{border:1px solid #dfe7ed;border-radius:12px;overflow:hidden;background:#fff;min-width:0;align-self:start}
.portal-app .portal-content .coordinator-placement-dialog .placement-evaluation header{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:17px 18px;border-bottom:1px solid #e7edf1;background:#f8fafb}
.portal-app .portal-content .coordinator-placement-dialog .placement-evaluation h3{font-size:14px!important;line-height:1.4!important;font-weight:700!important;margin:0!important;color:#19364b}
.portal-app .portal-content .coordinator-placement-dialog .placement-eval-status{font-size:10px;font-weight:650;line-height:1.5;padding:4px 8px;border:1px solid #dce5eb;border-radius:5px;color:#405e73;background:#fff;white-space:nowrap}
.portal-app .portal-content .coordinator-placement-dialog .placement-score{padding:22px 18px}
.portal-app .portal-content .coordinator-placement-dialog .placement-score>span{display:block;color:#607587;font-size:11px;font-weight:500;margin-bottom:6px}
.portal-app .portal-content .coordinator-placement-dialog .placement-score>strong{display:block;color:#003e73;font-size:26px!important;font-weight:750!important;letter-spacing:-.03em;line-height:1.3;font-variant-numeric:tabular-nums}
.portal-app .portal-content .coordinator-placement-dialog .placement-feedback{padding:0 18px 22px}
.portal-app .portal-content .coordinator-placement-dialog .placement-feedback h4{font-size:11px!important;font-weight:650!important;color:#526c7f;margin:0 0 10px!important;padding-top:16px;border-top:1px solid #e7edf1}
.portal-app .portal-content .coordinator-placement-dialog .placement-feedback p{font-size:13px!important;font-weight:400!important;line-height:1.8!important;white-space:pre-wrap;overflow-wrap:anywhere;word-break:break-word;margin:0!important;color:#425c70}
@media(max-width:650px){.portal-app .portal-content .coordinator-placement-dialog .placement-evaluations{grid-template-columns:minmax(0,1fr);padding:18px;gap:14px}}

/* Placement register: a quiet sheet with paired identity and progress. */
.portal-app .portal-content .placements-page{--pl-ink:#172f42;--pl-muted:#526777;--pl-line:#e3e9ed;--pl-blue:#003e73}
.portal-app .portal-content .placements-page .heading{margin:0 0 26px!important}
.portal-app .portal-content .placements-page h1{font-size:30px!important;letter-spacing:-.035em;line-height:1.2!important;margin:0 0 9px!important}
.portal-app .portal-content .placements-page .heading p{font-size:14px!important;color:var(--pl-muted)}
.portal-app .portal-content .placements-page .placement-summary{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));margin:0 0 28px;border-bottom:1px solid var(--pl-line);padding:0 0 23px;gap:24px}
.portal-app .portal-content .placements-page .placement-summary a{display:flex;flex-direction:column;gap:10px;text-decoration:none;color:var(--pl-ink);padding:0 20px;border-right:1px solid var(--pl-line)}
.portal-app .portal-content .placements-page .placement-summary a:first-child{padding-left:0}.portal-app .portal-content .placements-page .placement-summary a:last-child{border:0}
.portal-app .portal-content .placements-page .placement-summary span{font-size:13px;color:var(--pl-muted)}
.portal-app .portal-content .placements-page .placement-summary strong{font-size:28px;font-weight:600;line-height:1.2;font-variant-numeric:tabular-nums}
.portal-app .portal-content .placements-page .placement-summary a:hover span{color:var(--pl-blue);text-decoration:underline;text-underline-offset:4px}
.portal-app .portal-content .placements-page .placement-register{padding:0!important;border:1px solid var(--pl-line)!important;border-radius:12px!important;box-shadow:none!important;overflow:hidden;background:#fff!important}
.portal-app .portal-content .placements-page .placement-register-title{display:flex;justify-content:space-between;align-items:center;gap:16px;padding:24px 24px 0}
.portal-app .portal-content .placements-page .placement-register-title h2{font-size:17px!important;margin:0 0 5px!important;letter-spacing:-.02em}
.portal-app .portal-content .placements-page .placement-register-title p{font-size:13px!important;color:var(--pl-muted);margin:0!important}
.portal-app .portal-content .placements-page .placement-count{font-size:12px;color:var(--pl-muted);white-space:nowrap}
.portal-app .portal-content .placements-page .tools{display:flex;gap:12px;margin:0!important;padding:22px 24px 24px;align-items:end;border-bottom:1px solid var(--pl-line)}
.portal-app .portal-content .placements-page .tools .field{flex:0 1 220px;min-width:0}.portal-app .portal-content .placements-page .tools .field:first-child{flex:1}
.portal-app .portal-content .placements-page .field label{font-size:12px!important;font-weight:600;color:var(--pl-muted)}
.portal-app .portal-content .placements-page .tools :is(input,select){height:44px!important;width:100%;border:1px solid #c9d4dd!important;border-radius:7px!important;padding:10px 12px!important;background:#fff!important;font-size:13px!important;color:var(--pl-ink)}
.portal-app .portal-content .placements-page .tools .btn{min-height:44px;background:var(--pl-blue)!important;border-radius:7px!important;font-size:13px!important;padding:10px 18px!important}
.portal-app .portal-content .placements-page .placement-reset{font-size:13px;color:var(--pl-muted);padding:12px 4px;text-underline-offset:4px}
.portal-app .portal-content .placements-page .tablewrap{padding:0 24px!important;overflow-x:auto!important}
.portal-app .portal-content .placements-page .tablewrap table{min-width:780px!important;table-layout:auto!important;width:100%}
.portal-app .portal-content .placements-page :is(th,td){padding:19px 12px!important;font-size:13px!important;vertical-align:middle!important;white-space:normal!important}
.portal-app .portal-content .placements-page th{padding-block:14px!important;font-size:12px!important;color:var(--pl-muted)!important}
.portal-app .portal-content .placements-page :is(th,td):first-child{padding-left:0!important;width:24%}.portal-app .portal-content .placements-page :is(th,td):last-child{padding-right:0!important;width:22%}
.portal-app .portal-content .placements-page tbody tr:last-child td{border-bottom:0!important}
.portal-app .portal-content .placements-page .placement-student{display:block;font-size:14px;font-weight:650;color:var(--pl-ink)}
.portal-app .portal-content .placements-page .placement-company{display:block;color:var(--pl-muted);font-size:12px;margin-top:5px}
.portal-app .portal-content .placements-page .placement-hours{font-size:12px;color:var(--pl-muted);font-variant-numeric:tabular-nums;white-space:nowrap}.portal-app .portal-content .placements-page .placement-hours strong{font-size:14px;color:var(--pl-ink);font-weight:650}
.portal-app .portal-content .placements-page .progress-cell{display:flex;align-items:center;gap:8px;margin-top:8px;min-width:140px;font-size:11px;color:var(--pl-muted);font-variant-numeric:tabular-nums}
.portal-app .portal-content .placements-page .progress-bar{flex:1;height:5px;margin:0;background:#e8eef2;border-radius:9px;overflow:hidden}.portal-app .portal-content .placements-page .progress-fill{height:100%;background:#0078b5}
.portal-app .portal-content .placements-page .placement-actions{display:flex;gap:8px;flex-wrap:wrap;max-width:240px}.portal-app .portal-content .placements-page .placement-actions a{font-size:12px!important;font-weight:600!important;text-decoration:none!important;min-height:38px;display:inline-flex;align-items:center;justify-content:center;gap:6px;padding:8px 12px!important;border:1px solid #c9d4dd!important;border-radius:7px!important;background:#fff!important;color:var(--pl-blue)!important;white-space:nowrap!important}.portal-app .portal-content .placements-page .placement-actions a:hover{background:#edf3f7!important;border-color:#91a9bc!important;text-decoration:none!important}.portal-app .portal-content .placements-page .placement-actions span{color:var(--pl-muted);font-variant-numeric:tabular-nums}
.portal-app .portal-content .placements-page .tag{font-size:11px!important;border-radius:5px!important;padding:4px 8px!important}.portal-app .portal-content .placements-page .tag.neutral{background:#edf3f7;color:#365a71}
.portal-app .portal-content .placements-page .empty-cell{padding:48px 20px!important;text-align:center!important;color:var(--pl-muted)}
.portal-app .portal-content .placements-page :is(a,button,input,select):focus-visible{outline:2px solid #0078b5!important;outline-offset:3px}
@media(max-width:700px){
.portal-app .portal-content .placements-page .placement-summary{gap:20px 0;grid-template-columns:1fr 1fr;margin-bottom:22px}.portal-app .portal-content .placements-page .placement-summary a{padding:0 16px}.portal-app .portal-content .placements-page .placement-summary a:nth-child(3){padding-left:0}.portal-app .portal-content .placements-page .placement-summary a:nth-child(2){border:0}
.portal-app .portal-content .placements-page .placement-register-title{padding:18px 16px 0}.portal-app .portal-content .placements-page .placement-register-title p{display:none}
.portal-app .portal-content .placements-page .tools{padding:16px!important;display:grid!important;grid-template-columns:minmax(0,1fr) auto;gap:12px}.portal-app .portal-content .placements-page .tools .field:first-child{grid-column:1/-1}.portal-app .portal-content .placements-page .placement-reset{grid-column:2;grid-row:1;padding:0;justify-self:end}.portal-app .portal-content .placements-page .tools .field:first-child label{padding-right:45px}
.portal-app .portal-content .placements-page .tablewrap{padding:0 16px!important}.portal-app .portal-content .placements-page .tablewrap table{min-width:0!important}.portal-app .portal-content .placements-page thead{display:none}.portal-app .portal-content .placements-page :is(tbody,tr){display:block}.portal-app .portal-content .placements-page tr{padding:18px 0;border-bottom:1px solid var(--pl-line);display:grid;grid-template-columns:minmax(0,1fr) auto;gap:12px}.portal-app .portal-content .placements-page tr:last-child{border:0}.portal-app .portal-content .placements-page td{display:block!important;border:0!important;padding:0!important;width:auto!important;min-width:0}.portal-app .portal-content .placements-page td:first-child{grid-column:1;grid-row:1}.portal-app .portal-content .placements-page td:nth-child(2){grid-column:1/-1;grid-row:2;font-size:12px!important;color:var(--pl-muted)}.portal-app .portal-content .placements-page td:nth-child(2):before{content:'Supervisor: '}.portal-app .portal-content .placements-page td:nth-child(3){grid-column:1/-1;grid-row:3}.portal-app .portal-content .placements-page td:nth-child(4){grid-column:2;grid-row:1}.portal-app .portal-content .placements-page td:last-child{grid-column:1/-1}.portal-app .portal-content .placements-page .placement-actions{max-width:none;gap:8px}.portal-app .portal-content .placements-page .placement-actions a{min-height:44px}.portal-app .portal-content .placements-page .empty-cell{grid-column:1/-1}
}


.portal-app .portal-content .placements-page .placement-actions .placement-task-button{background:#003e73!important;border-color:#003e73!important;color:#fff!important}
.portal-app .portal-content .placements-page .placement-actions .placement-task-button:hover{background:#00568f!important;border-color:#00568f!important}
.portal-app .portal-content .placements-page .placement-actions .placement-task-button span{color:#fff!important}
.portal-app .portal-content .placements-page .placement-actions .placement-evaluation-button{background:#e5f2e9!important;border-color:#a8cbb6!important;color:#175b3c!important}
.portal-app .portal-content .placements-page .placement-actions .placement-evaluation-button:hover{background:#cfe7d8!important;border-color:#7daa8f!important}
.portal-app .portal-content .placements-page .placement-heading-row{display:flex;justify-content:space-between;align-items:flex-start;gap:20px;flex-wrap:wrap;margin-bottom:26px}
.portal-app .portal-content .placements-page .placement-heading-row .heading{margin:0!important;flex:1;min-width:240px}
.portal-app .portal-content .placements-page .placement-export{display:inline-flex;gap:8px;align-items:center;min-height:44px;font-size:13px!important;border-radius:7px!important;background:#fff!important;color:#175b3c!important;border:1px solid #afcdbb!important;padding:10px 16px!important}
.portal-app .portal-content .placements-page .placement-export:hover{background:#edf7f1!important}.portal-app .portal-content .placements-page .placement-export svg{width:17px;height:17px;fill:none;stroke:currentColor;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
</style>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<input type="hidden" name="csrfToken" value="<%= H(CsrfToken) %>" />
    <div class="layout placements-page">



        <div class="workspace">
            <header class="topbar">
                <span>University Internship Management System</span>
                <span class="avatar">CO</span>
            </header>

            <main>
                <div class="placement-heading-row">
                <div class="heading">
                    <h1>Placements</h1>
                    <p>Follow every internship, spot students at risk, and review their progress.</p>
                </div>
                <a class="btn secondary placement-export" href="MonitorPlacements.aspx?export=xlsx" title="Download every placement, regardless of the current filters"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3v12m-4-4 4 4 4-4M5 16v5h14v-5"/></svg>Export to Excel</a>
                </div>




                <nav class="placement-summary" aria-label="Placement status">
                    <a href="MonitorPlacements.aspx"><span>All placements</span><strong><%= string.IsNullOrEmpty(FirebaseError) ? Total.ToString() : "—" %></strong></a>
                    <a href="MonitorPlacements.aspx?status=On%20Track"><span>On track</span><strong><%= string.IsNullOrEmpty(FirebaseError) ? OnTrack.ToString() : "—" %></strong></a>
                    <a href="MonitorPlacements.aspx?status=At%20Risk"><span>At risk</span><strong class="risk-number"><%= string.IsNullOrEmpty(FirebaseError) ? AtRisk.ToString() : "—" %></strong></a>
                    <a href="MonitorPlacements.aspx?status=Completed"><span>Completed</span><strong><%= string.IsNullOrEmpty(FirebaseError) ? (Total - OnTrack - AtRisk).ToString() : "—" %></strong></a>
                </nav>
                <section class="card placement-register" aria-labelledby="register-title">
                    <div class="placement-register-title"><div><h2 id="register-title">Internship register</h2><p>Approved hours, supervision and evaluations in one place.</p></div><span class="placement-count"><%= VisibleCount %> shown</span></div>

                    <div class="tools">
                        <div class="field">
                            <label for="search">Search</label>
                            <input type="text" id="search" name="search"
                                   value="<%= H(Search) %>"
                                   placeholder="Student or company name…" />
                        </div>

                        <div class="field">
                            <label for="status">Progress status</label>
                            <select id="status" name="status">
                                <option value="All" <%= Selected("All") %>>All</option>
                                <option value="On Track" <%= Selected("On Track") %>>On Track</option>
                                <option value="At Risk" <%= Selected("At Risk") %>>At Risk</option>
                                <option value="Completed" <%= Selected("Completed") %>>Completed</option>
                            </select>
                        </div>

                        <button class="btn" type="submit">Apply filters</button>
                        <a class="placement-reset" href="MonitorPlacements.aspx">Reset</a>
                    </div>

                    <div class="tablewrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Academic supervisor</th>
                                    <th>Training progress</th>
                                    <th>Status</th>
                                    <th>Review</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%= Rows() %>
                            </tbody>
                        </table>
                    </div>
                </section>
            </main>
        </div>
    </div>

    <% if (SelectedPlacement != null &&
           (ViewMode == "tasks" || ViewMode == "evaluation" || ViewMode == "hours")) { %>

    <div class="student-popup open"
         role="dialog"
         aria-modal="true"
         aria-labelledby="studentPopupTitle">

        <div class="student-popup-content coordinator-placement-dialog">

            <div class="student-popup-header">
                <div>
                    <h2 id="studentPopupTitle">
                        <%= ViewMode == "tasks" ? "Assigned Tasks" : ViewMode == "hours" ? "Training Hours" : "Final Evaluations" %>
                    </h2>
                    <p><%= H(SelectedPlacement.Student) %></p>
                </div>

                <a class="student-popup-close"
                   href="MonitorPlacements.aspx?search=<%= H(HttpUtility.UrlEncode(Search)) %>&amp;status=<%= H(HttpUtility.UrlEncode(Status)) %>"
                   aria-label="Close popup">&times;</a>
            </div>

            <div class="student-popup-info">
                <div>
                    <span>Training Company</span>
                    <strong><%= H(SelectedPlacement.Company) %></strong>
                </div>
                <div>
                    <span>Academic Supervisor</span>
                    <strong><%= H(SelectedPlacement.Supervisor) %></strong>
                </div>
                <div>
                    <span>Approved Training Hours</span>
                    <strong>
                        <%= SelectedPlacement.Hours %> /
                        <%= SelectedPlacement.Required %> hrs
                    </strong>
                </div>
            </div>

            <% if (ViewMode == "tasks") { %>

                <div class="popup-section-title">
                    <h3>All Assigned Tasks</h3>
                    <span class="tag">
                        <%= SelectedPlacement.Tasks == null
                            ? 0
                            : SelectedPlacement.Tasks.Count %> Tasks
                    </span>
                </div>

                <div class="popup-tasks-scroll <%= HasManyTasks ? "has-scroll" : "" %>">
                    <%= TaskRows() %>
                </div>

            <% } else if (ViewMode == "hours") { %>
                <div class="popup-evaluation tablewrap">
                    <table><thead><tr><th>Date</th><th>Hours</th><th>Activity</th><th>Status</th></tr></thead><tbody>
                    <% foreach (var log in SelectedPlacement.HourLogs) { %>
                        <tr><td><%= H(log.Date) %></td><td><%= log.Hours %></td><td><%= H(log.Description) %></td><td><%= H(log.Status) %></td></tr>
                    <% } %>
                    <% if (SelectedPlacement.HourLogs.Count == 0) { %><tr><td colspan="4">No training hours logged for this placement.</td></tr><% } %>
                    </tbody></table>
                </div>
            <% } else { %>
                <div class="placement-evaluations">
                    <section class="placement-evaluation">
                        <header><h3>Company evaluation</h3><span class="placement-eval-status"><%= H(SelectedPlacement.CompanyEvaluation) %></span></header>
                        <div class="placement-score"><span>Final score</span><strong><%= H(SelectedPlacement.CompanyScore) %></strong></div>
                        <div class="placement-feedback"><h4>Supervisor feedback</h4><p><%= H(string.IsNullOrWhiteSpace(SelectedPlacement.CompanyFeedback) ? "No feedback has been submitted yet." : SelectedPlacement.CompanyFeedback) %></p></div>
                    </section>
                    <section class="placement-evaluation">
                        <header><h3>Academic evaluation</h3><span class="placement-eval-status"><%= H(SelectedPlacement.AcademicEvaluation) %></span></header>
                        <div class="placement-score"><span>Academic result</span><strong><%= H(SelectedPlacement.AcademicScore) %></strong></div>
                        <div class="placement-feedback"><h4>Supervisor feedback</h4><p><%= H(string.IsNullOrWhiteSpace(SelectedPlacement.AcademicFeedback) ? "No feedback has been submitted yet." : SelectedPlacement.AcademicFeedback) %></p></div>
                    </section>
                </div>
            <% } %>

            <div class="student-popup-footer">
                <a class="btn secondary" href="MonitorPlacements.aspx?search=<%= H(HttpUtility.UrlEncode(Search)) %>&amp;status=<%= H(HttpUtility.UrlEncode(Status)) %>">
                    Close
                </a>
            </div>

        </div>
    </div>

    <% } %>

</asp:Content>

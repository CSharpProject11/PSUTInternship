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
</style>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<input type="hidden" name="csrfToken" value="<%= H(CsrfToken) %>" />
    <div class="layout">



        <div class="workspace">
            <header class="topbar">
                <span>University Internship Management System</span>
                <span class="avatar">CO</span>
            </header>

            <main>
                <div class="heading">
                    <h1>Monitor Placements & Progress</h1>
                    <p>Monitor students, companies, assigned tasks, academic evaluations, training hours and progress.</p>
                </div>




                <section class="card">
                    <h2>Student Internship Monitoring</h2>

                    <div class="tools">
                        <div class="field">
                            <label for="search">Search</label>
                            <input type="text" id="search" name="search"
                                   value="<%= H(Search) %>"
                                   placeholder="Search student or company" />
                        </div>

                        <div class="field">
                            <label for="status">Progress Status</label>
                            <select id="status" name="status">
                                <option value="All" <%= Selected("All") %>>All</option>
                                <option value="On Track" <%= Selected("On Track") %>>On Track</option>
                                <option value="At Risk" <%= Selected("At Risk") %>>At Risk</option>
                                <option value="Completed" <%= Selected("Completed") %>>Completed</option>
                            </select>
                        </div>

                        <button class="btn" type="submit">Filter</button>
                    </div>

                    <div class="tablewrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Company</th>
                                    <th>Academic Supervisor</th>
                                    <th>Tasks</th>
                                    <th>Training Hours</th>
                                    <th>Progress</th>
                                    <th>Status</th>
                                    <th>Actions</th>
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
                   href="MonitorPlacements.aspx"
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
                        <div class="placement-score"><span>Final score</span><strong><%= H(SelectedPlacement.AcademicScore) %></strong></div>
                        <div class="placement-feedback"><h4>Supervisor feedback</h4><p><%= H(string.IsNullOrWhiteSpace(SelectedPlacement.AcademicFeedback) ? "No feedback has been submitted yet." : SelectedPlacement.AcademicFeedback) %></p></div>
                    </section>
                </div>
            <% } %>

            <div class="student-popup-footer">
                <a class="btn secondary" href="MonitorPlacements.aspx">
                    Close
                </a>
            </div>

        </div>
    </div>

    <% } %>

</asp:Content>

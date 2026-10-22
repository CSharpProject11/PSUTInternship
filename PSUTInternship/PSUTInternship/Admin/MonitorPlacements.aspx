
<%@ Page Language="C#" Async="true" AutoEventWireup="true" CodeBehind="MonitorPlacements.aspx.cs" Inherits="MonitorPlacements" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Monitor Placements & Progress | UIMS</title>
    <link href="Coordinator.css?v=5" rel="stylesheet" />
</head>
<body>
<form id="form1" runat="server">
<input type="hidden" name="csrfToken" value="<%= H(CsrfToken) %>" />
    <div class="layout">

        <aside class="sidebar">
            <div class="brand">
                UIMS <span>Coordinator</span>
            </div>
            <nav>
                <a class="nav-link" href="Dashboard.aspx">Dashboard</a>
                <a class="nav-link" href="ManageStudents.aspx">Manage Students</a>
                <a class="nav-link" href="ManageCompanies.aspx">Manage Companies</a>
                <a class="nav-link" href="ManageAcademic.aspx">Manage Academic Supervisors</a>
                <a class="nav-link" href="AssignSuper.aspx">Assign Academic Supervisors</a>
                <a class="nav-link active" href="MonitorPlacements.aspx">Monitor Placements & Progress</a>
                <a class="nav-link" href="FinalCompletionReview.aspx">Final Completion Review</a>
                <a class="nav-link" href="ContactMessages.aspx">Contact Messages</a>
                <a class="nav-link" href="CoordinatorAccount.aspx">Coordinator Account</a>
            </nav>
            <div class="sidefoot">University Internship System</div>
        </aside>

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

        <div class="student-popup-content">

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
                <div class="popup-section-title"><h3>Company Supervisor Evaluation</h3></div>
                <div class="popup-evaluation">
                    <strong><%= H(SelectedPlacement.CompanyEvaluation) %></strong>
                    <p>Score: <%= H(SelectedPlacement.CompanyScore) %></p>
                    <p><%= H(SelectedPlacement.CompanyFeedback) %></p>
                </div>
                <div class="popup-section-title">
                    <h3>Academic Supervisor Evaluation</h3>
                </div>

                <div class="popup-evaluation">
                    <div class="popup-evaluation-top">
                        <strong>
                            <%= H(SelectedPlacement.AcademicEvaluation) %>
                        </strong>
                        <span class="tag">
                            <%= H(SelectedPlacement.EvaluationStatus) %>
                        </span>
                    </div>
                    <p>Score: <%= H(SelectedPlacement.AcademicScore) %></p>
                    <p><%= H(SelectedPlacement.AcademicFeedback) %></p>
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

</form>
</body>
</html>

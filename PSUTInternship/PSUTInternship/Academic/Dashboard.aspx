
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="AcademicSupervisor.Dashboard" Async="true" %>

<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <title>Academic Dashboard | UIMS</title>

    <link href="AcademicSupervisor.css" rel="stylesheet" />

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
          rel="stylesheet" />

    <style>
        /* DASHBOARD DESIGN */
        :root {
            --primary: #2563eb;
            --primary-dark: #1748ad;
            --navy: #102544;
            --navy-light: #1b365d;
            --background: #f3f6fc;
            --text: #182b49;
            --muted: #75839b;
            --border: #e5ebf5;
            --white: #ffffff;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: var(--background);
            color: var(--text);
            font-family: 'Inter', Arial, sans-serif;
            font-size: 13px;
        }

        .layout {
            display: flex;
            min-height: 100vh;
        }

        /* SIDEBAR */

        .sidebar {
            width: 250px;
            min-width: 250px;
            background: linear-gradient(180deg, #102544 0%, #0c1d38 100%);
            color: white;
            padding: 27px 17px;
            display: flex;
            flex-direction: column;
        }

        .brand {
            font-size: 27px;
            font-weight: 800;
            letter-spacing: 1px;
            padding: 0 10px;
            margin-bottom: 47px;
            color: white;
        }

        .brand small {
            display: block;
            font-size: 9px;
            font-weight: 500;
            letter-spacing: 1.5px;
            color: #a8c5ef;
            margin-top: 7px;
        }

        .nav-title {
            color: #91a7c7;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: 1.1px;
            text-transform: uppercase;
            padding: 0 12px;
            margin: 0 0 14px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 13px;
            margin-bottom: 6px;
            border-radius: 10px;
            color: #dce8fa;
            text-decoration: none;
            font-size: 12px;
            font-weight: 500;
            transition: background 0.2s, transform 0.2s;
        }

        .nav-link:hover {
            background: rgba(255, 255, 255, 0.09);
            color: white;
            transform: translateX(2px);
        }

        .nav-link.active {
            color: white;
            background: linear-gradient(100deg, #2869e8, #1b50b8);
            box-shadow: 0 5px 15px rgba(20, 70, 170, 0.25);
        }

        .nav-icon {
            width: 20px;
            text-align: center;
            font-size: 17px;
        }

        .sidebar-divider {
            height: 1px;
            background: rgba(255, 255, 255, 0.12);
            margin: 24px 8px;
        }

        /* MAIN */

        .main {
            flex: 1;
            min-width: 0;
            display: flex;
            flex-direction: column;
        }

        .topbar {
            min-height: 70px;
            padding: 0 36px;
            background: white;
            border-bottom: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
        }

        .topbar strong {
            font-size: 13px;
            font-weight: 700;
        }

        .user-chip {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            background: #edf4ff;
            color: #2555a5;
            border-radius: 30px;
            padding: 11px 15px;
            font-size: 11px;
            font-weight: 600;
        }

        .user-avatar {
            width: 29px;
            height: 29px;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            background: #d9e8ff;
            border-radius: 50%;
            color: #2058bd;
            font-weight: 800;
        }

        /* PAGE CONTENT */

        .content {
            width: 100%;
            max-width: 1600px;
            margin: 0 auto;
            padding: 34px 36px;
            flex: 1;
        }

        .eyebrow {
            color: var(--primary);
            text-transform: uppercase;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 2px;
            margin-bottom: 12px;
        }

        h1 {
            margin: 0;
            font-size: clamp(25px, 2.3vw, 33px);
            font-weight: 800;
            letter-spacing: -1px;
            color: #152744;
        }

        .subtitle {
            color: var(--muted);
            line-height: 1.8;
            font-size: 12px;
            margin: 12px 0 25px;
        }

        /* STATISTICS */

        .cards {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 17px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: white;
            border: 1px solid var(--border);
            border-radius: 15px;
            padding: 23px 21px;
            min-height: 155px;
            box-shadow: 0 5px 20px rgba(25, 53, 96, 0.035);
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(25, 53, 96, 0.08);
        }

        .stat-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }

        .stat-label {
            color: #64748b;
            font-size: 11px;
            font-weight: 600;
        }

        .stat-icon {
            width: 42px;
            height: 42px;
            flex-shrink: 0;
            border-radius: 13px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            font-weight: 700;
        }

        .icon-blue {
            color: #2563eb;
            background: #e8f1ff;
        }

        .icon-green {
            color: #059669;
            background: #dcfce9;
        }

        .icon-orange {
            color: #d97706;
            background: #fff1d6;
        }

        .icon-purple {
            color: #7c3aed;
            background: #f0e8ff;
        }

        .stat-number {
            color: #172c4c;
            font-size: 32px;
            font-weight: 800;
            margin: 13px 0 6px;
            letter-spacing: -1px;
        }

        .stat-note {
            color: #8592a8;
            font-size: 10px;
            line-height: 1.6;
        }

        /* PANELS */

        .panel {
            background: white;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 23px;
            margin-bottom: 20px;
            box-shadow: 0 5px 20px rgba(25, 53, 96, 0.035);
        }

        .panel-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            margin-bottom: 22px;
        }

        .panel-title {
            display: flex;
            align-items: center;
            gap: 11px;
        }

        .panel-title-icon {
            width: 39px;
            height: 39px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 12px;
            color: var(--primary);
            background: #eaf2ff;
            font-size: 19px;
        }

        h2 {
            color: #1a2b46;
            font-size: 15px;
            font-weight: 800;
            margin: 0;
        }

        /* BUTTONS */

        .btn {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
            padding: 12px 16px;
            background: var(--primary);
            border: 1px solid var(--primary);
            border-radius: 9px;
            color: white;
            font-family: inherit;
            font-size: 11px;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            transition: background 0.2s, transform 0.2s;
        }

        .btn:hover {
            background: var(--primary-dark);
            color: white;
            transform: translateY(-1px);
        }

        .btn-light {
            background: #edf4ff;
            color: #2258b3;
            border-color: #e0ebff;
        }

        .btn-light:hover {
            background: #dceaff;
            color: #1748ad;
        }

        .btn-small {
            min-width: 80px;
            padding: 9px 13px;
            border-radius: 8px;
            font-size: 10px;
        }

        /* TABLE */

        .table-wrap {
            width: 100%;
            overflow-x: auto;
        }

        .dashboard-table {
            width: 100%;
            border-collapse: collapse;
            white-space: nowrap;
        }

        .dashboard-table thead {
            background: #f3f7fd;
        }

        .dashboard-table th {
            padding: 15px 13px;
            color: #61738f;
            font-size: 9px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 800;
            text-align: left;
            border-bottom: 1px solid var(--border);
        }

        .dashboard-table td {
            padding: 15px 13px;
            color: #394b66;
            font-size: 11px;
            border-bottom: 1px solid #edf1f7;
        }

        .dashboard-table tbody tr {
            transition: background 0.2s;
        }

        .dashboard-table tbody tr:hover {
            background: #f8faff;
        }

        .dashboard-table tbody tr:last-child td {
            border-bottom: none;
        }

        .student-name {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #203451;
            font-weight: 700;
        }

        .student-avatar {
            width: 34px;
            height: 34px;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            border-radius: 50%;
            background: #e8f1ff;
            color: #2458bd;
            font-size: 10px;
            font-weight: 800;
            flex-shrink: 0;
        }

        .avatar-green {
            color: #047857;
            background: #dcfce9;
        }

        .avatar-red {
            color: #dc2626;
            background: #fee2e2;
        }

        .progress-cell {
            min-width: 145px;
        }

        .progress-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .progress-value {
            font-weight: 700;
            color: #304866;
            min-width: 30px;
        }

        .progress {
            width: 100px;
            height: 8px;
            background: #e8edf5;
            border-radius: 20px;
            overflow: hidden;
        }

        .progress span {
            display: block;
            height: 100%;
            border-radius: 20px;
            background: linear-gradient(90deg, #2563eb, #3b82f6);
        }

        .status {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 8px 11px;
            border-radius: 30px;
            font-size: 9px;
            font-weight: 800;
        }

        .status::before {
            content: "";
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: currentColor;
        }

        .status.wait {
            color: #a16207;
            background: #fff3d9;
        }

        .status.good {
            color: #047857;
            background: #ddf8eb;
        }

        .status.issue {
            color: #dc2626;
            background: #fee8e8;
        }

        /* QUICK ACTIONS */

        .quick-description {
            margin: 10px 0 20px;
            color: var(--muted);
            font-size: 12px;
        }

        .quick-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }

        .quick-actions .btn {
            min-height: 45px;
        }

        /* FOOTER */

        .footer {
            padding: 18px 30px;
            text-align: center;
            color: #8491a7;
            font-size: 10px;
            border-top: 1px solid var(--border);
            background: #fff;
        }

        /* RESPONSIVE DESIGN */

        @media (max-width: 1200px) {
            .cards {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .content {
                padding: 28px 24px;
            }

            .topbar {
                padding: 0 24px;
            }
        }

        @media (max-width: 760px) {
            .layout {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                min-width: 0;
                padding: 18px;
            }

            .brand {
                margin-bottom: 20px;
            }

            .nav-title {
                margin-top: 10px;
            }

            .nav-link {
                padding: 11px;
            }

            .sidebar-divider {
                margin: 12px 8px;
            }

            .topbar {
                padding: 15px 18px;
                flex-wrap: wrap;
            }

            .content {
                padding: 24px 15px;
            }

            .cards {
                grid-template-columns: 1fr;
                gap: 12px;
            }

            .stat-card {
                min-height: 135px;
            }

            .panel {
                padding: 17px 13px;
            }

            .panel-head {
                align-items: flex-start;
                flex-wrap: wrap;
            }

            .dashboard-table {
                min-width: 760px;
            }

            .quick-actions {
                flex-direction: column;
            }

            .quick-actions .btn {
                width: 100%;
            }
        }
    </style>
</head>

<body>

<form id="form1" runat="server">

    <div class="layout">

        <!-- SIDEBAR -->
        <aside class="sidebar">

            <div class="brand">
                UIMS
                <small>INTERNSHIP MANAGEMENT</small>
            </div>

            <div class="nav-title">Academic Supervisor</div>

            <a class="nav-link active" href="Dashboard.aspx">
                <span class="nav-icon">▦</span>
                Dashboard
            </a>

            <a class="nav-link" href="StudentProgress.aspx">
                <span class="nav-icon">◷</span>
                Student Progress
            </a>

            <a class="nav-link" href="FinalEvaluation.aspx">
                <span class="nav-icon">✓</span>
                Final Evaluation
            </a>

            <a class="nav-link" href="ZommMeetings.html">
            <span class="nav-icon">▣</span>
            Zoom Meetings
            </a>
            <a class="nav-link" href="Account.aspx">
                <span class="nav-icon">♙</span>
                My Account
            </a>

            <div class="sidebar-divider"></div>

            <div class="nav-title">General</div>

            <a class="nav-link" href="Default.aspx">
                <span class="nav-icon">↩</span>
                Back to Home
            </a>

        </aside>

        <!-- MAIN -->
        <main class="main">

            <!-- TOPBAR -->
            <header class="topbar">

                <strong>Academic Supervisor Portal</strong>

                <div class="user-chip">
                    <span class="user-avatar"><asp:Label ID="lblInitials" runat="server" /></span>
                    <asp:Label ID="lblSupervisorName" runat="server" />
                    <span>⌄</span>
                </div>

            </header>

            <!-- CONTENT -->
            <section class="content">

                <div class="eyebrow">Overview</div>

                <h1>Academic Dashboard</h1>

                <p class="subtitle">
                    Welcome back, <asp:Label ID="lblWelcomeName" runat="server" />. Here is an overview of your
                    assigned internship students.
                </p>

                <asp:Panel ID="pnlError" runat="server" Visible="false" style="padding:14px 18px;margin-bottom:18px;background:#fff0f0;color:#a61b1b;border-radius:10px;">
                    <asp:Label ID="lblError" runat="server" />
                </asp:Panel>

                <!-- STATISTICS CARDS -->
                <div class="cards">

                    <div class="stat-card">
                        <div class="stat-top">
                            <div class="stat-label">Assigned Students</div>
                            <div class="stat-icon icon-blue">♙</div>
                        </div>

                        <div class="stat-number"><asp:Label ID="lblTotalStudents" runat="server" /></div>

                        <div class="stat-note">
                            Across <asp:Label ID="lblGroupCount" runat="server" /> student groups
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-top">
                            <div class="stat-label">In Progress</div>
                            <div class="stat-icon icon-green">▥</div>
                        </div>

                        <div class="stat-number"><asp:Label ID="lblInProgress" runat="server" /></div>

                        <div class="stat-note">
                            Currently completing training
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-top">
                            <div class="stat-label">Need Follow-up</div>
                            <div class="stat-icon icon-orange">!</div>
                        </div>

                        <div class="stat-number"><asp:Label ID="lblFollowUp" runat="server" /></div>

                        <div class="stat-note">
                            Require your attention
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-top">
                            <div class="stat-label">Evaluations Pending</div>
                            <div class="stat-icon icon-purple">▤</div>
                        </div>

                        <div class="stat-number"><asp:Label ID="lblPendingEvaluations" runat="server" /></div>

                        <div class="stat-note">
                            Academic evaluation not submitted
                        </div>
                    </div>

                </div>

                <!-- STUDENTS TABLE -->
                <div class="panel">

                    <div class="panel-head">

                        <div class="panel-title">
                            <div class="panel-title-icon">♧</div>
                            <h2>Students Requiring Attention</h2>
                        </div>

                        <a class="btn btn-light"
                           href="StudentProgress.aspx">
                            View All Students &nbsp; →
                        </a>

                    </div>

                    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" style="padding:15px;color:#75839b;">No students currently require follow-up.</asp:Panel>
                    <div class="table-wrap">

                        <table class="dashboard-table">

                            <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Company</th>
                                    <th>Progress</th>
                                    <th>Training Hours</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>

                            <tbody>
                                <asp:Repeater ID="rptAttention" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td><div class="student-name"><span class="student-avatar"><%#: Eval("Initials") %></span><%#: Eval("StudentName") %></div></td>
                                            <td><%#: Eval("Company") %></td>
                                            <td class="progress-cell"><div class="progress-info"><span class="progress-value"><%#: Eval("Progress") %>%</span><div class="progress"><span style='width:<%# Eval("Progress") %>%'></span></div></div></td>
                                            <td><%#: Eval("ApprovedHours") %> / <%#: Eval("RequiredHours") %></td>
                                            <td><span class='status <%# GetStatusCss(Eval("Status")) %>'><%#: Eval("Status") %></span></td>
                                            <td><a class="btn btn-small" href="StudentProgress.aspx">Review</a></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>

                        </table>

                    </div>

                </div>

                <!-- QUICK ACTIONS -->
                <div class="panel">

                    <div class="panel-title">
                        <div class="panel-title-icon">ϟ</div>
                        <h2>Quick Actions</h2>
                    </div>

                    <p class="quick-description">
                        Open the pages you use most often.
                    </p>

                    <div class="quick-actions">

                        <a class="btn"
                           href="StudentProgress.aspx">
                            ♧ &nbsp; Monitor Students
                        </a>

                        <a class="btn btn-light"
                           href="FinalEvaluation.aspx">
                            ✓ &nbsp; Prepare Final Evaluation
                        </a>

                        <a class="btn btn-light"
                           href="Account.aspx">
                            ⚙ &nbsp; Update Account
                        </a>

                    </div>

                </div>

            </section>

            <!-- FOOTER -->
            <footer class="footer">
                University Internship Management System
                &nbsp;·&nbsp; Academic Supervisor
            </footer>

        </main>

    </div>

</form>

</body>
</html>

<%@ Page Title="Student Progress Monitor | UIMS" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true"
    CodeBehind="StudentProgress.aspx.cs"
    Inherits="PSUTInternship.Academic.StudentProgress" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<style>
        :root {
            --navy: #102544;
            --blue: #2563eb;
            --blue-dark: #1748ad;
            --bg: #f3f6fc;
            --border: #e3ebf6;
            --muted: #75849d;
            --text: #19304f;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: 'Inter', Arial, sans-serif;
            font-size: 13px;
            color: var(--text);
            background: var(--bg);
        }

        button, input, select {
            font: inherit;
        }

        .layout {
            display: flex;
            min-height: 100vh;
        }

        /* SIDEBAR */

        .sidebar {
            width: 270px;
            min-width: 270px;
            background: linear-gradient(180deg, #102544, #0b1d38);
            padding: 30px 18px;
            color: white;
        }

        .brand {
            padding: 0 10px;
            margin-bottom: 55px;
            font-size: 26px;
            font-weight: 800;
        }

        .brand small {
            display: block;
            margin-top: 7px;
            color: #a8c5ef;
            font-size: 10px;
            font-weight: 500;
            letter-spacing: 1.1px;
        }

        .nav-title {
            margin: 25px 12px 15px;
            color: #94b2dc;
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 13px;
            padding: 15px;
            margin-bottom: 7px;
            color: #dce9ff;
            text-decoration: none;
            border-radius: 11px;
            font-size: 12px;
            transition: .2s;
        }

        .nav-link i {
            font-size: 17px;
            width: 20px;
            text-align: center;
        }

        .nav-link:hover {
            color: white;
            background: rgba(255,255,255,.1);
        }

        .nav-link.active {
            background: linear-gradient(110deg, #2869e8, #2053b8);
            color: white;
            font-weight: 700;
        }

        .sidebar-divider {
            height: 1px;
            margin: 25px 10px;
            background: rgba(255,255,255,.12);
        }

        /* MAIN */

        .main {
            display: flex;
            flex: 1;
            flex-direction: column;
            min-width: 0;
        }

        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            min-height: 75px;
            padding: 0 36px;
            background: white;
            border-bottom: 1px solid var(--border);
        }

        .topbar strong {
            font-size: 13px;
        }

        .user-chip {
            display: flex;
            align-items: center;
            gap: 9px;
            padding: 10px 15px;
            background: #edf4ff;
            border-radius: 30px;
            color: #2355ae;
            font-size: 11px;
        }

        .content {
            flex: 1;
            width: 100%;
            max-width: 1600px;
            margin: 0 auto;
            padding: 36px;
        }

        .eyebrow {
            color: var(--blue);
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        h1 {
            margin: 13px 0;
            font-size: 34px;
            letter-spacing: -1px;
            color: var(--navy);
        }

        .subtitle {
            margin-bottom: 29px;
            color: var(--muted);
            font-size: 12px;
            line-height: 1.8;
        }

        /* STATISTICS */

        .cards {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 18px;
            margin-bottom: 25px;
        }

        .stat-card {
            display: block;
            width: 100%;
            min-height: 155px;
            padding: 24px;
            border: 1px solid var(--border);
            border-radius: 18px;
            background: white;
            box-shadow: 0 8px 24px rgba(16,37,68,.04);
            text-align: left;
            color: inherit;
            text-decoration: none;
            transition: .2s;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 14px 30px rgba(16,37,68,.08);
        }

        .stat-card.clickable {
            cursor: pointer;
        }

        .stat-card.selected {
            border: 2px solid var(--blue);
            background: #f6f9ff;
        }

        .stat-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .stat-label {
            color: #60728e;
            font-weight: 700;
            font-size: 12px;
        }

        .stat-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 48px;
            height: 48px;
            border-radius: 14px;
            font-size: 20px;
        }

        .icon-blue {
            background: #e8f1ff;
            color: #2563eb;
        }

        .icon-green {
            background: #dcfce9;
            color: #059669;
        }

        .icon-orange {
            background: #fff1d6;
            color: #e59a10;
        }

        .stat-number {
            display: block;
            margin: 13px 0 6px;
            color: var(--navy);
            font-size: 34px;
            font-weight: 800;
        }

        .stat-note {
            color: #8795aa;
            font-size: 11px;
        }

        /* PANEL */

        .panel {
            background: white;
            border: 1px solid var(--border);
            border-radius: 19px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 8px 25px rgba(16,37,68,.035);
        }

        .panel-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 25px;
        }

        .panel h2 {
            margin: 0 0 9px;
            font-size: 18px;
            color: var(--navy);
        }

        .muted {
            font-size: 11px;
            color: var(--muted);
        }

        /* FILTER */

        .filters {
            display: flex;
            flex-wrap: wrap;
            align-items: end;
            gap: 10px;
        }

        .filter-field {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }

        .filter-field label {
            font-size: 11px;
            color: #536986;
            font-weight: 700;
        }

        .input {
            width: 230px;
            max-width: 100%;
            height: 44px;
            padding: 0 13px;
            border: 1px solid #d7e2f0;
            border-radius: 10px;
            outline: none;
            background: #fbfcff;
            color: #293f60;
        }

        .input:focus {
            border-color: var(--blue);
            box-shadow: 0 0 0 3px rgba(37,99,235,.1);
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 7px;
            min-height: 43px;
            padding: 10px 16px;
            border: 1px solid var(--blue);
            border-radius: 10px;
            background: var(--blue);
            color: white;
            text-decoration: none;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
        }

        .btn:hover {
            background: var(--blue-dark);
        }

        .btn-light {
            background: #eef4ff;
            color: #2458b5;
            border-color: #e3ecfc;
        }

        .btn-light:hover {
            background: #e2edff;
            color: #1748ad;
        }

        .btn-small {
            min-height: 35px;
            padding: 8px 12px;
            font-size: 10px;
        }

        /* TABLE */

        .table-wrap {
            width: 100%;
            overflow-x: auto;
        }

        .table {
            width: 100%;
            min-width: 980px;
            border-collapse: collapse;
            font-size: 11px;
        }

        .table th {
            padding: 17px 13px;
            background: #f2f6fc;
            color: #61748f;
            text-align: left;
            text-transform: uppercase;
            font-size: 9px;
            letter-spacing: .5px;
            white-space: nowrap;
        }

        .table td {
            padding: 16px 13px;
            border-bottom: 1px solid #edf2f9;
            vertical-align: middle;
        }

        .table tbody tr:hover {
            background: #f8fbff;
        }

        .student-cell {
            display: flex;
            align-items: center;
            gap: 11px;
            font-weight: 700;
        }

        .avatar {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 37px;
            height: 37px;
            border-radius: 50%;
            background: #e8f1ff;
            color: #215bc7;
            font-size: 11px;
            font-weight: 800;
        }

        .progress-flex {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .progress-bar {
            width: 110px;
            height: 9px;
            border-radius: 30px;
            background: #e7edf6;
            overflow: hidden;
        }

        .progress-bar span {
            display: block;
            height: 100%;
            background: linear-gradient(90deg, #2563eb, #60a5fa);
            border-radius: 30px;
        }

        .status {
            display: inline-flex;
            align-items: center;
            padding: 8px 12px;
            border-radius: 30px;
            font-size: 10px;
            font-weight: 800;
            white-space: nowrap;
        }

        .status.ontrack,
        .status.completed {
            background: #dcfce9;
            color: #047857;
        }

        .status.atrisk,
        .status.failed {
            background: #fee2e2;
            color: #dc2626;
        }

        .status.pending,
        .status.assigned {
            background: #fff1d6;
            color: #a16207;
        }

        .status.submitted {
            background: #e8f1ff;
            color: #2458b5;
        }

        .action-cell {
            white-space: nowrap;
        }

        .action-cell .btn {
            margin: 2px;
        }

        /* MODAL */

        .modal-overlay {
            position: fixed;
            inset: 0;
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            background: rgba(15,23,42,.55);
            backdrop-filter: blur(5px);
        }

        .modal-box {
            display: flex;
            flex-direction: column;
            width: min(900px, 96vw);
            max-height: 86vh;
            background: white;
            border-radius: 22px;
            overflow: hidden;
            box-shadow: 0 25px 75px rgba(0,0,0,.22);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 15px;
            padding: 27px 32px 20px;
            border-bottom: 1px solid #edf2fa;
        }

        .modal-header h2 {
            margin: 0 0 8px;
            font-size: 23px;
        }

        .modal-header p {
            margin: 0;
            color: var(--muted);
            font-size: 12px;
        }

        .modal-close {
            border: 0;
            width: 41px;
            height: 41px;
            border-radius: 12px;
            background: #f0f4fa;
            color: #58708f;
            cursor: pointer;
            font-size: 17px;
        }

        .modal-body {
            padding: 26px 32px;
            overflow-y: auto;
            min-height: 0;
        }

        .modal-footer {
            padding: 18px 32px;
            display: flex;
            justify-content: flex-end;
            border-top: 1px solid #edf2fa;
            background: #fcfdff;
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 13px;
            margin-bottom: 27px;
        }

        .summary-card {
            padding: 17px;
            background: #f2f6fc;
            border-radius: 13px;
            border: 1px solid #e8eff9;
        }

        .summary-card small {
            display: block;
            color: #8392a9;
            font-size: 10px;
            margin-bottom: 9px;
        }

        .summary-card strong {
            font-size: 12px;
            color: #223a5b;
        }

        .section-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
        }

        .section-heading h3 {
            margin: 0;
            font-size: 14px;
        }

        /* TASK DETAILS */

        .task-card {
            padding: 21px;
            border: 1px solid #e3ebf6;
            border-radius: 15px;
            margin-bottom: 15px;
            background: white;
            box-shadow: 0 4px 13px rgba(16,37,68,.035);
        }

        .task-head {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: flex-start;
            margin-bottom: 10px;
        }

        .task-title {
            font-weight: 800;
            font-size: 14px;
            margin-bottom: 8px;
        }

        .task-description {
            font-size: 12px;
            color: #72839d;
            line-height: 1.8;
            margin-bottom: 13px;
        }

        .task-date {
            font-size: 11px;
            color: #8a99b0;
        }

        .submission-box {
            margin-top: 18px;
            padding: 18px;
            border: 1px solid #dfe9f8;
            background: #f6f9fe;
            border-radius: 12px;
        }

        .submission-box h4 {
            display: flex;
            gap: 8px;
            align-items: center;
            margin: 0 0 15px;
            font-size: 13px;
            color: #1d3b66;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 15px;
        }

        .detail-item small {
            display: block;
            margin-bottom: 7px;
            color: #8292aa;
            font-size: 10px;
        }

        .detail-item strong {
            display: block;
            color: #273c5d;
            font-size: 12px;
            font-weight: 600;
            overflow-wrap: anywhere;
        }

        .feedback-box {
            margin-top: 15px;
            padding: 14px;
            background: white;
            border-left: 3px solid var(--blue);
            border-radius: 9px;
            font-size: 12px;
            line-height: 1.8;
            color: #536782;
            overflow-wrap: anywhere;
        }

        .evaluation-card {
            border: 1px solid #e2eafa;
            border-radius: 14px;
            padding: 23px;
            background: #f7faff;
        }

        .evaluation-card h3 {
            margin: 0 0 12px;
            font-size: 17px;
        }

        .evaluation-card p {
            color: #62748e;
            font-size: 12px;
            line-height: 1.9;
        }

        .empty-state {
            padding: 28px;
            text-align: center;
            color: var(--muted);
            border: 1px dashed #dce6f4;
            border-radius: 12px;
            background: #f8faff;
        }

        .footer {
            padding: 18px;
            background: white;
            text-align: center;
            font-size: 10px;
            color: #8391a7;
        }

        .filter-surface { position: relative; }
        .stat-card-hit {
            position: absolute; inset: 0; z-index: 2;
            width: 100%; height: 100%; opacity: 0;
            cursor: pointer; border: 0;
        }
        .stat-card-hit:focus-visible { opacity: .12; outline: 3px solid #2563eb; }
        .filter-surface:has(.stat-card-hit.selected) { border: 2px solid #2563eb; background: #f6f9ff; }
        .error-banner { display: block; padding: 15px; margin-bottom: 20px; color: #9b1c1c; background: #fff0f0; border-radius: 10px; }
        @media (max-width: 1150px) {
            .cards {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 800px) {
            .layout {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                min-width: 0;
            }

            .topbar {
                padding: 15px;
            }

            .content {
                padding: 22px 15px;
            }

            .summary-grid,
            .detail-grid {
                grid-template-columns: 1fr;
            }

            .modal-header,
            .modal-body,
            .modal-footer {
                padding-left: 18px;
                padding-right: 18px;
            }

            .panel {
                padding: 18px;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="layout">

    <!-- SIDEBAR -->


    <!-- MAIN -->
    <main class="main">

        <header class="topbar">
            <strong>Academic Supervisor Portal</strong>

            <div class="user-chip">
                <i class="bi bi-circle-fill"></i>
                <asp:Label ID="lblSupervisorName" runat="server" />
            </div>
        </header>

        <section class="content">
            <asp:Label ID="lblPageError" runat="server" Visible="false" CssClass="error-banner" />

            <div class="eyebrow">Student Monitoring</div>

            <h1>Student Progress Monitor</h1>

            <p class="subtitle">
                Monitor assigned students, training companies,
                task submissions, academic evaluations,
                training hours and progress.
            </p>

            <!-- STATISTICS -->
            <div class="cards">

                <!-- TOTAL -->
                <div class="stat-card">

                    <div class="stat-top">
                        <span class="stat-label">Assigned Students</span>
                        <span class="stat-icon icon-blue">
                            <i class="bi bi-people"></i>
                        </span>
                    </div>

                    <asp:Label
                        ID="lblTotal"
                        runat="server"
                        CssClass="stat-number" />

                    <div class="stat-note">
                        Students assigned to your supervision
                    </div>

                </div>

                <!-- ON TRACK -->
                <div class="stat-card clickable filter-surface">
                    <asp:Button ID="btnOnTrack" runat="server" Text="Filter On Track" CssClass="stat-card-hit" CausesValidation="false" OnClick="btnOnTrack_Click" />

                    <div class="stat-top">
                        <span class="stat-label">On Track</span>
                        <span class="stat-icon icon-green">
                            <i class="bi bi-graph-up-arrow"></i>
                        </span>
                    </div>

                    <asp:Label
                        ID="lblOnTrack"
                        runat="server"
                        CssClass="stat-number" />

                    <div class="stat-note">
                        Click to filter students
                    </div>

                </div>

                <!-- NEEDS ATTENTION -->
                <div class="stat-card clickable filter-surface">
                    <asp:Button ID="btnAttention" runat="server" Text="Filter Needs Attention" CssClass="stat-card-hit" CausesValidation="false" OnClick="btnAttention_Click" />

                    <div class="stat-top">
                        <span class="stat-label">Needs Attention</span>
                        <span class="stat-icon icon-orange">
                            <i class="bi bi-exclamation-triangle"></i>
                        </span>
                    </div>

                    <asp:Label
                        ID="lblAttention"
                        runat="server"
                        CssClass="stat-number" />

                    <div class="stat-note">
                        Click to filter at-risk students
                    </div>

                </div>

            </div>

            <!-- MONITORING PANEL -->
            <div class="panel">

                <div class="panel-head">

                    <div>
                        <h2>Student Internship Monitoring</h2>

                        <div class="muted">
                            Review your assigned students and their progress
                        </div>
                    </div>

                    <div class="filters">

                        <div class="filter-field">
                            <label>Search</label>

                            <asp:TextBox
                                ID="txtSearch"
                                runat="server"
                                CssClass="input"
                                placeholder="Student, ID or company" />
                        </div>

                        <div class="filter-field">
                            <label>Progress Status</label>

                            <asp:DropDownList
                                ID="ddlStatus"
                                runat="server"
                                CssClass="input">

                                <asp:ListItem Value="All">
                                    All
                                </asp:ListItem>

                                <asp:ListItem Value="On Track">
                                    On Track
                                </asp:ListItem>

                                <asp:ListItem Value="At Risk">
                                    At Risk
                                </asp:ListItem>

                                <asp:ListItem Value="Not Started">Not Started</asp:ListItem>

                                <asp:ListItem Value="Completed">
                                    Completed
                                </asp:ListItem>

                            </asp:DropDownList>
                        </div>

                        <asp:Button
                            ID="btnFilter"
                            runat="server"
                            Text="Filter"
                            CssClass="btn"
                            OnClick="btnFilter_Click" />

                        <asp:Button
                            ID="btnReset"
                            runat="server"
                            Text="Reset"
                            CssClass="btn btn-light"
                            OnClick="btnReset_Click" />

                    </div>

                </div>

                <!-- STUDENTS TABLE -->
                <div class="table-wrap">

                    <asp:GridView
                        ID="gvStudents"
                        runat="server"
                        AutoGenerateColumns="False"
                        CssClass="table"
                        GridLines="None"
                        EmptyDataText="No students match your search.">

                        <Columns>

                            <asp:TemplateField HeaderText="Student">
                                <ItemTemplate>

                                    <div class="student-cell">

                                        <span class="avatar">
                                            <%#: GetInitials(Eval("StudentName")) %>
                                        </span>

                                        <span>
                                            <%#: Eval("StudentName") %>
                                        </span>

                                    </div>

                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField
                                DataField="Company"
                                HeaderText="Company" />

                            <asp:TemplateField HeaderText="Tasks">
                                <ItemTemplate>
                                    <%#: Eval("TaskCount") %> Tasks
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Training Hours">
                                <ItemTemplate>
                                    <%#: Eval("ApprovedHours") %> /
                                    <%#: Eval("RequiredHours") %> hrs
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Progress">
                                <ItemTemplate>

                                    <div class="progress-flex">

                                        <strong>
                                            <%#: Eval("Progress") %>%
                                        </strong>

                                        <div class="progress-bar">
                                            <span style='width:<%# Eval("Progress") %>%'>
                                            </span>
                                        </div>

                                    </div>

                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>

                                    <span class='status <%# GetStatusClass(Eval("Status")) %>'>
                                        <%#: Eval("Status") %>
                                    </span>

                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>

                                    <div class="action-cell">

                                        <asp:LinkButton
                                            ID="btnTasks"
                                            runat="server"
                                            CssClass="btn btn-light btn-small"
                                            CommandArgument='<%# Eval("StudentId") %>'
                                            CausesValidation="false"
                                            OnCommand="btnTasks_Command">

                                            <i class="bi bi-list-task"></i>
                                            View Tasks

                                        </asp:LinkButton>

                                        <asp:LinkButton
                                            ID="btnEvaluation"
                                            runat="server"
                                            CssClass="btn btn-small"
                                            CommandArgument='<%# Eval("StudentId") %>'
                                            CausesValidation="false"
                                            OnCommand="btnEvaluation_Command">

                                            <i class="bi bi-clipboard-check"></i>
                                            View Evaluation

                                        </asp:LinkButton>

                                    </div>

                                </ItemTemplate>
                            </asp:TemplateField>

                        </Columns>

                    </asp:GridView>

                </div>

            </div>

        </section>

        <footer class="footer">
            University Internship Management System
            · Academic Supervisor
        </footer>

    </main>

</div>

<!-- TASKS MODAL -->
<asp:Panel
    ID="pnlTasksModal"
    runat="server"
    Visible="false"
    CssClass="modal-overlay">

    <div class="modal-box"
         role="dialog"
         aria-modal="true"
         aria-labelledby="tasksModalTitle">

        <div class="modal-header">
            <div>
                <h2 id="tasksModalTitle">Assigned Tasks</h2>

                <p>
                    <asp:Label ID="lblTaskStudent"
                        runat="server" />
                </p>
            </div>

            <asp:LinkButton
                ID="btnCloseTasksTop"
                runat="server"
                CssClass="modal-close"
                CausesValidation="false"
                OnClick="btnCloseModal_Click"
                aria-label="Close tasks">
                <i class="bi bi-x-lg"></i>
            </asp:LinkButton>

        </div>

        <div class="modal-body">

            <!-- STUDENT SUMMARY -->
            <div class="summary-grid">

                <div class="summary-card">
                    <small>Training Company</small>
                    <strong>
                        <asp:Label ID="lblTaskCompany"
                            runat="server" />
                    </strong>
                </div>

                <div class="summary-card">
                    <small>Academic Supervisor</small>
                    <strong>
                        <asp:Label ID="lblTaskSupervisor"
                            runat="server" />
                    </strong>
                </div>

                <div class="summary-card">
                    <small>Approved Training Hours</small>
                    <strong>
                        <asp:Label ID="lblTaskHours"
                            runat="server" />
                    </strong>
                </div>

            </div>

            <div class="section-heading">
                <h3>All Assigned Tasks</h3>

                <strong>
                    <asp:Label ID="lblTasksCount"
                        runat="server" />
                </strong>
            </div>

            <!-- TASKS AND SUBMISSIONS -->
            <asp:Repeater
                ID="rptTasks"
                runat="server">

                <ItemTemplate>

                    <article class="task-card">

                        <div class="task-head">

                            <div>
                                <div class="task-title">
                                    <%#: Eval("Title") %>
                                </div>

                                <div class="task-description">
                                    <%#: Eval("Description") %>
                                </div>

                                <div class="task-date">
                                    <i class="bi bi-calendar3"></i>
                                    Deadline:
                                    <%#: Eval("DueDate") %>
                                </div>
                            </div>

                            <span class='status <%# GetTaskStatusClass(Eval("Status")) %>'>
                                <%#: Eval("Status") %>
                            </span>

                        </div>

                        <div class="submission-box">

                            <h4>
                                <i class="bi bi-cloud-arrow-up"></i>
                                Student Submission
                            </h4>

                            <div class="detail-grid">

                                <div class="detail-item">
                                    <small>Submission Status</small>

                                    <strong>
                                        <%#: Eval("SubmissionStatus") %>
                                    </strong>
                                </div>

                                <div class="detail-item">
                                    <small>Submitted At</small>

                                    <strong>
                                        <%#: Eval("SubmittedAt") %>
                                    </strong>
                                </div>

                                <div class="detail-item">
                                    <small>Uploaded File</small>

                                    <strong>
                                        <i class="bi bi-file-earmark-text"></i>
                                        <%#: Eval("FileName") %>
                                        <asp:HyperLink runat="server" Text="Open File"
                                            NavigateUrl='<%# Eval("FileUrl") %>' Target="_blank"
                                            rel="noopener noreferrer"
                                            Visible='<%# HasUrl(Eval("FileUrl")) %>' />
                                    </strong>
                                </div>

                                <div class="detail-item">
                                    <small>Project / Submission Link</small>

                                    <strong>
                                        <asp:HyperLink runat="server"
                                            NavigateUrl='<%# Eval("SubmissionLink") %>'
                                            Text="Open Project Link" Target="_blank"
                                            rel="noopener noreferrer"
                                            Visible='<%# HasUrl(Eval("SubmissionLink")) %>' />
                                        <asp:Label runat="server" Text="No project link"
                                            Visible='<%# !HasUrl(Eval("SubmissionLink")) %>' />
                                    </strong>
                                </div>

                                <div class="detail-item">
                                    <small>Reviewed At</small>

                                    <strong>
                                        <%#: Eval("ReviewedAt") %>
                                    </strong>
                                </div>

                                <div class="detail-item">
                                    <small>Assigned Date</small>

                                    <strong>
                                        <%#: Eval("CreatedAt") %>
                                    </strong>
                                </div>

                            </div>

                            <div class="feedback-box">

                                <p>Task grade: <%#: Eval("Score") %></p><strong>Company Supervisor Feedback</strong>

                                <div style="margin-top:7px">
                                    <%#: Eval("Feedback") %>
                                </div>

                            </div>

                        </div>

                    </article>

                </ItemTemplate>

            </asp:Repeater>

            <asp:Panel
                ID="pnlNoTasks"
                runat="server"
                Visible="false"
                CssClass="empty-state">

                No tasks assigned to this student.

            </asp:Panel>

        </div>

        <div class="modal-footer">

            <asp:Button
                ID="btnCloseTasks"
                runat="server"
                Text="Close"
                CssClass="btn btn-light"
                OnClick="btnCloseModal_Click" />

        </div>

    </div>

</asp:Panel>

<!-- EVALUATION MODAL -->
<asp:Panel
    ID="pnlEvaluationModal"
    runat="server"
    Visible="false"
    CssClass="modal-overlay">

    <div class="modal-box"
         role="dialog"
         aria-modal="true"
         aria-labelledby="evaluationModalTitle">

        <div class="modal-header">
            <div>
                <h2 id="evaluationModalTitle">
                    Academic Evaluation
                </h2>

                <p>
                    <asp:Label
                        ID="lblEvaluationStudent"
                        runat="server" />
                </p>
            </div>

            <asp:LinkButton
                ID="btnCloseEvaluationTop"
                runat="server"
                CssClass="modal-close"
                CausesValidation="false"
                OnClick="btnCloseModal_Click"
                aria-label="Close evaluation">

                <i class="bi bi-x-lg"></i>

            </asp:LinkButton>

        </div>

        <div class="modal-body">

            <div class="summary-grid">

                <div class="summary-card">
                    <small>Training Company</small>
                    <strong>
                        <asp:Label ID="lblEvaluationCompany"
                            runat="server" />
                    </strong>
                </div>

                <div class="summary-card">
                    <small>Academic Supervisor</small>
                    <strong>
                        <asp:Label ID="lblEvaluationSupervisor"
                            runat="server" />
                    </strong>
                </div>

                <div class="summary-card">
                    <small>Training Hours</small>
                    <strong>
                        <asp:Label ID="lblEvaluationHours"
                            runat="server" />
                    </strong>
                </div>

            </div>

            <div class="evaluation-card">

                <div class="task-head">

                    <h3>Academic Supervisor Evaluation</h3>

                    <asp:Label
                        ID="lblEvaluationStatus"
                        runat="server" />

                </div>

                <h3>
                    <asp:Label
                        ID="lblEvaluationRecommendation"
                        runat="server" />
                </h3>

                <p>
                    <asp:Label
                        ID="lblEvaluationComments"
                        runat="server" />
                </p>

                <div class="detail-grid">

                    <div class="detail-item">
                        <small>Academic Score</small>
                        <strong>
                            <asp:Label
                                ID="lblEvaluationScore"
                                runat="server" />
                        </strong>
                    </div>

                    <div class="detail-item">
                        <small>Submitted Date</small>
                        <strong>
                            <asp:Label
                                ID="lblEvaluationDate"
                                runat="server" />
                        </strong>
                    </div>

                </div>

            </div>

        </div>

        <div class="modal-footer">

            <asp:Button
                ID="btnCloseEvaluation"
                runat="server"
                Text="Close"
                CssClass="btn btn-light"
                OnClick="btnCloseModal_Click" />

        </div>

    </div>

</asp:Panel>
</asp:Content>

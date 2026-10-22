<%@ Register Src="~/Shared/StudentLinks.ascx" TagPrefix="psut" TagName="StudentLinks" %>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentProgress.aspx.cs"  Async="true" Inherits="PSUTInternship.Student.StudentProgress" %>



<!DOCTYPE html>
<html>
<head runat="server">
    <title>My Progress & Evaluation</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: 'Segoe UI', Arial, sans-serif;
            background: #F5F8FC;
            color: #1E293B;
        }

        .container {
            max-width: 1150px;
            margin: 35px auto;
            padding: 0 20px;
        }

        .page-header {
            margin-bottom: 25px;
        }

        .page-header h1 {
            color: #061B70;
            font-size: 27px;
            margin: 0 0 8px;
        }

        .page-header p {
            color: #64748B;
            margin: 0;
            font-size: 14px;
        }

        /* Summary Cards */

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 25px;
        }

        .summary-card {
            background: white;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 20px;
        }

        .summary-card span {
            display: block;
            color: #64748B;
            font-size: 13px;
            margin-bottom: 12px;
        }

        .summary-card h2 {
            margin: 0;
            color: #061B70;
            font-size: 30px;
        }

        /* Sections */

        .section {
            background: white;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 22px;
        }

        .section h3 {
            color: #061B70;
            margin: 0 0 18px;
            font-size: 18px;
        }

        .section-description {
            font-size: 13px;
            color: #64748B;
            margin-bottom: 20px;
        }

        /* Training Progress */

        .hours-info {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            font-size: 14px;
        }

        .progress-bar {
            height: 12px;
            background: #E2E8F0;
            border-radius: 20px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            width: 0%;
            background: #00A7D8;
            border-radius: 20px;
        }

        /* Tables */

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        th {
            background: #F1F5F9;
            color: #334155;
            text-align: left;
            padding: 13px;
        }

        td {
            padding: 14px 13px;
            border-bottom: 1px solid #E2E8F0;
        }

        .status {
            display: inline-block;
            padding: 5px 11px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .submitted {
            background: #DBEAFE;
            color: #1D4ED8;
        }

        .revision {
            background: #FEF3C7;
            color: #92400E;
        }

        .approved {
            background: #DCFCE7;
            color: #166534;
        }

        /* Evaluation */

        .evaluation-card {
            padding: 17px;
            background: #F8FAFC;
            border: 1px solid #E2E8F0;
            border-radius: 10px;
            margin-bottom: 12px;
        }

        .evaluation-card h4 {
            margin: 0 0 8px;
            color: #005B9A;
        }

        .evaluation-card p {
            color: #475569;
            margin: 0;
            font-size: 14px;
            line-height: 1.7;
        }

        /* Report */

        .report-box {
            background: #F8FAFC;
            border: 1px dashed #CBD5E1;
            border-radius: 10px;
            padding: 24px;
            text-align: center;
        }

        .report-box h4 {
            margin: 0 0 10px;
            color: #061B70;
        }

        .report-box p {
            color: #64748B;
            font-size: 14px;
        }

        .report-btn {
            display: inline-block;
            margin-top: 10px;
            padding: 11px 20px;
            background: #005B9A;
            color: white;
            text-decoration: none;
            border-radius: 7px;
            font-size: 13px;
        }

        .report-btn:hover {
            background: #061B70;
        }

        @media (max-width: 850px) {
            .summary-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 480px) {
            .summary-grid {
                grid-template-columns: 1fr;
            }

            .container {
                padding: 0 12px;
            }
        }
    </style>
</head>

<body>
<form id="form1" runat="server">
<psut:StudentLinks runat="server" />

    <div class="container">

        <div class="page-header">
            <h1>My Progress & Evaluation</h1>
            <p>Monitor your internship tasks, feedback and progress.</p>
        </div>

        <!-- Summary -->

        <div class="summary-grid">

            <div class="summary-card">
                <span>Total Tasks</span>
                <h2>
                    <asp:Label ID="lblTotalTasks"
                        runat="server" Text="—" />
                </h2>
            </div>

            <div class="summary-card">
                <span>Submitted Tasks</span>
                <h2>
                    <asp:Label ID="lblSubmittedTasks"
                        runat="server" Text="—" />
                </h2>
            </div>

            <div class="summary-card">
                <span>Requested Revisions</span>
                <h2>
                    <asp:Label ID="lblRevisions"
                        runat="server" Text="—" />
                </h2>
            </div>

            <div class="summary-card">
                <span>Approved Hours</span>
                <h2>
                    <asp:Label ID="lblApprovedHours"
                        runat="server" Text="—" />
                </h2>
            </div>

        </div>

        <!-- Training Progress -->

        <div class="section">

            <h3>Training Progress</h3>

            <div class="hours-info">
                <span>Approved Training Hours</span>

                <asp:Label ID="lblHoursProgress"
                    runat="server"
                    Text="Awaiting data" />
            </div>
            <asp:Label ID="lblPercentage"
    runat="server"
    Text="0%" />

            <div class="progress-bar">
                <div id="progressFill"
                    runat="server"
                    class="progress-fill">
                </div>
            </div>

        </div>

       
<!-- Task Progress -->
<div class="section">

    <h3>Task Progress</h3>

    <p class="section-description">
        Track your submitted tasks and requested revisions.
    </p>

    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>Task</th>
                    <th>Submission Date</th>
                    <th>Status</th>
                </tr>
            </thead>

            <tbody>
                <asp:Repeater ID="rptTasks" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><%#: Eval("Title") %></td>
                            <td><%#: Eval("SubmissionDate") %></td>
                            <td><%#: Eval("Status") %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>

    <asp:Label ID="lblNoTasks"
        runat="server"
        Text="No task progress available yet."
        Visible="true" />

</div>


<!-- Task Feedback -->
<div class="section">

    <h3>Task Feedback</h3>

    <p class="section-description">
        View feedback on your submitted tasks.
    </p>

    <asp:Repeater ID="rptEvaluations" runat="server">
        <ItemTemplate>
            <div class="evaluation-card">
                <h4><%#: Eval("Title") %></h4>
                <p><%#: Eval("Comments") %></p>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <asp:Label ID="lblNoEvaluations"
        runat="server"
        Text="No task feedback available yet." />

</div>


<!-- Internship Evaluations -->
<div class="section">

    <h3>Internship Evaluations</h3>

    <p class="section-description">
        View your internship performance evaluations.
    </p>

    <asp:Repeater ID="rptInternshipEvaluations" runat="server">
        <ItemTemplate>
            <div class="evaluation-card">
                <h4><%#: Eval("Title") %></h4>
                <p><%#: Eval("Comments") %></p>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <asp:Label ID="lblNoInternshipEvaluations"
        runat="server"
        Text="No internship evaluations available yet." />

</div>


        <!-- Completion Report -->

        <div class="section">

            <h3>Internship Completion Report</h3>

            <div class="report-box">

                <h4>Official Internship Completion Report</h4>

                <asp:Label ID="lblReportStatus"
                    runat="server"
                    Text="Awaiting Coordinator Approval" />

                <p>
                    Your official report will be available
                    after the Internship Coordinator approves
                    your internship completion.
                </p>

                <asp:HyperLink ID="lnkReport"
                    runat="server"
                    CssClass="report-btn"
                    Text="View / Download PDF"
                    Target="_blank"
                    Visible="false" />

            </div>

        </div>

    </div>

</form>
</body>
</html>


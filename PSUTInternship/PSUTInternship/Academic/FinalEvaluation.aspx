<%@ Page Title="Final Academic Evaluation | UIMS" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="FinalEvaluation.aspx.cs" Inherits="PSUTInternship.Academic.FinalEvaluation" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">


<style>
        :root {
            --primary: #2563eb;
            --primary-dark: #1748ad;
            --navy: #102544;
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

        /* ================= LAYOUT ================= */

        .layout {
            display: flex;
            min-height: 100vh;
        }

        /* ================= SIDEBAR ================= */

        .sidebar {
            width: 250px;
            min-width: 250px;
            background: linear-gradient(180deg, #102544, #0b1d38);
            color: white;
            padding: 27px 17px;
        }

        .brand {
            padding: 0 10px;
            margin-bottom: 47px;
            font-size: 27px;
            font-weight: 800;
            letter-spacing: 1px;
        }

        .brand small {
            display: block;
            margin-top: 7px;
            color: #a8c5ef;
            font-size: 9px;
            font-weight: 500;
            letter-spacing: 1.5px;
        }

        .nav-title {
            margin: 0 0 14px;
            padding: 0 12px;
            color: #91a7c7;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: 1.1px;
            text-transform: uppercase;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 6px;
            padding: 14px 13px;
            border-radius: 10px;
            color: #dce8fa;
            text-decoration: none;
            font-size: 12px;
            font-weight: 500;
            transition: background .2s, color .2s;
        }

        .nav-link:hover {
            background: rgba(255,255,255,.09);
            color: white;
        }

        .nav-link.active {
            background: linear-gradient(100deg, #2869e8, #1b50b8);
            color: white;
            box-shadow: 0 5px 15px rgba(20,70,170,.2);
        }

        .nav-icon {
            width: 20px;
            text-align: center;
            font-size: 17px;
        }

        .sidebar-divider {
            height: 1px;
            margin: 24px 8px;
            background: rgba(255,255,255,.12);
        }

        /* ================= MAIN ================= */

        .main {
            display: flex;
            flex: 1;
            flex-direction: column;
            min-width: 0;
        }

        .topbar {
            min-height: 70px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            padding: 0 36px;
            background: white;
            border-bottom: 1px solid var(--border);
        }

        .topbar strong {
            font-size: 13px;
            font-weight: 700;
        }

        .user-chip {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            padding: 7px 13px 7px 7px;
            border-radius: 30px;
            background: #edf4ff;
            color: #2555a5;
            font-size: 11px;
            font-weight: 600;
        }

        .user-avatar {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 29px;
            height: 29px;
            border-radius: 50%;
            background: #d9e8ff;
            color: #2058bd;
            font-weight: 800;
        }

        .content {
            flex: 1;
            width: 100%;
            max-width: 1600px;
            margin: 0 auto;
            padding: 34px 36px;
        }

        .eyebrow {
            margin-bottom: 12px;
            color: var(--primary);
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        h1 {
            margin: 0;
            color: #152744;
            font-size: clamp(25px, 2.3vw, 33px);
            font-weight: 800;
            letter-spacing: -1px;
        }

        .page-description {
            max-width: 760px;
            margin: 12px 0 28px;
            color: var(--muted);
            font-size: 12px;
            line-height: 1.9;
        }

        /* ================= INTRO BANNER ================= */

        .intro-banner {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            overflow: hidden;
            margin-bottom: 25px;
            padding: 23px 26px;
            border: 1px solid #dce8fc;
            border-radius: 15px;
            background: linear-gradient(110deg, #eaf2ff, #ffffff);
        }

        .intro-text {
            position: relative;
            z-index: 1;
        }

        .intro-label {
            margin-bottom: 9px;
            color: #2563eb;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 1.3px;
            text-transform: uppercase;
        }

        .intro-banner h2 {
            margin: 0 0 8px;
            color: #193458;
            font-size: 17px;
            font-weight: 800;
        }

        .intro-banner p {
            max-width: 600px;
            margin: 0;
            color: #647795;
            font-size: 11px;
            line-height: 1.8;
        }

        .intro-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 68px;
            height: 68px;
            flex-shrink: 0;
            border: 1px solid #d6e5ff;
            border-radius: 19px;
            background: white;
            color: #2563eb;
            font-size: 32px;
            box-shadow: 0 6px 18px rgba(37,99,235,.08);
        }

        /* ================= PANELS ================= */

        .panel {
            margin-bottom: 22px;
            padding: 25px;
            border: 1px solid var(--border);
            border-radius: 16px;
            background: white;
            box-shadow: 0 5px 20px rgba(25,53,96,.035);
        }

        .panel-heading {
            display: flex;
            align-items: center;
            gap: 13px;
            margin-bottom: 25px;
            padding-bottom: 20px;
            border-bottom: 1px solid #edf1f7;
        }

        .panel-heading-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 43px;
            height: 43px;
            flex-shrink: 0;
            border-radius: 13px;
            background: #eaf2ff;
            color: #2563eb;
            font-size: 21px;
        }

        .panel-heading h2 {
            margin: 0;
            color: #1a2b46;
            font-size: 15px;
            font-weight: 800;
        }

        .panel-heading p {
            margin: 6px 0 0;
            color: #8491a7;
            font-size: 11px;
            line-height: 1.7;
        }

        /* ================= FORM GRID ================= */

        .field-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 23px 20px;
        }

        .field {
            display: flex;
            flex-direction: column;
            min-width: 0;
            margin-bottom: 23px;
        }

        .field-grid .field {
            margin-bottom: 0;
        }

        .field label {
            margin-bottom: 9px;
            color: #354761;
            font-size: 11px;
            font-weight: 700;
        }

        .required {
            color: #dc2626;
            margin-left: 3px;
        }

        .input {
            display: block;
            width: 100%;
            min-width: 0;
            height: 45px;
            padding: 0 13px;
            border: 1px solid #d7e1f0;
            border-radius: 9px;
            outline: none;
            background: #fbfcff;
            color: #243752;
            font-family: inherit;
            font-size: 12px;
            transition: border .2s, box-shadow .2s, background .2s;
        }

        select.input {
            cursor: pointer;
        }

        textarea.input {
            height: auto;
            min-height: 135px;
            padding: 13px;
            resize: vertical;
            line-height: 1.8;
        }

        .input:focus {
            border-color: #5b8def;
            background: white;
            box-shadow: 0 0 0 3px rgba(37,99,235,.1);
        }

        .input::placeholder {
            color: #a1adbf;
        }

        .field-hint {
            display: block;
            margin-top: 9px;
            color: #8996aa;
            font-size: 10px;
            line-height: 1.8;
        }

        .section-divider {
            height: 1px;
            margin: 25px 0;
            background: #edf1f7;
        }

        /* ================= SUBMIT AREA ================= */

        .submit-area {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            flex-wrap: wrap;
            margin-top: 8px;
            padding-top: 21px;
            border-top: 1px solid #edf1f7;
        }

        .submit-note {
            display: flex;
            align-items: flex-start;
            gap: 9px;
            max-width: 420px;
            color: #7b8aa1;
            font-size: 10px;
            line-height: 1.8;
        }

        .note-icon {
            color: #2563eb;
            font-size: 17px;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            min-height: 44px;
            padding: 12px 19px;
            border: 1px solid var(--primary);
            border-radius: 9px;
            background: var(--primary);
            color: white;
            font-family: inherit;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            transition: background .2s, transform .2s, box-shadow .2s;
        }

        .btn:hover {
            transform: translateY(-1px);
            background: var(--primary-dark);
            box-shadow: 0 5px 14px rgba(37,99,235,.2);
        }

        .btn:focus-visible {
            outline: 3px solid #bfdbfe;
            outline-offset: 3px;
        }

        /* ================= SERVER MESSAGE ================= */

        .message {
            display: block;
            margin-top: 18px;
            padding: 13px 15px;
            border: 1px solid #bfdbfe;
            border-radius: 9px;
            background: #eff6ff;
            color: #1d4ed8;
            font-size: 11px;
            line-height: 1.8;
        }

        .message:empty {
            display: none;
        }

        /* ================= WORKFLOW ================= */

        .workflow-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 15px;
        }

        .workflow-step {
            position: relative;
            min-height: 155px;
            padding: 19px 16px;
            border: 1px solid #e5ebf5;
            border-radius: 12px;
            background: #fbfcff;
            transition: border-color .2s, transform .2s;
        }

        .workflow-step:hover {
            transform: translateY(-2px);
            border-color: #c8d9f7;
        }

        .step-number {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 34px;
            height: 34px;
            margin-bottom: 16px;
            border-radius: 10px;
            background: #e6efff;
            color: #2563eb;
            font-size: 12px;
            font-weight: 800;
        }

        .workflow-step h3 {
            margin: 0 0 8px;
            color: #263b59;
            font-size: 12px;
            font-weight: 800;
        }

        .workflow-step p {
            margin: 0;
            color: #7a899f;
            font-size: 10px;
            line-height: 1.8;
        }

        /* ================= FOOTER ================= */

        .footer {
            padding: 18px 30px;
            border-top: 1px solid var(--border);
            background: white;
            color: #8491a7;
            text-align: center;
            font-size: 10px;
        }

        /* ================= RESPONSIVE ================= */

        @media (max-width: 1200px) {
            .content {
                padding: 28px 24px;
            }

            .topbar {
                padding: 0 24px;
            }

            .workflow-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
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
                margin-bottom: 22px;
            }

            .nav-title {
                margin-top: 12px;
            }

            .nav-link {
                padding: 11px;
            }

            .sidebar-divider {
                margin: 12px 8px;
            }

            .topbar {
                min-height: 65px;
                padding: 14px 18px;
                flex-wrap: wrap;
            }

            .content {
                padding: 23px 14px;
            }

            .intro-banner {
                padding: 19px;
            }

            .intro-icon {
                width: 52px;
                height: 52px;
                font-size: 25px;
            }

            .panel {
                padding: 19px 15px;
            }

            .field-grid {
                grid-template-columns: 1fr;
                gap: 22px;
            }

            .workflow-grid {
                grid-template-columns: 1fr;
            }

            .workflow-step {
                min-height: auto;
            }

            .submit-area {
                align-items: stretch;
                flex-direction: column;
            }

            .submit-area .btn {
                width: 100%;
            }

            .footer {
                padding: 17px 12px;
            }
        }


.summary-cards{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:14px;margin-bottom:20px}
.summary-tile{background:#f6f9ff;border:1px solid #e0eaf8;border-radius:12px;padding:17px}
.summary-tile span{display:block;font-size:10px;color:#73829b;margin-bottom:9px}
.summary-tile strong{font-size:21px;color:#173458}
.task-table{width:100%;border-collapse:collapse;min-width:660px}
.task-table th,.task-table td{padding:13px;text-align:left;border-bottom:1px solid #e9eef7;font-size:11px}
.task-table th{background:#f5f8fd;color:#657996;font-weight:800}
.task-scroll{overflow-x:auto}.data-note{padding:13px 15px;background:#f6f9ff;color:#506786;border-radius:10px;line-height:1.8;margin-top:14px}
.report-row{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px;margin-bottom:18px}
.report-label{display:block;color:#788aa4;font-size:11px;margin-bottom:6px}
.report-value{font-weight:700;overflow-wrap:anywhere;white-space:pre-wrap;line-height:1.7}
.report-block{padding:17px;background:#f8faff;border:1px solid #e7eef8;border-radius:12px;margin:14px 0;white-space:pre-wrap;line-height:1.8}
.btn-secondary{background:#eef4ff;color:#2458b5;border-color:#dce8fb}.btn-secondary:hover{background:#dceaff;color:#1748ad}
.btn:disabled{opacity:.48;cursor:not-allowed;transform:none}.msg-ok{background:#ecfdf3;border-color:#b4eccd;color:#067647}.msg-error{background:#fff2f2;border-color:#ffcaca;color:#b91c1c}
@media(max-width:850px){.summary-cards{grid-template-columns:repeat(2,1fr)}.report-row{grid-template-columns:1fr}}
@media print{.sidebar,.topbar,.intro-banner,.submit-area,.footer,.workflow-panel,.no-print,.page-description,.eyebrow{display:none!important}.layout,.main,.content{display:block!important;width:100%!important;padding:0!important}.panel{box-shadow:none!important;break-inside:avoid}.report-print-title{display:block!important}}
 .report-print-title{display:none}
.print-only{display:none}
@media print{
 @page{size:A4;margin:14mm}
 body{background:#fff!important;color:#172b49!important;font-size:11px!important}
 .content{max-width:none!important}
 .panel{border:1px solid #d9e0e9!important;margin:0 0 14px!important;padding:14px!important;break-inside:auto!important}
 .report-print-title{font-size:20px!important;margin-bottom:14px!important}
 .print-only{display:block!important}
 .academic-entry{display:none!important}
 .academic-print-section{border:1px solid #e3e8f0;border-radius:8px;padding:12px;margin-top:10px}
 .task-scroll{overflow:visible!important}
 .task-table{width:100%!important;min-width:0!important;table-layout:fixed;word-break:break-word}
 .task-table tr{break-inside:avoid}
 .report-block{break-inside:auto;white-space:pre-wrap}
 .panel-heading{break-after:avoid}
 .no-print{display:none!important}
}
</style>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="layout">

<main class="main"><header class="topbar"><strong>Academic Supervisor Portal</strong><div class="user-chip"><span class="user-avatar"><asp:Label ID="lblInitials" runat="server" Text="AS"/></span><asp:Label ID="lblSupervisor" runat="server" Text="Academic Supervisor"/></div></header>
<section class="content">
<div class="eyebrow">Academic Assessment</div><h1>Final Academic Evaluation</h1>
<p class="page-description">Review the company training report, student tasks and approved hours; record academic feedback and submit the assessment to the coordinator queue.</p>
<div class="intro-banner no-print"><div class="intro-text"><div class="intro-label">Evaluation Workflow</div><h2>Company report → Academic review → Coordinator</h2><p>Company results remain unchanged. Your academic assessment is stored separately and routed for coordinator review.</p></div><div class="intro-icon"><i class="bi bi-file-earmark-check"></i></div></div>
<asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="message no-print"/>
<div class="panel no-print"><div class="panel-heading"><div class="panel-heading-icon"><i class="bi bi-person-check"></i></div><div><h2>1. Choose assigned student</h2><p>Only students assigned to your account are listed.</p></div></div>
<div class="field-grid"><div class="field"><asp:Label runat="server" AssociatedControlID="Opportunity" Text="Training opportunity" /><asp:DropDownList ID="Opportunity" runat="server" CssClass="input" AutoPostBack="true" OnSelectedIndexChanged="Opportunity_Changed" /></div><div class="field"><label>Select Student</label><asp:DropDownList ID="ddlStudent" runat="server" CssClass="input" AutoPostBack="true" OnSelectedIndexChanged="ddlStudent_SelectedIndexChanged"/></div><div class="field"><label>Assigned Academic Supervisor</label><div class="input" style="display:flex;align-items:center"><%: lblSupervisor.Text %></div></div></div></div>
<asp:Panel ID="pnlReport" runat="server" Visible="false">
<div class="panel" id="printArea"><h2 class="report-print-title">University Internship Final Evaluation</h2>
<div class="panel-heading"><div class="panel-heading-icon"><i class="bi bi-file-earmark-text"></i></div><div><h2>2. Company Training Report</h2><p>Facts retrieved from Firebase, not manually entered grades.</p></div></div>
<div class="report-row"><div><span class="report-label">Student</span><asp:Label ID="lblStudent" runat="server" CssClass="report-value"/></div><div><span class="report-label">Student Number</span><asp:Label ID="lblStudentNumber" runat="server" CssClass="report-value"/></div><div><span class="report-label">Company</span><asp:Label ID="lblCompany" runat="server" CssClass="report-value"/></div><div><span class="report-label">Internship</span><asp:Label ID="lblInternship" runat="server" CssClass="report-value"/></div></div>
<div class="summary-cards"><div class="summary-tile"><span>Tasks Total</span><strong><asp:Label ID="lblTaskTotal" runat="server"/></strong></div><div class="summary-tile"><span>Completed Tasks</span><strong><asp:Label ID="lblTaskCompleted" runat="server"/></strong></div><div class="summary-tile"><span>Approved Hours</span><strong><asp:Label ID="lblHours" runat="server"/></strong></div><div class="summary-tile"><span>Company Result</span><strong style="font-size:15px"><asp:Label ID="lblCompanyResult" runat="server"/></strong></div></div>
<div class="report-row"><div><span class="report-label">Company evaluation status</span><asp:Label ID="lblCompanyStatus" runat="server" CssClass="report-value"/></div><div><span class="report-label">Academic evaluation status</span><asp:Label ID="lblAcademicStatus" runat="server" CssClass="report-value"/></div></div>
<h2 style="margin:20px 0 14px">Assigned Tasks &amp; Submissions</h2><div class="task-scroll"><asp:GridView ID="gvTasks" runat="server" AutoGenerateColumns="false" CssClass="task-table" GridLines="None" EmptyDataText="No tasks recorded for this student."><Columns>
<asp:BoundField DataField="Title" HeaderText="Task" HtmlEncode="true"/><asp:BoundField DataField="Status" HeaderText="Task Status"/><asp:BoundField DataField="Submission" HeaderText="Submission"/><asp:BoundField DataField="Feedback" HeaderText="Company Feedback" HtmlEncode="true"/>
</Columns></asp:GridView></div>
<h2 style="margin:24px 0 10px">Company Supervisor Feedback</h2><div class="report-block"><asp:Label ID="lblCompanyFeedback" runat="server"/></div>
<div class="report-row"><div><span class="report-label">Company Recommendation</span><asp:Label ID="lblCompanyRecommendation" runat="server" CssClass="report-value"/></div><div><span class="report-label">Company Score</span><asp:Label ID="lblCompanyScore" runat="server" CssClass="report-value"/></div></div>
<asp:HyperLink ID="lnkCompanyFile" runat="server" Target="_blank" CssClass="btn btn-secondary no-print" Visible="false" Text="Open Company Report File"/>
<asp:Label ID="lblReportNotice" runat="server" CssClass="data-note"/>
</div>
<div class="panel"><div class="panel-heading"><div class="panel-heading-icon"><i class="bi bi-pencil-square"></i></div><div><h2>3. Academic Supervisor Assessment</h2><p>Add your own feedback without altering the company evaluation.</p></div></div>
<div class="academic-entry"><div class="field-grid"><div class="field"><label>Percentage (%)</label><asp:TextBox ID="txtScore" runat="server" CssClass="input" TextMode="Number" min="0" max="100" step="0.01" placeholder="e.g. 85"/><asp:Label ID="PercentageError" runat="server" CssClass="field-error" /></div><div class="field"><label>Academic Final Recommendation</label><asp:DropDownList ID="ddlRecommendation" runat="server" CssClass="input"><asp:ListItem Text="Select recommendation" Value=""/><asp:ListItem Text="Pass" Value="Pass"/><asp:ListItem Text="Fail" Value="Fail"/><asp:ListItem Text="More information required" Value="More information required"/><asp:ListItem Text="Additional training required" Value="Additional training required"/></asp:DropDownList><asp:Label ID="RecommendationError" runat="server" CssClass="field-error" /></div></div>
<div class="field"><label>Academic Feedback</label><asp:TextBox ID="txtComments" runat="server" TextMode="MultiLine" Rows="5" CssClass="input" MaxLength="3000" placeholder="Review task quality, training progress, company feedback and final recommendations..."/><asp:Label ID="CommentsError" runat="server" CssClass="field-error" /></div></div>
<div class="academic-print-section print-only">
 <div class="report-row"><div><span class="report-label">Academic Supervisor</span><strong><asp:Label ID="lblSupervisorPrint" runat="server" Text="" /></strong></div><div><span class="report-label">Academic score</span><strong id="printAcademicScore">Not provided</strong></div></div>
 <div class="report-row"><div><span class="report-label">Academic Recommendation</span><strong id="printAcademicRecommendation">Not provided</strong></div><div><span class="report-label">Report Generated</span><strong id="printGeneratedAt">—</strong></div></div>
 <h3>Academic Supervisor Feedback</h3><div class="report-block" id="printAcademicFeedback">Not provided</div>
</div>
<div class="submit-area no-print"><div class="submit-note"><span class="note-icon"><i class="bi bi-info-circle"></i></span><span>Submitting requires a real internship and a submitted company evaluation. The coordinator must have a dashboard that reads this queue.</span></div><div style="display:flex;gap:10px;flex-wrap:wrap"><button class="btn btn-secondary" type="button" onclick="printCombinedReport()"><i class="bi bi-printer"></i> Print / Save PDF</button><asp:Button ID="btnSubmit" runat="server" Text="Submit to Coordinator" CssClass="btn" CausesValidation="false" OnClick="btnSubmit_Click"/></div></div>
</div></asp:Panel>
<div class="panel workflow-panel no-print"><div class="panel-heading"><div class="panel-heading-icon"><i class="bi bi-arrow-right-circle"></i></div><div><h2>Workflow</h2><p>1. Review company report → 2. Add academic feedback → 3. Submit to Firebase coordinator queue → 4. Coordinator reviews.</p></div></div></div>
</section><footer class="footer">University Internship Management System · Academic Supervisor</footer></main></div>
<script type="text/javascript">
(function () {
    function visibleText(id, fallback) {
        var el = document.getElementById(id);
        var value = el ? (el.value || '').trim() : '';
        return value || fallback;
    }
    window.prepareCombinedReport = function () {
        var score = document.getElementById('<%= txtScore.ClientID %>');
        var recommendation = document.getElementById('<%= ddlRecommendation.ClientID %>');
        var comments = document.getElementById('<%= txtComments.ClientID %>');
        var rec = recommendation && recommendation.selectedIndex >= 0
            ? recommendation.options[recommendation.selectedIndex].text : '';
        document.getElementById('printAcademicScore').textContent = score && score.value.trim() ? score.value.trim() + '%' : 'Not provided';
        document.getElementById('printAcademicRecommendation').textContent = recommendation && recommendation.value ? rec : 'Not provided';
        document.getElementById('printAcademicFeedback').textContent = comments && comments.value.trim() ? comments.value.trim() : 'Not provided';
        document.getElementById('printGeneratedAt').textContent = new Date().toLocaleString();
    };
    window.printCombinedReport = function () {
        window.prepareCombinedReport();
        window.print();
    };
    window.addEventListener('beforeprint', window.prepareCombinedReport);
}());
</script>
</asp:Content>

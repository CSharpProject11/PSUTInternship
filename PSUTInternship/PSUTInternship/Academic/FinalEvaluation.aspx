<%@ Page Title="Final Academic Evaluation | UIMS" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="FinalEvaluation.aspx.cs" Inherits="PSUTInternship.Academic.FinalEvaluation" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">


<style>
body.portal-app .portal-content .academic-evaluation{max-width:1200px;margin:auto;color:#19394f}
body.portal-app .portal-content .academic-evaluation h1{font-size:27px!important;letter-spacing:-.035em;margin:0 0 8px!important}body.portal-app .portal-content .academic-evaluation h2{font-size:17px!important;line-height:1.5;margin:0 0 8px!important}body.portal-app .portal-content .academic-evaluation h3{font-size:14px!important}
body.portal-app .portal-content .academic-evaluation .page-description{font-size:13px!important;font-weight:400!important;line-height:1.7;color:#607587;margin:0 0 24px!important}
body.portal-app .portal-content .academic-evaluation .fe-panel{border:1px solid #dce6ed;border-radius:12px;background:#fff;padding:24px;margin-bottom:22px;box-shadow:none}
.academic-evaluation .fe-panel-heading{display:flex;gap:14px;margin:0 0 22px;align-items:flex-start}.academic-evaluation .fe-panel-heading p{font-size:12px!important;font-weight:400!important;color:#607587;margin:4px 0 0!important;line-height:1.6}.academic-evaluation .panel-heading-icon{display:none}
.academic-evaluation .field-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:20px}.academic-evaluation .field{min-width:0;margin-bottom:18px}.academic-evaluation .field label{display:block;font-size:12px!important;font-weight:600!important;color:#526b7d;margin:0 0 8px!important}
body.portal-app .portal-content .academic-evaluation .input{width:100%!important;box-sizing:border-box;min-height:46px!important;border:1px solid #cddce6!important;border-radius:8px!important;padding:11px 13px!important;background:#fff!important;font-size:13px!important;font-weight:400!important;color:#19394f!important;box-shadow:none!important;margin:0!important}.academic-evaluation textarea{resize:vertical;line-height:1.8}.academic-evaluation :is(input,select,textarea,button,a):focus-visible{outline:2px solid #0078b5!important;outline-offset:3px}
.academic-evaluation .report-row{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px;padding:18px 0;border-bottom:1px solid #e5ecf1;margin-bottom:18px}.academic-evaluation .report-label{display:block;font-size:11px;color:#607587;margin-bottom:6px}.academic-evaluation .report-value{display:block;font-size:13px;font-weight:650;overflow-wrap:anywhere}
.academic-evaluation .summary-cards{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));border:1px solid #e0e8ef;border-radius:9px;padding:18px 0;margin:22px 0}.academic-evaluation .summary-tile{padding:0 20px;border-right:1px solid #e0e8ef}.academic-evaluation .summary-tile:last-child{border:0}.academic-evaluation .summary-tile>span{display:block;font-size:11px;color:#607587}.academic-evaluation .summary-tile strong{display:block;font-size:25px!important;font-weight:700;color:#003e73;margin-top:8px}.academic-evaluation .summary-tile:last-child strong{font-size:15px!important;line-height:1.6}
.academic-evaluation .task-scroll{overflow:auto;border:1px solid #e0e8ef;border-radius:8px;margin:16px 0 24px}.academic-evaluation .task-table{width:100%;border-collapse:collapse;min-width:600px}.academic-evaluation .task-table th{text-align:left!important;font-size:11px!important;font-weight:600!important;color:#607587;background:#fafcfd!important;padding:12px 16px!important}.academic-evaluation .task-table td{text-align:left!important;font-size:12px!important;line-height:1.6;padding:14px 16px!important;border:0;border-top:1px solid #e5ecf1;overflow-wrap:anywhere}
.academic-evaluation .report-block{font-size:13px;line-height:1.8;white-space:pre-line;color:#526b7d;padding:16px;background:#f7f9fb;border:1px solid #e5ecf1;border-radius:8px;margin:14px 0}.academic-evaluation .data-note{display:block;font-size:12px;color:#607587;margin-top:14px;line-height:1.7}.academic-evaluation .field-error{display:block;color:#ae4040;font-size:12px;margin-top:6px}
.academic-evaluation .submit-area{display:flex;justify-content:space-between;align-items:center;gap:24px;border-top:1px solid #e5ecf1;margin-top:6px;padding-top:22px}.academic-evaluation .submit-note{font-size:12px;color:#607587;line-height:1.7;max-width:420px}.academic-evaluation .note-icon{display:none}
body.portal-app .portal-content .academic-evaluation .btn{display:inline-flex;align-items:center;justify-content:center;min-height:44px!important;padding:11px 17px!important;font-size:12px!important;font-weight:650!important;background:#003e73!important;border:1px solid #003e73!important;border-radius:8px!important;color:#fff!important;line-height:1.5!important;text-decoration:none;margin:0!important}.academic-evaluation .btn i{display:none}body.portal-app .portal-content .academic-evaluation .btn-secondary{background:#fff!important;color:#003e73!important;border-color:#cddce6!important}
.academic-evaluation .message{display:block;font-size:13px;padding:16px;border-radius:8px;background:#eef6fb;margin-bottom:20px}.academic-evaluation .print-only,.academic-evaluation .report-print-title{display:none}
@media(max-width:700px){body.portal-app .portal-content .academic-evaluation .fe-panel{padding:18px}.academic-evaluation .field-grid{grid-template-columns:1fr;gap:0}.academic-evaluation .summary-cards{grid-template-columns:repeat(2,minmax(0,1fr));gap:20px 0}.academic-evaluation .summary-tile:nth-child(2){border:0}.academic-evaluation .report-row{grid-template-columns:1fr 1fr;gap:16px}.academic-evaluation .submit-area{flex-direction:column;align-items:stretch}.academic-evaluation .submit-area>div:last-child{display:grid!important;grid-template-columns:1fr!important}.academic-evaluation .submit-area .btn{width:100%!important}}
@media print{.academic-evaluation .no-print{display:none!important}.academic-evaluation .print-only,.academic-evaluation .report-print-title{display:block!important}body.portal-app .portal-content .academic-evaluation .fe-panel{padding:12px;border:0;break-inside:avoid}.academic-evaluation .task-table{min-width:0}.academic-evaluation .academic-entry{display:none}.academic-evaluation .task-scroll{overflow:visible}}
</style>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="academic-evaluation">

<div class="fe-main"><asp:Label ID="lblInitials" runat="server" Visible="false"/><asp:Label ID="lblSupervisor" runat="server" Visible="false"/>
<section class="fe-content">
<h1>Final Academic Evaluation</h1>
<p class="page-description">Review the company training report, student tasks and approved hours; record academic feedback and submit the assessment to the coordinator queue.</p>
<asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="message no-print"/>
<div class="fe-panel no-print"><div class="fe-panel-heading"><div class="panel-heading-icon"><i class="bi bi-person-check"></i></div><div><h2>Choose a student</h2><p>Only students assigned to your account are listed.</p></div></div>
<div class="field-grid"><div class="field"><asp:Label runat="server" AssociatedControlID="Major" Text="Major" /><asp:DropDownList ID="Major" runat="server" CssClass="input" AutoPostBack="true" OnSelectedIndexChanged="Major_Changed" /></div><div class="field"><asp:Label runat="server" AssociatedControlID="ddlStudent" Text="Student" /><asp:DropDownList ID="ddlStudent" runat="server" CssClass="input" AutoPostBack="true" OnSelectedIndexChanged="ddlStudent_SelectedIndexChanged"/></div></div></div>
<asp:Panel ID="pnlReport" runat="server" Visible="false">
<div class="fe-panel" id="printArea"><h2 class="report-print-title">University Internship Final Evaluation</h2>
<div class="fe-panel-heading"><div class="panel-heading-icon"><i class="bi bi-file-earmark-text"></i></div><div><h2>Training report</h2><p>Review the company assessment and the student’s training record.</p></div></div>
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
<div class="fe-panel"><div class="fe-panel-heading"><div class="panel-heading-icon"><i class="bi bi-pencil-square"></i></div><div><h2>Your academic assessment</h2><p>Record your decision and explain your assessment for the coordinator.</p></div></div>
<div class="academic-entry"><div class="field-grid"><div class="field"><asp:Label runat="server" AssociatedControlID="txtScore" Text="Assessment score (%)" /><asp:TextBox ID="txtScore" runat="server" CssClass="input" TextMode="Number" min="0" max="100" step="0.01" placeholder="e.g. 85"/><asp:Label ID="PercentageError" runat="server" CssClass="field-error" /></div><div class="field"><asp:Label runat="server" AssociatedControlID="ddlRecommendation" Text="Final decision" /><asp:DropDownList ID="ddlRecommendation" runat="server" CssClass="input"><asp:ListItem Text="Select recommendation" Value=""/><asp:ListItem Text="Pass" Value="Pass"/><asp:ListItem Text="Fail" Value="Fail"/></asp:DropDownList><asp:Label ID="RecommendationError" runat="server" CssClass="field-error" /></div></div>
<div class="field"><asp:Label runat="server" AssociatedControlID="txtComments" Text="Academic feedback" /><asp:TextBox ID="txtComments" runat="server" TextMode="MultiLine" Rows="5" CssClass="input" MaxLength="3000" placeholder="Review task quality, training progress, company feedback and final recommendations..."/><asp:Label ID="CommentsError" runat="server" CssClass="field-error" /></div></div>
<div class="academic-print-section print-only">
 <div class="report-row"><div><span class="report-label">Academic Supervisor</span><strong><asp:Label ID="lblSupervisorPrint" runat="server" Text="" /></strong></div></div>
 <div class="report-row"><div><span class="report-label">Academic Recommendation</span><strong id="printAcademicRecommendation">Not provided</strong></div><div><span class="report-label">Report Generated</span><strong id="printGeneratedAt">—</strong></div></div>
 <h3>Academic Supervisor Feedback</h3><div class="report-block" id="printAcademicFeedback">Not provided</div>
</div>
<div class="submit-area no-print"><div class="submit-note"><span class="note-icon"><i class="bi bi-info-circle"></i></span><span>Submit after reviewing the company evaluation. Your assessment will be sent to the coordinator for completion review.</span></div><div style="display:flex;gap:10px;flex-wrap:wrap"><button class="btn btn-secondary" type="button" onclick="printCombinedReport()"><i class="bi bi-printer"></i> Print / Save PDF</button><asp:Button ID="btnSubmit" runat="server" Text="Submit to Coordinator" CssClass="btn" CausesValidation="false" OnClick="btnSubmit_Click"/></div></div>
</div></asp:Panel>
</section></div></div>
<script type="text/javascript">
(function () {
    function visibleText(id, fallback) {
        var el = document.getElementById(id);
        var value = el ? (el.value || '').trim() : '';
        return value || fallback;
    }
    window.prepareCombinedReport = function () {
        var recommendation = document.getElementById('<%= ddlRecommendation.ClientID %>');
        var comments = document.getElementById('<%= txtComments.ClientID %>');

        document.getElementById('printAcademicRecommendation').textContent = recommendation && /^(Pass|Fail)$/.test(recommendation.value) ? recommendation.value : '—';
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

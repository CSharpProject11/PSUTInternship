<%@ Page Title="Reports &amp; Final Evaluation" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="ReportsAndEvaluation.aspx.cs" Inherits="PSUTInternship.Company.ReportsAndEvaluation" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<style>

        .breadcrumb{font-size:13px;margin-bottom:12px}
        h1{font-size:28px;font-weight:500;margin:0 0 8px}.intro{margin:0 0 24px}
        .stats{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:18px}
        .stat,.panel{border:1px solid;border-radius:12px}
        .stat{padding:16px;min-height:126px}.stat-title{font-size:13px;line-height:1.5;min-height:38px}
        .stat-number{font-size:27px;font-weight:bold;margin:4px 0}.stat-note{font-size:12px;line-height:1.4}
        .panel{padding:20px;margin-bottom:16px}.panel-heading{display:flex;justify-content:space-between;align-items:center;gap:12px}
        h2{font-size:18px;font-weight:500;margin:0}.subtext{font-size:13px;margin:10px 0 16px}
        .button{width:auto;min-width:0;white-space:nowrap;border:1px solid;border-radius:8px;padding:7px 10px;font:inherit;font-size:13px;text-decoration:none;cursor:pointer}
        .button-primary{font-weight:bold}
        .table-wrap{overflow-x:auto;border:1px solid;border-radius:9px}
        table{border-collapse:collapse;width:100%;min-width:680px}th,td{padding:14px 12px;text-align:left;border-bottom:1px solid;font-size:13px;white-space:nowrap}
        th{font-size:11px;letter-spacing:.04em;text-transform:uppercase}tbody tr:last-child td{border-bottom:0}
        .status{display:inline-block;padding:5px 9px;border:1px solid;border-radius:15px;font-size:11px}
        .small-button{padding:5px 8px;font-size:11px}.empty{padding:18px;text-align:center}
        .message{display:block;margin:12px 0;font-weight:bold}
        .modal{position:fixed;inset:0;display:flex;justify-content:center;align-items:center;padding:18px;z-index:5}
        .modal-card{width:min(700px,100%);max-height:94vh;overflow-y:auto;border:1px solid;border-radius:12px}
        .modal-head{display:flex;justify-content:space-between;align-items:center;padding:16px 20px;border-bottom:1px solid}
        .modal-head h2{margin-bottom:5px}.modal-body{padding:18px 20px}.field{margin-bottom:14px}
        .field label{display:block;font-size:12px;font-weight:bold;margin-bottom:6px}
        input,select,textarea{width:100%;padding:10px 11px;border:1px solid;border-radius:7px;font:inherit}
        textarea{min-height:82px;resize:vertical}.criteria-list{display:grid;gap:9px;margin:14px 0}
        .criterion{display:grid;grid-template-columns:minmax(120px,1fr) minmax(130px,180px) auto;align-items:center;gap:9px;padding:10px;border:1px solid;border-radius:9px}
        .criterion input{font-size:13px;padding:8px}.criterion small{grid-column:1/-1}
        .total{display:flex;justify-content:space-between;gap:12px;border:1px solid;border-radius:8px;padding:12px;font-weight:bold;margin:12px 0}
        .notice{font-size:12px;line-height:1.5;border:1px solid;border-radius:8px;padding:12px;margin:14px 0}
        .modal-actions{display:flex;justify-content:flex-end;gap:8px;margin-top:16px}
        @media(max-width:740px){.stats{grid-template-columns:repeat(2,1fr)}.panel{padding:15px}.criterion{grid-template-columns:minmax(0,1fr) 120px auto}.modal-body{padding:15px}}
        @media(max-width:420px){.criterion{grid-template-columns:1fr 1fr}.criterion .remove-criterion{grid-column:2}.stat{padding:12px}.stat-title{min-height:35px}}
    </style>
    <script>
        function addCriterion(name, percentage) {
            var row = document.createElement('div'); row.className = 'criterion';
            function field(label, input) {
                var box = document.createElement('label'); box.className = 'field'; var caption = document.createElement('span'); caption.className = 'criterion-label'; caption.textContent = label; box.appendChild(caption);
                box.appendChild(input); var error = document.createElement('span'); error.className = 'field-error'; error.setAttribute('aria-live','polite'); box.appendChild(error); row.appendChild(box); return error;
            }
            var title = document.createElement('input'); title.name = 'CriterionName'; title.value = name || ''; title.maxLength = 150;
            var titleError = field('Criterion', title);
            var percent = document.createElement('input'); percent.name = 'CriterionPercentage'; percent.type = 'number'; percent.min = '0'; percent.max = '100'; percent.step = '0.01'; percent.value = percentage == null ? '' : percentage; percent.placeholder = '0–100';
            field('Percentage (%)', percent);
            function validateTitle() { var ok = /^[^\x00-\x1f]{3,150}$/.test(title.value.trim()); titleError.textContent = ok ? '' : 'Enter a criterion of 3–150 characters.'; return ok; }
            title.addEventListener('input',validateTitle); row.validateTitle = validateTitle;
            percent.addEventListener('input',updateTotal);
            var remove = document.createElement('button'); remove.type='button'; remove.className='button small-button remove-criterion'; remove.textContent='Remove';
            remove.onclick=function(){row.remove();updateTotal();}; row.appendChild(remove);
            document.getElementById('criteriaList').appendChild(row); updateTotal();
        }
        function updateTotal() {
            var total = 0, valid = true;
            document.querySelectorAll('[name="CriterionPercentage"]').forEach(function(input){
                var value = input.value; var ok = /^(?:100(?:\.0{1,2})?|(?:[0-9]|[1-9][0-9])(?:\.[0-9]{1,2})?)$/.test(value);
                input.setCustomValidity(ok ? '' : 'Enter 0–100 with at most two decimals.');
                input.nextElementSibling.textContent = ok ? '' : 'Enter 0–100 with at most two decimals.';
                total += ok ? Math.round(Number(value) * 100) : 0; valid = valid && ok;
            });
            var tooHigh = total > 10000;
            document.getElementById('totalScore').textContent = (total / 100).toFixed(2) + '% / 100%';
            document.getElementById('percentageError').textContent = tooHigh ? 'The total percentage cannot exceed 100%.' : '';
            document.querySelectorAll('[data-evaluation-save]').forEach(function(button){button.disabled = tooHigh;});
            return valid && !tooHigh;
        }
    </script>
<style>
body.portal-app .portal-content .company-evaluation-page{max-width:1240px!important;margin:auto;color:#19394f}body.portal-app .portal-content .company-evaluation-page h1{font-size:28px!important;letter-spacing:-.03em;margin-bottom:8px!important}body.portal-app .portal-content .company-evaluation-page :is(.intro,.subtext){font-size:12px!important;font-weight:400!important;line-height:1.8;color:#607587!important}
body.portal-app .portal-content .company-evaluation-page .stats{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:0!important;border:1px solid #dce6ed;border-radius:12px;overflow:hidden;background:#fff;margin:24px 0!important}body.portal-app .portal-content .company-evaluation-page .stat{padding:18px 22px!important;min-height:0!important;background:#fff!important;border:0!important;border-right:1px solid #e3ebf1!important;border-radius:0!important;box-shadow:none!important}body.portal-app .portal-content .company-evaluation-page .stat-title{font-size:12px!important;min-height:0!important;font-weight:500;color:#607587!important}body.portal-app .portal-content .company-evaluation-page .stat-number{font-size:30px!important;color:#19394f!important;line-height:1.3;font-weight:600!important;margin:9px 0!important}.company-evaluation-page .stat-note{font-size:11px;color:#607587;font-weight:400}
body.portal-app .portal-content .company-evaluation-page .panel{background:#fff!important;border:1px solid #dce6ed!important;border-radius:12px!important;box-shadow:none!important;padding:24px!important}.company-evaluation-page .panel-heading{display:flex;align-items:center;justify-content:space-between;gap:18px}body.portal-app .portal-content .company-evaluation-page h2{font-size:18px!important;letter-spacing:-.02em}.company-evaluation-page .table-wrap{border:1px solid #dfe8ee;border-radius:8px;overflow:auto}body.portal-app .portal-content .company-evaluation-page th{font-size:11px!important;font-weight:600!important;text-transform:none!important;letter-spacing:0!important;color:#607587!important;background:#f6f9fb!important;padding:12px 16px!important}body.portal-app .portal-content .company-evaluation-page td{font-size:13px!important;font-weight:400!important;line-height:1.7;padding:16px!important;border-color:#e5edf2!important}.company-evaluation-page .empty{text-align:center;color:#607587;padding:32px!important}
body.portal-app .portal-content .company-evaluation-page .button{display:inline-flex;align-items:center;justify-content:center;font-size:12px!important;font-weight:600!important;line-height:1.5!important;padding:10px 15px!important;min-height:38px;border:1px solid #c6d7e3!important;border-radius:6px!important;background:#fff!important;color:#345b76!important;box-shadow:none!important}body.portal-app .portal-content .company-evaluation-page .button-primary{background:#003e73!important;color:#fff!important;border-color:#003e73!important}
body.portal-app .portal-content .company-evaluation-page .modal{z-index:1100;background:#091f3099;padding:20px}.company-evaluation-page .modal-card{display:flex;flex-direction:column;overflow:hidden!important;max-height:92dvh!important;width:min(800px,calc(100vw - 32px))!important;border:0!important;background:#fff!important;border-radius:16px!important}.company-evaluation-page .modal-head{padding:22px 26px!important;background:#f6f9fb;border-bottom:1px solid #e3ebf1;flex-shrink:0}.company-evaluation-page .modal-head h2{margin:0!important}.company-evaluation-page .modal-body{overflow-y:auto;min-height:0;padding:24px 26px!important;scrollbar-width:thin;display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:20px}.company-evaluation-page .modal-body> :not(.field){grid-column:1/-1}.company-evaluation-page .modal-body>.field:has(textarea){grid-column:1/-1}.company-evaluation-page .modal-body .field{margin:0;min-width:0}.company-evaluation-page .modal-body .field label{display:block;font-size:12px;font-weight:600;color:#48677d;margin-bottom:8px}body.portal-app .portal-content .company-evaluation-page .modal-body :is(input,select,textarea){width:100%;font-size:13px!important;font-weight:400!important;border:1px solid #c6d7e3!important;border-radius:6px!important;padding:11px 12px!important;background:#fff!important;min-height:44px}.company-evaluation-page .modal-body textarea{min-height:130px!important;resize:vertical}.company-evaluation-page .criteria-list{margin:4px 0!important;display:grid;gap:12px}.company-evaluation-page .criterion{background:#f5f8fa;border:1px solid #e0e8ef;border-radius:8px;padding:16px;grid-template-columns:minmax(0,1fr) 140px auto;align-items:end}.company-evaluation-page .criterion .field{margin:0!important;font-size:11px;font-weight:500}.company-evaluation-page .total{display:flex;justify-content:space-between;padding:16px;background:#eaf3f8;border:0;border-radius:8px;font-size:13px;font-weight:600;margin:0;font-variant-numeric:tabular-nums}.company-evaluation-page .notice{font-size:11px;line-height:1.8;background:#f5f8fa;color:#607587;border:0;padding:14px;border-radius:7px;margin:0}.company-evaluation-page .modal-actions{display:flex;justify-content:flex-end;gap:10px;border-top:1px solid #e3ebf1;padding-top:20px;margin:0}.company-evaluation-page .field-error{font-size:11px;line-height:1.7;color:#a14037}.company-evaluation-page :focus-visible{outline:3px solid #0078b5;outline-offset:3px}
@media(max-width:750px){body.portal-app .portal-content .company-evaluation-page .stats{grid-template-columns:repeat(2,minmax(0,1fr))}.company-evaluation-page .modal-body{grid-template-columns:1fr}.company-evaluation-page .modal-body>*{grid-column:1!important}.company-evaluation-page .criterion{grid-template-columns:minmax(0,1fr) 100px}.company-evaluation-page .criterion>button{grid-column:1/-1;justify-self:end}.company-evaluation-page .panel-heading{flex-wrap:wrap}}
/* Align criterion controls independently of their validation message height. */
body.portal-app .portal-content .company-evaluation-page .criteria-list .criterion{display:grid!important;grid-template-columns:minmax(0,1fr) 150px auto!important;align-items:start!important;gap:14px!important;padding:18px!important;background:#f7f9fb!important;border:1px solid #dfe8ef!important;border-radius:10px!important}
body.portal-app .portal-content .company-evaluation-page .criteria-list .criterion>.field{display:flex!important;flex-direction:column!important;gap:8px!important;margin:0!important;min-width:0;font-size:12px!important;font-weight:600!important;color:#48677d}
.criterion-label{display:block;font-size:11px;font-weight:600;line-height:1.5;color:#526d81}
body.portal-app .portal-content .company-evaluation-page .criteria-list .criterion input{display:block;width:100%!important;min-height:44px!important;height:44px;margin:0!important;padding:10px 12px!important;background:#fff!important}
body.portal-app .portal-content .company-evaluation-page .criteria-list .criterion .field-error{display:block;font-size:11px!important;font-weight:400!important;line-height:1.6!important;color:#a14037!important;margin:0!important;white-space:normal;overflow-wrap:anywhere}
body.portal-app .portal-content .company-evaluation-page .criteria-list .criterion .field-error:empty{display:none}
body.portal-app .portal-content .company-evaluation-page .criteria-list .criterion>.remove-criterion{margin-top:25px!important;min-height:44px!important;height:44px;padding:10px 12px!important;align-self:start!important;font-size:11px!important;background:#fff!important;color:#607587!important;border:1px solid #cbd9e3!important}
body.portal-app .portal-content .company-evaluation-page .criteria-list .criterion>.remove-criterion:hover{background:#fff1ef!important;color:#984a40!important;border-color:#e4bfb9!important}
@media(max-width:600px){body.portal-app .portal-content .company-evaluation-page .criteria-list .criterion{grid-template-columns:minmax(0,1fr) 110px!important;gap:12px!important;padding:14px!important}body.portal-app .portal-content .company-evaluation-page .criteria-list .criterion>.remove-criterion{grid-column:1/-1;justify-self:end;margin-top:0!important;min-height:34px!important;height:34px}}</style></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<main class="company-evaluation-page">
    <div class="breadcrumb">Workspace / Company Supervisor / Evaluations</div>
    <h1>Reports &amp; Final Evaluation</h1>
    <p class="intro">Review internship reports and submit your final evaluation to the academic supervisor.</p>
    <asp:Label ID="PageMessage" runat="server" CssClass="message" EnableViewState="false" />

    <asp:Panel ID="DashboardContent" runat="server"><div class="stats">
        <div class="stat"><div class="stat-title">Reports Submitted</div><div class="stat-number"><asp:Label ID="ReportsSubmittedCount" runat="server" Text="0" /></div><div class="stat-note">From your trainees</div></div>
        <div class="stat"><div class="stat-title">Awaiting Review</div><div class="stat-number"><asp:Label ID="AwaitingReviewCount" runat="server" Text="0" /></div><div class="stat-note">Need your evaluation</div></div>
        <div class="stat"><div class="stat-title">Evaluations Drafted</div><div class="stat-number"><asp:Label ID="DraftedCount" runat="server" Text="0" /></div><div class="stat-note">Not yet submitted</div></div>
        <div class="stat"><div class="stat-title">Sent to Academic</div><div class="stat-number"><asp:Label ID="SentCount" runat="server" Text="0" /></div><div class="stat-note">Submitted for review</div></div>
    </div>

    <section class="panel">
        <div class="panel-heading"><h2>Final company evaluations</h2><asp:Button ID="NewEvaluation" runat="server" Text="Create evaluation" CssClass="button button-primary" OnClick="NewEvaluation_Click" /></div>
        <p class="subtext">Review evaluations sent to academic supervisors or continue a saved draft.</p>
        <div class="table-wrap"><table><thead><tr><th>Student</th><th>Evaluation Period</th><th>Academic Supervisor</th><th>Status</th><th>Action</th></tr></thead><tbody id="EvaluationRows" runat="server"></tbody></table></div>
    </section>

    <div hidden><table><tbody id="ReportRows" runat="server"></tbody></table></div><asp:Panel ID="ReportReview" runat="server" Visible="false">
            <h3>Evaluate report</h3><asp:HiddenField ID="ReportId" runat="server" />
            <asp:HyperLink ID="ReportSubmissionLink" runat="server" Text="Open submitted report" Target="_blank" />
            <div class="field"><label for="ReportScore">Score according to university criteria</label><asp:TextBox ID="ReportScore" runat="server" /></div>
            <div class="field"><label for="ReportFeedback">Feedback</label><asp:TextBox ID="ReportFeedback" runat="server" TextMode="MultiLine" /></div>
            <asp:Button ID="SaveReport" runat="server" Text="Save Report Evaluation" CssClass="button" OnClick="SaveReport_Click" />
        </asp:Panel>

    </asp:Panel>
    <asp:Panel ID="EvaluationModal" runat="server" CssClass="modal" Visible="false">
        <div class="modal-card">
            <div class="modal-head"><div><h2>Final Company Evaluation</h2><asp:Label ID="SelectedStudentName" runat="server" CssClass="subtext" /></div>
                <asp:Button ID="CloseEvaluation" runat="server" Text="Close" CssClass="button" CausesValidation="false" formnovalidate="formnovalidate" OnClick="CloseEvaluation_Click" /></div>
            <div class="modal-body">
                <p class="subtext">Complete the evaluation and send it to the academic supervisor.</p>
                <asp:HiddenField ID="EvaluationId" runat="server" />
                <div class="field"><asp:Label runat="server" AssociatedControlID="Opportunity" Text="Training opportunity" /><asp:DropDownList ID="Opportunity" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Opportunity_Changed" /><asp:Label ID="OpportunityError" runat="server" CssClass="field-error" /></div>
                <div class="field"><label for="EvaluationStudent">Student</label><asp:DropDownList ID="EvaluationStudent" runat="server" AutoPostBack="true" OnSelectedIndexChanged="EvaluationStudent_Changed" /><asp:Label ID="StudentError" runat="server" CssClass="field-error" /></div>
                <div class="field"><label for="EvaluationPeriod">Evaluation Period</label><asp:TextBox ID="EvaluationPeriod" runat="server" MaxLength="100" placeholder="For example: Sep - Oct 2026" /><asp:Label ID="PeriodError" runat="server" CssClass="field-error" /></div>
                <div class="field"><label for="AcademicSupervisor">Academic Supervisor</label><asp:TextBox ID="AcademicSupervisor" runat="server" ReadOnly="true" MaxLength="150" placeholder="Filled after selecting a trainee" /><asp:Label ID="SupervisorError" runat="server" CssClass="field-error" /></div>
                <div class="field"><label for="AcademicSupervisorEmail">Academic Supervisor Email</label><asp:TextBox ID="AcademicSupervisorEmail" runat="server" ReadOnly="true" TextMode="Email" MaxLength="150" placeholder="Filled after selecting a trainee" /><asp:Label ID="EmailError" runat="server" CssClass="field-error" /></div>
                <div id="criteriaList" class="criteria-list"></div>
                <asp:Label ID="CriteriaError" runat="server" CssClass="field-error" /><span id="percentageError" class="field-error" role="alert"></span>
                <button type="button" class="button" onclick="addCriterion('', '')">Add criterion</button>
                <div class="total"><span>Evaluation total</span><span id="totalScore">0% / 100%</span></div>
                <div class="field"><label for="OverallFeedback">Overall feedback</label><asp:TextBox ID="OverallFeedback" runat="server" TextMode="MultiLine" placeholder="Summarize performance, strengths and areas for improvement." /><asp:Label ID="FeedbackError" runat="server" CssClass="field-error" /></div>
                <div class="notice">Enter the percentage earned for each criterion. The combined evaluation cannot exceed 100%.</div>
                <div class="modal-actions"><asp:Button ID="SaveDraft" runat="server" data-evaluation-save="true" Text="Save Draft" CssClass="button" OnClick="SaveEvaluation_Click" CommandArgument="Draft" /><asp:Button ID="SendEvaluation" runat="server" data-evaluation-save="true" Text="Send Evaluation" CssClass="button button-primary" OnClick="SaveEvaluation_Click" CommandArgument="Sent to Academic Supervisor" /></div>
            </div>
        </div>
    </asp:Panel>
</main>
</asp:Content>

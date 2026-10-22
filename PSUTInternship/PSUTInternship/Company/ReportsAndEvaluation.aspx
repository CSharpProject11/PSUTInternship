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
        .criterion{display:grid;grid-template-columns:minmax(120px,1fr) 90px 90px auto;align-items:center;gap:9px;padding:10px;border:1px solid;border-radius:9px}
        .criterion input{font-size:13px;padding:8px}.criterion small{grid-column:1/-1}
        .total{display:flex;justify-content:space-between;gap:12px;border:1px solid;border-radius:8px;padding:12px;font-weight:bold;margin:12px 0}
        .notice{font-size:12px;line-height:1.5;border:1px solid;border-radius:8px;padding:12px;margin:14px 0}
        .modal-actions{display:flex;justify-content:flex-end;gap:8px;margin-top:16px}
        @media(max-width:740px){.stats{grid-template-columns:repeat(2,1fr)}.panel{padding:15px}.criterion{grid-template-columns:1fr 75px 75px auto}.modal-body{padding:15px}}
        @media(max-width:420px){.criterion{grid-template-columns:1fr 1fr}.criterion .remove-criterion{grid-column:2}.stat{padding:12px}.stat-title{min-height:35px}}
    </style>
    <script>
        function addCriterion(name, score, maxPoints) {
            var list = document.getElementById('criteriaList');
            var row = document.createElement('div');
            row.className = 'criterion';
            var criterionName = document.createElement('input');
            criterionName.name = 'CriterionName'; criterionName.setAttribute('aria-label', 'Criterion name'); criterionName.placeholder = 'Criterion'; criterionName.value = name || '';
            var criterionScore = document.createElement('input');
            criterionScore.name = 'CriterionScore'; criterionScore.type = 'number'; criterionScore.min = '0'; criterionScore.step = 'any'; criterionScore.setAttribute('aria-label', 'Score'); criterionScore.placeholder = 'Score'; criterionScore.value = score || '';
            criterionScore.addEventListener('input', updateTotal);
            var criterionMax = document.createElement('input');
            criterionMax.name = 'CriterionMax'; criterionMax.type = 'number'; criterionMax.min = '0.01'; criterionMax.step = 'any'; criterionMax.setAttribute('aria-label', 'Maximum points'); criterionMax.placeholder = 'Max'; criterionMax.value = maxPoints || '';
            criterionMax.addEventListener('input', updateTotal);
            var remove = document.createElement('button');
            remove.type = 'button'; remove.className = 'button small-button remove-criterion'; remove.textContent = 'Remove';
            remove.addEventListener('click', function() { row.remove(); updateTotal(); });
            row.appendChild(criterionName); row.appendChild(criterionScore); row.appendChild(criterionMax); row.appendChild(remove);
            list.appendChild(row); updateTotal();
        }
        function updateTotal() {
            var rows = document.querySelectorAll('#criteriaList .criterion'); var score = 0; var max = 0;
            rows.forEach(function(row) { score += parseFloat(row.querySelector('[name="CriterionScore"]').value) || 0; max += parseFloat(row.querySelector('[name="CriterionMax"]').value) || 0; });
            document.getElementById('totalScore').textContent = score + ' / ' + max;
        }
    </script>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<main>
    <div class="breadcrumb">Workspace / Company Supervisor / Evaluations</div>
    <h1>Reports &amp; Final Evaluation</h1>
    <p class="intro">Review internship reports and submit your final evaluation to the academic supervisor.</p>
    <asp:Label ID="PageMessage" runat="server" CssClass="message" EnableViewState="false" />

    <div class="stats">
        <div class="stat"><div class="stat-title">Reports Submitted</div><div class="stat-number"><asp:Label ID="ReportsSubmittedCount" runat="server" Text="0" /></div><div class="stat-note">From your trainees</div></div>
        <div class="stat"><div class="stat-title">Awaiting Review</div><div class="stat-number"><asp:Label ID="AwaitingReviewCount" runat="server" Text="0" /></div><div class="stat-note">Need your evaluation</div></div>
        <div class="stat"><div class="stat-title">Evaluations Drafted</div><div class="stat-number"><asp:Label ID="DraftedCount" runat="server" Text="0" /></div><div class="stat-note">Not yet submitted</div></div>
        <div class="stat"><div class="stat-title">Sent to Academic</div><div class="stat-number"><asp:Label ID="SentCount" runat="server" Text="0" /></div><div class="stat-note">Submitted for review</div></div>
    </div>

    <section class="panel">
        <div class="panel-heading"><h2>Final company evaluations</h2><asp:Button ID="NewEvaluation" runat="server" Text="+ New Evaluation" CssClass="button button-primary" OnClick="NewEvaluation_Click" /></div>
        <p class="subtext">Review evaluations sent to academic supervisors or continue a saved draft.</p>
        <div class="table-wrap"><table><thead><tr><th>Student</th><th>Evaluation Period</th><th>Academic Supervisor</th><th>Status</th><th>Action</th></tr></thead><tbody id="EvaluationRows" runat="server"></tbody></table></div>
    </section>

    <section class="panel">
        <div class="panel-heading"><h2>Internship reports</h2><span class="status status-pending">Review required</span></div>
        <p class="subtext">Open a report to review its details and enter your assessment.</p>
        <div class="table-wrap"><table><thead><tr><th>Student</th><th>Report</th><th>Submitted</th><th>Status</th><th>Action</th></tr></thead><tbody id="ReportRows" runat="server"></tbody></table></div>
        <asp:Panel ID="ReportReview" runat="server" Visible="false">
            <h3>Evaluate report</h3><asp:HiddenField ID="ReportId" runat="server" />
            <asp:HyperLink ID="ReportSubmissionLink" runat="server" Text="Open submitted report" Target="_blank" />
            <div class="field"><label for="ReportScore">Score according to university criteria</label><asp:TextBox ID="ReportScore" runat="server" /></div>
            <div class="field"><label for="ReportFeedback">Feedback</label><asp:TextBox ID="ReportFeedback" runat="server" TextMode="MultiLine" /></div>
            <asp:Button ID="SaveReport" runat="server" Text="Save Report Evaluation" CssClass="button" OnClick="SaveReport_Click" />
        </asp:Panel>
    </section>

    <asp:Panel ID="EvaluationModal" runat="server" CssClass="modal" Visible="false">
        <div class="modal-card">
            <div class="modal-head"><div><h2>Final Company Evaluation</h2><asp:Label ID="SelectedStudentName" runat="server" CssClass="subtext" /></div>
                <asp:Button ID="CloseEvaluation" runat="server" Text="Close" CssClass="button" CausesValidation="false" OnClick="CloseEvaluation_Click" /></div>
            <div class="modal-body">
                <p class="subtext">Complete the evaluation and send it to the academic supervisor.</p>
                <asp:HiddenField ID="EvaluationId" runat="server" />
                <div class="field"><label for="EvaluationStudent">Student</label><asp:DropDownList ID="EvaluationStudent" runat="server" /></div>
                <div class="field"><label for="EvaluationPeriod">Evaluation Period</label><asp:TextBox ID="EvaluationPeriod" runat="server" MaxLength="100" placeholder="For example: Sep - Oct 2026" /></div>
                <div class="field"><label for="AcademicSupervisor">Academic Supervisor</label><asp:TextBox ID="AcademicSupervisor" runat="server" MaxLength="150" /></div>
                <div class="field"><label for="AcademicSupervisorEmail">Academic Supervisor Email</label><asp:TextBox ID="AcademicSupervisorEmail" runat="server" TextMode="Email" MaxLength="150" /></div>
                <div id="criteriaList" class="criteria-list">
                    <div class="criterion"><input name="CriterionName" aria-label="Criterion name" placeholder="Criterion" /><input name="CriterionScore" type="number" min="0" step="any" aria-label="Score" placeholder="Score" oninput="updateTotal()" /><input name="CriterionMax" type="number" min="0.01" step="any" aria-label="Maximum points" placeholder="Max points" oninput="updateTotal()" /><button type="button" class="button small-button remove-criterion" onclick="this.parentNode.remove();updateTotal()">Remove</button></div>
                </div>
                <button type="button" class="button" onclick="addCriterion('', '', '')">+ Add Criterion</button>
                <div class="total"><span>Evaluation total</span><span id="totalScore">0 / 0</span></div>
                <div class="field"><label for="OverallFeedback">Overall feedback</label><asp:TextBox ID="OverallFeedback" runat="server" TextMode="MultiLine" placeholder="Summarize performance, strengths and areas for improvement." /></div>
                <div class="notice">Enter the university-approved criteria and point values. The total uses the maximum points you provide and does not assume a fixed grading scale.</div>
                <div class="modal-actions"><asp:Button ID="SaveDraft" runat="server" Text="Save Draft" CssClass="button" OnClick="SaveEvaluation_Click" CommandArgument="Draft" /><asp:Button ID="SendEvaluation" runat="server" Text="Send Evaluation" CssClass="button button-primary" OnClick="SaveEvaluation_Click" CommandArgument="Sent to Academic Supervisor" /></div>
            </div>
        </div>
    </asp:Panel>
</main>
</asp:Content>

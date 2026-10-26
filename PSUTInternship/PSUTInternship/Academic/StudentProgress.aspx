<%@ Page Title="Student Progress Monitor | UIMS" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true"
    CodeBehind="StudentProgress.aspx.cs"
    Inherits="PSUTInternship.Academic.StudentProgress" %>

<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<style>
/* Scoped to academic progress; the portal shell owns typography and navigation. */
body.portal-app .portal-content .academic-progress{max-width:1320px;margin:0 auto;color:#19394f}
body.portal-app .portal-content .academic-progress h1{font-size:27px!important;letter-spacing:-.035em;margin:0 0 8px!important;line-height:1.3!important}
body.portal-app .portal-content .academic-progress h2{font-size:17px!important;margin:0 0 6px!important}
body.portal-app .portal-content .academic-progress .subtitle{font-size:13px!important;color:#607587;margin:0!important;line-height:1.7;font-weight:400!important}
.academic-progress .ap-heading{display:flex;justify-content:space-between;align-items:center;gap:24px;margin-bottom:24px}.academic-progress .ap-supervisor{color:#607587;font-size:12px;border:1px solid #dce6ed;border-radius:7px;padding:9px 12px;background:#fff}
body.portal-app .portal-content .academic-progress .cards{display:grid!important;grid-template-columns:repeat(3,minmax(0,1fr))!important;gap:0!important;border:1px solid #dce6ed;border-radius:12px;background:#fff;padding:20px 0;margin:0 0 24px!important}
body.portal-app .portal-content .academic-progress .stat-card{position:relative;border:0!important;border-right:1px solid #e3ebf0!important;border-radius:0!important;background:transparent!important;box-shadow:none!important;padding:0 24px!important;min-height:0!important;grid-column:auto!important;transform:none!important;margin:0!important;outline:0!important}.academic-progress .stat-card:last-child{border-right:0!important}
body.portal-app .portal-content .academic-progress .stat-label{font-size:12px!important;color:#607587;font-weight:600!important}.academic-progress .stat-top{display:block}.academic-progress .stat-icon{display:none!important}
body.portal-app .portal-content .academic-progress .stat-number{display:block;font-size:30px!important;font-weight:700!important;color:#003e73!important;line-height:1.4!important;margin:6px 0!important;letter-spacing:-.025em}.academic-progress .stat-note{font-size:11px;color:#607587}
body.portal-app .portal-content .academic-progress .stat-card-hit{position:absolute;inset:0;opacity:0;cursor:pointer;border:0!important;width:100%;height:100%}.academic-progress .stat-card:has(.stat-card-hit.selected){background:#eef6fb!important}.academic-progress .stat-card:has(.stat-card-hit:focus-visible){outline:2px solid #0078b5!important;outline-offset:3px!important}
body.portal-app .portal-content .academic-progress .panel{border:1px solid #dce6ed!important;border-radius:12px!important;padding:0!important;box-shadow:none!important;background:#fff;margin:0!important;overflow:hidden}.academic-progress .panel-head{display:flex;flex-direction:column;align-items:stretch;gap:20px;padding:22px;margin:0}.academic-progress .muted{color:#607587;font-size:12px}
.academic-progress .filters{display:flex;align-items:end;flex-wrap:wrap;gap:10px;padding:16px;background:#f7f9fb;border:1px solid #e5ecf1;border-radius:9px}.academic-progress .filter-field{display:flex;flex-direction:column;gap:7px;min-width:0;flex:0 1 220px}.academic-progress .filter-field:first-child{flex:1 1 260px}.academic-progress .filter-field label{font-size:11px;color:#526b7d;font-weight:600}
body.portal-app .portal-content .academic-progress .input{height:42px!important;min-height:42px!important;width:100%!important;padding:0 12px!important;border:1px solid #cddce6!important;border-radius:7px!important;background:#fff!important;color:#19394f;font-size:12px!important;margin:0!important}
body.portal-app .portal-content .academic-progress .btn{display:inline-flex;align-items:center;justify-content:center;min-height:42px!important;padding:10px 16px!important;border:1px solid #003e73!important;border-radius:7px!important;background:#003e73!important;color:#fff!important;font-size:12px!important;font-weight:650!important;text-decoration:none;margin:0!important;cursor:pointer;line-height:1.4!important;box-shadow:none!important}.academic-progress .btn:hover{filter:brightness(.94)}
body.portal-app .portal-content .academic-progress .btn-light{background:#fff!important;color:#003e73!important;border-color:#cddce6!important}.academic-progress :is(a,button,input,select,summary):focus-visible{outline:2px solid #0078b5!important;outline-offset:3px}
.academic-progress .table-wrap{overflow-x:auto;width:100%}body.portal-app .portal-content .academic-progress .table{width:100%;min-width:850px;border-collapse:collapse!important;border:0!important;margin:0!important;text-align:left!important}.academic-progress .table th{padding:13px 22px!important;background:#fafcfd!important;font-size:11px!important;font-weight:600!important;color:#607587!important;text-transform:none!important;letter-spacing:0!important;text-align:left!important;border-top:1px solid #e5ecf1!important;border-bottom:1px solid #e5ecf1!important}.academic-progress .table td{padding:17px 22px!important;font-size:12px!important;line-height:1.6!important;border:0!important;border-bottom:1px solid #e9eff3!important;text-align:left!important;vertical-align:middle!important;background:#fff!important}.academic-progress .table tr:last-child td{border-bottom:0!important}
.academic-progress .student-cell{display:flex;align-items:center;gap:10px;font-weight:650}.academic-progress .avatar{display:grid;place-items:center;width:34px;height:34px;flex-shrink:0;border-radius:50%;background:#e9f3f9;color:#245f84;font-size:11px}.academic-progress .student-id{display:block;font-size:10px;color:#607587;font-weight:400}.academic-progress .progress-flex{display:flex;align-items:center;gap:9px}.academic-progress .progress-bar{height:5px;width:80px;background:#e6edf2;border-radius:3px;overflow:hidden}.academic-progress .progress-bar span{display:block;height:100%;background:#0078b5!important}.academic-progress .hours-note{display:block;font-size:11px;color:#607587;margin-top:5px}.academic-progress .action-cell{display:flex;gap:7px;align-items:center}
body.portal-app .portal-content .academic-progress .action-cell .btn{min-height:34px!important;padding:7px 10px!important;font-size:11px!important;white-space:nowrap}
body.portal-app .portal-content .academic-progress .status{display:inline-block;padding:5px 9px!important;border-radius:5px!important;white-space:nowrap;font-size:11px!important;font-weight:600!important;background:#f0f3f6;color:#526b7d}.academic-progress .status.ontrack,.academic-progress .status.completed{background:#eaf5ef!important;color:#23714d!important}.academic-progress .status.atrisk,.academic-progress .status.failed{background:#fbeeee!important;color:#a74646!important}.academic-progress .status.pending,.academic-progress .status.assigned{background:#fff6df!important;color:#8a651c!important}.academic-progress .status.submitted{background:#eaf3fa!important;color:#24628c!important}
.academic-progress .error-banner{display:block;padding:16px;margin-bottom:20px;border:1px solid #edcccc;color:#9b3939;background:#fff4f4;border-radius:8px}
.academic-progress .modal-overlay{position:fixed;inset:0;z-index:9999;display:flex;align-items:center;justify-content:center;padding:20px;background:rgba(10,30,48,.5)}
body.portal-app .portal-content .academic-progress .modal-box{width:min(860px,calc(100vw - 40px))!important;max-height:88dvh!important;display:flex;flex-direction:column;margin:0!important;background:#fff;border-radius:14px!important;overflow:hidden;box-shadow:0 20px 70px #09233c33!important}.academic-progress .modal-header{display:flex;align-items:center;justify-content:space-between;gap:20px;border-bottom:1px solid #e3ebf0;padding:22px!important}.academic-progress .modal-header p{font-size:12px!important;color:#607587;margin:0!important}.academic-progress .modal-close{display:grid;place-items:center;flex-shrink:0;width:36px;height:36px;border-radius:50%;background:#f3f6f8;color:#526b7d;text-decoration:none;font-size:22px}.academic-progress .modal-body{overflow:auto;min-height:0;padding:22px!important}.academic-progress .modal-footer{display:flex;justify-content:flex-end;padding:16px 22px!important;border-top:1px solid #e3ebf0;background:#fafcfd}
.academic-progress .summary-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:14px}.academic-progress .summary-card{padding:12px!important;border:1px solid #e3ebf0!important;border-radius:7px!important;background:#fafcfd!important}.academic-progress .detail-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px}.academic-progress .detail-item strong{overflow-wrap:anywhere}.academic-progress .section-heading{display:flex;justify-content:space-between;align-items:center}.academic-progress .task-card summary{cursor:pointer;list-style:none}.academic-progress .task-card summary::-webkit-details-marker{display:none}.academic-progress .task-card summary:after{content:'Show submission +';display:block;color:#00598c;font-size:11px;margin-top:12px}.academic-progress .task-card[open] summary:after{content:'Hide submission -'}body.portal-app .portal-content .academic-progress .task-description{white-space:normal!important}.academic-progress .task-head{display:flex;justify-content:space-between;gap:16px}.academic-progress .feedback-box{padding:14px;margin-top:16px;border-left:3px solid #0078b5;background:#fff;font-size:12px;color:#526777;line-height:1.7;overflow-wrap:anywhere}.academic-progress .evaluation-card{padding:18px;border:1px solid #e3ebf0;border-radius:8px}.academic-progress .evaluation-card p{font-size:13px!important;line-height:1.7;color:#607587}.academic-progress .empty-state{padding:25px;text-align:center;color:#607587}
@media(max-width:700px){.academic-progress .ap-heading{flex-direction:column;align-items:flex-start;gap:12px}.academic-progress .ap-supervisor{display:none}.academic-progress .cards{padding:14px 0!important}.academic-progress .stat-card{padding:0 12px!important}.academic-progress .stat-note{display:none}.academic-progress .stat-label{font-size:11px!important}.academic-progress .panel-head{padding:16px;gap:14px}.academic-progress .filters{padding:12px;gap:10px}.academic-progress .filter-field:first-child{flex-basis:100%}.academic-progress .filter-field{flex:1 1 130px}.academic-progress .filters>.btn{flex:0 0 auto}.academic-progress .summary-grid{grid-template-columns:1fr!important}.academic-progress .modal-overlay{padding:10px}.academic-progress .task-head{flex-wrap:wrap}}

/* A single toolbar and document-like dialogs replace nested filter and summary cards. */
body.portal-app .portal-content .academic-progress .ap-toolbar{display:flex;align-items:center;gap:10px;background:#fff!important;padding:0!important;border:0!important;border-radius:0!important;flex-wrap:wrap}
.academic-progress .ap-search{display:flex;align-items:center;position:relative;flex:1 1 280px;min-width:0}.academic-progress .ap-search svg{position:absolute;left:14px;width:18px;height:18px;color:#6a8191;pointer-events:none;z-index:1}
body.portal-app .portal-content .academic-progress .ap-search .input{height:46px!important;padding:0 14px 0 42px!important;background:#f7f9fb!important;border-color:#dce6ed!important;border-radius:9px!important;font-size:13px!important;box-shadow:none!important}
.academic-progress .ap-search:focus-within svg{color:#0078b5}.academic-progress .ap-status-select{display:flex;align-items:center;gap:10px;border:1px solid #dce6ed;border-radius:9px;height:46px;padding-left:14px;min-width:225px;background:#fff}.academic-progress .ap-status-select label{font-size:12px!important;color:#607587;font-weight:500!important;white-space:nowrap}
body.portal-app .portal-content .academic-progress .ap-status-select .input{width:auto!important;flex:1;min-width:0;height:44px!important;border:0!important;background:transparent!important;padding-left:0!important;font-weight:650!important;box-shadow:none!important;outline-offset:0}
body.portal-app .portal-content .academic-progress .ap-toolbar>.btn{height:46px!important;border-radius:9px!important;padding:10px 20px!important;min-height:46px!important}.academic-progress .ap-clear{border-color:transparent!important}
body.portal-app .portal-content .academic-progress .modal-box{border-radius:16px!important;width:min(820px,calc(100vw - 40px))!important}.academic-progress .modal-header{padding:24px 28px!important}.academic-progress .modal-body{padding:0 28px 24px!important}.academic-progress .modal-header{border-bottom:0!important}.academic-progress .modal-header h2{font-size:22px!important;letter-spacing:-.025em}.academic-progress .modal-header p{font-size:13px!important;margin-top:5px!important}.academic-progress .modal-close:hover{background:#e8eff4}
body.portal-app .portal-content .academic-progress .modal-box .summary-grid{display:grid!important;grid-template-columns:1fr 1fr 1fr!important;gap:0!important;padding:16px 0!important;margin:0 0 22px!important;border-top:1px solid #e3ebf0;border-bottom:1px solid #e3ebf0}
body.portal-app .portal-content .academic-progress .modal-box .summary-card{padding:0 16px!important;border:0!important;border-right:1px solid #e3ebf0!important;border-radius:0!important;background:transparent!important}.academic-progress .modal-box .summary-card:first-child{padding-left:0!important}.academic-progress .modal-box .summary-card:last-child{border-right:0!important}
body.portal-app .portal-content .academic-progress .modal-box .summary-card strong{font-size:12px!important;line-height:1.6!important}.academic-progress .modal-box .summary-card small{font-size:10px!important;margin-bottom:5px!important}
body.portal-app .portal-content .academic-progress .modal-box .task-card{border:1px solid #dce6ed!important;border-radius:9px!important;padding:0!important;margin:0 0 12px!important;overflow:hidden}.academic-progress .task-card summary{padding:16px 18px;position:relative}.academic-progress .task-card summary:after{position:absolute;right:18px;bottom:16px;content:'+';font-size:19px;line-height:1;margin:0}.academic-progress .task-card[open] summary:after{content:'-'}
body.portal-app .portal-content .academic-progress .modal-box .task-head{align-items:flex-start;gap:14px;flex-wrap:nowrap}.academic-progress .task-head>div{flex:1;min-width:0}.academic-progress .task-card .task-title{padding-right:8px}.academic-progress .task-card .task-date{padding-right:24px}.academic-progress .task-card[open] summary{background:#f7fafc;border-bottom:1px solid #e3ebf0}.academic-progress .ap-task-content{padding:18px}.academic-progress .ap-task-content .task-description{margin:0 0 16px!important;font-size:13px!important}
body.portal-app .portal-content .academic-progress .modal-box .submission-box{border:0!important;background:#fff!important;padding:0!important;margin:0!important}.academic-progress .submission-box h4{margin:0 0 16px!important}.academic-progress .modal-box .detail-grid{grid-template-columns:1fr 1fr!important;gap:18px!important}.academic-progress .detail-item a{display:inline-block;color:#006799;font-size:12px;margin-left:5px}.academic-progress .modal-box .detail-item strong{font-size:12px!important;font-weight:500!important}.academic-progress .feedback-box{border:0!important;border-top:1px solid #e3ebf0!important;padding:16px 0 0!important;background:#fff!important}.academic-progress .feedback-box p{margin:0 0 10px!important;font-size:12px!important}
body.portal-app .portal-content .academic-progress .ap-evaluation-dialog{width:min(660px,calc(100vw - 40px))!important}.academic-progress .evaluation-card{border:1px solid #dce6ed;border-radius:10px;padding:22px;background:#f8fafb}.academic-progress .ap-result-heading{display:flex;justify-content:space-between;align-items:center;gap:16px}.academic-progress .ap-result-heading>span:first-child{font-size:12px;color:#607587}
body.portal-app .portal-content .academic-progress .ap-result-value{display:block;font-size:34px!important;letter-spacing:-.04em;font-weight:700!important;margin:14px 0!important;line-height:1.3;color:#19394f}.academic-progress .ap-evaluation-date{display:flex;gap:8px;font-size:11px;color:#607587}.academic-progress .ap-evaluation-feedback{padding:24px 0 0}.academic-progress .ap-evaluation-feedback h3{font-size:14px!important;margin:0 0 10px!important}.academic-progress .ap-evaluation-feedback p{font-size:13px!important;font-weight:400!important;line-height:1.8!important;color:#526b7d;white-space:pre-line;overflow-wrap:anywhere;margin:0!important}
@media(max-width:650px){.academic-progress .ap-search{flex-basis:100%}.academic-progress .ap-status-select{flex:1 1 160px;min-width:0}.academic-progress .ap-status-select label{display:none}.academic-progress .ap-status-select .input{padding-left:12px!important}.academic-progress .ap-toolbar>.btn{padding:10px 14px!important}.academic-progress .ap-clear{padding-inline:7px!important}.academic-progress .modal-header{padding:20px!important}.academic-progress .modal-body{padding:0 20px 20px!important}.academic-progress .modal-header h2{font-size:20px!important}body.portal-app .portal-content .academic-progress .modal-box .summary-grid{grid-template-columns:minmax(0,1fr)!important;padding:10px 0!important;gap:12px!important}body.portal-app .portal-content .academic-progress .modal-box .summary-card{display:flex;align-items:baseline;justify-content:space-between;gap:12px;padding:0!important;border:0!important}.academic-progress .modal-box .summary-card small{margin:0!important}.academic-progress .modal-box .summary-card strong{text-align:right}.academic-progress .task-card summary{padding:14px}.academic-progress .task-card .task-head{flex-wrap:wrap!important}body.portal-app .portal-content .academic-progress .modal-box .detail-grid{grid-template-columns:minmax(0,1fr)!important}.academic-progress .evaluation-card{padding:18px}.academic-progress .ap-result-value{font-size:30px!important}}

/* Unique names prevent the portal's generic panel and filter rules from reshaping this toolbar. */
body.portal-app .portal-content .academic-progress .ap-student-panel{background:#fff!important;border:1px solid #dce6ed;border-radius:12px;overflow:hidden}
body.portal-app .portal-content .academic-progress .ap-list-header{display:block!important;text-align:left!important;padding:24px!important;background:#fff!important;margin:0!important;width:100%!important;box-sizing:border-box}
body.portal-app .portal-content .academic-progress .ap-list-header>div:first-child{margin:0 0 20px!important;text-align:left!important}
body.portal-app .portal-content .academic-progress .ap-toolbar{display:grid!important;grid-template-columns:minmax(220px,1fr) 235px 100px 60px!important;gap:12px!important;align-items:center!important;width:100%!important;max-width:none!important;margin:0!important;padding:0!important;background:transparent!important;border:0!important;box-sizing:border-box}
body.portal-app .portal-content .academic-progress .ap-toolbar .ap-search{width:100%!important;margin:0!important;min-width:0!important;position:relative;display:flex;align-items:center}
body.portal-app .portal-content .academic-progress .ap-search-input{display:block!important;box-sizing:border-box!important;width:100%!important;max-width:none!important;min-width:0!important;height:46px!important;min-height:46px!important;border:1px solid #d6e1e9!important;border-radius:8px!important;background:#f8fafb!important;padding:0 14px 0 43px!important;font-size:13px!important;font-weight:400!important;color:#19394f!important;box-shadow:none!important;margin:0!important}
body.portal-app .portal-content .academic-progress .ap-search-input::placeholder{color:#718593!important;opacity:1}
body.portal-app .portal-content .academic-progress .ap-status-select{display:flex!important;align-items:center!important;height:46px!important;min-width:0!important;width:100%!important;box-sizing:border-box!important;border:1px solid #d6e1e9!important;border-radius:8px!important;padding:0 12px!important;background:#fff!important;gap:12px!important;margin:0!important}
body.portal-app .portal-content .academic-progress .ap-status-input{display:block!important;flex:1!important;width:100%!important;max-width:none!important;min-width:0!important;height:42px!important;min-height:0!important;padding:0!important;margin:0!important;border:0!important;border-radius:0!important;box-shadow:none!important;background:transparent!important;font-size:13px!important;font-weight:500!important;color:#19394f!important}
body.portal-app .portal-content .academic-progress .ap-toolbar>.btn{width:100%!important;max-width:none!important;margin:0!important;height:46px!important;min-height:46px!important;padding:10px 12px!important;font-size:12px!important;font-weight:600!important;border-radius:8px!important;box-sizing:border-box!important}
body.portal-app .portal-content .academic-progress .ap-toolbar>.ap-clear{background:transparent!important;border-color:transparent!important;color:#607587!important;text-decoration:underline;text-underline-offset:3px;padding:0!important}
body.portal-app .portal-content .academic-progress .ap-search-input:focus{border-color:#0078b5!important;outline:2px solid #0078b522!important;outline-offset:1px!important}
@media(max-width:1000px){body.portal-app .portal-content .academic-progress .ap-toolbar{grid-template-columns:minmax(180px,1fr) 200px 85px 50px!important;gap:8px!important}}
@media(max-width:700px){body.portal-app .portal-content .academic-progress .ap-list-header{padding:18px!important}body.portal-app .portal-content .academic-progress .ap-toolbar{grid-template-columns:minmax(0,1fr) 85px 45px!important;gap:10px 8px!important}body.portal-app .portal-content .academic-progress .ap-toolbar .ap-search{grid-column:1/-1!important}body.portal-app .portal-content .academic-progress .ap-status-select label{display:none!important}}

/* One boundary for the status control, with no nested field frame. */
body.portal-app .portal-content .academic-progress .ap-toolbar .ap-status-select{border:0!important;padding:0!important;background:transparent!important;border-radius:0!important;height:46px!important}
body.portal-app .portal-content .academic-progress .ap-toolbar .ap-status-input{appearance:none!important;-webkit-appearance:none!important;box-sizing:border-box!important;height:46px!important;min-height:46px!important;border:1px solid #d6e1e9!important;border-radius:8px!important;padding:0 38px 0 14px!important;background-color:#fff!important;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='none' stroke='%23607587' stroke-width='1.6' viewBox='0 0 24 24'%3E%3Cpath d='m7 10 5 5 5-5'/%3E%3C/svg%3E")!important;background-repeat:no-repeat!important;background-position:right 13px center!important;box-shadow:none!important;font-size:13px!important;font-weight:500!important;cursor:pointer}
body.portal-app .portal-content .academic-progress .ap-toolbar .ap-status-input:hover{border-color:#9fb8ca!important}
body.portal-app .portal-content .academic-progress .ap-toolbar .ap-status-input:focus-visible{border-color:#0078b5!important;outline:2px solid #0078b526!important;outline-offset:1px!important}

body.portal-app .portal-content .academic-progress .action-cell .btn{display:inline-flex!important;align-items:center!important;justify-content:center!important;text-align:center!important;height:40px!important;min-height:40px!important;padding:0 14px!important;line-height:1!important;vertical-align:middle!important;gap:0!important}
body.portal-app .portal-content .academic-progress .action-cell .btn i{display:none!important}
</style>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="academic-progress">

    <!-- SIDEBAR -->


    <!-- MAIN -->
    <div class="ap-main">



        <section class="ap-content">
            <asp:Label ID="lblPageError" runat="server" Visible="false" CssClass="error-banner" />

            <header class="ap-heading"><div>

            <h1>Student progress</h1>

<p class="subtitle">Follow student training and review the latest submissions.</p></div><span class="ap-supervisor"><asp:Label ID="lblSupervisorName" runat="server" /></span></header>

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
            <div class="ap-student-panel">

                <div class="ap-list-header">

                    <div>
                        <h2>Assigned students</h2>

                        <div class="muted">
                            Review your assigned students and their progress
                        </div>
                    </div>

                    <div class="ap-toolbar">
                        <div class="ap-search">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="ap-search-input" placeholder="Search student, ID or company" aria-label="Search student, ID or company" />
                        </div>
                        <div class="ap-status-select"><asp:DropDownList ID="ddlStatus" runat="server" CssClass="ap-status-input" aria-label="Filter students by progress status"><asp:ListItem Value="All">All students</asp:ListItem><asp:ListItem Value="On Track">On track</asp:ListItem><asp:ListItem Value="At Risk">Needs attention</asp:ListItem><asp:ListItem Value="Awaiting Certificate">Awaiting certificate</asp:ListItem><asp:ListItem Value="Not Started">Not started</asp:ListItem><asp:ListItem Value="Completed">Completed</asp:ListItem></asp:DropDownList></div>
                        <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="btn ap-search-submit" OnClick="btnFilter_Click" />
                        <asp:Button ID="btnReset" runat="server" Text="Clear" CssClass="btn btn-light ap-clear" OnClick="btnReset_Click" />
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

                            <asp:TemplateField HeaderText="Training progress">
                                <ItemTemplate>

                                    <div class="progress-flex">

                                        <strong>
                                            <%#: Eval("Progress") %>%
                                        </strong>

                                        <div class="progress-bar">
                                            <span style='width:<%# Eval("Progress") %>%'>
                                            </span>
                                        </div>

                                    </div><span class="hours-note"><%#: Eval("ApprovedHours") %> / <%#: Eval("RequiredHours") %> approved hours</span>

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
                                            Tasks

                                        </asp:LinkButton>

                                        <asp:LinkButton
                                            ID="btnEvaluation"
                                            runat="server"
                                            CssClass="btn btn-small"
                                            CommandArgument='<%# Eval("StudentId") %>'
                                            CausesValidation="false"
                                            OnCommand="btnEvaluation_Command">

                                            <i class="bi bi-clipboard-check"></i>
                                            Evaluation

                                        </asp:LinkButton>

                                    </div>

                                </ItemTemplate>
                            </asp:TemplateField>

                        </Columns>

                    </asp:GridView>

                </div>

            </div>

        </section>



    </div>

</div>

<div class="academic-progress">
<!-- TASKS MODAL -->
<asp:Panel
    ID="pnlTasksModal"
    runat="server"
    Visible="false"
    CssClass="modal-overlay">

    <div class="modal-box ap-tasks-dialog"
         role="dialog"
         aria-modal="true"
         aria-labelledby="tasksModalTitle">

        <div class="modal-header">
            <div>
                <h2 id="tasksModalTitle">Student tasks</h2>

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
                <span aria-hidden="true">&times;</span>
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
                <h3>Tasks &amp; submissions</h3>

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

                    <details class="task-card"><summary>

                        <div class="task-head">

                            <div>
                                <div class="task-title">
                                    <%#: Eval("Title") %>
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

                        </summary><div class="ap-task-content">                                <div class="task-description">
                                    <%#: Eval("Description") %>
                                </div><div class="submission-box">

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

                        </div>
                    </details>

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

    <div class="modal-box ap-evaluation-dialog"
         role="dialog"
         aria-modal="true"
         aria-labelledby="evaluationModalTitle">

        <div class="modal-header">
            <div>
                <h2 id="evaluationModalTitle">
                    Academic evaluation
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

                <span aria-hidden="true">&times;</span>

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

            <section class="evaluation-card">
                <div class="ap-result-heading"><span>Academic result</span><asp:Label ID="lblEvaluationStatus" runat="server" /></div>
                <asp:Label ID="lblEvaluationRecommendation" runat="server" CssClass="ap-result-value" />
                <div class="ap-evaluation-date"><span>Submitted on</span><asp:Label ID="lblEvaluationDate" runat="server" /></div>
            </section>
            <section class="ap-evaluation-feedback"><h3>Supervisor comments</h3><p><asp:Label ID="lblEvaluationComments" runat="server" /></p></section>
            <asp:Label ID="lblEvaluationScore" runat="server" Visible="false" />

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
</div>
</asp:Content>

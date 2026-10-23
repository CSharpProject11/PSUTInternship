<%@ Page MasterPageFile="~/Portal.Master" Title="Company Supervisors" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="ManageCompanies.aspx.cs" Inherits="PSUTInternship.Admin.ManageCompanies" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<style>
.portal-app .portal-content .company-directory{max-width:1280px!important;margin:0 auto!important;padding:8px 0 32px!important;color:#19364b}
.company-directory .top{display:flex;align-items:center;justify-content:space-between;gap:20px;margin:0 0 22px}.company-directory>header.top{padding-bottom:24px;border-bottom:1px solid #dce5ec}.company-directory>header.top>strong{display:none}
.portal-app .portal-content .company-directory h1{font-size:30px!important;line-height:1.25;letter-spacing:-.035em;margin:0 0 8px!important;font-weight:750}.portal-app .portal-content .company-directory h2{font-size:19px!important;margin:0 0 6px!important;letter-spacing:-.02em}.company-directory .muted{font-size:13px!important;line-height:1.7;color:#607587!important;margin:0}
.portal-app .portal-content .company-directory .stats{display:flex!important;flex-wrap:wrap;gap:0!important;border:1px solid #dfe7ed;border-radius:10px;background:#fff;margin:0 0 24px!important;padding:0!important;overflow:hidden}.portal-app .portal-content .company-directory .stat{flex:1;min-width:150px;background:transparent!important;box-shadow:none!important;border:0!important;border-right:1px solid #e5ebf0!important;border-radius:0!important;padding:18px 24px!important;font-size:12px!important;color:#607587!important}.portal-app .portal-content .company-directory .stat:last-child{border-right:0!important}.portal-app .portal-content .company-directory .stat strong{display:block;font-size:26px!important;line-height:1.3;font-weight:750;color:#003e73!important;margin-top:6px;font-variant-numeric:tabular-nums}
.portal-app .portal-content .company-directory .card{padding:26px!important;border:1px solid #dfe7ed!important;border-radius:12px!important;background:#fff!important;box-shadow:none!important;margin-bottom:24px}
.company-directory .search{display:flex;align-items:center;gap:10px;background:#f3f6f9;padding:14px;border-radius:8px;margin:20px 0}.company-directory .search input[type=text]{flex:1;min-width:0;height:42px;padding:10px 13px;border:1px solid #cddbe5!important;background:#fff!important;font-size:13px!important;border-radius:6px!important}
.portal-app .portal-content .company-directory .btn{display:inline-flex;align-items:center;justify-content:center;min-height:40px;margin:0!important;padding:10px 14px!important;font-size:12px!important;font-weight:650!important;line-height:1.4!important;border:1px solid #003e73!important;border-radius:6px!important;background:#003e73!important;color:#fff!important;box-shadow:none!important;text-decoration:none;white-space:nowrap}.portal-app .portal-content .company-directory .btn.light{background:#fff!important;border-color:#ccd9e3!important;color:#34566f!important}.portal-app .portal-content .company-directory .btn.danger{background:#fff5f4!important;border-color:#eed6d3!important;color:#9b4038!important}
.portal-app .portal-content .company-directory .tableWrap{overflow:auto!important;border:1px solid #e1e8ee;border-radius:8px}.portal-app .portal-content .company-directory table{width:100%;min-width:800px!important;table-layout:auto;border-collapse:collapse}.portal-app .portal-content .company-directory th{font-size:11px!important;font-weight:650!important;background:#f5f8fa!important;color:#607587!important;padding:13px 16px!important;white-space:nowrap}.portal-app .portal-content .company-directory td{font-size:13px!important;font-weight:400!important;padding:16px!important;line-height:1.6!important;color:#425e73;vertical-align:middle!important;border-bottom:1px solid #e7edf2!important}.company-directory tbody tr:hover{background:#f8fafc}.company-directory tbody tr:last-child td{border-bottom:0!important}.company-directory td:first-child{font-weight:650!important;color:#17374f}.company-directory td .btn{min-height:32px!important;padding:6px 10px!important;font-size:11px!important;margin:3px 3px 3px 0!important}
.company-directory .grid,.company-directory .details{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:22px 26px;margin:24px 0}.company-directory .field{min-width:0}.company-directory .field label{display:block;font-size:12px!important;font-weight:650!important;color:#486278;margin-bottom:8px}.company-directory .field :is(input,select){display:block;width:100%!important;min-height:44px;border:1px solid #cbd9e3!important;border-radius:6px!important;background:#fff!important;padding:10px 12px!important;font-size:13px!important}.company-directory .detail{font-size:11px;color:#607587;border-bottom:1px solid #e5ecf1;padding:0 0 16px}.company-directory .detail span{display:block;font-size:14px;color:#193b53;font-weight:600;margin-top:6px;overflow-wrap:anywhere}.company-directory .backRow{margin-bottom:18px}.company-directory .grid~.btn{margin:6px 8px 0 0!important}.company-directory .message:empty{display:none}.company-directory .message:not(:empty){display:block;padding:14px 16px;background:#edf4f9;border-radius:8px;margin:0 0 20px;color:#254c68;font-size:13px}.company-directory :focus-visible{outline:3px solid #0078b5;outline-offset:3px}
@media(max-width:650px){.company-directory .top{flex-wrap:wrap;align-items:flex-start;gap:14px}.portal-app .portal-content .company-directory .card{padding:18px!important}.company-directory .grid,.company-directory .details{grid-template-columns:1fr;gap:18px}.company-directory .search{flex-wrap:wrap}.company-directory .search input[type=text]{flex-basis:100%}.portal-app .portal-content .company-directory h1{font-size:25px!important}}
/* Supervisor profile: identity first, then academic and contact details. */
.portal-app .portal-content .company-directory .supervisor-profile{background:#fff;border:1px solid #dce6ee;border-radius:14px;overflow:hidden;max-width:1100px}
.company-directory .supervisor-profile-header{display:flex;align-items:center;gap:18px;padding:30px;background:#f6f9fb;border-bottom:1px solid #e0e8ef}
.company-directory .supervisor-profile-icon{display:grid;place-items:center;width:60px;height:60px;flex-shrink:0;border-radius:50%;background:#e2edf5;color:#003e73}
.portal-app .portal-content .company-directory .supervisor-profile-identity h2{font-size:24px!important;line-height:1.3;letter-spacing:-.025em;margin:0 0 5px!important;overflow-wrap:anywhere}.company-directory .supervisor-profile-identity p{font-size:13px;color:#607587;margin:0}
.company-directory .supervisor-profile-status{margin-left:auto;text-align:right;flex-shrink:0}.company-directory .supervisor-profile-status>span{display:block;font-size:11px;color:#607587;margin-bottom:6px}.company-directory .supervisor-profile-status>strong{display:inline-block;font-size:12px;font-weight:650;color:#34566f;background:#e6eef4;border:1px solid #d2e0ea;padding:5px 12px;border-radius:6px}
.company-directory .supervisor-profile-body{display:grid;grid-template-columns:1.2fr 1fr;gap:40px;padding:30px}.company-directory .supervisor-profile-section+section{border-left:1px solid #e4ebf1;padding-left:32px}
.portal-app .portal-content .company-directory .supervisor-profile-section h3{font-size:15px!important;font-weight:700;margin:0 0 5px!important;color:#193b53}.company-directory .profile-section-description{font-size:12px!important;color:#607587;margin:0 0 26px!important;line-height:1.6}
.company-directory .supervisor-profile-section dl{margin:0}.company-directory .supervisor-profile-section dl>div{padding:0 0 20px;margin:0 0 20px;border-bottom:1px solid #e7edf2}.company-directory .supervisor-profile-section dl>div:last-child{border:0;padding-bottom:0;margin-bottom:0}.company-directory .supervisor-profile-section dt{font-size:11px;font-weight:500;color:#607587;margin-bottom:7px}.company-directory .supervisor-profile-section dd{font-size:14px;font-weight:600;line-height:1.7;color:#26465e;margin:0;overflow-wrap:anywhere}.company-directory .supervisor-profile-section dd span:empty::after{content:'Not provided';color:#7a8996;font-weight:400}
@media(max-width:700px){.company-directory .supervisor-profile-header{padding:22px;flex-wrap:wrap;gap:14px}.company-directory .supervisor-profile-status{margin-left:0;text-align:left;flex-basis:100%;border-top:1px solid #dfe8ee;padding-top:14px}.company-directory .supervisor-profile-body{grid-template-columns:1fr;padding:22px;gap:28px}.company-directory .supervisor-profile-section+section{border-left:0;border-top:1px solid #e4ebf1;padding:24px 0 0}}
</style>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">

        <main class="main company-directory">
            <header class="top">
                <div>
                    <h1>Company Supervisors</h1>
                    <p class="muted">Create and manage company supervisor accounts.</p>
                </div>
                <strong>Coordinator</strong></header>
            <asp:Label ID="messageLabel" runat="server" CssClass="message" />

            <asp:Panel ID="listSection" runat="server">
                <section class="stats">
                    <div class="stat">Total supervisors<strong><asp:Label ID="totalLabel" runat="server" Text="0" /></strong></div>
                    <div class="stat">Active<strong><asp:Label ID="activeLabel" runat="server" Text="0" /></strong></div>
                    <div class="stat">Inactive<strong><asp:Label ID="inactiveLabel" runat="server" Text="0" /></strong></div>
                </section>
                <section class="card">
                    <div class="top">
                        <div>
                            <h2>Supervisor list</h2>
                            <p class="muted">View, edit, or change account status.</p>
                        </div>
                        <asp:Button ID="addButton" runat="server" Text="Add supervisor" CssClass="btn" CausesValidation="false" OnClick="addButton_Click" /></div>
                    <div class="search">
                        <asp:TextBox ID="searchTextBox" runat="server" placeholder="Search by name, email, or company" /><asp:Button ID="searchButton" runat="server" Text="Search" CssClass="btn" OnClick="searchButton_Click" /><a class="btn light" href="ManageCompanies.aspx">Reset</a></div>
                    <div class="tableWrap">
                        <asp:Literal ID="tableLiteral" runat="server" /></div>
                </section>
            </asp:Panel>

            <asp:Panel ID="formSection" runat="server" Visible="false">
                <div class="backRow">
                    <asp:Button ID="formBackButton" runat="server" Text="← Back" CssClass="btn light" CausesValidation="false" OnClick="backButton_Click" /></div>
                <section class="card">
                    <h2>
                        <asp:Label ID="formTitleLabel" runat="server" Text="Add company supervisor" /></h2>
                    <div class="grid">
                        <div class="field">
                            <label>Full name *</label><asp:TextBox ID="nameTextBox" runat="server" /></div>
                        <div class="field">
                            <label>Email *</label><asp:TextBox ID="emailTextBox" runat="server" TextMode="Email" /></div>
                        <div class="field">
                            <label>Temporary password (new account) *</label><asp:TextBox ID="passwordTextBox" runat="server" TextMode="Password" /></div>
                        <div class="field">
                            <label>Company name *</label><asp:TextBox ID="companyNameTextBox" runat="server" /></div>
                        <div class="field">
                            <label>Job title</label><asp:TextBox ID="jobTitleTextBox" runat="server" /></div>
                        <div class="field">
                            <label>Phone number</label><asp:TextBox ID="phoneTextBox" runat="server" /></div>
                    </div>
                    <asp:Button ID="saveButton" runat="server" Text="Create supervisor" CssClass="btn" OnClick="saveButton_Click" />
                    <asp:Button ID="clearButton" runat="server" Text="Clear" CssClass="btn light" CausesValidation="false" OnClick="clearButton_Click" />
                </section>
            </asp:Panel>

            <asp:Panel ID="viewSection" runat="server" Visible="false">
                <div class="backRow">
                    <asp:Button ID="viewBackButton" runat="server" Text="← Back to supervisors" CssClass="btn light" CausesValidation="false" OnClick="backButton_Click" /></div>
                <section class="supervisor-profile">
                    <header class="supervisor-profile-header">
                        <div class="supervisor-profile-icon" aria-hidden="true"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="8" r="3.5"/><path d="M5 21v-2a7 7 0 0 1 14 0v2"/></svg></div>
                        <div class="supervisor-profile-identity"><h2><asp:Label ID="viewNameLabel" runat="server" /></h2><p>Company supervisor</p></div>
                        <div class="supervisor-profile-status"><span>Account status</span><strong><asp:Label ID="viewStatusLabel" runat="server" /></strong></div>
                    </header>
                    <div class="supervisor-profile-body">
                        <section class="supervisor-profile-section"><h3>Company information</h3><p class="profile-section-description">Organization and professional role</p><dl><div><dt>Company</dt><dd><asp:Label ID="viewCompanyLabel" runat="server" /></dd></div><div><dt>Job title</dt><dd><asp:Label ID="viewJobTitleLabel" runat="server" /></dd></div></dl></section>
                        <section class="supervisor-profile-section"><h3>Contact details</h3><p class="profile-section-description">Contact information on this account</p><dl><div><dt>Email address</dt><dd><asp:Label ID="viewEmailLabel" runat="server" /></dd></div><div><dt>Phone number</dt><dd><asp:Label ID="viewPhoneLabel" runat="server" /></dd></div></dl></section>
                    </div>
                </section>
            </asp:Panel>
        </main>
</asp:Content>

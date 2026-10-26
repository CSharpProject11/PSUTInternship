<%@ Page MasterPageFile="~/Portal.Master" Title="Manage Students" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="ManageStudents.aspx.cs" Inherits="PSUTInternship.Admin.ManageStudents" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link rel="stylesheet" href="Coordinator.css?v=review4" />
<style>
.portal-app .portal-content .student-directory{max-width:1280px!important;margin:0 auto!important;padding:8px 0 32px!important;color:#19364b}
.student-directory .top{display:flex;align-items:center;justify-content:space-between;gap:20px;margin:0 0 22px}.student-directory>header.top{padding-bottom:24px;border-bottom:1px solid #dce5ec}.student-directory>header.top>strong{display:none}
.portal-app .portal-content .student-directory h1{font-size:30px!important;line-height:1.25;letter-spacing:-.035em;margin:0 0 8px!important;font-weight:750}.portal-app .portal-content .student-directory h2{font-size:19px!important;margin:0 0 6px!important;letter-spacing:-.02em}.student-directory .muted{font-size:13px!important;line-height:1.7;color:#607587!important;margin:0}
.portal-app .portal-content .student-directory .stats{display:flex!important;flex-wrap:wrap;gap:0!important;border:1px solid #dfe7ed;border-radius:10px;background:#fff;margin:0 0 24px!important;padding:0!important;overflow:hidden}.portal-app .portal-content .student-directory .stat{flex:1;min-width:150px;background:transparent!important;box-shadow:none!important;border:0!important;border-right:1px solid #e5ebf0!important;border-radius:0!important;padding:18px 24px!important;font-size:12px!important;color:#607587!important}.portal-app .portal-content .student-directory .stat:last-child{border-right:0!important}.portal-app .portal-content .student-directory .stat strong{display:block;font-size:26px!important;line-height:1.3;font-weight:750;color:#003e73!important;margin-top:6px;font-variant-numeric:tabular-nums}
.portal-app .portal-content .student-directory .card{padding:26px!important;border:1px solid #dfe7ed!important;border-radius:12px!important;background:#fff!important;box-shadow:none!important;margin-bottom:24px}
.student-directory .search{display:flex;align-items:center;gap:10px;background:#f3f6f9;padding:14px;border-radius:8px;margin:20px 0}.student-directory .search input[type=text]{flex:1;min-width:0;height:42px;padding:10px 13px;border:1px solid #cddbe5!important;background:#fff!important;font-size:13px!important;border-radius:6px!important}
.portal-app .portal-content .student-directory .btn{display:inline-flex;align-items:center;justify-content:center;min-height:40px;margin:0!important;padding:10px 14px!important;font-size:12px!important;font-weight:650!important;line-height:1.4!important;border:1px solid #003e73!important;border-radius:6px!important;background:#003e73!important;color:#fff!important;box-shadow:none!important;text-decoration:none;white-space:nowrap}.portal-app .portal-content .student-directory .btn.light{background:#fff!important;border-color:#ccd9e3!important;color:#34566f!important}.portal-app .portal-content .student-directory .btn.danger{background:#fff5f4!important;border-color:#eed6d3!important;color:#9b4038!important}
.portal-app .portal-content .student-directory .tableWrap{overflow:auto!important;border:1px solid #e1e8ee;border-radius:8px}.portal-app .portal-content .student-directory table{width:100%;min-width:800px!important;table-layout:auto;border-collapse:collapse}.portal-app .portal-content .student-directory th{font-size:11px!important;font-weight:650!important;background:#f5f8fa!important;color:#607587!important;padding:13px 16px!important;white-space:nowrap}.portal-app .portal-content .student-directory td{font-size:13px!important;font-weight:400!important;padding:16px!important;line-height:1.6!important;color:#425e73;vertical-align:middle!important;border-bottom:1px solid #e7edf2!important}.student-directory tbody tr:hover{background:#f8fafc}.student-directory tbody tr:last-child td{border-bottom:0!important}.student-directory td:first-child{font-weight:650!important;color:#17374f}.student-directory td .btn{min-height:32px!important;padding:6px 10px!important;font-size:11px!important;margin:3px 3px 3px 0!important}
.student-directory .grid,.student-directory .details{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:22px 26px;margin:24px 0}.student-directory .field{min-width:0}.student-directory .field label{display:block;font-size:12px!important;font-weight:650!important;color:#486278;margin-bottom:8px}.student-directory .field :is(input,select){display:block;width:100%!important;min-height:44px;border:1px solid #cbd9e3!important;border-radius:6px!important;background:#fff!important;padding:10px 12px!important;font-size:13px!important}.student-directory .detail{font-size:11px;color:#607587;border-bottom:1px solid #e5ecf1;padding:0 0 16px}.student-directory .detail span{display:block;font-size:14px;color:#193b53;font-weight:600;margin-top:6px;overflow-wrap:anywhere}.student-directory .backRow{margin-bottom:18px}.student-directory .grid~.btn{margin:6px 8px 0 0!important}.student-directory .message:empty{display:none}.student-directory .message:not(:empty){display:block;padding:14px 16px;background:#edf4f9;border-radius:8px;margin:0 0 20px;color:#254c68;font-size:13px}.student-directory :focus-visible{outline:3px solid #0078b5;outline-offset:3px}
@media(max-width:650px){.student-directory .top{flex-wrap:wrap;align-items:flex-start;gap:14px}.portal-app .portal-content .student-directory .card{padding:18px!important}.student-directory .grid,.student-directory .details{grid-template-columns:1fr;gap:18px}.student-directory .search{flex-wrap:wrap}.student-directory .search input[type=text]{flex-basis:100%}.portal-app .portal-content .student-directory h1{font-size:25px!important}}
/* Supervisor profile: identity first, then academic and contact details. */
.portal-app .portal-content .student-directory .supervisor-profile{background:#fff;border:1px solid #dce6ee;border-radius:14px;overflow:hidden;max-width:1100px}
.student-directory .supervisor-profile-header{display:flex;align-items:center;gap:18px;padding:30px;background:#f6f9fb;border-bottom:1px solid #e0e8ef}
.student-directory .supervisor-profile-icon{display:grid;place-items:center;width:60px;height:60px;flex-shrink:0;border-radius:50%;background:#e2edf5;color:#003e73}
.portal-app .portal-content .student-directory .supervisor-profile-identity h2{font-size:24px!important;line-height:1.3;letter-spacing:-.025em;margin:0 0 5px!important;overflow-wrap:anywhere}.student-directory .supervisor-profile-identity p{font-size:13px;color:#607587;margin:0}
.student-directory .supervisor-profile-status{margin-left:auto;text-align:right;flex-shrink:0}.student-directory .supervisor-profile-status>span{display:block;font-size:11px;color:#607587;margin-bottom:6px}.student-directory .supervisor-profile-status>strong{display:inline-block;font-size:12px;font-weight:650;color:#34566f;background:#e6eef4;border:1px solid #d2e0ea;padding:5px 12px;border-radius:6px}
.student-directory .supervisor-profile-body{display:grid;grid-template-columns:1.2fr 1fr;gap:40px;padding:30px}.student-directory .supervisor-profile-section+section{border-left:1px solid #e4ebf1;padding-left:32px}
.portal-app .portal-content .student-directory .supervisor-profile-section h3{font-size:15px!important;font-weight:700;margin:0 0 5px!important;color:#193b53}.student-directory .profile-section-description{font-size:12px!important;color:#607587;margin:0 0 26px!important;line-height:1.6}
.student-directory .supervisor-profile-section dl{margin:0}.student-directory .supervisor-profile-section dl>div{padding:0 0 20px;margin:0 0 20px;border-bottom:1px solid #e7edf2}.student-directory .supervisor-profile-section dl>div:last-child{border:0;padding-bottom:0;margin-bottom:0}.student-directory .supervisor-profile-section dt{font-size:11px;font-weight:500;color:#607587;margin-bottom:7px}.student-directory .supervisor-profile-section dd{font-size:14px;font-weight:600;line-height:1.7;color:#26465e;margin:0;overflow-wrap:anywhere}.student-directory .supervisor-profile-section dd span:empty::after{content:'Not provided';color:#7a8996;font-weight:400}
@media(max-width:700px){.student-directory .supervisor-profile-header{padding:22px;flex-wrap:wrap;gap:14px}.student-directory .supervisor-profile-status{margin-left:0;text-align:left;flex-basis:100%;border-top:1px solid #dfe8ee;padding-top:14px}.student-directory .supervisor-profile-body{grid-template-columns:1fr;padding:22px;gap:28px}.student-directory .supervisor-profile-section+section{border-left:0;border-top:1px solid #e4ebf1;padding:24px 0 0}}
.student-directory .admin-form-actions{display:flex;gap:10px;padding-top:20px;border-top:1px solid #e3ebf1;margin-top:26px}.student-directory .field>span{display:block;padding:12px;background:#f3f6f9;border:1px solid #dce6ee;border-radius:6px;color:#607587;font-size:13px}.student-directory .field input[type=number],.student-directory .field input[type=date]{font-variant-numeric:tabular-nums}.student-directory .grid{align-items:start}
</style>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">


        <main class="main student-directory">
            <header class="top">
                <div>
                    <h1>Students</h1>
                    <p class="muted">Create and manage student accounts.</p>
                </div>
                <strong>Coordinator</strong>
            </header>

            <asp:Label ID="messageLabel" runat="server" CssClass="message" />

            <asp:Panel ID="listSection" runat="server">
                <section class="stats">
                    <div class="stat">Total students<strong><asp:Label ID="studentCountLabel" runat="server" Text="0" /></strong></div>
                    <div class="stat">Active<strong><asp:Label ID="activeCountLabel" runat="server" Text="0" /></strong></div>
                    <div class="stat">Inactive<strong><asp:Label ID="inactiveCountLabel" runat="server" Text="0" /></strong></div>
                </section>
                <section class="card">
                    <div class="top">
                        <div>
                            <h2>Student list</h2>
                            <p class="muted">View, edit, or change account status.</p>
                        </div>
                        <asp:Button ID="addStudentButton" runat="server" Text="Add student" CssClass="btn" CausesValidation="false" OnClick="addStudentButton_Click" /></div>
                    <div class="search">
                        <asp:TextBox ID="searchTextBox" runat="server" placeholder="Search name, email, or student number" /><asp:Button ID="searchButton" runat="server" Text="Search" CssClass="btn" OnClick="searchButton_Click" /><a class="btn light" href="ManageStudents.aspx">Reset</a></div>
                    <div class="tableWrap">
                        <asp:Literal ID="studentsTable" runat="server" /></div>
                </section>
            </asp:Panel>

            <asp:Panel ID="formSection" runat="server" Visible="false">
                <div class="backRow">
                    <asp:Button ID="formBackButton" runat="server" Text="← Back" CssClass="btn light" CausesValidation="false" OnClick="backButton_Click" /></div>
                <section class="card">
                    <h2>
                        <asp:Label ID="formTitleLabel" runat="server" Text="Add Student" /></h2>
                    <div class="grid">
                        <div class="field">
                            <label>Full name *</label><asp:TextBox ID="fullNameTextBox" runat="server" /></div>
                        <div class="field">
                            <label>Email *</label><asp:TextBox ID="emailTextBox" runat="server" TextMode="Email" /></div>
                        <div class="field">
                            <label>Temporary password (new account) *</label><asp:TextBox ID="passwordTextBox" runat="server" TextMode="Password" /></div>
                        <div class="field">
                            <label>Enrollment year *</label><asp:TextBox ID="enrollmentYearTextBox" runat="server" TextMode="Number" placeholder="Example: 2026" /></div>
                        <div class="field">
                            <label>University number</label><asp:Label ID="generatedNumberLabel" runat="server" Text="Generated after saving" /></div>
                        <div class="field">
                            <label>College *</label><asp:DropDownList ID="collegeTextBox" runat="server"><asp:ListItem Text="Select college" Value="" /><asp:ListItem>King Hussein School of Computing Sciences</asp:ListItem></asp:DropDownList></div>
                        <div class="field">
                            <label>Major *</label><asp:DropDownList ID="majorTextBox" runat="server" AutoPostBack="true" OnSelectedIndexChanged="MajorChanged"><asp:ListItem Text="Select program or department" Value="" /><asp:ListItem>Computer Science</asp:ListItem><asp:ListItem>Computer Graphics and Animation</asp:ListItem><asp:ListItem>Software Engineering</asp:ListItem><asp:ListItem>Data Science and Artificial Intelligence</asp:ListItem><asp:ListItem>Cyber Security</asp:ListItem></asp:DropDownList></div>
                        <div class="field">
                            <label for="academicSupervisorList">Academic supervisor *</label><asp:DropDownList ID="academicSupervisorList" runat="server" /></div><div class="field">
                            <label>Required training hours *</label><asp:TextBox ID="requiredHoursTextBox" runat="server" Text="96" TextMode="Number" /></div>
                        <div class="field">
                            <label>Start date</label><asp:TextBox ID="startDateTextBox" runat="server" TextMode="Date" /></div>
                        <div class="field">
                            <label>End date</label><asp:TextBox ID="endDateTextBox" runat="server" TextMode="Date" /></div>
                    </div>
                    <div class="admin-form-actions"><asp:Button ID="saveButton" runat="server" Text="Create Student" CssClass="btn" OnClick="saveButton_Click" />
                    <asp:Button ID="clearButton" runat="server" Text="Clear" CssClass="btn light" CausesValidation="false" OnClick="clearButton_Click" /></div>
                </section>
            </asp:Panel>

            <asp:Panel ID="viewSection" runat="server" Visible="false">
                <div class="backRow">
                    <asp:Button ID="viewBackButton" runat="server" Text="← Back to students" CssClass="btn light" CausesValidation="false" OnClick="backButton_Click" /></div>
                <section class="supervisor-profile">
                    <header class="supervisor-profile-header">
                        <div class="supervisor-profile-icon" aria-hidden="true"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="8" r="3.5"/><path d="M5 21v-2a7 7 0 0 1 14 0v2"/></svg></div>
                        <div class="supervisor-profile-identity"><h2><asp:Label ID="viewNameLabel" runat="server" /></h2><p>Student · <asp:Label ID="viewStudentNumberLabel" runat="server" /></p></div>
                        <div class="supervisor-profile-status"><span>Account status</span><strong><asp:Label ID="viewStatusLabel" runat="server" /></strong></div>
                    </header>
                    <div class="supervisor-profile-body">
                        <section class="supervisor-profile-section"><h3>Academic information</h3><p class="profile-section-description">Enrollment and student account details</p><dl><div><dt>College</dt><dd><asp:Label ID="viewCollegeLabel" runat="server" /></dd></div><div><dt>Major</dt><dd><asp:Label ID="viewMajorLabel" runat="server" /></dd></div><div><dt>Enrollment year</dt><dd><asp:Label ID="viewYearLabel" runat="server" /></dd></div><div><dt>Email address</dt><dd><asp:Label ID="viewEmailLabel" runat="server" /></dd></div></dl></section>
                        <section class="supervisor-profile-section"><h3>Training requirements</h3><p class="profile-section-description">Required hours and internship dates</p><dl><div><dt>Required training hours</dt><dd><asp:Label ID="viewHoursLabel" runat="server" /></dd></div><div><dt>Start date</dt><dd><asp:Label ID="viewStartDateLabel" runat="server" /></dd></div><div><dt>End date</dt><dd><asp:Label ID="viewEndDateLabel" runat="server" /></dd></div></dl></section>
                    </div>
                </section>
            </asp:Panel>
        </main>
</asp:Content>

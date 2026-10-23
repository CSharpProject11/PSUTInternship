<%@ Page Title="Manage Student Groups - UIMS" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="AssignSuper.aspx.cs" Inherits="PSUTInternship.Admin.AssignSuper" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link rel="stylesheet" href="Coordinator.css?v=review4" />
<style>
.portal-app .portal-content .assignment-page{max-width:1250px!important;margin:0 auto!important;padding:8px 0 32px!important;color:#19364b}
.assignment-page .top{display:flex;align-items:center;justify-content:space-between;gap:24px;margin:0 0 24px}.assignment-page>header.top{padding-bottom:26px;border-bottom:1px solid #dce5ec}.assignment-page>header.top>strong{display:none}
.portal-app .portal-content .assignment-page h1{font-size:30px!important;line-height:1.2;letter-spacing:-.035em;margin:0 0 10px!important;font-weight:750}
.portal-app .portal-content .assignment-page h2{font-size:19px!important;line-height:1.4;letter-spacing:-.02em;margin:0 0 6px!important}.assignment-page .muted{font-size:13px!important;color:#607587!important;line-height:1.7;margin:0}
.portal-app .portal-content .assignment-page .card{padding:26px!important;border:1px solid #dfe7ed!important;background:#fff!important;border-radius:12px!important;box-shadow:none!important;margin-bottom:22px}
.assignment-page .search{display:flex;align-items:center;gap:10px;padding:16px;background:#f4f7fa;border-radius:8px;margin:20px 0 30px}.assignment-page .search input[type=text]{flex:1;min-width:0;background:#fff!important;border:1px solid #cedbe5!important;height:42px!important;padding:10px 13px!important;font-size:13px!important;border-radius:6px!important}
.portal-app .portal-content .assignment-page .btn{font-size:12px!important;line-height:1.4!important;font-weight:650!important;padding:11px 16px!important;min-height:40px;border-radius:6px!important;box-shadow:none!important;background:#003e73!important;color:#fff!important;border:1px solid #003e73!important;white-space:nowrap}
.portal-app .portal-content .assignment-page .btn.light{background:#fff!important;border-color:#cddae4!important;color:#34566f!important}
.portal-app .portal-content .assignment-page .assignment-department{font-size:14px!important;font-weight:700!important;margin:28px 0 12px!important;color:#26485f!important}
.portal-app .portal-content .assignment-page .tableWrap{border:1px solid #e0e8ee;border-radius:8px;overflow-x:auto!important;margin:0 0 24px}.portal-app .portal-content .assignment-page table{width:100%;min-width:620px!important;table-layout:auto;border-collapse:collapse}.portal-app .portal-content .assignment-page th{background:#f5f8fa!important;font-size:11px!important;font-weight:650!important;color:#607587!important;padding:12px 16px!important;white-space:nowrap}.portal-app .portal-content .assignment-page td{padding:15px 16px!important;font-size:13px!important;font-weight:400!important;border-bottom:1px solid #e8eef2!important;vertical-align:middle!important;color:#3d586d}.assignment-page td:first-child{font-weight:650!important;color:#183950!important}.assignment-page tbody tr:last-child td{border-bottom:0!important}.assignment-page tbody tr:hover{background:#f8fafc}.assignment-page td:last-child{text-align:right}.assignment-page th:last-child{text-align:right}
.assignment-page .field{margin:22px 0;max-width:760px}.assignment-page .field>label{display:block;font-size:12px!important;font-weight:650!important;margin-bottom:8px;color:#405d72}.assignment-page .field :is(input[type=text],select){display:block;width:100%!important;min-height:44px;border:1px solid #cbd9e3!important;border-radius:6px!important;background:#fff!important;font-size:13px!important;padding:10px 12px!important}.assignment-page .field>.btn{margin-top:12px}
.assignment-page .checkList{max-height:300px;overflow-y:auto;border:1px solid #d9e3eb;border-radius:8px;padding:8px 14px;scrollbar-width:thin}.portal-app .portal-content .assignment-page .checkList table{min-width:0!important}.assignment-page .checkList td{padding:10px 0!important}.assignment-page .checkList label{display:inline!important;font-size:13px;font-weight:400;margin-left:9px;cursor:pointer}.assignment-page input[type=checkbox]{width:16px;height:16px;accent-color:#003e73;vertical-align:middle}.assignment-page .backRow{margin:0 0 18px}.assignment-page .message:empty{display:none}.assignment-page .message:not(:empty){display:block;margin:0 0 20px;padding:13px 16px;border-radius:8px;background:#edf4f9;color:#254c68;font-size:13px}.assignment-page .empty{font-size:13px!important;color:#607587!important;padding:24px!important}.assignment-page hr{border:0;border-top:1px solid #e3ebf1;margin:28px 0}.assignment-page h3{font-size:15px!important}.assignment-page :focus-visible{outline:3px solid #0078b5;outline-offset:3px}
@media(max-width:650px){.assignment-page .top{align-items:flex-start;flex-wrap:wrap;gap:14px}.portal-app .portal-content .assignment-page .card{padding:18px!important}.assignment-page .search{flex-wrap:wrap;padding:12px}.assignment-page .search input[type=text]{flex-basis:100%}.portal-app .portal-content .assignment-page h1{font-size:25px!important}}
/* Group detail workspace: membership alongside assignment controls. */
.assignment-page .group-overview{padding:26px;background:#fff;border:1px solid #dfe7ed;border-radius:12px;margin-bottom:22px;display:flex;align-items:center;justify-content:space-between;gap:30px}.assignment-page .group-heading p{font-size:12px;color:#607587;margin:6px 0 0}.assignment-page .group-facts{display:flex;gap:36px;margin:0}.assignment-page .group-facts dt{font-size:11px;color:#607587;margin-bottom:6px}.assignment-page .group-facts dd{margin:0;font-size:13px;font-weight:600;color:#23475f;max-width:280px;overflow-wrap:anywhere}
.assignment-page .group-management{display:grid;grid-template-columns:minmax(0,1.65fr) minmax(300px,1fr);align-items:start;gap:22px}.assignment-page .group-members,.assignment-page .group-assignment,.assignment-page .group-add-members{background:#fff;border:1px solid #dfe7ed;border-radius:12px;padding:22px;min-width:0}.assignment-page .group-sidebar{display:grid;gap:20px}.portal-app .portal-content .assignment-page .group-management h3{font-size:16px!important;margin:0 0 6px!important}.assignment-page .group-members .tableWrap{margin-top:20px}.portal-app .portal-content .assignment-page .group-members table{min-width:540px!important}.portal-app .portal-content .assignment-page .group-members .empty{text-align:center!important;font-weight:400!important;font-size:13px!important;padding:36px 20px!important}
.assignment-page .group-assignment .field{margin:20px 0 14px}.portal-app .portal-content .assignment-page .group-assignment input[type=submit]{display:inline-flex!important;width:auto!important;max-width:100%!important;margin:0!important}.assignment-page .group-assignment select{margin-bottom:0!important}
.assignment-page .group-add-members .checkList{margin:18px 0 16px;padding:4px 12px;max-height:280px;overflow:auto}.portal-app .portal-content .assignment-page .group-add-members .checkList table{display:table!important;min-width:0!important;width:100%!important;table-layout:fixed!important;direction:ltr!important}.portal-app .portal-content .assignment-page .group-add-members .checkList td{padding:11px 0!important;text-align:left!important;direction:ltr!important;white-space:normal!important;font-size:12px!important}.portal-app .portal-content .assignment-page .group-add-members .checkList label{display:inline!important;font-size:12px!important;font-weight:500!important;line-height:1.7!important;margin-left:8px!important;white-space:normal!important;overflow-wrap:anywhere}.portal-app .portal-content .assignment-page .group-add-members input[type=checkbox]{width:16px!important;height:16px!important;margin:0!important;vertical-align:middle!important}.portal-app .portal-content .assignment-page .group-add-members input[type=submit]{width:auto!important;display:inline-flex!important;margin:0!important}
@media(max-width:1050px){.assignment-page .group-management{grid-template-columns:minmax(0,1fr)}.assignment-page .group-sidebar{grid-template-columns:repeat(2,minmax(0,1fr))}.assignment-page .group-overview{align-items:flex-start;flex-direction:column;gap:20px}}@media(max-width:650px){.assignment-page .group-sidebar{grid-template-columns:1fr}.assignment-page .group-facts{flex-direction:column;gap:16px}.assignment-page .group-overview,.assignment-page .group-members,.assignment-page .group-assignment,.assignment-page .group-add-members{padding:18px}}
</style>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">

        <main class="main assignment-page">
            <header class="top">
                <div>
                    <h1>Assign supervisors</h1>
                    <p class="muted">Manage academic supervision and student groups by department.</p>
                </div>
                <strong>Coordinator</strong></header>
            <asp:Label ID="messageLabel" runat="server" CssClass="message" />

            <asp:Panel ID="listSection" runat="server">
                <section class="card">
                    <div class="top">
                        <div>
                            <h2>Groups by department</h2>
                            <p class="muted">Search groups, supervisors, students, or student numbers.</p>
                        </div>
                        <asp:Button ID="addGroupButton" runat="server" Text="Create group" CssClass="btn" CausesValidation="false" OnClick="addGroupButton_Click" /></div>
                    <div class="search">
                        <asp:TextBox ID="searchTextBox" runat="server" placeholder="Search groups, supervisors or students" /><asp:Button ID="searchButton" runat="server" Text="Search" CssClass="btn" CausesValidation="false" OnClick="searchButton_Click" /><a class="btn light" href="AssignSuper.aspx">Reset</a></div>
                    <asp:Literal ID="groupsTables" runat="server" />
                </section>
            </asp:Panel>

            <asp:Panel ID="addSection" runat="server" Visible="false">
                <div class="backRow">
                    <asp:Button ID="addBackButton" runat="server" Text="← Back to groups" CssClass="btn light" CausesValidation="false" OnClick="backButton_Click" /></div>
                <section class="card">
                    <h2>Create a group</h2>
                    <p class="muted">Choose a department, an academic supervisor from that department, and students with the same major.</p>
                    <div class="field">
                        <label>Department / major *</label><asp:DropDownList ID="departmentDropDown" runat="server" AutoPostBack="true" OnSelectedIndexChanged="departmentDropDown_SelectedIndexChanged" /></div>
                    <div class="field">
                        <label>Group name *</label><asp:TextBox ID="groupNameTextBox" runat="server" /></div>
                    <div class="field">
                        <label>Academic supervisor *</label><asp:DropDownList ID="supervisorDropDown" runat="server" /></div>
                    <div class="field">
                        <label>Students *</label><div class="checkList">
                            <asp:CheckBoxList ID="studentsCheckBoxList" runat="server" /></div>
                    </div>
                    <asp:Button ID="saveGroupButton" runat="server" Text="Create group" CssClass="btn" OnClick="saveGroupButton_Click" />
                </section>
            </asp:Panel>

            <asp:Panel ID="viewSection" runat="server" Visible="false">
                <div class="backRow">
                    <asp:Button ID="viewBackButton" runat="server" Text="← Back to groups" CssClass="btn light" CausesValidation="false" OnClick="backButton_Click" /></div>
                <section class="group-overview">
                    <div class="group-heading"><h2><asp:Label ID="viewGroupNameLabel" runat="server" /></h2><p>Student group</p></div>
                    <dl class="group-facts"><div><dt>Department</dt><dd><asp:Label ID="viewDepartmentLabel" runat="server" /></dd></div><div><dt>Academic supervisor</dt><dd><asp:Label ID="viewSupervisorLabel" runat="server" /></dd></div></dl>
                </section>
                <div class="group-management">
                    <section class="group-members"><h3>Students in this group</h3><p class="muted">Current group membership and student details.</p><asp:Literal ID="viewStudentsTable" runat="server" /></section>
                    <aside class="group-sidebar">
                        <section class="group-assignment"><h3>Supervisor assignment</h3><p class="muted">Choose the academic supervisor responsible for this group.</p><div class="field"><asp:Label runat="server" AssociatedControlID="ReplacementSupervisor" Text="Academic supervisor" /><asp:DropDownList ID="ReplacementSupervisor" runat="server" /></div><asp:Button ID="ReassignSupervisor" runat="server" Text="Save assignment" CssClass="btn" OnClick="ReassignSupervisor_Click" /></section>
                        <section class="group-add-members"><h3>Add students</h3><p class="muted">Select students to include in this group.</p><div class="checkList"><asp:CheckBoxList ID="addStudentsCheckBoxList" runat="server" /></div><asp:Button ID="addStudentsButton" runat="server" Text="Add selected students" CssClass="btn" OnClick="addStudentsButton_Click" /></section>
                    </aside>
                </div>
            </asp:Panel>
        </main>
</asp:Content>

<%@ Page Title="Manage Student Groups - UIMS" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="AssignSuper.aspx.cs" Inherits="PSUTInternship.Admin.AssignSuper" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f3f6fb;
            color: #26324b;
        }

        .sidebar {
            position: fixed;
            inset: 0 auto 0 0;
            width: 220px;
            padding: 24px 14px;
            background: #263b69;
            color: white;
        }

            .sidebar h2 {
                margin: 0 10px 28px;
            }

            .sidebar a {
                display: block;
                padding: 12px;
                margin: 5px 0;
                border-radius: 7px;
                color: white;
                text-decoration: none;
            }

                .sidebar a:hover, .sidebar .active {
                    background: #435b91;
                }

        .main {
            margin-left: 220px;
            padding: 28px;
        }

        .top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 22px;
        }

            .top h1 {
                margin: 0 0 6px;
            }

        .muted {
            color: #748099;
            margin: 0;
        }

        .card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 18px;
            box-shadow: 0 4px 16px #263b6910;
        }

        .field {
            margin-bottom: 16px;
        }

            .field label {
                display: block;
                margin-bottom: 6px;
                font-weight: bold;
            }

            .field input, .field select {
                width: 100%;
                padding: 10px;
                border: 1px solid #dce2ee;
                border-radius: 7px;
            }

        .btn {
            border: 0;
            border-radius: 7px;
            padding: 10px 15px;
            background: #526bd4;
            color: white;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .light {
            background: #e8ecf8;
            color: #263b69;
        }

        .message {
            display: block;
            margin: 12px 0;
            color: #263b69;
        }

        .search {
            display: flex;
            gap: 8px;
            margin: 14px 0;
        }

            .search input {
                flex: 1;
                min-width: 0;
                padding: 10px;
                border: 1px solid #dce2ee;
                border-radius: 7px;
            }

        .tableWrap {
            overflow-x: auto;
            margin: 10px 0 24px;
        }

        table {
            width: 100%;
            min-width: 700px;
            border-collapse: collapse;
        }

        th, td {
            padding: 11px;
            border-bottom: 1px solid #edf0f6;
            text-align: left;
            vertical-align: top;
        }

        th {
            background: #f7f8fc;
        }

        .checkList {
            display: block;
            max-height: 300px;
            overflow-y: auto;
            border: 1px solid #dce2ee;
            border-radius: 7px;
            padding: 10px;
        }

            .checkList input {
                margin-right: 8px;
            }

            .checkList label {
                display: block;
                padding: 6px;
                font-weight: normal;
            }

        .backRow {
            margin-bottom: 14px;
        }

        .empty {
            color: #748099;
            padding: 10px;
        }

        @media(max-width: 760px) {
            .sidebar {
                position: static;
                width: 100%;
                height: auto;
            }

            .main {
                margin: 0;
                padding: 16px;
            }

            .top {
                align-items: flex-start;
            }

            .search {
                flex-wrap: wrap;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">

        <main class="main">
            <header class="top">
                <div>
                    <h1>Student groups</h1>
                    <p class="muted">Groups are organized by IT department and major.</p>
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
                        <asp:Button ID="addGroupButton" runat="server" Text="+ Add group" CssClass="btn" CausesValidation="false" OnClick="addGroupButton_Click" /></div>
                    <div class="search">
                        <asp:TextBox ID="searchTextBox" runat="server" placeholder="Type a search then press Search" /><asp:Button ID="searchButton" runat="server" Text="Search" CssClass="btn" CausesValidation="false" OnClick="searchButton_Click" /><a class="btn light" href="AssignSuper.aspx">Reset</a></div>
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
                <section class="card">
                    <h2>
                        <asp:Label ID="viewGroupNameLabel" runat="server" /></h2>
                    <p>Department:
                        <asp:Label ID="viewDepartmentLabel" runat="server" /></p>
                    <p>Academic supervisor:
                        <asp:Label ID="viewSupervisorLabel" runat="server" /></p><div class="field"><asp:Label runat="server" AssociatedControlID="ReplacementSupervisor" Text="Change academic supervisor" /><asp:DropDownList ID="ReplacementSupervisor" runat="server" /><asp:Button ID="ReassignSupervisor" runat="server" Text="Save supervisor assignment" CssClass="btn" OnClick="ReassignSupervisor_Click" /></div>
                    <h3>Students in this group</h3>
                    <asp:Literal ID="viewStudentsTable" runat="server" />
                    <hr />
                    <h3>Add students to this group</h3>
                    <div class="field">
                        <div class="checkList">
                            <asp:CheckBoxList ID="addStudentsCheckBoxList" runat="server" /></div>
                    </div>
                    <asp:Button ID="addStudentsButton" runat="server" Text="Add selected students" CssClass="btn" OnClick="addStudentsButton_Click" />
                </section>
            </asp:Panel>
        </main>
</asp:Content>

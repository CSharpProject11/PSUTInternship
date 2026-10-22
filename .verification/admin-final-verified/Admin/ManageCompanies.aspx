<%@ Page Title="Company Supervisors" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="ManageCompanies.aspx.cs" Inherits="PSUTInternship.Admin.ManageCompanies" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Company Supervisors - UIMS</title>
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

            .top h1, .top h2 {
                margin: 0 0 6px;
            }

        .muted {
            color: #748099;
            margin: 0;
        }

        .stats {
            display: flex;
            gap: 14px;
            margin-bottom: 18px;
            flex-wrap: wrap;
        }

        .stat, .card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 16px #263b6910;
        }

        .stat {
            flex: 1;
            min-width: 150px;
        }

            .stat strong {
                display: block;
                margin-top: 8px;
                color: #526bd4;
                font-size: 25px;
            }

        .card {
            margin-bottom: 18px;
        }

        .grid, .details {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
        }

        .field label {
            display: block;
            margin-bottom: 6px;
            font-weight: bold;
            font-size: 14px;
        }

        .field input {
            width: 100%;
            padding: 10px;
            border: 1px solid #dce2ee;
            border-radius: 7px;
        }

        .btn {
            border: 0;
            border-radius: 7px;
            padding: 10px 15px;
            margin: 12px 7px 0 0;
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

        .danger {
            background: #fde8e8;
            color: #a12626;
        }

        .backRow {
            display: flex;
            justify-content: flex-start;
            margin-bottom: 14px;
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

            .search .btn {
                margin: 0;
            }

        .tableWrap {
            overflow-x: auto;
        }

        table {
            width: 100%;
            min-width: 760px;
            border-collapse: collapse;
        }

        th, td {
            padding: 11px;
            border-bottom: 1px solid #edf0f6;
            text-align: left;
        }

        th {
            background: #f7f8fc;
        }

        .message {
            display: block;
            margin: 0 0 14px;
            color: #263b69;
        }

        .detail {
            padding: 12px;
            border-bottom: 1px solid #edf0f6;
        }

            .detail span {
                display: block;
                margin-top: 6px;
                color: #263b69;
                font-weight: bold;
                overflow-wrap: anywhere;
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

            .grid, .details {
                grid-template-columns: 1fr;
            }

            .top {
                align-items: flex-start;
            }

            .search {
                flex-wrap: wrap;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="sidebar">
            <h2>UIMS</h2>
            <a href="Dashboard.aspx">Dashboard</a>
            <a href="ManageStudents.aspx">Students</a>
            <a href="ManageAcademic.aspx">Academic Supervisors</a>
            <a href="ManageCompanies.aspx" class="active">Company Supervisors</a>
            <a href="AssignSuper.aspx">Assign Academic</a>
            <a href="../Login.aspx">Logout</a>
        </nav>
        <main class="main">
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
                        <asp:Button ID="addButton" runat="server" Text="Add company supervisor" CssClass="btn" CausesValidation="false" OnClick="addButton_Click" /></div>
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
                <section class="card">
                    <h2>Company supervisor details</h2>
                    <div class="details">
                        <div class="detail">Full name<span><asp:Label ID="viewNameLabel" runat="server" /></span></div>
                        <div class="detail">Email<span><asp:Label ID="viewEmailLabel" runat="server" /></span></div>
                        <div class="detail">Company<span><asp:Label ID="viewCompanyLabel" runat="server" /></span></div>
                        <div class="detail">Job title<span><asp:Label ID="viewJobTitleLabel" runat="server" /></span></div>
                        <div class="detail">Phone number<span><asp:Label ID="viewPhoneLabel" runat="server" /></span></div>
                        <div class="detail">Account status<span><asp:Label ID="viewStatusLabel" runat="server" /></span></div>
                    </div>
                </section>
            </asp:Panel>
        </main>
    </form>
</body>
</html>

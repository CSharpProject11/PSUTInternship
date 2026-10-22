<%@ Register Src="~/Shared/CompanyLinks.ascx" TagPrefix="psut" TagName="CompanyLinks" %>
<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="Tasks.aspx.cs" Inherits="PSUTInternship.Company.Tasks" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style>        
        .cards {
            display:flex;
            gap:10px;
            
        }
        #Box1Total{
            flex:1;
            border:1px solid black;
            border-radius:40px;
            padding:40px;
        }
        #Box2Pending{
            flex:1;
             border:1px solid black;
             border-radius:40px;
             padding:40px;
        }
        #Box3Progress{
            flex:1;
             border:1px solid black;
             border-radius:40px;
             padding:40px;
        }
        #Box4Reviewed{
            flex:1;
             border:1px solid black;
             border-radius:40px;
             padding:40px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
<psut:CompanyLinks runat="server" />
        <asp:Label ID="Manage" runat="server" Text="Manage &amp; Review Tasks"></asp:Label>
        <p>
            <a href="ReportsAndEvaluation.aspx">Reports &amp; Final Evaluation</a> |
            <a href="SupervisorAccount.aspx">Supervisor Account</a>
        </p>
        <div>
        </div>
        <p>
            <asp:Label ID="descrebtion" runat="server" Text="Create assignments, review submissions and guide your trainees."></asp:Label>
            <asp:Button ID="Create" runat="server" Text="Create New Task" OnClick="Create_Click" />
        </p>
        <p>
            &nbsp;
        </p>
        <div class="cards">
            <div id="Box1Total" runat="server">
                <p>Total Tasks</p>
                <p>
                    <asp:Label ID="countTotal" runat="server" Text="0"></asp:Label>
                </p>
                <p>Across your trainees</p>

            </div>
          
            <div id="Box2Pending" runat="server">
                <p>Pending Review</p>
                <p>
                    <asp:Label ID="countPending" runat="server" Text="0"></asp:Label>
                </p>
                <p>Awaiting your feedback</p>
            </div>
          
            <div id="Box3Progress" runat="server">
                <p>In Progress</p>
                <p>
                    <asp:Label ID="countProgress" runat="server" Text="0"></asp:Label>
                </p>
                <p>Currently being worked on</p>
            </div>
            
            <div id="Box4Reviewed" runat="server">
                <p>Reviewed</p>
                <p>
                    <asp:Label ID="countReviewed" runat="server" Text="0"></asp:Label>
                </p>
                <p>Reviewed or completed</p>
            </div>
        </div>

        <hr />
        <p>
            <asp:TextBox ID="search" runat="server" placeholder="Search task or student" AutoPostBack="true" OnTextChanged="search_TextChanged"></asp:TextBox>
            <asp:DropDownList AutoPostBack="true" ID="DropDownList1" runat="server" OnSelectedIndexChanged="DropDownList1_SelectedIndexChanged">
                <asp:ListItem>All statuses</asp:ListItem>
                <asp:ListItem>Pending Review</asp:ListItem>
                <asp:ListItem>In Progress</asp:ListItem>
                <asp:ListItem>Revision Requested</asp:ListItem>
                <asp:ListItem>Reviewed</asp:ListItem>
            </asp:DropDownList>
        </p>

        <table style="width: 100%;" border="1">
            <thead>
                <tr>
                    <th>Task</th>
                    <th>Student</th>
                    <th>Deadline</th>
                    <th>Priority</th>
                    <th>Status</th>
                    <th>Score</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="TaskTablebody" runat="server"></tbody>
        </table>
    </form>
</body>
</html>

<%@ Register Src="~/Shared/CompanyLinks.ascx" TagPrefix="psut" TagName="CompanyLinks" %>
<%@ Page MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="Tasks.aspx.cs" Inherits="PSUTInternship.Company.Tasks" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link rel="stylesheet" href="../Content/company-tasks.css?v=1" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="company-task-page"><h1>Tasks &amp; submissions</h1>
        <div>
        </div>
        <p>
            <asp:Label ID="descrebtion" runat="server" Text="Create assignments, review submissions and guide your trainees."></asp:Label>
        </p>
        <div class="stats portal-task-stats">
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

        <section class="panel">
            <div class="panel-heading">
                <h2>Tasks and submissions</h2>
                <asp:Button ID="Create" runat="server" Text="Create task" CssClass="btn" OnClick="Create_Click" />
            </div>
        <div class="task-filterbar"><label>Search tasks<asp:TextBox ID="search" runat="server" placeholder="Search task or student" AutoPostBack="true" OnTextChanged="search_TextChanged"></asp:TextBox>
</label><label>Status<asp:DropDownList AutoPostBack="true" ID="DropDownList1" runat="server" OnSelectedIndexChanged="DropDownList1_SelectedIndexChanged">
                <asp:ListItem>All statuses</asp:ListItem>
                <asp:ListItem Value="Submitted">Pending Review</asp:ListItem>
                <asp:ListItem Value="Pending">Pending</asp:ListItem><asp:ListItem Value="Assigned">In Progress</asp:ListItem>
                <asp:ListItem Value="Revision Requested">Resolve</asp:ListItem>
                <asp:ListItem Value="Reviewed">Complete</asp:ListItem>
            </asp:DropDownList></label></div>

        <div class="task-table-scroll"><table>
            <thead>
                <tr>
                    <th>Task</th>
                    <th>Student</th>
                    <th>Create Date</th><th>Due Date</th>
                    <th>Priority</th>
                    <th>Status</th>

                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="TaskTablebody" runat="server"></tbody>
        </table></div>
        </section>
</div><dialog id="taskReviewDialog" class="task-review-dialog"><button type="button" class="btn" onclick="this.closest('dialog').close()">Close review</button><iframe title="Review task" id="taskReviewFrame"></iframe></dialog>
<script>
document.addEventListener('click',function(event){var link=event.target.closest('[data-task-review]');if(!link)return;event.preventDefault();document.getElementById('taskReviewFrame').src=link.href;document.getElementById('taskReviewDialog').showModal();});
</script>
</asp:Content>

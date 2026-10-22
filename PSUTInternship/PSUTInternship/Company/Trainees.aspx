<%@ Import Namespace="System.Linq" %>
<%@ Page Title="My trainees" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="Trainees.aspx.cs" Inherits="PSUTInternship.Company.Trainees" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="../Content/Company.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<%= PageHeader("trainees", "My trainees", "Accepted students are listed immediately; active training starts when they confirm their offer.") %>
        <p>
            <input id="filter" placeholder="Search by name or keyword" oninput="filterRows()"/>
        </p>
        <section class="panel">
            <table id="trainees">
                <tr>
                    <th>Trainee</th>
                    <th>Internship</th>
                    <th>Tasks</th>
                    <th>Approved hours</th>
                    <th>Actions</th>
                </tr>
                <% foreach(var a in TraineeRows.Where(x => x.Status == "active")){ %>
                <tr>
                    <td>
                        <%= H(a.StudentName) %>
                    </td>
                    <td>
                        <%= H(a.OpportunityTitle) %>
                    </td>
                    <td>
                    <%= a.TasksCompleted %> / <%= a.TasksTotal %></td>
                    <td>
                    <%= a.ApprovedTrainingHours %> h</td>
                    <td>
                        <a href="Application.aspx?id=<%= H(a.ApplicationId) %>">View progress</a>
                    </td>
                </tr>
                <% } %>
                <% if(!TraineeRows.Any(x => x.Status == "active")) { %><tr><td colspan="5">No confirmed active trainees yet.</td></tr><% } %>
            </table>
        </section>
        <section class="panel" style="margin-top:24px"><h2>Accepted students awaiting confirmation</h2><div class="table-wrap"><table><thead><tr><th>Student</th><th>Opportunity</th><th>Status</th><th>Action</th></tr></thead><tbody>
        <% var awaiting = ApplicationRows.Where(x => x.Status == "Accepted" && !TraineeRows.Any(t => t.StudentId == x.StudentId && t.OpportunityId == x.OpportunityId)).ToList(); foreach (var app in awaiting) { %>
        <tr><td><%= H(app.Student) %></td><td><%= H(app.Opportunity) %></td><td>Accepted — awaiting student confirmation</td><td><a href="Application.aspx?id=<%= H(app.Id) %>">View application</a></td></tr><% } %>
        <% if(awaiting.Count == 0) { %><tr><td colspan="4">No accepted students awaiting confirmation.</td></tr><% } %></tbody></table></div></section>
        <section class="panel" style="margin-top:28px">
            <h2>Record history</h2>
            <p class="muted">Only confirmed placements appear as active trainees. Hours shown here come from Firebase and reflect approved records.</p>
        </section>
        <%= PageFooter() %>
        <script>function filterRows(){var q=document.getElementById('filter').value.toLowerCase();document.querySelectorAll('#trainees tr').forEach(function(r,i){if(i)r.style.display=r.innerText.toLowerCase().indexOf(q)>=0?'':'none';});}</script>
</asp:Content>

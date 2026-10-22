<%@ Import Namespace="System.Linq" %>
<%@ Page Title="My trainees" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="Trainees.aspx.cs" Inherits="PSUTInternship.Company.Trainees" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="../Content/Company.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<%= PageHeader("trainees", "My trainees", "Only confirmed placements appear as active trainees.") %>
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
            </table>
        </section>
        <section class="panel" style="margin-top:28px">
            <h2>Record history</h2>
            <p class="muted">Only confirmed placements appear as active trainees. Hours shown here come from Firebase and reflect approved records.</p>
        </section>
        <%= PageFooter() %>
        <script>function filterRows(){var q=document.getElementById('filter').value.toLowerCase();document.querySelectorAll('#trainees tr').forEach(function(r,i){if(i)r.style.display=r.innerText.toLowerCase().indexOf(q)>=0?'':'none';});}</script>
</asp:Content>

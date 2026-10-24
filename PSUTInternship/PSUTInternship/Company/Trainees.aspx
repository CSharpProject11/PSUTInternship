<%@ Import Namespace="System.Linq" %>
<%@ Page Title="My trainees" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="Trainees.aspx.cs" Inherits="PSUTInternship.Company.Trainees" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="../Content/Company.css" rel="stylesheet" />
<style>
body.portal-app .portal-content .company-trainees-page{max-width:1280px;margin:auto;color:#19394f}body.portal-app .portal-content .company-trainees-page h1{font-size:28px!important;letter-spacing:-.03em!important;margin-bottom:8px!important}.company-trainees-page :is(.subtitle,.header p,.page-header p){font-size:13px!important;font-weight:400!important;line-height:1.8;color:#607587}
.trainee-toolbar{display:flex;flex-direction:column;gap:8px;margin:24px 0 20px;padding:18px 20px;background:#fff;border:1px solid #dce6ed;border-radius:10px}.trainee-toolbar label{font-size:11px;color:#607587;font-weight:600}body.portal-app .portal-content .company-trainees-page #filter{width:min(100%,480px)!important;min-height:42px;font-size:13px!important;font-weight:400!important;padding:10px 12px!important;border:1px solid #cbd9e3!important;border-radius:6px!important;background:#fbfcfd!important}
body.portal-app .portal-content .company-trainees-page .panel{background:#fff!important;border:1px solid #dce6ed!important;border-radius:12px!important;padding:24px!important;margin:0 0 22px!important;box-shadow:none!important;min-width:0}.trainee-section-heading{display:flex;align-items:center;justify-content:space-between;gap:16px}.trainee-section-heading>span{font-size:11px;color:#536e82;padding:4px 9px;background:#edf4f8;border-radius:5px}body.portal-app .portal-content .company-trainees-page h2{font-size:18px!important;font-weight:650!important;letter-spacing:-.02em!important;margin:0 0 7px!important}.company-trainees-page .trainee-section-note{font-size:12px!important;font-weight:400!important;line-height:1.8;color:#607587;margin:0 0 20px!important}
.company-trainees-page .table-wrap{overflow-x:auto;border:1px solid #e1e9ef;border-radius:8px}body.portal-app .portal-content .company-trainees-page table{width:100%;min-width:600px;border-collapse:collapse;margin:0}body.portal-app .portal-content .company-trainees-page th{font-size:11px!important;font-weight:600!important;color:#607587!important;background:#f6f9fb!important;padding:12px 16px!important}body.portal-app .portal-content .company-trainees-page td{font-size:13px!important;font-weight:400!important;line-height:1.7!important;padding:17px 16px!important;border-color:#e6edf2!important;vertical-align:middle!important}.company-trainees-page td:first-child{color:#193b53;font-weight:600!important}.company-trainees-page td:last-child,.company-trainees-page th:last-child{text-align:right}.company-trainees-page tr[data-trainee]:hover{background:#f9fbfc}.company-trainees-page td[colspan]{text-align:center!important;padding:32px 16px!important;font-weight:400!important;color:#607587!important;font-size:13px!important}.company-trainees-page td a{display:inline-flex;padding:6px 11px;border:1px solid #cbd9e3;border-radius:6px;color:#345b76;font-size:11px;font-weight:600;text-decoration:none;white-space:nowrap}.company-trainees-page td a:hover{background:#edf5fa}.trainee-pending{display:inline-block;padding:4px 8px;background:#fff4dd;color:#7a602a;border-radius:5px;font-size:11px;font-weight:500}.company-trainees-page .trainee-footnote{font-size:11px!important;line-height:1.8!important;font-weight:400!important;color:#607587;margin:0 0 20px}.company-trainees-page :focus-visible{outline:3px solid #0078b5;outline-offset:3px}@media(max-width:600px){body.portal-app .portal-content .company-trainees-page .panel{padding:18px!important}.trainee-toolbar{padding:16px}.trainee-section-heading{align-items:flex-start}}
</style></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="company-trainees-page"><%= PageHeader("trainees", "My trainees", "Accepted students are listed immediately; active training starts when they confirm their offer.") %>
        <div class="trainee-toolbar"><label for="filter">Search trainees and accepted students</label><input type="search" id="filter" placeholder="Search by name or keyword" oninput="filterRows()"/>
        </div><section class="panel"><div class="trainee-section-heading"><h2>Active trainees</h2><span><%= TraineeRows.Count(x => x.Status == "active") %> active</span></div><p class="trainee-section-note">Confirmed placements and reviewed task progress.</p><div class="table-wrap">
            <table id="trainees">
                <tr>
                    <th>Trainee</th>
                    <th>Internship</th>
                    <th>Tasks</th>
                    <th>Approved hours</th>
                    <th>Actions</th>
                </tr>
                <% foreach(var a in TraineeRows.Where(x => x.Status == "active")){ %>
                <tr data-trainee>
                    <td>
                        <%= H(a.StudentName) %>
                    </td>
                    <td>
                        <%= H(a.OpportunityTitle) %>
                    </td>
                    <td>
                    <%= a.TasksCompleted %> / <%= a.TasksTotal %></td>
                    <td><%= a.ApprovedTrainingHours.ToString("0.##") %> hours</td>

                    <td>
                        <a href="Application.aspx?id=<%= H(a.ApplicationId) %>">View progress</a>
                    </td>
                </tr>
                <% } %>
                <% if(!TraineeRows.Any(x => x.Status == "active")) { %><tr><td colspan="5">No confirmed active trainees yet.</td></tr><% } %>
            </table></div></section>
        <section class="panel" style="margin-top:24px"><h2>Awaiting student confirmation</h2><p class="trainee-section-note">Accepted offers become active placements once the student confirms.</p><div class="table-wrap"><table><thead><tr><th>Student</th><th>Opportunity</th><th>Status</th><th>Approved hours</th><th>Action</th></tr></thead><tbody>
        <% var awaiting = ApplicationRows.Where(x => x.Status == "Accepted" && !TraineeRows.Any(t => t.StudentId == x.StudentId && t.OpportunityId == x.OpportunityId)).ToList(); foreach (var app in awaiting) { %>
        <tr data-trainee><td><%= H(app.Student) %></td><td><%= H(app.Opportunity) %></td><td><span class="trainee-pending">Awaiting confirmation</span></td><td>Not started</td><td><a href="Application.aspx?id=<%= H(app.Id) %>">View application</a></td></tr><% } %>
        <% if(awaiting.Count == 0) { %><tr><td colspan="5">No accepted students awaiting confirmation.</td></tr><% } %></tbody></table></div></section>
<p class="trainee-footnote">Only confirmed placements appear as active trainees. Task counts reflect active assignments and reviewed work.</p>
        </div><%= PageFooter() %>
<script>function filterRows(){var q=document.getElementById('filter').value.toLowerCase();document.querySelectorAll('.company-trainees-page tr[data-trainee]').forEach(function(r){r.hidden=!r.innerText.toLowerCase().includes(q);});}</script>
</asp:Content>
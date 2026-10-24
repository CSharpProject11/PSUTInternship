<%@ Import Namespace="System.Linq" %>
<%@ Page Title="Review applications" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="Applications.aspx.cs" Inherits="PSUTInternship.Company.Applications" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="../Content/Company.css" rel="stylesheet" />
<style>
body.portal-app .portal-content .company-applications-page{max-width:1280px;margin:auto;color:#19394f}body.portal-app .portal-content .company-applications-page h1{font-size:28px!important;font-weight:700!important;letter-spacing:-.03em!important;margin-bottom:8px!important}.company-applications-page :is(.header p,.page-header p,.subtitle){font-size:13px!important;font-weight:400!important;line-height:1.8;color:#607587}
.applications-inbox{margin-top:26px;background:#fff;border:1px solid #dce6ed;border-radius:12px;overflow:hidden}.applications-toolbar{display:flex;gap:18px;align-items:flex-end;padding:22px 24px;border-bottom:1px solid #e3ebf1;background:#fff}.applications-toolbar label{display:flex;flex-direction:column;gap:8px;font-size:11px;font-weight:600;color:#607587;min-width:0}.applications-toolbar label:first-child{flex:1;max-width:480px}.applications-toolbar label:nth-child(2){width:200px}body.portal-app .portal-content .applications-toolbar :is(input,select){width:100%!important;background:#fbfcfd!important;min-height:42px!important;font-size:13px!important;font-weight:400!important;padding:10px 12px!important;border:1px solid #cbd9e3!important;border-radius:6px!important}.applications-count{margin-left:auto;font-size:11px;color:#607587;padding-bottom:12px;white-space:nowrap}.applications-table{overflow-x:auto}body.portal-app .portal-content .company-applications-page table{width:100%;min-width:640px;border-collapse:collapse;margin:0}body.portal-app .portal-content .company-applications-page th{background:#f6f9fb!important;font-size:11px!important;font-weight:600!important;padding:13px 24px!important;color:#607587!important}body.portal-app .portal-content .company-applications-page td{font-size:13px!important;font-weight:400!important;line-height:1.7!important;padding:19px 24px!important;border-color:#e6edf2!important;vertical-align:middle!important}body.portal-app .portal-content .company-applications-page td:first-child{font-weight:600!important;color:#193b53}.company-applications-page td:nth-child(3){font-variant-numeric:tabular-nums;color:#607587}.company-applications-page td:last-child,.company-applications-page th:last-child{text-align:right;white-space:nowrap}.company-applications-page tr[data-status]:hover{background:#f8fbfd}.company-applications-page td a{display:inline-flex;align-items:center;justify-content:center;padding:6px 12px;border:1px solid #cbd9e3;border-radius:6px;font-size:11px;font-weight:600;text-decoration:none!important;color:#345b76}.company-applications-page td a:hover{background:#edf5fa;border-color:#8bb3cc}
body.portal-app .portal-content .company-applications-page .badge{background:#fff4dc!important;color:#7a5c20!important;font-size:11px!important;font-weight:500!important;border-radius:5px!important;padding:4px 9px!important}body.portal-app .portal-content .company-applications-page tr[data-status=Accepted] .badge{background:#eaf5ee!important;color:#286245!important}body.portal-app .portal-content .company-applications-page tr[data-status=Rejected] .badge{background:#faeeec!important;color:#974a40!important}.applications-help{padding:16px 24px;background:#f7f9fb;font-size:11px;color:#607587;border-top:1px solid #e3ebf1;line-height:1.8}.company-applications-page #applicationEmpty{font-size:13px;font-weight:400;color:#607587;padding:32px 24px;text-align:center}.company-applications-page :focus-visible{outline:3px solid #0078b5;outline-offset:3px}
@media(max-width:650px){.applications-toolbar{flex-wrap:wrap;padding:18px;gap:14px}.applications-toolbar label:first-child{flex-basis:100%;max-width:none}.applications-toolbar label:nth-child(2){flex:1}.applications-count{padding-bottom:12px}.applications-help{padding:14px 18px}}
</style></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="company-applications-page"><%= PageHeader("applications", "Review applications", "Review each student's application and record a clear decision.") %>
        <section class="applications-inbox"><div class="applications-toolbar"><label>Search applications<input type="search" id="filter" placeholder="Search by name or keyword" oninput="filterRows()"/></label><label>Application status<select id="status" onchange="filterRows()">
                <option value="">All statuses</option>
                <option>Pending</option>
                <option>Accepted</option>
                <option>Rejected</option>
            </select></label><span class="applications-count" role="status" aria-live="polite"><span id="applicationCount"><%= ApplicationRows.Count() %></span> applications</span></div>
        <div class="applications-table">
            <table id="applications">
                <tr>
                    <th>Applicant</th>
                    <th>Opportunity</th>
                    <th>Applied</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                <% foreach (var a in ApplicationRows) { %>
                <tr data-status="<%= H(a.Status) %>">
                    <td>
                        <%= H(a.Student) %>
                    </td>
                    <td>
                        <%= H(a.Opportunity) %>
                    </td>
                    <td>
                        <%= H(a.Applied) %>
                    </td>
                    <td>
                        <span class="badge <%= a.Status=="Accepted" ? "ok" : "" %>">
                            <%= H(a.Status) %>
                        </span>
                    </td>
                    <td>
                        <a href="Application.aspx?id=<%= H(a.Id) %>">
                            <%= a.Status=="Pending" ? "Review" : "View decision" %>
                        </a>
                    </td>
                </tr>
                <% } %>
            </table>
        </div><p id="applicationEmpty" hidden>No applications match your search.</p><footer class="applications-help">Select Review to inspect an application, or View decision for a previous outcome.</footer></section></div>
        <%= PageFooter() %>
        <script>function filterRows(){var q=document.getElementById('filter').value.toLowerCase(),s=document.getElementById('status').value;document.querySelectorAll('#applications tr[data-status]').forEach(function(r){r.style.display=(r.innerText.toLowerCase().indexOf(q)>=0&&(!s||r.dataset.status===s))?'':'none';});var count=Array.from(document.querySelectorAll("#applications tr[data-status]")).filter(function(r){return r.style.display!=="none";}).length;document.getElementById("applicationCount").textContent=count;document.getElementById("applicationEmpty").hidden=count!==0;}filterRows();</script>
</asp:Content>

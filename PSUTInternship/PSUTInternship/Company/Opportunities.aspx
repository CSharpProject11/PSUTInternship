<%@ Page Title="Manage opportunities" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="Opportunities.aspx.cs" Inherits="PSUTInternship.Company.Opportunities" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="../Content/Company.css" rel="stylesheet" />
<style>
body.portal-app .portal-content .company-opportunity-page{max-width:1280px;margin:auto;color:#19394f}
body.portal-app .portal-content .company-opportunity-page h1{font-size:28px!important;letter-spacing:-.03em!important;margin:0 0 8px!important}body.portal-app .portal-content .company-opportunity-page :is(.subtitle,.header p,.page-header p){font-size:13px!important;font-weight:400!important;line-height:1.8;color:#607587}
body.portal-app .portal-content .company-opportunity-page .panel{background:#fff!important;border:1px solid #dce6ed!important;border-radius:12px!important;box-shadow:none!important;padding:24px!important;margin-top:24px!important}
body.portal-app .portal-content .company-opportunity-page .panel-heading{display:flex;justify-content:space-between;align-items:center;gap:20px;margin-bottom:24px!important}body.portal-app .portal-content .company-opportunity-page h2{font-size:18px!important;font-weight:650!important;letter-spacing:-.02em!important;margin:0!important}
body.portal-app .portal-content .company-opportunity-page .btn{font-size:12px!important;font-weight:600!important;line-height:1.5!important;min-height:40px!important;padding:10px 16px!important;border-radius:6px!important;background:#003e73!important;color:#fff!important;border:1px solid #003e73!important;box-shadow:none!important}
body.portal-app .portal-content .company-opportunity-page .btn.light{min-height:32px!important;padding:6px 12px!important;background:#fff!important;border-color:#cbd9e3!important;color:#345b76!important;font-size:11px!important;margin:0 6px 0 0!important}
body.portal-app .portal-content .company-opportunity-page .opportunity-search{display:flex;flex-direction:column;align-items:flex-start;gap:7px;padding:16px;background:#f4f7fa;border-radius:8px;margin:0 0 22px!important}.opportunity-search label{font-size:11px;font-weight:600;color:#607587}
body.portal-app .portal-content .company-opportunity-page #filter{width:min(100%,480px)!important;min-height:42px!important;border:1px solid #cbd9e3!important;border-radius:6px!important;background:white!important;font-size:13px!important;font-weight:400!important;padding:10px 12px!important}
.company-opportunity-page .opportunity-table{overflow-x:auto;border:1px solid #e0e8ee;border-radius:8px}body.portal-app .portal-content .company-opportunity-page table{margin:0;width:100%;min-width:640px;border-collapse:collapse}body.portal-app .portal-content .company-opportunity-page th{font-size:11px!important;font-weight:600!important;background:#f6f9fb!important;color:#607587!important;padding:12px 16px!important}body.portal-app .portal-content .company-opportunity-page td{font-size:13px!important;font-weight:400!important;padding:17px 16px!important;line-height:1.7;border-color:#e5ecf1!important;vertical-align:middle!important}body.portal-app .portal-content .company-opportunity-page td:first-child{font-weight:650!important;color:#193b53}.company-opportunity-page th:nth-child(3),.company-opportunity-page td:nth-child(3){text-align:right;font-variant-numeric:tabular-nums}.company-opportunity-page td:last-child,.company-opportunity-page th:last-child{text-align:right;white-space:nowrap}.company-opportunity-page tr:last-child td{border-bottom:0!important}.company-opportunity-page tr:hover td{background:#f9fbfc}.opportunity-state{display:inline-block;font-size:11px;font-weight:600;padding:3px 9px;border-radius:5px}.opportunity-state.is-open{color:#286245;background:#eaf5ee}.opportunity-state.is-closed{color:#637484;background:#edf1f4}.opportunity-no-results{font-size:13px!important;font-weight:400!important;color:#607587;text-align:center;padding:24px}.company-opportunity-page :focus-visible{outline:3px solid #0078b5;outline-offset:3px}
@media(max-width:600px){body.portal-app .portal-content .company-opportunity-page .panel{padding:18px!important}.company-opportunity-page .panel-heading{flex-wrap:wrap;align-items:flex-start!important}body.portal-app .portal-content .company-opportunity-page h1{font-size:24px!important}}
</style></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="company-opportunity-page"><%= PageHeader("opportunities", "Manage opportunities", "Create, update, and close your internship opportunities.") %>
        <section class="panel">
            <div class="panel-heading">
                <h2>Internship opportunities</h2>
                <a class="btn" href="OpportunityForm.aspx">Create opportunity</a>
            </div>
            <div class="btn-row opportunity-search"><label for="filter">Search opportunities</label>
                <input id="filter" type="search" placeholder="Search by name or keyword" oninput="filterRows()"/>
            </div>
            <div class="opportunity-table"><table id="opportunities">
                <tr>
                    <th>Opportunity</th>
                    <th>Specialization</th>
                    <th>Seats</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                <% foreach (var o in OpportunityRows) { %>
                <tr>
                    <td>
                        <%= H(o.Title) %>
                    </td>
                    <td>
                        <%= H(o.Specialization) %>
                    </td>
                    <td>
                        <%= o.Seats %>
                    </td>
                    <td>
                        <span class="opportunity-state <%= o.IsOpen ? "is-open" : "is-closed" %>"><%= o.IsOpen ? "Open" : "Closed" %></span>
                    </td>
                    <td>
                        <a class="btn light" href="OpportunityForm.aspx?id=<%= H(o.Id) %>">Edit</a>  <% if(o.IsOpen){ %>

                            <button class="btn light" type="submit" name="closeOpportunity" value="<%= H(o.Id) %>">Close</button>

                        <% } else { %>
                        <span class="muted">Closed</span>
                        <% } %>
                    </td>
                </tr>
                <% } %>
            </table></div><p id="opportunityNoResults" class="opportunity-no-results" hidden>No opportunities match your search.</p>
        </section>
        </div><%= PageFooter() %>
        <script>function filterRows(){var q=document.getElementById('filter').value.toLowerCase();var rows=document.querySelectorAll('#opportunities tr');for(var i=1;i<rows.length;i++){rows[i].style.display=rows[i].innerText.toLowerCase().indexOf(q)>=0?'':'none';}}</script>
</asp:Content>

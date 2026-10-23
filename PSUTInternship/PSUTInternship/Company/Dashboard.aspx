<%@ Import Namespace="System.Linq" %>
<%@ Page Title="Company dashboard" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="PSUTInternship.Company.Dashboard" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="../Content/Company.css" rel="stylesheet" />
<style>
body.portal-app .portal-content .company-home{--ch-line:#dce6ed;--ch-muted:#607587;max-width:1280px;margin:auto;color:#19394f}
body.portal-app .portal-content .company-home .cards{display:grid!important;grid-template-columns:repeat(4,minmax(0,1fr));gap:0!important;border:1px solid var(--ch-line);border-radius:12px;overflow:hidden;margin:24px 0!important;background:white}
body.portal-app .portal-content .company-home .cards>.card,body.portal-app .portal-content .company-home .cards>.card:first-child{background:#fff!important;color:#536e82!important;border:0!important;border-right:1px solid var(--ch-line)!important;border-radius:0!important;box-shadow:none!important;padding:20px 22px!important;margin:0!important;font-size:12px;font-weight:500;min-height:0!important}
body.portal-app .portal-content .company-home .cards>.card:last-child{border-right:0!important}body.portal-app .portal-content .company-home .cards>.card .metric{font-size:30px!important;font-weight:600!important;line-height:1.3!important;letter-spacing:-.03em;margin:10px 0 7px!important;color:#19394f!important}body.portal-app .portal-content .company-home .cards>.card .muted{font-size:11px!important;font-weight:400!important;color:#607587!important;line-height:1.7!important}
body.portal-app .portal-content .company-home .portal-company-overview{display:grid!important;grid-template-columns:minmax(0,1.7fr) minmax(280px,1fr);gap:20px!important;align-items:start}
body.portal-app .portal-content .company-home .panel{background:#fff!important;border:1px solid var(--ch-line)!important;border-radius:12px!important;box-shadow:none!important;padding:24px!important;margin:0!important;min-width:0;overflow:auto}
body.portal-app .portal-content .company-home .panel:first-child{grid-row:span 2}
body.portal-app .portal-content .company-home h1{font-size:28px!important;letter-spacing:-.03em!important;margin-bottom:8px!important}body.portal-app .portal-content .company-home h2{font-size:17px!important;letter-spacing:-.02em;margin-bottom:18px!important}
body.portal-app .portal-content .company-home p{font-size:13px!important;font-weight:400!important;line-height:1.8!important;color:#536e82;margin:12px 0}body.portal-app .portal-content .company-home .muted{font-size:12px!important;font-weight:400!important;color:#607587!important}body.portal-app .portal-content .company-home .detail-title{font-size:21px!important;color:#003e73;font-weight:600!important;margin:0 0 10px!important}
body.portal-app .portal-content .company-home table{min-width:480px;border-collapse:collapse;width:100%;margin:0}body.portal-app .portal-content .company-home th{font-size:11px!important;font-weight:600!important;color:#607587!important;background:#f5f8fa!important;padding:12px!important}body.portal-app .portal-content .company-home td{font-size:13px!important;font-weight:400!important;line-height:1.7;padding:16px 12px!important;border-color:#e5ecf1!important}body.portal-app .portal-content .company-home td:first-child{font-weight:600!important}body.portal-app .portal-content .company-home .badge{font-size:11px!important;border-radius:5px;background:#fff3d9;color:#815f19;padding:4px 8px;font-weight:500}
body.portal-app .portal-content .company-home .panel a{color:#003e73;font-size:12px;font-weight:600;text-underline-offset:4px}body.portal-app .portal-content .company-home .panel a:hover{text-decoration:underline}body.portal-app .portal-content .company-home .btn{font-size:12px!important;font-weight:600!important;padding:10px 16px!important;border-radius:6px!important;background:#003e73!important;color:white!important;min-height:40px}body.portal-app .portal-content .company-home .company-queue-empty{text-align:center;padding:36px 12px!important;color:#607587;font-weight:400!important}.company-home :focus-visible{outline:3px solid #0078b5;outline-offset:3px}
@media(max-width:950px){body.portal-app .portal-content .company-home .cards{grid-template-columns:repeat(2,minmax(0,1fr))}body.portal-app .portal-content .company-home .portal-company-overview{grid-template-columns:minmax(0,1fr)}body.portal-app .portal-content .company-home .panel:first-child{grid-row:auto}}@media(max-width:550px){body.portal-app .portal-content .company-home .cards>.card{padding:16px!important}body.portal-app .portal-content .company-home .panel{padding:18px!important}}
</style></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="company-home"><%= PageHeader("dashboard", "Company dashboard", "Your internship workspace, with the next action always in view.") %>
            <div class="cards">
                <div class="card">Active trainees<div class="metric">
                        <%= ActiveTrainees %>
                    </div>
                    <span class="muted">Confirmed placements</span>
                </div>
                <div class="card">New applications<div class="metric">
                        <%= PendingApplications %>
                    </div>
                    <span class="muted">Awaiting your decision</span>
                </div>
                <div class="card">Submissions to review<div class="metric"><%= PendingSubmissions %></div>
                    <span class="muted">Awaiting your feedback</span>
                </div>
                <div class="card">Open opportunities<div class="metric">
                        <%= OpenOpportunities %>
                    </div>
                    <span class="muted">Currently accepting applicants</span>
                </div>
            </div>
            <div class="grid portal-company-overview">
                <section class="panel">
                    <h2>Your review queue</h2>
                    <table>
                        <tr>
                            <th>Applicant</th>
                            <th>Opportunity</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                        <% foreach (var a in ApplicationRows.Where(x=>x.Status=="Pending")) { %>
                        <tr>
                            <td>
                                <%= H(a.Student) %>
                            </td>
                            <td>
                                <%= H(a.Opportunity) %>
                            </td>
                            <td>
                                <span class="badge">
                                    <%= H(a.Status) %>
                                </span>
                            </td>
                            <td>
                                <a href="Application.aspx?id=<%= H(a.Id) %>">Review</a>
                            </td>
                        </tr>
                        <% } %>
                    <% if (!ApplicationRows.Any(x => x.Status == "Pending")) { %><tr><td colspan="4" class="company-queue-empty">No applications are waiting for review.</td></tr><% } %></table>
                    <p>
                        <a href="Applications.aspx">View all applications</a>
                    </p>
                </section>
                <section class="panel">
                    <h2>Your company</h2>
                    <p class="detail-title"><%: CompanyProfile.CompanyName %></p>
                    <p class="muted">Manage your trainees and the work they submit.</p>
                    <p><a href="Tasks.aspx">Review submitted work</a></p>
                </section>
                <section class="panel">
                    <h2>Training &amp; evaluations</h2>
                    <p class="muted">Review submitted work and send final company evaluations to the academic supervisor.</p><p><a href="Trainees.aspx">View trainees</a></p><p><a href="ReportsAndEvaluation.aspx">Open final evaluations</a></p>
                </section>
                <section class="panel">
                    <h2>Quick actions</h2>
                    <p>
                        <a class="btn" href="OpportunityForm.aspx">+ Create opportunity</a>
                    </p>

                </section>
            </div>
            </div><%= PageFooter() %>
</asp:Content>

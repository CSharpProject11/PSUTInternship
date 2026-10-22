
<%@ Import Namespace="System.Linq" %>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="PSUTInternship.Company.Dashboard" %>
<!DOCTYPE html>
<html>
    <head runat="server">
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Company dashboard</title>
        <link href="../Content/Company.css" rel="stylesheet" />
    </head>
    <body>
        <form id="form1" runat="server">
            <%= PageHeader("dashboard", "Company dashboard", "Your internship workspace, with the next action always in view.") %>
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
                    <span class="muted">Due this week</span>
                </div>
                <div class="card">Open opportunities<div class="metric">
                        <%= OpenOpportunities %>
                    </div>
                    <span class="muted">With seats available</span>
                </div>
            </div>
            <div class="grid">
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
                    </table>
                    <p>
                        <a href="Applications.aspx">View all applications</a>
                    </p>
                </section>
                <section class="panel">
                    <h2>Workspace context</h2>
                    <p class="detail-title">Ofuq Technology</p>
                    <p class="muted">Tasks, applications and hours<br/>Review each decision thoughtfully.</p>
                    <span class="badge ok">Role access enabled</span>
                </section>
                <section class="panel">
                    <h2>Important follow-ups</h2>
                    <p class="muted">Training hours need review. Task completion does not approve hours. Final company evaluation is sent to the academic supervisor.</p>
                </section>
                <section class="panel">
                    <h2>Quick actions</h2>
                    <p>
                        <a class="btn" href="OpportunityForm.aspx">Create opportunity</a>
                    </p>
                    <a href="Trainees.aspx">Open training hours</a>
                </section>
            </div>
            <%= PageFooter() %>
        </form>
    </body>
</html>



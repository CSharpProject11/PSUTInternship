<%@ Import Namespace="System.Linq" %>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Applications.aspx.cs" Inherits="PSUTInternship.Company.Applications" %>
<!DOCTYPE html>
<html>
    <head runat="server">
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Review applications</title>
        <link href="../Content/Company.css" rel="stylesheet" />
    </head>
    <body>
        <%= PageHeader("applications", "Review applications", "Review each student's application and record a clear decision.") %>
        <p>
            <input id="filter" placeholder="Search by name or keyword" oninput="filterRows()"/> &nbsp; <select id="status" onchange="filterRows()">
                <option value="">All statuses</option>
                <option>Pending</option>
                <option>Accepted</option>
                <option>Rejected</option>
            </select>
        </p>
        <section class="panel">
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
        </section>
        <section class="panel" style="margin-top:28px">
            <h2>Record history</h2>
            <p class="muted">Select an application to inspect details and the available next action.</p>
        </section>
        <%= PageFooter() %>
        <script>function filterRows(){var q=document.getElementById('filter').value.toLowerCase(),s=document.getElementById('status').value;document.querySelectorAll('#applications tr[data-status]').forEach(function(r){r.style.display=(r.innerText.toLowerCase().indexOf(q)>=0&&(!s||r.dataset.status===s))?'':'none';});}</script>
    </body>
</html>


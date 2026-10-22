<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Opportunities.aspx.cs" Inherits="PSUTInternship.Company.Opportunities" %>
<!DOCTYPE html>
<html>
    <head runat="server">
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Manage opportunities</title>
        <link href="../Content/Company.css" rel="stylesheet" />
    </head>
    <body>
        <%= PageHeader("opportunities", "Manage opportunities", "Create, update, and close your internship opportunities.") %>
        <div class="btn-row">
            <input id="filter" placeholder="Search by name or keyword" oninput="filterRows()"/>
            <a class="btn" href="OpportunityForm.aspx">Create opportunity</a>
        </div>
        <section class="panel">
            <table id="opportunities">
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
                        <%= o.IsOpen ? "Open" : "Closed" %>
                    </td>
                    <td>
                        <a href="OpportunityForm.aspx?id=<%= H(o.Id) %>">Edit</a> &nbsp; <% if(o.IsOpen){ %>
                        <form method="post" style="display:inline">
                            <input type="hidden" name="action" value="close"/>
                            <input type="hidden" name="id" value="<%= H(o.Id) %>"/>
                            <button class="link-button" type="submit">Close</button>
                        </form>
                        <% } else { %>
                        <span class="muted">Closed</span>
                        <% } %>
                    </td>
                </tr>
                <% } %>
            </table>
        </section>
        <%= PageFooter() %>
        <script>function filterRows(){var q=document.getElementById('filter').value.toLowerCase();var rows=document.querySelectorAll('#opportunities tr');for(var i=1;i<rows.length;i++){rows[i].style.display=rows[i].innerText.toLowerCase().indexOf(q)>=0?'':'none';}}</script>
        </body>
    </html>


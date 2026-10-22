<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RejectApplication.aspx.cs" Inherits="PSUTInternship.Company.RejectApplication" %>
<!DOCTYPE html>
<html>
    <head runat="server">
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Reject application</title>
        <link href="../Content/Company.css" rel="stylesheet" />
    </head>
    <body>
        <%= PageHeader("applications", "Reject application", "A reason is required. The applicant can read this decision in their application history.") %>
<% if (StudentApplication == null) { %>
        <section class="panel"><h2>Application not found</h2><p class="muted">This application may have been removed or the link is missing its ID.</p><a href="Applications.aspx">Back to applications</a></section>
<% } else { %>
        <div class="form-layout">
            <section class="form-card">
                <h2>Details</h2>
                <form method="post">
                    <label>Applicant and opportunity</label>
                    <input readonly value="<%= H(StudentApplication.Student) %> / <%= H(StudentApplication.Opportunity) %>"/>
                    <label>Rejection reason</label>
                    <textarea name="reason" required placeholder="Enter the reason clearly"></textarea>
                    <% if(ErrorMessage.Length>0){ %>
                    <div class="notice">
                        <%= H(ErrorMessage) %>
                    </div>
                    <% } %>
                    <button class="btn" type="submit">Reject and notify applicant</button>
                </form>
            </section>
            <aside class="side-note">
                <h2>Before you save</h2>
                <p class="muted">Add a short, respectful reason. The decision is part of the application history.</p>
            </aside>
        </div>

        <% } %>
        <%= PageFooter() %>
    </body>
</html>



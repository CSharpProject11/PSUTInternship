<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Application.aspx.cs" Inherits="PSUTInternship.Company.Application" %>
<!DOCTYPE html>
<html>
    <head runat="server">
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Review application</title>
        <link href="../Content/Company.css" rel="stylesheet" />
    </head>
    <body>
        <%= PageHeader("applications", "Review application", "Review the student's information before deciding.") %>
<% if (StudentApplication == null) { %>
        <section class="panel"><h2>Application not found</h2><p class="muted">This application may have been removed or the link is missing its ID.</p><a href="Applications.aspx">Back to applications</a></section>
<% } else { %>
        <div class="form-layout">
            <section class="panel info-list">
                <h2 class="detail-title">
                    <%= H(StudentApplication.Student) %>
                </h2>
                <h3>University-controlled academic record</h3>
                <p>
                    <b>College:</b> <%= H(StudentApplication.College) %>
                    <br/>
                    <b>Skills:</b> <%= H(StudentApplication.Skills) %>
                    <br/>
                    <b>CV:</b> <a target="_blank" rel="noopener" href="<%= H(StudentApplication.Cv) %>">Open CV / portfolio</a>
                </p>
                <h3>Application message</h3>
                <p>
                    <%= H(StudentApplication.Message) %>
                </p>
            </section>
            <aside class="panel">
                <h2>Application decision</h2>
                <p>
                    <span class="badge">
                        <%= H(StudentApplication.Status) %>
                    </span>
                </p>
                <% if(StudentApplication.Status=="Pending"){ %>
                <form method="post">
                    <button class="btn" name="action" value="accept" type="submit">Accept application</button>
                </form>
                <p>
                    <a class="btn outline" href="RejectApplication.aspx?id=<%= H(StudentApplication.Id) %>">Reject with reason</a>
                </p>
                <% } else if(StudentApplication.Status=="Rejected"){ %>
                <p>
                    <b>Reason:</b> <%= H(StudentApplication.RejectionReason) %>
                </p>
                <% } else if (StudentApplication.Status == "Accepted" && !StudentApplication.StudentConfirmed) { %>
                <p class="muted">After the student confirms the offer to you, mark the placement confirmed here.</p>
                <form method="post">
                    <button class="btn" name="action" value="confirm" type="submit">Student confirmed — activate trainee</button>
                </form>
                <% } else if (StudentApplication.StudentConfirmed) { %>
                <p class="badge ok">Placement confirmed; trainee is active.</p>
                <% } %>
                <p>
                    <a href="Applications.aspx">Back to applications</a>
                </p>
            </aside>
        </div>

        <% } %>
        <%= PageFooter() %>
    </body>
</html>



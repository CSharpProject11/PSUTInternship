<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OpportunityForm.aspx.cs" Inherits="PSUTInternship.Company.OpportunityForm" %>
<!DOCTYPE html>
<html>
    <head runat="server">
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title><%= IsEdit ? "Edit" : "Create" %> opportunity</title>
        <link href="../Content/Company.css" rel="stylesheet" />
    </head>
    <body>
        <%= PageHeader("opportunities", IsEdit ? "Edit internship opportunity" : "Create internship opportunity", "Opportunities are shown to students with eligible majors.") %>
        <div class="form-layout">
            <section class="form-card">
                <h2>Details</h2>
                <form method="post">
                    <label>Opportunity title</label>
                    <input name="title" required value="<%= Opportunity == null ? "" : H(Opportunity.Title) %>"/>
                    <label>Specialization</label>
                    <input name="specialization" required value="<%= Opportunity == null ? "" : H(Opportunity.Specialization) %>"/>
                    <label>Description</label>
                    <textarea name="description" required><%= Opportunity == null ? "" : H(Opportunity.Description) %></textarea>
                    <label>Requirements</label>
                    <textarea name="requirements"><%= Opportunity == null ? "" : H(Opportunity.Requirements) %></textarea>
                    <label>Available seats</label>
                    <input type="number" min="0" name="seats" required value="<%= Opportunity == null ? "1" : Opportunity.Seats.ToString() %>"/>
                    <label>Application deadline</label>
                    <input name="deadline" placeholder="e.g. 30 Oct 2026" required value="<%= Opportunity == null ? "" : H(Opportunity.Deadline) %>"/>
                    <p>
                        <button class="btn" type="submit">
                            <%= IsEdit ? "Save changes" : "Publish opportunity" %>
                        </button>
                    </p>
                </form>
            </section>
            <aside class="side-note">
                <h2>Before you save</h2>
                <p class="muted">Check the required information. Changes follow your role permissions. A history is kept when applicable.</p>
                <a href="Account.aspx">Need help? Contact the coordinator.</a>
            </aside>
        </div>
        <%= PageFooter() %>
    </body>
</html>


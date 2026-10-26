<%@ Page Title="<%= IsEdit ? &quot;Edit&quot; : &quot;Create&quot; %> opportunity" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="OpportunityForm.aspx.cs" Inherits="PSUTInternship.Company.OpportunityForm" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="../Content/Company.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<%= PageHeader("opportunities", IsEdit ? "Edit internship opportunity" : "Create internship opportunity", "Publish an opportunity for students to explore.") %>
        <div class="form-layout">
            <section class="form-card">
                <h2>Details</h2>
                <input type="hidden" name="csrfToken" value="<%= CsrfToken %>"/>
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
                    <input type="date" name="deadline" required value="<%= Opportunity == null ? "" : H(Opportunity.Deadline) %>"/>
                    <p><a class="btn secondary" href="Opportunities.aspx">Close</a>
                        <button class="btn" type="submit">
                            <%= IsEdit ? "Save changes" : "Publish opportunity" %>
                        </button>
                    </p>

            </section>
            <aside class="side-note">
                <h2>Before you save</h2>
                <p class="muted">Check the required information. Changes follow your role permissions. A history is kept when applicable.</p>
                <a href="Account.aspx">Need help? Contact the coordinator.</a>
            </aside>
        </div>
        <%= PageFooter() %>
</asp:Content>

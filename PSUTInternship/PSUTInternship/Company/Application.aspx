<%@ Page Title="Review application" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="Application.aspx.cs" Inherits="PSUTInternship.Company.Application" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="../Content/Company.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
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
                <input type="hidden" name="csrfToken" value="<%= CsrfToken %>"/>
                    <button class="btn" name="action" value="accept" type="submit">Accept application</button>

                <p>
                    <a class="btn outline" href="RejectApplication.aspx?id=<%= H(StudentApplication.Id) %>">Reject with reason</a>
                </p>
                <% } else if(StudentApplication.Status=="Rejected"){ %>
                <p>
                    <b>Reason:</b> <%= H(StudentApplication.RejectionReason) %>
                </p>
                <% } else if (StudentApplication.Status == "Accepted" && !StudentApplication.StudentConfirmed) { %>
                <p>The student can confirm this offer in My Applications.</p>
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
</asp:Content>

<%@ Page Title="My applications · PSUT Internship Portal" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="MyApplications.aspx.cs" Inherits="PSUTInternship.Student.MyApplications" %>
<%@ Register Src="~/Shared/StudentNav.ascx" TagPrefix="psut" TagName="StudentNav" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">

    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/student-workspace.css") %>" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="student-shell">

        <main id="student-main" class="student-main" tabindex="-1">
            <div class="student-heading"><div><h1>My applications.</h1><p>Track each decision and respond when an offer arrives. You can confirm only one internship offer.</p></div><a class="sd-button sd-heading-action" href="Opportunities.aspx">Explore opportunities</a></div>
            <asp:Label ID="MessageLabel" runat="server" CssClass="sd-status" role="status" />
            <div class="sd-applications">
                <asp:Repeater ID="ApplicationsRepeater" runat="server" OnItemCommand="ApplicationsRepeater_ItemCommand">
                    <ItemTemplate>
                        <article class="sd-card sd-application">
                            <div><h2><%#: Eval("Details.OrganizationName") %></h2><p>Training field: <%#: Eval("Details.TrainingField") %></p><p>Status: <strong><%#: GetApplicationStatus(Container.DataItem) %></strong></p></div>
                            <p><%#: Eval("RejectionReason") %></p><div class="sd-application-actions">
                                <asp:Button ID="AcceptButton" runat="server" Text="Accept offer" CommandName="AcceptOffer" CommandArgument='<%# Eval("Id") %>' OnClientClick="return portalConfirmAction(this, 'Confirm this internship? You can confirm only one offer.');" Visible='<%# CanAcceptOffer(Container.DataItem) %>' />
                                <asp:Button ID="DeclineButton" runat="server" Text="Decline offer" CommandName="DeclineOffer" CommandArgument='<%# Eval("Id") %>' OnClientClick="return portalConfirmAction(this, 'Decline this internship offer?');" Visible='<%# CanDeclineOffer(Container.DataItem) %>' />
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </main>
    </div>
</asp:Content>

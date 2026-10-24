<%@ Page Title="My applications · PSUT Internship Portal" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="MyApplications.aspx.cs" Inherits="PSUTInternship.Student.MyApplications" %>
<%@ Register Src="~/Shared/StudentNav.ascx" TagPrefix="psut" TagName="StudentNav" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">

    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/student-workspace.css?v=offers2") %>" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="student-shell">

        <main id="student-main" class="student-main" tabindex="-1">
            <div class="student-heading"><div><h1>My applications.</h1><p>Track each decision and respond when an offer arrives. You can confirm only one internship offer.</p></div><a class="sd-button sd-heading-action" href="Opportunities.aspx">Explore opportunities</a></div>
            <asp:Label ID="MessageLabel" runat="server" CssClass="sd-status" role="status" />
            <div class="sd-applications">
                <asp:Repeater ID="ApplicationsRepeater" runat="server" OnItemCommand="ApplicationsRepeater_ItemCommand">
                    <ItemTemplate>
                        <article class="sd-card sd-application student-offer-card" data-status='<%# Eval("Status") %>'>
                            <div class="student-offer-summary"><span class="student-offer-mark" aria-hidden="true"><%#: string.IsNullOrWhiteSpace(Convert.ToString(Eval("Details.OrganizationName"))) ? "P" : Convert.ToString(Eval("Details.OrganizationName")).Substring(0,1).ToUpperInvariant() %></span><div><h2><%#: Eval("Details.OrganizationName") %></h2><p class="student-offer-role"><%#: Eval("Details.TrainingField") %></p></div></div><span class="student-offer-status"><%#: GetApplicationStatus(Container.DataItem) %></span>
                            <p class="student-offer-note"><%#: Eval("RejectionReason") %></p><div class="sd-application-actions">
                                <asp:Button ID="AcceptButton" runat="server" CssClass="student-offer-accept" Text="Accept offer" CommandName="AcceptOffer" CommandArgument='<%# Eval("Id") %>' OnClientClick="return portalConfirmAction(this, 'Confirm this internship? You can confirm only one offer.');" Visible='<%# CanAcceptOffer(Container.DataItem) %>' />
                                <asp:Button ID="DeclineButton" runat="server" CssClass="student-offer-decline" Text="Decline offer" CommandName="DeclineOffer" CommandArgument='<%# Eval("Id") %>' OnClientClick="return portalConfirmAction(this, 'Decline this internship offer?');" Visible='<%# CanDeclineOffer(Container.DataItem) %>' />
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </main>
    </div>
</asp:Content>

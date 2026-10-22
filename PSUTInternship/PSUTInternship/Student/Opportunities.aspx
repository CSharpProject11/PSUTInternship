<%@ Page Title="Opportunities · PSUT Internship Portal" MasterPageFile="~/Portal.Master" Language="C#" Async="true" AutoEventWireup="true" CodeBehind="Opportunities.aspx.cs" Inherits="PSUTInternship.Student.Opportunities" %>
<%@ Register Src="~/Shared/StudentNav.ascx" TagPrefix="psut" TagName="StudentNav" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">

    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/student-workspace.css") %>" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="student-shell">

        <main id="student-main" class="student-main" tabindex="-1">
            <div class="student-heading"><div><h1>Find your opportunity.</h1><p>Explore internships that can turn what you learn into what you do.</p></div><a class="sd-button sd-heading-action" href="MyApplications.aspx">My applications</a></div>
            <asp:Label ID="EmptyMessage" runat="server" CssClass="sd-empty" Text="No opportunities are open right now. Please check back soon." Visible="false" />
            <div class="sd-opportunities">
                <asp:Repeater ID="OpportunitiesRepeater" runat="server" OnItemCommand="OpportunitiesRepeater_ItemCommand">
                    <ItemTemplate>
                        <article class="sd-card sd-opportunity">
                            <asp:Image runat="server" ImageUrl='<%# OpportunityImage(Eval("ImageUrl")) %>' AlternateText='<%# Eval("Title") %>' />
                            <div class="sd-opportunity-body">
                                <h2><%#: Eval("Title") %></h2>
                                <p class="sd-opportunity-meta"><%#: Eval("CompanyId") %> · <%#: Eval("Location") %> · <%#: Eval("WorkMode") %></p>
                                <asp:Button ID="DetailsButton" runat="server" CssClass="sd-button" Text="View &amp; apply" CommandName="ViewApply" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </main>
    </div>
</asp:Content>

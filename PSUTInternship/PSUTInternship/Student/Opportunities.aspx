<%@ Page Title="Opportunities · PSUT Internship Portal" MasterPageFile="~/Portal.Master" Language="C#" Async="true" AutoEventWireup="true" CodeBehind="Opportunities.aspx.cs" Inherits="PSUTInternship.Student.Opportunities" %>
<%@ Register Src="~/Shared/StudentNav.ascx" TagPrefix="psut" TagName="StudentNav" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">

    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/student-workspace.css?v=20261023-opps2") %>" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="student-shell">

        <main id="student-main" class="student-main" tabindex="-1">
            <div class="student-heading"><div><h1>Find your opportunity.</h1><p>Explore internships that can turn what you learn into what you do.</p></div><a class="sd-button sd-heading-action" href="MyApplications.aspx">My applications</a></div>
            <asp:Label ID="EmptyMessage" runat="server" CssClass="sd-empty" Text="No opportunities are open right now. Please check back soon." Visible="false" />
            <div class="sd-opportunity-tools">
                <label>Search opportunities<input type="search" id="opportunitySearch" placeholder="Title, company, location or specialization" /></label>
                <label>Work type<select id="opportunityWork"><option value="">All work types</option></select></label>
                <label>Status<select id="opportunityStatus"><option value="open">Open opportunities</option><option value="">All opportunities</option><option value="closed">Closed opportunities</option></select></label>
                <label>Applications<select id="opportunityApplied"><option value="">All applications</option><option value="new">Not applied</option><option value="applied">Already applied</option></select></label>
            </div>
            <p id="opportunityCount" role="status" aria-live="polite"></p>
            <p id="opportunityNoMatches" class="sd-empty" hidden>No opportunities match these filters. Try another search or filter.</p>
            <div class="sd-opportunities">
                <asp:Repeater ID="OpportunitiesRepeater" runat="server" OnItemCommand="OpportunitiesRepeater_ItemCommand">
                    <ItemTemplate>
                        <article class="sd-card sd-opportunity" data-status='<%# Convert.ToBoolean(Eval("IsAccepting")) ? "open" : "closed" %>' data-applied='<%# Convert.ToBoolean(Eval("HasApplied")) ? "applied" : "new" %>' data-work='<%#: Eval("WorkMode") %>' data-specialization='<%#: Eval("Specialization") %>'>
                            <asp:Image runat="server" ImageUrl='<%# OpportunityImage(Eval("ImageUrl")) %>' AlternateText='<%# Eval("Title") %>' />
                            <div class="sd-opportunity-body">
                                <h2><%#: Eval("Title") %></h2>
                                <p class="sd-opportunity-meta"><%#: Eval("CompanyName") %> · <%#: Eval("LocationDisplay") %> · <%#: Eval("WorkModeDisplay") %></p>
                                <span class='<%# "sd-opening-status " + (Convert.ToBoolean(Eval("IsAccepting")) ? "is-open" : "is-closed") %>'><%#: Eval("StatusLabel") %></span>
                                <asp:Button ID="DetailsButton" runat="server" CssClass="sd-button" Text='<%# Convert.ToBoolean(Eval("HasApplied")) ? "View details · Applied" : Convert.ToBoolean(Eval("IsAccepting")) ? "View & apply" : "View details · Closed" %>' CommandName="ViewApply" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </main>
    </div>
<script src="../Scripts/student-opportunities.js?v=1" defer></script>
</asp:Content>

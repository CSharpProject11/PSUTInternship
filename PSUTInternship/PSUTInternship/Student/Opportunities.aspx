<%@ Page Title="Opportunities · PSUT Internship Portal" MasterPageFile="~/Portal.Master" Language="C#" Async="true" AutoEventWireup="true" CodeBehind="Opportunities.aspx.cs" Inherits="PSUTInternship.Student.Opportunities" %>
<%@ Register Src="~/Shared/StudentNav.ascx" TagPrefix="psut" TagName="StudentNav" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">

    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/student-workspace.css?v=20261024-opps4") %>" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="student-shell">

        <main id="student-main" class="student-main" tabindex="-1">
            <div class="student-heading"><div><h1>Find your opportunity.</h1><p>Explore internships that can turn what you learn into what you do.</p></div><a class="sd-button sd-heading-action" href="MyApplications.aspx">My applications</a></div>
            <asp:Label ID="EmptyMessage" runat="server" CssClass="sd-empty" Text="No opportunities are open right now. Please check back soon." Visible="false" />
            <div class="sd-opportunity-tools">
                <div class="opportunity-filter-heading"><strong>Find your next step</strong><button type="button" id="opportunityReset">Reset filters</button></div>
                <label class="opportunity-search">Search opportunities<input type="search" id="opportunitySearch" placeholder="Search by role, company, city or specialization" /></label>
                <label>Work type<select id="opportunityWork"><option value="">All work types</option></select></label>
                <label>Status<select id="opportunityStatus"><option value="">All opportunities</option><option value="open">Open opportunities</option><option value="closed">Closed opportunities</option></select></label>
                <label>Applications<select id="opportunityApplied"><option value="">All applications</option><option value="new">Not applied</option><option value="applied">Already applied</option></select></label>
            </div>
            <p id="opportunityCount" role="status" aria-live="polite"></p>
            <p id="opportunityNoMatches" class="sd-empty" hidden>No opportunities match these filters. Try another search or filter.</p>
            <div class="sd-opportunities">
                <asp:Repeater ID="OpportunitiesRepeater" runat="server" OnItemCommand="OpportunitiesRepeater_ItemCommand">
                    <ItemTemplate>
                        <article class="sd-card sd-opportunity" data-status='<%# Convert.ToBoolean(Eval("IsAccepting")) ? "open" : "closed" %>' data-applied='<%# Convert.ToBoolean(Eval("HasApplied")) ? "applied" : "new" %>' data-work='<%#: Eval("WorkMode") %>' data-specialization='<%#: Eval("Specialization") %>'>
                            <div class="opportunity-identity"><span class="opportunity-company-mark" aria-hidden="true"><%#: string.IsNullOrWhiteSpace(Convert.ToString(Eval("CompanyName"))) ? "P" : Convert.ToString(Eval("CompanyName")).Substring(0,1).ToUpperInvariant() %></span><div><span class="opportunity-company-name"><%#: Eval("CompanyName") %></span><span class="opportunity-specialization"><%#: string.IsNullOrWhiteSpace(Convert.ToString(Eval("Specialization"))) ? "Internship opportunity" : Eval("Specialization") %></span></div></div>
                            <div class="sd-opportunity-body">
                                <h2><%#: Eval("Title") %></h2>
                                <p class="sd-opportunity-meta"><%#: Eval("CompanyName") %> · <%#: Eval("LocationDisplay") %> · <%#: Eval("WorkModeDisplay") %></p>
                                <span class='<%# "sd-opening-status " + (Convert.ToBoolean(Eval("IsAccepting")) ? "is-open" : "is-closed") %>'><%#: Eval("StatusLabel") %></span>
                                <span class="opportunity-seat-label"><%#: Eval("SeatsLabel") %></span>
                                <asp:Button ID="DetailsButton" runat="server" CssClass="sd-button" Text='<%# Convert.ToBoolean(Eval("HasConfirmedInternship")) ? "View details · Internship confirmed" : Convert.ToBoolean(Eval("HasApplied")) ? "View details · Applied" : Convert.ToBoolean(Eval("IsAccepting")) ? "View & apply" : "View details · Closed" %>' CommandName="ViewApply" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" />
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </main>
    </div>
<script src="../Scripts/student-opportunities.js?v=2" defer></script>
</asp:Content>

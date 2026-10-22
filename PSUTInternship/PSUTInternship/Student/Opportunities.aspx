<%@ Page Language="C#" Async="true" AutoEventWireup="true" CodeBehind="Opportunities.aspx.cs" Inherits="PSUTInternship.Student.Opportunities" %>
<%@ Register Src="~/Student/StudentNav.ascx" TagPrefix="psut" TagName="StudentNav" %>
<!doctype html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Opportunities · PSUT Internship Portal</title>
    <link rel="icon" href="<%= ResolveUrl("~/Assets/psut-logo.jpg") %>" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/student-workspace.css") %>" />
</head>
<body class="student-page">
<form id="form1" runat="server">
    <div class="student-shell">
        <psut:StudentNav runat="server" />
        <main id="student-main" class="student-main" tabindex="-1">
            <div class="student-heading"><div><h1>Find your opportunity.</h1><p>Explore internships that can turn what you learn into what you do.</p></div><a class="sd-button sd-heading-action" href="MyApplications.aspx">My applications</a></div>
            <asp:Label ID="EmptyMessage" runat="server" CssClass="sd-empty" Text="No opportunities are open right now. Please check back soon." Visible="false" />
            <div class="sd-opportunities">
                <asp:Repeater ID="OpportunitiesRepeater" runat="server" OnItemCommand="OpportunitiesRepeater_ItemCommand">
                    <ItemTemplate>
                        <article class="sd-card sd-opportunity">
                            <asp:Image runat="server" ImageUrl='<%# Eval("ImageUrl") %>' AlternateText='<%# Eval("Title") %>' />
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
</form>
</body>
</html>

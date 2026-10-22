<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="MyApplications.aspx.cs" Inherits="PSUTInternship.Student.MyApplications" %>
<%@ Register Src="~/Student/StudentNav.ascx" TagPrefix="psut" TagName="StudentNav" %>
<!doctype html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>My applications · PSUT Internship Portal</title>
    <link rel="icon" href="<%= ResolveUrl("~/Assets/psut-logo.jpg") %>" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/student-workspace.css") %>" />
</head>
<body class="student-page">
<form id="form1" runat="server">
    <div class="student-shell">
        <psut:StudentNav runat="server" />
        <main id="student-main" class="student-main" tabindex="-1">
            <div class="student-heading"><div><h1>My applications.</h1><p>Track each decision and respond when an offer arrives. You can confirm only one internship offer.</p></div><a class="sd-button sd-heading-action" href="Opportunities.aspx">Explore opportunities</a></div>
            <asp:Label ID="MessageLabel" runat="server" CssClass="sd-status" role="status" />
            <div class="sd-applications">
                <asp:Repeater ID="ApplicationsRepeater" runat="server" OnItemCommand="ApplicationsRepeater_ItemCommand">
                    <ItemTemplate>
                        <article class="sd-card sd-application">
                            <div><h2><%#: Eval("Details.OrganizationName") %></h2><p>Training field: <%#: Eval("Details.TrainingField") %></p><p>Status: <strong><%#: GetApplicationStatus(Container.DataItem) %></strong></p></div>
                            <div class="sd-application-actions">
                                <asp:Button ID="AcceptButton" runat="server" Text="Accept offer" CommandName="AcceptOffer" CommandArgument='<%# Eval("Id") %>' OnClientClick="return confirm('Confirm this internship? You can confirm only one offer.');" Visible='<%# CanAcceptOffer(Container.DataItem) %>' />
                                <asp:Button ID="DeclineButton" runat="server" Text="Decline offer" CommandName="DeclineOffer" CommandArgument='<%# Eval("Id") %>' OnClientClick="return confirm('Decline this internship offer?');" Visible='<%# CanDeclineOffer(Container.DataItem) %>' />
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

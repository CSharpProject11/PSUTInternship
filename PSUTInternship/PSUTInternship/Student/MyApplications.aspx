<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="MyApplications.aspx.cs" Inherits="PSUTInternship.Student.MyApplications" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>My Applications</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <h1>My Applications</h1>

            <p>You can confirm only one internship offer.</p>
            <asp:Label ID="MessageLabel" runat="server" role="status" />
            <asp:Repeater ID="ApplicationsRepeater" runat="server" OnItemCommand="ApplicationsRepeater_ItemCommand">
                <ItemTemplate>
                    <div>
                        <h3><%#: Eval("Details.OrganizationName") %></h3>
                        <p>Training field: <%#: Eval("Details.TrainingField") %></p>
                        <p>Status: <%#: GetApplicationStatus(Container.DataItem) %></p>
                        <asp:Button
                        ID="AcceptButton"
                        runat="server"
                        Text="Accept offer"
                        CommandName="AcceptOffer"
                        CommandArgument='<%# Eval("Id") %>'
                        OnClientClick="return confirm('Confirm this internship? You can confirm only one offer.');"
                        Visible='<%# CanAcceptOffer(Container.DataItem) %>' />

                        <asp:Button
                        ID="DeclineButton"
                        runat="server"
                        Text="Decline offer"
                        CommandName="DeclineOffer"
                        CommandArgument='<%# Eval("Id") %>'
                        OnClientClick="return confirm('Decline this internship offer?');"
                        Visible='<%# CanDeclineOffer(Container.DataItem) %>' />
                        <hr />
                    </div>
                </ItemTemplate>
            </asp:Repeater>

        </div>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendAccounts.aspx.cs" Inherits="internship_manegment.SendAccounts" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Send Account Emails</title>
</head>
<body>
    <form id="form1" runat="server">

<asp:Button
    ID="SendEmailsButton"
    runat="server"
    Text="Send Emails To All Users"
    OnClick="SendEmailsButton_Click" />

<br /><br />

<asp:Label
    ID="MessageLabel"
    runat="server">
</asp:Label>

    </form>
</body>
</html>

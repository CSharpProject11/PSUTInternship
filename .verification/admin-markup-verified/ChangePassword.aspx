<%@ Page Language="C#" Async="true" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="PSUTInternship.ChangePassword" %>
<!DOCTYPE html><html lang="en"><head runat="server"><title>Change password | PSUT</title>
<link rel="stylesheet" href="Content/portal.css" /></head><body><main class="container">
<h1>Change your temporary password</h1><p>Choose a new password before opening your workspace.</p>
<form id="form1" runat="server">
<p><label for="newPassword">New password</label><asp:TextBox ID="newPassword" runat="server" TextMode="Password" /></p>
<p><label for="confirmPassword">Confirm password</label><asp:TextBox ID="confirmPassword" runat="server" TextMode="Password" /></p>
<asp:Button ID="savePassword" runat="server" Text="Save password" OnClick="savePassword_Click" />
<asp:Label ID="passwordMessage" runat="server" role="alert" />
</form></main></body></html>

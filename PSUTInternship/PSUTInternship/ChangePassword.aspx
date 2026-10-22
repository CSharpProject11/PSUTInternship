<%@ Page Title="Change password" MasterPageFile="~/Portal.Master" Language="C#" Async="true" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="PSUTInternship.ChangePassword" %>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
    <h1>Change password</h1><p class="subtitle">Choose a new password before opening your workspace.</p>
    <section class="panel portal-form-panel"><h2>Secure your account</h2>
        <asp:Label ID="passwordMessage" runat="server" CssClass="message error" role="alert" />
        <div class="fields">
            <div class="field"><asp:Label runat="server" AssociatedControlID="newPassword" Text="New password" /><asp:TextBox ID="newPassword" runat="server" TextMode="Password" autocomplete="new-password" /></div>
            <div class="field"><asp:Label runat="server" AssociatedControlID="confirmPassword" Text="Confirm password" /><asp:TextBox ID="confirmPassword" runat="server" TextMode="Password" autocomplete="new-password" /></div>
        </div>
        <p class="muted">Use at least 8 characters.</p><div class="portal-form-actions"><asp:Button ID="savePassword" runat="server" Text="Save password" OnClick="savePassword_Click" /></div>
    </section>
</asp:Content>

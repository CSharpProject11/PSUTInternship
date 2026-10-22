<%@ Register Src="~/Shared/CompanyLinks.ascx" TagPrefix="psut" TagName="CompanyLinks" %>
<%@ Page MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="ViewTask.aspx.cs" Inherits="PSUTInternship.Company.ViewTask" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">

</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server"><h1>Task details</h1>
<div id="Describtion"  runat="server">
        </div>
        <div id="solution"  runat="server"></div>
        <asp:Button ID="Cansle" runat="server" OnClick="Cansle_Click" Text="Back to tasks" />
</asp:Content>

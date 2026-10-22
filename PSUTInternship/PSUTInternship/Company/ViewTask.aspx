<%@ Register Src="~/Shared/CompanyLinks.ascx" TagPrefix="psut" TagName="CompanyLinks" %>
<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="ViewTask.aspx.cs" Inherits="PSUTInternship.Company.ViewTask" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
<psut:CompanyLinks runat="server" />
        <div id="Describtion"  runat="server">
        </div>
        <div id="solution"  runat="server"></div>
        <asp:Button ID="Cansle" runat="server" OnClick="Cansle_Click" Text="Cansle" />
    </form>
</body>
</html>

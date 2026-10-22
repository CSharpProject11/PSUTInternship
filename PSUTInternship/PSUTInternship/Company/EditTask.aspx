<%@ Register Src="~/Shared/CompanyLinks.ascx" TagPrefix="psut" TagName="CompanyLinks" %>
<%@ Page MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="EditTask.aspx.cs" Inherits="PSUTInternship.Company.EditTask" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">

</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server"><h1>Edit task</h1>
<asp:Label ID="subject" runat="server" CssClass="message" role="status"></asp:Label>
         <br />
        <div id="describtion" runat="server">
            <asp:Literal ID="TaskDetails" runat="server"></asp:Literal>
        </div>

        <p>
            <asp:Label ID="State" runat="server" Text="State"></asp:Label>
        </p>
        <p>
            <asp:DropDownList ID="stateDrop" runat="server">
                <asp:ListItem>Select state</asp:ListItem>
                <asp:ListItem>Resolve</asp:ListItem>
                <asp:ListItem>Complete</asp:ListItem>
            </asp:DropDownList>
        </p>
        <br />
        <asp:Label ID="Feedback" runat="server" Text="Feedback"></asp:Label>
        <p>
            <textarea id="Feedbackinput" cols="20" name="S1" rows="2" runat="server"></textarea></p>
        <p><asp:Label runat="server" AssociatedControlID="maximumInput" Text="Task maximum score" /><asp:TextBox ID="maximumInput" runat="server" /></p>
        <p><label for="scoreInput">Awarded score</label><asp:TextBox ID="scoreInput" runat="server" /></p>
        <asp:Button ID="Save" runat="server" Text="Save" OnClick="Save_Click" />
        <asp:Button ID="Cansale" runat="server" Text="Cancel" OnClick="Cansale_Click" CausesValidation="false"/>
</asp:Content>

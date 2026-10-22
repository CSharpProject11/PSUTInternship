<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="EditTask.aspx.cs" Inherits="internship_manegment.EditTask" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
         <asp:Label ID="subject" runat="server" Text="Review Task Submission"></asp:Label>
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
        <asp:Button ID="Save" runat="server" Text="Save" OnClick="Save_Click" />
        <asp:Button ID="Cansale" runat="server" Text="Cansale" OnClick="Cansale_Click" CausesValidation="false"/>

    </form>
</body>
</html>

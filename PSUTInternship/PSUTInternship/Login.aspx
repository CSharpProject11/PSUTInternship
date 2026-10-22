<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="Login.aspx.cs" Inherits="PSUTInternship.Login" %>


<!DOCTYPE html>
<html>
<head runat="server">
    <title>UIMS Login</title>

    <style>
        body {
            font-family: Arial;
            background-color: #f0f6ff;
        }

        .loginBox {
            width: 350px;
            margin: 100px auto;
            padding: 30px;
            background-color: white;
            text-align: center;
            border-radius: 10px;
        }

        h1 {
            color: #1769aa;
        }

        .textBox {
            width: 90%;
            padding: 10px;
            margin: 10px;
        }

        .loginButton {
            width: 97%;
            padding: 10px;
            background-color: #1769aa;
            color: white;
            border: none;
            cursor: pointer;
        }
    </style>
</head>

<body>
    <form id="loginForm" runat="server">

        <div class="loginBox">

            <h1>UIMS</h1>
            <p>University Internship Management System</p>
            <h2>Login</h2>

            <asp:TextBox
                ID="emailTextBox"
                runat="server"
                CssClass="textBox"
                placeholder="Email">
            </asp:TextBox>

            <asp:TextBox
                ID="passwordTextBox"
                runat="server"
                CssClass="textBox"
                TextMode="Password"
                placeholder="Password">
            </asp:TextBox>

            <asp:Button
                ID="loginButton"
                runat="server"
                Text="Login"
                CssClass="loginButton"
                OnClick="loginButton_Click" />

            <br /><br />

            <asp:Label
                ID="messageLabel"
                runat="server">
            </asp:Label>

        </div>

    </form>
</body>
</html>

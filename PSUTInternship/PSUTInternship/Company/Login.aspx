<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="PSUTInternship.Company.Login" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Company supervisor login</title>
    <link href="../Content/Company.css" rel="stylesheet" />
</head>
<body class="login-page">
    <main class="login-card">
        <div class="brand login-brand"><span class="logo">PSUT</span><span>Internship Portal</span></div>
        <h1>Company supervisor login</h1>
        <p class="muted">Sign in with the account created in Firebase Authentication.</p>
        <% if (!string.IsNullOrEmpty(ErrorMessage)) { %>
        <div class="notice"><%= H(ErrorMessage) %></div>
        <% } %>
        <form method="post">
            <label for="email">Email address</label>
            <input id="email" name="email" type="email" required />
            <label for="password">Password</label>
            <input id="password" name="password" type="password" required />
            <button class="btn" type="submit">Sign in</button>
        </form>
    </main>
</body>
</html>

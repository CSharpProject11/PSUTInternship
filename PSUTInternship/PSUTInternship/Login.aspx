<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="Login.aspx.cs" Inherits="PSUTInternship.Login" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Login</title>
    <link rel="icon" type="image/png" href="Assets/login-emblem.png" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="preload" href="Assets/manrope-variable.ttf" as="font" type="font/ttf" crossorigin="anonymous" />

    <style>
        :root {
            --navy: #0d3b8e;
            --blue: #1565c0;
            --sky: #5bc8f5;
            --pale: #eaf3ff;
            --text: #1e2a44;
            --gray: #4a5876;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            color: var(--text);
            overflow-x: hidden;
            background-color: var(--pale);
        }

        .bgPhoto {
            position: fixed;
            inset: 0;
            background-image: url("Assets/login-campus.png");
            background-size: cover;
            background-position: center;
            animation: slowZoom 25s ease-in-out infinite alternate;
            z-index: -3;
        }

        .bgOverlay {
            position: fixed;
            inset: 0;
            background-image: linear-gradient(180deg, rgba(0, 0, 0, 0.50), rgba(234, 243, 255, 0.40));
            z-index: -2;
        }

        .blob {
            position: fixed;
            border-radius: 50%;
            z-index: -1;
        }

        

        .topBar {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 24px 5%;
        }

        .topLogo {
            background-color: white;
            padding: 8px 14px;
            border-radius: 14px;
            box-shadow: 0 8px 25px rgba(13, 59, 142, 0.2);
            animation: dropIn 0.8s ease both;
        }

        .topLogo img {
            height: 60px;
            display: block;
        }

        .topText {
            display: flex;
            align-items: center;
            gap: 14px;
            color: white;
            font-size: 14px;
            letter-spacing: 1px;
            text-shadow: 0 2px 8px rgba(13, 59, 142, 0.6);
            animation: dropIn 0.8s ease 0.3s both;
        }

        .topText span {
            display: block;
            width: 50px;
            height: 1px;
            background-color: white;
        }

        .page {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 110px 20px 40px 20px;
        }

        .loginBox {
            position: relative;
            width: 100%;
            max-width: 470px;
            padding: 36px 40px 28px 40px;
            text-align: center;
            border-radius: 28px;
            overflow: hidden;
            background-color: rgba(255, 255, 255, 0.38);
            backdrop-filter: blur(22px) saturate(160%);
            -webkit-backdrop-filter: blur(22px) saturate(160%);
            border: 1px solid rgba(255, 255, 255, 0.75);
            box-shadow: 0 25px 60px rgba(13, 59, 142, 0.3), inset 0 1px 0 rgba(255, 255, 255, 0.9);
            animation: popIn 1s cubic-bezier(0.2, 0.8, 0.2, 1) 0.2s both;
        }

        

        .cardLogo {
            height: 70px;
            animation: floatLogo 4s ease-in-out infinite;
        }

        .loginBox h2 {
            font-family: "Playfair Display", Georgia, serif;
            color: var(--navy);
            font-size: 46px;
            margin: 10px 0 6px 0;
            animation: riseUp 0.7s ease 0.6s both;
        }

        .subText {
            color: var(--text);
            font-size: 15px;
            line-height: 1.6;
            margin: 0 0 26px 0;
            animation: riseUp 0.7s ease 0.75s both;
        }

        .field {
            display: flex;
            align-items: center;
            gap: 12px;
            border: 1.5px solid transparent;
            border-radius: 14px;
            padding: 10px 16px;
            margin-bottom: 14px;
            background-color: rgba(255, 255, 255, 0.72);
            transition: border-color 0.3s, box-shadow 0.3s, transform 0.3s, background-color 0.3s;
            animation: riseUp 0.7s ease both;
        }

        .field.first { animation-delay: 0.9s; }
        .field.second { animation-delay: 1.05s; }

        .field:hover {
            background-color: rgba(255, 255, 255, 0.9);
        }

        .field:focus-within {
            background-color: white;
            border-color: var(--blue);
            box-shadow: 0 0 0 4px rgba(91, 200, 245, 0.4);
            transform: translateY(-2px);
        }

        .field > i {
            font-size: 22px;
            color: var(--gray);
            transition: color 0.3s, transform 0.3s;
        }

        .field:focus-within > i {
            color: var(--navy);
            transform: scale(1.2) rotate(-8deg);
        }

        .textBox {
            flex: 1;
            width: 100%;
            border: none;
            outline: none;
            font-size: 15px;
            padding: 6px 0;
            background-color: transparent;
            color: var(--text);
        }

        .eyeBtn {
            border: none;
            background-color: transparent;
            padding: 6px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--gray);
            transition: color 0.3s, background-color 0.3s, transform 0.2s;
        }

        .eyeBtn i {
            font-size: 20px;
        }

        .eyeBtn:hover {
            color: var(--navy);
            background-color: rgba(91, 200, 245, 0.3);
        }

        .eyeBtn:active {
            transform: scale(0.85);
        }

        .textBox::placeholder {
            color: #6b7690;
        }

        .optionsRow {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            font-size: 14px;
            margin: 4px 2px 20px 2px;
            animation: riseUp 0.7s ease 1.2s both;
        }

        .optionsRow label {
            cursor: pointer;
            color: var(--text);
        }

        .optionsRow input[type="checkbox"] {
            accent-color: var(--navy);
            margin-right: 6px;
            cursor: pointer;
        }

        .forgotLink {
            color: var(--navy);
            font-weight: 600;
            text-decoration: none;
            border-bottom: 1px solid transparent;
            transition: border-color 0.3s;
        }

        .forgotLink:hover {
            border-bottom-color: var(--navy);
        }

        .btnWrap {
            position: relative;
            overflow: hidden;
            border-radius: 40px;
            animation: riseUp 0.7s ease 1.3s both;
        }

        .btnWrap::after {
            content: "";
            position: absolute;
            top: 0;
            left: -80%;
            width: 50%;
            height: 100%;
            background-image: linear-gradient(100deg, transparent, rgba(255, 255, 255, 0.5), transparent);
            transform: skewX(-20deg);
            pointer-events: none;
            animation: buttonShine 3.5s ease-in-out 2.5s infinite;
        }

        .loginButton {
            width: 100%;
            padding: 16px;
            background-image: linear-gradient(90deg, var(--navy), var(--blue), var(--sky));
            background-size: 200% 100%;
            background-position: left;
            color: white;
            border: none;
            border-radius: 40px;
            font-size: 17px;
            font-weight: 600;
            cursor: pointer;
            transition: background-position 0.5s, transform 0.2s, box-shadow 0.3s;
        }

        .loginButton:hover {
            background-position: right;
            box-shadow: 0 10px 25px rgba(21, 101, 192, 0.45);
        }

        .loginButton:active {
            transform: scale(0.97);
        }

        .message {
            display: block;
            margin-top: 14px;
            color: #c62828;
            font-size: 14px;
            font-weight: 600;
            animation: shake 0.5s ease;
        }

        .cardFooter {
            margin-top: 22px;
            font-size: 13px;
            color: var(--text);
            line-height: 1.8;
            animation: riseUp 0.7s ease 1.5s both;
        }

        

        @keyframes floatBlob {
            0%, 100% { transform: translate(0, 0); }
            50% { transform: translate(-25px, 30px); }
        }

        @keyframes riseUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes dropIn {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes popIn {
            from { opacity: 0; transform: translateY(50px) scale(0.92); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        
        @keyframes floatLogo {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-6px); }
        }

        @keyframes buttonShine {
            0% { left: -80%; }
            40%, 100% { left: 140%; }
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-8px); }
            75% { transform: translateX(8px); }
        }

        @media (prefers-reduced-motion: reduce) {
            * {
                animation: none !important;
                transition: none !important;
            }
        }

        @media (max-width: 700px) {
            .topText {
                display: none;
            }

            .topBar {
                justify-content: center;
            }

            .loginBox {
                padding: 28px 22px 22px 22px;
            }

            .loginBox h2 {
                font-size: 38px;
            }
        }
    </style>
    <link rel="stylesheet" href="Content/login-fit.css?v=20261023-2" />
</head>

<body>
    <form id="loginForm" runat="server">

        <div class="bgPhoto"></div>
        <div class="bgOverlay"></div>
        <div class="blob blob1"></div>
        <div class="blob blob2"></div>
        <div class="blob blob3"></div>

        <div class="topBar">
            <div class="topLogo">
               <a href="Default.aspx"> <img src="Assets/login-wordmark.png" alt="Princess Sumaya University for Technology" /></a>
            </div>
           
        </div>

        <div class="page">
            <div class="loginBox">

                <a href="Default.aspx"><img class="cardLogo" src="Assets/login-emblem.png" alt="PSUT logo" /></a>

                <h2>Welcome</h2>
                <p class="subText">Sign in to your PSUT account to access your internship portal.</p>

                <div class="field first">
                    <i class="bi bi-envelope"></i>
                    <asp:TextBox
                        ID="emailTextBox"
                        runat="server"
                        CssClass="textBox"
                        aria-label="Email address"
                        placeholder="Email Address">
                    </asp:TextBox>
                </div>

                <div class="field second">
                    <svg class="lockIcon" viewBox="0 0 24 24" aria-hidden="true"><rect x="4" y="10" width="16" height="11" rx="3" /><path d="M8 10V7a4 4 0 0 1 8 0v3" /><path d="M12 14v3" /></svg>
                    <asp:TextBox
                        ID="passwordTextBox"
                        runat="server"
                        CssClass="textBox"
                        TextMode="Password"
                        aria-label="Password"
                        placeholder="Password">
                    </asp:TextBox>

                    <button type="button" class="eyeBtn" aria-label="Show password"
                        onclick="const input=document.getElementById('<%= passwordTextBox.ClientID %>');const show=input.type==='password';input.type=show?'text':'password';this.firstElementChild.className=show?'bi bi-eye-slash':'bi bi-eye';">
                        <i class="bi bi-eye"></i>
                    </button>
                </div>

                <div class="optionsRow">
                    <asp:LinkButton
                        ID="resetPassword"
                        runat="server"
                        Text="Forgot Password?"
                        CssClass="forgotLink"
                        OnClick="resetPassword_Click"
                        CausesValidation="false" />
                </div>

                <div class="btnWrap">
                    <asp:Button
                        ID="loginButton"
                        runat="server"
                        Text="Log In  →"
                        CssClass="loginButton"
                        OnClick="loginButton_Click" />
                </div>

                <asp:Label
                    ID="messageLabel"
                    runat="server"
                    CssClass="message">
                </asp:Label>

                <div class="cardFooter">
                    <i class="bi bi-lock-fill"></i> Secure access to your internship portal<br />
                    © Princess Sumaya University for Technology
                </div>

            </div>
        </div>

    </form>
</body>
</html>


<%@ Page Language="C#" Async="true" AutoEventWireup="true" CodeBehind="CoordinatorAccount.aspx.cs" Inherits="CoordinatorAccount" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <title>Account Settings | UIMS</title>

    <link href="Coordinator.css" rel="stylesheet" />

    <style>
        .account-container {
            max-width: 1100px;
            margin: 0 auto;
        }

        .account-banner {
            background: linear-gradient(120deg, #172e52, #28528b);
            border-radius: 15px;
            padding: 28px;
            color: white;
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 24px;
        }

        .account-avatar {
            width: 72px;
            height: 72px;
            border-radius: 18px;
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 27px;
            font-weight: 700;
            flex-shrink: 0;
        }

        .account-banner h2 {
            color: white;
            font-size: 22px;
            margin: 0 0 7px;
        }

        .account-banner p {
            color: #d4e3fa;
            font-size: 14px;
            margin: 0;
        }

        .account-section {
            background: white;
            border: 1px solid #e0e8f2;
            border-radius: 13px;
            padding: 27px;
            margin-bottom: 22px;
        }

        .account-section-title {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 22px;
        }

        .account-section-icon {
            width: 41px;
            height: 41px;
            background: #edf3fc;
            color: #255c9b;
            border-radius: 11px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 19px;
        }

        .account-section-title h2 {
            margin: 0;
            font-size: 19px;
            color: #172b4d;
        }

        .account-section-title p {
            color: #73849e;
            margin: 5px 0 0;
            font-size: 13px;
        }

        .account-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 20px;
        }

        .account-field {
            min-width: 0;
        }

        .account-field label {
            display: block;
            color: #344c70;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 9px;
        }

        .account-input {
            box-sizing: border-box;
            width: 100%;
            padding: 13px 14px;
            border: 1px solid #d5e0ee;
            border-radius: 8px;
            outline: none;
            background: white;
            color: #172b4d;
            font-size: 14px;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .account-input:focus {
            border-color: #2d67ad;
            box-shadow: 0 0 0 3px rgba(45,103,173,0.1);
        }

        .account-input:disabled {
            background: #f3f6fa;
            color: #657891;
            cursor: not-allowed;
        }

        .account-hint {
            display: block;
            font-size: 12px;
            color: #8491a6;
            margin-top: 7px;
        }

        .password-wrapper {
            display: flex;
            align-items: stretch;
            position: relative;
        }

        .password-wrapper .account-input {
            padding-right: 74px;
        }

        .toggle-password {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            border: none;
            background: transparent;
            color: #245b9d;
            cursor: pointer;
            padding: 8px;
            font-weight: 600;
            font-size: 12px;
        }

        .account-buttons {
            display: flex;
            justify-content: flex-end;
            margin-top: 23px;
        }

        .account-save {
            background: #245da4;
            border: none;
            color: white;
            padding: 12px 23px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

        .account-save:hover {
            background: #194983;
        }

        .account-save.security {
            background: #142f53;
        }

        .account-save.security:hover {
            background: #234a7c;
        }

        .security-info {
            background: #f1f6fd;
            color: #476181;
            padding: 13px;
            border-radius: 8px;
            font-size: 13px;
            margin-top: 19px;
        }

        @media (max-width: 700px) {
            .account-grid {
                grid-template-columns: 1fr;
            }

            .account-banner {
                padding: 20px;
            }

            .account-avatar {
                width: 58px;
                height: 58px;
            }

            .account-section {
                padding: 20px;
            }
        }
    </style>
</head>

<body>

    <form id="form1" runat="server">
<input type="hidden" name="csrfToken" value="<%= H(CsrfToken) %>" />

        <div class="layout">

            <!-- Sidebar -->
            <aside class="sidebar">
                <div class="brand">
                    UIMS
                    <span>Coordinator</span>
                </div>

                <nav>
                    <a class="nav-link" href="Dashboard.aspx">Dashboard</a>
                    <a class="nav-link" href="ManageStudents.aspx">Manage Students</a>
                    <a class="nav-link" href="ManageCompanies.aspx">Manage Companies</a>
                    <a class="nav-link" href="ManageAcademic.aspx">Manage Academic Supervisors</a>
                    <a class="nav-link" href="AssignSuper.aspx">Assign Academic Supervisors</a>
                    <a class="nav-link" href="MonitorPlacements.aspx">Monitor Placements & Progress</a>
                    <a class="nav-link" href="FinalCompletionReview.aspx">Final Completion Review</a>
                    <a class="nav-link" href="ContactMessages.aspx">Contact Messages</a>
                    <a class="nav-link active" href="CoordinatorAccount.aspx">Coordinator Account</a>
                </nav>

                <div class="sidefoot">
                    University Internship System
                </div>
            </aside>

            <!-- Workspace -->
            <div class="workspace">

                <header class="topbar">
                    <span>University Internship Management System</span>
                    <span class="avatar">CO</span>
                </header>

                <main>
                    <div class="account-container">

                        <div class="heading">
                            <h1>Account Settings</h1>
                            <p>
                                Manage your contact information
                                and account security.
                            </p>
                        </div>

                        <% if (!string.IsNullOrEmpty(Notice)) { %>
                            <div class="notice" role="status">
                                <%= H(Notice) %>
                            </div>
                        <% } %>

                        <!-- Account Banner -->
                        <div class="account-banner">
                            <div class="account-avatar">CO</div>

                            <div>
                                <h2><%= H(FullName) %></h2>
                                <p>University Internship Coordinator</p>
                                <p>Primary System Administrator</p>
                            </div>
                        </div>

                        <!-- Profile Information -->
                        <section class="account-section">

                            <div class="account-section-title">
                                <div class="account-section-icon">
                                    &#9787;
                                </div>

                                <div>
                                    <h2>Profile Information</h2>
                                    <p>Your official account identity</p>
                                </div>
                            </div>

                            <div class="account-grid">

                                <div class="account-field">
                                    <label>Full Name</label>
                                    <input class="account-input"
                                           type="text"
                                           value="<%= H(FullName) %>"
                                           disabled />

                                    <span class="account-hint">
                                        This information cannot be edited here.
                                    </span>
                                </div>

                                <div class="account-field">
                                    <label>Account Role</label>
                                    <input class="account-input"
                                           type="text"
                                           value="University Internship Coordinator"
                                           disabled />
                                </div>

                            </div>
                        </section>

                        <!-- Contact Information -->
<p id="emailHelp">Your sign-in email is managed through Firebase Authentication. You can update your phone number here.</p>
                        <section class="account-section">

                            <div class="account-section-title">
                                <div class="account-section-icon">
                                    &#9993;
                                </div>

                                <div>
                                    <h2>Contact Information</h2>
                                    <p>Update your email address and phone number</p>
                                </div>
                            </div>

                            <div class="account-grid">

                                <div class="account-field">
                                    <label for="accountEmail">
                                        Email Address
                                    </label>

                                    <input id="accountEmail"
                                           class="account-input"
                                           type="email"
                                           name="email" readonly aria-describedby="emailHelp"
                                           maxlength="120"
                                           value="<%= H(Email) %>"
                                           autocomplete="email"
                                           required />
                                </div>

                                <div class="account-field">
                                    <label for="accountPhone">
                                        Phone Number
                                    </label>

                                    <input id="accountPhone"
                                           class="account-input"
                                           type="tel"
                                           name="phone"
                                           maxlength="25"
                                           value="<%= H(Phone) %>"
                                           placeholder="+962 7X XXX XXXX"
                                           autocomplete="tel" />
                                </div>

                            </div>

                            <div class="account-buttons">
                                <button class="account-save"
                                        type="submit"
                                        name="accountAction"
                                        value="saveContact"
                                        formnovalidate
                                        onclick="return validateContact()">
                                    Save Changes
                                </button>
                            </div>
                        </section>

                        <!-- Security Settings -->
                        <section class="account-section">

                            <div class="account-section-title">
                                <div class="account-section-icon">
                                    &#128274;
                                </div>

                                <div>
                                    <h2>Security Settings</h2>
                                    <p>Update your account password securely</p>
                                </div>
                            </div>

                            <div class="account-grid">

                                <div class="account-field">
                                    <label for="currentPassword">
                                        Current Password
                                    </label>

                                    <div class="password-wrapper">
                                        <input id="currentPassword"
                                               class="account-input"
                                               type="password"
                                               name="currentPassword"
                                               autocomplete="off"
                                                value=""
                                               placeholder="Enter current password" />

                                        <button type="button"
                                                class="toggle-password"
                                                onclick="togglePassword('currentPassword', this)">
                                            Show
                                        </button>
                                    </div>
                                </div>

                                <div class="account-field">
                                    <label for="newPassword">
                                        New Password
                                    </label>

                                    <div class="password-wrapper">
                                        <input id="newPassword"
                                               class="account-input"
                                               type="password"
                                               name="newPassword"
                                               autocomplete="new-password"
                                               placeholder="Enter new password" />

                                        <button type="button"
                                                class="toggle-password"
                                                onclick="togglePassword('newPassword', this)">
                                            Show
                                        </button>
                                    </div>
                                </div>

                                <div class="account-field">
                                    <label for="confirmPassword">
                                        Confirm New Password
                                    </label>

                                    <div class="password-wrapper">
                                        <input id="confirmPassword"
                                               class="account-input"
                                               type="password"
                                               name="confirmPassword"
                                               autocomplete="new-password"
                                               placeholder="Confirm new password" />

                                        <button type="button"
                                                class="toggle-password"
                                                onclick="togglePassword('confirmPassword', this)">
                                            Show
                                        </button>
                                    </div>
                                </div>

                            </div>

                            <div class="security-info">
                                Use a strong password with at least 8 characters.
                                Your current password is required when changing it.
                            </div>

                            <div class="account-buttons">
                                <button class="account-save security"
                                        type="submit"
                                        name="accountAction"
                                        value="changePassword"
                                        formnovalidate
                                        onclick="return validatePassword()">
                                    Update Password
                                </button>
                            </div>

                        </section>

                    </div>
                </main>

            </div>
        </div>

    </form>

    <script>
function togglePassword(id, button) {
    const input = document.getElementById(id);

    if (input.type === "password") {
        input.type = "text";
        button.textContent = "Hide";
    } else {
        input.type = "password";
        button.textContent = "Show";
    }
}

function validateContact() {
    const email = document.getElementById("accountEmail");
    const phone = document.getElementById("accountPhone");

    if (!email.value.trim() || !email.checkValidity()) {
        alert("Please enter a valid email address.");
        email.focus();
        return false;
    }

    if (phone.value.trim() &&
        !/^[+0-9()\s-]{7,25}$/.test(phone.value.trim())) {
        alert("Please enter a valid phone number.");
        phone.focus();
        return false;
    }

    return true;
}

function validatePassword() {
    const current = document.getElementById("currentPassword");
    const next = document.getElementById("newPassword");
    const confirm = document.getElementById("confirmPassword");

    if (!current.value) {
        alert("Please enter your current password.");
        current.focus();
        return false;
    }

    if (next.value.length < 8) {
        alert("New password must contain at least 8 characters.");
        next.focus();
        return false;
    }

    if (next.value !== confirm.value) {
        alert("New passwords do not match.");
        confirm.focus();
        return false;
    }

    if (current.value === next.value) {
        alert("New password must be different from the current password.");
        next.focus();
        return false;
    }

    return true;
}
window.addEventListener("pageshow", function () {
    const currentPassword = document.getElementById("currentPassword");

    if (currentPassword) {
        currentPassword.value = "";
    }
});
    </script>

</body>
</html>

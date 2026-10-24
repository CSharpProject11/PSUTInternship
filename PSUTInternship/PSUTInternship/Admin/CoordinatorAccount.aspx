<%@ Page Title="Account Settings | UIMS" MasterPageFile="~/Portal.Master" Language="C#" Async="true" AutoEventWireup="true" CodeBehind="CoordinatorAccount.aspx.cs" Inherits="CoordinatorAccount" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="Coordinator.css" rel="stylesheet" />

    <style>
.portal-app .portal-content .account-container{max-width:1050px;margin:0 auto;color:#19364b}.account-container .heading{padding-bottom:24px;margin-bottom:24px;border-bottom:1px solid #dce5ec}.portal-app .portal-content .account-container .heading h1{font-size:30px!important;letter-spacing:-.035em;margin:0 0 8px!important}.account-container .heading p{font-size:13px!important;color:#607587;line-height:1.7;margin:0}
.portal-app .portal-content .account-banner{display:flex;align-items:center;gap:18px;padding:24px 28px;background:#f2f6f9!important;color:#19364b!important;border:1px solid #dce6ed;border-radius:12px;margin-bottom:24px}.account-avatar{display:grid;place-items:center;width:60px;height:60px;flex-shrink:0;border-radius:50%;background:#003e73;color:#fff;font-size:18px;font-weight:700}.portal-app .portal-content .account-banner h2{font-size:22px!important;letter-spacing:-.025em;color:#19364b!important;margin:0 0 5px!important}.portal-app .portal-content .account-banner p{font-size:12px!important;font-weight:400;color:#607587!important;margin:0;line-height:1.7}
.portal-app .portal-content .account-section{display:grid;grid-template-columns:240px minmax(0,1fr);column-gap:36px;background:#fff;border:1px solid #dfe7ed;border-radius:12px;padding:28px;margin-bottom:22px}.account-section-title{grid-column:1;grid-row:1 / span 3;align-self:start}.account-section-icon{display:none}.portal-app .portal-content .account-section-title h2{font-size:16px!important;letter-spacing:-.015em;margin:0 0 8px!important;color:#193b53}.account-section-title p{font-size:12px!important;font-weight:400;color:#607587;line-height:1.8;margin:0;max-width:25ch}
.portal-app .portal-content .account-section .account-grid{grid-column:2;display:grid!important;grid-template-columns:minmax(0,1fr)!important;gap:18px!important}.portal-app .portal-content .account-readonly>div{padding-bottom:16px;border-bottom:1px solid #e6edf2}.portal-app .portal-content .account-readonly p{font-size:11px!important;font-weight:500;color:#607587;margin:0 0 6px!important}.portal-app .portal-content .account-readonly strong{font-size:14px!important;font-weight:600;color:#25485f;overflow-wrap:anywhere}.account-field{min-width:0}.account-field label{display:block;font-size:12px!important;font-weight:600;color:#486479;margin-bottom:8px}
.portal-app .portal-content .account-input{width:100%!important;min-height:44px;border:1px solid #cbd9e3!important;border-radius:6px!important;background:#fff;padding:11px 13px;font-size:13px!important;color:#193b53;box-sizing:border-box}.password-wrapper{position:relative}.password-wrapper .account-input{padding-right:65px}.portal-app .portal-content .toggle-password{position:absolute;right:8px;top:50%;transform:translateY(-50%);padding:6px!important;min-height:30px!important;min-width:0!important;border:0!important;border-radius:4px;background:transparent!important;color:#345e7c!important;font-size:11px!important;cursor:pointer}
.account-buttons{grid-column:2;display:flex;justify-content:flex-start;gap:10px;margin-top:20px}.portal-app .portal-content .account-save{display:inline-flex;align-items:center;justify-content:center;width:auto!important;min-height:40px;padding:10px 17px!important;border:1px solid #003e73!important;border-radius:6px!important;background:#003e73!important;color:#fff!important;font-size:12px!important;font-weight:650!important;cursor:pointer;box-shadow:none!important}.portal-app .portal-content .account-save:hover{background:#002f59!important}.security-info{grid-column:2;background:#f4f7fa;padding:12px 14px;border-radius:6px;color:#607587;font-size:11px!important;font-weight:400!important;line-height:1.8;margin-top:18px}.account-container .notice{padding:14px 16px;background:#edf4f9;color:#254c68;font-size:13px;border-radius:8px;margin-bottom:20px}
.portal-app .portal-content .account-edit-dialog{width:min(480px,calc(100vw - 32px));padding:26px;border:0;border-radius:12px;color:#193b53;box-shadow:0 24px 70px #071f3233}.account-edit-dialog::backdrop{background:#071f3299}.account-edit-dialog h2{font-size:20px!important;margin:0 0 22px}.account-edit-dialog label{display:block;font-size:12px;font-weight:600;margin:18px 0 8px}.account-edit-dialog p{font-size:12px!important;color:#607587}.portal-app .portal-content .account-edit-dialog button:not(.account-save){background:#fff;color:#486479;border:1px solid #ccd9e3;border-radius:6px;padding:10px 16px;font-size:12px}.account-container :focus-visible{outline:3px solid #0078b5;outline-offset:3px}
@media(max-width:750px){.portal-app .portal-content .account-section{grid-template-columns:minmax(0,1fr);padding:20px;gap:20px}.account-section-title{grid-column:1;grid-row:auto}.account-section-title p{max-width:none}.portal-app .portal-content .account-section .account-grid,.account-buttons,.security-info{grid-column:1}.account-buttons,.security-info{margin-top:0}.portal-app .portal-content .account-banner{padding:20px}.portal-app .portal-content .account-container .heading h1{font-size:25px!important}}
/* A dedicated settings composition, isolated from generic portal cards. */
.portal-app .portal-content .account-container{max-width:1120px!important;margin:0 auto!important}.coordinator-settings{display:grid;grid-template-columns:285px minmax(0,1fr);gap:28px;align-items:start}.settings-identity{padding:28px 24px;border:1px solid #dce5ed;border-radius:14px;background:#f1f5f8;position:sticky;top:24px}.settings-monogram{display:grid;place-items:center;width:64px;height:64px;border-radius:50%;background:#003e73;color:#fff;font-weight:700;font-size:20px;margin-bottom:20px}.portal-app .portal-content .settings-identity h2{font-size:21px!important;letter-spacing:-.025em;margin:0 0 6px!important;overflow-wrap:anywhere}.settings-identity>p{font-size:12px!important;color:#607587;margin:0}.settings-identity dl{padding-top:24px;margin:0}.settings-identity dl>div{margin-bottom:20px}.settings-identity dt{font-size:10px;font-weight:600;color:#607587;margin-bottom:6px}.settings-identity dd{font-size:12px;line-height:1.8;margin:0;color:#34566f;overflow-wrap:anywhere}.settings-identity nav{border-top:1px solid #dce5ed;padding-top:14px;margin-top:24px}.settings-identity nav a{display:flex;justify-content:space-between;align-items:center;gap:12px;font-size:12px;font-weight:600;text-decoration:none;color:#34566f;padding:12px 0}.settings-identity nav a:hover{color:#0078b5}.settings-content{min-width:0;border:1px solid #dce5ed;border-radius:14px;background:#fff;overflow:hidden}
.portal-app .portal-content .settings-content .account-section{display:block!important;border:0!important;border-bottom:1px solid #e2e9ef!important;border-radius:0!important;box-shadow:none!important;background:#fff!important;padding:28px 30px!important;margin:0!important;scroll-margin-top:20px}.portal-app .portal-content .settings-content .account-section:last-child{border-bottom:0!important}.portal-app .portal-content .settings-content .account-section-title{display:block!important;margin:0 0 24px!important}.portal-app .portal-content .settings-content .account-section-title h2{font-size:18px!important;letter-spacing:-.02em;margin:0 0 7px!important}.portal-app .portal-content .settings-content .account-section-title p{max-width:52ch;font-size:12px!important;line-height:1.7!important}.portal-app .portal-content .settings-content .account-readonly{grid-template-columns:repeat(2,minmax(0,1fr))!important;gap:22px!important}.portal-app .portal-content .settings-content .account-readonly>div{border:0!important;padding:0!important}.portal-app .portal-content .settings-content .account-security-stack{max-width:460px;gap:18px!important}.portal-app .portal-content .settings-content .account-input{background:#fbfcfd!important;min-height:46px!important}.portal-app .portal-content .settings-content .account-input:focus{background:#fff!important;border-color:#0078b5!important}.settings-content .account-buttons{margin-top:24px;padding-top:20px;border-top:1px solid #e6edf2;justify-content:flex-end}.settings-content .security-info{max-width:460px;background:transparent!important;padding:0!important;color:#607587;font-size:11px!important;line-height:1.8;margin-top:14px}.settings-content .account-edit-dialog .account-buttons{border:0;padding:0}.settings-content .account-edit-dialog{max-height:90dvh;overflow:auto}
@media(max-width:850px){.coordinator-settings{grid-template-columns:minmax(0,1fr);gap:20px}.settings-identity{position:static;display:grid;grid-template-columns:64px minmax(0,1fr);column-gap:18px;padding:22px}.settings-monogram{grid-row:1/3;margin:0}.settings-identity dl,.settings-identity nav{grid-column:1/-1}.settings-identity nav{display:flex;gap:24px;margin-top:4px}.settings-identity dl{display:flex;flex-wrap:wrap;gap:18px 30px}.settings-identity dl>div{margin:0}.portal-app .portal-content .settings-content .account-section{padding:22px!important}}@media(max-width:500px){.portal-app .portal-content .settings-content .account-readonly{grid-template-columns:1fr!important}.settings-identity nav{display:block}}
</style><link rel="stylesheet" href="Coordinator.css?v=review2" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<input type="hidden" name="csrfToken" value="<%= H(CsrfToken) %>" />

        <div class="layout">

            <!-- Sidebar -->


            <!-- Workspace -->
            <div class="workspace">

                <header class="topbar">
                    <span>University Internship Management System</span>
                    <span class="avatar">CO</span>
                </header>

                <main>
                    <div class="account-container">

                        <div class="heading">
                            <h1>My account</h1>
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

                        <div class="coordinator-settings">
                            <aside class="settings-identity">
                                <div class="settings-monogram" aria-hidden="true">CO</div>
                                <h2><%= H(FullName) %></h2>
                                <p>Internship coordinator</p>
                                <dl><div><dt>Sign-in email</dt><dd><%= H(Email) %></dd></div><div><dt>Account access</dt><dd>Coordinator workspace</dd></div></dl>
                                <nav aria-label="Account sections"><a href="#contactSettings">Contact details <span aria-hidden="true">→</span></a><a href="#passwordSettings">Password &amp; security <span aria-hidden="true">→</span></a></nav>
                            </aside>
                            <div class="settings-content">                        <!-- Contact Information -->

                        <section class="account-section" id="contactSettings">

                            <div class="account-section-title">
                                <div class="account-section-icon">
                                    &#9993;
                                </div>

                                <div>
                                    <h2>Contact details</h2>
                                    <p>Review your sign-in email and keep your phone number up to date.</p>
                                </div>
                            </div>

                            <div class="account-grid account-readonly"><div><p>Email</p><strong><%= H(Email) %></strong></div><div><p>Phone</p><strong><%= H(Phone) %></strong></div></div>
<div class="account-buttons"><button type="button" class="account-save" onclick="document.getElementById('contactEditor').showModal()">Edit contact details</button></div>
<dialog id="contactEditor" class="account-edit-dialog"><h2>Edit contact information</h2><label for="accountEmail">Email</label><input id="accountEmail" name="email" type="email" value="<%= H(Email) %>" readonly class="account-input"/><p>Email changes require authentication re-verification.</p><label for="accountPhone">Phone</label><input id="accountPhone" name="phone" type="tel" value="<%= H(Phone) %>" class="account-input"/><div class="account-buttons"><button type="button" onclick="document.getElementById('contactEditor').close()">Cancel</button><button type="submit" name="accountAction" value="saveContact" class="account-save" onclick="return validateContact()" formnovalidate>Save Changes</button></div></dialog>
</section>

                        <!-- Security Settings -->
                        <section class="account-section" id="passwordSettings">

                            <div class="account-section-title">
                                <div class="account-section-icon">
                                    &#128274;
                                </div>

                                <div>
                                    <h2>Password &amp; security</h2>
                                    <p>Choose a new password to protect your coordinator account.</p>
                                </div>
                            </div>

                            <div class="account-grid account-security-stack">

                                <div class="account-field">
                                    <label for="currentPassword">
                                        Current Password
                                    </label>

                                    <div class="password-wrapper">
                                        <input id="currentPassword"
                                               class="account-input"
                                               type="password"
                                               name="currentPassword"
                                               autocomplete="current-password"
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
                            </div></div>
                    </div>

                        </section>

                    </div>
                </main>

            </div>
        </div>



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
        PortalUI.message("Please enter a valid email address.", { title: "Please check this", kind: "error" });
        email.focus();
        return false;
    }

    if (phone.value.trim() &&
        !/^[+0-9()\s-]{7,25}$/.test(phone.value.trim())) {
        PortalUI.message("Please enter a valid phone number.", { title: "Please check this", kind: "error" });
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
        PortalUI.message("Please enter your current password.", { title: "Please check this", kind: "error" });
        current.focus();
        return false;
    }

    if (next.value.length < 8) {
        PortalUI.message("New password must contain at least 8 characters.", { title: "Please check this", kind: "error" });
        next.focus();
        return false;
    }

    if (next.value !== confirm.value) {
        PortalUI.message("New passwords do not match.", { title: "Please check this", kind: "error" });
        confirm.focus();
        return false;
    }

    if (current.value === next.value) {
        PortalUI.message("New password must be different from the current password.", { title: "Please check this", kind: "error" });
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
</asp:Content>

<%@ Page Title="Student Profile | UIMS" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="StudentProfile.aspx.cs" Inherits="PSUTInternship.Student.StudentProfile" %>

<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">

<style>
/* =========================================
   STUDENT PROFILE - PREMIUM DESIGN
   All styles scoped to this page
========================================= */

.sp-profile,
.sp-profile * {
    box-sizing: border-box;
}

.sp-profile {
    --sp-navy: #102c4b;
    --sp-blue: #1768e8;
    --sp-muted: #6e83a2;
    --sp-border: #e1eaf6;

    width: 100%;
    max-width: 1500px;
    margin: 0 auto;
    color: var(--sp-navy);
    font-family: inherit;
}

/* PAGE HEADER */

.sp-profile .sp-header {
    margin-bottom: 22px;
}

.sp-profile .sp-header h1 {
    margin: 0 0 7px;
    font-size: clamp(25px, 2.3vw, 31px);
    font-weight: 800;
    color: #102c4b;
}

.sp-profile .sp-header p {
    margin: 0;
    font-size: 13px;
    color: #7085a4;
}

/* SUPERVISOR BAR */

.sp-profile .sp-supervisor {
    display: flex;
    align-items: center;
    gap: 15px;
    padding: 17px 20px;
    margin-bottom: 18px;

    background: linear-gradient(
        110deg,
        #ffffff 0%,
        #f2f8ff 60%,
        #e2efff 100%
    );

    border: 1px solid #dfeafb;
    border-radius: 15px;
}

.sp-profile .sp-supervisor-icon {
    width: 50px;
    height: 50px;
    border-radius: 13px;
    background: #e4efff;
    color: #1768e8;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 23px;
    flex-shrink: 0;
}

.sp-profile .sp-supervisor-label {
    display: block;
    font-size: 12px;
    color: #6680a2;
    margin-bottom: 5px;
}

.sp-profile .sp-supervisor-name {
    font-size: 15px;
    font-weight: 800;
    color: #17385c;
}

/* GRID */

.sp-profile .sp-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 17px;
    align-items: start;
    margin-bottom: 17px;
}

.sp-profile .sp-bottom {
    display: grid;
    grid-template-columns: 1.15fr .85fr;
    gap: 17px;
    align-items: start;
}

/* CARDS */

.sp-profile .sp-card {
    background: #ffffff;
    border: 1px solid var(--sp-border);
    border-radius: 17px;
    padding: 22px 24px;
    min-width: 0;

    box-shadow: 0 5px 24px rgba(24, 64, 110, .04);
}

.sp-profile .sp-card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;

    padding-bottom: 16px;
    margin-bottom: 9px;

    border-bottom: 1px solid #edf1f7;
}

.sp-profile .sp-heading {
    display: flex;
    align-items: center;
    gap: 13px;
    min-width: 0;
}

.sp-profile .sp-icon {
    width: 47px;
    height: 47px;
    border-radius: 13px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    background: #e6f0ff;
    color: #1768e8;
    font-size: 22px;
}

.sp-profile .sp-icon.academic {
    background: #eceaff;
    color: #6455dc;
}

.sp-profile .sp-icon.professional {
    background: #e2f7eb;
    color: #159b5a;
}

.sp-profile .sp-icon.security {
    background: #fff0dc;
    color: #e38a0d;
}

.sp-profile .sp-heading h2 {
    font-size: 17px;
    font-weight: 800;
    margin: 0 0 5px;
    color: #122e50;
}

.sp-profile .sp-heading p {
    font-size: 12px;
    margin: 0;
    color: #7489a7;
}

/* BUTTONS */

.sp-profile .sp-edit {
    border: none;
    border-radius: 10px;
    background: #eaf3ff;
    color: #1766db;
    font-size: 12px;
    font-weight: 750;
    padding: 11px 18px;
    cursor: pointer;
    font-family: inherit;
    white-space: nowrap;
    transition: background .2s, transform .2s;
}

.sp-profile .sp-edit:hover {
    background: #dceaff;
    transform: translateY(-1px);
}

.sp-profile .sp-readonly {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    background: #eef2f7;
    color: #657e9e;
    border-radius: 10px;
    padding: 10px 13px;
    font-size: 12px;
    font-weight: 750;
    white-space: nowrap;
}

/* INFORMATION ROWS
   Works with Details() in StudentProfile.aspx.cs */

.sp-profile .profile-details {
    display: block;
    margin: 0;
    padding: 0;
}

.sp-profile .profile-details > div {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;

    padding: 13px 3px;
    border-bottom: 1px solid #edf2f8;
    min-width: 0;
}

.sp-profile .profile-details > div:last-child {
    border-bottom: none;
}

.sp-profile .profile-details dt {
    color: #6981a2;
    font-size: 12px;
    font-weight: 600;
    flex: 0 0 40%;
}

.sp-profile .profile-details dd {
    color: #173453;
    font-size: 13px;
    font-weight: 750;
    text-align: right;
    margin: 0;
    min-width: 0;
    overflow-wrap: anywhere;
}

.sp-profile .profile-details a {
    color: #1768df;
    text-decoration: none;
}

.sp-profile .profile-details a:hover {
    text-decoration: underline;
}

/* PROFESSIONAL */

.sp-profile .sp-professional .profile-details {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 10px;
    margin-top: 17px;
}

.sp-profile .sp-professional .profile-details > div {
    display: flex;
    gap: 10px;
    padding: 13px;
    border: 1px solid #e5edf7;
    border-radius: 11px;
    background: #fbfdff;
}

.sp-profile .sp-professional .profile-details dt {
    flex: 0 0 auto;
}

.sp-profile .sp-professional .profile-details dd {
    flex: 1;
}

/* SECURITY */

.sp-profile .sp-security-text {
    font-size: 12px;
    line-height: 1.8;
    color: #6e84a3;
    margin: 20px 0;
}

.sp-profile .sp-password-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 12px 18px;
    border-radius: 10px;
    background: #103b99;
    color: white;
    text-decoration: none;
    font-size: 12px;
    font-weight: 750;
    transition: background .2s;
}

.sp-profile .sp-password-btn:hover {
    background: #1768e8;
    color: white;
}

/* MESSAGE */

.sp-profile .sp-message {
    display: block;
    margin-bottom: 14px;
    font-size: 12px;
    color: #b91c1c;
}

.sp-profile .sp-message:empty {
    display: none;
}

/* EDIT MODALS */

.sp-profile .profile-editor {
    position: fixed;
    inset: 0;
    z-index: 1000;
    background: rgba(12, 33, 61, .48);
    backdrop-filter: blur(4px);

    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
}

.sp-profile .profile-dialog {
    position: relative;
    display: block;
    width: 100%;
    max-width: 570px;
    max-height: 90vh;
    overflow-y: auto;
    margin: auto;
    padding: 28px;

    background: white;
    color: #142d4b;
    border: 1px solid #dfe8f5;
    border-radius: 18px;
    box-shadow: 0 25px 70px rgba(0,0,0,.18);
}

.sp-profile .profile-dialog h2 {
    font-size: 21px;
    margin: 0 0 20px;
}

.sp-profile .fields {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16px;
}

.sp-profile .field {
    min-width: 0;
}

.sp-profile .field label {
    display: block;
    font-size: 12px;
    font-weight: 650;
    margin-bottom: 7px;
}

.sp-profile .profile-dialog input,
.sp-profile .profile-dialog select {
    width: 100%;
    padding: 12px;
    border: 1px solid #dce6f2;
    border-radius: 10px;
    font-family: inherit;
    font-size: 13px;
    outline: none;
    background: white;
    color: #142d4b;
}

.sp-profile .profile-dialog input:focus,
.sp-profile .profile-dialog select:focus {
    border-color: #1768e8;
    box-shadow: 0 0 0 3px rgba(23,104,232,.1);
}

.sp-profile .field-error {
    display: block;
    font-size: 11px;
    color: #c62828;
    margin-top: 5px;
}

.sp-profile .muted {
    font-size: 12px;
    color: #758aa6;
    line-height: 1.7;
    margin: 18px 0;
}

.sp-profile .portal-form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 20px;
}

.sp-profile .portal-form-actions .btn {
    border: none;
    background: #1768e8;
    color: white;
    border-radius: 10px;
    padding: 12px 18px;
    cursor: pointer;
    font-family: inherit;
    font-size: 12px;
    font-weight: 750;
}

.sp-profile .portal-form-actions .btn.light {
    background: #edf2f8;
    color: #36526f;
}

/* ENTRANCE ANIMATION */

@keyframes spFadeUp {
    from {
        opacity: 0;
        transform: translateY(13px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.sp-profile .sp-supervisor {
    animation: spFadeUp .45s ease both;
}

.sp-profile .sp-card {
    animation: spFadeUp .55s ease both;
}

/* RESPONSIVE */

@media (max-width: 1050px) {
    .sp-profile .sp-grid,
    .sp-profile .sp-bottom {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 600px) {
    .sp-profile .sp-card {
        padding: 17px;
    }

    .sp-profile .sp-card-header {
        flex-wrap: wrap;
    }

    .sp-profile .sp-professional .profile-details,
    .sp-profile .fields {
        grid-template-columns: 1fr;
    }

    .sp-profile .profile-details > div {
        align-items: flex-start;
    }

    .sp-profile .profile-details dt {
        flex-basis: 42%;
    }
}

@media (prefers-reduced-motion: reduce) {
    .sp-profile .sp-card,
    .sp-profile .sp-supervisor {
        animation: none;
    }
}
.sp-profile .sp-profile-link {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    max-width: 100%;
    padding: 9px 13px;
    border-radius: 9px;
    background: #eaf3ff;
    color: #1768e8;
    font-size: 12px;
    font-weight: 700;
    text-decoration: none;
    white-space: nowrap;
    transition: all .2s ease;
}

.sp-profile .sp-profile-link:hover {
    background: #1768e8;
    color: #fff;
    transform: translateY(-2px);
}

/* Equal height cards in both rows */

.sp-grid,
.sp-bottom {
    display: grid !important;
    grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
    gap: 20px;
    align-items: stretch !important;
}

/* Stretch cards to match their row */
.sp-grid > .sp-card,
.sp-bottom > .sp-card {
    height: 100% !important;
    min-height: 0;
    box-sizing: border-box;
    align-self: stretch !important;
}

/* Keep content aligned from the top */
.sp-card {
    display: flex;
    flex-direction: column;
}

/* Mobile responsive */
@media (max-width: 900px) {
    .sp-grid,
    .sp-bottom {
        grid-template-columns: 1fr !important;
    }

    .sp-grid > .sp-card,
    .sp-bottom > .sp-card {
        height: auto !important;
    }
}


</style>

<div class="sp-profile">

    <!-- PAGE TITLE -->
    <header class="sp-header">
        <h1>Student profile</h1>
        <p>
            Manage your personal, academic and professional information.
        </p>
    </header>

    <!-- ACADEMIC SUPERVISOR -->
    <div class="sp-supervisor">
        <span class="sp-supervisor-icon">&#127891;</span>
        <div>
            <span class="sp-supervisor-label">
                Academic supervisor
            </span>
            <span class="sp-supervisor-name">
                <asp:Label ID="assignedSupervisor" runat="server" />
            </span>
        </div>
    </div>

    <asp:Label
    ID="lblMessage"
    runat="server"
    CssClass="sp-message"
    role="status" />

<!-- PERSONAL + ACADEMIC -->
<div class="sp-grid">

    <section class="sp-card">

        <div class="sp-card-header">

            <div class="sp-heading">

                <div class="personal-icon"
                     style="width:60px; height:60px; min-width:60px;
                            background: #DBEAFE;; border-radius:17px;
                            display:flex; align-items:center;
                            justify-content:center; flex-shrink:0;">

                    <svg xmlns="http://www.w3.org/2000/svg"
                         width="30" height="30"
                         viewBox="0 0 24 24"
                         fill="none"
                         stroke="#155DFC"
                         stroke-width="2.3"
                         stroke-linecap="round"
                         stroke-linejoin="round">

                        <rect x="3" y="5" width="18" height="17" rx="2"/>
                        <path d="M8 3v4"/>
                        <path d="M16 3v4"/>
                        <circle cx="12" cy="12.5" r="3"/>
                        <path d="M6.5 20c.5-2.6 2.5-4 5.5-4s5 1.4 5.5 4"/>

                    </svg>
                </div>

                    <div>
                        <h2>Personal information</h2>
                        <p>Your basic personal details.</p>
                    </div>
                </div>

                <asp:Button
                    ID="EditPersonal"
                    runat="server"
                    Text="✎ Edit"
                    CommandArgument="Personal"
                    OnCommand="EditSection"
                    CssClass="sp-edit"
                    CausesValidation="false"
                    formnovalidate="formnovalidate" />
            </div>

            <asp:Literal
                ID="PersonalDetails"
                runat="server" />

        </section>

        <section class="sp-card">

            <div class="sp-card-header">
                <div class="sp-heading">
                    <span class="sp-icon academic">&#127891;</span>
                    <div>
                        <h2>Academic information</h2>
                        <p>Your university and academic details.</p>
                    </div>
                </div>

                <span class="sp-readonly">
                    &#128274; Read Only
                </span>
            </div>

            <asp:Literal
                ID="AcademicDetails"
                runat="server" />

        </section>

    </div>

    <!-- PROFESSIONAL + SECURITY -->
    <div class="sp-bottom">

        <section class="sp-card sp-professional">

            <div class="sp-card-header">
                <div class="sp-heading">
                    <span class="sp-icon professional">&#128188;</span>
                    <div>
                        <h2>Professional information</h2>
                        <p>Your professional links and portfolio.</p>
                    </div>
                </div>

                <asp:Button
                    ID="EditProfessional"
                    runat="server"
                    Text="✎ Edit"
                    CommandArgument="Professional"
                    OnCommand="EditSection"
                    CssClass="sp-edit"
                    CausesValidation="false"
                    formnovalidate="formnovalidate" />
            </div>

            <asp:Literal
                ID="ProfessionalDetails"
                runat="server" />

        </section>

        <section class="sp-card">

            <div class="sp-card-header">
                <div class="sp-heading">
                    <span class="sp-icon security">&#128737;</span>
                    <div>
                        <h2>Account security</h2>
                        <p>Keep your account secure.</p>
                    </div>
                </div>
            </div>

            <p class="sp-security-text">
                You can change your password at any time
                to keep your account safe.
            </p>

            <a href="../ChangePassword.aspx"
                class="sp-password-btn">
                &#128274; Change password
            </a>

        </section>

    </div>

    <!-- PERSONAL EDITOR -->
    <asp:Panel
        ID="PersonalEditor"
        runat="server"
        Visible="false"
        CssClass="profile-editor">

        <dialog class="profile-dialog"
            aria-label="Edit personal information">

            <h2>Edit personal information</h2>

            <asp:Label
                ID="PersonalError"
                runat="server"
                CssClass="field-error"
                role="alert" />

            <div class="fields">

                <div class="field">
                    <asp:Label
                        runat="server"
                        AssociatedControlID="txtDateOfBirth"
                        Text="Date of birth" />

                    <asp:TextBox
                        ID="txtDateOfBirth"
                        runat="server"
                        TextMode="Date" />

                    <asp:Label
                        ID="txtDateOfBirthError"
                        runat="server"
                        CssClass="field-error" />
                </div>

                <div class="field">
                    <asp:Label
                        runat="server"
                        AssociatedControlID="txtPhone"
                        Text="Phone number" />

                    <asp:TextBox
                        ID="txtPhone"
                        runat="server"
                        TextMode="Phone" />

                    <asp:Label
                        ID="txtPhoneError"
                        runat="server"
                        CssClass="field-error" />
                </div>

                <div class="field">
                    <asp:Label
                        runat="server"
                        AssociatedControlID="ddlGender"
                        Text="Gender" />

                    <asp:DropDownList
                        ID="ddlGender"
                        runat="server">

                        <asp:ListItem Value="">
                            Not specified
                        </asp:ListItem>

                        <asp:ListItem Value="Male">
                            Male
                        </asp:ListItem>

                        <asp:ListItem Value="Female">
                            Female
                        </asp:ListItem>

                    </asp:DropDownList>
                </div>

            </div>

            <p class="muted">
                Name and email are managed by the
                University Internship Coordinator.
            </p>

            <div class="portal-form-actions">

                <asp:Button
                    ID="CancelPersonal"
                    runat="server"
                    Text="Cancel"
                    OnClick="CancelSection"
                    CssClass="btn light"
                    CausesValidation="false"
                    formnovalidate="formnovalidate" />

                <asp:Button
                    ID="SavePersonal"
                    runat="server"
                    Text="Save changes"
                    CommandArgument="Personal"
                    OnCommand="SaveSection"
                    CssClass="btn" />

            </div>

        </dialog>
    </asp:Panel>

    <!-- PROFESSIONAL EDITOR -->
    <asp:Panel
        ID="ProfessionalEditor"
        runat="server"
        Visible="false"
        CssClass="profile-editor">

        <dialog class="profile-dialog"
            aria-label="Edit professional information">

            <h2>Edit professional information</h2>

            <asp:Label
                ID="ProfessionalError"
                runat="server"
                CssClass="field-error"
                role="alert" />

            <div class="fields">

                <div class="field">
                    <asp:Label
                        runat="server"
                        AssociatedControlID="txtGithub"
                        Text="GitHub URL" />

                    <asp:TextBox
                        ID="txtGithub"
                        runat="server"
                        TextMode="Url" />

                    <asp:Label
                        ID="txtGithubError"
                        runat="server"
                        CssClass="field-error" />
                </div>

                <div class="field">
                    <asp:Label
                        runat="server"
                        AssociatedControlID="txtLinkedin"
                        Text="LinkedIn URL" />

                    <asp:TextBox
                        ID="txtLinkedin"
                        runat="server"
                        TextMode="Url" />

                    <asp:Label
                        ID="txtLinkedinError"
                        runat="server"
                        CssClass="field-error" />
                </div>

                <div class="field">
                    <asp:Label
                        runat="server"
                        AssociatedControlID="txtPortfolio"
                        Text="Portfolio URL" />

                    <asp:TextBox
                        ID="txtPortfolio"
                        runat="server"
                        TextMode="Url" />

                    <asp:Label
                        ID="txtPortfolioError"
                        runat="server"
                        CssClass="field-error" />
                </div>

                <div class="field">
                    <asp:Label
                        runat="server"
                        AssociatedControlID="txtCV"
                        Text="CV URL" />

                    <asp:TextBox
                        ID="txtCV"
                        runat="server"
                        TextMode="Url" />

                    <asp:Label
                        ID="txtCVError"
                        runat="server"
                        CssClass="field-error" />
                </div>

            </div>

            <div class="portal-form-actions">

                <asp:Button
                    ID="CancelProfessional"
                    runat="server"
                    Text="Cancel"
                    OnClick="CancelSection"
                    CssClass="btn light"
                    CausesValidation="false"
                    formnovalidate="formnovalidate" />

                <asp:Button
                    ID="SaveProfessional"
                    runat="server"
                    Text="Save changes"
                    CommandArgument="Professional"
                    OnCommand="SaveSection"
                    CssClass="btn" />

            </div>

        </dialog>
    </asp:Panel>

</div>

</asp:Content>

<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="SupervisorAccount.aspx.cs" Inherits="internship_manegment.SupervisorAccount" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Supervisor Account</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
        *{
            box-sizing:border-box

        }
        body{
            font-family:Arial,sans-serif;
            margin:0;padding:28px

        }
        main{
            max-width:980px;
            margin:0 auto

        }
        .breadcrumb{
            font-size:13px;
            margin-bottom:12px

        }
        h1{
            font-size:28px;
            font-weight:500;
            margin:0 0 8px

        }
        .intro{
            margin:0 0 22px

        }
        .profile-card,.info-card,.lookup{
            border:1px solid;
            border-radius:12px;
            padding:24px;
            margin-bottom:16px

        }
        .profile-head{
            display:flex;
            align-items:center;
            gap:16px;
            padding-bottom:20px;
            border-bottom:1px solid

        }
        .avatar,.avatar-fallback{
            width:56px;
            height:56px;
            border-radius:16px;
            object-fit:cover;
            display:flex;
            align-items:center;
            justify-content:center;
            flex:0 0 56px

        }
        .profile-name{
            font-size:20px;
            margin-bottom:7px

        }
        .profile-subtitle{
            margin-bottom:8px

        }
        .badge{
            display:inline-block;
            border:1px solid;
            border-radius:16px;
            padding:4px 9px;
            font-size:12px

        }
        .section-title{
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:12px;margin:17px 0

        }
        h2{
            font-size:17px;
            font-weight:500;
            margin:0

        }
        .details-grid{
            display:grid;
            grid-template-columns:1fr 1fr;
            gap:16px 28px

        }
        .detail-label{
            font-size:13px;
            margin-bottom:4px

        }
        .detail-value{
            overflow-wrap:anywhere

        }
        .bottom-grid{
            display:grid;
            grid-template-columns:1.2fr 1fr;
            gap:16px

        }
        .card-description{
            font-size:13px;
            line-height:1.6;
            margin:8px 0 16px

        }
        .company-name{
            font-weight:bold;
            margin:10px 0 4px

        }
        .company-description,.security-note{
            font-size:13px;
            line-height:1.6

        }
        .trainee-count{
            margin-top:18px;
            padding-top:16px;
            border-top:1px solid

        }
        .button{
            display:inline-block;
            padding:9px 13px;
            border:1px solid;
            border-radius:7px;
            font:inherit;
            text-decoration:none;
            cursor:pointer

        }
        .field{
            margin:14px 0

        }
        .field label{
            display:block;
            font-weight:bold;
            margin-bottom:6px

        }
        input{
            width:100%;
            max-width:560px;
            padding:10px;
            border:1px solid;
            border-radius:5px;
            font:inherit

        }
        .edit-grid{
            display:grid;
            grid-template-columns:1fr 1fr;
            gap:0 18px

        }
        .actions{
            display:flex;
            gap:10px;
            margin-top:16px

        }
        .message{
            display:block;
            margin:12px 0;
            font-weight:bold

        }
        .lookup{
            max-width:600px

        }
        @media(max-width:650px){
            body{padding:16px}
            .profile-card,.info-card,.lookup{
                padding:18px

            }
            .bottom-grid,.details-grid,.edit-grid
            {
                grid-template-columns:1fr

            }
            .section-title{
                align-items:flex-start;
                flex-direction:column}

        }
    </style>
</head>
<body>
<form id="form1" runat="server" enctype="multipart/form-data">
    <main>
        <div class="breadcrumb">Workspace / Company Supervisor / Account</div>
        <h1>Supervisor Account</h1>
        <p class="intro">Manage your profile and company contact information.</p>

        <asp:Label ID="PageMessage" runat="server" CssClass="message" EnableViewState="false" />
        <asp:HiddenField ID="UserId" runat="server" />
        <asp:HiddenField ID="PreviewMode" runat="server" />
        <asp:HiddenField ID="OriginalName" runat="server" />
        <asp:HiddenField ID="OriginalEmail" runat="server" />
        <asp:HiddenField ID="OriginalPhone" runat="server" />

        <asp:Panel ID="ProfilePanel" runat="server" Visible="false">
            <section class="profile-card">
                <div class="profile-head">
                    <asp:Image ID="ProfilePhoto" runat="server" CssClass="avatar" AlternateText="Supervisor profile photo" Visible="false" />
                    <asp:Panel ID="PhotoFallback" runat="server" CssClass="avatar-fallback"><asp:Label ID="Initials" runat="server" /></asp:Panel>
                    <div>
                        <div class="profile-name"><asp:Label ID="HeaderName" runat="server" /></div>
                        <div class="profile-subtitle"><asp:Label ID="HeaderRoleAndCompany" runat="server" /></div>
                        <asp:Label ID="AccountStatus" runat="server" CssClass="badge" />
                    </div>
                </div>

                <asp:Panel ID="ProfileView" runat="server">
                    <div class="section-title"><h2>Personal Information</h2>
                        <asp:Button ID="EditProfile" runat="server" Text="Edit Profile" CssClass="button" OnClick="EditProfile_Click" /></div>
                    <div class="details-grid">
                        <div><div class="detail-label">Full Name</div><div class="detail-value"><asp:Label ID="ViewName" runat="server" /></div></div>
                        <div><div class="detail-label">Work Email</div><div class="detail-value"><asp:Label ID="ViewEmail" runat="server" /></div></div>
                        <div><div class="detail-label">Company</div><div class="detail-value"><asp:Label ID="ViewCompany" runat="server" /></div></div>
                        <div><div class="detail-label">Job Title</div><div class="detail-value"><asp:Label ID="ViewPosition" runat="server" /></div></div>
                        <div><div class="detail-label">Phone Number</div><div class="detail-value"><asp:Label ID="ViewPhone" runat="server" /></div></div>
                        <div><div class="detail-label">Account Role</div><div class="detail-value"><asp:Label ID="ViewRole" runat="server" /></div></div>
                    </div>
                </asp:Panel>

                <asp:Panel ID="ProfileEdit" runat="server" Visible="false">
                    <div class="section-title"><h2>Edit Personal Information</h2></div>
                    <div class="edit-grid">
                        <div class="field"><label for="EditName">Full Name</label><asp:TextBox ID="EditName" runat="server" MaxLength="100" /></div>
                        <div class="field"><label for="EditEmail">Work Email</label><asp:TextBox ID="EditEmail" runat="server" TextMode="Email" MaxLength="150" /></div>
                        <div class="field"><label for="EditPhone">Phone Number</label><asp:TextBox ID="EditPhone" runat="server" TextMode="Phone" MaxLength="40" /></div>
                        <div class="field"><label for="EditPhotoUrl">Profile Photo URL</label><asp:TextBox ID="EditPhotoUrl" runat="server" MaxLength="500" />
                            <label for="UploadPhoto">Or upload an image (up to 1 MB)</label><asp:FileUpload ID="UploadPhoto" runat="server" /></div>
                    </div>
                    <asp:HiddenField ID="CurrentPhotoUrl" runat="server" />
                    <div class="actions">
                        <asp:Button ID="SaveProfile" runat="server" Text="Save Changes" CssClass="button" OnClick="SaveProfile_Click" />
                        <asp:Button ID="CancelEdit" runat="server" Text="Cancel" CssClass="button" CausesValidation="false" OnClick="CancelEdit_Click" />
                    </div>
                </asp:Panel>
            </section>

            <div class="bottom-grid">
                <section class="info-card">
                    <h2>Company Information</h2>
                    <p class="card-description">Your company is associated with your supervisor account.</p>
                    <div class="company-name"><asp:Label ID="CompanyNameCard" runat="server" /></div>
                    <div class="company-description"><asp:Label ID="CompanyDescription" runat="server" /></div>
                    <div class="trainee-count"><strong><asp:Label ID="TraineeCount" runat="server" Text="0" /> active trainees</strong><div class="card-description">Assigned to your supervision</div></div>
                </section>
                <section class="info-card">
                    <h2>Account Security</h2>
                    <p class="card-description">Keep your account details secure.</p>
                    <p class="security-note">Password changes are managed through Firebase Authentication.</p>
                </section>
            </div>
        </asp:Panel>
    </main>
</form>
</body>
</html>

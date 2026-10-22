<%@ Register Src="~/Shared/StudentLinks.ascx" TagPrefix="psut" TagName="StudentLinks" %>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentProfile.aspx.cs" Async="true" Inherits="PSUTInternship.Student.StudentProfile" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Student Profile</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f3f6fb;
            color: #1e293b;
        }

        .page {
            max-width: 1050px;
            margin: 40px auto;
            padding: 20px;
        }

        .header {
            background: linear-gradient(135deg, #1d4ed8, #3b82f6);
            color: white;
            padding: 30px;
            border-radius: 18px;
            margin-bottom: 25px;
        }

        .header h1 {
            margin: 0 0 10px;
        }

        .header p {
            margin: 0;
            opacity: .9;
        }

        .card {
            background: white;
            padding: 28px;
            border-radius: 16px;
            margin-bottom: 22px;
            box-shadow: 0 5px 20px rgba(15,23,42,.05);
        }

        .section-title {
            display: flex;
            align-items: center;
            gap: 10px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 15px;
            margin-bottom: 22px;
            color: #1d4ed8;
        }

        .section-title h2 {
            font-size: 21px;
            margin: 0;
        }

        .fields {
            display: grid;
            grid-template-columns: repeat(2, minmax(0,1fr));
            gap: 20px;
        }

        .field label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: bold;
        }

        .field input,
        .field select {
            width: 100%;
            padding: 12px;
            border: 1px solid #cbd5e1;
            border-radius: 9px;
            font-size: 15px;
            background: white;
        }

        .field input:disabled,
        .field select:disabled {
            background: #f8fafc;
            color: #475569;
        }

        .professional-heading {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 25px;
        }

        .professional-icon {
            background: #e0f2fe;
            padding: 13px;
            border-radius: 12px;
            font-size: 24px;
        }

        .professional-heading h2 {
            margin: 0;
            font-size: 21px;
        }

        .professional-heading p {
            color: #64748b;
            font-size: 14px;
        }

        .professional-fields {
            display: grid;
            gap: 20px;
        }

        .professional-field label {
            display: block;
            margin-bottom: 9px;
            font-size: 14px;
            font-weight: 600;
        }

        .professional-input {
            width: 100%;
            padding: 14px 16px;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            font-size: 14px;
        }

        .professional-input:disabled {
            background: #f8fafc;
            color: #475569;
        }

        .professional-input:focus {
            outline: none;
            border-color: #0d9488;
            box-shadow: 0 0 0 3px #ccfbf1;
        }

        .cv-upload {
            margin-top: 28px;
            padding: 30px;
            text-align: center;
            border: 2px dashed #cbd5e1;
            border-radius: 14px;
            background: #f8fafc;
        }

        .upload-icon {
            font-size: 36px;
            margin-bottom: 10px;
        }

        .cv-upload h3 {
            margin: 0;
        }

        .cv-upload p {
            color: #64748b;
            font-size: 13px;
        }

        .cv-file-input {
            display: block;
            margin: 18px auto;
            max-width: 100%;
        }

        .floating-edit-btn {
            position: fixed;
            right: 30px;
            bottom: 30px;
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 50px;
            padding: 15px 25px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            z-index: 1000;
            box-shadow: 0 8px 25px rgba(37,99,235,.3);
            transition: .3s;
        }

        .floating-edit-btn:hover {
            background: #1d4ed8;
            transform: translateY(-3px);
        }

        .message {
            display: block;
            margin-top: 15px;
            font-size: 14px;
        }

        @media (max-width: 650px) {
            .page {
                margin: 10px auto;
                padding: 12px;
            }

            .fields {
                grid-template-columns: 1fr;
            }

            .card {
                padding: 20px;
            }

            .floating-edit-btn {
                right: 15px;
                bottom: 15px;
                padding: 12px 18px;
                font-size: 13px;
            }
        }
            .cv-upload a {
    display: inline-block;
    margin: 15px;
    padding: 12px 20px;
    background: #0d9488;
    color: white;
    border-radius: 9px;
    text-decoration: none;
    font-weight: 600;
}

.cv-upload a:hover {
    background: #0f766e;
}

.cv-upload .btn {
    border: none;
    padding: 12px 20px;
    border-radius: 9px;
    background: #2563eb;
    color: white;
    cursor: pointer;
}

.cv-section {
    margin-top: 25px;
    padding: 22px;
    background: #f8fbff;
    border: 1px solid #dbe7f3;
    border-radius: 14px;
}

.cv-heading {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 18px;
}

.cv-heading span {
    font-size: 28px;
}

.cv-heading h3 {
    margin: 0;
    font-size: 17px;
    color: #061b70;
}

.cv-heading p {
    margin: 5px 0 0;
    font-size: 13px;
    color: #64748b;
}

.cv-view-btn {
    display: inline-block;
    margin-top: 15px;
    padding: 11px 20px;
    background: #005b9a;
    color: white !important;
    text-decoration: none;
    border-radius: 9px;
    font-size: 14px;
    font-weight: 600;
    transition: 0.2s;
}

.cv-view-btn:hover {
    background: #061b70;
    transform: translateY(-2px);
}

        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
<psut:StudentLinks runat="server" />

        <main class="page">

            <header class="header">
                <h1>Student Profile</h1>
                <p>Manage your personal and academic information.</p>
            </header>

            <p>Academic supervisor: <asp:Label ID="assignedSupervisor" runat="server" /></p>
            <!-- Personal Information -->
            <section class="card">
                <div class="section-title">
                    <span>👤</span>
                    <h2>Personal Information</h2>
                </div>

                <div class="fields">

                    <div class="field">
                        <label>Full Name</label>
                        <asp:TextBox ID="txtFullName" runat="server"
                            Enabled="false" />
                    </div>

                    <div class="field">
                        <label>Date of Birth</label>
                        <asp:TextBox ID="txtDateOfBirth" runat="server"
                            TextMode="Date" Enabled="false" />
                    </div>

                    <div class="field">
                        <label>Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server"
                            TextMode="Email" Enabled="false" />
                    </div>

                    <div class="field">
                        <label>Phone Number</label>
                        <asp:TextBox ID="txtPhone" runat="server"
                            TextMode="Phone" MaxLength="20"
                            Enabled="false" />
                    </div>

                    <div class="field">
                        <label>Gender</label>
                        <asp:DropDownList ID="ddlGender"
                            runat="server" Enabled="false">
                            <asp:ListItem Text="Select Gender" Value="" />
                            <asp:ListItem Text="Male" Value="Male" />
                            <asp:ListItem Text="Female" Value="Female" />
                        </asp:DropDownList>
                    </div>

                </div>
            </section>

            <!-- Academic Information -->
            <section class="card">
                <div class="section-title">
                    <span>🎓</span>
                    <h2>Academic Information</h2>
                </div>

                <div class="fields">

                    <div class="field">
                        <label>Student ID</label>
                        <asp:TextBox ID="txtStudentId"
                            runat="server" Enabled="false" />
                    </div>

                    <div class="field">
                        <label>University</label>
                        <asp:TextBox ID="txtUniversity"
                            runat="server" Enabled="false" />
                    </div>

                    <div class="field">
                        <label>Faculty</label>
                        <asp:TextBox ID="txtFaculty"
                            runat="server" Enabled="false" />
                    </div>

                    <div class="field">
                        <label>Major</label>
                        <asp:TextBox ID="txtMajor"
                            runat="server" Enabled="false" />
                    </div>

                    <div class="field">
                        <label>GPA (0–4)</label>
                        <asp:TextBox ID="txtGPA"
                            runat="server" Enabled="false" />
                    </div>

                    <div class="field">
                        <label>Academic Semester</label>
                        <asp:TextBox ID="txtSemester"
                            runat="server" Enabled="false" />
                    </div>

                    <div class="field">
                        <label>Completed Credit Hours</label>
                        <asp:TextBox ID="txtCompletedHours"
                            runat="server" Enabled="false" />
                    </div>

                    <div class="field">
                        <label>Application Date</label>
                        <asp:TextBox ID="txtApplicationDate"
                            runat="server" Enabled="false" />
                    </div>

                </div>
            </section>

            <!-- Professional Information -->
            <section class="card">

                <div class="professional-heading">
                    <div class="professional-icon">💼</div>
                    <div>
                        <h2>Professional Information</h2>
                        <p>Complete your professional profile to showcase your skills.</p>
                    </div>
                </div>

                
<div class="professional-fields">

    <!-- GitHub -->
    <div class="cv-section">
        <div class="cv-heading">
            <span>💻</span>
            <div>
                <h3>GitHub Profile</h3>
                <p>Showcase your coding projects.</p>
            </div>
        </div>

        <asp:TextBox ID="txtGithub" runat="server"
            CssClass="professional-input"
            TextMode="Url"
            Enabled="false"
            placeholder="https://github.com/username" />

        <asp:HyperLink ID="lnkGithub" runat="server"
            CssClass="cv-view-btn"
            Text="↗ View GitHub"
            Target="_blank"
            Visible="false" />
    </div>

    <!-- LinkedIn -->
    <div class="cv-section">
        <div class="cv-heading">
            <span>💼</span>
            <div>
                <h3>LinkedIn Profile</h3>
                <p>Share your professional experience.</p>
            </div>
        </div>

        <asp:TextBox ID="txtLinkedin" runat="server"
            CssClass="professional-input"
            TextMode="Url"
            Enabled="false"
            placeholder="https://linkedin.com/in/username" />

        <asp:HyperLink ID="lnkLinkedin" runat="server"
            CssClass="cv-view-btn"
            Text="↗ View LinkedIn"
            Target="_blank"
            Visible="false" />
    </div>

    <!-- Portfolio -->
    <div class="cv-section">
        <div class="cv-heading">
            <span>🌐</span>
            <div>
                <h3>Portfolio</h3>
                <p>Present your work and achievements.</p>
            </div>
        </div>

        <asp:TextBox ID="txtPortfolio" runat="server"
            CssClass="professional-input"
            TextMode="Url"
            Enabled="false"
            placeholder="https://yourportfolio.com" />

        <asp:HyperLink ID="lnkPortfolio" runat="server"
            CssClass="cv-view-btn"
            Text="↗ View Portfolio"
            Target="_blank"
            Visible="false" />
    </div>

</div>

<div class="professional-field">
    
<div class="cv-section">

    <div class="cv-heading">
        <span>📄</span>
        <div>
            <h3>Curriculum Vitae (CV)</h3>
            <p>Add a link to your CV.</p>
        </div>
    </div>

    <asp:TextBox
        ID="txtCV"
        runat="server"
        CssClass="professional-input"
        TextMode="Url"
        Enabled="false"
        placeholder="https://example.com/mycv.pdf" />

    <asp:HyperLink
        ID="lnkCV"
        runat="server"
        CssClass="cv-view-btn"
        Text="↗ View My CV"
        Target="_blank"
        Visible="false" />

</div>

            </section>

            <asp:Label ID="lblMessage"
                runat="server"
                CssClass="message" />

            <!-- Floating Edit / Save Button -->
            <asp:Button ID="btnEditProfile"
                runat="server"
                Text="Edit Profile"
                CssClass="floating-edit-btn"
                OnClick="btnEditProfile_Click" />

        </main>

    </form>
</body>
</html>

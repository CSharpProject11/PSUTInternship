<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentProfile.aspx.cs"  Async="true" Inherits="Student.StudentProfile" %>


<%@ Register Src="~/Student/StudentNav.ascx" TagPrefix="psut" TagName="StudentNav" %>
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
            box-shadow: 0 5px 20px rgba(15, 23, 42, .05);
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
            grid-template-columns: repeat(2, minmax(0, 1fr));
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
            background: #fff;
        }

        .field input:disabled,
        .field select:disabled {
            background: #f8fafc;
            color: #475569;
            cursor: default;
        }

        .actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 25px;
        }

        .btn {
            border: none;
            border-radius: 9px;
            padding: 12px 24px;
            font-size: 15px;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-edit {
            background: #2563eb;
            color: white;
        }

        .btn-save {
            background: #059669;
            color: white;
        }

        .btn-cancel {
            background: #e2e8f0;
            color: #334155;
        }

        .message {
            display: block;
            margin-top: 15px;
            padding: 12px;
            border-radius: 8px;
        }

        .error {
            color: #b91c1c;
            background: #fee2e2;
        }

        .success {
            color: #047857;
            background: #d1fae5;
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

            .header {
                padding: 24px;
            }
        }
        .professional-card {
    padding: 30px;
    border-radius: 16px;
}

.professional-heading {
    display: flex;
    align-items: center;
    gap: 15px;
    margin-bottom: 30px;
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
    color: #0f172a;
}

.professional-heading p {
    margin-top: 6px;
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
    color: #334155;
}

.professional-input {
    width: 100%;
    box-sizing: border-box;
    padding: 14px 16px;
    border: 1px solid #cbd5e1;
    border-radius: 10px;
    font-size: 14px;
    outline: none;
    transition: 0.2s;
}

.professional-input:focus {
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
    font-size: 17px;
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

.professional-save {
    width: 100%;
    margin-top: 25px;
    padding: 15px;
    background: #0f172a;
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: 0.2s;
}

.professional-save:hover {
    background: #0d9488;
}

@media (max-width: 600px) {
    .professional-card {
        padding: 18px;
    }

    .professional-heading {
        align-items: flex-start;
    }

    .cv-upload {
        padding: 20px 12px;
    }
}
    </style>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/student-workspace.css") %>" />
</head>

<body class="student-page">
    <form id="form1" runat="server">
    <div class="student-shell">
        <psut:StudentNav runat="server" />
        <main id="student-main" class="student-main sd-profile" tabindex="-1">

            <header class="header">
                <h1>Student Profile</h1>
                <p>Manage your personal and academic information.</p>
            </header>

            <section class="card">
                <div class="section-title">
                    <span><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg></span>
                    <h2>Personal Information</h2>
                </div>

                <div class="fields">
                    <div class="field">
                        <label for="txtFullName">Full Name</label>
                        <asp:TextBox ID="txtFullName" runat="server"
                            MaxLength="100" Enabled="false" />
                    </div>

                    <div class="field">
                        <label for="txtDateOfBirth">Date of Birth</label>
                        <asp:TextBox ID="txtDateOfBirth" runat="server"
                            TextMode="Date" Enabled="false" />
                    </div>

                    <div class="field">
                        <label for="txtEmail">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server"
                            TextMode="Email" MaxLength="150" Enabled="false" />
                    </div>

                    <div class="field">
                        <label for="txtPhone">Phone Number</label>
                        <asp:TextBox ID="txtPhone" runat="server"
                            TextMode="Phone" MaxLength="20" Enabled="false" />
                    </div>

                    <div class="field">
                        <label for="ddlGender">Gender</label>
                        <asp:DropDownList ID="ddlGender" runat="server"
                            Enabled="false">
                            <asp:ListItem Text="Select gender" Value="" />
                            <asp:ListItem Text="Male" Value="Male" />
                            <asp:ListItem Text="Female" Value="Female" />
                        </asp:DropDownList>
                    </div>

                    <div class="field">
                        <label for="txtAddress">Address</label>
                        <asp:TextBox ID="txtAddress" runat="server"
                            MaxLength="200" Enabled="false" />
                    </div>
                </div>
            </section>

            <section class="card">
                <div class="section-title">
                    <span><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m2 9 10-5 10 5-10 5L2 9zm4 3v5c4 3 8 3 12 0v-5M22 9v7"/></svg></span>
                    <h2>Academic Information</h2>
                </div>

                <div class="fields">
                    <div class="field">
                        <label for="txtStudentId">Student ID</label>
                        <asp:TextBox ID="txtStudentId" runat="server"
                            MaxLength="30" Enabled="false" />
                    </div>

                    <div class="field">
                        <label for="txtUniversity">University</label>
                        <asp:TextBox ID="txtUniversity" runat="server"
                            MaxLength="150" Enabled="false" />
                    </div>

                    <div class="field">
                        <label for="txtFaculty">Faculty</label>
                        <asp:TextBox ID="txtFaculty" runat="server"
                            MaxLength="100" Enabled="false" />
                    </div>

                    <div class="field">
                        <label for="txtMajor">Major</label>
                        <asp:TextBox ID="txtMajor" runat="server"
                            MaxLength="100" Enabled="false" />
                    </div>

                    <div class="field">
                        <label for="txtAcademicYear">Academic Year</label>
                        <asp:TextBox ID="txtAcademicYear" runat="server"
                            MaxLength="30" Enabled="false" />
                    </div>

                    <div class="field">
                        <label for="txtGPA">GPA (0–4)</label>
                        <asp:TextBox ID="txtGPA" runat="server"
                            TextMode="Number" Enabled="false" />
                    </div>
                </div>
            </section>

           
            <section class="card professional-card">

    <div class="professional-heading">
        <div class="professional-icon"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="7" width="18" height="14" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M3 12h18"/></svg></div>
        <div>
            <h2>Professional Information</h2>
            <p>
                Complete your professional profile
                to showcase your skills.
            </p>
        </div>
    </div>

    <div class="professional-fields">

        <div class="professional-field">
            <label>GitHub URL</label>
            <asp:TextBox ID="txtGithub"
                runat="server"
                CssClass="professional-input"
                TextMode="Url"
                placeholder="https://github.com/username" />
        </div>

        <div class="professional-field">
            <label>LinkedIn URL</label>
            <asp:TextBox ID="txtLinkedin"
                runat="server"
                CssClass="professional-input"
                TextMode="Url"
                placeholder="https://linkedin.com/in/username" />
        </div>

        <div class="professional-field">
            <label>Portfolio URL</label>
            <asp:TextBox ID="txtPortfolio"
                runat="server"
                CssClass="professional-input"
                TextMode="Url"
                placeholder="https://yourportfolio.com" />
        </div>

    </div>

    <div class="cv-upload">
        <div class="upload-icon"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 18H6a4 4 0 0 1-.6-8 7 7 0 0 1 13.2 1A3.5 3.5 0 0 1 18 18h-1M12 21V12m-3 3 3-3 3 3"/></svg></div>
        <h3>Upload your CV</h3>
        <p>PDF file · Maximum 5 MB</p>

        <asp:FileUpload ID="fileCV"
            runat="server"
            CssClass="cv-file-input"
            accept=".pdf,application/pdf" />

        <asp:HyperLink ID="lnkCV"
            runat="server"
            Text="View Current CV"
            Target="_blank"
            Visible="false" />
    </div>

    <asp:Button ID="btnSaveProfessional"
        runat="server"
        Text="Save Professional Information"
        CssClass="professional-save"
        OnClick="btnSaveProfessional_Click" />

</section>

        <nav class="sd-profile-links" aria-label="Account links"><a href="<%= ResolveUrl("~/") %>">PSUT homepage</a><a href="<%= ResolveUrl("~/Logout.aspx") %>">Sign out</a></nav>
        </main>
    </div>
    </form>
</body>
</html>


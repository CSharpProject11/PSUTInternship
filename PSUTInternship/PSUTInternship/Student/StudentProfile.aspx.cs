
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI.WebControls;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;

namespace PSUTInternship.Student
{
    public partial class StudentProfile : PortalPage
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                await LoadProfile();
            }
        }

        private async Task LoadProfile()
        {
            try
            {
                lblMessage.Text = "";

                var profile = await PortalRepository.Get<JObject>(
                    "students/" + PortalRepository.Key(CurrentProfileId)
                );

                if (profile == null)
                {
                    throw new InvalidOperationException(
                        "Student profile not found."
                    );
                }

                // Academic Supervisor
                assignedSupervisor.Text = Server.HtmlEncode(
                    DatabaseSchema.FirstText(
                        profile,
                        "academicSupervisorName"
                    )
                );

                // Personal Information
                PersonalDetails.Text = Details(
                    profile,
                    new[]
                    {
                        "Full name",
                        "Email address",
                        "Date of birth",
                        "Phone number",
                        "Gender"
                    },
                    new[]
                    {
                        "fullName",
                        "email",
                        "dateOfBirth",
                        "phone",
                        "gender"
                    }
                );

                // Academic Information - READ ONLY
                AcademicDetails.Text = Details(
                    profile,
                    new[]
                    {
                        "Student ID",
                        "University",
                        "Faculty",
                        "Major",
                        "GPA",
                        "Semester",
                        "Completed credit hours",
                        "Application date"
                    },
                    new[]
                    {
                        "studentNumber",
                        "university",
                        "college",
                        "major",
                        "gpa",
                        "academicSemester",
                        "completedCreditHours",
                        "applicationDate"
                    }
                );

                // Professional Information
                ProfessionalDetails.Text = Details(
                    profile,
                    new[]
                    {
                        "GitHub",
                        "LinkedIn",
                        "Portfolio",
                        "CV"
                    },
                    new[]
                    {
                        "githubUrl",
                        "linkedinUrl",
                        "portfolioUrl",
                        "cvUrl"
                    }
                );

                // Personal Editor
                txtDateOfBirth.Text =
                    (string)profile["dateOfBirth"];

                txtPhone.Text = DatabaseSchema.FirstText(
                    profile,
                    "phone",
                    "phoneNumber"
                );

                string gender = (string)profile["gender"] ?? "";

                if (ddlGender.Items.FindByValue(gender) != null)
                {
                    ddlGender.SelectedValue = gender;
                }

                // Professional Editor
                txtGithub.Text = (string)profile["githubUrl"];
                txtLinkedin.Text = (string)profile["linkedinUrl"];
                txtPortfolio.Text = (string)profile["portfolioUrl"];
                txtCV.Text = (string)profile["cvUrl"];
            }
            catch (Exception ex)
            {
                lblMessage.Text =
                    Server.HtmlEncode(ex.Message);
            }
        }

        private string Details(
            JObject profile,
            string[] labels,
            string[] fields)
        {
            string html = "<dl class='profile-details'>";

            for (int i = 0; i < fields.Length; i++)
            {
                string text = DatabaseSchema.FirstText(
                    profile,
                    fields[i]
                );

                if (fields[i] == "phone")
                {
                    text = DatabaseSchema.FirstText(
                        profile,
                        "phone",
                        "phoneNumber"
                    );
                }

                if (fields[i] == "college")
                {
                    text = DatabaseSchema.FirstText(
                        profile,
                        "college",
                        "faculty"
                    );
                }

                string content = Server.HtmlEncode(
                    string.IsNullOrWhiteSpace(text)
                        ? "Not recorded"
                        : text
                );

                Uri link;

                if (fields[i].EndsWith("Url") &&
     Uri.TryCreate(text, UriKind.Absolute, out link) &&
     link.Scheme == Uri.UriSchemeHttps)
                {
                    string linkText = "View " + labels[i];

                    content = "<a class='sp-profile-link' href='" +
                              System.Web.HttpUtility.HtmlAttributeEncode(link.AbsoluteUri) +
                              "' target='_blank' rel='noopener noreferrer'>" +
                              Server.HtmlEncode(linkText) +
                              " &#8599;</a>";
                }

                html +=
                    "<div class='detail-item'>" +
                        "<dt>" +
                            Server.HtmlEncode(labels[i]) +
                        "</dt>" +
                        "<dd>" +
                            content +
                        "</dd>" +
                    "</div>";
            }

            return html + "</dl>";
        }

        protected async void EditSection(
            object sender,
            CommandEventArgs e)
        {
            string group = Convert.ToString(e.CommandArgument);

            if (group != "Personal" &&
                group != "Professional")
            {
                lblMessage.Text =
                    "You cannot edit academic information.";
                return;
            }

            await LoadProfile();

            PersonalEditor.Visible = group == "Personal";
            ProfessionalEditor.Visible = group == "Professional";
        }

        protected void CancelSection(
            object sender,
            EventArgs e)
        {
            PersonalEditor.Visible = false;
            ProfessionalEditor.Visible = false;
        }

        protected async void SaveSection(
            object sender,
            CommandEventArgs e)
        {
            PersonalError.Text = "";
            ProfessionalError.Text = "";

            var changes = new Dictionary<string, object>();

            string group = Convert.ToString(e.CommandArgument);

            try
            {
                if (group == "Personal")
                {
                    string phone = txtPhone.Text.Trim();

                    if (!System.Text.RegularExpressions.Regex.IsMatch(
                        phone,
                        @"\A[+0-9 ()-]{7,20}\z"))
                    {
                        throw new ArgumentException(
                            "Enter a valid phone number of 7–20 characters."
                        );
                    }

                    DateTime dob;

                    if (txtDateOfBirth.Text.Length > 0 &&
                        (!DateTime.TryParseExact(
                            txtDateOfBirth.Text,
                            "yyyy-MM-dd",
                            CultureInfo.InvariantCulture,
                            DateTimeStyles.None,
                            out dob
                        ) || dob.Date >= TaskWorkflow.Today))
                    {
                        throw new ArgumentException(
                            "Enter a date of birth in the past."
                        );
                    }

                    changes["phone"] = phone;
                    changes["dateOfBirth"] = txtDateOfBirth.Text;
                    changes["gender"] = ddlGender.SelectedValue;
                }
                else if (group == "Professional")
                {
                    var links = new Dictionary<string, TextBox>
                    {
                        { "githubUrl", txtGithub },
                        { "linkedinUrl", txtLinkedin },
                        { "portfolioUrl", txtPortfolio },
                        { "cvUrl", txtCV }
                    };

                    foreach (var pair in links)
                    {
                        Uri url;

                        string value = pair.Value.Text.Trim();

                        if (value.Length > 2000 ||
                            (value.Length > 0 &&
                             (!Uri.TryCreate(
                                 value,
                                 UriKind.Absolute,
                                 out url
                             ) ||
                              url.Scheme != Uri.UriSchemeHttps)))
                        {
                            throw new ArgumentException(
                                "Use valid HTTPS profile links of at most 2,000 characters."
                            );
                        }

                        changes[pair.Key] = value;
                    }
                }
                else
                {
                    throw new InvalidOperationException(
                        "You cannot edit this profile section."
                    );
                }

                await PortalRepository.Patch(
                    "students/" +
                    PortalRepository.Key(CurrentProfileId),
                    changes
                );

                CancelSection(sender, EventArgs.Empty);

                await LoadProfile();

                lblMessage.Text = "Profile changes saved.";
            }
            catch (Exception ex)
            {
                var error = group == "Personal"
                    ? PersonalError
                    : ProfessionalError;

                error.Text = Server.HtmlEncode(ex.Message);
            }
        }
    }
}

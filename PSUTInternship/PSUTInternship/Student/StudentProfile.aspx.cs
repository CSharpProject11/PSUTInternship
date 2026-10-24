using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI.WebControls;
using Newtonsoft.Json.Linq;
using PSUTInternship.Shared;
namespace PSUTInternship.Student {
    public partial class StudentProfile : PortalPage {
        protected async void Page_Load(object sender, EventArgs e) { if (!IsPostBack) await LoadProfile(); }
        private async Task LoadProfile() {
            try {
                var profile = await PortalRepository.Get<JObject>("students/" + PortalRepository.Key(CurrentProfileId));
                if (profile == null) throw new InvalidOperationException("Student profile not found.");
                assignedSupervisor.Text = Server.HtmlEncode(DatabaseSchema.FirstText(profile, "academicSupervisorName"));
                PersonalDetails.Text = Details(profile, new[] { "Full name", "Email address", "Date of birth", "Phone number", "Gender" }, new[] { "fullName", "email", "dateOfBirth", "phone", "gender" });
                AcademicDetails.Text = Details(profile, new[] { "Student ID", "University", "Faculty", "Major", "GPA", "Semester", "Completed credit hours", "Application date" }, new[] { "studentNumber", "university", "college", "major", "gpa", "academicSemester", "completedCreditHours", "applicationDate" });
                ProfessionalDetails.Text = Details(profile, new[] { "GitHub", "LinkedIn", "Portfolio", "CV" }, new[] { "githubUrl", "linkedinUrl", "portfolioUrl", "cvUrl" });
                txtDateOfBirth.Text = (string)profile["dateOfBirth"]; txtPhone.Text = DatabaseSchema.FirstText(profile, "phone", "phoneNumber");
                string gender = (string)profile["gender"] ?? ""; if (ddlGender.Items.FindByValue(gender) != null) ddlGender.SelectedValue = gender;
                txtGPA.Text = (string)profile["gpa"]; txtSemester.Text = (string)profile["academicSemester"]; txtCompletedHours.Text = (string)profile["completedCreditHours"]; txtApplicationDate.Text = (string)profile["applicationDate"];
                txtGithub.Text = (string)profile["githubUrl"]; txtLinkedin.Text = (string)profile["linkedinUrl"]; txtPortfolio.Text = (string)profile["portfolioUrl"]; txtCV.Text = (string)profile["cvUrl"];
            } catch (Exception ex) { lblMessage.Text = Server.HtmlEncode(ex.Message); }
        }
        private string Details(JObject profile, string[] labels, string[] fields) {
            string html = "<dl class='profile-details'>";
            for (int i = 0; i < fields.Length; i++) {
                string text = DatabaseSchema.FirstText(profile, fields[i]);
                if (fields[i] == "phone") text = DatabaseSchema.FirstText(profile, "phone", "phoneNumber");
                if (fields[i] == "college") text = DatabaseSchema.FirstText(profile, "college", "faculty");
                string content = Server.HtmlEncode(string.IsNullOrWhiteSpace(text) ? "Not recorded" : text); Uri link;
                if (fields[i].EndsWith("Url") && Uri.TryCreate(text,UriKind.Absolute,out link) && link.Scheme == "https") content = "<a href='" + System.Web.HttpUtility.HtmlAttributeEncode(link.AbsoluteUri) + "' target='_blank' rel='noopener noreferrer'>" + content + "</a>";
                html += "<div><dt>" + Server.HtmlEncode(labels[i]) + "</dt><dd>" + content + "</dd></div>";
            }
            return html + "</dl>";
        }
        protected async void EditSection(object sender, CommandEventArgs e) { await LoadProfile(); PersonalEditor.Visible = e.CommandArgument.ToString() == "Personal"; AcademicEditor.Visible = e.CommandArgument.ToString() == "Academic"; ProfessionalEditor.Visible = e.CommandArgument.ToString() == "Professional"; }
        protected void CancelSection(object sender, EventArgs e) { PersonalEditor.Visible = AcademicEditor.Visible = ProfessionalEditor.Visible = false; }
        protected async void SaveSection(object sender, CommandEventArgs e) {
            PersonalError.Text = AcademicError.Text = ProfessionalError.Text = "";
            var changes = new Dictionary<string, object>();
            try {
                string group = e.CommandArgument.ToString();
                if (group == "Personal") {
                    if (!System.Text.RegularExpressions.Regex.IsMatch(txtPhone.Text.Trim(), @"\A[+0-9 ()-]{7,20}\z")) throw new ArgumentException("Enter a valid phone number of 7–20 characters.");
                    DateTime dob;
                    if (txtDateOfBirth.Text.Length > 0 && (!DateTime.TryParseExact(txtDateOfBirth.Text,"yyyy-MM-dd",CultureInfo.InvariantCulture,DateTimeStyles.None,out dob) || dob.Date >= TaskWorkflow.Today)) throw new ArgumentException("Enter a date of birth in the past.");
                    changes["phone"] = txtPhone.Text.Trim(); changes["dateOfBirth"] = txtDateOfBirth.Text; changes["gender"] = ddlGender.SelectedValue;
                } else if (group == "Academic") {
                    decimal gpa; int credits; DateTime applied;
                    if (!decimal.TryParse(txtGPA.Text, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out gpa) || gpa < 0 || gpa > 4) throw new ArgumentException("Enter a GPA between 0 and 4.");
                    if (!int.TryParse(txtCompletedHours.Text,out credits) || credits < 0 || credits > 300) throw new ArgumentException("Enter completed credit hours between 0 and 300.");
                    if (!TaskWorkflow.ValidText(txtSemester.Text,1,100)) throw new ArgumentException("Enter an academic semester of 1–100 characters.");
                    if (!DateTime.TryParseExact(txtApplicationDate.Text,"yyyy-MM-dd",CultureInfo.InvariantCulture,DateTimeStyles.None,out applied)) throw new ArgumentException("Enter a valid application date.");
                    changes["gpa"] = gpa; changes["completedCreditHours"] = credits; changes["academicSemester"] = txtSemester.Text.Trim(); changes["applicationDate"] = txtApplicationDate.Text;
                } else if (group == "Professional") {
                    var links = new Dictionary<string, TextBox> { {"githubUrl",txtGithub}, {"linkedinUrl",txtLinkedin}, {"portfolioUrl",txtPortfolio}, {"cvUrl",txtCV} };
                    foreach (var pair in links) { Uri url; string text = pair.Value.Text.Trim(); if (text.Length > 2000 || text.Length > 0 && (!Uri.TryCreate(text,UriKind.Absolute,out url) || url.Scheme != "https")) throw new ArgumentException("Use valid HTTPS profile links of at most 2,000 characters."); changes[pair.Key] = text; }
                } else throw new ArgumentException("Unknown profile section.");
                // Explicit whitelist only; the six protected identity fields never enter this PATCH.
                await PortalRepository.Patch("students/" + PortalRepository.Key(CurrentProfileId), changes);
                CancelSection(sender, EventArgs.Empty); await LoadProfile(); lblMessage.Text = "Profile changes saved.";
            } catch (Exception ex) { var error = e.CommandArgument.ToString() == "Personal" ? PersonalError : e.CommandArgument.ToString() == "Academic" ? AcademicError : ProfessionalError; error.Text = Server.HtmlEncode(ex.Message); }
        }
    }
}
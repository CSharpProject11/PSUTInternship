using PSUTInternship.Models;

using Newtonsoft.Json;
using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;


namespace PSUTInternship.Student
{
    public partial class StudentProfile : PSUTInternship.Shared.PortalPage
    {
        private string url { get { return PSUTInternship.Shared.FirebaseConfig.DatabaseUrl + "students/" + CurrentProfileId + ".json"; } }


        // Load student data
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                await LoadStudentData();

                ViewState["IsEditing"] = false;
            }
        }


        // Get student information from Firebase
        private async Task LoadStudentData()
        {
            try
            {
                using (HttpClient client = PSUTInternship.Shared.FirebaseConfig.CreateClient())
                {
                    string json = await client.GetStringAsync(url);

                    if (string.IsNullOrWhiteSpace(json))
                    {
                        lblMessage.Text = "Student not found.";
                        return;
                    }

                    // Object from StudentInfo class
                    StudentInfo student =JsonConvert.DeserializeObject<StudentInfo>(json);

                    if (student == null)
                        return;

                    // Personal Information
                    assignedSupervisor.Text = Server.HtmlEncode(student.AcademicSupervisorName ?? "Ask the coordinator to assign a supervisor.");
                    txtFullName.Text = student.FullName;
                    txtDateOfBirth.Text = student.DateOfBirth;
                    txtEmail.Text = student.Email;
                    txtPhone.Text = student.PhoneNumber;

                    if (ddlGender.Items.FindByValue(student.Gender) != null)
                    {
                        ddlGender.SelectedValue = student.Gender;
                    }

                    // Academic Information
                    txtStudentId.Text = student.StudentNumber;
                    txtUniversity.Text = student.University;
                    txtFaculty.Text = student.College;
                    txtMajor.Text = student.Major;
                    txtGPA.Text = student.GPA;

                    txtSemester.Text = student.AcademicSemester;

                    txtCompletedHours.Text =
                        student.CompletedCreditHours?.ToString() ?? "";

                    txtApplicationDate.Text = student.ApplicationDate;

                    // Professional Information
                    txtGithub.Text = student.GithubUrl;
                    txtLinkedin.Text = student.LinkedinUrl;
                    txtPortfolio.Text = student.PortfolioLink;
                    txtCV.Text = student.CvUrl;
                    SetProfileLink(lnkGithub, student.GithubUrl);
                    SetProfileLink(lnkLinkedin, student.LinkedinUrl);
                    SetProfileLink(lnkPortfolio, student.PortfolioLink);


                    Uri cvUri;

                    bool hasCV =
                        Uri.TryCreate(student.CvUrl, UriKind.Absolute, out cvUri)
                        && cvUri.Scheme == Uri.UriSchemeHttps;

                    lnkCV.Visible = hasCV;

                    if (hasCV)
                    {
                        lnkCV.NavigateUrl = cvUri.AbsoluteUri;
                    }

                    // CV
                
                }
            }
            catch (Exception)
            {
                lblMessage.Text = "Error loading student data.";
            }
        }

        private void SetProfileLink(
            System.Web.UI.WebControls.HyperLink link,
            string url)
        {
            Uri address;

            bool valid = Uri.TryCreate(
                url,
                UriKind.Absolute,
                out address)
                && address.Scheme == Uri.UriSchemeHttps;

            link.Visible = valid;

            if (valid)
            {
                link.NavigateUrl = address.AbsoluteUri;
            }
        }


        // Edit Profile / Save Changes
        protected async void btnEditProfile_Click(object sender, EventArgs e)
        {
           
            Uri cvUri;

            bool hasCV =Uri.TryCreate(txtCV.Text.Trim(), UriKind.Absolute, out cvUri)&& cvUri.Scheme == Uri.UriSchemeHttps;

            lnkCV.Visible = hasCV;

            if (hasCV)
            {
                lnkCV.NavigateUrl = cvUri.AbsoluteUri;
            }
            bool isEditing =
                (bool?)ViewState["IsEditing"] ?? false;

            if (!isEditing)
            {
                // Enable allowed fields
                txtPhone.Enabled = true;
                txtGithub.Enabled = true;
                txtLinkedin.Enabled = true;
                txtPortfolio.Enabled = true;
                txtCV.Enabled = true;
                btnEditProfile.Text = "Save Changes";

                ViewState["IsEditing"] = true;
                lblMessage.Text = "";
            }
            else
            {
                try
                {
                    await SaveStudentData();

                    // Disable fields after saving
                    txtPhone.Enabled = false;
                    txtGithub.Enabled = false;
                    txtLinkedin.Enabled = false;
                    txtPortfolio.Enabled = false;
                    txtCV.Enabled = false;
                   

                    btnEditProfile.Text = "Edit Profile";

                    ViewState["IsEditing"] = false;

                    lblMessage.Text = "Profile updated successfully!";
                    lblMessage.ForeColor =
                        System.Drawing.Color.Green;
                    SetProfileLink(lnkGithub, txtGithub.Text.Trim());
                    SetProfileLink(lnkLinkedin, txtLinkedin.Text.Trim());
                    SetProfileLink(lnkPortfolio, txtPortfolio.Text.Trim());
                }
                catch (Exception)
                {
                    lblMessage.Text =
                        "Error saving student information.";

                    lblMessage.ForeColor =
                        System.Drawing.Color.Red;
                }
            }
        }


        // Save allowed fields to Firebase
        private async Task SaveStudentData()
        {
            // Object from your StudentInfo class
            StudentInfo info = new StudentInfo();

            info.PhoneNumber = txtPhone.Text.Trim();
            info.GithubUrl = txtGithub.Text.Trim();
            info.LinkedinUrl = txtLinkedin.Text.Trim();
            info.PortfolioLink = txtPortfolio.Text.Trim();
            info.CvUrl = txtCV.Text.Trim();

            // Serialize only populated properties
            string json = JsonConvert.SerializeObject( info,
                new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore
                });

            using (HttpClient client = PSUTInternship.Shared.FirebaseConfig.CreateClient())
            {
                using (StringContent content =
                    new StringContent(
                        json,
                        Encoding.UTF8,
                        "application/json"))
                {
                    using (HttpRequestMessage request =
                        new HttpRequestMessage(
                            new HttpMethod("PATCH"), url))
                    {
                        request.Content = content;

                        HttpResponseMessage response =
                            await client.SendAsync(request);

                        response.EnsureSuccessStatusCode();
                    }
                }
            }
        }
      

    }
    }


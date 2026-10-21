using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net.Http;
using System.Threading.Tasks;

namespace Student
{
    public  partial class StudentProfile : System.Web.UI.Page
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            HttpClient client = new HttpClient();

            string url =
    "https://teacher-124b2-default-rtdb.firebaseio.com/students/student1.json";

            string json = await client.GetStringAsync(url);

            JObject student = JObject.Parse(json);

            txtFullName.Text = (string)student["fullName"];

            // Personal Information
            txtFullName.Text = (string)student["fullName"];
            txtDateOfBirth.Text = (string)student["dateOfBirth"];
            txtEmail.Text = (string)student["email"];
            txtPhone.Text = (string)student["phone"];

            string gender = (string)student["gender"] ?? "";
            if (ddlGender.Items.FindByValue(gender) != null)
                ddlGender.SelectedValue = gender;

            // Academic Information
            txtStudentId.Text = (string)student["studentNumber"];
            txtUniversity.Text = (string)student["university"];
            txtFaculty.Text = (string)student["college"];
            txtMajor.Text = (string)student["major"];
            txtGPA.Text = (string)student["gpa"];

            // Professional Information
            txtGithub.Text = (string)student["githubUrl"];
            txtLinkedin.Text = (string)student["linkedinUrl"];
            txtPortfolio.Text = (string)student["portfolioUrl"];

            string cvUrl = (string)student["cvUrl"];

            Uri cvUri;
            bool hasCV = Uri.TryCreate(cvUrl, UriKind.Absolute, out cvUri)
                && cvUri.Scheme == Uri.UriSchemeHttps;

            lnkCV.Visible = hasCV;
            

            if (hasCV)
                lnkCV.NavigateUrl = cvUri.AbsoluteUri;
        }
    

protected void btnEdit_Click(object sender, EventArgs e)
        {

        }

        protected void btnSave_Click(object sender, EventArgs e)
        {

        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {

        }

        protected void btnSaveProfessional_Click(object sender, EventArgs e)
        {

        }
    }
}
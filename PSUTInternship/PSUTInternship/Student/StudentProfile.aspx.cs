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
            if (Session["userId"] == null || Session["idToken"] == null || !string.Equals(Convert.ToString(Session["userRole"]), "student", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            if (IsPostBack) return;
            string profileId = Convert.ToString(Session["profileId"]);
            if (string.IsNullOrWhiteSpace(profileId)) profileId = Convert.ToString(Session["userId"]);
            string url = PSUTInternship.Shared.FirebaseConfig.DatabaseUrl.TrimEnd('/') + "/students/"
                + Uri.EscapeDataString(profileId) + ".json?auth="
                + Uri.EscapeDataString(Convert.ToString(Session["idToken"]));
            JObject student;
            try
            {
                string json = await PSUTInternship.Shared.FirebaseConfig.Client.GetStringAsync(url);
                student = Newtonsoft.Json.JsonConvert.DeserializeObject<JObject>(json) ?? new JObject();
            }
            catch (Exception ex) when (ex is HttpRequestException || ex is Newtonsoft.Json.JsonException || ex is TaskCanceledException)
            {
                var notice = new System.Web.UI.HtmlControls.HtmlGenericControl("p");
                notice.Attributes["role"] = "status";
                notice.InnerText = "Your profile could not be loaded. Return to your dashboard or sign in again.";
                form1.Controls.AddAt(0, notice);
                return;
            }

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

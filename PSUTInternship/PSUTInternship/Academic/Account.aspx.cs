using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace AcademicSupervisor
{
    public partial class Account : Page
    {
        private static readonly HttpClient Client = new HttpClient();
        private readonly JavaScriptSerializer json = new JavaScriptSerializer();

        // Firebase project URL, without /.json at the end.
        private const string DbUrl =
            "https://project-d2551-default-rtdb.firebaseio.com";

        // Academic supervisor Sara Sawalmeh.
        private const string SupervisorId =
            "9A8jqXmuQthnfld1A9Lonba3QTI3";

        private string ProfilePath
        {
            get { return "academicSupervisors/" + Uri.EscapeDataString(SupervisorId); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(LoadProfileAsync));
            }
        }

        private async Task LoadProfileAsync()
        {
            try
            {
                Dictionary<string, object> data = await ReadFirebaseAsync(ProfilePath);
                if (data == null)
                {
                    System.Diagnostics.Trace.TraceWarning("Account: Supervisor profile was not found.");
                    return;
                }

                string name = Field(data, "fullName");
                string department = Field(data, "department");
                string email = Field(data, "email");
                string phone = Field(data, "phoneNumber");
                string office = Field(data, "office");
                string officeHours = Field(data, "officeHours");

                lblTopName.Text = H(Show(name));
                lblHeaderName.Text = H(Show(name));
                lblHeaderDepartment.Text = H(Show(department));
                lblInitials.Text = H(GetInitials(name));
                lblName.Text = H(Show(name));
                lblPhone.Text = H(Show(phone));
                lblDepartment.Text = H(Show(department));
                lblOffice.Text = H(Show(office));
                lblOfficeHours.Text = H(Show(officeHours));
                lblEmail.Text = H(Show(email));

                txtName.Text = name;
                txtPhone.Text = phone;
                txtDepartment.Text = department;
                txtOffice.Text = office;
                txtOfficeHours.Text = officeHours;
                txtEmail.Text = email;
            }
            catch (Exception ex)
            {
                // Errors are recorded in the server diagnostics only.
                System.Diagnostics.Trace.TraceError("Account load failed: " + ex);
            }
        }

        // Firebase Realtime Database REST operations.
        // Database rules must permit these requests.
        private string FirebaseUrl(string path)
        {
            Uri url;
            if (!Uri.TryCreate(DbUrl, UriKind.Absolute, out url) ||
                url.Scheme != Uri.UriSchemeHttps)
            {
                throw new InvalidOperationException(
                    "Firebase database URL must be a valid HTTPS URL.");
            }

            return DbUrl + "/" + path + ".json";
        }

        private async Task<Dictionary<string, object>> ReadFirebaseAsync(string path)
        {
            string url = FirebaseUrl(path);
            using (HttpResponseMessage response = await Client.GetAsync(url))
            {
                response.EnsureSuccessStatusCode();
                string result = await response.Content.ReadAsStringAsync();
                if (string.IsNullOrWhiteSpace(result) || result.Trim() == "null")
                    return null;

                return json.Deserialize<Dictionary<string, object>>(result);
            }
        }

        private async Task PatchFirebaseAsync(string path,
            Dictionary<string, object> changes)
        {
            string url = FirebaseUrl(path);
            string body = json.Serialize(changes);

            using (var request = new HttpRequestMessage(
                new HttpMethod("PATCH"), url))
            {
                request.Content = new StringContent(
                    body, Encoding.UTF8, "application/json");

                using (HttpResponseMessage response =
                    await Client.SendAsync(request))
                {
                    response.EnsureSuccessStatusCode();
                }
            }
        }

        private static string Field(Dictionary<string, object> data, string key)
        {
            object value;
            return data != null && data.TryGetValue(key, out value) &&
                   value != null ? Convert.ToString(value) : "";
        }

        private static string H(string value)
        {
            return HttpUtility.HtmlEncode(value ?? "");
        }

        private static string Show(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "Not provided" : value;
        }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
                return "AS";

            string[] parts = name.Trim().Split(
                new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);

            if (parts.Length == 1)
                return parts[0].Substring(0, 1).ToUpperInvariant();

            return (parts[0].Substring(0, 1) +
                    parts[parts.Length - 1].Substring(0, 1))
                    .ToUpperInvariant();
        }

        private void ShowPersonalEdit(bool editing)
        {
            pnlPersonalView.Visible = !editing;
            pnlPersonalEdit.Visible = editing;
        }

        private void ShowAcademicEdit(bool editing)
        {
            pnlAcademicView.Visible = !editing;
            pnlAcademicEdit.Visible = editing;
        }

        protected void btnEditPersonal_Click(object sender, EventArgs e)
        {
            ShowPersonalEdit(true);
        }

        protected void btnEditAcademic_Click(object sender, EventArgs e)
        {
            ShowAcademicEdit(true);
        }

        protected void btnCancelPersonal_Click(object sender, EventArgs e)
        {
            ShowPersonalEdit(false);
            RegisterAsyncTask(new PageAsyncTask(LoadProfileAsync));
        }

        protected void btnCancelAcademic_Click(object sender, EventArgs e)
        {
            ShowAcademicEdit(false);
            RegisterAsyncTask(new PageAsyncTask(LoadProfileAsync));
        }

        protected void btnSavePersonal_Click(object sender, EventArgs e)
        {
            ShowPersonalEdit(true);
            RegisterAsyncTask(new PageAsyncTask(SavePersonalAsync));
        }

        private async Task SavePersonalAsync()
        {
            string name = (txtName.Text ?? "").Trim();
            string phone = (txtPhone.Text ?? "").Trim();
            if (string.IsNullOrWhiteSpace(name))
                return;

            try
            {
                await PatchFirebaseAsync(ProfilePath,
                    new Dictionary<string, object>
                    {
                        { "fullName", name },
                        { "phoneNumber", phone }
                    });

                await LoadProfileAsync();
                ShowPersonalEdit(false);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Account personal save failed: " + ex);
            }
        }

        protected void btnSaveAcademic_Click(object sender, EventArgs e)
        {
            ShowAcademicEdit(true);
            RegisterAsyncTask(new PageAsyncTask(SaveAcademicAsync));
        }

        private async Task SaveAcademicAsync()
        {
            string department = (txtDepartment.Text ?? "").Trim();
            string office = (txtOffice.Text ?? "").Trim();
            string officeHours = (txtOfficeHours.Text ?? "").Trim();
            if (string.IsNullOrWhiteSpace(department))
                return;

            try
            {
                await PatchFirebaseAsync(ProfilePath,
                    new Dictionary<string, object>
                    {
                        { "department", department },
                        { "office", office },
                        { "officeHours", officeHours }
                    });

                await LoadProfileAsync();
                ShowAcademicEdit(false);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Account academic save failed: " + ex);
            }
        }
    }
}

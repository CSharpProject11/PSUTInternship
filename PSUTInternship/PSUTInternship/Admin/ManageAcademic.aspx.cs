using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace PSUTInternship.Admin
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        private string databaseUrl = "https://uims-database-32b4f-default-rtdb.firebaseio.com";
        private string apiKey = "AIzaSyAC_4W_zSjHJddnRWC3_4_IgBS1VOqTUXg";
        private string objectName = "academicSupervisors";
        private string roleName = "Academic Supervisor";
        private JavaScriptSerializer serializer = new JavaScriptSerializer();

        private string idToken
        {
            get { return Convert.ToString(Session["idToken"]); }
        }
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (Convert.ToString(Session["userRole"]) != "coordinator" || idToken == "")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (IsPostBack) return;

            if (Session["academicMessage"] != null)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(Convert.ToString(Session["academicMessage"]));
                Session.Remove("academicMessage");
            }

            string id = Request.QueryString["toggle"];
            if (id != null)
            {
                try
                {
                    await ToggleSupervisor(id);
                    Session["academicMessage"] = "Supervisor status updated.";
                }
                catch (Exception error)
                {
                    Session["academicMessage"] = error.Message;
                }
                Response.Redirect("ManageAcademic.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            id = Request.QueryString["edit"];
            if (id != null)
            {
                await LoadSupervisorForEdit(id);
                return;
            }

            id = Request.QueryString["view"];
            if (id != null)
            {
                await LoadSupervisorForView(id);
                return;
            }

            ShowList();
            await LoadSupervisors();
        }
        private void ShowList()
        {
            listSection.Visible = true;
            formSection.Visible = false;
            viewSection.Visible = false;
        }

        private void ShowForm()
        {
            listSection.Visible = false;
            formSection.Visible = true;
            viewSection.Visible = false;
        }

        private void ShowView()
        {
            listSection.Visible = false;
            formSection.Visible = false;
            viewSection.Visible = true;
        }

        private async Task<Dictionary<string, Dictionary<string, object>>> GetRecords(string objectToRead)
        {
            string url = databaseUrl + "/" + objectToRead + ".json?auth=" + Uri.EscapeDataString(idToken);
            using (HttpClient client = new HttpClient())
            {
                HttpResponseMessage response = await client.GetAsync(url);
                string result = await response.Content.ReadAsStringAsync();
                if (!response.IsSuccessStatusCode)
                    throw new Exception("Could not read Firebase data. Check Database rules.");
                if (result == "null" || result == "")
                    return new Dictionary<string, Dictionary<string, object>>();

                Dictionary<string, Dictionary<string, object>> records =
                    serializer.Deserialize<Dictionary<string, Dictionary<string, object>>>(result);
                if (records == null)
                    return new Dictionary<string, Dictionary<string, object>>();
                return records;
            }
        }

        private string GetValue(Dictionary<string, object> data, string field)
        {
            if (data.ContainsKey(field) && data[field] != null)
                return Convert.ToString(data[field]);
            return "";
        }

        private async Task LoadSupervisors()
        {
            try
            {
                Dictionary<string, Dictionary<string, object>> supervisors = await GetRecords(objectName);
                StringBuilder table = new StringBuilder();
                string search = searchTextBox.Text.Trim();
                int total = 0, active = 0, inactive = 0;

                table.Append("<table>" +
                    "<thead>" +
                    "<tr><th>Name</th>" +
                    "<th>Email</th>" +
                    "<th>College</th>" +
                    "<th>Department</th>" +
                    "<th>Specialization</th>" +
                    "<th>Status</th>" +
                    "<th>Actions</th>" +
                    "</tr>" +
                    "</thead>" +
                    "<tbody>");
                foreach (KeyValuePair<string, Dictionary<string, object>> item in supervisors)
                {
                    Dictionary<string, object> supervisor = item.Value;
                    if (GetValue(supervisor, "role") != roleName) continue;

                    total++;
                    bool isActive = GetValue(supervisor, "isActive").ToLower() == "true";
                    if (isActive) active++;
                    else inactive++;

                    string name = GetValue(supervisor, "fullName");
                    string email = GetValue(supervisor, "email");
                    string college = GetValue(supervisor, "college");
                    string department = GetValue(supervisor, "department");
                    string specialization = GetValue(supervisor, "specialization");
                    bool found = search == "" ||
                        name.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0 ||
                        email.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0 ||
                        college.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0;
                    if (!found) continue;

                    string id = HttpUtility.UrlEncode(item.Key);
                    table.Append("<tr><td>").Append(HttpUtility.HtmlEncode(name));
                    table.Append("</td><td>").Append(HttpUtility.HtmlEncode(email));
                    table.Append("</td><td>").Append(HttpUtility.HtmlEncode(college));
                    table.Append("</td><td>").Append(HttpUtility.HtmlEncode(department));
                    table.Append("</td><td>").Append(HttpUtility.HtmlEncode(specialization));
                    table.Append("</td><td>").Append(isActive ? "Active" : "Inactive").Append("</td><td>");
                    table.Append("<a class='btn light' href='ManageAcademic.aspx?view=").Append(id).Append("'>View</a> ");
                    table.Append("<a class='btn light' href='ManageAcademic.aspx?edit=").Append(id).Append("'>Edit</a> ");
                    table.Append("<a class='btn danger' href='ManageAcademic.aspx?toggle=").Append(id);
                    table.Append("' onclick=\"return confirm('Change this account status?');\">");
                    table.Append(isActive ? "Deactivate</a></td></tr>" : "Activate</a></td></tr>");
                }

                if (total == 0) table.Append("<tr><td colspan='7'>No academic supervisors yet.</td></tr>");
                else if (table.ToString().EndsWith("<tbody>")) table.Append("<tr><td colspan='7'>No supervisors match your search.</td></tr>");
                table.Append("</tbody></table>");

                tableLiteral.Text = table.ToString();
                totalLabel.Text = total.ToString();
                activeLabel.Text = active.ToString();
                inactiveLabel.Text = inactive.ToString();
            }
            catch (Exception error)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(error.Message);
            }
        }

        protected void addButton_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowForm();
        }

        protected void backButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("ManageAcademic.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected async void saveButton_Click(object sender, EventArgs e)
        {
            string name = nameTextBox.Text.Trim();
            string email = emailTextBox.Text.Trim();
            string college = collegeTextBox.Text.Trim();
            string department = departmentTextBox.Text.Trim();
            string specialization = specializationTextBox.Text.Trim();
            string editId = Request.QueryString["edit"];
            bool isEditing = editId != null && editId != "";

            if (name == "" || email == "" || college == "" || department == "" || specialization == "")
            {
                messageLabel.Text = "Fill in name, email, college, department, and specialization.";
                ShowForm();
                return;
            }

            try
            {
                Dictionary<string, Dictionary<string, object>> users = await GetRecords("users");
                foreach (KeyValuePair<string, Dictionary<string, object>> item in users)
                {
                    if (item.Key == editId) continue;
                    if (GetValue(item.Value, "email").ToLower() == email.ToLower())
                    {
                        messageLabel.Text = "That email is already in use.";
                        ShowForm();
                        return;
                    }
                }

                Dictionary<string, object> oldSupervisor = null;
                string uid = editId;
                if (isEditing)
                {
                    Dictionary<string, Dictionary<string, object>> supervisors = await GetRecords(objectName);
                    if (!supervisors.ContainsKey(uid))
                    {
                        messageLabel.Text = "Supervisor record was not found.";
                        ShowForm();
                        return;
                    }
                    oldSupervisor = supervisors[uid];
                    if (GetValue(oldSupervisor, "email").ToLower() != email.ToLower())
                    {
                        messageLabel.Text = "The email also has to be changed in Firebase Authentication.";
                        ShowForm();
                        return;
                    }
                }
                else
                {
                    if (passwordTextBox.Text == "")
                    {
                        messageLabel.Text = "Enter a temporary password.";
                        ShowForm();
                        return;
                    }
                    uid = await CreateAccount(email, passwordTextBox.Text);
                    if (uid == null)
                    {
                        ShowForm();
                        return;
                    }
                }

                Dictionary<string, object> supervisor;
                if (oldSupervisor == null) supervisor = new Dictionary<string, object>();
                else supervisor = new Dictionary<string, object>(oldSupervisor);

                supervisor["profileId"] = uid;
                supervisor["role"] = roleName;
                supervisor["fullName"] = name;
                supervisor["email"] = email;
                supervisor["college"] = college;
                supervisor["department"] = department;
                supervisor["specialization"] = specialization;
                supervisor["phoneNumber"] = phoneTextBox.Text.Trim();

                if (oldSupervisor == null)
                {
                    supervisor["isActive"] = true;
                    supervisor["mustChangePassword"] = true;
                }

                await SaveSupervisor(uid, supervisor);
                Session["academicMessage"] = isEditing ? "Academic supervisor updated." : "Academic supervisor account created.";
                Response.Redirect("ManageAcademic.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception error)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(error.Message);
                ShowForm();
            }
        }

        private async Task<string> CreateAccount(string email, string password)
        {
            string url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + Uri.EscapeDataString(apiKey);
            Dictionary<string, object> account = new Dictionary<string, object>();
            account["email"] = email;
            account["password"] = password;
            account["returnSecureToken"] = true;

            using (HttpClient client = new HttpClient())
            using (StringContent content = new StringContent(serializer.Serialize(account), Encoding.UTF8, "application/json"))
            {
                HttpResponseMessage response = await client.PostAsync(url, content);
                string resultText = await response.Content.ReadAsStringAsync();
                if (!response.IsSuccessStatusCode)
                {
                    messageLabel.Text = "Firebase could not create the account. Check the email, password, and Email/Password sign-in setting.";
                    return null;
                }
                Dictionary<string, object> result = serializer.Deserialize<Dictionary<string, object>>(resultText);
                return Convert.ToString(result["localId"]);
            }
        }

        private async Task SaveSupervisor(string uid, Dictionary<string, object> supervisor)
        {
            await SaveInObject("users", uid, supervisor);
            await SaveInObject(objectName, uid, supervisor);
        }

        private async Task SaveInObject(string objectToSave, string uid, Dictionary<string, object> data)
        {
            string url = databaseUrl + "/" + objectToSave + "/" + Uri.EscapeDataString(uid) + ".json?auth=" + Uri.EscapeDataString(idToken);
            using (HttpClient client = new HttpClient())
            using (StringContent content = new StringContent(serializer.Serialize(data), Encoding.UTF8, "application/json"))
            {
                HttpResponseMessage response = await client.PutAsync(url, content);
                if (!response.IsSuccessStatusCode)
                    throw new Exception("Could not save supervisor data. Check Firebase rules for users and academicSupervisors.");
            }
        }

        private async Task LoadSupervisorForEdit(string uid)
        {
            try
            {
                Dictionary<string, Dictionary<string, object>> supervisors = await GetRecords(objectName);
                if (!supervisors.ContainsKey(uid))
                {
                    messageLabel.Text = "Supervisor record was not found.";
                    ShowList();
                    await LoadSupervisors();
                    return;
                }

                Dictionary<string, object> supervisor = supervisors[uid];
                nameTextBox.Text = GetValue(supervisor, "fullName");
                emailTextBox.Text = GetValue(supervisor, "email");
                collegeTextBox.Text = GetValue(supervisor, "college");
                departmentTextBox.Text = GetValue(supervisor, "department");
                specializationTextBox.Text = GetValue(supervisor, "specialization");
                phoneTextBox.Text = GetValue(supervisor, "phoneNumber");
                passwordTextBox.Enabled = false;
                formTitleLabel.Text = "Edit academic supervisor";
                saveButton.Text = "Save changes";
                ShowForm();
            }
            catch (Exception error)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(error.Message);
                ShowList();
            }
        }

        private async Task LoadSupervisorForView(string uid)
        {
            try
            {
                Dictionary<string, Dictionary<string, object>> supervisors = await GetRecords(objectName);
                if (!supervisors.ContainsKey(uid))
                {
                    messageLabel.Text = "Supervisor record was not found.";
                    ShowList();
                    await LoadSupervisors();
                    return;
                }

                Dictionary<string, object> supervisor = supervisors[uid];
                viewNameLabel.Text = HttpUtility.HtmlEncode(GetValue(supervisor, "fullName"));
                viewEmailLabel.Text = HttpUtility.HtmlEncode(GetValue(supervisor, "email"));
                viewCollegeLabel.Text = HttpUtility.HtmlEncode(GetValue(supervisor, "college"));
                viewDepartmentLabel.Text = HttpUtility.HtmlEncode(GetValue(supervisor, "department"));
                viewSpecializationLabel.Text = HttpUtility.HtmlEncode(GetValue(supervisor, "specialization"));
                viewPhoneLabel.Text = HttpUtility.HtmlEncode(GetValue(supervisor, "phoneNumber"));
                viewStatusLabel.Text = GetValue(supervisor, "isActive").ToLower() == "true" ? "Active" : "Inactive";
                ShowView();
            }
            catch (Exception error)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(error.Message);
                ShowList();
            }
        }

        private async Task ToggleSupervisor(string uid)
        {
            Dictionary<string, Dictionary<string, object>> supervisors = await GetRecords(objectName);
            if (!supervisors.ContainsKey(uid)) return;
            Dictionary<string, object> supervisor = supervisors[uid];
            supervisor["isActive"] = GetValue(supervisor, "isActive").ToLower() != "true";
            await SaveSupervisor(uid, supervisor);
        }

        protected async void searchButton_Click(object sender, EventArgs e)
        {
            ShowList();
            await LoadSupervisors();
        }

        protected void clearButton_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowForm();
        }

        private void ClearForm()
        {
            nameTextBox.Text = "";
            emailTextBox.Text = "";
            passwordTextBox.Text = "";
            passwordTextBox.Enabled = true;
            collegeTextBox.Text = "";
            departmentTextBox.Text = "";
            specializationTextBox.Text = "";
            phoneTextBox.Text = "";
            formTitleLabel.Text = "Add academic supervisor";
            saveButton.Text = "Create supervisor";
        }
    }
}
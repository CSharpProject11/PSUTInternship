using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Mail;
using System.Text;
using System.Web;
using System.Web.UI;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace internship_manegment
{
    public partial class SupervisorAccount : Page
    {
        private const string DatabaseUrl = "https://student-management-syste-bc369-default-rtdb.asia-southeast1.firebasedatabase.app/";

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string id = Request.QueryString["id"];
                if (string.IsNullOrWhiteSpace(id))
                {
                    await LoadFirstSupervisor();
                    return;
                }

                UserId.Value = id;
                await LoadUser(id);
            }
        }

        private async System.Threading.Tasks.Task LoadFirstSupervisor()
        {
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    string json = await client.GetStringAsync(DatabaseUrl + "Users.json");
                    Dictionary<string, JObject> users = JsonConvert.DeserializeObject<Dictionary<string, JObject>>(json)
                        ?? new Dictionary<string, JObject>();
                    KeyValuePair<string, JObject> supervisor = users.FirstOrDefault(item => item.Key == "demo-supervisor-001" && item.Value != null && IsCompanySupervisor(item.Value));
                    if (string.IsNullOrWhiteSpace(supervisor.Key))
                        supervisor = users.FirstOrDefault(item => item.Value != null && IsCompanySupervisor(item.Value));
                    if (!string.IsNullOrWhiteSpace(supervisor.Key))
                    {
                        UserId.Value = supervisor.Key;
                        await LoadUser(supervisor.Key);
                        if (!ProfilePanel.Visible)
                            ShowSampleProfile();
                        return;
                    }
                }
            }
            catch (Exception)
            {
                // If Firebase is unavailable, still show the profile layout with sample data.
            }

            ShowSampleProfile();
        }

        protected void EditProfile_Click(object sender, EventArgs e)
        {
            ProfileView.Visible = false;
            ProfileEdit.Visible = true;
            EditName.Text = OriginalName.Value;
            EditEmail.Text = OriginalEmail.Value;
            EditPhone.Text = OriginalPhone.Value;
            EditPhotoUrl.Text = CurrentPhotoUrl.Value.StartsWith("data:image/", StringComparison.OrdinalIgnoreCase)
                ? "" : CurrentPhotoUrl.Value;
        }

        protected void CancelEdit_Click(object sender, EventArgs e)
        {
            ProfileEdit.Visible = false;
            ProfileView.Visible = true;
        }

        protected async void SaveProfile_Click(object sender, EventArgs e)
        {
            string name = EditName.Text.Trim();
            string email = EditEmail.Text.Trim();
            string phone = EditPhone.Text.Trim();
            string photoUrl = CurrentPhotoUrl.Value;

            if (name.Length == 0 || !IsValidEmail(email))
            {
                ShowMessage("Enter a name and a valid work email.");
                return;
            }

            if (UploadPhoto.HasFile)
            {
                string extension = Path.GetExtension(UploadPhoto.FileName).ToLowerInvariant();
                string contentType = UploadPhoto.PostedFile.ContentType.ToLowerInvariant();
                if (UploadPhoto.PostedFile.ContentLength > 1024 * 1024 ||
                    !IsSupportedImage(extension, contentType))
                {
                    ShowMessage("Choose a JPG, PNG, GIF, or WEBP image that is no larger than 1 MB.");
                    return;
                }

                using (MemoryStream image = new MemoryStream())
                {
                    UploadPhoto.PostedFile.InputStream.CopyTo(image);
                    photoUrl = "data:" + contentType + ";base64," + Convert.ToBase64String(image.ToArray());
                }
            }
            else if (!string.IsNullOrWhiteSpace(EditPhotoUrl.Text))
            {
                photoUrl = EditPhotoUrl.Text.Trim();
            }

            if (photoUrl.Length > 0 && !IsWebUrl(photoUrl) && !IsSupportedImageData(photoUrl))
            {
                ShowMessage("Enter a complete image URL beginning with http:// or https://.");
                return;
            }

            if (PreviewMode.Value == "true")
            {
                JObject preview = new JObject();
                preview["Name"] = name;
                preview["Email"] = email;
                preview["Phone"] = phone;
                preview["PhotoUrl"] = photoUrl;
                preview["Company"] = "Tech Solutions";
                preview["CompanyDescription"] = "Technology & Software Development";
                preview["Role"] = "Company Supervisor";
                preview["Position"] = "Company Supervisor";
                preview["Active"] = true;
                FillProfile(preview);
                ProfileEdit.Visible = false;
                ProfileView.Visible = true;
                ShowMessage("Preview updated for this page only. Add a supervisor record to Firebase to save changes.");
                return;
            }

            if (string.IsNullOrWhiteSpace(UserId.Value))
            {
                ShowMessage("No supervisor account was found in Firebase.");
                return;
            }

            try
            {
                using (HttpClient client = new HttpClient())
                {
                    string currentJson = await client.GetStringAsync(GetUserUrl(UserId.Value));
                    if (currentJson == "null")
                    {
                        ShowMessage("Account was not found in Firebase.");
                        return;
                    }

                    JObject current = JObject.Parse(currentJson);
                    if (!IsCompanySupervisor(current))
                    {
                        ShowMessage("This account is not a company supervisor account.");
                        return;
                    }

                    JObject changes = new JObject();
                    changes["Name"] = name;
                    changes["Email"] = email;
                    changes["Phone"] = phone;
                    changes["PhotoUrl"] = photoUrl;

                    using (StringContent content = new StringContent(changes.ToString(Formatting.None), Encoding.UTF8, "application/json"))
                    {
                        HttpRequestMessage request = new HttpRequestMessage(new HttpMethod("PATCH"), GetUserUrl(UserId.Value));
                        request.Content = content;
                        HttpResponseMessage response = await client.SendAsync(request);
                        if (!response.IsSuccessStatusCode)
                        {
                            ShowMessage("Could not save profile changes. Please try again.");
                            return;
                        }
                    }
                }

                ProfileEdit.Visible = false;
                ProfileView.Visible = true;
                ShowMessage("Profile changes saved.");
                await LoadUser(UserId.Value);
            }
            catch (Exception)
            {
                ShowMessage("Could not connect to Firebase. Please try again.");
            }
        }

        private async System.Threading.Tasks.Task LoadUser(string id)
        {
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    string json = await client.GetStringAsync(GetUserUrl(id));
                    if (json == "null")
                    {
                        ProfilePanel.Visible = false;
                        ShowMessage("Account was not found in Firebase.");
                        return;
                    }

                    JObject user = JObject.Parse(json);
                    if (!IsCompanySupervisor(user))
                    {
                        ProfilePanel.Visible = false;
                        ShowMessage("The selected record is not a company supervisor account.");
                        return;
                    }

                    UserId.Value = id;
                    PreviewMode.Value = "false";
                    ProfilePanel.Visible = true;
                    ProfileEdit.Visible = false;
                    ProfileView.Visible = true;
                    FillProfile(user);

                    string usersJson = await client.GetStringAsync(DatabaseUrl + "Users.json");
                    Dictionary<string, JObject> users = JsonConvert.DeserializeObject<Dictionary<string, JObject>>(usersJson)
                        ?? new Dictionary<string, JObject>();
                    int traineeCount = CountAssignedTrainees(users, id, Read(user, "Email", "email"), Read(user, "Name", "name"));
                    if (traineeCount == 0 && user["TraineesCount"] != null)
                        int.TryParse(user["TraineesCount"].ToString(), out traineeCount);
                    TraineeCount.Text = traineeCount.ToString();
                }
            }
            catch (Exception)
            {
                ProfilePanel.Visible = false;
                ShowMessage("Could not load account information from Firebase. Please try again.");
            }
        }

        private void ShowSampleProfile()
        {
            UserId.Value = "";
            PreviewMode.Value = "true";
            ProfilePanel.Visible = true;
            ProfileEdit.Visible = false;
            ProfileView.Visible = true;

            JObject sample = new JObject();
            sample["Name"] = "Sarah Ahmed";
            sample["Email"] = "sarah.ahmed@techsolutions.example";
            sample["Phone"] = "+962 79 000 0000";
            sample["Company"] = "Tech Solutions";
            sample["CompanyDescription"] = "Technology & Software Development";
            sample["Position"] = "Company Supervisor";
            sample["Role"] = "Company Supervisor";
            sample["Active"] = true;
            sample["TraineesCount"] = 3;
            FillProfile(sample);
            TraineeCount.Text = "3";
            ShowMessage("Sample profile preview. Add a supervisor record to Firebase to use your own data.");
        }

        private void FillProfile(JObject user)
        {
            string name = Read(user, "Name", "name");
            string email = Read(user, "Email", "email");
            string company = Read(user, "Company", "company", "CompanyName", "companyName");
            string position = Read(user, "Position", "position", "Title", "title");
            string phone = Read(user, "Phone", "phone", "PhoneNumber", "phoneNumber");
            string role = Read(user, "Role", "role");
            string photoUrl = Read(user, "PhotoUrl", "PhotoURL", "photoUrl", "photoURL", "ProfileImage", "profileImage");
            string companyDescription = Read(user, "CompanyDescription", "companyDescription", "Industry", "industry", "CompanyType", "companyType");

            HeaderName.Text = EncodeOrFallback(name);
            HeaderRoleAndCompany.Text = EncodeOrFallback(role + (company.Length > 0 ? " · " + company : ""));
            ViewName.Text = EncodeOrFallback(name);
            ViewEmail.Text = EncodeOrFallback(email);
            ViewCompany.Text = EncodeOrFallback(company);
            ViewPosition.Text = EncodeOrFallback(position.Length > 0 ? position : role);
            ViewPhone.Text = EncodeOrFallback(phone);
            ViewRole.Text = EncodeOrFallback(role);
            CompanyNameCard.Text = EncodeOrFallback(company);
            CompanyDescription.Text = EncodeOrFallback(companyDescription);

            string status = Read(user, "Status", "status");
            bool active = user["Active"] == null || user["Active"].Type == JTokenType.Null ||
                user["Active"].Type != JTokenType.Boolean || (bool)user["Active"];
            if (status.Equals("inactive", StringComparison.OrdinalIgnoreCase) || status.Equals("disabled", StringComparison.OrdinalIgnoreCase)) active = false;
            AccountStatus.Text = active ? "Active Account" : "Inactive Account";

            string initials = GetInitials(name);
            Initials.Text = HttpUtility.HtmlEncode(initials);
            ProfilePhoto.Visible = IsWebUrl(photoUrl) || IsSupportedImageData(photoUrl);
            PhotoFallback.Visible = !ProfilePhoto.Visible;
            if (ProfilePhoto.Visible) ProfilePhoto.ImageUrl = photoUrl;

            EditName.Text = name;
            EditEmail.Text = email;
            EditPhone.Text = phone;
            OriginalName.Value = name;
            OriginalEmail.Value = email;
            OriginalPhone.Value = phone;
            CurrentPhotoUrl.Value = photoUrl;
            EditPhotoUrl.Text = photoUrl.StartsWith("data:image/", StringComparison.OrdinalIgnoreCase) ? "" : photoUrl;
        }

        private static int CountAssignedTrainees(Dictionary<string, JObject> users, string supervisorId, string supervisorEmail, string supervisorName)
        {
            return users.Where(item => item.Value != null && IsStudent(item.Value))
                .Count(item => IsAssignedToSupervisor(item.Value, supervisorId, supervisorEmail, supervisorName) && IsActiveStudent(item.Value));
        }

        private static bool IsAssignedToSupervisor(JObject student, string supervisorId, string supervisorEmail, string supervisorName)
        {
            string assignedId = Read(student, "CompanySupervisorId", "companySupervisorId", "SupervisorId", "supervisorId");
            string assignedEmail = Read(student, "CompanySupervisorEmail", "companySupervisorEmail", "SupervisorEmail", "supervisorEmail");
            string assignedName = Read(student, "CompanySupervisor", "companySupervisor", "SupervisorName", "supervisorName");
            return string.Equals(assignedId, supervisorId, StringComparison.OrdinalIgnoreCase) ||
                (!string.IsNullOrWhiteSpace(supervisorEmail) && string.Equals(assignedEmail, supervisorEmail, StringComparison.OrdinalIgnoreCase)) ||
                string.Equals(assignedName, supervisorName, StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsStudent(JObject user)
        {
            return Read(user, "Role", "role").Equals("Student", StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsActiveStudent(JObject student)
        {
            if (student["Active"] != null && student["Active"].Type == JTokenType.Boolean && !(bool)student["Active"]) return false;
            string status = Read(student, "Status", "status");
            return !status.Equals("inactive", StringComparison.OrdinalIgnoreCase) &&
                !status.Equals("completed", StringComparison.OrdinalIgnoreCase) &&
                !status.Equals("rejected", StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsCompanySupervisor(JObject user)
        {
            return Read(user, "Role", "role").Equals("Company Supervisor", StringComparison.OrdinalIgnoreCase);
        }

        private static string GetInitials(string name)
        {
            string[] words = (name ?? "").Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (words.Length == 0) return "?";
            if (words.Length == 1) return words[0].Substring(0, 1).ToUpperInvariant();
            return (words[0].Substring(0, 1) + words[words.Length - 1].Substring(0, 1)).ToUpperInvariant();
        }

        private static bool IsValidEmail(string value)
        {
            try { return new MailAddress(value).Address == value; }
            catch (FormatException) { return false; }
        }

        private static bool IsWebUrl(string value)
        {
            Uri uri;
            return Uri.TryCreate(value, UriKind.Absolute, out uri) &&
                (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps);
        }

        private static bool IsSupportedImage(string extension, string contentType)
        {
            return (extension == ".jpg" || extension == ".jpeg") && contentType == "image/jpeg" ||
                extension == ".png" && contentType == "image/png" ||
                extension == ".gif" && contentType == "image/gif" ||
                extension == ".webp" && contentType == "image/webp";
        }

        private static bool IsSupportedImageData(string value)
        {
            return value.StartsWith("data:image/jpeg;base64,", StringComparison.OrdinalIgnoreCase) ||
                value.StartsWith("data:image/png;base64,", StringComparison.OrdinalIgnoreCase) ||
                value.StartsWith("data:image/gif;base64,", StringComparison.OrdinalIgnoreCase) ||
                value.StartsWith("data:image/webp;base64,", StringComparison.OrdinalIgnoreCase);
        }

        private static string GetUserUrl(string id)
        {
            return DatabaseUrl + "Users/" + HttpUtility.UrlEncode(id) + ".json";
        }

        private static string Read(JObject user, params string[] keys)
        {
            foreach (string key in keys)
                if (user[key] != null && user[key].Type != JTokenType.Null) return user[key].ToString();
            return "";
        }

        private static string EncodeOrFallback(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "-" : HttpUtility.HtmlEncode(value);
        }

        private void ShowMessage(string text)
        {
            PageMessage.Text = HttpUtility.HtmlEncode(text);
        }
    }
}

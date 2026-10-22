using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using PSUTInternship.Shared;

namespace PSUTInternship
{
    public partial class Login : Page
    {
        private const string FirebaseApiKey = "AIzaSyATkBtZqIJO1rjyZuaGsykNtcOFBubukvk";

        protected async void loginButton_Click(object sender, EventArgs e)
        {
            string email = emailTextBox.Text.Trim();
            string password = passwordTextBox.Text;
            if (email == "" || password == "")
            {
                messageLabel.Text = "Enter your email and password.";
                return;
            }

            JavaScriptSerializer serializer = new JavaScriptSerializer();
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    string authUrl = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" + Uri.EscapeDataString(FirebaseApiKey);
                    var loginData = new Dictionary<string, object>();
                    loginData["email"] = email;
                    loginData["password"] = password;
                    loginData["returnSecureToken"] = true;

                    using (StringContent content = new StringContent(serializer.Serialize(loginData), Encoding.UTF8, "application/json"))
                    {
                        HttpResponseMessage authResponse = await client.PostAsync(authUrl, content);
                        string authJson = await authResponse.Content.ReadAsStringAsync();
                        if (!authResponse.IsSuccessStatusCode)
                        {
                            messageLabel.Text = "Email or password is incorrect. Check that Email/Password sign-in is enabled in Firebase Authentication.";
                            return;
                        }

                        var auth = serializer.Deserialize<Dictionary<string, object>>(authJson);
                        string uid = Convert.ToString(auth["localId"]);
                        string idToken = Convert.ToString(auth["idToken"]);

                        // Preferred profile location: Realtime Database /users/{Firebase UID}.
                        string profileId = uid;
                        Dictionary<string, object> user = await GetProfile(client, serializer, uid, idToken);

                        // Older project data may have a random database key, so try its email field too.
                        if (user == null)
                        {
                            KeyValuePair<string, Dictionary<string, object>> match =
                                await FindProfileByEmail(client, serializer, email, idToken);
                            profileId = match.Key;
                            user = match.Value;
                        }

                        if (user == null || !user.ContainsKey("role"))
                        {
                            messageLabel.Text = "Firebase login succeeded, but the profile is missing. Add a record under Realtime Database /users using this account's UID as the key.";
                            return;
                        }

                        if (!user.ContainsKey("isActive") || !String.Equals(Convert.ToString(user["isActive"]), "true", StringComparison.OrdinalIgnoreCase))
                        {
                            messageLabel.Text = "This account is inactive. Ask the coordinator to activate it.";
                            return;
                        }

                        string role = Convert.ToString(user["role"]);
                        Session["userId"] = uid;
                        Session["profileId"] = String.IsNullOrEmpty(Convert.ToString(user.ContainsKey("profileId") ? user["profileId"] : null)) ? profileId : Convert.ToString(user["profileId"]);
                        Session["userEmail"] = email;
                        Session["userRole"] = role;
                        Session["idToken"] = idToken;

                        if (user.ContainsKey("mustChangePassword") && String.Equals(Convert.ToString(user["mustChangePassword"]), "true", StringComparison.OrdinalIgnoreCase))
                        {
                            GoTo("~/ChangePassword.aspx");
                            return;
                        }

                        if (String.Equals(role, "coordinator", StringComparison.OrdinalIgnoreCase))
                            GoTo("~/Coordinator/Dashboard.aspx");
                        else if (String.Equals(role, "student", StringComparison.OrdinalIgnoreCase))
                            GoTo("~/Student/StudentDashboard.aspx");
                        else if (String.Equals(role, "academicSupervisor", StringComparison.OrdinalIgnoreCase))
                            GoTo("~/AcademicSupervisor/AcademicDashboard.aspx");
                        else if (String.Equals(role, "companySupervisor", StringComparison.OrdinalIgnoreCase))
                            GoTo("~/CompanySupervisor/CompanyDashboard.aspx");
                        else
                        {
                            Session.Clear();
                            messageLabel.Text = "This user's role is missing or not recognized. Check the role field under /users in Firebase.";
                        }
                    }
                }
                catch (Exception ex)
                {
                    messageLabel.Text = "Login error: " + HttpUtility.HtmlEncode(ex.Message);
                }
            }
        }

        private async Task<Dictionary<string, object>> GetProfile(HttpClient client, JavaScriptSerializer serializer, string uid, string idToken)
        {
            string url = FirebaseConfig.DatabaseUrl + "/Student/Opportunities/" + Uri.EscapeDataString(uid) + ".json?auth=" + Uri.EscapeDataString(idToken);
            HttpResponseMessage response = await client.GetAsync(url);
            if (!response.IsSuccessStatusCode)
                throw new Exception("Could not read Firebase /users profile. Check Database rules.");
            string json = await response.Content.ReadAsStringAsync();
            if (String.IsNullOrWhiteSpace(json) || json == "null") return null;
            return serializer.Deserialize<Dictionary<string, object>>(json);
        }

        private async Task<KeyValuePair<string, Dictionary<string, object>>> FindProfileByEmail(HttpClient client, JavaScriptSerializer serializer, string email, string idToken)
        {
            string query = "?orderBy=%22email%22&equalTo=" + Uri.EscapeDataString("\"" + email + "\"") + "&auth=" + Uri.EscapeDataString(idToken);
            HttpResponseMessage response = await client.GetAsync(FirebaseConfig.DatabaseUrl + "/Student/Opportunities.json" + query);
            if (!response.IsSuccessStatusCode)
                throw new Exception("Could not search Firebase /users by email. Check Database rules.");
            string json = await response.Content.ReadAsStringAsync();
            if (String.IsNullOrWhiteSpace(json) || json == "null")
                return new KeyValuePair<string, Dictionary<string, object>>(null, null);
            var users = serializer.Deserialize<Dictionary<string, Dictionary<string, object>>>(json);
            if (users == null || users.Count == 0)
                return new KeyValuePair<string, Dictionary<string, object>>(null, null);
            foreach (var item in users)
                return new KeyValuePair<string, Dictionary<string, object>>(item.Key, item.Value);
            return new KeyValuePair<string, Dictionary<string, object>>(null, null);
        }

        private void GoTo(string page)
        {
            Response.Redirect(page, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }

}



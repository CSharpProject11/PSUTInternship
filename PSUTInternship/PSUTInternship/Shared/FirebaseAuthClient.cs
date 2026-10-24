using PSUTInternship.Models;
using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PSUTInternship.Shared
{
    public static class FirebaseAuthClient
    {
        private static readonly HttpClient Client = PSUTInternship.Shared.FirebaseConfig.CreateClient();

        public static async Task<FirebaseSignInResult> SignInAsync(string email, string password, string apiKey)
        {
            if (string.IsNullOrWhiteSpace(apiKey))
                throw new InvalidOperationException("FirebaseWebApiKey is missing from Web.config.");

            string url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" + Uri.EscapeDataString(apiKey);
            string json = JsonConvert.SerializeObject(new { email = email, password = password, returnSecureToken = true });
            using (var content = new StringContent(json, Encoding.UTF8, "application/json"))
            using (HttpResponseMessage response = await Client.PostAsync(url, content).ConfigureAwait(false))
            {
                string responseText = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
                if (!response.IsSuccessStatusCode)
                    throw new InvalidOperationException(GetSignInError(responseText));
                return JsonConvert.DeserializeObject<FirebaseSignInResult>(responseText);
            }
        }


        public static async Task<JObject> RefreshAsync(string refreshToken)
        {
            using (var content = new FormUrlEncodedContent(new System.Collections.Generic.Dictionary<string, string>
                { { "grant_type", "refresh_token" }, { "refresh_token", refreshToken } }))
            using (var response = await Client.PostAsync("https://securetoken.googleapis.com/v1/token?key=" + Uri.EscapeDataString(FirebaseConfig.ApiKey), content).ConfigureAwait(false))
            {
                response.EnsureSuccessStatusCode();
                return JObject.Parse(await response.Content.ReadAsStringAsync().ConfigureAwait(false));
            }
        }
        public static async Task<FirebaseSignInResult> ChangePasswordAsync(string token, string password)
        {
            var payload = new { idToken = token, password = password, returnSecureToken = true };
            using (var content = new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json"))
            using (var response = await Client.PostAsync("https://identitytoolkit.googleapis.com/v1/accounts:update?key=" + Uri.EscapeDataString(FirebaseConfig.ApiKey), content).ConfigureAwait(false))
            {
                string body = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
                if (!response.IsSuccessStatusCode) throw new InvalidOperationException("Password change was rejected. Use a stronger password or sign in again.");
                return JsonConvert.DeserializeObject<FirebaseSignInResult>(body);
            }
        }
        public static async Task SendPasswordResetAsync(string email)
        {
            using (var content = new StringContent(JsonConvert.SerializeObject(new { requestType = "PASSWORD_RESET", email = email }), Encoding.UTF8, "application/json"))
            using (var response = await Client.PostAsync("https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=" + Uri.EscapeDataString(FirebaseConfig.ApiKey), content).ConfigureAwait(false))
                response.EnsureSuccessStatusCode();
        }
        private static string GetSignInError(string responseText)
        {
            string code = "";
            try
            {
                JObject response = JObject.Parse(responseText);
                code = (string)response["error"]["message"];
            }
            catch (Exception) { }

            switch (code)
            {
                case "EMAIL_NOT_FOUND":
                case "INVALID_PASSWORD":
                case "INVALID_LOGIN_CREDENTIALS":
                    return "Email or password is incorrect. Check the account under Firebase Authentication > Users.";
                case "OPERATION_NOT_ALLOWED":
                    return "Email/Password sign-in is disabled. Enable it under Firebase Authentication > Sign-in method.";
                case "API_KEY_INVALID":
                case "PROJECT_NOT_FOUND":
                    return "Firebase API key is invalid or belongs to another Firebase project. Check Web.config.";
                case "TOO_MANY_ATTEMPTS_TRY_LATER":
                    return "Too many sign-in attempts. Wait a few minutes and try again.";
                case "CONFIGURATION_NOT_FOUND":
                    return "Firebase Authentication is not configured for the project used by this API key.";
                default:
                    return "Firebase rejected the sign-in request (" + (string.IsNullOrEmpty(code) ? "unknown error" : code) + "). Check the Firebase project and Authentication settings.";
            }
        }
    }
}

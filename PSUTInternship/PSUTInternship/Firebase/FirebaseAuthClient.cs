using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PSUTInternship.Firebase
{
    public class FirebaseSignInResult
    {
        [JsonProperty("idToken")] public string IdToken { get; set; }
        [JsonProperty("refreshToken")] public string RefreshToken { get; set; }
        [JsonProperty("localId")] public string UserId { get; set; }
        [JsonProperty("email")] public string Email { get; set; }
    }

    public static class FirebaseAuthClient
    {
        private static readonly HttpClient Client = new HttpClient { Timeout = TimeSpan.FromSeconds(15) };

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

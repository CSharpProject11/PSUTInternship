using System;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PSUTInternship.Shared
{
    // REST helper for Realtime Database. Pass an ID token after Firebase sign-in.
    public static class FirebaseRestClient
    {
        private static readonly HttpClient Client = PSUTInternship.Shared.FirebaseConfig.CreateClient();

        public static async Task<T> GetAsync<T>(string path, string idToken)
        {
            string json = await SendAsync(HttpMethod.Get, path, null, idToken).ConfigureAwait(false);
            if (string.IsNullOrWhiteSpace(json) || json == "null") return default(T);
            return JsonConvert.DeserializeObject<T>(json);
        }

        public static async Task PutAsync<T>(string path, T value, string idToken)
        {
            await SendAsync(HttpMethod.Put, path, value, idToken).ConfigureAwait(false);
        }

        public static async Task PatchAsync<T>(string path, T value, string idToken)
        {
            await SendAsync(new HttpMethod("PATCH"), path, value, idToken).ConfigureAwait(false);
        }

        public static async Task<string> PostAsync<T>(string path, T value, string idToken)
        {
            return await SendAsync(HttpMethod.Post, path, value, idToken).ConfigureAwait(false);
        }

        private static async Task<string> SendAsync(HttpMethod method, string path, object value, string idToken)
        {
            if (string.IsNullOrWhiteSpace(idToken))
                throw new InvalidOperationException("Sign in with Firebase Authentication before using the database.");

            string databaseUrl = FirebaseConfig.DatabaseUrl;
            if (string.IsNullOrWhiteSpace(databaseUrl))
                throw new ConfigurationErrorsException("FirebaseDatabaseUrl is missing from Web.config.");

            string cleanPath = (path ?? "").Trim('/');
            int queryIndex = cleanPath.IndexOf('?');
            string query = queryIndex >= 0 ? cleanPath.Substring(queryIndex + 1) : "";
            if (queryIndex >= 0) cleanPath = cleanPath.Substring(0, queryIndex);
            string url = databaseUrl.TrimEnd('/') + "/" + cleanPath + ".json";
            url += string.IsNullOrEmpty(query) ? "?" : "?" + query + "&";
            url += "auth=" + Uri.EscapeDataString(idToken);

            using (var request = new HttpRequestMessage(method, url))
            {
                if (value != null)
                {
                    string json = JsonConvert.SerializeObject(value);
                    request.Content = new StringContent(json, Encoding.UTF8, "application/json");
                }

                using (HttpResponseMessage response = await Client.SendAsync(request).ConfigureAwait(false))
                {
                    string responseText = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
                    if (!response.IsSuccessStatusCode)
                    {
                        // Firebase explains invalid queries (including missing indexes) in the body.
                        // Never include the request URL: it contains the authentication token.
                        string detail = "";
                        try { detail = (string)JObject.Parse(responseText)["error"] ?? ""; }
                        catch (JsonException) { }
                        if (detail.Length > 600) detail = detail.Substring(0, 600);
                        detail = detail.Replace(idToken, "[redacted]");
                        throw new HttpRequestException("Firebase " + method.Method + " /" + cleanPath + " failed (" +
                            (int)response.StatusCode + "). " + detail);
                    }
                    return responseText;
                }
            }
        }
    }
}

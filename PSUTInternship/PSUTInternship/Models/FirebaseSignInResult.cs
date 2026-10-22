using Newtonsoft.Json;
namespace PSUTInternship.Models
{
    public class FirebaseSignInResult
    {
        [JsonProperty("idToken")] public string IdToken { get; set; }
        [JsonProperty("refreshToken")] public string RefreshToken { get; set; }
        [JsonProperty("localId")] public string UserId { get; set; }
        [JsonProperty("expiresIn")] public int ExpiresIn { get; set; }
        [JsonProperty("email")] public string Email { get; set; }
    }


}

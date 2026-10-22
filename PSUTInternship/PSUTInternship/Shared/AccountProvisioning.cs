using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Shared
{
    public static class AccountProvisioning
    {
        public static async Task<string> Create(string email,string password)
        {
            if(PortalRoles.Normalize(Convert.ToString(PortalRepository.RequestContext.Session["userRole"]))!="admin")throw new UnauthorizedAccessException("Only the coordinator creates portal accounts.");
            if(password.Length<8)throw new ArgumentException("Temporary passwords must contain at least eight characters.");
            using(var content=new StringContent(JsonConvert.SerializeObject(new {email=email,password=password,returnSecureToken=true}),Encoding.UTF8,"application/json"))
            using(var response=await FirebaseConfig.Client.PostAsync("https://identitytoolkit.googleapis.com/v1/accounts:signUp?key="+Uri.EscapeDataString(FirebaseConfig.ApiKey),content))
            {
                var body=JObject.Parse(await response.Content.ReadAsStringAsync());
                if(!response.IsSuccessStatusCode)throw new InvalidOperationException("Firebase could not create the account. Check the email, password policy and Email/Password sign-in settings.");
                return (string)body["localId"];
            }
        }
    }
}
using System;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using PSUTInternship.Shared;
class TransportChecks
{
    static int Main()
    {
        try
        {
            var result = FirebaseRestClient.GetAsync<Newtonsoft.Json.Linq.JObject>("evaluations?orderBy=%22internshipId%22&equalTo=%22placement1%22", "test-secret-token").GetAwaiter().GetResult();
            throw new Exception("Expected rejection.");
        }
        catch (HttpRequestException ex)
        {
            if (!ex.Message.Contains("Firebase GET /evaluations failed (400)") || !ex.Message.Contains("Index not defined") || ex.Message.Contains("test-secret-token") || ex.Message.Contains("auth=")) throw;
            Console.WriteLine("PASS Firebase 400 includes its cause and collection without exposing credentials.");
            return 0;
        }
    }
}
namespace PSUTInternship.Shared
{
    public static class FirebaseConfig
    {
        public static string DatabaseUrl { get { return "https://offline.invalid/"; } }
        public static HttpClient CreateClient() { return new HttpClient(new RejectHandler()); }
        class RejectHandler : HttpMessageHandler
        {
            protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken token)
            {
                return Task.FromResult(new HttpResponseMessage(HttpStatusCode.BadRequest) { Content = new StringContent("{\"error\":\"Index not defined, add .indexOn for internshipId\"}") });
            }
        }
    }
}

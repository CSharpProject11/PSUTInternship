using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web;

namespace PSUTInternship.Shared
{
    public static class FirebaseConfig
    {
        public static readonly string DatabaseUrl =
            "https://csharp-e078c-default-rtdb.firebaseio.com/";
        public static readonly HttpClient Client = new HttpClient();
    }
}
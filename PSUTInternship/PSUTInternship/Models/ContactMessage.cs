using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Models {
        public class ContactMessage
        {
            public string Id { get; set; }
            public string Sender { get; set; }
            public string Email { get; set; }
            public string Subject { get; set; }
            public string Message { get; set; }
            public string Status { get; set; }
            public string Reply { get; set; }
        }
}

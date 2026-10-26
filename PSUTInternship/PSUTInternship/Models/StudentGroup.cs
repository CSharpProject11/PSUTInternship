using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Models {
        public class StudentGroup
        {
            public string id;
            public string department;
            public string name;
            public string supervisorId;
            public string supervisorName;
            public Dictionary<string, object> data;
            public Dictionary<string, object> supervisor;
            public Dictionary<string, object> studentIds;
        }
}

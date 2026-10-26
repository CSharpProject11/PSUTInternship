using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Models {
        public class EvaluationTaskRow
        {
            public string Title { get; set; }
            public string Status { get; set; }
            public string Submission { get; set; }
            public string Feedback { get; set; }
        }
}

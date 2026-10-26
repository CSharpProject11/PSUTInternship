using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Models {
        public class AcademicTaskRow
        {
            public string Title { get; set; }
            public string Score { get; set; }
            public string Description { get; set; }
            public string CreatedAt { get; set; }
            public string DueDate { get; set; }
            public string Status { get; set; }
            public string SubmissionStatus { get; set; }
            public string SubmittedAt { get; set; }
            public string FileName { get; set; }
            public string FileUrl { get; set; }
            public string SubmissionLink { get; set; }
            public string Feedback { get; set; }
            public string ReviewedAt { get; set; }
        }
}

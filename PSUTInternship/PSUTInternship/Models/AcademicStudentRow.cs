using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Models {
        public class AcademicStudentRow
        {
            public string StudentId { get; set; }
            public string StudentName { get; set; }
            public string Company { get; set; }
            public decimal ApprovedHours { get; set; }
            public int RequiredHours { get; set; }
            public int Progress { get; set; }
            public string Status { get; set; }
            public int TaskCount { get; set; }
            public string InternshipId { get; set; }
        }
}

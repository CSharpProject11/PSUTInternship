using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Student
{
 
        public class StudentInfo
        {
            // Personal Information
            public string FullName { get; set; }
            public DateTime DateOfBirth { get; set; }
            public string Email { get; set; }
            public string PhoneNumber { get; set; }
            public string Gender { get; set; }
            public string Address { get; set; }

            // Academic Information
            public string StudentId { get; set; }
            public string University { get; set; }
            public string Faculty { get; set; }
            public string Major { get; set; }
            public int AcademicYear { get; set; }
            public double GPA { get; set; }

            // CV & Portfolio
            public string CVLink { get; set; }
            public string PortfolioLink { get; set; }
        }
    }
using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;

namespace Student
{
    public class StudentInfo
    {
        // Personal Information

        [JsonProperty("fullName")]
        public string FullName { get; set; }

        [JsonProperty("dateOfBirth")]
        public string DateOfBirth { get; set; }

        [JsonProperty("email")]
        public string Email { get; set; }

        [JsonProperty("phone")]
        public string PhoneNumber { get; set; }

        [JsonProperty("gender")]
        public string Gender { get; set; }


        // Academic Information

        [JsonProperty("studentNumber")]
        public string StudentNumber { get; set; }

        [JsonProperty("university")]
        public string University { get; set; }

        [JsonProperty("college")]
        public string College { get; set; }

        [JsonProperty("major")]
        public string Major { get; set; }

        [JsonProperty("gpa")]
        public string GPA { get; set; }

        [JsonProperty("academicSemester")]
        public string AcademicSemester { get; set; }

        [JsonProperty("completedCreditHours")]
        public int? CompletedCreditHours { get; set; }

        [JsonProperty("applicationDate")]
        public string ApplicationDate { get; set; }


        // Professional Information

        [JsonProperty("githubUrl")]
        public string GithubUrl { get; set; }

        [JsonProperty("linkedinUrl")]
        public string LinkedinUrl { get; set; }

        [JsonProperty("portfolioUrl")]
        public string PortfolioLink { get; set; }

        [JsonProperty("cvUrl")]
        public string CvUrl { get; set; }
    }
}

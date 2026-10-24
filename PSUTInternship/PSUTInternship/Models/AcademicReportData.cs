using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Models {
        public class AcademicReportData
        {
            public string StudentId;
            public string StudentName;
            public string StudentNumber;
            public string Company;
            public string InternshipId;
            public double ApprovedHours;
            public double RequiredHours;
            public List<EvaluationTaskRow> Tasks = new List<EvaluationTaskRow>();
            public JToken CompanyEvaluation;
            public JToken AcademicEvaluation;
            public string CompanyFileUrl;
            public string CompanyResult;
            public string CompanyFeedback;
        }
}

using System;
using System.Configuration;
namespace PSUTInternship.Shared
{
    // Proposed project policy; replace with the college's approved weights in Web.config.
    public static class EvaluationPolicy
    {
        private static decimal Setting(string key) { return decimal.Parse(ConfigurationManager.AppSettings[key], System.Globalization.CultureInfo.InvariantCulture); }
        public static decimal CompanyWeight { get { return Setting("CompanyEvaluationWeight"); } }
        public static decimal AcademicWeight { get { return Setting("AcademicEvaluationWeight"); } }
        public static decimal AcademicMaximum { get { return Setting("AcademicEvaluationMaximum"); } }
        public static decimal PassGrade { get { return Setting("CompletionPassGrade"); } }
        public static decimal FinalGrade(decimal company, decimal maximum, decimal academic)
        {
            if (maximum <= 0 || AcademicMaximum <= 0 || company < 0 || company > maximum || academic < 0 || academic > AcademicMaximum
                || CompanyWeight < 0 || AcademicWeight < 0 || CompanyWeight + AcademicWeight != 100)
                throw new InvalidOperationException("Evaluation scores or configured weights are invalid.");
            return Math.Round(company / maximum * CompanyWeight + academic / AcademicMaximum * AcademicWeight, 2);
        }
    }
}

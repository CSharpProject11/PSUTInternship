using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System;

namespace PSUTInternship.Models
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum ApplicationStatus
    {
        Pending,
        Approved,
        Rejected
    }

    public class Application
    {
        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("opportunityId")]
        public string OpportunityId { get; set; }

        [JsonProperty("studentId")]
        public string StudentId { get; set; }

        [JsonProperty("companyId")] public string CompanyId { get; set; }
        [JsonProperty("academicSupervisorId")] public string AcademicSupervisorId { get; set; }
        [JsonProperty("rejectionReason")] public string RejectionReason { get; set; }
        [JsonProperty("coverLetter")]
        public string Reason { get; set; }
        [JsonProperty("reason")] private string LegacyReason { set { if (string.IsNullOrEmpty(Reason)) Reason = value; } }
        [JsonProperty("cvUrl")] public string CvUrl { get; set; }
        [JsonProperty("isOfferConfirmed")] public bool IsOfferConfirmed { get; set; }

        [JsonProperty("studentResponse", NullValueHandling = NullValueHandling.Ignore)]
        public StudentOfferResponse StudentResponse { get; set; }

        [JsonProperty("status")]
        public ApplicationStatus Status { get; set; } = ApplicationStatus.Pending;

        [JsonProperty("appliedAt")]
        public DateTime AppliedAt { get; set; } = DateTime.UtcNow;

        [JsonProperty("details")]
        public TrainingApplicationDetails Details { get; set; } = new TrainingApplicationDetails();
    }

    public class TrainingApplicationDetails
    {
        [JsonProperty("faculty")]
        public string Faculty { get; set; }

        [JsonProperty("department")]
        public string Department { get; set; }

        [JsonProperty("program")]
        public string Program { get; set; }

        [JsonProperty("semester")]
        public string Semester { get; set; }

        [JsonProperty("academicYear")]
        public string AcademicYear { get; set; }

        [JsonProperty("applicationDate")]
        public DateTime ApplicationDate { get; set; }

        [JsonProperty("studentName")]
        public string StudentName { get; set; }

        [JsonProperty("universityId")]
        public string UniversityId { get; set; }

        [JsonProperty("completedCreditHours")]
        public int CompletedCreditHours { get; set; }

        [JsonProperty("studentPhone")]
        public string StudentPhone { get; set; }

        [JsonProperty("studentEmail")]
        public string StudentEmail { get; set; }

        [JsonProperty("alternativePhone")]
        public string AlternativePhone { get; set; }

        [JsonProperty("organizationName")]
        public string OrganizationName { get; set; }

        [JsonProperty("organizationPhone")]
        public string OrganizationPhone { get; set; }

        [JsonProperty("mailingAddress")]
        public string MailingAddress { get; set; }

        [JsonProperty("organizationEmail")]
        public string OrganizationEmail { get; set; }

        [JsonProperty("organizationWebsite")]
        public string OrganizationWebsite { get; set; }

        [JsonProperty("trainingAddress")]
        public string TrainingAddress { get; set; }

        [JsonProperty("trainingStartDate")]
        public DateTime TrainingStartDate { get; set; }

        [JsonProperty("trainingEndDate")]
        public DateTime TrainingEndDate { get; set; }

        [JsonProperty("trainingField")]
        public string TrainingField { get; set; }
    }

    public class StudentOfferResponse
    {
        [JsonProperty("decision")]
        public string Decision { get; set; }

        [JsonProperty("respondedAt")]
        public DateTime RespondedAt { get; set; }
    }
    public class InternshipConfirmation
    {
        [JsonProperty("applicationId")]
        public string ApplicationId { get; set; }

        [JsonProperty("confirmedAt")]
        public DateTime ConfirmedAt { get; set; }
    }
}

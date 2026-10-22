using Newtonsoft.Json;

namespace PSUTInternship.Models
{
    public class CompanyOpportunity
    {
        public string Id { get; set; }
        [JsonProperty("companyId")] public string CompanyId { get; set; }
        [JsonProperty("title")] public string Title { get; set; }
        [JsonProperty("specialization")] public string Specialization { get; set; }
        [JsonProperty("description")] public string Description { get; set; }
        [JsonProperty("requirements")] public string Requirements { get; set; }
        [JsonProperty("availableSeats")] public int Seats { get; set; }
        [JsonProperty("isOpen")] public bool IsOpen { get; set; }
        [JsonProperty("status")] public string Status { get; set; }
        [JsonProperty("applicationDeadline")] public string Deadline { get; set; }
        [JsonProperty("createdAt")] public string CreatedAt { get; set; }
    }

    public class CompanyApplication
    {
        public string Id { get; set; }
        [JsonProperty("studentId")] public string StudentId { get; set; }
        [JsonProperty("studentName")] public string Student { get; set; }
        [JsonProperty("opportunityId")] public string OpportunityId { get; set; }
        [JsonProperty("opportunityTitle")] public string Opportunity { get; set; }
        [JsonProperty("companyId")] public string CompanyId { get; set; }
        [JsonProperty("appliedAt")] public string Applied { get; set; }
        [JsonProperty("status")] public string Status { get; set; }
        [JsonProperty("college")] public string College { get; set; }
        [JsonProperty("skills")] public string Skills { get; set; }
        [JsonProperty("cvOrPortfolioUrl")] public string Cv { get; set; }
        [JsonProperty("message")] public string Message { get; set; }
        [JsonProperty("rejectionReason")] public string RejectionReason { get; set; }
        [JsonProperty("studentConfirmed")] public bool StudentConfirmed { get; set; }
    }

    public class CompanyAccount
    {
        [JsonProperty("displayName")] public string Name { get; set; }
        [JsonProperty("email")] public string Email { get; set; }
        [JsonProperty("phone")] public string Phone { get; set; }
        [JsonProperty("contactInfo")] public string ContactInfo { get; set; }
        [JsonProperty("companyName")] public string CompanyName { get; set; }
        [JsonProperty("role")] public string Role { get; set; }
        [JsonProperty("isActive")] public bool IsActive { get; set; }
    }

    public class CompanyTrainee
    {
        public string Id { get; set; }
        [JsonProperty("studentId")] public string StudentId { get; set; }
        [JsonProperty("studentName")] public string StudentName { get; set; }
        [JsonProperty("applicationId")] public string ApplicationId { get; set; }
        [JsonProperty("opportunityId")] public string OpportunityId { get; set; }
        [JsonProperty("opportunityTitle")] public string OpportunityTitle { get; set; }
        [JsonProperty("companyId")] public string CompanyId { get; set; }
        [JsonProperty("tasksCompleted")] public int TasksCompleted { get; set; }
        [JsonProperty("tasksTotal")] public int TasksTotal { get; set; }
        [JsonProperty("approvedTrainingHours")] public int ApprovedTrainingHours { get; set; }
        [JsonProperty("hoursPendingApproval")] public int HoursPendingApproval { get; set; }
        [JsonProperty("status")] public string Status { get; set; }
    }

    public class CompanyTaskSubmission
    {
        public string Id { get; set; }
        [JsonProperty("studentId")] public string StudentId { get; set; }
        [JsonProperty("studentName")] public string StudentName { get; set; }
        [JsonProperty("companyId")] public string CompanyId { get; set; }
        [JsonProperty("taskTitle")] public string TaskTitle { get; set; }
        [JsonProperty("dueDate")] public string DueDate { get; set; }
        [JsonProperty("status")] public string Status { get; set; }
        [JsonProperty("hoursSubmitted")] public int HoursSubmitted { get; set; }
        [JsonProperty("hoursApproved")] public bool HoursApproved { get; set; }
    }
}

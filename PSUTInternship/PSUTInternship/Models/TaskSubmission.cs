using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PSUTInternship.Models
{
    public class TaskSubmission
    {

        [JsonProperty("taskId")]
        public string TaskId { get; set; }

        [JsonProperty("studentId")]
        public string StudentId { get; set; }

        [JsonProperty("answer")]
        public string Answer { get; set; }

        [JsonProperty("attachmentUrl")]
        public string AttachmentUrl { get { return !string.IsNullOrWhiteSpace(attachmentUrl) ? attachmentUrl : !string.IsNullOrWhiteSpace(FileUrl) ? FileUrl : SubmissionLink; } set { attachmentUrl = value; } }
        private string attachmentUrl;
        [JsonProperty("fileUrl")] public string FileUrl { get; set; }
        [JsonProperty("submissionLink")] public string SubmissionLink { get; set; }
        [JsonProperty("feedback")] public string Feedback { get; set; }
        [JsonProperty("status")] public string Status { get; set; }
        [JsonProperty("internshipId")] public string InternshipId { get; set; }

        [JsonProperty("submittedAt")]
        public string SubmittedAt { get; set; }

        [JsonProperty("updatedAt")]
        public string UpdatedAt { get; set; }
        
    
}
}

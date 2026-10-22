using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApplication1
{
    public class StudentTask
    {
        [JsonProperty("taskId")]
        public string TaskId { get; set; }

        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("studentId")]
        public string StudentId { get; set; }

        [JsonProperty("assignedBy")]
        public string AssignedBy { get; set; }

        [JsonProperty("dueDate")]
        public string DueDate { get; set; }

        [JsonProperty("status")]
        public string Status { get; set; }

        // Student Answer
        [JsonProperty("answer")]
        public string Answer { get; set; }

        // PDF or Image path
        [JsonProperty("attachmentUrl")]
        public string AttachmentUrl { get; set; }

        [JsonProperty("submittedAt")]
        public string SubmittedAt { get; set; }
        [JsonIgnore]
        public string StudentAnswer { get; set; }
        [JsonIgnore]
        public string StudentPdfUrl { get; set; }
        [JsonIgnore]
        public bool CanSubmit { get; set; }

        [JsonIgnore]
        public bool HasSubmission { get; set; }

        [JsonIgnore]
        public string ButtonText { get; set; }

        [JsonIgnore]
        public bool HasPdfLink { get; set; }
    }
}
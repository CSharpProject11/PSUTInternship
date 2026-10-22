using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApplication1
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
        public string AttachmentUrl { get; set; }

        [JsonProperty("submittedAt")]
        public string SubmittedAt { get; set; }

        [JsonProperty("updatedAt")]
        public string UpdatedAt { get; set; }
        
    
}
}
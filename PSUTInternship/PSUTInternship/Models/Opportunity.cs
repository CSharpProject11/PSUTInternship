using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PSUTInternship.Models
{
    public class Opportunity
    {
        public string Id { get; set; }

        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("companyId")]
        public string CompanyId { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("location")]
        public string Location { get; set; }

        [JsonProperty("workMode")]
        public string WorkMode { get; set; }

        [JsonProperty("requirements")]
        public string Requirements { get; set; }

        [JsonProperty("duration")]
        public int Duration { get; set; }

        [JsonProperty("deadline")]
        public DateTime DeadLine { get; set; }

        [JsonProperty("status")]
        public bool Status { get; set; }

        [JsonProperty("createdAt")]
        public string CreatedAt { get; set; }

        [JsonProperty("imageUrl")]
        public string ImageUrl { get; set; }

        public Opportunity(string id, string title, string companyId, string description, string location, string workMode, string requirements, int duration, DateTime deadLine, bool status, string createdAt, string imageUrl)
        {
            Id = id;
            Title = title;
            this.CompanyId = companyId;
            this.Description = description;
            Location = location;
            WorkMode = workMode;
            Requirements = requirements;
            Duration = duration;
            DeadLine = deadLine;
            this.Status = status;
            CreatedAt = createdAt;
            ImageUrl = imageUrl;
        }
    }
}

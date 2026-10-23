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
        [JsonProperty("specialization")] public string Specialization { get; set; }
        [JsonProperty("college")] public string College { get; set; }
        [JsonProperty("availableSeats")] public int AvailableSeats { get; set; }
        [JsonProperty("companyName")] public string CompanyName { get; set; }
        [JsonIgnore] public bool HasApplied { get; set; }
        [JsonIgnore] public bool IsAccepting { get { return Status && (DeadLine == DateTime.MinValue || DeadLine.Date >= DateTime.UtcNow.Date); } }
        [JsonIgnore] public string StatusLabel { get { return IsAccepting ? "Open" : "Closed"; } }
        [JsonIgnore] public string LocationDisplay { get { return string.IsNullOrWhiteSpace(Location) ? "Location not specified" : Location; } }
        [JsonIgnore] public string WorkModeDisplay { get { return string.IsNullOrWhiteSpace(WorkMode) ? "Work type not specified" : WorkMode; } }
        public Opportunity() { }

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
        [JsonProperty("workType")] private string LegacyWorkType { set { if (string.IsNullOrWhiteSpace(WorkMode)) WorkMode = value; } }

        [JsonProperty("requirements")]
        public string Requirements { get; set; }

        [JsonProperty("duration")]
        public string Duration { get; set; }
        [JsonIgnore] public string DurationDisplay { get { int months; return int.TryParse(Duration, out months) ? months + " months" : Duration; } }

        [JsonProperty("deadline")]
        public DateTime DeadLine { get; set; }

        [JsonProperty("status")]
        [JsonConverter(typeof(PSUTInternship.Shared.OpportunityStatusConverter))]
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
            Duration = duration.ToString(System.Globalization.CultureInfo.InvariantCulture);
            DeadLine = deadLine;
            this.Status = status;
            CreatedAt = createdAt;
            ImageUrl = imageUrl;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Shared
{
    public static class TrainingHoursWorkflow
    {
        private static string ReadEtag(HttpResponseMessage response)
        {
            if (response.Headers.ETag != null) return response.Headers.ETag.ToString();
            IEnumerable<string> values;
            return response.Headers.TryGetValues("ETag", out values) ? values.FirstOrDefault() : null;
        }

        public static async Task Submit(DateTime date, decimal hours, string description)
        {
            string uid = PortalRepository.UserId;
            var placement = await PortalRepository.PlacementForStudent(uid);
            if ((string)placement?["status"] != "active") throw new InvalidOperationException("Confirm an active placement before logging hours.");
            if (date.Date > DateTime.Today || hours <= 0 || hours > 24 || description.Trim().Length < 3)
                throw new ArgumentException("Enter a past or current date, 0–24 hours and a description.");
            await FirebaseRestClient.PostAsync("trainingHours", new
            {
                studentId = uid,
                companyId = (string)placement["companyId"],
                academicSupervisorId = (string)placement["academicSupervisorId"],
                internshipId = DatabaseSchema.Id(placement),
                date = date.ToString("yyyy-MM-dd"),
                hours = hours,
                description = description.Trim(),
                status = "Pending",
                submittedAt = DateTime.UtcNow.ToString("o")
            }, PortalRepository.Token);
        }
        public static async Task Review(string id, bool approved)
        {
            var row = await PortalRepository.Get<JObject>("trainingHours/" + PortalRepository.Key(id));
            if (row == null) throw new InvalidOperationException("Hour entry not found.");
            var placement = await PortalRepository.PlacementForRecord(row);
            if ((string)placement["companyId"] != PortalRepository.CompanyId && (string)placement["companySupervisorId"] != PortalRepository.ProfileId) throw new InvalidOperationException("This record does not belong to your company.");
            if ((string)placement?["status"] != "active") throw new InvalidOperationException("Hours cannot be changed after completion.");
            await PortalRepository.Patch("trainingHours/" + id, new { status = approved ? "Approved" : "Rejected", reviewedAt = DateTime.UtcNow.ToString("o"), reviewedBy = PortalRepository.UserId });
            await Recalculate((string)row["studentId"]);
        }
        public static async Task Recalculate(string uid)
        {
            var placement = await PortalRepository.PlacementForStudent(uid);
            if (placement == null) throw new InvalidOperationException("Internship not found.");
            string placementId = DatabaseSchema.Id(placement);
            string url = FirebaseConfig.DatabaseUrl + "internships/" + PortalRepository.Key(placementId) + "/approvedHours.json?auth=" + Uri.EscapeDataString(PortalRepository.Token);
            for (int attempt = 0; attempt < 5; attempt++)
            {
                using (var read = new HttpRequestMessage(HttpMethod.Get, url))
                {
                    if (!read.Headers.TryAddWithoutValidation("X-Firebase-ETag", "true"))
                        throw new InvalidOperationException("The Firebase ETag request header could not be added.");
                    using (var response = await FirebaseConfig.Client.SendAsync(read))
                    {
                        response.EnsureSuccessStatusCode();
                        await response.Content.ReadAsStringAsync();
                        var hours = await PortalRepository.Collection(PortalRepository.Query("trainingHours", "internshipId", placementId));
                        decimal total = hours.Values.Where(x => string.Equals((string)x["status"], "Approved", StringComparison.OrdinalIgnoreCase) && ((string)x["internshipId"] == placementId || string.IsNullOrEmpty((string)x["internshipId"]))).Sum(x => (decimal?)x["hours"] ?? 0);
                        string etag = ReadEtag(response);
                        if (string.IsNullOrWhiteSpace(etag))
                            throw new InvalidOperationException("Firebase did not return an ETag for the approved training-hour total.");

                        using (var save = new HttpRequestMessage(HttpMethod.Put, url))
                        {
                            save.Headers.TryAddWithoutValidation("if-match", etag);
                            save.Content = new StringContent(JsonConvert.SerializeObject(total), Encoding.UTF8, "application/json");
                            using (var saved = await FirebaseConfig.Client.SendAsync(save))
                            {
                                if (saved.StatusCode == HttpStatusCode.PreconditionFailed) continue;
                                saved.EnsureSuccessStatusCode(); return;
                            }
                        }
                    }
                }
            }
            throw new InvalidOperationException("Hours changed during review. Refresh and retry to update the total.");
        }
    }
}

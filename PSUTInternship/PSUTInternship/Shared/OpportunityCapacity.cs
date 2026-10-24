using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace PSUTInternship.Shared
{
    public static class OpportunityCapacity
    {
        private static string ReadEtag(HttpResponseMessage response)
        {
            if (response.Headers.ETag != null) return response.Headers.ETag.ToString();
            IEnumerable<string> values;
            if (response.Headers.TryGetValues("ETag", out values)) return values.FirstOrDefault();
            return null;
        }

        private static string ReservationKey(string id)
        {
            using (var hash = SHA256.Create())
                return BitConverter.ToString(hash.ComputeHash(Encoding.UTF8.GetBytes(id))).Replace("-", "").ToLowerInvariant();
        }
        public static async Task Synchronize()
        {
            string role = PortalRoles.Normalize(Convert.ToString(PortalRepository.RequestSession["userRole"]));
            if (role != "admin" && role != "company") throw new InvalidOperationException("Only authorized staff can reconcile opportunity capacity.");
            var openingsTask = PortalRepository.Collection("opportunities");
            var applicationsTask = PortalRepository.Collection("applications");
            var placementsTask = PortalRepository.Collection("internships");
            await Task.WhenAll(openingsTask, applicationsTask, placementsTask).ConfigureAwait(false);
            var applications = applicationsTask.Result;
            foreach (var item in openingsTask.Result)
            {
                var snapshot = item.Value;
                if (snapshot["availableSeats"] == null) continue;
                if (role == "company" && (string)snapshot["companyId"] != PortalRepository.CompanyId) continue;
                var approved = applications.Where(x => (string)x.Value["opportunityId"] == item.Key && DatabaseSchema.WorkflowStatus((string)x.Value["status"]) == "Approved").ToList();
                var keys = new System.Collections.Generic.HashSet<string>(approved.Select(x => ReservationKey(x.Key)));
                foreach (var placement in placementsTask.Result.Values.Where(x => (string)x["opportunityId"] == item.Key && !string.Equals((string)x["status"], "cancelled", StringComparison.OrdinalIgnoreCase)))
                {
                    string applicationId = (string)placement["applicationId"];
                    if (string.IsNullOrEmpty(applicationId)) applicationId = approved.Where(x => (string)x.Value["studentId"] == (string)placement["studentId"]).Select(x => x.Key).FirstOrDefault();
                    keys.Add(ReservationKey(applicationId ?? "student:" + (string)placement["studentId"]));
                }
                var oldKeys = snapshot["seatReservations"] as JObject ?? new JObject();
                if (keys.All(key => (bool?)oldKeys[key] == true) && (int?)snapshot["occupiedSeats"] == oldKeys.Count && (oldKeys.Count < (int)snapshot["availableSeats"] || !DatabaseSchema.IsOpen((string)snapshot["status"]))) continue;
                string url = FirebaseConfig.DatabaseUrl.TrimEnd('/') + "/opportunities/" + PortalRepository.Key(item.Key) + ".json?auth=" + Uri.EscapeDataString(PortalRepository.Token);
                bool synchronized = false;
                for (int attempt = 0; attempt < 5; attempt++)
                {
                    using (var read = new HttpRequestMessage(HttpMethod.Get, url))
                    {
                        if (!read.Headers.TryAddWithoutValidation("X-Firebase-ETag", "true"))
                            throw new InvalidOperationException("The Firebase ETag request header could not be added.");
                        using (var response = await FirebaseConfig.Client.SendAsync(read).ConfigureAwait(false))
                        {
                            response.EnsureSuccessStatusCode();
                            var opening = JObject.Parse(await response.Content.ReadAsStringAsync().ConfigureAwait(false));
                            if ((string)opening["companyId"] != (string)snapshot["companyId"]) throw new InvalidOperationException("Opportunity ownership changed. Refresh and retry.");
                            var reservations = opening["seatReservations"] as JObject ?? new JObject();
                            foreach (string key in keys) reservations[key] = true;
                            opening["seatReservations"] = reservations;
                            opening["occupiedSeats"] = reservations.Count;
                            if (reservations.Count >= (int)opening["availableSeats"]) opening["status"] = false;
                            string etag = ReadEtag(response);
                            if (string.IsNullOrWhiteSpace(etag)) throw new InvalidOperationException("Firebase did not return an ETag for the opportunity. Check that the database endpoint supports conditional requests and that the X-Firebase-ETag header is preserved.");
                            using (var save = new HttpRequestMessage(HttpMethod.Put, url))
                            {
                                save.Headers.TryAddWithoutValidation("if-match", etag);
                                save.Content = new StringContent(opening.ToString(), Encoding.UTF8, "application/json");
                                using (var saved = await FirebaseConfig.Client.SendAsync(save).ConfigureAwait(false))
                                {
                                    if (saved.StatusCode == HttpStatusCode.PreconditionFailed) continue;
                                    saved.EnsureSuccessStatusCode(); synchronized = true; break;
                                }
                            }
                        }
                    }
                }
                if (!synchronized) throw new InvalidOperationException("Seat availability changed during reconciliation. Refresh and retry.");
            }
        }

        // The publicly readable opportunity stores only opaque reservation keys, never student identities.
        public static async Task Reserve(string applicationId)
        {
            if (PortalRoles.Normalize(Convert.ToString(PortalRepository.RequestSession["userRole"])) != "company")
                throw new InvalidOperationException("Only the company can allocate a seat.");
            var application = await PortalRepository.Get<JObject>("applications/" + PortalRepository.Key(applicationId)).ConfigureAwait(false);
            string companyId = PortalRepository.CompanyId;
            if (application == null || (string)application["companyId"] != companyId || DatabaseSchema.WorkflowStatus((string)application["status"]) != "Pending")
                throw new InvalidOperationException("Only pending applications belonging to your company can reserve a seat.");
            string opportunityId = PortalRepository.Key((string)application["opportunityId"]);
            var applications = await PortalRepository.Collection(PortalRepository.Query("applications", "companyId", companyId)).ConfigureAwait(false);
            var approvedKeys = applications.Where(x => (string)x.Value["opportunityId"] == opportunityId && DatabaseSchema.WorkflowStatus((string)x.Value["status"]) == "Approved").Select(x => ReservationKey(x.Key)).ToList();
            string reservation = ReservationKey(applicationId);
            string url = FirebaseConfig.DatabaseUrl.TrimEnd('/') + "/opportunities/" + opportunityId + ".json?auth=" + Uri.EscapeDataString(PortalRepository.Token);
            for (int attempt = 0; attempt < 5; attempt++)
            {
                using (var read = new HttpRequestMessage(HttpMethod.Get, url))
                {
                    if (!read.Headers.TryAddWithoutValidation("X-Firebase-ETag", "true"))
                        throw new InvalidOperationException("The Firebase ETag request header could not be added.");
                    using (var response = await FirebaseConfig.Client.SendAsync(read).ConfigureAwait(false))
                    {
                        response.EnsureSuccessStatusCode();
                        var opening = JObject.Parse(await response.Content.ReadAsStringAsync().ConfigureAwait(false));
                        if ((string)opening["companyId"] != companyId) throw new InvalidOperationException("This opportunity belongs to another company.");
                        int? capacity = (int?)opening["availableSeats"];
                        if (!capacity.HasValue) return; // Legacy records without a seat limit remain unrestricted.
                        var reservations = opening["seatReservations"] as JObject ?? new JObject();
                        foreach (string key in approvedKeys) reservations[key] = true;
                        bool retry = (bool?)reservations[reservation] == true;
                        bool full = !retry && reservations.Count >= capacity.Value;
                        if (!full) reservations[reservation] = true;
                        opening["seatReservations"] = reservations;
                        opening["occupiedSeats"] = reservations.Count;
                        if (reservations.Count >= capacity.Value) opening["status"] = false;
                        string etag = ReadEtag(response);
                        if (string.IsNullOrWhiteSpace(etag)) throw new InvalidOperationException("Firebase did not return an ETag for the opportunity. Check that the database endpoint supports conditional requests and that the X-Firebase-ETag header is preserved.");
                        using (var save = new HttpRequestMessage(HttpMethod.Put, url))
                        {
                            save.Headers.TryAddWithoutValidation("if-match", etag);
                            save.Content = new StringContent(opening.ToString(), Encoding.UTF8, "application/json");
                            using (var saved = await FirebaseConfig.Client.SendAsync(save).ConfigureAwait(false))
                            {
                                if (saved.StatusCode == HttpStatusCode.PreconditionFailed) continue;
                                saved.EnsureSuccessStatusCode();
                                if (full) throw new InvalidOperationException("All seats have been filled. This opportunity is closed.");
                                return;
                            }
                        }
                    }
                }
            }
            throw new InvalidOperationException("Seat availability changed during approval. Refresh and retry.");
        }
    }
}

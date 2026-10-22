using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using System.Net.Http;
using System.Threading.Tasks;
using PSUTInternship.Shared;
using System.Text;


namespace PSUTInternship.Student
{
   

    public partial class MyApplications : System.Web.UI.Page
    {
        private string confirmedApplicationId;

        protected override void OnInit(EventArgs e)
        {
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["idToken"] == null || !string.Equals(Convert.ToString(Session["userRole"]), "student", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(loadApplications));
            }
        }

        private async Task loadApplications()
        {
            ApplicationsRepeater.DataSource = null;
            ApplicationsRepeater.DataBind();
            string studentId = Session["userId"].ToString();
            //System.Diagnostics.Debug.WriteLine("Student ID: " + studentId);
            string token = Session["idToken"].ToString();

            string url = FirebaseConfig.DatabaseUrl
                       + "applications/"
                       + Uri.EscapeDataString(studentId)
                       + ".json?auth="
                       + Uri.EscapeDataString(token);

            try
            {
                await LoadConfirmation();
                string json = await FirebaseConfig.Client.GetStringAsync(url);

                var applications = JsonConvert.DeserializeObject<
                    Dictionary<string, Models.Application>>(json);

                if (applications == null || applications.Count == 0)
                {
                    MessageLabel.Text = "You have not applied to any opportunities yet.";
                    return;
                }
                //This copies each Firebase record’s key into its Id property, so the button sends the correct application ID.
                foreach (var application in applications)
                {
                    if (application.Value == null)
                    {
                        continue;
                    }
                    application.Value.Id = application.Key;
                    if (application.Value.Details == null)
                    {
                        application.Value.Details = new Models.TrainingApplicationDetails();
                    }
                }
                ApplicationsRepeater.DataSource = applications.Values.Where(application => application != null
                    && application.StudentId == studentId);
                ApplicationsRepeater.DataBind();
            }
            catch (HttpRequestException)
            {
                MessageLabel.Text = "Unable to load applications. Please sign in again and retry.";
            }
            catch (JsonException)
            {
                MessageLabel.Text = "The application data could not be read.";
            }
            catch (TaskCanceledException)
            {
                MessageLabel.Text = "Loading timed out. Please try again.";
            }
        }

        protected void ApplicationsRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (Session["userId"] == null || Session["idToken"] == null)
            {
                return;
            }

            string applicationId = e.CommandArgument.ToString();
            if (string.IsNullOrWhiteSpace(applicationId)
                || applicationId.IndexOfAny(new[] { '.', '#', '$', '[', ']', '/', '\\' }) >= 0)
            {
                MessageLabel.Text = "Invalid application. Refresh the page and retry.";
                return;
            }

            if (e.CommandName == "AcceptOffer")
            {
                RegisterAsyncTask(new PageAsyncTask(
                    () => RespondToApplication(applicationId, "Accepted")));
            }
            else if (e.CommandName == "DeclineOffer")
            {
                RegisterAsyncTask(new PageAsyncTask(
                    () => RespondToApplication(applicationId, "Declined")));
            }
        }
        private async Task RespondToApplication(string applicationId, string decision)
        {
            try
            {
                await SaveResponse(applicationId, decision);
            }
            catch (HttpRequestException)
            {
                MessageLabel.Text = "Unable to save your response. Refresh to check its status, or sign in again and retry.";
            }
            catch (JsonException)
            {
                MessageLabel.Text = "The application data could not be read.";
            }
            catch (TaskCanceledException)
            {
                MessageLabel.Text = "The request timed out. Refresh to check whether your response was saved.";
            }

            await loadApplications();
        }

        private async Task SaveResponse(string applicationId, string decision)
        {
            string studentId = Session["userId"].ToString();
            string token = Session["idToken"].ToString();

            string url = FirebaseConfig.DatabaseUrl
                + "applications/"
                + Uri.EscapeDataString(studentId)
                + "/"
                + Uri.EscapeDataString(applicationId)
                + ".json?auth="
                + Uri.EscapeDataString(token);

            string json = await FirebaseConfig.Client.GetStringAsync(url);

            var application = JsonConvert.DeserializeObject<Models.Application>(json);

            if (application == null || application.StudentId != studentId)
            {
                MessageLabel.Text = "Application not found.";
                return;
            }

            if (application.Status != PSUTInternship.Models.ApplicationStatus.Approved)
            {
                MessageLabel.Text = "The company has not approved this application yet.";
                return;
            }

            if (application.StudentResponse != null)
            {
                MessageLabel.Text = "You have already responded to this offer.";
                return;
            }

            await LoadConfirmation();
            if (confirmedApplicationId == applicationId)
            {
                MessageLabel.Text = "You have already confirmed this internship.";
                return;
            }

            var studentResponse = new Models.StudentOfferResponse
            {
                Decision = decision,
                RespondedAt = DateTime.UtcNow
            };
            if (decision == "Accepted")
            {
                if (!string.IsNullOrEmpty(confirmedApplicationId))
                {
                    MessageLabel.Text = "You have already confirmed another internship. You can confirm only one.";
                    return;
                }
                var confirmation = new Models.InternshipConfirmation();
                confirmation.ApplicationId = applicationId;
                confirmation.ConfirmedAt = DateTime.UtcNow;

                string confirmationUrl = FirebaseConfig.DatabaseUrl
                    + "internshipConfirmations/"
                    + Uri.EscapeDataString(studentId)
                    + ".json?auth="
                    + Uri.EscapeDataString(token);

                string confirmationJson = JsonConvert.SerializeObject(confirmation);

                using (var request = new HttpRequestMessage(
                    HttpMethod.Put, confirmationUrl))
                {
                    request.Headers.TryAddWithoutValidation("if-match", "null_etag");

                    request.Content = new StringContent(
                        confirmationJson, Encoding.UTF8, "application/json");

                    using (var response = await FirebaseConfig.Client.SendAsync(request))
                    {
                        if (response.StatusCode == System.Net.HttpStatusCode.PreconditionFailed)
                        {
                            MessageLabel.Text = "You have already confirmed an internship.";
                        }
                        else if (response.IsSuccessStatusCode)
                        {
                            MessageLabel.Text = "Internship confirmed.";
                        }
                        else
                        {
                            MessageLabel.Text = "Could not confirm the internship.";
                        }
                    }
                }

                return;
            }
            if (decision == "Declined")
            {
                string responseUrl = FirebaseConfig.DatabaseUrl
                    + "applications/"
                    + Uri.EscapeDataString(studentId)
                    + "/"
                    + Uri.EscapeDataString(applicationId)
                    + "/studentResponse.json?auth="
                    + Uri.EscapeDataString(token);

                string responseJson = JsonConvert.SerializeObject(studentResponse);

                using (var request = new HttpRequestMessage(HttpMethod.Put, responseUrl))
                {
                    request.Headers.TryAddWithoutValidation("if-match", "null_etag");
                    request.Content = new StringContent(responseJson, Encoding.UTF8, "application/json");

                    using (var response = await FirebaseConfig.Client.SendAsync(request))
                    {
                        if (response.IsSuccessStatusCode)
                        {
                            MessageLabel.Text = "Offer declined.";
                        }
                        else
                        {
                            MessageLabel.Text = "Could not save your response.";
                        }
                    }
                }
            }
        }

        protected string GetApplicationStatus(object item)
        {
            var application = (Models.Application)item;

            if (application.Id == confirmedApplicationId)
            {
                return "Accepted — internship confirmed";
            }

            if (application.StudentResponse != null)
            {
                return application.StudentResponse.Decision;
            }

            if (application.Status == Models.ApplicationStatus.Approved)
            {
                return "Accepted by company";
            }

            return application.Status.ToString();
        }

        private async Task LoadConfirmation()
        {
            string studentId = Session["userId"].ToString();
            string token = Session["idToken"].ToString();
            string url = FirebaseConfig.DatabaseUrl + "internshipConfirmations/"
                + Uri.EscapeDataString(studentId) + ".json?auth=" + Uri.EscapeDataString(token);

            string json = await FirebaseConfig.Client.GetStringAsync(url);
            var confirmation = JsonConvert.DeserializeObject<Models.InternshipConfirmation>(json);
            confirmedApplicationId = null;
            if (confirmation != null)
            {
                confirmedApplicationId = confirmation.ApplicationId;
            }
        }

        protected bool CanDeclineOffer(object item)
        {
            var application = (Models.Application)item;
            return application.Status == Models.ApplicationStatus.Approved
                && application.StudentResponse == null && application.Id != confirmedApplicationId;
        }

        protected bool CanAcceptOffer(object item)
        {
            return CanDeclineOffer(item) && string.IsNullOrEmpty(confirmedApplicationId);
        }
    }
    
}

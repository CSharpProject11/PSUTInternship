
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Mail;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.UI;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace internship_manegment
{
    public partial class SendAccounts : System.Web.UI.Page
    {
        protected async void SendEmailsButton_Click(object sender, EventArgs e)
        {
            string firebaseUrl = "https://student-management-syste-bc369-default-rtdb.asia-southeast1.firebasedatabase.app/Users.json";
            string senderEmail = "YOUR_EMAIL@gmail.com";
            string senderPassword = "YOUR_GMAIL_APP_PASSWORD";
            string websiteUrl = "YOUR_WEBSITE_URL";
            string password = "AmalObaidat12@";
            int sent = 0;
            int failed = 0;
            HashSet<string> emails = new HashSet<string>( StringComparer.OrdinalIgnoreCase);
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    string json = await client.GetStringAsync(firebaseUrl);

                    var users = JsonConvert.DeserializeObject< Dictionary<string, JObject> >(json);

                    if (users == null || users.Count == 0)
                    {
                        MessageLabel.Text = "No users found.";
                        return;
                    }

                
                    foreach (var user in users)
                    {
                        if (user.Value == null ||
                            user.Value["Email"] == null)
                        {
                            failed++;
                            continue;
                        }

                        string email = user.Value["Email"].ToString().Trim();

                        if (string.IsNullOrWhiteSpace(email) ||
                            !emails.Add(email))
                        {
                            continue;
                        }

                        try
                        {

                            string subject = "Your Internship Management System Account";
                            string body =
                                "<h2>Good morning!</h2>" +
                                "<p>Your account has been created successfully.</p>" +
                                "<p><b>Email:</b> " +
                                HttpUtility.HtmlEncode(email) + "</p>" +
                                "<p><b>Password:</b> " +
                                HttpUtility.HtmlEncode(password) + "</p>" +
                                "<p><b>Website:</b> <a href=\"" +
                                HttpUtility.HtmlAttributeEncode(websiteUrl) +
                                "\">Login to your account</a></p>" +
                                "<p>Please log in using these details.</p>" +
                                "<p>Please change your password after your first login.</p>" +
                                "<p>Best regards,<br/>" +
                                "Internship Management System Team</p>";

                            using (MailMessage message = new MailMessage())
                            {
                                message.From = new MailAddress(senderEmail);
                                message.To.Add(email);
                                message.Subject = subject;
                                message.Body = body;
                                message.IsBodyHtml = true;
                                message.BodyEncoding = Encoding.UTF8;
                                message.SubjectEncoding = Encoding.UTF8;
                                using (SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587))
                                {
                                    smtp.EnableSsl = true;
                                    smtp.UseDefaultCredentials = false;
                                    smtp.Credentials = new NetworkCredential(senderEmail, senderPassword  );
                                    await smtp.SendMailAsync(message);
                                }
                            }

                            sent++;
                        }
                        catch
                        {
                            failed++;
                        }
                    }

                    MessageLabel.Text =
                        "Emails sent: " + sent +
                        "<br />Failed: " + failed;
                }
                catch
                {
                    MessageLabel.Text =
                        "Could not read Firebase users. Check the URL and database permissions.";
                }
            }
        }
    }
}

using System;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;
namespace PSUTInternship.Shared {
    public static class ContactReplyMailer {
        public static string DraftUri(string recipient, string subject, string reply)
        {
            if (string.IsNullOrWhiteSpace(recipient) || recipient.IndexOfAny(new[] { '\r', '\n' }) >= 0)
                throw new FormatException("The sender email address is invalid.");
            var address = new MailAddress(recipient).Address;
            return "https://mail.google.com/mail/?view=cm&fs=1&to=" + Uri.EscapeDataString(address) +
                "&su=" + Uri.EscapeDataString("Re: " + (subject ?? "Contact message").Replace("\r", " ").Replace("\n", " ")) +
                "&body=" + Uri.EscapeDataString(reply ?? "");
        }

        internal static string ResolveSetting(string name, Func<string, EnvironmentVariableTarget, string> read)
        {
            // IIS Express can inherit Visual Studio's environment from before setup.
            // Read saved values for the worker's Windows identity when absent there.
            foreach (var scope in new[] { EnvironmentVariableTarget.Process, EnvironmentVariableTarget.User, EnvironmentVariableTarget.Machine })
            {
                string value = read(name, scope);
                if (!string.IsNullOrWhiteSpace(value)) return value;
            }
            return null;
        }
        private static string Setting(string name)
        {
            return ResolveSetting(name, Environment.GetEnvironmentVariable);
        }
        public static async Task Send(string recipient, string subject, string reply) {
            string host = Setting("UIMS_SMTP_HOST");
            string from = Setting("UIMS_SMTP_FROM");
            string username = Setting("UIMS_SMTP_USERNAME");
            string password = Setting("UIMS_SMTP_PASSWORD");
            int port; if (!int.TryParse(Setting("UIMS_SMTP_PORT"), out port)) port = 587;
            if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(from)) throw new InvalidOperationException("Email is not configured. Set UIMS_SMTP_HOST and UIMS_SMTP_FROM on the server, with the provider's port and credentials. Your reply has not been sent.");
            using (var message = new MailMessage(new MailAddress(from), new MailAddress(recipient)))
            using (var client = new SmtpClient(host, port)) {
                message.Subject = "Re: " + (subject ?? "UIMS contact message").Replace("\r", " ").Replace("\n", " ");
                message.Body = reply; message.IsBodyHtml = false;
                client.EnableSsl = true; client.UseDefaultCredentials = false; client.Timeout = 25000;
                if (!string.IsNullOrEmpty(username)) client.Credentials = new NetworkCredential(username, password);
                await client.SendMailAsync(message);
            }
        }
    }
}
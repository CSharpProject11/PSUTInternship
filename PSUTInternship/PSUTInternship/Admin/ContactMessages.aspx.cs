using PSUTInternship.Shared;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;

public partial class ContactMessages : PortalPage
{
    // ==========================================
    // Message Model
    // ==========================================

    public class ContactMessage
    {
        public string Id { get; set; }
        public string Sender { get; set; }
        public string Email { get; set; }
        public string Subject { get; set; }
        public string Message { get; set; }
        public string Status { get; set; }
        public string Reply { get; set; }
    }

    // ==========================================
    private List<ContactMessage> Messages = new List<ContactMessage>();
    private async Task LoadFirebase()
    {
        CoordinatorData.RequireCoordinator();
        foreach(var item in CoordinatorData.Items(await CoordinatorData.Read("contactMessages")))
        {
            var msg=item.Value;
            Messages.Add(new ContactMessage {Id=item.Key,Sender=CoordinatorData.Str(msg,"name"),Email=CoordinatorData.Str(msg,"email"),Subject=CoordinatorData.Str(msg,"subject"),Message=CoordinatorData.Str(msg,"message"),Reply=CoordinatorData.Str(msg,"reply"),Status=string.Equals(CoordinatorData.Str(msg,"status"),"resolved",StringComparison.OrdinalIgnoreCase)?"Resolved":"New"});
        }
    }
    protected string FirebaseError = "";
    // Page State
    // ==========================================

    protected string Filter = "All";
    protected string Notice = "";
    protected string ReplyError = "";
    protected string ReplyText = "";
    protected string SubmittedReply = "";

    protected ContactMessage SelectedMessage = null;

    // Also update the displayed status after a successful persisted reply.
    private string ResolvedThisRequestId = "";

    // ==========================================
    // Page Load
    // ==========================================

    protected async void Page_Load(object sender, EventArgs e)
    {
        Filter = Request.Form["status"] ??
                 Request.QueryString["status"] ??
                 "All";

        if (Filter != "All" &&
            Filter != "New" &&
            Filter != "Resolved")
        {
            Filter = "All";
        }

        CoordinatorData.RequireCoordinator();
        try { await LoadFirebase(); } catch(Exception ex) { FirebaseError = ex.Message; }
        string messageId = Request.QueryString["id"];
        if (!string.IsNullOrEmpty(messageId))
        {
            SelectedMessage =
                Messages.FirstOrDefault(m => m.Id == messageId);
            SubmittedReply = SelectedMessage == null ? "" : SelectedMessage.Reply;
        }

        // Handle Send Reply using C#
        string sendReplyValue = Request.Form["sendReply"];

        if (IsPostBack &&
            !string.IsNullOrEmpty(sendReplyValue))
        {
            string replyMessageId = sendReplyValue;
            if (!string.IsNullOrEmpty(replyMessageId))
            {
                await HandleSendReply(replyMessageId);
            }
        }
    }

    // ==========================================
    // Send Reply Logic
    // ==========================================

    private async Task HandleSendReply(string messageId)
    {
        ContactMessage message =
            Messages.FirstOrDefault(m => m.Id == messageId);

        if (message == null)
        {
            ReplyError = "Message not found.";
            return;
        }

        SelectedMessage = message;

        if (message.Status == "Resolved")
        {
            ReplyError = "This message is already resolved.";
            return;
        }

        ReplyText =
            (Request.Form["replyText"] ?? "").Trim();

        if (string.IsNullOrWhiteSpace(ReplyText))
        {
            ReplyError =
                "Please enter your reply before sending.";
            return;
        }

        if (ReplyText.Length > 2000)
        {
            ReplyError =
                "Your reply must not exceed 2000 characters.";
            return;
        }

        try
        {
            CoordinatorData.RequireCoordinator();
            // PATCH updates only reply fields, preserving other message data.
            await PortalRepository.Patch("contactMessages/" + PortalRepository.Key(message.Id), new {
                reply = ReplyText,
                repliedAt = DateTime.UtcNow.ToString("o"),
                repliedBy = PortalRepository.UserId,
                status = "resolved"
            });
            SubmittedReply = ReplyText;
            message.Reply = ReplyText;
            ResolvedThisRequestId = message.Id;
            message.Status = "Resolved";
            Notice = "Reply saved to Firebase and message marked Resolved. This is not an email delivery.";
        }
        catch(Exception ex) { ReplyError = ex.Message; return; }

        ReplyText = "";
    }

    // ==========================================
    // Temporary Status
    // ==========================================

    protected string EffectiveStatus(ContactMessage message)
    {
        if (message == null)
            return "New";

        if (message.Id == ResolvedThisRequestId)
            return "Resolved";

        return message.Status;
    }

    // ==========================================
    // Status Badge
    // ==========================================

    protected string StatusBadge(ContactMessage message)
    {
        string status = EffectiveStatus(message);

        if (status == "Resolved")
        {
            return "<span class='tag ok'>Resolved</span>";
        }

        return "<span class='tag warn'>New</span>";
    }

    // ==========================================
    // Filter
    // ==========================================

    protected string Selected(string value)
    {
        return Filter == value
            ? "selected=\"selected\""
            : "";
    }

    // ==========================================
    // Security - HTML Encoding
    // ==========================================

    protected string H(string value)
    {
        return HttpUtility.HtmlEncode(value ?? "");
    }

    // ==========================================
    // Sender Initials
    // ==========================================

    protected string Initials(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
            return "US";

        string[] parts = name.Split(
            new[] { ' ' },
            StringSplitOptions.RemoveEmptyEntries
        );

        if (parts.Length == 1)
        {
            return parts[0].Substring(0, 1).ToUpperInvariant();
        }

        return (
            parts[0].Substring(0, 1) +
            parts[parts.Length - 1].Substring(0, 1)
        ).ToUpperInvariant();
    }

    // ==========================================
    // Messages Table
    // ==========================================

    protected string Rows()
    {
        var filteredMessages = Messages
            .Where(m =>
                Filter == "All" ||
                EffectiveStatus(m) == Filter
            )
            .OrderBy(m =>
                EffectiveStatus(m) == "New" ? 0 : 1
            )
            .ThenBy(m => m.Id)
            .ToList();

        if (filteredMessages.Count == 0)
        {
            return
                "<tr>" +
                    "<td colspan='6' " +
                    "style='padding:30px;text-align:center;'>" +
                    H(string.IsNullOrEmpty(FirebaseError) ? "No messages found." : FirebaseError) +
                    "</td>" +
                "</tr>";
        }

        return string.Join(
            "",
            filteredMessages.Select(m =>
            {
                string messagePreview = m.Message ?? "";

                messagePreview = messagePreview
                    .Replace("\r", " ")
                    .Replace("\n", " ");

                if (messagePreview.Length > 75)
                {
                    messagePreview =
                        messagePreview.Substring(0, 75) + "...";
                }

                string viewUrl =
                    "ContactMessages.aspx?id=" + HttpUtility.UrlEncode(m.Id) +
                    "&status=" +
                    HttpUtility.UrlEncode(Filter);

                string actions =
                    "<div class='message-actions'>" +
                        "<a class='btn secondary' href='" +
                        H(viewUrl) +
                        "'>View &amp; Reply</a>" +
                    "</div>";

                return
                    "<tr>" +

                        "<td><strong>" +
                        H(m.Sender) +
                        "</strong></td>" +

                        "<td>" +
                        H(m.Email) +
                        "</td>" +

                        "<td>" +
                        H(m.Subject) +
                        "</td>" +

                        "<td>" +
                        H(messagePreview) +
                        "</td>" +

                        "<td>" +
                        StatusBadge(m) +
                        "</td>" +

                        "<td>" +
                        actions +
                        "</td>" +

                    "</tr>";
            })
        );
    }
}

<%@ Page Title="Contact Messages | UIMS" MasterPageFile="~/Portal.Master" Language="C#" Async="true" AutoEventWireup="true"
    CodeBehind="ContactMessages.aspx.cs"
    Inherits="ContactMessages" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="Coordinator.css" rel="stylesheet" />

    <style>
.portal-app .portal-content .contact-inbox{max-width:1240px;margin:auto}.portal-app .portal-content .contact-inbox .heading{padding-bottom:24px;margin:0 0 24px;border-bottom:1px solid #dfe7ee}.portal-app .portal-content .contact-inbox h1{font-size:28px!important;letter-spacing:-.03em;margin:0 0 8px!important}.contact-inbox .heading p{font-size:13px!important;font-weight:400!important;color:#607587;line-height:1.8;margin:0;max-width:70ch}.portal-app .portal-content .contact-inbox .card{padding:24px!important;border:1px solid #dce6ed!important;border-radius:14px!important;background:#fff!important;box-shadow:none!important}.portal-app .portal-content .contact-inbox h2{font-size:18px!important;margin:0 0 18px!important}.contact-inbox .message-filter{display:flex;align-items:flex-end;gap:12px;padding:16px;background:#f3f6f9;border-radius:8px;margin:0 0 22px}.contact-inbox .field{display:grid;gap:6px;min-width:220px}.portal-app .portal-content .contact-inbox .field label{font-size:11px!important;font-weight:600;margin:0;color:#607587}.portal-app .portal-content .contact-inbox select{font-size:13px!important;min-height:40px!important;background:#fff;border:1px solid #cbd9e3;border-radius:6px;padding:9px 12px}.portal-app .portal-content .contact-inbox .btn,.portal-app .portal-content .message-dialog .btn{font-size:12px!important;font-weight:600!important;min-height:38px!important;border-radius:6px!important;padding:9px 14px!important;line-height:1.5!important}.portal-app .portal-content .contact-inbox th{background:#f7f9fb!important;font-size:11px!important;font-weight:600!important;color:#607587;padding:12px 16px!important}.portal-app .portal-content .contact-inbox td{font-size:13px!important;font-weight:400!important;padding:18px 16px!important;line-height:1.7;border-color:#e5ecf1!important;vertical-align:middle!important}.contact-inbox .tablewrap{border:1px solid #e0e8ee;border-radius:8px}.contact-inbox .message-actions{display:flex;gap:8px}.contact-inbox tbody tr:hover{background:#f8fafc}.contact-inbox .tag{font-size:11px;font-weight:600;border-radius:5px}
.portal-app .portal-content .message-modal{position:fixed;inset:0;z-index:1100;display:flex;align-items:center;justify-content:center;padding:24px;background:rgba(9,29,46,.62)}.portal-app .portal-content .message-dialog{display:flex;flex-direction:column;width:min(760px,100%);max-height:90dvh;min-width:0;border-radius:16px;background:#fff;overflow:hidden;box-shadow:0 24px 80px #071f323d;color:#19394f}.message-dialog *{min-width:0;box-sizing:border-box;overflow-wrap:anywhere}.message-modal-header{display:flex;justify-content:space-between;align-items:center;gap:20px;padding:22px 28px;border-bottom:1px solid #e0e8ef}.portal-app .portal-content .message-modal-header h2{font-size:21px!important;letter-spacing:-.025em;margin:0 0 6px!important}.message-modal-header p{font-size:12px!important;font-weight:400!important;line-height:1.7;color:#607587;margin:0}.message-dialog-body{overflow-y:auto;min-height:0;padding:24px 28px;scrollbar-width:thin}.message-sender-card{display:flex;align-items:center;gap:14px;padding-bottom:22px;border-bottom:1px solid #e3ebf1;margin-bottom:22px}.message-sender-avatar{display:grid;place-items:center;width:44px;height:44px;border-radius:50%;background:#e5eff6;color:#345e7a;font-size:14px;font-weight:650;flex-shrink:0}.message-sender-info{flex:1}.message-sender-info strong{display:block;font-size:14px;font-weight:650}.message-sender-info span{display:block;font-size:12px;color:#607587;margin-top:4px}.message-section-title{font-size:14px;font-weight:700;margin:0 0 16px;color:#19394f}.message-detail{margin:0 0 18px}.message-detail label,.reply-field label{display:block;font-size:11px;font-weight:600;color:#607587;margin-bottom:7px}.portal-app .portal-content .message-detail p{font-size:14px!important;font-weight:400!important;line-height:1.8;margin:0;color:#345269}.message-body{white-space:pre-wrap;word-break:break-word}.message-divider{border-top:1px solid #e3ebf1;margin:24px 0}.portal-app .portal-content .reply-field textarea{display:block;width:100%;min-height:160px;resize:vertical;border:1px solid #bfceda;border-radius:8px;background:#fbfcfd;padding:14px;font-size:13px;line-height:1.8;color:#23485f}.portal-app .portal-content .reply-help{font-size:11px!important;color:#607587;font-weight:400!important;line-height:1.7;margin:10px 0 0}.message-dialog-footer{display:flex;justify-content:flex-end;gap:10px;padding:16px 28px;background:#f5f8fa;border-top:1px solid #e1e9ef;flex-shrink:0}.message-disabled-note,.reply-notice{font-size:12px;padding:14px 16px;border-radius:8px;background:#edf5f0;color:#326347}.reply-error{font-size:12px;padding:12px;background:#fff0ee;color:#9b4038;border-radius:6px;margin-bottom:14px}.message-dialog :focus-visible,.contact-inbox :focus-visible{outline:3px solid #0078b5;outline-offset:3px}
@media(max-width:600px){.portal-app .portal-content .message-modal{padding:12px}.portal-app .portal-content .message-dialog{max-height:94dvh}.message-modal-header,.message-dialog-body,.message-dialog-footer{padding:18px}.contact-inbox .message-filter{flex-wrap:wrap}.contact-inbox .field{min-width:0;flex:1}.portal-app .portal-content .contact-inbox .card{padding:18px!important}.message-sender-card{flex-wrap:wrap}}
</style>
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<input type="hidden" name="csrfToken" value="<%= H(CsrfToken) %>" />

    <div class="layout">

        <!-- Shared Sidebar -->


        <!-- Main Workspace -->
        <div class="workspace">

            <header class="topbar">
                <span>University Internship Management System</span>
                <span class="avatar">CO</span>
            </header>

            <main class="contact-inbox">
                <div class="heading">
                    <h1>Contact Messages</h1>
                    <p>
                        View incoming inquiries and respond to
                        students, company supervisors and academic supervisors.
                    </p>
                </div>

                <% if (!string.IsNullOrEmpty(Notice)) { %>
                    <div class="reply-notice" data-popup-message>
                        <%= H(Notice) %>
                    </div>
                <% } %>

                <section class="card">

                    <h2>Inbox</h2>

                    <!-- Status Filter -->
                    <div class="message-filter">

                        <div class="field">
                            <label for="statusFilter">
                                Message status
                            </label>

                            <select id="statusFilter" name="status">
                                <option value="All" <%= Selected("All") %>>
                                    All Messages
                                </option>

                                <option value="New" <%= Selected("New") %>>
                                    New
                                </option>

                                <option value="Resolved" <%= Selected("Resolved") %>>
                                    Resolved
                                </option>
                            </select>
                        </div>

                        <button type="submit" class="btn">
                            Filter
                        </button>

                    </div>

                    <!-- Messages Table -->
                    <div class="tablewrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Sender</th>
                                    <th>Email</th>
                                    <th>Subject</th>
                                    <th>Message</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>

                            <tbody>
                                <%= Rows() %>
                            </tbody>
                        </table>
                    </div>

                </section>
            </main>
        </div>
    </div>

    <!-- Message Details & Reply Modal -->
    <% if (SelectedMessage != null) { %>

        <div class="message-modal"
             role="dialog"
             aria-modal="true"
             aria-labelledby="messageModalTitle">

            <div class="message-dialog">

                <div class="message-modal-header">
                    <div>
                        <h2 id="messageModalTitle">
                            Message &amp; response
                        </h2>
                        <p>
                            Review the inquiry and send a response
                            to its sender.
                        </p>
                    </div>

                    <a class="message-close"
                       href="ContactMessages.aspx"
                       aria-label="Close message">
                        &times;
                    </a>
                </div>

                <div class="message-dialog-body">

                    <!-- Sender Information -->
                    <div class="message-sender-card">
                        <div class="message-sender-avatar">
                            <%= H(Initials(SelectedMessage.Sender)) %>
                        </div>

                        <div class="message-sender-info">
                            <strong>
                                <%= H(SelectedMessage.Sender) %>
                            </strong>

                            <span>
                                <%= H(SelectedMessage.Email) %>
                            </span>
                        </div>

                        <%= StatusBadge(SelectedMessage) %>
                    </div>

                    <div class="message-section-title">
                        Received Message
                    </div>

                    <div class="message-detail">
                        <label>Subject</label>
                        <p><%= H(SelectedMessage.Subject) %></p>
                    </div>

                    <div class="message-detail">
                        <label>Message</label>
                        <p class="message-body"><%= H(SelectedMessage.Message) %></p>
                    </div>

                    <div class="message-divider"></div>

                    <!-- Reply Section -->
                    <div class="message-section-title">
                        Coordinator Response
                    </div>

                    <% if (EffectiveStatus(SelectedMessage) == "New") { %>

                        <% if (!string.IsNullOrEmpty(ReplyError)) { %>
                            <div class="reply-error">
                                <%= H(ReplyError) %>
                            </div>
                        <% } %>

                        <div class="reply-field">
                            <label for="replyText">
                                Reply Message
                            </label>

                            <textarea id="replyText"
                                      name="replyText"
                                      maxlength="2000"
                                      placeholder="Write your response to the sender here..."
                                      required><%= H(ReplyText) %></textarea>

                            <p class="reply-help">
                                Once the reply is sent successfully,
                                the message status changes to Resolved.
                            </p>
                        </div>

                    <% } else { %>

                        <div class="message-disabled-note">
                            This message is resolved.
                        </div>

                        <% if (!string.IsNullOrEmpty(SubmittedReply)) { %>
                            <div class="message-detail"
                                 style="margin-top:16px;">
                                <label>Coordinator Reply</label>
                                <p class="message-body"><%= H(SubmittedReply) %></p>
                            </div>
                        <% } %>

                    <% } %>

                </div>

                <div class="message-dialog-footer">
                    <a class="btn secondary"
                       href="ContactMessages.aspx">
                        Close
                    </a>

                    <% if (EffectiveStatus(SelectedMessage) == "New") { %>

                        <button type="submit"
                                class="btn"
                                name="sendReply"
                                value="<%= SelectedMessage.Id %>">
                            Send Reply
                        </button>

                    <% } %>
                </div>

            </div>
        </div>

    <% } %>
</asp:Content>

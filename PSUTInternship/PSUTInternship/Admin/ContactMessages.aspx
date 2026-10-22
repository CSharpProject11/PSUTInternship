
<%@ Page Language="C#" Async="true" AutoEventWireup="true"
    CodeBehind="ContactMessages.aspx.cs"
    Inherits="ContactMessages" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <title>Contact Messages | UIMS</title>

    <link href="Coordinator.css" rel="stylesheet" />

    <style>
        .message-filter {
            display: flex;
            align-items: flex-end;
            gap: 12px;
            margin: 20px 0;
        }

        .message-filter .field {
            width: 230px;
        }

        .message-actions {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .message-actions .btn {
            white-space: nowrap;
            padding: 9px 14px;
            font-size: 12px;
            text-decoration: none;
        }

        .message-modal {
            position: fixed;
            inset: 0;
            z-index: 3000;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            background: rgba(12, 26, 48, .65);
            backdrop-filter: blur(3px);
        }

        .message-dialog {
            display: flex;
            flex-direction: column;
            background: #fff;
            width: 100%;
            max-width: 720px;
            max-height: 90vh;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 24px 70px rgba(12,26,48,.25);
        }

        .message-modal-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 20px;
            padding: 24px 28px;
            border-bottom: 1px solid #e7edf5;
        }

        .message-modal-header h2 {
            margin: 0 0 7px;
            font-size: 22px;
            color: #172b4d;
        }

        .message-modal-header p {
            margin: 0;
            color: #71829a;
            font-size: 13px;
            line-height: 1.6;
        }

        .message-close {
            display: grid;
            place-items: center;
            width: 37px;
            height: 37px;
            background: #f2f5fa;
            border-radius: 9px;
            color: #64748b;
            text-decoration: none;
            font-size: 26px;
            flex-shrink: 0;
        }

        .message-dialog-body {
            padding: 25px 28px;
            overflow-y: auto;
            min-height: 0;
        }

        .message-sender-card {
            display: flex;
            align-items: center;
            gap: 13px;
            padding: 17px;
            border: 1px solid #e2eaf4;
            border-radius: 12px;
            background: #f6f9fd;
            margin-bottom: 23px;
        }

        .message-sender-avatar {
            width: 48px;
            height: 48px;
            display: grid;
            place-items: center;
            border-radius: 11px;
            background: #e2edfb;
            color: #265b9b;
            font-weight: 700;
            font-size: 17px;
            flex-shrink: 0;
        }

        .message-sender-info {
            flex: 1;
            min-width: 0;
        }

        .message-sender-info strong {
            display: block;
            color: #172b4d;
            font-size: 15px;
            margin-bottom: 5px;
        }

        .message-sender-info span {
            color: #71829a;
            font-size: 12px;
            overflow-wrap: anywhere;
        }

        .message-section-title {
            font-size: 15px;
            color: #172b4d;
            margin: 22px 0 15px;
            font-weight: 700;
        }

        .message-detail {
            margin-bottom: 16px;
        }

        .message-detail label,
        .reply-field label {
            display: block;
            font-size: 12px;
            font-weight: 700;
            color: #566d89;
            margin-bottom: 8px;
        }

        .message-detail p {
            margin: 0;
            padding: 13px 15px;
            background: #f4f7fb;
            border: 1px solid #e7edf5;
            border-radius: 9px;
            color: #172b4d;
            line-height: 1.7;
            overflow-wrap: anywhere;
        }

        .message-detail .message-body {
            white-space: pre-wrap;
            min-height: 95px;
        }

        .message-divider {
            height: 1px;
            background: #e7edf5;
            margin: 23px 0;
        }

        .reply-field textarea {
            display: block;
            box-sizing: border-box;
            width: 100%;
            min-height: 145px;
            padding: 14px;
            border: 1px solid #cedae8;
            border-radius: 10px;
            color: #172b4d;
            font-family: inherit;
            font-size: 13px;
            line-height: 1.7;
            resize: vertical;
            outline: none;
        }

        .reply-field textarea:focus {
            border-color: #3477bd;
            box-shadow: 0 0 0 3px rgba(52,119,189,.1);
        }

        .reply-help {
            margin: 9px 0 0;
            color: #8392a7;
            font-size: 12px;
        }

        .message-dialog-footer {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 10px;
            border-top: 1px solid #e7edf5;
            padding: 18px 28px;
            background: #fff;
            flex-shrink: 0;
        }

        .reply-error {
            background: #fff1f2;
            color: #ac3145;
            border: 1px solid #f2cbd1;
            border-radius: 9px;
            padding: 12px 15px;
            font-size: 13px;
            margin-bottom: 15px;
        }

        .reply-notice {
            padding: 14px 17px;
            border: 1px solid #b9e2cb;
            background: #edf9f1;
            color: #207145;
            border-radius: 9px;
            margin: 0 0 20px;
            line-height: 1.6;
        }

        .message-disabled-note {
            margin: 0;
            background: #f3f8f5;
            color: #48735a;
            border: 1px solid #d9e9df;
            border-radius: 9px;
            padding: 15px;
            font-size: 13px;
        }

        @media (max-width: 600px) {
            .message-filter {
                flex-direction: column;
                align-items: stretch;
            }

            .message-filter .field {
                width: 100%;
            }

            .message-modal {
                padding: 10px;
            }

            .message-dialog {
                max-height: 95vh;
            }

            .message-modal-header,
            .message-dialog-body,
            .message-dialog-footer {
                padding: 18px;
            }

            .message-sender-card {
                flex-wrap: wrap;
            }
        }
    </style>
</head>

<body>
<form id="form1" runat="server">
<input type="hidden" name="csrfToken" value="<%= H(CsrfToken) %>" />

    <div class="layout">

        <!-- Shared Sidebar -->
        <aside class="sidebar">
            <div class="brand">
                UIMS
                <span>Coordinator</span>
            </div>

            <nav>
                <a class="nav-link"
                   href="Dashboard.aspx">Dashboard</a>

                <a class="nav-link"
                   href="ManageStudents.aspx">Manage Students</a>

                <a class="nav-link"
                   href="ManageCompanies.aspx">Manage Companies</a>

                <a class="nav-link"
                   href="ManageAcademic.aspx">Manage Academic Supervisors</a>

                <a class="nav-link"
                   href="AssignSuper.aspx">Assign Academic Supervisors</a>

                <a class="nav-link"
                   href="MonitorPlacements.aspx">Monitor Placements &amp; Progress</a>

                <a class="nav-link"
                   href="FinalCompletionReview.aspx">Final Completion Review</a>

                <a class="nav-link active"
                   href="ContactMessages.aspx">Contact Messages</a>

                <a class="nav-link"
                   href="CoordinatorAccount.aspx">Coordinator Account</a>
            </nav>

            <div class="sidefoot">
                University Internship System
            </div>
        </aside>

        <!-- Main Workspace -->
        <div class="workspace">

            <header class="topbar">
                <span>University Internship Management System</span>
                <span class="avatar">CO</span>
            </header>

            <main>
                <div class="heading">
                    <h1>Contact Messages</h1>
                    <p>
                        View incoming inquiries and respond to
                        students, company supervisors and academic supervisors.
                    </p>
                </div>

                <% if (!string.IsNullOrEmpty(Notice)) { %>
                    <div class="reply-notice">
                        <%= H(Notice) %>
                    </div>
                <% } %>

                <section class="card">

                    <h2>Contact Us Inbox</h2>

                    <!-- Status Filter -->
                    <div class="message-filter">

                        <div class="field">
                            <label for="statusFilter">
                                Filter by Status
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
                            Message Details &amp; Reply
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

</form>
</body>
</html>



<%@ Page Title="My Tasks | UIMS" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="MyTasks.aspx.cs" Inherits="PSUTInternship.Student.MyTasks" %>

<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">

<style>
    .mytasks-page {
        max-width: 1450px;
        margin: 0 auto;
        color: #122d48;
    }

    .mytasks-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        gap: 16px;
        margin-bottom: 22px;
    }

    .mytasks-header h1 {
        margin: 0 0 6px;
        font-size: 25px;
        font-weight: 750;
        color: #122d48;
    }

    .mytasks-header p {
        margin: 0;
        color: #647b96;
        font-size: 13px;
    }

    .mytasks-count {
        padding: 8px 14px;
        background: #e9f2ff;
        border-radius: 20px;
        color: #24518b;
        font-size: 12px;
        font-weight: 700;
        white-space: nowrap;
    }

    .mytasks-filters {
        display: grid;
        grid-template-columns: minmax(0, 2fr) minmax(0, 1fr) minmax(0, 1fr) auto;
        gap: 12px;
        align-items: end;
        margin-bottom: 22px;
    }

    .mytasks-field {
        display: flex;
        flex-direction: column;
        gap: 7px;
        min-width: 0;
    }

    .mytasks-field label {
        color: #344d69;
        font-size: 12px;
        font-weight: 650;
    }

    .mytasks-field input:not([type="file"]),
    .mytasks-field select,
    .mytasks-field textarea {
        width: 100%;
        box-sizing: border-box;
        min-width: 0;
        border: 1px solid #cddceb;
        border-radius: 9px;
        background: #fff;
        color: #173450;
        padding: 11px 12px;
        font-size: 13px;
        font-family: inherit;
    }

    .mytasks-field textarea {
        min-height: 110px;
        resize: vertical;
    }

    .mytasks-field input[type="file"] {
        max-width: 100%;
        font-size: 12px;
    }

    .mytasks-clear {
        height: 42px;
        padding: 0 18px;
        border: none;
        border-radius: 9px;
        background: #102d4d;
        color: white;
        font-size: 12px;
        font-weight: 700;
        cursor: pointer;
        white-space: nowrap;
    }

    .mytasks-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 15px;
        align-items: start;
    }

    .mytasks-card {
        min-width: 0;
        background: #ffffff;
        border: 1px solid #dce7f2;
        border-radius: 13px;
        padding: 18px;
        box-shadow: 0 3px 12px rgba(20, 48, 80, .035);
        transition: border-color .2s, box-shadow .2s;
    }

    .mytasks-card:hover {
        border-color: #b5cce8;
        box-shadow: 0 7px 22px rgba(20, 48, 80, .07);
    }

    .mytasks-card-top {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 10px;
    }

    .mytasks-card-main {
        min-width: 0;
        flex: 1;
    }

    .mytasks-title {
        margin: 0 0 7px;
        color: #102b4c;
        font-size: 14px;
        font-weight: 750;
        overflow-wrap: anywhere;
    }

    .mytasks-description {
        color: #617b9b;
        font-size: 12px;
        line-height: 1.6;
        margin: 0;
        overflow-wrap: anywhere;
    }

    .mytasks-status {
        display: inline-flex;
        align-items: center;
        border-radius: 30px;
        padding: 6px 10px;
        font-size: 11px;
        font-weight: 700;
        white-space: nowrap;
        background: #eef2f7;
        color: #526477;
    }

    .mytasks-status.status-reviewed {
        background: #dcfce7;
        color: #166534;
    }

    .mytasks-status.status-submitted {
        background: #dbeafe;
        color: #1d4ed8;
    }

    .mytasks-status.status-revision-requested {
        background: #fff0cf;
        color: #a75c00;
    }

    .mytasks-status.status-in-progress {
        background: #ebe5ff;
        color: #5933cb;
    }

    .mytasks-status.status-pending {
        background: #e9edf2;
        color: #475569;
    }

    .mytasks-meta {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 10px 22px;
        margin-top: 17px;
        color: #577294;
        font-size: 11px;
    }

    .mytasks-meta-item {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        min-width: 0;
        overflow-wrap: anywhere;
    }

    .mytasks-meta-item svg {
        flex-shrink: 0;
    }

    .mytasks-footer {
        display: flex;
        align-items: center;
        gap: 22px;
        flex-wrap: wrap;
        margin-top: 15px;
        padding-top: 13px;
        border-top: 1px solid #e6edf5;
    }

    .mytasks-details {
        min-width: 0;
    }

    .mytasks-details summary {
        list-style: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        color: #1d55bb;
        font-size: 12px;
        font-weight: 700;
    }

    .mytasks-details summary::-webkit-details-marker {
        display: none;
    }

    .mytasks-details summary::before {
        content: "◉";
        font-size: 13px;
    }

    .mytasks-details[open] {
        width: 100%;
    }

    .mytasks-detail-content {
        margin-top: 16px;
        padding-top: 15px;
        border-top: 1px solid #e6edf5;
    }

    .mytasks-info-block {
        background: #f2f6fb;
        border: 1px solid #e2eaf4;
        border-radius: 9px;
        padding: 12px;
        margin-bottom: 12px;
        font-size: 12px;
        color: #415b79;
        line-height: 1.65;
        overflow-wrap: anywhere;
    }

    .mytasks-info-block strong {
        display: block;
        color: #193653;
        margin-bottom: 4px;
    }

    .mytasks-form {
        display: grid;
        grid-template-columns: minmax(0, 1fr);
        gap: 14px;
        margin-top: 16px;
    }

    .mytasks-submit {
        background: #174db4;
        color: #fff;
        border: 0;
        border-radius: 8px;
        padding: 11px 17px;
        font-size: 12px;
        font-weight: 700;
        cursor: pointer;
    }

    .mytasks-submit:disabled {
        background: #e5eaf1;
        color: #8494a8;
        cursor: not-allowed;
    }

    .mytasks-download,
    .mytasks-download:visited {
        color: #1d55bb !important;
        background: transparent !important;
        border: none !important;
        padding: 0 !important;
        font-size: 12px;
        font-weight: 700;
        text-decoration: none;
    }

    .mytasks-download:hover {
        text-decoration: underline;
    }

    .mytasks-note {
        margin-top: 12px;
        color: #71839a;
        font-size: 11px;
        line-height: 1.65;
    }

    .mytasks-empty {
        grid-column: 1 / -1;
        text-align: center;
        background: #f1f6fc;
        padding: 35px;
        border-radius: 12px;
        color: #617b96;
        font-size: 13px;
    }

    .mytasks-error {
        color: #b91c1c;
        font-size: 12px;
    }

    @media (max-width: 1000px) {
        .mytasks-filters {
            grid-template-columns: 1fr 1fr;
        }
    }

    @media (max-width: 800px) {
        .mytasks-grid {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 550px) {
        .mytasks-filters {
            grid-template-columns: 1fr;
        }

        .mytasks-header {
            flex-wrap: wrap;
        }

        .mytasks-card {
            padding: 15px;
        }

    }
    /* Larger task cards */
.mytasks-page {
    max-width: 100%;
    width: 100%;
}

.mytasks-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 22px;
    align-items: start;
}

.mytasks-card {
    padding: 26px 28px;
    min-height: 225px;
    border-radius: 16px;
}

/* Bigger task information */
.mytasks-title {
    font-size: 18px;
    line-height: 1.4;
}

.mytasks-description {
    font-size: 14px;
    line-height: 1.7;
    margin-top: 8px;
}

.mytasks-status {
    font-size: 12px;
    padding: 8px 13px;
}

.mytasks-meta {
    font-size: 13px;
    margin-top: 22px;
    gap: 16px 24px;
}

.mytasks-footer {
    margin-top: 22px;
    padding-top: 17px;
    gap: 25px;
}

.mytasks-details summary,
.mytasks-download {
    font-size: 13px;
}

/* Responsive */
@media (max-width: 850px) {
    .mytasks-grid {
        grid-template-columns: 1fr;
    }

    .mytasks-card {
        min-height: auto;
        padding: 22px;
    }
}
</style>

<div class="mytasks-page">

    <header class="mytasks-header">
        <div>
            <h1>My Tasks</h1>
            <p>Manage your assigned tasks, submissions and supervisor feedback.</p>
        </div>

        <span class="mytasks-count">
            <asp:Literal ID="TaskCount" runat="server" />
        </span>
    </header>

    <asp:Label ID="lblMessage"
        runat="server"
        CssClass="message"
        role="status" />

    <section class="mytasks-filters">

        <div class="mytasks-field">
            <asp:Label runat="server"
                AssociatedControlID="Search"
                Text="Search Tasks" />

            <asp:TextBox ID="Search"
                runat="server"
                AutoPostBack="true"
                OnTextChanged="Filter_Changed"
                placeholder="Search title or description" />
        </div>

        <div class="mytasks-field">
            <asp:Label runat="server"
                AssociatedControlID="StatusFilter"
                Text="Status" />

            <asp:DropDownList ID="StatusFilter"
                runat="server"
                AutoPostBack="true"
                OnSelectedIndexChanged="Filter_Changed">

                <asp:ListItem Value="">All statuses</asp:ListItem>
                <asp:ListItem Value="Pending">Assigned</asp:ListItem>
                <asp:ListItem Value="In Progress">In Progress</asp:ListItem>
                <asp:ListItem Value="Submitted">Submitted</asp:ListItem>
                <asp:ListItem Value="Revision Requested">Resolve</asp:ListItem>
                <asp:ListItem Value="Reviewed">Complete</asp:ListItem>
            </asp:DropDownList>
        </div>

        <div class="mytasks-field">
            <asp:Label runat="server"
                AssociatedControlID="SortBy"
                Text="Sort By" />

            <asp:DropDownList ID="SortBy"
                runat="server"
                AutoPostBack="true"
                OnSelectedIndexChanged="Filter_Changed">

                <asp:ListItem Value="Nearest">Nearest Deadline</asp:ListItem>
                <asp:ListItem Value="Latest">Latest Deadline</asp:ListItem>
                <asp:ListItem Value="Title">Task Title (A-Z)</asp:ListItem>
            </asp:DropDownList>
        </div>

        <asp:Button ID="btnClearFilters"
            runat="server"
            Text="Clear Filters"
            CssClass="mytasks-clear"
            OnClick="btnClearFilters_Click" />

    </section>

    <div class="mytasks-grid">

        <asp:Repeater ID="rptTasks"
            runat="server"
            OnItemCommand="rptTasks_ItemCommand">

            <ItemTemplate>

                <article class="mytasks-card">

                    <div class="mytasks-card-top">

                        <div class="mytasks-card-main">
                            <h3 class="mytasks-title">
                                <%#: Eval("Title") %>
                            </h3>

                            <p class="mytasks-description">
                                <%#: Eval("Description") %>
                            </p>
                        </div>

                        <span class='<%# "mytasks-status status-" + Convert.ToString(Eval("Status")).ToLowerInvariant().Replace(" ", "-") %>'>
                            <%#: (string)Eval("Status") == "Reviewed"
                                ? "Complete"
                                : (string)Eval("Status") == "Revision Requested"
                                ? "Revision Requested"
                                : (string)Eval("Status") == "Pending"
                                ? "Assigned"
                                : Eval("Status") %>
                        </span>

                    </div>

                    <div class="mytasks-meta">

                        <span class="mytasks-meta-item">
                            <svg width="15" height="15" viewBox="0 0 24 24"
                                 fill="none" stroke="currentColor"
                                 stroke-width="1.8">
                                <rect x="3" y="5" width="18" height="16" rx="2"/>
                                <path d="M7 3v4M17 3v4M3 10h18"/>
                            </svg>

                            <%#: Eval("DueDate") %>
                        </span>

                        <span class="mytasks-meta-item">
                            <svg width="15" height="15" viewBox="0 0 24 24"
                                 fill="none" stroke="currentColor"
                                 stroke-width="1.8">
                                <circle cx="12" cy="8" r="4"/>
                                <path d="M4 21v-2a8 8 0 0 1 16 0v2"/>
                            </svg>

                            <%#: Eval("AssignedBy") %>
                        </span>

                    </div>

                    <div class="mytasks-footer">

                        <details class="mytasks-details">
                            <summary>View Details</summary>

                            <div class="mytasks-detail-content">

                                <div class="mytasks-info-block">
                                    <strong>Evaluation Criteria</strong>
                                    <%#: Eval("EvaluationCriteria") %>
                                </div>

                                <div class="mytasks-info-block">
                                    <strong>Supervisor Feedback</strong>
                                    <%#: string.IsNullOrWhiteSpace((string)Eval("Feedback"))
                                        ? "No feedback yet."
                                        : Eval("Feedback") %>
                                </div>

                                <div class="mytasks-form">

                                    <div class="mytasks-field">
                                        <asp:Label runat="server"
                                            AssociatedControlID="txtAnswer"
                                            Text="Your Answer" />

                                        <asp:TextBox ID="txtAnswer"
                                            runat="server"
                                            TextMode="MultiLine"
                                            Rows="4"
                                            MaxLength="10000"
                                            Text='<%# Eval("StudentAnswer") %>'
                                            Enabled='<%# Eval("CanSubmit") %>' />
                                    </div>

                                    <div class="mytasks-field">
                                        <asp:Label runat="server"
                                            AssociatedControlID="SolutionFile"
                                            Text="Upload Solution (up to 10 MB)" />

                                        <asp:FileUpload ID="SolutionFile"
                                            runat="server"
                                            Enabled='<%# Eval("CanSubmit") %>'
                                            accept=".pdf,.doc,.docx,.txt,.zip,.png,.jpg,.jpeg,.csv,.xlsx" />
                                    </div>

                                    <div class="mytasks-field">
                                        <asp:Label runat="server"
                                            AssociatedControlID="txtPdfUrl"
                                            Text="Or Provide an HTTPS Work Link" />

                                        <asp:TextBox ID="txtPdfUrl"
                                            runat="server"
                                            placeholder="https://"
                                            Enabled='<%# Eval("CanSubmit") %>' />

                                        <asp:Label ID="SubmissionError"
                                            runat="server"
                                            CssClass="mytasks-error"
                                            role="alert" />
                                    </div>

                                </div>

                                <div style="margin-top:16px;">
                                    <asp:Button ID="btnSubmit"
                                        runat="server"
                                        Text='<%# Eval("ButtonText") %>'
                                        CssClass="mytasks-submit"
                                        CommandName="SubmitTask"
                                        CommandArgument='<%# Eval("TaskId") %>'
                                        Enabled='<%# Eval("CanSubmit") %>' />
                                </div>

                                <p class="mytasks-note">
                                    Uploads and edits close at the end of the
                                    deadline in Jordan time. Leave the file
                                    and link blank to keep your existing file.
                                </p>

                            </div>
                        </details>

                        <asp:HyperLink ID="lnkPdf"
                            runat="server"
                            Text="↓ Download Solution"
                            NavigateUrl='<%# Eval("StudentPdfUrl") %>'
                            Visible='<%# Eval("HasPdfLink") %>'
                            CssClass="mytasks-download" />

                    </div>

                </article>

            </ItemTemplate>

        </asp:Repeater>

        <asp:PlaceHolder ID="EmptyTasksContainer"
            runat="server"
            Visible="false">

            <div class="mytasks-empty">
                <asp:Literal ID="EmptyTasks" runat="server" />
            </div>

        </asp:PlaceHolder>

    </div>

</div>

</asp:Content>

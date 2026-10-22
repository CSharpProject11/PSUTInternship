

<%@ Page Language="C#" AutoEventWireup="true"
    Async="true"
    CodeBehind="studenttaskes.aspx.cs"
    Inherits="Student.MyTasks" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>My Tasks | UIMS</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 35px 20px;
            background: #f3f6fb;
            font-family: 'Segoe UI', Arial, sans-serif;
            color: #1e293b;
        }

        .container {
            max-width: 1000px;
            margin: auto;
        }

        .page-title {
            font-size: 30px;
            color: #1e40af;
            margin-bottom: 8px;
        }

        .subtitle {
            color: #64748b;
            margin-bottom: 30px;
        }

        .task-card {
            background: #fff;
            padding: 28px;
            margin-bottom: 24px;
            border-radius: 15px;
            box-shadow: 0 5px 24px rgba(15,23,42,.06);
        }

        .task-title {
            font-size: 22px;
            color: #1d4ed8;
            margin-top: 0;
        }

        .task-description {
            line-height: 1.7;
            color: #475569;
        }

        .task-info {
            margin: 12px 0;
            color: #64748b;
            font-size: 14px;
        }

        .status {
            font-weight: 700;
            color: #ea580c;
        }

        .section-label {
            display: block;
            margin: 22px 0 8px;
            font-weight: 600;
            font-size: 14px;
        }

        .answer-box,
        .pdf-input {
            width: 100%;
            padding: 13px 15px;
            border: 1px solid #cbd5e1;
            border-radius: 9px;
            font-size: 15px;
            font-family: inherit;
        }

        .answer-box {
            min-height: 130px;
            resize: vertical;
        }

        .answer-box:disabled,
        .pdf-input:disabled {
            background: #f1f5f9;
            color: #64748b;
        }

        .pdf-link {
            display: inline-block;
            margin-top: 12px;
            color: #2563eb;
            text-decoration: none;
            font-weight: 600;
        }

        .pdf-link:hover {
            text-decoration: underline;
        }

        .submit-btn {
            display: inline-block;
            background: #2563eb;
            color: white;
            padding: 13px 25px;
            margin-top: 25px;
            border: none;
            border-radius: 9px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

        .submit-btn:hover {
            background: #1d4ed8;
        }

        .submit-btn:disabled {
            background: #94a3b8;
            cursor: not-allowed;
        }

        .message {
            display: block;
            margin: 15px 0;
            color: #1d4ed8;
            font-weight: 600;
        }

        .deadline-note {
            margin-top: 14px;
            color: #64748b;
            font-size: 13px;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">

        <div class="container">

            <h1 class="page-title">My Tasks</h1>

            <p class="subtitle">
                View, submit and update your internship tasks.
            </p>

            <asp:Label
                ID="lblMessage"
                runat="server"
                CssClass="message" />

            <asp:Repeater
                ID="rptTasks"
                runat="server"
                OnItemCommand="rptTasks_ItemCommand">

                <ItemTemplate>

                    <div class="task-card">

                        <h2 class="task-title">
                            <%#: Eval("Title") %>
                        </h2>

                        <p class="task-description">
                            <%#: Eval("Description") %>
                        </p>

                        <div class="task-info">
                            <strong>Assigned By:</strong>
                            <%#: Eval("AssignedBy") %>
                        </div>

                        <div class="task-info">
                            <strong>Due Date:</strong>
                            <%#: Eval("DueDate") %>
                        </div>

                        <div class="task-info">
                            <strong>Status:</strong>
                            <span class="status">
                                <%#: Eval("Status") %>
                            </span>
                        </div>

                        <label class="section-label">
                            Your Answer
                        </label>

                        <asp:TextBox
                            ID="txtAnswer"
                            runat="server"
                            TextMode="MultiLine"
                            Rows="5"
                            CssClass="answer-box"
                            placeholder="Write your answer here..."
                            Text='<%# Eval("StudentAnswer") %>'
                            Enabled='<%# Eval("CanSubmit") %>' />

                        <label class="section-label">
                            PDF Link (Optional)
                        </label>

                        <asp:TextBox
                            ID="txtPdfUrl"
                            runat="server"
                            CssClass="pdf-input"
                            placeholder="https://example.com/report.pdf"
                            Text='<%# Eval("StudentPdfUrl") %>'
                            Enabled='<%# Eval("CanSubmit") %>' />

                        <asp:HyperLink
                            ID="lnkPdf"
                            runat="server"
                            CssClass="pdf-link"
                            Text="View Submitted PDF"
                            NavigateUrl='<%# Eval("StudentPdfUrl") %>'
                            Visible='<%# Eval("HasPdfLink") %>'
                            Target="_blank" />

                        <br />

                        <asp:Button
                            ID="btnSubmit"
                            runat="server"
                            Text='<%# Eval("ButtonText") %>'
                            CssClass="submit-btn"
                            CommandName="SubmitTask"
                            CommandArgument='<%# Eval("TaskId") %>'
                            Enabled='<%# Eval("CanSubmit") %>' />

                        <p class="deadline-note">
                            Submissions and edits are allowed until
                            the end of the due date (Jordan time).
                        </p>

                    </div>

                </ItemTemplate>

            </asp:Repeater>

        </div>

    </form>
</body>
</html>

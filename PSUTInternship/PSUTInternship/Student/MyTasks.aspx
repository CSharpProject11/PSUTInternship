<%@ Page Title="My Tasks | UIMS" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="MyTasks.aspx.cs" Inherits="PSUTInternship.Student.MyTasks" %>

<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
    <h1>My tasks</h1>
    <p class="subtitle">Submit your work and review your supervisor's feedback.</p>
    <asp:Label ID="lblMessage" runat="server" CssClass="message" role="status" />
    <section class="student-task-kpis" aria-label="My task statistics">
        <div><span>Assigned tasks</span><strong><%= TaskTotal %></strong></div>
        <div><span>Submitted</span><strong><%= TaskSubmitted %></strong></div>
        <div><span>Needs revision</span><strong><%= TaskRevisions %></strong></div>
        <div><span>Completed</span><strong><%= TaskReviewed %></strong></div>
    </section>
    <section class="panel student-task-workspace">
        <div class="fields task-search-toolbar">
            <div class="field">
                <asp:Label runat="server" AssociatedControlID="Search" Text="Search tasks" /><asp:TextBox ID="Search" runat="server" AutoPostBack="true" OnTextChanged="Filter_Changed" placeholder="Search title or description" /></div>
            <div class="field">
                <asp:Label runat="server" AssociatedControlID="StatusFilter" Text="Status" /><asp:DropDownList ID="StatusFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                    <asp:ListItem Value="">All statuses</asp:ListItem>
                    <asp:ListItem Value="Pending">Assigned</asp:ListItem>
                    <asp:ListItem Value="Submitted">Submitted</asp:ListItem>
                    <asp:ListItem Value="Revision Requested">Resolve</asp:ListItem>
                    <asp:ListItem Value="Reviewed">Completed</asp:ListItem>
                </asp:DropDownList></div>
        </div>
        <div class="student-task-grid">
            <asp:Repeater ID="rptTasks" runat="server" OnItemCommand="rptTasks_ItemCommand">
                <ItemTemplate>
                    <article class="student-task-card">
                        <header class="student-task-card-header">
                            <h2><%#: Eval("Title") %></h2>
                            <span class="student-task-status" data-status='<%#: Eval("Status") %>'><%#: (string)Eval("Status") == "Reviewed" ? "Completed" : (string)Eval("Status") == "Revision Requested" ? "Needs revision" : Eval("Status") %></span></header>
                        <p class="student-task-description"><%#: Eval("Description") %></p>
                        <div class="student-task-deadline"><span>Deadline</span><strong><%#: Eval("DueDate") %> <span class="student-task-training-hours">· <%#: Eval("TrainingHours", "{0:0.##}") %> training hours on completion</span></strong></div>
                        <div class="student-task-card-feedback"><span>Supervisor feedback</span><p><%#: string.IsNullOrWhiteSpace((string)Eval("Feedback")) ? "No feedback yet." : Eval("Feedback") %></p>
                        </div>
                        <div class="student-task-card-actions">
                            <asp:HyperLink ID="lnkPdf" runat="server" Text="Download latest solution" NavigateUrl='<%# Eval("StudentPdfUrl") %>' Visible='<%# Eval("HasPdfLink") %>' CssClass="btn light" />
                            <button type="button" class="btn light task-editor-launch" onclick="this.nextElementSibling.showModal()">View task &amp; submission</button><dialog class="task-submission-modal" aria-label="Task submission">
                                <header class="task-submission-modal-header">
                                    <div>
                                        <h2>Task submission</h2>
                                        <p><%#: Eval("Title") %></p>
                                    </div>
                                    <button type="button" class="task-modal-close" aria-label="Close submission" onclick="this.closest('dialog').close()">×</button></header>
                                <div class="task-editor-body">
                                    
                                    <div class="task-modal-context">
                                        <h3>Task details</h3>
                                        <p><%#: Eval("Description") %></p>
                                        <h3>Evaluation criteria</h3>
                                        <p><%#: Eval("EvaluationCriteria") %></p>
                                        <h3>Supervisor feedback</h3>
                                        <p><%#: string.IsNullOrWhiteSpace((string)Eval("Feedback")) ? "No feedback yet." : Eval("Feedback") %></p>
                                    </div>
                                    <div class="field">
                                        <asp:Label runat="server" AssociatedControlID="txtAnswer" Text="Your answer" /><asp:TextBox ID="txtAnswer" runat="server" TextMode="MultiLine" Rows="4" MaxLength="10000" Text='<%# Eval("StudentAnswer") %>' Enabled='<%# Eval("CanSubmit") %>' /></div>
                                    <div class="field">
                                        <asp:Label runat="server" AssociatedControlID="SolutionFile" Text="Upload solution (up to 10 MB)" /><asp:FileUpload ID="SolutionFile" runat="server" Enabled='<%# Eval("CanSubmit") %>' accept=".pdf,.doc,.docx,.txt,.zip,.png,.jpg,.jpeg,.csv,.xlsx" /></div>
                                    <div class="field">
                                        <asp:Label runat="server" AssociatedControlID="txtPdfUrl" Text="Or provide an HTTPS work link" /><asp:TextBox ID="txtPdfUrl" runat="server" placeholder="https://" Enabled='<%# Eval("CanSubmit") %>' /><asp:Label ID="SubmissionError" runat="server" CssClass="field-error" role="alert" /></div>
                                    <asp:Button ID="btnSubmit" runat="server" Text='<%# Eval("ButtonText") %>' CssClass="btn" CommandName="SubmitTask" CommandArgument='<%# Eval("TaskId") %>' Enabled='<%# Eval("CanSubmit") %>' />
                                </div>
                                <footer class="task-submission-guidance">
                                    <p>Uploads and edits close at the end of the deadline in Jordan time.</p>
                                    <p>Leave the file and link blank to keep your existing file.</p>
                                </footer>
                            </dialog>
                        </div>
                    </article>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Literal ID="EmptyTasks" runat="server" />
        </div>
    </section>
</asp:Content>

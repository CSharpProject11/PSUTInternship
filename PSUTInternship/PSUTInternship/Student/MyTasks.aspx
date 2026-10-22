<%@ Page Title="My Tasks | UIMS" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="MyTasks.aspx.cs" Inherits="PSUTInternship.Student.MyTasks" %>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<h1>My tasks</h1><p class="subtitle">Submit your work and review your supervisor's feedback.</p>
<asp:Label ID="lblMessage" runat="server" CssClass="message" role="status" />
<section class="panel"><div class="fields"><div class="field"><asp:Label runat="server" AssociatedControlID="Search" Text="Search tasks" /><asp:TextBox ID="Search" runat="server" AutoPostBack="true" OnTextChanged="Filter_Changed" placeholder="Search title or description" /></div>
<div class="field"><asp:Label runat="server" AssociatedControlID="StatusFilter" Text="Status" /><asp:DropDownList ID="StatusFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"><asp:ListItem Value="">All statuses</asp:ListItem><asp:ListItem Value="Assigned">Assigned</asp:ListItem><asp:ListItem Value="Submitted">Submitted</asp:ListItem><asp:ListItem Value="Revision Requested">Resolve</asp:ListItem><asp:ListItem Value="Reviewed">Complete</asp:ListItem></asp:DropDownList></div></div>
<div class="table-wrap"><table><thead><tr><th>Task</th><th>Deadline</th><th>Status</th><th>Submission and feedback</th></tr></thead><tbody>
<asp:Repeater ID="rptTasks" runat="server" OnItemCommand="rptTasks_ItemCommand"><ItemTemplate>
<tr><td><strong><%#: Eval("Title") %></strong><p><%#: Eval("Description") %></p><p>Criteria: <%#: Eval("EvaluationCriteria") %></p><p>Assigned by: <%#: Eval("AssignedBy") %></p></td><td><%#: Eval("DueDate") %></td><td><%#: (string)Eval("Status") == "Reviewed" ? "Complete" : (string)Eval("Status") == "Revision Requested" ? "Resolve" : Eval("Status") %></td>
<td><p><strong>Supervisor feedback:</strong> <%#: string.IsNullOrWhiteSpace((string)Eval("Feedback")) ? "No feedback yet." : Eval("Feedback") %></p>
<asp:HyperLink ID="lnkPdf" runat="server" Text="Download latest solution" NavigateUrl='<%# Eval("StudentPdfUrl") %>' Visible='<%# Eval("HasPdfLink") %>' CssClass="btn light" />
<details><summary>Submission details</summary><div class="field"><asp:Label runat="server" AssociatedControlID="txtAnswer" Text="Your answer" /><asp:TextBox ID="txtAnswer" runat="server" TextMode="MultiLine" Rows="4" MaxLength="10000" Text='<%# Eval("StudentAnswer") %>' Enabled='<%# Eval("CanSubmit") %>' /></div>
<div class="field"><asp:Label runat="server" AssociatedControlID="SolutionFile" Text="Upload solution (up to 10 MB)" /><asp:FileUpload ID="SolutionFile" runat="server" Enabled='<%# Eval("CanSubmit") %>' accept=".pdf,.doc,.docx,.txt,.zip,.png,.jpg,.jpeg,.csv,.xlsx" /></div>
<div class="field"><asp:Label runat="server" AssociatedControlID="txtPdfUrl" Text="Or provide an HTTPS work link" /><asp:TextBox ID="txtPdfUrl" runat="server" placeholder="https://" Enabled='<%# Eval("CanSubmit") %>' /><asp:Label ID="SubmissionError" runat="server" CssClass="field-error" role="alert" /></div>
<asp:Button ID="btnSubmit" runat="server" Text='<%# Eval("ButtonText") %>' CssClass="btn" CommandName="SubmitTask" CommandArgument='<%# Eval("TaskId") %>' Enabled='<%# Eval("CanSubmit") %>' />
<p>Uploads and edits close at the end of the deadline in Jordan time. Leave the file and link blank to keep your existing file.</p></details></td></tr>
</ItemTemplate></asp:Repeater>
<asp:Literal ID="EmptyTasks" runat="server" /></tbody></table></div></section>
</asp:Content>
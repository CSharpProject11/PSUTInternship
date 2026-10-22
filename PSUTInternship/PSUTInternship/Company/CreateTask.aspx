<%@ Page Title="Create task" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="CreateTask.aspx.cs" Inherits="PSUTInternship.Company.CreateTask" %>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<a class="sd-back" href="Tasks.aspx">← Back to tasks</a><h1>Create task</h1><p class="subtitle">Set clear expectations for your confirmed trainees.</p>
<section class="panel portal-form-panel"><h2>Task details</h2><asp:Label ID="ErorrAssign" runat="server" CssClass="message" role="status" />
<div class="fields">
<div class="field wide"><label for="<%= Titelinput.ClientID %>">Task title</label><input id="Titelinput" type="text" runat="server" /><asp:Label ID="ErrorTitel" runat="server" CssClass="field-error" /></div>
<div class="field"><label>Assign trainees</label><details class="portal-trainee-picker"><summary>Select trainees</summary><asp:CheckBoxList ID="cblStudents" runat="server" /></details></div>
<div class="field"><asp:Label runat="server" AssociatedControlID="Deadlineinput" Text="Deadline" /><asp:TextBox ID="Deadlineinput" runat="server" TextMode="DateTimeLocal" /><asp:Label ID="ErorrDeadline" runat="server" CssClass="field-error" /></div>
<div class="field wide"><label for="<%= Descriptioniput.ClientID %>">Description</label><textarea id="Descriptioniput" rows="5" runat="server"></textarea><asp:Label ID="ErorrDescreption" runat="server" CssClass="field-error" /></div>
<div class="field wide"><label for="<%= EvaluationCriteriainput.ClientID %>">Evaluation criteria</label><textarea id="EvaluationCriteriainput" rows="3" runat="server"></textarea><asp:Label ID="ErorrEvaluation" runat="server" CssClass="field-error" /></div>
<div class="field"><label for="<%= Scoreinput.ClientID %>">Maximum score</label><input id="Scoreinput" type="text" inputmode="decimal" runat="server" /><asp:Label ID="Errorscor" runat="server" CssClass="field-error" /></div>
<div class="field"><asp:Label runat="server" AssociatedControlID="prorityinput" Text="Priority" /><asp:DropDownList ID="prorityinput" runat="server"><asp:ListItem>Low</asp:ListItem><asp:ListItem>Medium</asp:ListItem><asp:ListItem>High</asp:ListItem></asp:DropDownList></div>
</div><div class="portal-form-actions"><asp:Button ID="Cancel" runat="server" OnClick="Cancel_Click" Text="Cancel" CssClass="btn light" CausesValidation="false" /><asp:Button ID="CreateTaskButton" runat="server" OnClick="CreateTask_Click" Text="Create task" CssClass="btn" /></div></section>
</asp:Content>

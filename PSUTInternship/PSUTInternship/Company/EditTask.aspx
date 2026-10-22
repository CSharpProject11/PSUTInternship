<%@ Page Title="Review task" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="EditTask.aspx.cs" Inherits="PSUTInternship.Company.EditTask" %>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<a class="sd-back" href="Tasks.aspx">Back to tasks</a><h1>Review task</h1>
<asp:Label ID="subject" runat="server" CssClass="message" role="status" />
<section class="panel portal-form-panel"><div id="describtion" runat="server"><asp:Literal ID="TaskDetails" runat="server" /></div>
<div class="fields">
<div class="field"><asp:Label ID="State" runat="server" AssociatedControlID="stateDrop" Text="Status" /><asp:DropDownList ID="stateDrop" runat="server" AutoPostBack="true" OnSelectedIndexChanged="State_Changed"><asp:ListItem Value="">Select status</asp:ListItem><asp:ListItem Value="Revision Requested">Resolve</asp:ListItem><asp:ListItem Value="Reviewed">Complete</asp:ListItem></asp:DropDownList><asp:Label ID="StateError" runat="server" CssClass="field-error" /></div>
<asp:Panel ID="DeadlinePanel" runat="server" CssClass="field" Visible="false"><asp:Label runat="server" AssociatedControlID="NewDeadline" Text="New resubmission deadline" /><asp:TextBox ID="NewDeadline" runat="server" TextMode="Date" /><asp:Label ID="DeadlineError" runat="server" CssClass="field-error" /></asp:Panel>
<div class="field wide"><label for="<%= Feedbackinput.ClientID %>">Feedback</label><textarea ID="Feedbackinput" runat="server" rows="5"></textarea><asp:Label ID="FeedbackError" runat="server" CssClass="field-error" /></div></div>
<div class="portal-form-actions"><asp:Button ID="Cansale" runat="server" Text="Cancel" CssClass="btn light" OnClick="Cansale_Click" CausesValidation="false" formnovalidate="formnovalidate" /><asp:Button ID="Save" runat="server" Text="Save review" CssClass="btn" OnClick="Save_Click" /></div></section>
</asp:Content>
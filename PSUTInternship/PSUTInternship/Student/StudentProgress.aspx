<%@ Page Title="My Progress & Evaluation" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="StudentProgress.aspx.cs" Async="true" Inherits="PSUTInternship.Student.StudentProgress" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server"><link rel="stylesheet" href="../Content/task-progress.css?v=2" /></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<h1>My Progress &amp; Evaluation</h1><p>Track your assigned work, submissions and supervisor feedback.</p>
<asp:Label ID="lblReportStatus" runat="server" role="status" />
<section class="task-progress-overview panel">
 <div class="task-progress-ring" role="img" aria-label="Task progress: <%= TaskPercentage %>%"><svg viewBox="0 0 120 120" aria-hidden="true"><circle cx="60" cy="60" r="52"/><circle class="task-progress-arc" cx="60" cy="60" r="52" pathLength="100" stroke-dasharray="<%= TaskPercentage %> 100"/></svg><strong><asp:Label ID="lblPercentage" runat="server" Text="0%"/></strong><span>Task Progress</span></div>
 <div><h2>Every submission is a step forward.</h2><p>Each assigned task counts once after its first submission. Revisions retain that progress.</p><div class="task-progress-metrics">
 <div><span>Total assigned</span><strong><asp:Label ID="lblTotalTasks" runat="server" Text="0"/></strong></div>
 <div><span>Submitted at least once</span><strong><asp:Label ID="lblSubmittedTasks" runat="server" Text="0"/></strong></div>
 <div><span>Pending</span><strong><%= PendingCount %></strong></div><div><span>In progress</span><strong><%= InProgressCount %></strong></div><div><span>Revision requested</span><strong><asp:Label ID="lblRevisions" runat="server" Text="0"/></strong></div><div><span>Reviewed</span><strong><%= ReviewedCount %></strong></div>
 </div></div>
</section>
<section class="panel"><h2>Tasks and submission history</h2><asp:Label ID="lblNoTasks" runat="server" Text="No active tasks have been assigned yet. Your task progress is 0%."/>
<asp:Repeater ID="rptTasks" runat="server"><ItemTemplate><details class="task-progress-history"><summary><strong><%#: Eval("Title") %></strong><span><%#: Eval("Status") %></span></summary><p>First submitted: <%#: Eval("SubmissionDate") %></p><p>Latest submission: <%#: Eval("UpdatedDate") %></p><p><%#: Eval("Comments") %></p><p><%#: Eval("Score") %></p><p>Reviewed: <%#: Eval("ReviewDate") %></p><%# Eval("History") %><a href="MyTasks.aspx">Open My Tasks to view or resubmit work</a></details></ItemTemplate></asp:Repeater>
</section>
<section class="panel"><h2>Completion certificate</h2><p>Official completion remains subject to coordinator approval.</p><asp:HyperLink ID="lnkReport" runat="server" Text="Download Certificate" CssClass="btn" Visible="false"/></section>
<script>window.addEventListener('focus',function(){location.reload();});</script>
</asp:Content>

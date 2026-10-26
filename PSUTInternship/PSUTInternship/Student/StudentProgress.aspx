<%@ Page Title="Progress & report" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="StudentProgress.aspx.cs" Async="true" Inherits="PSUTInternship.Student.StudentProgress" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server"><link rel="stylesheet" href="../Content/task-progress.css?v=4" /></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="student-progress-page">
<div class="student-heading"><div><h1>Progress &amp; report</h1><p>Your tasks, submission history and completion certificate.</p></div><a class="btn" href="MyTasks.aspx">Open my tasks</a></div>
<asp:Label ID="lblReportStatus" runat="server" role="status" CssClass="error-banner" />
<section class="progress-kpis" aria-label="My task statistics">
<div><span>Assigned tasks</span><strong><asp:Label ID="lblTotalTasks" runat="server" Text="0"/></strong></div>
<div><span>Submitted</span><strong><asp:Label ID="lblSubmittedTasks" runat="server" Text="0"/></strong></div>
<div><span>Pending</span><strong><%= PendingCount %></strong></div>
<div><span>Needs revision</span><strong><asp:Label ID="lblRevisions" runat="server" Text="0"/></strong></div>
<div><span>Completed</span><strong><%= ReviewedCount %></strong></div>
</section>
<section class="progress-completion"><div><h2>Submission progress</h2><strong><asp:Label ID="lblPercentage" runat="server" Text="0%"/></strong></div><div class="progress-completion-track" role="progressbar" aria-label="Tasks submitted at least once" aria-valuemin="0" aria-valuemax="100" aria-valuenow="<%= TaskPercentage %>"><span style="width:<%= TaskPercentage %>%"></span></div><p>Each task counts once after its first submission. Revisions keep that progress.</p></section>
<section class="panel progress-history-panel"><div class="progress-section-heading"><h2>Tasks &amp; submission history</h2><span>Select a task to see its activity</span></div><asp:Label ID="lblNoTasks" runat="server" CssClass="progress-empty" Text="No active tasks have been assigned yet."/>
<asp:Repeater ID="rptTasks" runat="server"><ItemTemplate>
<details class="task-progress-history"><summary><span class="progress-task-title"><%#: Eval("Title") %></span><span class="progress-task-status" data-status='<%#: Eval("Status") %>'><%#: Convert.ToString(Eval("Status")) == "Reviewed" ? "Completed" : Eval("Status") %></span><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg></summary>
<div class="progress-task-detail"><dl class="progress-task-facts"><div><dt>First submitted</dt><dd><%#: Eval("SubmissionDate") %></dd></div><div><dt>Latest submission</dt><dd><%#: Eval("UpdatedDate") %></dd></div><div><dt>Latest review</dt><dd><%#: Eval("ReviewDate") %></dd></div><div><dt>Assessment</dt><dd><%#: Eval("Score") %></dd></div></dl>
<div class="progress-task-feedback"><h3>Supervisor feedback</h3><p><%#: string.IsNullOrWhiteSpace(Convert.ToString(Eval("Comments"))) ? "No feedback yet." : Eval("Comments") %></p></div>
<h3>Activity history</h3><%# Eval("History") %><a class="progress-task-link" href="MyTasks.aspx">View or update this work in My Tasks</a></div></details>
</ItemTemplate></asp:Repeater></section>
<section class="panel progress-certificate"><div><h2>Completion certificate</h2><p>Your certificate becomes available after coordinator approval.</p></div><asp:HyperLink ID="lnkReport" runat="server" Text="Download certificate" CssClass="btn" Visible="false"/></section>
</div>
</asp:Content>

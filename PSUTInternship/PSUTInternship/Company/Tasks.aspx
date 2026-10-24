<%@ Register Src="~/Shared/CompanyLinks.ascx" TagPrefix="psut" TagName="CompanyLinks" %>
<%@ Page MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="Tasks.aspx.cs" Inherits="PSUTInternship.Company.Tasks" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link rel="stylesheet" href="../Content/company-tasks.css?v=1" />
<style>body.portal-app .portal-content .portal-task-stats>div>p:nth-child(2),body.portal-app .portal-content .portal-task-stats>div>p:nth-child(2) span{color:#003e73!important;font-size:32px!important;font-weight:750!important;opacity:1!important}</style><style>body.portal-app .portal-content #taskReviewDialog{width:min(760px,calc(100vw - 28px))!important;height:min(690px,90dvh)!important;max-height:90dvh!important;padding:0!important;border:0!important;border-radius:14px!important;overflow:hidden!important;background:#fff!important}body.portal-app .portal-content #taskReviewDialog[open]{display:flex!important;flex-direction:column!important}#taskReviewDialog .review-dialog-heading{display:flex;justify-content:space-between;align-items:center;gap:20px;padding:22px 24px;border-bottom:1px solid #e3ebf0;flex-shrink:0}#taskReviewDialog .review-dialog-heading h2{font-size:20px!important;margin:0 0 6px!important}#taskReviewDialog .review-dialog-heading p{font-size:12px!important;font-weight:400!important;color:#607587;margin:0!important}body.portal-app .portal-content #taskReviewDialog .review-dialog-close{display:flex;align-items:center;justify-content:center;flex-shrink:0;width:34px!important;min-height:34px!important;height:34px!important;padding:0!important;border:1px solid #dce6ed!important;border-radius:7px!important;background:#fff!important;color:#526b7d!important;font-size:23px!important;line-height:1!important}body.portal-app .portal-content #taskReviewDialog iframe{display:block;width:100%!important;flex:1!important;min-height:0!important;height:100%!important;border:0!important;margin:0!important}#taskReviewDialog::backdrop{background:#0a1e3080}</style><style>
body.portal-app .portal-content #taskReviewDialog .review-dialog-close{display:grid!important;place-items:center!important;width:36px!important;height:36px!important;min-height:36px!important;padding:0!important;background:#f5f8fa!important;border:1px solid transparent!important;border-radius:8px!important;color:#607587!important;box-shadow:none!important;outline:none!important;transform:none!important}
body.portal-app .portal-content #taskReviewDialog .review-dialog-close svg{display:block;width:18px;height:18px;pointer-events:none}
body.portal-app .portal-content #taskReviewDialog .review-dialog-close:hover{background:#eaf0f5!important;color:#19394f!important}
body.portal-app .portal-content #taskReviewDialog .review-dialog-close:focus-visible{outline:2px solid #0078b5!important;outline-offset:3px!important}
</style></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="company-task-page"><h1>Tasks &amp; submissions</h1>
        <div>
        </div>
        <p>
            <asp:Label ID="descrebtion" runat="server" Text="Create assignments, review submissions and guide your trainees."></asp:Label>
        </p>
        <div class="stats portal-task-stats">
            <div id="Box1Total" runat="server">
                <p>Total Tasks</p>
                <p>
                    <asp:Label ID="countTotal" runat="server" Text="0"></asp:Label>
                </p>
                <p>Across your trainees</p>

            </div>

            <div id="Box2Pending" runat="server">
                <p>Pending Review</p>
                <p>
                    <asp:Label ID="countPending" runat="server" Text="0"></asp:Label>
                </p>
                <p>Awaiting your feedback</p>
            </div>

            <div id="Box3Progress" runat="server">
                <p>In Progress</p>
                <p>
                    <asp:Label ID="countProgress" runat="server" Text="0"></asp:Label>
                </p>
                <p>Currently being worked on</p>
            </div>

            <div id="Box4Reviewed" runat="server">
                <p>Reviewed</p>
                <p>
                    <asp:Label ID="countReviewed" runat="server" Text="0"></asp:Label>
                </p>
                <p>Reviewed or completed</p>
            </div>
        </div>

        <section class="panel">
            <div class="panel-heading">
                <h2>Tasks and submissions</h2>
                <asp:Button ID="Create" runat="server" Text="Create task" CssClass="btn" OnClick="Create_Click" />
            </div>
        <div class="task-filterbar"><label>Search tasks<asp:TextBox ID="search" runat="server" placeholder="Search task or student" AutoPostBack="true" OnTextChanged="search_TextChanged"></asp:TextBox>
</label><label>Status<asp:DropDownList AutoPostBack="true" ID="DropDownList1" runat="server" OnSelectedIndexChanged="DropDownList1_SelectedIndexChanged">
                <asp:ListItem>All statuses</asp:ListItem>
                <asp:ListItem Value="Submitted">Pending Review</asp:ListItem>
                <asp:ListItem Value="Pending">Pending</asp:ListItem><asp:ListItem Value="Assigned">In Progress</asp:ListItem>
                <asp:ListItem Value="Revision Requested">Resolve</asp:ListItem>
                <asp:ListItem Value="Reviewed">Complete</asp:ListItem>
            </asp:DropDownList></label></div>

        <div class="task-table-scroll"><table>
            <thead>
                <tr>
                    <th>Task</th>
                    <th>Student</th>
                    <th>Create Date</th><th>Due Date</th>
                    <th>Priority</th>
                    <th>Status</th>

                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="TaskTablebody" runat="server"></tbody>
        </table></div>
        </section>
</div><dialog id="taskReviewDialog" class="task-review-dialog"><header class="review-dialog-heading"><div><h2>Review task</h2><p>Give clear feedback and set the next step.</p></div><button type="button" class="review-dialog-close" onclick="this.closest('dialog').close()" aria-label="Close task review"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M6 18 18 6"/></svg></button></header><iframe title="Review task" id="taskReviewFrame"></iframe></dialog>
<script>
document.addEventListener('click',function(event){var link=event.target.closest('[data-task-review]');if(!link)return;event.preventDefault();var reviewUrl=new URL(link.href,location.href);reviewUrl.searchParams.set('embedded','1');document.getElementById('taskReviewFrame').src=reviewUrl.href;document.getElementById('taskReviewDialog').showModal();});
</script>
</asp:Content>

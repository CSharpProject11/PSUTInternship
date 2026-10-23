<%@ Page Title="Review application" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="Application.aspx.cs" Inherits="PSUTInternship.Company.Application" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="../Content/Company.css" rel="stylesheet" />
<style>
body.portal-app .portal-content .application-review-page{max-width:1180px;margin:auto;color:#19394f}body.portal-app .portal-content .application-review-page h1{font-size:28px!important;letter-spacing:-.03em!important;margin-bottom:8px!important}.application-review-page :is(.header p,.page-header p,.subtitle){font-size:13px!important;font-weight:400!important;line-height:1.8;color:#607587}
body.portal-app .portal-content .application-review-page .form-layout{display:grid;grid-template-columns:minmax(0,1fr) 310px;gap:22px;align-items:start;margin-top:26px}
body.portal-app .portal-content .application-review-page .panel{background:#fff!important;border:1px solid #dce6ed!important;border-radius:12px!important;box-shadow:none!important;padding:26px!important;margin:0!important;min-width:0}
body.portal-app .portal-content .application-review-page .detail-title{font-size:25px!important;letter-spacing:-.03em!important;margin:0 0 6px!important;color:#003e73}.application-review-page .app-profile-description{font-size:12px!important;font-weight:400!important;color:#607587;margin:0 0 26px!important}.app-academic-info{padding:22px 0;border-top:1px solid #e4ebf1}.application-review-page .app-academic-info h3,.application-review-page .app-message-section h3{font-size:15px!important;font-weight:650!important;margin:0 0 20px!important}.app-academic-info dl{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:22px;margin:0}.app-academic-info dl>div{min-width:0}.app-academic-info dt{font-size:11px;color:#607587;margin-bottom:7px;font-weight:500}.app-academic-info dd{font-size:13px;font-weight:500;line-height:1.8;color:#34566e;margin:0;overflow-wrap:anywhere}.application-review-page .app-cv-link{font-size:12px;color:#003e73;font-weight:600;text-decoration:underline;text-underline-offset:4px}.app-message-section{padding-top:22px;border-top:1px solid #e4ebf1}.application-review-page .app-message-section p{white-space:pre-wrap;overflow-wrap:anywhere;font-size:14px!important;font-weight:400!important;line-height:1.9!important;color:#425f75;background:#f6f9fb;padding:18px;border-radius:8px;margin:0!important}
body.portal-app .portal-content .application-review-page aside h2{font-size:17px!important;letter-spacing:-.02em;margin:0 0 16px!important}.application-review-page aside p{font-size:12px!important;line-height:1.8!important;font-weight:400!important;color:#607587}.application-review-page aside .badge{font-size:11px!important;font-weight:600!important;padding:4px 9px;border-radius:5px;background:#edf4f8;color:#345e79}
body.portal-app .portal-content .application-review-page aside .btn{display:flex;width:100%;align-items:center;justify-content:center;min-height:42px;font-size:12px!important;font-weight:600!important;padding:10px 14px!important;border-radius:6px!important;box-shadow:none!important;background:#003e73!important;color:#fff!important;border:1px solid #003e73!important;margin-top:20px}
body.portal-app .portal-content .application-review-page aside .btn.outline{background:#fff!important;border-color:#dfc5c0!important;color:#974b40!important;margin:0!important}.application-review-page aside>p:last-child{padding-top:18px;margin-top:22px;border-top:1px solid #e4ebf1}.application-review-page aside>p:last-child a{font-size:12px;color:#536e82;text-decoration:none}.application-review-page aside>p:last-child a:hover{color:#003e73;text-decoration:underline}.application-review-page :focus-visible{outline:3px solid #0078b5;outline-offset:3px}
@media(max-width:850px){body.portal-app .portal-content .application-review-page .form-layout{grid-template-columns:minmax(0,1fr)}}@media(max-width:550px){body.portal-app .portal-content .application-review-page .panel{padding:20px!important}.app-academic-info dl{grid-template-columns:1fr}.application-review-page .app-message-section p{padding:14px}}
</style></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="application-review-page"><%= PageHeader("applications", "Review application", "Review the student's information before deciding.") %>
<% if (StudentApplication == null) { %>
        <section class="panel"><h2>Application not found</h2><p class="muted">This application may have been removed or the link is missing its ID.</p><a href="Applications.aspx">Back to applications</a></section>
<% } else { %>
        <div class="form-layout">
            <section class="panel info-list">
                <h2 class="detail-title">
                    <%= H(StudentApplication.Student) %>
                </h2>
                <p class="app-profile-description">Applicant profile</p>
                <div class="app-academic-info"><h3>Academic &amp; professional information</h3><dl><div><dt>College</dt><dd><%= H(string.IsNullOrWhiteSpace(StudentApplication.College) ? "Not provided" : StudentApplication.College) %></dd></div><div><dt>Skills</dt><dd><%= H(string.IsNullOrWhiteSpace(StudentApplication.Skills) ? "Not provided" : StudentApplication.Skills) %></dd></div><div><dt>CV / portfolio</dt><dd><% if (!string.IsNullOrWhiteSpace(StudentApplication.Cv)) { %><a class="app-cv-link" target="_blank" rel="noopener" href="<%= H(StudentApplication.Cv) %>">Open CV / portfolio</a><% } else { %>Not provided<% } %></dd></div></dl></div>
                <div class="app-message-section"><h3>Application message</h3><p><%= H(string.IsNullOrWhiteSpace(StudentApplication.Message) ? "No message included with this application." : StudentApplication.Message) %></p></div>            </section>
            <aside class="panel">
                <h2>Application decision</h2>
                <p>
                    <span class="badge">
                        <%= H(StudentApplication.Status) %>
                    </span>
                </p>
                <% if(StudentApplication.Status=="Pending"){ %>
                <input type="hidden" name="csrfToken" value="<%= CsrfToken %>"/>
                    <button class="btn" name="action" value="accept" type="submit">Accept application</button>

                <p>
                    <a class="btn outline" href="RejectApplication.aspx?id=<%= H(StudentApplication.Id) %>">Reject with reason</a>
                </p>
                <% } else if(StudentApplication.Status=="Rejected"){ %>
                <p>
                    <b>Reason:</b> <%= H(StudentApplication.RejectionReason) %>
                </p>
                <% } else if (StudentApplication.Status == "Accepted" && !StudentApplication.StudentConfirmed) { %>
                <p>The student can confirm this offer in My Applications.</p>
                <% } else if (StudentApplication.StudentConfirmed) { %>
                <p class="badge ok">Placement confirmed; trainee is active.</p>
                <% } %>
                <p>
                    <a href="Applications.aspx">Back to applications</a>
                </p>
            </aside>
        </div>

        <% } %>
        </div><%= PageFooter() %>
</asp:Content>

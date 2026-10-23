<%@ Page Title="Account settings" MasterPageFile="~/Portal.Master" Language="C#" AutoEventWireup="true" CodeBehind="Account.aspx.cs" Inherits="PSUTInternship.Company.Account" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="../Content/Company.css" rel="stylesheet" />
<style>
body.portal-app .portal-content .company-account-page{max-width:1120px;margin:auto;color:#19394f}body.portal-app .portal-content .company-account-page h1{font-size:28px!important;letter-spacing:-.03em;margin-bottom:8px!important}.company-account-page :is(.header p,.page-header p,.subtitle){font-size:13px!important;font-weight:400!important;line-height:1.8;color:#607587}body.portal-app .portal-content .company-account-page .form-layout{display:grid;grid-template-columns:minmax(0,1.5fr) minmax(280px,1fr);gap:24px;align-items:start;margin-top:26px}.company-account-page .form-card{background:#fff;border:1px solid #dce6ed;border-radius:12px;padding:28px;box-shadow:none}.company-account-page .company-account-sidebar{display:grid;gap:18px}.company-account-page .company-account-identity,.company-account-page .company-account-security{background:#fff;border:1px solid #dce6ed;border-radius:12px;padding:24px}body.portal-app .portal-content .company-account-page h2{font-size:18px!important;letter-spacing:-.02em;margin:0 0 8px!important}.company-account-page .account-section-copy,.company-account-security p{font-size:12px!important;font-weight:400!important;line-height:1.8;color:#607587;margin:0 0 24px!important}.company-account-page .form-card>label{display:block;font-size:12px;font-weight:600;color:#48677d;margin:20px 0 8px}
body.portal-app .portal-content .company-account-page .form-card>input:not([type=hidden]){width:100%;min-height:44px;font-size:13px!important;font-weight:400!important;padding:11px 12px!important;border:1px solid #c5d6e2!important;border-radius:6px!important;background:#fff!important;color:#23485f}body.portal-app .portal-content .company-account-page .form-card>input[readonly]{background:#f4f7fa!important;color:#607587!important}.company-account-page .form-card>p:last-child{margin:26px 0 0;padding-top:20px;border-top:1px solid #e3ebf1;display:flex;justify-content:flex-end}body.portal-app .portal-content .company-account-page .btn{display:inline-flex;align-items:center;justify-content:center;min-height:40px;font-size:12px!important;font-weight:600!important;padding:10px 16px!important;border-radius:6px!important;background:#003e73!important;color:#fff!important;border:1px solid #003e73!important;box-shadow:none!important}body.portal-app .portal-content .company-account-page .btn.light{background:#fff!important;color:#345b76!important;border-color:#c5d6e2!important}.company-account-mark{display:grid;place-items:center;background:#eaf3f8;color:#345b76;width:48px;height:48px;border-radius:50%;margin-bottom:16px}.company-account-mark svg{width:24px;height:24px;fill:none;stroke:currentColor;stroke-width:1.5}.company-account-identity>p{font-size:12px!important;font-weight:400!important;color:#607587;margin:0 0 22px}.company-account-identity dl{margin:0;border-top:1px solid #e3ebf1;padding-top:18px}.company-account-identity dl>div+div{margin-top:18px}.company-account-identity dt{font-size:11px;color:#607587;margin-bottom:6px}.company-account-identity dd{font-size:13px;line-height:1.7;font-weight:500;color:#34566e;margin:0;overflow-wrap:anywhere}.account-help-link{font-size:12px;color:#607587;padding:0 4px;text-decoration:underline;text-underline-offset:4px}.company-account-page :focus-visible{outline:3px solid #0078b5;outline-offset:3px}.company-account-page .success{font-size:13px;line-height:1.8;padding:14px;background:#edf6f0;color:#326447;border-radius:8px;margin:20px 0}
@media(max-width:800px){body.portal-app .portal-content .company-account-page .form-layout{grid-template-columns:1fr}.company-account-sidebar{grid-row:1}.company-account-page .form-card,.company-account-page .company-account-identity,.company-account-page .company-account-security{padding:22px}}
</style></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="company-account-page"><%= PageHeader("", "Account settings", "Update the permitted contact details for your supervisor account.") %>
        <div class="form-layout">
            <section class="form-card">
                <h2>Contact details</h2><p class="account-section-copy">Keep your phone number and contact information up to date.</p>
                <% if(SavedMessage.Length>0){ %>
                <div class="success" data-popup-message>
                    <%= H(SavedMessage) %>
                </div>
                <% } %>
                <input type="hidden" name="csrfToken" value="<%= CsrfToken %>"/>
                    <label>Full name</label>
                    <input name="name" required value="<%= H(CompanyProfile.Name) %>"/>
                    <label>Sign-in email</label>
                    <input readonly value="<%= H(CompanyProfile.Email) %>"/>
                    <label>Phone number</label>
                    <input type="tel" autocomplete="tel" name="phone" value="<%= H(CompanyProfile.Phone) %>"/>
                    <label>Additional contact information</label>
                    <input name="contact" value="<%= H(CompanyProfile.ContactInfo) %>"/>
                    <p>
                        <button class="btn" type="submit">Save changes</button>
                    </p>

            </section>
            <aside class="company-account-sidebar"><section class="company-account-identity"><div class="company-account-mark" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg></div><h2><%= H(CompanyProfile.Name) %></h2><p>Company supervisor</p><dl><div><dt>Company</dt><dd><%= H(CompanyProfile.CompanyName) %></dd></div><div><dt>Email address</dt><dd><%= H(CompanyProfile.Email) %></dd></div></dl></section><section class="company-account-security"><h2>Password &amp; security</h2><p>Use the password settings page to update your sign-in password.</p><a class="btn light" href="../ChangePassword.aspx">Change password</a></section><a class="account-help-link" href="../Default.aspx">Contact the internship coordinator</a></aside>
        </div>
        </div><%= PageFooter() %>
</asp:Content>

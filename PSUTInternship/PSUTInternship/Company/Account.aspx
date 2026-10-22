<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Account.aspx.cs" Inherits="PSUTInternship.Company.Account" %>
<!DOCTYPE html>
<html>
    <head runat="server">
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Account settings</title>
        <link href="../Content/Company.css" rel="stylesheet" />
    </head>
    <body>
        <%= PageHeader("", "Account settings", "Update the permitted contact details for your supervisor account.") %>
        <div class="form-layout">
            <section class="form-card">
                <h2>Details</h2>
                <% if(SavedMessage.Length>0){ %>
                <div class="success">
                    <%= H(SavedMessage) %>
                </div>
                <% } %>
                <form method="post"><input type="hidden" name="csrfToken" value="<%= CsrfToken %>"/>
                    <label>Full name / coordinator controlled</label>
                    <input name="name" required value="<%= H(CompanyProfile.Name) %>"/>
                    <label>Email address / read only</label>
                    <input readonly value="<%= H(CompanyProfile.Email) %>"/>
                    <label>Phone number</label>
                    <input name="phone" value="<%= H(CompanyProfile.Phone) %>"/>
                    <label>Permitted contact information</label>
                    <input name="contact" value="<%= H(CompanyProfile.ContactInfo) %>"/>
                    <p>
                        <button class="btn" type="submit">Save changes</button>
                    </p>
                </form>
            </section>
            <aside class="side-note">
                <h2>Before you save</h2>
                <p class="muted">Check the required information. Changes follow your role permissions. A history is kept when applicable.</p>
                <a href="../Default.aspx">Need help? Contact the coordinator.</a>
            </aside>
        </div>
        <%= PageFooter() %>
    </body>
</html>


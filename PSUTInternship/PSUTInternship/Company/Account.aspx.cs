using PSUTInternship.Shared;
using System;
using PSUTInternship.Models;
namespace PSUTInternship.Company
{
    public partial class Account : CompanyPageBase
    {
        protected string SavedMessage = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadCompanyData();
            if (Request.HttpMethod != "POST") return;
            CompanyAccount update = new CompanyAccount
            {
                Name = PostedValue("name").Trim(),
                Phone = PostedValue("phone").Trim(),
                ContactInfo = PostedValue("contact").Trim()
            };
            if (string.IsNullOrWhiteSpace(update.Name)) { FirebaseError = "Display name is required."; return; }
            if (TryFirebase(() => UpdateCompanyProfile(update)))
            {
                CompanyProfile.Name = update.Name;
                CompanyProfile.Phone = update.Phone;
                CompanyProfile.ContactInfo = update.ContactInfo;
                SavedMessage = "Changes saved.";
            }
        }
    }
}



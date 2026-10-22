# Firebase setup for the Company Supervisor pages

The Company Supervisor pages use Firebase Authentication (Email/Password) and Firebase Realtime Database REST endpoints. The app settings in `Web.config` contain the Realtime Database URL, the Firebase web API key, and the current company ID (`ofuqTechnology`). A Firebase web API key is an application identifier; never add service-account JSON or database admin credentials to the project.

## Connect your project

1. In Firebase Console, open **Authentication → Sign-in method** and enable **Email/Password**.
2. In **Authentication → Users**, create the company supervisor's email/password account. Keep the password private.
3. Open **Authentication → Users**, copy that account's **UID**.
4. Open **Realtime Database → Rules**. Edit `database.rules.example.json`: replace `REPLACE_WITH_COMPANY_USER_UID` with the copied UID. Publish these rules. They require the logged-in account and the company filter for collection reads; opportunity and application writes are limited to `ofuqTechnology`.
5. Run the ASP.NET project and open `Company/Login.aspx`. Sign in with the account from step 2.
6. If you want the mockup data, import `company-supervisor-seed.json` into the Realtime Database using the Firebase console's JSON import. Importing replaces the selected database location, so import only into a new or intentionally empty database.

## Data paths used by the pages

- `companyAccounts/ofuqTechnology`: supervisor profile
- `opportunities`: list, create, edit, and close opportunities
- `applications`: review, accept, or reject applications
- `trainees`: active trainee list and recorded progress
- `taskSubmissions`: dashboard count of work awaiting review

The current project loads the company ID from `FirebaseCompanyId` in `Web.config`. If you use a different company ID, update the setting, sample data, and the matching paths and rule values together. This starter rules file intentionally binds access to one Firebase Auth UID and one company ID; use separate UID and company-specific rules when adding more companies.


After an application is accepted, the supervisor can open its details and use **Student confirmed — activate trainee** only after the student has confirmed the offer. This saves studentConfirmed on the application and creates or activates the record in `trainees`. The rules file includes the matching company-only trainee write rule; publish the updated rules in Firebase Console.



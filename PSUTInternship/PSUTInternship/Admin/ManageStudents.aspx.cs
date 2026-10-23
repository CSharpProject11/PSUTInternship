using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PSUTInternship.Admin
{
    public partial class ManageStudents : PSUTInternship.Shared.PortalPage
    {
        private string databaseUrl = PSUTInternship.Shared.FirebaseConfig.DatabaseUrl.TrimEnd('/');
        private JavaScriptSerializer serializer = new JavaScriptSerializer();
        private static Random random = new Random();
        private static object randomLock = new object();

        private string idToken
        {
            get { return Convert.ToString(Session["idToken"]); }
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (Convert.ToString(Session["userRole"]) != "coordinator" || idToken == "")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (IsPostBack) return;
            try { await PopulateAcademicSupervisors(); }
            catch (Exception error) { messageLabel.Text = HttpUtility.HtmlEncode(error.Message); return; }

            if (Session["studentMessage"] != null)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(Convert.ToString(Session["studentMessage"]));
                Session.Remove("studentMessage");
            }

            string studentId = Request.QueryString["toggle"];
            if (studentId != null)
            {
                try
                {
                    await ToggleStudent(studentId);
                    Session["studentMessage"] = "Student status updated.";
                }
                catch (Exception error)
                {
                    Session["studentMessage"] = error.Message;
                }

                Response.Redirect("ManageStudents.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            studentId = Request.QueryString["edit"];
            if (studentId != null)
            {
                await LoadStudentForEdit(studentId);
                return;
            }

            studentId = Request.QueryString["view"];
            if (studentId != null)
            {
                await LoadStudentForView(studentId);
                return;
            }

            ShowList();
            await LoadStudents();
        }

        private async Task PopulateAcademicSupervisors()
        {
            academicSupervisorList.Items.Clear();
            academicSupervisorList.Items.Add(new ListItem("Select academic supervisor", ""));
            var supervisors = await GetRecords("academicSupervisors");
            foreach (var item in supervisors.Where(x => GetValue(x.Value, "isActive").Equals("true", StringComparison.OrdinalIgnoreCase))
                .Where(x => SupervisorMatches(majorTextBox.SelectedValue, x.Value)))
                academicSupervisorList.Items.Add(new ListItem(GetValue(item.Value, "fullName"), item.Key));
        }
        private bool SupervisorMatches(string major, Dictionary<string, object> supervisor) {
            return PSUTInternship.Shared.AcademicCatalog.MatchesSupervisor(major, GetValue(supervisor,"department"), GetValue(supervisor,"specialization"));
        }
        protected async void MajorChanged(object sender, EventArgs e) { await PopulateAcademicSupervisors(); ShowForm(); }
        private void ShowList()
        {
            listSection.Visible = true;
            formSection.Visible = false;
            viewSection.Visible = false;
        }

        private void ShowForm()
        {
            listSection.Visible = false;
            formSection.Visible = true;
            viewSection.Visible = false;
        }

        private void ShowView()
        {
            listSection.Visible = false;
            formSection.Visible = false;
            viewSection.Visible = true;
        }

        private Task<Dictionary<string, Dictionary<string, object>>> GetUsers()
        {
            return GetRecords("users");
        }

        private Task<Dictionary<string, Dictionary<string, object>>> GetStudentRecords()
        {
            return GetRecords("students");
        }

        private async Task<Dictionary<string, Dictionary<string, object>>> GetRecords(string objectName)
        {
            string url = databaseUrl + "/" + objectName + ".json?auth=" + Uri.EscapeDataString(idToken);

            using (HttpClient client = PSUTInternship.Shared.FirebaseConfig.CreateClient())
            {
                HttpResponseMessage response = await client.GetAsync(url);
                string result = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                    throw new Exception("Could not read students from Firebase. Check Database rules.");

                if (result == "null" || result == "")
                    return new Dictionary<string, Dictionary<string, object>>();

                Dictionary<string, Dictionary<string, object>> users =
                    serializer.Deserialize<Dictionary<string, Dictionary<string, object>>>(result);

                if (users == null)
                    return new Dictionary<string, Dictionary<string, object>>();

                return users;
            }
        }

        private string GetValue(Dictionary<string, object> student, string fieldName)
        {
            if (student.ContainsKey(fieldName) && student[fieldName] != null)
                return Convert.ToString(student[fieldName]);

            return "";
        }

        private bool IsStudent(Dictionary<string, object> user)
        {
            return String.Equals(GetValue(user, "role"), "student", StringComparison.OrdinalIgnoreCase);
        }

        // Draw the student rows and update the three totals.
        private async Task LoadStudents()
        {
            try
            {
                Dictionary<string, Dictionary<string, object>> users = await GetUsers();
                StringBuilder table = new StringBuilder();
                int total = 0;
                int active = 0;
                int inactive = 0;
                string search = searchTextBox.Text.Trim();

                table.Append("<table><thead><tr>");
                table.Append("<th>University ID</th><th>Student name</th>");
                table.Append("<th>College</th><th>Actions</th>");
                table.Append("</tr></thead><tbody>");

                foreach (KeyValuePair<string, Dictionary<string, object>> item in users)
                {
                    Dictionary<string, object> student = item.Value;
                    if (!IsStudent(student)) continue;

                    total++;
                    bool isActive = GetValue(student, "isActive").ToLower() == "true";
                    if (isActive) active++;
                    else inactive++;

                    string number = GetValue(student, "studentNumber");
                    string name = GetValue(student, "fullName");
                    string email = GetValue(student, "email");

                    bool found = search == "" ||
                        name.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0 ||
                        email.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0 ||
                        number.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0;

                    if (!found) continue;

                    string safeId = HttpUtility.UrlEncode(item.Key);
                    int hours = 0;
                    Int32.TryParse(GetValue(student, "requiredHours"), out hours);

                    table.Append("<tr><td>").Append(HttpUtility.HtmlEncode(number));
                    table.Append("</td><td>").Append(HttpUtility.HtmlEncode(name));
                    table.Append("</td><td>").Append(HttpUtility.HtmlEncode(GetValue(student, "college")));
                    table.Append("</td><td>");
                    table.Append("<a class='btn light' href='ManageStudents.aspx?view=").Append(safeId).Append("'>View</a> ");
                    table.Append("<a class='btn light' href='ManageStudents.aspx?edit=").Append(safeId).Append("'>Edit</a> ");
                    table.Append("<a class='btn danger' href='ManageStudents.aspx?toggle=").Append(safeId);
                    table.Append("' onclick=\"return portalConfirmAction(this, 'Change this account status?');\">");
                    table.Append(isActive ? "Deactivate" : "Activate").Append("</a></td></tr>");
                }

                if (total == 0)
                    table.Append("<tr><td colspan='4'>No students yet.</td></tr>");
                else if (table.ToString().EndsWith("<tbody>"))
                    table.Append("<tr><td colspan='4'>No students match your search.</td></tr>");

                table.Append("</tbody></table>");
                studentsTable.Text = table.ToString();
                studentCountLabel.Text = total.ToString();
                activeCountLabel.Text = active.ToString();
                inactiveCountLabel.Text = inactive.ToString();
            }
            catch (Exception error)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(error.Message);
            }
        }

        protected void addStudentButton_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowForm();
        }

        protected void backButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("ManageStudents.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected async void saveButton_Click(object sender, EventArgs e)
        {
            string name = fullNameTextBox.Text.Trim();
            string email = emailTextBox.Text.Trim();
            string year = enrollmentYearTextBox.Text.Trim();
            string college = collegeTextBox.Text.Trim();
            string major = majorTextBox.Text.Trim();
            if (college != PSUTInternship.Shared.AcademicCatalog.College || !PSUTInternship.Shared.AcademicCatalog.ValidProgram(major)) { messageLabel.Text = "Select a college and program from the PSUT computing catalogue."; ShowForm(); return; }
            string editId = Request.QueryString["edit"];
            bool isEditing = editId != null && editId != "";
            int yearNumber;
            int hours;

            if (name == "" || email == "" || college == "" || major == "")
            {
                messageLabel.Text = "Fill in the name, email, college, and major.";
                ShowForm();
                return;
            }

            if (year.Length != 4 || !Int32.TryParse(year, out yearNumber))
            {
                messageLabel.Text = "Enter the enrollment year using four digits, for example 2026.";
                ShowForm();
                return;
            }

            if (!Int32.TryParse(requiredHoursTextBox.Text, out hours) || hours <= 0)
            {
                messageLabel.Text = "Enter valid required training hours.";
                ShowForm();
                return;
            }

            if (startDateTextBox.Text != "" && endDateTextBox.Text != "")
            {
                DateTime startDate;
                DateTime endDate;
                if (!DateTime.TryParse(startDateTextBox.Text, out startDate) ||
                    !DateTime.TryParse(endDateTextBox.Text, out endDate) || endDate < startDate)
                {
                    messageLabel.Text = "Check the training start and end dates.";
                    ShowForm();
                    return;
                }
            }

            try
            {
                Dictionary<string, Dictionary<string, object>> users = await GetUsers();
                Dictionary<string, Dictionary<string, object>> students = await GetStudentRecords();

                foreach (KeyValuePair<string, Dictionary<string, object>> item in users)
                {
                    if (!IsStudent(item.Value) || item.Key == editId) continue;
                    if (GetValue(item.Value, "email").ToLower() == email.ToLower())
                    {
                        messageLabel.Text = "That email is already in use.";
                        ShowForm();
                        return;
                    }
                }

                var supervisorRecords = await GetRecords("academicSupervisors");
                if (!supervisorRecords.ContainsKey(academicSupervisorList.SelectedValue))
                    throw new Exception("Select an active academic supervisor before creating this account.");
                if (!PSUTInternship.Shared.AcademicCatalog.SameDepartment(major, GetValue(supervisorRecords[academicSupervisorList.SelectedValue], "department"))) throw new Exception("Choose an academic supervisor from the student's department.");
                Dictionary<string, object> oldStudent = null;
                string uid = editId;

                if (isEditing)
                {
                    if (!users.ContainsKey(uid) || !IsStudent(users[uid]))
                    {
                        messageLabel.Text = "Student record was not found.";
                        ShowForm();
                        return;
                    }

                    oldStudent = users[uid];
                    if (GetValue(oldStudent, "email").ToLower() != email.ToLower())
                    {
                        messageLabel.Text = "The email also has to be changed in Firebase Authentication.";
                        ShowForm();
                        return;
                    }
                }
                else
                {
                    if (passwordTextBox.Text == "")
                    {
                        messageLabel.Text = "Enter a temporary password for the student.";
                        ShowForm();
                        return;
                    }

                    uid = await CreateAuthAccount(email, passwordTextBox.Text);
                    if (uid == null)
                    {
                        ShowForm();
                        return;
                    }
                }

                var supervisors = await GetRecords("academicSupervisors");
                if (!supervisors.ContainsKey(academicSupervisorList.SelectedValue))
                    throw new Exception("Select an active academic supervisor. Create one first if the list is empty.");
                if (!SupervisorMatches(major, supervisors[academicSupervisorList.SelectedValue])) throw new Exception("Select a supervisor matching the student department and specialization.");
                string studentNumber = GetStudentNumber(year, users, students, uid, oldStudent);
                Dictionary<string, object> student;

                if (oldStudent == null) student = new Dictionary<string, object>();
                else student = new Dictionary<string, object>(oldStudent);

                Dictionary<string, object> savedProfile;
                if (students.TryGetValue(uid, out savedProfile))
                    foreach (var field in savedProfile) if (!student.ContainsKey(field.Key)) student[field.Key] = field.Value;
                student["university"] = "Princess Sumaya University for Technology";
                student["academicSupervisorId"] = academicSupervisorList.SelectedValue;
                student["academicSupervisorName"] = GetValue(supervisors[academicSupervisorList.SelectedValue], "fullName");
                student["profileId"] = uid;
                student["role"] = "student";
                student["fullName"] = name;
                student["email"] = email;
                student["studentNumber"] = studentNumber;
                student["enrollmentYear"] = year;
                student["college"] = college;
                student["major"] = major;
                student["requiredHours"] = hours;
                student["startDate"] = startDateTextBox.Text.Trim();
                student["endDate"] = endDateTextBox.Text.Trim();

                if (oldStudent == null)
                {
                    student["isActive"] = true;
                    student["mustChangePassword"] = true;
                }

                await SaveStudent(uid, student);

                Session["studentMessage"] = isEditing ? "Student information updated." : "Student account created.";
                Response.Redirect("ManageStudents.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception error)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(error.Message);
                ShowForm();
            }
        }

        private string GetStudentNumber(string year,
            Dictionary<string, Dictionary<string, object>> users,
            Dictionary<string, Dictionary<string, object>> students,
            string uid, Dictionary<string, object> oldStudent)
        {
            string oldNumber = GetValue(oldStudent ?? new Dictionary<string, object>(), "studentNumber");

            if (oldStudent != null && oldNumber.Length == 8 && oldNumber.Substring(0, 4) == year)
                return oldNumber;

            for (int attempt = 0; attempt < 10000; attempt++)
            {
                int randomPart;
                lock (randomLock)
                {
                    randomPart = random.Next(0, 10000);
                }

                string newNumber = year + randomPart.ToString("D4");
                bool alreadyUsed = false;

                foreach (KeyValuePair<string, Dictionary<string, object>> item in users)
                {
                    if (item.Key != uid && GetValue(item.Value, "studentNumber") == newNumber)
                    {
                        alreadyUsed = true;
                        break;
                    }
                }

                foreach (KeyValuePair<string, Dictionary<string, object>> item in students)
                {
                    if (item.Key != uid && GetValue(item.Value, "studentNumber") == newNumber)
                    {
                        alreadyUsed = true;
                        break;
                    }
                }

                if (!alreadyUsed) return newNumber;
            }

            throw new Exception("Could not generate a unique student number. Try again.");
        }

        private Task<string> CreateAuthAccount(string email, string password)
        {
            return PSUTInternship.Shared.AccountProvisioning.Create(email, password);
        }

        private async Task SaveStudent(string uid, Dictionary<string, object> student)
        {
            await PSUTInternship.Shared.FirebaseRestClient.PatchAsync("", new Dictionary<string, object>
            { { "users/" + uid, student }, { "students/" + uid, student } }, idToken);
            await PSUTInternship.Shared.AcademicAssignments.Synchronize(uid, GetValue(student, "academicSupervisorId"));
        }



        private async Task LoadStudentForEdit(string uid)
        {
            try
            {
                Dictionary<string, Dictionary<string, object>> users = await GetUsers();
                if (!users.ContainsKey(uid) || !IsStudent(users[uid]))
                {
                    messageLabel.Text = "Student record was not found.";
                    ShowList();
                    await LoadStudents();
                    return;
                }

                Dictionary<string, object> student = users[uid];

                fullNameTextBox.Text = GetValue(student, "fullName");
                emailTextBox.Text = GetValue(student, "email");
                enrollmentYearTextBox.Text = GetValue(student, "enrollmentYear");
                if (enrollmentYearTextBox.Text == "")
                {
                    string number = GetValue(student, "studentNumber");
                    if (number.Length >= 4) enrollmentYearTextBox.Text = number.Substring(0, 4);
                }
                generatedNumberLabel.Text = HttpUtility.HtmlEncode(GetValue(student, "studentNumber"));
                PSUTInternship.Shared.AcademicCatalog.Select(collegeTextBox, GetValue(student, "college"));
                PSUTInternship.Shared.AcademicCatalog.Select(majorTextBox, GetValue(student, "major"));
                await PopulateAcademicSupervisors();
                var selectedSupervisor = academicSupervisorList.Items.FindByValue(GetValue(student, "academicSupervisorId"));
                if (selectedSupervisor != null) academicSupervisorList.SelectedValue = selectedSupervisor.Value;
                requiredHoursTextBox.Text = GetValue(student, "requiredHours");
                startDateTextBox.Text = GetValue(student, "startDate");
                endDateTextBox.Text = GetValue(student, "endDate");
                passwordTextBox.Enabled = false;
                formTitleLabel.Text = "Edit Student";
                saveButton.Text = "Save Changes";
                ShowForm();
            }
            catch (Exception error)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(error.Message);
                ShowList();
            }
        }

        private async Task LoadStudentForView(string uid)
        {
            try
            {
                Dictionary<string, Dictionary<string, object>> users = await GetUsers();
                if (!users.ContainsKey(uid) || !IsStudent(users[uid]))
                {
                    messageLabel.Text = "Student record was not found.";
                    ShowList();
                    await LoadStudents();
                    return;
                }

                Dictionary<string, object> student = users[uid];
                string number = GetValue(student, "studentNumber");
                viewStudentNumberLabel.Text = HttpUtility.HtmlEncode(number);
                viewYearLabel.Text = HttpUtility.HtmlEncode(GetValue(student, "enrollmentYear"));
                if (viewYearLabel.Text == "" && number.Length >= 4)
                    viewYearLabel.Text = HttpUtility.HtmlEncode(number.Substring(0, 4));
                viewNameLabel.Text = HttpUtility.HtmlEncode(GetValue(student, "fullName"));
                viewEmailLabel.Text = HttpUtility.HtmlEncode(GetValue(student, "email"));
                viewCollegeLabel.Text = HttpUtility.HtmlEncode(GetValue(student, "college"));
                viewMajorLabel.Text = HttpUtility.HtmlEncode(GetValue(student, "major"));
                viewHoursLabel.Text = HttpUtility.HtmlEncode(GetValue(student, "requiredHours"));
                viewStatusLabel.Text = GetValue(student, "isActive").ToLower() == "true" ? "Active" : "Inactive";
                viewStartDateLabel.Text = HttpUtility.HtmlEncode(GetValue(student, "startDate"));
                viewEndDateLabel.Text = HttpUtility.HtmlEncode(GetValue(student, "endDate"));
                ShowView();
            }
            catch (Exception error)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(error.Message);
                ShowList();
            }
        }

        private async Task ToggleStudent(string uid)
        {
            Dictionary<string, Dictionary<string, object>> users = await GetUsers();
            if (!users.ContainsKey(uid) || !IsStudent(users[uid])) return;

            bool newStatus = GetValue(users[uid], "isActive").ToLower() != "true";
            users[uid]["isActive"] = newStatus;
            await SaveStudent(uid, users[uid]);
            Session["studentMessage"] = newStatus ? "Student account activated." : "Student account deactivated.";
        }

        protected async void searchButton_Click(object sender, EventArgs e)
        {
            ShowList();
            await LoadStudents();
        }

        protected void clearButton_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowForm();
        }

        private void ClearForm()
        {
            fullNameTextBox.Text = "";
            emailTextBox.Text = "";
            passwordTextBox.Text = "";
            passwordTextBox.Enabled = true;
            enrollmentYearTextBox.Text = "";
            generatedNumberLabel.Text = "Generated after saving";
            collegeTextBox.Text = "";
            majorTextBox.Text = "";
            requiredHoursTextBox.Text = "96";
            startDateTextBox.Text = "";
            endDateTextBox.Text = "";
            formTitleLabel.Text = "Add Student";
            saveButton.Text = "Create Student";
        }
    }
}

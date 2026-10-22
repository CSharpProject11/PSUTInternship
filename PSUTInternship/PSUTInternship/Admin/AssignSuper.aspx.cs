using PSUTInternship.Models;
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
    public partial class AssignSuper : PSUTInternship.Shared.PortalPage
    {
        private string databaseUrl = PSUTInternship.Shared.FirebaseConfig.DatabaseUrl.TrimEnd('/');
        private JavaScriptSerializer serializer = new JavaScriptSerializer();

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

            try
            {
                Dictionary<string, Dictionary<string, object>> supervisors = await GetRecordsForRole("academicSupervisors", "academicSupervisor");
                Dictionary<string, Dictionary<string, object>> students = await GetRecordsForRole("students", "student");
                string groupId = Request.QueryString["view"];

                if (groupId != null)
                    ShowGroup(groupId, supervisors, students);
                else
                {
                    ShowList();
                    RenderGroups(supervisors, students, "");
                }

                if (Request.QueryString["saved"] == "1")
                    messageLabel.Text = "Group changes were saved.";
            }
            catch (Exception error)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(error.Message);
            }
        }

        private async Task<Dictionary<string, Dictionary<string, object>>> GetRecords(string objectName)
        {
            string url = databaseUrl + "/" + objectName + ".json?auth=" + Uri.EscapeDataString(idToken);
            using (HttpClient client = PSUTInternship.Shared.FirebaseConfig.CreateClient())
            {
                HttpResponseMessage response = await client.GetAsync(url);
                string result = await response.Content.ReadAsStringAsync();
                if (!response.IsSuccessStatusCode)
                {
                    if (result.Length > 400) result = result.Substring(0, 400);
                    throw new Exception("Firebase could not read /" + objectName + ". HTTP " +
                        (int)response.StatusCode + " " + response.StatusCode + ". Details: " + result);
                }
                if (result == "null" || result == "")
                    return new Dictionary<string, Dictionary<string, object>>();

                Dictionary<string, Dictionary<string, object>> records =
                    serializer.Deserialize<Dictionary<string, Dictionary<string, object>>>(result);
                if (records == null) return new Dictionary<string, Dictionary<string, object>>();
                return records;
            }
        }

        private async Task<Dictionary<string, Dictionary<string, object>>> GetRecordsForRole(
    string objectName, string role)
        {
            Dictionary<string, Dictionary<string, object>> records =
                new Dictionary<string, Dictionary<string, object>>();

            try
            {
                records = await GetRecords(objectName);
            }
            catch
            {
            }

            Dictionary<string, Dictionary<string, object>> users =
                await GetRecords("users");

            foreach (KeyValuePair<string, Dictionary<string, object>> item in users)
            {
                string userRole = NormalizeRole(GetValue(item.Value, "role"));

                if (userRole != NormalizeRole(role))
                    continue;

                if (!records.ContainsKey(item.Key))
                {
                    records[item.Key] = item.Value;
                }
                else
                {
                    foreach (KeyValuePair<string, object> field in item.Value)
                    {
                        if (!records[item.Key].ContainsKey(field.Key))
                            records[item.Key][field.Key] = field.Value;
                    }
                }
            }

            return records;
        }

        private string GetValue(Dictionary<string, object> data, string field)
        {
            if (data.ContainsKey(field) && data[field] != null)
                return Convert.ToString(data[field]);
            return "";
        }

        private string NormalizeRole(string role)
        {
            return role.Trim().Replace(" ", "").ToLowerInvariant();
        }

        private Dictionary<string, object> GetDictionary(Dictionary<string, object> data, string field)
        {
            if (data.ContainsKey(field))
                return data[field] as Dictionary<string, object>;
            return null;
        }

        private Dictionary<string, object> GetStudentIds(Dictionary<string, object> group)
        {
            Dictionary<string, object> ids = GetDictionary(group, "assignedStudentIds");
            if (ids == null) ids = new Dictionary<string, object>();
            return ids;
        }

        private List<StudentGroup> GetGroups(Dictionary<string, Dictionary<string, object>> supervisors)
        {
            List<StudentGroup> groups = new List<StudentGroup>();
            foreach (KeyValuePair<string, Dictionary<string, object>> supervisorItem in supervisors)
            {
                Dictionary<string, object> supervisor = supervisorItem.Value;
                Dictionary<string, object> savedGroups = GetDictionary(supervisor, "groups");
                if (savedGroups != null)
                {
                    foreach (KeyValuePair<string, object> groupItem in savedGroups)
                    {
                        Dictionary<string, object> group = groupItem.Value as Dictionary<string, object>;
                        if (group == null) continue;
                        groups.Add(MakeGroup(groupItem.Key, group, supervisorItem.Key, supervisor));
                    }
                }

                if (savedGroups == null && GetValue(supervisor, "groupName") != "")
                {
                    Dictionary<string, object> oldGroup = new Dictionary<string, object>();
                    oldGroup["groupName"] = GetValue(supervisor, "groupName");
                    oldGroup["department"] = GetValue(supervisor, "department");
                    oldGroup["assignedStudentIds"] = GetDictionary(supervisor, "assignedStudentIds") ?? new Dictionary<string, object>();
                    groups.Add(MakeGroup("old-" + supervisorItem.Key, oldGroup, supervisorItem.Key, supervisor));
                }
            }
            return groups;
        }

        private StudentGroup MakeGroup(string id, Dictionary<string, object> data, string supervisorId, Dictionary<string, object> supervisor)
        {
            StudentGroup group = new StudentGroup();
            group.id = id;
            group.data = data;
            group.supervisor = supervisor;
            group.supervisorId = supervisorId;
            group.name = GetValue(data, "groupName");
            group.department = GetValue(data, "department");
            group.supervisorName = GetValue(supervisor, "fullName");
            group.studentIds = GetStudentIds(data);
            return group;
        }

        private List<string> GetDepartments(Dictionary<string, Dictionary<string, object>> students,
            Dictionary<string, Dictionary<string, object>> supervisors)
        {
            List<string> departments = new List<string>();
            foreach (KeyValuePair<string, Dictionary<string, object>> item in students)
                AddDepartment(departments, GetValue(item.Value, "major"));
            foreach (KeyValuePair<string, Dictionary<string, object>> item in supervisors)
                AddDepartment(departments, GetValue(item.Value, "department"));
            departments.Sort(StringComparer.OrdinalIgnoreCase);
            return departments;
        }

        private void AddDepartment(List<string> departments, string department)
        {
            department = department.Trim();
            if (department == "") return;
            foreach (string existing in departments)
                if (String.Equals(existing, department, StringComparison.OrdinalIgnoreCase)) return;
            departments.Add(department);
        }

        private void RenderGroups(Dictionary<string, Dictionary<string, object>> supervisors,
            Dictionary<string, Dictionary<string, object>> students, string search)
        {
            List<StudentGroup> groups = GetGroups(supervisors);
            List<string> departments = GetDepartments(students, supervisors);
            StringBuilder html = new StringBuilder();
            search = search.Trim();

            foreach (string department in departments)
            {
                html.Append("<h3>").Append(HttpUtility.HtmlEncode(department)).Append("</h3>");
                html.Append("<div class='tableWrap'><table><thead><tr>");
                html.Append("<th>Group</th><th>Academic supervisor</th><th>Students</th><th>Actions</th>");
                html.Append("</tr></thead><tbody>");
                int shown = 0;

                foreach (StudentGroup group in groups)
                {
                    if (!String.Equals(group.department, department, StringComparison.OrdinalIgnoreCase)) continue;
                    StringBuilder studentNames = new StringBuilder();
                    foreach (string studentId in group.studentIds.Keys)
                    {
                        if (!students.ContainsKey(studentId)) continue;
                        Dictionary<string, object> student = students[studentId];
                        if (studentNames.Length > 0) studentNames.Append(", ");
                        studentNames.Append(GetValue(student, "fullName"));
                    }

                    string searchText = group.name + " " + group.supervisorName + " " + studentNames;
                    foreach (string studentId in group.studentIds.Keys)
                        if (students.ContainsKey(studentId)) searchText += " " + GetValue(students[studentId], "studentNumber");
                    if (search != "" && searchText.IndexOf(search, StringComparison.OrdinalIgnoreCase) < 0) continue;

                    shown++;
                    html.Append("<tr><td>").Append(HttpUtility.HtmlEncode(group.name)).Append("</td>");
                    html.Append("<td>").Append(HttpUtility.HtmlEncode(group.supervisorName)).Append("</td>");
                    html.Append("<td>").Append(group.studentIds.Count).Append(": ")
                        .Append(HttpUtility.HtmlEncode(studentNames.ToString())).Append("</td><td>");
                    html.Append("<a class='btn light' href='AssignSuper.aspx?view=")
                        .Append(HttpUtility.UrlEncode(group.id)).Append("'>View</a></td></tr>");
                }

                if (shown == 0)
                    html.Append("<tr><td colspan='4' class='empty'>No groups in this department match the search.</td></tr>");
                html.Append("</tbody></table></div>");
            }

            if (departments.Count == 0)
                html.Append("<p class='empty'>No IT departments or student majors were found.</p>");
            groupsTables.Text = html.ToString();
        }

        private void ShowList()
        {
            listSection.Visible = true;
            addSection.Visible = false;
            viewSection.Visible = false;
        }

        private void ShowAdd()
        {
            listSection.Visible = false;
            addSection.Visible = true;
            viewSection.Visible = false;
        }

        private void ShowView()
        {
            listSection.Visible = false;
            addSection.Visible = false;
            viewSection.Visible = true;
        }

        protected async void searchButton_Click(object sender, EventArgs e)
        {
            try
            {
                ShowList();
                Dictionary<string, Dictionary<string, object>> supervisors = await GetRecordsForRole("academicSupervisors", "academicSupervisor");
                Dictionary<string, Dictionary<string, object>> students = await GetRecordsForRole("students", "student");
                RenderGroups(supervisors, students, searchTextBox.Text);
            }
            catch (Exception error) { messageLabel.Text = HttpUtility.HtmlEncode(error.Message); }
        }

        protected async void addGroupButton_Click(object sender, EventArgs e)
        {
            try
            {
                Dictionary<string, Dictionary<string, object>> supervisors = await GetRecordsForRole("academicSupervisors", "academicSupervisor");
                Dictionary<string, Dictionary<string, object>> students = await GetRecordsForRole("students", "student");
                FillGroupForm(supervisors, students);
                ShowAdd();
            }
            catch (Exception error) { messageLabel.Text = HttpUtility.HtmlEncode(error.Message); }
        }

        private void FillGroupForm(Dictionary<string, Dictionary<string, object>> supervisors,
            Dictionary<string, Dictionary<string, object>> students)
        {
            departmentDropDown.Items.Clear();
            foreach (string department in GetDepartments(students, supervisors))
                departmentDropDown.Items.Add(new ListItem(department, department));

            if (departmentDropDown.Items.Count > 0)
                FillDepartmentChoices(supervisors, students, departmentDropDown.SelectedValue);
        }

        private void FillDepartmentChoices(Dictionary<string, Dictionary<string, object>> supervisors,
            Dictionary<string, Dictionary<string, object>> students, string department)
        {
            supervisorDropDown.Items.Clear();
            studentsCheckBoxList.Items.Clear();
            foreach (KeyValuePair<string, Dictionary<string, object>> item in supervisors)
            {
                Dictionary<string, object> supervisor = item.Value;
                if (NormalizeRole(GetValue(supervisor, "role")) != NormalizeRole("academicSupervisor") || GetValue(supervisor, "isActive").ToLower() != "true") continue;
                if (!String.Equals(GetValue(supervisor, "department").Trim(), department.Trim(), StringComparison.OrdinalIgnoreCase)) continue;
                string name = GetValue(supervisor, "fullName") + " — " + GetValue(supervisor, "department");
                supervisorDropDown.Items.Add(new ListItem(name, item.Key));
            }

            foreach (KeyValuePair<string, Dictionary<string, object>> item in students)
            {
                Dictionary<string, object> student = item.Value;
                if (NormalizeRole(GetValue(student, "role")) != "student") continue;
                if (!String.Equals(GetValue(student, "major").Trim(), department.Trim(), StringComparison.OrdinalIgnoreCase)) continue;
                string label = GetValue(student, "fullName") + " — " + GetValue(student, "studentNumber") + " — " + GetValue(student, "major");
                studentsCheckBoxList.Items.Add(new ListItem(label, item.Key));
            }
        }

        protected async void departmentDropDown_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                Dictionary<string, Dictionary<string, object>> supervisors = await GetRecordsForRole("academicSupervisors", "academicSupervisor");
                Dictionary<string, Dictionary<string, object>> students = await GetRecordsForRole("students", "student");
                FillDepartmentChoices(supervisors, students, departmentDropDown.SelectedValue);
                ShowAdd();
            }
            catch (Exception error) { messageLabel.Text = HttpUtility.HtmlEncode(error.Message); }
        }

        protected async void saveGroupButton_Click(object sender, EventArgs e)
        {
            string department = departmentDropDown.SelectedValue;
            string supervisorId = supervisorDropDown.SelectedValue;
            string groupName = groupNameTextBox.Text.Trim();
            List<string> selectedIds = new List<string>();
            foreach (ListItem item in studentsCheckBoxList.Items)
                if (item.Selected) selectedIds.Add(item.Value);

            if (department == "" || supervisorId == "" || groupName == "" || selectedIds.Count == 0)
            {
                messageLabel.Text = "Choose a department and supervisor, enter a group name, and select students.";
                ShowAdd();
                return;
            }

            try
            {
                Dictionary<string, Dictionary<string, object>> supervisors = await GetRecordsForRole("academicSupervisors", "academicSupervisor");
                Dictionary<string, Dictionary<string, object>> students = await GetRecordsForRole("students", "student");
                Dictionary<string, Dictionary<string, object>> users = await GetRecords("users");
                if (!supervisors.ContainsKey(supervisorId)) throw new Exception("The selected supervisor was not found.");

                Dictionary<string, object> supervisor = supervisors[supervisorId];
                if (!String.Equals(GetValue(supervisor, "department").Trim(), department.Trim(), StringComparison.OrdinalIgnoreCase))
                    throw new Exception("Choose a supervisor from the selected department.");

                string groupId = Guid.NewGuid().ToString("N");
                Dictionary<string, object> group = new Dictionary<string, object>();
                group["groupName"] = groupName;
                group["department"] = department;
                group["supervisorId"] = supervisorId;
                group["supervisorName"] = GetValue(supervisor, "fullName");
                group["assignedStudentIds"] = new Dictionary<string, object>();

                HashSet<string> changedStudentIds = new HashSet<string>();
                HashSet<string> changedSupervisorIds = new HashSet<string>();
                foreach (string studentId in selectedIds)
                {
                    if (!students.ContainsKey(studentId)) throw new Exception("A selected student was not found.");
                    if (!String.Equals(GetValue(students[studentId], "major").Trim(), department.Trim(), StringComparison.OrdinalIgnoreCase))
                        throw new Exception("Select students whose major matches the selected department.");
                    changedStudentIds.Add(studentId);
                }

                RemoveStudentsFromOldGroups(supervisors, selectedIds, changedSupervisorIds);
                AssignStudents(students, supervisor, group, groupId, department, groupName, supervisorId, selectedIds);
                AddGroupToSupervisor(supervisor, groupId, group);
                changedSupervisorIds.Add(supervisorId);
                await SaveChanges(supervisors, students, users, changedSupervisorIds, changedStudentIds);
                Response.Redirect("AssignSuper.aspx?saved=1", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception error)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(error.Message);
                ShowAdd();
            }
        }

        private void RemoveStudentsFromOldGroups(Dictionary<string, Dictionary<string, object>> supervisors,
            List<string> studentIds, HashSet<string> changedSupervisorIds)
        {
            foreach (KeyValuePair<string, Dictionary<string, object>> item in supervisors)
            {
                Dictionary<string, object> groups = GetDictionary(item.Value, "groups");
                if (groups != null)
                {
                    foreach (KeyValuePair<string, object> groupItem in groups)
                    {
                        Dictionary<string, object> group = groupItem.Value as Dictionary<string, object>;
                        if (group == null) continue;
                        Dictionary<string, object> ids = GetStudentIds(group);
                        foreach (string studentId in studentIds)
                            if (ids.Remove(studentId)) changedSupervisorIds.Add(item.Key);
                    }
                }

                Dictionary<string, object> oldIds = GetDictionary(item.Value, "assignedStudentIds");
                if (oldIds != null)
                    foreach (string studentId in studentIds)
                        if (oldIds.Remove(studentId)) changedSupervisorIds.Add(item.Key);
            }
        }

        private void AssignStudents(Dictionary<string, Dictionary<string, object>> students,
            Dictionary<string, object> supervisor, Dictionary<string, object> group, string groupId,
            string department, string groupName, string supervisorId, List<string> studentIds)
        {
            Dictionary<string, object> ids = GetStudentIds(group);
            foreach (string studentId in studentIds)
            {
                ids[studentId] = true;
                Dictionary<string, object> student = students[studentId];
                student["groupId"] = groupId;
                student["groupName"] = groupName;
                student["department"] = department;
                student["academicSupervisorId"] = supervisorId;
                student["academicSupervisorName"] = GetValue(supervisor, "fullName");
            }
            group["assignedStudentIds"] = ids;
        }

        private void AddGroupToSupervisor(Dictionary<string, object> supervisor, string groupId, Dictionary<string, object> group)
        {
            Dictionary<string, object> groups = GetDictionary(supervisor, "groups");
            if (groups == null) groups = new Dictionary<string, object>();
            groups[groupId] = group;
            supervisor["groups"] = groups;
        }

        private void ShowGroup(string groupId, Dictionary<string, Dictionary<string, object>> supervisors,
            Dictionary<string, Dictionary<string, object>> students)
        {
            StudentGroup group = FindGroup(groupId, supervisors);
            if (group == null)
            {
                messageLabel.Text = "Group not found.";
                ShowList();
                RenderGroups(supervisors, students, "");
                return;
            }

            ShowView();
            viewGroupNameLabel.Text = HttpUtility.HtmlEncode(group.name);
            viewDepartmentLabel.Text = HttpUtility.HtmlEncode(group.department);
            viewSupervisorLabel.Text = HttpUtility.HtmlEncode(group.supervisorName);
            RenderGroupStudents(group, students);
            FillAddStudents(group, students);
        }

        private StudentGroup FindGroup(string id, Dictionary<string, Dictionary<string, object>> supervisors)
        {
            foreach (StudentGroup group in GetGroups(supervisors))
                if (group.id == id) return group;
            return null;
        }

        private void RenderGroupStudents(StudentGroup group, Dictionary<string, Dictionary<string, object>> students)
        {
            StringBuilder html = new StringBuilder();
            html.Append("<div class='tableWrap'><table><thead><tr><th>Student number</th><th>Name</th><th>Email</th><th>Major</th></tr></thead><tbody>");
            int count = 0;
            foreach (string studentId in group.studentIds.Keys)
            {
                if (!students.ContainsKey(studentId)) continue;
                Dictionary<string, object> student = students[studentId];
                count++;
                html.Append("<tr><td>").Append(HttpUtility.HtmlEncode(GetValue(student, "studentNumber"))).Append("</td>");
                html.Append("<td>").Append(HttpUtility.HtmlEncode(GetValue(student, "fullName"))).Append("</td>");
                html.Append("<td>").Append(HttpUtility.HtmlEncode(GetValue(student, "email"))).Append("</td>");
                html.Append("<td>").Append(HttpUtility.HtmlEncode(GetValue(student, "major"))).Append("</td></tr>");
            }
            if (count == 0) html.Append("<tr><td colspan='4' class='empty'>No students are assigned to this group.</td></tr>");
            html.Append("</tbody></table></div>");
            viewStudentsTable.Text = html.ToString();
        }

        private void FillAddStudents(StudentGroup group, Dictionary<string, Dictionary<string, object>> students)
        {
            addStudentsCheckBoxList.Items.Clear();
            foreach (KeyValuePair<string, Dictionary<string, object>> item in students)
            {
                Dictionary<string, object> student = item.Value;
                if (NormalizeRole(GetValue(student, "role")) != "student") continue;
                if (!String.Equals(GetValue(student, "major").Trim(), group.department.Trim(), StringComparison.OrdinalIgnoreCase)) continue;
                if (group.studentIds.ContainsKey(item.Key)) continue;
                string label = GetValue(student, "fullName") + " — " + GetValue(student, "studentNumber");
                addStudentsCheckBoxList.Items.Add(new ListItem(label, item.Key));
            }
        }

        protected async void addStudentsButton_Click(object sender, EventArgs e)
        {
            string groupId = Request.QueryString["view"];
            List<string> selectedIds = new List<string>();
            foreach (ListItem item in addStudentsCheckBoxList.Items)
                if (item.Selected) selectedIds.Add(item.Value);
            if (selectedIds.Count == 0)
            {
                messageLabel.Text = "Select at least one student to add.";
                ShowView();
                return;
            }

            try
            {
                Dictionary<string, Dictionary<string, object>> supervisors = await GetRecordsForRole("academicSupervisors", "academicSupervisor");
                Dictionary<string, Dictionary<string, object>> students = await GetRecordsForRole("students", "student");
                Dictionary<string, Dictionary<string, object>> users = await GetRecords("users");
                StudentGroup groupInfo = FindGroup(groupId, supervisors);
                if (groupInfo == null) throw new Exception("Group not found.");

                HashSet<string> changedStudentIds = new HashSet<string>();
                HashSet<string> changedSupervisorIds = new HashSet<string>();
                foreach (string studentId in selectedIds)
                {
                    if (!students.ContainsKey(studentId)) throw new Exception("A selected student was not found.");
                    if (!String.Equals(GetValue(students[studentId], "major").Trim(), groupInfo.department.Trim(), StringComparison.OrdinalIgnoreCase))
                        throw new Exception("Only students from this department can join the group.");
                    changedStudentIds.Add(studentId);
                }

                RemoveStudentsFromOldGroups(supervisors, selectedIds, changedSupervisorIds);
                AssignStudents(students, groupInfo.supervisor, groupInfo.data, groupInfo.id,
                    groupInfo.department, groupInfo.name, groupInfo.supervisorId, selectedIds);
                AddGroupToSupervisor(groupInfo.supervisor, groupInfo.id, groupInfo.data);
                changedSupervisorIds.Add(groupInfo.supervisorId);
                await SaveChanges(supervisors, students, users, changedSupervisorIds, changedStudentIds);
                Response.Redirect("AssignSuper.aspx?view=" + HttpUtility.UrlEncode(groupId) + "&saved=1", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception error)
            {
                messageLabel.Text = HttpUtility.HtmlEncode(error.Message);
                ShowView();
            }
        }

        private async Task SaveChanges(Dictionary<string, Dictionary<string, object>> supervisors,
            Dictionary<string, Dictionary<string, object>> students, Dictionary<string, Dictionary<string, object>> users,
            HashSet<string> changedSupervisorIds, HashSet<string> changedStudentIds)
        {
            foreach (string studentId in changedStudentIds)
            {
                await SaveRecord("students", studentId, students[studentId]);
                if (users.ContainsKey(studentId))
                {
                    CopyAssignment(students[studentId], users[studentId]);
                    await SaveRecord("users", studentId, users[studentId]);
                }
            }

            foreach (string supervisorId in changedSupervisorIds)
            {
                await SaveRecord("academicSupervisors", supervisorId, supervisors[supervisorId]);
                if (users.ContainsKey(supervisorId))
                    await SaveRecord("users", supervisorId, supervisors[supervisorId]);
            }
        }

        private void CopyAssignment(Dictionary<string, object> from, Dictionary<string, object> to)
        {
            string[] fields = { "groupId", "groupName", "department", "academicSupervisorId", "academicSupervisorName" };
            foreach (string field in fields)
            {
                if (from.ContainsKey(field)) to[field] = from[field];
                else to.Remove(field);
            }
        }

        private async Task SaveRecord(string objectName, string id, Dictionary<string, object> data)
        {
            string url = databaseUrl + "/" + objectName + "/" + Uri.EscapeDataString(id) + ".json?auth=" + Uri.EscapeDataString(idToken);
            using (HttpClient client = PSUTInternship.Shared.FirebaseConfig.CreateClient())
            using (StringContent content = new StringContent(serializer.Serialize(data), Encoding.UTF8, "application/json"))
            {
                HttpResponseMessage response = await client.PutAsync(url, content);
                if (!response.IsSuccessStatusCode)
                    throw new Exception("Could not save the group. Check Firebase Database rules.");
                if (objectName == "students" && data.ContainsKey("academicSupervisorId"))
                    await PSUTInternship.Shared.AcademicAssignments.Synchronize(id, Convert.ToString(data["academicSupervisorId"]));
            }
        }

        protected void backButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("AssignSuper.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}


using System;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.UI;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using internship_manegment.Models;

namespace internship_manegment
{
    public partial class EditTask : System.Web.UI.Page
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string id = Request.QueryString["id"];
                string studentName = Request.QueryString["student"];

                if (string.IsNullOrEmpty(id) ||
                    string.IsNullOrEmpty(studentName))
                {
                    ShowMessage("Task ID or student name is missing");
                    return;
                }

                using (HttpClient client = new HttpClient())
                {
                    string url =
                        "https://student-management-syste-bc369-default-rtdb.asia-southeast1.firebasedatabase.app/Task/"
                        + HttpUtility.UrlEncode(id) + ".json";

                    string json = await client.GetStringAsync(url);

                    if (json == "null")
                    {
                        ShowMessage("Task not found");
                        return;
                    }

                    JObject task =
                        JsonConvert.DeserializeObject<JObject>(json);

                    bool studentFound = false;

                    if (task["assignedstudantTo"] is JArray)
                    {
                        foreach (JToken student in
                            (JArray)task["assignedstudantTo"])
                        {
                            if (string.Equals(
                                student.ToString(),
                                studentName,
                                StringComparison.OrdinalIgnoreCase))
                            {
                                studentFound = true;
                                break;
                            }
                        }
                    }
                    else if (task["assignedstudantTo"] != null)
                    {
                        studentFound = string.Equals(
                            task["assignedstudantTo"].ToString(),
                            studentName,
                            StringComparison.OrdinalIgnoreCase);
                    }

                    if (!studentFound)
                    {
                        ShowMessage(
                            "This student is not assigned to this task");
                        return;
                    }

                    string name =
                        task["nametask"]?.ToString() ?? "";

                    string deadline =
                        task["deedline"]?.ToString() ?? "";

                    string priority =
                        task["prprity"]?.ToString() ?? "";

                    string studentKey = TaskProgressHelper.GetStudentKey(studentName);
                    JObject studentProgress = task["studentProgress"]?[studentKey] as JObject;
                    string state = studentProgress?["state"]?.ToString()
                        ?? task["state"]?.ToString() ?? "";

                    string score =
                        task["score"]?.ToString() ?? "";

                    string feedback = studentProgress?["feedback"]?.ToString()
                        ?? task["feedback"]?.ToString() ?? "";

                    describtion.InnerHtml =
                        "<div style='padding:20px; margin:20px; background:#f5f7fa; border-radius:10px; font-family:Arial;'>" +

                        "<h2>Task Details</h2>" +

                        "<p><b>Task Name:</b> " +
                        HttpUtility.HtmlEncode(name) + "</p>" +

                        "<p><b>Student:</b> " +
                        HttpUtility.HtmlEncode(studentName) + "</p>" +

                        "<p><b>Deadline:</b> " +
                        HttpUtility.HtmlEncode(deadline) + "</p>" +

                        "<p><b>Priority:</b> " +
                        HttpUtility.HtmlEncode(priority) + "</p>" +

                        "<p><b>Current State:</b> " +
                        HttpUtility.HtmlEncode(state) + "</p>" +

                        "<p><b>Score:</b> " +
                        HttpUtility.HtmlEncode(score) + "</p>" +

                        "<p><b>Feedback:</b> " +
                        HttpUtility.HtmlEncode(feedback) + "</p>" +

                        "</div>";

                    Feedbackinput.Value = feedback;

                    if (state == "Resolve" ||
                        state == "Revision Requested")
                    {
                        stateDrop.SelectedValue = "Resolve";
                    }
                    else if (state == "Complete" ||
                             state == "Reviewed" ||
                             state == "Completed")
                    {
                        stateDrop.SelectedValue = "Complete";
                    }
                }
            }
        }

        protected async void Save_Click(object sender, EventArgs e)
        {
            string id = Request.QueryString["id"];
            string studentName = Request.QueryString["student"];

            if (string.IsNullOrEmpty(id) ||
                string.IsNullOrEmpty(studentName))
            {
                ShowMessage("Task ID or student name is missing");
                return;
            }

            string feedback = Feedbackinput.Value.Trim();

            if (feedback == "")
            {
                ShowMessage("Please enter feedback");
                return;
            }

            if (stateDrop.SelectedIndex == 0)
            {
                ShowMessage("Please select a state");
                return;
            }

            string state = stateDrop.SelectedValue;

            if (state == "Resolve")
            {
                state = "Revision Requested";
            }
            else if (state == "Complete")
            {
                state = "Reviewed";
            }

            using (HttpClient client = new HttpClient())
            {
                string taskUrl =
                    "https://student-management-syste-bc369-default-rtdb.asia-southeast1.firebasedatabase.app/Task/"
                    + HttpUtility.UrlEncode(id) + ".json";

                // Verify that the selected student belongs to this task.
                string existingJson = await client.GetStringAsync(taskUrl);

                if (existingJson == "null")
                {
                    ShowMessage("Task not found");
                    return;
                }

                JObject existingTask =
                    JsonConvert.DeserializeObject<JObject>(existingJson);

                bool studentFound = false;

                if (existingTask["assignedstudantTo"] is JArray)
                {
                    foreach (JToken student in
                        (JArray)existingTask["assignedstudantTo"])
                    {
                        if (string.Equals(
                            student.ToString(),
                            studentName,
                            StringComparison.OrdinalIgnoreCase))
                        {
                            studentFound = true;
                            break;
                        }
                    }
                }
                else if (existingTask["assignedstudantTo"] != null)
                {
                    studentFound = string.Equals(
                        existingTask["assignedstudantTo"].ToString(),
                        studentName,
                        StringComparison.OrdinalIgnoreCase);
                }

                if (!studentFound)
                {
                    ShowMessage(
                        "This student is not assigned to this task");
                    return;
                }

                string progressUrl =
                    "https://student-management-syste-bc369-default-rtdb.asia-southeast1.firebasedatabase.app/Task/"
                    + HttpUtility.UrlEncode(id) + "/studentProgress/"
                    + TaskProgressHelper.GetStudentKey(studentName) + ".json";
                var data = new
                {
                    state = state,
                    feedback = feedback,
                    updatedAtUtc = DateTime.UtcNow.ToString("o")
                };

                string json = JsonConvert.SerializeObject(data);

                StringContent content = new StringContent(
                    json,
                    Encoding.UTF8,
                    "application/json"
                );

                HttpRequestMessage request =
                    new HttpRequestMessage(new HttpMethod("PATCH"), progressUrl);

                request.Content = content;

                HttpResponseMessage response =
                    await client.SendAsync(request);

                if (response.IsSuccessStatusCode)
                {
                    Feedbackinput.Value = "";
                    stateDrop.SelectedIndex = 0;

                    ShowMessage("Feedback saved successfully");
                }
                else
                {
                    ShowMessage("Error saving feedback");
                }
            }
        }

        protected void Cansale_Click(object sender, EventArgs e)
        {
            Response.Redirect("task_manegment.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowMessage(string message)
        {
            string safeMessage =
                HttpUtility.JavaScriptStringEncode(message);

            ClientScript.RegisterStartupScript(
                this.GetType(),
                Guid.NewGuid().ToString(),
                "alert('" + safeMessage + "');",
                true
            );
        }
    }
}


using System;
using System.Net.Http;
using System.Web;
using System.Web.UI;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using internship_manegment.Models;

namespace internship_manegment
{
    public partial class ViewTask : System.Web.UI.Page
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
                    Describtion.InnerHtml =
                        "<p>Task ID or student name is missing.</p>";
                    solution.InnerHtml = "";
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
                        Describtion.InnerHtml =
                            "<p>Task not found.</p>";
                        solution.InnerHtml = "";
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
                        Describtion.InnerHtml =
                            "<p>This student is not assigned to this task.</p>";
                        solution.InnerHtml = "";
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

                    Describtion.InnerHtml =
                        "<div style='font-family:Arial; max-width:800px; margin:25px auto; padding:25px; background:#f5f7fa; border-radius:12px; box-shadow:0 3px 10px #ddd;'>" +

                        "<h2 style='border-bottom:2px solid #A8C9A5; padding-bottom:12px;'>Task Details</h2>" +

                        "<p><b>Task Name:</b> " +
                        HttpUtility.HtmlEncode(name) + "</p>" +

                        "<p><b>Student:</b> " +
                        HttpUtility.HtmlEncode(studentName) + "</p>" +

                        "<p><b>Deadline:</b> " +
                        HttpUtility.HtmlEncode(deadline) + "</p>" +

                        "<p><b>Priority:</b> " +
                        HttpUtility.HtmlEncode(priority) + "</p>" +

                        "<p><b>State:</b> " +
                        HttpUtility.HtmlEncode(state) + "</p>" +

                        "<p><b>Score:</b> " +
                        HttpUtility.HtmlEncode(score) + "</p>" +

                        "<p><b>Feedback:</b> " +
                        HttpUtility.HtmlEncode(feedback) + "</p>" +

                        "</div>";

                    // Display the submitted solution
                    JToken solutionData = task["solution"];

                    if (solutionData == null ||
                        solutionData.Type == JTokenType.Null ||
                        string.IsNullOrWhiteSpace(solutionData.ToString()))
                    {
                        solution.InnerHtml =
                            "<div style='font-family:Arial; max-width:800px; margin:20px auto; padding:20px;'>" +
                            "<h2>Student Solution</h2>" +
                            "<p style='background:#f5f7fa; padding:15px; border-radius:8px;'>" +
                            "The student has not submitted a solution yet." +
                            "</p></div>";
                    }
                    else
                    {
                        string solutionUrl = "";
                        string fileName = "Submitted Solution";
                        string fileType = "";

                        if (solutionData.Type == JTokenType.Object)
                        {
                            solutionUrl =
                                solutionData["url"]?.ToString() ??
                                solutionData["downloadUrl"]?.ToString() ??
                                solutionData["fileUrl"]?.ToString() ??
                                "";

                            fileName =
                                solutionData["fileName"]?.ToString() ??
                                solutionData["name"]?.ToString() ??
                                "Submitted Solution";

                            fileType =
                                solutionData["contentType"]?.ToString() ??
                                solutionData["type"]?.ToString() ??
                                "";
                        }
                        else
                        {
                            solutionUrl = solutionData.ToString();
                        }

                        if (string.IsNullOrWhiteSpace(solutionUrl))
                        {
                            solution.InnerHtml =
                                "<div style='font-family:Arial; max-width:800px; margin:20px auto; padding:20px;'>" +
                                "<h2>Student Solution</h2>" +
                                "<p>The solution information exists, but its file URL is missing.</p>" +
                                "</div>";
                        }
                        else if (
                            solutionUrl.StartsWith(
                                "https://", StringComparison.OrdinalIgnoreCase) ||
                            solutionUrl.StartsWith(
                                "http://", StringComparison.OrdinalIgnoreCase))
                        {
                            string safeUrl =
                                HttpUtility.HtmlAttributeEncode(solutionUrl);

                            string safeName =
                                HttpUtility.HtmlEncode(fileName);

                            bool isImage =
                                fileType.StartsWith(
                                    "image/", StringComparison.OrdinalIgnoreCase) ||
                                solutionUrl.Contains(".jpg") ||
                                solutionUrl.Contains(".jpeg") ||
                                solutionUrl.Contains(".png") ||
                                solutionUrl.Contains(".gif") ||
                                solutionUrl.Contains(".webp");

                            string content = "";

                            if (isImage)
                            {
                                content =
                                    "<a href='" + safeUrl + "' target='_blank'>" +
                                    "<img src='" + safeUrl +
                                    "' alt='Student Solution' " +
                                    "style='max-width:100%; max-height:500px; border-radius:10px; display:block; margin:15px 0;' />" +
                                    "</a>";
                            }

                            content +=
                                "<p><b>File:</b> " + safeName + "</p>" +

                                "<p><a href='" + safeUrl +
                                "' target='_blank' rel='noopener noreferrer' " +
                                "style='display:inline-block; padding:10px 18px; background:#355E3B; color:white; text-decoration:none; border-radius:6px; margin-right:8px;'>" +
                                "Open Solution</a>" +

                                "<a href='" + safeUrl +
                                "' download='" + safeName +
                                "' target='_blank' rel='noopener noreferrer' " +
                                "style='display:inline-block; padding:10px 18px; background:#6F9B73; color:white; text-decoration:none; border-radius:6px;'>" +
                                "Download Solution</a></p>";

                            solution.InnerHtml =
                                "<div style='font-family:Arial; max-width:800px; margin:20px auto; padding:25px; background:#fff; border:1px solid #ddd; border-radius:12px;'>" +
                                "<h2 style='color:#355E3B; border-bottom:2px solid #A8C9A5; padding-bottom:12px;'>Student Solution</h2>" +
                                content +
                                "</div>";
                        }
                        else
                        {
                            solution.InnerHtml =
                                "<div style='font-family:Arial; max-width:800px; margin:20px auto; padding:25px; background:#fff; border:1px solid #ddd; border-radius:12px;'>" +
                                "<h2 style='color:#355E3B;'>Student Solution</h2>" +
                                "<p>" +
                                HttpUtility.HtmlEncode(solutionData.ToString()) +
                                "</p></div>";
                        }
                    }
                }
            }
        }

        protected void Cansle_Click(object sender, EventArgs e)
        {
            Response.Redirect("task_manegment.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}

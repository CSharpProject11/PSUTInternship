
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using internship_manegment.Models;

namespace internship_manegment
{
    public partial class task_manegment : System.Web.UI.Page
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            string archiveId = Request.QueryString["archive"];

            if (!string.IsNullOrEmpty(archiveId))
            {
                using (HttpClient archiveClient = new HttpClient())
                {
                    string archiveUrl =
                        "https://student-management-syste-bc369-default-rtdb.asia-southeast1.firebasedatabase.app/Task/"
                        + HttpUtility.UrlEncode(archiveId) + ".json";

                    string taskJson =
                        await archiveClient.GetStringAsync(archiveUrl);

                    if (taskJson == "null")
                    {
                        Response.Write("Task not found.");
                        return;
                    }

                    JObject taskData =
                        JsonConvert.DeserializeObject<JObject>(taskJson);

                    bool currentActive = true;

                    if (taskData["Active"] != null)
                    {
                        currentActive = (bool)taskData["Active"];
                    }

                    var updateData = new
                    {
                        Active = !currentActive
                    };

                    string updateJson =
                        JsonConvert.SerializeObject(updateData);

                    StringContent content = new StringContent(
                        updateJson,
                        Encoding.UTF8,
                        "application/json"
                    );

                    HttpRequestMessage request =
                        new HttpRequestMessage(
                            new HttpMethod("PATCH"),
                            archiveUrl
                        );

                    request.Content = content;

                    HttpResponseMessage response =
                        await archiveClient.SendAsync(request);

                    if (response.IsSuccessStatusCode)
                    {
                        Response.Redirect("task_manegment.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                    else
                    {
                        string error =
                            await response.Content.ReadAsStringAsync();

                        Response.Write("Archive failed: " + error);
                        return;
                    }
                }
            }

            using (HttpClient client = new HttpClient())
            {
                string url =
                    "https://student-management-syste-bc369-default-rtdb.asia-southeast1.firebasedatabase.app/Task.json";

                string json = await client.GetStringAsync(url);

                var data =
                    JsonConvert.DeserializeObject<Dictionary<string, Models.TaskModel>>(json);

                if (data == null)
                {
                    data = new Dictionary<string, Models.TaskModel>();
                }

                string selectedStatus = DropDownList1.SelectedValue;
                string searchText = search.Text.Trim();

                foreach (var item in data)
                {
                    TaskModel task = item.Value;

                    if (task == null || task.assignedstudantTo == null)
                    {
                        continue;
                    }

                    for (int i = 0; i < task.assignedstudantTo.Count; i++)
                    {
                        string studentName = task.assignedstudantTo[i];
                        StudentTaskProgress studentProgress = task.GetProgressForStudent(studentName);
                        string taskStatus = GetStatus(studentProgress?.state ?? task.state);

                        if (selectedStatus != "All statuses" &&
                            taskStatus != selectedStatus)
                        {
                            continue;
                        }

                        if (!string.IsNullOrWhiteSpace(searchText) &&
                            (task.nametask ?? "").IndexOf(
                                searchText, StringComparison.OrdinalIgnoreCase) < 0 &&
                            (studentName ?? "").IndexOf(
                                searchText, StringComparison.OrdinalIgnoreCase) < 0)
                        {
                            continue;
                        }

                        HtmlTableRow Row = new HtmlTableRow();

                        if (!task.Active)
                        {
                            Row.BgColor = "#d3d3d3";
                        }

                        Row.Cells.Add(CreateCell(task.nametask));
                        Row.Cells.Add(CreateCell(studentName));
                        Row.Cells.Add(CreateCell(task.deedline.ToString("dd/MM/yyyy")));
                        Row.Cells.Add(CreateCell(task.prprity));
                        Row.Cells.Add(CreateCell(taskStatus));
                        Row.Cells.Add(CreateCell(Convert.ToString(task.score)));

                        HtmlTableCell actionCell = new HtmlTableCell();

                        HtmlAnchor viewLink = new HtmlAnchor();
                        viewLink.InnerText = "View";
                        viewLink.HRef = "ViewTask.aspx?id=" + item.Key
                            + "&student=" + HttpUtility.UrlEncode(studentName);

                        HtmlAnchor editLink = new HtmlAnchor();
                        editLink.InnerText = "Edit";
                        editLink.HRef = "EditTask.aspx?id=" + item.Key
                            + "&student=" + HttpUtility.UrlEncode(studentName);

                        HtmlAnchor archefLink = new HtmlAnchor();

                        if (task.Active)
                        {
                            archefLink.InnerText = "Archive";
                        }
                        else
                        {
                            archefLink.InnerText = "Unarchive";
                        }

                        archefLink.HRef =
                            "task_manegment.aspx?archive="
                            + HttpUtility.UrlEncode(item.Key);

                        actionCell.Controls.Add(viewLink);
                        actionCell.Controls.Add(new LiteralControl(" | "));
                        actionCell.Controls.Add(editLink);
                        actionCell.Controls.Add(new LiteralControl(" | "));
                        actionCell.Controls.Add(archefLink);

                        Row.Cells.Add(actionCell);

                        TaskTablebody.Controls.Add(Row);
                    }
                }

                List<string> studentStatuses = data.Values
                    .Where(task => task != null && task.assignedstudantTo != null)
                    .SelectMany(task => task.assignedstudantTo.Select(studentName =>
                    {
                        StudentTaskProgress progress = task.GetProgressForStudent(studentName);
                        return GetStatus(progress?.state ?? task.state);
                    }))
                    .ToList();

                countTotal.Text = studentStatuses.Count.ToString();
                countPending.Text = studentStatuses.Count(status => status == "Pending Review").ToString();
                countProgress.Text = studentStatuses.Count(status => status == "In Progress").ToString();
                countReviewed.Text = studentStatuses.Count(status => status == "Reviewed").ToString();
            }
        }

        private HtmlTableCell CreateCell(string text)
        {
            HtmlTableCell cell = new HtmlTableCell();
            cell.InnerText = text ?? "";
            return cell;
        }

        private string GetStatus(string status)
        {
            switch ((status ?? "").Trim().ToLowerInvariant())
            {
                case "pending":
                case "pending review":
                    return "Pending Review";

                case "in progress":
                    return "In Progress";

                case "revision requested":
                    return "Revision Requested";

                case "reviewed":
                case "completed":
                    return "Reviewed";

                default:
                    return status ?? "";
            }
        }

        protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e)
        {
        }

        protected void search_TextChanged(object sender, EventArgs e)
        {
        }

        protected void Create_Click(object sender, EventArgs e)
        {
            Response.Redirect("Create_task.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}

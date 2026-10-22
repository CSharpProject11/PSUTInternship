using internship_manegment.Models;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Net.Mime.MediaTypeNames;
using System.Text.RegularExpressions;

namespace internship_manegment
{
    public partial class Create_task : System.Web.UI.Page
    {
        protected async void Page_Load(object sender, EventArgs e)
        {

            HttpClient client = new HttpClient();
            string url = "https://student-management-syste-bc369-default-rtdb.asia-southeast1.firebasedatabase.app/Users.json";
            string json = await client.GetStringAsync(url);
            var users = JsonConvert.DeserializeObject<Dictionary<string, FirebaseUser>>(json);
            if (users != null)
            {
                foreach (var item in users)
                {
                    FirebaseUser user = item.Value;
                    if (user != null && user.Role == "Students")
                    {
                        cblStudents.Items.Add(new ListItem(user.Name, user.Name));
                    }
                }
            }
        }

        protected void txtassingeto_TextChanged(object sender, EventArgs e)
        {

        }

        protected void Cancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("task_manegment.aspx",false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected async void CreateTask_Click(object sender, EventArgs e)
        {
            List<string> selectedStudents = new List<string>();

            foreach (ListItem student in cblStudents.Items)
            {
                if (student.Selected)
                {
                    selectedStudents.Add(student.Value);
                }
            }
            string title = Titelinput.Value.Trim();
            string description = Descriptioniput.Value.Trim();
            string criteria = EvaluationCriteriainput.Value.Trim();
            string priority = prorityinput.SelectedValue;
            string scoreText = Scoreinput.Value.Trim();

            if (!IsValid(title, @"^[A-Za-z0-9 ]{3,100}$"))
            {
                ErrorTitel.Text = "Task title must be 3-100 characters.";
                return;
            }
            else
            {
                ErrorTitel.Text = "";
            }

            if (!IsValid(description, @"^.{10,500}$"))
            {
                ErorrDescreption.Text="Description must be 10-500 characters.";
                return;
            }
            else
            {
                ErorrDescreption.Text = "";
            }

            if (!IsValid(criteria, @"^.{5,300}$"))
            {
                ErorrEvaluation.Text="Evaluation criteria must be 5-300 characters.";
                return;
            }
            else
            {
                ErorrEvaluation.Text = "";
            }
            if (!IsValid(scoreText, @"^(100|[1-9]?[0-9])$"))
            {
                Errorscor.Text="Score must be between 0 and 100.";
                return;
            }
            else
            {
                Errorscor.Text = "";
            }
            if (cblStudents.Items.Cast<ListItem>().All(s => !s.Selected))
            {
                ErorrAssign.Text = "Please select at least one student.";
                return;
            }
            else
            {
                ErorrAssign.Text = "";
            }
            DateTime deadline;

            if (!DateTime.TryParse(Deadlineinput.Text, out deadline))
            {
                ErorrDeadline.Text = "Please enter a valid deadline.";
                return;
            }
            else if (deadline <= DateTime.Now)
            {
                ErorrDeadline.Text = "Deadline must be in the future.";
                return;
            }
            else
            {
                ErorrDeadline.Text = "";
            }
            var data = new
            {
                nametask = Titelinput.Value,
                Describtion = Descriptioniput.Value,
                prprity = prorityinput.SelectedValue,
                score = Convert.ToInt32( Scoreinput.Value),
                Evaluation_Criteria = EvaluationCriteriainput.Value,
                deedline= Convert.ToDateTime( Deadlineinput.Text),
                state= "pending",
                assignedstudantTo = selectedStudents
            };
            HttpClient client = new HttpClient();

            string json = JsonConvert.SerializeObject(data);
            StringContent contant = new StringContent(json, Encoding.UTF8, "application/json");
            var response = await client.PostAsync("https://student-management-syste-bc369-default-rtdb.asia-southeast1.firebasedatabase.app/Task.json", contant);

            if (response.IsSuccessStatusCode)
            {
                Titelinput.Value = "";
                Descriptioniput.Value = "";
                EvaluationCriteriainput.Value = "";
                prorityinput.SelectedIndex = 0;
                Scoreinput.Value = "";
                Deadlineinput.Text = "";

                foreach (ListItem student in cblStudents.Items)
                {
                    student.Selected = false;
                }
            }
        }
        private bool IsValid(string value, string pattern)
        {
            return Regex.IsMatch(value, pattern);
        }
    }
}
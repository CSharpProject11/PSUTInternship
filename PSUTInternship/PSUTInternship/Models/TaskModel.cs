using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace internship_manegment.Models
{
    public class TaskModel
    {
        public string nametask {  get; set; }
        public string Describtion { get; set; }
        public string prprity {  get; set; }
        public string state { get; set; }
        public int score {  get; set; }
        public string Evaluation_Criteria{  get; set; }
        public DateTime deedline {  get; set; }
        public List<string>assignedstudantTo { get; set; }
        public bool Active { get; set; } = true;
        public Dictionary<string, StudentTaskProgress> studentProgress { get; set; }

        public StudentTaskProgress GetProgressForStudent(string studentName)
        {
            StudentTaskProgress progress;
            string key = TaskProgressHelper.GetStudentKey(studentName);
            return studentProgress != null && studentProgress.TryGetValue(key, out progress)
                ? progress
                : null;
        }

    }

    public class StudentTaskProgress
    {
        public string state { get; set; }
        public string feedback { get; set; }
        public string updatedAtUtc { get; set; }
    }

    public static class TaskProgressHelper
    {
        public static string GetStudentKey(string studentName)
        {
            string value = Convert.ToBase64String(Encoding.UTF8.GetBytes(studentName ?? ""));
            return value.TrimEnd('=').Replace('+', '-').Replace('/', '_');
        }
    }
    public class FirebaseUser
    {
        public string Name { get; set; }
        public string Email { get; set; }
        public string Role { get; set; }
    }
}
using System;
using System.Linq;
using System.Web.UI.WebControls;
namespace PSUTInternship.Shared {
    // https://www.psut.edu.jo/en/about-khscs (reviewed 23 October 2026)
    public static class AcademicCatalog {
        public const string College = "King Hussein School of Computing Sciences";
        public static readonly string[] Programs = { "Computer Science", "Computer Graphics and Animation", "Software Engineering", "Data Science and Artificial Intelligence", "Cyber Security" };
        public static string Canonical(string text) {
            string value = (text ?? "").Trim().ToLowerInvariant().Replace("&", "and").Replace("department of ", "").Replace(" department", "").Replace("cybersecurity", "cyber security");
            return value;
        }
        public static bool SameDepartment(string first, string second) { return !string.IsNullOrWhiteSpace(first) && !string.IsNullOrWhiteSpace(second) && Canonical(first) == Canonical(second); }
        public static bool MatchesSupervisor(string program,string department,string specialization) { return SameDepartment(program,department) && SameDepartment(program,specialization); }
        public static bool ValidProgram(string value) { return Programs.Any(x => SameDepartment(x,value)); }
        public static void Select(DropDownList control, string value) {
            control.ClearSelection(); var option = control.Items.Cast<ListItem>().FirstOrDefault(x => Canonical(x.Value) == Canonical(value));
            if (option != null) option.Selected = true; else control.SelectedIndex = 0;
        }
    }
}
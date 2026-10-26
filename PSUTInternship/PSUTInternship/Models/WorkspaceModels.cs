using System;
namespace PSUTInternship.Models {
    public class WorkspaceMetric
    {
        public string Label, Value, Hint;
        public WorkspaceMetric(string label, string value, string hint) { Label = label; Value = value; Hint = hint; }
    }
    public class WorkspaceRow { public string Title, Person, Status, Date, Url; public DateTime SortDate; }
    public class WorkspaceOpening { public string Id, Title, Location, Mode, Status, Deadline, Url; }

}

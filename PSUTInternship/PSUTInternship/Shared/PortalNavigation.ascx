<%@ Control Language="C#" %>
<%@ Import Namespace="PSUTInternship.Shared" %>
<script runat="server">
    protected string Role { get { return PortalRoles.Normalize(Convert.ToString(Session["userRole"])); } }
    protected string RoleLabel { get { return Role == "admin" ? "Internship coordinator" : Role == "company" ? "Company supervisor" : Role == "academic" ? "Academic supervisor" : "Student workspace"; } }
    protected string[][] Links {
        get {
            if (Role == "admin") return new[] {
                new[] {"Dashboard", "~/Admin/Dashboard.aspx", "grid"}, new[] {"Students", "~/Admin/ManageStudents.aspx", "people"},
                new[] {"Company supervisors", "~/Admin/ManageCompanies.aspx", "bag"}, new[] {"Academic supervisors", "~/Admin/ManageAcademic.aspx", "people"},
                new[] {"Assign supervisors", "~/Admin/AssignSuper.aspx", "link"}, new[] {"Placements", "~/Admin/MonitorPlacements.aspx", "bag"},
                new[] {"Completion review", "~/Admin/CompletionReview.aspx", "check"},
                new[] {"Contact messages", "~/Admin/ContactMessages.aspx", "mail"}};
            if (Role == "company") return new[] {
                new[] {"Dashboard", "~/Company/Dashboard.aspx", "grid"}, new[] {"Opportunities", "~/Company/Opportunities.aspx", "bag"},
                new[] {"Applications", "~/Company/Applications.aspx", "file"}, new[] {"My trainees", "~/Company/Trainees.aspx", "people"},
                new[] {"Tasks & submissions", "~/Company/Tasks.aspx", "check"},
                new[] {"Final evaluations", "~/Company/ReportsAndEvaluation.aspx", "chart"}};
            if (Role == "academic") return new[] {
                new[] {"Dashboard", "~/Academic/Dashboard.aspx", "grid"}, new[] {"Student progress", "~/Academic/StudentProgress.aspx", "chart"},
                new[] {"Final evaluation", "~/Academic/FinalEvaluation.aspx", "check"},
                new[] {"Meetings", "~/Academic/Meetings.aspx", "video"}};
            return new[] {
                new[] {"Dashboard", "~/Student/Dashboard.aspx", "grid"}, new[] {"Opportunities", "~/Student/Opportunities.aspx", "bag"},
                new[] {"My applications", "~/Student/MyApplications.aspx", "file"}, new[] {"My tasks", "~/Student/MyTasks.aspx", "check"},
                new[] {"Progress & report", "~/Student/StudentProgress.aspx", "chart"},
                new[] {"Meetings", "~/Student/Meetings.aspx", "video"}};
        }
    }
    protected bool Current(string target) {
        string path = Request.AppRelativeCurrentExecutionFilePath;
        // Friendly URLs can omit .aspx while the menu stores physical page paths.
        string currentPage = path.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase) ? path.Substring(0, path.Length - 5) : path;
        string targetPage = target.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase) ? target.Substring(0, target.Length - 5) : target;
        if (currentPage.TrimEnd('/').Equals(targetPage.TrimEnd('/'), StringComparison.OrdinalIgnoreCase)) return true;
        string file = System.IO.Path.GetFileNameWithoutExtension(path);
        return (file == "Apply" && target.EndsWith("/Opportunities.aspx")) ||
            ((file == "Application" || file == "RejectApplication") && target.EndsWith("/Applications.aspx")) ||
            (file == "OpportunityForm" && target.EndsWith("/Opportunities.aspx")) ||
            ((file == "CreateTask" || file == "EditTask" || file == "ViewTask") && target.EndsWith("/Tasks.aspx"));
    }
    protected string Icon(string name) {
        switch(name) {
            case "grid": return "<rect x='3' y='3' width='7' height='7' rx='2'/><rect x='14' y='3' width='7' height='7' rx='2'/><rect x='3' y='14' width='7' height='7' rx='2'/><rect x='14' y='14' width='7' height='7' rx='2'/>";
            case "bag": return "<rect x='3' y='7' width='18' height='14' rx='3'/><path d='M8 7V3h8v4M3 12h18'/>";
            case "people": return "<circle cx='9' cy='8' r='3'/><path d='M2 21v-3a7 7 0 0 1 14 0v3M17 5a3 3 0 0 1 0 6m2 3a6 6 0 0 1 3 5'/>";
            case "clock": return "<circle cx='12' cy='12' r='9'/><path d='M12 7v5l4 2'/>";
            case "chart": return "<path d='M4 3v18h17M8 16v-5m5 5V6m5 10V9'/>";
            case "check": return "<rect x='4' y='3' width='16' height='18' rx='3'/><path d='m8 12 3 3 5-6'/>";
            case "mail": return "<rect x='3' y='5' width='18' height='14' rx='3'/><path d='m3 7 9 6 9-6'/>";
            case "video": return "<rect x='3' y='6' width='12' height='12' rx='3'/><path d='m15 10 6-4v12l-6-4'/>";
            case "link": return "<path d='m10 14 4-4m-5 6-2 2a4 4 0 0 1-6-6l4-4a4 4 0 0 1 6 0m2 0 2-2a4 4 0 0 1 6 6l-4 4a4 4 0 0 1-6 0'/>";
            default: return "<path d='M6 3h9l4 4v14H6zM14 3v5h5M9 12h7m-7 4h7'/>";
        }
    }
</script>
<aside class="portal-sidebar" id="portal-navigation" aria-label="Main navigation">
    <div class="portal-brand-row">
        <a class="portal-brand" href="<%= ResolveUrl("~/Default.aspx") %>" aria-label="PSUT Internship Portal homepage"><img class="portal-brand-emblem" src="<%= ResolveUrl("~/Assets/psut-emblem.png") %>" alt="" width="32" height="32" /><img class="portal-brand-wordmark" src="<%= ResolveUrl("~/Assets/psut-logo.jpg") %>" alt="Princess Sumaya University for Technology" /></a>
        <button type="button" class="portal-rail-toggle" aria-label="Collapse navigation" aria-controls="portal-navigation" aria-expanded="true"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m14 6-6 6 6 6"/></svg></button>
    </div>
    <span class="portal-nav-label">Workspace</span>
    <nav class="portal-nav" aria-label="Workspace pages"><% foreach (var item in Links) { %><a href="<%= ResolveUrl(item[1]) %>" aria-label="<%: item[0] %>" title="<%: item[0] %>" <%= Current(item[1]) ? "aria-current=\"page\"" : "" %>><svg viewBox="0 0 24 24" aria-hidden="true"><%= Icon(item[2]) %></svg><span><%: item[0] %></span></a><% } %></nav>
    <div class="portal-sidebar-bottom">
        <a href="<%= ResolveUrl(Role == "admin" ? "~/Admin/CoordinatorAccount.aspx" : Role == "company" ? "~/Company/Account.aspx" : Role == "academic" ? "~/Academic/Account.aspx" : "~/Student/StudentProfile.aspx") %>" aria-label="My account" title="My account" <%= Current(Role == "admin" ? "~/Admin/CoordinatorAccount.aspx" : Role == "company" ? "~/Company/Account.aspx" : Role == "academic" ? "~/Academic/Account.aspx" : "~/Student/StudentProfile.aspx") ? "aria-current=\"page\"" : "" %>><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></svg><span>My account</span></a>
        <a href="<%= ResolveUrl("~/Logout.aspx") %>" aria-label="Logout" title="Logout"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M10 4H4v16h6m4-4 4-4-4-4m4 4H9"/></svg><span>Logout</span></a>
    </div>
</aside>

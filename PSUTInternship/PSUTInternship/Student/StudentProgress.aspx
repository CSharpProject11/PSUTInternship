


<%@ Page Title="My Progress & Evaluation | UIMS"
    Language="C#"
    MasterPageFile="~/Portal.Master"
    AutoEventWireup="true"
    Async="true"
    CodeBehind="MyProgress.aspx.cs"
    Inherits="PSUTInternship.Student.MyProgress" %>

<asp:Content ID="PageContent"
    ContentPlaceHolderID="PortalContent"
    runat="server">

<style>
    /* Scoped to My Progress only */
    .mp-page, .mp-page * {
        box-sizing: border-box;
    }

    .mp-page {
        --mp-navy: #142d4b;
        --mp-blue: #1678ec;
        --mp-muted: #6c809d;
        --mp-border: #e4ebf5;
        width: 100%;
        max-width: 1500px;
        margin: 0 auto;
        color: var(--mp-navy);
        font-family: inherit;
    }

    .mp-page .mp-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        gap: 18px;
        margin-bottom: 20px;
    }

    .mp-page .mp-welcome {
        margin: 0 0 5px;
        font-size: 12px;
        color: #6680a3;
    }

    .mp-page h1 {
        margin: 0 0 7px;
        font-size: clamp(22px, 2vw, 29px);
        line-height: 1.2;
        color: #102945;
        font-weight: 800;
    }

    .mp-page .mp-subtitle {
        margin: 0;
        font-size: 13px;
        color: var(--mp-muted);
    }

    .mp-page .mp-overview-pill {
        display: inline-flex;
        align-items: center;
        gap: 9px;
        padding: 12px 17px;
        background: #e9f3ff;
        border-radius: 30px;
        color: #1765ca;
        font-size: 12px;
        font-weight: 700;
        white-space: nowrap;
    }

    .mp-page .mp-panel {
        background: #fff;
        border: 1px solid var(--mp-border);
        border-radius: 17px;
        box-shadow: 0 6px 22px rgba(25, 60, 100, .035);
        min-width: 0;
    }

    .mp-page .mp-top {
        display: grid;
        grid-template-columns: minmax(0, 1.12fr) minmax(0, 1fr);
        gap: 16px;
        margin-bottom: 16px;
    }

    /* Progress hero */
    .mp-page .mp-hero {
        position: relative;
        min-height: 240px;
        display: flex;
        align-items: center;
        gap: 26px;
        padding: 25px;
        overflow: hidden;
        background: linear-gradient(115deg,
            #fff 35%, #f5fff9 72%, #d7f9e5 100%);
    }

    .mp-page .mp-hero::after {
        content: "";
        position: absolute;
        width: 240px;
        height: 240px;
        right: -95px;
        bottom: -135px;
        border-radius: 50%;
        background: rgba(49, 211, 114, .12);
    }

    .mp-page .mp-ring {
        --progress: 0;
        width: 175px;
        height: 175px;
        flex: 0 0 175px;
        border-radius: 50%;
        background: conic-gradient(
            #20ad59 calc(var(--progress) * 1%),
            #e7f0eb 0
        );
        display: flex;
        align-items: center;
        justify-content: center;
        position: relative;
        box-shadow: 0 7px 18px rgba(29, 174, 86, .08);
    }

    .mp-page .mp-ring::before {
        content: "";
        position: absolute;
        inset: 15px;
        background: #fff;
        border-radius: 50%;
    }

    .mp-page .mp-ring-inner {
        position: relative;
        z-index: 1;
        text-align: center;
    }

    .mp-page .mp-ring-value {
        font-size: 36px;
        font-weight: 800;
        color: #132d4b;
        line-height: 1.2;
    }

    .mp-page .mp-ring-label {
        margin-top: 5px;
        color: #6e829d;
        font-size: 12px;
    }

    .mp-page .mp-hero-copy {
        position: relative;
        z-index: 1;
        flex: 1;
        min-width: 0;
    }

    .mp-page .mp-hero-copy h2 {
        margin: 0 0 10px;
        font-size: 21px;
        font-weight: 800;
    }

    .mp-page .mp-hero-count {
        display: block;
        font-size: 15px;
        font-weight: 750;
        margin-bottom: 13px;
    }

    .mp-page .mp-hero-copy p {
        margin: 0;
        max-width: 260px;
        color: #637c9d;
        font-size: 12px;
        line-height: 1.8;
    }

    .mp-page .mp-hero-decoration {
        align-self: flex-end;
        position: relative;
        z-index: 1;
        color: #22b768;
        font-size: 70px;
        opacity: .45;
        transform: rotate(-12deg);
        margin-right: 5px;
    }

    /* KPI cards */
    .mp-page .mp-stats {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 14px;
    }

    .mp-page .mp-stat {
        min-height: 112px;
        padding: 17px;
        display: flex;
        align-items: flex-start;
        gap: 14px;
    }

    .mp-page .mp-stat.completed {
        background: linear-gradient(120deg, #fff, #f2fcf6);
    }

    .mp-page .mp-stat.revision {
        background: linear-gradient(120deg, #fff, #fff9ef);
    }

    .mp-page .mp-stat-icon {
        width: 45px;
        height: 45px;
        border-radius: 13px;
        background: #e7f1ff;
        color: #1677e7;
        display: flex;
        align-items: center;
        justify-content: center;
        flex: 0 0 45px;
        font-size: 22px;
        font-weight: 700;
    }

    .mp-page .mp-stat.completed .mp-stat-icon {
        background: #ddf7e6;
        color: #14a452;
    }

    .mp-page .mp-stat.revision .mp-stat-icon {
        background: #fff0d9;
        color: #ef920b;
    }

    .mp-page .mp-stat-copy {
        flex: 1;
        min-width: 0;
    }

    .mp-page .mp-stat-label {
        color: #637b9b;
        font-size: 12px;
        margin-bottom: 8px;
    }

    .mp-page .mp-stat-number {
        display: block;
        font-size: 29px;
        line-height: 1.1;
        font-weight: 800;
        color: #112b49;
        background: transparent !important;
        padding: 0 !important;
        border: 0 !important;
    }

    .mp-page .mp-stat-note {
        margin-top: 7px;
        color: #7185a2;
        font-size: 11px;
    }

    /* Shared section */
    .mp-page .mp-section {
        padding: 20px;
        margin-bottom: 16px;
    }

    .mp-page .mp-section-heading {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 15px;
        margin-bottom: 17px;
    }

    .mp-page .mp-section-title {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .mp-page .mp-heading-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 43px;
        height: 43px;
        border-radius: 12px;
        background: #e7edff;
        color: #456cf2;
        font-size: 22px;
        flex-shrink: 0;
    }

    .mp-page .mp-section-heading h2 {
        margin: 0 0 4px;
        font-size: 17px;
        font-weight: 800;
    }

    .mp-page .mp-section-heading p {
        margin: 0;
        font-size: 12px;
        color: #7286a2;
    }

    /* Task table */
    .mp-page .mp-tools {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .mp-page .mp-search,
    .mp-page .mp-filter {
        height: 40px;
        border: 1px solid #e4eaf3;
        border-radius: 11px;
        padding: 0 13px;
        background: #fbfcff;
        color: #23405f;
        font-size: 12px;
        font-family: inherit;
    }

    .mp-page .mp-search {
        width: 220px;
        max-width: 100%;
    }

    .mp-page .mp-filter {
        min-width: 130px;
    }

    .mp-page .mp-table-wrap {
        overflow-x: auto;
        border: 1px solid #e9eef5;
        border-radius: 12px;
    }

    .mp-page .mp-table {
        width: 100%;
        border-collapse: collapse;
        min-width: 650px;
    }

    .mp-page .mp-table th {
        background: #f2f6fb;
        padding: 14px 16px;
        color: #294360;
        text-align: left;
        font-size: 11px;
        font-weight: 750;
    }

    .mp-page .mp-table td {
        padding: 14px 16px;
        border-top: 1px solid #edf1f7;
        color: #536e8e;
        font-size: 12px;
        vertical-align: middle;
    }

    .mp-page .mp-task-name {
        font-weight: 750;
        color: #183552;
    }

    .mp-page .mp-task-sub {
        display: block;
        margin-top: 4px;
        color: #7d90a9;
        font-size: 11px;
    }

    .mp-page .mp-status {
        display: inline-flex;
        align-items: center;
        border-radius: 30px;
        padding: 7px 11px;
        background: #e8edf3;
        color: #526477;
        font-size: 11px;
        font-weight: 750;
        white-space: nowrap;
    }

    .mp-page .mp-status.completed {
        background: #ddf8e6;
        color: #09853b;
    }

    .mp-page .mp-status.submitted {
        background: #e1eeff;
        color: #1765d3;
    }

    .mp-page .mp-status.reassign {
        background: #fff0da;
        color: #ba6907;
    }

    .mp-page .mp-status.assigned {
        background: #e9eef4;
        color: #53647a;
    }

    .mp-page .mp-detail-link {
        display: inline-flex;
        align-items: center;
        padding: 9px 13px;
        background: #eaf3ff;
        color: #1765d3;
        border-radius: 10px;
        text-decoration: none;
        font-size: 11px;
        font-weight: 750;
        white-space: nowrap;
    }

    .mp-page .mp-detail-link:hover {
        background: #dbeaff;
    }

    /* Bottom panels */
    .mp-page .mp-bottom {
        display: grid;
        grid-template-columns: minmax(0, 1.25fr) minmax(0, .85fr);
        gap: 16px;
        align-items: start;
    }

    .mp-page .mp-bottom .mp-section {
        margin-bottom: 0;
    }

    .mp-page .mp-feedback-item {
        background: linear-gradient(110deg, #f5fff9, #f9fdfb);
        border: 1px solid #e0f3e7;
        border-left: 4px solid #20b65a;
        border-radius: 11px;
        padding: 17px;
        margin-bottom: 12px;
    }

    .mp-page .mp-feedback-title {
        font-size: 13px;
        font-weight: 750;
        margin-bottom: 8px;
    }

    .mp-page .mp-feedback-text {
        font-size: 12px;
        color: #637b9a;
        line-height: 1.7;
        margin-bottom: 12px;
        overflow-wrap: anywhere;
    }

    .mp-page .mp-feedback-filter {
        height: 39px;
        border: 1px solid #e4eaf3;
        border-radius: 10px;
        padding: 0 12px;
        background: #fff;
        color: #23405f;
        font-size: 12px;
    }

    .mp-page .mp-completion {
        text-align: center;
        padding: 8px 0 0;
    }

    .mp-page .mp-completion-icon {
        width: 78px;
        height: 78px;
        border-radius: 50%;
        background: #e9f3ff;
        color: #1973e7;
        margin: 0 auto 16px;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 36px;
    }

    .mp-page .mp-completion h3 {
        margin: 0 0 9px;
        font-size: 15px;
        color: #18324f;
    }

    .mp-page .mp-completion p {
        margin: 0 auto 16px;
        max-width: 330px;
        color: #7185a2;
        font-size: 12px;
        line-height: 1.8;
    }

    .mp-page .mp-completion-note {
        padding: 13px;
        border-radius: 10px;
        background: #eaf3ff;
        color: #1765c5;
        font-size: 11px;
        line-height: 1.7;
        text-align: left;
    }

    .mp-page .mp-empty {
        padding: 23px;
        text-align: center;
        font-size: 12px;
        color: #7185a2;
    }

    .mp-page .mp-error {
        color: #b91c1c;
        font-size: 12px;
        display: block;
        margin-bottom: 12px;
    }

    @media (max-width: 1150px) {
        .mp-page .mp-top,
        .mp-page .mp-bottom {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 700px) {
        .mp-page .mp-hero {
            flex-wrap: wrap;
            justify-content: center;
            text-align: center;
        }

        .mp-page .mp-hero-copy p {
            margin: 0 auto;
        }

        .mp-page .mp-hero-decoration {
            display: none;
        }

        .mp-page .mp-section-heading {
            align-items: flex-start;
            flex-wrap: wrap;
        }

        .mp-page .mp-tools {
            width: 100%;
        }

        .mp-page .mp-search {
            flex: 1;
            min-width: 0;
        }
    }

    @media (max-width: 460px) {
        .mp-page .mp-stats {
            grid-template-columns: 1fr;
        }

        .mp-page .mp-header {
            flex-wrap: wrap;
        }

        .mp-page .mp-hero {
            padding: 20px;
        }
    }
    
/* Dashboard entrance animation */
@keyframes mpFadeUp {
    from {
        opacity: 0;
        transform: translateY(22px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.mp-page .mp-hero {
    animation: mpFadeUp .65s ease both;
}

.mp-page .mp-stat {
    animation: mpFadeUp .6s ease both;
}

.mp-page .mp-stat:nth-child(1) { animation-delay: .10s; }
.mp-page .mp-stat:nth-child(2) { animation-delay: .18s; }
.mp-page .mp-stat:nth-child(3) { animation-delay: .26s; }
.mp-page .mp-stat:nth-child(4) { animation-delay: .34s; }

.mp-page .mp-section {
    animation: mpFadeUp .7s ease both;
    animation-delay: .3s;
}

/* Smooth ring movement using a custom property */
@property --progress {
    syntax: "<number>";
    inherits: false;
    initial-value: 0;
}

.mp-page .mp-ring {
    transition: --progress 1.8s cubic-bezier(.22,1,.36,1);
}

@media (prefers-reduced-motion: reduce) {
    .mp-page .mp-hero,
    .mp-page .mp-stat,
    .mp-page .mp-section {
        animation: none !important;
    }

    .mp-page .mp-ring {
        transition: none !important;
    }
}

</style>

<div class="mp-page">

    <!-- Header -->
    <header class="mp-header">
        <div>
            <p class="mp-welcome">Your internship journey</p>
            <h1>My Progress &amp; Evaluation</h1>
            <p class="mp-subtitle">
                Track your internship progress, tasks and supervisor feedback.
            </p>
        </div>

        <span class="mp-overview-pill">
            &#9635; Internship Overview
        </span>
    </header>

    <asp:Label ID="lblMessage"
        runat="server"
        CssClass="mp-error" />

    <!-- Progress and statistics -->
    <div class="mp-top">

        <section class="mp-panel mp-hero">

            <div id="progressRing"
                runat="server"
                class="mp-ring">

                <div class="mp-ring-inner">
                    <div class="mp-ring-value">
                        <asp:Literal ID="litPercentage"
                            runat="server"
                            Text="0%" />
                    </div>

                    <div class="mp-ring-label">
                        Completed
                    </div>
                </div>
            </div>

            <div class="mp-hero-copy">
                <h2>Overall Progress</h2>

                <span class="mp-hero-count">
                    <asp:Literal ID="litProgressDescription"
                        runat="server"
                        Text="0 of 0 tasks completed" />
                </span>

                <p>
                    Your progress increases when a supervisor
                    reviews and approves your submitted work.
                </p>
            </div>

            <div class="mp-hero-decoration"
                aria-hidden="true">&#10004;</div>

        </section>

        <div class="mp-stats">

            <div class="mp-panel mp-stat">
                <span class="mp-stat-icon">&#9776;</span>
                <div class="mp-stat-copy">
                    <div class="mp-stat-label">Total Tasks</div>
                    <span class="mp-stat-number">
                        <asp:Literal ID="litTotal" runat="server" Text="0" />
                    </span>
                    <div class="mp-stat-note">All assigned tasks</div>
                </div>
            </div>

            <div class="mp-panel mp-stat completed">
                <span class="mp-stat-icon">&#10003;</span>
                <div class="mp-stat-copy">
                    <div class="mp-stat-label">Completed</div>
                    <span class="mp-stat-number">
                        <asp:Literal ID="litCompleted" runat="server" Text="0" />
                    </span>
                    <div class="mp-stat-note">Approved tasks</div>
                </div>
            </div>

            <div class="mp-panel mp-stat">
                <span class="mp-stat-icon">&#9716;</span>
                <div class="mp-stat-copy">
                    <div class="mp-stat-label">Awaiting Review</div>
                    <span class="mp-stat-number">
                        <asp:Literal ID="litSubmitted" runat="server" Text="0" />
                    </span>
                    <div class="mp-stat-note">Submitted and under review</div>
                </div>
            </div>

            <div class="mp-panel mp-stat revision">
                <span class="mp-stat-icon">&#8635;</span>
                <div class="mp-stat-copy">
                    <div class="mp-stat-label">Needs Revision</div>
                    <span class="mp-stat-number">
                        <asp:Literal ID="litReassigned" runat="server" Text="0" />
                    </span>
                    <div class="mp-stat-note">Requires your attention</div>
                </div>
            </div>

        </div>
    </div>

    <!-- Task tracking -->
    <section class="mp-panel mp-section">

        <div class="mp-section-heading">
            <div class="mp-section-title">
                <span class="mp-heading-icon">&#9776;</span>
                <div>
                    <h2>Task Tracking</h2>
                    <p>Follow the latest status of your assigned tasks.</p>
                </div>
            </div>

            <div class="mp-tools">
                <input type="search"
                    id="mpTaskSearch"
                    class="mp-search"
                    placeholder="Search tasks..."
                    aria-label="Search tasks" />

                <select id="mpTaskFilter"
                    class="mp-filter"
                    aria-label="Filter tasks">
                    <option value="">All Status</option>
                    <option value="Assigned">Assigned</option>
                    <option value="Submitted">Submitted</option>
                    <option value="Reassign">Reassign</option>
                    <option value="Completed">Completed</option>
                </select>
            </div>
        </div>

        <div class="mp-table-wrap">
            <table class="mp-table">
                <thead>
                    <tr>
                        <th>Task</th>
                        <th>Status</th>
                        <th>Due Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>

                <tbody id="mpTaskBody">
                    <asp:Repeater ID="rptProgressTasks" runat="server">
                        <ItemTemplate>
                            <tr class="mp-task-row"
                                data-status='<%#: GetStatusText(Eval("Status")) %>'>

                                <td>
                                    <span class="mp-task-name">
                                        <%#: Eval("Title") %>
                                    </span>
                                    <span class="mp-task-sub">
                                        Assigned Task
                                    </span>
                                </td>

                                <td>
                                    <span class='mp-status <%# GetStatusClass(Eval("Status")) %>'>
                                        <%#: GetStatusText(Eval("Status")) %>
                                    </span>
                                </td>

                                <td>
                                    <%#: Eval("DueDate") %>
                                </td>

                                <td>
                                    <a href="MyTasks.aspx"
                                        class="mp-detail-link">
                                        View Details &#8594;
                                    </a>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <asp:Panel ID="pnlNoTasks"
            runat="server"
            CssClass="mp-empty"
            Visible="false">
            No assigned tasks yet.
        </asp:Panel>

        <div id="mpNoMatches"
            class="mp-empty"
            style="display:none">
            No tasks match your search or filter.
        </div>

    </section>

    <!-- Feedback and completion -->
    <div class="mp-bottom">

        <section class="mp-panel mp-section">

            <div class="mp-section-heading">
                <div class="mp-section-title">
                    <span class="mp-heading-icon">&#9993;</span>
                    <div>
                        <h2>Supervisor Feedback</h2>
                        <p>Comments and revision requests on your tasks.</p>
                    </div>
                </div>
            </div>

            <asp:Repeater ID="rptFeedback" runat="server">
                <ItemTemplate>
                    <div class="mp-feedback-item">
                        <div class="mp-feedback-title">
                            <%#: Eval("Title") %>
                        </div>

                        <div class="mp-feedback-text">
                            <%#: Eval("Feedback") %>
                        </div>

                        <span class='mp-status <%# GetStatusClass(Eval("Status")) %>'>
                            <%#: GetStatusText(Eval("Status")) %>
                        </span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoFeedback"
                runat="server"
                CssClass="mp-empty"
                Visible="false">
                No supervisor feedback available yet.
            </asp:Panel>

        </section>

        <section class="mp-panel mp-section">

            <div class="mp-section-heading">
                <div class="mp-section-title">
                    <span class="mp-heading-icon">&#9733;</span>
                    <div>
                        <h2>Internship Completion</h2>
                        <p>Official report and certificate.</p>
                    </div>
                </div>
            </div>

            <div class="mp-completion">
                <div class="mp-completion-icon">
                    &#128274;
                </div>

                <h3>Awaiting Coordinator Approval</h3>

                <p>
                    Your official internship completion
                    documents will become available after
                    approval by the University Internship
                    Coordinator.
                </p>

                <div class="mp-completion-note">
                    &#9432; Official documents are not
                    available for download yet.
                </div>
            </div>

        </section>
    </div>

</div>


<script>
(function () {
    var search = document.getElementById("mpTaskSearch");
    var filter = document.getElementById("mpTaskFilter");
    var empty = document.getElementById("mpNoMatches");

    if (!search || !filter) return;

    function applyFilters() {
        var rows = document.querySelectorAll(
            "#mpTaskBody .mp-task-row"
        );

        var query = search.value.trim().toLowerCase();
        var status = filter.value.toLowerCase();
        var visible = 0;

        rows.forEach(function (row) {
            var taskText = row.cells[0].textContent.toLowerCase();

            var taskStatus = (
                row.getAttribute("data-status") || ""
            ).toLowerCase();

            var matchesSearch = taskText.indexOf(query) !== -1;
            var matchesStatus = !status || taskStatus === status;

            var show = matchesSearch && matchesStatus;

            row.style.display = show ? "" : "none";

            if (show) {
                visible++;
            }
        });

        if (empty) {
            empty.style.display =
                rows.length > 0 && visible === 0
                    ? "block"
                    : "none";
        }
    }

    search.addEventListener("input", applyFilters);
    filter.addEventListener("change", applyFilters);

    applyFilters();

})();
</script>




</asp:Content>

<%@ Page Language="C#" MasterPageFile="~/Portal.Master" Inherits="PSUTInternship.Shared.PortalPage" Title="Meetings" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server"><link href="../Academic/ZoomMeetings.css" rel="stylesheet"/></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">

    <select id="studentAccount" hidden aria-label="Signed-in student"></select>
<div class="layout">
        <main class="main">
            <header class="topbar"><strong>Student Portal</strong><span class="user-chip" id="studentChip">● Student</span></header><section class="content">
                <div class="eyebrow">ONLINE MEETINGS</div><h1>My Meeting Invitations</h1><p class="subtitle">View invitations from your academic supervisor, accept meeting invitations and join accepted interviews.</p>
                
                <div class="meeting-stats"><div class="meeting-stat"><span>Total invitations</span><strong id="studentTotal">0</strong></div><div class="meeting-stat"><span>Pending invitations</span><strong id="studentPending">0</strong></div><div class="meeting-stat"><span>Accepted meetings</span><strong id="studentAccepted">0</strong></div></div>
<div class="meeting-panel"><div class="meeting-section-head"><div><h2>Meeting Invitations</h2><p class="meeting-muted">Invitations sent by your academic supervisor.</p></div><button type="button" id="refreshMeetings" class="meeting-secondary-btn">Refresh</button></div><div id="studentInvitations" class="meeting-card-grid"></div></div><div class="meeting-panel"><h2>Accepted Meetings</h2><p class="meeting-muted">Your accepted meetings and available video rooms.</p><div id="studentUpcoming" class="meeting-card-grid"></div></div><p id="studentMessage" role="status" class="form-feedback"></p>
            </section><footer class="footer">University Internship Management System · Student</footer>
        </main>
    </div>
    <script src="../Shared/meetings.js?v=20261023"></script>
    <script src="../Academic/StudentMeetings.js?v=20261023-workspace"></script>

</asp:Content>

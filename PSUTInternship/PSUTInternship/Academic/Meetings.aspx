<%@ Page Language="C#" MasterPageFile="~/Portal.Master" Inherits="PSUTInternship.Shared.PortalPage" Title="Meetings" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server"><link href="../Academic/ZoomMeetings.css" rel="stylesheet"/><style>
body.portal-app .portal-content .academic-meetings{max-width:1240px;margin:auto;color:#19394f}.academic-meetings .am-heading{display:flex;justify-content:space-between;align-items:center;gap:24px;margin-bottom:24px}body.portal-app .portal-content .academic-meetings h1{font-size:27px!important;letter-spacing:-.035em;margin:0 0 8px!important}.academic-meetings .subtitle{font-size:13px!important;font-weight:400!important;color:#607587;line-height:1.7;margin:0!important}
body.portal-app .portal-content .academic-meetings .meeting-stats{display:grid!important;grid-template-columns:repeat(4,minmax(0,1fr))!important;gap:0!important;padding:20px 0!important;background:#fff;border:1px solid #dce6ed;border-radius:12px;margin-bottom:24px}.academic-meetings .meeting-stat{border:0!important;border-right:1px solid #e3ebf0!important;padding:0 24px!important;background:transparent!important;border-radius:0!important;box-shadow:none!important;min-height:0!important}.academic-meetings .meeting-stat:last-child{border:0!important}.academic-meetings .meeting-stat>span{font-size:12px!important;color:#607587}.academic-meetings .meeting-stat strong{font-size:29px!important;font-weight:700!important;color:#003e73!important;margin-top:8px!important}
.academic-meetings .am-panel{background:#fff;border:1px solid #dce6ed;border-radius:12px;padding:22px;margin-bottom:22px}.academic-meetings .am-section-head{display:flex;align-items:center;justify-content:space-between;gap:20px;margin-bottom:18px}.academic-meetings h2{font-size:17px!important;margin:0 0 7px!important}.academic-meetings .meeting-muted{font-size:12px!important;font-weight:400!important;color:#607587;line-height:1.6;margin:0 0 16px!important}.academic-meetings .am-section-head .meeting-muted{margin:0!important}
body.portal-app .portal-content .academic-meetings .meeting-input{border:1px solid #cddce6!important;border-radius:8px!important;background:#fff!important;color:#19394f!important;padding:11px 13px!important;font-size:13px!important;font-weight:400!important;min-height:44px!important;box-shadow:none!important;width:100%;box-sizing:border-box;margin:0!important}.academic-meetings .filter-select{max-width:190px}.academic-meetings .meeting-card-grid{display:grid!important;grid-template-columns:repeat(2,minmax(0,1fr))!important;gap:16px!important;margin-top:18px}.academic-meetings .meeting-card{padding:20px!important;border:1px solid #e0e8ef!important;border-radius:9px!important;background:#fff!important;box-shadow:none!important;transform:none!important}.academic-meetings .meeting-avatar{display:none!important}.academic-meetings .card-top{justify-content:flex-end;margin-bottom:10px}.academic-meetings .meeting-card h3{font-size:16px!important;margin:0 0 6px!important}.academic-meetings .meeting-card-title{font-size:13px!important;color:#607587;margin-bottom:14px}.academic-meetings .meeting-details p,.academic-meetings .meeting-notes,.academic-meetings .waiting-note{font-size:12px!important;font-weight:400!important;line-height:1.7;color:#607587}.academic-meetings .status-badge{font-size:11px!important;border-radius:5px!important;padding:5px 9px!important}.academic-meetings .empty-state{grid-column:1/-1;padding:24px!important;background:#fafcfd!important;border:1px dashed #dce6ed;border-radius:8px;font-size:13px;color:#607587}.academic-meetings .activity-item{display:flex;justify-content:space-between;gap:20px;padding:16px 0!important;border-bottom:1px solid #e5ecf1;background:#fff!important;font-size:12px}.academic-meetings .activity-item small{font-size:11px;color:#607587}
body.portal-app .portal-content :is(.academic-meetings,#invitationDialog) :is(.meeting-primary-btn,.meeting-secondary-btn,.join-button,.cancel-button){min-height:44px!important;padding:11px 16px!important;display:inline-flex;align-items:center;justify-content:center;border-radius:8px!important;background:#003e73!important;color:#fff!important;border:1px solid #003e73!important;font-size:12px!important;font-weight:650!important;box-shadow:none!important;margin:0!important;width:auto!important}body.portal-app .portal-content :is(.academic-meetings,#invitationDialog) :is(.meeting-secondary-btn,.cancel-button){background:#fff!important;color:#526b7d!important;border-color:#cddce6!important}
body.portal-app .portal-content #invitationDialog{box-sizing:border-box;width:min(720px,calc(100vw - 32px));max-height:90dvh;border:0;border-radius:16px;padding:0;color:#19394f;background:#fff;box-shadow:0 24px 80px #09233c44}#invitationDialog::backdrop{background:#0a1e3080}#invitationDialog .am-dialog-head{display:flex;align-items:flex-start;justify-content:space-between;gap:20px;padding:24px;border-bottom:1px solid #e3ebf0}#invitationDialog h2{font-size:22px!important;margin:0 0 8px!important;letter-spacing:-.025em}#invitationDialog .meeting-muted{font-size:12px!important;line-height:1.7;color:#607587;margin:0!important;max-width:500px}body.portal-app .portal-content #invitationDialog .am-close{width:34px!important;min-height:34px!important;flex-shrink:0;padding:0!important;background:#f2f6f8!important;color:#526b7d!important;border:0!important;border-radius:50%!important;font-size:22px!important}#invitationDialog .am-dialog-body{padding:24px}#invitationDialog .meeting-form-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px}#invitationDialog .meeting-field{margin:0 0 18px}#invitationDialog .meeting-form-grid .meeting-field{margin:0}#invitationDialog .am-dialog-body>.meeting-field{margin:18px 0 0}#invitationDialog label{display:block;font-size:12px;font-weight:600;color:#526b7d;margin-bottom:8px}body.portal-app .portal-content #invitationDialog .meeting-input{box-sizing:border-box;width:100%!important;min-width:0;min-height:44px;border:1px solid #cddce6!important;border-radius:8px!important;background:#fff!important;padding:11px 13px!important;font-size:13px!important;font-weight:400!important;box-shadow:none!important}#invitationDialog textarea{resize:vertical;line-height:1.7}#invitationDialog .am-dialog-footer{display:flex;justify-content:flex-end;flex-wrap:wrap;gap:10px;padding:18px 24px;border-top:1px solid #e3ebf0;background:#fafcfd}#invitationDialog .form-feedback{flex-basis:100%;margin:0;font-size:12px}#invitationDialog .form-feedback:empty{display:none}#invitationDialog .error{color:#ac3c3c}#invitationDialog :focus-visible{outline:2px solid #0078b5;outline-offset:3px}
@media(max-width:700px){.academic-meetings .am-heading{align-items:flex-start;flex-direction:column}.academic-meetings .meeting-stats{grid-template-columns:repeat(2,minmax(0,1fr))!important;gap:20px 0!important}.academic-meetings .meeting-stat:nth-child(2){border:0!important}.academic-meetings .meeting-card-grid{grid-template-columns:1fr!important}.academic-meetings .am-section-head{align-items:flex-start;flex-direction:column}.academic-meetings .activity-item{flex-direction:column;gap:5px}#invitationDialog .meeting-form-grid{grid-template-columns:1fr}#invitationDialog .am-dialog-head,#invitationDialog .am-dialog-body{padding:20px}#invitationDialog .am-dialog-footer{padding:16px 20px}.academic-meetings .am-panel{padding:18px}}
</style><style>
body.portal-app .portal-content .academic-meetings .meeting-stat{background:transparent!important;border:0!important;border-right:1px solid #e3ebf0!important;border-radius:0!important;padding:0 24px!important;box-shadow:none!important}body.portal-app .portal-content .academic-meetings .meeting-stat:last-child{border-right:0!important}body.portal-app .portal-content .academic-meetings .meeting-stat strong{font-size:29px!important;font-weight:700!important;color:#003e73!important}body.portal-app .portal-content .academic-meetings .filter-select{width:190px!important;max-width:190px!important;flex:0 0 190px!important}body.portal-app .portal-content #invitationDialog[open]{display:flex!important;flex-direction:column!important;overflow:hidden!important}#invitationDialog .am-dialog-head,#invitationDialog .am-dialog-footer{flex-shrink:0}#invitationDialog .am-dialog-body{overflow-y:auto;min-height:0}body.portal-app .portal-content #invitationDialog .meeting-field label{font-size:12px!important;font-weight:600!important;margin:0 0 8px!important;line-height:1.5!important}body.portal-app .portal-content #invitationDialog .meeting-field{margin-bottom:0!important}@media(max-width:700px){body.portal-app .portal-content .academic-meetings .meeting-stats{grid-template-columns:repeat(2,minmax(0,1fr))!important;gap:18px 0!important}body.portal-app .portal-content .academic-meetings .meeting-stat:nth-child(2){border-right:0!important}}
</style><style>
body.portal-app .portal-content .academic-meetings .meeting-card{display:flex!important;flex-direction:column!important;background:#fff!important;border:1px solid #dce6ed!important;border-radius:10px!important;padding:20px!important;box-shadow:none!important;min-width:0}
body.portal-app .portal-content .academic-meetings .meeting-card .card-top{display:flex!important;justify-content:flex-end!important;margin:0 0 10px!important;padding:0!important}
body.portal-app .portal-content .academic-meetings .meeting-card .meeting-details{display:grid!important;gap:8px!important;background:#f7f9fb!important;border:1px solid #e7edf2!important;border-radius:7px!important;padding:14px!important;margin:16px 0!important}
body.portal-app .portal-content .academic-meetings .meeting-card .meeting-details p{display:flex!important;align-items:center!important;gap:8px!important;padding:0!important;margin:0!important;font-size:12px!important;font-weight:400!important;line-height:1.6!important;color:#607587!important}
body.portal-app .portal-content .academic-meetings .meeting-card .card-actions{display:flex!important;align-items:center!important;flex-wrap:wrap!important;gap:10px!important;padding:16px 0 0!important;margin-top:auto!important;border-top:1px solid #e5ecf1!important;width:100%!important}
body.portal-app .portal-content .academic-meetings .meeting-card .card-actions :is(.join-button,.cancel-button){display:inline-flex!important;align-items:center!important;justify-content:center!important;flex:0 1 auto!important;width:auto!important;height:42px!important;min-height:42px!important;padding:0 14px!important;margin:0!important;line-height:1!important;font-size:12px!important;border-radius:7px!important;box-sizing:border-box!important;text-decoration:none!important;white-space:nowrap}
body.portal-app .portal-content .academic-meetings .meeting-card .card-actions i{display:none!important}
body.portal-app .portal-content .academic-meetings .meeting-card .waiting-note{flex-basis:100%!important;background:transparent!important;border:0!important;padding:0!important;margin:0 0 2px!important;text-align:left!important;color:#8a651c!important;font-size:11px!important}
body.portal-app .portal-content #invitationDialog .am-close{display:inline-flex!important;align-items:center!important;justify-content:center!important;width:36px!important;height:36px!important;min-height:36px!important;border:1px solid #dce6ed!important;border-radius:8px!important;background:#fff!important;color:#526b7d!important;padding:0!important;line-height:1!important}
body.portal-app .portal-content #invitationDialog .am-close:hover{background:#f2f6f9!important;border-color:#a5bdcd!important}body.portal-app .portal-content #invitationDialog .am-close svg{display:block;width:18px;height:18px;flex-shrink:0}
@media(max-width:500px){body.portal-app .portal-content .academic-meetings .meeting-card .card-actions :is(.join-button,.cancel-button){flex:1 1 0!important;padding:0 8px!important;font-size:11px!important}}
</style><style>
body.portal-app .portal-content .academic-meetings .meeting-card-grid{grid-template-columns:repeat(3,minmax(0,1fr))!important;gap:14px!important}body.portal-app .portal-content .academic-meetings .meeting-card{padding:16px!important;border-radius:9px!important}body.portal-app .portal-content .academic-meetings .meeting-card .card-top{margin-bottom:5px!important}body.portal-app .portal-content .academic-meetings .meeting-card h3{font-size:14px!important}body.portal-app .portal-content .academic-meetings .meeting-card .meeting-card-title{margin:0!important;font-size:12px!important}body.portal-app .portal-content .academic-meetings .meeting-card .meeting-details{gap:5px!important;padding:10px!important;margin:12px 0!important}body.portal-app .portal-content .academic-meetings .meeting-card .card-actions{padding-top:12px!important;gap:8px!important}body.portal-app .portal-content .academic-meetings .meeting-card .card-actions :is(.join-button,.cancel-button){height:38px!important;min-height:38px!important;padding:0 10px!important;font-size:11px!important}@media(max-width:1150px){body.portal-app .portal-content .academic-meetings .meeting-card-grid{grid-template-columns:repeat(2,minmax(0,1fr))!important}}@media(max-width:650px){body.portal-app .portal-content .academic-meetings .meeting-card-grid{grid-template-columns:1fr!important}}
</style></asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">


    <div class="academic-meetings">

        <!-- SIDEBAR -->
        

        <!-- MAIN -->
        <div class="am-main">

<span id="supervisorChip" hidden></span>

            <section class="am-content">

                <header class="am-heading"><div>
                <h1>Meetings</h1>
                <p class="subtitle">
                    Create meeting invitations, manage student
                    responses and join online interviews.
                </p>

</div><button type="button" id="openInvitation" class="meeting-primary-btn">+ Send meeting invitation</button></header><p id="meetingPageMessage" role="status" hidden></p>                <!-- STATISTICS -->
                <div class="meeting-stats">
                    <div class="meeting-stat">
                        <span>Total Invitations</span>
                        <strong id="totalCount">0</strong>
                    </div>

                    <div class="meeting-stat">
                        <span>Pending</span>
                        <strong id="pendingCount">0</strong>
                    </div>

                    <div class="meeting-stat">
                        <span>Accepted</span>
                        <strong id="acceptedCount">0</strong>
                    </div>

                    <div class="meeting-stat">
                        <span>Rejected</span>
                        <strong id="rejectedCount">0</strong>
                    </div>
                </div>

                <!-- INVITATIONS -->
                <div class="am-panel">

                    <div class="am-section-head">
                        <div>
                            <h2>Meeting Invitations</h2>
                            <p class="meeting-muted">
                                Track student responses and manage invitations.
                            </p>
                        </div>

                        <select id="statusFilter"
                                class="meeting-input filter-select">
                            <option value="all">Pending invitations</option>
                            <option value="Pending">Pending</option>
                            <option value="Accepted">Accepted</option>

                            <option value="Cancelled">Cancelled</option>
                        </select>
                    </div>

                    <div id="invitationsList"
                         class="meeting-card-grid"></div>

                </div>

                <!-- UPCOMING MEETINGS -->
                <div class="am-panel">

                    <h2>Upcoming Meetings</h2>

                    <p class="meeting-muted">
                        Accepted meetings with available video rooms.
                    </p>

                    <div id="upcomingList"
                         class="meeting-card-grid"></div>

                </div>

                <!-- RECENT ACTIVITY -->
                <div class="am-panel">

                    <h2>Recent Activity</h2>

                    <div id="activityList"></div>

                </div>

            </section>



        </div>

    </div>


                <!-- CREATE INVITATION -->
                <dialog id="invitationDialog" aria-labelledby="invitationTitle"><div class="am-dialog-head"><div>

                    <h2 id="invitationTitle">New meeting invitation</h2>

                    <p class="meeting-muted">
                        Select a student and schedule an academic
                        interview. The student must accept before joining.
                    </p>

                    

</div><button type="button" class="am-close" data-close-invitation aria-label="Close invitation"><svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="m6 6 12 12M6 18 18 6"/></svg></button></div><div class="am-dialog-body">                        <div class="meeting-form-grid">

                            <div class="meeting-field">
                                <label for="studentSelect">
                                    Select Student *
                                </label>

                                <select id="studentSelect"
                                        class="meeting-input"
                                        required>
                                    <option value="">Loading assigned students...</option>
                                </select>
                            </div>

                            <div class="meeting-field">
                                <label for="meetingTitle">
                                    Meeting Title *
                                </label>

                                <input type="text"
                                       id="meetingTitle"
                                       class="meeting-input"
                                       placeholder="Internship Progress Review"
                                       maxlength="120"
                                       required>
                            </div>

                            <div class="meeting-field">
                                <label for="meetingDate">
                                    Meeting Date *
                                </label>

                                <input type="date"
                                       id="meetingDate"
                                       class="meeting-input"
                                       required>
                            </div>

                            <div class="meeting-field">
                                <label for="meetingTime">
                                    Meeting Time *
                                </label>

                                <input type="time"
                                       id="meetingTime"
                                       class="meeting-input"
                                       required>
                            </div>

                            <div class="meeting-field">
                                <label for="meetingDuration">
                                    Duration *
                                </label>

                                <select id="meetingDuration"
                                        class="meeting-input"
                                        required>
                                    <option value="30">30 minutes</option>
                                    <option value="45">45 minutes</option>
                                    <option value="60">60 minutes</option>
                                </select>
                            </div>

                            <div class="meeting-field">
                                <label for="meetingPurpose">
                                    Meeting Purpose *
                                </label>

                                <input type="text"
                                       id="meetingPurpose"
                                       class="meeting-input"
                                       placeholder="Discuss student progress"
                                       maxlength="200"
                                       required>
                            </div>

                        </div>

                        <div class="meeting-field">
                            <label for="meetingNotes">
                                Additional Notes (optional)
                            </label>

                            <textarea id="meetingNotes"
                                      class="meeting-input"
                                      rows="3"
                                      maxlength="1000"
                                      placeholder="Additional meeting details..."></textarea>
                        </div>

                        </div><div class="am-dialog-footer"><button type="button" class="meeting-secondary-btn" data-close-invitation>Cancel</button><button type="submit"
                                class="meeting-primary-btn">
                            Send Meeting Invitation
                        </button>

                        <p id="formMessage"
                           class="form-feedback"
                           role="status"></p>
                    

                </div></dialog>

    <script src="../Shared/meetings.js?v=20261023-review28"></script>
    <script src="../Academic/ZoomMeetings.js?v=20261024-dialog1"></script>


</asp:Content>

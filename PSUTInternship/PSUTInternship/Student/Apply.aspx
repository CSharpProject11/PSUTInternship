<%@ Page Title="Apply for an opportunity" MasterPageFile="~/Portal.Master" Language="C#" Async="true"
    AutoEventWireup="true"
    CodeBehind="Apply.aspx.cs"
    Inherits="PSUTInternship.Student.Apply" %>
<%@ Register Src="~/Shared/StudentNav.ascx" TagPrefix="psut" TagName="StudentNav" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="../Content/bootstrap.min.css" rel="stylesheet" />
    <link href="../Content/student-workspace.css?v=20261023-opps2" rel="stylesheet" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<div class="student-shell">

        <main id="student-main" class="student-main sd-apply-main" tabindex="-1">
        <a class="sd-back" href="Opportunities.aspx">← Back to opportunities</a>
        <div class="student-heading"><div><h1>Opportunity details.</h1><p>Review the placement, then submit your application.</p></div></div>

        <asp:Label ID="MessageLabel" runat="server" CssClass="text-danger" role="status" />

        <asp:Panel ID="DetailsPanel"
            runat="server" Visible="false">

            <asp:FormView ID="OpportunityDetails"
                runat="server" CssClass="w-100">
                <ItemTemplate>
                    <article class="card sd-card sd-apply-card">
                    <asp:Image runat="server"
                        CssClass="img-fluid w-100"
                        ImageUrl='<%# ApplicationImage(Eval("ImageUrl")) %>'
                        AlternateText='<%# Eval("Title") %>'
                         />
                    <div class="card-body p-3 p-md-4">
                    <h2 class="h2 text-break mb-3"><%#: Eval("Title") %></h2>
                    <span class='<%# "sd-opening-status " + (Convert.ToBoolean(Eval("IsAccepting")) ? "is-open" : "is-closed") %>'><%#: Eval("StatusLabel") %></span>

                    <dl class="row g-3 border-bottom pb-4 my-3">
                        <div class="col-12 col-md-6"><dt class="text-muted small">Company</dt><dd class="text-break"><%#: Eval("CompanyName") %></dd></div>
                        <div class="col-12 col-md-6"><dt class="text-muted small">Created at</dt><dd class="text-break"><%#: FormatCreatedDate(Eval("CreatedAt")) %></dd></div>
                        <div class="col-12 col-md-6"><dt class="text-muted small">Location</dt><dd class="text-break"><%#: Eval("LocationDisplay") %></dd></div>
                        <div class="col-12 col-md-6"><dt class="text-muted small">Work type</dt><dd class="text-break"><%#: Eval("WorkModeDisplay") %></dd></div>
                        <div class="col-12 col-md-6"><dt class="text-muted small">Duration</dt><dd class="text-break"><%#: Eval("DurationDisplay") %></dd></div>
                        <div class="col-12 col-md-6"><dt class="text-muted small">Application deadline</dt><dd class="text-break"><%#: Convert.ToDateTime(Eval("DeadLine")) == DateTime.MinValue ? "Not specified" : string.Format("{0:dd MMM yyyy}", Eval("DeadLine")) %></dd></div>
                    </dl>

                    <h2 class="h5 mt-4 mb-2">About this opportunity</h2>
                    <p class="text-break"><%#: Eval("Description") %></p>

                    <h2 class="h5 mt-4 mb-2">Requirements</h2>
                    <p class="text-break"><%#: Eval("Requirements") %></p>

                    <div class="mt-4">
                        <asp:Button ID="OpenApplication" runat="server" Text='<%# CanApply ? "Apply for this opportunity" : "Applications unavailable" %>' CssClass="btn btn-primary" Enabled='<%# CanApply %>' OnClientClick="new bootstrap.Modal(document.getElementById('applicationModal')).show(); return false;" CausesValidation="false" />
<p class="mt-3" role="status"><%#: ApplicationAvailability %></p>
                    </div>
                    </div>
                    </article>
                </ItemTemplate>
            </asp:FormView>

        </asp:Panel>
        </main>
    </div>
        <div class="modal fade" id="applicationModal" tabindex="-1" aria-labelledby="applicationModalLabel" aria-describedby="applicationNotice" aria-hidden="true">
            <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="modal-header">
                        <h2 class="modal-title fs-5" id="applicationModalLabel">Field Training Application</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p class="text-muted">Your identity and program information is retrieved from your profile and cannot be edited here. Complete the remaining application details. All fields are required unless marked optional.</p>
                        <fieldset class="mb-4"><legend class="h5 border-bottom pb-2 mb-3">General Information</legend><div class="row g-3"><div class="col-12 col-md-6"><label class="form-label" for="university">University</label><input class="form-control" id="university" name="university" readonly="readonly" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="faculty">Faculty</label><input class="form-control" id="faculty" name="faculty" readonly="readonly" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="department">Department</label><input class="form-control" id="department" name="department" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="program">Program</label><input class="form-control" id="program" name="program" readonly="readonly" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="semester">Semester</label><input class="form-control" id="semester" name="semester" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="academicYear">Academic Year</label><input class="form-control" id="academicYear" name="academicYear" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="applicationDate">Application Date</label><input class="form-control" id="applicationDate" name="applicationDate" type="date" required="required" /></div>
</div></fieldset>
<fieldset class="mb-4"><legend class="h5 border-bottom pb-2 mb-3">Student Information</legend><div class="row g-3">
<div class="col-12 col-md-6"><label class="form-label" for="studentName">Student Name</label><input class="form-control" id="studentName" name="studentName" readonly="readonly" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="universityId">University ID</label><input class="form-control" id="universityId" name="universityId" readonly="readonly" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="completedCreditHours">Completed Credit Hours</label><input class="form-control" id="completedCreditHours" name="completedCreditHours" type="number" required="required" min="0" step="1" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="studentPhone">Phone Number</label><input class="form-control" id="studentPhone" name="studentPhone" type="tel" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="studentEmail">Email Address</label><input class="form-control" id="studentEmail" name="studentEmail" readonly="readonly" type="email" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="alternativePhone">Alternative Phone Number (optional)</label><input class="form-control" id="alternativePhone" name="alternativePhone" type="tel" /></div>
</div></fieldset>
                        <div class="mt-4">
                            <label class="form-label" for="applicationReason">Why do you want to apply to this company?</label>
                            <textarea class="form-control" id="applicationReason" name="applicationReason" rows="4" required="required" aria-describedby="applicationReasonHelp"></textarea>
                            <div class="form-text" id="applicationReasonHelp">Explain your interest in the company and what you hope to learn during your training.</div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <p class="text-muted small w-100 mb-1" id="applicationNotice">Your application will be submitted for review with a Pending status.</p>
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" runat="server" onserverclick="SubmitApplication_Click" class="btn btn-primary">Submit Application</button>
                    </div>
                </div>
            </div>
        </div>

    <script src="../Scripts/bootstrap.bundle.min.js"></script>
</asp:Content>

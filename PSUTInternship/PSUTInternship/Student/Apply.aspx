<%@ Page Language="C#" Async="true"
    AutoEventWireup="true"
    CodeBehind="Apply.aspx.cs"
    Inherits="PSUTInternship.Student.Apply" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Apply for an opportunity</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../Content/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <main class="container py-4">
        <a class="btn btn-outline-primary mb-4" href="Opportunities.aspx">Back to opportunities</a>

        <asp:Label ID="MessageLabel" runat="server" CssClass="text-danger" role="status" />

        <asp:Panel ID="DetailsPanel"
            runat="server" Visible="false">

            <asp:FormView ID="OpportunityDetails"
                runat="server" CssClass="w-100">
                <ItemTemplate>
                    <article class="card overflow-hidden">
                    <asp:Image runat="server"
                        CssClass="img-fluid w-100"
                        ImageUrl='<%# Eval("ImageUrl") %>'
                        AlternateText='<%# Eval("Title") %>'
                        Visible='<%# !string.IsNullOrWhiteSpace(Convert.ToString(Eval("ImageUrl"))) %>' />
                    <div class="card-body p-3 p-md-4">
                    <h1 class="h2 text-break mb-3"><%#: Eval("Title") %></h1>
                    <span class="badge bg-secondary"><%#: Convert.ToBoolean(Eval("Status")) ? "Open" : "Closed" %></span>

                    <dl class="row g-3 border-bottom pb-4 my-3">
                        <div class="col-12 col-md-6"><dt class="text-muted small">Company ID</dt><dd class="text-break"><%#: Eval("CompanyId") %></dd></div>
                        <div class="col-12 col-md-6"><dt class="text-muted small">Created at</dt><dd class="text-break"><%#: Eval("CreatedAt") %></dd></div>
                        <div class="col-12 col-md-6"><dt class="text-muted small">Location</dt><dd class="text-break"><%#: Eval("Location") %></dd></div>
                        <div class="col-12 col-md-6"><dt class="text-muted small">Work mode</dt><dd class="text-break"><%#: Eval("WorkMode") %></dd></div>
                        <div class="col-12 col-md-6"><dt class="text-muted small">Duration</dt><dd class="text-break"><%#: Eval("Duration") %> Months</dd></div>
                        <div class="col-12 col-md-6"><dt class="text-muted small">Application deadline</dt><dd class="text-break"><%#: Convert.ToDateTime(Eval("DeadLine")) == DateTime.MinValue ? "Not specified" : string.Format("{0:dd MMM yyyy}", Eval("DeadLine")) %></dd></div>
                    </dl>

                    <h2 class="h5 mt-4 mb-2">About this opportunity</h2>
                    <p class="text-break"><%#: Eval("Description") %></p>

                    <h2 class="h5 mt-4 mb-2">Requirements</h2>
                    <p class="text-break"><%#: Eval("Requirements") %></p>

                    <div class="mt-4">
                        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#applicationModal">Apply for this opportunity</button>
                    </div>
                    </div>
                    </article>
                </ItemTemplate>
            </asp:FormView>

        </asp:Panel>
        </main>
        <div class="modal fade" id="applicationModal" tabindex="-1" aria-labelledby="applicationModalLabel" aria-describedby="applicationNotice" aria-hidden="true">
            <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="modal-header">
                        <h2 class="modal-title fs-5" id="applicationModalLabel">Field Training Application</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p class="text-muted">Enter your academic, student, and training organization details. All fields are required unless marked optional.</p>
                        <fieldset class="mb-4"><legend class="h5 border-bottom pb-2 mb-3">General Information</legend><div class="row g-3">
<div class="col-12 col-md-6"><label class="form-label" for="faculty">Faculty</label><input class="form-control" id="faculty" name="faculty" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="department">Department</label><input class="form-control" id="department" name="department" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="program">Program</label><input class="form-control" id="program" name="program" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="semester">Semester</label><input class="form-control" id="semester" name="semester" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="academicYear">Academic Year</label><input class="form-control" id="academicYear" name="academicYear" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="applicationDate">Application Date</label><input class="form-control" id="applicationDate" name="applicationDate" type="date" required="required" /></div>
</div></fieldset>
<fieldset class="mb-4"><legend class="h5 border-bottom pb-2 mb-3">Student Information</legend><div class="row g-3">
<div class="col-12 col-md-6"><label class="form-label" for="studentName">Student Name</label><input class="form-control" id="studentName" name="studentName" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="universityId">University ID</label><input class="form-control" id="universityId" name="universityId" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="completedCreditHours">Completed Credit Hours</label><input class="form-control" id="completedCreditHours" name="completedCreditHours" type="number" required="required" min="0" step="1" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="studentPhone">Phone Number</label><input class="form-control" id="studentPhone" name="studentPhone" type="tel" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="studentEmail">Email Address</label><input class="form-control" id="studentEmail" name="studentEmail" type="email" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="alternativePhone">Alternative Phone Number (optional)</label><input class="form-control" id="alternativePhone" name="alternativePhone" type="tel" /></div>
</div></fieldset>
<fieldset class="mb-4"><legend class="h5 border-bottom pb-2 mb-3">Training Organization Information</legend><div class="row g-3">
<div class="col-12 col-md-6"><label class="form-label" for="organizationName">Organization Name</label><input class="form-control" id="organizationName" name="organizationName" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="organizationPhone">Phone Number</label><input class="form-control" id="organizationPhone" name="organizationPhone" type="tel" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="mailingAddress">Mailing Address</label><input class="form-control" id="mailingAddress" name="mailingAddress" type="text" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="organizationEmail">Email Address</label><input class="form-control" id="organizationEmail" name="organizationEmail" type="email" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="organizationWebsite">Website (optional)</label><input class="form-control" id="organizationWebsite" name="organizationWebsite" type="url" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="trainingAddress">Training Location Address</label><input class="form-control" id="trainingAddress" name="trainingAddress" type="text" required="required" /></div>
</div></fieldset>
<fieldset class="mb-4"><legend class="h5 border-bottom pb-2 mb-3">Training Period</legend><div class="row g-3">
<div class="col-12 col-md-6"><label class="form-label" for="trainingStartDate">Training Start Date</label><input class="form-control" id="trainingStartDate" name="trainingStartDate" type="date" required="required" /></div>
<div class="col-12 col-md-6"><label class="form-label" for="trainingEndDate">Training End Date</label><input class="form-control" id="trainingEndDate" name="trainingEndDate" type="date" required="required" /></div>
</div></fieldset>
                        <fieldset class="mb-0">
                            <legend class="h5 border-bottom pb-2 mb-3">Training Field</legend>
                            <label class="form-label" for="trainingField">Field of Training</label>
                            <textarea class="form-control" id="trainingField" name="trainingField" rows="4" required="required"></textarea>
                        </fieldset>
                        <div class="mt-4">
                            <label class="form-label" for="applicationReason">Why do you want to apply to this company?</label>
                            <textarea class="form-control" id="applicationReason" name="applicationReason" rows="4" required="required" aria-describedby="applicationReasonHelp"></textarea>
                            <div class="form-text" id="applicationReasonHelp">Explain your interest in the company and what you hope to learn during your training.</div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <p class="text-muted small w-100 mb-1" id="applicationNotice">Submission is not available yet. This form is not connected to application storage.</p>
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" disabled="disabled">Submit Application</button>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script src="../Scripts/bootstrap.bundle.min.js"></script>
</body>
</html>



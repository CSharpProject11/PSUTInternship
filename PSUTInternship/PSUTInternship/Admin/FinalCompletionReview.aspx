<%@ Page Title="Final Completion Review | UIMS" MasterPageFile="~/Portal.Master" Language="C#" Async="true" AutoEventWireup="true"
    CodeBehind="FinalCompletionReview.aspx.cs"
    Inherits="FinalCompletionReview" %>
<asp:Content ID="PageHead" ContentPlaceHolderID="PortalHead" runat="server">
<link href="Coordinator.css?v=10" rel="stylesheet" />
    <link href="FinalCompletionReview.css?v=11" rel="stylesheet" />
</asp:Content>
<asp:Content ID="PageContent" ContentPlaceHolderID="PortalContent" runat="server">
<input type="hidden" name="csrfToken" value="<%= H(CsrfToken) %>" />

<div class="layout">

    <!-- Shared Sidebar -->


    <div class="workspace">
        <header class="topbar">
            <span>University Internship Management System</span>
            <span class="avatar">CO</span>
        </header>

        <main>
            <div class="heading">
                <h1>Final Completion Review</h1>
                <p>
                    Review company and academic evaluations, verify training
                    requirements, and prepare internship certificates.
                </p>
            </div>

            <% if (!string.IsNullOrEmpty(Notice)) { %><p role="status"><%= H(Notice) %></p><% } %>
<% if (!string.IsNullOrEmpty(FirebaseError)) { %><p role="alert"><%= H(FirebaseError) %></p><% } %>
<div class="stats">
                <div class="stat">
                    <span class="muted">Total Students</span>
                    <strong><%= Total %></strong>
                </div>
                <div class="stat">
                    <span class="muted">Eligible for Certificate</span>
                    <strong><%= EligibleCount %></strong>
                </div>
                <div class="stat">
                    <span class="muted">Pending Requirements</span>
                    <strong><%= PendingCount %></strong>
                </div>
            </div>

            <section class="card">
                <div class="fcr-card-heading">
                    <div>
                        <h2>Student Final Evaluations</h2>
                        <p>
                            Both the company supervisor and academic supervisor
                            must submit a passing final evaluation.
                        </p>
                    </div>
                </div>

                <div class="tools">
                    <div class="field">
                        <label for="search">Search</label>
                        <input id="search"
                               name="search"
                               type="text"
                               value="<%= H(Search) %>"
                               placeholder="Student, university ID or company" />
                    </div>

                    <div class="field">
                        <label for="filter">Evaluation Filter</label>
                        <select id="filter" name="filter">
                            <option value="All" <%= Selected("All") %>>All Students</option>
                            <option value="Pass" <%= Selected("Pass") %>>Both Pass</option>
                            <option value="Failed" <%= Selected("Failed") %>>Failed</option>
                            <option value="Pending" <%= Selected("Pending") %>>Pending</option>
                        </select>
                    </div>

                    <button type="submit" class="btn">Filter</button>
                </div>

                <div class="tablewrap">
                    <table class="fcr-table">
                        <thead>
                            <tr>
                                <th>Student</th>
                                <th>Company</th>
                                <th>Company Evaluation</th>
                                <th>Academic Evaluation</th>
                                <th>Training Hours</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%= Rows() %>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>

</div>

<!-- REVIEW POPUP -->
<% if (SelectedStudent != null && Mode == "review") { %>

<div class="fcr-overlay open"
     role="dialog"
     aria-modal="true"
     aria-labelledby="reviewTitle">

    <div class="fcr-dialog">

        <div class="fcr-dialog-header">
            <div>
                <div class="fcr-eyebrow">INTERNSHIP COMPLETION</div>
                <h2 id="reviewTitle">Final Internship Review</h2>
                <p>
                    Review the training record and the evaluations
                    submitted by both supervisors.
                </p>
            </div>

            <a class="fcr-close"
               href="FinalCompletionReview.aspx"
               aria-label="Close">×</a>
        </div>

        <div class="fcr-dialog-body">

            <!-- Student Identity -->
            <div class="fcr-student-banner">
                <div class="fcr-student-avatar">
                    <%= H(Initials(SelectedStudent.Name)) %>
                </div>

                <div class="fcr-student-identity">
                    <h3><%= H(SelectedStudent.Name) %></h3>
                    <p>
                        Student ID: <%= H(SelectedStudent.StudentId) %>
                    </p>
                </div>

                <span class="fcr-small-label">Internship Record</span>
            </div>

            <!-- Internship Data -->
            <div class="fcr-section-heading">
                <div>
                    <h3>Internship Information</h3>
                    <p>Verified student and placement information</p>
                </div>
            </div>

            <div class="fcr-info-grid">
                <div class="fcr-info-field">
                    <span>Student Name</span>
                    <strong><%= H(SelectedStudent.Name) %></strong>
                </div>

                <div class="fcr-info-field">
                    <span>University</span>
                    <strong><%= H(SelectedStudent.University) %></strong>
                </div>

                <div class="fcr-info-field">
                    <span>Major</span>
                    <strong><%= H(SelectedStudent.Major) %></strong>
                </div>

                <div class="fcr-info-field">
                    <span>Training Company</span>
                    <strong><%= H(SelectedStudent.Company) %></strong>
                </div>

                <div class="fcr-info-field">
                    <span>Training Field</span>
                    <strong><%= H(SelectedStudent.TrainingField) %></strong>
                </div>

                <div class="fcr-info-field">
                    <span>Training Period</span>
                    <strong>
                        <%= H(SelectedStudent.StartDate) %>
                        —
                        <%= H(SelectedStudent.EndDate) %>
                    </strong>
                </div>

                <div class="fcr-info-field">
                    <span>Company Supervisor</span>
                    <strong><%= H(SelectedStudent.CompanySupervisor) %></strong>
                </div>

                <div class="fcr-info-field">
                    <span>Academic Supervisor</span>
                    <strong><%= H(SelectedStudent.AcademicSupervisor) %></strong>
                </div>
            </div>

            <!-- Hours -->
            <div class="fcr-hours-card">
                <div class="fcr-hours-head">
                    <div>
                        <span>Approved Training Hours</span>
                        <strong>
                            <%= SelectedStudent.CompletedHours %>
                            / <%= SelectedStudent.RequiredHours %> Hours
                        </strong>
                    </div>
                    <strong><%= Progress(SelectedStudent) %>%</strong>
                </div>

                <div class="fcr-hours-track">
                    <div class="fcr-hours-fill"
                         style="width:<%= Progress(SelectedStudent) %>%">
                    </div>
                </div>
            </div>

            <!-- Evaluation Details -->
            <div class="fcr-section-heading">
                <div>
                    <h3>Supervisor Final Evaluations</h3>
                    <p>Submitted by the responsible supervisors</p>
                </div>
            </div>

            <div class="fcr-evaluation-grid">

                <!-- Company -->
                <div class="fcr-evaluation-card">
                    <div class="fcr-evaluation-header">
                        <div>
                            <span class="fcr-evaluation-type">COMPANY</span>
                            <h4>Company Evaluation</h4>
                            <p><%= H(SelectedStudent.CompanySupervisor) %></p>
                        </div>
                        <%= Badge(SelectedStudent.CompanyEvaluation) %>
                    </div>

                    <div class="fcr-evaluation-criteria">
                        <div>
                            <span>Technical Performance</span>
                            <strong><%= H(SelectedStudent.TechnicalPerformance) %></strong>
                        </div>
                        <div>
                            <span>Work Commitment</span>
                            <strong><%= H(SelectedStudent.WorkCommitment) %></strong>
                        </div>
                        <div>
                            <span>Professional Conduct</span>
                            <strong><%= H(SelectedStudent.ProfessionalConduct) %></strong>
                        </div>
                        <div>
                            <span>Assigned Tasks</span>
                            <strong><%= H(SelectedStudent.TaskPerformance) %></strong>
                        </div>
                    </div>

                    <div class="fcr-feedback">
                        <span>Supervisor Feedback</span>
                        <p><%= H(SelectedStudent.CompanyFeedback) %></p>
                    </div>
                </div>

                <!-- Academic -->
                <div class="fcr-evaluation-card">
                    <div class="fcr-evaluation-header">
                        <div>
                            <span class="fcr-evaluation-type">ACADEMIC</span>
                            <h4>Academic Evaluation</h4>
                            <p><%= H(SelectedStudent.AcademicSupervisor) %></p>
                        </div>
                        <%= Badge(SelectedStudent.AcademicResult) %>
                    </div>

                    <div class="fcr-feedback">
                        <span>Academic Supervisor Feedback</span>
                        <p><%= H(SelectedStudent.AcademicFeedback) %></p>
                    </div>
                </div>

            </div>

            <!-- University Verification -->
            <div class="fcr-section-heading">
                <div>
                    <h3>University Requirements</h3>
                    <p>Completion conditions checked by the coordinator</p>
                </div>
            </div>

            <div class="tablewrap fcr-requirements-table"><table><thead><tr><th scope="col">Completion requirement</th><th scope="col">Result</th></tr></thead><tbody>
<tr><th scope="row">Required training hours completed</th><td><%= RequirementBadge(SelectedStudent.RequiredHours > 0 && SelectedStudent.CompletedHours >= SelectedStudent.RequiredHours) %></td></tr>
<tr><th scope="row">Company final evaluation passed</th><td><%= RequirementBadge(SelectedStudent.CompanyEvaluation == "Pass") %></td></tr>
<tr><th scope="row">Academic final evaluation passed</th><td><%= RequirementBadge(SelectedStudent.AcademicEvaluation == "Pass") %></td></tr>
<tr><th scope="row">University documents and requirements verified</th><td><%= RequirementBadge(SelectedStudent.RequirementsMet) %></td></tr>
</tbody></table></div>

            <% if (HasFailedEvaluation(SelectedStudent)) { %>
                <div class="fcr-alert fcr-alert-danger">
                    <strong>Failed</strong>
                    At least one supervisor submitted a Not Pass evaluation.
                    The student is not eligible for a completion certificate.
                </div>
            <% } else if (!CanCreateCertificate(SelectedStudent)) { %>
                <div class="fcr-alert fcr-alert-warning">
                    <%= SelectedStudent.ReadyForApproval ? "All checks passed. Select Approve &amp; Create Certificate to approve completion and generate the official certificate." : "Passing evaluations are only part of completion. Approved training hours, reviewed tasks, and a submitted academic review with a Pass recommendation are also required." %>
                </div>
            <% } %>

        </div>

        <div class="fcr-dialog-footer">
            <a class="btn secondary" href="FinalCompletionReview.aspx">
                Close
            </a>

            <% if (!SelectedStudent.Approved && SelectedStudent.ReadyForApproval) { %><button type="submit" class="btn" name="approveCompletion" value="<%= H(SelectedStudent.ReviewId) %>">Approve &amp; Create Certificate</button><% } %>
<% if (CanCreateCertificate(SelectedStudent)) { %>
                <a class="btn green"
                   href="<%= H(PopupUrl(SelectedStudent.Id, "certificate")) %>">
                    Preview Certificate
                </a>
            <% } %>
        </div>

    </div>
</div>

<% } %>

<!-- CERTIFICATE FORM AND PREVIEW POPUP -->
<% if (SelectedStudent != null &&
       CanCreateCertificate(SelectedStudent) &&
       (Mode == "certificate" || Mode == "preview")) { %>

<div class="fcr-overlay open"
     role="dialog"
     aria-modal="true"
     aria-labelledby="certificateTitle">

    <div class="fcr-dialog fcr-certificate-dialog">

        <div class="fcr-dialog-header">
            <div>
                <div class="fcr-eyebrow">OFFICIAL CERTIFICATE</div>
                <h2 id="certificateTitle">
                    <%= Mode == "preview"
                        ? "Certificate Preview"
                        : "Create Internship Certificate" %>
                </h2>
                <p>Certificate details are populated from the student's internship record.</p>
            </div>

            <a class="fcr-close"
               href="FinalCompletionReview.aspx"
               aria-label="Close">×</a>
        </div>

        <div class="fcr-dialog-body">

            <% if (Mode == "certificate") { %>

                <div class="fcr-form-info">
                    Student information is automatically filled and cannot
                    be changed here. The coordinator can review the
                    certificate before final issuance.
                </div>

                <div class="fcr-certificate-form">
                    <div>
                        <label>Student Name</label>
                        <input value="<%= H(SelectedStudent.Name) %>" readonly />
                    </div>

                    <div>
                        <label>University ID</label>
                        <input value="<%= H(SelectedStudent.StudentId) %>" readonly />
                    </div>

                    <div>
                        <label>University</label>
                        <input value="<%= H(SelectedStudent.University) %>" readonly />
                    </div>

                    <div>
                        <label>Major</label>
                        <input value="<%= H(SelectedStudent.Major) %>" readonly />
                    </div>

                    <div>
                        <label>Training Company</label>
                        <input value="<%= H(SelectedStudent.Company) %>" readonly />
                    </div>

                    <div>
                        <label>Training Field</label>
                        <input value="<%= H(SelectedStudent.TrainingField) %>" readonly />
                    </div>

                    <div>
                        <label>Training Start Date</label>
                        <input value="<%= H(SelectedStudent.StartDate) %>" readonly />
                    </div>

                    <div>
                        <label>Training End Date</label>
                        <input value="<%= H(SelectedStudent.EndDate) %>" readonly />
                    </div>

                    <div>
                        <label>Approved Training Hours</label>
                        <input value="<%= SelectedStudent.CompletedHours %> Hours" readonly />
                    </div>

                    <div>
                        <label>Certificate Reference</label>
                        <input value="<%= H(CertificateReference(SelectedStudent)) %>" readonly />
                    </div>

                    <div class="fcr-form-full">
                        <label for="certificateSkills">Gained Skills</label>
                        <textarea id="certificateSkills"
                                  name="certificateSkills"
                                  maxlength="500"
                                  required><%= H(CertificateSkills) %></textarea>
                    </div>

                    <div>
                        <label for="certificateSignatory">Authorized Signatory</label>
                        <input id="certificateSignatory"
                               name="certificateSignatory"
                               maxlength="100"
                               value="<%= H(CertificateSignatory) %>"
                               required />
                    </div>

                    <div>
                        <label>Issue Date</label>
                        <input value="<%= DateTime.Today.ToString("yyyy-MM-dd") %>"
                               readonly />
                    </div>
                </div>

            <% } else { %>

                <div class="fcr-certificate-preview">
                    <div class="fcr-certificate-paper">

                        <div class="fcr-certificate-university">
                            <span class="fcr-certificate-symbol">✦</span>
                            <strong><%= H(SelectedStudent.University) %></strong>
                        </div>

                        <h2>CERTIFICATE OF INTERNSHIP</h2>

                        <p class="fcr-certificate-intro">
                            This is to certify that
                        </p>

                        <div class="fcr-recipient">
                            <%= H(SelectedStudent.Name) %>
                        </div>

                        <p>
                            Student of
                            <strong><%= H(SelectedStudent.University) %></strong>,
                            ID <strong><%= H(SelectedStudent.StudentId) %></strong>,
                            majoring in
                            <strong><%= H(SelectedStudent.Major) %></strong>,
                            has successfully completed an internship
                            in the field of
                            <strong><%= H(SelectedStudent.TrainingField) %></strong>
                            at
                            <strong><%= H(SelectedStudent.Company) %></strong>.
                        </p>

                        <p>
                            From <strong><%= H(SelectedStudent.StartDate) %></strong>
                            to <strong><%= H(SelectedStudent.EndDate) %></strong>,
                            completing
                            <strong><%= SelectedStudent.CompletedHours %></strong>
                            approved training hours.
                        </p>

                        <p class="fcr-certificate-skills">
                            During the internship, the student gained experience in:
                            <strong><%= H(CertificateSkills) %></strong>.
                        </p>

                        <div class="fcr-certificate-bottom">
                            <div>
                                <strong><%= H(CertificateSignatory) %></strong>
                                <span>Authorized Signatory</span>
                            </div>

                            <div>
                                <strong><%= H(CertificateReference(SelectedStudent)) %></strong>
                                <span>Reference Number</span>
                            </div>

                            <div>
                                <strong><%= DateTime.Today.ToString("yyyy-MM-dd") %></strong>
                                <span>Issue Date</span>
                            </div>
                        </div>

                    </div>
                </div>

                <div class="fcr-form-info">
                    This is a visual preview only. The certificate has not
                    been saved, issued or sent to the student.
                </div>

            <% } %>

        </div>

        <div class="fcr-dialog-footer">
            <% if (Mode == "certificate") { %>
                <a class="btn secondary"
                   href="FinalCompletionReview.aspx">
                    Cancel
                </a>

                <button type="submit"
                        class="btn"
                        name="certificateAction"
                        value="preview:<%= SelectedStudent.Id %>">
                    Preview Certificate
                </button>
            <% } else { %>
                <a class="btn secondary"
                   href="<%= H(PopupUrl(SelectedStudent.Id, "certificate")) %>">
                    Back to Form
                </a>

                <span class="fcr-not-issued">
                    Preview Only — Not Issued
                </span>
            <% } %>
        </div>

    </div>
</div>

<% } %>
</asp:Content>

namespace PSUTInternship.Student { public partial class StudentProfile {
protected global::System.Web.UI.WebControls.Label assignedSupervisor,lblMessage,PersonalError,AcademicError,ProfessionalError,txtDateOfBirthError,txtPhoneError,txtGPAError,txtSemesterError,txtCompletedHoursError,txtApplicationDateError,txtGithubError,txtLinkedinError,txtPortfolioError,txtCVError;
protected global::System.Web.UI.WebControls.TextBox txtDateOfBirth,txtPhone,txtGPA,txtSemester,txtCompletedHours,txtApplicationDate,txtGithub,txtLinkedin,txtPortfolio,txtCV;
protected global::System.Web.UI.WebControls.DropDownList ddlGender;
protected global::System.Web.UI.WebControls.Literal PersonalDetails,AcademicDetails,ProfessionalDetails;
protected global::System.Web.UI.WebControls.Panel PersonalEditor,AcademicEditor,ProfessionalEditor;
protected global::System.Web.UI.WebControls.Button EditPersonal,EditAcademic,EditProfessional,CancelPersonal,SavePersonal,CancelAcademic,SaveAcademic,CancelProfessional,SaveProfessional;
protected global::System.Web.UI.WebControls.Content PageContent;
} }
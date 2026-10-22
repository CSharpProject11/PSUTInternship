<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="Create_task.aspx.cs" Inherits="internship_manegment.Create_task" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style>
        #boxDeadline_assingTo{
            display:flex;
        }
        #ErorrDeadline,#ErrorTitel,#ErorrAssign,#ErorrDescreption,#ErorrEvaluation,#Errorscor{
            color:red;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:Label ID="Subject" runat="server" Text="Create New Task"></asp:Label>
        </div>
        <p>
            <asp:Label ID="statment" runat="server" Text="Assign a new task to one of your trainees"></asp:Label>
        </p>
        <p>
            <asp:Label ID="TitleTask" runat="server" Text="Task Title "></asp:Label>
        </p>
        <p>
            <input id="Titelinput" type="text" runat="server" runat="server"/>
        <div id="boxDeadline_assingTo">
            <asp:Label ID="ErrorTitel" runat="server"></asp:Label>
        </p>

            <asp:Label ID="AssignTo" runat="server" Text="Assign To"></asp:Label>
            <details>
            <summary>Select trainees</summary><asp:CheckBoxList ID="cblStudents"  runat="server"> </asp:CheckBoxList>

            <summary>
            </summary>&nbsp;<br />
            <asp:Label ID="ErorrAssign" runat="server"></asp:Label>

           </details>
        <p>
            <asp:Label ID="Deadline" runat="server" Text="Deadline"></asp:Label>
        </p>
        <p>
            <asp:TextBox ID="Deadlineinput" runat="server" TextMode="DateTime"></asp:TextBox>
        </p>
            <p>
                <asp:Label ID="ErorrDeadline" runat="server"></asp:Label>
        </p>
        </div>
        <p>
            <asp:Label ID="Description" runat="server" Text="Description"></asp:Label>
        </p>
        <p>
            <textarea id="Descriptioniput" cols="20" name="S1" rows="2" runat="server"></textarea></p>
        <p>
            <asp:Label ID="ErorrDescreption" runat="server"></asp:Label>
        </p>
        <p>
            <asp:Label ID="EvaluationCriteria" runat="server" Text="Evaluation Criteria"></asp:Label>
        </p>
        <p>
            <textarea id="EvaluationCriteriainput" cols="20" name="S2" rows="2" runat="server"></textarea></p>
        <p>
            <asp:Label ID="ErorrEvaluation" runat="server"></asp:Label>
        </p>
        <p>
            <asp:Label ID="Score" runat="server" Text="Score"></asp:Label>
        </p>
        <p id="Scoreinput">
            <input id="Scoreinput" type="text" runat="server"/></p>
        <p>
            <asp:Label ID="Errorscor" runat="server"></asp:Label>
        </p>
        <p>
            <asp:Label ID="Prorirty" runat="server" Text="Prorirty"></asp:Label>
        </p>
        <p>
            <asp:DropDownList ID="prorityinput" runat="server">
                <asp:ListItem>Low</asp:ListItem>
                <asp:ListItem>Higth</asp:ListItem>
                <asp:ListItem>Meudim</asp:ListItem>
            </asp:DropDownList>
        </p>
        <p>
            &nbsp;</p>
      
        <p>
            <asp:Button ID="Cancel" runat="server" OnClick="Cancel_Click" Text="Cancel" />
            <asp:Button ID="CreateTask" runat="server" OnClick="CreateTask_Click" Text="Create Task" />
        </p>
    </form>
</body>
</html>
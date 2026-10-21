<%@ Page Language="C#" Async="true" AutoEventWireup="true" CodeBehind="Opportunities.aspx.cs" Inherits="PSUTInternship.Student.Opportunities" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Opportunities</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
        body { margin: 0; padding: 32px 20px; font-family: Arial, sans-serif; background: #f5f6f8; color: #202939; }
        main { max-width: 1100px; margin: auto; }
        .cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 280px), 1fr)); gap: 24px; }
        .card { background: white; border: 1px solid #e0e4ea; border-radius: 12px; overflow: hidden; }
        .card-image { width: 100%; height: 180px; object-fit: cover; display: block; background: #e8edf3; }
        .card-body { padding: 20px; }
        .card h2 { margin: 0 0 16px; font-size: 20px; }
        .details-button { border: 0; border-radius: 6px; background: #215ac7; color: white; padding: 10px 16px; cursor: pointer; font: inherit; }
        .details-button:focus-visible { outline: 3px solid #93b6fa; outline-offset: 3px; }
        .details { margin-top: 18px; line-height: 1.6; overflow-wrap: anywhere; }
        .description { white-space: pre-line; }
        .details p { margin: 8px 0; }
        .popup-overlay {
                position: fixed;
                inset: 0;
                background: rgba(0, 0, 0, 0.5);
                display: flex;
                justify-content: center;
                align-items: center;
                z-index: 1000;
            }

            .popup-box {
                background: white;
                padding: 24px;
                border-radius: 12px;
                width: 500px;
                max-width: 90%;
                max-height: 80vh;
                overflow-y: auto;
                box-sizing: border-box;
            }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <main>
            <h1>Opportunities</h1>
            <asp:Label ID="EmptyMessage" runat="server" Text="No opportunities found." Visible="false" />
            <div class="cards">
                <asp:Repeater ID="OpportunitiesRepeater" runat="server" OnItemCommand="OpportunitiesRepeater_ItemCommand">
                    <ItemTemplate>
                        <article class="card">
                            <asp:Image runat="server" CssClass="card-image" ImageUrl='<%# Eval("ImageUrl") %>' AlternateText='<%# Eval("Title") %>' />
                            <div class="card-body">
                                <h2><%#: Eval("Title") %></h2>
                                <h5><%#: Eval("CompanyId") %> . <%#: Eval("Location") %> . <%#: Eval("WorkMode") %></h5>
                                
                               <asp:Button ID="DetailsButton" runat="server" CssClass="details-button" Text="View &amp; Apply" 
                                   CommandName="ViewApply" CommandArgument='<%# Eval("Id") %>'
                                    CausesValidation="false" /> 

                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </main>
    </form>
</body>
</html>




using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Text;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Shared
{
    public static class CompletionReportPdf
    {
        public static byte[] Create(JObject report)
        {
            byte[] jpeg;
            // Landscape A4 at roughly 200 dpi; coordinates follow the supplied HTML layout.
            using(var page=new Bitmap(2246,1588))
            using(var graphics=Graphics.FromImage(page))
            {
                graphics.Clear(Color.White);
                graphics.ScaleTransform(2,2);
                graphics.TextRenderingHint=System.Drawing.Text.TextRenderingHint.AntiAliasGridFit;
                graphics.SmoothingMode=System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
                using(var navy=new SolidBrush(Color.FromArgb(21,40,78)))
                using(var ink=new SolidBrush(Color.FromArgb(22,38,61)))
                using(var muted=new SolidBrush(Color.FromArgb(83,97,112)))
                using(var teal=new SolidBrush(Color.FromArgb(17,125,139)))
                using(var rule=new Pen(Color.FromArgb(137,150,162),.8f))
                using(var accent=new Pen(Color.FromArgb(22,138,153),1))
                using(var heading=new Font("Arial",30,FontStyle.Bold,GraphicsUnit.Pixel))
                using(var body=new Font("Arial",17,FontStyle.Regular,GraphicsUnit.Pixel))
                using(var label=new Font("Arial",13,FontStyle.Bold,GraphicsUnit.Pixel))
                using(var small=new Font("Arial",11,FontStyle.Regular,GraphicsUnit.Pixel))
                {
                    string logoPath=System.Web.Hosting.HostingEnvironment.MapPath("~/Assets/certificate-psut-logo.png");
                    if(string.IsNullOrEmpty(logoPath)) logoPath=Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"Assets","certificate-psut-logo.png");
                    if(!File.Exists(logoPath)) logoPath=Path.Combine(Environment.CurrentDirectory,"PSUTInternship","PSUTInternship","Assets","certificate-psut-logo.png");
                    if(File.Exists(logoPath))
                    {
                        using(var logo=Image.FromFile(logoPath))
                        {
                            DrawLogo(graphics,logo,new RectangleF(64,56,440,134));
                            using(var sealPen=new Pen(Color.FromArgb(21,40,78),1.5f)) graphics.DrawEllipse(sealPen,880,497,150,150);
                            DrawLogo(graphics,logo,new RectangleF(896,541,118,62));
                        }
                    }
                    else graphics.DrawString("Princess Sumaya University\nfor Technology",heading,navy,new RectangleF(64,64,650,120));
                    graphics.DrawString("Date",label,muted,834,65);
                    Field(graphics,Date((string)report["approvedAt"]),new RectangleF(834,91,225,43),body,teal);
                    using(var topRule=new Pen(Color.FromArgb(21,40,78),2.5f)) graphics.DrawLine(topRule,64,235,787,235);
                    graphics.DrawString("Certificate of Training",heading,navy,64,250);
                    graphics.DrawLine(rule,64,313,787,313);
                    graphics.DrawString("The Training Center at Princess Sumaya University for Technology certifies that",body,ink,new RectangleF(64,329,723,54));
                    Field(graphics,(string)report["studentName"],new RectangleF(64,398,723,48),body,teal);
                    graphics.DrawString("Student number: "+((string)report["studentNumber"] ?? "Not recorded"),small,muted,64,455);
                    graphics.DrawLine(rule,64,485,787,485);
                    graphics.DrawString("Has fulfilled the requirements for the Training Course entitled",body,ink,new RectangleF(64,500,723,46));
                    Field(graphics,(string)report["company"],new RectangleF(64,549,723,48),body,teal);
                    graphics.DrawLine(rule,64,624,787,624);
                    string[] labels={"From","To","Total training hours"};
                    string[] values={Date((string)report["startDate"]),Date((string)report["endDate"]),(string)(report["approvedHours"] ?? report["totalApprovedHours"])};
                    for(int i=0;i<3;i++) {float x=64+i*247;graphics.DrawString(labels[i],label,muted,x,641);Field(graphics,values[i],new RectangleF(x,665,229,43),body,teal);}
                    graphics.DrawLine(accent,834,313,1059,313);
                    graphics.DrawString("Authorized approval",label,ink,834,332);
                    Field(graphics,"Approved electronically",new RectangleF(834,366,225,44),small,teal);
                    graphics.DrawString("University Internship\nCoordinator",body,ink,new RectangleF(834,425,225,55));
                    graphics.DrawString("Report reference: "+((string)report["internshipId"] ?? ""),small,muted,new RectangleF(64,744,995,30));
                }
                using(var image=new MemoryStream()){page.Save(image,ImageFormat.Jpeg);jpeg=image.ToArray();}
            }
            using(var pdf=new MemoryStream())
            {
                var offsets=new List<long>{0};Action<string> text=s=>{byte[] b=Encoding.ASCII.GetBytes(s);pdf.Write(b,0,b.Length);};
                Action<int,string> obj=(id,s)=>{offsets.Add(pdf.Position);text(id+" 0 obj\n"+s+"\nendobj\n");};
                text("%PDF-1.4\n");obj(1,"<< /Type /Catalog /Pages 2 0 R >>");obj(2,"<< /Type /Pages /Kids [3 0 R] /Count 1 >>");
                obj(3,"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 842 595] /Resources << /XObject << /Im0 4 0 R >> >> /Contents 5 0 R >>");
                offsets.Add(pdf.Position);text("4 0 obj\n<< /Type /XObject /Subtype /Image /Width 2246 /Height 1588 /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length "+jpeg.Length+" >>\nstream\n");pdf.Write(jpeg,0,jpeg.Length);text("\nendstream\nendobj\n");
                string commands="q 842 0 0 595 0 0 cm /Im0 Do Q\n";obj(5,"<< /Length "+Encoding.ASCII.GetByteCount(commands)+" >>\nstream\n"+commands+"endstream");
                long xref=pdf.Position;text("xref\n0 6\n0000000000 65535 f \n");for(int i=1;i<=5;i++)text(offsets[i].ToString("D10")+" 00000 n \n");
                text("trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n"+xref+"\n%%EOF");return pdf.ToArray();
            }
        }
        private static string Date(string value)
        {
            DateTime date;
            return DateTime.TryParse(value,System.Globalization.CultureInfo.InvariantCulture,System.Globalization.DateTimeStyles.RoundtripKind,out date)
                ? date.ToString("dd MMM yyyy",System.Globalization.CultureInfo.InvariantCulture) : "Not recorded";
        }
        private static void DrawLogo(Graphics graphics,Image image,RectangleF box)
        {
            float scale=Math.Min(box.Width/image.Width,box.Height/image.Height);
            graphics.DrawImage(image,box.X,box.Y,image.Width*scale,image.Height*scale);
        }
        private static void Field(Graphics graphics,string value,RectangleF box,Font font,Brush ink)
        {
            using(var fill=new SolidBrush(Color.FromArgb(251,253,254))) graphics.FillRectangle(fill,box);
            using(var border=new Pen(Color.FromArgb(170,182,193),.8f)) graphics.DrawRectangle(border,box.X,box.Y,box.Width,box.Height);
            var area=new RectangleF(box.X+10,box.Y+6,box.Width-20,box.Height-12);
            string text=string.IsNullOrWhiteSpace(value)?"Not recorded":value;
            float size=font.Size;
            while(size>10) { using(var test=new Font(font.FontFamily,size,font.Style,GraphicsUnit.Pixel)) {if(graphics.MeasureString(text,test,(int)area.Width).Height<=area.Height) break;} size-=.5f; }
            using(var fitted=new Font(font.FontFamily,size,font.Style,GraphicsUnit.Pixel))
            using(var format=new StringFormat { LineAlignment=StringAlignment.Center,Trimming=StringTrimming.EllipsisCharacter })
                graphics.DrawString(text,fitted,ink,area,format);
        }
    }
}

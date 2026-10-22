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
            using(var page=new Bitmap(1240,1754))
            using(var graphics=Graphics.FromImage(page))
            using(var title=new Font("Segoe UI",32,FontStyle.Bold))
            using(var body=new Font("Segoe UI",20))
            using(var small=new Font("Segoe UI",15))
            {
                graphics.Clear(Color.White); graphics.TextRenderingHint=System.Drawing.Text.TextRenderingHint.AntiAliasGridFit;
                graphics.DrawString("Princess Sumaya University\nfor Technology",title,Brushes.Black,new RectangleF(100,100,1040,180));
                graphics.DrawString("Internship Completion Report",title,Brushes.Black,new RectangleF(100,330,1040,100));
                string[] lines={"Student: "+(string)report["studentName"],"Student number: "+(string)report["studentNumber"],"Placement: "+(string)report["company"],
                    "Approved training hours: "+(string)report["approvedHours"]+" / "+(string)report["requiredHours"],"Final grade: "+(string)report["finalGrade"],"Approved on: "+(string)report["approvedAt"]};
                int y=500;foreach(string line in lines){graphics.DrawString(line,body,Brushes.Black,new RectangleF(100,y,1040,130));y+=150;}
                graphics.DrawString("Approved electronically by the University Internship Coordinator.\nReport reference: "+(string)report["internshipId"],small,Brushes.Black,new RectangleF(100,1510,1040,150));
                using(var image=new MemoryStream()){page.Save(image,ImageFormat.Jpeg);jpeg=image.ToArray();}
            }
            using(var pdf=new MemoryStream())
            {
                var offsets=new List<long>{0};Action<string> text=s=>{byte[] b=Encoding.ASCII.GetBytes(s);pdf.Write(b,0,b.Length);};
                Action<int,string> obj=(id,s)=>{offsets.Add(pdf.Position);text(id+" 0 obj\n"+s+"\nendobj\n");};
                text("%PDF-1.4\n");obj(1,"<< /Type /Catalog /Pages 2 0 R >>");obj(2,"<< /Type /Pages /Kids [3 0 R] /Count 1 >>");
                obj(3,"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /XObject << /Im0 4 0 R >> >> /Contents 5 0 R >>");
                offsets.Add(pdf.Position);text("4 0 obj\n<< /Type /XObject /Subtype /Image /Width 1240 /Height 1754 /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length "+jpeg.Length+" >>\nstream\n");pdf.Write(jpeg,0,jpeg.Length);text("\nendstream\nendobj\n");
                string commands="q 595 0 0 842 0 0 cm /Im0 Do Q\n";obj(5,"<< /Length "+Encoding.ASCII.GetByteCount(commands)+" >>\nstream\n"+commands+"endstream");
                long xref=pdf.Position;text("xref\n0 6\n0000000000 65535 f \n");for(int i=1;i<=5;i++)text(offsets[i].ToString("D10")+" 00000 n \n");
                text("trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n"+xref+"\n%%EOF");return pdf.ToArray();
            }
        }
    }
}

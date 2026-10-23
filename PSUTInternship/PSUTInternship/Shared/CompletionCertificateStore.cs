using System;
using System.IO;
using System.Web.Hosting;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Shared {
 public static class CompletionCertificateStore {
  private static string PathFor(string id) { Guid key;if(!Guid.TryParseExact(id,"N",out key))throw new ArgumentException("Invalid certificate.");return Path.Combine(HostingEnvironment.MapPath("~/App_Data/Certificates")??Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"App_Data","Certificates"),key.ToString("N")+".pdf"); }
  public static string Save(JObject report) {var id=Guid.NewGuid().ToString("N");var path=PathFor(id);Directory.CreateDirectory(Path.GetDirectoryName(path));File.WriteAllBytes(path,CompletionReportPdf.Create(report));return id;}
  public static byte[] Read(JObject report) {string id=(string)report["certificateId"];return string.IsNullOrEmpty(id)?CompletionReportPdf.Create(report):File.Exists(PathFor(id))?File.ReadAllBytes(PathFor(id)):CompletionReportPdf.Create(report);}
 }
}

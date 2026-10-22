using System;
using System.IO;
using System.Linq;
using System.Web;
using Newtonsoft.Json.Linq;
namespace PSUTInternship.Shared {
    public static class TaskFileStore {
        public const int MaximumBytes = 10 * 1024 * 1024;
        public static JObject Save(HttpPostedFile file, string taskId, string studentId) {
            if (file == null || file.ContentLength == 0) return null;
            if (file.ContentLength > MaximumBytes) throw new ArgumentException("The solution file must be no larger than 10 MB.");
            string name = Path.GetFileName(file.FileName);
            string extension = Path.GetExtension(name).ToLowerInvariant();
            if (!new[] { ".pdf", ".doc", ".docx", ".txt", ".zip", ".png", ".jpg", ".jpeg", ".csv", ".xlsx" }.Contains(extension))
                throw new ArgumentException("Upload a PDF, document, text, ZIP, image or spreadsheet file.");
            string id = Guid.NewGuid().ToString("N");
            string path = FilePath(id, taskId, studentId);
            Directory.CreateDirectory(Path.GetDirectoryName(path));
            try { using (var target = new FileStream(path, FileMode.CreateNew, FileAccess.Write)) {
                byte[] buffer = new byte[81920]; int count, total = 0;
                while ((count = file.InputStream.Read(buffer, 0, buffer.Length)) > 0) {
                    total += count;
                    if (total > MaximumBytes) throw new ArgumentException("The solution file must be no larger than 10 MB.");
                    target.Write(buffer, 0, count);
                }
                if (total == 0) throw new ArgumentException("The solution file is empty.");
            } } catch { if (File.Exists(path)) File.Delete(path); throw; }
            return new JObject { ["id"] = id, ["name"] = name, ["size"] = new FileInfo(path).Length };
        }
        public static string FilePath(string id, string taskId, string studentId) {
            Guid parsed;
            if (!Guid.TryParseExact(id, "N", out parsed)) throw new ArgumentException("Invalid solution file.");
            string scope;
            using (var hash = System.Security.Cryptography.SHA256.Create()) scope = BitConverter.ToString(hash.ComputeHash(System.Text.Encoding.UTF8.GetBytes(taskId + "\n" + studentId))).Replace("-", "");
            return Path.Combine(HttpContext.Current.Server.MapPath("~/App_Data/TaskSolutions"), scope, parsed.ToString("N") + ".bin");
        }
        public static void Delete(JObject file, string taskId, string studentId) { if (file == null) return; string path = FilePath((string)file["id"], taskId, studentId); if (File.Exists(path)) File.Delete(path); }
    }
}
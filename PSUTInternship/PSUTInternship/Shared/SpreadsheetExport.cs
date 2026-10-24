using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Xml;

namespace PSUTInternship.Shared
{
    public static class SpreadsheetExport
    {
        private const string SheetNs = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
        public static byte[] Create(string[] headers, IEnumerable<object[]> records)
        {
            var rows = records.ToList();
            if (headers.Length == 0 || headers.Length > 16384 || rows.Count > 1048575 || rows.Any(row => row.Length != headers.Length))
                throw new ArgumentException("The export exceeds Excel limits or contains inconsistent columns.");
            using (var output = new MemoryStream())
            {
                using (var zip = new ZipArchive(output, ZipArchiveMode.Create, true))
                {
                    Add(zip, "[Content_Types].xml", "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/><Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/><Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/></Types>");
                    Add(zip, "_rels/.rels", "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/></Relationships>");
                    Add(zip, "xl/workbook.xml", "<workbook xmlns=\"" + SheetNs + "\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"><sheets><sheet name=\"Student placements\" sheetId=\"1\" r:id=\"rId1\"/></sheets></workbook>");
                    Add(zip, "xl/_rels/workbook.xml.rels", "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/><Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/></Relationships>");
                    Add(zip, "xl/styles.xml", "<styleSheet xmlns=\"" + SheetNs + "\"><fonts count=\"2\"><font><sz val=\"11\"/><name val=\"Calibri\"/></font><font><b/><sz val=\"11\"/><color rgb=\"FFFFFFFF\"/><name val=\"Calibri\"/></font></fonts><fills count=\"3\"><fill><patternFill patternType=\"none\"/></fill><fill><patternFill patternType=\"gray125\"/></fill><fill><patternFill patternType=\"solid\"><fgColor rgb=\"FF003E73\"/><bgColor indexed=\"64\"/></patternFill></fill></fills><borders count=\"1\"><border><left/><right/><top/><bottom/><diagonal/></border></borders><cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs><cellXfs count=\"2\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\"/><xf numFmtId=\"0\" fontId=\"1\" fillId=\"2\" borderId=\"0\" xfId=\"0\" applyFont=\"1\" applyFill=\"1\"><alignment vertical=\"center\" wrapText=\"1\"/></xf></cellXfs><cellStyles count=\"1\"><cellStyle name=\"Normal\" xfId=\"0\" builtinId=\"0\"/></cellStyles></styleSheet>");
                    using (var stream = zip.CreateEntry("xl/worksheets/sheet1.xml").Open())
                    using (var xml = XmlWriter.Create(stream, new XmlWriterSettings { Encoding = new UTF8Encoding(false) }))
                    {
                        xml.WriteStartElement("worksheet", SheetNs);
                        xml.WriteStartElement("sheetViews"); xml.WriteStartElement("sheetView"); xml.WriteAttributeString("workbookViewId", "0");
                        xml.WriteStartElement("pane"); xml.WriteAttributeString("ySplit", "1"); xml.WriteAttributeString("topLeftCell", "A2"); xml.WriteAttributeString("activePane", "bottomLeft"); xml.WriteAttributeString("state", "frozen"); xml.WriteEndElement(); xml.WriteEndElement(); xml.WriteEndElement();
                        xml.WriteStartElement("cols");
                        for (int c = 0; c < headers.Length; c++) { xml.WriteStartElement("col"); xml.WriteAttributeString("min", (c + 1).ToString()); xml.WriteAttributeString("max", (c + 1).ToString()); xml.WriteAttributeString("width", c < 6 ? "26" : "20"); xml.WriteAttributeString("customWidth", "1"); xml.WriteEndElement(); }
                        xml.WriteEndElement(); xml.WriteStartElement("sheetData");
                        WriteRow(xml, headers.Cast<object>().ToArray(), 1, true);
                        for (int row = 0; row < rows.Count; row++) WriteRow(xml, rows[row], row + 2, false);
                        xml.WriteEndElement(); xml.WriteStartElement("autoFilter"); xml.WriteAttributeString("ref", "A1:" + Column(headers.Length) + (rows.Count + 1)); xml.WriteEndElement(); xml.WriteEndElement();
                    }
                }
                return output.ToArray();
            }
        }
        private static void Add(ZipArchive zip, string path, string content)
        { using (var writer = new StreamWriter(zip.CreateEntry(path).Open(), new UTF8Encoding(false))) writer.Write(content); }
        private static string Column(int index)
        { string name = ""; while (index > 0) { index--; name = (char)('A' + index % 26) + name; index /= 26; } return name; }
        private static void WriteRow(XmlWriter xml, object[] values, int row, bool header)
        {
            xml.WriteStartElement("row"); xml.WriteAttributeString("r", row.ToString(CultureInfo.InvariantCulture));
            if (header) { xml.WriteAttributeString("ht", "32"); xml.WriteAttributeString("customHeight", "1"); }
            for (int c = 0; c < values.Length; c++)
            {
                xml.WriteStartElement("c"); xml.WriteAttributeString("r", Column(c + 1) + row);
                if (header) xml.WriteAttributeString("s", "1");
                if (values[c] is decimal || values[c] is int) xml.WriteElementString("v", Convert.ToString(values[c], CultureInfo.InvariantCulture));
                else
                {
                    // Inline strings preserve IDs, Unicode and formula-looking user input as text.
                    xml.WriteAttributeString("t", "inlineStr"); xml.WriteStartElement("is"); xml.WriteStartElement("t"); xml.WriteAttributeString("xml", "space", "http://www.w3.org/XML/1998/namespace", "preserve");
                    var text = Convert.ToString(values[c]) ?? ""; var clean = new StringBuilder();
                    for (int i = 0; i < text.Length && clean.Length < 32767; i++)
                    {
                        if (char.IsHighSurrogate(text[i]) && i + 1 < text.Length && char.IsLowSurrogate(text[i + 1])) { if (clean.Length < 32766) clean.Append(text[i]).Append(text[++i]); else break; }
                        else if (XmlConvert.IsXmlChar(text[i])) clean.Append(text[i]);
                    }
                    xml.WriteString(clean.ToString()); xml.WriteEndElement(); xml.WriteEndElement();
                }
                xml.WriteEndElement();
            }
            xml.WriteEndElement();
        }
    }
}

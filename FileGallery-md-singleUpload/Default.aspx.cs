using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.UI;

namespace FileGallery
{
    public partial class Default : System.Web.UI.Page
    {
        private string uploadsPath;
        private string dataPath;

        protected void Page_Load(object sender, EventArgs e)
        {
            uploadsPath = Server.MapPath("~/Uploads");
            dataPath = Server.MapPath("~/App_Data");

            if (!Directory.Exists(uploadsPath))
                Directory.CreateDirectory(uploadsPath);
            if (!Directory.Exists(dataPath))
                Directory.CreateDirectory(dataPath);

            if (!IsPostBack)
            {
                LoadCategories();
                LoadFiles();
            }
        }

        private void LoadCategories()
        {
            var categories = GetCategories();
            var categoryData = categories.Select(c => new
            {
                Name = c,
                FileCount = GetFilesInCategory(c).Count
            }).ToList();

            CategoryRepeater.DataSource = categoryData;
            CategoryRepeater.DataBind();
        }

        private void LoadFiles()
        {
            string selectedCategory = Request.QueryString["category"];
            List<FileInfo> files;

            if (!string.IsNullOrEmpty(selectedCategory))
            {
                CategoryNameLiteral.Text = selectedCategory;
                files = GetFilesInCategory(selectedCategory);

                // Load markdown if exists
                LoadMarkdown(selectedCategory);
            }
            else
            {
                CategoryNameLiteral.Text = "All Files";
                files = GetAllFiles();
            }

            if (files.Count == 0)
            {
                NoFilesPanel.Visible = true;
                FileListPanel.Visible = false;
            }
            else
            {
                NoFilesPanel.Visible = false;
                FileListPanel.Visible = true;
                FileCountLiteral.Text = $"{files.Count} {(files.Count == 1 ? "file" : "files")}";

                var fileData = files.Select(f => new FileDisplayData
                {
                    FileName = f.Name,
                    FilePath = ResolveUrl("~/FileHandler.ashx?category=" + Server.UrlEncode(GetCategoryForFile(f.FullName)) + "&file=" + Server.UrlEncode(f.Name)),
                    Extension = f.Extension,
                    Category = GetCategoryForFile(f.FullName),
                    Size = FormatFileSize(f.Length),
                    Modified = f.LastWriteTime.ToString("MMM dd, yyyy")
                }).ToList();

                FileRepeater.DataSource = fileData;
                FileRepeater.DataBind();
            }
        }

        private void LoadMarkdown(string category)
        {
            string readmePath = Path.Combine(uploadsPath, category, "README.md");

            if (File.Exists(readmePath))
            {
                try
                {
                    string markdownText = File.ReadAllText(readmePath);
                    string html = ConvertMarkdownToHtml(markdownText);

                    MarkdownContent.Text = html;
                    MarkdownPanel.Visible = true;
                }
                catch (Exception ex)
                {
                    // Silently fail if markdown cannot be loaded
                    MarkdownPanel.Visible = false;
                }
            }
            else
            {
                MarkdownPanel.Visible = false;
            }
        }

        private string ConvertMarkdownToHtml(string markdown)
        {
            // Simple markdown parser
            var html = markdown;

            // Convert headers
            html = System.Text.RegularExpressions.Regex.Replace(html, @"^### (.*?)$", "<h3>$1</h3>", System.Text.RegularExpressions.RegexOptions.Multiline);
            html = System.Text.RegularExpressions.Regex.Replace(html, @"^## (.*?)$", "<h2>$1</h2>", System.Text.RegularExpressions.RegexOptions.Multiline);
            html = System.Text.RegularExpressions.Regex.Replace(html, @"^# (.*?)$", "<h1>$1</h1>", System.Text.RegularExpressions.RegexOptions.Multiline);

            // Convert bold and italic
            html = System.Text.RegularExpressions.Regex.Replace(html, @"\*\*\*(.*?)\*\*\*", "<strong><em>$1</em></strong>");
            html = System.Text.RegularExpressions.Regex.Replace(html, @"\*\*(.*?)\*\*", "<strong>$1</strong>");
            html = System.Text.RegularExpressions.Regex.Replace(html, @"\*(.*?)\*", "<em>$1</em>");

            // Convert inline code
            html = System.Text.RegularExpressions.Regex.Replace(html, @"`([^`]+)`", "<code>$1</code>");

            // Convert links
            html = System.Text.RegularExpressions.Regex.Replace(html, @"\[([^\]]+)\]\(([^\)]+)\)", "<a href=\"$2\">$1</a>");

            // Convert lists
            var lines = html.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None);
            var result = new System.Text.StringBuilder();
            bool inList = false;

            foreach (var line in lines)
            {
                if (line.TrimStart().StartsWith("- ") || line.TrimStart().StartsWith("* "))
                {
                    if (!inList)
                    {
                        result.Append("<ul>");
                        inList = true;
                    }
                    result.Append("<li>").Append(line.TrimStart().Substring(2)).Append("</li>");
                }
                else if (System.Text.RegularExpressions.Regex.IsMatch(line.TrimStart(), @"^\d+\. "))
                {
                    if (!inList)
                    {
                        result.Append("<ol>");
                        inList = true;
                    }
                    var content = System.Text.RegularExpressions.Regex.Replace(line.TrimStart(), @"^\d+\. ", "");
                    result.Append("<li>").Append(content).Append("</li>");
                }
                else
                {
                    if (inList)
                    {
                        result.Append("</ul>");
                        inList = false;
                    }

                    if (!string.IsNullOrWhiteSpace(line))
                    {
                        if (!line.StartsWith("<h") && !line.StartsWith("<ul") && !line.StartsWith("<ol"))
                        {
                            result.Append("<p>").Append(line).Append("</p>");
                        }
                        else
                        {
                            result.Append(line);
                        }
                    }
                }
            }

            if (inList)
            {
                result.Append("</ul>");
            }

            return result.ToString();
        }

        private string FormatFileSize(long bytes)
        {
            string[] sizes = { "B", "KB", "MB", "GB" };
            double len = bytes;
            int order = 0;
            while (len >= 1024 && order < sizes.Length - 1)
            {
                order++;
                len = len / 1024;
            }
            return $"{len:0.##} {sizes[order]}";
        }

        private List<string> GetCategories()
        {
            var categories = new List<string>();
            string categoriesFile = Path.Combine(dataPath, "categories.txt");

            if (File.Exists(categoriesFile))
            {
                categories = File.ReadAllLines(categoriesFile)
                    .Where(c => !string.IsNullOrWhiteSpace(c))
                    .ToList();
            }

            if (categories.Count == 0)
            {
                categories.Add("General");
                File.WriteAllLines(categoriesFile, categories);
                Directory.CreateDirectory(Path.Combine(uploadsPath, "General"));
            }

            return categories;
        }

        private List<FileInfo> GetFilesInCategory(string category)
        {
            string categoryPath = Path.Combine(uploadsPath, category);
            if (Directory.Exists(categoryPath))
            {
                return new DirectoryInfo(categoryPath)
                    .GetFiles()
                    .Where(f => f.Name != ".gitkeep" && f.Extension.ToLower() != ".md")
                    .OrderBy(f => f.Name)
                    .ToList();
            }
            return new List<FileInfo>();
        }

        private List<FileInfo> GetAllFiles()
        {
            var allFiles = new List<FileInfo>();
            var categories = GetCategories();

            foreach (var category in categories)
            {
                allFiles.AddRange(GetFilesInCategory(category));
            }

            return allFiles.OrderBy(f => f.Name).ToList();
        }

        private string GetCategoryForFile(string filePath)
        {
            string relativePath = filePath.Replace(uploadsPath, "").TrimStart('\\', '/');
            int firstSlash = relativePath.IndexOfAny(new[] { '\\', '/' });
            if (firstSlash > 0)
            {
                return relativePath.Substring(0, firstSlash);
            }
            return "General";
        }

        protected string GetFileIcon(string extension)
        {
            extension = extension.ToLower();
            switch (extension)
            {
                case ".pdf": return "📄";
                case ".doc":
                case ".docx": return "📝";
                case ".txt": return "📃";
                case ".jpg":
                case ".jpeg":
                case ".png":
                case ".gif":
                case ".bmp": return "🖼️";
                case ".mp4":
                case ".webm":
                case ".avi":
                case ".mov": return "🎥";
                case ".mp3":
                case ".wav":
                case ".ogg": return "🎵";
                case ".zip":
                case ".rar":
                case ".7z": return "🗜️";
                case ".xls":
                case ".xlsx": return "📊";
                case ".ppt":
                case ".pptx": return "📊";
                default: return "📎";
            }
        }
    }

    // Helper class for file display data
    public class FileDisplayData
    {
        public string FileName { get; set; }
        public string FilePath { get; set; }
        public string Extension { get; set; }
        public string Category { get; set; }
        public string Size { get; set; }
        public string Modified { get; set; }
    }
}
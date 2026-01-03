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
            }
            else
            {
                CategoryNameLiteral.Text = "All Files";
                files = GetAllFiles();
            }

            if (files.Count == 0)
            {
                NoFilesPanel.Visible = true;
                FileRepeater.Visible = false;
            }
            else
            {
                NoFilesPanel.Visible = false;
                FileRepeater.Visible = true;

                var fileData = files.Select(f => new
                {
                    FileName = f.Name,
                    FilePath = ResolveUrl("~/FileHandler.ashx?category=" + Server.UrlEncode(GetCategoryForFile(f.FullName)) + "&file=" + Server.UrlEncode(f.Name)),
                    Extension = f.Extension,
                    Category = GetCategoryForFile(f.FullName)
                }).ToList();

                FileRepeater.DataSource = fileData;
                FileRepeater.DataBind();
            }
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
                    .Where(f => f.Name != ".gitkeep")
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
}
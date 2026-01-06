using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FileGallery
{
    public partial class Admin : Page
    {
        private string uploadsPath;
        private string publicUploadsPath;
        private string dataPath;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is logged in
            if (Session["IsAdmin"] == null || !(bool)Session["IsAdmin"])
            {
                Response.Redirect("Login.aspx");
                return;
            }

            uploadsPath = Server.MapPath("~/Uploads");
            publicUploadsPath = Server.MapPath("~/PublicUploads");
            dataPath = Server.MapPath("~/App_Data");

            if (!Directory.Exists(uploadsPath))
                Directory.CreateDirectory(uploadsPath);
            if (!Directory.Exists(publicUploadsPath))
                Directory.CreateDirectory(publicUploadsPath);
            if (!Directory.Exists(dataPath))
                Directory.CreateDirectory(dataPath);

            if (!IsPostBack)
            {
                LoadData();
            }
        }

        private void LoadData()
        {
            LoadStats();
            LoadCategories();
            LoadCategoryDropdown();
            LoadFiles();
            LoadPublicFiles();
        }

        private void LoadStats()
        {
            var categories = GetCategories();
            litTotalCategories.Text = categories.Count.ToString();

            int totalFiles = 0;
            foreach (var category in categories)
            {
                totalFiles += GetFilesInCategory(category).Count;
            }
            litTotalFiles.Text = totalFiles.ToString();

            var publicFiles = GetPublicFiles();
            litPublicFiles.Text = publicFiles.Count.ToString();
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

        private void LoadCategoryDropdown()
        {
            var categories = GetCategories();
            ddlUploadCategory.Items.Clear();
            ddlReadmeCategory.Items.Clear();
            
            foreach (var category in categories)
            {
                ddlUploadCategory.Items.Add(new ListItem(category, category));
                ddlReadmeCategory.Items.Add(new ListItem(category, category));
            }
            
            // Load README for first category if exists
            if (categories.Count > 0)
            {
                LoadReadmeForCategory(categories[0]);
            }
        }

        private void LoadFiles()
        {
            var allFiles = new List<FileDisplayInfo>();
            var categories = GetCategories();

            foreach (var category in categories)
            {
                var files = GetFilesInCategory(category);
                foreach (var file in files)
                {
                    allFiles.Add(new FileDisplayInfo
                    {
                        FileName = file.Name,
                        Category = category,
                        Size = FormatFileSize(file.Length),
                        UploadDate = file.LastWriteTime.ToString("yyyy-MM-dd HH:mm"),
                        FilePath = ResolveUrl("~/FileHandler.ashx?category=" + Server.UrlEncode(category) + "&file=" + Server.UrlEncode(file.Name)),
                        FullPath = file.FullName,
                        Extension = file.Extension
                    });
                }
            }

            FileRepeater.DataSource = allFiles.OrderByDescending(f => f.UploadDate).ToList();
            FileRepeater.DataBind();
        }

        private void LoadPublicFiles()
        {
            var publicFiles = GetPublicFiles();
            var fileData = publicFiles.Select(f => new
            {
                FileName = f.Name,
                Size = FormatFileSize(f.Length),
                UploadDate = f.LastWriteTime.ToString("yyyy-MM-dd HH:mm"),
                FilePath = ResolveUrl("~/FileHandler.ashx?type=public&file=" + Server.UrlEncode(f.Name)),
                FullPath = f.FullName,
                Extension = f.Extension
            }).OrderByDescending(f => f.UploadDate).ToList();

            PublicFileRepeater.DataSource = fileData;
            PublicFileRepeater.DataBind();
        }

        protected void btnAddCategory_Click(object sender, EventArgs e)
        {
            string categoryName = txtNewCategory.Text.Trim();

            if (string.IsNullOrEmpty(categoryName))
            {
                ShowMessage("Please enter a category name.", "error");
                return;
            }

            var categories = GetCategories();
            if (categories.Contains(categoryName, StringComparer.OrdinalIgnoreCase))
            {
                ShowMessage("Category already exists.", "error");
                return;
            }

            categories.Add(categoryName);
            SaveCategories(categories);

            string categoryPath = Path.Combine(uploadsPath, categoryName);
            Directory.CreateDirectory(categoryPath);

            txtNewCategory.Text = string.Empty;
            ShowMessage($"Category '{categoryName}' created successfully.", "success");
            LoadData();
        }

        protected void btnDeleteCategory_Click(object sender, EventArgs e)
        {
            var btn = (Button)sender;
            string categoryName = btn.CommandArgument;

            var categories = GetCategories();
            categories.Remove(categoryName);
            SaveCategories(categories);

            string categoryPath = Path.Combine(uploadsPath, categoryName);
            if (Directory.Exists(categoryPath))
            {
                Directory.Delete(categoryPath, true);
            }

            ShowMessage($"Category '{categoryName}' deleted successfully.", "success");
            LoadData();
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (!fileUpload.HasFile)
            {
                ShowMessage("Please select a file to upload.", "error");
                return;
            }

            string category = ddlUploadCategory.SelectedValue;
            string categoryPath = Path.Combine(uploadsPath, category);
            
            if (!Directory.Exists(categoryPath))
            {
                Directory.CreateDirectory(categoryPath);
            }

            string fileName = Path.GetFileName(fileUpload.FileName);
            string filePath = Path.Combine(categoryPath, fileName);

            try
            {
                fileUpload.SaveAs(filePath);
                ShowMessage($"File '{fileName}' uploaded successfully to '{category}'.", "success");
                LoadData();
            }
            catch (Exception ex)
            {
                ShowMessage($"Error uploading file: {ex.Message}", "error");
            }
        }

        protected void btnDeleteFile_Click(object sender, EventArgs e)
        {
            var btn = (Button)sender;
            string filePath = btn.CommandArgument;

            try
            {
                if (File.Exists(filePath))
                {
                    File.Delete(filePath);
                    ShowMessage("File deleted successfully.", "success");
                    LoadData();
                }
            }
            catch (Exception ex)
            {
                ShowMessage($"Error deleting file: {ex.Message}", "error");
            }
        }

        protected void btnDeletePublicFile_Click(object sender, EventArgs e)
        {
            var btn = (Button)sender;
            string filePath = btn.CommandArgument;

            try
            {
                if (File.Exists(filePath))
                {
                    File.Delete(filePath);
                    ShowMessage("Public file deleted successfully.", "success");
                    LoadData();
                }
            }
            catch (Exception ex)
            {
                ShowMessage($"Error deleting file: {ex.Message}", "error");
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Default.aspx");
        }
        
        protected void ddlReadmeCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            string selectedCategory = ddlReadmeCategory.SelectedValue;
            LoadReadmeForCategory(selectedCategory);
        }
        
        protected void btnSaveMarkdown_Click(object sender, EventArgs e)
        {
            string category = ddlReadmeCategory.SelectedValue;
            string markdownText = txtMarkdown.Text;
            
            if (string.IsNullOrEmpty(category))
            {
                ShowMessage("Please select a category.", "error");
                return;
            }
            
            string categoryPath = Path.Combine(uploadsPath, category);
            string readmePath = Path.Combine(categoryPath, "README.md");
            
            try
            {
                File.WriteAllText(readmePath, markdownText);
                ShowMessage($"README.md saved successfully for category '{category}'.", "success");
                MarkdownPreviewPanel.Visible = false;
            }
            catch (Exception ex)
            {
                ShowMessage($"Error saving README: {ex.Message}", "error");
            }
        }
        
        protected void btnPreviewMarkdown_Click(object sender, EventArgs e)
        {
            string markdownText = txtMarkdown.Text;
            
            if (string.IsNullOrWhiteSpace(markdownText))
            {
                ShowMessage("Please enter some markdown content to preview.", "error");
                return;
            }
            
            string html = ConvertMarkdownToHtml(markdownText);
            MarkdownPreview.Text = html;
            MarkdownPreviewPanel.Visible = true;
        }
        
        protected void btnDeleteMarkdown_Click(object sender, EventArgs e)
        {
            string category = ddlReadmeCategory.SelectedValue;
            
            if (string.IsNullOrEmpty(category))
            {
                ShowMessage("Please select a category.", "error");
                return;
            }
            
            string categoryPath = Path.Combine(uploadsPath, category);
            string readmePath = Path.Combine(categoryPath, "README.md");
            
            try
            {
                if (File.Exists(readmePath))
                {
                    File.Delete(readmePath);
                    txtMarkdown.Text = string.Empty;
                    MarkdownPreviewPanel.Visible = false;
                    ShowMessage($"README.md deleted successfully for category '{category}'.", "success");
                }
                else
                {
                    ShowMessage("README.md does not exist for this category.", "error");
                }
            }
            catch (Exception ex)
            {
                ShowMessage($"Error deleting README: {ex.Message}", "error");
            }
        }
        
        private void LoadReadmeForCategory(string category)
        {
            string categoryPath = Path.Combine(uploadsPath, category);
            string readmePath = Path.Combine(categoryPath, "README.md");
            
            if (File.Exists(readmePath))
            {
                try
                {
                    txtMarkdown.Text = File.ReadAllText(readmePath);
                }
                catch
                {
                    txtMarkdown.Text = string.Empty;
                }
            }
            else
            {
                txtMarkdown.Text = string.Empty;
            }
            
            MarkdownPreviewPanel.Visible = false;
        }
        
        private string ConvertMarkdownToHtml(string markdown)
        {
            // Simple markdown parser - same as Default.aspx.cs
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
            bool inOrderedList = false;
            
            foreach (var line in lines)
            {
                if (line.TrimStart().StartsWith("- ") || line.TrimStart().StartsWith("* "))
                {
                    if (!inList)
                    {
                        if (inOrderedList)
                        {
                            result.Append("</ol>");
                            inOrderedList = false;
                        }
                        result.Append("<ul>");
                        inList = true;
                    }
                    result.Append("<li>").Append(line.TrimStart().Substring(2)).Append("</li>");
                }
                else if (System.Text.RegularExpressions.Regex.IsMatch(line.TrimStart(), @"^\d+\. "))
                {
                    if (!inOrderedList)
                    {
                        if (inList)
                        {
                            result.Append("</ul>");
                            inList = false;
                        }
                        result.Append("<ol>");
                        inOrderedList = true;
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
                    if (inOrderedList)
                    {
                        result.Append("</ol>");
                        inOrderedList = false;
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
            if (inOrderedList)
            {
                result.Append("</ol>");
            }
            
            return result.ToString();
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
                SaveCategories(categories);
                Directory.CreateDirectory(Path.Combine(uploadsPath, "General"));
            }

            return categories;
        }

        private void SaveCategories(List<string> categories)
        {
            string categoriesFile = Path.Combine(dataPath, "categories.txt");
            File.WriteAllLines(categoriesFile, categories);
        }

        private List<FileInfo> GetFilesInCategory(string category)
        {
            string categoryPath = Path.Combine(uploadsPath, category);
            if (Directory.Exists(categoryPath))
            {
                return new DirectoryInfo(categoryPath)
                    .GetFiles()
                    .Where(f => f.Name != ".gitkeep")
                    .ToList();
            }
            return new List<FileInfo>();
        }

        private List<FileInfo> GetPublicFiles()
        {
            if (Directory.Exists(publicUploadsPath))
            {
                return new DirectoryInfo(publicUploadsPath)
                    .GetFiles()
                    .Where(f => f.Name != ".gitkeep")
                    .ToList();
            }
            return new List<FileInfo>();
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

        private void ShowMessage(string message, string type)
        {
            MessagePanel.CssClass = type == "success" ? "success-message" : "error-message";
            MessagePanel.Controls.Clear();
            MessagePanel.Controls.Add(new Literal { Text = message });
            MessagePanel.Visible = true;
        }
    }

    // Helper class for file display
    public class FileDisplayInfo
    {
        public string FileName { get; set; }
        public string Category { get; set; }
        public string Size { get; set; }
        public string UploadDate { get; set; }
        public string FilePath { get; set; }
        public string FullPath { get; set; }
        public string Extension { get; set; }
    }
}
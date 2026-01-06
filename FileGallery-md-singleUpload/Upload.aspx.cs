using System;
using System.IO;
using System.Web.UI;

namespace FileGallery
{
    public partial class Upload : Page
    {
        private string publicUploadsPath;

        protected void Page_Load(object sender, EventArgs e)
        {
            publicUploadsPath = Server.MapPath("~/PublicUploads");

            if (!Directory.Exists(publicUploadsPath))
            {
                Directory.CreateDirectory(publicUploadsPath);
            }
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (!fileUpload.HasFile)
            {
                ShowMessage("Please select a file to upload.", "error");
                return;
            }

            try
            {
                string fileName = Path.GetFileName(fileUpload.FileName);
                string filePath = Path.Combine(publicUploadsPath, fileName);

                // Check if file already exists and create unique name if needed
                if (File.Exists(filePath))
                {
                    string fileNameWithoutExt = Path.GetFileNameWithoutExtension(fileName);
                    string extension = Path.GetExtension(fileName);
                    int counter = 1;

                    do
                    {
                        fileName = $"{fileNameWithoutExt}_{counter}{extension}";
                        filePath = Path.Combine(publicUploadsPath, fileName);
                        counter++;
                    } while (File.Exists(filePath));
                }

                fileUpload.SaveAs(filePath);
                ShowMessage($"File '{fileName}' uploaded successfully! It will be reviewed by an administrator.", "success");
                
                // Clear the file input
                ScriptManager.RegisterStartupScript(this, GetType(), "clearFile", 
                    "document.getElementById('fileUpload').value = ''; " +
                    "document.getElementById('selectedFileDiv').style.display = 'none';", true);
            }
            catch (Exception ex)
            {
                ShowMessage($"Error uploading file: {ex.Message}", "error");
            }
        }

        private void ShowMessage(string message, string type)
        {
            MessagePanel.CssClass = type == "success" ? "success-message" : "error-message";
            MessagePanel.Controls.Clear();
            MessagePanel.Controls.Add(new System.Web.UI.WebControls.Literal { Text = message });
            MessagePanel.Visible = true;
        }
    }
}
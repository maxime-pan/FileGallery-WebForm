using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
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
            if (!fileUpload.HasFiles)
            {
                ShowMessage("Please select at least one file to upload.", "error");
                return;
            }

            int successCount = 0;
            int failCount = 0;
            var errorMessages = new List<string>();

            try
            {
                foreach (HttpPostedFile uploadedFile in fileUpload.PostedFiles)
                {
                    try
                    {
                        string fileName = Path.GetFileName(uploadedFile.FileName);
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

                        uploadedFile.SaveAs(filePath);
                        successCount++;
                    }
                    catch (Exception ex)
                    {
                        failCount++;
                        errorMessages.Add($"'{Path.GetFileName(uploadedFile.FileName)}': {ex.Message}");
                    }
                }

                // Show result message
                if (successCount > 0 && failCount == 0)
                {
                    ShowMessage($"Successfully uploaded {successCount} file(s)! They will be reviewed by an administrator.", "success");
                }
                else if (successCount > 0 && failCount > 0)
                {
                    string msg = $"Uploaded {successCount} file(s) successfully, but {failCount} failed. Errors: " + string.Join("; ", errorMessages);
                    ShowMessage(msg, "error");
                }
                else
                {
                    string msg = "Failed to upload files. Errors: " + string.Join("; ", errorMessages);
                    ShowMessage(msg, "error");
                }

                // Clear the file input
                ScriptManager.RegisterStartupScript(this, GetType(), "clearFile",
                    "document.getElementById('fileUpload').value = ''; " +
                    "document.getElementById('selectedFileDiv').style.display = 'none';", true);
            }
            catch (Exception ex)
            {
                ShowMessage($"Error uploading files: {ex.Message}", "error");
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
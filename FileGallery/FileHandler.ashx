<%@ WebHandler Language="C#" Class="FileHandler" %>

using System;
using System.IO;
using System.Web;

public class FileHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        try
        {
            string category = context.Request.QueryString["category"];
            string fileName = context.Request.QueryString["file"];
            string type = context.Request.QueryString["type"]; // "upload" or "public"

            // Validate inputs
            if (string.IsNullOrEmpty(fileName))
            {
                SendError(context, 400, "File name is required");
                return;
            }

            // Prevent directory traversal attacks
            fileName = Path.GetFileName(fileName);
            
            string filePath = "";
            
            if (type == "public")
            {
                filePath = context.Server.MapPath("~/PublicUploads/" + fileName);
            }
            else if (!string.IsNullOrEmpty(category))
            {
                // Prevent directory traversal in category
                category = Path.GetFileName(category);
                filePath = context.Server.MapPath("~/Uploads/" + category + "/" + fileName);
            }
            else
            {
                SendError(context, 400, "Category or type parameter is required");
                return;
            }

            // Check if file exists
            if (!File.Exists(filePath))
            {
                SendError(context, 404, "File not found: " + fileName);
                return;
            }

            // Get file info
            FileInfo fileInfo = new FileInfo(filePath);
            string extension = fileInfo.Extension.ToLower();
            
            // Clear any existing output
            context.Response.Clear();
            context.Response.ClearHeaders();
            context.Response.ClearContent();
            context.Response.Buffer = false;
            
            // Set content type based on file extension
            string contentType = GetContentType(extension);
            context.Response.ContentType = contentType;
            
            // Set headers for proper file delivery
            context.Response.AppendHeader("Content-Length", fileInfo.Length.ToString());
            context.Response.AppendHeader("Content-Disposition", "inline; filename=\"" + Uri.EscapeDataString(fileName) + "\"");
            context.Response.AppendHeader("Accept-Ranges", "bytes");
            
            // Disable caching for debugging, enable for production
            context.Response.Cache.SetCacheability(HttpCacheability.Public);
            context.Response.Cache.SetExpires(DateTime.Now.AddHours(1));
            context.Response.Cache.SetMaxAge(new TimeSpan(1, 0, 0));
            
            // Stream the file in chunks
            using (FileStream fs = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Read))
            {
                byte[] buffer = new byte[8192];
                int bytesRead;
                
                while ((bytesRead = fs.Read(buffer, 0, buffer.Length)) > 0)
                {
                    if (context.Response.IsClientConnected)
                    {
                        context.Response.OutputStream.Write(buffer, 0, bytesRead);
                        context.Response.Flush();
                    }
                    else
                    {
                        break;
                    }
                }
            }
            
            context.ApplicationInstance.CompleteRequest();
        }
        catch (Exception ex)
        {
            try
            {
                context.Response.Clear();
                context.Response.StatusCode = 500;
                context.Response.ContentType = "text/plain";
                context.Response.Write("Error: " + ex.Message);
                context.ApplicationInstance.CompleteRequest();
            }
            catch
            {
                // Already sent response
            }
        }
    }

    private void SendError(HttpContext context, int statusCode, string message)
    {
        try
        {
            context.Response.Clear();
            context.Response.StatusCode = statusCode;
            context.Response.ContentType = "text/plain";
            context.Response.Write(message);
            context.ApplicationInstance.CompleteRequest();
        }
        catch
        {
            // Already sent response
        }
    }

    private string GetContentType(string extension)
    {
        switch (extension)
        {
            case ".pdf": return "application/pdf";
            case ".txt": return "text/plain; charset=utf-8";
            case ".jpg":
            case ".jpeg": return "image/jpeg";
            case ".png": return "image/png";
            case ".gif": return "image/gif";
            case ".bmp": return "image/bmp";
            case ".svg": return "image/svg+xml";
            case ".ico": return "image/x-icon";
            case ".mp4": return "video/mp4";
            case ".webm": return "video/webm";
            case ".avi": return "video/x-msvideo";
            case ".mov": return "video/quicktime";
            case ".mp3": return "audio/mpeg";
            case ".wav": return "audio/wav";
            case ".ogg": return "audio/ogg";
            case ".doc": return "application/msword";
            case ".docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case ".xls": return "application/vnd.ms-excel";
            case ".xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            case ".ppt": return "application/vnd.ms-powerpoint";
            case ".pptx": return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
            case ".zip": return "application/zip";
            case ".rar": return "application/x-rar-compressed";
            case ".7z": return "application/x-7z-compressed";
            default: return "application/octet-stream";
        }
    }

    public bool IsReusable
    {
        get { return true; }
    }
}
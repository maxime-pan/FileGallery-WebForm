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

            // Get file extension and set content type
            string extension = Path.GetExtension(fileName).ToLower();
            string contentType = GetContentType(extension);
            
            // Set response headers
            context.Response.Clear();
            context.Response.ContentType = contentType;
            context.Response.AddHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
            context.Response.Cache.SetCacheability(HttpCacheability.Public);
            context.Response.Cache.SetExpires(DateTime.Now.AddMinutes(30));
            
            // Stream the file
            using (FileStream fs = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Read))
            {
                byte[] buffer = new byte[8192];
                int bytesRead;
                while ((bytesRead = fs.Read(buffer, 0, buffer.Length)) > 0)
                {
                    context.Response.OutputStream.Write(buffer, 0, bytesRead);
                    context.Response.Flush();
                }
            }
        }
        catch (Exception ex)
        {
            SendError(context, 500, "Error processing file: " + ex.Message);
        }
    }

    private void SendError(HttpContext context, int statusCode, string message)
    {
        context.Response.Clear();
        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "text/plain";
        context.Response.Write(message);
        context.Response.End();
    }

    private string GetContentType(string extension)
    {
        switch (extension)
        {
            case ".pdf": return "application/pdf";
            case ".txt": return "text/plain";
            case ".jpg":
            case ".jpeg": return "image/jpeg";
            case ".png": return "image/png";
            case ".gif": return "image/gif";
            case ".bmp": return "image/bmp";
            case ".mp4": return "video/mp4";
            case ".webm": return "video/webm";
            case ".mp3": return "audio/mpeg";
            case ".wav": return "audio/wav";
            case ".ogg": return "audio/ogg";
            case ".doc": return "application/msword";
            case ".docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case ".xls": return "application/vnd.ms-excel";
            case ".xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            default: return "application/octet-stream";
        }
    }

    public bool IsReusable
    {
        get { return true; }
    }
}
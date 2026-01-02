<%@ WebHandler Language="C#" Class="FileHandler" %>

using System;
using System.IO;
using System.Web;

public class FileHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        string category = context.Request.QueryString["category"];
        string fileName = context.Request.QueryString["file"];
        string type = context.Request.QueryString["type"]; // "upload" or "public"

        if (string.IsNullOrEmpty(fileName))
        {
            context.Response.StatusCode = 400;
            context.Response.Write("File name is required");
            return;
        }

        string filePath = "";
        
        if (type == "public")
        {
            filePath = context.Server.MapPath("~/PublicUploads/" + fileName);
        }
        else if (!string.IsNullOrEmpty(category))
        {
            filePath = context.Server.MapPath("~/Uploads/" + category + "/" + fileName);
        }
        else
        {
            context.Response.StatusCode = 400;
            context.Response.Write("Category is required");
            return;
        }

        if (!File.Exists(filePath))
        {
            context.Response.StatusCode = 404;
            context.Response.Write("File not found");
            return;
        }

        // Get file extension and set content type
        string extension = Path.GetExtension(fileName).ToLower();
        string contentType = GetContentType(extension);
        
        context.Response.ContentType = contentType;
        context.Response.AddHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
        context.Response.TransmitFile(filePath);
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
            default: return "application/octet-stream";
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
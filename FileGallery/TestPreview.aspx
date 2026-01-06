<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TestPreview.aspx.cs" Inherits="FileGallery.TestPreview" %>
<%@ Import Namespace="System.IO" %>

<!DOCTYPE html>
<html>
<head>
    <title>File Handler Diagnostics</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; max-width: 1200px; margin: 0 auto; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; background: #f9f9f9; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .info { color: blue; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #667eea; color: white; }
        .test-link { color: blue; text-decoration: underline; cursor: pointer; margin: 5px 0; display: block; }
    </style>
</head>
<body>
    <h1>🔍 File Handler Diagnostics</h1>
    <p>This page helps diagnose file preview issues.</p>
    
    <%
        string baseDir = Server.MapPath("~/");
        string uploadsDir = Server.MapPath("~/Uploads");
        string publicDir = Server.MapPath("~/PublicUploads");
        string dataDir = Server.MapPath("~/App_Data");
    %>
    
    <div class="section">
        <h2>1. Directory Check</h2>
        <table>
            <tr>
                <th>Path</th>
                <th>Exists</th>
                <th>Readable</th>
                <th>Files Count</th>
            </tr>
            <tr>
                <td>Base Directory: <%= baseDir %></td>
                <td><%= Directory.Exists(baseDir) ? "✓ Yes" : "✗ No" %></td>
                <td><%= Directory.Exists(baseDir) ? "✓ Yes" : "✗ No" %></td>
                <td>-</td>
            </tr>
            <tr>
                <td>Uploads: <%= uploadsDir %></td>
                <td class="<%= Directory.Exists(uploadsDir) ? "success" : "error" %>">
                    <%= Directory.Exists(uploadsDir) ? "✓ Yes" : "✗ No" %>
                </td>
                <td><%= Directory.Exists(uploadsDir) ? "✓ Yes" : "✗ No" %></td>
                <td>
                    <% if (Directory.Exists(uploadsDir)) { 
                        int count = 0;
                        foreach (var dir in Directory.GetDirectories(uploadsDir)) {
                            count += Directory.GetFiles(dir).Length;
                        }
                        Response.Write(count);
                    } else { 
                        Response.Write("N/A"); 
                    } %>
                </td>
            </tr>
            <tr>
                <td>PublicUploads: <%= publicDir %></td>
                <td class="<%= Directory.Exists(publicDir) ? "success" : "error" %>">
                    <%= Directory.Exists(publicDir) ? "✓ Yes" : "✗ No" %>
                </td>
                <td><%= Directory.Exists(publicDir) ? "✓ Yes" : "✗ No" %></td>
                <td>
                    <%= Directory.Exists(publicDir) ? Directory.GetFiles(publicDir).Length.ToString() : "N/A" %>
                </td>
            </tr>
        </table>
    </div>
    
    <div class="section">
        <h2>2. FileHandler.ashx Check</h2>
        <p>FileHandler.ashx path: <%= Server.MapPath("~/FileHandler.ashx") %></p>
        <p>Exists: <span class="<%= File.Exists(Server.MapPath("~/FileHandler.ashx")) ? "success" : "error" %>">
            <%= File.Exists(Server.MapPath("~/FileHandler.ashx")) ? "✓ Yes" : "✗ No" %>
        </span></p>
        
        <% if (!File.Exists(Server.MapPath("~/FileHandler.ashx"))) { %>
            <p class="error">⚠️ FileHandler.ashx is missing! This is required for file preview.</p>
        <% } %>
    </div>
    
    <div class="section">
        <h2>3. Available Files</h2>
        
        <% if (Directory.Exists(uploadsDir)) { 
            foreach (var categoryDir in Directory.GetDirectories(uploadsDir)) {
                string categoryName = Path.GetFileName(categoryDir);
                var files = Directory.GetFiles(categoryDir);
        %>
                <h3>Category: <%= categoryName %> (<%= files.Length %> files)</h3>
                <% if (files.Length > 0) { %>
                    <table>
                        <tr>
                            <th>File Name</th>
                            <th>Size</th>
                            <th>Test Link</th>
                        </tr>
                        <% foreach (var file in files.Take(5)) { 
                            string fileName = Path.GetFileName(file);
                            long size = new FileInfo(file).Length;
                            string handlerUrl = "FileHandler.ashx?category=" + Server.UrlEncode(categoryName) + "&file=" + Server.UrlEncode(fileName);
                        %>
                        <tr>
                            <td><%= fileName %></td>
                            <td><%= FormatFileSize(size) %></td>
                            <td>
                                <a href="<%= handlerUrl %>" target="_blank">Open in new tab</a> | 
                                <span class="test-link" onclick="testPreview('<%= handlerUrl %>', '<%= Path.GetExtension(fileName) %>', '<%= fileName %>')">Test Preview</span>
                            </td>
                        </tr>
                        <% } %>
                    </table>
                    <% if (files.Length > 5) { %>
                        <p class="info">Showing first 5 files only...</p>
                    <% } %>
                <% } else { %>
                    <p>No files in this category</p>
                <% } %>
        <%  }
        } else { %>
            <p class="error">Uploads directory not found!</p>
        <% } %>
    </div>
    
    <div class="section">
        <h2>4. Test Results</h2>
        <div id="testResults" style="background: white; padding: 10px; min-height: 100px; border: 1px solid #ccc;"></div>
    </div>
    
    <div id="previewModal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.8);">
        <div style="background-color: white; margin: 2% auto; padding: 20px; width: 90%; max-width: 1200px; max-height: 90vh; border-radius: 10px; overflow: auto;">
            <span onclick="closeModal()" style="color: #aaa; float: right; font-size: 32px; font-weight: bold; cursor: pointer;">&times;</span>
            <h2 id="previewTitle"></h2>
            <div style="margin-top: 20px; text-align: center;" id="previewContainer"></div>
        </div>
    </div>
    
    <script>
        function log(message, isError) {
            const results = document.getElementById('testResults');
            const color = isError ? 'red' : 'black';
            results.innerHTML += '<div style="color: ' + color + '; margin: 5px 0;">' + message + '</div>';
            console.log(message);
        }
        
        function testPreview(url, ext, name) {
            log('Testing preview for: ' + name);
            log('URL: ' + url);
            log('Extension: ' + ext);
            
            fetch(url)
                .then(response => {
                    log('Response status: ' + response.status);
                    log('Content-Type: ' + response.headers.get('Content-Type'));
                    if (response.ok) {
                        log('✓ File accessible', false);
                        previewFile(url, ext, name);
                    } else {
                        return response.text().then(text => {
                            log('✗ Error response: ' + text, true);
                        });
                    }
                })
                .catch(error => {
                    log('✗ Fetch error: ' + error.message, true);
                });
        }
        
        function previewFile(path, ext, name) {
            const modal = document.getElementById('previewModal');
            const container = document.getElementById('previewContainer');
            const title = document.getElementById('previewTitle');
            
            title.textContent = name;
            container.innerHTML = '';
            ext = ext.toLowerCase();
            
            if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].includes(ext)) {
                container.innerHTML = '<img src="' + path + '" style="max-width: 100%; max-height: 70vh;" onerror="alert(\'Image failed to load\')">';
            } else if (ext === '.pdf') {
                container.innerHTML = '<iframe src="' + path + '" width="100%" height="600px" style="border: none;"></iframe>';
            } else if (ext === '.txt') {
                fetch(path).then(r => r.text()).then(text => {
                    container.innerHTML = '<pre style="text-align: left; padding: 20px; background: #f5f5f5;">' + text + '</pre>';
                });
            } else {
                container.innerHTML = '<p>Preview not available. <a href="' + path + '" download>Download file</a></p>';
            }
            
            modal.style.display = 'block';
        }
        
        function closeModal() {
            document.getElementById('previewModal').style.display = 'none';
        }
    </script>
    
    <%!
        string FormatFileSize(long bytes) {
            string[] sizes = { "B", "KB", "MB", "GB" };
            double len = bytes;
            int order = 0;
            while (len >= 1024 && order < sizes.Length - 1) {
                order++;
                len = len / 1024;
            }
            return string.Format("{0:0.##} {1}", len, sizes[order]);
        }
    %>
</body>
</html>
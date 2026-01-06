<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="FileGallery.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>File Gallery</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            font-size: 28px;
            font-weight: 600;
        }
        
        .header-links {
            display: flex;
            gap: 15px;
        }
        
        .header-links a {
            color: white;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 5px;
            background: rgba(255,255,255,0.2);
            transition: all 0.3s;
        }
        
        .header-links a:hover {
            background: rgba(255,255,255,0.3);
            transform: translateY(-2px);
        }
        
        .container {
            display: flex;
            max-width: 1400px;
            margin: 30px auto;
            gap: 20px;
            padding: 0 20px;
        }
        
        .left-column {
            width: 280px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            padding: 20px;
            height: fit-content;
        }
        
        .category-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }
        
        .category-item {
            padding: 12px 15px;
            margin-bottom: 8px;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s;
            background: #f8f9fa;
            color: #555;
        }
        
        .category-item:hover {
            background: #667eea;
            color: white;
            transform: translateX(5px);
        }
        
        .category-item.active {
            background: #667eea;
            color: white;
        }
        
        .right-column {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            overflow: hidden;
            height: calc(100vh - 130px);
        }
        
        .files-section {
            flex: 2;
            padding: 30px;
            overflow-y: auto;
            border-bottom: 2px solid #e0e0e0;
        }
        
        .markdown-section {
            flex: 1;
            padding: 30px;
            overflow-y: auto;
            background: #f8f9fa;
        }
        
        .markdown-section.empty {
            display: flex;
            align-items: center;
            justify-content: center;
            color: #999;
            font-style: italic;
        }
        
        .files-title {
            font-size: 24px;
            font-weight: 600;
            color: #333;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .file-list-view {
            margin-bottom: 30px;
        }
        
        .file-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        .file-table thead {
            background: #f8f9fa;
            border-bottom: 2px solid #e0e0e0;
        }
        
        .file-table th {
            padding: 12px 15px;
            text-align: left;
            font-weight: 600;
            color: #555;
            font-size: 14px;
        }
        
        .file-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .file-table tr:hover {
            background: #f8f9fa;
        }
        
        .file-link {
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .file-link:hover {
            text-decoration: underline;
        }
        
        .file-icon-small {
            font-size: 18px;
        }
        
        .file-meta {
            color: #777;
            font-size: 13px;
        }
        
        .markdown-section {
            border-top: 1px solid #e0e0e0;
            padding-top: 30px;
            margin-top: 30px;
        }
        
        .markdown-content {
            line-height: 1.6;
            color: #333;
            font-size: 14px;
        }
        
        .markdown-content h1 {
            font-size: 22px;
            margin: 15px 0 10px 0;
            padding-bottom: 8px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .markdown-content h2 {
            font-size: 19px;
            margin: 15px 0 8px 0;
        }
        
        .markdown-content h3 {
            font-size: 17px;
            margin: 12px 0 8px 0;
        }
        
        .markdown-content p {
            margin: 8px 0;
        }
        
        .markdown-content ul, .markdown-content ol {
            margin: 8px 0;
            padding-left: 25px;
        }
        
        .markdown-content li {
            margin: 4px 0;
        }
        
        .markdown-content code {
            background: #f5f5f5;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
            font-size: 14px;
        }
        
        .markdown-content pre {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            margin: 15px 0;
        }
        
        .markdown-content pre code {
            background: none;
            padding: 0;
        }
        
        .markdown-content blockquote {
            border-left: 4px solid #667eea;
            padding-left: 15px;
            margin: 15px 0;
            color: #666;
        }
        
        .markdown-content a {
            color: #667eea;
            text-decoration: none;
        }
        
        .markdown-content a:hover {
            text-decoration: underline;
        }
        
        .markdown-content table {
            border-collapse: collapse;
            width: 100%;
            margin: 15px 0;
        }
        
        .markdown-content table th,
        .markdown-content table td {
            border: 1px solid #ddd;
            padding: 8px 12px;
            text-align: left;
        }
        
        .markdown-content table th {
            background: #f5f5f5;
            font-weight: 600;
        }
        
        .file-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
        }
        
        .file-card {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            border: 2px solid transparent;
        }
        
        .file-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            border-color: #667eea;
        }
        
        .file-icon {
            font-size: 48px;
            margin-bottom: 10px;
        }
        
        .file-name {
            font-size: 14px;
            color: #333;
            word-break: break-word;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.8);
        }
        
        .modal-content {
            background-color: white;
            margin: 2% auto;
            padding: 20px;
            width: 90%;
            max-width: 1200px;
            max-height: 90vh;
            border-radius: 10px;
            overflow: auto;
        }
        
        .close {
            color: #aaa;
            float: right;
            font-size: 32px;
            font-weight: bold;
            cursor: pointer;
            line-height: 20px;
        }
        
        .close:hover {
            color: #000;
        }
        
        .preview-container {
            margin-top: 20px;
            text-align: center;
        }
        
        .preview-container img,
        .preview-container video,
        .preview-container audio {
            max-width: 100%;
            max-height: 70vh;
        }
        
        .no-files {
            text-align: center;
            padding: 60px 20px;
            color: #999;
            font-size: 18px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="header">
            <h1>📁 File Gallery</h1>
            <div class="header-links">
                <a href="Upload.aspx">⬆️ Upload to Public</a>
                <a href="Login.aspx">🔐 Admin Login</a>
            </div>
        </div>
        
        <div class="container">
            <div class="left-column">
                <div class="category-title">Categories</div>
                <asp:Repeater ID="CategoryRepeater" runat="server">
                    <ItemTemplate>
                        <div class="category-item" onclick="location.href='?category=<%# Server.UrlEncode(Eval("Name").ToString()) %>'">
                            <%# Eval("Name") %> (<%# Eval("FileCount") %>)
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            
            <div class="right-column">
                <!-- Files Section (Upper 2/3) -->
                <div class="files-section">
                    <div class="files-title">
                        <span><asp:Literal ID="CategoryNameLiteral" runat="server" Text="All Files"></asp:Literal></span>
                        <span class="file-meta"><asp:Literal ID="FileCountLiteral" runat="server"></asp:Literal></span>
                    </div>
                    
                    <asp:Panel ID="NoFilesPanel" runat="server" CssClass="no-files" Visible="false">
                        No files found in this category.
                    </asp:Panel>
                    
                    <asp:Panel ID="FileListPanel" runat="server" CssClass="file-list-view">
                        <table class="file-table">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Size</th>
                                    <th>Modified</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="FileRepeater" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <a href="javascript:void(0)" class="file-link" onclick="previewFile('<%# Eval("FilePath") %>', '<%# Eval("Extension") %>', '<%# Eval("FileName") %>')">
                                                    <span class="file-icon-small"><%# GetFileIcon(Eval("Extension").ToString()) %></span>
                                                    <span><%# Eval("FileName") %></span>
                                                </a>
                                            </td>
                                            <td class="file-meta"><%# Eval("Size") %></td>
                                            <td class="file-meta"><%# Eval("Modified") %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </asp:Panel>
                </div>
                
                <!-- Markdown Section (Lower 1/3) -->
                <div class="markdown-section <asp:Literal ID="MarkdownEmptyClass" runat="server" Text="empty"></asp:Literal>">
                    <asp:Panel ID="MarkdownPanel" runat="server" Visible="false">
                        <div class="markdown-content">
                            <asp:Literal ID="MarkdownContent" runat="server"></asp:Literal>
                        </div>
                    </asp:Panel>
                    <asp:Panel ID="NoMarkdownPanel" runat="server" Visible="true">
                        No description available for this category.
                    </asp:Panel>
                </div>
            </div>
        </div>
        
        <div id="previewModal" class="modal">
            <div class="modal-content">
                <span class="close" onclick="closeModal()">&times;</span>
                <h2 id="previewTitle"></h2>
                <div class="preview-container" id="previewContainer"></div>
            </div>
        </div>
    </form>
    
    <script>
        function previewFile(path, ext, name) {
            console.log('Preview file:', path, ext, name);

            const modal = document.getElementById('previewModal');
            const container = document.getElementById('previewContainer');
            const title = document.getElementById('previewTitle');

            title.textContent = name;
            container.innerHTML = '<div style="padding: 20px; text-align: center;">Loading...</div>';
            modal.style.display = 'block';

            ext = ext.toLowerCase();

            if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].includes(ext)) {
                const img = new Image();
                img.onload = function () {
                    container.innerHTML = '<img src="' + path + '" style="max-width: 100%; max-height: 70vh;" alt="' + name + '">';
                };
                img.onerror = function () {
                    container.innerHTML = '<div style="padding: 40px;"><p style="color: #e74c3c; margin-bottom: 15px;">Failed to load image.</p><a href="' + path + '" download="' + name + '" style="display: inline-block; padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px;">Download File</a></div>';
                };
                img.src = path;
            } else if (['.mp4', '.webm', '.ogg'].includes(ext)) {
                container.innerHTML = '<video controls style="max-width: 100%; max-height: 70vh;"><source src="' + path + '" type="video/' + ext.substring(1) + '">Your browser does not support the video tag.</video>';
            } else if (['.mp3', '.wav'].includes(ext)) {
                container.innerHTML = '<audio controls style="width: 100%;"><source src="' + path + '" type="audio/' + (ext === '.mp3' ? 'mpeg' : 'wav') + '">Your browser does not support the audio tag.</audio>';
            } else if (ext === '.ogg') {
                container.innerHTML = '<audio controls style="width: 100%;"><source src="' + path + '" type="audio/ogg">Your browser does not support the audio tag.</audio>';
            } else if (ext === '.pdf') {
                // Use object tag with embed fallback for better PDF support
                container.innerHTML = '<object data="' + path + '" type="application/pdf" width="100%" height="600px" style="border: none;">' +
                    '<embed src="' + path + '" type="application/pdf" width="100%" height="600px" style="border: none;" />' +
                    '<div style="padding: 40px; text-align: center;">' +
                    '<p style="margin-bottom: 15px;">Your browser does not support PDF preview.</p>' +
                    '<a href="' + path + '" download="' + name + '" style="display: inline-block; padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px;">Download PDF</a>' +
                    '</div>' +
                    '</object>';
            } else if (ext === '.txt') {
                fetch(path)
                    .then(response => {
                        if (!response.ok) throw new Error('Failed to load file');
                        return response.text();
                    })
                    .then(text => {
                        container.innerHTML = '<pre style="text-align: left; padding: 20px; background: #f5f5f5; border-radius: 5px; max-height: 600px; overflow: auto; white-space: pre-wrap; word-wrap: break-word;">' + escapeHtml(text) + '</pre>';
                    })
                    .catch(error => {
                        container.innerHTML = '<div style="padding: 40px;"><p style="color: #e74c3c; margin-bottom: 15px;">Error loading file: ' + error.message + '</p><a href="' + path + '" download="' + name + '" style="display: inline-block; padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px;">Download File</a></div>';
                    });
            } else if (['.doc', '.docx'].includes(ext)) {
                container.innerHTML = '<div style="padding: 40px; text-align: center;"><p style="margin-bottom: 20px;">Preview not available for Word documents in browser.</p><a href="' + path + '" download="' + name + '" style="display: inline-block; padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px;">Download Document</a></div>';
            } else {
                container.innerHTML = '<div style="padding: 40px; text-align: center;"><p style="margin-bottom: 20px;">Preview not available for this file type.</p><a href="' + path + '" download="' + name + '" style="display: inline-block; padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px;">Download File</a></div>';
            }
        }

        function handlePdfError(iframe, path, name) {
            iframe.parentElement.innerHTML = '<div style="padding: 40px;"><p style="color: #e74c3c; margin-bottom: 15px;">Failed to load PDF.</p><a href="' + path + '" download="' + name + '" style="display: inline-block; padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px;">Download PDF</a></div>';
        }

        function closeModal() {
            document.getElementById('previewModal').style.display = 'none';
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        window.onclick = function (event) {
            const modal = document.getElementById('previewModal');
            if (event.target == modal) {
                closeModal();
            }
        }

        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') {
                closeModal();
            }
        });
    </script>
</body>
</html>
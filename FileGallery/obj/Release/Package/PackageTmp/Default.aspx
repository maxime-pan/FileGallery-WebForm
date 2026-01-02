<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="FileGallery.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            padding: 30px;
        }
        
        .files-title {
            font-size: 24px;
            font-weight: 600;
            color: #333;
            margin-bottom: 20px;
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
            <h1>File Gallery</h1>
            <div class="header-links">
                <a href="Upload.aspx">Upload to Public</a>
                <a href="Login.aspx">Admin Login</a>
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
                <div class="files-title">
                    <asp:Literal ID="CategoryNameLiteral" runat="server" Text="All Files"></asp:Literal>
                </div>
                
                <asp:Panel ID="NoFilesPanel" runat="server" CssClass="no-files" Visible="false">
                    No files found in this category.
                </asp:Panel>
                
                <div class="file-grid">
                    <asp:Repeater ID="FileRepeater" runat="server">
                        <ItemTemplate>
                            <div class="file-card" onclick="previewFile('<%# Eval("FilePath") %>', '<%# Eval("Extension") %>', '<%# Eval("FileName") %>')">
                                <div class="file-icon"><%# GetFileIcon(Eval("Extension").ToString()) %></div>
                                <div class="file-name"><%# Eval("FileName") %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
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
            const modal = document.getElementById('previewModal');
            const container = document.getElementById('previewContainer');
            const title = document.getElementById('previewTitle');
            
            title.textContent = name;
            container.innerHTML = '';
            
            ext = ext.toLowerCase();
            
            if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].includes(ext)) {
                container.innerHTML = '<img src="' + path + '" alt="' + name + '">';
            } else if (['.mp4', '.webm', '.ogg'].includes(ext)) {
                container.innerHTML = '<video controls><source src="' + path + '">Your browser does not support the video tag.</video>';
            } else if (['.mp3', '.wav', '.ogg'].includes(ext)) {
                container.innerHTML = '<audio controls><source src="' + path + '">Your browser does not support the audio tag.</audio>';
            } else if (ext === '.pdf') {
                container.innerHTML = '<embed src="' + path + '" type="application/pdf" width="100%" height="600px">';
            } else if (ext === '.txt') {
                fetch(path)
                    .then(response => response.text())
                    .then(text => {
                        container.innerHTML = '<pre style="text-align: left; padding: 20px; background: #f5f5f5; border-radius: 5px; max-height: 600px; overflow: auto;">' + escapeHtml(text) + '</pre>';
                    });
            } else {
                container.innerHTML = '<p style="padding: 40px;">Preview not available for this file type. <a href="' + path + '" download>Download file</a></p>';
            }
            
            modal.style.display = 'block';
        }
        
        function closeModal() {
            document.getElementById('previewModal').style.display = 'none';
        }
        
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        window.onclick = function(event) {
            const modal = document.getElementById('previewModal');
            if (event.target == modal) {
                closeModal();
            }
        }
    </script>
</body>
</html>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin.aspx.cs" Inherits="FileGallery.Admin" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Admin Dashboard - File Gallery</title>
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
            align-items: center;
        }
        
        .header-links a, .btn-logout {
            color: white;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 5px;
            background: rgba(255,255,255,0.2);
            transition: all 0.3s;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }
        
        .header-links a:hover, .btn-logout:hover {
            background: rgba(255,255,255,0.3);
        }
        
        .container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .section {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            padding: 30px;
            margin-bottom: 30px;
        }
        
        .section-title {
            font-size: 22px;
            font-weight: 600;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #667eea;
        }
        
        .form-row {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            align-items: end;
        }
        
        .form-group {
            flex: 1;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 500;
            font-size: 14px;
        }
        
        .form-group input, .form-group select {
            width: 100%;
            padding: 10px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 6px;
            font-size: 14px;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: #667eea;
            color: white;
        }
        
        .btn-primary:hover {
            background: #5568d3;
            transform: translateY(-2px);
        }
        
        .btn-danger {
            background: #e74c3c;
            color: white;
        }
        
        .btn-danger:hover {
            background: #c0392b;
        }
        
        .btn-success {
            background: #27ae60;
            color: white;
        }
        
        .btn-success:hover {
            background: #229954;
        }
        
        .category-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 20px;
        }
        
        .category-tag {
            background: #f0f0f0;
            padding: 8px 15px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .category-tag .btn {
            padding: 2px 8px;
            font-size: 12px;
        }
        
        .file-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        .file-table th {
            background: #f8f9fa;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #555;
            border-bottom: 2px solid #e0e0e0;
        }
        
        .file-table td {
            padding: 12px;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .file-table tr:hover {
            background: #f8f9fa;
        }
        
        .action-buttons {
            display: flex;
            gap: 8px;
        }
        
        .action-buttons .btn {
            padding: 6px 12px;
            font-size: 13px;
        }
        
        .success-message {
            background: #d4edda;
            color: #155724;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
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
        
        .public-section {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            text-align: center;
        }
        
        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
        }
        
        .stat-label {
            color: #777;
            margin-top: 5px;
        }
        
        .markdown-content {
            line-height: 1.6;
            color: #333;
        }
        
        .markdown-content h1 {
            font-size: 28px;
            margin: 20px 0 15px 0;
            padding-bottom: 10px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .markdown-content h2 {
            font-size: 24px;
            margin: 20px 0 10px 0;
        }
        
        .markdown-content h3 {
            font-size: 20px;
            margin: 15px 0 10px 0;
        }
        
        .markdown-content p {
            margin: 10px 0;
        }
        
        .markdown-content ul, .markdown-content ol {
            margin: 10px 0;
            padding-left: 30px;
        }
        
        .markdown-content li {
            margin: 5px 0;
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
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="header">
            <h1>🛠️ Admin Dashboard</h1>
            <div class="header-links">
                <span style="margin-right: 10px;">Welcome, admin</span>
                <a href="Default.aspx">🏠 Gallery</a>
                <asp:Button ID="btnLogout" runat="server" Text="🚪 Logout" CssClass="btn-logout" OnClick="btnLogout_Click" />
            </div>
        </div>
        
        <div class="container">
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-number"><asp:Literal ID="litTotalCategories" runat="server"></asp:Literal></div>
                    <div class="stat-label">Categories</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><asp:Literal ID="litTotalFiles" runat="server"></asp:Literal></div>
                    <div class="stat-label">Total Files</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><asp:Literal ID="litPublicFiles" runat="server"></asp:Literal></div>
                    <div class="stat-label">Public Uploads</div>
                </div>
            </div>
            
            <asp:Panel ID="MessagePanel" runat="server" Visible="false"></asp:Panel>
            
            <!-- Category Management -->
            <div class="section">
                <div class="section-title">📁 Category Management</div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="txtNewCategory">New Category Name</label>
                        <asp:TextBox ID="txtNewCategory" runat="server" placeholder="Enter category name"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnAddCategory" runat="server" Text="➕ Add Category" CssClass="btn btn-primary" OnClick="btnAddCategory_Click" />
                </div>
                
                <div class="category-list">
                    <asp:Repeater ID="CategoryRepeater" runat="server">
                        <ItemTemplate>
                            <div class="category-tag">
                                <span><%# Eval("Name") %> (<%# Eval("FileCount") %> files)</span>
                                <asp:Button ID="btnDeleteCategory" runat="server" 
                                    Text="✖" 
                                    CssClass="btn btn-danger" 
                                    CommandArgument='<%# Eval("Name") %>'
                                    OnClick="btnDeleteCategory_Click"
                                    OnClientClick="return confirm('Delete this category and all its files?');" />
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
            
            <!-- File Upload -->
            <div class="section">
                <div class="section-title">⬆️ Upload Files</div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="ddlUploadCategory">Select Category</label>
                        <asp:DropDownList ID="ddlUploadCategory" runat="server"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label for="fileUpload">Select Files (Multiple)</label>
                        <asp:FileUpload ID="fileUpload" runat="server" AllowMultiple="true" />
                        <small style="color: #666; display: block; margin-top: 5px;">Hold Ctrl (Cmd on Mac) to select multiple files</small>
                    </div>
                    <asp:Button ID="btnUpload" runat="server" Text="Upload Files" CssClass="btn btn-success" OnClick="btnUpload_Click" />
                </div>
            </div>
            
            <!-- Category README Management -->
            <div class="section">
                <div class="section-title">📝 Category README Upload</div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="ddlReadmeCategory">Select Category</label>
                        <asp:DropDownList ID="ddlReadmeCategory" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlReadmeCategory_SelectedIndexChanged"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label for="fileMarkdown">Upload README.md File</label>
                        <asp:FileUpload ID="fileMarkdown" runat="server" accept=".md,.txt" />
                    </div>
                    <asp:Button ID="btnUploadMarkdown" runat="server" Text="📤 Upload README" CssClass="btn btn-success" OnClick="btnUploadMarkdown_Click" />
                </div>
                
                <asp:Panel ID="CurrentMarkdownPanel" runat="server" Visible="false" style="margin-top: 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 10px; background: #e8f4f8; border-radius: 6px;">
                        <div>
                            <strong>📄 Current README:</strong> README.md
                            <span style="margin-left: 15px; color: #666;">
                                <asp:Literal ID="litMarkdownSize" runat="server"></asp:Literal>
                            </span>
                        </div>
                        <div style="display: flex; gap: 10px;">
                            <asp:Button ID="btnPreviewMarkdown" runat="server" Text="👁️ Preview" CssClass="btn btn-primary" OnClick="btnPreviewMarkdown_Click" style="padding: 6px 15px; font-size: 13px;" />
                            <asp:Button ID="btnDownloadMarkdown" runat="server" Text="⬇️ Download" CssClass="btn btn-success" OnClick="btnDownloadMarkdown_Click" style="padding: 6px 15px; font-size: 13px;" />
                            <asp:Button ID="btnDeleteMarkdown" runat="server" Text="🗑️ Delete" CssClass="btn btn-danger" OnClick="btnDeleteMarkdown_Click" 
                                OnClientClick="return confirm('Delete README.md for this category?');" style="padding: 6px 15px; font-size: 13px;" />
                        </div>
                    </div>
                </asp:Panel>
                
                <asp:Panel ID="MarkdownPreviewPanel" runat="server" Visible="false" style="margin-top: 20px; padding: 20px; background: #f9f9f9; border: 2px solid #ddd; border-radius: 6px; max-height: 400px; overflow-y: auto;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                        <h3 style="margin: 0;">Preview:</h3>
                        <span style="cursor: pointer; font-size: 20px;" onclick="document.getElementById('<%= MarkdownPreviewPanel.ClientID %>').style.display='none'">✖</span>
                    </div>
                    <div class="markdown-content">
                        <asp:Literal ID="MarkdownPreview" runat="server"></asp:Literal>
                    </div>
                </asp:Panel>
                
                <div style="margin-top: 15px; padding: 10px; background: #e8f4f8; border-left: 4px solid #3498db; font-size: 13px;">
                    <strong>💡 Instructions:</strong>
                    <ul style="margin: 5px 0 0 20px; padding: 0;">
                        <li>Select a category from the dropdown</li>
                        <li>Choose a <strong>.md</strong> or <strong>.txt</strong> file containing markdown content</li>
                        <li>Click "Upload README" to upload</li>
                        <li>The README will display in the lower 1/3 of the category view</li>
                        <li>Supports: headers (#), bold (**text**), italic (*text*), lists (- item), links ([text](url))</li>
                    </ul>
                </div>
            </div>
            
            <!-- File Management -->
            <div class="section">
                <div class="section-title">📄 Manage Files</div>
                
                <table class="file-table">
                    <thead>
                        <tr>
                            <th>File Name</th>
                            <th>Category</th>
                            <th>Size</th>
                            <th>Upload Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="FileRepeater" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%# Eval("FileName") %></td>
                                    <td><%# Eval("Category") %></td>
                                    <td><%# Eval("Size") %></td>
                                    <td><%# Eval("UploadDate") %></td>
                                    <td>
                                        <div class="action-buttons">
                                            <button type="button" class="btn btn-primary" 
                                                onclick="previewFile('<%# Eval("FilePath") %>', '<%# Eval("Extension") %>', '<%# Eval("FileName") %>')">
                                                👁️ Preview
                                            </button>
                                            <asp:Button ID="btnDeleteFile" runat="server" 
                                                Text="🗑️ Delete" 
                                                CssClass="btn btn-danger" 
                                                CommandArgument='<%# Eval("FullPath") %>'
                                                OnClick="btnDeleteFile_Click"
                                                OnClientClick="return confirm('Delete this file?');" />
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            
            <!-- Public Uploads -->
            <div class="section public-section">
                <div class="section-title">📤 Public Uploads (Moderation Queue)</div>
                
                <table class="file-table">
                    <thead>
                        <tr>
                            <th>File Name</th>
                            <th>Size</th>
                            <th>Upload Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="PublicFileRepeater" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%# Eval("FileName") %></td>
                                    <td><%# Eval("Size") %></td>
                                    <td><%# Eval("UploadDate") %></td>
                                    <td>
                                        <div class="action-buttons">
                                            <button type="button" class="btn btn-primary" 
                                                onclick="previewFile('<%# Eval("FilePath") %>', '<%# Eval("Extension") %>', '<%# Eval("FileName") %>')">
                                                👁️ Preview
                                            </button>
                                            <a href="<%# Eval("FilePath") %>" download class="btn btn-success">⬇️ Download</a>
                                            <asp:Button ID="btnDeletePublicFile" runat="server" 
                                                Text="🗑️ Delete" 
                                                CssClass="btn btn-danger" 
                                                CommandArgument='<%# Eval("FullPath") %>'
                                                OnClick="btnDeletePublicFile_Click"
                                                OnClientClick="return confirm('Delete this file?');" />
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>
        
        <div id="previewModal" class="modal">
            <div class="modal-content">
                <span class="close" onclick="closeModal()">&times;</span>
                <h2 id="previewTitle"></h2>
                <div style="margin-top: 20px; text-align: center;" id="previewContainer"></div>
            </div>
        </div>
    </form>
    
    <script>
        function previewFile(path, ext, name) {
            console.log('Preview file:', path, ext, name); // Debug log

            const modal = document.getElementById('previewModal');
            const container = document.getElementById('previewContainer');
            const title = document.getElementById('previewTitle');

            title.textContent = name;
            container.innerHTML = '';

            ext = ext.toLowerCase();

            if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].includes(ext)) {
                container.innerHTML = '<img src="' + path + '" style="max-width: 100%; max-height: 70vh;" alt="' + name + '" onerror="handleImageError(this)">';
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
                        container.innerHTML = '<p style="padding: 40px; color: #e74c3c;">Error loading file: ' + error.message + '</p>';
                    });
            } else if (['.doc', '.docx'].includes(ext)) {
                container.innerHTML = '<div style="padding: 40px; text-align: center;"><p style="margin-bottom: 20px;">Preview not available for Word documents in browser.</p><a href="' + path + '" download class="btn btn-primary" style="display: inline-block; padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px;">Download Document</a></div>';
            } else {
                container.innerHTML = '<div style="padding: 40px; text-align: center;"><p style="margin-bottom: 20px;">Preview not available for this file type.</p><a href="' + path + '" download class="btn btn-primary" style="display: inline-block; padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px;">Download File</a></div>';
            }

            modal.style.display = 'block';
        }

        function handleImageError(img) {
            img.style.display = 'none';
            img.parentElement.innerHTML += '<p style="color: #e74c3c; padding: 20px;">Failed to load image. <a href="' + img.src + '" download>Download instead</a></p>';
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

        // Add keyboard support for closing modal
        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') {
                closeModal();
            }
        });
    </script>
</body>
</html>
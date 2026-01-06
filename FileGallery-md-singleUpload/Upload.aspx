<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Upload.aspx.cs" Inherits="FileGallery.Upload" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Upload to Public - File Gallery</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        .header {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            color: white;
            padding: 20px 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .header h1 {
            font-size: 28px;
            font-weight: 600;
        }
        
        .container {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .upload-box {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 600px;
        }
        
        .upload-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .upload-header h2 {
            font-size: 28px;
            color: #333;
            margin-bottom: 10px;
        }
        
        .upload-header p {
            color: #777;
            font-size: 14px;
        }
        
        .info-box {
            background: #e8f4f8;
            border-left: 4px solid #3498db;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 25px;
            font-size: 14px;
            color: #555;
        }
        
        .upload-area {
            border: 3px dashed #d0d0d0;
            border-radius: 10px;
            padding: 40px;
            text-align: center;
            margin-bottom: 25px;
            transition: all 0.3s;
            cursor: pointer;
            background: #fafafa;
        }
        
        .upload-area:hover {
            border-color: #667eea;
            background: #f5f5ff;
        }
        
        .upload-area.dragover {
            border-color: #667eea;
            background: #f0f0ff;
            transform: scale(1.02);
        }
        
        .upload-icon {
            font-size: 64px;
            margin-bottom: 15px;
        }
        
        .upload-text {
            font-size: 18px;
            color: #555;
            margin-bottom: 10px;
        }
        
        .upload-subtext {
            font-size: 14px;
            color: #999;
        }
        
        .file-input {
            display: none;
        }
        
        .selected-file {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .selected-file-icon {
            font-size: 32px;
        }
        
        .selected-file-info {
            flex: 1;
        }
        
        .selected-file-name {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }
        
        .selected-file-size {
            font-size: 13px;
            color: #777;
        }
        
        .btn {
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        
        .btn-primary:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }
        
        .success-message {
            background: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
        }
        
        .back-link {
            text-align: center;
            margin-top: 20px;
        }
        
        .back-link a {
            color: #667eea;
            text-decoration: none;
            font-size: 14px;
        }
        
        .back-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="header">
            <h1>📤 Upload to Public Folder</h1>
        </div>
        
        <div class="container">
            <div class="upload-box">
                <div class="upload-header">
                    <h2>Share Your Files</h2>
                    <p>Upload files to the public folder for admin review</p>
                </div>
                
                <div class="info-box">
                    ℹ️ Files uploaded here will be reviewed by administrators before being published to the gallery.
                </div>
                
                <asp:Panel ID="MessagePanel" runat="server" Visible="false"></asp:Panel>
                
                <div class="upload-area" id="uploadArea" onclick="document.getElementById('fileUpload').click();">
                    <div class="upload-icon">📁</div>
                    <div class="upload-text">Click to select a file</div>
                    <div class="upload-subtext">or drag and drop here</div>
                </div>
                
                <asp:FileUpload ID="fileUpload" runat="server" CssClass="file-input" onchange="handleFileSelect(this)" />
                
                <div id="selectedFileDiv" style="display: none;">
                    <div class="selected-file">
                        <div class="selected-file-icon">📄</div>
                        <div class="selected-file-info">
                            <div class="selected-file-name" id="fileName"></div>
                            <div class="selected-file-size" id="fileSize"></div>
                        </div>
                    </div>
                </div>
                
                <asp:Button ID="btnUpload" runat="server" Text="Upload File" CssClass="btn btn-primary" OnClick="btnUpload_Click" />
                
                <div class="back-link">
                    <a href="Default.aspx">← Back to Gallery</a>
                </div>
            </div>
        </div>
    </form>
    
    <script>
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('fileUpload');
        const selectedFileDiv = document.getElementById('selectedFileDiv');

        // Prevent default drag behaviors
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            uploadArea.addEventListener(eventName, preventDefaults, false);
            document.body.addEventListener(eventName, preventDefaults, false);
        });

        function preventDefaults(e) {
            e.preventDefault();
            e.stopPropagation();
        }

        // Highlight drop area
        ['dragenter', 'dragover'].forEach(eventName => {
            uploadArea.addEventListener(eventName, highlight, false);
        });

        ['dragleave', 'drop'].forEach(eventName => {
            uploadArea.addEventListener(eventName, unhighlight, false);
        });

        function highlight(e) {
            uploadArea.classList.add('dragover');
        }

        function unhighlight(e) {
            uploadArea.classList.remove('dragover');
        }

        // Handle dropped files
        uploadArea.addEventListener('drop', handleDrop, false);

        function handleDrop(e) {
            const dt = e.dataTransfer;
            const files = dt.files;

            if (files.length > 0) {
                // Set the file to the file input
                fileInput.files = files;
                handleFileSelect(fileInput);
            }
        }

        function handleFileSelect(input) {
            if (input.files && input.files[0]) {
                const file = input.files[0];
                document.getElementById('fileName').textContent = file.name;
                document.getElementById('fileSize').textContent = formatFileSize(file.size);
                selectedFileDiv.style.display = 'block';
            }
        }

        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
        }
    </script>
</body>
</html>
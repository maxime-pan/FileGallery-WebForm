<%@ Page Language="C#" AutoEventWireup="true" %>

<!DOCTYPE html>
<html>
<head>
    <title>Test File Preview</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .test-section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; }
        .test-link { display: block; margin: 10px 0; color: blue; text-decoration: underline; cursor: pointer; }
    </style>
</head>
<body>
    <h1>File Preview Test Page</h1>
    
    <div class="test-section">
        <h2>Test Direct File Access</h2>
        <p>Test if FileHandler.ashx is working:</p>
        <a href="FileHandler.ashx?category=General&file=test.txt" target="_blank">Test FileHandler (test.txt in General category)</a>
    </div>
    
    <div class="test-section">
        <h2>Test Preview Function</h2>
        <p>Click to test preview modal:</p>
        <div class="test-link" onclick="testPreview()">Test Image Preview (sample.jpg)</div>
        <div class="test-link" onclick="testPreviewPDF()">Test PDF Preview (sample.pdf)</div>
    </div>
    
    <div class="test-section">
        <h2>Console Logs</h2>
        <p>Open browser console (F12) to see debug information</p>
        <div id="output" style="background: #f5f5f5; padding: 10px; margin-top: 10px; min-height: 100px;"></div>
    </div>
    
    <script>
        function log(message) {
            console.log(message);
            const output = document.getElementById('output');
            output.innerHTML += message + '<br>';
        }
        
        function testPreview() {
            log('Testing image preview...');
            const path = 'FileHandler.ashx?category=General&file=sample.jpg';
            log('Path: ' + path);
            
            // Test if we can fetch it
            fetch(path)
                .then(response => {
                    log('Response status: ' + response.status);
                    log('Response type: ' + response.headers.get('Content-Type'));
                    if (response.ok) {
                        log('✓ File accessible!');
                        // Now test preview
                        previewFile(path, '.jpg', 'sample.jpg');
                    } else {
                        log('✗ File not accessible');
                    }
                })
                .catch(error => {
                    log('✗ Error: ' + error.message);
                });
        }
        
        function testPreviewPDF() {
            log('Testing PDF preview...');
            const path = 'FileHandler.ashx?category=General&file=sample.pdf';
            previewFile(path, '.pdf', 'sample.pdf');
        }
        
        function previewFile(path, ext, name) {
            log('previewFile called with: ' + path + ', ' + ext + ', ' + name);
            
            const modal = document.getElementById('previewModal');
            const container = document.getElementById('previewContainer');
            const title = document.getElementById('previewTitle');
            
            if (!modal) {
                log('✗ Modal not found!');
                alert('Preview modal not found. Creating it...');
                createModal();
                return;
            }
            
            title.textContent = name;
            container.innerHTML = '';
            
            ext = ext.toLowerCase();
            log('Processing extension: ' + ext);
            
            if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].includes(ext)) {
                log('Creating image preview');
                container.innerHTML = '<img src="' + path + '" style="max-width: 100%; max-height: 70vh;" alt="' + name + '" onload="console.log(\'Image loaded\')" onerror="console.log(\'Image load error\')">';
            } else if (ext === '.pdf') {
                log('Creating PDF preview');
                container.innerHTML = '<iframe src="' + path + '" width="100%" height="600px" style="border: none;"></iframe>';
            }
            
            modal.style.display = 'block';
            log('Modal displayed');
        }
        
        function createModal() {
            const modalHTML = `
                <div id="previewModal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.8);">
                    <div style="background-color: white; margin: 2% auto; padding: 20px; width: 90%; max-width: 1200px; max-height: 90vh; border-radius: 10px; overflow: auto;">
                        <span onclick="document.getElementById('previewModal').style.display='none'" style="color: #aaa; float: right; font-size: 32px; font-weight: bold; cursor: pointer;">&times;</span>
                        <h2 id="previewTitle"></h2>
                        <div style="margin-top: 20px; text-align: center;" id="previewContainer"></div>
                    </div>
                </div>
            `;
            document.body.insertAdjacentHTML('beforeend', modalHTML);
            log('Modal created');
        }
        
        // Check if modal exists on load
        window.onload = function() {
            const modal = document.getElementById('previewModal');
            if (modal) {
                log('✓ Preview modal found on page');
            } else {
                log('✗ Preview modal NOT found on page');
                createModal();
            }
        };
    </script>
    
    <div id="previewModal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.8);">
        <div style="background-color: white; margin: 2% auto; padding: 20px; width: 90%; max-width: 1200px; max-height: 90vh; border-radius: 10px; overflow: auto;">
            <span onclick="document.getElementById('previewModal').style.display='none'" style="color: #aaa; float: right; font-size: 32px; font-weight: bold; cursor: pointer; line-height: 20px;">&times;</span>
            <h2 id="previewTitle"></h2>
            <div style="margin-top: 20px; text-align: center;" id="previewContainer"></div>
        </div>
    </div>
</body>
</html>
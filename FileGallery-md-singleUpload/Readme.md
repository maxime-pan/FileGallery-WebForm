# File Gallery Web Application

A comprehensive ASP.NET Web Forms application for managing and sharing files with category organization, admin management, and public uploads.

## Features

### For All Visitors
- Browse files organized by categories
- Preview files in-browser (PDF, images, videos, audio, text files)
- Upload files to a public folder for admin review
- Clean, modern, and responsive interface

### For Administrators
- Secure login (username: `admin`, password: `Admin@123`)
- Complete category management (create, delete)
- File management (upload, delete, preview)
- Move files between categories
- Review and manage public uploads
- Dashboard with statistics
- Download and backup capabilities

## Technical Requirements

- **Web Server**: IIS 7.0 or higher
- **.NET Framework**: 4.7.2 or higher
- **Operating System**: Windows Server 2012 R2 or higher (or Windows 10/11 with IIS)

## Project Structure

```
FileGallery/
├── Default.aspx              # Main gallery page
├── Default.aspx.cs
├── Login.aspx                # Admin login page
├── Login.aspx.cs
├── Admin.aspx                # Admin dashboard
├── Admin.aspx.cs
├── Upload.aspx               # Public upload page
├── Upload.aspx.cs
├── Web.config                # Application configuration
├── Uploads/                  # Category-based file storage
│   └── General/              # Default category
├── PublicUploads/            # Public upload folder (admin-only access)
└── App_Data/                 # Application data
    └── categories.txt        # Category list
```

## Deployment Instructions

### Step 1: Install IIS and ASP.NET

1. Open **Server Manager** (Windows Server) or **Control Panel** → **Programs** → **Turn Windows features on or off** (Windows 10/11)
2. Enable:
   - **Internet Information Services**
   - **Web Management Tools** → **IIS Management Console**
   - **.NET Framework 4.7 (or higher)** → **ASP.NET 4.7**
   - **Application Development Features** → **ASP.NET 4.7**

### Step 2: Prepare the Application

1. Create a folder on your server (e.g., `C:\inetpub\FileGallery`)
2. Copy all application files to this folder:
   - All `.aspx` files
   - All `.aspx.cs` files (code-behind)
   - `Web.config`
3. Create the following folders if they don't exist:
   - `Uploads\General\`
   - `PublicUploads\`
   - `App_Data\`

### Step 3: Configure IIS

1. Open **IIS Manager**
2. Right-click **Sites** → **Add Website**
3. Configure the new website:
   - **Site name**: FileGallery
   - **Physical path**: C:\inetpub\FileGallery
   - **Binding**: 
     - Type: http
     - IP address: Your server IP or "All Unassigned"
     - Port: 80 (or your preferred port)
4. Click **OK**

### Step 4: Set Permissions

1. Right-click the FileGallery folder in Windows Explorer
2. Select **Properties** → **Security** tab
3. Click **Edit** → **Add**
4. Add `IIS_IUSRS` and `IUSR` accounts
5. Grant **Modify** permissions to:
   - `Uploads` folder
   - `PublicUploads` folder
   - `App_Data` folder

### Step 5: Configure Application Pool

1. In IIS Manager, select **Application Pools**
2. Find your application pool (usually named after your site)
3. Right-click → **Advanced Settings**
4. Set:
   - **.NET CLR Version**: v4.0
   - **Managed Pipeline Mode**: Integrated
   - **Identity**: ApplicationPoolIdentity

### Step 6: Test the Application

1. Open a browser and navigate to `http://your-server-ip/` or `http://your-domain/`
2. You should see the File Gallery home page
3. Test admin login:
   - Click "Admin Login"
   - Username: `admin`
   - Password: `Admin@123`

## Configuration Options

### Change Upload Size Limits

Edit `Web.config`:

```xml
<!-- Maximum upload size in KB (100MB = 102400 KB) -->
<httpRuntime maxRequestLength="102400" />

<!-- Maximum upload size in bytes (100MB = 104857600 bytes) -->
<requestLimits maxAllowedContentLength="104857600" />
```

### Change Admin Credentials

Edit `Login.aspx.cs`, modify line:

```csharp
if (username == "admin" && password == "Admin@123")
```

For production, consider implementing:
- Hashed passwords
- Database-backed authentication
- Multiple admin accounts

### Add More File Types

The application supports preview for:
- **Documents**: PDF, DOC, DOCX, TXT
- **Images**: JPG, JPEG, PNG, GIF, BMP
- **Video**: MP4, WEBM, OGG
- **Audio**: MP3, WAV, OGG

To add more types, edit the `GetFileIcon` method in code-behind files.

## Security Recommendations

### For Production Deployment:

1. **Enable HTTPS**: Configure SSL certificate in IIS
2. **Strong Passwords**: Change default admin password
3. **File Type Validation**: Add server-side file type checking
4. **File Size Limits**: Adjust based on your needs
5. **Request Filtering**: Configure IIS request filtering
6. **Error Handling**: Set `customErrors mode="RemoteOnly"` in Web.config
7. **Session Security**: Use secure session configuration
8. **Regular Backups**: Backup the `Uploads` and `App_Data` folders

### Firewall Configuration:

1. Open Windows Firewall
2. Allow inbound connections on port 80 (HTTP) and 443 (HTTPS)
3. Configure specific IP restrictions if needed

## Troubleshooting

### Application Won't Start
- Verify .NET Framework 4.7.2 is installed
- Check Application Pool is running
- Review IIS logs: `C:\inetpub\logs\LogFiles`

### Upload Fails
- Check folder permissions (IIS_IUSRS needs Modify access)
- Verify `maxRequestLength` and `maxAllowedContentLength` settings
- Check available disk space

### Files Not Displaying
- Verify MIME types are configured in IIS
- Check file permissions
- Ensure files exist in correct folder structure

### Preview Not Working
- Check browser console for JavaScript errors
- Verify file extensions match supported types
- Ensure static content is enabled in IIS

## Maintenance

### Backup Files
Regularly backup:
- `Uploads\` folder (all categories)
- `PublicUploads\` folder
- `App_Data\categories.txt`

### Monitor Disk Space
- Check available disk space regularly
- Implement file retention policies
- Consider archiving old files

### Update Categories
Categories are stored in `App_Data\categories.txt`. You can manually edit this file if needed (one category per line).

## Support & Enhancement Ideas

### Potential Enhancements:
- User registration and authentication
- File versioning
- Bulk upload capability
- Advanced search functionality
- File tagging system
- Usage analytics
- Email notifications for uploads
- File compression/thumbnails
- Integration with cloud storage

## License

This is a custom-built application. Modify and use according to your needs.

## Author

Created as a comprehensive file gallery solution for web deployment.
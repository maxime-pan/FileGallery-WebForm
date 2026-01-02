# File Gallery - Complete Project Structure

## Directory Structure

Create the following folder structure:

```
FileGallery/
│
├── FileGallery.sln                    # Solution file
│
└── FileGallery/                       # Project folder
    ├── FileGallery.csproj             # Project file
    ├── Web.config                     # Configuration file
    │
    ├── Default.aspx                   # Main gallery page
    ├── Default.aspx.cs                # Main gallery code-behind
    │
    ├── Login.aspx                     # Admin login page
    ├── Login.aspx.cs                  # Login code-behind
    │
    ├── Admin.aspx                     # Admin dashboard
    ├── Admin.aspx.cs                  # Admin code-behind
    │
    ├── Upload.aspx                    # Public upload page
    ├── Upload.aspx.cs                 # Upload code-behind
    │
    ├── Properties/
    │   └── AssemblyInfo.cs            # Assembly information
    │
    ├── App_Data/                      # Application data (auto-created)
    │   └── categories.txt             # Categories list (auto-created)
    │
    ├── Uploads/                       # File storage (auto-created)
    │   └── General/                   # Default category (auto-created)
    │
    └── PublicUploads/                 # Public uploads (auto-created)
```

## Files to Download/Create

### Root Level Files:
1. **FileGallery.sln** - Solution file (see artifact)

### FileGallery Project Folder:
2. **FileGallery.csproj** - Project file (see artifact)
3. **Web.config** - Configuration (see artifact)
4. **Default.aspx** - Main page (see artifact)
5. **Default.aspx.cs** - Main page code (see artifact)
6. **Login.aspx** - Login page (see artifact)
7. **Login.aspx.cs** - Login code (see artifact)
8. **Admin.aspx** - Admin page (see artifact)
9. **Admin.aspx.cs** - Admin code (see artifact)
10. **Upload.aspx** - Upload page (see artifact)
11. **Upload.aspx.cs** - Upload code (see artifact)

### Properties Folder:
12. **Properties/AssemblyInfo.cs** - Assembly info (see artifact)

## Step-by-Step Setup Instructions

### 1. Create Project Structure

```batch
mkdir FileGallery
cd FileGallery
mkdir FileGallery
cd FileGallery
mkdir Properties
mkdir App_Data
mkdir Uploads
mkdir Uploads\General
mkdir PublicUploads
```

### 2. Copy Files

Copy each file from the artifacts into the appropriate folder according to the structure above.

### 3. Open in Visual Studio

1. Double-click `FileGallery.sln`
2. Visual Studio will open the solution
3. Build the solution (Ctrl+Shift+B)

### 4. Run Locally

**Option A: IIS Express (in Visual Studio)**
- Press F5 or click "Start Debugging"
- The application will open in your browser

**Option B: Local IIS**
1. Open IIS Manager
2. Right-click "Sites" → "Add Website"
3. Set physical path to your FileGallery\FileGallery folder
4. Configure binding (port 8080 or your preference)
5. Browse to http://localhost:8080

## Publishing for Production

### Method 1: Publish from Visual Studio

1. Right-click the **FileGallery** project → **Publish**
2. Choose **Folder** as publish target
3. Select output folder (e.g., `C:\Publish\FileGallery`)
4. Click **Publish**
5. Copy published files to your production server

### Method 2: Manual Deploy

1. Build solution in **Release** mode
2. Copy these folders/files to production:
   - All `.aspx` files
   - All `.aspx.cs` files (if not compiled into DLL)
   - `Web.config`
   - `bin/` folder (contains compiled DLLs)
   - Create empty folders: `App_Data/`, `Uploads/General/`, `PublicUploads/`

### Method 3: Web Deploy Package

1. Right-click project → **Publish**
2. Choose **Web Deploy Package**
3. Configure package settings
4. Generate package (.zip file)
5. Import package on production IIS

## Production Server Setup

### 1. Install Prerequisites
- Windows Server 2012 R2 or higher
- IIS 7.5 or higher
- .NET Framework 4.7.2 or higher

### 2. Configure IIS
```powershell
# Enable IIS features (PowerShell as Administrator)
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45
```

### 3. Create Website in IIS
1. Open IIS Manager
2. Right-click "Sites" → "Add Website"
3. Configure:
   - **Site name**: FileGallery
   - **Physical path**: C:\inetpub\FileGallery
   - **Binding**: 
     - Type: http
     - IP: Your server IP
     - Port: 80
     - Host name: (optional)

### 4. Set Permissions
```powershell
# Grant IIS permissions (PowerShell as Administrator)
icacls "C:\inetpub\FileGallery\App_Data" /grant "IIS_IUSRS:(OI)(CI)M"
icacls "C:\inetpub\FileGallery\Uploads" /grant "IIS_IUSRS:(OI)(CI)M"
icacls "C:\inetpub\FileGallery\PublicUploads" /grant "IIS_IUSRS:(OI)(CI)M"
```

### 5. Configure Application Pool
1. Select **Application Pools**
2. Find your app pool → **Advanced Settings**
3. Set:
   - **.NET CLR Version**: v4.0
   - **Managed Pipeline Mode**: Integrated
   - **Identity**: ApplicationPoolIdentity

### 6. Test
- Browse to http://your-server-ip/
- Test admin login: username=`admin`, password=`Admin@123`

## Configuration Options

### Change Upload Limits
Edit `Web.config`:
```xml
<!-- 100MB = 102400 KB -->
<httpRuntime maxRequestLength="102400" executionTimeout="3600" />

<!-- 100MB = 104857600 bytes -->
<requestLimits maxAllowedContentLength="104857600" />
```

### Change Admin Credentials
Edit `Login.aspx.cs`, line 23:
```csharp
if (username == "admin" && password == "Admin@123")
```

### Enable HTTPS
1. Obtain SSL certificate
2. In IIS, edit Site Bindings
3. Add HTTPS binding with certificate
4. Update `Web.config`:
```xml
<system.webServer>
  <rewrite>
    <rules>
      <rule name="HTTP to HTTPS redirect" stopProcessing="true">
        <match url="(.*)" />
        <conditions>
          <add input="{HTTPS}" pattern="off" ignoreCase="true" />
        </conditions>
        <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" redirectType="Permanent" />
      </rule>
    </rules>
  </rewrite>
</system.webServer>
```

## Troubleshooting

### Build Errors
- Ensure .NET Framework 4.7.2 is installed
- Check all references are resolved
- Clean solution, then rebuild

### Runtime Errors
- Check IIS application pool is started
- Verify folder permissions
- Review IIS logs: `C:\inetpub\logs\LogFiles`
- Check Windows Event Viewer

### Upload Issues
- Verify `maxRequestLength` and `maxAllowedContentLength` settings
- Check folder permissions (IIS_IUSRS needs Modify)
- Ensure sufficient disk space

## Support Files

All code files have been provided in the artifacts. Simply copy each artifact's content into the appropriate file according to the structure above.

## Default Login Credentials

- **Username**: admin
- **Password**: Admin@123

**⚠️ IMPORTANT**: Change these credentials before deploying to production!

## Next Steps

1. Create the folder structure
2. Copy all files from artifacts
3. Open solution in Visual Studio
4. Build and test locally
5. Publish to production server
6. Configure IIS and permissions
7. Test all functionality
8. Change admin password!

Good luck with your deployment! 🚀
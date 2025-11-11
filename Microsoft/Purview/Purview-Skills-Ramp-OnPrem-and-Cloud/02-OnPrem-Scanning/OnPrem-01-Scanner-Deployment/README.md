# OnPrem-01: Purview Information Protection Scanner Deployment

## 🎯 Lab Objectives

- Install Purview Information Protection scanner client on Windows Server 2022.
- Configure scanner cluster in Purview portal with authentication credentials.
- Install and configure scanner database using PowerShell cmdlets.
- Set up scanner authentication with service account and app registration.
- Verify scanner installation and cluster configuration.
- Understand scanner architecture and authentication flow.

## ⏱️ Estimated Duration

1.5-2 hours

## 📋 Prerequisites

- All Setup labs completed (Setup-01, Setup-02, Setup-03).
- Windows Server 2022 VM with SQL Server Express (from Setup-02).
- Service account and app registration credentials (from Setup-03).
- RDP access to Windows Server 2022 VM.
- Admin access to Purview portal.

## 🏗️ Scanner Architecture Overview

The Purview Information Protection scanner consists of:

- **Scanner Client**: Installed on Windows Server, performs actual file scanning
- **SQL Database**: Stores scanner configuration and scan results
- **App Registration**: Entra ID application for delegated authentication (created in Setup-03)
- **Scanner Cluster**: Logical grouping of scanner nodes (we'll create one node)
- **Service Account**: Runs scanner service, requires M365 licensing (created in Setup-03)

**Authentication Flow**:

1. Scanner service runs as service account (`scanner-svc`)
2. Uses app registration (`Purview-Scanner-App`) for delegated API access
3. Connects to Purview compliance center for policy/label downloads
4. Scans on-premises repositories (SMB shares, SQL databases, SharePoint on-prem)

## 🚀 Lab Steps

### Step 1: Download and Install Information Protection Client

**On your VM (vm-purview-scanner):**

Navigate to the Microsoft Download Center to get the latest unified labeling client.

- Open **Microsoft Edge** browser.
- Navigate to: [https://www.microsoft.com/en-us/download/details.aspx?id=53018](https://www.microsoft.com/en-us/download/details.aspx?id=53018).
- Download: **PurviewInformationProtection.exe** (Unified Labeling client).

> **💡 Tip**: This is the unified labeling client that replaces the legacy Azure Information Protection client. Ensure you download the latest version for compatibility with current Purview features.

**Run Installation:**

- Locate the downloaded **PurviewInformationProtection.exe** file.
- Right-click and select **Run as administrator**.
- Accept the license terms when prompted.
- Use the default installation path: `C:\Program Files (x86)\Microsoft Azure Information Protection`.
- Click **Install** to begin installation.
- Complete the installation wizard.
- Restart the VM if prompted.

**Verify Installation:**

> **💡 PowerShell Environment Refresh Required**: After installing the Purview Information Protection client, you must close any open Windows PowerShell windows and reopen Windows PowerShell **as Administrator** before the `PurviewInformationProtection` module will be recognized. This is because the installer registers the PowerShell module, but existing PowerShell sessions do not automatically reload the module registry. Opening a new administrative PowerShell session ensures the module is available.

Open PowerShell as Administrator and verify the installation:

```powershell
# Close current Windows PowerShell window (if open)
# Right-click Windows PowerShell > Run as Administrator
# Check if the client installed successfully by verifying the installation folder
Test-Path "C:\Program Files (x86)\Microsoft Purview Information Protection"

# List installed files in the installation directory
Get-ChildItem "C:\Program Files (x86)\Microsoft Purview Information Protection" | Select-Object Name, Length, LastWriteTime

# Check the viewer application version (main client component)
(Get-Item "C:\Program Files (x86)\Microsoft Purview Information Protection\MSIP.Viewer.exe").VersionInfo

# Check if PurviewInformationProtection module is available
Get-Module -ListAvailable -Name PurviewInformationProtection
```

> **✅ Installation Success Criteria**: 
>
> - Installation folder exists (Test-Path returns `True`)
> - MSIP.Viewer.exe shows version information
> - PurviewInformationProtection module appears in Get-Module -ListAvailable
>
> **If all three checks pass, your installation is complete and correct - proceed to Step 2!**

---

### Step 2: Create Scanner Cluster in Purview Portal

Scanner clusters organize scanner nodes and manage scanning operations centrally through the Purview portal.

**Navigate to Purview Portal:**

- On your main device (not VM), open browser and go to the **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com).
- Sign in with your **admin account** (not scanner-svc).
- Navigate to **Settings** > **Information protection** > **Information protection scanner**.
  - Click the **Settings** card (gear icon) or use the settings menu
  - Select **Information protection** from the left navigation
  - Then select **Information protection scanner**

> **💡 Portal Note**: The Microsoft Purview portal interface was redesigned in 2024. The scanner configuration is now accessed through Settings > Information protection. The steps below reflect the current portal as of October 2025.

> **⚠️ Azure Information Protection Client Requirement**: When you access the **Information protection scanner** page, you may see a notice that "The information protection scanner uses Azure Information Protection. To access this functionality, first deploy Azure Information Protection from the Microsoft Download Center."
>
> **If you see this message on your admin machine**, you'll need to install the Azure Information Protection client (completed in Step 1) on the admin workstation you're using to access the Purview portal. The scanner functionality in the portal requires the client to be installed on the machine where you're performing the configuration, not just on the scanner VM.
>
> **To resolve**: Download and install the Purview Information Protection client from Step 1 on your admin machine, then refresh the Purview portal page.

**Create Scanner Cluster:**

From the **Information protection scanner** page:

- Select the **Clusters** tab at the top.
- Click **Add** button (or **+ Add** icon).
- **Cluster name**: `Lab-Scanner-Cluster`
- **Description** (optional): `Weekend lab scanner for on-prem file shares and Azure Files`
- Click **Save** to create the cluster.

> **📚 Background**: Scanner clusters can contain multiple scanner nodes for distributed scanning in large environments. For this lab, we'll use a single node.

---

### Step 3: Create Content Scan Job

Content scan jobs define what to scan, when to scan, and what policies to apply during scanning.

**Still in Purview Portal > Information Protection Scanner:**

- Select the **Content scan jobs** tab.
- Click **+ Add** to create a new scan job.
- **Content scan job name**: `Lab-OnPrem-Scan`
- **Description**: `Discovery scan for lab file shares and Azure Files`
- **Select cluster**: **Lab-Scanner-Cluster** (from dropdown)

**Configure Scan Job Settings:**

- **Schedule**: **Manual** (for testing; use scheduled scans in production)
- **Info types to be discovered**: **Policy only** (uses SITs defined in your tenant's DLP policies)
- **Configure repositories**: Leave empty for now (we'll add these in OnPrem-02 after scanner installation)
- Click **Save**.

> **💡 Production Tip**: For production deployments, configure scheduled scans during off-peak hours to minimize impact on file server performance.

---

### Step 4: Install Scanner on VM

The scanner installation creates a Windows service that executes scans and stores configuration in SQL Server.

> **Important**: the earlier step to install Microsoft Office iFilter is **required on Windows Server** to scan .zip files for sensitive information types. This must be installed BEFORE running Install-Scanner.

**On VM, open PowerShell as Administrator:**

```powershell
# Download Microsoft Office iFilter (64-bit)
Write-Host "📥 Downloading Microsoft Office iFilter..." -ForegroundColor Cyan
$downloadUrl = "https://download.microsoft.com/download/0/A/2/0A28BBFA-CBFA-4C03-A739-30CCA5E21659/FilterPack64bit.exe"
$installerPath = "$env:TEMP\FilterPack64bit.exe"

Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

# Install Office iFilter (silent installation)
Write-Host "📦 Installing Office iFilter..." -ForegroundColor Cyan
Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart" -Wait

# Verify installation
Write-Host "✅ Verifying Office iFilter installation..." -ForegroundColor Green
$iFilter = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*Office*Filter*"}
if ($iFilter) {
    Write-Host "   Office iFilter installed: $($iFilter.Name)" -ForegroundColor Green
} else {
    Write-Host "   WARNING: Office iFilter not detected!" -ForegroundColor Yellow
}
```

> **⚠️ Important**: After installing Office iFilter, **close and reopen PowerShell** for the changes to take effect before proceeding with scanner installation.

#### Create Local Scanner Service Account

The scanner uses **two different accounts** for different purposes:

1. **Local Windows Account** (`COMPUTERNAME\scanner-svc`): Runs the scanner Windows service on the VM
2. **Entra ID Account** (`scanner-svc@yourtenant.onmicrosoft.com`): Authenticates to Purview APIs and downloads policies

> **💡 Why Two Accounts?**
> 
> - **Local account**: Required to run the Windows service (Install-Scanner uses this)
> - **Entra ID account**: Required to authenticate to Microsoft Purview and Azure Rights Management (Set-Authentication uses this in Step 5)
> - This "alternative configuration" approach is used when you can't synchronize AD accounts to Entra ID

**Create the local Windows account:**

```powershell
# Prompt for secure password (you'll create your own)
Write-Host "📋 Create a password for the local scanner-svc account" -ForegroundColor Cyan
Write-Host "   Password requirements:" -ForegroundColor Yellow
Write-Host "   - At least 8 characters" -ForegroundColor Yellow
Write-Host "   - Include uppercase, lowercase, numbers, and symbols" -ForegroundColor Yellow
Write-Host ""

$password = Read-Host "Enter password for scanner-svc" -AsSecureString
$passwordConfirm = Read-Host "Confirm password" -AsSecureString

# Convert SecureString to plain text for net user command
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Create local Windows account
Write-Host "👤 Creating local account: scanner-svc..." -ForegroundColor Cyan
net user scanner-svc $plainPassword /add

# Add to local Administrators group (required for scanner installation)
Write-Host "🔐 Adding scanner-svc to Administrators group..." -ForegroundColor Cyan
net localgroup Administrators scanner-svc /add

# Verify account was created
Write-Host "✅ Verifying account creation..." -ForegroundColor Green
net user scanner-svc

Write-Host ""
Write-Host "✅ Local scanner service account created successfully!" -ForegroundColor Green
Write-Host "   Account: $env:COMPUTERNAME\scanner-svc" -ForegroundColor Cyan
Write-Host "   Save this password - you'll need it for Install-Scanner!" -ForegroundColor Yellow
```

> **💡 Account Configuration**:
> 
> - **Account name**: `scanner-svc` (local to this VM)
> - **Full name format**: `COMPUTERNAME\scanner-svc` (e.g., `VM-PURVIEW-SCANNER\scanner-svc`)
> - **Permissions**: Local Administrator (required during installation and configuration)
> - **Service rights**: "Log on as a service" is automatically granted during Install-Scanner
> - **Important**: This is DIFFERENT from your Entra ID scanner-svc@tenant account!

#### Install Scanner Service Using Windows PowerShell 5.1

**CRITICAL: The PurviewInformationProtection module is NOT compatible with PowerShell 7.** You must use **Windows PowerShell 5.1** for scanner installation.

**Verify you're using Windows PowerShell 5.1:**

```powershell
# Check PowerShell version - should show 5.1.x
$PSVersionTable.PSVersion
```

**Install the Scanner Service:**

> **⚠️ Important: Verify Actual Computer Name**
>
> Windows has a 15-character limit for computer names. If you named your VM `vm-purview-scanner` in Azure (17 characters), Windows automatically truncated it during installation.
>
> **Before running Install-Scanner, verify the ACTUAL computer name on the VM**:
>
> - Option 1: Run `$env:COMPUTERNAME` in PowerShell
> - Option 2: Right-click Start > **System** > Check "Device name"
> - Option 3: Open **Settings** > **System** > **About** > Check "Device name"
>
> **Example**: Azure resource name `vm-purview-scanner` becomes `vm-purview-scan` (15 chars)
>
> Use the ACTUAL computer name (from the VM) in the credential prompt, not the Azure resource name.

```powershell
# FIRST: Get your actual computer name (critical for credential format)
Write-Host "Your actual computer name is: $env:COMPUTERNAME" -ForegroundColor Cyan
Write-Host "Use this format in credential prompt: $env:COMPUTERNAME\scanner-svc" -ForegroundColor Yellow
Write-Host ""

# Create credential object with COMPUTERNAME\username format
$cred = Get-Credential

# When prompted, enter credentials in this exact format:
# Username: COMPUTERNAME\scanner-svc (use the ACTUAL computer name from above)
# Password: [Your scanner-svc password]

# Run Install-Scanner with explicit credentials
Install-Scanner -SqlServerInstance localhost\SQLEXPRESS -Cluster Lab-Scanner-Cluster -ServiceUserCredentials $cred
```

> **💡 Command Explanation**:
>
> - `-SqlServerInstance localhost\SQLEXPRESS` - Specifies the local SQL Server Express instance
> - `-Cluster Lab-Scanner-Cluster` - Associates with the cluster created in Purview portal (Step 2)
> - `-ServiceUserCredentials $cred` - Provides the local account credentials for the Windows service
> - **Username format is critical**: Must be `COMPUTERNAME\scanner-svc`, not just `scanner-svc` or `.\scanner-svc`

**Expected Success Output:**

```
Running a transacted installation.

Beginning the Install phase of the installation.
Installing service MIPScanner...
Service MIPScanner has been successfully installed.
Creating EventLog source MIPScanner in log Application...

The Install phase completed successfully, and the Commit phase is beginning.
The Commit phase completed successfully.
The transacted install has completed.
```

> **✅ Success Indicators**:
> 
> - "Service MIPScanner has been successfully installed"
> - "The transacted install has completed"
> - No rollback or error messages

**Verify Scanner Service Installation:**

```powershell
# Check that the scanner service was created
Get-Service -Name "MIPScanner"

# Expected output:
# Status: Stopped or Running
# Name: MIPScanner
# DisplayName: Microsoft Purview Information Protection Scanner
```

> **✅ Success Indicators**:
>
> - **Status: Stopped** - Normal if authentication hasn't been configured yet (service starts after Step 5)
> - **Status: Running** - Also valid! This means the service started successfully (possibly because authentication was already configured, or the service auto-started)
> - Either status indicates successful installation - the key is that the service exists

---

### Step 5: Authenticate Scanner

Scanner authentication uses the app registration credentials (from Setup-03) to acquire tokens for Purview API access.

> **💡 Two-Account Authentication Model**:
>
> In Step 4, you created a **local Windows account** (`COMPUTERNAME\scanner-svc`) to run the scanner SERVICE.
>
> Now in Step 5, you'll also reference your **Entra ID account** (`scanner-svc@yourtenant.onmicrosoft.com` from Setup-03) to access Purview APIs.
>
> **Why both accounts are needed**:
>
> - **Local account**: Runs the Windows service on the VM (already configured in Step 4)
> - **Entra ID account**: Authenticates to Microsoft Purview compliance portal and Azure Rights Management APIs
> - This is Microsoft's "alternative configuration" for environments without Active Directory synchronization

**On VM, in Windows PowerShell 5.1 as Administrator:**

> **💡 Running as Your Admin Account**:
>
> You can run scanner commands from your regular admin account (e.g., `labadmin`) without logging off. Use the `-OnBehalfOf` parameter to execute commands in the scanner service account's security context.
>
> This approach:
>
> - Keeps you logged in as your admin account
> - Stores authentication tokens in the correct user profile (scanner service account)
> - Avoids repeated logoff/logon actions

**Before running Set-Authentication, follow these preparation steps:**

**Step 1: Verify your actual computer name** (critical for credential format)

```powershell
# Display your actual computer name
Write-Host "Your actual computer name is: $env:COMPUTERNAME" -ForegroundColor Cyan
Write-Host "You will use this in the script: $env:COMPUTERNAME\scanner-svc" -ForegroundColor Yellow
```

> **⚠️ Important**: Due to Windows 15-character limit, your computer name may differ from the Azure VM name. For example, `vm-purview-scanner` becomes `vm-purview-scan`. Use the ACTUAL computer name shown above.

**Step 2: Copy the PowerShell script to Notepad and update placeholders**:

- Copy the script below to **Notepad** (or your preferred text editor).
- Replace ALL placeholder values with your actual values from Setup-03:
  - `YOUR-ACTUAL-COMPUTERNAME` → Your computer name from Step 1 (e.g., `vm-purview-scan`)
  - `YOUR-APP-ID-FROM-SETUP-03` → Application (client) ID from Setup-03
  - `YOUR-SECRET-VALUE-FROM-SETUP-03` → Client secret value from Setup-03
  - `YOUR-TENANT-ID-FROM-SETUP-03` → Directory (tenant) ID from Setup-03
  - `scanner-svc@yourtenant.onmicrosoft.com` → Your Entra ID scanner account UPN from Setup-03

```powershell
# Create credentials for the scanner service account (you'll be prompted for password)
$scannerCreds = Get-Credential YOUR-ACTUAL-COMPUTERNAME\scanner-svc

# Set authentication using the Entra ID account and app registration credentials
# Using -OnBehalfOf ensures tokens are cached under the scanner account profile
Set-Authentication `
    -AppId "YOUR-APP-ID-FROM-SETUP-03" `
    -AppSecret "YOUR-SECRET-VALUE-FROM-SETUP-03" `
    -TenantId "YOUR-TENANT-ID-FROM-SETUP-03" `
    -DelegatedUser "scanner-svc@yourtenant.onmicrosoft.com" `
    -OnBehalfOf $scannerCreds
```

**Step 3: Run the updated script**:

- Copy your updated script from Notepad.
- Paste into PowerShell window.
- Press **Enter** to execute.

**Step 4: Enter LOCAL credentials in the authentication pop-up**:

When the `Get-Credential` dialog appears:

- **Username**: `YOUR-ACTUAL-COMPUTERNAME\scanner-svc` (the LOCAL Windows account)
  - Example: `vm-purview-scan\scanner-svc`
  - **NOT** the Entra ID account (scanner-svc@tenant.onmicrosoft.com)
- **Password**: The password you created for the LOCAL scanner-svc account (from Step 4)

> **⚠️ Critical**: The credential prompt is asking for the **LOCAL Windows account** credentials (`COMPUTERNAME\scanner-svc`), NOT your Entra ID account. The Entra ID account is specified in the `-DelegatedUser` parameter within the script itself.

**Expected Success Output:**

```text
Acquired access token on behalf of vm-purview-scanner\scanner-svc.
```

> **✅ Success Indicators**:
>
> - Message shows "Acquired access token on behalf of"
> - Shows your local scanner service account name
> - No error messages about authentication failure

**Troubleshooting Authentication:**

If authentication fails:

```powershell
# Verify app registration exists
az ad app list --display-name "Purview-Scanner-App"

# Check app permissions (should show UnifiedGroupMember.Read.All and InformationProtectionPolicy.Read)
az ad app permission list --id "YOUR-APP-ID"

# Verify Entra ID service account exists
az ad user show --id "scanner-svc@yourtenant.onmicrosoft.com"

# Check if admin consent was granted for app permissions
az ad app permission admin-consent --id "YOUR-APP-ID"
```

**If you see "TokenCache is missing" error:**

This error occurs when authentication tokens aren't cached in the scanner service account's profile. Re-run `Set-Authentication` with the `-OnBehalfOf` parameter using your ACTUAL computer name:

```powershell
# Re-authenticate using OnBehalfOf parameter
# Replace YOUR-ACTUAL-COMPUTERNAME with your actual computer name (e.g., vm-purview-scan)
$scannerCreds = Get-Credential YOUR-ACTUAL-COMPUTERNAME\scanner-svc

Set-Authentication `
    -AppId "YOUR-APP-ID" `
    -AppSecret "YOUR-SECRET-VALUE" `
    -TenantId "YOUR-TENANT-ID" `
    -DelegatedUser "scanner-svc@yourtenant.onmicrosoft.com" `
    -OnBehalfOf $scannerCreds
```

> **💡 Credential Reminder**: When the `Get-Credential` prompt appears, enter your **LOCAL Windows account** credentials (COMPUTERNAME\scanner-svc with the local account password), NOT your Entra ID account credentials.

**Verify Authentication with Diagnostics:**

```powershell
# Run scanner diagnostics to verify authentication and configuration
# Use OnBehalfOf to execute in scanner account context
Start-ScannerDiagnostics -OnBehalfOf $scannerCreds

# Expected output should show:
# - All connectivity checks completed successfully
# - Database check completed successfully
# - Authentication check completed successfully
# - Content scan job check completed successfully
# - Configuration check completed successfully
```

**Verify Scanner Service Status:**

After successful authentication, verify the scanner service is running:

```powershell
# Check scanner service status
Get-Service -Name "MIPScanner"

# Expected output:
# Status: Running
# Name: MIPScanner
# DisplayName: Microsoft Purview Information Protection Scanner

# If service is not running, start it
Start-Service -Name "MIPScanner"

# Verify it started successfully
Get-Service -Name "MIPScanner"
```

> **✅ Success Indicators**:
>
> - Service **Status** shows **Running**
> - No errors when starting the service
> - Service remains running (doesn't stop immediately after starting)
>
> If the service fails to start, check Event Viewer (Applications and Services Logs > Microsoft > AIP) for detailed error messages.

---

## ✅ Validation Checklist

Before proceeding to OnPrem-02 (Discovery Scans), verify:

### Step 1: Scanner Client Installation

- [ ] Purview Information Protection scanner client installed successfully
- [ ] Installation folder exists: `C:\Program Files (x86)\Microsoft Purview Information Protection`
- [ ] MSIP.Viewer.exe shows version information
- [ ] PurviewInformationProtection module available: `Get-Module -ListAvailable -Name PurviewInformationProtection`
- [ ] PowerShell restarted after installation (module recognition)

### Step 2: Scanner Cluster in Purview Portal

- [ ] Scanner cluster created in Purview portal
- [ ] Cluster name: `Lab-Scanner-Cluster` (or your chosen name)
- [ ] Cluster visible in Settings > Information protection > Information protection scanner

### Step 3: Content Scan Job

- [ ] Content scan job created: `Lab-OnPrem-Scan`
- [ ] Scan job associated with `Lab-Scanner-Cluster`
- [ ] Schedule set to **Manual**
- [ ] Info types set to **Policy only**

### Step 4: Scanner Service Installation

- [ ] Office iFilter installed (required for .zip scanning)
- [ ] Local scanner service account created: `COMPUTERNAME\scanner-svc`
- [ ] Account added to local Administrators group
- [ ] `Install-Scanner` cmdlet completed successfully
- [ ] Scanner service created: `MIPScanner` (check `Get-Service -Name "MIPScanner"`)
- [ ] SQL Server Express instance accessible: `localhost\SQLEXPRESS`

### Step 5: Scanner Authentication

- [ ] `Set-Authentication` completed successfully with `-OnBehalfOf` parameter
- [ ] Authentication message: "Acquired access token on behalf of..."
- [ ] No error messages about token generation
- [ ] Scanner service status: Running (check `Get-Service -Name "MIPScanner"`)
- [ ] `Start-ScannerDiagnostics` shows all checks passed

## 🔍 Troubleshooting

### SQL Server connection fails during Install-Scanner

**Symptoms**: Error about SQL Server access or database creation

**Solutions**:

1. **Verify SQL Server service running**: Services > SQL Server (SQLEXPRESS) should be "Running"
2. **Check TCP/IP enabled** (from Setup-02): SQL Server Configuration Manager
3. **Test local connection**: `sqlcmd -S localhost\SQLEXPRESS -Q "SELECT @@VERSION"`
4. **Verify scanner service account permissions**: Should have sysadmin or db_creator role
5. **Check SQL instance name**: Use exactly `localhost\SQLEXPRESS` (not just `localhost`)
6. **Firewall**: Ensure SQL Server port 1433 not blocked locally
7. **Wait and retry**: Sometimes SQL takes a few minutes after boot to be fully ready

### Set-Authentication fails with token error

**Symptoms**: Cannot create authentication token for delegated access

**Solutions**:

1. **Verify app registration details**: Client ID and tenant ID must be exact
2. **Check client secret validity**: Secret must not be expired
3. **Admin consent required**: API permissions must have green checkmark admin consent
4. **Run as scanner service account**: Sign in as scanner-svc account or use `-AppId` and `-AppSecret` parameters
5. **Clear previous tokens**: Delete `%LocalAppData%\Microsoft\MSIP\mip\[user]\mip.policies.sqlite3`
6. **Check internet connectivity**: Scanner needs to reach login.microsoftonline.com
7. **Time synchronization**: Ensure server time is accurate (token validation issue)

### Scanner service won't start

**Symptoms**: AIPScanner service fails to start or stops immediately

**Solutions**:

1. **Check Event Viewer**: Applications and Services Logs > Azure Information Protection
2. **Verify service account password**: Service properties > Log On tab
3. **Confirm SQL database access**: Service account must connect to SQL
4. **Check authentication token**: `Set-Authentication` must have succeeded
5. **Validate cluster configuration**: Verify scanner connected to cluster in Purview portal
6. **Database permissions**: Scanner account needs db_owner on AIPScanner_* database
7. **Restart after config changes**: Stop service, update config, start service

## 📝 Scanner Configuration Documentation Template

```plaintext
Purview Scanner Configuration
==============================
Cluster Name: PurviewScannerCluster
Scanner Node: [VM-NAME]
SQL Server: localhost\SQLEXPRESS
Database: AIPScanner_PurviewScannerCluster

App Registration Details:
- Name: Purview Scanner Client.
- Application ID: [GUID].
- Client Secret: [DOCUMENTED SECURELY].
- Tenant ID: [GUID].
- API Permissions: InformationProtectionPolicy.Read.All (Delegated).

Service Account: scanner-svc@[tenant].onmicrosoft.com
Service Status: Running
Installation Date: [Date]
```

## ⏭️ Next Steps

Scanner deployed successfully! You now have:

- ✅ Purview Information Protection scanner client installed.
- ✅ Scanner cluster created in Purview portal.
- ✅ Content scan job configured for manual discovery scans.
- ✅ Scanner service installed and authenticated.
- ✅ Scanner ready to scan on-premises repositories.

Proceed to **[OnPrem-02: Discovery Scans](../OnPrem-02-Discovery-Scans/README.md)** to configure repository connections, execute your first discovery scan, and analyze scanner results.

## 📚 Reference Documentation

- [Purview Information Protection scanner deployment](https://learn.microsoft.com/en-us/purview/deploy-scanner)
- [Scanner prerequisites and requirements](https://learn.microsoft.com/en-us/purview/deploy-scanner-prereqs)
- [Configure scanner using PowerShell](https://learn.microsoft.com/en-us/purview/deploy-scanner-configure-install)
- [Entra ID app registration](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)
- [Scanner authentication with app registration](https://learn.microsoft.com/en-us/purview/deploy-scanner-manage#azure-ad-app-based-authentication)

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Purview scanner installation and configuration while maintaining technical accuracy for on-premises data discovery scenarios.*

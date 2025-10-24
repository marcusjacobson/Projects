# Lab 01: Information Protection Scanner Deployment

## 📋 Overview

**Duration**: 4 hours

**Objective**: Deploy and configure Microsoft Purview Information Protection Scanner to discover sensitive data in on-premises file shares and Azure Files.

**What You'll Learn:**
- Install and configure the Purview Information Protection client
- Create and configure Entra ID app registrations for scanner authentication
- Deploy scanner cluster and content scan jobs in Purview portal
- Execute discovery scans and analyze results

**Prerequisites from Lab 00:**
- ✅ Azure VM running with SQL Express configured
- ✅ SMB shares created with sample sensitive data
- ✅ Entra ID service account (scanner-svc) with E5 Compliance license
- ✅ Azure CLI installed on VM

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

1. Install Microsoft Purview Information Protection client on Windows Server
2. Create Entra ID app registrations with appropriate API permissions
3. Configure scanner clusters and content scan jobs in Purview portal
4. Authenticate scanner using service principal credentials
5. Add on-premises and cloud repositories for scanning
6. Execute discovery scans and interpret results
7. Review scanner logs and CSV reports for sensitive data findings

---

## 📖 Step-by-Step Instructions

### Step 1: Download and Install Information Protection Client

**On your VM (vm-purview-scanner):**

Navigate to the Microsoft Download Center to get the latest unified labeling client.

- Open **Microsoft Edge** browser
- Navigate to: https://www.microsoft.com/en-us/download/details.aspx?id=53018
- Download: **PurviewInformationProtection.exe** (Unified Labeling client)

> **💡 Tip**: This is the unified labeling client that replaces the legacy Azure Information Protection client. Ensure you download the latest version for compatibility with current Purview features.

**Run Installation:**

- Locate the downloaded **PurviewInformationProtection.exe** file
- Right-click and select **Run as administrator**
- Accept the license terms when prompted
- Use the default installation path: `C:\Program Files (x86)\Microsoft Azure Information Protection`
- Click **Install** to begin installation
- Complete the installation wizard
- Restart the VM if prompted

**Verify Installation:**

Open PowerShell as Administrator and verify the installation:

```powershell
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
> - Installation folder exists (Test-Path returns `True`)
> - MSIP.Viewer.exe shows version information
> - PurviewInformationProtection module appears in Get-Module -ListAvailable
> 
> **If all three checks pass, your installation is complete and correct - proceed to Step 2!**

---

### Step 2: Create App Registration for Scanner Authentication

Scanner authentication requires an Entra ID app registration with specific API permissions. This enables the scanner to run unattended with service principal credentials.

**On your local machine (Microsoft Entra Admin Center):**

Navigate to Microsoft Entra ID to create the app registration.

- Sign in to the **Microsoft Entra admin center**: [https://entra.microsoft.com](https://entra.microsoft.com)
  - Alternatively, you can access this through **Azure Portal** > **Microsoft Entra ID**
- If you have access to multiple tenants, use the **Settings** icon in the top menu to switch to the correct tenant
- Browse to **Entra ID** > **App registrations**
- Select **New registration**

> **💡 Portal Note**: As of October 2025, Microsoft recommends using the Entra admin center (entra.microsoft.com) for app registrations. The Azure Portal still supports this functionality as well.

**Configure Application Registration:**

- **Name**: `Purview-Scanner-App` (users will see this name; can be changed later)
- **Supported account types**: **Accounts in this organizational directory only** (Single tenant - recommended for most applications)
- **Redirect URI** (optional for scanner): 
  - Type: **Web**
  - Value: `http://localhost`
- Click **Register** to complete the app registration

**Save Application Details:**

After registration completes, note the following values (you'll need them later):

- **Application (client) ID**: Copy and save this GUID
- **Directory (tenant) ID**: Copy and save this GUID

> **⚠️ Important**: Store these values securely. You'll need them for scanner authentication in Step 6.

---

### Step 3: Create Client Secret

Client secrets provide credentials for service principal authentication.

**In the Purview-Scanner-App registration:**

- Navigate to **Certificates & secrets** in the left menu
- Click **+ New client secret**
- **Description**: `Scanner-Secret`
- **Expires**: **12 months** (recommended for lab; use shorter duration for production)
- Click **Add**

**Save Secret Value:**

> **🚨 CRITICAL**: The secret value is only shown ONCE immediately after creation.

- **IMMEDIATELY COPY** the secret **Value** (not the Secret ID)
- Save this securely in a password manager or secure note
- You cannot retrieve this value later

---

### Step 4: Configure API Permissions

The scanner requires specific API permissions to read and write content metadata and sync policies.

**Add Azure Rights Management Permissions:**

- In the app registration, go to **API permissions**
- Click **+ Add a permission**
- Select **Azure Rights Management Services**
- Select **Application permissions**
- Check the following permissions:
  - **Content.DelegatedReader**
  - **Content.DelegatedWriter**
- Click **Add permissions**

**Add Microsoft Information Protection Sync Service Permissions:**

- Click **+ Add a permission** again
- Select **APIs my organization uses** tab
- Search for: `Microsoft Information Protection Sync Service`
- Select it from the results
- Select **Application permissions**
- Check: **UnifiedPolicy.Tenant.Read**
- Click **Add permissions**

**Add Azure Storage Permissions (for Azure Files scanning):**

If you plan to scan Azure Files shares (as configured in Lab 00), add storage permissions:

- Click **+ Add a permission** again
- Select **APIs my organization uses** tab
- Search for: `Azure Storage`
- Select **Azure Storage** from the results
- Select **Delegated permissions**
- Check: **user_impersonation**
- Click **Add permissions**

> **💡 Azure Files Note**: For scanning Azure Files shares, you'll also need to assign the **Storage File Data SMB Share Contributor** RBAC role to your scanner service account (`scanner-svc@tenant.onmicrosoft.com`) on the Azure Files share. This is done in the Azure Portal under the storage account's Access Control (IAM) settings.

**Grant Admin Consent:**

- Click **Grant admin consent for [Your Tenant Name]**
- Click **Yes** to confirm the consent prompt
- Verify all permissions show **green checkmarks** under the Status column

> **📊 Best Practice**: In production environments, document all API permissions granted and review them periodically as part of security audits.

---

### Step 5: Create Scanner Cluster in Purview Portal

Scanner clusters organize scanner nodes and manage scanning operations centrally through the Purview portal.

**Navigate to Purview Portal:**

- Open browser and go to the **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com)
- Sign in with your **admin account** (not scanner-svc)
- Navigate to **Settings** > **Information protection** > **Information protection scanner**
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

- Select the **Clusters** tab at the top
- Click **Add** button (or **+ Add** icon)
- **Cluster name**: `Lab-Scanner-Cluster`
- **Description** (optional): `Weekend lab scanner for on-prem file shares and Azure Files`
- Click **Save** to create the cluster

> **📚 Background**: Scanner clusters can contain multiple scanner nodes for distributed scanning in large environments. For this lab, we'll use a single node.

---

### Step 6: Create Content Scan Job

Content scan jobs define what to scan, when to scan, and what policies to apply during scanning.

**Still in Purview Portal > Information Protection Scanner:**

- Select the **Content scan jobs** tab
- Click **+ Add** to create a new scan job
- **Content scan job name**: `Lab-OnPrem-Scan`
- **Description**: `Discovery scan for lab file shares and Azure Files`
- **Select cluster**: **Lab-Scanner-Cluster** (from dropdown)

**Configure Scan Job Settings:**

- **Schedule**: **Manual** (for testing; use scheduled scans in production)
- **Info types to be discovered**: **Policy only** (uses SITs defined in your tenant's DLP policies)
- **Configure repositories**: Leave empty for now (we'll add these after scanner installation)
- Click **Save**

> **💡 Production Tip**: For production deployments, configure scheduled scans during off-peak hours to minimize impact on file server performance.

---

### Step 7: Install Scanner on VM

The scanner installation creates a Windows service that executes scans and stores configuration in SQL Server.

#### Install Microsoft Office iFilter (Required Prerequisite)

Microsoft Office iFilter is **required on Windows Server** to scan .zip files for sensitive information types. This must be installed BEFORE running Install-Scanner.

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
> - **Entra ID account**: Required to authenticate to Microsoft Purview and Azure Rights Management (Set-Authentication uses this in Step 8)
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

**On VM, close any PowerShell 7 sessions and open Windows PowerShell 5.1:**

- Search for **"Windows PowerShell"** (blue icon, NOT the black PowerShell 7 icon)
- Right-click **Windows PowerShell**
- Select **Run as Administrator**

**Verify you're using Windows PowerShell 5.1:**

```powershell
# Check PowerShell version - should show 5.1.x
$PSVersionTable.PSVersion
```

> **⚠️ Critical**: If the version shows 7.x.x, you're in the wrong PowerShell! Close that window and open **Windows PowerShell 5.1** (the blue icon). The PurviewInformationProtection module will fail to load in PowerShell 7 with "Could not load file or assembly 'MSIP.Scanner'" error.

**Install the Scanner Service:**

```powershell
# Create credential object with COMPUTERNAME\username format
$cred = Get-Credential

# When prompted, enter credentials in this exact format:
# Username: COMPUTERNAME\scanner-svc (e.g., VM-PURVIEW-SCANNER\scanner-svc)
# Password: YourSecurePassword123!
# 
# To get your computer name, run: $env:COMPUTERNAME

# Run Install-Scanner with explicit credentials
Install-Scanner -SqlServerInstance localhost\SQLEXPRESS -Cluster Lab-Scanner-Cluster -ServiceUserCredentials $cred
```

> **💡 Command Explanation**:
>
> - `-SqlServerInstance localhost\SQLEXPRESS` - Specifies the local SQL Server Express instance
> - `-Cluster Lab-Scanner-Cluster` - Associates with the cluster created in Purview portal (Step 5)
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
> - **Status: Stopped** - Normal if authentication hasn't been configured yet (service starts after Step 8)
> - **Status: Running** - Also valid! This means the service started successfully (possibly because authentication was already configured, or the service auto-started)
> - Either status indicates successful installation - the key is that the service exists

### Step 8: Authenticate Scanner

Scanner authentication uses the app registration credentials to acquire tokens for Purview API access.

> **💡 Two-Account Authentication Model**:
>
> In Step 7, you created a **local Windows account** (`COMPUTERNAME\scanner-svc`) to run the scanner SERVICE.
>
> Now in Step 8, you'll authenticate using your **Entra ID account** (`scanner-svc@yourtenant.onmicrosoft.com`) to access Purview APIs.
>
> **Why both accounts are needed**:
> 
> - **Local account**: Runs the Windows service on the VM (already configured in Step 7)
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

```powershell
# Create credentials for the scanner service account (you'll be prompted for password)
$scannerCreds = Get-Credential vm-purview-scanner\scanner-svc

# Set authentication using the Entra ID account and app registration credentials
# Using -OnBehalfOf ensures tokens are cached under the scanner account profile
Set-Authentication `
    -AppId "YOUR-APP-ID-FROM-STEP-2" `
    -AppSecret "YOUR-SECRET-VALUE-FROM-STEP-3" `
    -TenantId "YOUR-TENANT-ID-FROM-STEP-2" `
    -DelegatedUser "scanner-svc@yourtenant.onmicrosoft.com" `
    -OnBehalfOf $scannerCreds
```

**Replace the placeholder values:**

- `YOUR-APP-ID-FROM-STEP-2`: Application (client) ID from app registration
- `YOUR-SECRET-VALUE-FROM-STEP-3`: Client secret value you saved
- `YOUR-TENANT-ID-FROM-STEP-2`: Directory (tenant) ID from app registration
- `scanner-svc@yourtenant.onmicrosoft.com`: Your **Entra ID** scanner service account UPN (from Lab 00, Step 5)
- `vm-purview-scanner\scanner-svc`: Your local scanner service account (computer name\username format)

> **⚠️ Important**: Use the **Entra ID account** (scanner-svc@tenant.onmicrosoft.com) in the `-DelegatedUser` parameter, NOT the local Windows account (COMPUTERNAME\scanner-svc). The Entra ID account is required to download policies and authenticate to Purview services.

**Expected Success Output:**

```text
Acquired access token on behalf of vm-purview-scanner\scanner-svc.
```

> **✅ Success Indicators**:
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

This error occurs when authentication tokens aren't cached in the scanner service account's profile. Re-run `Set-Authentication` with the `-OnBehalfOf` parameter:

```powershell
# Re-authenticate using OnBehalfOf parameter
$scannerCreds = Get-Credential vm-purview-scanner\scanner-svc

Set-Authentication `
    -AppId "YOUR-APP-ID" `
    -AppSecret "YOUR-SECRET-VALUE" `
    -TenantId "YOUR-TENANT-ID" `
    -DelegatedUser "scanner-svc@yourtenant.onmicrosoft.com" `
    -OnBehalfOf $scannerCreds
```

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

---

### Step 9: Add Repositories to Scan Job

Repositories define the UNC paths or Azure Files shares the scanner will scan for sensitive data.

**Back in Purview Portal:**

- Navigate to **Information protection scanner** > **Content scan jobs**
- Click on **Lab-OnPrem-Scan** (the job you created in Step 6)
- Select the **Repositories** tab
- Click **+ Add**

**Add Each Repository:**

Add the following repositories one at a time:

> **💡 Important - UNC Path Format**: Use your **actual computer name** or `localhost` for the UNC paths. The scanner runs locally on the VM and needs to resolve the network paths correctly.
>
> **To find your actual computer name**, run this command on your VM:
> ```powershell
> $env:COMPUTERNAME
> ```
> Then use that exact name in your UNC paths (e.g., if your computer is named `my-scanner-vm`, use `\\my-scanner-vm\Finance`).
>
> **Examples below show `vm-purview-scanner` - replace with YOUR actual computer name if it is different!**

**Repository 1 - Finance Share:**

- **UNC Path**: `\\vm-purview-scanner\Finance` (or `\\localhost\Finance`)
- Click **Save**

**Repository 2 - HR Share:**

- **UNC Path**: `\\vm-purview-scanner\HR` (or `\\localhost\HR`)
- Click **Save**

**Repository 3 - Projects Share:**

- **UNC Path**: `\\vm-purview-scanner\Projects` (or `\\localhost\Projects`)
- Click **Save**

**Repository 4 - Azure Files Share:**

- **UNC Path**: `\\[storageaccount].file.core.windows.net\nasuni-simulation`
- Replace `[storageaccount]` with your storage account name from Lab 00
- Click **Save**

> **✅ Verification**: After adding all repositories, verify they appear in the Repositories tab with correct UNC paths.

**Update Scanner Configuration:**

After adding repositories in the Purview portal, you **MUST** update the local scanner to download the new configuration:

**On VM, in Windows PowerShell 5.1 as Administrator:**

```powershell
# Update scanner configuration from Purview portal
# This downloads the repository settings and scan job configuration
Update-AIPScanner

# When prompted: "Do you want to stop service 'Microsoft Purview Information Protection Scanner'?"
# Type: Y (Yes)
# The service will stop temporarily to update configuration, then restart automatically
```

**Expected Success Output:**

```text
The Microsoft Purview Information Protection Scanner was successfully updated. 
Your cluster is set to Lab-Scanner-Cluster.

To configure the scanner, use the Microsoft Purview compliance portal.

For more information, see updating the Microsoft Purview Information Protection scanner 
(https://learn.microsoft.com/purview/deploy-scanner-configure-install) from the admin guide.
```

> **✅ Success Indicators**:
> 
> - "The Microsoft Purview Information Protection Scanner was successfully updated"
> - Shows your cluster name: "Lab-Scanner-Cluster"
> - No error messages

**Restart Scanner Service:**

After the update completes, manually restart the scanner service to ensure the new configuration is loaded:

```powershell
# Restart the scanner service to load new configuration
Restart-Service -Name "MIPScanner"

# Wait a few seconds for service to fully start
Start-Sleep -Seconds 5

# Verify service is running
Get-Service -Name "MIPScanner"
# Status should show "Running"
```

**Verify Configuration Update:**

```powershell
# Verify repositories were downloaded
Get-AIPScannerRepository

# Expected output shows all 4 repositories with their paths
# If you see "WARNING: No content scan job or repositories defined", 
# the service hasn't fully loaded the config - wait 10 more seconds and try again

# Verify scanner configuration
Get-AIPScannerConfiguration

# Expected output shows:
# - Cluster: Lab-Scanner-Cluster
# - OnlineConfiguration: On
# - ContentScanJob details
```

> **💡 When to Run Update-AIPScanner**:
> 
> - After adding or removing repositories in Purview portal
> - After changing scan job settings (schedule, info types, sensitivity labels)
> - After creating or modifying DLP policies or sensitivity labels
> - Before running a scan to ensure latest configuration is active

**Grant NTFS File System Permissions:**

The scanner requires **both SMB share permissions AND NTFS file system permissions** to access files.

While SMB share permissions (configured in Lab 00) control network access to the shares, we also need NTFS permissions on the underlying folder structure:

> **💡 Important - Computer Name**: Replace `vm-purview-scanner` in the commands below with **YOUR actual computer name** if needed.
>
> **To find your actual computer name**, run:
> 
> ```powershell
> $env:COMPUTERNAME
> ```

> Then use that exact name in the format: `YOUR-COMPUTER-NAME\scanner-svc`

```powershell
# Grant NTFS Read permissions to scanner account on all repository folders
icacls "C:\PurviewScanner\Finance" /grant "vm-purview-scanner\scanner-svc:(OI)(CI)R" /T
icacls "C:\PurviewScanner\HR" /grant "vm-purview-scanner\scanner-svc:(OI)(CI)R" /T
icacls "C:\PurviewScanner\Projects" /grant "vm-purview-scanner\scanner-svc:(OI)(CI)R" /T

# Verify permissions were applied correctly
icacls "C:\PurviewScanner\Finance" | findstr scanner-svc
icacls "C:\PurviewScanner\HR" | findstr scanner-svc
icacls "C:\PurviewScanner\Projects" | findstr scanner-svc
```

**Expected Output:**

```text
processed file: C:\PurviewScanner\Finance
processed file: C:\PurviewScanner\Finance\CustomerPayments.txt
Successfully processed 2 files; Failed processing 0 files

C:\PurviewScanner\Finance vm-purview-scanner\scanner-svc:(OI)(CI)(R)
C:\PurviewScanner\HR vm-purview-scanner\scanner-svc:(OI)(CI)(R)
C:\PurviewScanner\Projects vm-purview-scanner\scanner-svc:(OI)(CI)(R)
```

> **Understanding Permission Notation:**
>
> - **(OI)** = Object Inherit - applies permission to files
> - **(CI)** = Container Inherit - applies permission to subfolders
> - **R** = Read permission
> - **/T** = Apply recursively to all existing subfolders and files
>
> **⚠️ Why Both SMB and NTFS Permissions?**
>
> Windows uses a **dual permission model** for network file access:
>
> 1. **SMB Share Permissions**: First checkpoint - grants network access to `\\servername\sharename`
> 2. **NTFS Permissions**: Second checkpoint - grants file system access to actual files
>
> The **most restrictive** permission wins. Even if SMB allows Full access, if NTFS denies access, the user/service cannot access files.
>
> The scanner service needs **Read permission at both levels** to successfully enumerate and scan files.

**Alternative GUI Method:**

If you prefer using Windows File Explorer instead of PowerShell:

- Open File Explorer and navigate to `C:\PurviewScanner`
- Right-click **Finance** folder → **Properties** → **Security** tab
- Click **Edit** → **Add**
- Enter `scanner-svc` → Click **Check Names** → **OK**
- Check **Read & execute**, **List folder contents**, and **Read** checkboxes
- Click **Apply** → **OK**
- Repeat for **HR** and **Projects** folders

---

### Step 10: Run Discovery Scan

Discovery scans identify files containing sensitive information types without applying labels or enforcement actions.

**In PowerShell on VM (as Administrator):**

```powershell
# Start the discovery scan
Start-Scan

# Monitor scan progress
Get-ScanStatus
# Expected output will show:
# - Current scan status
# - Files scanned count
# - Sensitive items discovered

# Check scanner service is running
Get-Service | Where-Object {$_.Name -like "*purview*" -or $_.Name -like "*scanner*"}
```

**Monitor Scan Progress:**

```powershell
# Continuously monitor status (runs every 30 seconds)
while ($true) {
    Clear-Host
    Write-Host "Scanner Status Check - $(Get-Date)" -ForegroundColor Cyan
    Get-ScanStatus
    Start-Sleep -Seconds 30
}
# Press Ctrl+C to exit monitoring loop
```

**View Scan Results:**

Scanner logs and reports are generated in the **scanner service account's profile**, not the admin account profile:

```powershell
# Navigate to scanner reports directory (under scanner-svc account profile)
Set-Location "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"

# List all report files
Get-ChildItem -File | Sort-Object LastWriteTime -Descending

# View the latest detailed CSV report
$latestReport = Get-ChildItem -Filter "DetailedReport*.csv" -ErrorAction SilentlyContinue | 
                Sort-Object LastWriteTime -Descending | 
                Select-Object -First 1

if ($latestReport) {
    Write-Host "Opening latest detailed report: $($latestReport.Name)" -ForegroundColor Green
    Invoke-Item $latestReport.FullName
} else {
    Write-Host "No DetailedReport CSV found. Checking for other report formats..." -ForegroundColor Yellow
    
    # Check for summary report
    $summaryReport = Get-ChildItem -Filter "Summary*.txt" | 
                     Sort-Object LastWriteTime -Descending | 
                     Select-Object -First 1
    
    if ($summaryReport) {
        Write-Host "Opening summary report: $($summaryReport.Name)" -ForegroundColor Green
        Invoke-Item $summaryReport.FullName
    }
    
    # List all available reports
    Write-Host "`nAvailable reports:" -ForegroundColor Cyan
    Get-ChildItem -File | Select-Object Name, Length, LastWriteTime
}
```

> **💡 Report Location Note**: Scanner reports are created under the **scanner service account's profile** (`C:\Users\scanner-svc\AppData\Local\...`), not under your admin account (`C:\Users\labadmin\AppData\Local\...`). This is because the scanner service runs as the `scanner-svc` account.

**CSV Report Columns:**

The scanner CSV reports include:

- **File Path**: Full UNC path to scanned file
- **Sensitive Information Types**: Which SITs were detected
- **Count**: Number of occurrences of each SIT
- **Last Modified**: File timestamp
- **Owner**: File owner information

---

## ✅ Validation Checklist

Complete the following validation steps to ensure successful lab completion:

### Installation Validation

- [ ] Information Protection client installed without errors
- [ ] Scanner cmdlets available in PowerShell (`Get-Command -Module AzureInformationProtection`)
- [ ] App registration created in Entra ID with correct permissions
- [ ] Client secret created and saved securely
- [ ] API permissions granted and showing green checkmarks

### Configuration Validation

- [ ] Scanner cluster **Lab-Scanner-Cluster** created in Purview portal
- [ ] Content scan job **Lab-OnPrem-Scan** created and configured
- [ ] Scanner installed on VM with SQL Express backend
- [ ] Scanner service exists in Windows Services

### Authentication Validation

- [ ] `Set-Authentication` cmdlet executed successfully with `-OnBehalfOf` parameter
- [ ] Message displayed: "Acquired access token on behalf of vm-purview-scanner\scanner-svc"
- [ ] No authentication errors in PowerShell output
- [ ] `Start-ScannerDiagnostics -OnBehalfOf $scannerCreds` shows all checks completed successfully
- [ ] Scanner node appears in Purview portal under Clusters > Lab-Scanner-Cluster > Nodes tab

### Repository Validation

- [ ] All 4 repositories added to scan job (Finance, HR, Projects, Azure Files)
- [ ] Repository paths use correct UNC format
- [ ] Repositories visible in Purview portal under scan job

### Scan Execution Validation

- [ ] `Start-Scan` executed without errors
- [ ] `Get-ScanStatus` shows scan progress or completion
- [ ] Scanner service running in Windows Services
- [ ] CSV reports generated in scanner reports directory
- [ ] CSV reports contain discovered files and sensitive data

### Results Validation

- [ ] Scanner reports show files scanned from all repositories
- [ ] Sensitive Information Types detected (Credit Card, SSN, etc.)
- [ ] File paths match expected share locations
- [ ] No permission errors in scan logs

---

## �️ Troubleshooting Common Issues

### Issue: Repositories Show as "Not Accessible" in Scan Reports

**Symptoms:**

- Scan completes in 1-2 seconds with zero files scanned
- Scan report shows: "The following repositories are not accessible: [repository paths]"
- All configured repositories fail to scan

**Root Cause:**
This issue typically occurs when the scanner cannot resolve the UNC network paths to the repositories, even though NTFS and SMB permissions are correctly configured.

**Common Scenario:**
Using the incorrect computer name in UNC paths. The VM computer name should match the actual Windows computer name (e.g., `\\vm-purview-scanner\Finance`) or use `\\localhost\Finance`.

**Diagnostic Steps:**

```powershell
# Test if repositories are accessible with different path formats
Write-Host "Testing repository access..." -ForegroundColor Cyan

# Get actual computer name
$computerName = $env:COMPUTERNAME
Write-Host "Computer name: $computerName" -ForegroundColor Yellow

# Test with localhost
Test-Path "\\localhost\Finance"
Test-Path "\\localhost\HR"
Test-Path "\\localhost\Projects"

# Test with computer name
Test-Path "\\$computerName\Finance"
Test-Path "\\$computerName\HR"
Test-Path "\\$computerName\Projects"

# Verify NTFS permissions
icacls "C:\PurviewScanner\Finance" | findstr scanner-svc
icacls "C:\PurviewScanner\HR" | findstr scanner-svc
icacls "C:\PurviewScanner\Projects" | findstr scanner-svc

# Verify SMB permissions
Get-SmbShareAccess -Name "Finance"
Get-SmbShareAccess -Name "HR"
Get-SmbShareAccess -Name "Projects"
```

**Solution:**

If `\\localhost\...` or `\\computername\...` paths return `True` but the original repository paths fail:

1. **Update Repository Paths in Purview Portal:**
   - Navigate to **Purview portal** > **Information protection scanner** > **Content scan jobs**
   - Click on your scan job (e.g., **Lab-OnPrem-Scan**)
   - Select **Repositories** tab
   - Edit each repository and change the UNC path to use the correct computer name:
     - Use: `\\vm-purview-scanner\Finance` (actual computer name) or `\\localhost\Finance`
   - Click **Save** for each repository

2. **Update Scanner Configuration:**

   ```powershell
   # Download updated repository configuration from Purview portal
   Update-AIPScanner
   # Type Y when prompted to stop the service
   
   # Restart scanner service
   Restart-Service -Name "MIPScanner"
   Start-Sleep -Seconds 10
   
   # Verify updated configuration
   Get-AIPScannerRepository
   # Should show updated UNC paths
   ```

3. **Re-run Discovery Scan:**

   ```powershell
   # Start new scan with corrected repository paths
   Start-Scan
   
   # Monitor progress
   Get-ScanStatus
   ```

**Expected Results After Fix:**

- Scan duration: Several minutes (not 1-2 seconds)
- Scanned files: 3+ files from the repositories
- Scan report: No "not accessible" errors
- Sensitive Information Types detected in scan results

---

## Next Steps

**Proceed to Lab 02**: DLP On-Premises Configuration

In the next lab, you will:

- Create DLP policies for on-premises repositories
- Configure enforcement rules for Credit Card and SSN data
- Enable DLP in the scanner content scan job
- Run enforcement scans that block access to sensitive files
- Monitor DLP actions in Activity Explorer

**Before starting Lab 02, ensure:**

- [ ] Scanner is operational and discovery scan completed successfully
- [ ] CSV reports show sensitive data detected
- [ ] All validation checklist items marked complete

---

## 📚 Reference Documentation

- [Microsoft Purview Information Protection Scanner Overview](https://learn.microsoft.com/en-us/purview/deploy-scanner)
- [Scanner Prerequisites and Requirements](https://learn.microsoft.com/en-us/purview/deploy-scanner-prereqs)
- [Scanner Installation and Configuration](https://learn.microsoft.com/en-us/purview/deploy-scanner-configure-install)
- [Scanner Command Reference](https://learn.microsoft.com/en-us/powershell/module/azureinformationprotection/)
- [Sensitive Information Types Reference](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)

---

## 🤖 AI-Assisted Content Generation

This comprehensive lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview Information Protection Scanner documentation as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of scanner deployment procedures while maintaining technical accuracy and current portal navigation steps.*

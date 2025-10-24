# Lab 00: Environment Setup & Cost Management

## 🎯 Lab Objectives

- Deploy Azure VM for on-premises scanner simulation
- Configure SQL Express for scanner database
- Create SMB file shares with sample sensitive data
- Set up Azure Files as Nasuni-like storage
- Implement cost controls and auto-shutdown
- Create Entra ID service account for scanner

## ⏱️ Estimated Duration

2-3 hours

## 📋 Prerequisites

- Azure subscription with Contributor role
- Microsoft 365 tenant with Global Admin or Compliance Admin role
- Basic PowerShell and Azure Portal knowledge
- Ability to create Entra ID users

## 💰 Cost Optimization Strategy

**Target Weekend Cost**: $3-5

**Cost-Saving Measures**:
- Use Standard_D2s_v3 VM (cost-effective for lab workload)
- Enable auto-shutdown at 10 PM local time
- Deallocate VM when not actively working
- Use Standard HDD for OS disk (lab environment only)
- Minimum Azure Files provisioned size (100 GiB)
- Delete all resources after lab completion

## 🚀 Lab Steps

### Step 1: Activate Microsoft 365 E5 Compliance Trial

**If you already have E5 licensing, skip to Step 2.**

Navigate to Microsoft 365 Admin Center:

- Open browser and go to [https://admin.microsoft.com](https://admin.microsoft.com)
- Sign in with Global Admin credentials
- In the left navigation, expand **Billing** and select **Purchase services**

Search for E5 Compliance trial:

- In the search box, type **E5 Compliance**
- Locate **Microsoft 365 E5 Compliance**
- Click **Details** button

Start the trial:

- Click **Start free trial** button
- Review the trial terms (no credit card required, 25 licenses for 30 days)
- Click **Try now**
- Click **Continue** to confirm
- Wait 10-15 minutes for license provisioning to complete

Verify and assign licenses:

- Navigate to **Billing** > **Licenses** in Admin Center
- Confirm **Microsoft 365 E5 Compliance** appears with 25 available licenses
- Click on the license name
- Under **Users** tab, click **Assign licenses**
- Add your admin account
- Click **Assign**

> **💡 Tip**: Also assign a license to the scanner service account you'll create later

### Step 2: Create Azure Resource Group

Using Azure Portal:

- Navigate to [https://portal.azure.com](https://portal.azure.com)
- Sign in with your Azure credentials
- In the search bar at top, type **Resource groups**
- Click **Resource groups** in the results
- Click **+ Create** button

Configure resource group:

- **Subscription**: Select your subscription
- **Resource group**: `rg-purview-lab`
- **Region**: `East US` (or your preferred region)

Apply tags for cost tracking:

- Click **Next: Tags**
- Add the following tags:
  - **Project**: `Purview-Weekend-Lab`
  - **Environment**: `Lab`
  - **Owner**: Your email address
  - **DeleteAfter**: Date one week from today (e.g., `2025-10-30`)

Create the resource group:

- Click **Review + create**
- Verify settings
- Click **Create**
- Wait for "Resource group created" notification

### Step 3: Deploy Windows Server 2022 VM

Navigate to VM creation:

- In Azure Portal search bar, type **Virtual machines**
- Click **Virtual machines** in results
- Click **+ Create** > **Azure virtual machine**

Configure **Basics** tab:

**Project details**:
- **Subscription**: Your subscription
- **Resource group**: `rg-purview-lab`

**Instance details**:
- **Virtual machine name**: `vm-purview-scanner`
- **Region**: Same as resource group (East US)
- **Availability options**: No infrastructure redundancy required
- **Security type**: Standard
- **Image**: Windows Server 2022 Datacenter - Gen2 (click **See all images** if not visible)
- **Size**: Click **See all sizes**, search for `D2s_v3`, select **Standard_D2s_v3** (2 vcpus, 8 GiB memory)

**Administrator account**:
- **Username**: `labadmin`
- **Password**: Create and document a secure password (min 12 characters, mixed case, numbers, symbols)
- **Confirm password**: Re-enter password

**Inbound port rules**:
- **Public inbound ports**: Allow selected ports
- **Select inbound ports**: Check **RDP (3389)**

> **🔒 Security Note**: In production, use Azure Bastion or VPN instead of public RDP

Configure **Disks** tab:

- Click **Next: Disks**
- **OS disk type**: Standard HDD (sufficient for lab, reduces cost)
- **Delete with VM**: Checked (ensures cleanup)
- **Encryption type**: (Default) Encryption at-rest with platform-managed key
- Leave other settings as default

Configure **Networking** tab:

- Click **Next: Networking**

**Network interface**:
- **Virtual network**: Click **Create new**
  - **Name**: `vnet-purview-lab`
  - **Address space**: 10.0.0.0/16 (default)
  - **Subnet name**: default
  - **Subnet address range**: 10.0.0.0/24 (default)
  - Click **OK**
- **Subnet**: default (10.0.0.0/24)
- **Public IP**: Click **Create new**
  - **Name**: `pip-vm-purview-scanner`
  - **SKU**: Standard
  - Click **OK**
- **NIC network security group**: Basic
- **Public inbound ports**: Allow selected ports
- **Select inbound ports**: RDP (3389)
- **Delete NIC when VM is deleted**: Checked

Configure **Management** tab:

- Click **Next: Management**

**Auto-shutdown** (critical for cost savings):
- **Enable auto-shutdown**: Checked
- **Shutdown time**: 22:00 (10:00 PM)
- **Time zone**: Select your local timezone
- **Send notification before auto-shutdown**: Optional (check if desired)
- **Email address**: Your email (if notifications enabled)
- **Notification**: 15 minutes before

**Monitoring**:
- **Boot diagnostics**: Enable with managed storage account (recommended)
- **Enable OS guest diagnostics**: Off (not needed for lab)

**Identity**:
- **System assigned managed identity**: Off (not needed for this lab)

Configure **Advanced**, **Tags** tabs:

- Click **Next: Advanced** - leave all defaults
- Click **Next: Tags**
- Tags should inherit from resource group, verify:
  - **Project**: Purview-Weekend-Lab
  - **Environment**: Lab
  - **Owner**: Your email

Review and create:

- Click **Review + create**
- Review all settings carefully
- Estimated cost should display (approx $0.10/hour for Standard_D2s_v3)
- Click **Create**
- Wait for deployment (typically 5-7 minutes)

Download RDP file:

- Once deployment completes, click **Go to resource**
- Click **Connect** dropdown > **RDP**
- Click **Download RDP File**
- Save file to your desktop

### Step 4: Connect to VM and Initial Configuration

Connect via RDP:

- Double-click the downloaded RDP file
- Click **Connect** when warned about unknown publisher
- Enter credentials:
  - **Username**: `labadmin`
  - **Password**: Your VM password
- Click **Yes** to accept certificate warning

Initial VM configuration:

- When Server Manager opens automatically, click **Local Server** in left menu
- Locate **IE Enhanced Security Configuration**
- Click **On** next to it
- Set both Administrators and Users to **Off**
- Click **OK**

> **💡 Tip**: This makes it easier to download software in the lab environment

Set timezone:

- Right-click Start menu > **Settings**
- Go to **Time & language** > **Date & time**
- Verify timezone is correct for your location
- Close Settings

### Step 5: Install SQL Server Express

Download SQL Server Express:

- Open **Microsoft Edge** browser
- Navigate to: `https://www.microsoft.com/en-us/sql-server/sql-server-downloads`
- Scroll to **Express** edition section
- Click **Download now** button
- Save `SQL2022-SSEI-Expr.exe` to Downloads folder

Install SQL Server:

- Run the downloaded `SQL2022-SSEI-Expr.exe` installer
- Select **Basic** installation type
- Click **Accept** to agree to license terms
- **Install location**: Accept default (`C:\Program Files\Microsoft SQL Server`)
- Click **Install**
- Wait for download and installation (10-15 minutes)

Note connection information:

- When installation completes, note the displayed information:
  - **Instance name**: `SQLEXPRESS`
  - **Connection string**: `localhost\SQLEXPRESS` or `COMPUTERNAME\SQLEXPRESS`
- Click **Install SSMS** if you want SQL Server Management Studio (optional for lab)
- Click **Close**

Configure SQL Server networking:

- Press **Windows key**, search for **SQL Server Configuration Manager**
- Expand **SQL Server Network Configuration**
- Click **Protocols for SQLEXPRESS**

Enable TCP/IP:

- Right-click **TCP/IP** in the right pane
- Select **Enable**
- Click **OK** on the warning message

Restart SQL Server service:

- In Configuration Manager, expand **SQL Server Services**
- Right-click **SQL Server (SQLEXPRESS)**
- Select **Restart**
- Wait for service to restart (Status should show "Running")

Close SQL Server Configuration Manager.

### Step 6: Create Local File Shares and Sample Data

Create folder structure:

- Open **File Explorer**
- Navigate to `C:\`
- Right-click in empty space > **New** > **Folder**
- Name it: `PurviewScanner`
- Press Enter

Create subfolders:

- Open `C:\PurviewScanner`
- Create three new folders:
  - `Finance`
  - `HR`
  - `Projects`

Create sample files with sensitive information:

- Open **PowerShell ISE** as Administrator:
  - Press **Windows key**
  - Type **PowerShell ISE**
  - Right-click **Windows PowerShell ISE**
  - Select **Run as administrator**

Run the following script to create realistic sample data:

```powershell
# Create Finance folder sample - Credit Card data
$financeContent = @"
ACME CORPORATION - CUSTOMER PAYMENT RECORDS
Generated: $(Get-Date -Format 'yyyy-MM-dd')
Classification: CONFIDENTIAL

CUSTOMER PAYMENT INFORMATION

Transaction ID: TXN-2024-001
Customer Name: John Smith
Email: john.smith@email.com
Credit Card Number: 4532-1234-5678-9010
Expiration Date: 12/2026
CVV: 123
Amount: `$5,000.00
Date: 2024-10-15

Transaction ID: TXN-2024-002
Customer Name: Jane Doe
Email: jane.doe@email.com
Credit Card Number: 5425-2334-5566-7788
Expiration Date: 03/2027
CVV: 456
Amount: `$3,250.00
Date: 2024-10-16

Transaction ID: TXN-2024-003
Customer Name: Robert Johnson
Email: robert.j@email.com
Credit Card Number: 3782-822463-10005
Expiration Date: 08/2025
CVV: 789
Amount: `$1,875.50
Date: 2024-10-17
"@

$financeContent | Out-File -FilePath "C:\PurviewScanner\Finance\CustomerPayments.txt" -Encoding UTF8

# Create HR folder sample - PII/SSN data
$hrContent = @"
ACME CORPORATION - EMPLOYEE PERSONAL RECORDS
HR Department - RESTRICTED ACCESS
Last Updated: $(Get-Date -Format 'yyyy-MM-dd')

EMPLOYEE INFORMATION DATABASE

Employee ID: EMP-001
Full Name: Sarah Johnson
Social Security Number: 123-45-6789
Date of Birth: 01/15/1985
Home Address: 123 Main Street, Anytown, ST 12345
Phone Number: (555) 123-4567
Email: sarah.johnson@acme.com
Hire Date: 03/10/2020
Department: Engineering
Salary: `$95,000

Employee ID: EMP-002
Full Name: Michael Chen
Social Security Number: 987-65-4321
Date of Birth: 08/22/1990
Home Address: 456 Oak Avenue, Somewhere, ST 67890
Phone Number: (555) 987-6543
Email: michael.chen@acme.com
Hire Date: 06/15/2019
Department: Finance
Salary: `$88,000

Employee ID: EMP-003
Full Name: Emily Rodriguez
Social Security Number: 456-78-9012
Date of Birth: 11/30/1988
Home Address: 789 Pine Road, Another Town, ST 11223
Phone Number: (555) 456-7890
Email: emily.rodriguez@acme.com
Hire Date: 01/20/2021
Department: Marketing
Salary: `$72,000
"@

$hrContent | Out-File -FilePath "C:\PurviewScanner\HR\EmployeeRecords.txt" -Encoding UTF8

# Create Projects folder sample - Old archived data (3+ years)
$projectContent = @"
PROJECT PHOENIX - ARCHIVED TECHNICAL DOCUMENTATION
Status: ARCHIVED - DEPRECATED
Last Access: 2020-01-15
Classification: CONFIDENTIAL - DO NOT DISTRIBUTE

LEGACY SYSTEM INFORMATION

Project Code: PHOENIX-2019
Classification Level: Highly Confidential
Data Retention: EXPIRED - CANDIDATE FOR DELETION

TECHNICAL SPECIFICATIONS:
- Internal Server IP: 192.168.100.50
- Database Connection: SERVER=db-prod-01;UID=sa;PWD=P@ssw0rd123
- API Key: SAMPLE_API_KEY_NOT_REAL_12345ABCDEF67890
- Encryption Key: AES256_KEY_0x4B3F9E2D8C1A7F5E

PROPRIETARY ALGORITHMS:
The Phoenix algorithm uses a three-stage processing pipeline:
1. Data ingestion with AES-256 encryption
2. Processing using proprietary compression (Patent Pending)
3. Output to secure storage with versioning

CUSTOMER DATA SAMPLES:
Customer 001: Social Security: 111-22-3333
Customer 002: Credit Card: 4111-1111-1111-1111

WARNING: THIS PROJECT WAS DECOMMISSIONED IN 2020
ALL SYSTEMS SHUT DOWN - DATA SHOULD BE ARCHIVED OR DELETED
RETENTION POLICY: 3 YEARS FROM LAST ACCESS
CURRENT STATUS: PAST RETENTION PERIOD - DELETION CANDIDATE
"@

$projectContent | Out-File -FilePath "C:\PurviewScanner\Projects\PhoenixProject.txt" -Encoding UTF8

# Set file to 3+ years old (simulates old data discovery)
$oldFile = Get-Item "C:\PurviewScanner\Projects\PhoenixProject.txt"
$oldDate = (Get-Date).AddYears(-3).AddMonths(-2)
$oldFile.LastWriteTime = $oldDate
$oldFile.LastAccessTime = $oldDate
$oldFile.CreationTime = $oldDate

Write-Host "`n✅ Sample files created successfully" -ForegroundColor Green
Write-Host "`nFiles created:" -ForegroundColor Cyan
Write-Host "  - C:\PurviewScanner\Finance\CustomerPayments.txt (Credit Cards)" -ForegroundColor Yellow
Write-Host "  - C:\PurviewScanner\HR\EmployeeRecords.txt (SSN, PII)" -ForegroundColor Yellow
Write-Host "  - C:\PurviewScanner\Projects\PhoenixProject.txt (Old data, 3+ years)" -ForegroundColor Yellow
```

Verify file creation:

```powershell
# Verify files exist and check timestamps
Get-ChildItem "C:\PurviewScanner" -Recurse -File | 
    Select-Object FullName, Length, LastWriteTime, LastAccessTime | 
    Format-Table -AutoSize

# Verify old file timestamp
$oldFile = Get-Item "C:\PurviewScanner\Projects\PhoenixProject.txt"
$age = (Get-Date) - $oldFile.LastAccessTime
Write-Host "`nPhoenix Project file age: $([math]::Round($age.TotalDays / 365, 1)) years" -ForegroundColor Cyan
```

Create SMB shares:

```powershell
# Create network shares for scanner to access
New-SmbShare -Name "Finance" `
    -Path "C:\PurviewScanner\Finance" `
    -FullAccess "Everyone" `
    -Description "Finance department files - LAB ONLY"

New-SmbShare -Name "HR" `
    -Path "C:\PurviewScanner\HR" `
    -FullAccess "Everyone" `
    -Description "HR department files - LAB ONLY"

New-SmbShare -Name "Projects" `
    -Path "C:\PurviewScanner\Projects" `
    -FullAccess "Everyone" `
    -Description "Project archive files - LAB ONLY"

Write-Host "`n✅ SMB shares created successfully" -ForegroundColor Green

# Display created shares
Get-SmbShare | Where-Object {$_.Name -in @("Finance", "HR", "Projects")} | 
    Format-Table Name, Path, Description -AutoSize
```

> **🔒 Security Note**: Using "Everyone" with Full Access is for LAB ONLY. Production environments require proper NTFS and share permissions.

### Step 7: Create Azure Files Storage Account (Nasuni Simulation)

Return to Azure Portal on your local machine (not in VM):

- Navigate to [https://portal.azure.com](https://portal.azure.com)
- In search bar, type **Storage accounts**
- Click **Storage accounts** in results
- Click **+ Create**

Configure **Basics** tab:

**Project details**:
- **Subscription**: Your subscription
- **Resource group**: `rg-purview-lab`

**Instance details**:
- **Storage account name**: `stpurviewlab` + random 6 digits (e.g., `stpurviewlab829456`)
  - Must be globally unique, lowercase, no special characters
  - Note this name - you'll need it later
- **Region**: Same as resource group (East US)
- **Performance**: Premium
- **Premium account type**: File shares
- **Redundancy**: Locally-redundant storage (LRS)

> **💡 Cost Note**: Premium is required for certain scenarios, minimum 100 GiB provisioned

Configure **Advanced** tab:

- Click **Next: Advanced**
- **Require secure transfer for REST API operations**: Enabled
- **Allow enabling public access on containers**: Disabled
- **Enable storage account key access**: Enabled
- **Default to Microsoft Entra authorization**: Disabled
- Leave other settings as default

Configure **Networking** tab:

- Click **Next: Networking**
- **Network connectivity**: Enable public access from all networks (for lab simplicity)

> **🔒 Production Note**: Use private endpoints or selected networks in production

Configure **Data protection** tab:

- Click **Next: Data protection**
- Leave all defaults (soft delete disabled for cost savings in lab)

Configure **Encryption** tab:

- Click **Next: Encryption**
- Leave defaults (Microsoft-managed keys)

Configure **Tags** tab:

- Click **Next: Tags**
- Verify tags inherited from resource group

Review and create:

- Click **Review + create**
- Verify configuration
- Note estimated cost (Premium File Shares minimum 100 GiB)
- Click **Create**
- Wait for deployment (2-3 minutes)

Create file share:

- Once deployed, click **Go to resource**
- In left menu under **Data storage**, click **File shares**
- Click **+ File share** button

Configure file share:

- **Name**: `nasuni-simulation`
- **Provisioned capacity**: `100` GiB (minimum for Premium)
- **Protocol**: SMB
- **Tier**: Not applicable for Premium
- Click **Review + create**
- Click **Create**

Get connection script:

- Click on the newly created **nasuni-simulation** file share
- Click **Connect** button in top toolbar
- **Operating system**: Windows
- Copy the PowerShell script displayed (it contains your storage account key)

Mount share on VM:

- Switch back to your VM RDP session
- Open **PowerShell ISE** as Administrator
- Paste the copied connection script
- Run the script
- Verify drive letter assigned (typically Z:)

Create sample data on Azure Files:

```powershell
# Assuming share mounted as Z: drive
$cloudContent = @"
ACME CORPORATION - CLOUD MIGRATION PROJECT
Cloud Infrastructure Team
Classification: Internal Use Only
Last Modified: $(Get-Date -Format 'yyyy-MM-dd')

MIGRATION PROJECT STATUS

Project Name: Cloud Migration Initiative 2024
Status: Phase 2 - In Progress
Lead: Cloud Operations Team

MIGRATION PHASES:
Phase 1: Assessment & Planning - COMPLETE (2024-Q1)
Phase 2: Pilot Migration - IN PROGRESS (2024-Q3)
Phase 3: Full Production Migration - PENDING (2025-Q1)

AZURE RESOURCE INFORMATION:
Subscription ID: 12345678-1234-1234-1234-123456789abc
Resource Group: rg-prod-migration
Location: East US
Storage Account: stprodmigration001

CONTACT INFORMATION:
Project Manager: cloudops@acme.com
Technical Lead: infrastructure@acme.com
Security Contact: security@acme.com

NOTES:
This file simulates data stored on Nasuni-like cloud storage
accessible via SMB protocol from on-premises scanner.
"@

# Write to Azure Files share
$cloudContent | Out-File -FilePath "Z:\CloudMigration.txt" -Encoding UTF8

Write-Host "`n✅ Azure Files share mounted and sample data created" -ForegroundColor Green
Write-Host "  Drive: Z:\" -ForegroundColor Yellow
Write-Host "  File: Z:\CloudMigration.txt" -ForegroundColor Yellow

# Verify
Get-ChildItem Z:\ | Format-Table Name, Length, LastWriteTime
```

### Step 8: Install Scanner Prerequisites

Download and install Microsoft Office IFilter:

- In VM, open **Microsoft Edge**
- Navigate to: `https://www.microsoft.com/en-us/download/details.aspx?id=17062`
- Click **Download** button
- Select **FilterPack64bit.exe**
- Click **Next** to download
- Run the downloaded installer
- Click **Yes** on UAC prompt
- Accept license agreement
- Click **Install**
- Wait for completion
- Click **OK** when finished

> **📝 Note**: Office IFilter enables scanner to inspect .zip files for sensitive information types

Install Azure CLI:

- Navigate to: `https://aka.ms/installazurecliwindowsx64`
- Download will start automatically (`azure-cli-latest.msi`)
- Run the downloaded MSI installer
- Click **Next** on welcome screen
- Accept license terms, click **Next**
- Use default install location, click **Next**
- Click **Install**
- Click **Yes** on UAC prompt
- Wait for installation
- Click **Finish**

Verify Azure CLI installation:

```powershell
# Open new PowerShell window to refresh PATH
# Close current PowerShell ISE and reopen as Administrator

# Verify Azure CLI installed
az --version

# Should display version info
```

Install PowerShell 7 (optional but recommended):

- Navigate to: `https://github.com/PowerShell/PowerShell/releases`
- Download latest stable `.msi` for Windows x64
- Run installer with default options
- Click **Finish** when complete

### Step 9: Create Entra ID Service Account for Scanner

> **Important**: Scanner requires a synchronized Entra ID account. In this lab, we'll create a cloud-only account since we don't have on-premises AD.

On your local machine (not VM), open Azure Portal:

- Navigate to **Microsoft Entra ID** (formerly Azure AD)
- In left menu, click **Users**
- Click **+ New user** > **Create new user**

Configure user:

**Identity**:
- **User principal name**: `scanner-svc@yourtenant.onmicrosoft.com`
  - Replace `yourtenant` with your actual tenant name
- **Display name**: `Purview Scanner Service Account`
- **Mail nickname**: `scanner-svc`

**Password**:
- Select **Let me create the password**
- **Password**: Create secure password (document it!)
- **Force change password on first sign-in**: Unchecked (critical for service accounts)

**Assignments** (optional for now, we'll assign licenses later):

- Click **Review + create**
- Click **Create**

Assign compliance license to scanner account:

- In **Microsoft Entra ID** > **Users**, find the **scanner-svc** account
- Click on it to open
- In left menu, click **Licenses**
- Click **+ Assignments**
- Check **Microsoft 365 E5 Compliance**
- Click **Save**

Assign required roles:

- Still in the scanner-svc user page
- In left menu, click **Assigned roles**
- Click **+ Add assignments**
- Search for and select:
  - **Compliance Data Administrator**
- Click **Add**

> **📝 Note**: In production with hybrid AD, you'd use an on-premises service account synced to Entra ID.

### Step 10: Configure Windows Firewall on VM

Enable File and Printer Sharing (if needed for external scanner scenarios):

```powershell
# Open PowerShell ISE as Administrator on VM

# Enable File and Printer Sharing rules
Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Domain, Private

Write-Host "`n✅ Firewall configured to allow file sharing" -ForegroundColor Green

# Verify rules
Get-NetFirewallRule -DisplayGroup "File And Printer Sharing" | 
    Where-Object {$_.Enabled -eq 'True'} |
    Select-Object DisplayName, Enabled, Profile |
    Format-Table -AutoSize
```

## ✅ Validation Checklist

Before proceeding to Lab 01, verify all components:

### Azure Resources

- [ ] Resource group `rg-purview-lab` created
- [ ] VM `vm-purview-scanner` running and accessible via RDP
- [ ] Auto-shutdown configured for 10 PM local time
- [ ] Storage account created with Premium file share
- [ ] All resources tagged appropriately
- [ ] Estimated daily cost is within budget ($3-5)

### VM Configuration

- [ ] SQL Server Express installed and TCP/IP enabled
- [ ] SQL Server service running (verify in Services.msc)
- [ ] Connection test: `Test-NetConnection -ComputerName localhost -Port 1433` succeeds
- [ ] SMB shares created: `\\localhost\Finance`, `\\localhost\HR`, `\\localhost\Projects`
- [ ] Sample files contain sensitive data (credit cards, SSNs)
- [ ] Phoenix project file shows LastAccessTime > 3 years old
- [ ] Azure Files share mounted and accessible (Z: drive)
- [ ] Microsoft Office IFilter installed
- [ ] Azure CLI installed and working (`az --version`)

### Entra ID Configuration

- [ ] Microsoft 365 E5 Compliance trial activated (or existing license)
- [ ] Service account `scanner-svc@tenant.onmicrosoft.com` created
- [ ] Scanner account has E5 Compliance license assigned
- [ ] Scanner account has Compliance Data Administrator role
- [ ] Password documented securely

### Sample Data Validation

Test sensitive information types detection readiness:

```powershell
# Run on VM to verify sample data
Write-Host "`nValidating sample files contain detectable SITs:" -ForegroundColor Cyan

# Check Finance file for credit cards
$financeContent = Get-Content "C:\PurviewScanner\Finance\CustomerPayments.txt" -Raw
if ($financeContent -match '\d{4}-\d{4}-\d{4}-\d{4}') {
    Write-Host "  ✅ Finance file contains credit card patterns" -ForegroundColor Green
}

# Check HR file for SSNs
$hrContent = Get-Content "C:\PurviewScanner\HR\EmployeeRecords.txt" -Raw
if ($hrContent -match '\d{3}-\d{2}-\d{4}') {
    Write-Host "  ✅ HR file contains SSN patterns" -ForegroundColor Green
}

# Check Projects file age
$projectFile = Get-Item "C:\PurviewScanner\Projects\PhoenixProject.txt"
$ageYears = ((Get-Date) - $projectFile.LastAccessTime).TotalDays / 365
if ($ageYears -gt 3) {
    Write-Host "  ✅ Phoenix project file is $([math]::Round($ageYears, 1)) years old" -ForegroundColor Green
}

# Check Azure Files
if (Test-Path "Z:\CloudMigration.txt") {
    Write-Host "  ✅ Azure Files share accessible with sample data" -ForegroundColor Green
}

Write-Host "`nEnvironment validation complete!`n" -ForegroundColor Cyan
```

## 🧹 Daily Shutdown Procedure

At the end of each lab session:

```powershell
# Run from local machine (Azure CLI or Portal)

# Stop and deallocate VM to avoid charges
az vm deallocate --resource-group rg-purview-lab --name vm-purview-scanner

# Verify VM is deallocated
az vm show --resource-group rg-purview-lab --name vm-purview-scanner --query "provisioningState" -o tsv
```

Or use Azure Portal:

- Navigate to VM `vm-purview-scanner`
- Click **Stop** button
- Wait for status to change to **Stopped (deallocated)**

## 🔍 Troubleshooting

### Cannot connect to VM via RDP

**Symptoms**: RDP connection fails or times out

**Solutions**:
1. Verify VM is running (not stopped): Portal > VM > Status should be "Running"
2. Check NSG rules: VM > Networking > Verify port 3389 allowed
3. Verify public IP: VM > Overview > Copy Public IP address
4. Reset password: VM > Reset password (in Portal)
5. Check local firewall: Ensure your firewall allows outbound RDP

### SQL Server not accessible

**Symptoms**: Cannot connect to SQL Server, scanner installation fails

**Solutions**:
1. Verify service running: Open Services.msc, find "SQL Server (SQLEXPRESS)", ensure Status is "Running"
2. Enable TCP/IP: SQL Configuration Manager > Protocols for SQLEXPRESS > TCP/IP should be "Enabled"
3. Restart service: After enabling TCP/IP, restart SQL Server (SQLEXPRESS) service
4. Test connection: `Test-NetConnection -ComputerName localhost -Port 1433`
5. Check firewall: Windows Firewall may block SQL (typically not an issue for localhost connections)

### SMB shares not accessible

**Symptoms**: Cannot access `\\vm-name\Finance` shares

**Solutions**:
1. Verify shares created: `Get-SmbShare | Where-Object {$_.Name -in @("Finance", "HR", "Projects")}`
2. Check Windows Firewall: File and Printer Sharing should be enabled
3. Test locally first: From VM, access `\\localhost\Finance`
4. Verify permissions: `Get-SmbShareAccess -Name Finance`
5. Network discovery: Ensure Network Discovery is enabled (Network and Sharing Center)

### Azure Files mount fails

**Symptoms**: Cannot mount Z: drive, script fails

**Solutions**:
1. Verify storage account key: Portal > Storage Account > Access keys > Copy key1
2. Check port 445: `Test-NetConnection -ComputerName yourstorageaccount.file.core.windows.net -Port 445`
3. ISP blocking: Some ISPs block port 445; test from Azure VM directly
4. Regenerate connection script: Portal > File Share > Connect > Copy fresh script
5. Manual mount:
   ```powershell
   $connectTestResult = Test-NetConnection -ComputerName yourstorageaccount.file.core.windows.net -Port 445
   if ($connectTestResult.TcpTestSucceeded) {
       cmd.exe /C "cmdkey /add:`"yourstorageaccount.file.core.windows.net`" /user:`"Azure\yourstorageaccount`" /pass:`"STORAGEACCOUNTKEY`""
       New-PSDrive -Name Z -PSProvider FileSystem -Root "\\yourstorageaccount.file.core.windows.net\nasuni-simulation" -Persist
   }
   ```

### Sample files missing sensitive data

**Symptoms**: Files created but don't contain expected patterns

**Solutions**:
1. Re-run PowerShell scripts from Step 6
2. Verify file encoding: Should be UTF-8
3. Check file contents: `Get-Content "C:\PurviewScanner\Finance\CustomerPayments.txt"`
4. Ensure no anti-malware removed files: Check Windows Defender exclusions if needed
5. Recreate files manually if needed, ensuring credit card and SSN patterns are present

### E5 Compliance trial not activating

**Symptoms**: Cannot start trial, or trial not showing licenses

**Solutions**:
1. Verify account has Global Admin role
2. Check if trial already used: Each tenant can only use trial once
3. Wait 15-30 minutes for license propagation after activation
4. Try from different browser (clear cache)
5. Verify tenant is eligible: Some tenant types may have restrictions
6. Alternative: Use existing E5 license if available, or contact Microsoft support

### Cost higher than expected

**Symptoms**: Azure charges accumulating faster than anticipated

**Solutions**:
1. Verify VM deallocated when not in use: `az vm show` should show "deallocated"
2. Check auto-shutdown configured: VM > Auto-shutdown should be enabled
3. Review running resources: Portal > Cost Management > Cost analysis
4. Reduce VM size: Can downgrade to B2s if D2s_v3 too expensive
5. Delete unused resources: Remove any resources not needed for lab

## 📊 Cost Monitoring

Check current spending:

- Azure Portal > Cost Management + Billing
- Select your subscription
- Click **Cost analysis**
- Filter by Resource group: `rg-purview-lab`
- View daily costs and trends

Set up cost alert (optional):

- Cost Management > Budgets
- Click **+ Add**
- Scope: Resource group `rg-purview-lab`
- Budget amount: $20
- Alert conditions: 80%, 100%
- Email: Your email
- Create

## 📚 Reference Documentation

- [Create Windows VM in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-portal)
- [Install SQL Server Express](https://learn.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server)
- [Azure Files SMB shares](https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows)
- [Create Entra ID users](https://learn.microsoft.com/en-us/entra/fundamentals/how-to-create-delete-users)
- [Azure Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/quick-acm-cost-analysis)

## ⏭️ Next Steps

Environment setup complete! You now have:

- ✅ Azure VM ready for scanner installation
- ✅ SQL Express database platform configured
- ✅ On-premises file shares simulated with sensitive data
- ✅ Cloud storage (Azure Files) simulating Nasuni
- ✅ Entra ID service account with proper licensing
- ✅ Cost controls in place

Proceed to **[Lab 01: Information Protection Scanner Deployment](../Lab-01-Scanner-Deployment/README.md)** to install and configure the Purview scanner.

## 🤖 AI-Assisted Content Generation

This comprehensive lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating current Microsoft Learn documentation and Azure best practices as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of environment setup procedures while maintaining technical accuracy and cost optimization strategies for weekend lab scenarios.*

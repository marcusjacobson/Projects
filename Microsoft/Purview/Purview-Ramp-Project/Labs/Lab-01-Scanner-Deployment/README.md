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
# Check if Information Protection module is available
Get-Module -ListAvailable | Where-Object {$_.Name -like "*AIP*" -or $_.Name -like "*MIP*"}

# Verify scanner cmdlets are available
Get-Command -Module AzureInformationProtection
```

---

### Step 2: Create App Registration for Scanner Authentication

Scanner authentication requires an Entra ID app registration with specific API permissions. This enables the scanner to run unattended with service principal credentials.

**On your local machine (Azure Portal):**

Navigate to Microsoft Entra ID to create the app registration.

- Sign in to **Azure Portal**: https://portal.azure.com
- Navigate to **Microsoft Entra ID**
- Select **App registrations** from the left navigation menu
- Click **+ New registration**

**Configure Application Registration:**

- **Name**: `Purview-Scanner-App`
- **Supported account types**: **Accounts in this organizational directory only (Single tenant)**
- **Redirect URI**: 
  - Type: **Web**
  - Value: `http://localhost`
- Click **Register**

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

**Grant Admin Consent:**

- Click **Grant admin consent for [Your Tenant Name]**
- Click **Yes** to confirm the consent prompt
- Verify all permissions show **green checkmarks** under the Status column

> **�� Best Practice**: In production environments, document all API permissions granted and review them periodically as part of security audits.

---

### Step 5: Create Scanner Cluster in Purview Portal

Scanner clusters organize scanner nodes and manage scanning operations centrally through the Purview portal.

**Navigate to Purview Portal:**

- Open browser and go to: https://purview.microsoft.com
- Sign in with your **admin account** (not scanner-svc)
- Click **Settings** (gear icon in the top right corner)
- Select **Information protection** from the left navigation menu
- Click **Information protection scanner**

**Create Scanner Cluster:**

- Select the **Clusters** tab
- Click **+ Add** to create a new cluster
- **Cluster name**: `Lab-Scanner-Cluster`
- **Description**: `Weekend lab scanner for on-prem file shares and Azure Files`
- Click **Save**

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

**On VM, open PowerShell ISE as Administrator:**

First, authenticate to Azure:

```powershell
# Option 1: Azure PowerShell
Connect-AzAccount

# Option 2: Azure CLI (if PowerShell module not available)
az login
```

**Install the Scanner:**

```powershell
# Install scanner with SQL Server configuration
Install-Scanner -SqlServerInstance "localhost\SQLEXPRESS" -Cluster "Lab-Scanner-Cluster"
```

**Expected Prompts and Responses:**

- **Scanner service account**: Enter `scanner-svc` for cloud-only accounts
- If using domain accounts: `DOMAIN\scanner-svc`

> **⚠️ Cloud-Only Accounts**: For cloud-only Entra ID accounts (like scanner-svc@tenant.onmicrosoft.com), you may need to use the `-OnBehalfOf` parameter. The scanner will use the app registration credentials instead.

**Verify Installation:**

```powershell
# Check scanner service
Get-Service -Name "*scanner*"

# Expected output: Service should be in "Stopped" state initially
# Status: Stopped
# Name: MIP Scanner Service
```

**Troubleshooting Installation Issues:**

If installation fails:

```powershell
# Check SQL Server connectivity
Test-NetConnection -ComputerName localhost -Port 1433

# Verify SQL instance is running
Get-Service -Name "*SQL*"

# Check scanner installation logs
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\MSIP\Scanner\Reports" -Recurse
```

---

### Step 8: Authenticate Scanner

Scanner authentication uses the app registration credentials to acquire tokens for Purview API access.

**Set Authentication with App Registration:**

```powershell
# Set authentication using the app registration credentials from Step 2-3
Set-Authentication `
    -AppId "YOUR-APP-ID-FROM-STEP-2" `
    -AppSecret "YOUR-SECRET-VALUE-FROM-STEP-3" `
    -TenantId "YOUR-TENANT-ID-FROM-STEP-2" `
    -DelegatedUser "scanner-svc@yourtenant.onmicrosoft.com"
```

**Replace the placeholder values:**
- `YOUR-APP-ID-FROM-STEP-2`: Application (client) ID from app registration
- `YOUR-SECRET-VALUE-FROM-STEP-3`: Client secret value you saved
- `YOUR-TENANT-ID-FROM-STEP-2`: Directory (tenant) ID from app registration
- `scanner-svc@yourtenant.onmicrosoft.com`: Your scanner service account UPN

**Expected Success Output:**

```
Acquired application access token on behalf of scanner-svc@yourtenant.onmicrosoft.com
```

**Troubleshooting Authentication:**

If authentication fails:

```powershell
# Verify app registration exists
az ad app list --display-name "Purview-Scanner-App"

# Check app permissions
az ad app permission list --id "YOUR-APP-ID"

# Verify service account exists
az ad user show --id "scanner-svc@yourtenant.onmicrosoft.com"
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

**Repository 1 - Finance Share:**
- **UNC Path**: `\\vm-purview-scanner\Finance`
- Click **Save**

**Repository 2 - HR Share:**
- **UNC Path**: `\\vm-purview-scanner\HR`
- Click **Save**

**Repository 3 - Projects Share:**
- **UNC Path**: `\\vm-purview-scanner\Projects`
- Click **Save**

**Repository 4 - Azure Files Share:**
- **UNC Path**: `\\[storageaccount].file.core.windows.net\nasuni-simulation`
- Replace `[storageaccount]` with your storage account name from Lab 00
- Click **Save**

> **💡 Azure Files Authentication**: Ensure the scanner service account has appropriate RBAC permissions on the Azure Files share (Storage File Data SMB Share Contributor role recommended).

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

Scanner logs and reports are generated in the local app data folder:

```powershell
# Navigate to scanner reports directory
Set-Location "$env:LOCALAPPDATA\Microsoft\MSIP\Scanner\Reports"

# List all report files
Get-ChildItem -File | Sort-Object LastWriteTime -Descending

# View the latest CSV report in Excel or text editor
Invoke-Item (Get-ChildItem -Filter "*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1)
```

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
- [ ] `Set-Authentication` cmdlet executed successfully
- [ ] Message displayed: "Acquired application access token"
- [ ] No authentication errors in PowerShell output

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

## 🔍 Troubleshooting Common Issues

### Issue: Scanner Installation Fails

**Symptoms**: `Install-Scanner` cmdlet fails with SQL Server errors

**Solutions**:

```powershell
# Verify SQL Server Express is running
Get-Service -Name "MSSQL`$SQLEXPRESS"

# If not running, start the service
Start-Service -Name "MSSQL`$SQLEXPRESS"

# Test SQL connectivity
sqlcmd -S localhost\SQLEXPRESS -Q "SELECT @@VERSION"

# Verify TCP/IP protocol is enabled (should be done in Lab 00)
# Open SQL Server Configuration Manager > SQL Server Network Configuration > Protocols for SQLEXPRESS
# Ensure TCP/IP is "Enabled"
```

### Issue: Authentication Fails

**Symptoms**: `Set-Authentication` returns errors about invalid credentials

**Solutions**:

```powershell
# Verify app registration details
az ad app show --id "YOUR-APP-ID"

# Check if secret is expired
az ad app credential list --id "YOUR-APP-ID"

# Verify service account exists and has E5 license
az ad user show --id "scanner-svc@yourtenant.onmicrosoft.com"

# If secret expired, create a new one:
# Azure Portal > Entra ID > App registrations > Purview-Scanner-App > Certificates & secrets > New client secret
```

### Issue: Scan Finds No Files

**Symptoms**: Scan completes but CSV report is empty or shows 0 files scanned

**Solutions**:

```powershell
# Verify scanner service account has read access to shares
# On VM, test access as scanner-svc account
Test-Path "\\vm-purview-scanner\Finance"

# Check SMB share permissions
Get-SmbShare | Where-Object {$_.Name -in @("Finance","HR","Projects")}
Get-SmbShareAccess -Name "Finance"

# Verify firewall allows File and Printer Sharing
Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Where-Object {$_.Enabled -eq $true}

# For Azure Files, verify storage account firewall settings
# Azure Portal > Storage Account > Networking > Firewalls and virtual networks
# Ensure "Enabled from selected virtual networks and IP addresses" includes your VM's network
```

### Issue: Scanner Service Won't Start

**Symptoms**: Scanner service shows "Stopped" and fails to start

**Solutions**:

```powershell
# Check scanner service startup type
Get-Service -Name "*scanner*" | Select-Object Name, Status, StartType

# Try starting manually
Start-Service -Name "MIPScanner"

# Check Windows Event Logs for errors
Get-EventLog -LogName Application -Source "*MIP*" -Newest 20 | Format-List

# Review scanner detailed logs
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\MSIP\Scanner\Logs" -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 5
```

### Issue: No Sensitive Data Detected

**Symptoms**: Scan completes but no SITs found despite sample data containing credit cards/SSNs

**Solutions**:

```powershell
# Verify sample data files exist and contain sensitive data
Get-ChildItem "C:\PurviewScanner\Finance" -Recurse
Get-Content "C:\PurviewScanner\Finance\CustomerPayments.txt"

# Check scan job configuration
# Purview Portal > Information protection scanner > Content scan jobs > Lab-OnPrem-Scan
# Verify "Info types to be discovered" is set to "Policy only" or "All"

# Ensure SITs are configured in your tenant
# Purview Portal > Data classification > Classifiers > Sensitive info types
# Verify "Credit Card Number" and "U.S. Social Security Number (SSN)" exist

# Re-run scan with increased discovery sensitivity
# In Purview portal, edit scan job settings to include "All" info types
```

---

## 📊 Expected Results

After completing this lab successfully, you should observe:

### Scanner Installation
- Information Protection client installed in `C:\Program Files (x86)\Microsoft Azure Information Protection`
- Scanner Windows service created and configured
- Scanner configuration stored in SQL Express database

### Purview Portal Configuration
- Scanner cluster visible in Purview portal with 1 node
- Content scan job created with 4 repositories
- Scan job status shows "Manual" schedule

### Scan Execution
- Scanner service runs discovery scan across all repositories
- CSV reports generated with filenames like `DetailedReport_YYYY-MM-DD_HH-MM-SS.csv`
- Reports contain:
  - ~20-30 files scanned (depending on Lab 00 sample data creation)
  - Credit Card SITs detected in Finance folder
  - SSN SITs detected in HR folder
  - File paths showing all 4 repositories scanned

### Files Containing Sensitive Data
Based on Lab 00 sample data, expect to find:
- **Finance\CustomerPayments.txt**: Credit Card Number SIT
- **Finance\TransactionHistory.csv**: Credit Card Number SIT
- **HR\EmployeeRecords.txt**: U.S. SSN SIT
- **HR\SalaryData.csv**: U.S. SSN SIT, Email Address SIT

---

## 🎯 Key Learning Outcomes

After completing Lab 01, you have learned:

1. **Scanner Architecture**: Understanding of how Purview Information Protection Scanner operates with SQL backend, Windows service, and cloud-managed configuration

2. **Authentication Models**: Service principal authentication using Entra ID app registrations for unattended scanner operations

3. **API Permissions**: Specific permissions required for scanner operations (Content.DelegatedReader, Content.DelegatedWriter, UnifiedPolicy.Tenant.Read)

4. **Discovery Scanning**: How to configure and execute discovery scans to identify sensitive data without enforcement

5. **Repository Management**: Adding on-premises SMB shares and Azure Files shares to scanner scope

6. **Results Interpretation**: Reading scanner CSV reports to understand sensitive data distribution

---

## 🚀 Next Steps

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

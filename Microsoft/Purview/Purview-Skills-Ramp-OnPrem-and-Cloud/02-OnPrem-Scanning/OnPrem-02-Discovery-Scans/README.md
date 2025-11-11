# OnPrem-02: Discovery Scans and Results Analysis

## 🎯 Lab Objectives

- Add on-premises file share repositories to scanner content scan job.
- Execute discovery scans to identify sensitive content.
- Monitor scan progress and completion.
- Review detailed CSV scan reports.
- Analyze discovery results in Purview Activity Explorer.
- Understand sensitive information type detection patterns.

## ⏱️ Estimated Duration

1-2 hours (includes 30-60 minutes for scan execution)

## 📋 Prerequisites

- **OnPrem-01 completed**: Scanner client installed, cluster created, service authenticated.
- Scanner service running successfully.
- SMB file shares created with sample data (Finance, HR, Projects from Setup-02).
- Sample files containing PII (credit cards, SSNs, old data).
- Purview compliance portal access.

## ✅ Quick Validation: Verify OnPrem-01 Completion

Before starting OnPrem-02, verify that OnPrem-01 was completed successfully:

**On VM, in Windows PowerShell 5.1 as Administrator:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans"
.\Verify-OnPrem01Completion.ps1
```

> **⚠️ If any validation fails**: Return to **[OnPrem-01: Scanner Deployment](../OnPrem-01-Scanner-Deployment/README.md)** and complete the missing steps before continuing.

---

## 🔍 Discovery Scan Overview

**Discovery Mode Benefits**:

- Identifies sensitive content **without applying labels or protection**.
- Generates comprehensive reports for data classification analysis.
- Reveals shadow IT data repositories and compliance gaps.
- Provides baseline for DLP policy development.
- Zero risk to existing files (read-only operation).

**What Scanner Discovers**:

- Credit card numbers (Visa, MasterCard, Amex, Discover).
- Social Security Numbers (US SSNs).
- File age and last modified dates (for retention analysis).
- File types and locations.
- Sensitive information type matches.

---

## 🚀 Lab Steps

### Step 1: Add Repository to Content Scan Job

Add the Finance share as the first repository to scan.

> **💡 Finding Your Computer Name**: On the VM, run `$env:COMPUTERNAME` in PowerShell to get the actual name. Due to Windows' 15-character limit, Azure VM names like `vm-purview-scanner` get truncated (e.g., to `VM-PURVIEW-SCAN`).

**In Microsoft Purview compliance portal:**

- Navigate to **Settings** > **Information protection** > **Information protection scanner**.
- Click the **Content scan jobs** tab.
- Click on the content scan job: **Lab-OnPrem-Scan**.
- Click the **Repositories** tab.
- Click **+ Add** to add a new repository.
- Enter the repository details:
  - **Path**: `\\COMPUTERNAME\Finance` (replace COMPUTERNAME with your VM's actual computer name).
  - Example: If your computer name is `VM-PURVIEW-SCAN`, use `\\VM-PURVIEW-SCAN\Finance`.
  - Leave other settings as default.
- Click **Save** at the top of the page.

**Add the additional repositories**:

- Click **+ Add** for each additional repository.
- Add `\\COMPUTERNAME\HR`.
- Add `\\COMPUTERNAME\Projects`.
- Click **Save**.

**CRITICAL: Save the Scan Job**:

- Return to the **General** tab and click **Save**. Failing to perform this step will not allow the VM to sync the updated policy.

**Sync configuration and start initial scan:**

> **⚠️ Critical - Scanner Account Context**: The scanner requires **both** `Update-AIPScanner` and `Start-Scan` to fully sync configuration:
> 
> - `Update-AIPScanner` - Registers the scanner node with the cluster in the portal
> - `Start-Scan` - **Actually pulls the content scan job configuration** from the portal to the local database AND initiates the scan
>
> Until you run `Start-Scan`, the `Get-ScannerRepository` cmdlet will show "WARNING: No content scan job defined."
>
> **Important**: The scan will access file shares using the authentication tokens that were cached by `Set-Authentication -OnBehalfOf` in OnPrem-01. If you're experiencing "SkippedRepositories" issues, you may need to re-run `Set-Authentication` with the `-OnBehalfOf` parameter first.

**Part 1: Sync scanner configuration from portal:**

> **🖥️ Scanner VM Execution Required**: This script uses AIP Scanner cmdlets and must run on the Scanner VM.

**Copy and Execute on Scanner VM:**

1. On your **development/admin machine**, open the script file:

   ```
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans\Update-ScannerConfiguration.ps1
   ```

2. Copy the entire script content (Ctrl+A, Ctrl+C).
3. **RDP to your Scanner VM**.
4. Open **PowerShell ISE** as Administrator on the Scanner VM
5. Paste the script content and save as `Update-ScannerConfiguration.ps1`.
6. Run the script:

   ```powershell
   .\Update-ScannerConfiguration.ps1
   ```

**Part 2: Create SMB file shares:**

Create the SMB shares that the scanner will access:

> **🖥️ Scanner VM Execution Required**: This script creates SMB shares and must run on the Scanner VM.

**Copy and Execute on Scanner VM:**

1. On your **development/admin machine**, open the script file:

   ```
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans\Create-ScannerSMBShares.ps1
   ```

2. Copy the entire script content (Ctrl+A, Ctrl+C).
3. **RDP to your Scanner VM** (or continue in the same PowerShell window).
4. Open **PowerShell ISE** as Administrator on the Scanner VM.
5. Paste the script content and save as `Create-ScannerSMBShares.ps1`.
6. Run the script:

   ```powershell
   .\Create-ScannerSMBShares.ps1
   ```

**Verify SMB shares are accessible:**

> **🖥️ Scanner VM Execution Required**: This script tests SMB share access and must run on the Scanner VM.

**Copy and Execute on Scanner VM:**

1. On your **development/admin machine**, open the script file:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans\Test-RepositoryAccess.ps1
   ```

2. Copy the entire script content (Ctrl+A, Ctrl+C).
3. In the same PowerShell window on Scanner VM (or open new as Administrator).
4. Paste the script content and save as `Test-RepositoryAccess.ps1`.
5. Run the script:

   ```powershell
   .\Test-RepositoryAccess.ps1
   ```

> **✅ Expected Results**:
>
> - All `Test-Path` commands should return `True`
> - If `\\localhost\...` paths work, you can use that format in Purview portal
> - If `\\computername\...` paths work, use your actual computer name in Purview portal
> - **Both formats should work** after creating the SMB shares

**If any paths return False after creating shares:**

1. **Verify File and Printer Sharing is enabled**:
   - Open **Control Panel** > **Network and Sharing Center**
   - Click **Change advanced sharing settings**
   - Ensure **Turn on file and printer sharing** is enabled
   - Click **Save changes**

2. **Verify Windows Firewall allows File Sharing**:

> **🖥️ Scanner VM Execution Required**: This script configures firewall rules and must run on the Scanner VM.

**Copy and Execute on Scanner VM:**

1. On your **development/admin machine**, open the script file:

   ```
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans\Enable-FileSharingFirewall.ps1
   ```

2. Copy the entire script content (Ctrl+A, Ctrl+C).
3. In the same PowerShell window on Scanner VM (or open new as Administrator).
4. Paste the script content and save as `Enable-FileSharingFirewall.ps1`
5. Run the script:

   ```powershell
   .\Enable-FileSharingFirewall.ps1
   ```

**Part 3: Grant NTFS file system permissions to scanner account:**

The scanner requires **both SMB share permissions AND NTFS file system permissions** to access files.

> **🖥️ Scanner VM Execution Required**: This script modifies NTFS permissions and must run on the Scanner VM.

**Copy and Execute on Scanner VM:**

1. On your **development/admin machine**, open the script file:

   ```
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans\Grant-ScannerNTFSPermissions.ps1
   ```

2. Copy the entire script content (Ctrl+A, Ctrl+C).
3. In the same PowerShell window on Scanner VM (or open new as Administrator).
4. Paste the script content and save as `Grant-ScannerNTFSPermissions.ps1`.
5. Run the script:
   
   ```powershell
   .\Grant-ScannerNTFSPermissions.ps1
   ```

**Expected output:**

```text
processed file: C:\PurviewScanner\Finance
Successfully processed files

vm-purview-scanner\scanner-svc:(OI)(CI)(R)
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
> Windows uses a **dual permission model**:
>
> 1. **SMB Share Permissions**: Network access to `\\servername\sharename`
> 2. **NTFS Permissions**: File system access to actual files
>
> The **most restrictive** permission wins. The scanner service needs **Read permission at both levels**.

**Part 4: Start scan to pull content scan job configuration:**

> **🖥️ Scanner VM Execution Required**: This script starts the scanner and must run on the Scanner VM.

**Copy and Execute on Scanner VM:**

1. On your **development/admin machine**, open the script file:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans\Start-InitialScan.ps1
   ```

2. Copy the entire script content (Ctrl+A, Ctrl+C).
3. In the same PowerShell window on Scanner VM (or open new as Administrator).
4. Paste the script content and save as `Start-InitialScan.ps1`.
5. Run the script:

   ```powershell
   .\Start-InitialScan.ps1
   ```

**Expected output from Get-ScannerRepository:**

```
Path                   : \\COMPUTERNAME\Finance
OverrideContentScanJob :
EnableDlp              : On
Enforce                : On
LabelFilesByContent    : On
RelabelFiles           : Off
AllowLabelDowngrade    : Off
[Additional settings displayed]

Path                   : \\COMPUTERNAME\HR
[Full configuration displayed]

Path                   : \\COMPUTERNAME\Projects
[Full configuration displayed]
```

> **⏱️ Scan Duration**: Discovery scans typically take 5-30 minutes depending on the number of files. For the lab sample data (3 shares with ~10 files each), expect 5-10 minutes. The scan is now running using the authentication tokens cached during OnPrem-01 setup.

---

#### Step 2: Monitor Scan Progress

> **🖥️ Scanner VM Execution Required**: This script uses Get-AIPScannerStatus cmdlet and must run on the Scanner VM.

**Copy and Execute on Scanner VM:**

1. On your **development/admin machine**, open the script file:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans\Monitor-ScanProgress.ps1
   ```

2. Copy the entire script content (Ctrl+A, Ctrl+C).
3. In the same PowerShell window on Scanner VM (or open new as Administrator).
4. Paste the script content and save as `Monitor-ScanProgress.ps1`.
5. Run the script:

   ```powershell
   .\Monitor-ScanProgress.ps1
   ```

The script will display real-time scan progress and status updates. Wait for the scan to complete (LastScanEndTime will show a timestamp).

---

### Step 3: Review DetailedReport.csv

> **🖥️ Scanner VM Execution Required**: This script accesses the scanner reports directory and must run on the Scanner VM.

**Copy and Execute on Scanner VM:**

1. On your **development/admin machine**, open the script file:

   ```
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans\Get-DetailedScanReport.ps1
   ```

2. Copy the entire script content (Ctrl+A, Ctrl+C).
3. In the same PowerShell window on Scanner VM (or open new as Administrator).
4. Paste the script content and save as `Get-DetailedScanReport.ps1`.
5. Run the script:

   ```powershell
   .\Get-DetailedScanReport.ps1
   ```

6. In the same PowerShell window on Scanner VM (or open new as Administrator).
7. Paste the script content and save as `Get-DetailedScanReport.ps1`.
8. Run the script:

   ```powershell
   .\Get-DetailedScanReport.ps1
   ```

**Key Columns in DetailedReport.csv**:

| Column | Purpose | Example Values |
|--------|---------|----------------|
| **Repository** | UNC path to share | `\\vm-purview-scan\Finance` |
| **File Name** | Full file path | `\\vm-purview-scan\Finance\CustomerPayments.txt` |
| **Information Type Name** | Sensitive data detected | `Credit Card Number`, `U.S. Social Security Number (SSN)` |
| **Applied Label** | Label applied by scanner | `General \ All Employees (unrestricted)` |
| **Last Modified** | File modification timestamp | `2025-10-26 13:58:15Z` |
| **Status** | Scan operation result | `Success` |

**Expected Results from Sample Data**:

**Finance Folder**:

- Repository: `\\vm-purview-scan\Finance` (or `\\localhost\Finance`).
- File Name: `\\vm-purview-scan\Finance\CreditCards.txt`.
- Information Type Name: `Credit Card Number`.
- Applied Label: `General \ All Employees (unrestricted)` (or label from your policy).
- Status: `Success`.

**HR Folder**:

- Repository: `\\vm-purview-scan\HR` (or `\\localhost\HR`).
- File Name: `\\vm-purview-scan\HR\SSNData.txt`.
- Information Type Name: `U.S. Social Security Number (SSN)`.
- Applied Label: `General \ All Employees (unrestricted)` (or label from your policy).
- Status: `Success`.

**Projects Folder**:

- Repository: `\\vm-purview-scan\Projects` (or `\\localhost\Projects`).
- File Name: `\\vm-purview-scan\Projects\OldProjectData.txt`.
- Last Modified: Shows timestamp 3+ years old.
- Status: `Success`.
- May contain passwords or other sensitive data types.

---

### Step 4: Check Activity Explorer (Optional)

Review scan activity in the Purview compliance portal.

> **💡 Optional Step**: Activity Explorer provides portal-based reporting but is **not required** for lab completion. DetailedReport.csv provides all necessary scan results. If you prefer to skip this step due to the 1-2 hour data delay, proceed directly to the Validation Checklist.

**Navigate to Activity Explorer:**

- Open browser and go to **Microsoft Purview compliance portal**: [https://compliance.microsoft.com](https://compliance.microsoft.com).
- Sign in with your **admin account**.
- Navigate to **Data classification** > **Activity explorer**.

> **⏱️ Data Ingestion Delay**: Activity Explorer data may take **1-2 hours** to appear after scan completion. This is normal Azure data ingestion latency. If data isn't visible yet, proceed to OnPrem-03 and return to Activity Explorer later.

**Filter Activity Explorer Results:**

- **Activity type**: Filter by "File discovered".
- **Source**: Filter by "Scanner".
- **Location**: Shows your repository paths.
- **Sensitive info type**: Shows Credit Card Number, SSN, etc.

**Expected Activity Explorer Data**:

- Multiple "File discovered" events.
- Source: Scanner.
- Sensitive information types detected.
- File paths matching your repositories.

---

## ✅ Validation Checklist

Before proceeding to OnPrem-03, verify:

### Repository Configuration

- [ ] Repositories added in Purview portal: Finance, HR, Projects (minimum).
- [ ] Content scan job saved in portal (General tab → Save).
- [ ] `Update-AIPScanner` executed successfully.
- [ ] Scanner service restarted and running.

### SMB Share Creation

- [ ] SMB shares created: Finance, HR, Projects.
- [ ] `Get-SmbShare` shows all three shares.
- [ ] `Test-Path "\\localhost\Finance"` returns True.
- [ ] `Test-Path "\\COMPUTERNAME\Finance"` returns True (using actual computer name).
- [ ] All repository paths accessible via UNC path from scanner VM.

### NTFS Permissions

- [ ] icacls commands executed for all three folders.
- [ ] `icacls "C:\PurviewScanner\Finance" | findstr scanner-svc` shows Read permissions.
- [ ] Scanner service account has (OI)(CI)R permissions on all repository folders.

### Configuration Sync

- [ ] `Get-ScannerRepository` shows all repositories (Finance, HR, Projects).
- [ ] Repository paths match what was configured in Purview portal.
- [ ] No "WARNING: No content scan job defined" message.

### Scan Execution

- [ ] `Start-Scan` command executed without errors.
- [ ] `Get-AIPScannerStatus` shows `LastScanEndTime` populated (not null).
- [ ] Scan duration was several minutes (not 1-2 seconds).
- [ ] `SkippedRepositories` field is empty: `{}`.
- [ ] `ScannedFileCount` shows positive number (3+ files).
- [ ] No errors in Event Viewer > Azure Information Protection logs.

### Scan Results - CSV Report

- [ ] DetailedReport.csv found in `C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports`.
- [ ] Report contains rows for sample files (CreditCards.txt, SSNData.txt, OldProjectData.txt, etc.).
- [ ] PowerShell table output displays correctly with Repository, File Name, Information Type Name columns.
- [ ] Information Type Name shows: `Credit Card Number`, `U.S. Social Security Number (SSN)`.
- [ ] Applied Label column shows labels from your policy.
- [ ] Status column shows `Success` for scanned files.

### Scan Results - Portal (Activity Explorer)

> **Note**: If less than 2 hours since scan completion, Activity Explorer data may not be visible yet. This is normal - proceed to OnPrem-03 and check Activity Explorer later.

- [ ] Activity Explorer accessible in Purview compliance portal
- [ ] "File discovered" events appear (after 1-2 hour ingestion delay)
- [ ] Sensitive information types shown in event details

### Sample Data Validation

- [ ] Finance folder: Credit card patterns detected in CreditCards.txt.
- [ ] HR folder: SSN patterns detected in SSNData.txt.
- [ ] Projects folder: OldProjectData.txt scanned successfully.
- [ ] DetailedReport.csv shows expected files from all three repositories.

---

## 🔍 Troubleshooting

### Get-ScannerRepository shows "No content scan job or repositories defined"

**Symptoms**: After running `Update-AIPScanner`, `Get-ScannerRepository` returns warning about no content scan job or repositories defined

**Solutions**:

1. **Run Start-Scan first**: **Most important** - `Update-AIPScanner` only registers the scanner node with the cluster. You must run `Start-Scan` to actually pull the content scan job configuration from the portal to the local database. After `Start-Scan` completes initialization (a few seconds), `Get-ScannerRepository` will show all configured repositories.

2. **Save the scan job in portal**: Second most common cause - after adding repositories in Purview portal, you must return to the **General** tab and click **Save** to commit the changes.

3. **Verify portal configuration**: In Purview portal, check that repositories appear under Content scan job > Repositories tab.

4. **Check scanner service**: Ensure `MIPScanner` service is running: `Get-Service -Name "MIPScanner"`.

5. **Restart scanner service if needed**: `Restart-Service -Name "MIPScanner"` then wait 30 seconds before running `Start-Scan`.

### Repositories showing as "SkippedRepositories" in scan status

**Symptoms**: `Get-AIPScannerStatus` shows repositories listed under `SkippedRepositories` instead of being scanned. Scan completes in 1-2 seconds with no files processed.

**Root Causes**: This issue has TWO common causes that must BOTH be addressed:

1. **Incorrect UNC path format in Purview portal** (Most Common)
2. **Missing authentication tokens** (Less Common if OnPrem-01 completed successfully)

---

**SOLUTION 1: Test and Fix Repository UNC Paths** ⭐ **TRY THIS FIRST**

The scanner cannot resolve the UNC network paths configured in the Purview portal, even though NTFS and SMB permissions are correctly configured.

**Diagnostic Steps:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans"
.\Test-RepositoryPathDiagnostics.ps1
```

**Expected Results:**

- ✅ `Test-Path` should return `True` for at least ONE path format (localhost OR computername).
- ✅ NTFS permissions should show `scanner-svc:(OI)(CI)(R)`.
- ✅ SMB permissions should show `scanner-svc` with `Full` or `Read` access.

**If `\\localhost\...` or `\\computername\...` returns TRUE but repositories still skipped:**

The issue is that the **UNC paths in the Purview portal don't match** the paths that actually work on your VM.

**Fix the Repository Paths in Purview Portal:**

1. **Navigate to Purview Portal**:
   - Go to [compliance.microsoft.com](https://compliance.microsoft.com)
   - Navigate to **Information protection** > **Scanner** > **Content scan jobs**
   - Click on your scan job name (e.g., **OnPrem-Discovery-Scan**)

2. **Update Repository Paths**:
   - Select **Repositories** tab
   - For **each repository** (Finance, HR, Projects):
     - Click the **Edit** (pencil) icon
     - Change the **Path** to use the format that worked in your Test-Path commands:
       - If `\\localhost\Finance` returned `True`, use: `\\localhost\Finance`
       - If `\\vm-purview-scan\Finance` returned `True`, use: `\\vm-purview-scan\Finance`
       - Use your actual computer name from `$env:COMPUTERNAME`
     - Click **Save**

3. **Save the Content Scan Job**:
   - **CRITICAL**: After editing repositories, click the **General** tab
   - Click **Save** to commit all changes
   - Wait for "Successfully saved" confirmation

4. **Update Scanner Configuration on VM**:

   ```powershell
   cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans"
   .\Update-RepositoryPathsPostFix.ps1
   ```

5. **Re-run Discovery Scan**:

   ```powershell
   cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans"
   .\Invoke-ScanAfterFix.ps1
   ```

**Expected Results After Fix:**

- ✅ Scan duration: Several minutes (not 1-2 seconds).
- ✅ `Get-AIPScannerStatus` shows: `SkippedRepositories: {}` (empty).
- ✅ Scanned files count: 3+ files from repositories.
- ✅ No "not accessible" errors in scan reports.
- ✅ Sensitive information types detected.

---

**SOLUTION 2: Re-authenticate with OnBehalfOf Tokens** (Only if Solution 1 didn't work)

If repository paths are correct but still being skipped, the scanner may lack authentication tokens.

```powershell
# Get scanner service account credentials
$scannerCreds = Get-Credential COMPUTERNAME\scanner-svc

# Re-authenticate with OnBehalfOf to cache tokens
Set-Authentication `
    -AppId "YOUR-APP-ID" `
    -AppSecret "YOUR-SECRET-VALUE" `
    -TenantId "YOUR-TENANT-ID" `
    -DelegatedUser "scanner-svc@yourtenant.onmicrosoft.com" `
    -OnBehalfOf $scannerCreds

# Expected output: "Acquired access token on behalf of COMPUTERNAME\scanner-svc"

# Verify authentication
Start-ScannerDiagnostics -OnBehalfOf $scannerCreds
# Should show: Authentication check completed successfully

# Restart scan
Start-Scan
```

> **💡 Why Two Solutions?**
>
> - **Path Issue (Solution 1)**: Scanner cannot resolve the UNC path format used in portal configuration
> - **Auth Issue (Solution 2)**: Scanner has no cached tokens to authenticate to Purview services
>
> **Both** authentication tokens AND correct UNC paths are required. If one is missing, repositories will be skipped.

### Scanner service not running or crashes

**Symptoms**: `Get-Service -Name "MIPScanner"` shows "Stopped" or service keeps stopping

**Solutions**:

1. **Check Event Viewer**: Applications and Services Logs > Azure Information Protection for error details.
2. **Restart scanner service**: `Restart-Service -Name "MIPScanner"`.
3. **Verify authentication**: Run `Start-ScannerDiagnostics -OnBehalfOf $scannerCreds` from OnPrem-01.
4. **Check account permissions**: Scanner service account must be local admin on VM.

### No files scanned or scan completes in 1-2 seconds

**Symptoms**: Scan completes immediately but DetailedReport.csv is empty or shows zero files

**Solutions**:

1. **Verify SMB shares created**: Run `Get-SmbShare` and confirm Finance, HR, Projects shares exist.
2. **Test path accessibility**: `Test-Path "\\localhost\Finance"` should return True.
3. **Check NTFS permissions**: Run `icacls "C:\PurviewScanner\Finance" | findstr scanner-svc`.
4. **Verify sample files exist**: Navigate to `C:\PurviewScanner\Finance` and confirm .txt files are present.
5. **Check repository paths in portal**: UNC paths must exactly match accessible format (localhost vs computername).

### Information types not detected in sample files

**Symptoms**: Scan finds files but no sensitive info types matched in DetailedReport.csv

**Solutions**:

1. **Verify sample data format**: 
   - Credit cards: 16-digit numbers (e.g., `4111111111111111`).
   - SSNs: XXX-XX-XXXX format with hyphens (e.g., `123-45-6789`).
2. **Check file content**: Open sample files to ensure they contain the expected sensitive data.
3. **Label policy published**: Verify label policy is published in Purview portal.
4. **Wait for sync**: Allow 15-30 minutes after label policy changes before scanning.

### Activity Explorer shows no data after 2+ hours

**Symptoms**: Portal activity data not appearing despite successful scan and DetailedReport.csv exists

**Solutions**:

1. **Azure ingestion delay**: Normal delay is 1-2 hours, but can take up to 24 hours in some cases
2. **Use DetailedReport.csv for immediate results**: The CSV report provides instant verification
3. **Verify auditing enabled**: Check that audit log ingestion is enabled (should be from Setup-01)
4. **Check scan completion**: Confirm DetailedReport.csv exists and contains scanned files

> **💡 Note**: Activity Explorer is not required for lab completion. The DetailedReport.csv provides all necessary scan results. If Activity Explorer data hasn't appeared after 2 hours, proceed with the lab and check back later.

---

## 📊 Common Discovery Patterns

| Pattern | Meaning | Action |
|---------|---------|--------|
| Multiple files with credit cards | Finance data spread across shares | Consolidate to secure location |
| SSNs in multiple folders | HR data not centralized | Implement data governance |
| Old files (3+ years) with sensitive data | Retention policy gaps | Apply retention policies |
| .zip files with sensitive content | Archived sensitive data | Review archive policies |

---

## 💡 Discovery Scan Best Practices

**For Lab Environment**:

- Configure all three repositories (Finance, HR, Projects) in the portal before starting scan.
- Save the content scan job in portal (General tab) to commit repository changes.
- Create SMB shares before granting NTFS permissions.
- Test UNC path accessibility with both localhost and computername formats.
- Review DetailedReport.csv immediately using PowerShell table output for instant results.
- Activity Explorer is optional and has 1-2 hour data delay.

**For Production Deployments**:

- Always run discovery scan first before enabling enforcement or auto-labeling.
- Establish baseline of sensitive data location and volume before applying policies.
- Use DetailedReport.csv for stakeholder presentations and compliance reporting.
- Plan label policies based on actual discovery results, not assumptions.
- Schedule scans during off-hours to minimize network impact.
- Implement proper permission model: SMB shares, NTFS permissions, and authentication tokens.

---

## ⏭️ Next Steps

Discovery scan completed successfully! You now have:

- ✅ Repositories configured for on-premises SMB shares (Finance, HR, Projects).
- ✅ Discovery scan executed and completed.
- ✅ DetailedReport.csv generated with sensitive content analysis.
- ✅ Baseline understanding of credit card and SSN data locations.

**OnPrem Scanning Foundation Complete!** Scanner is operational and discovering sensitive content.

Proceed to **[OnPrem-03: DLP Policy Configuration](../OnPrem-03-DLP-Policy-Configuration/README.md)** to create Data Loss Prevention policies that will prevent external sharing of the credit card and SSN data you just discovered.

---

## 📚 Reference Documentation

- [Scanner repository configuration](https://learn.microsoft.com/en-us/purview/deploy-scanner-configure-install#configure-the-scanner-in-the-azure-portal)
- [Run discovery scans](https://learn.microsoft.com/en-us/purview/deploy-scanner-manage)
- [Sensitive information types](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)
- [Activity Explorer in Purview](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)
- [DetailedReport.csv schema](https://learn.microsoft.com/en-us/purview/deploy-scanner-manage#detailed-report)

---

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of discovery scan procedures and scanner report analysis while maintaining technical accuracy for sensitive information type detection.*

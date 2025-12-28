# Advanced Remediation

## 📋 Overview

**Duration**: 4-6 hours

**Objective**: Apply advanced remediation automation techniques specific to production data governance projects, including multi-tier severity-based remediation, dual-source deduplication (on-prem + cloud), SharePoint PnP PowerShell automation, and stakeholder progress tracking.

**What You'll Learn:**

- Implement multi-tier remediation strategies based on data severity and age.
- Handle dual-source scenarios (on-premises + cloud storage).
- Automate SharePoint/OneDrive bulk deletion using PnP PowerShell.
- Create progress tracking dashboards for stakeholder reporting.
- Apply production deployment best practices.

**Prerequisites for Remediation Labs:**

- All main labs in Sections 1-3 (Setup, OnPrem-Scanning, Cloud-Scanning) completed successfully.
- Scanner reports available in `%LOCALAPPDATA%\Microsoft\MSIP\Scanner\Reports\`.
- Azure Files share deployed with test files (from OnPrem-01).
- VM has direct network access to on-prem shares (`\\COMPUTERNAME\Projects`).
- SharePoint test site created (from Cloud-01).
- **PowerShell 5.1** (required for Purview scanner compatibility - do NOT upgrade to PowerShell 7).

**Additional Prerequisites for Step 5 (Progress Tracking from External Admin Machine):**

> **💡 Note**: If you plan to run Step 5 from an admin machine **outside the Azure VNet** (e.g., your work/home workstation), complete these one-time setup steps on both your **admin machine** and the **Azure VM**:

**On Your Admin Machine** (one-time setup):

1. **Enable WinRM Service** (requires Administrator PowerShell):

   ```powershell
   Enable-PSRemoting -Force -SkipNetworkProfileCheck
   ```

2. **Add VM to TrustedHosts** (requires Administrator PowerShell):

   ```powershell
   # Replace with your VM's public IP
   Set-Item WSMan:\localhost\Client\TrustedHosts -Value '<VM_PUBLIC_IP>' -Force
   ```

**On Azure VM** (one-time setup via RDP):

1. **Enable PowerShell Remoting**:

   ```powershell
   Enable-PSRemoting -Force -SkipNetworkProfileCheck
   ```

2. **Allow WinRM through Windows Firewall**:

   ```powershell
   Set-NetFirewallRule -Name WINRM-HTTP-In-TCP -Enabled True
   ```

3. **Verify WinRM Listening**:

   ```powershell
   Get-NetTCPConnection -LocalPort 5985 -State Listen
   # Expected: Shows listening on port 5985
   ```

**In Azure Portal** (one-time NSG configuration):

1. **Find Your Public IP Address**:

   ```powershell
   (Invoke-WebRequest -Uri "https://api.ipify.org").Content
   ```

2. **Add NSG Inbound Rule**:
   - Navigate to: Azure Portal → Your VM → **Networking** → **Add inbound port rule**
   - **Source**: `IP Addresses`
   - **Source IP addresses/CIDR ranges**: `<YOUR_PUBLIC_IP>/32` (e.g., `203.0.113.45/32`)
   - **Source port ranges**: `*`
   - **Destination**: `Any`
   - **Service**: `Custom`
   - **Destination port ranges**: `5985`
   - **Protocol**: `TCP`
   - **Action**: `Allow`
   - **Priority**: `1000`
   - **Name**: `Allow-WinRM-MyIP`
   - **Description**: `Allow PowerShell Remoting from my public IP`

3. **Verify Connectivity** (from admin machine):

   ```powershell
   Test-NetConnection -ComputerName <VM_PUBLIC_IP> -Port 5985
   # Expected: TcpTestSucceeded : True
   ```

> **🔒 Security Note**: These prerequisites are **only required** if you choose Option 2 (external access via public IP) in Step 5. If your admin machine is on the same Azure VNet or connected via VPN/ExpressRoute, use Option 1 (network share) instead - it's simpler and more secure.
>
> **⚠️ Production Recommendation**: For production environments, use Azure Bastion, VPN Gateway, or private endpoints instead of exposing WinRM to public internet. The public IP + WinRM approach shown here is for lab/testing purposes.

---

## 💻 Script Execution Location Guide

> **🎯 IMPORTANT**: Different scripts in this lab must be executed from different locations depending on what resources they access.

### Quick Reference Table

| Script Section | Execute From | Why | Requirements |
|----------------|--------------|-----|--------------|
| **Step 1**: Severity-Based Remediation | **🖥️ VM (COMPUTERNAME)** | Accesses scanner reports stored locally on VM | Scanner reports in `%LOCALAPPDATA%\Microsoft\MSIP\Scanner\Reports\` |
| **Step 2**: Dual-Source Deduplication | **🖥️ VM (COMPUTERNAME)** | Direct access to on-prem file shares and Azure Files | Network access to UNC paths `\\COMPUTERNAME\Projects` |
| **Step 3**: SharePoint PnP PowerShell | **💼 Admin Machine (your workstation)** | Connects to SharePoint Online via internet | PnP.PowerShell module, SharePoint admin permissions |
| **Step 4**: On-Prem Remediation + Tombstones | **🖥️ VM (COMPUTERNAME)** | Deletes files on on-prem shares, creates tombstones | Write access to on-prem file shares |
| **Step 5**: Progress Tracking Dashboard | **💼 Admin Machine (your workstation)** | Reads CSV files, generates reports | CSV files copied from VM |

### Recommended Workflow

```
PHASE 1: Scanner Analysis (VM) → Generate remediation plans
    ↓
PHASE 2: SharePoint Cleanup (Admin Machine) → PnP PowerShell deletion
    ↓
PHASE 3: On-Prem Cleanup (VM) → File deletion + tombstones
    ↓
PHASE 4: Reporting (Admin Machine) → Progress dashboards
```

### Key Considerations

**Scanner Reports Location**:

- Reports are stored on the VM at: `C:\Users\svc-purview-scanner\AppData\Local\Microsoft\MSIP\Scanner\Reports\`.
- Cannot be accessed remotely - must run scripts on VM or copy CSV files to admin machine.

**SharePoint Operations**:

- PnP PowerShell connects to SharePoint Online via Microsoft Graph API.
- Does NOT require VM - runs from any machine with internet connectivity.
- Easier modern authentication (interactive login) from admin machine.

**File Share Access**:

- VM has direct network access to on-prem shares (`\\COMPUTERNAME\Projects`).
- Admin machine may not have access to internal UNC paths (check your network configuration).

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

1. Implement severity-based remediation decision matrix (HIGH/MEDIUM/LOW data)
2. Handle dual-source remediation scenarios (on-prem + cloud)
3. Deduplicate files across on-premises and cloud shares
4. Automate SharePoint/OneDrive bulk deletion with PnP PowerShell
5. Create weekly/monthly progress tracking reports
6. Build stakeholder dashboards showing remediation velocity
7. Apply tombstone creation patterns for audit compliance

---

## 🚨 Important: Project-Specific Scenarios

> **💡 Context**: This lab addresses the specific challenges from your consultancy project:
>
> - **Challenge #1**: On-prem scanners can't do auditing - must apply remediation via scripting
> - **Challenge #2**: On-prem scanner can't do retention labeling - use PowerShell lifecycle management
> - **Challenge #3**: SharePoint eDiscovery doesn't have remediation - use PnP PowerShell for "seek and destroy"
> - **Current State**: Dual data sources (on-prem + cloud storage) requiring coordinated remediation
> - **Future State**: Automated, severity-based remediation with stakeholder progress tracking

---

## 📖 Step-by-Step Instructions

---

### Step 0: Generate Test Data for All Remediation Scenarios (OPTIONAL)

> **💻 Execute From**: **VM (COMPUTERNAME)**  
> **Why**: Creates comprehensive test data across on-prem, cloud, and SharePoint for all lab steps  
> **Requirements**:
>
> - Write access to `\\COMPUTERNAME\Projects` share
> - Azure Files share configured (from OnPrem-01) with UNC path access
> - SharePoint site with document library (from Cloud-01)
> - SharePointPnPPowerShellOnline module: `Install-Module -Name SharePointPnPPowerShellOnline -Scope CurrentUser`
> - **PowerShell 5.1** (do NOT use PowerShell 7 - Purview scanner requires 5.1)
>
> **When to Use**: If you only have 3 test files and want to see realistic remediation results across ALL lab steps

This optional script generates **isolated test data sets** for each remediation scenario without conflicts.

> **🎯 Data Isolation Strategy**:
>
> - **Step 1 Files** (On-Prem Only) → `\\COMPUTERNAME\Projects\RemediationTestData\Step1-SeverityBased\`
> - **Step 2 Files** (Dual-Source) → `\\COMPUTERNAME\Projects\RemediationTestData\Step2-DualSource\` + Azure Files copy
> - **Step 3 Files** (SharePoint) → Uploaded to SharePoint document library (separate from on-prem)
> - **Step 4 Files** → Uses Step 1 remediation plan (reads only, doesn't conflict)
> - **Step 5 Dashboard** → Reads CSV outputs (no file conflicts)

**Run Test Data Generation Script:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-Remediation"
.\Generate-RemediationTestData.ps1
```

**Expected Results:**

After running this test data generation script, you should see:

- ✅ **11 test files created** in `\\COMPUTERNAME\Projects\RemediationTestData\`.
- ✅ **File distribution**:
  - 4 HIGH severity files (PCI/PHI/HIPAA data).
  - 4 MEDIUM severity files (SSN, Passport, Driver's License).
  - 3 LOW severity files (Email addresses, phone numbers).
- ✅ **Age range**: 3 months to 7+ years old covering all decision matrix scenarios.
- ✅ **Console output** with color-coded severity indicators.

> **📊 Scanner Detection Note**: The script creates 11 files, but the scanner will only detect files matching your configured Sensitive Information Types (SITs). Typical detection: 5-8 files. This is normal behavior and demonstrates that SIT pattern matching is working correctly.

---

### Step 0.5: Run Full Rescan to Detect New Test Files

> **💻 Execute From**: **VM (COMPUTERNAME)**  
> **Why**: After adding test files, force a full re-scan to ensure scanner detects all new files  
> **Requirements**: Windows PowerShell 5.1 as Administrator

After creating test data in Step 0, run a full re-scan to detect the new files.

> **🔍 Why `-Reset` Parameter?**: By default, the scanner only scans new or modified files after the first run (incremental scan). Since you added test files to existing directories, use `-Reset` to force a full re-scan of ALL files.

**Run Full Rescan:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-Remediation"
.\Start-ScannerRescan.ps1
```

**Expected Results:**

After the scan completes (5-15 minutes), you should see:

- ✅ **5+ test files detected** with sensitive data (actual count depends on your sensitivity label policy configuration).
- ✅ **Step 1 script shows remediation actions** across different severity levels and age ranges.

> **📊 Note on Detection Counts**: The test data script creates 11 files, but the scanner only detects files that match your configured Sensitive Information Types (SITs). Typical detection: 5-8 files depending on which SITs are enabled in your sensitivity labels. This demonstrates real-world behavior where not all files with sensitive-looking content match SIT patterns.

---

### Step 1: Multi-Tier Severity-Based Remediation

> **💻 Execute From**: **VM (COMPUTERNAME)**  
> **Why**: This script accesses scanner reports stored locally on the VM at `%LOCALAPPDATA%\Microsoft\MSIP\Scanner\Reports\`  
> **Requirements**: RDP/SSH access to VM where Purview scanner is installed

Real-world projects require different remediation actions based on data sensitivity and age criteria.

**Remediation Decision Matrix:**

| Data Severity | Age (Last Access) | Recommended Action | Rationale |
|---------------|-------------------|-------------------|-----------|
| **HIGH** (PCI, PHI, HIPAA) | 0-1 year | Retain + Encrypt | Active sensitive data, legal protection required |
| **HIGH** (PCI, PHI, HIPAA) | 1-3 years | Archive to secure storage | Historical value, restricted access needed |
| **HIGH** (PCI, PHI, HIPAA) | 3+ years | Manual review before deletion | Compliance review required, potential legal holds |
| **MEDIUM** (PII: SSN, Passport) | 0-2 years | Retain with DLP monitoring | Active use, moderate sensitivity |
| **MEDIUM** (PII) | 2-3 years | Archive to long-term storage | Declining usage, moderate sensitivity |
| **MEDIUM** (PII) | 3+ years | Auto-delete with audit logging | Past retention requirements, automated cleanup |
| **LOW** (General business) | 3+ years | Auto-delete immediately | No special handling, storage optimization |

**Run Severity-Based Remediation Analysis:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-Remediation"
.\Analyze-SeverityBasedRemediation.ps1
```

**Expected Results:**

After running this script, you should see:

- ✅ **Remediation plan CSV created**: `C:\PurviewLab\RemediationPlan.csv`.
- ✅ **Console summary table** showing breakdown by action type:
  
  ```text
  Name                   Count Percentage
  ----                   ----- ----------
  RETAIN_ENCRYPT             1       20.0
  RETAIN_MONITOR             1       20.0
  ARCHIVE_STANDARD           1       20.0
  AUTO_DELETE_WITH_AUDIT     1       20.0
  MANUAL_REVIEW_REQUIRED     1       20.0
  ```

- ✅ **Total files with sensitive data**: 5 files from test dataset (production environments typically have thousands).
- ✅ **Files requiring manual review**: 1 file with HIGH severity data (PCI/PHI) that is 3+ years old.
- ✅ **Remediation plan** ready for Steps 3-4 (actual deletion).

**CSV File Contents** (`RemediationPlan.csv`):

- FilePath, Severity, SITs, AgeYears, LastModified, Action, EstimatedDeletionDate columns.
- One row per file with sensitive data.
- Used as input for subsequent remediation steps.

> **🎯 Production Tip**: This lab uses a small test dataset (5 files) to demonstrate the decision matrix. In production environments with thousands of files, you'd see more realistic distributions like 40% RETAIN_MONITOR, 30% AUTO_DELETE, 15% ARCHIVE, etc.

---

### Step 2: Dual-Source Remediation (On-Prem + Azure Files Cloud Storage)

> **💻 Execute From**: **VM (COMPUTERNAME)**  
> **Target Storage**: **Azure Files** (cloud file shares accessed via SMB/UNC paths)  
> **NOT SharePoint**: This step handles Azure Files, which is different from SharePoint Online  
> **Why**: Requires direct network access to both on-prem file shares and Azure Files UNC paths  
> **Requirements**:
>
> - Network access to `\\COMPUTERNAME\Projects` (on-prem share)
> - Network access to Azure Files (e.g., `\\storageaccount.file.core.windows.net\sharename`)
> - SMB permissions on both shares

Handle scenarios where the same files exist in both on-premises and Azure Files cloud storage during migration or hybrid storage deployments.

**Scenario**: During cloud migration, files may exist in both locations. Identify duplicates and prioritize remediation.

**Run Dual-Source Deduplication Analysis:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-Remediation"
.\Analyze-DualSourceDeduplication.ps1
```

**Expected Results:**

After running this deduplication script, you should see:

- ✅ **Console summary** with file counts:
  
  ```text
  ========== DUAL-SOURCE ANALYSIS ==========
  On-Prem Files: 16
  Cloud Files: 5
  Duplicates Found: 3
  Potential Storage Savings: 0 MB
  ```

- ✅ **Duplicates CSV created**: `C:\PurviewLab\Duplicates.csv` with columns:
  - FileName, OnPremPath, CloudPath, SizeMB.
  - OnPremLastModified, CloudLastModified, Recommendation.
- ✅ **Safe deletion list** displayed showing 3 files where cloud version is newer:
  - Compliance_Audit_2022.txt.
  - Financial_Report_Q1_2023.txt.
  - Marketing_Strategy_2024.txt.
- ✅ **Storage savings**: 0 MB (test files are tiny for demonstration purposes).

**What This Tells You:**

- **Duplicate detection works**: 3 out of 5 cloud files have matching on-prem versions (60% overlap)
- **Cloud versions are newer**: All 3 duplicates show cloud files modified more recently
- **Safe to delete on-prem**: Cloud storage has the latest versions
- **Small dataset demonstration**: Production environments typically find hundreds or thousands of duplicates

> **⚠️ Production Consideration**: Always verify file content integrity before deleting duplicates. Consider using hash comparison (Get-FileHash) for critical data instead of just name/size matching. In production scenarios with thousands of files, you'd see 40-60% overlap during migration with significant storage savings (GB or TB).

---

### Step 3: SharePoint/OneDrive PnP PowerShell Automation

**Overview**: Bulk delete sensitive files from SharePoint Online using PnP PowerShell. The script automatically handles Entra ID app registration, connects to SharePoint, queries for old/sensitive files, creates an audit log, and safely moves files to the Recycle Bin.

**Prerequisites**:

- **PnP.PowerShell module**: `Install-Module -Name PnP.PowerShell -Force -Scope CurrentUser`
- **SharePoint permissions**: Site Owner or Site Collection Admin
- **PowerShell version**: PowerShell 7.x recommended (5.1 limited to PnP v1.x)
- **Admin consent**: Global Admin or Application Admin to grant app permissions

**Key Differences from Step 2 (Azure Files)**:

| Aspect | Step 2 (Azure Files) | Step 3 (SharePoint Online) |
|--------|---------------------|---------------------------|
| **Storage Type** | Cloud file shares (SMB) | Collaboration sites (REST API) |
| **Access Method** | UNC paths | HTTPS URLs |
| **Authentication** | Storage key | OAuth 2.0 with Entra ID app |
| **Use Case** | Migrated file server data | Teams/OneDrive collaboration files |

**What the Script Does**:

1. **Prompts for SharePoint site URL** with validation
2. **Auto-detects tenant** from URL
3. **Checks for Entra ID app registration** (environment variable `$env:ENTRAID_APP_ID`)
4. **Offers 3 registration options** if app doesn't exist:
   - Automatic (PowerShell 7.4+ using `Register-PnPEntraIDAppForInteractiveLogin`)
   - Manual (step-by-step Azure Portal instructions)
   - Skip (if you already have a Client ID)
5. **Validates Client ID** format (GUID)
6. **Sets environment variable** for session persistence
7. **Connects to SharePoint** with choice of Interactive or Device Code authentication
8. **Queries files** matching deletion criteria (3+ years old OR sensitive data indicators)
9. **Creates audit log** (`C:\PurviewLab\SharePoint-Deletions.csv`)
10. **Prompts for confirmation** before deletion
11. **Safely deletes files** to Recycle Bin (93-day recovery window)

> **Execute From**: **Admin Machine (your workstation)**  
> **Why**: SharePoint/OneDrive connections require interactive authentication and PnP PowerShell module on admin workstation  
> **Not on VM**: This script connects to SharePoint Online, not on-premises file shares

**💡 Authentication Note**: The script handles authentication in two steps - first creating/verifying the Entra ID app registration, then connecting to SharePoint. Device Code Flow (`-DeviceLogin`) works best in terminals; Interactive Browser works best in standalone PowerShell.

**Run SharePoint Deletion Script:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-Remediation"
.\Remove-SharePointDuplicates.ps1
```

**Expected Results:**

After running this SharePoint deletion script, you should see:

- ✅ **PnP PowerShell module installed** successfully (first-time setup).
- ✅ **Connection established** to SharePoint site with modern authentication prompt.
- ✅ **Site details displayed**:
  
  ```text
  Title: Finance Test Site
  Url: https://[yourtenant].sharepoint.com/sites/[YourTestSite]
  ```

- ✅ **Deletion candidate count**: Typically 50-200 files matching criteria (3+ years old or sensitive indicators).
- ✅ **Audit log CSV created**: `C:\PurviewLab\SharePoint-Deletions.csv` before any deletion occurs.
- ✅ **User confirmation prompt**: "Delete [X] files from SharePoint? (yes/no)".
- ✅ **Deletion progress**: Green checkmarks for each successfully deleted file.
- ✅ **Files moved to Recycle Bin** (not permanently deleted).
- ✅ **Final summary**:
  
  ```text
  [SUCCESS] Deletion complete. Files moved to SharePoint Recycle Bin.
  Audit log saved to: C:\PurviewLab\SharePoint-Deletions.csv
  ```

**Audit Log Contents** (`SharePoint-Deletions.csv`):

- FileName, FilePath, Modified, ModifiedBy, SizeMB, DeletedOn, Reason columns.
- Complete deletion trail for compliance auditing.
- Can be used for restoration requests.

**SharePoint Recycle Bin**:

- Deleted files remain in Recycle Bin for 93 days (default).
- Can be restored by site collection admins.
- Navigate to: Site Settings → Recycle Bin → Second-stage Recycle Bin.

> **💡 PnP PowerShell Tip**: Use `-Recycle` parameter instead of permanent deletion. This moves files to SharePoint Recycle Bin where they can be restored for 93 days (default retention).

---

### Step 4: On-Premises Remediation with Tombstone Creation

**Overview**: Delete files from on-premises file shares and create tombstone audit files for restoration reference. The script reads the remediation plan from Step 1, confirms deletion with the user, creates detailed tombstones before deletion, and verifies successful deletion.

**Prerequisites**:

- **Remediation plan**: `C:\PurviewLab\RemediationPlan.csv` from Step 1
- **File share permissions**: Write/delete access to on-premises file shares
- **Disk space**: Sufficient space for tombstone files (minimal - text only)
- **Backup system**: Reference to organizational backup system (e.g., Rubrik)

**What the Script Does**:

1. **Loads remediation plan** from Step 1 CSV
2. **Filters for auto-delete actions** (AUTO_DELETE, AUTO_DELETE_WITH_AUDIT)
3. **Displays deletion count** and prompts for confirmation
4. **Creates tombstone files** with complete deletion metadata BEFORE deletion
5. **Deletes original files** from on-premises shares
6. **Verifies deletion** by checking file existence
7. **Reports summary** (deleted count, tombstones created, any failures)

> **💡 Tombstone Purpose**: Tombstones document when/why files were deleted and provide restoration instructions. They remain in the original directory for discovery by users and backup administrators.

> **💻 Execute From**: **VM (COMPUTERNAME)**  
> **Why**: Deletes files from on-premises file shares and creates tombstone audit files  
> **Requirements**:
>
> - Remediation plan CSV from Step 1 (`C:\PurviewLab\RemediationPlan.csv`)
> - Write/delete permissions on on-premises file shares
> - Disk space for tombstone files (minimal - text only)
> - Reference to organizational backup system (e.g., Rubrik)

**Run On-Premises Deletion Script:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-Remediation"
.\Remove-OnPremDuplicates.ps1
```

**Expected Results:**

After running this on-premises deletion script, you should see:

- ✅ **Remediation plan analysis**:
  
  ```text
  ========== REMEDIATION PLAN ANALYSIS ==========
  Total files in remediation plan: 5
  Files marked for AUTO_DELETE: 1
  
  Analyzing current state of files...
  
  ========== CURRENT STATE ==========
  Files still in original location: 1
  Files already deleted (not found): 0
  Existing tombstones found: 0
  
  Files remaining to delete: 1
  ```

- ✅ **User confirmation prompt**: "Proceed with deletion? (yes/no)".
- ✅ **For each file deleted**:
  
  ```text
  ✅ Deleted: Background_Check_2020.txt
     Tombstone: \\vm-purview-scan\Projects\RemediationTestData\Step1-SeverityBased\Background_Check_2020.txt.DELETED_20251029_111126.txt
  ```

- ✅ **Deletion verification**:
  
  ```text
  ========== DELETION VERIFICATION ==========
  Verifying files have been deleted...
  
  ✅ Confirmed deleted: Background_Check_2020.txt
  ```

- ✅ **Verification summary**:
  
  ```text
  ========== VERIFICATION SUMMARY ==========
  Files Successfully Deleted: 1
  Files Still Exist: 0
  Tombstone Files Created: 1
  
  ✅ All files deleted successfully!
  ```

- ✅ **Tombstone files created** in same directory as deleted files:
  - Named with `.DELETED_[timestamp].txt` suffix
  - Contains complete deletion metadata
  - Includes restoration instructions

**If All Files Already Processed:**

If you've run the script before, you'll see an early exit message:

```text
========== REMEDIATION PLAN ANALYSIS ==========
Total files in remediation plan: 5
Files marked for AUTO_DELETE: 1

Analyzing current state of files...

========== CURRENT STATE ==========
Files still in original location: 0
Files already deleted (not found): 1
Existing tombstones found: 1

[!] No files remaining to delete. All marked files have already been processed.
    Existing tombstones: 1
    Files in plan: 1

If you need to re-run deletions, restore files from backup first.
```

**Viewing Tombstone Files:**

To view a tombstone file and verify its contents:

```powershell
# Find all tombstone files in the remediation directory
Get-ChildItem -Path "\\vm-purview-scan\Projects\RemediationTestData" -Recurse -Filter "*.DELETED_*.txt"

# View the most recent tombstone file (useful if multiple exist)
$latestTombstone = Get-ChildItem -Path "\\vm-purview-scan\Projects\RemediationTestData" -Recurse -Filter "*.DELETED_*.txt" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1

Get-Content $latestTombstone.FullName
```

**Tombstone File Contents** (example):

```text
============================================================
FILE DELETION RECORD
============================================================
Original File: \\COMPUTERNAME\Projects\RemediationTestData\Step1-SeverityBased\Background_Check_2020.txt
Deleted On: 2025-10-29 11:27:49
Deleted By: labadmin
Computer: COMPUTERNAME

FILE DETAILS:
Size: 0 MB
Last Modified: 10/28/2021 16:53:18
Last Accessed: 10/29/2025 11:26:57
Created: 10/29/2025 11:26:57

REMEDIATION DETAILS:
Severity: MEDIUM
Sensitive Info Types: U.S. Social Security Number (SSN)
Age: 4 years
Remediation Action: AUTO_DELETE_WITH_AUDIT

RESTORATION INFORMATION:
This file was deleted as part of data remediation project.
Contact IT Service Desk for restoration from backup.

Backup System: Rubrik / JCI Backup Service
Retention: Check backup retention policy
Project Reference: Purview Remediation - 2025-10

Approved By: [Compliance Officer Name]
Legal Hold Check: None Active
============================================================
```

**What This Accomplishes**:

- ✅ **Pre-deletion analysis** showing total files, current state, and files remaining.
- ✅ **Permanent deletion** of files from on-premises shares.
- ✅ **Complete audit trail** via tombstone files with deletion metadata.
- ✅ **Restoration capability** through backup system reference.
- ✅ **Compliance documentation** for regulatory requirements.
- ✅ **Clear communication** to users (tombstone files remain in original directories).
- ✅ **Smart early exit** if all files already processed (prevents errors).

**Verify Success**:

1. **Pre-deletion analysis displays correctly**:
   - Shows total files in remediation plan
   - Shows files marked for AUTO_DELETE
   - Displays current state breakdown (existing/deleted/tombstones)
   - Shows files remaining to delete OR early exit message

2. **If files were deleted**:
   - Original files no longer exist at their paths
   - Tombstone `.txt` files created in same directories
   - Verification summary shows successful deletion count
   - Tombstone count matches deleted file count

3. **If all files already processed**:
   - Early exit message displayed
   - Existing tombstone count shown
   - No errors or failed deletion attempts

4. **View tombstone contents** using the commands from the viewing section above to verify deletion metadata

---

### Step 5: Weekly Progress Update 📊 [Admin Machine] [Aggregation]

> **💻 Execute From**: **Admin Machine (your workstation)** ✅ RECOMMENDED  
> **Why**: Creates progress tracking reports using data from previous steps  
> **Requirements**:
>
> - CSV files from previous steps:
>   - `RemediationPlan.csv` (from Step 1 on VM) - **Auto-downloads via remote access** ✨
>   - `SharePoint-Deletions.csv` (from Step 3 - already on admin machine)
> - VM credentials: `labadmin` account for remote file access
> - Remote connectivity to Azure VM (choose based on your location):
>   - **Option 1 (On-VNet)**: Network share access (for devices in same Azure VNet or peered networks)
>   - **Option 2 (External)**: Public IP + PowerShell Remoting (for work/home workstations outside VNet)
> - PowerShell with `ImportExcel` module (optional): `Install-Module ImportExcel -Scope CurrentUser`
>
> **Network Location Guide**:
>
> - **Choose Option 1** if your admin machine is:
>   - Another Azure VM in the same VNet
>   - A VM in a peered Azure VNet
>   - Connected via ExpressRoute with private connectivity
> - **Choose Option 2** if your admin machine is:
>   - Your work/home workstation (external to Azure)
>   - Accessing Azure via public internet
>   - Requires VM to have a public IP assigned

Create weekly/monthly tracking metrics for stakeholder reporting.

**Initialize Progress Tracking:**

```powershell
# Create baseline snapshot (run once at project start)
$baseline = [PSCustomObject]@{
    Date = Get-Date -Format "yyyy-MM-dd"
    Week = 0
    TotalFiles = 50000
    SensitiveFiles = 5000
    FilesOver3Years = 12000
    RemediationCandidates = 3000
    TotalSizeGB = 500
}

$baseline | Export-Csv "C:\PurviewLab\ProgressTracking.csv" -NoTypeInformation

Write-Host "✅ Baseline snapshot created" -ForegroundColor Green
```

**Run Weekly Progress Update Script:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-Remediation"
.\Update-WeeklyProgress.ps1
```

> **💡 Note**: Increment the `$weekNumber` variable at the top of the script each week (Week 1, Week 2, etc.)

**Expected Results:**

After running this progress tracking dashboard script, you should see:

- ✅ **Automatic metric calculation**:
  
  ```text
  ========== CALCULATING WEEKLY METRICS ==========
  ✅ Remediation plan loaded: 5 total files
     AUTO_DELETE candidates: 1
     MANUAL_REVIEW files: 0
  
  Calculating deleted files from tombstones...
  ✅ Found 2 tombstone files on VM
     Total storage saved: 0 GB
  
  Checking for SharePoint deletions...
  [INFO] SharePoint-Deletions.csv exists but contains 0 deletions
     This means Step 3 was executed but no files were actually deleted
     (Step 3 creates empty CSV if no deletions occur)
  
  Manual review metrics:
  How many HIGH severity files did you manually review this week?: 0
  How many HIGH severity files did you remediate?: 0
  How many files did you decide to RETAIN?: 0
  
  ========== WEEKLY SUMMARY ==========
  Files Deleted: 2 (2 on-prem + 0 SharePoint)
  Storage Saved: 0 GB
  Remediation Rate: 40%
  Estimated Cost Savings: $0/month
  ```

- ✅ **Data sources used**:
  - **RemediationPlan.csv**: Downloaded from VM or used from local cache at `C:\PurviewLab\`.
  - **Tombstone files**: Counted remotely via PowerShell remoting from `\\VM\Projects\RemediationTestData\`.
  - **SharePoint-Deletions.csv**: Created locally on admin machine by Step 3 (SharePoint PnP PowerShell script).
  - **Tombstone metadata**: Parsed to calculate storage saved (regex matches "Size: X MB" pattern).
  - **Manual review metrics**: User input for human-decision activities tracked outside automation.

- ✅ **Calculated metrics**:
  - `FilesDeleted`: Tombstone count + SharePoint deletions count.
  - `StorageSavedGB`: Sum of file sizes from tombstone metadata (parsed via regex).
  - `RemediationRate`: (Total deleted / Total files in plan) × 100.
  - `CostSavingsUSD`: Storage saved × $3/GB/month (standard cloud storage cost estimate).

- ✅ **Weekly tracking file updated**: `C:\PurviewLab\ProgressTracking.csv` with new Week 1 data appended.

- ✅ **Progress report generated** with live calculated values:
  
  ```text
  ============================================================
  REMEDIATION PROGRESS REPORT - WEEK 1
  ============================================================
  Date: 2025-10-29

  REMEDIATION SUMMARY:
    Files Deleted This Week: 2
    Files Archived This Week: 0
    Files Retained: 0

  CUMULATIVE PROGRESS:
    Total Remediation Rate: 40%
    Storage Reclaimed: 0 GB
    Estimated Cost Savings: $0/month

  COMPLIANCE METRICS:
    Manual Reviews Completed: 0
    High-Severity Files Resolved: 0

  VELOCITY ANALYSIS:
    Avg Files/Week: 0
    Projected Completion: ~2 weeks
  ============================================================
  ```

**How the Script Gets VM Deletion Data**:

1. **RemediationPlan.csv Download** (Two Options Based on Network Location):

   **Option 1: Same VNet - Network Share Access**:
   - Use VM's **private IP** (e.g., `10.0.1.4`) or hostname (e.g., `vm-purview-scan`)
   - Connects to VM's admin share: `\\<vm-name-or-ip>\c$\PurviewLab\RemediationPlan.csv`
   - Uses `net use` command to authenticate with `labadmin` credentials
   - Downloads file directly via SMB protocol
   - Works like local network file sharing
   - **Prerequisites**: Admin machine in same VNet, peered VNet, or ExpressRoute-connected network
   - **Best for**: Azure VM admin machines, on-premises with ExpressRoute

   **Option 2: External Network - Public IP + PowerShell Remoting**:
   - VM must have public IP assigned (check Azure Portal → VM → Overview)
   - Use VM's **public IP address** (e.g., `20.120.45.78`) instead of hostname
   - Requires NSG rule allowing WinRM port 5985 from your IP
   - Requires one-time TrustedHosts setup: `Set-Item WSMan:\localhost\Client\TrustedHosts -Value '<public-ip>' -Force`
   - Creates PowerShell remoting session: `New-PSSession -ComputerName <public-ip> -Credential $credential`
   - Downloads file: `Copy-Item -FromSession $session`
   - Once configured, fully automated file download
   - **Prerequisites**: VM public IP, NSG rule, TrustedHosts configured
   - **Best for**: Work/home workstations accessing Azure via internet
   - **Manual alternative**: RDP to public IP (`mstsc /v:<public-ip>`) and copy file via clipboard

2. **Tombstone Count** (Remote Execution via PowerShell Remoting):
   - **External Access (Option 2)**: Script creates PowerShell session to VM and executes tombstone counting remotely
   - Runs `Get-ChildItem` filter on VM: `*.DELETED_*.txt` in `\\VM\Projects\RemediationTestData\`
   - Parses tombstone metadata for size calculation: `Size:\s+([\d.]+)\s+MB` regex pattern
   - Returns count and total size to admin machine
   - **On-VNet Access (Option 1)**: Can access network share directly (not implemented in current version - uses manual input)
   - **Fallback**: Manual count prompt if remote execution fails

3. **SharePoint Data**: 
   - **Created locally on admin machine** by Step 3 SharePoint PnP PowerShell script
   - Location: `C:\PurviewLab\SharePoint-Deletions.csv`
   - **NOT downloaded from VM** - Step 3 runs on admin machine, not on VM
   - Script checks if file exists locally and imports deletion count
   - Shows conditional messaging based on count (0 vs >0 deletions)

4. **Why Two Different Approaches**:
   - ✅ **On-VNet (Option 1)**: SMB file shares work naturally with private IP connectivity
   - ✅ **External (Option 2)**: Public IP + PowerShell remoting enables automation without VPN setup
   - ❌ **Network shares don't work from internet** (SMB port 445 blocked by Azure NSG for security)
   - ❌ **Hostname resolution doesn't work outside Azure** (use public IP for external access)
   - 💡 **No Bastion or VPN needed**: Simplified to two practical approaches based on network location

**What This Tells You**:

- Whether remediation is progressing at acceptable pace (example: 2 files deleted in Week 1 = 40% of 5-file plan).
- If storage savings justify project investment (cost savings calculated at $3/GB/month industry standard).
- Where bottlenecks exist (manual reviews lag, SharePoint deletions not happening, etc.).
- When project will complete (projected based on current velocity and remediation rate).

**Weekly Workflow**:

1. Run Step 5 script on admin machine each week
2. Increment `$weekNumber` parameter (Week 1, Week 2, etc.)
3. Script automatically downloads RemediationPlan.csv from VM
4. Script counts tombstones remotely via PowerShell remoting
5. Script loads SharePoint deletions from local CSV
6. User provides manual review metrics when prompted
7. Report generated and appended to `ProgressTracking.csv`
8. Weekly report saved to `WeeklyReport-Week1.txt`

---

## ✅ Validation Checklist

### Multi-Tier Remediation

- [ ] Remediation plan generated with severity classification
- [ ] HIGH, MEDIUM, LOW categories assigned correctly
- [ ] Manual review list created for HIGH severity + old files
- [ ] Auto-delete list generated for appropriate candidates

### Dual-Source Deduplication

- [ ] Both on-prem and cloud storage sources scanned
- [ ] Duplicates identified by name and size
- [ ] Safe deletion list created (files exist in both locations)
- [ ] Storage savings calculated

### SharePoint PnP Automation

- [ ] PnP PowerShell module installed
- [ ] Successfully connected to SharePoint site
- [ ] Files queried from document library
- [ ] Deletion criteria applied (age + sensitivity)
- [ ] Audit log created before deletion
- [ ] Files deleted (or moved to Recycle Bin)

### On-Premises Tombstone Creation

- [ ] Tombstone pattern implemented
- [ ] Tombstones created before file deletion
- [ ] Restoration information included in tombstones
- [ ] Backup system reference documented

### Progress Tracking

- [ ] Baseline snapshot created
- [ ] Weekly progress metrics captured
- [ ] Progress report generated
- [ ] Velocity analysis calculated
- [ ] Stakeholder dashboard created

---

## 🔍 Troubleshooting

### Issue: PnP PowerShell Connection Fails

**Symptoms**: `Connect-PnPOnline` throws authentication errors

**Solutions**:

1. **Modern Auth**: Ensure modern authentication is enabled for your tenant
2. **Permissions**: Verify you have Site Collection Admin or Owner permissions
3. **MFA**: Use `-Interactive` parameter for MFA-enabled accounts
4. **App Registration**: For unattended scenarios, create app registration with SharePoint permissions

### Issue: Dual-Source Scan Performance

**Symptoms**: Scanning large cloud storage shares is very slow

**Solutions**:

1. **Filter by date**: Only scan files modified in last 5 years
2. **Parallel processing**: Use PowerShell jobs for concurrent scanning
3. **Incremental scanning**: Scan one folder at a time, cache results

### Issue: Progress Tracking Data Missing

**Symptoms**: Weekly reports show incomplete data

**Solutions**:

1. **Centralize logs**: Keep all deletion logs in single directory
2. **Standardize naming**: Use consistent CSV export filenames
3. **Automate collection**: Schedule weekly script to gather metrics

---

## 🎯 Key Learning Outcomes

After completing Advanced-Remediation, you should understand:

1. **Severity-Based Remediation**: How to classify and handle data differently based on sensitivity (HIGH/MEDIUM/LOW)
2. **Dual-Source Management**: Techniques for handling on-prem + cloud storage scenarios with deduplication
3. **SharePoint Automation**: PnP PowerShell for bulk operations that eDiscovery UI doesn't support
4. **Production Patterns**: Tombstones, audit trails, and error handling for production deployments
5. **Progress Tracking**: How to measure and report remediation velocity to stakeholders

---

## 🚀 Next Steps & Real-World Applications

### Applying Lab Skills Beyond the Lab Environment

The techniques learned in this lab form the foundation for enterprise data governance projects. Here are practical examples of how these skills apply to real-world scenarios:

**Severity-Based Remediation**: Healthcare organizations use multi-tier classification to handle PHI differently than general business files, with HIGH severity requiring manual review and LOW severity enabling automated deletion.

**Dual-Source Deduplication**: Cloud migration projects (transitioning from on-premises file servers to SharePoint/Azure Files) use deduplication to eliminate redundant storage and reduce costs.

**SharePoint PnP Automation**: When eDiscovery identifies thousands of policy violations but lacks bulk deletion capabilities, PnP PowerShell enables scripted remediation that would take weeks manually.

**Tombstone Audit Trails**: Production environments require detailed deletion tracking for compliance audits and accidental deletion recovery (tombstone metadata enables quick restoration from backups).

**Progress Tracking**: Multi-month remediation projects use velocity metrics to justify costs, adjust timelines, and report progress to stakeholders.

### Integration with Section 2 Labs

This lab builds upon skills from earlier labs in the Purview Skills Ramp series:

- **OnPrem-02 (Scanner)**: The severity classification in Step 1 relies on scanner-discovered data
- **OnPrem-03 (DLP)**: Remediation plans use DLP classifications to identify sensitive data requiring deletion

> **💡 Recommended Preparation**: Complete Sections 1-3 before attempting this advanced lab to ensure you have foundational Purview scanning and classification experience.

### Additional Resources

**PowerShell Modules:**

- **PnP PowerShell**: [Official Documentation](https://pnp.github.io/powershell/) for SharePoint/OneDrive automation
- **Microsoft Graph PowerShell**: Advanced SharePoint operations and Microsoft 365 integration
- **Az.Storage**: Azure Files lifecycle management and storage automation

**Compliance & Best Practices:**

- **Microsoft Purview Documentation**: Data retention policies and compliance frameworks
- **Legal Hold Procedures**: eDiscovery and litigation hold considerations
- **GDPR Compliance**: Right to erasure and data minimization requirements

**Automation & Scaling:**

- **Azure Automation**: Schedule remediation scripts for production environments
- **Power Automate**: Create approval workflows for manual review processes
- **Azure Logic Apps**: Build event-driven remediation triggers

> **📚 Further Learning**: For production implementation guidance, enterprise integration patterns, and career development resources, see the companion **Real-World Implementation Guide** (available separately).

---

## 🏁 Completion Confirmation

Before moving to cleanup, verify:

- [ ] Remediation decision matrix implemented and tested
- [ ] Dual-source deduplication logic working correctly
- [ ] SharePoint PnP deletion tested with recycle bin safety
- [ ] Tombstone creation pattern validated
- [ ] Progress tracking reports generated
- [ ] All scripts exported to C:\PurviewLab\ for future reference

---

## 🧹 Lab Cleanup & Reset

> **💻 Execute From**: **VM (COMPUTERNAME)** and **Admin Machine (your workstation)**  
> **Why**: Removes all test data and outputs to reset lab environment without VM recreation  
> **When to Use**: After completing lab, before re-running scenarios, or when resetting environment

This cleanup script removes all test data, CSV outputs, tombstone files, and SharePoint test files while preserving VM configuration, scanner installation, and Azure resources.

**Run Cleanup Script:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-Remediation"
.\Remediation-Lab-Cleanup.ps1
```

> **💡 Note**: The script includes three phases:
> - **Part 1**: On-premises file cleanup (VM) - removes test data, tombstones, CSV outputs
> - **Part 2**: SharePoint test files cleanup (Admin Machine) - removes uploaded test files
> - **Part 3**: Scanner reports cleanup (VM - OPTIONAL) - removes historical scanner reports

### When to Use Cleanup Script

**✅ Use cleanup when**:

- Lab is complete and you want to reset environment.
- Testing script modifications and need fresh data.
- Preparing to re-run lab with different parameters.
- Removing test data after taking screenshots/documentation.

**❌ Don't use cleanup if**:

- You need to preserve remediation results for reporting.
- Legal hold or audit requirements exist.
- Still troubleshooting lab steps (keep test data for debugging).
- Need historical scanner reports for comparison.

---

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of advanced remediation automation and PowerShell scripting patterns while maintaining technical accuracy for production data governance scenarios.*

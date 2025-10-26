# Lab 02 - Part 2: DLP Enforcement & Monitoring

> **🛑 BEFORE YOU BEGIN**: You MUST complete Lab 02 - Part 1 and verify that the DLP policy sync is complete before starting this lab.
>
> **Required verification**:
>
> - Navigate to Purview Portal → **Solutions** → **Data loss prevention** → **Policies**
> - Locate the **Lab-OnPrem-Sensitive-Data-Protection** policy
> - Verify **NO "Sync in progress" message** appears (refresh page with Ctrl+F5 if needed)
> - Confirm at least **1-2 hours** have passed since policy creation in Part 1
>
> **If sync is still in progress**: Return to Lab 02 - Part 1 and follow the sync wait instructions. Do NOT proceed until sync completes.

---

## 📋 Overview

**Duration**: 1-2 hours

**Objective**: Configure and validate DLP policy detection through the Purview scanner, run scans with DLP enabled, and monitor DLP activity through reporting tools.

**What You'll Learn:**

- How DLP policies integrate with the Information Protection Scanner
- The difference between Test mode and Enforce mode for DLP deployment
- How to interpret scanner reports for sensitive data discovery
- Using Activity Explorer for compliance monitoring and audit trails
- Why Test mode is the recommended approach for consultancy projects

**Prerequisites from Lab 02 - Part 1:**

- ✅ DLP policy **Lab-OnPrem-Sensitive-Data-Protection** created
- ✅ DLP policy **sync completed** (no "Sync in progress" message)
- ✅ Scanner service running and operational
- ✅ Test files with sensitive data in place (Finance, HR repositories)

> **⚠️ CRITICAL PREREQUISITE**: Do NOT start this lab until the DLP policy sync has completed in Part 1. The policy must show as fully synced in the Purview portal (no "Sync in progress" message). Sync typically takes 1-2 hours after policy creation.

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

1. Enable DLP policy detection in scanner content scan jobs
2. Run scans with DLP policy application and sensitivity labeling
3. Interpret DLP detection results in scanner CSV reports (`Information Type Name`, `Applied Label` columns)
4. Monitor DLP activity using Activity Explorer with appropriate filters
5. Validate that DLP policies correctly identify Credit Card and SSN data
6. Generate audit trails for stakeholder reporting and compliance documentation

---

## 📖 Step-by-Step Instructions

### Step 1: Verify DLP Policy Sync Completion

Before proceeding with enforcement configuration, verify that the DLP policy from Part 1 has completed synchronization.

**Check Policy Sync Status:**

- Navigate to [Purview Portal](https://purview.microsoft.com)
- Go to **Solutions** > **Data loss prevention** > **Policies**
- Locate **Lab-OnPrem-Sensitive-Data-Protection** policy
- **Verify**: No "Sync in progress" message appears on the policy screen

**Alternative Verification - Policy Sync Status Tab:**

- Click on the **Lab-OnPrem-Sensitive-Data-Protection** policy name
- Select the **Policy sync status** tab
- Confirm sync status shows completed/synced

> **⏳ If Sync Still In Progress**: If you still see "Sync in progress", you must wait for sync to complete before proceeding. Policy sync typically takes 1-2 hours. Restarting the scanner or running scans before sync completes will not help and may interfere with policy distribution.

---

### Step 2: Enable DLP in Scanner Content Scan Job

Now configure the scanner to enforce DLP policies during scans.

**Navigate to Scanner Configuration:**

- [Purview Portal](https://purview.microsoft.com)
- Go to **Settings** (gear icon)
- Select **Information protection**
- Click **Information protection scanner**
- Select **Content scan jobs** tab
- Click on **Lab-OnPrem-Scan** (your scan job from Lab 01)

**Enable DLP Policy:**

- Scroll to **Enable DLP policy rules** setting
- Toggle to **On**
- **Enable DLP rules**: Toggle to **On**

> **💡 Technical Detail**: When DLP is enabled in the scan job, the scanner downloads DLP policies from the service and applies them during file scanning.

**Save Configuration:**

- Click **Save** at the top of the page
- Wait for confirmation message

---

### Step 3: Run DLP Detection Scan

With DLP enabled and policy sync complete, run a new scan to apply DLP policies to files.

> **⚠️ Important - Full Rescan Required**: After enabling DLP policies, you must run a **full rescan** using the `-Reset` parameter. By default, the scanner only scans new or changed files. Previously scanned files will show as "Already scanned" and won't have DLP policies applied unless you force a full rescan.

**Restart Scanner Service to Apply Configuration:**

After enabling DLP in the portal, restart the scanner service to load the new settings:

**Restart Scanner Service:**

Restart the scanner service to ensure it picks up the enforcement configuration:

```powershell
# Restart scanner service to refresh DLP configuration
Restart-Service -Name "MIPScanner" -Force

# Verify service is running
Get-Service -Name "MIPScanner"

# Expected Status: Running
```

**Run Full Enforcement Scan:**

```powershell
# Start FULL enforcement scan with DLP policies using -Reset parameter
# This forces the scanner to rescan ALL files, not just new/changed files
Start-Scan -Reset

# Expected output:
# The scanner service is starting...
# Scan started successfully
```

> **💡 Why -Reset is Required**: The scanner performs incremental scans by default, only scanning new or changed files. When you add or modify DLP policies, you need to run `Start-Scan -Reset` to apply those policies to all files, including previously scanned ones.

**Monitor Scan Progress:**

```powershell
# Check scan status
Get-ScanStatus

# Expected fields in output:
# - Status: Running/Completed
# - Files scanned
# - Sensitive items found
# - DLP actions applied

# Monitor scanner service
Get-Service -Name "*scanner*"
```

**Continuous Monitoring:**

```powershell
# Real-time status monitoring (updates every 30 seconds)
while ($true) {
    Clear-Host
    Write-Host "DLP Enforcement Scan Status - $(Get-Date)" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    Get-ScanStatus
    Write-Host "`nPress Ctrl+C to exit monitoring" -ForegroundColor Yellow
    Start-Sleep -Seconds 30
}
```

**Check Scanner Reports for DLP Actions:**

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

**View Report Contents in PowerShell:**

For easier analysis, display the report contents in PowerShell table format:

```powershell
# Import and display the report in PowerShell
$reportData = Import-Csv $latestReport.FullName

# First, show available column names to understand the report structure
Write-Host "`n========== SCANNER DETAILED REPORT - PREVIEW ==========" -ForegroundColor Cyan
Write-Host "Report File: $($latestReport.Name)" -ForegroundColor Yellow
Write-Host "Total Rows: $($reportData.Count)" -ForegroundColor Yellow

# Display available columns
Write-Host "`nAvailable Columns:" -ForegroundColor Green
$reportData[0].PSObject.Properties.Name | Sort-Object | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }

# Display first 10 rows with all columns (easier to see actual data)
Write-Host "`nShowing first 10 rows with all available data:`n" -ForegroundColor Green
$reportData | Select-Object -First 10 | Format-List

# Alternative: Display in table format
Write-Host "`nTable View (if applicable):`n" -ForegroundColor Green
$reportData | Select-Object -First 10 | Format-Table -AutoSize -Wrap
```

> **💡 Analysis Tip**: Use `Out-GridView` for interactive filtering and sorting: `$reportData | Out-GridView`. This opens a searchable, filterable window that's easier to work with than Notepad or Excel.

> **💡 Report Location Note**: Scanner reports are created under the **scanner service account's profile** (`C:\Users\scanner-svc\AppData\Local\...`), not under your admin account (`C:\Users\labadmin\AppData\Local\...`). This is because the scanner service runs as the `scanner-svc` account.

**What to Look For in Scanner Reports:**

When you open the DetailedReport CSV in Excel, focus on these key columns to validate DLP detection:

**Primary Validation Columns** (Confirm DLP is working):

| Column Name | What to Look For | Expected Values for Lab Files |
|-------------|------------------|-------------------------------|
| **Information Type Name** | Sensitive data types detected | `Credit Card Number`, `U.S. Social Security Number (SSN)` |
| **Applied Label** | Sensitivity label applied | `General\All Employees` |
| **File Path** | Location of scanned files | `\\vm-purview-scanner\Finance\CustomerPayments.txt`, `\\vm-purview-scanner\HR\EmployeeRecords.txt` |

**Success Indicator**: If `Information Type Name` is populated with values like "Credit Card Number" or "U.S. Social Security Number", **DLP detection is working correctly**. This is your primary validation.

**Additional DLP Columns** (May vary based on configuration):

| Column Name | Typical Value | What It Means |
|-------------|---------------|---------------|
| **DLP Mode** | `Test` | Scanner detects and labels but doesn't block access (expected for this lab) |
| **DLP Policy Matched** | May be blank or show policy name | Some configurations don't populate this column in Test mode |
| **DLP Rule Matched** | May be blank or show rule name | Some configurations don't populate this column in Test mode |
| **DLP Status** | `Skipped` or blank | Typical in Test mode; doesn't indicate failure |

**Expected Results for Lab Sample Data:**

Based on the files created in Lab 00, you should see:

- **Finance\CustomerPayments.txt**: Information Type Name = `Credit Card Number`
- **Finance\TransactionHistory.csv**: Information Type Name = `Credit Card Number`
- **HR\EmployeeRecords.txt**: Information Type Name = `U.S. Social Security Number (SSN)`
- **HR\SalaryData.csv**: Information Type Name = `U.S. Social Security Number (SSN)`

All four files should also show `Applied Label` = `General\All Employees`

---

### Step 4: View Activity in Activity Explorer

Activity Explorer provides comprehensive DLP activity monitoring and reporting.

> **⚠️ PREREQUISITE - Auditing Must Be Enabled**: Activity Explorer requires Microsoft 365 auditing to be enabled to display DLP activity data from the scanner. If you followed **Lab 00 - Step 2: Enable Microsoft 365 Auditing**, auditing should already be active and you can proceed immediately.
>
> **If you see a banner** stating *"To use this feature, turn on auditing"*:
> 
> 1. Click **Turn on auditing** on the banner
> 2. Wait for confirmation: *"We're preparing the audit log. It can take up to 24 hours..."*
> 3. **Auditing activation takes 2-24 hours** (typically 2-4 hours for initial data)
> 4. **After auditing activates**: Return to **Step 3** and re-run the scan (`Start-Scan -Reset`) to generate audit records
> 5. **Then wait 15-30 minutes** for Activity Explorer data to sync
>
> **Note**: Audit data is only collected from the point auditing is enabled forward. Any scanner activity before auditing was enabled will not appear in Activity Explorer.

**Navigate to Activity Explorer:**

- Purview Portal: [Purview Portal](https://purview.microsoft.com)
- Navigate to **Data loss prevention** (in left navigation)
- Select **Explorers** (in left submenu)
- Click **Activity explorer**

> **💡 Portal Note**: The Activity Explorer navigation was updated in 2024-2025. Activity Explorer is now located under **Data loss prevention > Explorers > Activity explorer**, not under **Solutions > Data classification** as in earlier portal versions.

**Filter for On-Premises Activity:**

Configure filters to focus on on-premises DLP activity:

- **Location**: Select **On-premises repositories**
- **Date range**: **Last 7 days** (or custom range)
- **Activity type**:
  - File accessed
  - File modified
  - File scanned
  - DLP policy matched
- **DLP policy**: Select **Lab-OnPrem-Sensitive-Data-Protection**

**Review DLP Matches:**

Activity Explorer shows:

- **Files with DLP matches**: Count of files matching DLP rules
- **Policy name**: Which policies triggered
- **Rule name**: Specific rules matched
- **Sensitive info types**: What SITs were detected
- **Actions taken**: Block, audit, notify

**Export Activity Data:**

- Click **Export** to download activity data
- Format: CSV
- Use for reporting to stakeholders or compliance documentation

> **📊 Reporting Tip**: Activity Explorer data is essential for DLP effectiveness reporting, compliance audits, and identifying data remediation priorities.

> **⏳ Activity Explorer Data Timing**:
>
> - **If auditing was already enabled**: Activity data appears 15-30 minutes after scan completion
> - **If you just enabled auditing**: Allow 2-4 hours minimum for audit system activation, then additional 15-30 minutes after scan
> - **Full audit activation**: Can take up to 24 hours
> - **Recommendation**: If you just turned on auditing, proceed with other lab activities and return to Activity Explorer validation later (after 4+ hours)

---

## ✅ Validation Checklist

Complete the following validation steps to ensure successful lab completion:

### DLP Policy Sync (Step 1)

- [ ] DLP policy sync completed (no "Sync in progress" message)
- [ ] Policy shows "On" status in Purview portal
- [ ] Policy accessible in scanner configuration

### Scanner Configuration (Step 2)

- [ ] Scanner content scan job DLP settings enabled
- [ ] **DLP policy** toggle set to **On**
- [ ] **Enable DLP rules** toggle set to **On**
- [ ] **Enforce sensitivity labeling policy** set to **On** (enables automatic sensitivity labeling)
- [ ] Configuration saved successfully

### Scan Execution (Step 3)

- [ ] DLP detection scan executed with `Start-Scan -Reset` cmdlet
- [ ] Scan completed without errors
- [ ] Scanner reports generated in service account profile location

### Scanner Reports Validation (Step 3)

- [ ] DetailedReport CSV opened and reviewed
- [ ] **Information Type Name** column populated (e.g., "Credit Card Number", "U.S. Social Security Number")
- [ ] **Applied Label** column shows sensitivity labels applied (e.g., "General\All Employees")
- [ ] Credit card files show "Credit Card Number" detections
- [ ] SSN files show "U.S. Social Security Number" detections

> **✅ Success Indicator**: If `Information Type Name` is populated with sensitive information types, DLP detection is working correctly in Test mode.

### Activity Explorer (Step 4 - Optional)

- [ ] Activity Explorer accessible in Purview portal
- [ ] Filters configured: Location = On-premises repositories
- [ ] DLP matches visible in activity data (15-30 min after scan)
- [ ] Policy name displayed: "Lab-OnPrem-Sensitive-Data-Protection"
- [ ] Sensitive info types identified in activity records

---

## 🔍 Troubleshooting Common Issues

### Issue: "Already Scanned" Files Not Being Processed

**Symptom**: Scan shows `Skipped due to - Already scanned: 3` and no DLP detections appear

**Root Cause**: Scanner performs incremental scans by default, skipping previously scanned files even when DLP policies are newly added

**Solution**: Run full rescan with `-Reset` parameter

```powershell
# Force full rescan of all files
Start-Scan -Reset
```

The `-Reset` parameter forces the scanner to rescan ALL files and apply newly added DLP policies.

---

### Issue: Activity Explorer Shows No Data

**Symptoms**: Activity Explorer appears empty or shows no on-premises DLP activity

**Common Causes and Solutions**:

1. **Auditing Not Enabled** (Most Common):
   - Microsoft 365 auditing must be enabled BEFORE scanning
   - If just enabled: Allow 2-4 hours for activation
   - Re-run scan after auditing activates: `Start-Scan -Reset`
   - See **Lab 00 - Step 2** for auditing enablement

2. **Data Sync Timing**:
   - Activity data takes 15-30 minutes to appear after scan completes
   - Wait, then refresh Activity Explorer

3. **Incorrect Filters**:
   - Verify filter: **Location** = **On-premises repositories**
   - Check date range includes scan time
   - Verify DLP policy filter matches: **Lab-OnPrem-Sensitive-Data-Protection**

4. **Verify Scanner Reports First**:

   ```powershell
   # Confirm DLP detections exist in scanner CSV reports
   cd C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports
   
   # Open latest DetailedReport CSV
   # Check if Information Type Name column is populated
   # If yes: DLP is working, Activity Explorer just needs more time
   ```

> **✅ Primary Validation**: Scanner CSV reports are the immediate validation method. Activity Explorer is supplemental audit trail visualization.

---

## 📊 Lab Completion Summary

After completing this lab successfully, you should have:

### ✅ DLP Detection Working

- Scanner CSV reports show **Information Type Name** column populated with:
  - "Credit Card Number" for Finance files
  - "U.S. Social Security Number" for HR files
- Scanner CSV reports show **Applied Label** column populated with sensitivity labels
- DLP policy successfully detecting sensitive information in on-premises files

### ✅ Skills Demonstrated

- Configured scanner content scan job for DLP policy integration
- Executed DLP detection scan with PowerShell commands
- Interpreted scanner CSV reports to validate DLP detection
- (Optional) Viewed DLP activity audit trails in Activity Explorer

---

## 🤖 AI-Assisted Content Generation

This comprehensive lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview DLP detection procedures and validation guidance as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of DLP detection configuration and monitoring while maintaining technical accuracy and reflecting modern scanner capabilities and Test mode best practices.*

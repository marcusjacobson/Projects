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

**Objective**: Configure and validate DLP policy enforcement through the Purview scanner, run enforcement scans, and monitor DLP activity.

**What You'll Learn:**

- Enable DLP enforcement in scanner content scan jobs
- Run full enforcement scans with DLP policy application
- Interpret DLP actions in scanner reports
- Monitor DLP activity through Activity Explorer
- Test and validate DLP enforcement behavior

**Prerequisites from Lab 02 - Part 1:**

- ✅ DLP policy **Lab-OnPrem-Sensitive-Data-Protection** created
- ✅ DLP policy **sync completed** (no "Sync in progress" message)
- ✅ Scanner service running and operational
- ✅ Test files with sensitive data in place (Finance, HR repositories)

> **⚠️ CRITICAL PREREQUISITE**: Do NOT start this lab until the DLP policy sync has completed in Part 1. The policy must show as fully synced in the Purview portal (no "Sync in progress" message). Sync typically takes 30-60 minutes after policy creation.

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

1. Enable DLP policy enforcement in scanner content scan jobs
2. Configure enforcement mode for active DLP rule application
3. Execute full enforcement scans with DLP policy enforcement
4. Interpret DLP columns in scanner CSV reports
5. Monitor DLP activity using Activity Explorer
6. Test DLP enforcement behavior on sensitive files
7. Troubleshoot common DLP enforcement issues

---

## 📖 Step-by-Step Instructions

### Step 1: Verify DLP Policy Sync Completion

Before proceeding with enforcement configuration, verify that the DLP policy from Part 1 has completed synchronization.

**Check Policy Sync Status:**

- Navigate to Purview Portal: https://purview.microsoft.com
- Go to **Solutions** > **Data loss prevention** > **Policies**
- Locate **Lab-OnPrem-Sensitive-Data-Protection** policy
- **Verify**: No "Sync in progress" message appears on the policy screen

**Alternative Verification - Policy Sync Status Tab:**

- Click on the **Lab-OnPrem-Sensitive-Data-Protection** policy name
- Select the **Policy sync status** tab
- Confirm sync status shows completed/synced

> **⏳ If Sync Still In Progress**: If you still see "Sync in progress", you must wait for sync to complete before proceeding. Policy sync typically takes 30-60 minutes. Restarting the scanner or running scans before sync completes will not help and may interfere with policy distribution.

---

### Step 2: Enable DLP in Scanner Content Scan Job

Now configure the scanner to enforce DLP policies during scans.

**Navigate to Scanner Configuration:**

- Purview Portal: https://purview.microsoft.com
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

**Enable Enforcement Mode (CRITICAL):**

> **⚠️ REQUIRED for DLP Enforcement**: You MUST set the **Enforce** setting to **On** for DLP policies to actually enforce actions. Without this, the scanner runs in "Test" mode and only logs matches without applying blocking or restriction actions.

- Scroll to **Sensitivity policy** section
- Find **Enforce sensitivity labeling policy** setting
- Toggle to **On**

This enables enforcement mode for both sensitivity labels AND DLP policies. Without enforcement mode enabled, DLP runs in test/simulation mode only.

**Save Configuration:**

- Click **Save** at the top of the page
- Wait for confirmation message

---

### Step 3: Run Enforcement Scan

With DLP enabled and policy sync complete, run a new scan to apply DLP policies to files.

> **⚠️ Important - Full Rescan Required**: After enabling DLP policies, you must run a **full rescan** using the `-Reset` parameter. By default, the scanner only scans new or changed files. Previously scanned files will show as "Already scanned" and won't have DLP policies applied unless you force a full rescan.

**Restart Scanner Service (Recommended):**

Restart the scanner service to ensure it picks up the new DLP policy configuration:

```powershell
# Restart scanner service to refresh DLP policies
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

> **💡 Report Location Note**: Scanner reports are created under the **scanner service account's profile** (`C:\Users\scanner-svc\AppData\Local\...`), not under your admin account (`C:\Users\labadmin\AppData\Local\...`). This is because the scanner service runs as the `scanner-svc` account.

**Interpret DLP Actions in Reports:**

Scanner CSV reports now include DLP-related columns:

- **DLP Mode**: Shows "Enforce" when enforcement is active, "Test" when in simulation
- **DLP Policy Matched**: Which policy matched the file
- **DLP Rule Matched**: Specific rule that triggered
- **DLP Status**: Success, Skipped, or error status
- **DLP Comment**: Additional details about the match or action
- **DLP Actions**: Action taken (Block, Audit, etc.)
- **Sensitive Info Types**: Which SITs were detected

---

### Step 4: View Activity in Activity Explorer

Activity Explorer provides comprehensive DLP activity monitoring and reporting.

**Navigate to Activity Explorer:**

- Purview Portal: https://purview.microsoft.com
- Select **Solutions** > **Data classification**
- Click **Activity explorer** from the left menu

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

> **⏳ Activity Explorer Timing**: Activity data can take **15-30 minutes** to appear in Activity Explorer after scan completion. If you don't see data immediately, wait and refresh after 30 minutes.

---

### Step 5: Test DLP Enforcement (Optional)

Validate that DLP policies are actively enforcing by attempting to access blocked files.

**On VM, Test File Access:**

> **💡 Important - Computer Name**: Replace `vm-purview-scanner` with **YOUR actual computer name**.
>
> **To find your actual computer name**, run:
> ```powershell
> $env:COMPUTERNAME
> ```
> Or use `\\localhost\Finance\CustomerPayments.txt` which always works for local shares.

```powershell
# Attempt to open a file with credit card data
# This should be blocked if DLP enforcement is active
# Replace "vm-purview-scanner" with your actual computer name from $env:COMPUTERNAME
$testFile = "\\vm-purview-scanner\Finance\CustomerPayments.txt"

# Try to read the file
Try {
    Get-Content $testFile -ErrorAction Stop
    Write-Host "File access succeeded - DLP may not be enforcing" -ForegroundColor Yellow
} Catch {
    Write-Host "File access blocked - DLP enforcement active!" -ForegroundColor Green
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
```

**Expected Behavior:**

- **Credit Card files** (Block rule): Access denied with DLP policy message
- **SSN files** (Audit rule): Access allowed but activity logged in Activity Explorer

**Verify User Notifications:**

If user notifications were enabled:
- Policy tips should appear when accessing files
- Email notifications sent to configured recipients
- Incident reports generated for admins

---

## ✅ Validation Checklist

Complete the following validation steps to ensure successful lab completion:

### DLP Policy Sync
- [ ] DLP policy sync completed (no "Sync in progress" message)
- [ ] Policy shows "On" status in Purview portal
- [ ] Policy accessible in scanner configuration

### Scanner Configuration
- [ ] Scanner content scan job DLP settings enabled
- [ ] **DLP policy** toggle set to **On**
- [ ] **Enable DLP rules** toggle set to **On**
- [ ] **Enforce sensitivity labeling policy** set to **On** (enforcement mode)
- [ ] Configuration saved successfully

### Scan Execution
- [ ] Enforcement scan executed with `Start-Scan -Reset` cmdlet
- [ ] Scan completed without errors
- [ ] Scanner reports generated with DLP action details
- [ ] DLP policy matches recorded in scanner CSV reports
- [ ] DLP Mode shows "Enforce" (not "Test")

### Scanner Reports Validation
- [ ] CSV reports include DLP columns (DLP Mode, DLP Policy Matched, etc.)
- [ ] Credit card files show DLP policy matches
- [ ] SSN files show DLP policy matches
- [ ] DLP Mode column shows "Enforce"
- [ ] DLP Actions column populated appropriately

### Activity Explorer
- [ ] Activity Explorer accessible in Purview portal
- [ ] Filters configured for on-premises repositories
- [ ] DLP matches visible in activity data (allow 15-30 min for data sync)
- [ ] Policy name and rule name displayed correctly
- [ ] Sensitive info types identified accurately

### Enforcement Validation
- [ ] Credit card files show DLP block action in reports
- [ ] SSN files show DLP audit action in reports
- [ ] File access attempts logged in Activity Explorer
- [ ] User notifications delivered (if configured)
- [ ] Incident reports generated for admins

---

## 🔍 Troubleshooting Common Issues

### Issue: DLP Mode Shows "Test" Instead of "Enforce"

**Symptoms**: Scanner CSV reports show `DLP Mode: Test` and `DLP Status: Skipped`

**Root Cause**: The **Enforce sensitivity labeling policy** setting in the content scan job is set to **Off**.

**Solution**:

- Navigate to **Scanner** > **Content scan jobs** > **Lab-OnPrem-Scan**
- Scroll to **Sensitivity policy** section
- Find **Enforce sensitivity labeling policy** setting
- Toggle to **On**
- Click **Save**
- Restart scanner service: `Restart-Service -Name "MIPScanner" -Force`
- Run full rescan: `Start-Scan -Reset`

### Issue: DLP Policy Not Showing in Scanner

**Symptoms**: Scanner completes scan but no DLP actions recorded, DLP columns empty

**Solutions**:

```powershell
# Verify DLP is enabled in scan job
# Purview Portal > Scanner > Content scan jobs > Lab-OnPrem-Scan
# Check "DLP policy" setting is ON

# Verify policy sync completed
# Purview Portal > Policies > Lab-OnPrem-Sensitive-Data-Protection
# Ensure no "Sync in progress" message

# Force policy sync
# On VM in PowerShell:
Update-ScannerConfiguration

# Restart scanner service to ensure policy download
Restart-Service -Name "MIPScanner"

# Check scanner can reach Purview portal
Test-NetConnection -ComputerName purview.microsoft.com -Port 443

# Run full rescan
Start-Scan -Reset
```

### Issue: "Already scanned" Files Not Being Processed

**Symptom:**
Scan output shows `Skipped due to - Already scanned: 3` and no DLP actions are applied.

**Root Cause:**
After the first scan, the scanner performs **incremental scans** by default, only scanning new or changed files. Previously scanned files are skipped even if you've added new DLP policies.

**Solution:**
Run a full rescan using the `-Reset` parameter:

```powershell
# Force full rescan of all files
Start-Scan -Reset

# The -Reset parameter forces the scanner to:
# - Rescan ALL files, even previously scanned ones
# - Apply newly added or modified DLP policies
# - Update all DLP actions and classifications
```

### Issue: Activity Explorer Shows No Data

**Symptoms**: Activity Explorer appears empty or shows no on-premises activity

**Solutions**:

- **Timing Issue**: Activity data can take 15-30 minutes to appear in Activity Explorer after scan completion
- **Filter Configuration**: Verify filters are set correctly (Location: On-premises repositories, correct date range)
- **Data Collection**: Ensure scanner completed successfully and DLP matches were recorded
- **Permissions**: Verify your account has permissions to view Activity Explorer (Compliance Data Administrator role recommended)

```powershell
# Check if DLP matches were recorded in scanner reports first
Set-Location "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"
$latestReport = Get-ChildItem -Filter "DetailedReport*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Import-Csv $latestReport.FullName | Where-Object {$_.'DLP Policy Matched' -ne ''} | Select-Object 'File Path', 'DLP Policy Matched', 'DLP Rule Matched'

# If CSV shows DLP matches, wait for Activity Explorer sync (15-30 minutes)
```

### Issue: Files Not Blocked Despite Policy

**Symptoms**: Users can still access files with credit card data despite block rule

**Solutions**:

1. **Verify Enforcement Mode**: Ensure **Enforce sensitivity labeling policy** is **On** in scan job

2. **Check Policy Mode**: Check if policy is in test/simulation mode
   - Purview Portal > Data loss prevention > Policies > Lab-OnPrem-Sensitive-Data-Protection
   - Change mode to **Turn it on immediately** if currently in test mode

3. **Check DLP Rule Priority**: Ensure no conflicting rules allow access
   - Review rule order and priority

4. **Scanner Enforcement Timing**: DLP enforcement applies during next scan, not retroactively
   - Run `Start-Scan -Reset` again to apply latest policies

5. **File Access Method**: DLP on-premises blocks file access through SMB shares; direct disk access on the VM may bypass DLP

```powershell
# Verify policy is active
# Purview Portal > Policies > Check Status column shows "On"

# Re-run full rescan to apply enforcement
Start-Scan -Reset

# Monitor for enforcement actions in reports
Get-ScanStatus
```

### Issue: Scanner Fails After Enabling DLP

**Symptoms**: Scanner service stops or scans fail after DLP enabled

**Solutions**:

```powershell
# Check scanner service status
Get-Service -Name "*scanner*"

# Review scanner event logs
Get-EventLog -LogName Application -Source "*MIP*" -Newest 20

# Check scanner detailed logs
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\MSIP\Scanner\Logs" -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 5

# Verify scanner has network access to Purview
Test-NetConnection -ComputerName purview.microsoft.com -Port 443

# Re-authenticate scanner if needed
# Replace "scanner-svc@yourtenant.onmicrosoft.com" with your actual UPN
Set-Authentication `
    -AppId "YOUR-APP-ID" `
    -AppSecret "YOUR-SECRET" `
    -TenantId "YOUR-TENANT-ID" `
    -DelegatedUser "scanner-svc@yourtenant.onmicrosoft.com"
```

### Issue: Policy Rules Not Matching Expected Files

**Symptoms**: Files with credit cards/SSNs not triggering DLP rules

**Solutions**:

```powershell
# Verify sample data files contain detectable patterns
Get-Content "\\localhost\Finance\CustomerPayments.txt"
Get-Content "\\localhost\HR\EmployeeRecords.txt"

# Check if patterns match SIT definitions
# Valid credit card: 4532-1234-5678-9010 (must be Luhn-valid)
# Valid SSN: 123-45-6789

# Review DLP policy configuration
# Purview Portal > Policies > Lab-OnPrem-Sensitive-Data-Protection > Rules
# Verify instance count is "1 to Any"

# Check scanner info types discovery setting
# Scanner > Content scan jobs > Lab-OnPrem-Scan
# Ensure "Info types to be discovered" includes SITs in DLP policies
```

### Issue: Azure File Share Not Accessible

**Symptom:**
Scan output shows `The following repositories are not accessible: \\stpurviewlab829456.file.core.windows.net\nasuni-simulation`

**Root Cause:**
Scanner service account doesn't have authentication tokens cached for Azure File Share access, or credentials expired.

**Solution 1 - Re-authenticate Using OnBehalfOf:**

```powershell
# Create credentials for scanner service account
$scannerAccount = "contoso\scanner-svc"
$scannerPassword = ConvertTo-SecureString "YourPassword" -AsPlainText -Force
$scannerCreds = New-Object System.Management.Automation.PSCredential($scannerAccount, $scannerPassword)

# Re-authenticate using OnBehalfOf parameter
# This caches tokens in the scanner service account's profile
Set-Authentication -OnBehalfOf $scannerCreds

# Restart scanner service
Restart-Service -Name "MIPScanner" -Force

# Run diagnostics to verify
Start-ScannerDiagnostics -OnBehalfOf $scannerCreds
```

**Solution 2 - Verify Storage Account Permissions:**

```powershell
# Verify scanner account has Storage Blob Data Contributor role
# Azure Portal > Storage Account > Access Control (IAM)
# Add role assignment:
# - Role: Storage Blob Data Contributor
# - Assign access to: User, group, or service principal
# - Members: scanner-svc@yourdomain.com or CONTOSO\scanner-svc
```

---

## 📊 Expected Results

After completing this lab successfully, you should observe:

### Scanner Configuration
- Scanner scan job configured with DLP enabled
- Enforcement mode activated (**Enforce sensitivity labeling policy** = On)
- Scanner successfully downloads DLP policies from Purview service
- Scanner applies DLP rules during file scanning

### Enforcement Results
Based on Lab 00 sample data:
- **Finance\CustomerPayments.txt**: DLP match on Credit Card Number, DLP Mode = Enforce
- **Finance\TransactionHistory.csv**: DLP match on Credit Card Number, DLP Mode = Enforce
- **HR\EmployeeRecords.txt**: DLP match on SSN, DLP Mode = Enforce
- **HR\SalaryData.csv**: DLP match on SSN and Email, DLP Mode = Enforce

### Scanner CSV Reports
Scanner detailed reports include:
- **DLP Mode** column showing "Enforce" (not "Test")
- **DLP Policy Matched** column populated with policy name
- **DLP Rule Matched** column showing specific rule
- **DLP Status** column showing "Success"
- **DLP Comment** column with match details
- **Sensitive Info Types** column listing detected SITs

### Activity Explorer Data
- On-premises DLP activity visible within 15-30 minutes
- Activity shows:
  - Files scanned: 20-30 files
  - DLP matches: 4-6 files with sensitive data
  - Policy matched: Lab-OnPrem-Sensitive-Data-Protection
  - Rules matched: Block-Credit-Card-Access, Audit-SSN-Access
  - Actions: Block (for credit cards), Audit (for SSNs)

---

## 🎓 Key Learning Outcomes

After completing Lab 02 - Part 2, you have learned:

1. **DLP Scanner Integration**: How to enable and configure DLP policies in scanner content scan jobs

2. **Enforcement Mode Configuration**: The critical importance of enabling enforcement mode for active DLP policy application

3. **Full Rescan Requirements**: Understanding when and why to use `Start-Scan -Reset` for policy application

4. **Scanner Report Interpretation**: Reading and interpreting DLP columns in scanner CSV reports to validate enforcement

5. **Activity Monitoring**: Using Activity Explorer to monitor DLP matches, enforcement actions, and compliance posture

6. **Troubleshooting DLP**: Diagnosing and resolving common DLP enforcement issues (Test mode, sync delays, rescan requirements)

7. **Testing Strategies**: Validating DLP enforcement through file access testing and report verification

---

## 🚀 Next Steps

**Proceed to Lab 03**: Retention Labels & Data Lifecycle Management

In the next lab, you will:
- Create retention labels for data lifecycle management
- Configure auto-apply policies based on sensitive information types
- Test retention label application in SharePoint Online
- Understand limitations of retention labels for on-premises file shares
- Implement data lifecycle management strategies

**Before starting Lab 03, ensure:**
- [ ] DLP enforcement scan completed successfully with `Start-Scan -Reset`
- [ ] Scanner CSV reports show DLP Mode = "Enforce" (not "Test")
- [ ] DLP Policy Matched column populated in reports
- [ ] Activity Explorer showing DLP matches (allow 15-30 min for data sync)
- [ ] All validation checklist items marked complete

---

## 📚 Reference Documentation

- [Microsoft Purview DLP for On-Premises Repositories](https://learn.microsoft.com/en-us/purview/dlp-on-premises-scanner-learn)
- [DLP Policy Configuration](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
- [Information Protection Scanner Configuration](https://learn.microsoft.com/en-us/purview/deploy-scanner-configure-install)
- [Activity Explorer Documentation](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)
- [DLP Policy Tips and Notifications](https://learn.microsoft.com/en-us/purview/use-notifications-and-policy-tips)

---

## 🤖 AI-Assisted Content Generation

This comprehensive lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview DLP enforcement procedures and troubleshooting guidance as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of DLP enforcement configuration and monitoring while maintaining technical accuracy and reflecting real-world DLP policy sync timing considerations.*

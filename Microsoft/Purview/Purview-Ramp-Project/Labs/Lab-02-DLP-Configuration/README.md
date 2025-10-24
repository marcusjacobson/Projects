# Lab 02: DLP On-Premises Configuration

## 📋 Overview

**Duration**: 2-3 hours

**Objective**: Configure Data Loss Prevention (DLP) policies to protect sensitive information on on-premises file repositories, enable enforcement through the Purview scanner, and monitor DLP actions.

**What You'll Learn:**

- Create custom DLP policies for on-premises repositories
- Configure DLP rules with conditions and enforcement actions
- Enable DLP enforcement in scanner content scan jobs
- Run enforcement scans that apply DLP policy actions
- Monitor DLP activity through Activity Explorer

**Prerequisites from Lab 01:**

- ✅ Information Protection Scanner deployed and operational
- ✅ Discovery scan completed successfully showing sensitive data
- ✅ Scanner service running and authenticated
- ✅ Repositories configured (Finance, HR, Projects, Azure Files)

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

1. Create DLP policies specifically for on-premises file repositories
2. Configure advanced DLP rules with sensitive information type conditions
3. Implement enforcement actions (block access, audit, notify users)
4. Enable DLP policy enforcement in scanner content scan jobs
5. Execute enforcement scans and validate DLP actions
6. Monitor and analyze DLP activity using Activity Explorer
7. Understand DLP policy testing modes and deployment strategies

---

## 📖 Step-by-Step Instructions

### Step 1: Create DLP Policy in Purview Portal

**Navigate to Purview DLP Portal:**

- Open browser and go to the **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com)
- Sign in with your **admin account**
- Navigate to **Solutions** > **Data loss prevention**
- Select **Policies** from the left menu within Data loss prevention
- Click **+ Create policy** to start policy creation

> **💡 Portal Note**: The Microsoft Purview portal interface was redesigned in 2024. DLP policies are now accessed through Solutions > Data loss prevention > Policies. The steps below reflect the current portal as of October 2025.

> **💡 Background**: DLP policies for on-premises repositories work differently than cloud DLP. The scanner acts as the enforcement agent, applying policies during scan operations.

#### Choose What Type of Data to Protect

The policy creation wizard starts by asking what type of data you want to protect.

- Select: **Data stored in connected sources**
- Click **Next**

> **💡 Option Context**:
> 
> - **Data stored in connected sources** = On-premises repositories, devices, cloud apps
> - **Data created, received or shared in Microsoft 365** = Exchange, SharePoint, OneDrive, Teams

#### Select Policy Template:

- Under **Categories**, select: **Custom**
- Under **Regulations**, select: **Custom policy** (allows full control over rules and conditions)
- Click **Next**

> **💡 Template Options**: Microsoft provides pre-built templates for Financial, Medical/Health, and Privacy regulations. Custom policy gives you complete control over sensitive information types, conditions, and actions.

#### Name Your Policy:

- **Name**: `Lab-OnPrem-Sensitive-Data-Protection`
- **Description**: `Protect PII and PCI data on on-premises file shares and Azure Files`
- Click **Next**

#### Assign Admin Units:

- **Full directory** is selected by default (applies policy to all users and groups)
- You can optionally click **Add or remove admin units** to scope the policy to specific organizational units
- For this lab, keep the default **Full directory** selection
- Click **Next**

> **📚 Note**: Admin units allow scoping DLP policies to specific organizational units within your Microsoft Entra ID (Azure AD) tenant. If you click **Add or remove admin units** and see no options available, this is expected behavior when admin units haven't been configured in your tenant. Full directory applies the policy across your entire organization, which is appropriate for lab scenarios.

#### Configure Locations:

DLP policies can apply to multiple locations (Exchange, SharePoint, Teams, on-premises). For this lab, we focus exclusively on on-premises repositories.

By default, several locations are checked (enabled):

- ✅ **Exchange email** (checked by default)
- ✅ **SharePoint sites** (checked by default)
- ✅ **OneDrive accounts** (checked by default)
- ✅ **Teams chat and channel messages** (checked by default)
- ✅ **Instances** (checked by default)
- ✅ **On-premises repositories** (checked by default)

**Uncheck all locations EXCEPT On-premises repositories:**

1. Click to **uncheck** the following locations (toggle them to OFF):
   - **Exchange email** → Uncheck
   - **SharePoint sites** → Uncheck
   - **OneDrive accounts** → Uncheck
   - **Teams chat and channel messages** → Uncheck
   - **Instances** → Uncheck

2. Keep **ONLY** this location checked:
   - ✅ **On-premises repositories** → Keep checked (ON)

3. Verify **On-premises repositories** is the ONLY location with a checkmark
4. Click **Next**

> **⚠️ Important**: On-premises repository DLP requires the Information Protection Scanner to be deployed and scanning the repositories. Without the scanner, DLP policies cannot be enforced on file shares. We performed this action in lab 01.

> **💡 Lab Focus**: We're unchecking cloud locations (Exchange, SharePoint, OneDrive, Teams, Instances) to focus exclusively on on-premises file shares for this lab. In production environments, you would typically enable multiple locations to protect data across your entire organization.

#### Select Rule Configuration Method:

- **Create or customize advanced DLP rules**: Selected
- This allows you to create multiple rules with different conditions and actions
- Click **Next**

You'll now create two DLP rules: one for Credit Card data (with blocking) and one for SSN data (with auditing).

#### Add First Rule:

- Click **+ Create rule**
- **Name**: `Block-Credit-Card-Access`
- **Description**: `Block user access to files containing credit card numbers`

**Configure Conditions:**

Under **Conditions**, click **+ Add condition**:

- Select: **Content contains**
- **Content contains**: Click **Add** > **Sensitive info types**
- Search for and select: **Credit Card Number**
- Click **Add**
- **Instance count**: 
  - From: `1`
  - To: `Any`

This condition triggers when the scanner detects at least one credit card number in a file.

**Configure Actions:**

Under **Actions**, click **+ Add an action** and configure enforcement for on-premises repositories:

1. **Select action**: **Restrict access or remove on-premises files**

2. **Choose restriction method** - You have four options:

   **Option 1: Block people from accessing file stored in on-premises scanner**
   - **Block everyone**: Blocks all accounts except content owner, last modifier, repository owner, and admin
   - **Block only people who have access to your on-premises network and users in your organization who weren't granted explicit access**: Removes "Everyone", "NT AUTHORITY\authenticated users", and "Domain Users" from file ACL

   **Option 2: Set permissions on the file**
   - Forces the file to inherit permissions from its parent folder
   - Only applies if parent folder permissions are more restrictive than current file permissions
   - Optional: Check **Inherit even if parent permissions are less restrictive** to force inheritance regardless

   **Option 3: Remove the file from improper location**
   - Moves original file to a quarantine folder
   - Replaces original file with a `.txt` stub file
   - Useful for isolating sensitive files from general access

3. **For this lab**, select:
   - **Block people from accessing file stored in on-premises repositories**
   - Choose: **Block everyone** (most restrictive for lab demonstration)

> **💡 Action Explanation**:
>
> - **Block everyone**: Removes all NTFS/SharePoint permissions except file owner, repository owner (from scan job settings), last modifier, admin, and scanner account
> - **Block only people with network access**: Removes broad access groups (Everyone, Domain Users, Authenticated Users) but preserves explicit user/group permissions
> - **Set permissions**: Makes file inherit parent folder permissions (useful for standardizing access)
> - **Remove file**: Quarantines sensitive files completely - most restrictive option

> **💡 Production Consideration**: In production, "Block only people who have access to your on-premises network" is often preferred as it removes broad access while preserving legitimate explicit permissions. "Block everyone" is more restrictive and may require additional permission management.

**Configure User Notifications:**

> **⚠️ On-Premises Limitation**: The **User notifications** option is grayed out (disabled) for on-premises repository DLP policies. Policy tips are NOT available when using the on-premises scanner location. This is a known limitation documented by Microsoft.
>
> User notifications and policy tips are only supported for cloud locations (Exchange, SharePoint, OneDrive, Teams). For on-premises repositories, DLP enforcement happens silently through the scanner without user-facing notifications.

**Skip User Notifications section** - These settings are not available for on-premises repositories:

- ~~User notifications~~ (grayed out)
- ~~Policy tips~~ (not supported)
- ~~Email notifications~~ (not available)
- ~~Notify these people~~ (not available)

**User Overrides:**

- **Allow overrides** will also be grayed out (not available for on-premises repositories)

**Incident Reports:**

Configure alert settings for when this rule matches:

- **Severity level**: Select **High** from the dropdown
  - Options available: Low, Medium, High
  - High severity ensures alerts are prioritized and visible in admin dashboards

**Alert Triggering Options** - Choose one:

**Option 1: Send alert every time an activity matches the rule** (Recommended for lab)

- Select this radio button for immediate alerts on each credit card detection
- Best for critical data and low-volume monitoring

**Option 2: Send alert when the volume of matched activities reaches a threshold**:

- Select this radio button for threshold-based alerting
- Configure the following thresholds:
  - ☐ **Number of matched activities**: Specify minimum count (e.g., 5 activities)
  - ☐ **Number of MB**: Specify data volume threshold (e.g., 10 MB)
  - **During the last X minutes**: Time window for threshold evaluation (e.g., 60 minutes)
- Use for high-volume environments to reduce alert noise

**For this lab**: Select **"Send alert every time an activity matches the rule"**

**Email Notifications:**

- **Use email incident reports**: Toggle ON to send email notifications
  - **Send notification emails to these people**: Add admin email addresses

> **💡 Severity Level Guidance**:
>
> - **High**: Use for critical sensitive data (credit cards, SSNs) that require immediate attention
> - **Medium**: Use for moderately sensitive data that needs review but isn't urgent
> - **Low**: Use for general monitoring and audit purposes
>
> For this lab, we use **High** severity to ensure credit card detections are immediately visible in the DLP alerts dashboard.

> **💡 Threshold vs Immediate Alerting**:
>
> - **Every time** (immediate): Alert on each individual match - ideal for critical data like credit cards
> - **Threshold-based**: Alert only when volume exceeds limits - reduces noise in high-activity environments
> - You can combine multiple threshold conditions (activities AND/OR data size within time window)

**Review and Save:**

- Click **Save** to create the rule

#### Add Second Rule for SSN Data (Audit Mode)

- Click **+ Create rule**
- **Name**: `Audit-SSN-Access`
- **Description**: `Audit access to files containing Social Security Numbers without blocking`

**Configure Conditions:**

Under **Conditions**, click **+ Add condition**:

- Select: **Content contains**
- **Content contains**: Click **Add** > **Sensitive info types**
- Search for and select: **U.S. Social Security Number (SSN)**
- Click **Add**
- **Instance count**: 
  - From: `1`
  - To: `Any`

This condition triggers when the scanner detects at least one Social Security Number in a file.

**Configure Actions (Audit Only):**

For audit-only monitoring, **do NOT add any actions**:

- Under **Actions**, you will see **+ Add an action** option
- **Do not click** this for the SSN audit rule
- Leave the Actions section empty (no actions configured)

> **💡 Audit vs Enforcement**: 
>
> - **Audit-only rule** (SSN): No actions configured → Scanner detects and logs SSN files but doesn't modify permissions or block access
> - **Enforcement rule** (Credit Card): Actions configured → Scanner detects files AND applies restrictive actions (block, quarantine, etc.)
>
> Leaving Actions empty creates a monitoring/discovery rule that logs activity in Activity Explorer without disrupting user access.

> **💡 Testing Strategy**: Using audit-only for SSN allows you to test DLP without disrupting access, which is ideal for initial deployments and monitoring data usage patterns before implementing restrictive actions.

**Configure User Notifications:**

> **⚠️ On-Premises Limitation**: The **User notifications** option is grayed out (disabled) for on-premises repository DLP policies. Policy tips are NOT available when using the on-premises scanner location.

**Skip User Notifications section** - These settings are not available for on-premises repositories:

- ~~User notifications~~ (grayed out)
- ~~Policy tips~~ (not supported)
- ~~Email notifications~~ (not available)

**User Overrides:**

- **Allow overrides** will also be grayed out (not available for on-premises repositories)

**Incident Reports:**

Configure alert settings for when this rule matches:

- **Severity level**: Select **Medium** from the dropdown
  - High: Reserved for critical data (credit cards)
  - **Medium**: Appropriate for SSN monitoring and audit scenarios
  - Low: General monitoring

**Alert Triggering Options** - Choose one:

**Option 1: Send alert every time an activity matches the rule** (Recommended for lab)

- Select this radio button for immediate alerts on each SSN detection
- Best for low-volume monitoring and testing scenarios

**Option 2: Send alert when the volume of matched activities reaches a threshold**:

- Select this radio button for threshold-based alerting
- Configure the following thresholds:
  - ☐ **Number of matched activities**: Specify minimum count (e.g., 5 activities)
  - ☐ **Number of MB**: Specify data volume threshold (e.g., 10 MB)
  - **During the last X minutes**: Time window for threshold evaluation (e.g., 60 minutes)
- Use for high-volume environments to reduce alert noise

**For this lab**: Select **"Send alert every time an activity matches the rule"**

**Email Notifications:**

- **Use email incident reports**: Toggle ON to send email notifications
  - **Send notification emails to these people**: Add admin email addresses

> **💡 Audit Rule Alerting**: Even though this rule uses audit-only enforcement (no blocking), incident reports still generate alerts when SSNs are detected. This allows you to monitor SSN data usage and identify potential risks before implementing blocking actions.

> **💡 Threshold vs Immediate Alerting**: 
> 
> - **Every time** (immediate): Alert on each individual match - ideal for critical data or testing
> - **Threshold-based**: Alert only when volume exceeds limits - reduces noise in high-activity environments
> - You can combine multiple threshold conditions (activities AND/OR data size within time window)

**Review and Save:**

- Click **Save** to create the rule
- Click **Next** to advance to Policy mode

##### Policy Mode Options

The wizard presents three deployment options:

**Option 1: Run the policy in simulation mode**:

- Policy runs as if enforced but **no actual enforcement occurs**
- All matched items and alerts are reported in simulation dashboard
- Use to assess policy impact before full enforcement
- Optional: **Show policy tips while in simulation mode** (not available for on-premises repositories)
- Optional: **Turn the policy on if it's not edited within fifteen days of the simulation** (auto-activation)

**Option 2: Turn the policy on immediately**:

- Policy enforces immediately with full actions applied
- Credit card blocking and SSN audit logging active immediately
- Recommended only after testing in simulation mode

**Option 3: Keep it off**:

- Policy created but inactive
- No enforcement, no simulation, no alerts
- Use when policy configuration is incomplete or requires approval

**For this lab**, select one of the following:

- **Recommended**: **Run the policy in simulation mode** (safer for initial testing)
  - Allows you to see what would be blocked/audited without actual enforcement
  - Review simulation results before enabling full enforcement
  - Change to "Turn it on right away" later after validation

- **Alternative**: **Turn the policy on immediately** (if you want immediate enforcement)
  - Credit card files will be blocked immediately on next scan
  - SSN files will be audited (logged) but not blocked

**For this lab, we recommend**: Select **Turn it on right away** to demonstrate active DLP enforcement

- Click **Next** to advance to Review and finish

> **✅ Best Practice**: In production environments, always start with **Run the policy in simulation mode** to assess impact, identify false positives, and educate users before full enforcement. For this lab, we use immediate enforcement to demonstrate DLP actions during the enforcement scan.

#### Review and Finish:

The final screen displays a comprehensive summary of your policy configuration. Review each section carefully before creating the policy.

**Page Header:** "Create the policy if these details look fine. Otherwise, adjust the settings to better meet your needs."

**Summary Sections Displayed:**

**1. The information to protect**:

- **Type**: Custom policy
- Click **Edit** to modify policy template selection

**2. Name**:

- **Name**: Lab-OnPrem-Sensitive-Data-Protection
- Click **Edit** to change policy name

**3. Description**:

- **Description**: Protect PII and PCI data on on-premises file shares and Azure Files
- Click **Edit** to modify description

**4. Locations**:

- **Selected location**: On-premises repositories
- Teams suggestion banner may appear: "Consider adding Teams as a location to protect the accidental sharing of sensitive info in Teams messages"
  - You can ignore this for the lab (focused on on-premises only)
- Click **Edit** to modify location selection

**5. Policy settings**:

- **Rules configured**:
  - Block-Credit-Card-Access
  - Audit-SSN-Access
- Click **Edit** to modify rules

**6. Turn policy on after it's created?**

- **Status**: Yes (if you selected "Turn it on right away")
- **Status**: No (if you selected "Run the policy in simulation mode" or "Keep it off")
- Click **Edit** to change policy mode

**Verify all settings are correct** - Each section has an **Edit** link to return to that configuration step if changes are needed.

**Submit Policy:**

- Click **Submit** to create the policy
- Wait for confirmation message: "Your policy was created"
- Click **Done**

**Policy Created:**

- Policy appears in the **Policies** list
- **Status column** shows:
  - **On** (if turned on immediately)
  - **In simulation** (if simulation mode selected)
  - **Off** (if kept off)
- **Name**: Lab-OnPrem-Sensitive-Data-Protection
- **Locations**: On-premises repositories
- **Policy settings**: The configured policy names

> **IMPORTANT: 🔄 DLP Policy Sync Timing**: You will likely see a "Sync in progress" message on the policy screen after creation. This is normal behavior as the DLP policy is being distributed to the on-premises scanner infrastructure.
>
> **Expected sync time**: While Microsoft doesn't provide specific SLAs for on-premises scanner DLP policy sync, based on similar Purview services (Endpoint DLP), policy synchronization typically takes **30 minutes to 1 hour** to complete across the service.
>
> **⏳ Wait for sync to complete**: Do NOT restart the scanner service or run scans while the policy shows "Sync in progress". Restarting the scanner before sync completes does not speed up the process and may interfere with policy distribution. Simply wait for the sync status to clear.
>
> **How to verify sync completion**:
>
> - Refresh the **Policies** page in Purview portal (or check the **Policy sync status** tab in policy details)
> - The "Sync in progress" message should disappear once sync completes (typically within 30-60 minutes)
> - **Only after sync completes**, proceed to Step 2 to enable DLP in the scanner and run enforcement scans

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

With DLP enabled, run a new scan to apply DLP policies to files.

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

- **DLP Policy Matched**: Which policy matched the file
- **DLP Rule Matched**: Specific rule that triggered
- **DLP Action**: Action taken (Block, Audit, etc.)
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

### DLP Policy Creation
- [ ] DLP policy **Lab-OnPrem-Sensitive-Data-Protection** created
- [ ] Policy location set to **On-premises repositories** only
- [ ] Two rules created: Block-Credit-Card-Access and Audit-SSN-Access
- [ ] Rules configured with correct sensitive info types
- [ ] Enforcement actions configured (block for credit cards, audit for SSN)
- [ ] User notifications enabled

### Scanner Configuration
- [ ] Scanner content scan job DLP settings enabled
- [ ] **DLP policy** toggle set to **On**
- [ ] **Enable DLP rules** toggle set to **On**
- [ ] Configuration saved successfully

### Scan Execution
- [ ] Enforcement scan executed with `Start-Scan` cmdlet
- [ ] Scan completed without errors
- [ ] Scanner reports generated with DLP action details
- [ ] DLP policy matches recorded in scanner CSV reports

### Activity Explorer
- [ ] Activity Explorer accessible in Purview portal
- [ ] Filters configured for on-premises repositories
- [ ] DLP matches visible in activity data
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

### Issue: DLP Policy Not Showing in Scanner

**Symptoms**: Scanner completes scan but no DLP actions recorded

**Solutions**:

```powershell
# Verify DLP is enabled in scan job
# Purview Portal > Scanner > Content scan jobs > Lab-OnPrem-Scan
# Check "DLP policy" setting is ON

# Force policy sync
# On VM in PowerShell:
Update-ScannerConfiguration

# Restart scanner service to ensure policy download
Restart-Service -Name "MIPScanner"

# Check scanner can reach Purview portal
Test-NetConnection -ComputerName purview.microsoft.com -Port 443
```

### Issue: Activity Explorer Shows No Data

**Symptoms**: Activity Explorer appears empty or shows no on-premises activity

**Solutions**:

- **Timing Issue**: Activity data can take 15-30 minutes to appear in Activity Explorer after scan completion
- **Filter Configuration**: Verify filters are set correctly (Location: On-premises repositories, correct date range)
- **Data Collection**: Ensure scanner completed successfully and DLP matches were recorded
- **Permissions**: Verify your account has permissions to view Activity Explorer (Compliance Data Administrator role recommended)

```powershell
# Check if DLP matches were recorded in scanner reports
$reports = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\MSIP\Scanner\Reports" -Filter "*.csv" | Sort-Object LastWriteTime -Descending
$latestReport = Import-Csv $reports[0].FullName
$latestReport | Where-Object {$_.'DLP Policy Matched' -ne ''} | Select-Object 'File Path', 'DLP Policy Matched', 'DLP Rule Matched'
```

### Issue: Files Not Blocked Despite Policy

**Symptoms**: Users can still access files with credit card data despite block rule

**Solutions**:

1. **Verify Policy Mode**: Check if policy is in test/simulation mode
   - Purview Portal > Data loss prevention > Policies > Lab-OnPrem-Sensitive-Data-Protection
   - Change mode to **Turn it on immediately** if currently in test mode

2. **Check DLP Rule Priority**: Ensure no conflicting rules allow access
   - Review rule order and priority

3. **Scanner Enforcement Timing**: DLP enforcement applies during next scan, not retroactively
   - Run `Start-Scan` again to apply latest policies

4. **File Access Method**: DLP on-premises blocks file access through SMB shares; direct disk access on the VM may bypass DLP

```powershell
# Verify policy is active
# Purview Portal > Policies > Check Status column shows "On"

# Re-run scan to apply enforcement
Start-Scan

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

# Re-authenticate scanner
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
Get-Content "C:\PurviewScanner\Finance\CustomerPayments.txt"

# Check if patterns match SIT definitions
# Valid credit card: 4532-1234-5678-9010 (must be Luhn-valid)
# Valid SSN: 123-45-6789

# Review DLP policy configuration
# Purview Portal > Policies > Lab-OnPrem-Sensitive-Data-Protection > Rules
# Verify instance count is 1 to Any

# Check scanner info types discovery setting
# Scanner > Content scan jobs > Lab-OnPrem-Scan
# Ensure "Info types to be discovered" includes SITs in DLP policies
```

---

## � Troubleshooting Common Issues

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

**Solution 3 - Test Azure File Share Connectivity:**

```powershell
# Test if you can access the share manually
$sharePath = "\\stpurviewlab829456.file.core.windows.net\nasuni-simulation"
Test-Path $sharePath

# If authentication is required, mount the share with credentials
# Get storage account key from Azure Portal
$storageAccountName = "stpurviewlab829456"
$storageAccountKey = "YOUR_STORAGE_ACCOUNT_KEY"

# Mount Azure File Share
$acctKey = ConvertTo-SecureString -String $storageAccountKey -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("Azure\$storageAccountName", $acctKey)
New-PSDrive -Name "Z" -PSProvider FileSystem -Root $sharePath -Credential $credential -Persist
```

### Issue: Scanner Service Won't Start After DLP Configuration

**Symptom:**
Scanner service fails to start or immediately stops after enabling DLP.

**Solution:**

```powershell
# Check scanner service status
Get-Service -Name "MIPScanner"

# View recent scanner errors in Event Viewer
Get-EventLog -LogName Application -Source "MSIP.Scanner" -Newest 10 | Format-List

# Check scanner configuration
Get-ScannerConfiguration

# Restart scanner service with verbose logging
Stop-Service -Name "MIPScanner" -Force
Start-Sleep -Seconds 5
Start-Service -Name "MIPScanner"

# Monitor service startup
Get-Service -Name "MIPScanner" | Select-Object Status, StartType
```

### Issue: No DLP Matches Showing in Scanner Reports

**Symptom:**
Scanner completes successfully but no DLP matches appear in CSV reports, or CSV shows `DLP Mode: Test` and `DLP Status: Skipped`.

> **⚠️ Most Common Cause**: Scanner is running in **Test mode** instead of **Enforce mode**. This happens when the **Enforce sensitivity labeling policy** setting in the content scan job is set to **Off**. See Step 2 above for the required enforcement mode configuration.

**Checklist:**

- [ ] **Enforce mode** (MOST COMMON): Scanner **Enforce sensitivity labeling policy** is **On** in content scan job → Sensitivity policy section
- [ ] **DLP policy status**: Verify policy is **On** (not in simulation or off)
- [ ] **Policy location**: Ensure **On-premises repositories** is selected
- [ ] **Scanner DLP enabled**: Content scan job has **DLP policy** toggle **On**
- [ ] **Full rescan**: Run `Start-Scan -Reset` to force reprocessing of all files
- [ ] **Sync completion**: Wait for DLP policy sync to complete (check policy screen for "Sync in progress")
- [ ] **Test files exist**: Verify test files with sensitive data are in scanned repositories
- [ ] **SIT validation**: Test files actually contain valid sensitive information types

```powershell
# Verify DLP policy sync status in Purview portal
# Navigate to: Policies > Lab-OnPrem-Sensitive-Data-Protection
# Check for "Sync in progress" or "Last synced" timestamp

# Force scanner to refresh policies
Restart-Service -Name "MIPScanner" -Force
Start-Sleep -Seconds 10

# Run full rescan
Start-Scan -Reset
```

### Issue: Activity Explorer Shows No Data

**Symptom:**
Activity Explorer doesn't show on-premises DLP activity even after successful scan.

**Root Cause:**
Activity data can take **15-30 minutes** to appear in Activity Explorer after scanning.

**Solution:**

```powershell
# Wait 15-30 minutes after scan completion

# Verify scan actually detected DLP matches in local reports first
Set-Location "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"
$latestReport = Get-ChildItem -Filter "DetailedReport*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Import-Csv $latestReport.FullName | Where-Object {$_."DLP Policy Matched" -ne ""} | Select-Object "File Path", "DLP Policy Matched", "DLP Rule Matched"

# If CSV shows DLP matches, wait for Activity Explorer sync
# Activity Explorer may take up to 24 hours for full data availability
```

---

## �📊 Expected Results

After completing this lab successfully, you should observe:

### DLP Policy Configuration
- DLP policy **Lab-OnPrem-Sensitive-Data-Protection** active in Purview
- Two rules configured:
  - **Block-Credit-Card-Access**: Enforcement action blocking file access
  - **Audit-SSN-Access**: Audit-only action logging access
- Policy scope: On-premises repositories only

### Scanner DLP Integration
- Scanner scan job configured with DLP enabled
- Scanner successfully downloads DLP policies from Purview service
- Scanner applies DLP rules during file scanning

### Enforcement Results
Based on Lab 00 sample data:
- **Finance\CustomerPayments.txt**: DLP match on Credit Card Number, access blocked
- **Finance\TransactionHistory.csv**: DLP match on Credit Card Number, access blocked
- **HR\EmployeeRecords.txt**: DLP match on SSN, access audited (not blocked)
- **HR\SalaryData.csv**: DLP match on SSN and Email, access audited

### Activity Explorer Data
- On-premises DLP activity visible within 15-30 minutes
- Activity shows:
  - Files scanned: 20-30 files
  - DLP matches: 4-6 files with sensitive data
  - Policy matched: Lab-OnPrem-Sensitive-Data-Protection
  - Rules matched: Block-Credit-Card-Access, Audit-SSN-Access
  - Actions: Block (for credit cards), Audit (for SSNs)

### Scanner CSV Reports
Scanner detailed reports include:
- **DLP Policy Matched** column populated
- **DLP Rule Matched** column showing specific rule
- **DLP Action** column showing Block or Audit
- **Sensitive Info Types** column listing detected SITs

---

## �� Key Learning Outcomes

After completing Lab 02, you have learned:

1. **DLP Policy Architecture**: Understanding how DLP policies work for on-premises repositories through the scanner

2. **Rule Configuration**: Creating DLP rules with conditions, actions, and notifications for different enforcement scenarios

3. **Enforcement vs. Audit**: Implementing blocking enforcement for high-risk data (credit cards) and audit-only for monitoring (SSNs)

4. **Scanner Integration**: Enabling DLP in scanner content scan jobs to apply policies during scanning operations

5. **Activity Monitoring**: Using Activity Explorer to monitor DLP matches, enforcement actions, and compliance posture

6. **Testing Strategies**: Differentiating between test/simulation mode and full enforcement for safe policy deployment

---

## 🚀 Next Steps

**Proceed to Lab 03**: Retention Labels & Data Lifecycle Management

In the next lab, you will:
- Create retention labels for old data management
- Configure auto-apply policies based on sensitive information types
- Test retention label application in SharePoint Online
- Understand limitations of retention labels for on-premises file shares
- Implement data lifecycle management strategies

**Before starting Lab 03, ensure:**
- [ ] DLP policy created and active
- [ ] Scanner DLP enforcement scan completed successfully
- [ ] Activity Explorer showing DLP matches
- [ ] All validation checklist items marked complete

---

## 📚 Reference Documentation

- [Microsoft Purview DLP for On-Premises Repositories](https://learn.microsoft.com/en-us/purview/dlp-on-premises-scanner-learn)
- [DLP Policy Configuration](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
- [Sensitive Information Types Reference](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)
- [Activity Explorer Documentation](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)
- [DLP Policy Tips and Notifications](https://learn.microsoft.com/en-us/purview/use-notifications-and-policy-tips)

---

## 🤖 AI-Assisted Content Generation

This comprehensive lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview DLP for on-premises repositories documentation as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of DLP configuration procedures while maintaining technical accuracy and current portal navigation steps.*

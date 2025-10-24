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

- Open browser and go to: https://purview.microsoft.com
- Sign in with your **admin account**
- Select **Solutions** from the left navigation
- Click **Data loss prevention**
- Select **Policies** from the left menu
- Click **+ Create policy**

> **💡 Background**: DLP policies for on-premises repositories work differently than cloud DLP. The scanner acts as the enforcement agent, applying policies during scan operations.

**Select Policy Template:**

- Template category: **Custom**
- Template: **Custom policy** (allows full control over rules and conditions)
- Click **Next**

**Name Your Policy:**

- **Name**: `Lab-OnPrem-Sensitive-Data-Protection`
- **Description**: `Protect PII and PCI data on on-premises file shares and Azure Files`
- Click **Next**

**Assign Admin Units:**

- Select **Full directory** (applies policy to all users and groups)
- Click **Next**

> **📚 Note**: Admin units allow scoping DLP policies to specific organizational units. For this lab, we use full directory for simplicity.

---

### Step 2: Choose Policy Locations

DLP policies can apply to multiple locations (Exchange, SharePoint, Teams, on-premises). For this lab, we focus exclusively on on-premises repositories.

**Configure Locations:**

- **Turn OFF all locations** by toggling them to OFF
- **On-premises repositories**: Toggle to **ON**
- Verify this is the ONLY location enabled
- Click **Next**

> **⚠️ Important**: On-premises repository DLP requires the Information Protection Scanner to be deployed and scanning the repositories. Without the scanner, DLP policies cannot be enforced on file shares.

---

### Step 3: Define Policy Settings

**Select Rule Configuration Method:**

- **Create or customize advanced DLP rules**: Selected
- This allows you to create multiple rules with different conditions and actions
- Click **Next**

You'll now create two DLP rules: one for Credit Card data (with blocking) and one for SSN data (with auditing).

---

### Step 4: Create DLP Rule for Credit Card Data

**Add First Rule:**

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

Under **Actions**, configure enforcement for on-premises repositories:

- Expand **On-premises repositories**
- Select: **Block people from accessing file**
- Choose: **Block everyone** (most restrictive for lab demonstration)

> **💡 Production Consideration**: In production, you might use "Block people external to your organization" to allow internal users access while preventing external sharing.

**Configure User Notifications:**

- **User notifications**: Toggle to **ON**
- **Policy tips**: Keep default or customize:
  - `This file contains credit card information and access has been restricted by your organization's DLP policy`
- **Email notifications**: Toggle ON if you want email alerts
- **Notify these people**: Select relevant stakeholders

**User Overrides (Optional for Lab):**

- Leave **Allow overrides** as OFF for this lab
- In production, you might allow business justifications

**Incident Reports:**

- **Send an alert to admins when a rule match occurs**: Toggle ON
- **Send alert every time an activity matches the rule**: Selected
- **Use email incident reports**: Configure notification email

**Review and Save:**

- Click **Save** to create the rule

---

### Step 5: Create DLP Rule for SSN Data (Audit Mode)

Now create a second rule for SSN data that audits but doesn't block access.

**Add Second Rule:**

- Click **+ Create rule**
- **Name**: `Audit-SSN-Access`
- **Description**: `Audit access to files containing Social Security Numbers without blocking`

**Configure Conditions:**

- **Content contains**: Click **Add** > **Sensitive info types**
- Search for and select: **U.S. Social Security Number (SSN)**
- Click **Add**
- **Instance count**: 
  - From: `1`
  - To: `Any`

**Configure Actions (Audit Only):**

- Expand **On-premises repositories**
- Select: **Audit or restrict activities**
- Choose: **Audit only** (no blocking, just logging)

> **💡 Testing Strategy**: Using audit-only for SSN allows you to test DLP without disrupting access, which is ideal for initial deployments.

**Configure Notifications:**

- **User notifications**: Toggle to **ON** (optional for audit mode)
- **Policy tips**: 
  - `This file contains sensitive information (Social Security Numbers). Access is being audited for compliance purposes.`

**Incident Reports:**

- **Send an alert to admins**: Toggle ON
- Configure alert recipients

**Review and Save:**

- Click **Save** to create the rule

---

### Step 6: Review and Create Policy

**Policy Summary Review:**

- **Locations**: Verify **On-premises repositories** is the only location enabled
- **Rules**: Verify both rules appear:
  - Block-Credit-Card-Access (Enforcement)
  - Audit-SSN-Access (Audit only)
- Click **Next**

**Policy Mode:**

You have three options for deploying the policy:

1. **Turn it on immediately**: Policy enforces immediately
2. **Test it out first**: Simulation mode with policy tips but no enforcement
3. **Keep it off**: Policy created but not active

For this lab:

- Select **Test it out first** (recommended) OR **Turn it on immediately** if you want immediate enforcement
- Click **Next**

**Create Policy:**

- Review all settings
- Click **Submit**
- Policy creation completes and appears in the policy list

> **✅ Best Practice**: Always test DLP policies in simulation mode first to understand impact before full enforcement, especially in production.

---

### Step 7: Enable DLP in Scanner Content Scan Job

Now configure the scanner to enforce DLP policies during scans.

**Navigate to Scanner Configuration:**

- Purview Portal: https://purview.microsoft.com
- Go to **Settings** (gear icon)
- Select **Information protection**
- Click **Information protection scanner**
- Select **Content scan jobs** tab
- Click on **Lab-OnPrem-Scan** (your scan job from Lab 01)

**Enable DLP Policy:**

- Scroll to **DLP policy** setting
- Toggle to **On**
- **Enable DLP rules**: Toggle to **On**

> **💡 Technical Detail**: When DLP is enabled in the scan job, the scanner downloads DLP policies from the service and applies them during file scanning.

**Save Configuration:**

- Click **Save** at the top of the page
- Wait for confirmation message

---

### Step 8: Run Enforcement Scan

With DLP enabled, run a new scan to apply DLP policies to files.

**On VM in PowerShell (as Administrator):**

```powershell
# Start enforcement scan with DLP policies
Start-Scan

# Expected output:
# The scanner service is starting...
# Scan started successfully
```

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

```powershell
# Navigate to scanner reports
Set-Location "$env:LOCALAPPDATA\Microsoft\MSIP\Scanner\Reports"

# List reports sorted by date
Get-ChildItem -Filter "*.csv" | Sort-Object LastWriteTime -Descending | Select-Object Name, LastWriteTime

# View latest detailed report
$latestReport = Get-ChildItem -Filter "DetailedReport*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Invoke-Item $latestReport.FullName
```

**Interpret DLP Actions in Reports:**

Scanner CSV reports now include DLP-related columns:
- **DLP Policy Matched**: Which policy matched the file
- **DLP Rule Matched**: Specific rule that triggered
- **DLP Action**: Action taken (Block, Audit, etc.)
- **Sensitive Info Types**: Which SITs were detected

---

### Step 9: View Activity in Activity Explorer

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

### Step 10: Test DLP Enforcement (Optional)

Validate that DLP policies are actively enforcing by attempting to access blocked files.

**On VM, Test File Access:**

```powershell
# Attempt to open a file with credit card data
# This should be blocked if DLP enforcement is active
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

## 📊 Expected Results

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

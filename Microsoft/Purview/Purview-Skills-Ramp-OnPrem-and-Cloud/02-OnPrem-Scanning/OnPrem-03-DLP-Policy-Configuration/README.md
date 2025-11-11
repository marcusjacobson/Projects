# Lab 02 - Part 1: DLP Policy Creation

## 📋 Overview

**Duration**: 30-45 minutes active work + 1-2 hours wait time for policy sync

**Objective**: Create and configure Data Loss Prevention (DLP) policies in the Purview portal to protect sensitive information on on-premises file repositories.

**What You'll Learn:**

- Create custom DLP policies for on-premises repositories.
- Configure DLP rules with conditions and sensitive information types.
- Understand DLP rule actions (block vs audit).
- Configure user notifications and admin alerts.
- Verify DLP policy creation and sync status.

**Prerequisites from Lab 01:**

- ✅ Information Protection Scanner deployed and operational.
- ✅ Discovery scan completed successfully showing sensitive data.
- ✅ Scanner service running and authenticated.
- ✅ Repositories configured (Finance, HR, Projects, Azure Files).

---

## 🎯 Lab Objectives

By the end of OnPrem-03, you will be able to:

1. Create DLP policies specifically for on-premises file repositories
2. Configure advanced DLP rules with sensitive information type conditions
3. Implement different enforcement actions (block access, audit only)
4. Configure user notifications and admin alerts for DLP matches
5. Understand DLP policy sync timing and requirements
6. Verify DLP policy creation and readiness for enforcement

> **⏳ Important**: This lab ends with a mandatory 1-2 hour wait for DLP policy synchronization. Do NOT proceed to OnPrem-04 until the policy sync completes.

---

## � Alternative Path: Existing DLP Policies with New Scanner Environment

**Use this section if:**

- ✅ You already have DLP policies configured in your tenant from previous setup.
- ✅ You completed OnPrem-01 (Scanner Deployment) and OnPrem-02 (Discovery Scans) on a fresh/recreated VM.
- ✅ You want to validate the new scanner environment is ready to use existing DLP policies.

**Skip this section if:**

- ❌ This is your first time creating DLP policies → Follow the standard Step-by-Step Instructions below.

---

### Why This Section Exists

**DLP Policy Architecture Explained:**

- **DLP policies** are stored at the **tenant level** in the Microsoft Purview portal (cloud-based).
- **Scanner** is a **local agent** that syncs and enforces these tenant-level policies.
- **When you recreate a scanner**: Policies persist in the portal, but the new scanner needs configuration to USE them.

**Critical Distinction:**

| Component | Storage Location | Survives VM Recreation? |
|-----------|------------------|------------------------|
| DLP Policies | Purview portal (tenant-level) | ✅ Yes |
| Content Scan Job DLP Settings | Scanner local database | ❌ No - must reconfigure |

### Validation & Configuration Steps

> **🖥️ Execution Environment**: Steps 2-6 must be executed **on the Purview Scanner VM** where the Microsoft Information Protection Scanner service is installed. Step 1 can be performed from any machine with portal access.

#### Step 1: Verify Existing DLP Policies in Portal

Confirm your DLP policies still exist in the tenant.

**Portal Verification:**

- Navigate to [Microsoft Purview portal](https://purview.microsoft.com).
- Go to **Solutions** > **Data loss prevention** > **Policies**.
- Verify your policy appears in the list (e.g., `Lab-OnPrem-Sensitive-Data-Protection`).
- Note the policy **Status** (should be "On" or "Test mode").

**Expected Policy Details:**

| Property | Expected Value |
|----------|----------------|
| **Policy Name** | Lab-OnPrem-Sensitive-Data-Protection |
| **Location** | On-premises repositories |
| **Rules** | Block-Credit-Card-Access, Audit-SSN-Access |
| **Status** | On (or Test mode if you left it in simulation) |

✅ **If your policy exists**: Continue to Step 2

❌ **If your policy is missing**: Follow the standard Step-by-Step Instructions below to recreate it

#### Step 2: Verify Scanner Discovery Scan Completed (OnPrem-02)

Confirm the new scanner environment completed discovery scans successfully.

**PowerShell Verification:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration"
.\Verify-OnPrem02Completion.ps1
```

**Expected Results:**

- Recent DetailedReport CSV from within last 24 hours.
- Repositories scanned: Finance, HR, Projects.
- File count > 0.

✅ **If discovery scan completed with repositories**: Continue to Step 3

❌ **If no recent scan or empty repositories**: Return to OnPrem-02 and complete discovery scan first

#### Step 3: Enable DLP in Content Scan Job

**Critical Configuration Required:**

Your new scanner needs the content scan job configured to evaluate DLP policies. This is LOCAL to the scanner and was NOT carried over from your previous setup.

**Enable DLP in Scanner:**

> **🖥️ Scanner VM Execution Required**: This script uses AIP Scanner cmdlets and must run on the Scanner VM.

**Copy and Execute on Scanner VM:**

1. On your **development/admin machine**, open the script file:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration\Enable-ScannerDLP.ps1
   ```

2. Copy the entire script content (Ctrl+A, Ctrl+C)
3. **RDP to your Scanner VM**
4. Open **PowerShell ISE** as Administrator on the Scanner VM
5. Paste the script content and save as `Enable-ScannerDLP.ps1`
6. Run the script:

   ```powershell
   .\Enable-ScannerDLP.ps1
   ```

The script will:

- Check current DLP configuration.
- Set OnlineConfiguration Off (for PowerShell-based configuration).
- Enable DLP with RepositoryOwner setting.
- Verify configuration applied successfully.

> **💡 Using Variables**: This script uses `$env:COMPUTERNAME` to automatically get your VM's actual computer name, handling Windows' 15-character name truncation (e.g., `vm-purview-scanner` becomes `VM-PURVIEW-SCAN`).
>
> **💡 Online Configuration**: The script sets `OnlineConfiguration Off` when switching from portal-based scanner configuration to PowerShell cmdlet-based configuration.

**What These Settings Do:**

| Setting | Purpose | Required For |
|---------|---------|--------------|
| **EnableDLP = On** | Enables DLP policy evaluation during scans | All DLP functionality |
| **RepositoryOwner** | Sets owner for DLP "make private" actions | DLP enforcement (blocking) |
| **Enforce = Off** | Audit mode (log matches but don't block) | Keep Off until OnPrem-04 |

> **💡 Why This Matters**: Without `EnableDLP = On`, the scanner won't evaluate files against your DLP policies, even though the policies exist in the portal.

#### Step 4: Sync Policies to Scanner

Force the scanner to download your existing DLP policies from the portal.

**Update Scanner Configuration:**

> **🖥️ Scanner VM Execution Required**: This script must be run **on the Purview Scanner VM**.

**Copy and Execute on Scanner VM:**

1. Open the script on your admin machine:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration\Sync-DLPPolicies.ps1
   ```

2. Copy entire script content.
3. **RDP to Scanner VM**, open PowerShell as Administrator.
4. Paste script content and save as `Sync-DLPPolicies.ps1`.
5. Run: `.\Sync-DLPPolicies.ps1`.

**Expected Results:**

- Policy sync completed successfully.
- Scanner service restarted.
- Verification instructions for Purview portal to check sync status.

#### Step 5: Run Scan with DLP Enabled

Run a new scan with DLP evaluation enabled.

> **⚠️ Important - Full Rescan Required**: After enabling DLP policies, you must run a **full rescan** using the `-Reset` parameter. By default, the scanner only scans new or changed files. Previously scanned files will show as "Already scanned" and won't have DLP policies applied unless you force a full rescan.

> **🖥️ Scanner VM Execution Required**: Both scripts must be run **on the Purview Scanner VM**.

**Start Full DLP Scan with Reset:**

1. Open the script on your admin machine:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration\Start-DLPScanWithReset.ps1
   ```

2. Copy entire script content
3. **RDP to Scanner VM**, open PowerShell as Administrator
4. Paste script content and save as `Start-DLPScanWithReset.ps1`
5. Run: `.\Start-DLPScanWithReset.ps1`

> **💡 Why -Reset is Required**: The scanner performs incremental scans by default, only scanning new or changed files. When you add or modify DLP policies, you need to run `Start-Scan -Reset` to apply those policies to all files, including previously scanned ones. This ensures fresh DLP policy evaluation and prevents "Already scanned" status from skipping files.

⏳ **Scan Duration**: Expect 5-15 minutes depending on repository size (same as OnPrem-02 discovery scan)

**Monitor Scan Progress:**

1. Open the script on your admin machine:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration\Monitor-DLPScan.ps1
   ```

2. Copy entire script content
3. In the same PowerShell window on Scanner VM (or open new as Administrator)
4. Paste script content and save as `Monitor-DLPScan.ps1`
5. Run: `.\Monitor-DLPScan.ps1`

The monitoring script will continuously display:

- Current scan status.
- Repository being scanned.
- File counts.
- DLP configuration settings.
- Automatic refresh every 30 seconds.

> **✅ Scan Complete Indicators**:
>
> - Monitor script shows Status = 'Idle'.
> - New DetailedReport file appears in reports directory.
> - Script displays completion summary with file counts.

Wait until the scan completes (scanner returns to Idle status).

#### Step 6: Verify DLP Policy Sync (Critical Validation)

> **🖥️ Scanner VM Execution Required**: This script must be run **on the Purview Scanner VM** to access scanner reports directory.

**Analyze DLP Scan Results:**

1. Open the script on your admin machine:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration\Get-DLPScanReport.ps1
   ```

2. Copy entire script content
3. **RDP to Scanner VM**, open PowerShell as Administrator
4. Paste script content and save as `Get-DLPScanReport.ps1`
5. Run: `.\Get-DLPScanReport.ps1`

The script will:

- Locate latest DetailedReport.csv (handles both loose CSV and ZIP archives).
- Extract and analyze DLP policy matches.
- Display sensitive information type detections.
- Group results by repository, policy, and info type.
- Show sample files with DLP matches.

**Expected Output (DLP Successfully Synced):**

- Files with DLP matches identified.
- Sensitive information types populated (Credit Card Number, SSN).
- DLP Mode = "Test" (audit-only).
- Repository groupings showing match distribution.

> **⚠️ On-Premises Scanner Limitation - Empty DLP Columns**: For on-premises scanners, **DLP Rule Name and DLP Status columns are typically empty or show "Skipped"** even when DLP policies are working correctly. This is **expected behavior** and does NOT indicate a problem.
>
> **Why These Columns Are Empty**:
>
> - **Test mode limitation**: On-premises scanners run DLP in "Test" mode only - actual enforcement (blocking access) only works in Microsoft 365 cloud services
> - **Detection-only operation**: The scanner detects sensitive information types and logs matches but doesn't populate detailed enforcement metadata
> - **Policy metadata not synced**: DLP Rule Name and DLP Status require full enforcement mode which isn't available for on-premises repositories
>
> **Primary Success Indicator**: If **Information Type Name** column is populated with values like "Credit Card Number" or "U.S. Social Security Number (SSN)", **DLP detection is working correctly**.

**Key Indicators:**

| Column | What to Look For | Meaning |
|--------|------------------|---------|
| **Information Type Name** | Sensitive info type names | **PRIMARY VALIDATION** - DLP detection working |
| **DLP Mode** | "Test" | Scanner detects but doesn't block (expected for on-premises) |
| **DLP Rule Name** | Usually **empty/blank** | **EXPECTED** - Not populated in Test mode for on-premises |
| **DLP Status** | Usually **empty/blank** or "Skipped" | **EXPECTED** - Not populated in Test mode for on-premises |

✅ **If you see DLP Mode = "Test" and Information Type Name populated**: DLP detection successfully working! (Empty DLP Rule Name and DLP Status are expected)

❌ **If Information Type Name column is completely empty**:

- Verify `EnableDLP = On` in Step 3.
- Re-run `Update-AIPScanner` and `Start-Scan`.
- Wait 1-2 hours and check again (policy sync can be delayed).

#### Step 7: Wait for Complete Policy Sync (Mandatory)

⏳ **STOP**: Even though DLP Mode and Information Type Name columns are populated, wait **1-2 hours** for complete policy synchronization before proceeding to OnPrem-04.

**Why This Wait is Required:**

- Scanner downloads basic DLP detection capability immediately (visible as DLP Mode = "Test" and populated Information Type Name).
- **Full policy sync to Activity Explorer** happens asynchronously and takes 1-2 hours.
- Activity Explorer updates require processing time for DLP events to appear.
- Complete policy distribution ensures DLP events are logged and reportable.

**What to Do During Wait Time:**

- ✅ Review OnPrem-04 overview section.
- ✅ Review your existing DLP policy rules in the Purview portal.
- ✅ Verify scan reports show expected sensitive files detected.
- ❌ Do NOT change DLP policy settings during sync.
- ❌ Do NOT restart scanner service during sync.
- ❌ Do NOT run additional scans during sync.

**Verify Sync Completion:**

After 1-2 hours, check Activity Explorer for DLP events:

- Navigate to [Purview portal](https://purview.microsoft.com) > **Solutions** > **Data loss prevention** > **Activity explorer**.
- Filter: **Activities** = "File accessed from on-premises repository".
- Look for your repositories (Finance, HR, Projects).
- Verify DLP events appear (sensitive information type matches logged).

> **💡 Activity Explorer Note**: Like the DetailedReport CSV, Activity Explorer may not show detailed DLP rule names for on-premises scanners. The presence of DLP events with matched sensitive information types (Credit Card Number, SSN) confirms the policy sync is complete.

✅ **If Activity Explorer shows DLP events with sensitive info types**: Policy sync complete, proceed to OnPrem-04

❌ **If no Activity Explorer events after 2 hours**:

- Verify scanner service running: `Get-Service MIPScanner`.
- Check latest scan completed successfully.
- Wait another hour and check again.

### Summary: You're Ready for OnPrem-04

**What You've Accomplished:**

✅ Verified existing DLP policies persist in tenant.
✅ Enabled DLP evaluation in content scan job (`EnableDLP = On`).
✅ Configured repository owner for enforcement (`RepositoryOwner`).
✅ Synced tenant policies to new scanner (`Update-AIPScanner`).
✅ Ran DLP-enabled scan and verified sensitive information type detection.
✅ Confirmed DLP Mode = "Test" and Information Type Name populated in DetailedReport.csv.
✅ Waited 1-2 hours for complete policy sync to Activity Explorer.

**Next Steps:**

➡️ **Proceed to OnPrem-04**: DLP Enforcement Configuration

OnPrem-04 will cover:

- Setting `Enforce = On` to enable blocking actions.
- Testing DLP enforcement with credit card file access.
- Reviewing NTFS permission changes from DLP "make private" actions.
- Monitoring DLP events in Activity Explorer and audit logs.

---

## �📖 Step-by-Step Instructions

## 📖 Step-by-Step Instructions

> **🖥️ Execution Environment**: 
> - **Step 1** (Policy Creation): Portal-based, can be done from any machine
> - **Steps 2-3** (Enable DLP & Run Scan): Must be executed **on the Purview Scanner VM** where the Microsoft Information Protection Scanner service is installed

### Step 1: Create DLP Policy in Purview Portal

**Navigate to Purview DLP Portal:**

- Open browser and go to the **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com).
- Sign in with your **admin account**.
- Navigate to **Solutions** > **Data loss prevention**.
- Select **Policies** from the left menu within Data loss prevention.
- Click **+ Create policy** to start policy creation.

> **💡 Portal Note**: The Microsoft Purview portal interface was redesigned in 2024. DLP policies are now accessed through Solutions > Data loss prevention > Policies. The steps below reflect the current portal as of October 2025.
>
> **💡 Background**: DLP policies for on-premises repositories work differently than cloud DLP. The scanner acts as the enforcement agent, applying policies during scan operations.

#### Choose What Type of Data to Protect

The policy creation wizard starts by asking what type of data you want to protect.

- Select: **Data stored in connected sources**.
- Click **Next**.

> **💡 Option Context**:
>
> - **Data stored in connected sources** = On-premises repositories, devices, cloud apps.
> - **Data created, received or shared in Microsoft 365** = Exchange, SharePoint, OneDrive, Teams.

#### Select Policy Template

- Under **Categories**, select: **Custom**.
- Under **Regulations**, select: **Custom policy** (allows full control over rules and conditions).
- Click **Next**.

> **💡 Template Options**: Microsoft provides pre-built templates for Financial, Medical/Health, and Privacy regulations. Custom policy gives you complete control over sensitive information types, conditions, and actions.

#### Name Your Policy

- **Name**: `Lab-OnPrem-Sensitive-Data-Protection`.
- **Description**: `Protect PII and PCI data on on-premises file shares and Azure Files`.
- Click **Next**.

#### Assign Admin Units

- **Full directory** is selected by default (applies policy to all users and groups).
- You can optionally click **Add or remove admin units** to scope the policy to specific organizational units.
- For this lab, keep the default **Full directory** selection.
- Click **Next**.

> **📚 Note**: Admin units allow scoping DLP policies to specific organizational units within your Microsoft Entra ID (Azure AD) tenant. If you click **Add or remove admin units** and see no options available, this is expected behavior when admin units haven't been configured in your tenant. Full directory applies the policy across your entire organization, which is appropriate for lab scenarios.

#### Configure Locations

DLP policies can apply to multiple locations (Exchange, SharePoint, Teams, on-premises). For this lab, we focus exclusively on on-premises repositories.

By default, several locations are checked (enabled):

- ✅ **Exchange email** (checked by default).
- ✅ **SharePoint sites** (checked by default).
- ✅ **OneDrive accounts** (checked by default).
- ✅ **Teams chat and channel messages** (checked by default).
- ✅ **Instances** (checked by default).
- ✅ **On-premises repositories** (checked by default).

**Uncheck all locations EXCEPT On-premises repositories:**

1. Click to **uncheck** the following locations (toggle them to OFF):
   - **Exchange email** → Uncheck.
   - **SharePoint sites** → Uncheck.
   - **OneDrive accounts** → Uncheck.
   - **Teams chat and channel messages** → Uncheck.
   - **Instances** → Uncheck.

2. Keep **ONLY** this location checked:
   - ✅ **On-premises repositories** → Keep checked (ON).

3. Verify **On-premises repositories** is the ONLY location with a checkmark.
4. Click **Next**.

> **⚠️ Important**: On-premises repository DLP requires the Information Protection Scanner to be deployed and scanning the repositories. Without the scanner, DLP policies cannot be enforced on file shares. We performed this action in lab 01.
>
> **💡 Lab Focus**: We're unchecking cloud locations (Exchange, SharePoint, OneDrive, Teams, Instances) to focus exclusively on on-premises file shares for this lab. In production environments, you would typically enable multiple locations to protect data across your entire organization.

#### Select Rule Configuration Method

- **Create or customize advanced DLP rules**: Selected.
- This allows you to create multiple rules with different conditions and actions.
- Click **Next**.

You'll now create two DLP rules: one for Credit Card data (with blocking) and one for SSN data (with auditing).

#### Add First Rule

- Click **+ Create rule**.
- **Name**: `Block-Credit-Card-Access`.
- **Description**: `Block user access to files containing credit card numbers`.

**Configure Conditions:**

Under **Conditions**, click **+ Add condition**:

- Select: **Content contains**.
- **Content contains**: Click **Add** > **Sensitive info types**.
- Search for and select: **Credit Card Number**.
- Click **Add**.
- **Instance count**:
  - From: `1`.
  - To: `Any`.

This condition triggers when the scanner detects at least one credit card number in a file.

**Configure Actions:**

Under **Actions**, click **+ Add an action** and configure enforcement for on-premises repositories:

1. **Select action**: **Restrict access or remove on-premises files**

2. **Choose restriction method** - You have four options:

   **Option 1: Block people from accessing file stored in on-premises scanner**:

   - **Block everyone**: Blocks all accounts except content owner, last modifier, repository owner, and admin.
   - **Block only people who have access to your on-premises network and users in your organization who weren't granted explicit access**: Removes "Everyone", "NT AUTHORITY\authenticated users", and "Domain Users" from file ACL.

   **Option 2: Set permissions on the file**:

   - Forces the file to inherit permissions from its parent folder.
   - Only applies if parent folder permissions are more restrictive than current file permissions.
   - Optional: Check **Inherit even if parent permissions are less restrictive** to force inheritance regardless.

   **Option 3: Remove the file from improper location**:

   - Moves original file to a quarantine folder.
   - Replaces original file with a `.txt` stub file.
   - Useful for isolating sensitive files from general access.

3. **For this lab**, select:
   - **Block people from accessing file stored in on-premises repositories**.
   - Choose: **Block everyone** (most restrictive for lab demonstration).

> **💡 Action Explanation**:
>
> - **Block everyone**: Removes all NTFS/SharePoint permissions except file owner, repository owner (from scan job settings), last modifier, admin, and scanner account
> - **Block only people with network access**: Removes broad access groups (Everyone, Domain Users, Authenticated Users) but preserves explicit user/group permissions
> - **Set permissions**: Makes file inherit parent folder permissions (useful for standardizing access)
> - **Remove file**: Quarantines sensitive files completely - most restrictive option
>
> **💡 Production Consideration**: In production, "Block only people who have access to your on-premises network" is often preferred as it removes broad access while preserving legitimate explicit permissions. "Block everyone" is more restrictive and may require additional permission management.

**Configure User Notifications:**

> **⚠️ On-Premises Limitation**: The **User notifications** option is grayed out (disabled) for on-premises repository DLP policies. Policy tips are NOT available when using the on-premises scanner location. This is a known limitation documented by Microsoft.
>
> User notifications and policy tips are only supported for cloud locations (Exchange, SharePoint, OneDrive, Teams). For on-premises repositories, DLP enforcement happens silently through the scanner without user-facing notifications.

**Skip User Notifications section** - These settings are not available for on-premises repositories:

- ~~User notifications~~ (grayed out).
- ~~Policy tips~~ (not supported).
- ~~Email notifications~~ (not available).
- ~~Notify these people~~ (not available).

**User Overrides:**

- **Allow overrides** will also be grayed out (not available for on-premises repositories).

**Incident Reports:**

Configure alert settings for when this rule matches:

- **Severity level**: Select **High** from the dropdown.
  - Options available: Low, Medium, High.
  - High severity ensures alerts are prioritized and visible in admin dashboards.

**Alert Triggering Options** - Choose one:

**Option 1: Send alert every time an activity matches the rule** (Recommended for lab):

- Select this radio button for immediate alerts on each credit card detection.
- Best for critical data and low-volume monitoring.

**Option 2: Send alert when the volume of matched activities reaches a threshold**:

- Select this radio button for threshold-based alerting.
- Configure the following thresholds:
  - ☐ **Number of matched activities**: Specify minimum count (e.g., 5 activities).
  - ☐ **Number of MB**: Specify data volume threshold (e.g., 10 MB).
  - **During the last X minutes**: Time window for threshold evaluation (e.g., 60 minutes).
- Use for high-volume environments to reduce alert noise.

**For this lab**: Select **"Send alert every time an activity matches the rule"**.

**Email Notifications:**

- **Use email incident reports**: Toggle ON to send email notifications.
  - **Send notification emails to these people**: Add admin email addresses.

> **💡 Severity Level Guidance**:
>
> - **High**: Use for critical sensitive data (credit cards, SSNs) that require immediate attention.
> - **Medium**: Use for moderately sensitive data that needs review but isn't urgent.
> - **Low**: Use for general monitoring and audit purposes.
>
> For this lab, we use **High** severity to ensure credit card detections are immediately visible in the DLP alerts dashboard.

> **💡 Threshold vs Immediate Alerting**:
>
> - **Every time** (immediate): Alert on each individual match - ideal for critical data like credit cards
> - **Threshold-based**: Alert only when volume exceeds limits - reduces noise in high-activity environments
> - You can combine multiple threshold conditions (activities AND/OR data size within time window)

**Review and Save:**

- Click **Save** to create the rule.

#### Add Second Rule for SSN Data (Audit Mode)

- Click **+ Create rule**.
- **Name**: `Audit-SSN-Access`.
- **Description**: `Audit access to files containing Social Security Numbers without blocking`.

**Configure Conditions:**

Under **Conditions**, click **+ Add condition**:

- Select: **Content contains**.
- **Content contains**: Click **Add** > **Sensitive info types**.
- Search for and select: **U.S. Social Security Number (SSN)**.
- Click **Add**.
- **Instance count**:
  - From: `1`.
  - To: `Any`.

This condition triggers when the scanner detects at least one Social Security Number in a file.

**Configure Actions (Audit Only):**

For audit-only monitoring, **do NOT add any actions**:

- Under **Actions**, you will see **+ Add an action** option.
- **Do not click** this for the SSN audit rule.
- Leave the Actions section empty (no actions configured).

> **💡 Audit vs Enforcement**:
>
> - **Audit-only rule** (SSN): No actions configured → Scanner detects and logs SSN files but doesn't modify permissions or block access
> - **Enforcement rule** (Credit Card): Actions configured → Scanner detects files AND applies restrictive actions (block, quarantine, etc.)
>
> Leaving Actions empty creates a monitoring/discovery rule that logs activity in Activity Explorer without disrupting user access.
>
> **💡 Testing Strategy**: Using audit-only for SSN allows you to test DLP without disrupting access, which is ideal for initial deployments and monitoring data usage patterns before implementing restrictive actions.

**Configure User Notifications:**

> **⚠️ On-Premises Limitation**: The **User notifications** option is grayed out (disabled) for on-premises repository DLP policies. Policy tips are NOT available when using the on-premises scanner location.

**Skip User Notifications section** - These settings are not available for on-premises repositories:

- ~~User notifications~~ (grayed out).
- ~~Policy tips~~ (not supported).
- ~~Email notifications~~ (not available).

**User Overrides:**

- **Allow overrides** will also be grayed out (not available for on-premises repositories).

**Incident Reports:**

Configure alert settings for when this rule matches:

- **Severity level**: Select **Medium** from the dropdown.
  - High: Reserved for critical data (credit cards).
  - **Medium**: Appropriate for SSN monitoring and audit scenarios.
  - Low: General monitoring.

**Alert Triggering Options** - Choose one:

**Option 1: Send alert every time an activity matches the rule** (Recommended for lab):

- Select this radio button for immediate alerts on each SSN detection.
- Best for low-volume monitoring and testing scenarios.

**Option 2: Send alert when the volume of matched activities reaches a threshold**:

- Select this radio button for threshold-based alerting.
- Configure the following thresholds:
  - ☐ **Number of matched activities**: Specify minimum count (e.g., 5 activities).
  - ☐ **Number of MB**: Specify data volume threshold (e.g., 10 MB).
  - **During the last X minutes**: Time window for threshold evaluation (e.g., 60 minutes).
- Use for high-volume environments to reduce alert noise.

**For this lab**: Select **"Send alert every time an activity matches the rule"**.

**Email Notifications:**

- **Use email incident reports**: Toggle ON to send email notifications.
  - **Send notification emails to these people**: Add admin email addresses.

> **💡 Audit Rule Alerting**: Even though this rule uses audit-only enforcement (no blocking), incident reports still generate alerts when SSNs are detected. This allows you to monitor SSN data usage and identify potential risks before implementing blocking actions.
>
> **💡 Threshold vs Immediate Alerting**:
>
> - **Every time** (immediate): Alert on each individual match - ideal for critical data or testing
> - **Threshold-based**: Alert only when volume exceeds limits - reduces noise in high-activity environments
> - You can combine multiple threshold conditions (activities AND/OR data size within time window)

**Review and Save:**

- Click **Save** to create the rule.
- Click **Next** to advance to Policy mode.

##### Policy Mode Options

The wizard presents three deployment options:

**Option 1: Run the policy in simulation mode**:

- Policy runs as if enforced but **no actual enforcement occurs**.
- All matched items and alerts are reported in simulation dashboard.
- Use to assess policy impact before full enforcement.
- Optional: **Show policy tips while in simulation mode** (not available for on-premises repositories).
- Optional: **Turn the policy on if it's not edited within fifteen days of the simulation** (auto-activation).

**Option 2: Turn the policy on immediately**:

- Policy enforces immediately with full actions applied.
- Credit card blocking and SSN audit logging active immediately.
- Recommended only after testing in simulation mode.

**Option 3: Keep it off**:

- Policy created but inactive.
- No enforcement, no simulation, no alerts.
- Use when policy configuration is incomplete or requires approval.

**For this lab**, select one of the following:

- **Recommended**: **Run the policy in simulation mode** (safer for initial testing)
  - Allows you to see what would be blocked/audited without actual enforcement
  - Review simulation results before enabling full enforcement
  - Change to "Turn it on right away" later after validation

- **Alternative**: **Turn the policy on immediately** (if you want immediate enforcement)
  - Credit card files will be blocked immediately on next scan
  - SSN files will be audited (logged) but not blocked.

**For this lab, we recommend**: Select **Turn it on right away** to demonstrate active DLP enforcement.

- Click **Next** to advance to Review and finish.

> **✅ Best Practice**: In production environments, always start with **Run the policy in simulation mode** to assess impact, identify false positives, and educate users before full enforcement. For this lab, we use immediate enforcement to demonstrate DLP actions during the enforcement scan.

#### Review and Finish

The final screen displays a comprehensive summary of your policy configuration. Review each section carefully before creating the policy.

**Page Header:** "Create the policy if these details look fine. Otherwise, adjust the settings to better meet your needs."

**Summary Sections Displayed:**

**1. The information to protect**:

- **Type**: Custom policy.
- Click **Edit** to modify policy template selection.

**2. Name**:

- **Name**: Lab-OnPrem-Sensitive-Data-Protection.
- Click **Edit** to change policy name.

**3. Description**:

- **Description**: Protect PII and PCI data on on-premises file shares and Azure Files.
- Click **Edit** to modify description.

**4. Locations**:

- **Selected location**: On-premises repositories.
- Teams suggestion banner may appear: "Consider adding Teams as a location to protect the accidental sharing of sensitive info in Teams messages".
  - You can ignore this for the lab (focused on on-premises only).
- Click **Edit** to modify location selection.

**5. Policy settings**:

- **Rules configured**:
  - Block-Credit-Card-Access.
  - Audit-SSN-Access.
- Click **Edit** to modify rules.

**6. Turn policy on after it's created?**

- **Status**: Yes (if you selected "Turn it on right away").
- **Status**: No (if you selected "Run the policy in simulation mode" or "Keep it off").
- Click **Edit** to change policy mode.

**Verify all settings are correct** - Each section has an **Edit** link to return to that configuration step if changes are needed.

**Submit Policy:**

- Click **Submit** to create the policy.
- Wait for confirmation message: "Your policy was created".
- Click **Done**.

**Policy Created:**

- Policy appears in the **Policies** list.
- **Status column** shows:
  - **On** (if turned on immediately).
  - **In simulation** (if simulation mode selected).
  - **Off** (if kept off).
- **Name**: Lab-OnPrem-Sensitive-Data-Protection.
- **Locations**: On-premises repositories.
- **Policy settings**: The configured policy names.

> **🔄 DLP Policy Sync Timing**: You will likely see a "Sync in progress" message on the policy screen after creation. This is normal behavior as the DLP policy is being distributed to the on-premises scanner infrastructure.
>
> **Expected sync time**: While Microsoft doesn't provide specific SLAs for on-premises scanner DLP policy sync, based on similar Purview services (Endpoint DLP) and real-world testing, policy synchronization typically takes **1-2 hours** to complete across the service.
>
> **⏳ Wait for sync to complete**: Do NOT restart the scanner service or run scans while the policy shows "Sync in progress". Restarting the scanner before sync completes does not speed up the process and may interfere with policy distribution. Simply wait for the sync status to clear.
>
> **How to verify sync completion**:
>
> - Refresh the **Policies** page in Purview portal (or check the **Policy sync status** tab in policy details)
> - The "Sync in progress" message should disappear once sync completes (typically within 1-2 hours)
> - **Only after sync completes**, proceed to Lab 02 - Part 2 for DLP enforcement configuration

---

### Step 2: Enable DLP in Content Scan Job

Before waiting for the policy sync to complete, you must enable DLP functionality in the scanner's content scan job. This is a **required configuration** that enables the scanner to evaluate files against DLP policies.

> **⚠️ Critical Requirement**: Without enabling DLP in the content scan job, the scanner will NOT evaluate files against your DLP policies, even after the policies sync successfully. This configuration must be completed before running a DLP-enabled scan.
>
> **🖥️ Scanner VM Execution Required**: This script must be run **on the Purview Scanner VM**.

**Enable DLP in Content Scan Job:**

1. Open the script on your admin machine:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration\Enable-ScannerDLP.ps1
   ```

2. Copy entire script content
3. **RDP to Scanner VM**, open PowerShell as Administrator
4. Paste script content and save as `Enable-ScannerDLP.ps1`
5. Run: `.\Enable-ScannerDLP.ps1`

This script will:

- Check current DLP configuration (`Get-ScannerContentScan`).
- Skip configuration if DLP is already enabled.
- Enable DLP with proper settings if not configured.
- Verify configuration after changes.

> **💡 Using Variables**: This pattern uses `$computerName = $env:COMPUTERNAME` (same as OnPrem-02) to automatically get your VM's actual computer name, handling Windows' 15-character name truncation (e.g., `vm-purview-scanner` becomes `VM-PURVIEW-SCAN`).
>
> **💡 Online Configuration**: The `Set-ScannerConfiguration -OnlineConfiguration Off` command is required when switching from portal-based scanner configuration (from OnPrem-02) to PowerShell cmdlet-based configuration. This allows the `Set-ScannerContentScan` cmdlet to modify scanner settings that were originally configured through the Purview portal.

**What These Settings Do:**

| Setting | Purpose | Impact |
|---------|---------|--------|
| **EnableDLP = On** | Enables DLP policy evaluation during scans | All DLP functionality |
| **RepositoryOwner** | Account for "make private" DLP actions | Sets owner for restricted files |
| **Enforce = Off** | Audit mode (default) | Logs policy matches without blocking |

> **💡 Why This Matters**: Without `EnableDLP = On`, the scanner won't evaluate files against your DLP policies, even though the policies exist in the portal.

**Verify Configuration Applied:**

```powershell
# Confirm DLP is now enabled
Get-ScannerContentScan | Select-Object EnableDlp, RepositoryOwner, Enforce
```

**Expected Output After Configuration:**

```text
EnableDlp RepositoryOwner              Enforce
--------- ---------------              -------
On        PURVIEWDEMO\scanner-svc      Off
```

> **✅ Configuration Complete**: With `EnableDLP = On`, your scanner is now ready to evaluate files against DLP policies once the policy sync completes.

---

### Step 3: Sync Policies to Scanner and Run DLP-Enabled Scan

After enabling DLP in the content scan job, you must sync the DLP policies from the portal and run a scan to validate DLP detection is working.

> **🖥️ Scanner VM Execution Required**: All three scripts must be run **on the Purview Scanner VM**.

**Sync DLP Policies from Portal:**

1. Open the script on your admin machine:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration\Sync-DLPPolicies.ps1
   ```

2. Copy entire script content
3. **RDP to Scanner VM**, open PowerShell as Administrato
4. Paste script content and save as `Sync-DLPPolicies.ps1`
5. Run: `.\Sync-DLPPolicies.ps1`

**Run Full DLP Scan with Reset:**

1. Open the script on your admin machine:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration\Start-DLPScanWithReset.ps1
   ```

2. Copy entire script content.
3. In the same PowerShell window on Scanner VM (or open new as Administrator).
4. Paste script content and save as `Start-DLPScanWithReset.ps1`.
5. Run: `.\Start-DLPScanWithReset.ps1`.

> **💡 Why -Reset is Required**: The scanner performs incremental scans by default, only scanning new or changed files. When you add or modify DLP policies, you need to run `Start-Scan -Reset` to apply those policies to all files, including previously scanned ones. This ensures fresh DLP policy evaluation and prevents "Already scanned" status from skipping files.

⏳ **Scan Duration**: Expect 5-15 minutes depending on repository size (same as OnPrem-02 discovery scan)

**Monitor Scan Progress:**

1. Open the script on your admin machine:

   ```powershell
   c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration\Monitor-DLPScan.ps1
   ```

2. Copy entire script content.
3. In the same PowerShell window on Scanner VM (or open new as Administrator).
4. Paste script content and save as `Monitor-DLPScan.ps1`.
5. Run: `.\Monitor-DLPScan.ps1`.

- Extract and analyze DetailedReport.csv for DLP matches.
- Show files grouped by repository, policy name, and sensitive info type.
- Display sample files with DLP matches.
- Open full CSV for detailed review.

> **📦 Report Format**: The scanner may create loose DetailedReport CSV files or ZIP archives containing CSV files. The script handles both formats automatically.

**Expected Output (DLP Detection Working):**

```text
Repository                 File                                           Info Type                         DLP Mode
----------                 ----                                           ---------                         --------
\\vm-purview-scan\Finance  \\vm-purview-scan\Finance\CustomerPayments.txt Credit Card Number                Test
\\vm-purview-scan\HR       \\vm-purview-scan\HR\EmployeeRecords.txt       U.S. Social Security Number (SSN) Test
\\vm-purview-scan\Projects \\vm-purview-scan\Projects\PhoenixProject.txt  Credit Card Number                Test
```

> **⚠️ On-Premises Scanner Limitation - Empty DLP Columns**: For on-premises scanners, **DLP Rule Name and DLP Status columns are typically empty or show "Skipped"** even when DLP policies are working correctly. This is **expected behavior** and does NOT indicate a problem.
>
> **Why These Columns Are Empty**:
>
> - **Test mode limitation**: On-premises scanners run DLP in "Test" mode only - actual enforcement (blocking access) only works in Microsoft 365 cloud services
> - **Detection-only operation**: The scanner detects sensitive information types and logs matches but doesn't populate detailed enforcement metadata
> - **Policy metadata not synced**: DLP Rule Name and DLP Status require full enforcement mode which isn't available for on-premises repositories
>
> **Primary Success Indicator**: If **Information Type Name** column is populated with values like "Credit Card Number" or "U.S. Social Security Number (SSN)", **DLP detection is working correctly**.

**Key Indicators:**

| Column | What to Look For | Meaning |
|--------|------------------|---------|
| **Information Type Name** | Sensitive info type names | **PRIMARY VALIDATION** - DLP detection working |
| **DLP Mode** | "Test" | Scanner detects but doesn't block (expected for on-premises) |
| **DLP Rule Name** | Usually **empty/blank** | **EXPECTED** - Not populated in Test mode for on-premises |
| **DLP Status** | Usually **empty/blank** or "Skipped" | **EXPECTED** - Not populated in Test mode for on-premises |

✅ **If you see DLP Mode = "Test" and Information Type Name populated**: DLP detection successfully working! (Empty DLP Rule Name and DLP Status are expected)

❌ **If Information Type Name column is completely empty**:

- Verify `EnableDLP = On` in Step 2.
- Re-run `Update-AIPScanner` and `Start-Scan -Reset`.
- Wait 1-2 hours and check again (policy sync can be delayed).

---

## 🛑 STOP - Policy Sync Wait Required

**⏳ MANDATORY WAIT PERIOD**: Even though DLP detection is working in the scan report, you must wait **1-2 hours** for complete policy synchronization to Activity Explorer before proceeding to OnPrem-04.

### What Happens During Sync

The scanner has already downloaded basic DLP detection capability (visible in your scan report), but full policy synchronization to Activity Explorer happens asynchronously:

- Scanner downloads basic DLP detection capability immediately (visible as DLP Mode = "Test" and populated Information Type Name).
- **Full policy sync to Activity Explorer** happens asynchronously and takes 1-2 hours.
- Activity Explorer updates require processing time for DLP events to appear.
- Complete policy distribution ensures DLP events are logged and reportable.

### What You Should Do Now

**✅ DO:**

- Take a break - grab coffee, lunch, or work on other tasks.
- Set a timer for 1-2 hours to check Activity Explorer.
- Review OnPrem-04 overview section to understand enforcement steps.
- Review the DLP policy configuration you just created.
- Verify scan reports show expected sensitive files detected.

**❌ DO NOT:**

- Proceed to OnPrem-04 before Activity Explorer sync completes.
- Restart the scanner service (doesn't help, may interfere).
- Run additional scans during sync period.
- Modify the DLP policy (may reset sync timer).
- Create additional DLP policies (each requires its own sync time).

### How to Verify Sync Completion

**Check Activity Explorer Readiness:**

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration"
.\Verify-ActivityExplorerSync.ps1
```

The script will:

- Check local prerequisites (scan completion, DLP configuration).
- Provide detailed instructions for Activity Explorer portal verification.
- Display success criteria and troubleshooting guidance.
- Show expected timeline for sync completion.

**Manual Activity Explorer Verification:**

After 1-2 hours, check Activity Explorer for DLP events:

- Navigate to [Purview portal](https://purview.microsoft.com) > **Solutions** > **Data loss prevention** > **Activity explorer**.
- Filter: **Activities** = "File accessed from on-premises repository".
- Look for your repositories (Finance, HR, Projects).
- Verify DLP events appear (sensitive information type matches logged).

> **💡 Activity Explorer Note**: Like the DetailedReport CSV, Activity Explorer may not show detailed DLP rule names for on-premises scanners. The presence of DLP events with matched sensitive information types (Credit Card Number, SSN) confirms the policy sync is complete.

✅ **If Activity Explorer shows DLP events with sensitive info types**: Policy sync complete, proceed to OnPrem-04

❌ **If no Activity Explorer events after 2 hours**: Run Verify-ActivityExplorerSync.ps1 for troubleshooting guidance

### Expected Timeline

- **DLP scan completed**: Immediate (Step 5)
- **DLP detection visible in CSV**: Immediate (Information Type Name populated)
- **Activity Explorer sync starts**: Automatic after scan
- **Typical Activity Explorer sync completion**: 1-2 hours after scan
- **Maximum expected**: 2-3 hours for Activity Explorer events to appear
- **If exceeds 2-3 hours**: Use Verify-ActivityExplorerSync.ps1 for diagnostics

### Troubleshooting Extended Sync Times

If Activity Explorer events don't appear after 2-3 hours, run the verification script for comprehensive troubleshooting:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-03-DLP-Policy-Configuration"
.\Verify-ActivityExplorerSync.ps1
```

The script provides:

- Scanner service status verification.
- Scan completion checks.
- Network connectivity tests.
- Auditing configuration guidance.
- Timeline reference and next steps.

**If Events Still Don't Appear:**

- Verify DLP policy is set to "On" status in portal.
- Confirm EnableDLP = On in scanner configuration.
- Re-run scan with Start-DLPScanWithReset.ps1.
- Contact Microsoft Support if events don't appear after 4+ hours.

---

## ✅ Validation Checklist

Before proceeding to OnPrem-04, verify:

### DLP Policy Creation

- [ ] DLP policy **Lab-OnPrem-Sensitive-Data-Protection** created successfully
- [ ] Policy status set to **On** (not "Off" or "Test only")
- [ ] Policy location set to **On-premises repositories** only (no cloud locations)
- [ ] Two rules created:
  - [ ] **Block-Credit-Card-Access**: Block enforcement action
  - [ ] **Audit-SSN-Access**: Audit-only action
- [ ] Rules configured with correct sensitive information types:
  - [ ] Credit Card Number SIT in Block rule
  - [ ] U.S. Social Security Number SIT in Audit rule
- [ ] Enforcement actions configured appropriately
- [ ] User notifications enabled for both rules
- [ ] Admin notifications configured

### Scanner DLP Configuration

- [ ] **DLP enabled in content scan job** (`EnableDLP = On`)
- [ ] **Repository owner configured** (domain\scanner-svc)
- [ ] Verified configuration with `Get-ScannerContentScan`
- [ ] **Scanner service restarted** after enabling DLP (`Restart-Service MIPScanner`)

### DLP Detection Validation

- [ ] **DLP scan completed** using `Start-Scan -Reset`
- [ ] **DetailedReport CSV** shows DLP Mode = "Test"
- [ ] **Information Type Name populated** with "Credit Card Number" or "U.S. Social Security Number (SSN)"
- [ ] **Empty columns expected**: DLP Rule Name and DLP Status empty/blank (expected for on-premises scanners)

### Policy Sync Completion

- [ ] **Activity Explorer events appear** (1-2 hours after scan completion)
- [ ] **DLP events visible** in Activity Explorer with filter "File accessed from on-premises repository"
- [ ] **Sensitive info types logged**: Activity Explorer shows matched sensitive information types
- [ ] **Repositories visible**: Finance, HR, and Projects repositories appear in Activity Explorer events
- [ ] **Empty rule names expected**: Activity Explorer may not show detailed DLP rule names (expected for on-premises)

> **🎯 Success Indicator**: The primary success indicator is **Activity Explorer showing DLP events** with matched sensitive information types (Credit Card Number, SSN), even if DLP rule names don't appear. This confirms the on-premises scanner is successfully detecting sensitive data and logging events for compliance reporting.

---

## 🚀 Next Steps

### Summary: You're Ready for OnPrem-04

Congratulations! You've successfully configured DLP policy detection for on-premises repositories:

**✅ What You've Accomplished:**

- Created comprehensive DLP policy **Lab-OnPrem-Sensitive-Data-Protection** with blocking and auditing rules.
- Configured DLP policy to protect on-premises repositories (Finance, HR, Projects).
- Enabled DLP in scanner content scan job configuration.
- Ran DLP-enabled scan and validated detection in reports.
- Confirmed DLP Mode = "Test" and Information Type Name populated (Credit Card Number, SSN).
- Understood empty DLP Rule Name/Status columns are expected for on-premises scanners.
- Waited for Activity Explorer sync to complete (DLP events now visible).

### Immediate Next Step

**⏳ WAIT for Activity Explorer sync** (if not already complete - allow 1-2 hours after scan)

Verify Activity Explorer shows DLP events with matched sensitive information types using the verification method in the "How to Verify Sync Completion" section above.

### After Sync Completes

**Proceed to OnPrem-04: DLP Enforcement & Monitoring**:

In OnPrem-04, you will:

- **Understand DLP Test vs Enforce modes** and on-premises limitations
- **Monitor DLP activity** in Activity Explorer with realistic expectations
- **Validate DLP detection** against your test sensitive data files
- **Troubleshoot common DLP scenarios** like missing columns or empty rule names
- **Review compliance reporting** and understand what's available for on-premises

**Location**: `OnPrem-04-DLP-Enforcement/README.md`

**Duration**: 1 hour (validation and monitoring focus)

---

## 📚 Reference Documentation

- [Microsoft Purview DLP for On-Premises Repositories](https://learn.microsoft.com/en-us/purview/dlp-on-premises-scanner-learn)
- [DLP Policy Configuration](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
- [Sensitive Information Types Reference](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)
- [DLP Policy Tips and Notifications](https://learn.microsoft.com/en-us/purview/use-notifications-and-policy-tips)
- [Information Protection Scanner Overview](https://learn.microsoft.com/en-us/purview/deploy-scanner)

---

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of DLP policy configuration while maintaining technical accuracy for on-premises data protection scenarios.*

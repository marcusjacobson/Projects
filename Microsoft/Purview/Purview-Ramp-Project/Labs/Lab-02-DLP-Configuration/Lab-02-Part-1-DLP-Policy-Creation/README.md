# Lab 02 - Part 1: DLP Policy Creation

## 📋 Overview

**Duration**: 30-45 minutes active work + 1-2 hours wait time for policy sync

**Objective**: Create and configure Data Loss Prevention (DLP) policies in the Purview portal to protect sensitive information on on-premises file repositories.

**What You'll Learn:**

- Create custom DLP policies for on-premises repositories
- Configure DLP rules with conditions and sensitive information types
- Understand DLP rule actions (block vs audit)
- Configure user notifications and admin alerts
- Verify DLP policy creation and sync status

**Prerequisites from Lab 01:**

- ✅ Information Protection Scanner deployed and operational
- ✅ Discovery scan completed successfully showing sensitive data
- ✅ Scanner service running and authenticated
- ✅ Repositories configured (Finance, HR, Projects, Azure Files)

---

## 🎯 Lab Objectives

By the end of Lab 02 - Part 1, you will be able to:

1. Create DLP policies specifically for on-premises file repositories
2. Configure advanced DLP rules with sensitive information type conditions
3. Implement different enforcement actions (block access, audit only)
4. Configure user notifications and admin alerts for DLP matches
5. Understand DLP policy sync timing and requirements
6. Verify DLP policy creation and readiness for enforcement

> **⏳ Important**: This lab ends with a mandatory 1-2 hour wait for DLP policy synchronization. Do NOT proceed to Lab 02 - Part 2 until the policy sync completes.

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

## 🛑 STOP - Policy Sync Wait Required

**⏳ MANDATORY WAIT PERIOD**: DLP policy synchronization typically takes **1-2 hours** to complete after policy creation.

### What Happens During Sync

The DLP policy is being distributed from the Purview portal to the on-premises scanner infrastructure. This process:

- Synchronizes policy rules to the Purview service
- Distributes policy configuration to scanner endpoints
- Prepares enforcement mechanisms for on-premises repositories
- Cannot be accelerated by restarting services or running scans

### What You Should Do Now

**✅ DO:**

- Take a break - grab coffee, lunch, or work on other tasks
- Set a timer for 1 hour to check sync status
- Verify the "Sync in progress" message clears in the Purview portal
- Review the DLP policy configuration you just created
- Read ahead in Lab 02 - Part 2 to understand enforcement steps

**❌ DO NOT:**

- Proceed to Lab 02 - Part 2 before sync completes
- Restart the scanner service (doesn't help, may interfere)
- Run scanner scans (DLP policies won't be available yet)
- Modify the DLP policy (resets sync timer)
- Create additional DLP policies (each requires its own sync time)

### How to Verify Sync Completion

**Method 1 - Purview Portal Check:**

- Navigate to **Solutions** > **Data loss prevention** > **Policies**
- Locate **Lab-OnPrem-Sensitive-Data-Protection** policy
- Refresh the page (Ctrl+F5) to ensure current status
- **Sync Complete**: No "Sync in progress" message appears
- **Still Syncing**: "Sync in progress" message still visible → Wait longer

**Method 2 - Policy Sync Status Tab:**

- Click on the **Lab-OnPrem-Sensitive-Data-Protection** policy name
- Select the **Policy sync status** tab
- Check sync status and timestamp
- **Ready to proceed**: Status shows "Synced" with recent timestamp

### Expected Timeline

- **Policy created**: Current time
- **Initial sync starts**: Within 1-5 minutes
- **Typical completion**: 1-2 hours after creation
- **Maximum expected**: 2-3 hours for complex policies
- **If exceeds 2-3 hours**: Check troubleshooting section below

### Troubleshooting Extended Sync Times

If sync is still in progress after 2-3 hours:

**Check Policy Status:**

```powershell
# Verify policy appears in Purview portal
# Navigate to Solutions > Data loss prevention > Policies
# Confirm Lab-OnPrem-Sensitive-Data-Protection is listed
```

**Verify Network Connectivity:**

```powershell
# On scanner VM, verify connectivity to Purview portal
Test-NetConnection -ComputerName purview.microsoft.com -Port 443

# Expected: TcpTestSucceeded: True
```

**Check for Policy Errors:**

- Review policy configuration for any error messages
- Verify all required fields are configured correctly
- Check that policy is set to "On" status (not "Off" or "Test only")

**If Sync Remains Stuck:**

- Contact Microsoft Support with policy details
- Provide tenant ID and policy name
- Include timestamp of when policy was created

---

## ✅ Validation Checklist - Part 1 Complete

Before proceeding to Lab 02 - Part 2, verify:

### DLP Policy Creation

- [ ] DLP policy **Lab-OnPrem-Sensitive-Data-Protection** created successfully
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

### Policy Status

- [ ] Policy status set to **On** (Turn it on immediately mode)
- [ ] Policy appears in Policies list in Purview portal
- [ ] Policy configuration saved successfully

### Policy Sync Completion (REQUIRED)

- [ ] **"Sync in progress" message has cleared** (CRITICAL - DO NOT SKIP)
- [ ] Policy sync status shows "Synced" in Policy sync status tab
- [ ] At least 1-2 hours have elapsed since policy creation
- [ ] Purview portal page refreshed (Ctrl+F5) to verify current status

---

## 🚀 Next Steps

### Immediate Next Step

**⏳ WAIT for DLP policy sync to complete** (1-2 hours)

Monitor sync status using the verification methods above. Do not proceed until sync completes.

### After Sync Completes

**Proceed to Lab 02 - Part 2: DLP Enforcement & Monitoring**

In Part 2, you will:

- Enable DLP in scanner content scan job
- Run full scans with DLP policy application
- View DLP detection results in scanner CSV reports
- Monitor DLP activity in Activity Explorer
- Understand Test vs Enforce modes for DLP
- Validate DLP sensitive information type detection
- Troubleshoot common DLP scanning issues

**Location**: `Labs/Lab-02-DLP-Configuration/Lab-02-Part-2-DLP-Enforcement/README.md`

**Duration**: 1-2 hours (after sync completes)

---

## 📚 Reference Documentation

- [Microsoft Purview DLP for On-Premises Repositories](https://learn.microsoft.com/en-us/purview/dlp-on-premises-scanner-learn)
- [DLP Policy Configuration](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
- [Sensitive Information Types Reference](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)
- [DLP Policy Tips and Notifications](https://learn.microsoft.com/en-us/purview/use-notifications-and-policy-tips)
- [Information Protection Scanner Overview](https://learn.microsoft.com/en-us/purview/deploy-scanner)

---

## 🤖 AI-Assisted Content Generation

This comprehensive lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview DLP policy creation procedures and realistic policy sync timing expectations as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of DLP policy configuration while maintaining technical accuracy and reflecting real-world DLP policy synchronization timing requirements for on-premises repositories.*
# Lab 06: Data Loss Prevention for Fabric

## 🎯 Objective

Create and test **Microsoft Purview Data Loss Prevention (DLP) policies** that automatically detect sensitive information types (SITs) in your Fabric data stores — Lakehouse, Warehouse, and KQL Database.

**Duration**: 35 minutes

---

## 💰 Cost Note

> **✅ M365 E5 Required**: This lab uses DLP for Fabric, which requires Microsoft 365 E5 (or E5 Compliance add-on). DLP policies for Fabric are configured in the **Microsoft Purview portal** ([purview.microsoft.com](https://purview.microsoft.com)).
>
> **📊 Fabric Capacity**: Your Fabric workspaces must be on Fabric capacity or Premium capacity for DLP scanning. Your 60-day trial qualifies.

---

## 🏗️ What You'll Build

| Item | Description |
|------|-------------|
| **DLP Policy** | Custom policy targeting Fabric and Power BI location |
| **SIT Detection** | Automatic scanning for SSNs, credit cards, financial data |
| **Policy Tips** | Visual indicators on flagged items |
| **Alert Configuration** | Admin notifications when sensitive data is detected |

### Real-World Context

This lab demonstrates **automatic data classification** for Fabric:

- **DLP scans actual data content** — not just metadata.
- **Sensitive Information Types (SITs)** detect patterns like SSN, credit card numbers, health records.
- **Policy actions** can alert, restrict access, or notify users.
- **Coverage across Fabric** — Lakehouse, Warehouse, and KQL Database are ALL scanned.

Enterprise DLP scenarios:

- **Financial Services** — Detect credit card numbers, prevent unauthorized export.
- **Healthcare** — Flag PHI/HIPAA data, restrict external sharing.
- **HR Systems** — Identify SSNs, apply strict access controls.

---

## 📋 Prerequisites

- [ ] Labs 01-05 completed (Lakehouse, Warehouse, KQL Database with data).
- [ ] **Microsoft 365 E5** license (or E5 Compliance/Information Protection & Governance add-on).
- [ ] Access to **Microsoft Purview portal** ([purview.microsoft.com](https://purview.microsoft.com)).
- [ ] Workspace on Fabric capacity (trial qualifies).
- [ ] **Pay-as-you-go billing enabled** for Microsoft Purview (completed in Lab 00).

> **🔒 Permissions**: You need one of these roles: **Compliance Administrator**, **Compliance Data Administrator**, **Information Protection Admin**, or **Security Administrator**.

---

## 🔧 Step 1: Understand DLP Coverage for Your Lab Items

### Which Items Get Scanned

DLP for Fabric automatically scans these item types from your labs:

| Lab | Item Created | DLP Scans? | Scan Trigger |
|-----|--------------|------------|--------------|
| **Lab 02** | CustomerDataLakehouse | ✅ **YES** | When data changes |
| **Lab 04** | AnalyticsWarehouse | ✅ **YES** | When data changes |
| **Lab 05** | IoTEventhouse (KQL DB) | ✅ **YES** | When data changes |
| Lab 03 | Dataflows/Pipelines | ❌ No | Moves data, doesn't store it |

### What DLP Detects in Your Data

Your sample data contains these detectable SITs:

**From customers.csv (loaded in Lab 02):**

| Sensitive Information Type | Example Pattern |
|---------------------------|-----------------|
| **U.S. Social Security Number (SSN)** | 123-45-6789 |

**From transactions.csv (loaded in Lab 02):**

| Sensitive Information Type | Example Pattern |
|---------------------------|-----------------|
| **Credit Card Number** | 4532-1234-5678-9012 |

> **📝 Note**: Not all SITs are supported for Fabric/Power BI locations. **SSN** and **Credit Card Number** are fully supported and will be used in this lab.

> **💡 Key Insight**: DLP scans the **actual data content** in Delta tables (Lakehouse), SQL tables (Warehouse), and KQL tables — not just file names or metadata.

---

## 🔧 Step 2: Access Microsoft Purview Portal

### Navigate to DLP

1. Open a new browser tab.
2. Go to **[purview.microsoft.com](https://purview.microsoft.com)** (Microsoft Purview portal).
3. Sign in with your organizational account.

### Verify DLP Access

1. In the left navigation, under **Solutions**, expand **Data loss prevention**.
2. Select **Policies**.
3. You should see the policy management interface with a **+ Create policy** button.

> **❌ If you don't see DLP**: You may not have the required Compliance Administrator or Information Protection Admin role. Contact your tenant administrator.

---

## 🔧 Step 3: Create a DLP Policy for Fabric

### Start Policy Creation

1. In **Data loss prevention** → **Policies**, click **+ Create policy**.

> **📝 Note**: The **+ Create policy** button only appears if you have the required role permissions.

2. On the **What info do you want to protect?** page:
   - Select **Enterprise applications & devices** (left option).
   - This option covers Fabric, Power BI, SharePoint, OneDrive, and other M365 locations.
   - Click to continue.

> **📝 Note**: The "Inline web traffic" option is for Edge browser and network integrations — not needed for Fabric.

3. On the **Categories** page:
   - Select **Custom** in the left categories list.
   - Select **Custom policy** template on the right.
   - Click **Next**.

> **⚠️ Important**: No other categories or templates are currently supported for Fabric DLP policies. You must use Custom.

### Name Your Policy

1. **Name**: `Fabric PII Detection - Lab`
2. **Description**: `Detects SSN, credit card, and financial data in Fabric Lakehouse, Warehouse, and KQL Database items.`
3. Click **Next**.

### Assign Admin Units

1. On the **Assign admin units** page, click **Next** to skip.
   - Admin units are not supported for DLP in Fabric and Power BI.
   - Leave as default (Full directory).

---

## 🔧 Step 4: Select Fabric as the Location

### Choose Location

This is the critical step — you must select **Fabric and Power BI workspaces**:

1. On the **Choose locations to apply the policy** page:
   - Select **Fabric and Power BI workspaces** as the location.
   - All other locations will be automatically disabled — DLP policies for Fabric only support this location.

2. **Scope to specific workspaces** (optional):
   - By default, the policy applies to all workspaces.
   - Click **Edit** to specify particular workspaces to include or exclude.
   - For this lab, leave as **All workspaces** or choose your specific `Fabric-Purview-Lab` workspace.

3. Click **Next**.

> **⚠️ Important**: DLP actions are only supported for workspaces hosted on **Fabric capacity** or **Premium capacity**. Shared capacity workspaces won't be scanned.

---

## 🔧 Step 5: Configure Detection Rules

### Define Policy Settings

1. On the **Define policy settings** page, select **Create or customize advanced DLP rules**.
2. Click **Next**.

### Create Detection Rule

1. On the **Customize advanced DLP rules** page, click **+ Create rule**.

### Configure Rule Details

1. **Name**: Enter `Detect PII in Fabric Data`.
2. **Description**: Optionally add `Detects SSN, credit card, and financial data patterns in Fabric items.`

### Add Sensitive Information Types

The **Conditions** section shows a **Content contains** group by default:

1. In the **Content contains** section, you'll see:
   - **Group name**: Rename from `Default` to `PII Detection` for clarity.
   - **Group operator**: Verify it's set to **Any of these** (matches if any SIT is detected).
2. Click **Add** → **Sensitive info types**.
3. In the sidebar that opens, search and select these SITs (matching your Lab 02 data):

| Sensitive Info Type | Search Term | Source |
|---------------------|-------------|--------|
| **U.S. Social Security Number (SSN)** | `SSN` or `social security` | customers.csv |
| **Credit Card Number** | `credit card` | transactions.csv |

> **⚠️ Note**: Some SITs like **All Full Names** are not supported for Fabric/Power BI locations. If you try to add them, you'll receive an error when saving the rule.

4. Click **Add** to confirm your SIT selections.
5. For each SIT added, you can adjust:
   - **Instance count**: Default is 1-Any (keep default for lab).
   - **Confidence level**: Default is Medium 75% (keep default).
6. Toggle **Quick summary** to **On** to verify your rule logic displays correctly.

> **💡 Tip**: The Quick summary shows a human-readable version of your conditions — useful for validating complex rules.

### Configure Actions (Optional for Lab)

Under **Actions**:

1. Expand **Restrict access or encrypt the content in Microsoft 365 locations**.
2. Select **Block users from receiving email, or accessing shared SharePoint, OneDrive, and Teams files, and Power BI items**.
3. Choose whether to block **Everyone** or **Only people outside your organization**.

> **💡 Lab Tip**: For initial testing, skip actions — just configure detection and notifications. Add blocking actions after validating detection works.

> **📝 Note**: When you enable the restrict access action, user overrides are automatically allowed.

---

## 🔧 Step 6: Configure User Notifications and Overrides

### Enable User Notifications

1. In the **User notifications** section, toggle to **On**.
2. Under **Policy tips**, optionally check **Customize the policy tip text** to add a custom message.
   - Example: `This Fabric item contains sensitive data (SSN or credit card numbers). Handle according to data protection policies.`

### Configure User Overrides (Optional)

1. In the **User overrides** section:
   - The checkbox **Allow users to override policy restrictions in Fabric (including Power BI), Exchange, SharePoint, OneDrive, and Teams** controls whether users can override.
   - **Require a business justification to override** — users must explain why they're overriding.
   - **Override the rule automatically if they report it as a false positive** — allows quick dismissal of false positives.

> **💡 Lab Tip**: For testing, leave overrides enabled so you can see how the override workflow functions.

---

## 🔧 Step 7: Configure Incident Reports (Admin Alerts)

### Set Alert Severity

1. In the **Incident reports** section, select a severity level from the **Use this severity level in admin alerts and reports** dropdown:
   - **Low**, **Medium**, or **High** — choose based on policy importance.
   - For this lab, select **Medium**.

### Enable Admin Alerts

1. Toggle **Send an alert to admins when a rule match occurs** to **On**.

2. Click **+ Add or remove users** to specify alert recipients:
   - Add your email address.
   - Add any compliance team members who should receive alerts.

3. Choose alert frequency:
   - **Send alert every time an activity matches the rule** — good for testing (select this).
   - **Send alert when the volume of matched activities reaches a threshold** — better for production (reduces noise). Configure thresholds if selected.

### Additional Options (Optional)

1. **If there's a match for this rule, stop processing additional DLP policies and rules** — leave unchecked unless you want this rule to be the only one evaluated.

2. **Evaluate rule per component** — leave **Off** for Fabric scenarios.

3. **Priority** — leave as **0** (default) unless you have multiple rules and need ordering.

### Save the Rule

1. Click **Save** to save the rule and return to the **Customize advanced DLP rules** page.

2. You should see your `Detect PII in Fabric Data` rule listed.

3. Click **Next** to continue to policy mode selection.

---

## 🔧 Step 8: Review and Activate Policy

### Policy Mode

1. On the **Policy mode** page, choose one of these options:

| Mode | Behavior | When to Use |
|------|----------|-------------|
| **Run the policy in simulation mode** | No actions enforced, events audited | Initial testing |
| **Run in simulation mode and show policy tips** | No actions, but users see policy tips | User awareness testing |
| **Turn it on right away** | Full enforcement | After validating detection |
| **Keep it off** | Policy inactive | While still configuring |

> **💡 Recommendation**: Start with **Run the policy in simulation mode** to validate detection, review matches in Activity Explorer, then switch to active mode.

### Review Settings

1. Review all policy settings on the **Review and finish** page.
2. Confirm:
   - Location: **Fabric and Power BI workspaces**
   - SITs: SSN, Credit Card Number
   - Notifications: Enabled with policy tips
   - Mode: Simulation (recommended for testing)

3. Click **Submit** to create the policy.

### Wait for Policy Deployment

- DLP policies can take **1-24 hours** to fully deploy and start scanning.
- Initial scans of existing data occur when data changes trigger evaluation.

> **🎯 What's Next**: Continue to Lab 07 while your DLP policy deploys. By the time you complete Labs 07-08, sufficient time will have passed for DLP scans to complete. You'll validate DLP results in **Lab 09: Final Validation**.

---

## ✅ Validation Checklist

Before proceeding to Lab 07, verify:

### DLP Policy Configuration

- [ ] Created custom DLP policy in Microsoft Purview portal.
- [ ] Selected **Fabric and Power BI** as the location.
- [ ] Added SITs: SSN, Credit Card Number.
- [ ] Configured policy tips and admin alerts.
- [ ] Policy submitted (active or simulation mode).

> **📝 Note**: DLP results validation (policy tips, alerts, Activity Explorer) is covered in **Lab 09: Final Validation** after your policy has had time to deploy.

---

## ❌ Troubleshooting

### Cannot Access DLP in Purview Portal

**Symptom**: DLP option not visible or access denied at [purview.microsoft.com](https://purview.microsoft.com).

**Resolution**:

1. Verify you have one of these roles: **Compliance Administrator**, **Compliance Data Administrator**, **Information Protection Admin**, or **Security Administrator**.
2. Check your M365 E5 license (or E5 Compliance add-on) is active.
3. Contact your tenant administrator for role assignment.
4. Ensure you're signing in at [purview.microsoft.com](https://purview.microsoft.com), not the legacy compliance.microsoft.com URL.

### Fabric and Power BI Location Not Available

**Symptom**: Cannot select Fabric and Power BI as a DLP location.

**Resolution**:

1. Verify your tenant has DLP for Fabric enabled.
2. Check that your Fabric workspaces are on Fabric capacity (not shared capacity).
3. DLP for Fabric may need to be enabled by your Fabric administrator.

### No Policy Tips Appearing

**Symptom**: DLP policy is active but no policy tips on Fabric items.

**Resolution**:

1. **Wait longer** — policy deployment can take 1-24 hours.
2. **Trigger a data change** — DLP scans on data modification.
3. **Check policy scope** — ensure your workspace is included.
4. **Verify data contains SITs** — the sample data must have matching patterns.
5. **Check simulation mode** — if in simulation mode, policy tips may not show.

### Alerts Not Appearing

**Symptom**: No alerts in the DLP Alerts dashboard.

**Resolution**:

1. Verify **Incident reports** are enabled in the policy.
2. Check alert recipient email addresses.
3. Wait for policy propagation (up to 24 hours).
4. Check Activity Explorer for policy matches even if alerts haven't generated.

### DLP Not Scanning Lakehouse Tables

**Symptom**: Lakehouse exists but no DLP results.

**Resolution**:

1. Verify data is in **Delta format** (default for Lakehouse tables).
2. DLP does NOT scan DirectQuery or live connection sources.
3. Ensure data is imported, not linked via DirectQuery.
4. Check that Delta tables contain actual data rows.

---

## 📊 SIT Selection Reference

### Common SITs for Fabric Data

| SIT Category | Sensitive Info Types | Use Case |
|--------------|---------------------|----------|
| **Personal Identifiers** | SSN, Driver's License, Passport | HR, Customer PII |
| **Financial** | Credit Card, Bank Account, SWIFT | Financial services |
| **Health** | Health Insurance Claim Number | Healthcare |
| **Credentials** | Azure Storage Account Key, Passwords | Security |

### Confidence Levels

| Level | Percentage | When to Use |
|-------|------------|-------------|
| Low | 65% | Catch more matches, higher false positives |
| Medium | 75% | Balanced (recommended for testing) |
| High | 85% | Fewer matches, higher precision |

---

## 📚 Related Resources

- [DLP for Fabric and Power BI Overview](https://learn.microsoft.com/en-us/purview/dlp-powerbi-get-started)
- [Configure DLP Policy for Fabric](https://learn.microsoft.com/en-us/fabric/governance/data-loss-prevention-configure)
- [Create and Deploy DLP Policies](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
- [Respond to DLP Violations in Fabric](https://learn.microsoft.com/en-us/fabric/governance/data-loss-prevention-respond)
- [Monitor DLP Policy Matches](https://learn.microsoft.com/en-us/fabric/governance/data-loss-prevention-monitor)
- [Sensitive Information Types Reference](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-entity-definitions)

---

## ➡️ Next Steps

Your DLP policy is now deploying in the background. Choose your path:

**[Lab 07: Data Map and Asset Discovery](../07-Data-Map-Asset-Discovery/)** ⭐ Recommended

> **🎯 Continue Configuration**: Proceed with Lab 07 to configure Data Map and Lineage while your DLP policy deploys. By the time you complete Labs 07-08, your policy will have had time to scan your data.

**[Lab 09: Final Validation](../09-Final-Validation/)**

> **⏱️ Validate DLP Now**: If you've already completed Labs 07-08 (or want to skip ahead), go directly to Lab 09 to validate your DLP policy results, including policy tips, alerts, and Activity Explorer.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. DLP for Fabric procedures were verified against Microsoft Purview documentation within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview DLP capabilities for Fabric while maintaining technical accuracy against official Microsoft documentation.*


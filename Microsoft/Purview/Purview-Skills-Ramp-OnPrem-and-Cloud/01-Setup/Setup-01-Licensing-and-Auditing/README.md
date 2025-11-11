# Setup-01: Microsoft 365 Licensing and Auditing

## 🎯 Lab Objectives

- Verify or activate Microsoft 365 E5 licensing required for Purview Information Protection.
- Enable Microsoft 365 auditing for Activity Explorer and DLP tracking.
- Prepare foundational M365 services for subsequent Purview labs.

## ⏱️ Estimated Duration

30-45 minutes

## 📋 Prerequisites

- Microsoft 365 tenant with Global Admin or Compliance Admin role.
- Ability to start trials or assign existing E5 licenses.
- Web browser access to Microsoft admin portals.

## ⚠️ Critical Timing Considerations

> **Enable Auditing Early**: Auditing activation can take **2-24 hours** to fully activate. By enabling it in this first setup lab, the audit system will be ready when you need it in later labs (OnPrem-04 DLP Enforcement and Reporting labs).
>
> **Historical Data**: Audit data is only collected from the point auditing is enabled forward. Historical activity before auditing is enabled will NOT be available in Activity Explorer.

## 🚀 Lab Steps

### Step 1: Verify or Activate Required Microsoft 365 Licensing

**If you already have Microsoft 365 E5 (standard or developer), skip to Step 2.**

> **💡 License Requirements for Purview Information Protection Scanner**: To complete these labs, you need a Microsoft 365 license that includes sensitivity labels and the Information Protection scanner. The following options provide these capabilities:
>
> - **Microsoft 365 E5** (standard subscription) - Includes all required Purview features
> - **Microsoft 365 E5 Compliance** (add-on license) - Adds Purview capabilities to E3 subscriptions
> - **Microsoft 365 E5 Developer** (developer trial) - Suitable alternative if available to you (not available to all users; requires Visual Studio subscription, Microsoft partner status, or Premier/Unified Support)
>
> For more information about licensing, see the [Microsoft 365 licensing guidance for security & compliance](https://learn.microsoft.com/en-us/office365/servicedescriptions/microsoft-365-service-descriptions/microsoft-365-tenantlevel-services-licensing-guidance/microsoft-365-security-compliance-licensing-guidance#microsoft-purview-information-protection-sensitivity-labeling).

Navigate to Microsoft 365 Admin Center:

- Open browser and go to [https://admin.microsoft.com](https://admin.microsoft.com).
- Sign in with Global Admin credentials.
- The admin center may display in **Simplified view** or **Dashboard view**.
- If using **Simplified view**: Select **Billing**, then select **Add more products**.
- If using **Dashboard view**: Go to **Billing** > **Purchase services** (some tenants may see **Marketplace** instead).

> **💡 Navigation Note**: Microsoft has introduced a Simplified view option in the M365 Admin Center. The steps below work for both views.

Search for Microsoft 365 license options:

- In the search box or product catalog, type **E5** or **Microsoft 365 E5**.
- You may see multiple options including:
  - **Microsoft 365 E5** (full suite - recommended if available)
  - **Microsoft 365 E5 Compliance** (add-on for organizations with existing E3 licenses)
- If you see **Microsoft 365 E5**, select that option (it includes all Compliance features).
- If you only see **Microsoft 365 E5 Compliance**, select that option (designed to add Purview capabilities to E3).
- Click **Details** button.

Start the trial:

- In the product details page, select the trial plan from the dropdown if available.
- Click **Start free trial** button.
- Review the trial terms (no credit card required, 25 licenses for 30 days).
- Click **Try now** or **Start free trial**.
- Click **Continue** to confirm.
- Wait 10-15 minutes for license provisioning to complete.

Verify and assign licenses:

- In the Admin Center, navigate to **Billing** > **Licenses** (or **Billing** > **Your products** depending on view).
- Confirm your Microsoft 365 E5 license appears with available licenses (either **Microsoft 365 E5** or **Microsoft 365 E5 Compliance**).
- Click on the license name to view details.
- Select **Assign licenses** or the **Assignments** tab.
- Add your admin account.
- Click **Save** or **Assign**.

> **💡 Tip**: Also assign a license to the scanner service account you'll create in Setup-03. If you're using Microsoft 365 E5 Developer trial, you have 25 user licenses available for the development tenant.

---

### Step 2: Enable Microsoft 365 Auditing

**Purpose**: Enable audit logging for Activity Explorer and DLP activity tracking used in later labs.

> **⚠️ Important - Enable Early**: Auditing should be enabled at the beginning of the lab series because:
>
> - Audit data is only collected from the point auditing is enabled forward
> - Auditing activation can take 2-24 hours to fully activate
> - Enabling it now prevents workflow disruption in OnPrem-04 (DLP Enforcement) and Reporting labs
> - Historical activity before auditing is enabled will NOT be available in Activity Explorer

**Verify Auditing Status:**

Navigate to Microsoft Purview portal:

- Open browser and go to [https://purview.microsoft.com](https://purview.microsoft.com).
- Sign in with your Global Admin or Compliance Admin credentials.
- Navigate to **Data loss prevention** (in left navigation).
- Select **Explorers** (in left submenu).
- Click **Activity explorer**.

Check for auditing banner:

- If you see a banner stating: *"To use this feature, turn on auditing so we can start recording user and admin activity in your organization"*, proceed to enable auditing.
- If you do NOT see the banner, auditing is already enabled - you're done with this lab!

**Enable Auditing (If Required):**

- In Activity Explorer, click **Turn on auditing** on the banner.
- This launches an activation wizard.
- After activation, you'll see: *"We're preparing the audit log. It can take up to 24 hours to fully record user and admin activity, but you might start seeing activity appear in a few hours."*
- Auditing activation is now in progress - continue with remaining setup labs.
- By the time you reach OnPrem-04 (DLP Enforcement) and Reporting labs, auditing should be fully activated.

**Verify Auditing via PowerShell (Optional - Recommended):**

To confirm auditing is actually enabled at the backend level, use PowerShell verification:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\01-Setup\Setup-01-Licensing-and-Auditing"
.\Verify-AuditingStatus.ps1
```

This script connects to Exchange Online PowerShell and verifies the unified audit log ingestion status.

Expected output: `UnifiedAuditLogIngestionEnabled : True`

> **⚠️ Important PowerShell Note**: You must use **Exchange Online PowerShell** for accurate auditing status verification. If you use Security & Compliance PowerShell, the `Get-AdminAuditLogConfig` cmdlet will always show `False` even when auditing is enabled. This is a known behavior documented by Microsoft.

**Alternative: Enable Auditing via PowerShell:**

If you prefer to enable auditing using PowerShell instead of the portal:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\01-Setup\Setup-01-Licensing-and-Auditing"
.\Enable-AuditingConfiguration.ps1
```

This script enables unified audit log ingestion and verifies the configuration.

> **💡 Timing Strategy**: Enabling auditing early in Setup-01 ensures the audit system is ready by the time you need it in later labs. The 2-24 hour activation window runs in the background while you complete VM setup, scanner installation, and other foundational tasks.
>
> **✅ Validation**: You can verify auditing status anytime by returning to Activity Explorer or running the PowerShell verification command. The Activity Explorer banner behavior may vary, but the PowerShell command provides definitive confirmation of auditing status.

---

## ✅ Validation Checklist

Before proceeding to Setup-02, verify:

### Microsoft 365 Licensing

- [ ] Microsoft 365 E5 (or E5 Compliance) trial activated OR existing license verified
- [ ] License assigned to your admin account
- [ ] License appears in **Billing** > **Licenses** with available seats
- [ ] License activation completed (10-15 minute wait if starting trial)

### Auditing Configuration

- [ ] Navigated to Purview portal successfully
- [ ] Located Activity Explorer under **Data loss prevention** > **Explorers**
- [ ] Auditing enabled (banner clicked and activation started) OR verified already enabled
- [ ] **PowerShell verification completed**: `Get-AdminAuditLogConfig` shows `UnifiedAuditLogIngestionEnabled : True`
- [ ] Understand 2-24 hour activation timeline for full audit data availability

## 🔍 Troubleshooting

### Cannot find Microsoft 365 E5 or E5 Compliance licenses

**Symptoms**: License not appearing in purchase/trial options

**Solutions**:

- Verify you're signed in with Global Admin role.
- Check if trial already used: Each tenant can only use the same trial type once.
- Try from different browser (clear cache).
- Look for **Microsoft 365 E5** (standard) which includes all Compliance features.
- If you have access to Microsoft 365 Developer Program, use **Microsoft 365 E5 Developer** subscription.
- Alternative: Contact Microsoft support or use existing E5 license if available.

### License trial not activating

**Symptoms**: Trial started but licenses not showing, or cannot assign licenses

**Solutions**:

- Wait 15-30 minutes for license propagation after activation.
- Verify tenant is eligible: Some tenant types may have restrictions.
- Check account has Global Admin role.
- Refresh browser and re-check **Billing** > **Licenses**.
- Sign out and sign back in to refresh admin center session.

### Auditing banner not appearing

**Symptoms**: No auditing banner in Activity Explorer

**Solutions**:

- Auditing may already be enabled - this is good news!
- Verify you're in the correct location: **Data loss prevention** > **Explorers** > **Activity explorer**.
- Check if another admin already enabled auditing.
- Try from different browser or incognito mode.
- Sign out and sign back in to refresh portal session.

### Cannot access Purview portal

**Symptoms**: Access denied or portal not loading

**Solutions**:

- Verify you have Global Admin or Compliance Admin role.
- Ensure Microsoft 365 E5 license is assigned to your account.
- Wait 10-15 minutes if you just assigned the license.
- Clear browser cache or try incognito mode.
- Use Microsoft Edge or Chrome (recommended browsers).

## ⏭️ Next Steps

Licensing and auditing setup complete! You now have:

- ✅ Microsoft 365 E5 licensing activated and assigned.
- ✅ Auditing enabled and activation in progress (2-24 hour background process).
- ✅ Foundation M365 services ready for Purview deployment.

Proceed to **[Setup-02: Azure Infrastructure Deployment](../Setup-02-Azure-Infrastructure/README.md)** to deploy the Azure VM, SQL Server, file shares, and storage components needed for the scanner lab environment.

## 📚 Reference Documentation

- [Microsoft 365 licensing guidance for security & compliance](https://learn.microsoft.com/en-us/office365/servicedescriptions/microsoft-365-service-descriptions/microsoft-365-tenantlevel-services-licensing-guidance/microsoft-365-security-compliance-licensing-guidance)
- [Turn auditing on or off](https://learn.microsoft.com/en-us/purview/audit-log-enable-disable)
- [Search the audit log in the Microsoft Purview portal](https://learn.microsoft.com/en-us/purview/audit-new-search)
- [Activity Explorer overview](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft 365 licensing and auditing configuration while maintaining technical accuracy for Microsoft Purview deployment scenarios.*

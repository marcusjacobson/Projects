# Cloud-02: Retention Labels Configuration

## 🎯 Lab Objectives

- Create retention labels for data lifecycle management.
- Configure file plan descriptors for organizational categorization.
- Set retention periods with time-based deletion policies.
- Understand retention trigger events (creation, modification, labeled).
- Configure label settings for automatic deletion.
- Publish retention labels to SharePoint locations.

## ⏱️ Estimated Duration

45-60 minutes

## 📋 Prerequisites

- Cloud-01 completed (SharePoint site with sample documents).
- Global Admin or Compliance Administrator role.
- Microsoft 365 E5 Compliance licensing.
- Access to Microsoft Purview compliance portal.
- Understanding of data lifecycle management concepts.

## 📊 Retention Labels Overview

**What Are Retention Labels?**

Retention labels manage data lifecycle by:

- Defining how long content should be retained.
- Automatically deleting content after retention period expires.
- Triggering retention based on events (creation, modification, labeling).
- Providing compliance documentation for regulatory requirements.
- Enabling defensible deletion of obsolete data.

**Retention Trigger Events**:

- **When content was created**: Based on file creation date
- **When content was last modified**: Based on last save/edit date
- **When content was labeled**: Based on when retention label applied

**Use Cases**:

- Delete financial records after 3 years per Sarbanes-Oxley.
- Remove old project files to reduce storage costs.
- Compliance with data minimization regulations (GDPR).
- Automated cleanup of abandoned SharePoint content.

## 🚀 Lab Steps

### Step 1: Create Retention Labels

**Navigate to Purview Records Management:**

- Open browser and go to the **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com).
- Sign in with your **admin account**.
- Navigate to **Solutions** > **Records management** (or **Data lifecycle management**).
  - Select **Solutions** from the left navigation.
  - Click **Records management** or **Data lifecycle management**.
- Select **File plan** from the left menu.
- Click **+ Create a label** to create a new retention label.

> **💡 Portal Navigation**: Retention labels can be created in either **Records management** or **Data lifecycle management** sections - the functionality is identical. The steps below reflect the current portal as of October 2025.
>
> **Navigation paths:**
> 
> - **Records management**: `Solutions > Records management > File plan > + Create a label`
> - **Data lifecycle management**: `Solutions > Data lifecycle management > Microsoft 365 > Retention labels > Create a label`

**Name and Description:**

- **Name**: `Delete-After-3-Years`
- **Description for users**: `This file is subject to automatic deletion after 3 years of inactivity`
- **Description for admins**: `Auto-delete files not accessed or modified in 3+ years for compliance and storage optimization`
- Click **Next**.

---

### Step 2: Configure Retention Settings

**Define File Plan Descriptors (Optional):**

File plan descriptors help organize and categorize retention labels.

> **💡 Interface Note**: Each descriptor field has a **Choose** button on the right. Click **Choose** to either select from existing values or click **Create new** to add custom values.

- **Reference ID**: Sample data: `FIN-RET-003`
- **Function/department**: Sample data: `Finance`
- **Category**: Sample data: `Financial Records`
- **Sub-category**: Sample data: `Transaction Data`
- **Authority type**: Sample data: `Regulatory`
- **Provision/citation**: Sample data: `Sarbanes-Oxley Act of 2002`
- Click **Next**.

**Define Label Settings:**

On the **Define label settings** page, you'll choose one of three retention options:

- **Retain items forever or for a specific period**: Select this option for standard retention scenarios.
- **Enforce actions after a specific period**: Select this for delete-only scenarios without retention.
- **Just label items**: Select this if you want the label to only classify content without retention actions.

For this lab, select:

- **Retain items forever or for a specific period**.
- Click **Next**.

---

### Step 3: Define the Retention Period

**Configure Retention Duration:**

- **Retain items for**: Select **Custom** and configure for `3`  **years**

**Start Retention Based On:**

- Select **When items were last modified**.

> **📚 Retention Trigger Options**:
>
> - **When items were created**: Starts retention from file creation date
> - **When items were last modified**: Starts from last modification timestamp
> - **When items were labeled**: Starts when label is applied
> - **When an event occurs**: Event-based retention (advanced scenarios)
>
> **⚠️ Important: Last Access Time Not Supported**
>
> **Purview retention labels do NOT support "last access time" as a trigger**. This is a critical limitation for data remediation projects that need to identify files based on when they were last opened/accessed rather than when they were modified.
>
> **Why This Matters:**
>
> - A file might be modified once in 2020 but accessed frequently through 2025 (should be retained)
> - A file might be created in 2018 and never accessed again (should be deleted)
> - Last modified time doesn't reflect actual usage patterns
>
> **For access-time-based remediation**, you must use **PowerShell scripting** (covered in Lab 04 and Lab 05) instead of retention labels.

**Choose what happens during the retention period:**

You'll choose one of two actions:

- **Retain items even if users delete** - Items are preserved in their original location and remain accessible to users, but copies are stored in secure locations (Preservation Hold library for SharePoint/OneDrive, Recoverable Items folder for Exchange) to prevent permanent deletion during the retention period.
- **Mark items as a record** - Items are declared as records with restrictions on editing and deletion. Records cannot be permanently deleted by users and provide proof of regulatory compliance and legal defensibility.

For this lab choose **Retain items even if users delete**. Click **Next**.

**Choose What Happens After the Retention Period:**

You'll choose one of five actions:

- **Delete items automatically** - Items are permanently deleted when the retention period expires, with no manual review required.
- **Start a disposition review** - Designated reviewers receive notifications to manually approve or deny permanent deletion, ensuring human oversight for critical content.
- **Change the label** - Automatically apply a different retention label with new retention settings, enabling multi-stage retention workflows.
- **Run a Power Automate flow** - Trigger custom automated workflows for actions like sending notifications, moving items, or integrating with external systems.
- **Deactivate retention settings** - Remove retention restrictions while keeping the label applied for classification purposes only.

For this lab choose **Delete items automatically**. Click **Next**.

> **⚠️ Production Consideration**: Test deletion policies thoroughly before deploying to production data. Consider using "Start a disposition review" for critical data requiring human approval before deletion.

**Review Label Configuration:**

- Verify all settings are correct.
  - **Name**: Delete-After-3-Years.
  - **Description for users**: This file is subject to automatic deletion after 3 years of inactivity.
  - **Description for admins**: Auto-delete files not accessed or modified in 3+ years for compliance and storage optimization.
  - **Retention**: 3 years from last modified.
  - **Retention action**: Retain and delete.
  - **Based on**: Based on when it was last modified.
- Once all settings are confirmed, Click **Create label**.

**Label Creation Complete:**

After clicking **Create label**, the portal automatically launches the **"Publish labels so users can apply them to their content"** wizard. This is a separate workflow for creating a publish policy that makes the label available for manual application by users.

> **💡 Lab Strategy**: For this lab, we'll **skip the Publish wizard** and create an **Auto-Apply policy** instead. Auto-apply policies provide automated label application based on content conditions, which aligns better with our data governance scenario. You can always create a publish policy later if you need users to manually apply labels.

The Publish wizard that appears has 5 steps, but we'll cancel it and proceed to create an Auto-Apply policy in the next step.

---

### Step 4: Navigate Through or Skip the Publish Labels Wizard

After creating the retention label, the **Publish labels** wizard automatically appears. Since we want to create an **Auto-Apply policy** instead, we'll skip this wizard.

**Publish Labels Wizard Overview:**

The wizard contains 5 steps:

1. **Choose labels to publish** - Select which labels to make available for manual application
2. **Administrative Units** - Scope the policy to specific administrative units (or use Full directory)
3. **Scope** - Choose Static or Adaptive policy scope, then select locations (SharePoint sites, OneDrive accounts, Exchange mailboxes, Microsoft 365 Groups)
4. **Name your policy** - Provide a name and description for the publish policy
5. **Finish** - Review and create the policy

**For This Lab - Skip/Cancel the Wizard:**

- Click **Cancel** to close the Publish labels wizard. Click **Yes** to confirm.
- This returns you to the **File plan** page where your newly created label appears. You will need to refresh the list to see the newly created plan.

> **💡 Alternative Workflow**: If you want users to manually apply retention labels in Outlook, SharePoint, or OneDrive, you would complete this Publish wizard instead. Published labels appear in the **Apply label** menu in Microsoft 365 apps. However, for automated data governance (our lab focus), Auto-Apply policies are more effective.
>
> **📚 When to Use Publish vs. Auto-Apply**:
>
> - **Publish labels** - Best when users need flexibility to classify their own content (user-driven classification)
> - **Auto-apply labels** - Best for consistent, automated classification based on content types or conditions (system-driven classification)
> - **Both** - You can use both approaches with the same retention label for hybrid scenarios

After canceling the wizard, proceed to the next step to create an Auto-Apply policy.

---

## ✅ Validation Checklist

Before proceeding to Cloud-03 (Auto-Apply Policies), verify:

### Retention Label Created

- [ ] Label name: "Delete-After-3-Years"
- [ ] Description for users and admins configured
- [ ] File plan descriptors completed (optional but recommended)
- [ ] Label visible in Purview portal > Data lifecycle management > Retention labels

### Retention Settings Configured

- [ ] Retention period: 3 years
- [ ] Retention trigger: "When items were last modified" or "When items were labeled"
- [ ] Action after retention: "Delete items automatically"
- [ ] Label settings configured correctly (retain items, delete automatically)

### Publish Labels Wizard

- [ ] Publish Labels wizard navigated successfully
- [ ] Decision made to skip publishing (clicked Cancel)
- [ ] Understood that label will be applied via auto-apply policy in Cloud-03
- [ ] No errors encountered during label creation process

## 💡 Retention Label Best Practices

**For Lab Environment**:

- Start with conservative retention periods (3 years is safe for testing).
- Use "When items were labeled" trigger for predictable testing.
- Test manual label application before enabling auto-apply.
- Use descriptive label names that indicate retention period.

**For Production Deployments**:

- Align retention periods with legal and regulatory requirements.
- Document file plan descriptors for audit trails.
- Test in pilot SharePoint site before organization-wide rollout.
- Enable disposition review for high-value content before deletion.
- Implement change management communication for end users.

## ⏭️ Next Steps

Retention labels configured! You now have:

- ✅ Retention label created with 3-year deletion policy.
- ✅ File plan descriptors documented for compliance.
- ✅ Retention settings configured for automatic deletion.
- ✅ Label policy published to SharePoint locations.
- ✅ Foundation ready for auto-apply policies.

**Important Wait Period**: Label policies can take **15-30 minutes to propagate** to SharePoint sites. Manual label application will be available after this period.

Proceed to **[Cloud-03: Auto-Apply Policies](../Cloud-03-Auto-Apply-Policies/README.md)** to configure automatic retention label application based on sensitive information types (credit cards, SSNs).

> **⚠️ Critical Timing**: Cloud-03 includes an **up-to-7-day wait period** for auto-apply policy processing. Plan your lab schedule accordingly.

## 📚 Reference Documentation

- [Retention labels overview](https://learn.microsoft.com/en-us/purview/retention)
- [Create retention labels](https://learn.microsoft.com/en-us/purview/create-retention-labels-data-lifecycle-management)
- [File plan descriptors](https://learn.microsoft.com/en-us/purview/file-plan-manager)
- [Retention policies and labels](https://learn.microsoft.com/en-us/purview/retention-policies-retention-labels)

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of retention label configuration while maintaining technical accuracy for data lifecycle management scenarios.*

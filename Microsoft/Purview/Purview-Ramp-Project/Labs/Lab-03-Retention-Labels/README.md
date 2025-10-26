# Lab 03: Retention Labels & Data Lifecycle Management

## 📋 Overview

**Duration**: 2-3 hours

**Objective**: Create and configure retention labels to manage data lifecycle, implement auto-apply policies for automated label application, and understand the capabilities and limitations of retention labels for on-premises repositories.

**What You'll Learn:**

- Create retention labels for data lifecycle management
- Configure retention settings for time-based policies
- Implement auto-apply policies based on conditions
- Understand SharePoint vs. on-premises retention capabilities
- Test retention label application and validation

**Prerequisites from Lab 02:**

- ✅ Information Protection Scanner operational with DLP enabled
- ✅ Sample data in SharePoint or ability to create test site
- ✅ Microsoft 365 E5 Compliance trial activated
- ✅ Understanding of sensitive information types from Labs 01-02

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

1. Create retention labels with time-based deletion policies
2. Understand retention trigger events (creation, modification, last access)
3. Configure auto-apply policies based on sensitive information types
4. Implement retention labels in SharePoint Online
5. Understand limitations of retention labels for on-premises file shares
6. Validate retention label application and policy effectiveness
7. Align retention strategies with real-world data remediation requirements

---

## ⚠️ Important Limitation Notice

> **🚨 Critical Information**: Auto-apply retention labels currently work in **SharePoint Online** and **OneDrive for Business**, but **NOT on-premises file shares** scanned by the Information Protection Scanner.
>
> For on-premises file remediation:
>
> - Manual label application may be possible through scanner (check current capabilities)
> - PowerShell scripting for bulk file operations is recommended
> - Cloud migration to SharePoint enables full retention capabilities
>
> **This lab demonstrates retention labels in SharePoint** to show the technology, even though it doesn't directly apply to the on-premises scanner scenario from Labs 01-02.

---

## 📖 Step-by-Step Instructions

### Step 1: Create Retention Labels

**Navigate to Purview Records Management:**

- Open browser and go to the **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com)
- Sign in with your **admin account**
- Navigate to **Solutions** > **Records management** (or **Data lifecycle management**)
  - Select **Solutions** from the left navigation
  - Click **Records management** or **Data lifecycle management**
- Select **File plan** from the left menu
- Click **+ Create a label** to create a new retention label

> **💡 Portal Navigation**: Retention labels can be created in either **Records management** or **Data lifecycle management** sections - the functionality is identical. The steps below reflect the current portal as of October 2025.
>
> **Navigation paths:**
> - **Records management**: `Solutions > Records management > File plan > + Create a label`
> - **Data lifecycle management**: `Solutions > Data lifecycle management > Microsoft 365 > Retention labels > Create a label`

**Name and Description:**

- **Name**: `Delete-After-3-Years`
- **Description for users**: `This file is subject to automatic deletion after 3 years of inactivity`
- **Description for admins**: `Auto-delete files not accessed or modified in 3+ years for compliance and storage optimization`
- Click **Next**

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
- Click **Next**

**Define Label Settings:**

On the **Define label settings** page, you'll choose one of three retention options:

- **Retain items forever or for a specific period**: Select this option for standard retention scenarios.
- **Enforce actions after a specific period**: Select this for delete-only scenarios without retention.
- **Just label items**: Select this if you want the label to only classify content without retention actions.

For this lab, select:

- **Retain items forever or for a specific period**
- Click **Next**

---

### Step 3: Define the Retention Period

**Configure Retention Duration:**

- **Retain items for**: Select **Custom** and configure for `3`  **years**

**Start Retention Based On:**

- Select **When items were last modified**

> **📚 Retention Trigger Options**:
>
> - **When items were created**: Starts retention from file creation date
> - **When items were last modified**: Starts from last modification timestamp
> - **When items were labeled**: Starts when label is applied
> - **When an event occurs**: Event-based retention (advanced scenarios)

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

- Verify all settings are correct
  - **Name**: Delete-After-3-Years
  - **Description for users**: This file is subject to automatic deletion after 3 years of inactivity
  - **Description for admins**: Auto-delete files not accessed or modified in 3+ years for compliance and storage optimization
  - **Retention**: 3 years from last modified
  - **Retention action**: Retain and delete
  - **Based on**: Based on when it was last modified
- Once all settings are confirmed, Click **Create label**

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

### Step 5: Create Auto-Apply Policy for Retention Labels

Auto-apply policies automatically apply retention labels to content based on conditions like sensitive information types or keywords.

**Navigate to Label Policies:**

- Still in Purview Portal > **Records management** (or **Data lifecycle management**)
- Expand the **Policies** menu and then select **Label policies**
- Click **Auto-apply a label** to start the wizard

> **💡 Wizard Overview**: The Auto-apply wizard has 10 steps: Name, Choose info to label, Policy template selection (if applicable), Define classification groups and sensitive info types, Assign admin units, Scope type, Locations, Label selection, Mode, and Review/Finish. The exact flow varies based on condition type and template selections.

---

#### Wizard Step 1: Name Your Auto-Labeling Policy

- **Name**: `Auto-Delete-Old-Sensitive-Files`
- **Description**: `Automatically apply 3-year deletion label to files containing sensitive data`
- Click **Next**

---

#### Wizard Step 2: Choose the Type of Content You Want to Apply This Label To

Select one of the available condition types:

- Apply label to content that contains sensitive info
- Apply label to content that contains specific words or phrase, or properties
- Apply label to content that matches a trainable classifier
- Apply label to cloud attachments and links shared in Exchange, Teams, Viva Engage and Copilot

For this lab, choose **Apply label to content that contains sensitive info**. Click **Next**.

---

#### Wizard Step 3: Choose Policy Template or Custom Policy (Conditional)

This step appears only if you selected "sensitive info types" in Step 2.

**Content that contains sensitive info:**

You'll see options to search or browse for pre-configured policy templates organized by regulation category (Financial, Medical and health, Privacy) or create a custom policy.

**For This Lab - Use Custom Policy:**

- Select **Custom** > **Custom policy**, This allows you to manually select specific sensitive info types (Credit Card, SSN)
- Click **Next**

> **💡 Template vs. Custom**:
>
> - **Templates**: Pre-configured bundles of sensitive info types for specific regulations (e.g., "U.S. Financial Data" includes Credit Card, Bank Account, Tax ID)
> - **Custom policy**: Manually select specific sensitive info types for targeted control
> - Templates are useful for compliance with specific regulations; custom policies offer precision
>
> <details>
> <summary>📚 Click to expand: Example Template Categories</summary>
>
> **Financial Templates:**
>
> - U.S. Financial Data: Credit Card Number, U.S. Bank Account Number, ABA Routing Number
> - GLBA (Gramm-Leach-Bliley Act)
> - PCI-DSS (Payment Card Industry Data Security Standard)
>
> **Privacy Templates:**
>
> - U.S. Personally Identifiable Information (PII) Data: SSN, Driver's License, Passport Number
> - GDPR (General Data Protection Regulation)
> - Australia Privacy Act
>
> **Medical and Health Templates:**
>
> - U.S. Health Insurance Act (HIPAA): Medical terms, drug names, patient identifiers
> - U.K. Medical Data
> </details>

---

#### Wizard Step 4: Define Content That Contains Sensitive Info

After selecting **Custom policy**, you'll see the classification group configuration interface.

**Classification Groups Overview:**

This screen allows you to create one or more classification groups. Each group is a logical container for sensitive information types that work together to identify content.

**Options on This Screen:**

- **Use an existing classification group** - Select from previously created groups (if any exist)
- **Create group** - Create a new classification group with custom sensitive info types

**For This Lab - Create a New Classification Group:**

Since no classification groups exist yet in your tenant, you'll create your first group.

**Create Group:**

- Click **Create group**
- **Group name**: Enter a descriptive name such as `Financial and Identity Data`
- **Group operator**: Select how multiple sensitive info types within this group should relate:
  - **Any of these** - Content matches if it contains ANY of the selected sensitive info types (OR logic)
  - **All of these** - Content matches only if it contains ALL of the selected sensitive info types (AND logic)

**For This Lab:**

- **Group name**: `Financial and Identity Data`
- **Group operator**: Select **Any of these**
  - This means files will be labeled if they contain Credit Card Number OR SSN
  - More flexible for real-world scenarios where files may contain different types of sensitive data

> **💡 Group Operator Guidance**:
>
> - **Any of these (OR)**: Best for broad coverage - labels content if it contains at least one sensitive info type. Recommended for most scenarios.
> - **All of these (AND)**: Strict matching - requires ALL sensitive info types to be present in the same file. Use when multiple data types together indicate higher sensitivity.
> 
> **📚 Multiple Groups**: You can create multiple classification groups on this screen with different operators. The policy will then evaluate all groups together. For this lab, one group is sufficient.

**Add Sensitive Information Types to the Group:**

After configuring the group name and operator, you'll add specific sensitive information types to this group.

- Click **Add** (under the Sensitive info types section)
- In the **Add sensitive info types** flyout panel, search for and select:
  - **Credit Card Number**
  - **U.S. Social Security Number (SSN)**
- Click **Add** to confirm selections

**Configure Confidence Level and Instance Count:**

After adding the sensitive info types, you'll see them listed with configuration options:

**For Credit Card Number:**

- **Confidence level**: Select **Medium confidence** (recommended for balance between accuracy and coverage)
  - Low confidence: More matches, higher false positives
  - Medium confidence: Balanced approach (recommended)
  - High confidence: Fewer matches, higher accuracy
- **Instance count**:
  - **From**: `1`
  - **To**: `Any`
  - This means the policy will match if 1 or more credit card numbers are detected

**For U.S. Social Security Number (SSN):**

- **Confidence level**: Select **Medium confidence**
- **Instance count**:
  - **From**: `1`
  - **To**: `Any`

> **💡 Confidence Level Guidance**: Higher confidence levels require more supporting evidence (keywords, formatting, context) around the detected pattern. Medium confidence provides a good balance for most scenarios. Start with medium and adjust based on simulation results.
>
> **📚 Instance Count**: This defines how many unique instances of the sensitive info type must be present. Setting "From: 1" means even a single occurrence will trigger the policy. Adjust based on your risk tolerance and data patterns.

**Review Classification Group:**

- Verify your group configuration:
  - **Group name**: Financial and Identity Data
  - **Group operator**: Any of these
  - **Sensitive info types**: Credit Card Number (Medium, 1-Any), U.S. Social Security Number (Medium, 1-Any)
- Click **Next** to continue

> **💡 Lab Recommendation**: Using sensitive info types aligns with the remediation scenario from the consultancy project and enables targeted retention based on data classification.

---

#### Wizard Step 5: Assign Admin Units

- Keep the default: **Full directory**
- Click **Next**

> **📚 Administrative Units**: These allow scoping policies to specific organizational units. For this lab, we use the full directory to include all locations.

---

#### Wizard Step 6: Choose the Type of Retention Policy to Create (Scope)

Select policy scope type:

- **Static**: Policy applies to all specified locations or specific included/excluded locations
- **Adaptive**: Policy uses dynamic queries to target users, groups, or sites (requires pre-configured adaptive scopes)

For this lab:

- Select **Static**
- Click **Next**

> **📚 Adaptive vs. Static Scopes**:
>
> - **Static scopes**: Fixed locations (all sites, specific sites, all users, specific users)
> - **Adaptive scopes**: Dynamic membership based on queries (e.g., all users in Finance department, all sites with specific tags)
> - Adaptive scopes require pre-configuration before policy creation

---

#### Wizard Step 7: Choose Locations to Apply the Policy

**Select SharePoint Sites:**

- **Status**: Ensure **Exchange mailboxes** is **OFF** (not needed for this lab)
- **Status**: Turn **ON** for **SharePoint classic and communication sites**
- **Status**: Ensure **OneDrive accounts** is **OFF** (not needed for this lab)
- **Status**: Ensure **Microsoft 365 Groups** is **OFF** (not needed for this lab)

**Configure SharePoint Sites:**

- Leave **SharePoint classic and communication sites** set to **All sites** (default)
- This will apply the policy to all current and future SharePoint sites in your tenant
- The test site you'll create in Step 7 will automatically be included

> **💡 Lab Approach**: Using "All sites" simplifies the lab workflow and ensures the policy will automatically apply to the test SharePoint site when you create it later. In production environments, you would typically scope policies to specific sites or use adaptive scopes for more targeted deployment.

---

#### Wizard Step 8: Choose a Label to Auto-Apply

- Click **+ Add label**
- Select **Delete-After-3-Years** and click **Add**.
- Review label details:
  - **Retention settings**: 3 years keep + delete
  - **Is record**: No
  - **Is regulatory**: No
- Click **Next**

---

#### Wizard Step 9: Decide Whether to Test or Run Your Policy (Mode)

**Policy Mode Options:**

**Test the policy before running it** (Recommended)

- Preview which files would be labeled without actually applying labels
- Simulation results appear within 2-7 days
- Review results, refine policy, then turn on
- Best for: Complex policies, testing conditions, gradual deployment

**Turn on policy** (Immediate deployment)

- Labels will be applied automatically to matching content within 7 days
- No simulation phase
- Best for: Policies you've already tested or simple scenarios

For this lab:

- Select **Test the policy before running it**
- This allows you to see which files match without making changes
- Click **Next**

> **💡 Simulation Mode Benefits**:
> 
> - **Safe testing**: See what would happen without making actual changes
> - **Refinement**: Adjust sensitive info types, keywords, or locations based on results
> - **Validation**: Confirm policy matches expected content before deployment
> - **Gradual rollout**: Start with small scope, expand after validating
>
> **⏳ Processing Time**: Simulation typically completes within 1-2 days depending on content volume. You'll receive an email notification when simulation completes.

---

#### Wizard Step 10: Review and Finish

**Review All Policy Settings:**

- **Policy name**: Auto-Delete-Old-Sensitive-Files
- **Policy description**: Automatically apply 3-year deletion label to files containing sensitive data
- **Info to label**: Apply label to content that contains sensitive info
- **Locations to apply the policy**: SharePoint classic and communication sites (All Sites)
- **Label**: Delete-After-3-Years (3 years retention, delete automatically)
- **Mode**: Simulation mode

**Submit Policy:**

- Verify all settings are correct
- Click **Submit** to create the policy
- Policy creation confirmation appears
- Click **Done**

**Policy Status:**

- Return to **Label policies** page and click **Refresh** to see the new policy
- Your new policy appears with **Status**: **In simulation***
- Click on the policy name to view details and processing status

> **✅ Success Indicator**: Policy appears in Label policies list with "In simulation" status and begins processing within minutes. Simulation results typically available within 1-2 days.

---

### Step 6: Monitor Simulation Results (Optional but Recommended)

If you selected simulation mode, you can monitor the simulation progress and view results.

**Check Simulation Status:**

- Navigate to **Data lifecycle management** > **Label policies**
- Locate your policy: **Auto-Delete-Old-Sensitive-Files**
- **Status** column shows: **In simulation** (processing) or **Completed (in simulation)**
- Click on the policy name to view details

**View Simulation Results:**

After simulation completes (typically 1-2 days):

- Click **View simulation** from the policy details pane
- Review matching items:
  - **Number of items**: Count of files that match the conditions
  - **Locations**: Distribution across SharePoint sites
  - **File samples**: Preview of specific files that would be labeled
- **Sample details**: Click on samples to see file names, locations, and why they matched

**Refine Policy Based on Results:**

If simulation shows unexpected results:

- **Too many matches**: Adjust sensitive info types, increase confidence levels, or narrow locations
- **Too few matches**: Verify test files contain valid SIT patterns, check confidence levels
- **Wrong files matched**: Review sensitive info type configuration, add exclusions
- Click **Edit policy** to make adjustments
- Restart simulation to validate changes

**Turn On Policy After Validation:**

Once simulation results meet expectations:

- Click **Turn on policy** from the policy details pane
- Policy status changes to **On** (active)
- Labels will be applied automatically to matching content within 7 days

---

### Step 7: Create Test SharePoint Site and Upload Files

To test retention label auto-apply, you need a SharePoint site with sample files.

**Find Your SharePoint URL:**

- Going to [office.com](https://office.com) and signing in. This page has been updated with **M365 Copilot** branding.
- Click the **Apps** in the left navigation panel
- Click **SharePoint** from the apps list- this will navigate to your SharePoint home page
- The URL in your browser's address bar shows your domain (e.g., `https://contoso.sharepoint.com`)

> **💡 Lab Tip**: Your SharePoint domain typically matches your organization's Microsoft 365 tenant name. For example, if your tenant is `contoso.onmicrosoft.com`, your SharePoint domain is usually `contoso.sharepoint.com`.

**Create Test SharePoint Site (if not exists):**

- Navigate to your SharePoint URL: `https://[yourtenant].sharepoint.com`
- Click the **home** icon in the left navigation bar
- Click **+ Create site**
- Select **Team site** or **Communication site**, and follow the wizard to select a template to use.
  - For simplicity, choose **Team Site** and the **Standard team template**
- **Site name**: `Purview Lab - Retention Testing`
- **Description**: `Test site for Purview weekend lab retention policies`
- Click **Next**
- For the **Privacy settings**, select **Private**
- Click **Next**
- Add your main Entra account and any other users you have.
- **Finish**

**Create Document Library:**

- In the new site, click **+ New** > **Document library**
- Click **Blank library**
- **Name**: `Sensitive Data Archive`
- **Description**: `Sample files with sensitive data for retention testing`
- Click **Create**

**Upload Sample Files with Sensitive Data:**

Create test files on your local machine or VM:

**File 1: OldCreditCardTransactions.txt**:

```text
Transaction Report - Archived Data

Customer: John Doe
Date: January 15, 2021
Credit Card: 4532-1234-5678-9010
Amount: $1,234.56

Customer: Jane Smith
Date: February 20, 2021
Credit Card: 5425-2334-4567-8901
Amount: $987.65
```

**File 2: EmployeeSSNArchive.xlsx** (or .txt):

```text
Employee ID,Name,SSN
EMP001,Michael Johnson,123-45-6789
EMP002,Sarah Williams,987-65-4321
EMP003,David Brown,456-78-9012
```

**Upload Files to SharePoint:**

- Navigate to your SharePoint **Sensitive Data Archive** library
- Click **Upload** > **Files**
- Select the 2 test files you created
- Click **Open** to upload

---

### Step 8: Understanding Manual vs. Auto-Apply Label Application

This lab focuses on **auto-apply policies** for automated, system-driven label application. As a result, you will not be able to manually apply the **Delete-After-3-Years** label in SharePoint during this lab.

**Why Manual Application Is Not Available:**

In Step 4, we intentionally **skipped the Publish Labels wizard** to focus on auto-apply policies. This means:

- The **Delete-After-3-Years** label was created but **NOT published**
- Only **published labels** appear in the **Apply label** dropdown in SharePoint
- Our **auto-apply policy** will automatically label matching files without user intervention

> **💡 Lab Strategy**: This lab demonstrates **system-driven classification** through auto-apply policies, which aligns with enterprise data governance scenarios where consistent, automated label application is preferred over manual user selection.

**Auto-Apply vs. Publish - Key Differences:**

| Aspect | Auto-Apply Policy (This Lab) | Publish Policy |
|--------|------------------------------|----------------|
| **Label availability** | Not visible to users in UI | Appears in "Apply label" dropdown |
| **Application method** | Automatic based on conditions | Manual user selection required |
| **Processing time** | 2-7 days for initial processing | Labels available within 1-7 days |
| **Use case** | Consistent, automated governance | User-driven classification |
| **Testing approach** | View simulation results | Apply label immediately to test files |

**How to View Auto-Apply Results:**

Since manual application is not available in this lab, you'll validate label application through:

**Step 1: Monitor Simulation Results (Recommended)**:

- Navigate to **Data lifecycle management** > **Label policies**
- Click on **Auto-Delete-Old-Sensitive-Files** policy
- Once simulation completes (1-2 days), click **View simulation results**
- Review which files would be labeled based on sensitive info type detection
- See count of matching items and file samples

**Step 2: Turn On Policy and Wait for Processing**:

- After validating simulation results, click **Turn on policy**
- Policy status changes from "In simulation" to "On"
- Labels will be applied automatically within 7 days
- Check file details pane in SharePoint to see applied labels

**Step 3: Verify Applied Labels in SharePoint**:

Once auto-apply processing completes:

- Navigate to **Sensitive Data Archive** library
- Select a file (checkbox next to file name)
- Click the **Details pane** icon in upper-right corner
- In the details pane, look for **Applied label** section
- You should see: **Delete-After-3-Years** with "Auto-applied" designation
- View retention period and calculated deletion date

> **⏳ Processing Timeline**: Auto-apply is NOT instantaneous. Files are labeled through a background process that can take 2-7 days. This is expected behavior for enterprise-scale automated classification.

> **📚 Optional Additional Activity - Manual Label Application with Publish Policy**:
>
> If you want to experiment with manual label application (outside this lab's scope), you can create a Publish policy:
>
> 1. Navigate to **Data lifecycle management** > **Policies** > **Label policies**
> 2. Click **Publish labels** and complete the 5-step wizard
> 3. Select **Delete-After-3-Years** label
> 4. Choose SharePoint locations
> 5. **Wait 1-7 days** for labels to publish (NOT immediate)
> 6. Labels will then appear in **Apply label** dropdown for manual selection in SharePoint
>
> **Real-World Note**: Organizations often use **both** auto-apply and publish policies together - auto-apply for consistent baseline governance, publish for user flexibility on edge cases.

---

## ✅ Validation Checklist

Complete the following validation steps to ensure successful lab completion:

### Retention Label Creation

- [ ] Retention label **Delete-After-3-Years** created
- [ ] Retention period set to 3 years
- [ ] Retention trigger set to "last modified"
- [ ] End of retention action set to "delete automatically"
- [ ] Label visible in File plan
- [ ] Publish Labels wizard skipped to focus on auto-apply

### Auto-Apply Policy Configuration

- [ ] Auto-apply policy **Auto-Delete-Old-Sensitive-Files** created
- [ ] Policy configured to apply **Delete-After-3-Years** label
- [ ] Classification group "Financial and Identity Data" created
- [ ] Conditions set for sensitive info types (Credit Card Number, U.S. SSN)
- [ ] Confidence levels set to Medium for both SITs
- [ ] Instance counts set to 1-Any for both SITs
- [ ] Locations set to SharePoint sites (All sites)
- [ ] Policy mode set to simulation mode

### SharePoint Testing

- [ ] Test SharePoint site created: "Purview Lab - Retention Testing"
- [ ] Document library **Sensitive Data Archive** created
- [ ] Sample files with sensitive data uploaded (2 files: Credit Card + SSN)
- [ ] Files contain valid, detectable SIT patterns

### Auto-Apply Policy Monitoring

- [ ] Auto-apply policy status shows "In simulation" or "Completed (in simulation)"
- [ ] Simulation results accessible in policy details (after 1-2 days)
- [ ] Results show matching files count
- [ ] Files with sensitive data correctly identified in simulation
- [ ] Policy ready to turn on after simulation validation

### Auto-Applied Label Verification (After Turning On Policy)

- [ ] Policy turned on after successful simulation
- [ ] Policy status changed to "On" (active)
- [ ] Waited appropriate time for auto-apply processing (2-7 days)
- [ ] Files in SharePoint show auto-applied labels in details pane
- [ ] Applied label shows "Delete-After-3-Years" with auto-applied designation
- [ ] Retention period and calculated deletion date visible in file properties

---

## 🔍 Troubleshooting Common Issues

### Issue: Auto-Apply Policy Not Processing

**Symptoms**: Policy shows "In simulation" or "Processing" for extended period with no results

**Possible Causes and Solutions**:

- **Normal Delay**: Auto-apply can take 2-7 days to complete initial processing - this is expected behavior
- **Verify Locations**: Check that SharePoint sites are correctly configured in policy (should be "All sites")
- **Check Policy Status**:
  - Navigate to **Data lifecycle management** > **Label policies**
  - Click on **Auto-Delete-Old-Sensitive-Files** policy name
  - Check **Last processed** timestamp and processing details
- **Content Volume**: Large volumes of content take longer to process

> **⏳ Expected Timeline**: Initial simulation typically completes within 1-2 days for small test sites. Wait at least 48 hours before troubleshooting.

---

### Issue: Simulation Shows No Matching Files

**Symptoms**: Simulation completes but shows 0 files matched or labeled

**Possible Causes and Solutions**:

- **Invalid SIT Patterns**: Verify file content contains valid, detectable patterns
  - Credit card numbers must be **Luhn-valid** (passes checksum validation)
  - SSNs must match proper format: `###-##-####`
  - Use test patterns from Step 7 that are known to work
- **File Format**: Ensure files are in supported formats (`.txt`, `.docx`, `.xlsx`, `.pdf`)
- **Confidence Level**: Medium confidence requires proper formatting - check that test data matches expected patterns
- **Policy Scope**: Verify test SharePoint site is included in policy locations ("All sites" should cover it)

**Test SIT Detection**:

Create a new test file with these known-valid patterns:

```text
Test File - SIT Detection Validation

Credit Card (Visa): 4532-1234-5678-9010
Credit Card (Mastercard): 5425-2334-4567-8901
Social Security Number: 123-45-6789
Social Security Number: 987-65-4321
```

Upload to SharePoint and wait for simulation to re-run.

---

### Issue: Cannot See Applied Labels After Turning On Policy

**Symptoms**: Policy shows "On" status but files in SharePoint don't show retention labels

**Possible Causes and Solutions**:

- **Processing Delay**: Auto-apply takes 2-7 days after turning on policy - labels are not applied instantly
- **Check Application Status**:
  - Select a file in SharePoint library
  - Click **Details pane** icon (upper-right corner)
  - Look for **Applied label** section
  - If not visible yet, continue waiting for background processing
- **Policy Errors**: Check policy details page for any error messages or warnings
- **Permissions**: Ensure the auto-apply service has access to the SharePoint site

> **⏳ Patience Required**: After turning on policy from simulation mode, allow up to 7 days for full label application across all matching files.

---

### Issue: Understanding On-Premises Limitations

**Symptoms**: Attempting to use retention labels with Information Protection Scanner for on-premises files

**Important Clarification**:

> **🚨 Expected Limitation**: Retention label auto-apply does NOT work for on-premises file shares scanned by Information Protection Scanner as of October 2025. This is not an error - it's a platform limitation.

**This Lab's Focus**: This lab demonstrates retention labels in **SharePoint Online** to show the technology. On-premises file remediation requires different approaches covered in Labs 04-05 (PowerShell scripting, File Server Resource Manager, cloud migration). See the Important Limitation Notice at the beginning of this lab for more details.

---

## 🎯 Key Learning Outcomes

After completing Lab 03, you have learned:

1. **Retention Label Creation**: Configuring time-based retention policies with automatic deletion actions

2. **Retention Triggers**: Understanding different retention period triggers (created, modified, labeled, events)

3. **Auto-Apply Policies**: Configuring conditions for automatic label application based on sensitive information types

4. **Auto-Apply vs Publish Policies**: Understanding the difference between system-driven auto-apply (2-7 day processing) and user-driven publish policies (1-7 day availability)

5. **Simulation Mode**: Testing auto-apply policies safely before activating automatic labeling on production content

6. **Classification Groups**: Organizing multiple SITs with logical operators (Any of these, All of these) for flexible policy conditions

7. **SharePoint Integration**: Implementing retention labels in SharePoint Online for cloud-based data lifecycle management

8. **Platform Limitations**: Understanding that auto-apply retention labels currently do not support on-premises file repositories scanned by Information Protection Scanner

9. **Workaround Strategies**: Identifying alternative approaches for on-premises file retention (PowerShell, migration, FSRM)

10. **Hybrid Strategy**: Designing data governance solutions that combine cloud-based retention (SharePoint) with scripted approaches for on-premises legacy data

### Real-World Application Considerations

Understanding retention labels in consultancy and enterprise contexts:

- **Cloud-First Advantage**: Retention labels work fully in SharePoint/OneDrive with automatic policy enforcement
- **On-Premises Challenges**: On-premises file shares require alternative approaches (PowerShell, FSRM, migration to cloud)
- **Cloud Migration Enabler**: Comprehensive data lifecycle management is a key benefit of SharePoint Online migration
- **Hybrid Approach**: Consultancy projects may need combined strategy - SharePoint for new/active data, PowerShell scripts for legacy on-premises data
- **Processing Expectations**: Auto-apply policies take 2-7 days for initial processing - plan implementation timelines accordingly
- **Simulation Best Practice**: Always test in simulation mode first to validate SIT detection and policy scope before activating

---

## 🚀 Next Steps

**Proceed to Lab 04**: Validation & Reporting

In the next lab, you will:

- Review comprehensive scanner reports from Labs 01-02
- Analyze Activity Explorer for DLP and discovery insights
- Explore Data Estate Insights dashboards
- Create stakeholder-ready remediation reports
- Compile findings for consultancy project presentation
- Execute cleanup procedures for all Azure resources

**Before starting Lab 04, ensure:**

- [ ] Retention label created successfully
- [ ] Auto-apply policy configured
- [ ] SharePoint testing completed (or understood limitations for on-prem)
- [ ] Understanding of retention label capabilities and limitations
- [ ] All validation checklist items marked complete

---

## 📚 Reference Documentation

- [Retention Labels Overview](https://learn.microsoft.com/en-us/purview/retention)
- [Create and Apply Retention Labels](https://learn.microsoft.com/en-us/purview/create-apply-retention-labels)
- [Auto-Apply Retention Labels](https://learn.microsoft.com/en-us/purview/apply-retention-labels-automatically)
- [Retention Label Limitations](https://learn.microsoft.com/en-us/purview/retention-limits)
- [Data Lifecycle Management](https://learn.microsoft.com/en-us/purview/data-lifecycle-management)
- [File Plan Manager](https://learn.microsoft.com/en-us/purview/file-plan-manager)

---

## 🤖 AI-Assisted Content Generation

This comprehensive lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview retention labels and data lifecycle management documentation as of October 2025, with explicit acknowledgment of platform limitations for on-premises repositories.

*AI tools were used to enhance productivity and ensure comprehensive coverage of retention label capabilities while maintaining technical accuracy, current portal navigation steps, and realistic expectations for on-premises vs. cloud-based data governance scenarios.*

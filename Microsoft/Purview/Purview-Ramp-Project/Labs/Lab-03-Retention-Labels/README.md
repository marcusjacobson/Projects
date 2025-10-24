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
> - Manual label application may be possible through scanner (check current capabilities)
> - PowerShell scripting for bulk file operations is recommended
> - Cloud migration to SharePoint enables full retention capabilities
>
> **This lab demonstrates retention labels in SharePoint** to show the technology, even though it doesn't directly apply to the on-premises scanner scenario from Labs 01-02.

---

## 📖 Step-by-Step Instructions

### Step 1: Create Retention Labels

**Navigate to Purview Records Management:**

- Open browser and go to: https://purview.microsoft.com
- Sign in with your **admin account**
- Select **Solutions** from the left navigation
- Click **Records management** (or **Data lifecycle management**)
- Select **File plan** from the left menu
- Click **+ Create a label**

> **💡 Note**: Retention labels can be created in either Records management or Data lifecycle management sections. The functionality is the same.

**Name and Description:**

- **Name**: `Delete-After-3-Years`
- **Description for admins**: `Auto-delete files not accessed or modified in 3+ years for compliance and storage optimization`
- **Description for users**: `This file is subject to automatic deletion after 3 years of inactivity`
- Click **Next**

---

### Step 2: Configure Retention Settings

**Define File Plan Descriptors (Optional):**

File plan descriptors help organize and categorize retention labels.

- **Function/department**: Leave blank or select appropriate option
- **Category**: Leave blank or create custom category
- **Sub-category**: Leave blank
- **Authority type**: Leave blank
- **Provision/citation**: Leave blank
- Click **Next**

**Configure Label Settings:**

- **Retention**: Toggle to **ON**
- **Retain items for**: Enter `3` and select **years**
- **Start retention based on**: **When items were last modified**

> **📚 Retention Trigger Options**:
> - **When items were created**: Starts retention from file creation date
> - **When items were last modified**: Starts from last modification timestamp
> - **When items were labeled**: Starts when label is applied
> - **When an event occurs**: Event-based retention (advanced scenarios)

> **⚠️ Important: Last Access Time Not Supported**
>
> **Purview retention labels do NOT support "last access time" as a trigger**. This is a critical limitation for data remediation projects that need to identify files based on when they were last opened/accessed rather than when they were modified.
>
> **Why This Matters:**
> - A file might be modified once in 2020 but accessed frequently through 2025 (should be retained)
> - A file might be created in 2018 and never accessed again (should be deleted)
> - Last modified time doesn't reflect actual usage patterns
>
> **For access-time-based remediation**, you must use **PowerShell scripting** (covered in Lab 04 and Lab 05) instead of retention labels.

**End of Retention Period Action:**

- **At the end of the retention period**: Select **Delete items automatically**

> **⚠️ Production Consideration**: Test deletion policies thoroughly before deploying to production data. Consider using "Start a disposition review" for critical data requiring human approval before deletion.

**Review Settings:**

- Retention period: 3 years
- Trigger: Last modified date
- Action: Automatic deletion
- Click **Next**

---

### Step 3: Review and Create Label

**Review Label Configuration:**

- Verify all settings are correct
- **Name**: Delete-After-3-Years
- **Retention**: 3 years from last modified
- **Action**: Delete automatically
- Click **Create label**

**Creation Confirmation:**

- Label created successfully message appears
- Click **Done**
- Label now appears in File plan list

---

### Step 4: Create Auto-Apply Policy for Retention Labels

Auto-apply policies automatically apply retention labels to content based on conditions like sensitive information types or keywords.

**Navigate to Label Policies:**

- Still in Purview Portal > **Records management** (or **Data lifecycle management**)
- Select **Label policies** from the left menu
- Click **Auto-apply a label**

**Choose Label to Auto-Apply:**

- **Name your auto-labeling policy**: `Auto-Delete-Old-Sensitive-Files`
- **Description**: `Automatically apply 3-year deletion label to files containing sensitive data`
- **Choose label to auto-apply**: Select **Delete-After-3-Years**
- Click **Next**

---

### Step 5: Configure Auto-Apply Conditions

You can auto-apply labels based on sensitive information types, keywords, or properties.

**Select Condition Type:**

Option A: **Apply label to content that contains sensitive info types** (Recommended for this lab)

- Select this option
- Click **Next**
- **Choose sensitive info types**: Click **+ Add**
- Search for and add:
  - **Credit Card Number**
  - **U.S. Social Security Number (SSN)**
  - **Email Address** (optional)
- Click **Add** to confirm selections
- Click **Next**

Option B: **Apply to all content in specific locations**

- Select this option if you want to label ALL files regardless of content
- This is useful for blanket retention policies
- Click **Next**

> **💡 Lab Recommendation**: Use Option A (sensitive info types) to align with the remediation scenario from the consultancy project.

---

### Step 6: Choose Locations for Auto-Apply

**Select SharePoint Sites:**

- **Status**: Turn ON for **SharePoint sites**
- **Status**: Turn ON for **OneDrive accounts** (optional)
- **Status**: Ensure **On-premises repositories** is OFF (not supported for auto-apply)

**Add Specific Sites:**

- Click **Choose sites** under SharePoint sites
- Click **+ Add sites**
- Search for and select your test SharePoint site
- Click **Add**
- Click **Done**

> **📚 Note**: In production, you might use "All sites" or specific site collections based on your data governance strategy.

**Review Locations:**

- Verify SharePoint sites are configured
- Click **Next**

---

### Step 7: Configure Auto-Apply Settings

**Policy Mode:**

- **Run policy in simulation mode first**: **Recommended** (selected)
- This allows you to preview which files would be labeled without actually applying labels
- Simulation results appear in Compliance Center after processing

**Automatic vs. Simulation:**

- **Simulation mode**: Shows what would happen, generates reports, no actual labeling
- **Turn on automatic labeling**: Applies labels automatically to matching content

For this lab:

- **Select simulation mode** to see results quickly
- You can switch to automatic mode later after reviewing simulation results

**Review and Submit:**

- Click **Next**
- Review all policy settings
- Click **Submit**
- Policy creation confirmation appears
- Click **Done**

---

### Step 8: Create Test SharePoint Site and Upload Files

To test retention label auto-apply, you need a SharePoint site with sample files.

**Create Test SharePoint Site (if not exists):**

- Navigate to: https://[yourtenant].sharepoint.com
- Click **+ Create site**
- Select **Team site** or **Communication site**
- **Site name**: `Purview Lab - Retention Testing`
- **Description**: `Test site for Purview weekend lab retention policies`
- **Privacy settings**: Private
- Click **Next** and **Finish**

**Create Document Library:**

- In the new site, click **+ New** > **Document library**
- **Name**: `Sensitive Data Archive`
- **Description**: `Sample files with sensitive data for retention testing`
- Click **Create**

**Upload Sample Files with Sensitive Data:**

Create test files on your local machine or VM:

**File 1: OldCreditCardTransactions.txt**

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

**File 2: EmployeeSSNArchive.xlsx** (or .txt)

```text
Employee ID,Name,SSN
EMP001,Michael Johnson,123-45-6789
EMP002,Sarah Williams,987-65-4321
EMP003,David Brown,456-78-9012
```

**File 3: CustomerEmailList.txt**

```text
Customer Email Directory

customer1@example.com
customer2@example.com
john.doe@contoso.com
jane.smith@fabrikam.com
```

**Upload Files to SharePoint:**

- Navigate to your SharePoint **Sensitive Data Archive** library
- Click **Upload** > **Files**
- Select the 3 test files you created
- Click **Open** to upload

**Set File Modification Dates (Optional):**

To simulate old files:

- In SharePoint, you cannot directly modify timestamps
- Files will be labeled based on current upload date
- For "old data" simulation, this lab focuses on the label configuration rather than actual age

---

### Step 9: Wait for Auto-Apply Policy Processing

**Processing Timeline:**

- **Simulation mode**: Results typically available within 2-7 days
- **Automatic mode**: Label application can take up to 7 days for full propagation
- **Lab consideration**: Simulation results may appear sooner (within hours to 1 day)

> **⏳ Important**: Retention label auto-apply is NOT instantaneous. This is a background process that runs periodically.

**Check Auto-Apply Policy Status:**

- Purview Portal > **Data lifecycle management** > **Label policies**
- Locate your policy: **Auto-Delete-Old-Sensitive-Files**
- **Status** column shows: **Processing** or **Completed (in simulation)**
- Click on the policy to see processing details

**Simulation Results:**

After processing completes:

- Policy details show **Simulation results**
- Click **View simulation results**
- See which files match the conditions
- Review how many items would be labeled

---

### Step 10: Manually Apply Retention Labels (Immediate Testing)

If you want to see labels in action immediately without waiting for auto-apply:

**In SharePoint Document Library:**

- Navigate to **Sensitive Data Archive** library
- Select a file (checkbox next to file name)
- Click **More options (...)** or right-click
- Select **More** > **Compliance details**
- **Labels**: Click **Apply label**
- Select **Delete-After-3-Years**
- Click **Save**

**Verify Label Application:**

- File now shows retention label in library view
- **Retention label** column displays: Delete-After-3-Years
- File properties show retention details

**Check Retention Details:**

- Click on a labeled file
- View **Details pane** on the right
- **Retention**: Shows label name and deletion date
- **Label applied**: Manual or Auto-apply

---

### Step 11: Introduction to SharePoint Content Search (eDiscovery Basics)

Content Search (eDiscovery) is a critical skill for finding and analyzing sensitive data in SharePoint and OneDrive before applying retention or remediation.

> **💡 Core Concept**: While retention labels automate lifecycle management, **Content Search** lets you manually discover, analyze, and prepare data for remediation - especially useful when you need precise control over what gets deleted.

**Navigate to Content Search:**

- Go to: https://purview.microsoft.com
- Select **Solutions** > **eDiscovery** > **Standard**
- Click **Searches** tab
- Click **+ New search**

**Create Search:**

- **Name**: `Lab-Old-Sensitive-Files-Search`
- **Description**: `Search for files older than 3 years containing sensitive data`
- Click **Next**

**Configure Locations:**

- **Exchange mailboxes**: OFF (not needed for this lab)
- **SharePoint sites**: ON
- Click **Choose sites**
- Click **+ Choose sites**
- Add your test SharePoint site: `Purview Lab - Retention Testing`
- Click **Done**
- Click **Next**

**Build Search Query:**

Content Search uses Keyword Query Language (KQL) for powerful filtering.

**Basic Query for Sensitive Data:**

```
(SensitiveType:"Credit Card Number" OR SensitiveType:"U.S. Social Security Number (SSN)")
```

**Add Date Filter (files older than specific date):**

```
(SensitiveType:"Credit Card Number" OR SensitiveType:"U.S. Social Security Number (SSN)") AND LastModifiedTime<2022-01-01
```

**Query Explanation:**
- `SensitiveType:` - Searches for files containing specific Sensitive Information Types
- `OR` - Matches either condition
- `LastModifiedTime<2022-01-01` - Files modified before January 1, 2022 (3+ years old)

**Enter Query:**

- In **Keywords** box, paste your query
- Click **Next**

**Review and Submit:**

- Review search configuration
- Click **Submit**
- Search begins processing

**View Search Results:**

- Wait for search to complete (usually 1-5 minutes for small datasets)
- Search status changes to **Completed**
- Click on the search name to view results
- **Items found**: Count of matching files
- **Preview results**: Click to see file list

**Analyze Results:**

- **Export results**: Download search results for offline analysis
- **Preview results**: See file names, locations, last modified dates
- **Refine query**: Adjust search criteria if needed

> **📚 Key Learning**: Content Search is essential when:
> - You need to verify what will be affected by retention policies
> - You want to analyze sensitive data distribution before remediation
> - You need precise control over file selection (eDiscovery export + scripted deletion)
> - Retention labels don't support your required trigger (e.g., last access time)

> **⚠️ Production Note**: In large environments, Content Search can take hours to complete. Use targeted site selections and date filters to improve performance.

---

## ✅ Validation Checklist

Complete the following validation steps to ensure successful lab completion:

### Retention Label Creation
- [ ] Retention label **Delete-After-3-Years** created
- [ ] Retention period set to 3 years
- [ ] Retention trigger set to "last modified"
- [ ] End of retention action set to "delete automatically"
- [ ] Label visible in File plan

### Auto-Apply Policy Configuration
- [ ] Auto-apply policy **Auto-Delete-Old-Sensitive-Files** created
- [ ] Policy configured to apply **Delete-After-3-Years** label
- [ ] Conditions set for sensitive info types (Credit Card, SSN)
- [ ] Locations set to SharePoint sites (specific test site)
- [ ] Policy mode set to simulation or automatic

### SharePoint Testing
- [ ] Test SharePoint site created
- [ ] Document library **Sensitive Data Archive** created
- [ ] Sample files with sensitive data uploaded (3 files minimum)
- [ ] Files contain detectable SITs (Credit Card, SSN, Email)

### Label Application Validation
- [ ] Manual label application successful (immediate testing)
- [ ] Labeled files show retention label in library view
- [ ] File properties display retention details and deletion date
- [ ] Auto-apply policy status shows "Processing" or "Completed"

### Simulation Results (if using simulation mode)

- [ ] Simulation results accessible in policy details
- [ ] Results show matching files count
- [ ] Files with sensitive data correctly identified
- [ ] Label would be applied to appropriate files

### Content Search (eDiscovery)

- [ ] Content search **Lab-Old-Sensitive-Files-Search** created
- [ ] Search configured for SharePoint test site
- [ ] KQL query includes SITs and date filter
- [ ] Search completed successfully
- [ ] Results preview shows matching files
- [ ] Export functionality tested (optional)

---

## 🔍 Troubleshooting Common Issues

### Issue: Retention Label Not Appearing in SharePoint

**Symptoms**: Labels created but not visible when trying to apply in SharePoint

**Solutions**:

- **Publication Delay**: Labels can take up to 24 hours to publish to SharePoint
- **Scope**: Verify label is published (not just created)
- **Permissions**: Ensure you have permissions to apply labels

```powershell
# Use PowerShell to check label publication status
Connect-IPPSSession

Get-RetentionCompliancePolicy | Where-Object {$_.Name -like "*Delete*"}
Get-RetentionComplianceRule | Where-Object {$_.Name -like "*Delete*"}
```

### Issue: Auto-Apply Policy Not Processing

**Symptoms**: Policy shows "Processing" for extended period with no results

**Solutions**:

- **Normal Delay**: Auto-apply can take 2-7 days to complete initial processing
- **Verify Locations**: Check that SharePoint sites are correctly configured in policy
- **Check Permissions**: Ensure service account has access to SharePoint sites
- **Content Volume**: Large volumes of content take longer to process

**Check Policy Status:**

- Purview Portal > Data lifecycle management > Label policies
- Click on policy name to view processing details
- Check **Last processed** timestamp

### Issue: Labels Not Matching Files with Sensitive Data

**Symptoms**: Files with credit cards/SSNs not being labeled by auto-apply policy

**Solutions**:

- **Sensitive Info Type Match**: Verify file content actually contains valid SIT patterns
- **Pattern Validation**: Credit card numbers must be Luhn-valid, SSNs must match pattern
- **File Format**: Ensure file formats are supported (txt, docx, xlsx, pdf)
- **Simulation Mode**: In simulation, files are identified but not actually labeled

**Test SIT Detection:**

Upload a test file with known valid patterns:

```text
Test File for SIT Detection

Valid Credit Card: 4532-1234-5678-9010
Valid SSN: 123-45-6789
Email: test@example.com
```

### Issue: Deletion Not Occurring After Retention Period

**Symptoms**: Files past retention period not automatically deleted

**Solutions**:

- **Timing**: Deletion processes run periodically (not immediate upon expiration)
- **Preservation Holds**: Check if files are subject to litigation hold or other preservation policies
- **Disposition Review**: If disposition review is required, deletion waits for approval
- **Recycle Bin**: Deleted files may be in SharePoint recycle bin

**Check Retention Status:**

- In SharePoint, view file **Compliance details**
- **Retention status**: Shows "Pending deletion" or "Deleted"
- **Deletion date**: Shows calculated deletion date based on trigger event

### Issue: Cannot Apply Labels to On-Premises Files

**Symptoms**: Attempting to use retention labels with scanner for on-premises files

**Solutions**:

> **Expected Limitation**: Retention label auto-apply does NOT work for on-premises file shares scanned by Information Protection Scanner as of October 2025.

**Workarounds for On-Premises:**

1. **Migrate to SharePoint**: Move files to SharePoint Online to enable full retention capabilities
2. **PowerShell Scripting**: Use custom scripts to identify and delete old files based on timestamps
3. **File Server Resource Manager (FSRM)**: Use Windows FSRM for on-premises file lifecycle management
4. **Azure Files**: Migrate to Azure Files and use Azure lifecycle management policies

**Example PowerShell for On-Premises Cleanup:**

```powershell
# Identify files older than 3 years based on last modified date
$cutoffDate = (Get-Date).AddYears(-3)
$sharePaths = @("\\vm-purview-scanner\Finance", "\\vm-purview-scanner\HR", "\\vm-purview-scanner\Projects")

foreach ($sharePath in $sharePaths) {
    Get-ChildItem -Path $sharePath -Recurse -File | 
        Where-Object {$_.LastWriteTime -lt $cutoffDate} |
        Select-Object FullName, LastWriteTime, @{N='Age(Days)';E={((Get-Date) - $_.LastWriteTime).Days}}
}

# For actual deletion (USE WITH CAUTION):
# Add -WhatIf parameter to test before actual deletion
# | Remove-Item -WhatIf
```

---

## 📊 Expected Results

After completing this lab successfully, you should observe:

### Retention Label Configuration
- Retention label **Delete-After-3-Years** created and published
- Label settings:
  - Retention period: 3 years from last modified date
  - Action: Delete automatically
  - Available in SharePoint for manual or auto-apply

### Auto-Apply Policy
- Policy **Auto-Delete-Old-Sensitive-Files** created
- Conditions: Files containing Credit Card Number, SSN
- Locations: Specific SharePoint test site
- Mode: Simulation (or automatic if selected)

### SharePoint Testing
- Test site created with document library
- 3+ sample files uploaded containing sensitive data
- Files contain:
  - Credit card numbers (Visa, Mastercard patterns)
  - Social Security Numbers
  - Email addresses

### Label Application
**Manual Application (Immediate):**
- Files manually labeled show retention label in library view
- File properties display:
  - Label name: Delete-After-3-Years
  - Label applied: Manual
  - Deletion date: 3 years from last modified date

**Auto-Apply (After Processing):**
- Simulation results show matching files (if in simulation mode)
- Automatic mode: Labels applied to files with sensitive data within 7 days
- Files with credit cards and SSNs automatically labeled

### Real-World Application
Understanding that:
- Retention labels work fully in SharePoint/OneDrive
- On-premises file shares require alternative approaches (PowerShell, FSRM, migration)
- Cloud migration enables comprehensive data lifecycle management
- Consultancy project may need hybrid approach: SharePoint for new data, scripting for legacy on-prem data

---

## 🎯 Key Learning Outcomes

After completing Lab 03, you have learned:

1. **Retention Label Creation**: Configuring time-based retention policies with automatic deletion actions

2. **Retention Triggers**: Understanding different retention period triggers (created, modified, labeled, events)

3. **Auto-Apply Policies**: Configuring conditions for automatic label application based on sensitive information types

4. **SharePoint Integration**: Implementing retention labels in SharePoint Online for cloud-based data lifecycle management

5. **Platform Limitations**: Understanding that auto-apply retention labels currently do not support on-premises file repositories scanned by Information Protection Scanner

6. **Workaround Strategies**: Identifying alternative approaches for on-premises file retention (PowerShell, migration, FSRM)

7. **Hybrid Strategy**: Designing data governance solutions that combine cloud-based retention (SharePoint) with scripted approaches for on-premises legacy data

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

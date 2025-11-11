# Lab 1: On-Demand Classification for SharePoint & OneDrive

## 🎯 Lab Objectives

- Understand Microsoft Purview's On-Demand Classification feature for SharePoint Online.
- Create custom Sensitive Information Types (SITs) for organizational data patterns.
- Manually trigger re-indexing of existing SharePoint content for classification.
- Run On-Demand Classification scans on specific SharePoint sites.
- Validate classification results using Content Explorer in the Purview portal.
- Understand classification timing, indexing behavior, and content processing.

## ⏱️ Estimated Duration

**Active Work**: 45-60 minutes  
**Wait Period**: 15-30 minutes for classification indexing to complete

## 📋 Prerequisites

**Microsoft 365 Licensing**:

- Microsoft 365 E5 OR Microsoft 365 E5 Compliance add-on required.
- Needed for On-Demand Classification and Content Explorer features.

**Azure AD Permissions**:

- Compliance Administrator OR Global Administrator role.
- Permission to create Sensitive Information Types.
- Access to SharePoint Online site administration.

**Technical Requirements**:

- PowerShell 5.1+ or PowerShell 7+ installed.
- ExchangeOnlineManagement module v3.0+ installed.
- Active Security & Compliance PowerShell connection.
- SharePoint Online site with test documents uploaded.

**Knowledge Prerequisites**:

- Basic understanding of Sensitive Information Types (SITs).
- Familiarity with SharePoint Online navigation.
- Knowledge of Microsoft Purview portal (compliance.microsoft.com).

## 🧠 On-Demand Classification Overview

**What Is On-Demand Classification?**

On-Demand Classification is a SharePoint Online feature that allows administrators to manually trigger re-indexing and classification of existing content. This is useful when:

- New Sensitive Information Types are created after documents were uploaded.
- Classification policies are updated and need to be reapplied to existing content.
- Documents were uploaded before Purview was configured.
- You need immediate classification without waiting for automatic re-indexing.

**How It Works**:

1. Administrator navigates to SharePoint site settings.
2. Selects **On-Demand Classification** option.
3. SharePoint re-indexes all documents in the site.
4. Purview applies current classification rules to re-indexed content.
5. Results appear in Content Explorer within 15-30 minutes.

**SharePoint Online Only**:

> **⚠️ Important**: On-Demand Classification works only in **SharePoint Online** and **OneDrive for Business**, not on-premises SharePoint Server or file shares.

---

## 🚀 Lab Steps

### Step 1: Create SharePoint Test Site and Upload Sample Data

Before configuring On-Demand Classification, we need a SharePoint site with sample documents containing sensitive information.

#### Create SharePoint Communication Site

Navigate to your SharePoint tenant.

- Go to [SharePoint Admin Center](https://admin.microsoft.com/sharepoint) or your tenant's SharePoint home page.
- Click **+ Create site** or **Create a site**.
- Select **Communication site** template.
- Configure the site:
  - **Site name**: `Purview Classification Lab`.
  - **Site description**: `Test site for Purview On-Demand Classification testing and validation`.
  - **Privacy settings**: Private (visible only to members).
- Click **Finish** to create the site.

Wait 2-3 minutes for site provisioning to complete.

#### Create Sample Data Directory Structure

Run the provided PowerShell script to generate sample files with embedded sensitive data:

```powershell
# Navigate to Lab 1 scripts directory
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\01-OnDemandClassification\scripts"

# Execute sample data creation script
.\Create-PurviewLabTestData.ps1
```

The script creates test files in `C:\PurviewLabs\` with:

- **Finance folder**: Customer payment records with credit card numbers (Visa, Mastercard, American Express).
- **HR folder**: Employee information with Social Security Numbers (SSN) and contact details.
- **Projects folder**: Archived data with old timestamps for retention testing.

#### Upload Sample Files to SharePoint

Upload the generated sample files to your SharePoint site.

- Navigate to **Purview Classification Lab** site.
- Open the default **Documents** library.
- Create three folders: **Finance**, **HR**, **Projects**.
- Upload corresponding files from `C:\PurviewLabs\` to each SharePoint folder.
- Verify all files uploaded successfully (check file count and sizes).

> **💡 Production Tip**: In enterprise environments, use PnP PowerShell or SharePoint Online Management Shell for bulk file uploads to multiple sites efficiently.

---

### Step 2: Create Custom Sensitive Information Type

Before running On-Demand Classification, create a custom SIT that will detect specific organizational data patterns.

#### Connect to Security & Compliance PowerShell

```powershell
# Import ExchangeOnlineManagement module
Import-Module ExchangeOnlineManagement

# Connect to Security & Compliance PowerShell
Connect-IPPSSession -UserPrincipalName your-admin@yourtenant.onmicrosoft.com
```

#### Create Custom SIT for Internal Employee IDs

For this lab, we'll create a custom SIT to detect fictional employee ID patterns (format: EMP-XXXX-YYYY).

Execute the script to create the custom SIT:

```powershell
# Navigate to Lab 1 scripts directory
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\01-OnDemandClassification\scripts"

# Execute custom SIT creation script
.\Create-CustomSIT.ps1
```

The script creates a custom SIT with:

- **Name**: `Contoso Employee ID`.
- **Pattern**: Regex pattern matching `EMP-\d{4}-\d{4}` format.
- **Confidence Level**: Medium (balanced detection accuracy).
- **Keywords**: `employee`, `staff`, `personnel` for contextual validation.

#### Validate SIT Creation in Portal

Verify the custom SIT appears in the Purview portal.

- Navigate to [Microsoft Purview Portal](https://compliance.microsoft.com).
- Go to **Data classification** → **Classifiers** → **Sensitive info types**.
- Search for `Contoso Employee ID`.
- Click the SIT name to view details (pattern, confidence level, keywords).

> **⚠️ Classification Timing**: New SITs may take 5-10 minutes to become active in classification engines. Wait before proceeding to On-Demand Classification.

---

### Step 3: Run On-Demand Classification on SharePoint Site

Now trigger manual re-indexing and classification on the SharePoint site with uploaded documents.

#### Navigate to Site Settings

Access SharePoint site settings for On-Demand Classification.

- Navigate to **Purview Classification Lab** SharePoint site.
- Click the **Settings** gear icon (top-right corner).
- Select **Site settings** from dropdown menu.
- Under **Site Administration** section, locate **On-Demand Classification** option.

> **💡 Portal Note**: The **On-Demand Classification** option appears only in SharePoint Online sites with Microsoft 365 E5 or E5 Compliance licensing. If not visible, verify tenant licensing and site permissions.

#### Initiate On-Demand Classification Scan

Trigger the classification scan.

- Click **On-Demand Classification** in site settings.
- Review the information dialog explaining the process and timing.
- Click **Run classification** button to start the scan.
- Confirmation message appears: "Classification scan initiated for this site".

**Expected Processing Time**:

- Small sites (< 100 documents): 5-10 minutes.
- Medium sites (100-1,000 documents): 15-30 minutes.
- Large sites (> 1,000 documents): 30-60 minutes.

**What Happens During Processing**:

1. SharePoint re-indexes all documents in the site library.
2. Purview classification engine analyzes document content.
3. Built-in SITs (Credit Card, SSN) and custom SITs are applied.
4. Classification metadata is updated in SharePoint and Purview.
5. Results become visible in Content Explorer and Activity Explorer.

> **⚠️ Service Processing**: On-Demand Classification runs as a background service operation. You can continue with other work while processing completes. Do not close the SharePoint site or modify documents during classification.

---

### Step 4: Validate Classification Results in Content Explorer

After classification processing completes (15-30 minutes), validate that documents were classified correctly.

#### Navigate to Content Explorer

Access Purview Content Explorer to view classification results.

- Navigate to [Microsoft Purview Portal](https://compliance.microsoft.com).
- Go to **Data classification** → **Content explorer**.
- Wait for Content Explorer to load (may take 10-15 seconds).

#### Review Classification by Sensitive Information Type

Examine which SITs were detected in your documents.

- In Content Explorer, expand **Sensitive info types** category in left navigation.
- Look for the following SITs with document counts:
  - **Credit Card Number**: Should show documents from Finance folder.
  - **U.S. Social Security Number (SSN)**: Should show documents from HR folder.
  - **Contoso Employee ID** (custom SIT): Should show documents with employee ID patterns.

Click each SIT name to view:

- **Document count**: Number of documents containing this SIT.
- **File locations**: SharePoint site URLs where documents reside.
- **Detection confidence**: Confidence level of SIT matches (Low/Medium/High).

#### Drill Down to Individual Documents

Examine specific documents that were classified.

- Click a SIT name (e.g., **Credit Card Number**).
- View list of classified documents with columns:
  - **Document name**: Filename with hyperlink to SharePoint.
  - **Location**: Full SharePoint path.
  - **Detected instances**: Count of SIT occurrences in document.
  - **Last modified**: Document timestamp.
- Click a document name to open it in SharePoint (verify sensitive data presence).

#### Verify Custom SIT Detection

Confirm your custom SIT is detecting organizational data patterns.

- Search for **Contoso Employee ID** in Content Explorer.
- Verify document count matches expected files with employee ID patterns.
- If no matches found:
  - Wait additional 10-15 minutes for classification propagation.
  - Verify custom SIT regex pattern is correct in **Sensitive info types** portal.
  - Re-run On-Demand Classification if needed.

> **💡 Production Tip**: Content Explorer updates every 24 hours with full tenant data. For immediate validation after On-Demand Classification, results may take 15-30 minutes to appear. Use Activity Explorer for near real-time classification events.

---

### Step 5: Monitor Classification Activity

Use Activity Explorer to monitor real-time classification events and policy applications.

#### Navigate to Activity Explorer

Access Activity Explorer for detailed classification activity logs.

- In Microsoft Purview Portal, go to **Data classification** → **Activity explorer**.
- Set date range filter to **Last 7 days** (covers today's On-Demand Classification).
- Review activity timeline chart showing classification events over time.

#### Filter by Activity Type

Focus on On-Demand Classification and labeling activities.

- Apply filters in Activity Explorer:
  - **Activity**: Select **File classified**.
  - **Location**: Select **SharePoint Online**.
  - **Sensitive info type**: Select specific SITs (Credit Card, SSN, custom SIT).
- View filtered results showing:
  - **Document name**: Files that were classified.
  - **Activity timestamp**: When classification occurred.
  - **User**: System account (automatic classification).
  - **Sensitive info type detected**: Which SIT matched.

#### Export Activity Data for Reporting

Generate CSV export for compliance reporting and stakeholder review.

- Click **Export** button in Activity Explorer.
- Select export format: **CSV** or **JSON**.
- Choose export scope:
  - **Current view**: Exports filtered results only.
  - **All activities**: Exports all classification events in date range.
- Wait for export generation (5-10 seconds).
- Download generated file to local machine.

> **📚 Activity Explorer Retention**: Activity Explorer data retention is 30 days. Export critical classification events for long-term audit trails and compliance records.

---

## ✅ Validation Checklist

Confirm successful lab completion by verifying these outcomes:

### Custom SIT Creation Validation

- [ ] **Custom SIT Visible in Portal**: Navigate to **Data classification** → **Sensitive info types** and search for `Contoso Employee ID`.
- [ ] **SIT Pattern Correct**: Open SIT details and verify regex pattern `EMP-\d{4}-\d{4}` is configured.
- [ ] **Keywords Present**: Confirm keywords `employee`, `staff`, `personnel` are included for contextual matching.
- [ ] **Confidence Level Set**: Verify Medium confidence level is configured.

### On-Demand Classification Validation

- [ ] **Classification Scan Completed**: SharePoint site settings show "Classification scan completed" status (not "In progress").
- [ ] **Processing Time Reasonable**: Scan completed within expected timeframe (5-30 minutes for small sites).
- [ ] **No Error Messages**: No errors displayed in SharePoint site settings or Purview portal.

### Content Explorer Validation

- [ ] **Built-in SITs Detected**: Content Explorer shows document counts for Credit Card Number and U.S. SSN.
- [ ] **Custom SIT Detected**: Content Explorer shows documents classified with Contoso Employee ID custom SIT.
- [ ] **Document Drill-Down Works**: Clicking SIT names displays document lists with location and instance counts.
- [ ] **SharePoint Links Functional**: Document hyperlinks in Content Explorer open correct SharePoint files.

### Activity Explorer Validation

- [ ] **Classification Events Visible**: Activity Explorer shows "File classified" events for today's date.
- [ ] **Event Details Accurate**: Activity records include correct document names, timestamps, and SIT types.
- [ ] **Export Functionality Works**: CSV/JSON export generates successfully with complete activity data.

---

## 🔍 Troubleshooting

### Common Issues and Solutions

#### On-Demand Classification Option Missing

**Symptom**: **On-Demand Classification** doesn't appear in SharePoint site settings.

**Solutions**:

- Verify Microsoft 365 E5 or E5 Compliance licensing for your admin account.
- Confirm you're accessing SharePoint **Online** (not on-premises SharePoint Server).
- Check that you have **Site Owner** or **Site Admin** permissions on the SharePoint site.
- Wait 24 hours after E5 license activation for feature provisioning to complete.
- Try accessing site settings in a different browser (clear cache/cookies).

#### Classification Scan Stuck "In Progress"

**Symptom**: On-Demand Classification shows "In progress" for over 60 minutes.

**Solutions**:

- Wait additional 30 minutes - large sites with 1,000+ documents may take longer.
- Check Microsoft 365 Service Health for SharePoint Online or Purview service incidents.
- Verify documents aren't locked for editing or checked out by users.
- Retry classification scan: Refresh site settings page and click **Run classification** again.
- Contact Microsoft Support if stuck for 4+ hours.

#### Custom SIT Not Detecting Content

**Symptom**: Custom SIT created but Content Explorer shows zero documents classified.

**Solutions**:

- Wait 15-30 minutes for SIT activation in classification engine.
- Verify regex pattern matches document content exactly (test pattern using regex validator).
- Check document encoding - ensure UTF-8 encoding for proper text extraction.
- Confirm keywords are present near the pattern in documents (required for Medium/High confidence).
- Lower confidence level from High to Medium if pattern is correct but not matching.
- Re-run On-Demand Classification after SIT corrections.

#### Content Explorer Shows No Results

**Symptom**: Content Explorer is empty after classification scan completes.

**Solutions**:

- Wait full 30 minutes for Content Explorer indexing to catch up with SharePoint changes.
- Verify documents actually contain sensitive data - open files in SharePoint and manually check.
- Confirm SITs are enabled (not disabled) in **Sensitive info types** portal.
- Check that file types are supported - Content Explorer works with Office docs, PDFs, text files.
- Verify Purview Data Loss Prevention service is enabled in Microsoft 365 Admin Center.

#### Activity Explorer Missing Events

**Symptom**: Activity Explorer shows no "File classified" events after On-Demand Classification.

**Solutions**:

- Adjust date range filter to include today's date (Activity Explorer may default to last 7 days excluding today).
- Remove activity type filters temporarily to see all events, then reapply specific filters.
- Wait 30-60 minutes for Activity Explorer to update with recent classification events.
- Verify activity logging is enabled in Purview Audit settings.

---

## 📖 Additional Resources

**Microsoft Learn Documentation**:

- [What is On-Demand Classification?](https://learn.microsoft.com/en-us/purview/data-classification-overview)
- [Create Custom Sensitive Information Types](https://learn.microsoft.com/en-us/purview/sit-create-a-custom-sensitive-information-type)
- [Content Explorer in Microsoft Purview](https://learn.microsoft.com/en-us/purview/data-classification-content-explorer)
- [Activity Explorer for Data Classification](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)

**PowerShell References**:

- [Security & Compliance PowerShell Cmdlets](https://learn.microsoft.com/en-us/powershell/exchange/scc-powershell)
- [New-DlpSensitiveInformationType Cmdlet](https://learn.microsoft.com/en-us/powershell/module/exchange/new-dlpsensitiveinformationtype)
- [Get-DlpSensitiveInformationType Cmdlet](https://learn.microsoft.com/en-us/powershell/module/exchange/get-dlpsensitiveinformationtype)

**SharePoint Online**:

- [SharePoint Online Service Limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits)
- [Manage SharePoint Site Settings](https://support.microsoft.com/en-us/office/manage-your-sharepoint-site-settings-8376034d-d0c7-446e-9178-6ab51c58df42)

---

## ⏭️ Next Steps

After completing Lab 1 and validating On-Demand Classification results:

**Proceed to [Lab 2: Custom Sensitive Information Types](../02-CustomSITs/README.md)** to learn:

- Advanced regex pattern design for organizational data formats.
- Keyword dictionary creation for specialized terminology.
- Confidence level tuning for optimal detection accuracy.
- Exact Data Match (EDM) for structured sensitive data protection.

Lab 2 builds on classification fundamentals from Lab 1, introducing custom SIT creation techniques for enterprise-scale data governance.

---

## 🤖 AI-Assisted Content Generation

This lab curriculum was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview On-Demand Classification workflows, PowerShell automation patterns, and data classification best practices validated against current Microsoft Learn documentation as of November 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview classification capabilities while maintaining technical accuracy and reflecting industry best practices for information protection.*

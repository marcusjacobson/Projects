# Lab 3: On-Demand Classification & Content Explorer Validation

## 🎯 Lab Objectives

- Validate custom Sensitive Information Types (SITs) created in Labs 1-2 against SharePoint content.
- Use On-Demand Classification to verify background indexing from Lab 0 is complete.
- Review classification results using Content Explorer in the Purview portal.
- Analyze SIT detection effectiveness with confidence level distribution reports.
- Monitor classification activity using Activity Explorer for real-time events.
- Understand Content Explorer navigation and classification metrics interpretation.

## ⏱️ Estimated Duration

**Active Work**: 30-45 minutes  
**Wait Period**: None (SharePoint indexing from Lab 0 is complete by now)

## 📋 Prerequisites

**Completed Labs**:

- ✅ **Lab 0 Completed**: SharePoint test site created with sample documents, placeholder SITs initialized, retention labels configured.
- ✅ **Lab 1 Completed**: Custom regex-based SITs created (Project ID, Customer Number, Purchase Order).
- ✅ **Lab 2 Completed**: EDM-based SIT created with employee database schema and hashed data uploaded.

**Microsoft 365 Licensing**:

- Microsoft 365 E5 OR Microsoft 365 E5 Compliance add-on required.
- Needed for On-Demand Classification and Content Explorer features.

**Azure AD Permissions**:

- Compliance Administrator OR Global Administrator role.
- Access to SharePoint Online site administration.

**Technical Requirements**:

- PowerShell 5.1+ or PowerShell 7+ installed.
- ExchangeOnlineManagement module v3.0+ installed.
- Active Security & Compliance PowerShell connection (from Labs 0-2).

**Knowledge Prerequisites**:

- Understanding of custom SIT creation from Labs 1-2.
- Familiarity with SharePoint Online navigation from Lab 0.
- Knowledge of Microsoft Purview portal (compliance.microsoft.com).

## 🧠 On-Demand Classification Overview

**What Is On-Demand Classification?**

On-Demand Classification is a SharePoint Online feature that allows administrators to manually trigger re-indexing and classification of existing content. In this lab, we use it to **validate that background indexing from Lab 0 is complete** and verify custom SITs from Labs 1-2 are detecting patterns correctly.

**When to Use On-Demand Classification**:

- New Sensitive Information Types are created after documents were uploaded (Labs 1-2 SITs applied to Lab 0 documents).
- Classification policies are updated and need to be reapplied to existing content.
- You need to verify background indexing has completed successfully.
- Immediate classification validation is required without waiting for automatic re-indexing.

**How It Works**:

1. Administrator navigates to SharePoint site settings.
2. Selects **On-Demand Classification** option to trigger re-indexing.
3. SharePoint re-indexes all documents in the site using current SITs.
4. Purview applies custom SITs from Labs 1-2 to re-indexed content.
5. Results appear in Content Explorer (typically immediate if background indexing from Lab 0 is complete).

**Timing Note for This Lab**:

> **✅ Background Indexing Complete**: By now, you've completed Labs 0-2 (approximately 4-6 hours of active work). The SharePoint indexing initiated in Lab 0 (15-30 minutes) has long since completed. On-Demand Classification in this lab serves as **validation**, not a wait period.

**SharePoint Online Only**:

> **⚠️ Important**: On-Demand Classification works only in **SharePoint Online** and **OneDrive for Business**, not on-premises SharePoint Server or file shares.

---

## 🚀 Lab Steps

### Step 1: Verify SharePoint Test Site Readiness

Confirm the SharePoint site created in Lab 0 is ready for On-Demand Classification validation.

#### Navigate to SharePoint Test Site

Access the SharePoint site created in Lab 0 Exercise 2.

- Navigate to [SharePoint Home](https://yourtenant.sharepoint.com) (replace `yourtenant` with your actual tenant name).
- Locate **Purview Classification Lab** site in your sites list.
- Click the site tile to open the site.
- Verify the **Documents** library contains sample files uploaded in Lab 0.

#### Verify Sample Documents Present

Confirm all sample documents from Lab 0 are accessible and indexed.

- Open the **Documents** library in the SharePoint site.
- Verify the following folders exist with sample files:
  - **Finance**: Customer payment records with credit card numbers.
  - **HR**: Employee information with Social Security Numbers (SSN).
  - **Projects**: Project documents with custom SIT patterns.
- Count total documents uploaded (should match Lab 0 completion checklist).

> **✅ Background Indexing Complete**: By now, SharePoint has had 4-6 hours to index these documents (time elapsed during Labs 0-2). The 15-30 minute indexing delay from Lab 0 is long complete.

---

### Step 2: Verify Custom SITs Are Active

Before running On-Demand Classification, confirm custom SITs from Labs 1-2 are active and ready for validation.

#### Connect to Security & Compliance PowerShell

```powershell
# Import ExchangeOnlineManagement module (if not already connected)
Import-Module ExchangeOnlineManagement

# Connect to Security & Compliance PowerShell
Connect-IPPSSession -UserPrincipalName your-admin@yourtenant.onmicrosoft.com
```

#### List Custom SITs Created in Labs 1-2

Verify all custom SITs are visible and active:

```powershell
# List all custom SITs created in previous labs
Get-DlpSensitiveInformationType | Where-Object {$_.Publisher -eq "YourOrganization"} | 
    Select-Object Name, Id, Publisher, @{Name="Created";Expression={$_.WhenCreated}} |
    Format-Table -AutoSize
```

Expected SITs from previous labs:

- **Project ID Custom SIT** (Lab 1 - regex-based).
- **Customer Number Custom SIT** (Lab 1 - regex-based).
- **Purchase Order Custom SIT** (Lab 1 - regex-based).
- **Employee Database EDM SIT** (Lab 2 - EDM-based).

#### Verify SITs in Purview Portal

Confirm SITs appear in the Microsoft Purview portal.

- Navigate to [Microsoft Purview Portal](https://compliance.microsoft.com).
- Go to **Data classification** → **Classifiers** → **Sensitive info types**.
- Search for each custom SIT from Labs 1-2.
- Click SIT names to view details (pattern, confidence level, keywords for regex SITs; schema for EDM SIT).

> **💡 Production Tip**: Custom SITs created in Labs 1-2 have had sufficient time (5-15 minutes) to replicate globally. They are now active in classification engines and ready to detect patterns in SharePoint content.

---

### Step 3: Run On-Demand Classification for Validation

Trigger On-Demand Classification to validate custom SITs from Labs 1-2 against SharePoint content.

#### Navigate to Site Settings

Access SharePoint site settings for On-Demand Classification.

- Navigate to **Purview Classification Lab** SharePoint site.
- Click the **Settings** gear icon (top-right corner).
- Select **Site settings** from dropdown menu.
- Under **Site Administration** section, locate **On-Demand Classification** option.

> **💡 Portal Note**: The **On-Demand Classification** option appears only in SharePoint Online sites with Microsoft 365 E5 or E5 Compliance licensing. If not visible, verify tenant licensing and site permissions.

#### Initiate On-Demand Classification Scan

Trigger the classification validation scan.

- Click **On-Demand Classification** in site settings.
- Review the information dialog explaining the process and timing.
- Click **Run classification** button to start the validation scan.
- Confirmation message appears: "Classification scan initiated for this site".

**Expected Processing Time for This Lab**:

- **Immediate to 5 minutes**: Background indexing from Lab 0 is complete, On-Demand Classification serves as validation trigger.
- **10-15 minutes maximum**: If custom SITs from Labs 1-2 need final propagation to classification engine.

**What Happens During Validation**:

1. SharePoint confirms documents are already indexed (Lab 0 background processing complete).
2. Purview classification engine applies custom SITs from Labs 1-2 to indexed content.
3. Built-in SITs (Credit Card, SSN) and custom regex SITs (Lab 1) are applied.
4. EDM-based SIT (Lab 2) performs exact matches against hashed employee database.
5. Classification metadata is updated and visible in Content Explorer immediately.

> **✅ No Active Waiting Required**: Unlike the original lab sequence, background indexing from Lab 0 is complete by now. On-Demand Classification in this lab validates SIT effectiveness, not trigger initial indexing.

---

### Step 4: Validate Classification Results in Content Explorer

Validate that custom SITs from Labs 1-2 are detecting patterns correctly in SharePoint documents.

#### Navigate to Content Explorer

Access Purview Content Explorer to view classification results.

- Navigate to [Microsoft Purview Portal](https://compliance.microsoft.com).
- Go to **Data classification** → **Content explorer**.
- Wait for Content Explorer to load (may take 10-15 seconds).

#### Review Classification by Sensitive Information Type

Examine which SITs were detected in your documents from Lab 0.

- In Content Explorer, expand **Sensitive info types** category in left navigation.
- Look for the following SITs with document counts:
  - **Built-in SITs**: Credit Card Number, U.S. Social Security Number (SSN).
  - **Lab 1 Custom Regex SITs**: Project ID, Customer Number, Purchase Order.
  - **Lab 2 EDM SIT**: Employee Database EDM SIT (exact matches).

Click each SIT name to view:

- **Document count**: Number of documents containing this SIT.
- **File locations**: SharePoint site URLs where documents reside (should be Purview Classification Lab site from Lab 0).
- **Detection confidence**: Confidence level of SIT matches (Low/Medium/High for regex SITs, High for EDM SITs).

#### Drill Down to Individual Documents

Examine specific documents that were classified.

- Click a SIT name (e.g., **Credit Card Number**).
- View list of classified documents with columns:
  - **Document name**: Filename with hyperlink to SharePoint.
  - **Location**: Full SharePoint path.
  - **Detected instances**: Count of SIT occurrences in document.
  - **Last modified**: Document timestamp.
- Click a document name to open it in SharePoint (verify sensitive data presence).

#### Verify Custom SIT Detection from Labs 1-2

Confirm custom SITs from previous labs are detecting organizational data patterns.

**Lab 1 Regex SITs Validation**:

- Search for **Project ID Custom SIT** in Content Explorer.
- Search for **Customer Number Custom SIT** in Content Explorer.
- Search for **Purchase Order Custom SIT** in Content Explorer.
- Verify document counts match expected files with these patterns from Lab 0 sample data.

**Lab 2 EDM SIT Validation**:

- Search for **Employee Database EDM SIT** in Content Explorer.
- Verify document counts show exact matches against hashed employee database.
- Compare detection accuracy: EDM should show higher confidence (99%) vs regex SITs (85-95%).

**If No Matches Found**:

- Wait additional 5-10 minutes for final classification propagation.
- Verify custom SIT configuration is correct in **Sensitive info types** portal.
- Re-run On-Demand Classification if needed.
- Check sample documents from Lab 0 actually contain the expected patterns.

> **✅ Validation Complete**: By now, all custom SITs from Labs 1-2 should be detecting patterns in Lab 0 SharePoint documents. This validates the complete workflow: Lab 0 setup → Labs 1-2 SIT creation → Lab 3 classification validation.

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

### Prerequisites Validation (From Labs 0-2)

- [ ] **Lab 0 Completed**: SharePoint site created with sample documents uploaded and indexed.
- [ ] **Lab 1 Completed**: Custom regex SITs created (Project ID, Customer Number, Purchase Order).
- [ ] **Lab 2 Completed**: EDM SIT created with employee database schema and hashed data uploaded.
- [ ] **Custom SITs Active**: All custom SITs visible in **Sensitive info types** portal.

### On-Demand Classification Validation

- [ ] **Classification Scan Completed**: SharePoint site settings show "Classification scan completed" status (not "In progress").
- [ ] **Processing Time Fast**: Scan completed within 5-15 minutes (background indexing from Lab 0 was already complete).
- [ ] **No Error Messages**: No errors displayed in SharePoint site settings or Purview portal.

### Content Explorer Validation - Built-in SITs

- [ ] **Credit Card Number Detected**: Content Explorer shows document counts for built-in Credit Card Number SIT.
- [ ] **U.S. SSN Detected**: Content Explorer shows document counts for built-in U.S. Social Security Number SIT.

### Content Explorer Validation - Lab 1 Custom Regex SITs

- [ ] **Project ID SIT Detected**: Content Explorer shows documents classified with Lab 1 Project ID custom SIT.
- [ ] **Customer Number SIT Detected**: Content Explorer shows documents classified with Lab 1 Customer Number custom SIT.
- [ ] **Purchase Order SIT Detected**: Content Explorer shows documents classified with Lab 1 Purchase Order custom SIT.
- [ ] **Confidence Levels Correct**: Regex SITs show appropriate confidence levels (High 85%, Medium 75%, Low 65%).

### Content Explorer Validation - Lab 2 EDM SIT

- [ ] **EDM SIT Detected**: Content Explorer shows documents classified with Lab 2 Employee Database EDM SIT.
- [ ] **Exact Match Accuracy**: EDM SIT shows higher confidence (99%) compared to regex SITs (85-95%).
- [ ] **Zero False Positives**: EDM SIT matches only exact employee database records, no false matches.

### Document and Activity Validation

- [ ] **Document Drill-Down Works**: Clicking SIT names displays document lists with location and instance counts.
- [ ] **SharePoint Links Functional**: Document hyperlinks in Content Explorer open correct SharePoint files from Lab 0.
- [ ] **Activity Explorer Shows Events**: Activity Explorer displays "File classified" events for On-Demand Classification.
- [ ] **Export Functionality Works**: CSV/JSON export generates successfully with complete classification activity data.

### Classification Metrics Validation

- [ ] **Document Count Accurate**: Total classified documents match sample files uploaded in Lab 0.
- [ ] **SIT Distribution Correct**: Multiple SITs detected in same documents (e.g., Credit Card + Purchase Order).
- [ ] **Confidence Level Distribution**: Content Explorer shows distribution across High/Medium/Low confidence levels.
- [ ] **Classification Coverage**: All expected document types (Finance, HR, Projects folders) are represented.

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

#### Custom SIT from Labs 1-2 Not Detecting Content

**Symptom**: Custom SITs created in Labs 1-2 but Content Explorer shows zero documents classified.

**Solutions**:

- Verify Lab 0 sample documents actually contain the expected patterns (open files in SharePoint and manually check).
- Wait 10-15 minutes for final SIT propagation to classification engine.
- Verify regex pattern matches document content exactly (test pattern using regex validator from Lab 1).
- Check EDM schema matches hashed data structure (verify schema fields from Lab 2).
- Confirm keywords are present near the pattern in documents (required for Medium/High confidence in Lab 1 regex SITs).
- Lower confidence level from High to Medium if pattern is correct but not matching.
- Re-run On-Demand Classification after verifying SIT configuration.
- Review Lab 1 and Lab 2 validation checklists to ensure SITs were configured correctly.

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

After completing Lab 3 and validating classification results for all custom SITs:

**Proceed to [Lab 4: Retention Labels & Auto-Apply Policies](../04-RetentionLabels/README.md)** to learn:

- Enhance initial retention labels from Lab 0 with custom SIT triggers.
- Configure auto-apply policies linking labels to Labs 1-2 custom SITs.
- Understand simulation mode (1-2 days) vs production mode (7 days) timing.
- Work with retention label policies regardless of activation timeline.
- Monitor retention label adoption and coverage metrics.

Lab 4 builds on classification validation from Lab 3, applying retention policies to documents classified with your custom SITs for enterprise data lifecycle management.

---

## 🤖 AI-Assisted Content Generation

This lab curriculum was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview On-Demand Classification workflows, optimized lab sequencing to eliminate active waiting periods, and data classification validation best practices validated against current Microsoft Learn documentation as of November 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview classification validation capabilities while maintaining technical accuracy and reflecting industry best practices for information protection and timing optimization.*

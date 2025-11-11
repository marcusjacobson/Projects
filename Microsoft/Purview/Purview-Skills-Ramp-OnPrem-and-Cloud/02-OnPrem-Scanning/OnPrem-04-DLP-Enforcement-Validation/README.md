# Lab 02 - Part 2: DLP Activity Monitoring & Reporting

> **🛑 BEFORE YOU BEGIN**: You MUST complete OnPrem-03 (DLP Policy Configuration) and verify that DLP detection is working before starting this lab.
>
> **Required Prerequisites**:
>
> - ✅ OnPrem-03 completed with DLP scan showing **Information Type Name** populated
> - ✅ Microsoft 365 auditing enabled (covered in Lab 00 - Step 2)
> - ✅ At least **15-30 minutes** have passed since completing OnPrem-03 DLP scan
> - ✅ Scanner reports confirm DLP detection is working (Credit Card, SSN detected)
>
> **If OnPrem-03 not complete**: Return to OnPrem-03 and complete DLP policy configuration and initial scan validation. This lab focuses on **monitoring and reporting** DLP activity, not running scans.

---

## 📋 Overview

**Duration**: 15-20 minutes

**Objective**: Learn how to monitor on-premises DLP activity using Activity Explorer, interpret DLP audit data, and generate compliance reports for stakeholders.

**What You'll Learn:**

- Navigate Activity Explorer and filter for on-premises DLP activity.
- Configure filters to isolate on-premises scanner events from cloud workloads.
- Interpret DLP activity data and understand what appears for on-premises scanners.
- Identify the three primary DLP reporting sources and their purposes.
- Export DLP activity data for compliance reporting.
- Generate stakeholder-ready audit trails showing sensitive data discovery.
- Establish regular monitoring cadence for ongoing compliance.

**Prerequisites from OnPrem-03:**

- ✅ DLP policy **Lab-OnPrem-Sensitive-Data-Protection** created and synced.
- ✅ DLP scan completed showing Information Type Name populated in scanner reports.
- ✅ Microsoft 365 auditing enabled (Lab 00 - Step 2).
- ✅ 15-30 minutes elapsed since DLP scan completion (for Activity Explorer data sync).

> **💡 What This Lab Covers**: This lab teaches how to use **Activity Explorer for real-time DLP monitoring**, complemented by local DetailedReport CSV files and Audit Log for comprehensive compliance reporting. Scanning operations were covered in OnPrem-03. Cloud data monitoring will be covered in dedicated cloud modules.
>
> **📚 Microsoft Learn Context**: According to [Use the data loss prevention on-premises repositories location](https://learn.microsoft.com/en-us/purview/dlp-on-premises-scanner-use), on-premises DLP activity is available through three primary sources:
>
> 1. **Activity Explorer** (Portal) - Real-time monitoring and filtering
> 2. **DetailedReport CSV** (Local scanner) - Complete technical details with DLP Mode, DLP Status, DLP Rule Name columns
> 3. **Audit Log** (Portal/PowerShell) - Long-term compliance records via `Search-UnifiedAuditLog`

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

1. **Access Activity Explorer** and locate on-premises DLP activity data in the Purview portal
2. **Filter and analyze** DLP events to isolate on-premises scanner activity from cloud workloads
3. **Interpret DLP activity data** including file counts, sensitive info types, timestamps, and understand realistic expectations for on-premises scanners
4. **Export Activity Explorer data** to CSV for stakeholder reporting and compliance documentation
5. **Generate compliance audit trails** combining Activity Explorer, DetailedReport CSV, and Audit Log sources
6. **Establish monitoring cadence** for ongoing DLP compliance with daily/weekly/monthly schedules

---

## 📖 Step-by-Step Instructions

### Step 1: Access Activity Explorer

Activity Explorer provides comprehensive DLP activity monitoring and audit trail visualization for compliance reporting.

> **⚠️ PREREQUISITE - Auditing Must Be Enabled**: Activity Explorer requires Microsoft 365 auditing to be enabled to display DLP activity data from the scanner. If you followed **Lab 00 - Step 2: Enable Microsoft 365 Auditing**, auditing should already be active and you can proceed immediately.
>
> **If you see a banner** stating *"To use this feature, turn on auditing"*:
>
> 1. Click **Turn on auditing** on the banner
> 2. Wait for confirmation: *"We're preparing the audit log. It can take up to 24 hours..."*
> 3. **Auditing activation takes 2-24 hours** (typically 2-4 hours for initial data)
> 4. **After auditing activates**: Return to **OnPrem-03** and re-run the scan (`Start-Scan -Reset`) to generate audit records
> 5. **Then wait 15-30 minutes** for Activity Explorer data to sync
>
> **💡 Banner May Persist Even When Data Is Flowing**: In some cases, the "To use this feature, turn on auditing" banner may remain visible even after auditing is enabled and Activity Explorer data is flowing. **If you see DLP activity events in the timeline and activity list below the banner, ignore the banner and proceed** - your auditing is working correctly.
>
> **Note**: Audit data is only collected from the point auditing is enabled forward. Any scanner activity before auditing was enabled will not appear in Activity Explorer.

**Navigate to Activity Explorer:**

- Navigate to [Purview Portal](https://purview.microsoft.com).
- Go to **Data loss prevention** (in left navigation).
- Select **Explorers** (in left submenu).
- Click **Activity explorer**.

> **💡 Portal Note**: The Activity Explorer navigation was updated in 2024-2025. Activity Explorer is now located under **Data loss prevention > Explorers > Activity explorer**, not under **Solutions > Data classification** as in earlier portal versions.

**Understand Activity Explorer Interface:**

When Activity Explorer loads, you'll see:

- **Activity timeline**: Graphical view of DLP events over time
- **Filter panel** (left side): Configure filters for location, date range, activity types
- **Activity list**: Detailed view of individual DLP events
- **Export button**: Download activity data to CSV for reporting

---

### Step 2: Filter and Analyze On-Premises DLP Activity

Activity Explorer provides real-time monitoring of DLP events. This step teaches you how to filter for on-premises scanner activity and interpret the results.

> **📚 Microsoft Learn Reference**: According to [Use the data loss prevention on-premises repositories location](https://learn.microsoft.com/en-us/purview/dlp-on-premises-scanner-use), on-premises DLP activity is available through Activity Explorer, Audit logs, and local DetailedReport CSV files. Activity Explorer provides the most user-friendly real-time monitoring interface.

#### Configure Filters

Apply the following filters to isolate on-premises scanner activity (excluding cloud data):

**Primary Filters** (Required):

- **Location**: Select **Endpoint devices**
  - Excludes SharePoint, OneDrive, Exchange data
  - Focuses only on file share scanner activity

- **Date range**: Select **Last 7 days** (or custom range)
  - Start date: Date of OnPrem-03 DLP scan
  - End date: Today

- **Activity type**: Select **File discovered**
  - Primary activity type for on-premises scanner detection events
  - Click individual events to see sensitive info type details

> **💡 Activity Type Note**: Unlike cloud workloads (SharePoint, OneDrive) which show "File scanned" or "DLP policy matched", on-premises scanners generate **"File discovered"** events. Sensitive information type details (Credit Card Number, SSN) are visible when you open individual activity event details.

**Optional Filters** (May Not Populate):

- **DLP policy**: Lab-OnPrem-Sensitive-Data-Protection (may appear as generic or blank)
- **Sensitive info type**: Credit Card Number, U.S. Social Security Number (SSN)

**Apply Filters:**

- Click **Apply** or **Refresh**.
- Activity timeline and list will update to show filtered results.

#### Analyze Activity Explorer Results

After applying filters, review the Activity Explorer interface to validate DLP detection.

**Activity Explorer Data Visible for On-Premises Scanners:**

| Data Point | What You'll See | Expected Values (OnPrem-03 Lab) |
|------------|-----------------|----------------------------------|
| **Files with DLP matches** | Total count of files with sensitive info detected | 3 files (CustomerPayments.txt, EmployeeRecords.txt, PhoenixProject.txt) |
| **Sensitive info types** | Types detected in scanned files | Credit Card Number, U.S. Social Security Number (SSN) |
| **Activity timestamps** | When files were scanned | Date/time of OnPrem-03 DLP scan completion |
| **File locations** | Repositories/paths containing matches | C:\ScannerTestRepos\Finance, C:\ScannerTestRepos\HR, C:\ScannerTestRepos\Projects |
| **Location filter** | Endpoint devices (not SharePoint/OneDrive) | Endpoint devices |
| **Activity type** | File discovered | File discovered |

**Activity Explorer Limitations for On-Premises Scanners:**

> **⚠️ Expected Behavior**: The following metadata may appear as generic or blank. This is **normal for on-premises scanners** and does NOT indicate a problem.

| Data Point | Expected Limitation | Why This Occurs |
|------------|---------------------|-----------------|
| **DLP policy names** | May show as generic or blank | On-premises scanner metadata not fully populated in Activity Explorer |
| **DLP rule names** | Typically not displayed | Scanner reports provide this detail instead |
| **Enforcement actions** | Shows "Detected" instead of "Blocked"/"Allowed" | Test mode scanners detect but don't enforce |
| **User context** | Shows scanner service account | Scanner runs as service, not individual users |

#### Success Validation

✅ **Validation Criteria:**

- DLP events present in Activity Explorer timeline (time period after OnPrem-03 scan).
- Sensitive info types identified (Credit Card Number and/or SSN).
- File counts match DetailedReport CSV from OnPrem-03 (3 files expected).
- Location filter = Endpoint devices (confirms on-premises, not cloud).

> **💡 Primary Validation**: The presence of **File discovered** events with matched **sensitive information types** (Credit Card Number, SSN) confirms DLP detection is working correctly and generating audit trails. Policy/rule names being generic or missing is expected for on-premises scanners.

#### Complementary Reporting Sources

Activity Explorer is one of three DLP reporting sources. Use these complementary sources for different reporting needs:

| Reporting Source | Access Method | Best Use Case | Key Data Available |
|------------------|---------------|---------------|---------------------|
| **Activity Explorer** | Purview portal > Data loss prevention > Explorers | Real-time monitoring and filtering | Files with matches, sensitive info types, timestamps, location |
| **DetailedReport CSV** | `%localappdata%\Microsoft\MSIP\Scanner\Reports\DetailedReport\` | Technical troubleshooting | DLP Mode, DLP Status, DLP Rule Name, DLP Actions, file paths |
| **Audit Log** | Purview portal > Audit (PowerShell: `Search-UnifiedAuditLog`) | Long-term compliance records | Complete audit trail with all DLP events and metadata |

> **📊 Reporting Strategy**: Use Activity Explorer for **daily monitoring**, DetailedReport CSV for **technical validation**, and Audit Log for **compliance documentation**. Each source provides different detail levels for different audiences.

---

### Step 3: Export Activity Data for Compliance Reporting

Activity Explorer data can be exported to CSV for stakeholder reporting, compliance audits, and executive dashboards. By customizing the visible columns, you can include sensitive info type details in your export.

**Customize Columns to Include Sensitive Info Types:**

Before exporting, configure Activity Explorer to show the sensitive info type data:

- In Activity Explorer, click **Customize columns** (gear icon or column settings).
- Enable the following columns for export:
  - ✅ **Activity** (default)
  - ✅ **File** (default)
  - ✅ **Location** (default)
  - ✅ **User** (default)
  - ✅ **Happened** (default)
  - ✅ **Sensitive info type** ← **Add this column to see what was detected**
  - ✅ **Policy** (optional - typically empty for on-premises)
  - ✅ **Rule** (optional - typically empty for on-premises)
- Click **Apply** or **Save** to update the view.

> **💡 Critical Step**: The **Sensitive info type** column is **not included by default** in Activity Explorer exports. You must use **Customize columns** to add it, otherwise your CSV will only show file paths without indicating what sensitive data was detected.

**Export Activity Data to CSV:**

After customizing columns:

- Ensure filters are applied (Location = Endpoint devices).
- Click **Export** button (top right of Activity Explorer interface).
- Select export format: **CSV**.
- Wait for export to generate (may take 1-2 minutes for large datasets).
- Download the CSV file when ready.

**Review Exported Data Structure:**

Open the exported CSV file in Excel or a text editor. With the Sensitive info type column enabled, your Activity Explorer export will contain:

**Activity Explorer CSV Export Columns (With Customization):**

| Column Name | Sample Data | Use in Reporting |
|-------------|-------------|------------------|
| **Activity** | File discovered | Activity type for filtering and grouping |
| **File** | `\\COMPUTERNAME\Finance\CustomerPayments.txt` | Full UNC path to scanned file |
| **Location** | Endpoint devices | Confirms on-premises vs cloud workloads |
| **User** | scanner-svc@yourdomain.com | Service account running scanner |
| **Happened** | XXXX-XX-XXT00:00:00.000Z | ISO 8601 timestamp of detection event |
| **Sensitive info type** | Credit Card Number/Social Security Number | **What sensitive data was detected** |
| **Policy** | (Empty for on-premises scanners) | DLP policy name (may not populate) |
| **Rule** | (Empty for on-premises scanners) | DLP rule name (may not populate) |

**Expected Export Data (OnPrem-03 Lab Files):**

Based on the OnPrem-03 lab, your Activity Explorer export should show multiple "File discovered" events with sensitive info types:

- `\\COMPUTERNAME\Finance\CustomerPayments.txt` - **Credit Card Number**.
- `\\COMPUTERNAME\HR\EmployeeRecords.txt` - **U.S. Social Security Number (SSN)**.
- `\\COMPUTERNAME\Projects\PhoenixProject.txt` - **Credit Card Number**.

> **💡 Multiple Events Per File**: You may see duplicate entries for the same file with different timestamps. This occurs when the scanner runs multiple times. Use PowerShell to deduplicate and generate unique file summaries.

**Create Stakeholder-Ready Reports:**

Use the exported CSV with sensitive info type data to create executive summaries:

#### Option 1: Excel Pivot Table Summary

```excel
1. Open exported CSV in Excel
2. Insert > PivotTable
3. Rows: Sensitive info type
4. Values: Count of File (shows unique file count per sensitive data type)
5. Add filter: Location = "Endpoint devices"
6. Result: Executive summary showing "Credit Card Number: 2 files, SSN: 1 file"
```

#### Option 2: PowerShell Executive Summary (Personal workstation, NOT VM)

On your development/admin machine (not Scanner VM), open PowerShell and run:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-04-DLP-Enforcement-Validation"
.\Generate-DLPExecutiveSummary.ps1
```

> **💡 Script Functionality**: This script automatically finds the most recent Activity Explorer export in your Downloads folder, processes the data to identify sensitive information types, and generates two comprehensive reports in C:\Reports directory: an executive summary and a detailed file-level report.

**Expected PowerShell Output:**

```text
========== ON-PREMISES DLP EXECUTIVE SUMMARY ==========
Report Date: 2025-10-27
Scope: On-Premises File Repositories (Endpoint Devices)

Sensitive Data Type              Unique Files Detected Total Detection Events Sample Files
--------------------              --------------------- --------------------- ------------
Credit Card Number                                   2                    12 \\vm-purview-scan\Finance\CustomerPayments.txt; \\vm-purview-scan\Projects\PhoenixProject.txt
U.S. Social Security Number (SSN)                   1                     6 \\vm-purview-scan\HR\EmployeeRecords.txt

========== DETAILED FILE-LEVEL REPORT ==========
File Name             Repository Sensitive Data Type
---------             ---------- --------------------
CustomerPayments.txt  Finance    Credit Card Number
PhoenixProject.txt    Projects   Credit Card Number
EmployeeRecords.txt   HR         U.S. Social Security Number (SSN)
```

#### Compliance Audit Trail Template

For compliance documentation, combine Activity Explorer exports with local scanner reports:

**Executive Summary Template** (from Activity Explorer CSV):

- **Report Date**: [Current date]
- **Scope**: On-premises file repositories (Endpoint devices only)
- **Detection Summary**:
  - Credit Card Numbers: X unique files detected
  - Social Security Numbers: Y unique files detected
  - Total sensitive files: Z unique files
- **Data Source**: Activity Explorer export with Customize columns (Sensitive info type enabled)
- **Export Date Range**: [Start date] to [End date]

**Supporting Documentation**:

- **Activity Explorer CSV**: Shows what was detected and when (sensitive info types visible)
- **DetailedReport CSV** (Local scanner): Shows DLP Mode, DLP Status, DLP Rule Name for technical validation
- **Audit Log**: Long-term compliance records accessible via Purview portal > Audit

> **📊 Best Practice**: Activity Explorer exports with the **Sensitive info type** column provide stakeholder-ready summaries. Use local DetailedReport CSV for technical troubleshooting and Audit Log for regulatory compliance documentation requiring long-term retention.

---

### Step 4: Schedule Regular Activity Monitoring

For ongoing compliance monitoring, establish a regular Activity Explorer review cadence.

**Recommended Monitoring Cadence:**

**Daily Monitoring** (High-Risk Environments):

- Check Activity Explorer daily for new DLP matches.
- Focus on "File discovered" activity type.
- Alert stakeholders for unexpected sensitive data discovery.

**Weekly Monitoring** (Standard Environments):

- Review Activity Explorer weekly for trends.
- Export activity data for weekly compliance reports.
- Track sensitive info type distribution over time.

**Monthly Monitoring** (Low-Risk Environments):

- Generate monthly DLP activity summary.
- Compare month-over-month trends.
- Identify repositories with recurring sensitive data issues.

**PowerShell Monitoring Script Example:**

On your development/admin machine, open PowerShell and run:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-04-DLP-Enforcement-Validation"
.\Invoke-WeeklyDLPMonitoring.ps1
```

This script provides a quick summary from the previously generated reports:

> **💡 Script Functionality**: Analyzes the most recent executive summary and detailed reports from C:\Reports directory, displays sensitive data detection statistics by type and repository, and provides monitoring dashboard for weekly compliance reviews.

> **💡 Monitoring Tip**: Combine Activity Explorer monitoring with scanner DetailedReport CSV reviews for comprehensive visibility. Activity Explorer provides audit trails, while scanner reports provide file-level detail.

---

## ✅ Validation Checklist

Complete the following validation steps to ensure successful lab completion:

### Activity Explorer Access (Step 1)

- [ ] Activity Explorer accessible in Purview portal under **Data loss prevention > Explorers**
- [ ] Microsoft 365 auditing enabled and active (no banner prompting to enable auditing)
- [ ] Activity Explorer interface loads without errors

### Filter and Analyze On-Premises DLP Activity (Step 2)

- [ ] **Location filter** set to **Endpoint devices** (excludes cloud workloads)
- [ ] **Date range filter** configured to include OnPrem-03 scan date
- [ ] **Activity type filter** shows **File discovered** for on-premises scanner events
- [ ] DLP events visible in Activity Explorer timeline after applying filters
- [ ] **Sensitive info types identified** in activity data (Credit Card Number, SSN)
- [ ] **File count matches scanner reports** from OnPrem-03 (4 files expected)
- [ ] Activity timestamps correspond to OnPrem-03 scan completion time

> **✅ Success Indicator**: If Activity Explorer shows **File discovered** events with **sensitive information types** (Credit Card Number, SSN) for Endpoint devices location, DLP monitoring is working correctly. Policy/rule names may be generic or missing - this is expected for on-premises scanners.

### Activity Data Export (Step 3)

- [ ] **Customize columns** configured to include **Sensitive info type** column before export
- [ ] Activity data exported to CSV successfully from Activity Explorer
- [ ] CSV contains expected columns including **Sensitive info type** (Activity, File, Location, User, Happened, Sensitive info type, Policy, Rule)
- [ ] CSV filtered to show only on-premises repository data (Endpoint devices)
- [ ] PowerShell executive summary script executed successfully
- [ ] Executive summary and detailed reports generated in `C:\Reports` directory
- [ ] Reports show sensitive data types grouped by category (Credit Card Number, SSN)

### Monitoring Cadence (Step 4)

- [ ] Reviewed recommended monitoring cadence options (daily, weekly, monthly)
- [ ] PowerShell weekly monitoring script executed successfully
- [ ] Monitoring script displays executive summary from generated reports
- [ ] Repository breakdown shows files grouped by location and sensitive data type
- [ ] Regular monitoring schedule established for ongoing compliance

---

## 🔍 Troubleshooting Common Issues

### Issue: Activity Explorer Shows No Data

**Symptoms**: Activity Explorer appears empty after completing OnPrem-03

**Common Causes**:

1. **Data Sync Timing**: Activity data takes 15-30 minutes to appear after scan completes
2. **Incorrect Filters**: **Location** filter must be set to **On-premises repositories**
3. **Prerequisite Not Met**: Verify OnPrem-03 scan completed successfully with DLP detections

**Quick Resolution**:

- Wait 30 minutes after OnPrem-03 scan completion, then refresh Activity Explorer (Ctrl+F5).
- Apply **Location = On-premises repositories** filter.
- Verify OnPrem-03 scanner reports show populated **Information Type Name** column.

---

### Issue: Activity Explorer Shows Cloud Data Instead of On-Premises

**Symptoms**: Activity Explorer shows SharePoint or OneDrive activity instead of file share scanner activity

**Resolution**:

1. Click **Filters** in Activity Explorer
2. Set **Location** = **On-premises repositories** (not SharePoint, OneDrive, Exchange, Teams)
3. Click **Apply** to refresh results

---

### Issue: Exported CSV Missing Sensitive Info Type Column

**Symptoms**: Activity Explorer export CSV lacks the **Sensitive info type** column needed for analysis

**Resolution**:

1. In Activity Explorer, click **Customize columns** button
2. Enable **Sensitive info type** checkbox
3. Click **Export** to download CSV with all required columns
4. Verify exported CSV includes: Activity, File, Location, User, Happened, **Sensitive info type**

---

### Issue: PowerShell Script "CSV File Not Found" Error

**Symptoms**: Executive summary script fails to find Activity Explorer export in Downloads folder

**Resolution**:

1. Verify you exported Activity Explorer data to CSV (Step 3 - Option 1)
2. Check Downloads folder contains: `Activity explorer _ Microsoft Purview*.csv`
3. If export in different location, update script line: `$downloadsDir = "C:\Users\$env:USERNAME\Downloads"`

---

### Issue: Monitoring Script Shows 0 Events/Files

**Symptoms**: Weekly monitoring script displays no DLP activity despite having data

**Resolution**:

1. **MUST run Step 3 - Option 2 PowerShell script first** to generate reports
2. Verify `C:\Reports` directory contains:
   - `OnPrem-DLP-Executive-Summary-[date].csv`
   - `OnPrem-DLP-Detailed-Report-[date].csv`
3. If reports missing, run executive summary script before monitoring script

**Workflow**: Export Activity Explorer → Run Executive Summary Script → Run Monitoring Script

---

## 📊 Lab Completion Summary

After completing this lab successfully, you should have:

### ✅ Activity Explorer Monitoring Skills

- **Access**: Navigated to Activity Explorer and located DLP activity monitoring interface in Microsoft Purview portal
- **Filter and Analyze**: Configured filters to isolate on-premises scanner events (Endpoint devices location, File discovered activity type) and interpreted DLP activity data
- **Export with Customize Columns**: Enabled **Sensitive info type** column visibility before export to ensure all critical data is captured in CSV
- **Monitoring Cadence**: Established regular monitoring schedule for ongoing DLP compliance tracking

### ✅ DLP Reporting Automation Capabilities

- **PowerShell Executive Summary Script**:
  - Automatic latest Activity Explorer export file selection (handles multiple downloads with browser suffixes)
  - Error handling with clear user guidance for missing files or directories
  - Automated report directory creation (`C:\Reports`)
  - Generates executive summary grouped by sensitive data type (Credit Card Number, SSN)
  - Creates detailed repository breakdown showing file distribution across locations
  
- **PowerShell Weekly Monitoring Script**:
  - Reads processed executive summary and detailed reports (not raw Activity Explorer exports)
  - Displays DLP activity summary by sensitive data type with unique file counts and total event counts
  - Shows repository breakdown with files grouped by location and data type
  - Provides actionable next steps guidance for ongoing monitoring
  
- **Reporting Sources**: Understand the three primary DLP reporting sources for comprehensive compliance validation
  - **Activity Explorer** (Portal) - Real-time monitoring and filtering
  - **DetailedReport CSV** (Local scanner) - Technical details with DLP columns
  - **Audit Log** (Portal/PowerShell) - Long-term compliance records

### ✅ On-Premises vs Cloud Data Distinction

- **Filtered** Activity Explorer to show only on-premises scanner activity (Endpoint devices)
- **Excluded** cloud workload data (SharePoint, OneDrive, Teams) from on-premises reporting
- **Recognized** Activity Explorer behavior differences between on-premises scanners and cloud workloads
- **Prepared** for cloud workload DLP monitoring in future dedicated modules

---

## 🚀 Next Steps

**Immediate Next Actions:**

1. **Establish Regular Monitoring**: Set up weekly Activity Explorer reviews for ongoing DLP compliance
2. **Create Report Templates**: Build Excel templates for monthly DLP detection summaries
3. **Automate Exports**: Schedule Activity Explorer exports and PowerShell analysis scripts

**Future Learning Paths:**

- **Cloud Workload DLP**: Dedicated modules will cover SharePoint, OneDrive, Teams DLP monitoring
- **Advanced Reporting**: Power BI integration for executive-level DLP dashboards
- **Incident Response**: Using Activity Explorer for DLP incident investigation and forensics

---

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Activity Explorer monitoring and DLP validation while maintaining technical accuracy for on-premises enforcement scenarios.*

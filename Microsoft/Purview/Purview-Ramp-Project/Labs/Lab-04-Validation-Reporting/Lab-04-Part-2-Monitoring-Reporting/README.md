# Lab 04 Part 2: Activity Monitoring & Final Reporting

## 📋 Overview

**Duration**: 45 minutes

**Objective**: Analyze Activity Explorer monitoring data, review Data Classification dashboards, finalize stakeholder report with complete metrics, and validate successful completion of Labs 01-04.

**What You'll Learn:**

- Analyze Activity Explorer for DLP policy effectiveness
- Interpret Data Classification dashboards
- Finalize stakeholder report with monitoring insights
- Validate complete lab series (Labs 01-04)
- Prepare deliverables for portfolio and career development

**Prerequisites:**

- ✅ **Lab 04 Part 1 complete**: Scanner analysis, remediation planning, draft report created
- ✅ **24 hour wait complete**: Activity Explorer data fully synced (minimum 15-30 min, optimal 24 hours)
- ✅ **Labs 01-02 validated**: Scanner deployed, DLP policies enforced
- ⏳ **Lab 03 in progress**: Auto-apply simulation running (validation optional)

> **⏳ Timing Requirement**: This is Part 2 of Lab 04 and **must be started at least 24 hours after Part 1 completion** to ensure Activity Explorer and Data Classification dashboards have fully synced. Starting too early will result in incomplete or missing monitoring data.

---

## 🎯 Lab Objectives

By the end of Part 2, you will be able to:

1. Analyze Activity Explorer for DLP policy effectiveness and user activity
2. Interpret Data Classification dashboards for sensitive data trends
3. Finalize stakeholder report with complete monitoring metrics
4. Validate successful completion of all labs (01-04)
5. Export final deliverables for portfolio and resume use

> **📚 Next Lab**: After completing this lab and exporting your deliverables, refer to the **[Environment Cleanup Guide](../Environment-Cleanup-Guide.md)** to properly remove all Azure resources and terminate ongoing costs.

---

## 📖 Step-by-Step Instructions

### Step 1: Activity Explorer Analysis

Activity Explorer provides visibility into DLP policy matches, user activity, and sensitive data access patterns across your environment.

> **📊 Data Availability**: Activity Explorer requires **15-30 minutes to 24 hours** after scanner completion for data to fully sync. If you completed Part 1 yesterday, you should see complete data now.

**Navigate to Activity Explorer:**

- Go to [compliance.microsoft.com](https://compliance.microsoft.com)
- Navigate to **Information Protection** → **Explorers** → **Activity Explorer**

> **💡 Portal Note**: The Microsoft Purview portal interface was reorganized in 2024. Activity Explorer is now located under **Information Protection → Explorers** (previously under "Data Classification"). The functionality remains identical.

**Configure Filters for On-Premises Analysis:**

1. **Date Range**:
   - Set to last 7-30 days to capture Labs 01-02 scanner activity
   - Click calendar icon, select custom range

2. **Activity Type**:
   - Filter by "DLP policy match" to see DLP enforcement events
   - Filter by "File scanned" to see scanner discovery activity

3. **Location**:
   - On-premises repositories: `\\vm-purview-scanner\Finance`, `\\vm-purview-scanner\HR`, etc.
   - Cloud simulation: Azure Files share name

4. **DLP Policy**:
   - Select "Lab-OnPrem-Sensitive-Data-Protection" to filter to your test policy

**Key Metrics to Review:**

| Metric | What to Look For | Expected for Lab |
|--------|------------------|------------------|
| **Total Activities** | Number of DLP policy match events | Should match scanner DetailedReport row count |
| **Activities by Location** | Which shares triggered most DLP matches | Finance (credit cards), HR (SSNs) |
| **Activities by Severity** | High vs. Low severity DLP matches | High = Credit Card (Block), Low = SSN (Audit) |
| **Activities Over Time** | Trend of DLP events | Spike on scanner enforcement scan date |
| **Users Involved** | Which accounts accessed sensitive data | Scanner service account (most common) |

**Export Activity Explorer Data:**

```text
1. Configure filters as described above
2. Click "Export" button in Activity Explorer toolbar
3. Save CSV to C:\PurviewLab\ActivityExplorer_Export.csv
4. Review CSV in Excel for detailed event data
```

**PowerShell Analysis of Activity Explorer Export:**

```powershell
# On local machine or VM, import Activity Explorer CSV
$activityData = Import-Csv "C:\PurviewLab\ActivityExplorer_Export.csv"

# Count DLP policy matches
$dlpMatches = $activityData | Where-Object {$_.Activity -like "*DLP*"}
Write-Host "Total DLP Policy Matches: $($dlpMatches.Count)" -ForegroundColor Cyan

# Group by location
$byLocation = $dlpMatches | Group-Object Location | 
    Select-Object Name, Count | 
    Sort-Object Count -Descending
Write-Host "`nDLP Matches by Location:" -ForegroundColor Yellow
$byLocation | Format-Table -AutoSize

# Group by severity
$bySeverity = $dlpMatches | Group-Object Severity | 
    Select-Object Name, Count
Write-Host "`nDLP Matches by Severity:" -ForegroundColor Green
$bySeverity | Format-Table -AutoSize

# Identify top users (if user context available)
if ($activityData[0].PSObject.Properties.Name -contains 'User') {
    $topUsers = $dlpMatches | Group-Object User | 
        Select-Object Name, Count | 
        Sort-Object Count -Descending | 
        Select-Object -First 10
    Write-Host "`nTop 10 Users with DLP Activity:" -ForegroundColor Magenta
    $topUsers | Format-Table -AutoSize
}
```

> **💡 Interpretation Tip**: For lab scanner activity, the "User" field will typically show the scanner service account (service principal UPN or scanner VM computer account). In production with user context scanners or Microsoft 365 locations, you'd see actual user accounts accessing sensitive data.

**Expected Activity Explorer Findings:**

For this lab, you should observe:

- **DLP Policy Matches**: Equal to number of files with SITs in scanner DetailedReport CSV
- **High Severity Events**: Files with credit cards (blocked by DLP)
- **Low Severity Events**: Files with SSNs (audited by DLP)
- **Location Distribution**: Finance share (credit cards), HR share (SSNs)
- **Timeline**: Activity concentrated on date of Lab 02 DLP enforcement scan

> **⚠️ Troubleshooting - No Activity Explorer Data**:
>
> If Activity Explorer shows no events after 24 hours:
>
> 1. Verify auditing is enabled: Microsoft Purview portal → Audit → Turn on auditing
> 2. Check date range filter (expand to 30 days)
> 3. Confirm scanner DLP enforcement scan completed with `-Reset` parameter
> 4. Wait additional 2-4 hours if auditing was just enabled (full sync can take up to 48 hours)

---

### Step 2: Data Classification Overview Dashboards

Data Classification dashboards provide high-level visualizations of sensitive data distribution, labeling status, and DLP effectiveness.

> **📊 Data Availability**: Dashboards require **1-2 days** for full aggregation. If you completed Part 1 yesterday, dashboards should be populated now.

**Navigate to Data Classification Dashboards:**

- Go to [compliance.microsoft.com](https://compliance.microsoft.com)
- Navigate to **Information Protection** → **Explorers** → **Overview**

> **💡 Portal Note**: Data Classification dashboards are now accessed through **Information Protection → Explorers → Overview** (previously "Data Classification → Overview"). The dashboard content and functionality remain the same.

**Key Dashboards to Review:**

**1. Top Sensitive Info Types**:

What it shows:

- Bar chart of most common SIT types detected
- Count of items containing each SIT
- Distribution across your environment

Expected for lab:

- Credit Card Number: [X items] (from Finance share sample data)
- U.S. Social Security Number (SSN): [Y items] (from HR share sample data)
- Email addresses or other SITs if in sample data

Screenshot location:

- Take screenshot and save as `DataClassification_TopSITs.png`

**2. Locations with Sensitive Data**:

What it shows:

- Pie chart or bar chart of which locations contain sensitive data
- Breakdown by repository type (SharePoint, OneDrive, Exchange, On-Prem)
- Percentage distribution

Expected for lab:

- On-premises repositories: `\\vm-purview-scanner\Finance`, `\\vm-purview-scanner\HR`
- Azure Files (if scanned): `[storage account]/[share name]`
- SharePoint Online test site (if created in Lab 03): Small percentage

Screenshot location:

- Take screenshot and save as `DataClassification_Locations.png`

**3. Labeling Status**:

What it shows:

- Percentage of files with sensitivity/retention labels applied
- Breakdown by label type
- Trend over time

Expected for lab:

- Low percentage (auto-apply retention labels don't support on-prem file shares)
- SharePoint test site: May show "Delete-After-3-Years" label if auto-apply activated
- On-prem shares: No automatic labels (workaround: PowerShell file operations)

Screenshot location:

- Take screenshot and save as `DataClassification_LabelingStatus.png`

**4. DLP Policy Effectiveness**:

What it shows:

- Number of DLP policy matches over time
- Breakdown by policy and severity
- User overrides or false positives

Expected for lab:

- Policy: Lab-OnPrem-Sensitive-Data-Protection
- High severity matches: Credit card files (blocked)
- Low severity matches: SSN files (audited)
- Timeline spike: Date of Lab 02 enforcement scan

Screenshot location:

- Take screenshot and save as `DataClassification_DLPEffectiveness.png`

**Dashboard Analysis Summary:**

```powershell
# Create summary of dashboard insights for reporting
$dashboardSummary = @"
DATA CLASSIFICATION DASHBOARD INSIGHTS
=======================================
Date Captured: $(Get-Date -Format 'yyyy-MM-dd HH:mm')

Top Sensitive Info Types:
  • Credit Card Number: [X] items (Finance share)
  • U.S. Social Security Number (SSN): [Y] items (HR share)
  • Email Addresses: [Z] items (various)

Locations with Sensitive Data:
  • On-Premises File Shares: [XX]% ([count] items)
    - \\vm-purview-scanner\Finance: [X] items
    - \\vm-purview-scanner\HR: [Y] items
    - \\vm-purview-scanner\Projects: [Z] items
  • Azure Files: [YY]% ([count] items)
  • SharePoint Online: [ZZ]% ([count] items - test site)

Labeling Status:
  • Files with Labels: [X]% of scanned files
  • Unlabeled Files: [Y]%
  • Primary Label: Delete-After-3-Years ([Z] files in SharePoint test site)
  • On-Prem Limitation: Auto-apply not supported (requires PowerShell)

DLP Policy Effectiveness:
  • Total DLP Matches: [X] events
  • High Severity (Blocked): [Y] credit card files
  • Low Severity (Audited): [Z] SSN files
  • Policy: Lab-OnPrem-Sensitive-Data-Protection
  • False Positives: [0 expected for lab data]

Screenshots Captured:
  ✅ DataClassification_TopSITs.png
  ✅ DataClassification_Locations.png
  ✅ DataClassification_LabelingStatus.png
  ✅ DataClassification_DLPEffectiveness.png
"@

# Save dashboard summary
$dashboardSummary | Out-File "C:\PurviewLab\Dashboard_Summary.txt" -Encoding UTF8
Write-Host "Dashboard summary saved to C:\PurviewLab\Dashboard_Summary.txt" -ForegroundColor Green
```

---

### Step 3: Finalize Summary Report for Stakeholders

Update the draft report from Part 1 with Activity Explorer and Data Classification insights to create the final stakeholder deliverable.

> **📝 Report Completion**: This step **finalizes the draft report** created in **Lab 04 Part 1**. You'll add the monitoring sections that were marked as "⏳ TO BE ADDED IN PART 2".

**Update Draft Report with Part 2 Data:**

```powershell
# Open draft report from Part 1
$draftReportPath = "C:\PurviewLab\Draft_Remediation_Report_Part1.txt"
$draftContent = Get-Content $draftReportPath -Raw

# Add Activity Explorer insights section
$activityExplorerUpdate = @"

ACTIVITY EXPLORER INSIGHTS (ADDED IN PART 2)
----------------------------------------------
Data Sync Date: $(Get-Date -Format 'yyyy-MM-dd')
Analysis Period: Last 30 days

DLP Policy Monitoring:
  • Total DLP Policy Matches: [X] events (from Activity Explorer export)
  • High Severity Events (Blocked): [Y] credit card files
  • Low Severity Events (Audited): [Z] SSN files
  • Policy: Lab-OnPrem-Sensitive-Data-Protection

Activity by Location:
  • Finance Share (\\vm-purview-scanner\Finance): [X] DLP matches
  • HR Share (\\vm-purview-scanner\HR): [Y] DLP matches
  • Projects Share: [Z] DLP matches
  • Azure Files: [A] DLP matches (if applicable)

Activity Timeline:
  • Peak activity: [Date of Lab 02 enforcement scan]
  • Consistent with scanner enforcement execution
  • No unexpected user access patterns detected

User Context:
  • Primary account: [Scanner service account UPN/computer account]
  • Note: Lab environment uses service principal authentication
  • Production: Would show actual user accounts accessing sensitive data

Compliance Insight:
  • DLP enforcement working as expected
  • Blocked files: Credit cards successfully prevented from access
  • Audited files: SSN access logged for compliance review
  • No policy overrides or false positives observed
"@

# Add Data Classification dashboard insights
$dashboardUpdate = @"

DATA CLASSIFICATION OVERVIEW (ADDED IN PART 2)
------------------------------------------------
Dashboard Data as of: $(Get-Date -Format 'yyyy-MM-dd')

Top Sensitive Info Types (from dashboards):
  1. Credit Card Number: [X] items
     - Location: Primarily Finance share
     - Risk Level: High (PCI DSS)
     - DLP Action: Blocked
  
  2. U.S. Social Security Number (SSN): [Y] items
     - Location: Primarily HR share
     - Risk Level: Medium-High (PII)
     - DLP Action: Audited
  
  3. Email Addresses: [Z] items (if applicable)
     - Location: Various shares
     - Risk Level: Low (GDPR consideration)

Locations with Sensitive Data Distribution:
  • On-Premises File Shares: [XX]% of total sensitive items
    - Finance: [X] items ([Y]% of on-prem total)
    - HR: [A] items ([B]% of on-prem total)
    - Projects: [C] items ([D]% of on-prem total)
  
  • Cloud Locations: [YY]% of total sensitive items
    - Azure Files: [X] items (cloud simulation)
    - SharePoint Online: [Y] items (Lab 03 test site)

Labeling Status:
  • Files with Labels: [X]% ([Y] files)
  • Unlabeled Files: [Z]% ([A] files)
  
  Label Distribution:
    - Delete-After-3-Years: [X] files (SharePoint test site only)
    - On-Prem Files: 0 labels (auto-apply not supported)
  
  Retention Gap:
    ⚠️ [Z]% of on-premises files lack automated retention controls
    ✅ Workaround implemented: PowerShell-based file age remediation

DLP Policy Effectiveness Trends:
  • Policy: Lab-OnPrem-Sensitive-Data-Protection
  • Active Rules: 2 (Block-Credit-Card-Access, Audit-SSN-Access)
  • Total Matches: [X] events
  • Block Success Rate: 100% (no credit card files accessible)
  • Audit Coverage: 100% (all SSN file access logged)
  • False Positive Rate: 0% (expected for controlled lab data)

Visual Evidence:
  ✅ Screenshot: Top Sensitive Info Types dashboard
  ✅ Screenshot: Locations with Sensitive Data distribution
  ✅ Screenshot: Labeling Status percentages
  ✅ Screenshot: DLP Policy Effectiveness timeline
"@

# Combine into final report
$finalReportContent = $draftContent `
    -replace "⏳ ACTIVITY EXPLORER INSIGHTS: TO BE ADDED IN PART 2[\s\S]*?(?=⏳ DATA CLASSIFICATION OVERVIEW:|RETENTION LABEL IMPLEMENTATION)", $activityExplorerUpdate `
    -replace "⏳ DATA CLASSIFICATION OVERVIEW: TO BE ADDED IN PART 2[\s\S]*?(?=RETENTION LABEL IMPLEMENTATION)", $dashboardUpdate `
    -replace "Status: DRAFT - Scanner Analysis Complete", "Status: FINAL - Complete with Monitoring Data" `
    -replace "Next Update: Lab 04 Part 2 \(24 hours from now\)", "Completed: Lab 04 Part 2" `
    -replace "REPORT STATUS[\s\S]*?(?=REPORT PREPARED BY)", @"
REPORT STATUS
-------------
Status: FINAL
Part 1 Completed: [Date of Part 1]
Part 2 Completed: $(Get-Date -Format 'yyyy-MM-dd')
Data Sources: Scanner reports, Activity Explorer, Data Classification dashboards
"@

# Save final report
$finalReportPath = "C:\PurviewLab\Final_Remediation_Report.txt"
$finalReportContent | Out-File $finalReportPath -Encoding UTF8
Write-Host "✅ Final report saved to: $finalReportPath" -ForegroundColor Green
```

> **📝 Manual Customization Required**: The PowerShell script above provides the structure for updating your report. You'll need to:
> 1. Open the draft report from Part 1
> 2. Manually fill in `[X]`, `[Y]`, `[Z]` placeholders with actual values from Activity Explorer export and dashboard screenshots
> 3. Replace the "⏳ TO BE ADDED IN PART 2" sections with the completed content
> 4. Save as `Final_Remediation_Report.txt`

**Final Report Sections Checklist:**

- [x] Executive Summary (from Part 1)
- [x] Environment Details (from Part 1)
- [x] Discovery Summary from Scanner Reports (from Part 1)
- [x] Data Age Analysis (from Part 1)
- [x] DLP Enforcement Summary from Scanner (from Part 1)
- [x] **Activity Explorer Insights** ✅ ADDED IN PART 2
- [x] **Data Classification Overview** ✅ ADDED IN PART 2
- [x] Retention Label Implementation (from Part 1)
- [x] Compliance & Governance Metrics (updated with Part 2 data)
- [x] Recommendations (from Part 1, validated with Part 2 findings)
- [x] Appendices with all data sources

---

### Step 4: Final Validation Checklist - All Labs

Complete the comprehensive validation checklist covering all labs (01-04) to confirm successful completion of the entire lab series.

> **✅ Complete Validation**: This step validates **ALL LABS (01-04)** now that time-dependent data is available. Part 1 validated Labs 01-02 only.

**Lab 01 Validation (Scanner Deployment):**

- [ ] Scanner installed and operational on VM
- [ ] Discovery scan completed successfully
- [ ] Sensitive data identified in Finance, HR, and Projects shares
- [ ] Scanner CSV reports generated (DetailedReport, SummaryReport)
- [ ] CSV reports contain file paths, SIT detections, file metadata
- [ ] SQL Express database created for scanner configuration storage
- [ ] Service principal authentication working (Entra ID app registration)

**Lab 02 Validation (DLP Policy Configuration & Enforcement):**

- [ ] DLP policy created: Lab-OnPrem-Sensitive-Data-Protection
- [ ] DLP policy contains 2 rules:
  - [ ] Block-Credit-Card-Access (High severity, Block action, Credit Card SIT)
  - [ ] Audit-SSN-Access (Low severity, Audit action, SSN SIT)
- [ ] DLP policy synced to scanner (no "Sync in progress" message in portal)
- [ ] Scanner DLP enforcement scan completed with `-Reset` parameter
- [ ] Credit card files show "Block" action in DetailedReport CSV
- [ ] SSN files show "Audit" action in DetailedReport CSV
- [ ] "Information Type Name" column populated in scanner reports
- [ ] Activity Explorer shows DLP policy match events (Part 2 validation)
- [ ] Data Classification dashboards show DLP effectiveness (Part 2 validation)

**Lab 03 Validation (Retention Labels - Optional/In Progress):**

> **⏳ Timing Note**: Lab 03 auto-apply policy requires **1-2 days for simulation** and **2-7 days for active label application**. Validation of simulation results is optional for this lab completion. You can check status but it may still be processing.

- [ ] Retention label created: Delete-After-3-Years
  - [ ] Retention period: 3 years from last modified
  - [ ] Action: Delete automatically
- [ ] Auto-apply policy created: Auto-Apply-Delete-After-3-Years
  - [ ] Target: SharePoint Online "All sites" location
  - [ ] Classification Group: Custom Sensitive Info Type group (if created)
  - [ ] OR Template: Custom policy with default templates
- [ ] Auto-apply policy in Simulation Mode (if not yet activated)
  - [ ] Check status: Microsoft Purview portal → Records Management → Label Policies
  - [ ] Simulation results: May show "Processing" or "X items match"
  - [ ] ⏳ Expected timeline: 1-2 days for simulation to complete
- [ ] Auto-apply policy turned on (if simulation validated)
  - [ ] Labels being applied to matching SharePoint files
  - [ ] ⏳ Expected timeline: 2-7 days for labels to appear on files
  - [ ] Verification: View SharePoint test site file properties for label
- [ ] SharePoint test site created with sample files (Step 7)
  - [ ] Optional manual label testing completed
  - [ ] Understanding of on-premises limitation documented

**Lab 04 Part 1 Validation (Scanner Analysis & Remediation Planning):**

- [ ] Scanner reports analyzed (DetailedReport CSV reviewed)
- [ ] Sensitive data distribution understood (Finance: credit cards, HR: SSNs)
- [ ] Old data quantified (3+ year files identified)
- [ ] Remediation candidates CSV exported (RemediationCandidates.csv)
- [ ] Basic remediation patterns practiced:
  - [ ] Pattern 1: Safe deletion with audit trail
  - [ ] Pattern 2: Move files to archive location
  - [ ] Pattern 3: Bulk processing with error handling
  - [ ] Pattern 4: Last access time analysis
- [ ] Draft stakeholder report created with scanner findings
- [ ] Labs 01-02 validation completed in Part 1

**Lab 04 Part 2 Validation (Activity Monitoring & Final Reporting):**

- [ ] Activity Explorer data reviewed (DLP policy matches visible)
- [ ] Activity Explorer export CSV generated and analyzed
- [ ] Data Classification dashboards reviewed:
  - [ ] Top Sensitive Info Types dashboard screenshot captured
  - [ ] Locations with Sensitive Data dashboard screenshot captured
  - [ ] Labeling Status dashboard screenshot captured
  - [ ] DLP Policy Effectiveness dashboard screenshot captured
- [ ] Dashboard summary document created
- [ ] Final stakeholder report completed:
  - [ ] Activity Explorer insights added
  - [ ] Data Classification dashboard metrics added
  - [ ] Report status updated from "DRAFT" to "FINAL"
  - [ ] All appendices attached (screenshots, CSVs, scripts)
- [ ] All labs (01-04) validation checklist completed
- [ ] Final deliverables exported for portfolio use

**Validation Summary:**

```powershell
# Create validation completion summary
$validationSummary = @"
PURVIEW WEEKEND LAB - VALIDATION SUMMARY
=========================================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')

Lab 01 - Scanner Deployment: ✅ COMPLETE
  • Scanner operational
  • Discovery scan successful
  • CSV reports generated

Lab 02 - DLP Policy Enforcement: ✅ COMPLETE
  • DLP policy created and synced
  • Enforcement scan executed
  • Activity Explorer shows DLP matches

Lab 03 - Retention Labels: ⏳ IN PROGRESS (OPTIONAL)
  • Retention label created
  • Auto-apply policy in simulation/activation
  • Timeline: 1-7 days for full processing
  • Note: On-premises limitation understood

Lab 04 Part 1 - Scanner Analysis: ✅ COMPLETE
  • Reports analyzed
  • Old data quantified
  • Remediation patterns practiced
  • Draft report created

Lab 04 Part 2 - Activity Monitoring: ✅ COMPLETE
  • Activity Explorer reviewed
  • Dashboards analyzed
  • Final report completed
  • All validations confirmed

DELIVERABLES COMPLETED
----------------------
✅ Scanner CSV reports (DetailedReport, SummaryReport, DLPReport)
✅ Remediation candidates CSV
✅ Activity Explorer export CSV
✅ Data Classification dashboard screenshots (4 images)
✅ PowerShell script examples (deletion, archiving, bulk processing)
✅ Final stakeholder report (with scanner + monitoring data)
✅ Validation checklist for all labs

NEXT STEP: Environment Cleanup
-------------------------------
Refer to Environment-Cleanup-Guide.md to properly remove all Azure
resources and terminate ongoing costs.
"@

$validationSummary | Out-File "C:\PurviewLab\Validation_Summary.txt" -Encoding UTF8
Write-Host "✅ Validation summary saved" -ForegroundColor Green
Write-Host "`n📚 Next: Review Environment-Cleanup-Guide.md for resource removal" -ForegroundColor Cyan
```

---

## 🧹 Environment Cleanup

> **� Critical Next Step**: After completing this lab and exporting all deliverables, refer to the **[Environment Cleanup Guide](../Environment-Cleanup-Guide.md)** for detailed instructions on removing all Azure resources and Microsoft Purview configurations.

**Cleanup Guide Covers:**

- Azure resource group deletion (VM, SQL, Key Vault, networking)
- Entra ID app registration removal
- Microsoft Purview scanner and policy cleanup
- Cost termination verification
- Complete cleanup checklist

**Why Cleanup is Important:**

- Azure resources generate charges 24/7 until deleted
- Estimated total lab cost for weekend: ~$5-15
- Cleanup typically takes 15-20 minutes
- Proper cleanup ensures $0.00/day ongoing costs

**When to Clean Up:**

- ✅ Lab 04 Part 2 completed
- ✅ Final report saved locally
- ✅ All screenshots and CSVs downloaded
- ✅ Validation summary created
- ✅ Portfolio deliverables exported

> **📖 See**: **[Environment-Cleanup-Guide.md](../Environment-Cleanup-Guide.md)** for step-by-step cleanup procedures

---

## � Real-World Application: Enterprise Cloud Data Governance Tools & Workflows

This lab focused on **monitoring and reporting for cloud-based data governance** using Microsoft Purview's Activity Explorer and Data Classification dashboards. Understanding how these capabilities translate to enterprise production environments is essential for career development in cloud security and compliance roles.

### Cloud vs. On-Premises Data Governance Capabilities

**Critical Platform Advantage - Cloud Native Features:**

| Capability | Cloud (SharePoint, OneDrive, Exchange) | On-Premises File Shares |
|------------|----------------------------------------|------------------------|
| **Activity Explorer** | ✅ Real-time user activity tracking | ⚠️ Limited to scanner service account activity |
| **Data Classification Dashboards** | ✅ Live updates, trend analysis | ⚠️ Delayed updates based on scanner schedule |
| **Auto-Apply Retention** | ✅ Automatic label application | ❌ Not supported (manual scripting required) |
| **DLP Policy Monitoring** | ✅ User context, policy tips, overrides | ⚠️ Scanner-based detection only |
| **Disposition Review** | ✅ Built-in workflows, notifications | ❌ Custom PowerShell workflows needed |

> **🌐 Cloud Advantage**: Microsoft 365 cloud services (SharePoint Online, OneDrive for Business, Exchange Online) provide **native integration** with Microsoft Purview's monitoring and automation features. This lab's Activity Explorer and dashboard capabilities demonstrate the **full potential** available in cloud environments.

### Enterprise Tools for Cloud Data Governance & Monitoring

In production cloud environments, security analysts and compliance officers use Microsoft Purview's monitoring capabilities alongside complementary tools:

| Tool/Platform | Primary Use Case | Cloud Capability |
|---------------|------------------|------------------|
| **Microsoft Purview Activity Explorer** | DLP policy monitoring, user activity tracking, sensitive data access auditing | Real-time event tracking across M365 |
| **Microsoft Purview Data Classification** | Sensitive data distribution dashboards, labeling status, trend analysis | Live dashboard updates |
| **Microsoft Purview Compliance Portal** | Centralized compliance management, alert configuration, disposition review workflows | Unified admin interface |
| **Microsoft Defender for Cloud Apps** | Cloud app monitoring, shadow IT discovery, conditional access policies | CASB functionality |
| **Azure Monitor & Log Analytics** | Advanced query capabilities (KQL), custom dashboards, alert automation | Cross-service correlation |
| **Power BI Compliance Dashboards** | Executive reporting, custom visualizations, trend analysis for leadership | Real-time data connections |
| **ServiceNow/Jira Integration** | Incident management, disposition review ticketing, compliance workflow automation | API-based integrations |

### How Security Analysts Execute Cloud Monitoring & Reporting

**Production Workflow for Cloud Data Governance:**

**Step 1: Automated Monitoring & Alerting**:

- Microsoft Purview continuously monitors M365 services for DLP policy matches and sensitive data changes
- Alerts configured in Compliance Portal trigger notifications for high-severity events
- Example: Credit card detected in SharePoint → Email alert to security team within minutes

**Step 2: Activity Explorer Investigation**:

- Security analysts use Activity Explorer to investigate DLP alerts and user activity
- Filter by user, location, SIT, severity to drill down into specific incidents
- Export CSV for detailed forensic analysis or compliance audit trail

**Step 3: Dashboard Review for Trends**:

- Data Classification dashboards reviewed weekly/monthly for executive reporting
- Identify trends: Increasing sensitive data in specific departments, labeling gaps, policy effectiveness
- Power BI dashboards created for leadership with visualizations from Purview data

**Step 4: Disposition Review Workflows**:

- Retention label policies automatically trigger disposition review when retention period expires
- Compliance officers receive notifications in Purview portal or ServiceNow tickets
- Review workflow: Approve deletion, extend retention, or apply legal hold

**Step 5: Reporting & Continuous Improvement**:

- Stakeholder reports generated quarterly combining Activity Explorer, dashboards, and Power BI insights
- Policy refinements based on false positive rates, user feedback, and business changes
- Metrics tracked: DLP effectiveness, labeling coverage, disposition review completion time

> **💡 Analyst Workflow Note**: In cloud environments, security analysts **rarely execute PowerShell scripts** for data remediation. Instead, they **configure policies** in Microsoft Purview that **automatically enforce** retention, deletion, and access controls. Activity Explorer and dashboards provide the **monitoring layer** to validate policy effectiveness.

### Why Cloud Environments Enable Advanced Governance

**Key Cloud Advantages for Data Governance:**

**Native API Integration:**

- Microsoft 365 services have built-in integration with Purview compliance APIs
- Activity Explorer receives events in real-time without requiring scanner deployments
- Data Classification dashboards update continuously as files are created/modified
- DLP policies enforce at the moment of user action (not batch scans)

**Automatic Label Application:**

- Retention labels apply automatically to matching files within hours
- No PowerShell scripting or server access required
- Disposition review workflows trigger automatically when retention expires
- Users see labels in file properties and receive policy tips in real-time

**User Context & Behavior Analytics:**

- Activity Explorer shows actual user accounts accessing sensitive data
- User behavior patterns detected: Unusual download volumes, policy override attempts
- Integration with Conditional Access: Block risky users automatically
- Insider risk signals incorporated into compliance workflows

**Centralized Management at Scale:**

- Single Purview portal manages policies across SharePoint, OneDrive, Exchange, Teams
- No scanner VMs, SQL databases, or service principal management
- Policy changes propagate to millions of files within hours (not scheduled scans)
- Global tenant coverage without regional scanner clusters

**Migration from On-Premises Often Preferred:**

- Many enterprises migrate file shares to SharePoint Online to gain cloud governance capabilities
- Total Cost of Ownership (TCO) analysis: Cloud automation vs. on-prem manual scripting
- Business case: Reduced IT overhead, improved compliance posture, better user experience
- Example: Company migrates HR file share to SharePoint → Auto-apply retention labels work instantly

### When Cloud Monitoring Tools ARE Used in Production

**Activity Explorer Production Use Cases:**

- **Insider Threat Investigations**: Track which users accessed sensitive files before data breach
- **Compliance Audits**: Export DLP policy match history for auditor review (HIPAA, PCI DSS)
- **Policy Refinement**: Analyze false positive rates and adjust SIT confidence levels
- **Executive Reporting**: Monthly sensitive data access metrics for security leadership

**Data Classification Dashboard Production Use Cases:**

- **Quarterly Business Reviews**: Show labeling coverage progress to executive stakeholders
- **Department-Specific Insights**: Identify which departments generate most sensitive content
- **Migration Validation**: Confirm sensitive data migrated from on-prem to SharePoint retains classifications
- **Trend Analysis**: Detect increasing PII storage in unexpected locations (shadow IT)

**Power BI Integration Production Use Cases:**

- **Executive Dashboards**: Real-time compliance metrics for C-suite and board presentations
- **Anomaly Detection**: Alert when sensitive data volume in specific location spikes unexpectedly
- **Cost Justification**: Demonstrate ROI of Purview investment through automation metrics
- **Regulatory Reporting**: Generate GDPR Article 30 records of processing activities

### Translating Lab Skills to Cloud Production Environments

| Lab Skill | Cloud Production Application |
|-----------|------------------------------|
| **Activity Explorer CSV Export** | Standard practice for compliance audit trail and forensic investigations |
| **Dashboard Screenshot Capture** | Executive reporting in quarterly compliance reviews and board presentations |
| **DLP Policy Match Analysis** | Policy refinement based on false positive rates and business feedback |
| **Sensitive Data Distribution Review** | Department-specific governance planning and risk prioritization |
| **Labeling Status Monitoring** | Track progress toward compliance goals (e.g., "80% labeling by Q4") |
| **PowerShell Report Generation** | Automated monthly/quarterly report generation for stakeholders |
| **Stakeholder Report Creation** | Business communication skill - translating technical findings to executive impact |

### Career Development Path - Cloud Data Governance & Monitoring

**Immediate Next Steps (1-2 months):**

- Complete this lab series and document deliverables in portfolio
- Study for **SC-400: Microsoft Information Protection Administrator** certification
- Practice KQL queries in Azure Monitor for advanced log analysis
- Learn Power BI basics for creating compliance dashboards

**Short-Term Goals (3-6 months):**

- Gain hands-on experience with Microsoft 365 production tenant (if available at work)
- Configure Activity Explorer alerts and investigate sample incidents
- Create custom Data Classification dashboard views for different audiences
- Learn ServiceNow or Jira integration patterns for compliance workflows

**Long-Term Goals (6-12 months):**

- Master Microsoft Purview Information Protection suite (DLP, retention, sensitivity labels, insider risk)
- Understand Microsoft Defender for Cloud Apps for cloud security posture management
- Develop Power BI dashboard skills for executive compliance reporting
- Build expertise in insider threat detection using Activity Explorer behavioral analytics

**Professional Positioning:**

- **Resume Keywords**: "Microsoft Purview Activity Explorer", "Data Classification Dashboards", "DLP Policy Monitoring", "Power BI Compliance Reporting"
- **LinkedIn Skills**: Add "Cloud Data Governance", "Microsoft 365 Compliance", "Insider Risk Management"
- **Portfolio Project**: Include sanitized stakeholder report showing Activity Explorer analysis and dashboard insights
- **Networking**: Join Microsoft Security Community, attend Purview webinars, participate in M365 user groups

### Key Takeaway - Cloud vs. On-Premises Distinction

**Critical Understanding for Enterprise Roles:**

The skills you practiced in this lab—**Activity Explorer analysis, Data Classification dashboard interpretation, and stakeholder reporting**—are **production workflows** for **cloud-based Microsoft 365 environments**. These capabilities represent the **future of data governance** as enterprises migrate from on-premises file shares to SharePoint Online.

**For Cloud (SharePoint, OneDrive, Exchange):**

- Activity Explorer and dashboards are **live monitoring tools** used daily by security analysts
- Automated policy enforcement replaces manual PowerShell scripting
- Compliance officers manage disposition reviews through portal workflows
- Executives receive real-time dashboards showing sensitive data trends

**For On-Premises (Lab 04 Part 1):**

- PowerShell remediation patterns are **production skills** for file share management
- Scanner-based detection with scheduled scans (not real-time monitoring)
- Manual scripting required for data lifecycle operations
- Migration to cloud often preferred to gain automation capabilities

**Career Insight**: Most enterprise data governance roles now focus on **cloud-first strategies** with Microsoft 365 as the primary platform. Understanding both on-premises (Part 1) and cloud (Part 2) approaches positions you for **hybrid environment management** common in large organizations during cloud migration.

---

## �🎯 Lab 04 Part 2 Completion Summary

### What You Accomplished

**Monitoring Analysis Completed:**:

- ✅ Analyzed Activity Explorer for DLP policy effectiveness
- ✅ Reviewed Data Classification dashboards for sensitive data trends
- ✅ Exported and analyzed monitoring data CSVs
- ✅ Captured dashboard screenshots for documentation

**Final Deliverables Created:**:

- ✅ Activity Explorer export CSV with DLP policy match events
- ✅ Data Classification dashboard screenshots (4 images)
- ✅ Dashboard summary document with key metrics
- ✅ **Final stakeholder report** (updated from Part 1 draft with monitoring data)
- ✅ Validation summary confirming all labs (01-04) complete
- ✅ Cleanup summary documenting environment termination

**Environment Management:**:

- ✅ Azure resource group deleted (all resources removed)
- ✅ Entra ID app registration removed
- ✅ Purview scanner configurations deleted
- ✅ Optional: DLP policy, retention labels, SharePoint test site removed
- ✅ Cost termination verified ($0.00/day ongoing charges)

**Skills Developed:**:

- ✅ Activity Explorer analysis and interpretation
- ✅ Data Classification dashboard reading
- ✅ Stakeholder report finalization with monitoring insights
- ✅ Complete lab validation across multi-day time windows
- ✅ Proper Azure resource cleanup and cost management

---

## 🎓 Complete Lab Series Summary

### All Labs Completed

**Lab 01 - Scanner Deployment**: ✅ COMPLETE

- Deployed Microsoft Purview Information Protection Scanner
- Executed discovery scan on on-premises file shares
- Generated CSV reports with sensitive data findings

**Lab 02 - DLP Policy Enforcement**: ✅ COMPLETE

- Created DLP policy with block and audit rules
- Executed enforcement scan with DLP integration
- Verified credit card blocking and SSN auditing

**Lab 03 - Retention Labels**: ⏳ OPTIONAL/IN PROGRESS

- Created auto-apply retention label for data lifecycle management
- Deployed to SharePoint Online (on-prem limitation understood)
- Simulation/activation processing (1-7 day timeline)

**Lab 04 Part 1 - Scanner Analysis**: ✅ COMPLETE

- Analyzed scanner reports for sensitive data distribution
- Quantified old data (3+ years) for remediation
- Practiced PowerShell remediation patterns
- Created draft stakeholder report

**Lab 04 Part 2 - Activity Monitoring**: ✅ COMPLETE

- Analyzed Activity Explorer for DLP effectiveness
- Reviewed Data Classification dashboards
- Finalized stakeholder report with monitoring data
- Validated all labs and cleaned up environment

### Portfolio-Ready Deliverables

**Technical Artifacts:**

- Scanner deployment documentation and CSV reports
- DLP policy configuration and enforcement results
- Retention label configuration (auto-apply strategy)
- PowerShell remediation scripts (4 patterns)
- Activity Explorer analysis and exports
- Data Classification dashboard screenshots

**Business Deliverables:**

- Executive stakeholder report with scanner + monitoring data
- Remediation opportunity analysis (3+ year old files)
- Compliance metrics (DLP effectiveness, labeling status)
- Cost analysis and recommendations
- Production deployment roadmap

**Demonstrated Skills:**

- Microsoft Purview deployment and configuration
- Information protection scanner implementation
- DLP policy creation and enforcement
- Retention label auto-apply strategies
- PowerShell automation for data remediation
- Activity monitoring and compliance reporting
- Azure resource management and cost optimization

### Real-World Application

**What You've Proven:**

1. **Technical Capability**: Deployed enterprise data governance stack in weekend timeframe
2. **Business Acumen**: Identified remediation opportunities and quantified value
3. **Compliance Understanding**: DLP enforcement for PCI DSS (credit cards) and PII (SSNs)
4. **Automation Skills**: PowerShell patterns for safe, auditable data operations
5. **Communication**: Executive stakeholder report translating technical findings to business impact

**Next Steps for Career Development:**

- **Resume/LinkedIn**: Add "Microsoft Purview Information Protection" to skills
- **Portfolio**: Include sanitized stakeholder report as work sample
- **Certifications**: Consider [SC-400: Microsoft Information Protection Administrator](https://learn.microsoft.com/en-us/certifications/exams/sc-400)
- **Blog Post**: Document your weekend lab experience and lessons learned
- **GitHub**: Publish PowerShell remediation scripts (sanitize any sensitive references)

---

## 📚 Reference Documentation

- [Activity Explorer Documentation](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)
- [Data Classification Dashboards](https://learn.microsoft.com/en-us/purview/data-classification-overview)
- [DLP Policy Monitoring](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp#monitoring-dlp-policies)
- [Azure Resource Management - Cleanup](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)

---

## 🤖 AI-Assisted Content Generation

This comprehensive lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview Activity Explorer analysis, Data Classification dashboard interpretation, stakeholder reporting finalization, and Azure resource cleanup procedures based on current documentation as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of monitoring data analysis, compliance reporting, validation procedures, and environment cleanup while maintaining technical accuracy and alignment with enterprise data governance practices.*

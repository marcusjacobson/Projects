# Lab 04: Validation & Reporting

## 📋 Overview

**Duration**: 1-2 hours

**Objective**: Consolidate findings from Labs 01-03, analyze scanner reports and Activity Explorer data, create stakeholder-ready remediation reports, and execute complete environment cleanup.

**What You'll Learn:**
- Analyze scanner CSV reports for sensitive data findings
- Use Activity Explorer for compliance and DLP monitoring
- Explore Data Estate Insights dashboards
- Create professional stakeholder reports
- Quantify remediation opportunities (3+ year old data)
- Execute complete Azure resource cleanup

**Prerequisites from Labs 01-03:**
- ✅ Scanner deployed and discovery/enforcement scans completed
- ✅ DLP policies configured and enforced
- ✅ Retention labels created (understanding SharePoint vs. on-prem limitations)
- ✅ Sample data scanned with sensitive data findings

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

1. Analyze scanner CSV reports to identify sensitive data distribution
2. Use Activity Explorer filters to monitor DLP and discovery activity
3. Navigate Data Estate Insights for data classification overview
4. Quantify old data (3+ years) eligible for remediation
5. Create executive-level summary reports for stakeholders
6. Compile actionable recommendations for consultancy project
7. Execute complete cleanup of all Azure lab resources

---

## 📖 Step-by-Step Instructions

### Step 1: Review Scanner Reports

Scanner reports provide detailed file-level information about discovered sensitive data, DLP matches, and label application.

**On VM, Navigate to Scanner Reports:**

```powershell
# Navigate to scanner reports directory
Set-Location "$env:LOCALAPPDATA\Microsoft\MSIP\Scanner\Reports"

# List all available reports sorted by date
Get-ChildItem -Filter "*.csv" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object Name, LastWriteTime, @{N='Size(MB)';E={[math]::Round($_.Length/1MB,2)}}
```

**Key Report Types:**

1. **DetailedReport_*.csv**: Comprehensive file-by-file scan results
2. **SummaryReport_*.csv**: High-level statistics and counts
3. **DLPReport_*.csv**: DLP-specific findings (if DLP enabled)

**Open Latest Detailed Report:**

```powershell
# Open most recent detailed report in default CSV viewer (Excel)
$latestDetailedReport = Get-ChildItem -Filter "DetailedReport*.csv" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1
Invoke-Item $latestDetailedReport.FullName
```

**Key Columns to Review:**

| Column Name | Purpose | Example Values |
|-------------|---------|----------------|
| **File Path** | Full UNC path to scanned file | `\\vm-purview-scanner\Finance\CustomerPayments.txt` |
| **Sensitive Information Types** | Which SITs were detected | Credit Card Number, SSN |
| **SIT Count** | Number of SIT instances | 5 credit cards, 10 SSNs |
| **Last Modified** | File modification timestamp | 2021-01-15 (3+ years old) |
| **File Size** | Size in bytes/KB | 45 KB |
| **Owner** | File owner/creator | DOMAIN\user or UPN |
| **DLP Policy Matched** | Which DLP policy matched | Lab-OnPrem-Sensitive-Data-Protection |
| **DLP Rule Matched** | Specific DLP rule triggered | Block-Credit-Card-Access |
| **DLP Action** | Action taken by DLP | Block, Audit |
| **Label Applied** | Retention/sensitivity label | Delete-After-3-Years (if applicable) |

**Analysis Questions:**

1. **How many files contain sensitive data?**
   - Count rows where "Sensitive Information Types" is not empty

2. **Which SITs are most common?**
   - Group by SIT type and count occurrences

3. **Where is sensitive data concentrated?**
   - Analyze file paths to identify high-risk folders (Finance, HR)

4. **How many files are 3+ years old?**
   - Filter by Last Modified date < 3 years ago

**PowerShell Analysis Example:**

```powershell
# Import latest detailed report
$report = Import-Csv $latestDetailedReport.FullName

# Count files with sensitive data
$sensitiveFiles = $report | Where-Object {$_.'Sensitive Information Types' -ne ''}
Write-Host "Files with Sensitive Data: $($sensitiveFiles.Count)" -ForegroundColor Cyan

# Group by SIT type
$sitCounts = $sensitiveFiles | 
    Group-Object 'Sensitive Information Types' | 
    Select-Object Name, Count | 
    Sort-Object Count -Descending
Write-Host "`nSensitive Information Types Found:" -ForegroundColor Yellow
$sitCounts | Format-Table -AutoSize

# Files older than 3 years
$cutoffDate = (Get-Date).AddYears(-3)
$oldFiles = $report | Where-Object {
    try { [DateTime]$_.'Last Modified' -lt $cutoffDate } catch { $false }
}
Write-Host "`nFiles Older Than 3 Years: $($oldFiles.Count)" -ForegroundColor Magenta

# DLP enforcement summary
$dlpBlocked = $report | Where-Object {$_.'DLP Action' -eq 'Block'}
$dlpAudited = $report | Where-Object {$_.'DLP Action' -eq 'Audit'}
Write-Host "`nDLP Enforcement Summary:" -ForegroundColor Green
Write-Host "  Blocked Files: $($dlpBlocked.Count)"
Write-Host "  Audited Files: $($dlpAudited.Count)"
```

---

### Step 2: Activity Explorer Analysis

Activity Explorer provides comprehensive monitoring of DLP matches, label application, and user activity across Purview-protected locations.

**Navigate to Activity Explorer:**

- Open browser and go to the **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com)
- Sign in with your **admin account**
- Navigate to **Solutions** > **Data classification** > **Activity explorer**

> **💡 Portal Note**: The Microsoft Purview portal interface was redesigned in 2024. Activity Explorer is now accessed through Solutions > Data classification > Activity explorer. The steps below reflect the current portal as of October 2025.

**Configure Filters for Comprehensive Analysis:**

**Filter 1: All On-Premises Activity**

- **Location**: Select **On-premises repositories**
- **Date range**: **Last 7 days** (or custom range covering your scans)
- **Activity type**: **All** (to see discovery and DLP activity)
- Click **Refresh** or **Apply filters**

**Review Key Metrics:**

Activity Explorer dashboard shows:

1. **Total Activities**: Count of all scanned/accessed files
2. **Files with Sensitive Data**: Files matching SIT patterns
3. **DLP Policy Matches**: Files triggering DLP rules
4. **Top Sensitive Info Types**: Most frequently detected SITs
5. **Top Users**: Users accessing sensitive files (if user context available)
6. **Top Locations**: File shares with most activity

**Filter 2: DLP-Specific Activity**

- **DLP policy**: Select **Lab-OnPrem-Sensitive-Data-Protection**
- **DLP action**: Filter by **Block** or **Audit** to see enforcement
- **Activity type**: **DLP policy matched**
- Review which files were blocked vs. audited

**Filter 3: Sensitive Data Discovery**

- **Location**: **On-premises repositories**
- **Sensitive info types**: Select **Credit Card Number**, **SSN**
- Review distribution of sensitive data across repositories

**Export Activity Data:**

- Click **Export** button (top right)
- Format: **CSV**
- Use for:
  - Executive reporting
  - Compliance documentation
  - Trend analysis over time
  - Stakeholder presentations

```powershell
# After exporting, analyze in PowerShell
$activityData = Import-Csv "C:\Users\Admin\Downloads\ActivityExplorer_Export.csv"

# Count by activity type
$activityData | Group-Object 'Activity type' | Select-Object Name, Count | Format-Table -AutoSize

# Count by sensitive info type
$activityData | Group-Object 'Sensitive info type' | Select-Object Name, Count | Format-Table -AutoSize
```

---

### Step 3: Data Estate Insights

Data Estate Insights provides high-level dashboards for data classification and governance posture.

**Navigate to Data Classification Overview:**

- Microsoft Purview portal: [https://purview.microsoft.com](https://purview.microsoft.com)
- Navigate to **Solutions** > **Data classification** > **Overview**
  - Select **Solutions** > **Data classification**
  - Click **Overview** from the left menu

> **💡 Portal Note**: The Data Classification dashboard provides aggregated views of sensitive data discovery across your Microsoft 365 environment, including on-premises repositories scanned by the Information Protection Scanner.

**Key Dashboards to Review:**

**Dashboard 1: Top Sensitive Info Types**

- **Purpose**: Shows which SITs are most prevalent in your environment
- **Insight**: Identify highest-risk data types
- **Expected for Lab**: Credit Card Number, SSN, Email Address

**Dashboard 2: Locations with Sensitive Data**

- **Purpose**: Geographic/logical distribution of sensitive data
- **Insight**: Identify high-risk repositories
- **Expected for Lab**: 
  - \\vm-purview-scanner\Finance (credit cards)
  - \\vm-purview-scanner\HR (SSNs)
  - Azure Files share (cloud data)

**Dashboard 3: Labeling Status**

- **Purpose**: Percentage of files with sensitivity/retention labels
- **Insight**: Measure governance coverage
- **Expected for Lab**: Low percentage (lab environment, limited label application)

**Dashboard 4: DLP Policy Effectiveness**

- **Purpose**: DLP matches over time, policy coverage
- **Insight**: Measure DLP policy impact
- **Expected for Lab**: Matches corresponding to Finance and HR files

**Dashboard 5: Trends Over Time**

- **Purpose**: Historical data classification trends
- **Insight**: Track improvement in data governance
- **Expected for Lab**: Limited trend data (weekend lab, short timeframe)

**Take Screenshots:**

For stakeholder reporting:

- Screenshot each dashboard
- Highlight key metrics (total files scanned, sensitive files found, DLP matches)
- Use in final summary report

---

### Step 4: Quantify Old Data for Remediation

Based on the consultancy project requirement to identify and remediate 3+ year old data.

**Calculate Remediation Opportunities:**

```powershell
# On VM, analyze files by age
$shares = @(
    "\\vm-purview-scanner\Finance",
    "\\vm-purview-scanner\HR",
    "\\vm-purview-scanner\Projects"
)

$cutoffDate = (Get-Date).AddYears(-3)
$remediationCandidates = @()

foreach ($share in $shares) {
    $oldFiles = Get-ChildItem -Path $share -Recurse -File -ErrorAction SilentlyContinue | 
        Where-Object {$_.LastWriteTime -lt $cutoffDate}
    
    foreach ($file in $oldFiles) {
        $remediationCandidates += [PSCustomObject]@{
            FilePath = $file.FullName
            LastModified = $file.LastWriteTime
            Age_Days = ((Get-Date) - $file.LastWriteTime).Days
            Age_Years = [math]::Round(((Get-Date) - $file.LastWriteTime).Days / 365, 1)
            SizeMB = [math]::Round($file.Length / 1MB, 2)
            Share = $share.Split('\')[-1]
        }
    }
}

# Summary statistics
$totalOldFiles = $remediationCandidates.Count
$totalSizeMB = ($remediationCandidates | Measure-Object -Property SizeMB -Sum).Sum
$avgAgeYears = [math]::Round(($remediationCandidates | Measure-Object -Property Age_Years -Average).Average, 1)

Write-Host "`n========== REMEDIATION OPPORTUNITY ANALYSIS ==========" -ForegroundColor Cyan
Write-Host "Total Files Older Than 3 Years: $totalOldFiles" -ForegroundColor Yellow
Write-Host "Total Size: $([math]::Round($totalSizeMB, 2)) MB" -ForegroundColor Yellow
Write-Host "Average Age: $avgAgeYears years" -ForegroundColor Yellow
Write-Host "`nBreakdown by Share:" -ForegroundColor Green
$remediationCandidates | Group-Object Share | 
    Select-Object Name, Count, @{N='TotalSizeMB';E={[math]::Round(($_.Group | Measure-Object -Property SizeMB -Sum).Sum, 2)}} |
    Format-Table -AutoSize

# Export for reporting
$remediationCandidates | Export-Csv "C:\PurviewLab\RemediationCandidates.csv" -NoTypeInformation
Write-Host "`nRemediation candidates exported to: C:\PurviewLab\RemediationCandidates.csv" -ForegroundColor Cyan
```

**Remediation Recommendations:**

Based on the analysis:

1. **Delete**: Files with no business value, past retention requirements
2. **Archive**: Files with historical value, low access frequency → Move to cold storage (Azure Archive tier)
3. **Retain with Labels**: Files subject to legal/compliance requirements → Apply retention labels

---

### Step 4B: Basic Remediation Scripting Patterns

Before implementing complex production scenarios, practice these fundamental remediation patterns.

> **💡 Core Skill**: These PowerShell patterns form the foundation for any data remediation project. Master these basics before moving to advanced automation in Lab 05.

**Pattern 1: Safe File Deletion with Audit Trail**

```powershell
# Always test with -WhatIf first
$testFile = "\\vm-purview-scanner\Projects\OldProjectPlan.xlsx"

# Create deletion log BEFORE removing file
$logEntry = [PSCustomObject]@{
    FilePath = $testFile
    DeletedOn = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    DeletedBy = $env:USERNAME
    Reason = "Lab testing - 3+ years old"
    FileSize = (Get-Item $testFile).Length
    LastModified = (Get-Item $testFile).LastWriteTime
}

# Export to audit log
$logEntry | Export-Csv "C:\PurviewLab\DeletionAudit.csv" -Append -NoTypeInformation

# Delete file (test with -WhatIf first)
# Remove-Item $testFile -WhatIf
Remove-Item $testFile -Force -Verbose

Write-Host "✅ File deleted and logged" -ForegroundColor Green
```

**Pattern 2: Move Files to Archive Location**

```powershell
# Archive old files instead of deleting
$sourceFile = "\\vm-purview-scanner\HR\EmployeeRecords2020.xlsx"
$archiveRoot = "\\vm-purview-scanner\Archive"

# Create archive folder structure (preserves original paths)
$relativePath = $sourceFile.Replace("\\vm-purview-scanner\", "")
$archivePath = Join-Path $archiveRoot $relativePath
$archiveFolder = Split-Path $archivePath -Parent

# Create folder if doesn't exist
if (-not (Test-Path $archiveFolder)) {
    New-Item -ItemType Directory -Path $archiveFolder -Force | Out-Null
}

# Move file
Move-Item -Path $sourceFile -Destination $archivePath -Force -Verbose
Write-Host "✅ File archived to: $archivePath" -ForegroundColor Green
```

**Pattern 3: Bulk Processing with Error Handling**

```powershell
# Process multiple files with proper error handling
$filesToProcess = @(
    "\\vm-purview-scanner\Finance\OldInvoice.pdf",
    "\\vm-purview-scanner\Projects\ArchivedNotes.txt"
)

$results = @()

foreach ($file in $filesToProcess) {
    try {
        # Verify file exists
        if (-not (Test-Path $file)) {
            throw "File not found"
        }
        
        # Get file info
        $fileInfo = Get-Item $file
        
        # Perform operation (example: archive)
        # Move-Item $file -Destination "\\archive\path" -Force
        
        # Log success
        $results += [PSCustomObject]@{
            File = $file
            Status = "Success"
            Action = "Archived"
            Error = $null
        }
        
        Write-Host "✅ Processed: $file" -ForegroundColor Green
        
    } catch {
        # Log failure
        $results += [PSCustomObject]@{
            File = $file
            Status = "Failed"
            Action = "None"
            Error = $_.Exception.Message
        }
        
        Write-Warning "Failed to process $file: $_"
    }
}

# Export results
$results | Export-Csv "C:\PurviewLab\ProcessingResults.csv" -NoTypeInformation
Write-Host "`nProcessing complete. Results exported." -ForegroundColor Cyan
```

**Pattern 4: Last Access Time Analysis**

```powershell
# Compare Last Modified vs Last Access Time
$share = "\\vm-purview-scanner\Projects"

# Enable last access time tracking (run once on file server)
# fsutil behavior set disablelastaccess 0

# Find files with access/modify time discrepancy
$files = Get-ChildItem -Path $share -Recurse -File -ErrorAction SilentlyContinue

$accessAnalysis = $files | ForEach-Object {
    [PSCustomObject]@{
        FileName = $_.Name
        Path = $_.FullName
        LastAccess = $_.LastAccessTime
        LastModified = $_.LastWriteTime
        AccessAgeDays = ((Get-Date) - $_.LastAccessTime).Days
        ModifyAgeDays = ((Get-Date) - $_.LastWriteTime).Days
        Discrepancy = ((Get-Date) - $_.LastAccessTime).Days - ((Get-Date) - $_.LastWriteTime).Days
    }
}

# Show files accessed recently but modified long ago (indicates active use)
$accessAnalysis | Where-Object {$_.AccessAgeDays -lt 365 -and $_.ModifyAgeDays -gt 1095} |
    Select-Object FileName, AccessAgeDays, ModifyAgeDays, Discrepancy |
    Format-Table -AutoSize

Write-Host "Files recently accessed but not modified in 3+ years (should NOT delete)" -ForegroundColor Yellow
```

> **🎯 Key Takeaway**: These four patterns are the building blocks for all remediation projects:
> 1. **Audit Trail** - Always log what you delete
> 2. **Archive** - Move before deleting (safer, reversible)
> 3. **Error Handling** - Process thousands of files reliably
> 4. **Access Time** - Identify truly unused files vs. read-only usage

> **📚 Next Step**: Lab 05 builds on these patterns to create production-ready, multi-tier remediation automation specific to your consultancy project requirements.

---

### Step 5: Create Summary Report for Stakeholders

Compile findings into an executive summary report for consultancy project presentation.

**Purview Weekend Lab - Remediation Report Template:**

```text
=============================================================================
PURVIEW WEEKEND LAB - DATA GOVERNANCE & REMEDIATION REPORT
=============================================================================

EXECUTIVE SUMMARY
-----------------
This report summarizes findings from a weekend lab deployment of Microsoft 
Purview Information Protection Scanner, DLP policies, and retention labels 
for on-premises file share data governance.

ENVIRONMENT DETAILS
-------------------
Scan Date: [Date of Labs 01-02 scans]
Repositories Scanned:
  - \\vm-purview-scanner\Finance (SMB share)
  - \\vm-purview-scanner\HR (SMB share)
  - \\vm-purview-scanner\Projects (SMB share)
  - Azure Files share (cloud simulation)

Scanner Configuration:
  - Microsoft Purview Information Protection Scanner
  - Unified Labeling Client
  - SQL Express backend for configuration storage
  - Service principal authentication (Entra ID app registration)

DISCOVERY SUMMARY
-----------------
Total Files Scanned: [X] (from scanner reports)
Files with Sensitive Data: [Y] (from DetailedReport CSV)

Sensitive Information Types Found:
  • Credit Card Numbers: [count] files, [total instances]
  • U.S. Social Security Numbers (SSN): [count] files, [total instances]
  • Email Addresses: [count] files, [total instances]
  • Other PII: [count if applicable]

Distribution by Repository:
  • Finance Share: [X] files with sensitive data (primarily credit cards)
  • HR Share: [Y] files with sensitive data (primarily SSNs)
  • Projects Share: [Z] files with sensitive data
  • Azure Files: [A] files with sensitive data

DATA AGE ANALYSIS
-----------------
Files Older Than 3 Years: [count]
Total Size of Old Files: [XX] MB
Average Age of Old Files: [X.X] years
Oldest File Found: [filename], Last Modified: [date]

Remediation Opportunity:
  • Deletion Candidates: [X] files with no retention requirements
  • Archive Candidates: [Y] files with low access, historical value
  • Retention Label Candidates: [Z] files requiring compliance retention

DLP ENFORCEMENT SUMMARY
-----------------------
DLP Policy: Lab-OnPrem-Sensitive-Data-Protection
Policy Status: Active (Enforcement Mode / Test Mode)

DLP Rules Applied:
  1. Block-Credit-Card-Access
     - Files Matched: [X]
     - Action: Block access to everyone
     - Status: [X] files blocked from access
  
  2. Audit-SSN-Access
     - Files Matched: [Y]
     - Action: Audit only (access allowed, logged)
     - Status: [Y] files audited

Total DLP Actions Taken:
  • Files Blocked: [X]
  • Files Audited: [Y]
  • User Notifications Sent: [Z] (if enabled)
  • Admin Incident Reports: [A] (if enabled)

Activity Explorer Insights:
  • Total DLP policy matches: [X]
  • On-premises repository activity: [Y] events
  • Users accessing sensitive data: [Z] (if user context available)

RETENTION LABEL IMPLEMENTATION
-------------------------------
Retention Label: Delete-After-3-Years
Configuration:
  • Retention Period: 3 years from last modified date
  • Action: Automatic deletion
  • Locations: SharePoint Online (auto-apply not supported for on-prem)

SharePoint Testing Results:
  • Test Site: [Site name]
  • Files Uploaded: [X] with sensitive data
  • Labels Applied: [Y] (manual or auto-apply after processing)
  • Auto-Apply Policy: [Processing / Completed / Simulation mode]

On-Premises Limitation:
  ⚠️ Auto-apply retention labels DO NOT support on-premises file shares.
  Workaround: PowerShell scripting for bulk file operations based on age.

COMPLIANCE & GOVERNANCE METRICS
--------------------------------
Data Classification Coverage:
  • Files Classified: [X]% of total scanned files
  • Files with DLP Protection: [Y]% of sensitive files
  • Files with Retention Labels: [Z]% (SharePoint only for this lab)

Risk Mitigation:
  • High-Risk Files (Credit Cards) Blocked: [X] files
  • Medium-Risk Files (SSN) Audited: [Y] files
  • Old Data Identified for Remediation: [Z] files (3+ years)

RECOMMENDATIONS
---------------
1. Production Deployment Strategy:
   - Pilot Purview scanner on 1-2 high-risk file shares
   - Start with discovery mode (no DLP enforcement) for 2 weeks
   - Analyze findings and refine DLP policies
   - Phase in enforcement mode incrementally

2. Data Remediation Priorities:
   - Immediate: Delete files > 5 years old with no retention requirements
   - Short-term (30 days): Archive files 3-5 years old to cold storage
   - Ongoing: Apply retention labels to files with compliance requirements

3. DLP Policy Tuning:
   - Review blocked files for false positives
   - Adjust Credit Card rule if legitimate business files blocked
   - Consider exception groups for authorized users
   - Add additional SITs based on business requirements (GDPR, PHI, etc.)

4. On-Premises File Lifecycle Management:
   - Evaluate cloud migration to SharePoint for full retention capabilities
   - Implement PowerShell automation for old file identification
   - Consider Azure Files for hybrid storage with lifecycle policies

5. Stakeholder Communication:
   - Share Activity Explorer reports monthly for transparency
   - Provide DLP effectiveness metrics to security team
   - Report storage savings from old file remediation to finance

NEXT STEPS FOR CONSULTANCY PROJECT
-----------------------------------
Based on this lab, recommended approach for real-world implementation:

Phase 1 - Discovery (Weeks 1-2):
  ✓ Deploy scanner on production file servers (read-only)
  ✓ Run discovery scans to identify sensitive data distribution
  ✓ Analyze findings and create data classification inventory

Phase 2 - Policy Development (Weeks 3-4):
  ✓ Create DLP policies based on discovered SITs
  ✓ Configure audit-only rules for initial deployment
  ✓ Test policies in simulation mode
  ✓ Refine policies based on stakeholder feedback

Phase 3 - Enforcement (Weeks 5-6):
  ✓ Enable DLP enforcement for high-risk data (credit cards, SSNs)
  ✓ Monitor Activity Explorer for false positives
  ✓ Adjust policies as needed
  ✓ Communicate changes to end users

Phase 4 - Remediation (Weeks 7-8):
  ✓ Identify files > 3 years old using PowerShell analysis
  ✓ Coordinate with business owners for deletion approval
  ✓ Execute bulk file operations (delete, archive, migrate)
  ✓ Measure storage savings and compliance improvement

Phase 5 - Cloud Migration (Weeks 9-12):
  ✓ Migrate high-value data to SharePoint Online
  ✓ Apply retention labels via auto-apply policies
  ✓ Implement automated data lifecycle management
  ✓ Decommission legacy on-premises shares

COST SAVINGS PROJECTION
------------------------
Based on lab findings extrapolated to production environment:

Storage Optimization:
  • Old files identified: [X]% of total storage
  • Projected deletion: [Y] GB
  • Azure storage cost savings: $[Z]/month (based on Azure pricing)
  • On-premises storage reclaimed: [A] TB

Compliance Risk Reduction:
  • Sensitive files secured with DLP: [X] files
  • Reduced exposure to data breaches
  • Improved audit readiness for compliance frameworks

Operational Efficiency:
  • Automated scanning replaces manual data discovery
  • DLP enforcement reduces user error incidents
  • Retention automation reduces manual file management

APPENDICES
----------
Appendix A: Scanner CSV Reports (DetailedReport_*.csv)
Appendix B: Activity Explorer Exports (ActivityExplorer_Export.csv)
Appendix C: Remediation Candidates List (RemediationCandidates.csv)
Appendix D: Data Estate Insights Screenshots
Appendix E: DLP Policy Configurations
Appendix F: Retention Label Policies

REPORT PREPARED BY
------------------
[Your Name]
Purview Weekend Lab Project
Date: [Report Date]

Tools Used: Microsoft Purview, Information Protection Scanner, Activity Explorer
AI Assistance: GitHub Copilot for documentation and automation scripts
=============================================================================
```

**Customize the Template:**

- Replace `[X]`, `[Y]`, `[Z]` with actual numbers from your lab findings
- Add specific file names and paths as examples
- Include screenshots from Activity Explorer and Data Estate Insights
- Attach CSV exports as appendices

**Export Report:**

```powershell
# Save report template to file
$reportPath = "C:\PurviewLab\Final_Remediation_Report.txt"
# [Paste template content here and save]
Write-Host "Report saved to: $reportPath" -ForegroundColor Green
```

---

### Step 6: Validation Checklist

Complete this final validation to ensure all labs were successful:

**Lab 01 Validation:**
- [ ] Scanner installed and operational
- [ ] Discovery scan completed
- [ ] Sensitive data identified in Finance and HR shares
- [ ] Scanner CSV reports generated

**Lab 02 Validation:**
- [ ] DLP policy created with 2 rules (Block, Audit)
- [ ] Scanner DLP enforcement scan completed
- [ ] Credit card files blocked
- [ ] SSN files audited
- [ ] Activity Explorer showing DLP matches

**Lab 03 Validation:**
- [ ] Retention label created (Delete-After-3-Years)
- [ ] Auto-apply policy configured
- [ ] SharePoint testing completed (or limitation understood)
- [ ] Manual label application successful

**Lab 04 Validation:**
- [ ] Scanner reports analyzed
- [ ] Activity Explorer data reviewed
- [ ] Data Estate Insights explored
- [ ] Old data quantified (3+ year analysis)
- [ ] Summary report created for stakeholders
- [ ] All validation items checked

---

### Step 7: Environment Cleanup

Execute complete cleanup of all Azure resources to avoid unnecessary costs after lab completion.

**Cleanup Checklist:**

**Azure Resources:**

```bash
# From local machine with Azure CLI authenticated
az login

# Delete resource group (removes VM, storage, networking)
az group delete --name rg-purview-lab --yes --no-wait

# Verify deletion
az group list --query "[?name=='rg-purview-lab']" --output table
```

Or via **Azure Portal:**

- Navigate to **Resource Groups**
- Select `rg-purview-lab`
- Click **Delete resource group**
- Type resource group name to confirm: `rg-purview-lab`
- Click **Delete**
- Deletion takes 5-10 minutes

**Entra ID Cleanup:**

**Remove App Registration:**

- Azure Portal > **Microsoft Entra ID** > **App registrations**
- Find **Purview-Scanner-App**
- Click on the app
- Click **Delete**
- Confirm deletion

**Remove Scanner Service Account (Optional):**

- Azure Portal > **Microsoft Entra ID** > **Users**
- Find **scanner-svc**
- Click on the user
- Click **Delete**
- Confirm deletion

> **💡 Tip**: You may want to keep the scanner-svc account if you plan to repeat the lab or use it for future Purview testing.

**Purview Configuration Cleanup:**

**Remove Scanner Cluster:**

- Open browser and go to the **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com)
- Navigate to **Settings** > **Information protection** > **Information protection scanner**
- Select the **Clusters** tab
- Select **Lab-Scanner-Cluster**
- Click **Delete**
- Confirm deletion

**Remove Content Scan Job:**

- **Content scan jobs** tab
- Select **Lab-OnPrem-Scan**
- Click **Delete**
- Confirm deletion

**Remove DLP Policy (Optional):**

- Purview Portal > **Solutions** > **Data loss prevention** > **Policies**
- Find **Lab-OnPrem-Sensitive-Data-Protection**
- Click **Delete** or **Turn off** if you want to preserve for future reference

**Remove Retention Label Policy (Optional):**

- Purview Portal > **Data lifecycle management** > **Label policies**
- Find **Auto-Delete-Old-Sensitive-Files**
- Click **Delete** or disable

**SharePoint Test Site Cleanup (Optional):**

- Navigate to SharePoint site: https://[tenant].sharepoint.com/sites/[site-name]
- **Settings** (gear icon) > **Site settings**
- **Site Administration** > **Delete this site**
- Confirm deletion

Or keep for future testing.

**E5 Compliance Trial:**

- Trial automatically expires after 30 days
- No manual cancellation needed
- Data and configurations are retained but features become unavailable

**VM Cleanup Verification:**

After resource group deletion, verify VM and associated resources removed:

```bash
# Verify VM deleted
az vm list --resource-group rg-purview-lab --output table
# Should return empty result

# Verify storage account deleted
az storage account list --resource-group rg-purview-lab --output table
# Should return empty result
```

**Cost Verification:**

- Azure Portal > **Cost Management + Billing** > **Cost analysis**
- Filter by resource group: `rg-purview-lab`
- Verify costs stopped accruing after deletion
- Total lab costs should be approximately $10-15 for weekend usage

---

## ✅ Final Validation Checklist

Confirm successful completion of all 4 labs:

### Lab 00 - Environment Setup
- [x] Azure VM deployed with SQL Express
- [x] SMB shares created with sample sensitive data
- [x] Azure Files configured
- [x] Entra ID service account provisioned
- [x] E5 Compliance trial activated

### Lab 01 - Scanner Deployment
- [x] Information Protection client installed
- [x] App registration created with API permissions
- [x] Scanner cluster and content scan job configured
- [x] Discovery scan completed successfully
- [x] CSV reports showing sensitive data findings

### Lab 02 - DLP Configuration
- [x] DLP policy created with 2 rules
- [x] DLP enabled in scanner scan job
- [x] Enforcement scan completed
- [x] Credit card files blocked, SSN files audited
- [x] Activity Explorer showing DLP matches

### Lab 03 - Retention Labels
- [x] Retention label created (3-year deletion)
- [x] Auto-apply policy configured
- [x] SharePoint testing completed
- [x] On-premises limitations understood
- [x] Workaround strategies identified

### Lab 04 - Validation & Reporting
- [x] Scanner reports analyzed comprehensively
- [x] Activity Explorer data reviewed
- [x] Data Estate Insights explored
- [x] Old data quantified (3+ year analysis)
- [x] Stakeholder report created
- [x] Complete environment cleanup executed

### Consultancy Project Readiness
- [x] Understanding of Purview scanner capabilities
- [x] DLP policy configuration expertise
- [x] Retention label knowledge (with platform limitations)
- [x] Data remediation strategy developed
- [x] Stakeholder reporting template ready
- [x] Phase-based implementation plan created

---

## 🎯 Key Learning Outcomes

After completing all 4 labs, you have gained:

1. **Scanner Deployment Expertise**: Full understanding of Information Protection Scanner architecture, authentication, and repository configuration

2. **DLP Policy Management**: Ability to create, configure, and enforce DLP policies for on-premises repositories with appropriate testing strategies

3. **Retention Label Knowledge**: Understanding of retention label capabilities, auto-apply policies, and critical platform limitations (SharePoint vs. on-prem)

4. **Data Discovery & Classification**: Skills to identify sensitive data distribution, quantify old data, and prioritize remediation efforts

5. **Compliance Reporting**: Ability to create executive-level reports using Activity Explorer, Data Estate Insights, and scanner CSV reports

6. **Real-World Application**: Practical knowledge ready for consultancy project implementation with phased approach and stakeholder communication

---

## 🎉 Weekend Lab Complete!

### What You Accomplished

**Technical Skills Developed:**
- ✅ Deployed Microsoft Purview Information Protection Scanner
- ✅ Configured DLP policies for on-premises data protection
- ✅ Implemented retention labels (with understanding of limitations)
- ✅ Analyzed compliance data using Activity Explorer and Data Estate Insights
- ✅ Created professional stakeholder reports

**Business Value Delivered:**
- ✅ Identified sensitive data across file shares
- ✅ Quantified remediation opportunities (3+ year old files)
- ✅ Developed phased implementation strategy
- ✅ Created cost savings projections
- ✅ Prepared stakeholder communication materials

**Consultancy Project Preparation:**
- ✅ Hands-on experience with Purview scanner technology
- ✅ Understanding of hybrid scenarios (on-prem + cloud)
- ✅ Knowledge of platform capabilities and limitations
- ✅ Ready-to-use implementation roadmap
- ✅ Risk mitigation strategies and best practices

### Apply to Your Real Project

**Your Consultancy Scenario:**
> Find old data (3+ years) with sensitive details (PII/PCI/PHI), remediate via delete/archive/retain

**What You Can Now Do:**

1. **Discovery**: Deploy scanner to production file servers, run discovery scans, identify sensitive data distribution

2. **Classification**: Use SITs to detect credit cards, SSNs, PII across on-prem shares

3. **Protection**: Create DLP policies to block unauthorized access to sensitive files

4. **Remediation**: Use PowerShell analysis to identify 3+ year old files, coordinate deletion/archiving with stakeholders

5. **Reporting**: Leverage Activity Explorer and Data Estate Insights for compliance reporting

6. **Migration Strategy**: Plan cloud migration for high-value data to enable full retention capabilities

### Cost Summary

**Weekend Lab Costs:**
- Azure VM runtime: ~$2-3 (with auto-shutdown)
- Azure Files storage: ~$0.30-0.50
- Networking and operations: < $0.20
- **Total**: $10-15 (as estimated)

**E5 Compliance Trial**: Free for 30 days, 25 users

### Cleanup Confirmation

- [ ] Resource group **rg-purview-lab** deleted
- [ ] VM and all associated resources removed
- [ ] App registration **Purview-Scanner-App** deleted
- [ ] Scanner cluster and scan job removed from Purview portal
- [ ] DLP policies removed or disabled
- [ ] Costs stopped accruing in Azure Cost Management

---

## 📚 Reference Documentation

- [Microsoft Purview Information Protection](https://learn.microsoft.com/en-us/purview/information-protection)
- [Data Classification in Purview](https://learn.microsoft.com/en-us/purview/data-classification-overview)
- [Activity Explorer](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)
- [Data Estate Insights](https://learn.microsoft.com/en-us/purview/data-estate-insights)
- [Purview Reports](https://learn.microsoft.com/en-us/purview/reports-overview)

---

## 🤖 AI-Assisted Content Generation

This comprehensive lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview reporting, analysis, and validation procedures based on current documentation as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of validation procedures, stakeholder reporting templates, and environment cleanup processes while maintaining technical accuracy and alignment with real-world consultancy project requirements.*

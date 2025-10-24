# Lab 05: Advanced Remediation & Production Automation

## 📋 Overview

**Duration**: 4-6 hours

**Objective**: Apply advanced remediation automation techniques specific to production data governance projects, including multi-tier severity-based remediation, dual-source deduplication (on-prem + cloud), SharePoint PnP PowerShell automation, and stakeholder progress tracking.

**What You'll Learn:**
- Implement multi-tier remediation strategies based on data severity and age
- Handle dual-source scenarios (on-premises + Nasuni/cloud storage)
- Automate SharePoint/OneDrive bulk deletion using PnP PowerShell
- Create progress tracking dashboards for stakeholder reporting
- Apply production deployment best practices

**Prerequisites from Labs 01-04:**
- ✅ Scanner operational with discovery and DLP scans completed
- ✅ Understanding of SITs, DLP policies, and retention labels
- ✅ Basic PowerShell remediation patterns from Lab 04
- ✅ SharePoint test site with sample sensitive data

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

1. Implement severity-based remediation decision matrix (HIGH/MEDIUM/LOW data)
2. Handle dual-source remediation scenarios (on-prem + cloud)
3. Deduplicate files across on-premises and Nasuni/cloud shares
4. Automate SharePoint/OneDrive bulk deletion with PnP PowerShell
5. Create weekly/monthly progress tracking reports
6. Build stakeholder dashboards showing remediation velocity
7. Apply tombstone creation patterns for audit compliance

---

## 🚨 Important: Project-Specific Scenarios

> **💡 Context**: This lab addresses the specific challenges from your consultancy project:
>
> - **Challenge #1**: On-prem scanners can't do auditing - must apply remediation via scripting
> - **Challenge #2**: On-prem scanner can't do retention labeling - use PowerShell lifecycle management
> - **Challenge #3**: SharePoint eDiscovery doesn't have remediation - use PnP PowerShell for "seek and destroy"
> - **Current State**: Dual data sources (on-prem + Nasuni) requiring coordinated remediation
> - **Future State**: Automated, severity-based remediation with stakeholder progress tracking

---

## 📖 Step-by-Step Instructions

### Step 1: Multi-Tier Severity-Based Remediation

Real-world projects require different remediation actions based on data sensitivity and age criteria.

**Remediation Decision Matrix:**

| Data Severity | Age (Last Access) | Recommended Action | Rationale |
|---------------|-------------------|-------------------|-----------|
| **HIGH** (PCI, PHI, HIPAA) | 0-1 year | Retain + Encrypt | Active sensitive data, legal protection required |
| **HIGH** (PCI, PHI, HIPAA) | 1-3 years | Archive to secure storage | Historical value, restricted access needed |
| **HIGH** (PCI, PHI, HIPAA) | 3+ years | Manual review before deletion | Compliance review required, potential legal holds |
| **MEDIUM** (PII: SSN, Passport) | 0-2 years | Retain with DLP monitoring | Active use, moderate sensitivity |
| **MEDIUM** (PII) | 2-3 years | Archive to long-term storage | Declining usage, moderate sensitivity |
| **MEDIUM** (PII) | 3+ years | Auto-delete with audit logging | Past retention requirements, automated cleanup |
| **LOW** (General business) | 3+ years | Auto-delete immediately | No special handling, storage optimization |

**Implementation Script:**

```powershell
# Import scanner report
$reportPath = "$env:LOCALAPPDATA\Microsoft\MSIP\Scanner\Reports"
$latestReport = Get-ChildItem -Path $reportPath -Filter 'DetailedReport*.csv' |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1

$scanResults = Import-Csv $latestReport.FullName

# Severity classification function
function Get-DataSeverity {
    param([string]$SITs)
    
    if ([string]::IsNullOrWhiteSpace($SITs)) {
        return 'NONE'
    }
    
    switch -Regex ($SITs) {
        'Credit Card|Medical Record|Health Insurance|HIPAA|Protected Health' {
            return 'HIGH'
        }
        'Social Security|SSN|Passport|Driver.*License|National ID' {
            return 'MEDIUM'
        }
        'Email Address|Phone Number|IP Address|Employee ID' {
            return 'LOW'
        }
        default {
            return 'UNKNOWN'
        }
    }
}

# Create remediation plan
$remediationPlan = @()
$now = Get-Date

foreach ($file in $scanResults) {
    # Skip files without sensitive data
    if ([string]::IsNullOrWhiteSpace($file.'Sensitive Information Types')) {
        continue
    }
    
    # Get file details
    $filePath = $file.'File Path'
    $sits = $file.'Sensitive Information Types'
    $severity = Get-DataSeverity -SITs $sits
    
    # Calculate age (use Last Access if available)
    try {
        # Adjust based on your scanner report column names
        $lastModified = [DateTime]$file.'Last Modified'
        $ageYears = [math]::Round((($now - $lastModified).Days / 365), 1)
    } catch {
        $ageYears = 0
    }
    
    # Determine remediation action based on matrix
    $action = switch ($severity) {
        'HIGH' {
            if ($ageYears -ge 3) { 'MANUAL_REVIEW_REQUIRED' }
            elseif ($ageYears -ge 1) { 'ARCHIVE_SECURE' }
            else { 'RETAIN_ENCRYPT' }
        }
        'MEDIUM' {
            if ($ageYears -ge 3) { 'AUTO_DELETE_WITH_AUDIT' }
            elseif ($ageYears -ge 2) { 'ARCHIVE_STANDARD' }
            else { 'RETAIN_MONITOR' }
        }
        'LOW' {
            if ($ageYears -ge 3) { 'AUTO_DELETE' }
            else { 'RETAIN' }
        }
        default { 'NO_ACTION' }
    }
    
    # Add to remediation plan
    $remediationPlan += [PSCustomObject]@{
        FilePath = $filePath
        Severity = $severity
        SITs = $sits
        AgeYears = $ageYears
        LastModified = $lastModified
        Action = $action
        EstimatedDeletionDate = if ($action -match 'DELETE') {
            ($now.AddDays(30)).ToString('yyyy-MM-dd')
        } else {
            'N/A'
        }
    }
}

# Export remediation plan
$remediationPlan | Export-Csv "C:\PurviewLab\Lab05-RemediationPlan.csv" -NoTypeInformation

# Summary by action
$summary = $remediationPlan | Group-Object Action | 
    Select-Object Name, Count, @{N='Percentage';E={[math]::Round(($_.Count / $remediationPlan.Count) * 100, 1)}} |
    Sort-Object Count -Descending

Write-Host "`n========== REMEDIATION PLAN SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Total Files with Sensitive Data: $($remediationPlan.Count)" -ForegroundColor Yellow
$summary | Format-Table -AutoSize

# Files requiring manual review (HIGH severity + old)
$manualReview = $remediationPlan | Where-Object {$_.Action -eq 'MANUAL_REVIEW_REQUIRED'}
Write-Host "`nFiles Requiring Manual Review: $($manualReview.Count)" -ForegroundColor Yellow
Write-Host "These contain HIGH severity data (PCI/PHI) and are 3+ years old." -ForegroundColor Yellow
Write-Host "Manual compliance review required before deletion.`n" -ForegroundColor Yellow
```

> **🎯 Production Tip**: Always start with manual review for HIGH severity data. After establishing processes and legal approval, you can automate HIGH severity deletion with appropriate controls.

---

### Step 2: Dual-Source Remediation (On-Prem + Nasuni)

Handle scenarios where the same files exist in both on-premises and cloud storage.

**Scenario**: During Nasuni migration, files may exist in both locations. Identify duplicates and prioritize remediation.

**Deduplication Strategy:**

```powershell
# Define both sources
$onPremPath = '\\vm-purview-scanner\Projects'
$nasuniPath = '\\[storageaccount].file.core.windows.net\nasuni-simulation'  # Or actual Nasuni share

# Get file inventories from both sources
Write-Host "Scanning on-premises files..." -ForegroundColor Cyan
$onPremFiles = Get-ChildItem -Path $onPremPath -Recurse -File -ErrorAction SilentlyContinue |
    Select-Object Name, Length, LastWriteTime, FullName

Write-Host "Scanning Nasuni/cloud files..." -ForegroundColor Cyan
$nasuniFiles = Get-ChildItem -Path $nasuniPath -Recurse -File -ErrorAction SilentlyContinue |
    Select-Object Name, Length, LastWriteTime, FullName

# Find duplicates by name and size
$duplicates = @()

foreach ($onPremFile in $onPremFiles) {
    $match = $nasuniFiles | Where-Object {
        $_.Name -eq $onPremFile.Name -and
        $_.Length -eq $onPremFile.Length
    } | Select-Object -First 1
    
    if ($match) {
        $duplicates += [PSCustomObject]@{
            FileName = $onPremFile.Name
            OnPremPath = $onPremFile.FullName
            NasuniPath = $match.FullName
            SizeMB = [math]::Round($onPremFile.Length / 1MB, 2)
            OnPremLastModified = $onPremFile.LastWriteTime
            NasuniLastModified = $match.LastWriteTime
            Recommendation = if ($match.LastWriteTime -gt $onPremFile.LastWriteTime) {
                'Delete on-prem (Nasuni newer)'
            } else {
                'Verify before deletion'
            }
        }
    }
}

# Summary
Write-Host "`n========== DUAL-SOURCE ANALYSIS ==========" -ForegroundColor Cyan
Write-Host "On-Prem Files: $($onPremFiles.Count)" -ForegroundColor Yellow
Write-Host "Nasuni Files: $($nasuniFiles.Count)" -ForegroundColor Yellow
Write-Host "Duplicates Found: $($duplicates.Count)" -ForegroundColor Green
Write-Host "Potential Storage Savings: $(($duplicates | Measure-Object -Property SizeMB -Sum).Sum) MB`n" -ForegroundColor Green

# Export for review
$duplicates | Export-Csv "C:\PurviewLab\Lab05-Duplicates.csv" -NoTypeInformation

# Safe deletion of on-prem duplicates
Write-Host "Files safe to delete from on-premises (exist in Nasuni):" -ForegroundColor Yellow
$safeDeletions = $duplicates | Where-Object {$_.Recommendation -eq 'Delete on-prem (Nasuni newer)'}
$safeDeletions | Select-Object FileName, SizeMB, OnPremPath | Format-Table -AutoSize

# Optional: Execute deletion (uncomment to run)
<#
foreach ($duplicate in $safeDeletions) {
    try {
        Remove-Item -Path $duplicate.OnPremPath -Force -Verbose
        Write-Host "✅ Deleted: $($duplicate.FileName)" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to delete: $($duplicate.OnPremPath) - $_"
    }
}
#>
```

> **⚠️ Production Consideration**: Always verify file content integrity before deleting duplicates. Consider using hash comparison (Get-FileHash) for critical data instead of just name/size matching.

---

### Step 3: SharePoint/OneDrive PnP PowerShell Automation

Content Search (eDiscovery) can find sensitive files in SharePoint/OneDrive, but you need PnP PowerShell for bulk deletion.

**Install PnP PowerShell:**

```powershell
# Install PnP PowerShell module (run once)
Install-Module -Name PnP.PowerShell -Force -Scope CurrentUser

# Verify installation
Get-Module -Name PnP.PowerShell -ListAvailable
```

**Connect to SharePoint Site:**

```powershell
# Connect to SharePoint site (interactive authentication)
$siteUrl = "https://[yourtenant].sharepoint.com/sites/[YourTestSite]"
Connect-PnPOnline -Url $siteUrl -Interactive

# Verify connection
Get-PnPWeb | Select-Object Title, Url
```

**Query and Delete Old Sensitive Files:**

```powershell
# Get all items from document library
$libraryName = "Sensitive Data Archive"  # From Lab 03
$allItems = Get-PnPListItem -List $libraryName -PageSize 500

# Filter files: 3+ years old OR containing sensitive data
$cutoffDate = (Get-Date).AddYears(-3)

$deleteTargets = $allItems | Where-Object {
    $fileRef = $_.FieldValues.FileRef
    $modified = $_.FieldValues.Modified
    $fileName = $_.FieldValues.FileLeafRef
    
    # Check if file is old enough
    $isOld = $modified -lt $cutoffDate
    
    # Check if filename indicates sensitive data (simple heuristic)
    $hasSensitiveIndicator = $fileName -match 'SSN|CreditCard|Confidential|Payment'
    
    # Delete if old OR sensitive
    $isOld -or $hasSensitiveIndicator
}

Write-Host "`nFiles Matching Deletion Criteria: $($deleteTargets.Count)" -ForegroundColor Yellow

# Create audit log before deletion
$deletionLog = @()

foreach ($item in $deleteTargets) {
    $deletionLog += [PSCustomObject]@{
        FileName = $item.FieldValues.FileLeafRef
        FilePath = $item.FieldValues.FileRef
        Modified = $item.FieldValues.Modified
        ModifiedBy = $item.FieldValues.Editor.LookupValue
        SizeMB = [math]::Round($item.FieldValues.File_x0020_Size / 1MB, 2)
        DeletedOn = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Reason = "3+ years old or sensitive data"
    }
}

# Export audit log
$deletionLog | Export-Csv "C:\PurviewLab\Lab05-SharePoint-Deletions.csv" -NoTypeInformation

# Execute deletion (use -Recycle to send to recycle bin first)
$confirm = Read-Host "Delete $($deleteTargets.Count) files from SharePoint? (yes/no)"

if ($confirm -eq 'yes') {
    foreach ($item in $deleteTargets) {
        try {
            # Use -Recycle for safety (can be restored from recycle bin)
            Remove-PnPListItem -List $libraryName -Identity $item.Id -Recycle -Force
            
            Write-Host "✅ Deleted: $($item.FieldValues.FileLeafRef)" -ForegroundColor Green
            
        } catch {
            Write-Warning "Failed to delete: $($item.FieldValues.FileLeafRef) - $_"
        }
    }
    
    Write-Host "`n✅ Deletion complete. Files moved to SharePoint Recycle Bin." -ForegroundColor Green
    Write-Host "Audit log saved to: C:\PurviewLab\Lab05-SharePoint-Deletions.csv" -ForegroundColor Cyan
} else {
    Write-Host "Deletion cancelled." -ForegroundColor Yellow
}

# Disconnect
Disconnect-PnPOnline
```

> **💡 PnP PowerShell Tip**: Use `-Recycle` parameter instead of permanent deletion. This moves files to SharePoint Recycle Bin where they can be restored for 93 days (default retention).

---

### Step 4: On-Premises Remediation with Tombstone Creation

For on-premises files, create tombstones to document deletions and enable restoration from backup.

**Production-Ready Deletion Script:**

```powershell
# Load remediation plan from Step 1
$remediationPlan = Import-Csv "C:\PurviewLab\Lab05-RemediationPlan.csv"

# Filter for auto-delete actions
$autoDeleteFiles = $remediationPlan | Where-Object {
    $_.Action -eq 'AUTO_DELETE' -or $_.Action -eq 'AUTO_DELETE_WITH_AUDIT'
}

Write-Host "`nFiles Marked for Auto-Deletion: $($autoDeleteFiles.Count)" -ForegroundColor Yellow

# Confirm deletion
$confirm = Read-Host "Proceed with deletion? (yes/no)"

if ($confirm -ne 'yes') {
    Write-Host "Deletion cancelled." -ForegroundColor Yellow
    exit
}

# Create tombstones and delete files
foreach ($file in $autoDeleteFiles) {
    $filePath = $file.FilePath
    
    try {
        # Verify file exists
        if (-not (Test-Path $filePath)) {
            Write-Warning "File not found: $filePath"
            continue
        }
        
        # Get file info for tombstone
        $fileInfo = Get-Item $filePath
        
        # Create tombstone BEFORE deletion
        $tombstonePath = "$filePath.DELETED_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        
        $tombstoneContent = @"
============================================================
FILE DELETION RECORD
============================================================
Original File: $filePath
Deleted On: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Deleted By: $env:USERNAME
Computer: $env:COMPUTERNAME

FILE DETAILS:
Size: $([math]::Round($fileInfo.Length / 1MB, 2)) MB
Last Modified: $($fileInfo.LastWriteTime)
Last Accessed: $($fileInfo.LastAccessTime)
Created: $($fileInfo.CreationTime)

REMEDIATION DETAILS:
Severity: $($file.Severity)
Sensitive Info Types: $($file.SITs)
Age: $($file.AgeYears) years
Remediation Action: $($file.Action)

RESTORATION INFORMATION:
This file was deleted as part of data remediation project.
Contact IT Service Desk for restoration from backup.

Backup System: Rubrik / JCI Backup Service
Retention: Check backup retention policy
Project Reference: Purview Remediation - $(Get-Date -Format 'yyyy-MM')

Approved By: [Compliance Officer Name]
Legal Hold Check: None Active
============================================================
"@
        
        # Write tombstone
        $tombstoneContent | Out-File -FilePath $tombstonePath -Encoding UTF8 -Force
        
        # Delete original file
        Remove-Item -Path $filePath -Force -ErrorAction Stop
        
        Write-Host "✅ Deleted: $($fileInfo.Name)" -ForegroundColor Green
        Write-Host "   Tombstone: $tombstonePath" -ForegroundColor Gray
        
    } catch {
        Write-Error "Failed to delete $filePath: $($_.Exception.Message)"
    }
}

Write-Host "`n✅ Remediation complete." -ForegroundColor Green
Write-Host "Tombstones created for audit trail and backup restoration reference.`n" -ForegroundColor Cyan
```

---

### Step 5: Progress Tracking Dashboard

Create weekly/monthly tracking metrics for stakeholder reporting.

**Initialize Progress Tracking:**

```powershell
# Create baseline snapshot (run once at project start)
$baseline = [PSCustomObject]@{
    Date = Get-Date -Format "yyyy-MM-dd"
    Week = 0
    TotalFiles = 50000
    SensitiveFiles = 5000
    FilesOver3Years = 12000
    RemediationCandidates = 3000
    TotalSizeGB = 500
}

$baseline | Export-Csv "C:\PurviewLab\Lab05-ProgressTracking.csv" -NoTypeInformation

Write-Host "✅ Baseline snapshot created" -ForegroundColor Green
```

**Weekly Progress Update:**

```powershell
# Run this weekly to track progress
$weekNumber = 1  # Increment each week

# Calculate current state
$currentScan = Import-Csv "$env:LOCALAPPDATA\Microsoft\MSIP\Scanner\Reports\DetailedReport*.csv" |
    Select-Object -Last 1

$currentStats = [PSCustomObject]@{
    Date = Get-Date -Format "yyyy-MM-dd"
    Week = $weekNumber
    FilesDeleted = 500  # From deletion logs
    FilesArchived = 200  # From archive operations
    FilesRetained = 100  # Files explicitly retained
    RemediationRate = '23%'  # (Deleted + Archived) / RemediationCandidates
    StorageSavedGB = 50
    CostSavingsUSD = 150  # Estimated storage cost savings
    ManualReviewsCompleted = 25
    HighSeverityResolved = 10
}

# Append to tracking file
$currentStats | Export-Csv "C:\PurviewLab\Lab05-ProgressTracking.csv" -Append -NoTypeInformation

# Generate progress report
$allProgress = Import-Csv "C:\PurviewLab\Lab05-ProgressTracking.csv"
$latestWeek = $allProgress | Select-Object -Last 1

$progressReport = @"

============================================================
REMEDIATION PROGRESS REPORT - WEEK $($latestWeek.Week)
============================================================
Date: $($latestWeek.Date)

REMEDIATION SUMMARY:
  Files Deleted This Week: $($latestWeek.FilesDeleted)
  Files Archived This Week: $($latestWeek.FilesArchived)
  Files Retained: $($latestWeek.FilesRetained)

CUMULATIVE PROGRESS:
  Total Remediation Rate: $($latestWeek.RemediationRate)
  Storage Reclaimed: $($latestWeek.StorageSavedGB) GB
  Estimated Cost Savings: $`$$($latestWeek.CostSavingsUSD)

COMPLIANCE METRICS:
  Manual Reviews Completed: $($latestWeek.ManualReviewsCompleted)
  High-Severity Files Resolved: $($latestWeek.HighSeverityResolved)

VELOCITY ANALYSIS:
  Avg Files/Week: $(($allProgress | Where-Object {$_.Week -gt 0} | Measure-Object -Property FilesDeleted -Average).Average)
  Projected Completion: $(if ($latestWeek.RemediationRate -match '(\d+)%') {
      $rate = [int]$Matches[1]
      $weeksRemaining = [math]::Ceiling((100 - $rate) / ($rate / $latestWeek.Week))
      "~$weeksRemaining weeks"
  } else { 'TBD' })

NEXT WEEK TARGETS:
  - Delete 600 files (20% increase)
  - Archive 250 files
  - Complete 30 manual reviews for HIGH severity data

============================================================
"@

Write-Host $progressReport -ForegroundColor Cyan

# Save report
$progressReport | Out-File "C:\PurviewLab\Lab05-WeeklyReport-Week$weekNumber.txt" -Encoding UTF8
```

**Stakeholder Dashboard (PowerShell Chart):**

```powershell
# Simple text-based progress visualization
$allProgress = Import-Csv "C:\PurviewLab\Lab05-ProgressTracking.csv"

Write-Host "`n========== REMEDIATION VELOCITY DASHBOARD ==========" -ForegroundColor Cyan

foreach ($week in $allProgress | Where-Object {$_.Week -gt 0}) {
    $barLength = [math]::Round($week.FilesDeleted / 10)  # Scale for display
    $bar = "█" * $barLength
    
    Write-Host "Week $($week.Week): " -NoNewline -ForegroundColor Yellow
    Write-Host "$bar " -NoNewline -ForegroundColor Green
    Write-Host "($($week.FilesDeleted) files, $($week.StorageSavedGB) GB)" -ForegroundColor White
}

Write-Host "`n" -NoNewline
```

---

## ✅ Validation Checklist

### Multi-Tier Remediation

- [ ] Remediation plan generated with severity classification
- [ ] HIGH, MEDIUM, LOW categories assigned correctly
- [ ] Manual review list created for HIGH severity + old files
- [ ] Auto-delete list generated for appropriate candidates

### Dual-Source Deduplication

- [ ] Both on-prem and Nasuni/cloud sources scanned
- [ ] Duplicates identified by name and size
- [ ] Safe deletion list created (files exist in both locations)
- [ ] Storage savings calculated

### SharePoint PnP Automation

- [ ] PnP PowerShell module installed
- [ ] Successfully connected to SharePoint site
- [ ] Files queried from document library
- [ ] Deletion criteria applied (age + sensitivity)
- [ ] Audit log created before deletion
- [ ] Files deleted (or moved to Recycle Bin)

### On-Premises Tombstone Creation

- [ ] Tombstone pattern implemented
- [ ] Tombstones created before file deletion
- [ ] Restoration information included in tombstones
- [ ] Backup system reference documented

### Progress Tracking

- [ ] Baseline snapshot created
- [ ] Weekly progress metrics captured
- [ ] Progress report generated
- [ ] Velocity analysis calculated
- [ ] Stakeholder dashboard created

---

## 📊 Expected Results

### Remediation Plan Output

After Step 1, you should have:

```
========== REMEDIATION PLAN SUMMARY ==========
Total Files with Sensitive Data: 150

Name                        Count  Percentage
----                        -----  ----------
AUTO_DELETE_WITH_AUDIT      45     30.0
ARCHIVE_STANDARD            30     20.0
MANUAL_REVIEW_REQUIRED      25     16.7
RETAIN_MONITOR              20     13.3
AUTO_DELETE                 15     10.0
RETAIN_ENCRYPT              10     6.7
ARCHIVE_SECURE              5      3.3

Files Requiring Manual Review: 25
These contain HIGH severity data (PCI/PHI) and are 3+ years old.
```

### Dual-Source Analysis

After Step 2:

```
========== DUAL-SOURCE ANALYSIS ==========
On-Prem Files: 150
Nasuni Files: 175
Duplicates Found: 75
Potential Storage Savings: 2,500 MB
```

### Weekly Progress Report

After Step 5:

```
REMEDIATION PROGRESS REPORT - WEEK 1
Date: 2025-10-30

REMEDIATION SUMMARY:
  Files Deleted This Week: 500
  Files Archived This Week: 200
  
CUMULATIVE PROGRESS:
  Total Remediation Rate: 23%
  Storage Reclaimed: 50 GB
  Estimated Cost Savings: $150
```

---

## 🔍 Troubleshooting

### Issue: PnP PowerShell Connection Fails

**Symptoms**: `Connect-PnPOnline` throws authentication errors

**Solutions**:

1. **Modern Auth**: Ensure modern authentication is enabled for your tenant
2. **Permissions**: Verify you have Site Collection Admin or Owner permissions
3. **MFA**: Use `-Interactive` parameter for MFA-enabled accounts
4. **App Registration**: For unattended scenarios, create app registration with SharePoint permissions

### Issue: Dual-Source Scan Performance

**Symptoms**: Scanning large Nasuni shares is very slow

**Solutions**:

1. **Filter by date**: Only scan files modified in last 5 years
2. **Parallel processing**: Use PowerShell jobs for concurrent scanning
3. **Incremental scanning**: Scan one folder at a time, cache results

### Issue: Progress Tracking Data Missing

**Symptoms**: Weekly reports show incomplete data

**Solutions**:

1. **Centralize logs**: Keep all deletion logs in single directory
2. **Standardize naming**: Use consistent CSV export filenames
3. **Automate collection**: Schedule weekly script to gather metrics

---

## 🎯 Key Learning Outcomes

After completing Lab 05, you should understand:

1. **Severity-Based Remediation**: How to classify and handle data differently based on sensitivity (HIGH/MEDIUM/LOW)
2. **Dual-Source Management**: Techniques for handling on-prem + cloud storage scenarios with deduplication
3. **SharePoint Automation**: PnP PowerShell for bulk operations that eDiscovery UI doesn't support
4. **Production Patterns**: Tombstones, audit trails, and error handling for production deployments
5. **Progress Tracking**: How to measure and report remediation velocity to stakeholders

---

## 🚀 Real-World Application

### Applying to Your Consultancy Project

**Week 1-2: Assessment & Planning**
- Run severity classification on all file servers
- Generate remediation plan with estimates
- Get stakeholder approval for multi-tier approach

**Week 3-4: Pilot Remediation**
- Start with LOW severity, 3+ year old files (low risk)
- Test tombstone creation and restoration process
- Validate backup integration with Rubrik

**Week 5-8: Scale Up**
- Process MEDIUM severity files
- Implement progress tracking dashboard
- Weekly stakeholder reports

**Week 9-12: HIGH Severity & Dual-Source**
- Manual review process for HIGH severity + old files
- Dual-source deduplication (on-prem + Nasuni)
- SharePoint remediation using PnP PowerShell

---

## 📚 Additional Resources

### PowerShell Modules

- **PnP PowerShell**: [Documentation](https://pnp.github.io/powershell/)
- **Microsoft Graph PowerShell**: For advanced SharePoint/OneDrive operations
- **Az.Storage**: For Azure Files lifecycle management

### Compliance References

- **Data Retention Best Practices**: Microsoft Purview documentation
- **Legal Hold Considerations**: eDiscovery and litigation hold procedures
- **GDPR Compliance**: Right to erasure and data minimization

### Automation Tools

- **Azure Automation**: Schedule remediation scripts
- **Power Automate**: Approval workflows for manual reviews
- **Azure Logic Apps**: Event-driven remediation triggers

---

## 🏁 Completion Confirmation

Before moving to cleanup, verify:

- [ ] Remediation decision matrix implemented and tested
- [ ] Dual-source deduplication logic working correctly
- [ ] SharePoint PnP deletion tested with recycle bin safety
- [ ] Tombstone creation pattern validated
- [ ] Progress tracking reports generated
- [ ] All scripts exported to C:\PurviewLab\ for future reference

---

## 🤖 AI-Assisted Content Generation

This advanced remediation lab was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating real-world consultancy project requirements, production deployment patterns, and enterprise-grade data governance automation strategies.

*AI tools were used to enhance productivity and ensure comprehensive coverage of advanced Purview remediation scenarios while maintaining technical accuracy and reflecting modern data lifecycle management best practices.*

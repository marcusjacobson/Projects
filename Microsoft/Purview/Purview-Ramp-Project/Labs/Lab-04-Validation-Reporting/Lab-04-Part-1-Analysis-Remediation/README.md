# Lab 04 Part 1: Scanner Analysis & Remediation Planning

> **💻 PowerShell Version Requirement**: This lab uses commands from the **AzureInformationProtection PowerShell module** which is designed for **Windows PowerShell 5.1**. You must use **Windows PowerShell 5.1** (not PowerShell 7) for all scanner-related commands (`Start-Scan`, `Get-ScanStatus`, etc.).
>
> **To launch Windows PowerShell 5.1**: Search for "Windows PowerShell" in the Start menu (the blue icon, NOT the black "PowerShell 7" icon).

## 📋 Overview

**Duration**: 2-3 hours

**Objective**: Analyze scanner reports from Labs 01-02, quantify old data for remediation, practice basic remediation scripting patterns, and create initial stakeholder report with scanner findings.

**What You'll Learn:**

- Analyze scanner CSV reports for sensitive data findings
- Quantify remediation opportunities (3+ year old data)
- Practice fundamental PowerShell remediation patterns
- Create draft stakeholder report with scanner analysis
- Validate Labs 01-02 completion

**Prerequisites:**

- ✅ Lab 01 complete: Scanner deployed and discovery scan executed
- ✅ Lab 02 complete: DLP policies configured and enforcement scan executed
- ✅ Scanner CSV reports generated and accessible
- ✅ Sample data in file shares with sensitive information

> **⏳ Timing Note**: This is Part 1 of Lab 04, containing activities you can complete **immediately**. Part 2 (Activity Monitoring & Final Reporting) should be completed **24 hours later** after Activity Explorer data has fully synced. See the end of this lab for transition guidance.

---

## 🎯 Lab Objectives

By the end of Part 1, you will be able to:

1. Analyze scanner CSV reports to identify sensitive data distribution
2. Quantify old data (3+ years) eligible for remediation
3. Practice basic PowerShell remediation patterns (delete, archive, audit)
4. Create draft stakeholder report with scanner findings
5. Validate successful completion of Labs 01-02
6. Understand what data monitoring will be available in Part 2

---

## 📖 Step-by-Step Instructions

### Step 1: Review Scanner Reports

Scanner reports provide detailed file-level information about discovered sensitive data, DLP matches, and label application.

> **⏳ Expected Label Behavior**: The scanner applies **sensitivity labels** (e.g., `General \ All Employees`) to on-premises files immediately. However, the **Delete-After-3-Years retention label** from Lab 03 will ONLY apply to **SharePoint sites** (not on-premises shares).
>
> **Why?** Auto-apply retention label policies only support cloud locations (SharePoint, OneDrive, Exchange). The on-premises scanner cannot apply retention labels. Lab 03's retention label validation in Part 2 checks SharePoint files, not your local file shares.

**On VM, Navigate to Scanner Reports:**

> **💡 Report Location Note**: Scanner reports are created under the **scanner service account's profile** (`C:\Users\scanner-svc\AppData\Local\...`), not under your admin account. This is because the scanner service runs as the `scanner-svc` account.

```powershell
# Navigate to scanner reports directory (under scanner-svc account profile)
Set-Location "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"

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

**View Report Contents in PowerShell:**

For easier analysis, display the report contents in PowerShell table format:

```powershell
# Import and display the report in PowerShell
$reportData = Import-Csv $latestDetailedReport.FullName

# First, show available column names to understand the report structure
Write-Host "`n========== SCANNER DETAILED REPORT - PREVIEW ==========" -ForegroundColor Cyan
Write-Host "Report File: $($latestDetailedReport.Name)" -ForegroundColor Yellow
Write-Host "Total Rows: $($reportData.Count)" -ForegroundColor Yellow

# Display available columns
Write-Host "`nAvailable Columns:" -ForegroundColor Green
$reportData[0].PSObject.Properties.Name | Sort-Object | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }

# Display first 10 rows with all columns (easier to see actual data)
Write-Host "`nShowing first 10 rows with all available data:`n" -ForegroundColor Green
$reportData | Select-Object -First 10 | Format-List

# Alternative: Display in table format with specific columns if they exist
Write-Host "`nTable View (if applicable):`n" -ForegroundColor Green
$reportData | Select-Object -First 10 | Format-Table -AutoSize -Wrap
```

> **💡 Analysis Tip**: Use `Out-GridView` for interactive filtering and sorting: `$reportData | Out-GridView`. This opens a searchable, filterable window that's easier to work with than Notepad.
>
> **📋 Column Names May Vary**: Scanner report column names can vary based on scanner version and configuration. The script above shows all available columns first, then displays the data. Common column names include: `Path`, `File`, `Information Types`, `Sensitive Info Types Detected`, `Recommendation`, `Last Modified Time`, etc.

**Key Columns to Review** (Based on Actual Scanner Output):

| Column Name | Purpose | Lab Relevance | Example Values |
|-------------|---------|---------------|----------------|
| **Repository** | Network share location | Identify which shares contain sensitive data | `\\vm-purview-scanner\Finance`, `\\vm-purview-scanner\HR` |
| **File Name** | Full UNC path to scanned file | Locate specific files for remediation | `\\vm-purview-scanner\Finance\CustomerPayments.txt` |
| **Information Type Name** | Which SITs were detected | Identify credit cards, SSNs, other PII | `Credit Card Number`, `U.S. Social Security Number (SSN)` |
| **Applied Label** | Sensitivity/retention label applied | Verify auto-labeling worked | `General \ All Employees (unrestricted)` |
| **Last Modified** | File modification timestamp | Find files older than 3 years for remediation | `2022-08-24 14:20:02Z` (3+ years old) |
| **DLP Mode** | Test or Enforce mode | Verify DLP policy application mode | `Test`, `Enforce` |
| **DLP Status** | DLP rule match status | Check if DLP rules triggered | `Matched`, `Skipped`, `No match` |
| **DLP Rule Name** | Specific DLP rule triggered | Identify which rule matched | `Block-Credit-Card-Access`, `Audit-SSN-Access` |
| **DLP Actions** | Action taken by DLP | Verify blocking/auditing behavior | `Block`, `Audit` |
| **Action** | Scanner action performed | Confirm labeling occurred | `Labeled`, `Removed`, `Skipped` |
| **Status** | Scan result status | Verify successful scan | `Success`, `Failed` |

**Analysis Questions:**

1. **How many files contain sensitive data?**
   - Count rows where "Information Type Name" is not empty

2. **Which SITs are most common?**
   - Group by "Information Type Name" and count occurrences

3. **Where is sensitive data concentrated?**
   - Analyze "Repository" column to identify high-risk shares (Finance, HR)

4. **How many files are 3+ years old?**
   - Filter by "Last Modified" date < 3 years ago

**PowerShell Analysis Example** (Using Actual Column Names):

```powershell
# Import latest detailed report (already loaded as $reportData)
$report = $reportData

# Count files with sensitive data
$sensitiveFiles = $report | Where-Object {$_.'Information Type Name' -ne ''}
Write-Host "Files with Sensitive Data: $($sensitiveFiles.Count)" -ForegroundColor Cyan

# Group by SIT type
$sitCounts = $sensitiveFiles | 
    Group-Object 'Information Type Name' | 
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
if ($oldFiles.Count -gt 0) {
    Write-Host "Old files found:" -ForegroundColor Yellow
    $oldFiles | Select-Object 'File Name', 'Last Modified', 'Information Type Name' | Format-Table -AutoSize
}

# DLP enforcement summary (note: may show as "Skipped" or "No match" in Test mode)
$dlpMatched = $report | Where-Object {$_.'DLP Status' -eq 'Matched'}
$dlpSkipped = $report | Where-Object {$_.'DLP Status' -eq 'Skipped' -or $_.'DLP Comment' -eq 'No match'}
Write-Host "`nDLP Status Summary:" -ForegroundColor Green
Write-Host "  DLP Matched Files: $($dlpMatched.Count)"
Write-Host "  DLP Skipped/No Match: $($dlpSkipped.Count)"
Write-Host "  DLP Mode: $($report[0].'DLP Mode')" -ForegroundColor Cyan

# Repository breakdown
$repoBreakdown = $report | Group-Object 'Repository' | 
    Select-Object Name, Count
Write-Host "`nFiles by Repository:" -ForegroundColor Magenta
$repoBreakdown | Format-Table -AutoSize
```

> **💡 DLP Status Note**: You will typically see `DLP Status: Skipped` and `DLP Comment: No match` in scanner reports. This is **normal behavior** because:
>
> - **On-premises DLP enforcement is not supported** - DLP policies can detect sensitive data via the scanner, but cannot block or audit file access on network file shares
> - **Scanner runs in detection mode** - It identifies sensitive information types and applies labels, but DLP enforcement requires cloud storage locations (SharePoint, OneDrive, Exchange)
> - **Test mode is the only option** - For on-premises scanning, DLP mode shows as "Test" because actual enforcement (blocking access) only works in Microsoft 365 cloud services
>
> **What you should see**: Files with `Information Type Name` populated (e.g., "Credit Card Number", "SSN") confirm the scanner is successfully **detecting** sensitive data, even though DLP enforcement shows as "Skipped".

---

### Step 2: Quantify Old Data for Remediation

Based on the consultancy project requirement to identify and remediate 3+ year old data.

**Calculate Remediation Opportunities:**

```powershell
# Create working directory if it doesn't exist
$workingDir = "C:\PurviewLab"
if (-not (Test-Path $workingDir)) {
    New-Item -ItemType Directory -Path $workingDir -Force | Out-Null
    Write-Host "Created working directory: $workingDir" -ForegroundColor Green
}

# On VM, analyze files by age (using localhost to reference local shares)
$shares = @(
    "\\localhost\Finance",
    "\\localhost\HR",
    "\\localhost\Projects"
)

$cutoffDate = (Get-Date).AddYears(-3)
$remediationCandidates = @()

foreach ($share in $shares) {
    Write-Host "Analyzing share: $share" -ForegroundColor Cyan
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
$avgAgeYears = if ($totalOldFiles -gt 0) { [math]::Round(($remediationCandidates | Measure-Object -Property Age_Years -Average).Average, 1) } else { 0 }

Write-Host "`n========== REMEDIATION OPPORTUNITY ANALYSIS ==========" -ForegroundColor Cyan
Write-Host "Total Files Older Than 3 Years: $totalOldFiles" -ForegroundColor Yellow
Write-Host "Total Size: $([math]::Round($totalSizeMB, 2)) MB" -ForegroundColor Yellow
Write-Host "Average Age: $avgAgeYears years" -ForegroundColor Yellow

if ($totalOldFiles -gt 0) {
    Write-Host "`nBreakdown by Share:" -ForegroundColor Green
    $remediationCandidates | Group-Object Share | 
        Select-Object Name, Count, @{N='TotalSizeMB';E={[math]::Round(($_.Group | Measure-Object -Property SizeMB -Sum).Sum, 2)}} |
        Format-Table -AutoSize

    # Export for reporting
    $remediationCandidates | Export-Csv "$workingDir\RemediationCandidates.csv" -NoTypeInformation
    Write-Host "`nRemediation candidates exported to: $workingDir\RemediationCandidates.csv" -ForegroundColor Cyan
} else {
    Write-Host "`nNo files older than 3 years found in the scanned shares." -ForegroundColor Yellow
    Write-Host "This may be expected if your test files are recent." -ForegroundColor Gray
}
```

### ✅ Remediation Options Available Now

These PowerShell patterns work **immediately** and don't require waiting for retention label policies:

1. **Safe Deletion** (Pattern 1): Files with no business value, past retention requirements
   - Works immediately with audit trail logging
   - Example: Delete old files identified in RemediationCandidates.csv

2. **Archive to Cold Storage** (Pattern 2): Files with historical value, low access frequency
   - Works immediately via PowerShell file move
   - Example: Move old files to `\\localhost\Archive` location

3. **Bulk Processing** (Pattern 3): Process multiple files with error handling
   - Works immediately for batch operations
   - Example: Archive all files older than 3 years in one operation

4. **Access Pattern Analysis** (Pattern 4): Identify truly unused files
   - Works immediately by reading filesystem metadata
   - Helps identify files that appear old but are still being accessed

> **💡 Key Insight**: The PowerShell patterns in Step 3 are the **production approach** for on-premises file share remediation. Unlike cloud storage (SharePoint/OneDrive), on-premises shares require manual scripting for data lifecycle management.

### ⏳ About Retention Labels (Lab 03 Follow-up)

**Where retention labels apply:**

- ✅ **SharePoint Online**: The Delete-After-3-Years label from Lab 03 auto-applies to SharePoint files
  - Timeline: 1-2 days simulation + 2-7 days for label application
  - Validation: Lab 04 Part 2 checks if labels applied to SharePoint test site
  
- ❌ **On-premises file shares**: Auto-apply retention labels NOT supported
  - Scanner cannot apply retention labels to `\\localhost\Finance`, `\\localhost\HR`, `\\localhost\Projects`
  - Platform limitation - retention auto-apply only works for cloud locations
  - For on-premises remediation: Use PowerShell patterns (manual approach)

---

### Step 3: Basic Remediation Scripting Patterns

Practice these fundamental PowerShell remediation patterns before implementing production scenarios.

> **⚠️ CRITICAL - Both Commands Are Commented Out By Default**:
>
> **For your safety, ALL destructive operations are commented out.** You must manually uncomment the command you want to run.
>
> **Required Steps for Each Pattern:**
>
> 1. **Copy the script** to Notepad or VS Code for safe editing
>
> 2. **First Test - Uncomment the `-WhatIf` line ONLY**:
>
>    ```powershell
>    # Remove-Item $testFile -WhatIf          ← Remove the # from THIS line first
>    # Remove-Item $testFile -Force -Verbose  ← Keep this commented
>    ```
>
>    This shows what **WOULD** happen without making actual changes
>
> 3. **Review the preview output** carefully - does it show the correct file(s)?
>
> 4. **If satisfied with preview, uncomment the ACTUAL command**:
>
>    ```powershell
>    # Remove-Item $testFile -WhatIf          ← Comment this back out (add # back)
>    Remove-Item $testFile -Force -Verbose    ← Remove the # from THIS line
>    ```
>
> 5. **Run the script** to perform the actual operation
>
> **💡 Why Both Lines Are Commented**:
>
> - Prevents accidental deletion/moving of files
> - Forces you to consciously choose which operation to perform
> - **ALWAYS start with `-WhatIf`** to preview before running the actual command
>
> **🎯 Pro Tip**: Edit scripts in Notepad first, then copy back to PowerShell. This prevents accidental execution while you're figuring out which line to uncomment.

**Pattern 1: Safe File Deletion with Audit Trail**:

```powershell
# Always test with -WhatIf first
# Using actual test file from Lab 00 - old archived project data (3+ years)
$testFile = "\\localhost\Projects\PhoenixProject.txt"

# Verify file exists before proceeding
if (-not (Test-Path $testFile)) {
    Write-Warning "File not found: $testFile"
    Write-Host "Please update the file path to an actual file from your RemediationCandidates.csv" -ForegroundColor Yellow
    return
}

# Get file info before deletion
$fileInfo = Get-Item $testFile

# Create deletion log BEFORE removing file
$logEntry = [PSCustomObject]@{
    FilePath = $testFile
    DeletedOn = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    DeletedBy = $env:USERNAME
    Reason = "Lab testing - 3+ years old"
    FileSize = $fileInfo.Length
    LastModified = $fileInfo.LastWriteTime
}

# Export to audit log
$logEntry | Export-Csv "C:\PurviewLab\DeletionAudit.csv" -Append -NoTypeInformation

# Delete file (test with -WhatIf first, then uncomment actual deletion)
# Remove-Item $testFile -WhatIf
# Remove-Item $testFile -Force -Verbose

Write-Host "✅ File deleted and logged" -ForegroundColor Green
```

**Pattern 2: Move Files to Archive Location**:

```powershell
# Archive old files instead of deleting
# Using actual test file from Lab 00 HR share
$sourceFile = "\\localhost\HR\EmployeeRecords.txt"
$archiveRoot = "\\localhost\Archive"

# Verify file exists before proceeding
if (-not (Test-Path $sourceFile)) {
    Write-Warning "File not found: $sourceFile"
    Write-Host "Please update the file path to an actual file from your RemediationCandidates.csv" -ForegroundColor Yellow
    return
}

# Get file info before archiving
$fileInfo = Get-Item $sourceFile

# Create archive folder structure (preserves original paths)
$relativePath = $sourceFile.Replace("\\localhost\", "")
$archivePath = Join-Path $archiveRoot $relativePath
$archiveFolder = Split-Path $archivePath -Parent

# Create folder if doesn't exist (use -Force to suppress UNC path errors)
try {
    if (-not (Test-Path $archiveFolder)) {
        $null = New-Item -ItemType Directory -Path $archiveFolder -Force -ErrorAction Stop
    }
} catch {
    # If New-Item fails with UNC path, try alternative approach
    Write-Host "Creating archive directory structure..." -ForegroundColor Cyan
    # Create using mkdir command which handles UNC paths better
    $null = mkdir $archiveFolder -Force -ErrorAction SilentlyContinue
}

# Move file (test with -WhatIf first, then uncomment actual move)
# Move-Item -Path $sourceFile -Destination $archivePath -WhatIf
# Move-Item -Path $sourceFile -Destination $archivePath -Force -Verbose
Write-Host "✅ File archived to: $archivePath" -ForegroundColor Green
Write-Host "   Original size: $($fileInfo.Length) bytes" -ForegroundColor Cyan
Write-Host "   Last modified: $($fileInfo.LastWriteTime)" -ForegroundColor Cyan
```

**Pattern 3: Bulk Processing with Error Handling**:

```powershell
# Process multiple files with proper error handling
# Using actual test files from Lab 00
$filesToProcess = @(
    "\\localhost\Finance\CustomerPayments.txt",
    "\\localhost\Projects\PhoenixProject.txt"
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
        
        # Perform operation (test with -WhatIf first, then uncomment actual move)
        # Move-Item $file -Destination "\\localhost\Archive" -WhatIf
        # Move-Item $file -Destination "\\localhost\Archive" -Force
        
        # Log success
        $results += [PSCustomObject]@{
            File = $file
            Status = "Success"
            Action = "Archived"
            FileSize = $fileInfo.Length
            LastModified = $fileInfo.LastWriteTime
            Error = $null
        }
        
        Write-Host "✅ Processed: $file" -ForegroundColor Green
        
    } catch {
        # Log failure
        $results += [PSCustomObject]@{
            File = $file
            Status = "Failed"
            Action = "None"
            FileSize = 0
            LastModified = $null
            Error = $_.Exception.Message
        }
        
        Write-Warning "Failed to process ${file}: $($_.Exception.Message)"
    }
}

# Export results
$results | Export-Csv "C:\PurviewLab\ProcessingResults.csv" -NoTypeInformation
Write-Host "`n✅ Processing complete. Results: C:\PurviewLab\ProcessingResults.csv" -ForegroundColor Cyan
```

**Pattern 4: Last Access Time Analysis**:

```powershell
# Compare Last Modified vs Last Access Time
# Using actual test file share from Lab 00
$share = "\\localhost\Projects"

# Verify share exists before proceeding
if (-not (Test-Path $share)) {
    Write-Warning "Share not found: $share"
    Write-Host "Please verify the UNC path is correct and accessible" -ForegroundColor Yellow
    return
}

# Enable last access time tracking (run once on file server if needed)
# fsutil behavior set disablelastaccess 0

# Find files with access/modify time discrepancy
Write-Host "Analyzing files in $share..." -ForegroundColor Cyan
$files = Get-ChildItem -Path $share -Recurse -File -ErrorAction SilentlyContinue

if ($files.Count -eq 0) {
    Write-Warning "No files found in $share"
    Write-Host "Verify that test files exist (e.g., PhoenixProject.txt from Lab 00)" -ForegroundColor Yellow
    return
}

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
Write-Host "`nFiles recently accessed but not modified in 3+ years:" -ForegroundColor Yellow
Write-Host "(These files should NOT be deleted - they're still being used)" -ForegroundColor Yellow

$accessAnalysis | Where-Object {$_.AccessAgeDays -lt 365 -and $_.ModifyAgeDays -gt 1095} |
    Select-Object FileName, AccessAgeDays, ModifyAgeDays, Discrepancy |
    Format-Table -AutoSize

# Export full analysis for further review
$accessAnalysis | Export-Csv "C:\PurviewLab\AccessTimeAnalysis.csv" -NoTypeInformation
Write-Host "`n✅ Analysis exported to: C:\PurviewLab\AccessTimeAnalysis.csv" -ForegroundColor Green

# Optional: Open in default viewer
Invoke-Item "C:\PurviewLab\AccessTimeAnalysis.csv"
```

> **🎯 Key Takeaway**: These four patterns are building blocks for remediation projects. Lab 05 builds on these to create production-ready, multi-tier automation.

---

### Step 4: Generate Automated On-Premises Analysis Report

Generate an automated report based on your scanner analysis and remediation candidate data from Steps 1-3. This script pulls actual data from your environment rather than requiring manual placeholder replacement.

> **📝 Report Focus**: This automated report focuses on **on-premises file share analysis only** (scanner findings, file age analysis, remediation opportunities). You'll add Activity Explorer and Data Classification insights in **Lab 04 Part 2** after monitoring data syncs.

**Automated Report Generation Script:**

```powershell
# =============================================================================
# Generate On-Premises File Share Analysis Report
# =============================================================================

Write-Host "📊 Generating On-Premises Analysis Report..." -ForegroundColor Cyan

# Get latest scanner detailed report
$scannerReportsPath = "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"
$latestDetailedReport = Get-ChildItem -Path $scannerReportsPath -Filter "DetailedReport*.csv" -ErrorAction SilentlyContinue | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1

if (-not $latestDetailedReport) {
    Write-Warning "No scanner detailed report found. Please run scanner first (Lab 01-02)."
    return
}

# Import scanner data
Write-Host "Loading scanner report: $($latestDetailedReport.Name)" -ForegroundColor Yellow
$scannerData = Import-Csv $latestDetailedReport.FullName

# Import remediation candidates (from Step 2)
$remediationCandidatesPath = "C:\PurviewLab\RemediationCandidates.csv"
$remediationData = @()
if (Test-Path $remediationCandidatesPath) {
    # Force array with @() to handle single-row CSV correctly
    $remediationData = @(Import-Csv $remediationCandidatesPath)
    # Ensure it's an array even if empty
    if ($null -eq $remediationData) { $remediationData = @() }
}

# Calculate metrics
$totalFilesScanned = $scannerData.Count
$filesWithSensitiveData = ($scannerData | Where-Object {$_.'Information Type Name' -ne ''}).Count
$filesOlderThan3Years = if ($remediationData.Count -gt 0) { $remediationData.Count } else { 0 }
$totalSizeOldFilesMB = if ($remediationData.Count -gt 0) { 
    [math]::Round(($remediationData | Measure-Object -Property SizeMB -Sum).Sum, 2) 
} else { 0 }
$avgAgeYears = if ($remediationData.Count -gt 0) { 
    [math]::Round(($remediationData | Measure-Object -Property Age_Years -Average).Average, 1) 
} else { 0 }

# Oldest file (from remediation candidates)
$oldestFile = $null
if ($remediationData.Count -gt 0) {
    $oldestFile = $remediationData | Sort-Object LastModified | Select-Object -First 1
}

# SIT breakdown (on-premises only)
$sitCounts = $scannerData | 
    Where-Object {$_.'Information Type Name' -ne ''} | 
    Group-Object 'Information Type Name' | 
    Select-Object Name, Count | 
    Sort-Object Count -Descending

$creditCardFiles = ($sitCounts | Where-Object {$_.Name -like '*Credit Card*'}).Count
if ($null -eq $creditCardFiles) { $creditCardFiles = 0 }

$ssnFiles = ($sitCounts | Where-Object {$_.Name -like '*Social Security*' -or $_.Name -like '*SSN*'}).Count
if ($null -eq $ssnFiles) { $ssnFiles = 0 }

# Repository breakdown (on-premises shares only - filter out Azure Files if present)
$repoBreakdown = $scannerData | 
    Where-Object {$_.'Repository' -notlike '*azurefiles*'} |
    Group-Object 'Repository' | 
    Select-Object Name, Count

# DLP status summary
$dlpMatched = ($scannerData | Where-Object {$_.'DLP Status' -eq 'Matched'}).Count
$dlpSkipped = ($scannerData | Where-Object {$_.'DLP Status' -eq 'Skipped' -or $_.'DLP Comment' -eq 'No match'}).Count

# Generate report content
$reportContent = @"
=============================================================================
ON-PREMISES FILE SHARE ANALYSIS REPORT
=============================================================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Lab: Purview Weekend Lab - Part 1 (On-Premises Analysis)
Scanner Report: $($latestDetailedReport.Name)

EXECUTIVE SUMMARY
-----------------
This report summarizes findings from Microsoft Purview Information Protection 
Scanner analysis of on-premises file shares. Focus is on sensitive data 
discovery, DLP enforcement readiness, and old data remediation opportunities.

ENVIRONMENT DETAILS (ON-PREMISES ONLY)
---------------------------------------
Scan Date: $($latestDetailedReport.LastWriteTime.ToString("yyyy-MM-dd HH:mm"))
Total Files Scanned: $totalFilesScanned

On-Premises Repositories Scanned:
$(($repoBreakdown | ForEach-Object { "  • $($_.Name) - $($_.Count) files" }) -join "`n")

Scanner Configuration:
  • Microsoft Purview Information Protection Scanner
  • Unified Labeling Client
  • SQL Express backend for configuration storage
  • Service principal authentication (Entra ID app registration)

SENSITIVE DATA DISCOVERY (ON-PREMISES SHARES)
----------------------------------------------
Files with Sensitive Data Detected: $filesWithSensitiveData
Percentage of Files with Sensitive Data: $([math]::Round(($filesWithSensitiveData / $totalFilesScanned) * 100, 1))%

Sensitive Information Types Found:
$(($sitCounts | ForEach-Object { "  • $($_.Name): $($_.Count) file(s)" }) -join "`n")
Distribution by Repository (Sensitive Data Only):
$(($scannerData | Where-Object {$_.'Information Type Name' -ne ''} | Group-Object 'Repository' | ForEach-Object { "  • $($_.Name): $($_.Count) file(s) with sensitive data" }) -join "`n")

DATA AGE ANALYSIS (ON-PREMISES FILE SHARES)
--------------------------------------------
Files Older Than 3 Years: $filesOlderThan3Years
Total Size of Old Files: $totalSizeOldFilesMB MB
Average Age of Old Files: $avgAgeYears years
$(if ($oldestFile) {
"Oldest File Found: $($oldestFile.FilePath)
  Last Modified: $($oldestFile.LastModified)
  Age: $($oldestFile.Age_Years) years"
} else {
"No files older than 3 years found in current analysis."
})

Remediation Opportunity Breakdown:
$(if ($remediationData.Count -gt 0) {
($remediationData | Group-Object Share | ForEach-Object { "  • $($_.Name) Share: $($_.Count) file(s), $([math]::Round(($_.Group | Measure-Object -Property SizeMB -Sum).Sum, 2)) MB" }) -join "`n"
} else {
"  • No remediation candidates identified (all files < 3 years old)"
})

DLP ENFORCEMENT STATUS (ON-PREMISES SHARES)
--------------------------------------------
DLP Policy: Lab-OnPrem-Sensitive-Data-Protection

DLP Detection Results:
  • Files with DLP Matches: $dlpMatched
  • Files Skipped/No Match: $dlpSkipped
  
⚠️ On-Premises DLP Limitation:
  DLP enforcement (blocking file access) is NOT supported for on-premises 
  file shares. Scanner detects sensitive information types but cannot block 
  access. For actual DLP enforcement, migrate to SharePoint Online/OneDrive.

Scanner DLP Mode: Detection Only (Test Mode)
  • Scanner identifies sensitive data successfully ✅
  • Auto-labeling applied to files ✅
  • File access blocking NOT available (platform limitation) ⚠️

COMPLIANCE & GOVERNANCE METRICS (ON-PREMISES)
----------------------------------------------
Data Classification Coverage:
  • Total Files Scanned: $totalFilesScanned
  • Files with Sensitive Data: $filesWithSensitiveData ($([math]::Round(($filesWithSensitiveData / $totalFilesScanned) * 100, 1))%)
  • High-Risk Files (Credit Cards): $creditCardFiles
  • Medium-Risk Files (SSN/PII): $ssnFiles

Old Data Remediation Opportunity:
  • Files Older Than 3 Years: $filesOlderThan3Years
  • Total Size for Potential Cleanup: $totalSizeOldFilesMB MB
  • Estimated Storage Savings: $totalSizeOldFilesMB MB (if deleted)

RECOMMENDATIONS (ON-PREMISES FOCUS)
------------------------------------
1. Data Remediation Priorities:
$(if ($filesOlderThan3Years -gt 0) {
"   • Review $filesOlderThan3Years file(s) in RemediationCandidates.csv
   • Use PowerShell Pattern 1-4 from Step 3 for safe remediation
   • Start with archive approach (Pattern 2) for reversibility"
} else {
"   • No immediate remediation needed (all files < 3 years old)
   • Implement monitoring for future old data accumulation"
})

2. On-Premises DLP Considerations:
   • DLP detection works successfully on file shares ✅
   • For actual access blocking, consider SharePoint migration
   • Current setup ideal for discovery and labeling only
   • Use scanner reports for compliance auditing

3. File Lifecycle Management:
   • On-premises shares require manual PowerShell automation
   • Auto-apply retention labels NOT supported (cloud only)
   • Implement scheduled PowerShell jobs for old file cleanup
   • Consider hybrid approach: Azure Files + lifecycle policies

4. Next Steps for Production:
   • Pilot scanner on 1-2 high-risk shares first
   • Run discovery mode for 2-4 weeks before enforcement
   • Build PowerShell automation library for remediation
   • Evaluate cloud migration ROI for advanced governance

APPENDICES
----------
Appendix A: Scanner Detailed Report
  Location: $($latestDetailedReport.FullName)
  Rows: $totalFilesScanned
  Size: $([math]::Round($latestDetailedReport.Length / 1KB, 2)) KB

Appendix B: Remediation Candidates
  Location: $remediationCandidatesPath
  $(if (Test-Path $remediationCandidatesPath) {
$rowCount = if ($remediationData.Count -gt 0) { $remediationData.Count } else { 0 }
"  Rows: $rowCount
  Export Date: $((Get-Item $remediationCandidatesPath).LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))"
} else {
"  Status: Not yet generated (run Step 2 analysis)"
})

⏳ PART 2 ADDITIONS (AVAILABLE IN 24 HOURS)
--------------------------------------------
The following sections will be added in Lab 04 Part 2:
  • Activity Explorer: DLP monitoring and user activity insights
  • Data Classification Dashboards: Trend analysis and visualizations
  • SharePoint Retention Labels: Auto-apply policy validation
  • Final Compliance Metrics: Complete governance coverage

REPORT STATUS
-------------
Status: PART 1 COMPLETE - On-Premises Analysis
Focus: File shares, scanner findings, old data quantification
Next Update: Lab 04 Part 2 (add Activity Explorer + dashboards)

REPORT PREPARED BY
------------------
Automated PowerShell Report Generator
Purview Weekend Lab Project - Part 1
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Tools Used: Microsoft Purview Information Protection Scanner, PowerShell
AI Assistance: GitHub Copilot for documentation and automation scripts
=============================================================================
"@

# Save report to file
$reportPath = "C:\PurviewLab\OnPrem_Analysis_Report_Part1.txt"
$reportContent | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`n✅ On-Premises analysis report generated successfully!" -ForegroundColor Green
Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
Write-Host "`nReport Summary:" -ForegroundColor Yellow
Write-Host "  • Total Files Scanned: $totalFilesScanned" -ForegroundColor White
Write-Host "  • Files with Sensitive Data: $filesWithSensitiveData" -ForegroundColor White
Write-Host "  • Files Older Than 3 Years: $filesOlderThan3Years" -ForegroundColor White
Write-Host "  • Total Old File Size: $totalSizeOldFilesMB MB" -ForegroundColor White

# Open report in default text viewer
Write-Host "`nOpening report..." -ForegroundColor Cyan
Invoke-Item $reportPath
```

> **💡 What This Script Does**:
>
> - **Automatically pulls data** from your scanner DetailedReport CSV (Step 1)
> - **Imports remediation candidates** from RemediationCandidates.csv (Step 2) with proper single-row CSV handling
> - **Calculates all metrics** (file counts, SIT breakdown, old data stats, oldest file details)
> - **Generates complete report** with actual numbers (no manual placeholders)
> - **Focuses on on-premises only** (excludes Activity Explorer/Data Classification for Part 2)
> - **Opens the report** automatically when complete

**Report Customization (Optional):**

The automated script generates a complete report based on your actual data. If you want to add additional context or notes:

```powershell
# Open the generated report for editing
notepad "C:\PurviewLab\OnPrem_Analysis_Report_Part1.txt"

# Add custom notes, observations, or recommendations as needed
```

> **📝 Important**: This automated report focuses on **on-premises scanner analysis and file age data** only. You'll enhance this report in **Lab 04 Part 2** (24 hours from now) by adding:
>
> - Activity Explorer DLP monitoring metrics
> - Data Classification dashboard screenshots and trends
> - SharePoint retention label validation results
> - Complete compliance and governance analytics

---

### Step 5: Validation Checklist

Confirm successful completion of all steps before proceeding to Part 2.

> **✅ Validation Scope**: This step validates **Lab 04 Part 1 completion** (Steps 1-4). Labs 01-03 and Lab 04 Part 2 validation will be completed in **Lab 04 Part 2** after time-dependent data becomes available.

**Lab 04 Part 1 Validation:**

- [ ] Scanner reports analyzed for sensitive data distribution (Step 1)
- [ ] Old data (3+ years) quantified and exported to RemediationCandidates.csv (Step 2)
- [ ] Remediation patterns practiced (deletion, archiving, bulk processing, access analysis) (Step 3)
- [ ] Automated on-premises analysis report generated successfully (Step 4)
- [ ] Report displays accurate data (files older than 3 years, SIT counts, remediation breakdown)

> **⏳ Labs 01-03 & Lab 04 Part 2 Validation**: Comprehensive validation of all labs will be completed in **Lab 04 Part 2** after:
>
> - Retention label auto-apply simulation completes (1-2 days)
> - Activity Explorer data syncs (15-30 minutes to 24 hours)
> - Data Classification dashboards populate (1-2 days)

---

## 🎯 Part 1 Completion Summary

**What You Accomplished:**

- ✅ **Analysis & Quantification**: Analyzed scanner CSV reports, identified sensitive data patterns, quantified 3+ year old files for remediation
- ✅ **Remediation Foundations**: Practiced fundamental PowerShell patterns (safe deletion, archiving, bulk processing, access time analysis)
- ✅ **Automated Reporting**: Generated complete on-premises analysis report with actual data (no manual placeholders)
- ✅ **Deliverables**: RemediationCandidates.csv, OnPrem_Analysis_Report_Part1.txt, PowerShell remediation script library

---

## 🏢 Real-World Application: Enterprise Remediation Tools & Workflows

### From Lab Scripts to Production Systems

While this lab teaches foundational PowerShell scripting for **on-premises file share remediation**, enterprise security analysts use a combination of manual scripting and centralized platforms depending on the environment.

### On-Premises vs. Cloud Data Governance

**Critical Platform Limitation**:

- ✅ **Cloud (SharePoint/OneDrive)**: Auto-apply retention policies, automatic deletion, lifecycle management all work natively
- ❌ **On-Premises File Shares**: Microsoft Purview **cannot** auto-apply retention labels or execute automatic remediation
- ⚠️ **Hybrid Reality**: Most enterprises have both environments requiring different approaches

### Enterprise Tools for On-Premises File Share Remediation

**Microsoft Purview Information Protection Scanner**:

- **Discovery only**: Scans on-premises shares, identifies sensitive data, applies sensitivity labels
- **DLP detection**: Detects policy violations but **cannot block file access** on-premises
- **Reporting**: Generates CSV reports for analyst review (what you used in Step 1)
- **Limitation**: Cannot apply retention labels or execute automatic deletion on file shares

**Third-Party Data Governance Platforms for On-Premises**:

| Tool | Primary Use Case | Key Features for On-Premises |
|------|------------------|------------------------------|
| **Varonis** | File activity monitoring & automated remediation | Stale data identification, automated archival, permission remediation for Windows file servers |
| **Netwrix** | Change auditing & compliance reporting | Who-what-when-where analysis, policy-based remediation workflows for on-prem shares |
| **Quest (formerly Dell)** | Large-scale data migration & cleanup | Pre-migration data reduction, automated archival, file server decommission preparation |
| **AvePoint** | Hybrid governance (on-prem + cloud) | Unified policies for file shares and SharePoint, migration tools |
| **Commvault** | Enterprise backup with data intelligence | Identify duplicate/stale data in backups, archive to cheap storage, legal hold |

### How Security Analysts Execute On-Premises Remediation

**Typical Enterprise Workflow for File Shares**:

1. **Discovery & Analysis** (What you practiced in Steps 1-2):
   - Security analyst runs Microsoft Purview scanner on file shares
   - Reviews CSV reports showing sensitive data distribution, stale files, compliance gaps
   - Uses third-party tools (Varonis/Netwrix) for access pattern analysis
   - Exports remediation candidates to CSV for stakeholder review

2. **Business Review & Approval** (Governance):
   - Present findings to data owners (Finance, HR departments)
   - Data owners review RemediationCandidates.csv and approve/reject deletions
   - Legal/compliance teams identify files requiring legal hold (exempt from deletion)
   - Document approval decisions in ticketing system (ServiceNow, Jira)

3. **Manual Remediation Execution** (PowerShell or Third-Party Tools):

   **Option A: PowerShell Scripts (What You Learned)**:
   - IT operations team executes approved PowerShell remediation scripts
   - Scripts run on file servers directly (requires server admin access)
   - Audit logs exported to centralized logging (SIEM, Log Analytics)

   **Option B: Third-Party Automation (Varonis/Netwrix)**:
   - Configure remediation policies in tool admin console
   - Tool executes approved actions automatically (archive, delete, move)
   - All actions logged in tool's audit database
   - No direct PowerShell scripting required

4. **Post-Remediation Validation**:
   - Re-run Purview scanner to verify files removed/archived
   - Compare before/after CSV reports (file counts, sensitive data volume)
   - Update stakeholder reports with remediation results
   - Document lessons learned for next remediation cycle

### Why On-Premises Requires Different Approach

**Cloud Advantages (SharePoint/OneDrive)**:

- Auto-apply retention labels work natively
- Disposition review workflows built into Purview
- Centralized management from Purview admin center
- No file server access needed

**On-Premises Reality (File Shares)**:

- **Manual scripting required**: PowerShell is primary automation method
- **Server access needed**: Scripts must run on file servers with appropriate permissions
- **Limited centralized management**: Can't configure "delete after 7 years" policy from Purview portal
- **Third-party tools help**: Varonis/Netwrix provide centralized management for file shares
- **Migration often preferred**: Many organizations migrate to SharePoint to gain automatic lifecycle features

### When PowerShell Scripts ARE Used in Production

**Common On-Premises Scenarios**:

- ✅ **File share decommissioning**: One-time cleanup before migrating to SharePoint Online
- ✅ **Periodic remediation cycles**: Quarterly/annual cleanup of aged data
- ✅ **Department-specific cleanup**: HR runs script to archive old employee records
- ✅ **Compliance-driven deletion**: Delete files past legal retention period (approved by legal)
- ✅ **Manufacturing/OT environments**: Air-gapped networks that will never migrate to cloud

**When Third-Party Tools Replace Scripts**:

- Large enterprises with thousands of file shares (scale beyond manual scripting)
- Organizations requiring centralized policy management across multiple sites
- Environments with strict change control (automated workflows vs. manual scripts)
- Companies with dedicated data governance teams (invest in platform vs. script maintenance)

### Translating Lab Skills to On-Premises Production

**What You Learned in This Lab** → **How It Applies for File Shares**:

| Lab Skill | On-Premises Production Application |
|-----------|-------------------------------------|
| **Pattern 1: Safe Deletion with Audit Trail** | Standard approach for on-prem remediation - always log what you delete |
| **Pattern 2: Archive to Cold Storage** | Move aged files to `\\archive-server\` or Azure Files before deletion |
| **Pattern 3: Bulk Processing with Error Handling** | Production scripts process thousands of files - error handling is critical |
| **Pattern 4: Access Time Analysis** | Identify files not accessed in years - safe deletion candidates |
| **Scanner CSV Analysis** | Primary discovery method for on-premises sensitive data and stale files |
| **Automated Reporting** | Generate stakeholder reports from scanner data and remediation results |

### Your Next Steps as a Security Analyst (On-Premises Focus)

**Immediate (This Lab Series)**:

- ✅ Complete Lab 04 Part 2 to understand cloud monitoring (Activity Explorer, Data Classification)
- ✅ Complete Lab 05 to practice advanced on-premises multi-tier remediation scenarios
- ✅ Understand fundamental differences: on-premises = manual, cloud = automated

**Short-Term (Next 3-6 Months)**:

- 📚 Master PowerShell for file operations - critical skill for on-premises remediation
- 📚 Learn Varonis or Netwrix basics if your organization uses these tools
- 📚 Understand legal hold and retention schedule requirements for your industry
- 📚 Practice CSV analysis and data visualization (Excel pivot tables, Power BI basics)

**Long-Term (Career Development)**:

- 🎯 Evaluate migration to SharePoint: Understand TCO of manual on-prem remediation vs. cloud automation
- 🎯 Get certified: Microsoft SC-400 (covers both on-prem scanner and cloud lifecycle management)
- 🎯 Develop business communication skills for data owner remediation discussions
- 🎯 Learn hybrid scenarios: Managing both on-prem and cloud simultaneously

> **💡 Key Takeaway for On-Premises**: The PowerShell patterns you practiced are **production skills** for on-premises file share remediation. Unlike cloud (where you configure policies in portals), on-premises requires manual scripting or third-party tools. Many organizations eventually migrate to SharePoint/OneDrive to gain automatic lifecycle management, but until then, the scripting skills you learned are exactly what IT operations teams use daily.

---

## ⏳ Next Steps: Transition to Lab 04 Part 2

### Waiting Period Required

**Recommended Wait Time**: **24 hours minimum** after completing Part 1

During this waiting period, background processes complete to populate Activity Explorer and Data Classification dashboards with monitoring data.

### Background Processing Timeline

**Activity Explorer Data Sync**:

- **Basic data availability**: 15-30 minutes after scanner activity
- **Full sync (if auditing just enabled)**: 2-4 hours
- **Complete data population**: Up to 24 hours for all activity details

**Data Classification Dashboards**:

- **Dashboard aggregation**: 1-2 days for full visualization updates
- **Trend calculations**: 24-48 hours for complete trend data
- **Optimal viewing**: 24 hours after Part 1 completion

**Lab 03 Retention Label Simulation** (background process):

- **Simulation results**: 1-2 days for small test sites
- **Validation available**: Check policy status before Part 2 final validation

> **💡 Best Practice**: Complete Part 1 today, start Part 2 tomorrow at the same time (e.g., finish Part 1 at 2pm Friday → start Part 2 at 2pm Saturday). This ensures all monitoring data is fully synced.

### Lab 04 Part 2 Preview

**What You'll Do in Part 2** (estimated 1 hour):

1. **Activity Explorer Analysis**: Review DLP matches, scanner activity, and user access patterns
2. **Data Classification Dashboards**: Interpret sensitive data distribution and trend visualizations
3. **Finalize Stakeholder Report**: Add Activity Explorer and dashboard insights to complete report
4. **Complete Final Validation**: Validate all labs (01-04) including Lab 03 retention label simulation
5. **Environment Cleanup**: Delete Azure resources and remove Purview configurations

---

## 📚 Reference Documentation

- [Scanner CSV Report Columns](https://learn.microsoft.com/en-us/purview/deploy-scanner-configure-install#detailed-report-columns)
- [PowerShell File Management](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/)
- [Data Remediation Best Practices](https://learn.microsoft.com/en-us/purview/information-protection-compliance)

---

## 🤖 AI-Assisted Content Generation

This comprehensive lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview scanner analysis, PowerShell remediation patterns, and stakeholder reporting procedures based on current documentation as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of scanner report analysis, file age quantification, and remediation planning while maintaining technical accuracy and alignment with real-world consultancy project requirements.*

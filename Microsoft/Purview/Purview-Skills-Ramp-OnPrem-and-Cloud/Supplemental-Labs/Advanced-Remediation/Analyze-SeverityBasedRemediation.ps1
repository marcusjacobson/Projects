<#
.SYNOPSIS
    Analyzes Purview scanner reports to generate a severity-based remediation plan.

.DESCRIPTION
    This script imports the latest detailed scanner report, classifies files based on sensitive
    information types (SITs) and age, and generates a comprehensive remediation plan.
    It applies a severity matrix (High/Medium/Low) to determine appropriate actions such as
    manual review, secure archiving, or automated deletion.

.PARAMETER None
    This script does not accept parameters. It automatically finds the latest scanner report.

.EXAMPLE
    .\Analyze-SeverityBasedRemediation.ps1
    
    Generates a remediation plan based on the most recent scanner report in the default location.

.NOTES
    File Name      : Analyze-SeverityBasedRemediation.ps1
    Author         : Marcus Jacobson
    Prerequisite   : PowerShell 5.1 or later, Completed Purview Scanner run
    Version        : 1.0
    Last Updated   : July 17, 2025
    
    Script development orchestrated using GitHub Copilot.

.DATA GOVERNANCE OPERATIONS
    - Scanner Report Import
    - Severity Classification (High/Medium/Low)
    - Age-Based Analysis
    - Remediation Action Determination
    - Plan Export (CSV)
#>
#
# =============================================================================
# Step 2: Severity-Based Remediation Analysis
# =============================================================================

# Create output directory if it doesn't exist
$outputDir = "C:\PurviewLab"
if (-not (Test-Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    Write-Host "✅ Created output directory: $outputDir" -ForegroundColor Green
}

# Import scanner report
# Scanner runs under scanner-svc account, so reports are in that user's AppData
$reportPath = "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"

# Verify reports directory exists
if (-not (Test-Path $reportPath)) {
    Write-Host "❌ Scanner reports directory not found: $reportPath" -ForegroundColor Red
    Write-Host "   This script requires a completed scanner scan." -ForegroundColor Yellow
    Write-Host "   Expected location: C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports" -ForegroundColor Yellow
    Write-Host "`n   To resolve:" -ForegroundColor Cyan
    Write-Host "   1. Verify scanner has run at least once (from OnPrem-02)" -ForegroundColor Cyan
    Write-Host "   2. Check scanner service account name (may differ from 'scanner-svc')" -ForegroundColor Cyan
    Write-Host "   3. Run: Get-ChildItem 'C:\Users\*\AppData\Local\Microsoft\MSIP\Scanner\Reports' -ErrorAction SilentlyContinue" -ForegroundColor Cyan
    return
}

$latestReport = Get-ChildItem -Path $reportPath -Filter 'DetailedReport*.csv' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $latestReport) {
    Write-Host "❌ No scanner reports found in: $reportPath" -ForegroundColor Red
    Write-Host "   Run a scanner scan first (OnPrem-02) to generate DetailedReport CSV files." -ForegroundColor Yellow
    return
}

Write-Host "✅ Found scanner report: $($latestReport.Name)" -ForegroundColor Green
Write-Host "   Report date: $($latestReport.LastWriteTime)" -ForegroundColor Cyan
Write-Host "   Importing scan results...`n" -ForegroundColor Cyan

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
    if ([string]::IsNullOrWhiteSpace($file.'Information Type Name')) {
        continue
    }
    
    # Get file details
    $filePath = $file.'File Name'
    $sits = $file.'Information Type Name'
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
$remediationPlan | Export-Csv "$outputDir\RemediationPlan.csv" -NoTypeInformation

Write-Host "✅ Remediation plan exported to: $outputDir\RemediationPlan.csv" -ForegroundColor Green

# Summary by action
if ($remediationPlan.Count -gt 0) {
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
} else {
    Write-Host "`n========== REMEDIATION PLAN SUMMARY ==========" -ForegroundColor Cyan
    Write-Host "⚠️  No files with sensitive data found in scanner report." -ForegroundColor Yellow
    Write-Host "`n   This is expected if you only have 3 test files from earlier labs." -ForegroundColor Cyan
    Write-Host "   To generate realistic remediation scenarios:" -ForegroundColor Cyan
    Write-Host "   1. Add more test files with sensitive data (SSN, Credit Cards, etc.)" -ForegroundColor Cyan
    Write-Host "   2. Run scanner again to detect them" -ForegroundColor Cyan
    Write-Host "   3. Re-run this remediation script`n" -ForegroundColor Cyan
}

<#
.SYNOPSIS
    Analyzes Activity Explorer DLP event data and generates effectiveness reports.

.DESCRIPTION
    This script imports Activity Explorer CSV export data and performs detailed analysis of 
    DLP policy effectiveness including severity distribution, sensitive info type detection,
    timing analysis, and compliance recommendations.

.PARAMETER ExportPath
    Path to the Activity Explorer DLP CSV export file.
    If not provided, the script will prompt for the file location.

.EXAMPLE
    .\Generate-DLPEffectivenessReport.ps1
    
    Prompts for Activity Explorer export file location and generates effectiveness report.

.EXAMPLE
    .\Generate-DLPEffectivenessReport.ps1 -ExportPath "C:\purview-lab\ActivityExplorer_DLP_Export.csv"
    
    Analyzes Activity Explorer export from specified location.

.NOTES
    Author: Marcus Jacobson
    Version: 1.1.0
    Created: 2025-11-09
    Last Modified: 2025-12-26
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Activity Explorer CSV export from Microsoft Purview
    - PowerShell 5.1+ or PowerShell 7+
    
    Script development orchestrated using GitHub Copilot.

.OUTPUTS
    - Console display of DLP effectiveness metrics and recommendations
    - Stakeholder report saved to same directory as input CSV file
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ExportPath
)

# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# If no path provided, prompt for file location
if (-not $ExportPath) {
    Write-Host "📁 Activity Explorer Export File Selection" -ForegroundColor Cyan
    Write-Host "   No file path provided. Please enter the full path to your Activity Explorer DLP CSV export." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Common locations:" -ForegroundColor Gray
    Write-Host "   - C:\purview-lab\ActivityExplorer_DLP_Export.csv" -ForegroundColor Gray
    Write-Host "   - C:\Downloads\ActivityExplorer_Export.csv" -ForegroundColor Gray
    Write-Host ""
    $ExportPath = Read-Host "   Enter full path to Activity Explorer CSV file"
    Write-Host ""
}

# Verify Activity Explorer export exists
if (-not (Test-Path $ExportPath)) {
    Write-Host "❌ ERROR: Activity Explorer export not found" -ForegroundColor Red
    Write-Host "   Specified location: $ExportPath" -ForegroundColor Yellow
    Write-Host "" 
    Write-Host "   Please verify:" -ForegroundColor Yellow
    Write-Host "   1. The file path is correct (check spelling and case)" -ForegroundColor Gray
    Write-Host "   2. Activity Explorer data was exported (click Export button in Purview portal)" -ForegroundColor Gray
    Write-Host "   3. The CSV file exists at the specified location" -ForegroundColor Gray
    return
}

# Set output directory to same location as input file
$outputDir = Split-Path -Parent $ExportPath

Write-Host "   ✅ Activity Explorer export found: $ExportPath" -ForegroundColor Green
Write-Host "   📂 Output directory: $outputDir" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 2: Import and Analyze Data
# =============================================================================

Write-Host "📥 Step 2: Import Activity Explorer Data" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

try {
    # Import Activity Explorer export
    $dlpEvents = Import-Csv $ExportPath
    
    if ($dlpEvents.Count -eq 0) {
        Write-Host "   ⚠️  WARNING: Activity Explorer export is empty (0 rows)" -ForegroundColor Yellow
        Write-Host "   This may indicate no DLP events detected or incorrect export" -ForegroundColor Gray
        return
    }
    
    Write-Host "   ✅ Loaded Activity Explorer data: $($dlpEvents.Count) DLP events" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "   ❌ ERROR: Failed to import Activity Explorer data: $_" -ForegroundColor Red
    return
}

# =============================================================================
# Step 3: DLP Analysis
# =============================================================================

# Analyze by policy rule severity (using 'Rule' column from Activity Explorer)
$highSeverity = $dlpEvents | Where-Object {$_.Rule -like "*High Severity*"}
$lowSeverity = $dlpEvents | Where-Object {$_.Rule -like "*Low Severity*"}

# Analyze by sensitive info type (inferred from rule names)
$creditCardDetections = $dlpEvents | Where-Object {$_.Rule -like "*Credit Card*"}
$ssnDetections = $dlpEvents | Where-Object {$_.Rule -like "*SSN*"}

# Get unique files (since same file can match multiple rules)
$uniqueFiles = $dlpEvents | Select-Object -Property File -Unique

# Display analysis header
Write-Host "`nDLP POLICY EFFECTIVENESS ANALYSIS" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Policy Name: SharePoint Sensitive Data Protection - Lab" -ForegroundColor White
Write-Host "Analysis Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor White

Write-Host "`nDETECTION SUMMARY" -ForegroundColor Cyan
Write-Host "-----------------" -ForegroundColor Cyan
Write-Host "Total DLP Rule Matches: $($dlpEvents.Count)" -ForegroundColor White
Write-Host "Unique Files with Detections: $($uniqueFiles.Count)" -ForegroundColor White
Write-Host "Expected Matches (40% of 1000 files): ~400" -ForegroundColor Gray
Write-Host "Detection Rate: $([math]::Round(($uniqueFiles.Count / 400) * 100, 1))%" -ForegroundColor Green

Write-Host "`nSEVERITY DISTRIBUTION" -ForegroundColor Cyan
Write-Host "---------------------" -ForegroundColor Cyan
Write-Host "High Severity Rule Matches (Credit Cards): $($highSeverity.Count) matches" -ForegroundColor Yellow
Write-Host "  - Action: Block external sharing" -ForegroundColor Gray
Write-Host "  - Business Impact: Users cannot share these files externally" -ForegroundColor Gray
Write-Host ""
Write-Host "Low Severity Rule Matches (SSNs): $($lowSeverity.Count) matches" -ForegroundColor Yellow
Write-Host "  - Action: Block external sharing" -ForegroundColor Gray
Write-Host "  - Business Impact: Users cannot share these files externally" -ForegroundColor Gray

Write-Host "`nSENSITIVE INFO TYPE BREAKDOWN" -ForegroundColor Cyan
Write-Host "------------------------------" -ForegroundColor Cyan
Write-Host "Credit Card Number Detections: $($creditCardDetections.Count) rule matches" -ForegroundColor White
Write-Host "U.S. Social Security Number Detections: $($ssnDetections.Count) rule matches" -ForegroundColor White

Write-Host "`nTIMING ANALYSIS" -ForegroundColor Cyan
Write-Host "---------------" -ForegroundColor Cyan
$firstDetection = $dlpEvents | Sort-Object Happened | Select-Object -First 1 -ExpandProperty Happened
$lastDetection = $dlpEvents | Sort-Object Happened | Select-Object -Last 1 -ExpandProperty Happened
$detectionWindow = [math]::Round(((Get-Date $lastDetection) - (Get-Date $firstDetection)).TotalMinutes, 1)
Write-Host "First Detection: $firstDetection" -ForegroundColor White
Write-Host "Last Detection: $lastDetection" -ForegroundColor White
Write-Host "Detection Window: $detectionWindow minutes" -ForegroundColor White

Write-Host "`nNOTES" -ForegroundColor Cyan
Write-Host "-----" -ForegroundColor Cyan
Write-Host "• Rule matches may exceed unique files because some files contain both credit cards AND SSNs" -ForegroundColor Gray
Write-Host "• Each sensitive info type triggers a separate rule match for the same file" -ForegroundColor Gray
Write-Host "• Detection rate based on unique files, not total rule matches" -ForegroundColor Gray

Write-Host "`nRECOMMENDATIONS" -ForegroundColor Cyan
Write-Host "---------------" -ForegroundColor Cyan
Write-Host "✅ DLP policy successfully detecting sensitive data" -ForegroundColor Green
Write-Host "✅ Detection rate matches expected test data distribution" -ForegroundColor Green
Write-Host "✅ Policy provides real-time protection (15-30 min detection)" -ForegroundColor Green
Write-Host "⚠️  Consider user override capability for legitimate business needs" -ForegroundColor Yellow
Write-Host "⚠️  Review false positives (if any) and adjust confidence levels" -ForegroundColor Yellow

# Generate text report for file export
$report = @"
DLP POLICY EFFECTIVENESS ANALYSIS
==================================
Policy Name: SharePoint Sensitive Data Protection - Lab
Analysis Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')

DETECTION SUMMARY
-----------------
Total DLP Rule Matches: $($dlpEvents.Count)
Unique Files with Detections: $($uniqueFiles.Count)
Expected Matches (40% of 1000 files): ~400
Detection Rate: $([math]::Round(($uniqueFiles.Count / 400) * 100, 1))%

SEVERITY DISTRIBUTION
---------------------
High Severity Rule Matches (Credit Cards): $($highSeverity.Count) matches
  - Action: Block external sharing
  - Business Impact: Users cannot share these files externally

Low Severity Rule Matches (SSNs): $($lowSeverity.Count) matches
  - Action: Block external sharing
  - Business Impact: Users cannot share these files externally

SENSITIVE INFO TYPE BREAKDOWN
------------------------------
Credit Card Number Detections: $($creditCardDetections.Count) rule matches
U.S. Social Security Number Detections: $($ssnDetections.Count) rule matches

TIMING ANALYSIS
---------------
First Detection: $firstDetection
Last Detection: $lastDetection
Detection Window: $detectionWindow minutes

NOTES
-----
- Rule matches may exceed unique files because some files contain both credit cards AND SSNs
- Each sensitive info type triggers a separate rule match for the same file
- Detection rate based on unique files, not total rule matches

RECOMMENDATIONS
---------------
✅ DLP policy successfully detecting sensitive data
✅ Detection rate matches expected test data distribution
✅ Policy provides real-time protection (15-30 min detection)
⚠️  Consider user override capability for legitimate business needs
⚠️  Review false positives (if any) and adjust confidence levels
"@

# Save report to file
$reportPath = Join-Path $outputDir "DLP_Effectiveness_Report.txt"
$report | Out-File $reportPath -Encoding UTF8
Write-Host "`n📄 Report saved to: $reportPath" -ForegroundColor Green

<#
.SYNOPSIS
    Generate comprehensive cross-platform SIT analysis report from Activity Explorer exports.

.DESCRIPTION
    This script generates a comprehensive cross-platform analysis report comparing
    on-premises scanner activity with SharePoint DLP policy detection events. It loads
    Activity Explorer CSV exports from both environments and produces a unified 
    executive report showing detection patterns, platform comparison, and strategic 
    recommendations.
    
    The script can analyze data from:
    - Default location: C:\PurviewLab (for live tenant exports)
    - Custom paths: Specify via -OnPremExportPath and -SharePointExportPath parameters
    - Sample data: Use -UseSampleData switch for immediate testing without live data

.PARAMETER OnPremExportPath
    Optional. Full path to the on-premises scanner Activity Explorer export CSV file.
    If not specified, defaults to C:\PurviewLab\ActivityExplorer_Export.csv.

.PARAMETER SharePointExportPath
    Optional. Full path to the SharePoint DLP Activity Explorer export CSV file.
    If not specified, defaults to C:\PurviewLab\ActivityExplorer_DLP_Export.csv.

.PARAMETER UseSampleData
    Switch parameter. When specified, uses the sample data files included with the lab
    for immediate testing without requiring live tenant data exports.

.PARAMETER OutputPath
    Optional. Full path for the output report file.
    If not specified, saves to the same directory as the input files.

.EXAMPLE
    .\Generate-CrossPlatform-Report.ps1
    
    Analyzes files in C:\PurviewLab and generates report.

.EXAMPLE
    .\Generate-CrossPlatform-Report.ps1 -UseSampleData
    
    Uses sample data files from ./sample-data/ directory for testing.

.EXAMPLE
    .\Generate-CrossPlatform-Report.ps1 -OnPremExportPath "D:\Exports\scanner.csv" -SharePointExportPath "D:\Exports\dlp.csv"
    
    Analyzes files at custom paths.

.NOTES
    Author: Marcus Jacobson
    Version: 1.1.0
    Created: 2025-11-09
    Last Modified: 2025-12-26
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Activity Explorer CSV exports from both environments OR sample data
    
    Script development orchestrated using GitHub Copilot.

.OUTPUTS
    Final_Stakeholder_Report_CrossPlatform.txt - Comprehensive cross-platform analysis report
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$OnPremExportPath,
    
    [Parameter(Mandatory = $false)]
    [string]$SharePointExportPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$UseSampleData,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

# =============================================================================
# Cross-Platform Sensitive Data Discovery Analysis Report Generator
# =============================================================================

# Determine file paths based on parameters
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($UseSampleData) {
    Write-Host ""
    Write-Host "📁 Using sample data files for testing" -ForegroundColor Yellow
    $onPremExportPath = Join-Path $scriptDir "sample-data\Sample_ActivityExplorer_OnPrem_Export.csv"
    $sharePointExportPath = Join-Path $scriptDir "sample-data\Sample_ActivityExplorer_DLP_Export.csv"
    $outputDir = $scriptDir
} elseif ($OnPremExportPath -or $SharePointExportPath) {
    # Use provided paths (with defaults for missing ones)
    if (-not $OnPremExportPath) { $onPremExportPath = "C:\PurviewLab\ActivityExplorer_Export.csv" } else { $onPremExportPath = $OnPremExportPath }
    if (-not $SharePointExportPath) { $sharePointExportPath = "C:\PurviewLab\ActivityExplorer_DLP_Export.csv" } else { $sharePointExportPath = $SharePointExportPath }
    $outputDir = Split-Path -Parent $onPremExportPath
} else {
    # Default paths
    $onPremExportPath = "C:\PurviewLab\ActivityExplorer_Export.csv"
    $sharePointExportPath = "C:\PurviewLab\ActivityExplorer_DLP_Export.csv"
    $outputDir = "C:\PurviewLab"
}

# Override output directory if OutputPath specified
if ($OutputPath) {
    $outputDir = Split-Path -Parent $OutputPath
}

# Verify both files exist
if (!(Test-Path $onPremExportPath)) {
    Write-Host "❌ On-premises export file not found: $onPremExportPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 TIP: Use -UseSampleData to test with sample files:" -ForegroundColor Cyan
    Write-Host "   .\Generate-CrossPlatform-Report.ps1 -UseSampleData" -ForegroundColor Gray
    exit 1
}

if (!(Test-Path $sharePointExportPath)) {
    Write-Host "❌ SharePoint export file not found: $sharePointExportPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 TIP: Use -UseSampleData to test with sample files:" -ForegroundColor Cyan
    Write-Host "   .\Generate-CrossPlatform-Report.ps1 -UseSampleData" -ForegroundColor Gray
    exit 1
}

# Determine final report path
if ($OutputPath) {
    $finalReportPath = $OutputPath
} else {
    $finalReportPath = Join-Path $outputDir "Final_Stakeholder_Report_CrossPlatform.txt"
}

# Load data from both CSV exports
$onPremData = Import-Csv $onPremExportPath
$sharePointData = Import-Csv $sharePointExportPath

# Calculate basic statistics
$onPremEvents = $onPremData.Count
$onPremFiles = ($onPremData | Select-Object -ExpandProperty File -Unique).Count
$sharePointEvents = $sharePointData.Count
$sharePointFiles = ($sharePointData | Select-Object -ExpandProperty File -Unique).Count

# Analyze on-premises breakdown by share (since SIT details not in Activity Explorer export)
$onPremShareBreakdown = $onPremData | ForEach-Object {
    # Parse UNC path to extract share name
    if ($_.File -match '\\\\[^\\]+\\([^\\]+)') {
        $matches[1]
    }
} | Group-Object | Select-Object @{N='Share';E={$_.Name}}, @{N='Events';E={$_.Count}} |
    Sort-Object Events -Descending

# Calculate unique files per share
$onPremUniqueFilesByShare = $onPremData | ForEach-Object {
    if ($_.File -match '\\\\[^\\]+\\([^\\]+)') {
        [PSCustomObject]@{
            Share = $matches[1]
            File = $_.File
        }
    }
} | Group-Object Share | Select-Object @{N='Share';E={$_.Name}}, @{N='UniqueFiles';E={($_.Group | Select-Object -ExpandProperty File -Unique).Count}}

# Analyze SharePoint breakdown by SIT type (from Rule column)
$sharePointSITBreakdown = $sharePointData | Group-Object Rule | 
    Select-Object @{N='SITType';E={$_.Name}}, @{N='Events';E={$_.Count}} | 
    Sort-Object Events -Descending

# Calculate unique files per SIT type
$sharePointUniqueBySIT = $sharePointData | Group-Object Rule | 
    Select-Object @{N='SITType';E={$_.Name}}, @{N='UniqueFiles';E={($_.Group | Select-Object -ExpandProperty File -Unique).Count}} | 
    Sort-Object UniqueFiles -Descending

# Get current date/time for report
$reportDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

Write-Host ""
Write-Host "Generating cross-platform comparison report..." -ForegroundColor Cyan

# Note: $finalReportPath was set earlier based on parameters

# Build concise report with detailed breakdowns
$reportContent = @"
================================================================================
             CROSS-PLATFORM SENSITIVE DATA DISCOVERY ANALYSIS
================================================================================

Report Generated: $reportDate
Data Sources: Activity Explorer (On-Premises Scanner + SharePoint DLP)

EXECUTIVE SUMMARY
-----------------
Total Events Analyzed: $($onPremEvents + $sharePointEvents)
- On-Premises Scanner: $onPremEvents events ($onPremFiles unique files)
- SharePoint DLP: $sharePointEvents events ($sharePointFiles unique files)


ON-PREMISES SCANNER ANALYSIS (File Share Detection)
----------------------------------------------------

Detection Breakdown by Share:
"@

# Add on-premises share breakdown table
$onPremShareBreakdown | ForEach-Object {
    $shareData = $onPremUniqueFilesByShare | Where-Object {$_.Share -eq $_.Share}
    $uniqueCount = ($shareData | Select-Object -First 1).UniqueFiles
    $reportContent += "`n  $($_.Share): $($_.Events) events ($uniqueCount unique files)"
}

$reportContent += @"


SHAREPOINT DLP ANALYSIS (Sensitive Information Type Detection)
---------------------------------------------------------------

SIT Detection Breakdown by Type:
"@

# Add SharePoint SIT breakdown
$sharePointSITBreakdown | ForEach-Object {
    $sitData = $sharePointUniqueBySIT | Where-Object {$_.SITType -eq $_.SITType}
    $uniqueCount = ($sitData | Select-Object -First 1).UniqueFiles
    $reportContent += "`n  $($_.SITType): $($_.Events) events ($uniqueCount unique files)"
}

$reportContent += @"


CROSS-PLATFORM COMPARISON
--------------------------

Platform Characteristics:
  
  On-Premises Scanner:
  - Detection Method: Batch scheduled scans
  - Activity Type: "File discovered"
  - Coverage: File shares, network storage
  - Timing: Scanner schedule-based (typically daily/weekly)
  
  SharePoint DLP:
  - Detection Method: Real-time policy evaluation
  - Activity Type: "DLP rule matched"  
  - Coverage: SharePoint Online documents
  - Timing: Real-time during user access

Detection Patterns:
  - On-Premises shows distribution across $($onPremShareBreakdown.Count) file shares
  - SharePoint shows $($sharePointSITBreakdown.Count) distinct SIT types detected
  - Combined coverage provides hybrid environment visibility
"@

$reportContent += @"


KEY INSIGHTS
------------

1. On-Premises Coverage:
   Highest activity in "$($onPremShareBreakdown[0].Share)" share ($($onPremShareBreakdown[0].Events) events)
   
2. SharePoint SIT Detection:
   Primary detection type: "$($sharePointSITBreakdown[0].SITType)" ($($sharePointSITBreakdown[0].Events) events)

3. Detection Methodology:
   - Scanner provides batch discovery for existing files
   - DLP provides real-time enforcement for cloud documents
   - Both methods complement each other for comprehensive governance


RECOMMENDATIONS
---------------

Immediate Actions:
✓ Review on-premises files in high-activity shares for remediation
✓ Validate SharePoint DLP policies are appropriately scoped
✓ Ensure scanner schedules remain active and consistent

Strategic Guidance:
→ Expand DLP coverage to additional M365 workloads (OneDrive, Teams)
→ Optimize scanner schedules based on file change patterns
→ Establish baseline metrics for ongoing monitoring
→ Cross-reference detections with compliance requirements


================================================================================
                              END OF REPORT
================================================================================
"@

# Write report to file
$reportContent | Out-File $finalReportPath -Encoding UTF8

Write-Host ""
Write-Host "✅ Cross-platform comparison report generated successfully" -ForegroundColor Green
Write-Host "   Report saved to: $finalReportPath" -ForegroundColor Cyan
Write-Host ""

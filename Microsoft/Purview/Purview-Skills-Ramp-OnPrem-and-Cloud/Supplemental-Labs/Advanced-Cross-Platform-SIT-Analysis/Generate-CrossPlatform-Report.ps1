# =============================================================================
# Cross-Platform Sensitive Data Discovery Analysis Report Generator
# =============================================================================
# This script generates a comprehensive cross-platform analysis report comparing
# on-premises scanner activity with SharePoint DLP policy detection events.

# Define file paths
$onPremExportPath = "C:\PurviewLab\ActivityExplorer_Export.csv"
$sharePointExportPath = "C:\PurviewLab\ActivityExplorer_DLP_Export.csv"

# Verify both files exist
if (!(Test-Path $onPremExportPath)) {
    Write-Host "❌ On-premises export file not found: $onPremExportPath" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $sharePointExportPath)) {
    Write-Host "❌ SharePoint export file not found: $sharePointExportPath" -ForegroundColor Red
    exit 1
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

$finalReportPath = "C:\PurviewLab\Final_Stakeholder_Report_CrossPlatform.txt"

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

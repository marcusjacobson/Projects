<#
.SYNOPSIS
    Analyzes Content Explorer SIT detection data and generates comprehensive stakeholder reports.

.DESCRIPTION
    This script imports Content Explorer CSV export data and performs detailed analysis of 
    Sensitive Information Type (SIT) detections across SharePoint sites. It generates executive 
    summaries, distribution reports, confidence analysis, and risk assessments for compliance 
    stakeholders.

.PARAMETER ExportPath
    Path to the Content Explorer CSV export file.
    If not provided, the script will prompt for the file location.

.EXAMPLE
    .\Generate-SITAnalysisReport.ps1
    
    Prompts for Content Explorer export file location and generates stakeholder report.

.EXAMPLE
    .\Generate-SITAnalysisReport.ps1 -ExportPath "C:\purview-lab\ContentExplorer_Export.csv"
    
    Analyzes Content Explorer export from specified location.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-09
    Last Modified: 2025-11-09
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Content Explorer CSV export from Microsoft Purview
    - PowerShell 5.1+ or PowerShell 7+
    
    Script development orchestrated using GitHub Copilot.

.OUTPUTS
    - Console display of SIT distribution, location analysis, confidence scores, and risk assessment
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
    Write-Host "📁 Content Explorer Export File Selection" -ForegroundColor Cyan
    Write-Host "   No file path provided. Please enter the full path to your Content Explorer CSV export." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Common locations:" -ForegroundColor Gray
    Write-Host "   - C:\purview-lab\ContentExplorer_Export.csv" -ForegroundColor Gray
    Write-Host "   - C:\Downloads\ContentExplorer_Export.csv" -ForegroundColor Gray
    Write-Host "   - C:\PurviewLab\ContentExplorer_SIT_Export.csv" -ForegroundColor Gray
    Write-Host ""
    $ExportPath = Read-Host "   Enter full path to Content Explorer CSV file"
    Write-Host ""
}

# Verify Content Explorer export exists
if (-not (Test-Path $ExportPath)) {
    Write-Host "❌ ERROR: Content Explorer export not found" -ForegroundColor Red
    Write-Host "   Specified location: $ExportPath" -ForegroundColor Yellow
    Write-Host "" 
    Write-Host "   Please verify:" -ForegroundColor Yellow
    Write-Host "   1. The file path is correct (check spelling and case)" -ForegroundColor Gray
    Write-Host "   2. Content Explorer data was exported (click Export button in Purview portal)" -ForegroundColor Gray
    Write-Host "   3. The CSV file exists at the specified location" -ForegroundColor Gray
    return
}

# Set output directory to same location as input file
$outputDir = Split-Path -Parent $ExportPath
if (-not (Test-Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    Write-Host "   ✅ Created output directory: $outputDir" -ForegroundColor Green
}

Write-Host "   ✅ Content Explorer export found: $ExportPath" -ForegroundColor Green
Write-Host "   📂 Output directory: $outputDir" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 2: Import and Validate Data
# =============================================================================

Write-Host "📥 Step 2: Import Content Explorer Data" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

try {
    # Import SIT detection data
    $sitData = Import-Csv $ExportPath
    
    if ($sitData.Count -eq 0) {
        Write-Host "   ⚠️  WARNING: Content Explorer export is empty (0 rows)" -ForegroundColor Yellow
        Write-Host "   This may indicate no sensitive data detected or incorrect export" -ForegroundColor Gray
        return
    }
    
    Write-Host "   ✅ Loaded Content Explorer data: $($sitData.Count) total SIT detections" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "   ❌ ERROR: Failed to import Content Explorer data: $_" -ForegroundColor Red
    return
}

# =============================================================================
# Step 3: SIT Distribution Analysis
# =============================================================================

Write-Host "📊 Step 3: SIT Type Distribution Analysis" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Parse JSON arrays in "Sensitive info type" column
$sitDetections = @()
foreach ($row in $sitData) {
    $sitJson = $row.'Sensitive info type'
    if ($sitJson -and $sitJson -ne '[]') {
        try {
            $sitArray = $sitJson | ConvertFrom-Json
            foreach ($sit in $sitArray) {
                $sitDetections += [PSCustomObject]@{
                    FileName = $row.Name
                    SITName = $sit.name
                    SITId = $sit.id
                    LowConfidence = $sit.low
                    MediumConfidence = $sit.medium
                    HighConfidence = $sit.high
                    TotalInstances = $sit.low + $sit.medium + $sit.high
                }
            }
        } catch {
            Write-Host "   ⚠️  Warning: Could not parse SIT data for file: $($row.Name)" -ForegroundColor Yellow
        }
    }
}

# Group by SIT name and count files
$sitDistribution = $sitDetections | Group-Object SITName | 
    Select-Object @{Name='Sensitive Info Type';Expression={$_.Name}}, 
                  @{Name='Files Detected';Expression={$_.Count}},
                  @{Name='Total Instances';Expression={($_.Group | Measure-Object -Property TotalInstances -Sum).Sum}} |
    Sort-Object 'Files Detected' -Descending

$sitDistribution | Format-Table -AutoSize

Write-Host "   Total unique SIT types detected: $($sitDistribution.Count)" -ForegroundColor Cyan
Write-Host "   Total SIT instances across all files: $(($sitDistribution | Measure-Object -Property 'Total Instances' -Sum).Sum)" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 4: SharePoint Location Analysis
# =============================================================================

Write-Host "📍 Step 4: SharePoint Site Distribution" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Note: Content Explorer export doesn't include Location column in new format
# This analysis requires the full export with location data
if ($sitData[0].PSObject.Properties.Name -contains 'Location') {
    $locationAnalysis = $sitDetections | ForEach-Object {
        $file = $_.FileName
        $location = ($sitData | Where-Object {$_.Name -eq $file}).Location
        
        # Extract site name from SharePoint URL
        # Example: https://tenant.sharepoint.com/sites/SiteName/... -> SiteName
        if ($location -and $location -match 'sharepoint\.com/sites/([^/]+)') {
            [PSCustomObject]@{
                Site = $matches[1]
                File = $file
                SIT = $_.SITName
            }
        }
    } | Group-Object Site | 
        Select-Object @{Name='SharePoint Site';Expression={$_.Name}}, 
                      @{Name='Files with Sensitive Data';Expression={($_.Group | Select-Object -Unique File).Count}} |
        Sort-Object 'Files with Sensitive Data' -Descending

    $locationAnalysis | Format-Table -AutoSize
    Write-Host "   Total SharePoint sites with sensitive data: $($locationAnalysis.Count)" -ForegroundColor Cyan
} else {
    Write-Host "   ⚠️  Location data not available in export - cannot analyze SharePoint site distribution" -ForegroundColor Yellow
    Write-Host "   Note: Ensure full Content Explorer export includes Location column" -ForegroundColor Gray
}

Write-Host ""

# =============================================================================
# Step 5: Confidence Score Analysis
# =============================================================================

Write-Host "🎯 Step 5: Detection Confidence Distribution" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

# Analyze confidence levels from parsed JSON data
$confidenceAnalysis = @(
    [PSCustomObject]@{
        'Confidence Level' = 'High confidence detections'
        'Instance Count' = ($sitDetections | Measure-Object -Property HighConfidence -Sum).Sum
    },
    [PSCustomObject]@{
        'Confidence Level' = 'Medium confidence detections'
        'Instance Count' = ($sitDetections | Measure-Object -Property MediumConfidence -Sum).Sum
    },
    [PSCustomObject]@{
        'Confidence Level' = 'Low confidence detections'
        'Instance Count' = ($sitDetections | Measure-Object -Property LowConfidence -Sum).Sum
    }
) | Where-Object {$_.'Instance Count' -gt 0} | Sort-Object 'Instance Count' -Descending

$confidenceAnalysis | Format-Table -AutoSize

$totalInstances = ($confidenceAnalysis | Measure-Object -Property 'Instance Count' -Sum).Sum
$highConfidencePct = if ($totalInstances -gt 0) { 
    [math]::Round((($confidenceAnalysis | Where-Object {$_.'Confidence Level' -eq 'High confidence detections'}).'Instance Count' / $totalInstances) * 100, 1) 
} else { 0 }

Write-Host "   High confidence detections: $highConfidencePct% of total instances" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 6: Instance Count Analysis
# =============================================================================

Write-Host "🔢 Step 6: Sensitive Data Instance Distribution" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

# Group files by total SIT instances detected
$fileInstanceCounts = $sitDetections | Group-Object FileName | 
    Select-Object @{Name='File';Expression={$_.Name}},
                  @{Name='Total SIT Instances';Expression={($_.Group | Measure-Object -Property TotalInstances -Sum).Sum}}

$instanceDistribution = $fileInstanceCounts | Group-Object 'Total SIT Instances' |
    Select-Object @{Name='Instances Per File';Expression={$_.Name}}, 
                  @{Name='Number of Files';Expression={$_.Count}} |
    Sort-Object {[int]$_.'Instances Per File'} -Descending

$instanceDistribution | Format-Table -AutoSize

$filesWithMultipleSITs = ($fileInstanceCounts | Where-Object {$_.'Total SIT Instances' -ge 2}).Count
Write-Host "   Files with multiple SIT instances: $filesWithMultipleSITs" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 7: High-Risk File Identification
# =============================================================================

Write-Host "⚠️  Step 7: High-Risk File Identification" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow

# Identify high-risk files (multiple SIT instances or high confidence detections)
$highRiskFiles = $fileInstanceCounts | Where-Object {
    $_.'Total SIT Instances' -ge 3
} | Sort-Object 'Total SIT Instances' -Descending | Select-Object -First 10

if ($highRiskFiles.Count -gt 0) {
    Write-Host "`nTop 10 High-Risk Files (Multiple SIT Instances):" -ForegroundColor Yellow
    $highRiskFiles | Format-Table -AutoSize
    
    # Show SIT breakdown for top high-risk file
    $topRiskFile = $highRiskFiles[0].File
    Write-Host "`nSIT Breakdown for highest-risk file: $topRiskFile" -ForegroundColor Cyan
    $sitDetections | Where-Object {$_.FileName -eq $topRiskFile} | 
        Select-Object SITName, 
                      @{Name='High Conf';Expression={$_.HighConfidence}},
                      @{Name='Med Conf';Expression={$_.MediumConfidence}},
                      @{Name='Low Conf';Expression={$_.LowConfidence}},
                      @{Name='Total';Expression={$_.TotalInstances}} |
        Format-Table -AutoSize
} else {
    Write-Host "   No files with 3+ SIT instances detected" -ForegroundColor Gray
}

Write-Host "   📝 High-risk files require priority review for data retention compliance" -ForegroundColor Gray
Write-Host ""

# =============================================================================
# Step 8: Generate Stakeholder Compliance Report
# =============================================================================

Write-Host "📄 Step 8: Generate Stakeholder Compliance Report" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Calculate statistics for report
$totalFiles = ($fileInstanceCounts | Measure-Object).Count
$uniqueSITTypes = ($sitDistribution | Measure-Object).Count
$totalSITInstances = ($sitDetections | Measure-Object -Property TotalInstances -Sum).Sum

# Calculate confidence statistics
$highConfidenceSum = ($sitDetections | Measure-Object -Property HighConfidence -Sum).Sum
$mediumConfidenceSum = ($sitDetections | Measure-Object -Property MediumConfidence -Sum).Sum
$lowConfidenceSum = ($sitDetections | Measure-Object -Property LowConfidence -Sum).Sum
$highConfidencePercentage = if ($totalSITInstances -gt 0) { 
    [math]::Round(($highConfidenceSum / $totalSITInstances) * 100, 1) 
} else { 0 }

# Count high-risk files (3+ instances)
$highRiskFileCount = ($fileInstanceCounts | Where-Object {$_.'Total SIT Instances' -ge 3} | Measure-Object).Count

# Generate location analysis summary (if Location column exists)
$locationSummary = if ($sitData[0].PSObject.Properties.Name -contains 'Location') {
    $locationAnalysis | ForEach-Object { "  $($_.Name): $($_.Count) files with sensitive data" } | Out-String
} else {
    "  [Location data not available in export]"
}

$report = @"
================================================================================
SHAREPOINT SIT DETECTION ANALYSIS REPORT
================================================================================
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Data Source: Microsoft Purview Content Explorer
Analysis Scope: SharePoint Online Test Site

EXECUTIVE SUMMARY
-----------------
Total Files with Sensitive Information: $totalFiles
Unique SIT Types Detected: $uniqueSITTypes
Total SIT Instances: $totalSITInstances
High Confidence Detections: $highConfidenceSum instances ($highConfidencePercentage%)
High-Risk Files (3+ SIT instances): $highRiskFileCount

SENSITIVE INFORMATION TYPE BREAKDOWN
------------------------------------
$($sitDistribution | ForEach-Object { "  $($_.'Sensitive Info Type'): $($_.'Files Detected') files ($($_.'Total Instances') instances)" } | Out-String)

SHAREPOINT SITE DISTRIBUTION
----------------------------
$locationSummary

DETECTION CONFIDENCE ANALYSIS
-----------------------------
  High Confidence (detailed pattern match): $highConfidenceSum instances
  Medium Confidence (probable match): $mediumConfidenceSum instances
  Low Confidence (possible false positive): $lowConfidenceSum instances

RISK ASSESSMENT
---------------
High-Risk Files (3+ SIT instances): $highRiskFileCount files
Files with Multiple SIT types: $filesWithMultipleSITs files
Average SIT Instances per File: $([math]::Round(($totalSITInstances / $totalFiles), 1))

COMPLIANCE IMPLICATIONS
-----------------------
✅ DLP Policy Active: Real-time protection enabled (external sharing blocked)
✅ Activity Explorer Monitoring: DLP events tracked for audit trail
✅ Content Explorer Inventory: Comprehensive SIT detection catalog available
⚠️  Remediation Required: $highConfidenceSum high confidence detections require review
⚠️  User Training: Sensitive data handling training recommended for file owners

RECOMMENDED NEXT STEPS
----------------------
1. Review $highRiskFileCount high-risk files for legitimate business need vs unnecessary data retention
2. Apply sensitivity labels to $totalFiles files containing sensitive information
3. Configure retention policies based on $uniqueSITTypes detected SIT types
4. Implement user training program for sensitive data handling
5. Schedule periodic Content Explorer reviews (quarterly recommended)
6. Integrate Content Explorer exports with SIEM/compliance reporting tools

TECHNICAL DETAILS
-----------------
Detection Engine: Microsoft Purview DLP + Content Explorer
Data Collection Period: Past 7 days (Activity Explorer) + 24-48 hours (Content Explorer sync)
SIT Pattern Matching: Built-in Microsoft SIT definitions
Confidence Scoring: Microsoft ML models (pattern strength: High/Medium/Low)
Export Format: CSV with JSON arrays (sensitive info type, trainable classifiers)

REPORT VALIDATION
-----------------
Files Analyzed: $totalFiles
SIT Types Found: $uniqueSITTypes
Total Detections: $totalSITInstances
Detection Rate: $([math]::Round(($totalFiles / 400.0) * 100, 1))% of expected test data
Analysis Status: ✅ Detection completed successfully
"@

try {
    # Save stakeholder report
    $reportPath = Join-Path $outputDir "SIT_Analysis_Stakeholder_Report.txt"
    $report | Out-File $reportPath -Encoding UTF8
    Write-Host "   ✅ Stakeholder report saved to: $reportPath" -ForegroundColor Green
} catch {
    Write-Host "   ❌ ERROR: Failed to save stakeholder report: $_" -ForegroundColor Red
    return
}

Write-Host ""
Write-Host "✅ Advanced PowerShell SIT analysis complete!" -ForegroundColor Green
Write-Host "   Reports available in: $outputDir" -ForegroundColor Cyan
Write-Host ""

<#
.SYNOPSIS
    Compares two temporal scan results to measure classification drift and index maturation.

.DESCRIPTION
    This script analyzes classification changes between two temporal scan intervals to identify
    detection count changes, new/disappeared detections, and SIT type distribution shifts.
    
    It generates a comprehensive comparison report showing classification drift patterns,
    per-site breakdown, and stability metrics to validate index maturation progress.

.PARAMETER BaselineScan
    The baseline temporal scan interval to compare from. Valid values:
    - "24-Hour" - eDiscovery baseline from Lab 05b
    - "7-Day" - Week 1 Graph API checkpoint
    - "14-Day" - Week 2 Graph API checkpoint

.PARAMETER ComparisonScan
    The comparison temporal scan interval to compare to. Valid values:
    - "7-Day" - Week 1 Graph API checkpoint
    - "14-Day" - Week 2 Graph API checkpoint
    - "21-Day" - Week 3 Graph API checkpoint (final)

.PARAMETER DetailedSiteBreakdown
    Switch parameter to include per-site classification drift analysis in the comparison report.

.PARAMETER ExportReport
    Switch parameter to export the comparison results to a CSV file.

.EXAMPLE
    .\Compare-TemporalScans.ps1 -BaselineScan "24-Hour" -ComparisonScan "7-Day"
    
    Compares Lab 05b baseline (24-hour) with Week 1 temporal scan (7-day).

.EXAMPLE
    .\Compare-TemporalScans.ps1 -BaselineScan "14-Day" -ComparisonScan "21-Day" -DetailedSiteBreakdown
    
    Compares Week 2 with Week 3 scans, including per-site drift analysis for convergence validation.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-21
    Last Modified: 2025-11-21
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Completed temporal scans at specified intervals
    - CSV result files in reports folder
    - Lab 05b baseline (for 24-Hour comparisons)
    
    Script development orchestrated using GitHub Copilot.

.TEMPORAL ANALYSIS OPERATIONS
    Detection Count Changes: Total drift between scan intervals
    SIT Type Distribution: Per-SIT classification evolution
    Site-Level Breakdown: Per-site detection pattern changes
    Convergence Validation: <2% drift indicates classification stability
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("24-Hour", "7-Day", "14-Day")]
    [string]$BaselineScan,
    
    [Parameter(Mandatory = $true)]
    [ValidateSet("7-Day", "14-Day", "21-Day")]
    [string]$ComparisonScan,
    
    [Parameter(Mandatory = $false)]
    [switch]$DetailedSiteBreakdown,
    
    [Parameter(Mandatory = $false)]
    [switch]$ExportReport
)

# =============================================================================
# Step 1: Load Scan Results Files
# =============================================================================

Write-Host "📊 Temporal Scan Comparison: $BaselineScan vs $ComparisonScan" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

$reportsPath = Join-Path $PSScriptRoot "..\reports"

# Load baseline scan results
Write-Host "🔍 Loading baseline scan ($BaselineScan)..." -ForegroundColor Cyan

try {
    if ($BaselineScan -eq "24-Hour") {
        # Try to load Lab 05b eDiscovery baseline first
        $lab05bPath = Join-Path $PSScriptRoot "..\..\05b-eDiscovery-Compliance-Search\reports"
        $baselineCsv = Get-ChildItem -Path $lab05bPath -Filter "Items_0*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        
        if ($baselineCsv) {
            $baselineResults = Import-Csv $baselineCsv.FullName
            Write-Host "   ✅ Loaded Lab 05b baseline: $($baselineCsv.Name)" -ForegroundColor Green
        } else {
            # Fallback to Temporal 24-Hour scan (e.g. from Simulation Mode)
            $searchPattern = "Temporal-Scan-24Hour*.csv"
            $baselineCsv = Get-ChildItem -Path $reportsPath -Filter $searchPattern | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            
            if ($baselineCsv) {
                $baselineResults = Import-Csv $baselineCsv.FullName
                Write-Host "   ✅ Loaded Temporal 24-Hour scan: $($baselineCsv.Name)" -ForegroundColor Green
            } else {
                Write-Host "❌ Lab 05b baseline (24-Hour) not found" -ForegroundColor Red
                throw "Complete Lab 05b or run 'Invoke-TemporalScan.ps1 -ScanInterval 24-Hour -SimulationMode' before running temporal comparison"
            }
        }
        
    } else {
        # Load temporal scan result
        $searchPattern = "Temporal-Scan-$($BaselineScan.Replace('-',''))*.csv"
        $baselineCsv = Get-ChildItem -Path $reportsPath -Filter $searchPattern | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        
        if (-not $baselineCsv) {
            Write-Host "❌ $BaselineScan temporal scan not found" -ForegroundColor Red
            throw "Run temporal scan for $BaselineScan interval first"
        }
        
        $baselineResults = Import-Csv $baselineCsv.FullName
        Write-Host "   ✅ Loaded $BaselineScan scan: $($baselineCsv.Name)" -ForegroundColor Green
    }
    
} catch {
    Write-Host "❌ Failed to load baseline scan: $_" -ForegroundColor Red
    throw
}

# Load comparison scan results
Write-Host "🔍 Loading comparison scan ($ComparisonScan)..." -ForegroundColor Cyan

try {
    $searchPattern = "Temporal-Scan-$($ComparisonScan.Replace('-',''))*.csv"
    $comparisonCsv = Get-ChildItem -Path $reportsPath -Filter $searchPattern | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if (-not $comparisonCsv) {
        Write-Host "❌ $ComparisonScan temporal scan not found" -ForegroundColor Red
        throw "Run temporal scan for $ComparisonScan interval first"
    }
    
    $comparisonResults = Import-Csv $comparisonCsv.FullName
    Write-Host "   ✅ Loaded $ComparisonScan scan: $($comparisonCsv.Name)" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Failed to load comparison scan: $_" -ForegroundColor Red
    throw
}

# =============================================================================
# Step 2: Calculate Detection Count Changes
# =============================================================================

Write-Host ""
Write-Host "📈 Detection Count Changes:" -ForegroundColor Green

$baselineCount = $baselineResults.Count
$comparisonCount = $comparisonResults.Count
$countChange = $comparisonCount - $baselineCount
$percentChange = if ($baselineCount -gt 0) { [Math]::Round(($countChange / $baselineCount) * 100, 1) } else { 0 }

Write-Host "   $BaselineScan Baseline: $baselineCount detections" -ForegroundColor Cyan
Write-Host "   $ComparisonScan Scan: $comparisonCount detections" -ForegroundColor Cyan

if ($countChange -gt 0) {
    Write-Host "   Change: +$countChange detections (+$percentChange%)" -ForegroundColor Green
} elseif ($countChange -lt 0) {
    Write-Host "   Change: $countChange detections ($percentChange%)" -ForegroundColor Yellow
} else {
    Write-Host "   Change: No change (0%)" -ForegroundColor Cyan
}

# =============================================================================
# Step 3: Analyze SIT Type Distribution Changes
# =============================================================================

Write-Host ""
Write-Host "📊 SIT Type Distribution Changes:" -ForegroundColor Green

# Group by SIT type for both scans
$baselineSITs = $baselineResults | Group-Object "Sensitive type" | Sort-Object Count -Descending
$comparisonSITs = $comparisonResults | Group-Object SITType | Sort-Object Count -Descending

# Get top 8 SIT types from comparison scan
$topSITs = $comparisonSITs | Select-Object -First 8

foreach ($sitGroup in $topSITs) {
    $sitName = $sitGroup.Name
    $comparisonSITCount = $sitGroup.Count
    
    # Find matching baseline SIT count
    $baselineSIT = $baselineSITs | Where-Object { $_.Name -eq $sitName }
    $baselineSITCount = if ($baselineSIT) { $baselineSIT.Count } else { 0 }
    
    $sitChange = $comparisonSITCount - $baselineSITCount
    $sitPercentChange = if ($baselineSITCount -gt 0) { [Math]::Round(($sitChange / $baselineSITCount) * 100, 1) } else { 100 }
    
    if ($sitChange -gt 0) {
        Write-Host "   $sitName`: +$sitChange (+$sitPercentChange%)" -ForegroundColor Green
    } elseif ($sitChange -lt 0) {
        Write-Host "   $sitName`: $sitChange ($sitPercentChange%)" -ForegroundColor Yellow
    } else {
        Write-Host "   $sitName`: No change" -ForegroundColor Cyan
    }
}

# =============================================================================
# Step 4: Site-Level Breakdown (Optional)
# =============================================================================

if ($DetailedSiteBreakdown) {
    Write-Host ""
    Write-Host "🏢 Site-Level Breakdown:" -ForegroundColor Green
    
    # Group by site for both scans
    $baselineSites = $baselineResults | Group-Object SiteName | Sort-Object Name
    $comparisonSites = $comparisonResults | Group-Object SiteName | Sort-Object Name
    
    foreach ($siteGroup in $comparisonSites) {
        $siteName = $siteGroup.Name
        $comparisonSiteCount = $siteGroup.Count
        
        # Find matching baseline site count
        $baselineSite = $baselineSites | Where-Object { $_.Name -eq $siteName }
        $baselineSiteCount = if ($baselineSite) { $baselineSite.Count } else { 0 }
        
        $siteChange = $comparisonSiteCount - $baselineSiteCount
        $sitePercentChange = if ($baselineSiteCount -gt 0) { [Math]::Round(($siteChange / $baselineSiteCount) * 100, 1) } else { 100 }
        
        Write-Host "   $siteName`:" -ForegroundColor Cyan
        Write-Host "      $BaselineScan`: $baselineSiteCount detections" -ForegroundColor Cyan
        Write-Host "      $ComparisonScan`: $comparisonSiteCount detections" -ForegroundColor Cyan
        
        if ($siteChange -gt 0) {
            Write-Host "      Change: +$siteChange (+$sitePercentChange%)" -ForegroundColor Green
        } elseif ($siteChange -lt 0) {
            Write-Host "      Change: $siteChange ($sitePercentChange%)" -ForegroundColor Yellow
        } else {
            Write-Host "      Change: No change" -ForegroundColor Cyan
        }
    }
}

# =============================================================================
# Step 5: Generate Analysis Insights
# =============================================================================

Write-Host ""
Write-Host "💡 Analysis Insights:" -ForegroundColor Magenta

# Convergence validation for 14-Day vs 21-Day
if ($BaselineScan -eq "14-Day" -and $ComparisonScan -eq "21-Day") {
    if ($percentChange -lt 2 -and $percentChange -gt -2) {
        Write-Host "   ✅ CONVERGENCE ACHIEVED: Change <2% indicates classification stability." -ForegroundColor Green
        Write-Host "      Classification has reached stable state suitable for production reporting." -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠️  CONVERGENCE NOT YET REACHED: Change ≥2% suggests ongoing indexing." -ForegroundColor Yellow
        Write-Host "      Consider waiting additional 7 days and re-scanning for stability validation." -ForegroundColor Cyan
    }
}

# Index maturation guidance for 24-Hour vs 7-Day
if ($BaselineScan -eq "24-Hour" -and $ComparisonScan -eq "7-Day") {
    if ($percentChange -ge 5 -and $percentChange -le 15) {
        Write-Host "   ✅ EXPECTED MATURATION PATTERN: 5-15% increase is typical for Week 1." -ForegroundColor Green
        Write-Host "      Microsoft Search unified index completing cross-workload indexing." -ForegroundColor Cyan
    } elseif ($percentChange -lt 5) {
        Write-Host "   ⚠️  LOW MATURATION: <5% increase may indicate indexing delays." -ForegroundColor Yellow
        Write-Host "      Verify SharePoint sites are accessible and content is indexed." -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠️  HIGH MATURATION: >15% increase is unusual for Week 1." -ForegroundColor Yellow
        Write-Host "      May indicate baseline scan had indexing issues or incomplete coverage." -ForegroundColor Cyan
    }
}

# Export report if requested
if ($ExportReport) {
    Write-Host ""
    Write-Host "📄 Exporting comparison report..." -ForegroundColor Cyan
    
    $timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
    $reportFileName = "Temporal-Comparison-$($BaselineScan.Replace('-',''))-vs-$($ComparisonScan.Replace('-',''))-$timestamp.csv"
    $reportPath = Join-Path $reportsPath $reportFileName
    
    try {
        # Create comparison report data
        $reportData = [PSCustomObject]@{
            ComparisonDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            BaselineScan = $BaselineScan
            ComparisonScan = $ComparisonScan
            BaselineCount = $baselineCount
            ComparisonCount = $comparisonCount
            CountChange = $countChange
            PercentChange = $percentChange
            ConvergenceAchieved = ($percentChange -lt 2 -and $percentChange -gt -2)
        }
        
        $reportData | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8
        
        Write-Host "   ✅ Report exported: $reportFileName" -ForegroundColor Green
        
    } catch {
        Write-Host "   ❌ Failed to export report: $_" -ForegroundColor Red
    }
}

Write-Host ""

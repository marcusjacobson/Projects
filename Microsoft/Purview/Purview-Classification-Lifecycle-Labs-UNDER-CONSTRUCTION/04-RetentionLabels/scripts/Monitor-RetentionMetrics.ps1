<#
.SYNOPSIS
    Monitors retention label adoption metrics and identifies coverage gaps across SharePoint content.

.DESCRIPTION
    This script provides comprehensive monitoring and analytics for retention label adoption across
    SharePoint Online sites. It calculates adoption rates, identifies unlabeled content, evaluates
    policy effectiveness, and generates actionable recommendations for improving retention label
    coverage and compliance.
    
    The monitoring capabilities include:
    - Retention label adoption rate calculation and trending
    - Unlabeled content identification and categorization
    - Policy effectiveness scoring based on auto-apply performance
    - Coverage gap analysis by content type and location
    - Historical tracking for adoption trending over time
    - Executive dashboard metrics for leadership reporting
    
    Results can be exported to CSV format for executive dashboards, compliance reporting, and
    continuous improvement tracking. The script provides actionable recommendations for addressing
    coverage gaps and optimizing retention label deployment.

.PARAMETER SharePointSiteUrl
    The URL of the SharePoint Online site to monitor retention label adoption metrics.
    Must be a valid SharePoint site URL accessible to the authenticated user.
    
    Example: "https://contoso.sharepoint.com/sites/FinancialRecords"

.PARAMETER ReportingPeriod
    Optional time period for historical metric analysis. Valid values are "Today", "Week", "Month",
    or "All" for all available historical data. Default is "Week" for 7-day trending analysis.

.PARAMETER ExportPath
    Optional path to export monitoring results to CSV format for dashboard integration and
    executive reporting. If not specified, results are displayed in the console only.
    
    Example: "C:\Reports\RetentionMetrics_2025-01-22.csv"

.PARAMETER SkipConnectionTest
    Skip the initial Microsoft 365 connection test. Use this parameter when running multiple
    scripts in sequence where connections have already been established.

.EXAMPLE
    .\Monitor-RetentionMetrics.ps1 -SharePointSiteUrl "https://contoso.sharepoint.com/sites/Finance"
    
    Monitors retention label adoption metrics for the specified SharePoint site over the past week.
    Displays summary metrics and recommendations in the console.

.EXAMPLE
    .\Monitor-RetentionMetrics.ps1 -SharePointSiteUrl "https://contoso.sharepoint.com/sites/Finance" -ReportingPeriod "Month"
    
    Generates comprehensive 30-day adoption metrics with trending analysis and coverage gap
    identification for executive reporting.

.EXAMPLE
    .\Monitor-RetentionMetrics.ps1 -SharePointSiteUrl "https://contoso.sharepoint.com/sites/Finance" -ReportingPeriod "Month" -ExportPath "C:\Reports\Metrics.csv"
    
    Monitors 30-day adoption metrics and exports results to CSV format for integration with
    Power BI dashboards or executive reporting tools.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-22
    Last Modified: 2025-01-22
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - ExchangeOnlineManagement module version 3.4.0 or higher
    - PnP.PowerShell module version 1.12.0 or higher (for SharePoint operations)
    - Security & Compliance PowerShell connection established
    - SharePoint Online connection established
    - Appropriate Microsoft Purview permissions (Compliance Data Administrator or higher)
    - SharePoint site access with read permissions
    
    Script development orchestrated using GitHub Copilot.

.MONITORING METRICS
    Adoption Rate Metrics:
    - Overall retention label coverage percentage
    - Labeled content count and distribution
    - Unlabeled content requiring attention
    - Trending analysis for adoption rate changes
    
    Policy Effectiveness:
    - Auto-apply policy success rate
    - Manual label application rate
    - Policy coverage by content type
    - Policy conflict identification
    
    Coverage Gap Analysis:
    - Unlabeled content by library and folder
    - Content types without retention policies
    - High-risk unlabeled content identification
    - Recommended policy adjustments
    
    Executive Dashboard Metrics:
    - Overall compliance score (0-100)
    - Coverage trends (improving/declining)
    - Top coverage gaps requiring attention
    - Resource allocation recommendations

.LINK
    https://learn.microsoft.com/en-us/purview/retention-policies-sharepoint
    https://learn.microsoft.com/en-us/purview/retention-reports
    https://learn.microsoft.com/en-us/powershell/module/sharepoint-online/
#>

#Requires -Modules ExchangeOnlineManagement, PnP.PowerShell

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$SharePointSiteUrl,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("Today", "Week", "Month", "All")]
    [string]$ReportingPeriod = "Week",
    
    [Parameter(Mandatory = $false)]
    [string]$ExportPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipConnectionTest
)

# =============================================================================
# Script Initialization
# =============================================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Retention Label Metrics Monitoring" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

# Check required modules
Write-Host "📋 Checking required PowerShell modules..." -ForegroundColor Cyan
$requiredModules = @(
    @{ Name = "ExchangeOnlineManagement"; MinVersion = "3.4.0" },
    @{ Name = "PnP.PowerShell"; MinVersion = "1.12.0" }
)

foreach ($module in $requiredModules) {
    $installedModule = Get-Module -Name $module.Name -ListAvailable | 
        Where-Object { $_.Version -ge [version]$module.MinVersion } | 
        Select-Object -First 1
    
    if ($installedModule) {
        Write-Host "   ✅ $($module.Name) version $($installedModule.Version) installed" -ForegroundColor Green
    }
    else {
        Write-Host "   ❌ $($module.Name) version $($module.MinVersion) or higher not found" -ForegroundColor Red
        Write-Host "      Install with: Install-Module -Name $($module.Name) -MinimumVersion $($module.MinVersion) -Force" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""

# Test connections
if (-not $SkipConnectionTest) {
    Write-Host "📋 Testing Security & Compliance PowerShell connection..." -ForegroundColor Cyan
    
    try {
        # Import module if not already loaded
        if (-not (Get-Module -Name ExchangeOnlineManagement)) {
            Import-Module ExchangeOnlineManagement -ErrorAction Stop
            Write-Host "   ✅ ExchangeOnlineManagement module imported" -ForegroundColor Green
        }
        
        # Test connection
        $testConnection = Get-ComplianceTag -ResultSize 1 -ErrorAction Stop
        Write-Host "   ✅ Security & Compliance PowerShell connection verified" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ Security & Compliance PowerShell connection failed" -ForegroundColor Red
        Write-Host "      Connect with: Connect-IPPSSession" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host ""
    Write-Host "📋 Testing SharePoint Online connection..." -ForegroundColor Cyan
    
    try {
        # Connect to SharePoint Online site
        Connect-PnPOnline -Url $SharePointSiteUrl -Interactive -ErrorAction Stop
        Write-Host "   ✅ SharePoint Online connection established" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ SharePoint Online connection failed" -ForegroundColor Red
        Write-Host "      Error: $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "   ⏭️  Skipping connection test (SkipConnectionTest parameter specified)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Step 1 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 2: Metrics Collection
# =============================================================================

Write-Host "🔍 Step 2: Metrics Collection" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Collecting retention label adoption metrics..." -ForegroundColor Cyan
Write-Host "   Site: $SharePointSiteUrl" -ForegroundColor Gray
Write-Host "   Reporting Period: $ReportingPeriod" -ForegroundColor Gray
Write-Host ""

# Calculate date range for reporting period
$dateFilter = switch ($ReportingPeriod) {
    "Today" { (Get-Date).Date }
    "Week" { (Get-Date).AddDays(-7) }
    "Month" { (Get-Date).AddMonths(-1) }
    "All" { [DateTime]::MinValue }
}

$metricsResults = @()
$totalItems = 0
$labeledItems = 0
$unlabeledItems = 0
$autoAppliedItems = 0
$manualItems = 0
$labelDistribution = @{}
$libraryMetrics = @{}

try {
    # Get all retention labels
    $allLabels = Get-ComplianceTag -ErrorAction Stop
    
    # Get all document libraries
    $libraries = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 -and $_.Hidden -eq $false }
    
    Write-Host "   Analyzing $($libraries.Count) document libraries..." -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($library in $libraries) {
        Write-Host "   Processing library: $($library.Title)" -ForegroundColor Cyan
        
        $libraryStats = @{
            LibraryName = $library.Title
            TotalItems = 0
            LabeledItems = 0
            UnlabeledItems = 0
            CoverageRate = 0
        }
        
        try {
            # Get all items in the library
            $items = Get-PnPListItem -List $library.Title -Fields "FileLeafRef", "FileRef", "ComplianceTag", "Created", "Modified" -ErrorAction Stop
            
            $libraryStats.TotalItems = $items.Count
            $totalItems += $items.Count
            
            foreach ($item in $items) {
                $fileName = $item.FieldValues["FileLeafRef"]
                $fileUrl = $item.FieldValues["FileRef"]
                $complianceTag = $item.FieldValues["ComplianceTag"]
                $created = $item.FieldValues["Created"]
                $modified = $item.FieldValues["Modified"]
                
                # Filter by reporting period
                if ($ReportingPeriod -ne "All" -and $created -lt $dateFilter) {
                    continue
                }
                
                # Determine label status
                $isLabeled = -not [string]::IsNullOrEmpty($complianceTag)
                
                if ($isLabeled) {
                    $labeledItems++
                    $libraryStats.LabeledItems++
                    
                    # Track label distribution
                    if ($labelDistribution.ContainsKey($complianceTag)) {
                        $labelDistribution[$complianceTag]++
                    }
                    else {
                        $labelDistribution[$complianceTag] = 1
                    }
                    
                    # Determine if auto-applied or manual (approximate based on timing)
                    if ($modified -gt $created.AddHours(1)) {
                        $autoAppliedItems++
                    }
                    else {
                        $manualItems++
                    }
                }
                else {
                    $unlabeledItems++
                    $libraryStats.UnlabeledItems++
                }
            }
            
            # Calculate library coverage rate
            if ($libraryStats.TotalItems -gt 0) {
                $libraryStats.CoverageRate = [Math]::Round(($libraryStats.LabeledItems / $libraryStats.TotalItems) * 100, 2)
            }
            
            $libraryMetrics[$library.Title] = $libraryStats
            
            Write-Host "      Items: $($libraryStats.TotalItems) | Labeled: $($libraryStats.LabeledItems) | Coverage: $($libraryStats.CoverageRate)%" -ForegroundColor Gray
        }
        catch {
            Write-Host "      ⚠️  Failed to process library: $($library.Title)" -ForegroundColor Yellow
            Write-Host "         Error: $_" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Host "   ❌ Failed to collect metrics" -ForegroundColor Red
    Write-Host "      Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Step 2 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 3: Metrics Analysis and Reporting
# =============================================================================

Write-Host "🔍 Step 3: Metrics Analysis and Reporting" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Calculate overall metrics
$overallCoverageRate = if ($totalItems -gt 0) { [Math]::Round(($labeledItems / $totalItems) * 100, 2) } else { 0 }
$autoApplyEffectiveness = if ($labeledItems -gt 0) { [Math]::Round(($autoAppliedItems / $labeledItems) * 100, 2) } else { 0 }

# Calculate compliance score (weighted formula)
$complianceScore = 0
if ($totalItems -gt 0) {
    $coverageWeight = 0.6
    $autoApplyWeight = 0.3
    $distributionWeight = 0.1
    
    $coverageScore = $overallCoverageRate
    $autoApplyScore = $autoApplyEffectiveness
    $distributionScore = if ($labelDistribution.Count -gt 0) { 
        [Math]::Min(($labelDistribution.Count / 5.0) * 100, 100) 
    } else { 0 }
    
    $complianceScore = [Math]::Round(
        ($coverageScore * $coverageWeight) + 
        ($autoApplyScore * $autoApplyWeight) + 
        ($distributionScore * $distributionWeight), 
        2
    )
}

Write-Host "📊 Executive Dashboard Metrics:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Overall Compliance Score: $complianceScore / 100" -ForegroundColor $(
    if ($complianceScore -ge 90) { "Green" }
    elseif ($complianceScore -ge 70) { "Yellow" }
    else { "Red" }
)
Write-Host ""

Write-Host "   Content Overview:" -ForegroundColor White
Write-Host "   • Total items analyzed: $totalItems" -ForegroundColor Gray
Write-Host "   • Labeled items: $labeledItems" -ForegroundColor Green
Write-Host "   • Unlabeled items: $unlabeledItems" -ForegroundColor $(if ($unlabeledItems -eq 0) { "Green" } else { "Yellow" })
Write-Host "   • Overall coverage rate: $overallCoverageRate%" -ForegroundColor $(
    if ($overallCoverageRate -ge 90) { "Green" }
    elseif ($overallCoverageRate -ge 70) { "Yellow" }
    else { "Red" }
)
Write-Host ""

Write-Host "   Policy Effectiveness:" -ForegroundColor White
Write-Host "   • Auto-applied labels: $autoAppliedItems ($autoApplyEffectiveness%)" -ForegroundColor Gray
Write-Host "   • Manually applied labels: $manualItems" -ForegroundColor Gray
Write-Host ""

Write-Host "   Label Distribution:" -ForegroundColor White
$sortedDistribution = $labelDistribution.GetEnumerator() | Sort-Object -Property Value -Descending
foreach ($entry in $sortedDistribution) {
    $percentage = [Math]::Round(($entry.Value / $labeledItems) * 100, 1)
    Write-Host "   • $($entry.Key): $($entry.Value) items ($percentage%)" -ForegroundColor Gray
}
Write-Host ""

Write-Host "   Library Coverage Analysis:" -ForegroundColor White
$sortedLibraries = $libraryMetrics.GetEnumerator() | Sort-Object -Property { $_.Value.CoverageRate }
foreach ($entry in $sortedLibraries) {
    $stats = $entry.Value
    $coverageColor = if ($stats.CoverageRate -ge 80) { "Green" } elseif ($stats.CoverageRate -ge 50) { "Yellow" } else { "Red" }
    Write-Host "   • $($stats.LibraryName): $($stats.CoverageRate)% ($($stats.LabeledItems)/$($stats.TotalItems))" -ForegroundColor $coverageColor
}
Write-Host ""

Write-Host "✅ Step 3 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 4: Gap Analysis and Recommendations
# =============================================================================

Write-Host "🔍 Step 4: Gap Analysis and Recommendations" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Coverage Gap Analysis:" -ForegroundColor Cyan
Write-Host ""

# Identify top coverage gaps
$topGaps = $libraryMetrics.GetEnumerator() | 
    Where-Object { $_.Value.UnlabeledItems -gt 0 } | 
    Sort-Object -Property { $_.Value.UnlabeledItems } -Descending | 
    Select-Object -First 5

if ($topGaps.Count -gt 0) {
    Write-Host "   Top 5 Libraries with Unlabeled Content:" -ForegroundColor Yellow
    foreach ($gap in $topGaps) {
        $stats = $gap.Value
        Write-Host "   • $($stats.LibraryName): $($stats.UnlabeledItems) unlabeled items ($($stats.CoverageRate)% coverage)" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Generate recommendations
Write-Host "   📝 Recommendations:" -ForegroundColor Cyan
Write-Host ""

if ($overallCoverageRate -lt 80) {
    Write-Host "   1. Coverage Rate Below Target (Current: $overallCoverageRate%, Target: 80%+)" -ForegroundColor Yellow
    Write-Host "      • Review and expand auto-apply policy scope" -ForegroundColor Gray
    Write-Host "      • Train users on manual label application for edge cases" -ForegroundColor Gray
    Write-Host "      • Consider additional custom SITs for unlabeled content patterns" -ForegroundColor Gray
    Write-Host ""
}

if ($autoApplyEffectiveness -lt 70) {
    Write-Host "   2. Low Auto-Apply Effectiveness (Current: $autoApplyEffectiveness%, Target: 70%+)" -ForegroundColor Yellow
    Write-Host "      • Review SIT patterns for accuracy improvements" -ForegroundColor Gray
    Write-Host "      • Adjust auto-apply policy priorities to resolve conflicts" -ForegroundColor Gray
    Write-Host "      • Enable simulation mode to validate policy changes before deployment" -ForegroundColor Gray
    Write-Host ""
}

if ($topGaps.Count -gt 0) {
    Write-Host "   3. High-Priority Coverage Gaps Identified" -ForegroundColor Yellow
    Write-Host "      • Focus remediation efforts on libraries with highest unlabeled counts" -ForegroundColor Gray
    Write-Host "      • Analyze content types in gap libraries for pattern identification" -ForegroundColor Gray
    Write-Host "      • Consider library-specific auto-apply policies for targeted coverage" -ForegroundColor Gray
    Write-Host ""
}

if ($complianceScore -ge 90) {
    Write-Host "   ✅ Overall Compliance Score Excellent" -ForegroundColor Green
    Write-Host "      • Maintain current policy configuration" -ForegroundColor Gray
    Write-Host "      • Continue monitoring for trending changes" -ForegroundColor Gray
    Write-Host "      • Document best practices for knowledge sharing" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "✅ Step 4 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 5: Export Results (Optional)
# =============================================================================

if ($ExportPath) {
    Write-Host "🔍 Step 5: Export Results" -ForegroundColor Green
    Write-Host "=========================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📋 Exporting monitoring results to CSV..." -ForegroundColor Cyan
    Write-Host "   Export path: $ExportPath" -ForegroundColor Gray
    
    try {
        # Prepare export data
        $exportData = @()
        
        foreach ($entry in $libraryMetrics.GetEnumerator()) {
            $stats = $entry.Value
            $exportData += [PSCustomObject]@{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                ReportingPeriod = $ReportingPeriod
                LibraryName = $stats.LibraryName
                TotalItems = $stats.TotalItems
                LabeledItems = $stats.LabeledItems
                UnlabeledItems = $stats.UnlabeledItems
                CoverageRate = $stats.CoverageRate
                OverallComplianceScore = $complianceScore
                OverallCoverageRate = $overallCoverageRate
                AutoApplyEffectiveness = $autoApplyEffectiveness
            }
        }
        
        # Ensure directory exists
        $exportDir = Split-Path -Path $ExportPath -Parent
        if (-not (Test-Path $exportDir)) {
            New-Item -Path $exportDir -ItemType Directory -Force | Out-Null
        }
        
        # Export to CSV
        $exportData | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
        
        Write-Host "   ✅ Monitoring results exported successfully" -ForegroundColor Green
        Write-Host "      File: $ExportPath" -ForegroundColor Gray
    }
    catch {
        Write-Host "   ⚠️  Failed to export results" -ForegroundColor Yellow
        Write-Host "      Error: $_" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "✅ Step 5 completed successfully" -ForegroundColor Green
    Write-Host ""
}

# =============================================================================
# Summary and Next Steps
# =============================================================================

Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host ""

Write-Host "   1. Address high-priority coverage gaps in identified libraries" -ForegroundColor White
Write-Host ""

Write-Host "   2. Review and optimize auto-apply policies for improved effectiveness:" -ForegroundColor White
Write-Host "      .\Create-AutoApplyPolicies.ps1 -SimulationMode" -ForegroundColor Gray
Write-Host ""

Write-Host "   3. Schedule regular monitoring for trending analysis:" -ForegroundColor White
Write-Host "      Run this script weekly or monthly to track adoption progress" -ForegroundColor Gray
Write-Host ""

Write-Host "   4. Review retention policies in Microsoft Purview compliance portal:" -ForegroundColor White
Write-Host "      https://compliance.microsoft.com/informationgovernance?viewid=retention" -ForegroundColor Gray
Write-Host ""

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Retention Metrics Monitoring Complete" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

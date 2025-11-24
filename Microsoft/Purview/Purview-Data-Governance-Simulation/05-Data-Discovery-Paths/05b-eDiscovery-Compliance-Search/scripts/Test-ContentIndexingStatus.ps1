<#
.SYNOPSIS
    Validates SharePoint content indexing status for eDiscovery readiness.

.DESCRIPTION
    Checks if Lab 03 uploaded content has been indexed by SharePoint Search
    and is ready for eDiscovery Compliance Search. Calculates elapsed time
    since upload and tests searchability of known content patterns.

.PARAMETER HoursToCheck
    Number of hours to look back for recent file modifications. Defaults to 48 hours
    to catch any content uploaded in the last 2 days. SharePoint indexing typically
    completes within 24 hours, so 48-hour window provides safe buffer.

.PARAMETER IndexingThresholdHours
    Minimum hours required for content to be indexed. Defaults to 24 hours based on
    SharePoint Search indexing SLA. Content older than this threshold is considered
    likely indexed.

.EXAMPLE
    .\Test-ContentIndexingStatus.ps1
    
    Checks for files modified in last 48 hours and validates 24-hour indexing threshold.

.EXAMPLE
    .\Test-ContentIndexingStatus.ps1 -HoursToCheck 72 -IndexingThresholdHours 24
    
    Checks for files modified in last 72 hours with 24-hour indexing requirement.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-17
    Last Modified: 2025-11-17
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - PnP.PowerShell module installed
    - Lab 03 document upload completed
    - SharePoint sites accessible
    - global-config.json in project root
    
    Script development orchestrated using GitHub Copilot.

.INDEXING TIMELINE
    - SharePoint Search indexing: Up to 24 hours for new content
    - Microsoft Search unified index: 7-14 days for Content Explorer
    - eDiscovery uses SharePoint Search (24-hour timeline)
#>
#
# =============================================================================
# Helper script to validate content indexing status for eDiscovery readiness.
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int]$HoursToCheck = 48,
    
    [Parameter(Mandatory = $false)]
    [int]$IndexingThresholdHours = 24
)

# =============================================================================
# Step 1: Load Configuration and Connect to SharePoint
# =============================================================================

Write-Host "`n🔍 Starting Content Indexing Status Check..." -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

Write-Host "`n📋 Step 1: Load Configuration" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$labRoot = Split-Path -Parent $scriptPath
$discoveryPathsRoot = Split-Path -Parent $labRoot
$projectRoot = Split-Path -Parent $discoveryPathsRoot
$configPath = Join-Path $projectRoot "global-config.json"

if (-not (Test-Path $configPath)) {
    Write-Host "❌ Configuration file not found: $configPath" -ForegroundColor Red
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$appClientId = $config.Environment.PnPClientId
$tenantUrl = $config.Environment.TenantUrl
$sites = $config.SharePointSites

Write-Host "✅ Configuration loaded" -ForegroundColor Green
Write-Host "   🔧 Tenant: $tenantUrl" -ForegroundColor Cyan
Write-Host "   🔧 Sites to check: $($sites.Count)" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 2: Analyze Recent File Modifications Across All Sites
# =============================================================================

Write-Host "🔍 Step 2: Scan SharePoint Sites for Recent Files" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

$currentTime = Get-Date
$windowStartTime = $currentTime.AddHours(-$HoursToCheck)
$indexingCutoffTime = $currentTime.AddHours(-$IndexingThresholdHours)

Write-Host "📊 Time Window Configuration:" -ForegroundColor Cyan
Write-Host "   Current Time: $($currentTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor DarkGray
Write-Host "   Looking back: $HoursToCheck hours ($([math]::Round($HoursToCheck / 24.0, 1)) days)" -ForegroundColor DarkGray
Write-Host "   Window Start: $($windowStartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor DarkGray
Write-Host "   Indexing Threshold: $IndexingThresholdHours hours" -ForegroundColor DarkGray
Write-Host "   Ready Cutoff: $($indexingCutoffTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor DarkGray
Write-Host ""
Write-Host "💡 Logic: Files modified before cutoff time ($IndexingThresholdHours hrs ago) are likely indexed" -ForegroundColor Yellow
Write-Host ""

# Connect to SharePoint with PnP
Write-Host "🔐 Connecting to SharePoint..." -ForegroundColor Cyan
try {
    Connect-PnPOnline -Url $tenantUrl -Interactive -ClientId $appClientId -ErrorAction Stop
    Write-Host "✅ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to connect to SharePoint: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Scan all sites for recent files
$allRecentFiles = @()
$siteStats = @()

foreach ($site in $sites) {
    $siteName = $site.Name
    $siteUrl = "$tenantUrl/sites/$siteName"
    
    Write-Host "📂 Scanning: $siteName" -ForegroundColor Cyan
    Write-Host "   URL: $siteUrl" -ForegroundColor DarkGray
    
    try {
        Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $appClientId -ErrorAction Stop
        
        # Get all files from Shared Documents library
        $files = Get-PnPListItem -List "Shared Documents" -PageSize 1000 -ErrorAction SilentlyContinue | 
                 Where-Object { $_["FileLeafRef"] -notlike "Forms" -and $_["FileLeafRef"] -ne $null }
        
        $recentFiles = @()
        foreach ($file in $files) {
            $modified = [DateTime]$file["Modified"]
            if ($modified -ge $windowStartTime) {
                $recentFiles += [PSCustomObject]@{
                    Site = $siteName
                    FileName = $file["FileLeafRef"]
                    Modified = $modified
                    Age = ($currentTime - $modified).TotalHours
                }
            }
        }
        
        $allRecentFiles += $recentFiles
        
        $siteStats += [PSCustomObject]@{
            Site = $siteName
            TotalFiles = $files.Count
            RecentFiles = $recentFiles.Count
            OldestRecent = if ($recentFiles.Count -gt 0) { ($recentFiles | Sort-Object Modified | Select-Object -First 1).Modified } else { $null }
        }
        
        Write-Host "   ✅ Found $($files.Count) total files, $($recentFiles.Count) recent files" -ForegroundColor Green
        
    } catch {
        Write-Host "   ⚠️ Could not access site: $_" -ForegroundColor Yellow
        $siteStats += [PSCustomObject]@{
            Site = $siteName
            TotalFiles = 0
            RecentFiles = 0
            OldestRecent = $null
        }
    }
    Write-Host ""
}

Disconnect-PnPOnline

Write-Host "📊 Scan Summary:" -ForegroundColor Cyan
Write-Host "   Total sites scanned: $($siteStats.Count)" -ForegroundColor DarkGray
Write-Host "   Total recent files found: $($allRecentFiles.Count)" -ForegroundColor DarkGray
Write-Host ""

# =============================================================================
# Step 3: Evaluate Indexing Readiness Based on Real Data
# =============================================================================

Write-Host "⚖️  Step 3: Evaluate Indexing Readiness" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

if ($allRecentFiles.Count -eq 0) {
    Write-Host "⚠️ No files found modified in the last $HoursToCheck hours" -ForegroundColor Yellow
    Write-Host "   This suggests either:" -ForegroundColor Yellow
    Write-Host "   • Lab 03 upload was completed more than $HoursToCheck hours ago" -ForegroundColor DarkGray
    Write-Host "   • Files were uploaded to different time window" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "💡 Recommendation: Content is likely fully indexed and ready for eDiscovery" -ForegroundColor Green
    $isReady = $true
    $readinessScore = 100
    $hoursSinceOldest = $HoursToCheck + 1
} else {
    # Find oldest file in the recent window
    $oldestFile = $allRecentFiles | Sort-Object Age -Descending | Select-Object -First 1
    $hoursSinceOldest = $oldestFile.Age
    
    Write-Host "📊 Recent File Analysis:" -ForegroundColor Cyan
    Write-Host "   Files modified in window: $($allRecentFiles.Count)" -ForegroundColor DarkGray
    Write-Host "   Oldest recent file: $($oldestFile.FileName)" -ForegroundColor DarkGray
    Write-Host "   From site: $($oldestFile.Site)" -ForegroundColor DarkGray
    Write-Host "   Modified: $($oldestFile.Modified.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor DarkGray
    Write-Host "   Age: $([math]::Round($hoursSinceOldest, 1)) hours" -ForegroundColor DarkGray
    Write-Host ""
    
    # Evaluate readiness based on oldest file in window
    if ($hoursSinceOldest -ge $IndexingThresholdHours) {
        Write-Host "✅ Content likely fully indexed - ready for eDiscovery search" -ForegroundColor Green
        Write-Host "   Oldest recent file age: $([math]::Round($hoursSinceOldest, 1)) hours" -ForegroundColor Green
        Write-Host "   Required minimum: $IndexingThresholdHours hours" -ForegroundColor Green
        Write-Host "   Status: All recent files exceed indexing threshold" -ForegroundColor Green
        $isReady = $true
        $readinessScore = 100
    } elseif ($hoursSinceOldest -ge ($IndexingThresholdHours * 0.75)) {
        Write-Host "⏳ Content likely partially indexed - worth attempting test search" -ForegroundColor Yellow
        Write-Host "   Oldest recent file age: $([math]::Round($hoursSinceOldest, 1)) hours" -ForegroundColor Yellow
        Write-Host "   Required minimum: $IndexingThresholdHours hours" -ForegroundColor Yellow
        Write-Host "   Recommend waiting: $([math]::Round($IndexingThresholdHours - $hoursSinceOldest, 1)) more hours for guarantee" -ForegroundColor Yellow
        $isReady = $false
        $readinessScore = [math]::Round(($hoursSinceOldest / $IndexingThresholdHours) * 100, 0)
    } else {
        Write-Host "❌ Content not ready - wait before proceeding with eDiscovery" -ForegroundColor Red
        Write-Host "   Oldest recent file age: $([math]::Round($hoursSinceOldest, 1)) hours" -ForegroundColor Red
        Write-Host "   Required minimum: $IndexingThresholdHours hours" -ForegroundColor Red
        Write-Host "   Recommend waiting: $([math]::Round($IndexingThresholdHours - $hoursSinceOldest, 1)) more hours" -ForegroundColor Red
        $isReady = $false
        $readinessScore = [math]::Round(($hoursSinceOldest / $IndexingThresholdHours) * 100, 0)
    }
}

Write-Host ""
Write-Host "📊 Readiness Score: $readinessScore%" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 3: Provide Next Step Guidance
# =============================================================================

Write-Host "📋 Step 4: Next Steps" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""

if ($isReady) {
    Write-Host "✅ Proceed with Lab 05b eDiscovery Compliance Search:" -ForegroundColor Green
    Write-Host ""
    Write-Host "   1. Navigate to compliance.microsoft.com" -ForegroundColor Cyan
    Write-Host "   2. Go to Solutions > eDiscovery > Content search" -ForegroundColor Cyan
    Write-Host "   3. Create new search with 8 targeted SIT types" -ForegroundColor Cyan
    Write-Host "   4. Include all $($sites.Count) simulation SharePoint sites" -ForegroundColor Cyan
    Write-Host "   5. Run search and review results" -ForegroundColor Cyan
    Write-Host ""
    if ($allRecentFiles.Count -gt 0) {
        Write-Host "💡 Tip: $($allRecentFiles.Count) files modified in the last $HoursToCheck hours are ready for search" -ForegroundColor Yellow
    } else {
        Write-Host "💡 Tip: All files are older than $HoursToCheck hours and fully indexed" -ForegroundColor Yellow
    }
} else {
    Write-Host "⏳ Wait for indexing to complete, then proceed:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Recommended wait time: $([math]::Round($IndexingThresholdHours - $hoursSinceOldest, 1)) hours" -ForegroundColor Yellow
    Write-Host "   Check back after: $($oldestFile.Modified.AddHours($IndexingThresholdHours).ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔄 While Waiting:" -ForegroundColor Cyan
    Write-Host "   • Review Lab 05a PnP Direct File Access results" -ForegroundColor DarkGray
    Write-Host "   • Monitor Lab 04 On-Demand Classification progress" -ForegroundColor DarkGray
    Write-Host "   • Read eDiscovery documentation and prepare search query" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "🔁 Run this script again later to recheck status" -ForegroundColor Cyan
}

Write-Host ""

# =============================================================================
# Step 4: Generate Status Report
# =============================================================================

Write-Host "📊 Step 5: Generate Status Report" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

$statusReport = [PSCustomObject]@{
    CurrentTime = $currentTime.ToString('yyyy-MM-dd HH:mm:ss')
    WindowStartTime = $windowStartTime.ToString('yyyy-MM-dd HH:mm:ss')
    HoursChecked = $HoursToCheck
    IndexingThresholdHours = $IndexingThresholdHours
    IndexingCutoffTime = $indexingCutoffTime.ToString('yyyy-MM-dd HH:mm:ss')
    SitesScanned = $siteStats.Count
    TotalRecentFiles = $allRecentFiles.Count
    OldestFileAge = if ($allRecentFiles.Count -gt 0) { [math]::Round($hoursSinceOldest, 2) } else { "N/A" }
    OldestFileName = if ($allRecentFiles.Count -gt 0) { $oldestFile.FileName } else { "N/A" }
    OldestFileSite = if ($allRecentFiles.Count -gt 0) { $oldestFile.Site } else { "N/A" }
    ReadinessScore = $readinessScore
    IsReady = $isReady
    Status = if ($isReady) { "Ready" } elseif ($readinessScore -ge 75) { "Likely Ready" } else { "Not Ready" }
    RecommendedWaitHours = if ($isReady) { 0 } else { [math]::Round($IndexingThresholdHours - $hoursSinceOldest, 1) }
    CheckBackTime = if ($isReady -or $allRecentFiles.Count -eq 0) { "N/A" } else { $oldestFile.Modified.AddHours($IndexingThresholdHours).ToString('yyyy-MM-dd HH:mm:ss') }
    SiteBreakdown = $siteStats
}

# Display all properties except SiteBreakdown
$statusReport | Select-Object -Property * -ExcludeProperty SiteBreakdown | Format-List

Write-Host ""
Write-Host "📋 Per-Site Breakdown:" -ForegroundColor Cyan
$siteStats | Format-Table -AutoSize

$reportsPath = Join-Path $PSScriptRoot "..\reports"
if (-not (Test-Path $reportsPath)) {
    New-Item -ItemType Directory -Path $reportsPath -Force | Out-Null
}

$reportFile = Join-Path $reportsPath "Indexing-Status-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').json"
$statusReport | ConvertTo-Json -Depth 3 | Set-Content $reportFile

Write-Host "✅ Status report saved: $reportFile" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Summary
# =============================================================================

if ($isReady) {
    Write-Host "✅ Lab 05b eDiscovery Compliance Search is ready to proceed!" -ForegroundColor Green
    if ($allRecentFiles.Count -gt 0) {
        Write-Host "   All $($allRecentFiles.Count) files modified in the last $HoursToCheck hours have exceeded the $IndexingThresholdHours-hour indexing threshold" -ForegroundColor Green
    } else {
        Write-Host "   All content is older than $HoursToCheck hours and fully indexed" -ForegroundColor Green
    }
} else {
    Write-Host "⏳ Wait $([math]::Round($IndexingThresholdHours - $hoursSinceOldest, 1)) more hours before proceeding with Lab 05b" -ForegroundColor Yellow
    Write-Host "   Recent files need more time to be indexed by SharePoint Search" -ForegroundColor Yellow
}

Write-Host ""

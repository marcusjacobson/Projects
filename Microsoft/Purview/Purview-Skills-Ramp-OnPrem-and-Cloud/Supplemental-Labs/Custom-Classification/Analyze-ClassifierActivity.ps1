<#
.SYNOPSIS
    Analyzes Activity Explorer export data for trainable classifier DLP policy activity.

.DESCRIPTION
    This script imports Activity Explorer CSV export data and generates an executive summary
    report showing total detections, unique users, blocked actions, and top locations for
    trainable classifier DLP policy matches.

.PARAMETER ExportPath
    Path to the Activity Explorer CSV export file.
    Default: C:\Downloads\Activity explorer _ Microsoft Purview.csv

.EXAMPLE
    .\Analyze-ClassifierActivity.ps1
    
    Analyzes Activity Explorer data using default export path.

.EXAMPLE
    .\Analyze-ClassifierActivity.ps1 -ExportPath "C:\PurviewLab\ActivityExplorer_Export.csv"
    
    Analyzes Activity Explorer data from custom path.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-11
    Last Modified: 2025-11-11
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Activity Explorer export CSV file
    - PowerShell 5.1+ or PowerShell 7+
    
    Script development orchestrated using GitHub Copilot.

.ANALYSIS CATEGORIES
    - Total trainable classifier detections
    - Unique users triggering DLP policies
    - Blocked sharing attempts
    - Top locations by activity volume
#>

# =============================================================================
# Analyzes Activity Explorer data for trainable classifier DLP policy activity.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ExportPath = "C:\Downloads\Activity explorer _ Microsoft Purview.csv"
)

# =============================================================================
# Step 1: Validate Export File
# =============================================================================

Write-Host "🔍 Step 1: Validate Export File" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

if (-not (Test-Path $ExportPath)) {
    Write-Host "   ❌ ERROR: Activity Explorer export not found" -ForegroundColor Red
    Write-Host "   Expected location: $ExportPath" -ForegroundColor Yellow
    Write-Host "" -ForegroundColor Yellow
    Write-Host "   Please complete these steps first:" -ForegroundColor Yellow
    Write-Host "   1. Navigate to Activity Explorer in Purview portal" -ForegroundColor Gray
    Write-Host "   2. Apply filters: DLP matched + Financial Reports Classifier + 30 days" -ForegroundColor Gray
    Write-Host "   3. Click Export button and save CSV file" -ForegroundColor Gray
    Write-Host "   4. Update -ExportPath parameter to match saved file location" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "   ✅ Export file found: $ExportPath" -ForegroundColor Green

# =============================================================================
# Step 2: Import Activity Data
# =============================================================================

Write-Host "`n📊 Step 2: Import Activity Data" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

try {
    $activities = Import-Csv $ExportPath
    Write-Host "   ✅ Loaded $($activities.Count) activity records" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to import CSV: $_" -ForegroundColor Red
    exit 1
}

if ($activities.Count -eq 0) {
    Write-Host "   ⚠️  WARNING: Activity Explorer export is empty (0 rows)" -ForegroundColor Yellow
    Write-Host "   This may indicate:" -ForegroundColor Gray
    Write-Host "   - No DLP policy activity has synced to Activity Explorer yet (wait 1-24 hours)" -ForegroundColor Gray
    Write-Host "   - Incorrect filters applied during export" -ForegroundColor Gray
    Write-Host "   - No content matching the trainable classifier detected yet" -ForegroundColor Gray
    exit 0
}

# =============================================================================
# Step 3: Generate Executive Summary
# =============================================================================

Write-Host "`n📈 Step 3: Generate Executive Summary" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Total detections
Write-Host "`n📋 Total Detections: $($activities.Count)" -ForegroundColor Cyan

# Unique users
$uniqueUsers = $activities | Select-Object -Property User -Unique
Write-Host "👥 Unique Users: $($uniqueUsers.Count)" -ForegroundColor Cyan

# Blocked shares
$blockedActions = $activities | Where-Object { $_.Action -like "*Block*" -or $_.Action -eq "Blocked" }
Write-Host "🚫 Blocked Actions: $($blockedActions.Count)" -ForegroundColor Cyan

# Top locations
Write-Host "`n📍 Top 5 Locations by Activity:" -ForegroundColor Yellow
$topLocations = $activities | Group-Object Location | 
    Sort-Object Count -Descending | 
    Select-Object -First 5 |
    Select-Object @{Name="Location";Expression={$_.Name}}, @{Name="Activities";Expression={$_.Count}}

if ($topLocations) {
    $topLocations | Format-Table -AutoSize
} else {
    Write-Host "   No location data available" -ForegroundColor Gray
}

# Activity timeline
Write-Host "📅 Activity Timeline (Last 7 Days):" -ForegroundColor Yellow
$timeline = $activities | Where-Object { $_.Date -ne $null } | 
    Group-Object { ([DateTime]$_.Date).Date } | 
    Sort-Object Name -Descending |
    Select-Object @{Name="Date";Expression={$_.Name}}, @{Name="Activities";Expression={$_.Count}}

if ($timeline) {
    $timeline | Format-Table -AutoSize
} else {
    Write-Host "   No date data available" -ForegroundColor Gray
}

# =============================================================================
# Step 4: Summary Report
# =============================================================================

Write-Host "`n✅ Analysis Complete" -ForegroundColor Green
Write-Host "====================" -ForegroundColor Green
Write-Host ""
Write-Host "Executive Summary:" -ForegroundColor Cyan
Write-Host "   Total classifier detections: $($activities.Count)" -ForegroundColor Gray
Write-Host "   Unique users affected: $($uniqueUsers.Count)" -ForegroundColor Gray
Write-Host "   Blocked sharing attempts: $($blockedActions.Count)" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Next Steps:" -ForegroundColor Yellow
Write-Host "   - Review top locations for potential policy adjustments" -ForegroundColor Gray
Write-Host "   - Investigate blocked actions for user training needs" -ForegroundColor Gray
Write-Host "   - Monitor timeline trends for compliance reporting" -ForegroundColor Gray
Write-Host ""

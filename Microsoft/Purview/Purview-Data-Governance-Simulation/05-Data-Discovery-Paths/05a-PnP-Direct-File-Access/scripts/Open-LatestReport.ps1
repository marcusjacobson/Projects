<#
.SYNOPSIS
    Opens the most recent PnP Discovery CSV report.

.DESCRIPTION
    Locates and opens the most recent PnP-Discovery-*.csv report file from the
    reports directory. If multiple reports exist, displays a list and opens the
    newest one automatically.

.EXAMPLE
    .\Open-LatestReport.ps1
    
    Finds and opens the most recent CSV report in default application.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-17
    Last Modified: 2025-11-17
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - PnP Discovery report CSV files in ../reports/ directory
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Helper script to quickly open the most recent PnP Discovery report.
# =============================================================================

[CmdletBinding()]
param()

# =============================================================================
# Step 1: Locate Reports Directory
# =============================================================================

Write-Host "📂 Locating PnP Discovery reports..." -ForegroundColor Cyan

$reportsPath = Join-Path $PSScriptRoot "..\reports"

if (-not (Test-Path $reportsPath)) {
    Write-Host "   ❌ Reports directory not found: $reportsPath" -ForegroundColor Red
    Write-Host "   💡 Run Invoke-PnPDirectFileDiscovery.ps1 first to generate reports" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 2: Find CSV Reports
# =============================================================================

Write-Host "🔍 Searching for CSV reports..." -ForegroundColor Cyan

$csvFiles = Get-ChildItem -Path $reportsPath -Filter "PnP-Discovery-*.csv" -File | Sort-Object LastWriteTime -Descending

if ($csvFiles.Count -eq 0) {
    Write-Host "   ❌ No CSV reports found in: $reportsPath" -ForegroundColor Red
    Write-Host "   💡 Run Invoke-PnPDirectFileDiscovery.ps1 to generate a report" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 3: Display Available Reports
# =============================================================================

Write-Host "   ✅ Found $($csvFiles.Count) report(s)" -ForegroundColor Green
Write-Host ""

if ($csvFiles.Count -gt 1) {
    Write-Host "📊 Available Reports:" -ForegroundColor Cyan
    Write-Host "   (Most recent first)" -ForegroundColor DarkGray
    Write-Host ""
    
    for ($i = 0; $i -lt [Math]::Min($csvFiles.Count, 5); $i++) {
        $file = $csvFiles[$i]
        $fileSize = "{0:N0}" -f ($file.Length / 1KB)
        $timestamp = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        
        if ($i -eq 0) {
            Write-Host "   → $($file.Name)" -ForegroundColor Green
        } else {
            Write-Host "     $($file.Name)" -ForegroundColor DarkGray
        }
        Write-Host "     📅 $timestamp | 📊 $fileSize KB" -ForegroundColor DarkGray
    }
    
    if ($csvFiles.Count -gt 5) {
        Write-Host "     ... and $($csvFiles.Count - 5) older report(s)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# =============================================================================
# Step 4: Open Most Recent Report
# =============================================================================

$latestReport = $csvFiles[0]

Write-Host "📂 Opening most recent report..." -ForegroundColor Cyan
Write-Host "   📄 $($latestReport.Name)" -ForegroundColor Green
Write-Host "   📅 Modified: $($latestReport.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Green
Write-Host "   📊 Size: $("{0:N0}" -f ($latestReport.Length / 1KB)) KB" -ForegroundColor Green
Write-Host ""

try {
    # Get row count (quick preview)
    $rowCount = (Get-Content $latestReport.FullName | Measure-Object -Line).Lines - 1 # Subtract header
    Write-Host "   🎯 Total detections: $("{0:N0}" -f $rowCount)" -ForegroundColor Green
    
    # Open in default CSV application (Excel, CSV editor, etc.)
    Start-Process $latestReport.FullName
    
    Write-Host ""
    Write-Host "✅ Report opened successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 Tips for analyzing the report:" -ForegroundColor Cyan
    Write-Host "   • Create pivot table: Rows=FileName, Columns=SIT_Type, Values=DetectionCount" -ForegroundColor DarkGray
    Write-Host "   • Filter high-risk files: Files with 3+ different SIT types" -ForegroundColor DarkGray
    Write-Host "   • Group by SiteName to see detection distribution" -ForegroundColor DarkGray
    Write-Host "   • Sort by ConfidenceLevel to prioritize review" -ForegroundColor DarkGray
    
} catch {
    Write-Host "   ❌ Failed to open report: $_" -ForegroundColor Red
    Write-Host "   📁 Full path: $($latestReport.FullName)" -ForegroundColor Yellow
    Write-Host "   💡 Try opening manually from File Explorer" -ForegroundColor Yellow
    exit 1
}

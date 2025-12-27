<#
.SYNOPSIS
    Verify required Activity Explorer CSV files exist for cross-platform analysis.

.DESCRIPTION
    This script checks for the presence of both required Activity Explorer CSV exports
    and displays event counts for each file. Used to validate that prerequisite labs 
    have been completed and data has been exported before proceeding with cross-platform 
    analysis.
    
    The script can verify files in:
    - Default location: C:\PurviewLab (for live tenant exports)
    - Custom paths: Specify via -OnPremExportPath and -SharePointExportPath parameters
    - Sample data: Use -UseSampleData switch for immediate testing without live data
    
    The script verifies:
    - On-premises scanner data (ActivityExplorer_Export.csv or custom path)
    - SharePoint DLP data (ActivityExplorer_DLP_Export.csv or custom path)

.PARAMETER OnPremExportPath
    Optional. Full path to the on-premises scanner Activity Explorer export CSV file.
    If not specified, defaults to C:\PurviewLab\ActivityExplorer_Export.csv.

.PARAMETER SharePointExportPath
    Optional. Full path to the SharePoint DLP Activity Explorer export CSV file.
    If not specified, defaults to C:\PurviewLab\ActivityExplorer_DLP_Export.csv.

.PARAMETER UseSampleData
    Switch parameter. When specified, uses the sample data files included with the lab
    for immediate testing without requiring live tenant data exports.

.EXAMPLE
    .\Verify-DataFiles.ps1
    
    Checks for both required CSV files in C:\PurviewLab and displays event counts.

.EXAMPLE
    .\Verify-DataFiles.ps1 -UseSampleData
    
    Uses sample data files from ./sample-data/ directory for testing.

.EXAMPLE
    .\Verify-DataFiles.ps1 -OnPremExportPath "D:\Exports\scanner-data.csv" -SharePointExportPath "D:\Exports\dlp-data.csv"
    
    Checks for files at custom paths.

.NOTES
    Author: Marcus Jacobson
    Version: 1.1.0
    Created: 2025-11-09
    Last Modified: 2025-12-26
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Completed prerequisite labs OR sample data for testing
    - Activity Explorer data exported to specified location
    
    Script development orchestrated using GitHub Copilot.
    
.PREREQUISITE LABS
    - Advanced-Remediation Step 1 (creates ActivityExplorer_Export.csv)
    - Advanced-SharePoint-SIT-Analysis Step 2 (creates ActivityExplorer_DLP_Export.csv)
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$OnPremExportPath,
    
    [Parameter(Mandatory = $false)]
    [string]$SharePointExportPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$UseSampleData
)

# =============================================================================
# Verification script for cross-platform analysis prerequisite data files.
# =============================================================================

Write-Host "🔍 Verifying Activity Explorer Data Files" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Determine file paths based on parameters
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($UseSampleData) {
    Write-Host "📁 Using sample data files for testing" -ForegroundColor Yellow
    Write-Host ""
    $onPremFile = Join-Path $scriptDir "sample-data\Sample_ActivityExplorer_OnPrem_Export.csv"
    $sharePointFile = Join-Path $scriptDir "sample-data\Sample_ActivityExplorer_DLP_Export.csv"
} elseif ($OnPremExportPath -or $SharePointExportPath) {
    # Use provided paths (with defaults for missing ones)
    $onPremFile = if ($OnPremExportPath) { $OnPremExportPath } else { "C:\PurviewLab\ActivityExplorer_Export.csv" }
    $sharePointFile = if ($SharePointExportPath) { $SharePointExportPath } else { "C:\PurviewLab\ActivityExplorer_DLP_Export.csv" }
} else {
    # Default to C:\PurviewLab
    $purviewLabPath = "C:\PurviewLab"
    
    if (-not (Test-Path $purviewLabPath)) {
        Write-Host "❌ ERROR: C:\PurviewLab directory not found" -ForegroundColor Red
        Write-Host "   Please create the directory first: mkdir C:\PurviewLab" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "💡 TIP: Use -UseSampleData to test with sample files:" -ForegroundColor Cyan
        Write-Host "   .\Verify-DataFiles.ps1 -UseSampleData" -ForegroundColor Gray
        exit 1
    }
    
    $onPremFile = Join-Path $purviewLabPath "ActivityExplorer_Export.csv"
    $sharePointFile = Join-Path $purviewLabPath "ActivityExplorer_DLP_Export.csv"
}

$onPremExists = $false
$sharePointExists = $false

# Verify on-premises scanner export
if (Test-Path $onPremFile) {
    try {
        $onPremCount = (Import-Csv $onPremFile).Count
        Write-Host "✅ Found on-premises data: $onPremFile" -ForegroundColor Green
        Write-Host "   Events: $onPremCount" -ForegroundColor Gray
        $onPremExists = $true
    } catch {
        Write-Host "⚠️  Found file but failed to read it: $onPremFile" -ForegroundColor Yellow
        Write-Host "   Error: $_" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ Missing on-premises data: $onPremFile" -ForegroundColor Red
    if (-not $UseSampleData) {
        Write-Host "   Use Export Procedure A in the lab guide, or use -UseSampleData" -ForegroundColor Yellow
    }
}

Write-Host ""

# Verify SharePoint DLP export
if (Test-Path $sharePointFile) {
    try {
        $sharePointCount = (Import-Csv $sharePointFile).Count
        Write-Host "✅ Found SharePoint DLP data: $sharePointFile" -ForegroundColor Green
        Write-Host "   Events: $sharePointCount" -ForegroundColor Gray
        $sharePointExists = $true
    } catch {
        Write-Host "⚠️  Found file but failed to read it: $sharePointFile" -ForegroundColor Yellow
        Write-Host "   Error: $_" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ Missing SharePoint DLP data: $sharePointFile" -ForegroundColor Red
    if (-not $UseSampleData) {
        Write-Host "   Use Export Procedure B in the lab guide, or use -UseSampleData" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan

# Summary and next steps
if ($onPremExists -and $sharePointExists) {
    Write-Host "✅ All required data files present - Ready for cross-platform analysis!" -ForegroundColor Green
    Write-Host ""
    if ($UseSampleData) {
        Write-Host "Next Step: Run .\Generate-CrossPlatform-Report.ps1 -UseSampleData" -ForegroundColor Cyan
    } elseif ($OnPremExportPath -or $SharePointExportPath) {
        Write-Host "Next Step: Run .\Generate-CrossPlatform-Report.ps1 with matching -OnPremExportPath and -SharePointExportPath parameters" -ForegroundColor Cyan
    } else {
        Write-Host "Next Step: Run .\Generate-CrossPlatform-Report.ps1" -ForegroundColor Cyan
    }
    exit 0
} else {
    Write-Host "❌ Missing required data files - Cannot proceed with analysis" -ForegroundColor Red
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Option 1 - Use Sample Data (Immediate Testing):" -ForegroundColor Cyan
    Write-Host "    .\Verify-DataFiles.ps1 -UseSampleData" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Option 2 - Complete Prerequisites (Live Data):" -ForegroundColor Cyan
    if (-not $onPremExists) {
        Write-Host "    - Complete Advanced-Remediation Step 1" -ForegroundColor Gray
        Write-Host "    - Export Activity Explorer on-premises scanner data" -ForegroundColor Gray
        Write-Host "    - Save as: C:\PurviewLab\ActivityExplorer_Export.csv" -ForegroundColor Gray
        Write-Host ""
    }
    if (-not $sharePointExists) {
        Write-Host "    - Complete Advanced-SharePoint-SIT-Analysis Step 2" -ForegroundColor Gray
        Write-Host "    - Export Activity Explorer SharePoint DLP data" -ForegroundColor Gray
        Write-Host "    - Save as: C:\PurviewLab\ActivityExplorer_DLP_Export.csv" -ForegroundColor Gray
    }
    exit 1
}

<#
.SYNOPSIS
    Verify required Activity Explorer CSV files exist for cross-platform analysis.

.DESCRIPTION
    This script checks for the presence of both required Activity Explorer CSV exports
    in C:\PurviewLab and displays event counts for each file. Used to validate that
    prerequisite labs have been completed and data has been exported before proceeding
    with cross-platform analysis.
    
    The script verifies:
    - ActivityExplorer_Export.csv (on-premises scanner data)
    - ActivityExplorer_DLP_Export.csv (SharePoint DLP data)

.EXAMPLE
    .\Verify-DataFiles.ps1
    
    Checks for both required CSV files and displays event counts.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-09
    Last Modified: 2025-11-09
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Completed prerequisite labs (Advanced-Remediation and Advanced-SharePoint-SIT-Analysis)
    - Activity Explorer data exported to C:\PurviewLab
    
    Script development orchestrated using GitHub Copilot.
    
.PREREQUISITE LABS
    - Advanced-Remediation Step 1 (creates ActivityExplorer_Export.csv)
    - Advanced-SharePoint-SIT-Analysis Step 2 (creates ActivityExplorer_DLP_Export.csv)
#>

# =============================================================================
# Verification script for cross-platform analysis prerequisite data files.
# =============================================================================

Write-Host "🔍 Verifying Activity Explorer Data Files" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to C:\PurviewLab
$purviewLabPath = "C:\PurviewLab"

if (-not (Test-Path $purviewLabPath)) {
    Write-Host "❌ ERROR: C:\PurviewLab directory not found" -ForegroundColor Red
    Write-Host "   Please create the directory first: mkdir C:\PurviewLab" -ForegroundColor Yellow
    exit 1
}

Set-Location $purviewLabPath

# Check for required files
$onPremFile = "ActivityExplorer_Export.csv"
$sharePointFile = "ActivityExplorer_DLP_Export.csv"

$onPremExists = $false
$sharePointExists = $false

# Verify on-premises scanner export
if (Test-Path $onPremFile) {
    try {
        $onPremCount = (Import-Csv $onPremFile).Count
        Write-Host "✅ Found $onPremFile ($onPremCount events)" -ForegroundColor Green
        $onPremExists = $true
    } catch {
        Write-Host "⚠️  Found $onPremFile but failed to read it: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Missing $onPremFile" -ForegroundColor Red
    Write-Host "   Use Export Procedure A in the lab guide" -ForegroundColor Yellow
}

Write-Host ""

# Verify SharePoint DLP export
if (Test-Path $sharePointFile) {
    try {
        $sharePointCount = (Import-Csv $sharePointFile).Count
        Write-Host "✅ Found $sharePointFile ($sharePointCount events)" -ForegroundColor Green
        $sharePointExists = $true
    } catch {
        Write-Host "⚠️  Found $sharePointFile but failed to read it: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Missing $sharePointFile" -ForegroundColor Red
    Write-Host "   Use Export Procedure B in the lab guide" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan

# Summary and next steps
if ($onPremExists -and $sharePointExists) {
    Write-Host "✅ All required data files present - Ready for cross-platform analysis!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Step: Run .\Generate-CrossPlatform-Report.ps1" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "❌ Missing required data files - Cannot proceed with analysis" -ForegroundColor Red
    Write-Host ""
    Write-Host "Action Required:" -ForegroundColor Yellow
    if (-not $onPremExists) {
        Write-Host "   1. Complete prerequisite: Advanced-Remediation Step 1" -ForegroundColor Gray
        Write-Host "   2. Export Activity Explorer on-premises scanner data" -ForegroundColor Gray
        Write-Host "   3. Save as: C:\PurviewLab\ActivityExplorer_Export.csv" -ForegroundColor Gray
        Write-Host ""
    }
    if (-not $sharePointExists) {
        Write-Host "   1. Complete prerequisite: Advanced-SharePoint-SIT-Analysis Step 2" -ForegroundColor Gray
        Write-Host "   2. Export Activity Explorer SharePoint DLP data" -ForegroundColor Gray
        Write-Host "   3. Save as: C:\PurviewLab\ActivityExplorer_DLP_Export.csv" -ForegroundColor Gray
    }
    exit 1
}

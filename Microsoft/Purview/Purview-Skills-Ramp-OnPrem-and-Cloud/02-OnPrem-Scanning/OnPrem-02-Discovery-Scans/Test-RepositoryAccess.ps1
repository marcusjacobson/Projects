<#
.SYNOPSIS
    Tests repository accessibility using different UNC path formats.

.DESCRIPTION
    This script tests SMB share accessibility using both localhost and computer name UNC path formats
    to determine which format works correctly on the scanner VM. This helps users configure the
    correct repository paths in the Purview portal.
    
    The script tests both path formats because Windows' 15-character name truncation and network
    configuration can affect which UNC path format is accessible.

.EXAMPLE
    .\Test-RepositoryAccess.ps1
    
    Tests \\localhost\... and \\COMPUTERNAME\... paths for Finance, HR, and Projects shares.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - SMB shares created (Finance, HR, Projects)
    - File and Printer Sharing enabled
    - Network connectivity to localhost and computer name
    
    Script development orchestrated using GitHub Copilot.

.ACCESSIBILITY TESTS
    - Tests \\localhost\Finance, \\localhost\HR, \\localhost\Projects
    - Tests \\COMPUTERNAME\Finance, \\COMPUTERNAME\HR, \\COMPUTERNAME\Projects
    - Displays which path format is accessible
    - Provides guidance for Purview portal configuration
#>

[CmdletBinding()]
param()

# =============================================================================
# Test repository accessibility with different UNC path formats.
# =============================================================================

Write-Host "`n🔍 Testing Repository Access" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

# Get computer name
$computerName = $env:COMPUTERNAME
Write-Host "`n📋 Computer name: $computerName" -ForegroundColor Yellow

# Test localhost paths
Write-Host "`n📋 Testing \\localhost paths:" -ForegroundColor Cyan
$localhostFinance = Test-Path "\\localhost\Finance"
$localhostHR = Test-Path "\\localhost\HR"
$localhostProjects = Test-Path "\\localhost\Projects"

Write-Host "   \\localhost\Finance: " -NoNewline
if ($localhostFinance) {
    Write-Host "✅ Accessible" -ForegroundColor Green
} else {
    Write-Host "❌ Not accessible" -ForegroundColor Red
}

Write-Host "   \\localhost\HR: " -NoNewline
if ($localhostHR) {
    Write-Host "✅ Accessible" -ForegroundColor Green
} else {
    Write-Host "❌ Not accessible" -ForegroundColor Red
}

Write-Host "   \\localhost\Projects: " -NoNewline
if ($localhostProjects) {
    Write-Host "✅ Accessible" -ForegroundColor Green
} else {
    Write-Host "❌ Not accessible" -ForegroundColor Red
}

# Test computer name paths
Write-Host "`n📋 Testing \\$computerName paths:" -ForegroundColor Cyan
$computerFinance = Test-Path "\\$computerName\Finance"
$computerHR = Test-Path "\\$computerName\HR"
$computerProjects = Test-Path "\\$computerName\Projects"

Write-Host "   \\$computerName\Finance: " -NoNewline
if ($computerFinance) {
    Write-Host "✅ Accessible" -ForegroundColor Green
} else {
    Write-Host "❌ Not accessible" -ForegroundColor Red
}

Write-Host "   \\$computerName\HR: " -NoNewline
if ($computerHR) {
    Write-Host "✅ Accessible" -ForegroundColor Green
} else {
    Write-Host "❌ Not accessible" -ForegroundColor Red
}

Write-Host "   \\$computerName\Projects: " -NoNewline
if ($computerProjects) {
    Write-Host "✅ Accessible" -ForegroundColor Green
} else {
    Write-Host "❌ Not accessible" -ForegroundColor Red
}

# Provide guidance based on results
Write-Host "`n📊 Test Results Summary:" -ForegroundColor Cyan

$localhostCount = @($localhostFinance, $localhostHR, $localhostProjects) | Where-Object {$_ -eq $true} | Measure-Object | Select-Object -ExpandProperty Count
$computerCount = @($computerFinance, $computerHR, $computerProjects) | Where-Object {$_ -eq $true} | Measure-Object | Select-Object -ExpandProperty Count

Write-Host "   Localhost paths accessible: $localhostCount of 3" -ForegroundColor Gray
Write-Host "   Computer name paths accessible: $computerCount of 3" -ForegroundColor Gray

if ($localhostCount -eq 3) {
    Write-Host "`n✅ Recommendation: Use \\localhost\ format in Purview portal" -ForegroundColor Green
    Write-Host "   Repository paths:" -ForegroundColor Gray
    Write-Host "   - \\localhost\Finance" -ForegroundColor Gray
    Write-Host "   - \\localhost\HR" -ForegroundColor Gray
    Write-Host "   - \\localhost\Projects" -ForegroundColor Gray
} elseif ($computerCount -eq 3) {
    Write-Host "`n✅ Recommendation: Use \\$computerName\ format in Purview portal" -ForegroundColor Green
    Write-Host "   Repository paths:" -ForegroundColor Gray
    Write-Host "   - \\$computerName\Finance" -ForegroundColor Gray
    Write-Host "   - \\$computerName\HR" -ForegroundColor Gray
    Write-Host "   - \\$computerName\Projects" -ForegroundColor Gray
} else {
    Write-Host "`n⚠️  Not all paths are accessible" -ForegroundColor Yellow
    Write-Host "   Troubleshooting steps:" -ForegroundColor Gray
    Write-Host "   1. Verify File and Printer Sharing is enabled" -ForegroundColor Gray
    Write-Host "   2. Check Windows Firewall allows File Sharing" -ForegroundColor Gray
    Write-Host "   3. Confirm SMB shares were created successfully" -ForegroundColor Gray
    Write-Host "   4. Run Enable-FileSharingFirewall.ps1 script" -ForegroundColor Gray
}

Write-Host "`n⏭️  If paths are not accessible, run Enable-FileSharingFirewall.ps1" -ForegroundColor Yellow
Write-Host "⏭️  If all paths accessible, continue with Grant-ScannerNTFSPermissions.ps1" -ForegroundColor Yellow

<#
.SYNOPSIS
    Diagnoses repository path and permission issues when repositories are skipped during scans.

.DESCRIPTION
    This comprehensive diagnostic script tests repository accessibility using different UNC path formats,
    verifies NTFS and SMB permissions, and provides specific recommendations for fixing SkippedRepositories
    issues. It identifies whether the problem is UNC path format, permissions, or authentication tokens.

.EXAMPLE
    .\Test-RepositoryPathDiagnostics.ps1
    
    Runs comprehensive diagnostics on all repository paths and permissions.

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
    - Repository folders exist with sample data
    - Scanner service account created
    
    Script development orchestrated using GitHub Copilot.

.DIAGNOSTIC CHECKS
    - Tests \\localhost\ and \\COMPUTERNAME\ UNC path formats
    - Verifies NTFS permissions on repository folders
    - Checks SMB share permissions
    - Provides fix recommendations based on test results
#>

[CmdletBinding()]
param()

# =============================================================================
# Diagnostic: Test repository UNC paths and permissions.
# =============================================================================

Write-Host "`n🔍 SOLUTION 1: Test and Fix Repository UNC Paths" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Step 1: Get computer name
Write-Host "`n📋 Step 1: Getting actual computer name..." -ForegroundColor Cyan
$computerName = $env:COMPUTERNAME
Write-Host "   Computer name: $computerName" -ForegroundColor Yellow
Write-Host ""

# Step 2: Test different UNC path formats
Write-Host "📋 Step 2: Testing repository access with different path formats..." -ForegroundColor Cyan

# Test localhost paths
Write-Host "`n   Testing \\localhost paths:" -ForegroundColor Cyan
$localhostFinance = Test-Path "\\localhost\Finance"
$localhostHR = Test-Path "\\localhost\HR"
$localhostProjects = Test-Path "\\localhost\Projects"

Write-Host "   \\localhost\Finance: " -NoNewline
if ($localhostFinance) { Write-Host "✅ True" -ForegroundColor Green } else { Write-Host "❌ False" -ForegroundColor Red }
Write-Host "   \\localhost\HR: " -NoNewline
if ($localhostHR) { Write-Host "✅ True" -ForegroundColor Green } else { Write-Host "❌ False" -ForegroundColor Red }
Write-Host "   \\localhost\Projects: " -NoNewline
if ($localhostProjects) { Write-Host "✅ True" -ForegroundColor Green } else { Write-Host "❌ False" -ForegroundColor Red }

# Test computer name paths
Write-Host "`n   Testing \\$computerName paths:" -ForegroundColor Cyan
$computerFinance = Test-Path "\\$computerName\Finance"
$computerHR = Test-Path "\\$computerName\HR"
$computerProjects = Test-Path "\\$computerName\Projects"

Write-Host "   \\$computerName\Finance: " -NoNewline
if ($computerFinance) { Write-Host "✅ True" -ForegroundColor Green } else { Write-Host "❌ False" -ForegroundColor Red }
Write-Host "   \\$computerName\HR: " -NoNewline
if ($computerHR) { Write-Host "✅ True" -ForegroundColor Green } else { Write-Host "❌ False" -ForegroundColor Red }
Write-Host "   \\$computerName\Projects: " -NoNewline
if ($computerProjects) { Write-Host "✅ True" -ForegroundColor Green } else { Write-Host "❌ False" -ForegroundColor Red }

# Step 3: Verify permissions
Write-Host "`n📋 Step 3: Verifying NTFS permissions..." -ForegroundColor Cyan
Write-Host "`n   Finance folder:" -ForegroundColor Gray
icacls "C:\PurviewScanner\Finance" | findstr scanner-svc

Write-Host "`n   HR folder:" -ForegroundColor Gray
icacls "C:\PurviewScanner\HR" | findstr scanner-svc

Write-Host "`n   Projects folder:" -ForegroundColor Gray
icacls "C:\PurviewScanner\Projects" | findstr scanner-svc

Write-Host "`n📋 Verifying SMB share permissions..." -ForegroundColor Cyan
try {
    Write-Host "`n   Finance share:" -ForegroundColor Gray
    Get-SmbShareAccess -Name "Finance" | Format-Table -AutoSize
    
    Write-Host "   HR share:" -ForegroundColor Gray
    Get-SmbShareAccess -Name "HR" | Format-Table -AutoSize
    
    Write-Host "   Projects share:" -ForegroundColor Gray
    Get-SmbShareAccess -Name "Projects" | Format-Table -AutoSize
} catch {
    Write-Host "   ⚠️  Could not verify SMB permissions: $_" -ForegroundColor Yellow
}

# Analyze results and provide recommendations
Write-Host "`n📊 Diagnostic Results:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

$localhostCount = @($localhostFinance, $localhostHR, $localhostProjects) | Where-Object {$_ -eq $true} | Measure-Object | Select-Object -ExpandProperty Count
$computerCount = @($computerFinance, $computerHR, $computerProjects) | Where-Object {$_ -eq $true} | Measure-Object | Select-Object -ExpandProperty Count

Write-Host "`n✅ Expected Results:" -ForegroundColor Green
Write-Host "   Test-Path should return True for at least ONE path format" -ForegroundColor Gray
Write-Host "   NTFS permissions should show scanner-svc:(OI)(CI)(R)" -ForegroundColor Gray
Write-Host "   SMB permissions should show scanner-svc with Full or Read access" -ForegroundColor Gray

Write-Host "`n📈 Your Results:" -ForegroundColor Cyan
Write-Host "   Localhost paths accessible: $localhostCount of 3" -ForegroundColor Gray
Write-Host "   Computer name paths accessible: $computerCount of 3" -ForegroundColor Gray

if ($localhostCount -eq 3) {
    Write-Host "`n✅ RECOMMENDATION: Use \\localhost\ format in Purview portal" -ForegroundColor Green
    Write-Host "`n   Update repository paths in Purview portal to:" -ForegroundColor Yellow
    Write-Host "   - \\localhost\Finance" -ForegroundColor Gray
    Write-Host "   - \\localhost\HR" -ForegroundColor Gray
    Write-Host "   - \\localhost\Projects" -ForegroundColor Gray
    Write-Host "`n⏭️  Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Update paths in Purview portal" -ForegroundColor Gray
    Write-Host "   2. Save the content scan job (General tab)" -ForegroundColor Gray
    Write-Host "   3. Run Update-RepositoryPathsPostFix.ps1" -ForegroundColor Gray
} elseif ($computerCount -eq 3) {
    Write-Host "`n✅ RECOMMENDATION: Use \\$computerName\ format in Purview portal" -ForegroundColor Green
    Write-Host "`n   Update repository paths in Purview portal to:" -ForegroundColor Yellow
    Write-Host "   - \\$computerName\Finance" -ForegroundColor Gray
    Write-Host "   - \\$computerName\HR" -ForegroundColor Gray
    Write-Host "   - \\$computerName\Projects" -ForegroundColor Gray
    Write-Host "`n⏭️  Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Update paths in Purview portal" -ForegroundColor Gray
    Write-Host "   2. Save the content scan job (General tab)" -ForegroundColor Gray
    Write-Host "   3. Run Update-RepositoryPathsPostFix.ps1" -ForegroundColor Gray
} else {
    Write-Host "`n⚠️  WARNING: Repositories are not accessible" -ForegroundColor Yellow
    Write-Host "`n   Troubleshooting required:" -ForegroundColor Yellow
    Write-Host "   1. Verify SMB shares created: Get-SmbShare" -ForegroundColor Gray
    Write-Host "   2. Check File and Printer Sharing enabled" -ForegroundColor Gray
    Write-Host "   3. Run Enable-FileSharingFirewall.ps1" -ForegroundColor Gray
    Write-Host "   4. Verify sample data files exist in C:\PurviewScanner folders" -ForegroundColor Gray
}

Write-Host "`n✅ Diagnostics Complete" -ForegroundColor Green

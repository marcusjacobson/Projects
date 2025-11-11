<#
.SYNOPSIS
    Grants NTFS Read permissions to scanner service account on repository folders.

.DESCRIPTION
    This script grants the scanner service account (COMPUTERNAME\scanner-svc) NTFS Read permissions
    on all repository folders (Finance, HR, Projects). The scanner requires both SMB share permissions
    AND NTFS file system permissions to access files during scans.
    
    The script uses icacls to apply inheritance flags ensuring permissions apply to all subfolders
    and files within each repository.

.PARAMETER ComputerName
    The computer name for the scanner service account. If not provided, uses $env:COMPUTERNAME.

.EXAMPLE
    .\Grant-ScannerNTFSPermissions.ps1
    
    Grants Read permissions to scanner-svc account on all repository folders.

.EXAMPLE
    .\Grant-ScannerNTFSPermissions.ps1 -ComputerName "VM-PURVIEW-SCAN"
    
    Grants permissions using explicit computer name.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Local administrator permissions
    - Scanner service account created (COMPUTERNAME\scanner-svc)
    - Repository folders exist: C:\PurviewScanner\Finance, HR, Projects
    
    Script development orchestrated using GitHub Copilot.

.PERMISSION DETAILS
    - Account: COMPUTERNAME\scanner-svc
    - Permission: Read (R)
    - Inheritance: (OI)(CI) - Object and Container Inherit
    - Scope: Applies recursively to all subfolders and files (/T)
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ComputerName = $env:COMPUTERNAME
)

# =============================================================================
# Grant NTFS Read permissions to scanner service account.
# =============================================================================

Write-Host "`n🔐 Part 3: Grant NTFS Permissions to Scanner Account" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

Write-Host "`n📋 Granting Read permissions to $ComputerName\scanner-svc..." -ForegroundColor Cyan

# Grant permissions to Finance folder
Write-Host "`n   Processing Finance folder..." -ForegroundColor Gray
try {
    $output = icacls "C:\PurviewScanner\Finance" /grant "$ComputerName\scanner-svc:(OI)(CI)R" /T 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Finance permissions applied" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Finance permissions may have issues" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Failed to apply Finance permissions" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
}

# Grant permissions to HR folder
Write-Host "   Processing HR folder..." -ForegroundColor Gray
try {
    $output = icacls "C:\PurviewScanner\HR" /grant "$ComputerName\scanner-svc:(OI)(CI)R" /T 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ HR permissions applied" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  HR permissions may have issues" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Failed to apply HR permissions" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
}

# Grant permissions to Projects folder
Write-Host "   Processing Projects folder..." -ForegroundColor Gray
try {
    $output = icacls "C:\PurviewScanner\Projects" /grant "$ComputerName\scanner-svc:(OI)(CI)R" /T 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Projects permissions applied" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Projects permissions may have issues" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Failed to apply Projects permissions" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
}

# Verify permissions were applied
Write-Host "`n📋 Verifying permissions..." -ForegroundColor Cyan

Write-Host "`n   Finance folder:" -ForegroundColor Gray
icacls "C:\PurviewScanner\Finance" | findstr scanner-svc

Write-Host "`n   HR folder:" -ForegroundColor Gray
icacls "C:\PurviewScanner\HR" | findstr scanner-svc

Write-Host "`n   Projects folder:" -ForegroundColor Gray
icacls "C:\PurviewScanner\Projects" | findstr scanner-svc

Write-Host "`n✅ NTFS Permissions Configuration Complete" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

Write-Host "`n📚 Permission Notation Explained:" -ForegroundColor Cyan
Write-Host "   (OI) = Object Inherit - applies to files" -ForegroundColor Gray
Write-Host "   (CI) = Container Inherit - applies to subfolders" -ForegroundColor Gray
Write-Host "   R = Read permission" -ForegroundColor Gray
Write-Host "   /T = Apply recursively to existing content" -ForegroundColor Gray

Write-Host "`n💡 Dual Permission Model:" -ForegroundColor Cyan
Write-Host "   ✅ SMB Share Permissions = Network access (Everyone Full Access)" -ForegroundColor Gray
Write-Host "   ✅ NTFS Permissions = File system access (scanner-svc Read)" -ForegroundColor Gray
Write-Host "   🔒 Most restrictive permission wins (Read only in this case)" -ForegroundColor Gray

Write-Host "`n⏭️  Continue with Part 4: Start Scan to Pull Content Scan Job Configuration" -ForegroundColor Yellow

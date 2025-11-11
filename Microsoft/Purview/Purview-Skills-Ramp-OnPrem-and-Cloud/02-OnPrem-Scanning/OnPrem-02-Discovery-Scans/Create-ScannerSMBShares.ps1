<#
.SYNOPSIS
    Creates SMB file shares for Purview scanner repositories.

.DESCRIPTION
    This script creates SMB file shares (Finance, HR, Projects) that the Purview Information Protection
    scanner will access during discovery scans. It configures shares with Everyone Full Access for
    lab purposes and verifies share creation successfully.
    
    The script displays the actual computer name to help users configure correct UNC paths in the
    Purview portal, accounting for Windows' 15-character name truncation.

.EXAMPLE
    .\Create-ScannerSMBShares.ps1
    
    Creates Finance, HR, and Projects SMB shares with Full Access for Everyone.

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
    - File and Printer Sharing enabled
    - Repository folders exist: C:\PurviewScanner\Finance, HR, Projects
    
    Script development orchestrated using GitHub Copilot.

.SHARE CONFIGURATION
    - Share Name: Finance, HR, Projects
    - Local Path: C:\PurviewScanner\[ShareName]
    - Permissions: Everyone - Full Access (LAB ONLY)
    - Purpose: Provide network access to scanner repositories
#>

[CmdletBinding()]
param()

# =============================================================================
# Create SMB file shares for scanner repositories.
# =============================================================================

Write-Host "`n📂 Part 2: Create SMB File Shares" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Get and display actual computer name
$computerName = $env:COMPUTERNAME
Write-Host "`n📋 Computer Information:" -ForegroundColor Cyan
Write-Host "   Computer name: $computerName" -ForegroundColor Yellow
Write-Host "   Use this name in Purview portal UNC paths:" -ForegroundColor Gray
Write-Host "   \\$computerName\Finance" -ForegroundColor Gray
Write-Host "   \\$computerName\HR" -ForegroundColor Gray
Write-Host "   \\$computerName\Projects" -ForegroundColor Gray

# Create SMB shares
Write-Host "`n📋 Creating SMB shares..." -ForegroundColor Cyan

try {
    # Create Finance share
    New-SmbShare -Name "Finance" `
        -Path "C:\PurviewScanner\Finance" `
        -FullAccess "Everyone" `
        -ErrorAction Stop
    Write-Host "   ✅ Created Finance share" -ForegroundColor Green
    
    # Create HR share
    New-SmbShare -Name "HR" `
        -Path "C:\PurviewScanner\HR" `
        -FullAccess "Everyone" `
        -ErrorAction Stop
    Write-Host "   ✅ Created HR share" -ForegroundColor Green
    
    # Create Projects share
    New-SmbShare -Name "Projects" `
        -Path "C:\PurviewScanner\Projects" `
        -FullAccess "Everyone" `
        -ErrorAction Stop
    Write-Host "   ✅ Created Projects share" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Failed to create SMB shares" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    Write-Host "`n   Common causes:" -ForegroundColor Yellow
    Write-Host "   1. Share already exists (remove with: Remove-SmbShare -Name 'Finance' -Force)" -ForegroundColor Gray
    Write-Host "   2. Local path does not exist (verify: C:\PurviewScanner\Finance)" -ForegroundColor Gray
    Write-Host "   3. File and Printer Sharing not enabled" -ForegroundColor Gray
    exit 1
}

# Verify shares were created
Write-Host "`n📋 Verifying SMB shares..." -ForegroundColor Cyan
try {
    $shares = Get-SmbShare | Where-Object {$_.Name -in @("Finance", "HR", "Projects")}
    
    if ($shares.Count -eq 3) {
        Write-Host "   ✅ All 3 shares created successfully" -ForegroundColor Green
        Write-Host "`n   Share Details:" -ForegroundColor Cyan
        $shares | Format-Table Name, Path, Description -AutoSize
    } else {
        Write-Host "   ⚠️  Only $($shares.Count) of 3 shares found" -ForegroundColor Yellow
        $shares | Format-Table Name, Path -AutoSize
    }
    
} catch {
    Write-Host "   ❌ Failed to verify SMB shares" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
}

Write-Host "`n✅ SMB Share Creation Complete" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
Write-Host "`n⚠️  SECURITY NOTE:" -ForegroundColor Yellow
Write-Host "   Everyone Full Access is configured for LAB purposes only." -ForegroundColor Gray
Write-Host "   Production environments should use proper security groups." -ForegroundColor Gray
Write-Host "`n⏭️  Continue with: Verify SMB Shares Are Accessible" -ForegroundColor Yellow

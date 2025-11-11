<#
.SYNOPSIS
    Creates SMB file shares for Finance, HR, and Projects folders.

.DESCRIPTION
    This script creates three SMB network shares pointing to the C:\PurviewScanner
    subfolders. These shares enable the Purview scanner to access file share content
    remotely using UNC paths (\\COMPUTERNAME\ShareName).
    
    Shares created:
    - Finance: \\localhost\Finance
    - HR: \\localhost\HR
    - Projects: \\localhost\Projects
    
    Each share is configured with Full Access for "Everyone" (LAB ONLY).

.EXAMPLE
    .\Create-SMBShares.ps1
    
    Creates all three SMB shares and displays their configuration.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1+ (Administrator)
    - C:\PurviewScanner directory with Finance, HR, Projects subfolders
    - SMB Server feature enabled (default on Windows Server)
    
    Security Warning:
    - Uses "Everyone" Full Access for lab simplicity
    - Production environments require proper NTFS and share permissions
    - Never use Everyone/Full Access in production file shares
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Create SMB file shares for scanner to access via UNC paths
# =============================================================================

# =============================================================================
# Step 1: Create Finance Share
# =============================================================================

Write-Host "📋 Step 1: Creating Finance Share" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

try {
    New-SmbShare -Name "Finance" `
        -Path "C:\PurviewScanner\Finance" `
        -FullAccess "Everyone" `
        -Description "Finance department files - LAB ONLY" `
        -ErrorAction Stop
    Write-Host "   ✅ Finance share created successfully" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Finance share may already exist or creation failed: $_" -ForegroundColor Yellow
}

# =============================================================================
# Step 2: Create HR Share
# =============================================================================

Write-Host "`n📋 Step 2: Creating HR Share" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

try {
    New-SmbShare -Name "HR" `
        -Path "C:\PurviewScanner\HR" `
        -FullAccess "Everyone" `
        -Description "HR department files - LAB ONLY" `
        -ErrorAction Stop
    Write-Host "   ✅ HR share created successfully" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  HR share may already exist or creation failed: $_" -ForegroundColor Yellow
}

# =============================================================================
# Step 3: Create Projects Share
# =============================================================================

Write-Host "`n📋 Step 3: Creating Projects Share" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

try {
    New-SmbShare -Name "Projects" `
        -Path "C:\PurviewScanner\Projects" `
        -FullAccess "Everyone" `
        -Description "Project archive files - LAB ONLY" `
        -ErrorAction Stop
    Write-Host "   ✅ Projects share created successfully" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Projects share may already exist or creation failed: $_" -ForegroundColor Yellow
}

# =============================================================================
# Step 4: Display Created Shares
# =============================================================================

Write-Host "`n✅ SMB shares created successfully" -ForegroundColor Green

Write-Host "`n📊 Created Shares:" -ForegroundColor Cyan
Get-SmbShare | Where-Object {$_.Name -in @("Finance", "HR", "Projects")} | 
    Format-Table Name, Path, Description -AutoSize

Write-Host "`n🔒 Security Note: Using 'Everyone' with Full Access is for LAB ONLY." -ForegroundColor Yellow
Write-Host "   Production environments require proper NTFS and share permissions." -ForegroundColor Yellow

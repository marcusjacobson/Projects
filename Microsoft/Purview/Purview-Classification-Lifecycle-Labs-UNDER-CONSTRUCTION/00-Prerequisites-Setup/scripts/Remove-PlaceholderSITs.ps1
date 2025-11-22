<#
.SYNOPSIS
    Removes placeholder custom Sensitive Information Types created in Lab 0.

.DESCRIPTION
    This cleanup script removes the 3 placeholder custom SITs created in Exercise 3:
    - Contoso Employee ID
    - Contoso Customer Number
    - Contoso Project Code
    
    Use this script when:
    - Encountering "duplicate name" errors during SIT creation
    - Resetting Lab 0 Exercise 3 for fresh start
    - Cleaning up test environment after lab completion
    
    The script prompts for confirmation before deletion and provides detailed
    feedback about each removal operation.

.PARAMETER Force
    Skip confirmation prompt and proceed with deletion immediately.

.PARAMETER Verbose
    Show detailed progress during execution.

.EXAMPLE
    .\Remove-PlaceholderSITs.ps1
    
    Prompts for confirmation, then removes all 3 placeholder custom SITs.

.EXAMPLE
    .\Remove-PlaceholderSITs.ps1 -Force -Verbose
    
    Removes all placeholder SITs without confirmation and shows detailed progress.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-13
    Last Modified: 2025-11-13
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - ExchangeOnlineManagement module v3.0+ installed
    - Security & Compliance PowerShell access
    - Compliance Administrator or Global Administrator role
    - Microsoft 365 E5 or E5 Compliance license
    
    Script development orchestrated using GitHub Copilot.

.WARNING
    This script permanently removes custom SITs. If any retention policies or
    DLP policies reference these SITs, those policies will need to be updated
    or will no longer function correctly.
#>

# =============================================================================
# Placeholder Custom SIT Removal for Purview Classification Labs
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

Write-Host "🗑️  Placeholder Custom SIT Removal" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Security & Compliance PowerShell Authentication
# =============================================================================

Write-Host "📋 Step 1: Security & Compliance Authentication" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

try {
    Write-Host "🔐 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
    Write-Host "   (Browser window will open for authentication)" -ForegroundColor Yellow
    
    # Connect to Security & Compliance PowerShell
    Connect-IPPSSession
    
    Write-Host "✅ Connected to Security & Compliance successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Security & Compliance authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Verify you have Compliance Administrator or Global Administrator role" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 2: Identify Placeholder Custom SITs
# =============================================================================

Write-Host "`n📋 Step 2: Identifying Placeholder Custom SITs" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

$targetSITs = @(
    "Contoso Employee ID",
    "Contoso Customer Number",
    "Contoso Project Code"
)

$foundSITs = @()

Write-Host "🔍 Searching for placeholder custom SITs..." -ForegroundColor Cyan

foreach ($sitName in $targetSITs) {
    try {
        $sit = Get-DlpSensitiveInformationType -Identity $sitName -ErrorAction SilentlyContinue
        
        if ($sit) {
            $foundSITs += $sit
            Write-Host "   ✅ Found: $sitName" -ForegroundColor Green
        } else {
            Write-Host "   ℹ️  Not found: $sitName (may not exist)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "   ℹ️  Not found: $sitName" -ForegroundColor Gray
    }
}

if ($foundSITs.Count -eq 0) {
    Write-Host "`n⚠️  No placeholder custom SITs found to remove" -ForegroundColor Yellow
    Write-Host "   All SITs may have already been removed or never created" -ForegroundColor Cyan
    
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    exit 0
}

Write-Host "`n✅ Found $($foundSITs.Count) placeholder custom SIT(s) to remove" -ForegroundColor Green

# =============================================================================
# Step 3: Confirmation and Removal
# =============================================================================

Write-Host "`n📋 Step 3: Confirmation and Removal" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

if (-not $Force) {
    Write-Host "`n⚠️  Warning: This will permanently remove the following custom SITs:" -ForegroundColor Yellow
    foreach ($sit in $foundSITs) {
        Write-Host "   • $($sit.Name)" -ForegroundColor White
    }
    Write-Host ""
    
    $confirmation = Read-Host "Do you want to proceed with removal? (Y/N)"
    
    if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
        Write-Host "`n❌ Operation cancelled by user" -ForegroundColor Red
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        exit 0
    }
}

Write-Host "`n🗑️  Removing placeholder custom SITs..." -ForegroundColor Cyan

$removedCount = 0
$failedCount = 0

foreach ($sit in $foundSITs) {
    try {
        Write-Host "   🔸 Removing: $($sit.Name)..." -ForegroundColor Cyan
        
        Remove-DlpSensitiveInformationType -Identity $sit.Name -Confirm:$false -ErrorAction Stop
        
        Write-Host "   ✅ Successfully removed: $($sit.Name)" -ForegroundColor Green
        $removedCount++
    } catch {
        Write-Host "   ❌ Failed to remove '$($sit.Name)': $($_.Exception.Message)" -ForegroundColor Red
        $failedCount++
        
        # Check if SIT is referenced in policies
        if ($_.Exception.Message -like "*in use*" -or $_.Exception.Message -like "*referenced*") {
            Write-Host "      💡 Tip: This SIT may be referenced in retention policies or DLP policies" -ForegroundColor Yellow
            Write-Host "      Remove policy references first, then retry deletion" -ForegroundColor Yellow
        }
    }
}

# =============================================================================
# Step 4: Summary
# =============================================================================

Write-Host "`n📋 Step 4: Summary" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green

Write-Host "`n📊 Removal Summary:" -ForegroundColor Cyan
Write-Host "   Total SITs found: $($foundSITs.Count)" -ForegroundColor White
Write-Host "   Successfully removed: $removedCount" -ForegroundColor Green
Write-Host "   Failed to remove: $failedCount" -ForegroundColor Red

# Verify removal
Write-Host "`n🔍 Verifying removal..." -ForegroundColor Cyan

$remainingSITs = @()
foreach ($sitName in $targetSITs) {
    try {
        $sit = Get-DlpSensitiveInformationType -Identity $sitName -ErrorAction SilentlyContinue
        if ($sit) {
            $remainingSITs += $sitName
        }
    } catch {
        # SIT not found - this is expected after successful removal
    }
}

if ($remainingSITs.Count -eq 0) {
    Write-Host "✅ All placeholder custom SITs have been successfully removed" -ForegroundColor Green
} else {
    Write-Host "⚠️  The following SITs still exist:" -ForegroundColor Yellow
    foreach ($sitName in $remainingSITs) {
        Write-Host "   • $sitName" -ForegroundColor White
    }
    Write-Host "`n💡 These SITs may be referenced in retention policies or DLP policies" -ForegroundColor Cyan
    Write-Host "   Remove policy references, then re-run this script" -ForegroundColor Cyan
}

# Disconnect from Security & Compliance
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "`n🎉 Placeholder Custom SIT Removal Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

if ($removedCount -gt 0) {
    Write-Host "✅ You can now re-run Exercise 3 to create fresh placeholder SITs" -ForegroundColor Green
    Write-Host "   cd C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\00-Prerequisites-Setup\scripts" -ForegroundColor Cyan
    Write-Host "   .\Create-PlaceholderSITs.ps1 -Verbose" -ForegroundColor Cyan
}

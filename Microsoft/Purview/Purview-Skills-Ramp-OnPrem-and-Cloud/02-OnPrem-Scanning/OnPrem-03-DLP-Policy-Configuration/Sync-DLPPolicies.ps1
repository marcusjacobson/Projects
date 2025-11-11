<#
.SYNOPSIS
    Synchronizes DLP policies from Purview portal to the on-premises scanner.

.DESCRIPTION
    This script downloads Data Loss Prevention (DLP) policies from the Microsoft Purview compliance
    portal to the local scanner. It executes Update-AIPScanner to retrieve the latest policy configurations,
    then restarts the scanner service to apply them. This sync step is required after creating or modifying
    DLP policies in the portal before the scanner can evaluate files against them.

.EXAMPLE
    .\Sync-DLPPolicies.ps1
    
    Downloads DLP policies from portal and restarts scanner service.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Information Protection Scanner installed and configured
    - DLP policies created in Purview portal (Standard Path) OR existing DLP policies (Alternative Path)
    - EnableDLP=On configured (run Enable-ScannerDLP.ps1 first)
    - Internet connectivity to Microsoft 365 services
    
    Script development orchestrated using GitHub Copilot.

.POLICY SYNC
    - Update-AIPScanner: Downloads policies from Purview portal
    - Service Restart: Applies downloaded policies to scanner
    - Sync Time: May take 1-2 hours for new policies to become available
    - Verification: Check Purview portal for policy sync status
#>

[CmdletBinding()]
param()

# =============================================================================
# Configuration: Sync DLP Policies from Portal
# =============================================================================

Write-Host "`n🔄 Synchronizing DLP Policies from Purview Portal" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Step 1: Verify DLP is enabled
Write-Host "`n📋 Step 1: Verifying DLP configuration..." -ForegroundColor Cyan

try {
    $scannerConfig = Get-ScannerContentScan -ErrorAction Stop
    
    if ($scannerConfig.EnableDlp -ne 'On') {
        Write-Host "   ❌ DLP is not enabled (current: $($scannerConfig.EnableDlp))" -ForegroundColor Red
        Write-Host "`n⚠️  Prerequisite Missing:" -ForegroundColor Yellow
        Write-Host "   Run Enable-ScannerDLP.ps1 first to enable DLP" -ForegroundColor Gray
        exit 1
    }
    
    Write-Host "   ✅ DLP is enabled" -ForegroundColor Green
    Write-Host "   RepositoryOwner: $($scannerConfig.RepositoryOwner)" -ForegroundColor Gray
    
} catch {
    Write-Host "   ❌ Failed to check DLP configuration: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Check scanner service status
Write-Host "`n📋 Step 2: Checking scanner service status..." -ForegroundColor Cyan

try {
    $service = Get-Service -Name "MIPScanner" -ErrorAction Stop
    
    Write-Host "   Service Status: $($service.Status)" -ForegroundColor Gray
    
    if ($service.Status -ne 'Running') {
        Write-Host "   ⚠️  Scanner service is not running" -ForegroundColor Yellow
        Write-Host "   Starting service..." -ForegroundColor Gray
        
        Start-Service -Name "MIPScanner" -ErrorAction Stop
        Start-Sleep -Seconds 5
        
        $service = Get-Service -Name "MIPScanner" -ErrorAction Stop
        if ($service.Status -eq 'Running') {
            Write-Host "   ✅ Scanner service started" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Failed to start scanner service" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "   ✅ Scanner service is running" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Scanner service check failed: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Download policies from portal
Write-Host "`n📋 Step 3: Downloading DLP policies from Purview portal..." -ForegroundColor Cyan
Write-Host "   This may take 1-2 minutes..." -ForegroundColor Gray

try {
    Update-AIPScanner -ErrorAction Stop
    Write-Host "   ✅ Policy sync completed successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Policy sync failed: $_" -ForegroundColor Red
    Write-Host "`n⚠️  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Verify internet connectivity" -ForegroundColor Gray
    Write-Host "   - Check scanner service account has policy read permissions" -ForegroundColor Gray
    Write-Host "   - Ensure DLP policies exist in Purview portal" -ForegroundColor Gray
    Write-Host "   - Wait 1-2 hours after policy creation for sync availability" -ForegroundColor Gray
    exit 1
}

# Step 4: Restart scanner service
Write-Host "`n📋 Step 4: Restarting scanner service to apply policies..." -ForegroundColor Cyan

try {
    Restart-Service -Name "MIPScanner" -Force -ErrorAction Stop
    Write-Host "   ✅ Service restart initiated" -ForegroundColor Green
    
    Write-Host "   Waiting for service to start..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
    
    $service = Get-Service -Name "MIPScanner" -ErrorAction Stop
    if ($service.Status -eq 'Running') {
        Write-Host "   ✅ Scanner service is running with updated policies" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Service status: $($service.Status)" -ForegroundColor Yellow
        Write-Host "   Service may take additional time to start" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "   ❌ Service restart failed: $_" -ForegroundColor Red
    Write-Host "`n⚠️  Manual restart required:" -ForegroundColor Yellow
    Write-Host "   Run: Restart-Service -Name MIPScanner -Force" -ForegroundColor Gray
    exit 1
}

# Step 5: Verify policy sync status
Write-Host "`n📋 Step 5: Verifying policy sync status..." -ForegroundColor Cyan

Write-Host "`n   📊 Policy Sync Verification:" -ForegroundColor Yellow
Write-Host "   =============================" -ForegroundColor Yellow
Write-Host ""
Write-Host "   To verify policies synced successfully:" -ForegroundColor Gray
Write-Host ""
Write-Host "   1. Open Microsoft Purview compliance portal:" -ForegroundColor Gray
Write-Host "      https://purview.microsoft.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "   2. Navigate to:" -ForegroundColor Gray
Write-Host "      Solutions > Data loss prevention > Policies" -ForegroundColor Cyan
Write-Host ""
Write-Host "   3. Find policy: 'Lab-OnPrem-Sensitive-Data-Protection'" -ForegroundColor Gray
Write-Host ""
Write-Host "   4. Check columns:" -ForegroundColor Gray
Write-Host "      • Status: Should be 'On' or 'Test mode'" -ForegroundColor Gray
Write-Host "      • Synced to devices: Should show scanner computer name" -ForegroundColor Gray
Write-Host ""
Write-Host "   ⚠️  If policy shows 'Pending' or missing computer:" -ForegroundColor Yellow
Write-Host "      • Wait 1-2 hours for initial policy sync" -ForegroundColor Gray
Write-Host "      • New policies take time to propagate" -ForegroundColor Gray
Write-Host "      • Re-run this script after waiting" -ForegroundColor Gray

Write-Host "`n💡 Policy Sync Notes:" -ForegroundColor Cyan
Write-Host "   • Update-AIPScanner downloads policies from cloud" -ForegroundColor Gray
Write-Host "   • Service restart applies downloaded policies" -ForegroundColor Gray
Write-Host "   • New policies may require 1-2 hour wait before sync" -ForegroundColor Gray
Write-Host "   • Existing policies sync immediately" -ForegroundColor Gray

Write-Host "`n⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Verify policy sync status in Purview portal" -ForegroundColor Gray
Write-Host "   2. If policy is synced, run Start-DLPScanWithReset.ps1" -ForegroundColor Gray
Write-Host "   3. If policy shows 'Pending', wait 1-2 hours then re-run this script" -ForegroundColor Gray
Write-Host "   4. Monitor DLP scan with Monitor-DLPScan.ps1" -ForegroundColor Gray

Write-Host "`n✅ DLP Policy Sync Complete" -ForegroundColor Green

<#
.SYNOPSIS
    Syncs corrected repository paths from Purview portal and verifies scanner configuration.

.DESCRIPTION
    After updating repository UNC paths in the Purview portal (fixing \\localhost vs \\COMPUTERNAME issues),
    this script downloads the updated content scan job configuration and verifies the repositories are properly
    registered with the scanner. It confirms the fix is in place before re-running the scan.

.EXAMPLE
    .\Update-RepositoryPathsPostFix.ps1
    
    Downloads updated repository paths from portal and verifies configuration.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Repository paths corrected in Purview portal
    - Content scan job saved in portal
    - Scanner service running
    
    Script development orchestrated using GitHub Copilot.

.FIX WORKFLOW
    1. Portal paths updated (from Test-RepositoryPathDiagnostics.ps1 recommendations)
    2. This script downloads updated configuration
    3. Verifies scanner sees corrected paths
    4. Prepares for re-scan with Invoke-ScanAfterFix.ps1
#>

[CmdletBinding()]
param()

# =============================================================================
# Solution 2: Update Scanner Configuration After Path Fixes
# =============================================================================

Write-Host "`n🔄 SOLUTION 2: Apply Repository Path Fixes" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Step 1: Download updated configuration
Write-Host "`n📋 Step 1: Downloading updated configuration from Purview portal..." -ForegroundColor Cyan

try {
    Update-AIPScanner -ErrorAction Stop
    Write-Host "   ✅ Configuration update complete" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Update-AIPScanner failed: $_" -ForegroundColor Red
    Write-Host "`n⚠️  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Verify content scan job saved in portal" -ForegroundColor Gray
    Write-Host "   - Check network connectivity to portal" -ForegroundColor Gray
    Write-Host "   - Ensure you're still authenticated: Get-AIPServiceConfiguration" -ForegroundColor Gray
    exit 1
}

# Step 2: Restart scanner service
Write-Host "`n📋 Step 2: Restarting scanner service to apply changes..." -ForegroundColor Cyan

try {
    Restart-Service -Name "MIPScanner" -ErrorAction Stop
    Write-Host "   ✅ Scanner service restarted" -ForegroundColor Green
    
    Write-Host "`n   Waiting 60 seconds for service to stabilize..." -ForegroundColor Gray
    Start-Sleep -Seconds 60
    
    $service = Get-Service -Name "MIPScanner" -ErrorAction Stop
    if ($service.Status -eq "Running") {
        Write-Host "   ✅ Scanner service is running" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Service status: $($service.Status)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Service restart failed: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Verify updated repository configuration
Write-Host "`n📋 Step 3: Verifying updated repository configuration..." -ForegroundColor Cyan

try {
    $repositories = Get-ScannerRepository -ErrorAction Stop
    
    if ($repositories.Count -eq 0) {
        Write-Host "   ⚠️  WARNING: No repositories configured!" -ForegroundColor Yellow
        Write-Host "`n   This means Update-AIPScanner didn't pull the configuration." -ForegroundColor Yellow
        Write-Host "   Verify content scan job saved in portal and try again." -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "`n   ✅ Found $($repositories.Count) configured repositories:" -ForegroundColor Green
    foreach ($repo in $repositories) {
        Write-Host "`n   Repository: $($repo.Path)" -ForegroundColor Yellow
        Write-Host "      EnableDlp: $($repo.EnableDlp)" -ForegroundColor Gray
        Write-Host "      Enforce: $($repo.Enforce)" -ForegroundColor Gray
        Write-Host "      LabelFilesByContent: $($repo.LabelFilesByContent)" -ForegroundColor Gray
    }
    
    Write-Host "`n✅ Configuration Verification Complete" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Get-ScannerRepository failed: $_" -ForegroundColor Red
    Write-Host "`n⚠️  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Run Start-Scan to pull repository config from portal" -ForegroundColor Gray
    Write-Host "   - Verify content scan job has repositories defined" -ForegroundColor Gray
    exit 1
}

# Provide next steps
Write-Host "`n⏭️  Next Steps:" -ForegroundColor Cyan
Write-Host "==============" -ForegroundColor Cyan
Write-Host "   1. Verify repository paths match Test-RepositoryPathDiagnostics.ps1 recommendations" -ForegroundColor Gray
Write-Host "   2. Run Invoke-ScanAfterFix.ps1 to re-scan with corrected paths" -ForegroundColor Gray
Write-Host "   3. Monitor with Monitor-ScanProgress.ps1" -ForegroundColor Gray
Write-Host "   4. Verify scan completes with 0 skipped repositories" -ForegroundColor Gray

Write-Host "`n✅ Ready to re-scan with corrected repository paths" -ForegroundColor Green

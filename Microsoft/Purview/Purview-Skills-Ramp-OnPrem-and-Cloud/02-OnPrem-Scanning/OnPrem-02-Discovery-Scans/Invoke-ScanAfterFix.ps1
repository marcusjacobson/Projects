<#
.SYNOPSIS
    Re-runs the scanner after repository path fixes to verify skipped repositories are resolved.

.DESCRIPTION
    After correcting repository UNC paths in the Purview portal and syncing the configuration with
    Update-RepositoryPathsPostFix.ps1, this script starts a new scan with the -Reset flag to clear
    the previous scan state. It then provides monitoring guidance to verify the scan completes
    successfully with 0 skipped repositories.

.EXAMPLE
    .\Invoke-ScanAfterFix.ps1
    
    Starts a new scan with -Reset flag after repository path corrections.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Repository paths corrected and synced
    - Scanner service running
    - Update-RepositoryPathsPostFix.ps1 completed successfully
    
    Script development orchestrated using GitHub Copilot.

.RESET FLAG
    The -Reset flag clears the scanner's previous scan state in the local database,
    forcing it to treat this as a fresh scan with the new repository paths.
#>

[CmdletBinding()]
param()

# =============================================================================
# Solution 3: Re-scan with Reset Flag
# =============================================================================

Write-Host "`n🔄 SOLUTION 3: Re-scan After Repository Path Fixes" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Step 1: Start scan with -Reset flag
Write-Host "`n📋 Step 1: Starting scan with -Reset flag..." -ForegroundColor Cyan
Write-Host "   (This clears previous scan state and forces fresh scan)" -ForegroundColor Gray

try {
    Start-Scan -Reset -ErrorAction Stop
    Write-Host "   ✅ Scan initiated successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Start-Scan failed: $_" -ForegroundColor Red
    Write-Host "`n⚠️  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Verify scanner service is running: Get-Service MIPScanner" -ForegroundColor Gray
    Write-Host "   - Check that Update-RepositoryPathsPostFix.ps1 completed successfully" -ForegroundColor Gray
    Write-Host "   - Verify repositories configured: Get-ScannerRepository" -ForegroundColor Gray
    exit 1
}

Write-Host "`n   Waiting 10 seconds for scan initialization..." -ForegroundColor Gray
Start-Sleep -Seconds 10

# Step 2: Verify scan started
Write-Host "`n📋 Step 2: Verifying scan started..." -ForegroundColor Cyan

try {
    $status = Get-AIPScannerStatus -ErrorAction Stop
    
    if ($null -ne $status.LastScanStartTime) {
        Write-Host "   ✅ Scan started at: $($status.LastScanStartTime)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Scan status unclear - check manually with Get-AIPScannerStatus" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ⚠️  Could not verify scan status: $_" -ForegroundColor Yellow
    Write-Host "   Scan may still be starting - use Monitor-ScanProgress.ps1 to check" -ForegroundColor Gray
}

# Step 3: Provide monitoring guidance
Write-Host "`n📋 Step 3: Monitor scan progress and verify fix..." -ForegroundColor Cyan

Write-Host "`n   ✅ Expected Results (if fix worked):" -ForegroundColor Green
Write-Host "      - Scan discovers files in all 3 repositories" -ForegroundColor Gray
Write-Host "      - No SkippedRepositories (count should be 0)" -ForegroundColor Gray
Write-Host "      - DetailedReport.csv shows files from Finance, HR, and Projects" -ForegroundColor Gray

Write-Host "`n   ⏳ Estimated Scan Duration:" -ForegroundColor Cyan
Write-Host "      - Lab environment: 5-10 minutes" -ForegroundColor Gray
Write-Host "      - Production: 5-30 minutes (depends on file count)" -ForegroundColor Gray

Write-Host "`n   📊 Monitoring Options:" -ForegroundColor Cyan
Write-Host "      Option 1: Continuous monitoring with auto-refresh" -ForegroundColor Yellow
Write-Host "         Run: Monitor-ScanProgress.ps1" -ForegroundColor Gray
Write-Host "         (Updates every 30 seconds until scan completes)" -ForegroundColor Gray
Write-Host ""
Write-Host "      Option 2: Manual periodic checks" -ForegroundColor Yellow
Write-Host "         Run: Get-AIPScannerStatus" -ForegroundColor Gray
Write-Host "         (Run every few minutes to check progress)" -ForegroundColor Gray

# Step 4: Verification steps after scan completes
Write-Host "`n⏭️  After Scan Completes:" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan

Write-Host "`n   1. Check for skipped repositories:" -ForegroundColor Gray
Write-Host "      Get-AIPScannerStatus | Select-Object SkippedRepositories" -ForegroundColor Yellow
Write-Host "      Expected: 0 (or blank)" -ForegroundColor Gray

Write-Host "`n   2. Review detailed scan report:" -ForegroundColor Gray
Write-Host "      Run: Get-DetailedScanReport.ps1" -ForegroundColor Yellow
Write-Host "      Verify files from all 3 repositories appear in results" -ForegroundColor Gray

Write-Host "`n   3. Validate in Activity Explorer (wait 24 hours):" -ForegroundColor Gray
Write-Host "      - Go to Activity Explorer in Purview portal" -ForegroundColor Gray
Write-Host "      - Filter by 'Scanned by' = scanner activity" -ForegroundColor Gray
Write-Host "      - Confirm files from Finance, HR, Projects appear" -ForegroundColor Gray

Write-Host "`n✅ Scan Initiated - Use Monitor-ScanProgress.ps1 to track completion" -ForegroundColor Green

<#
.SYNOPSIS
    Initiates a full DLP-enabled scan with reset to evaluate all files against DLP policies.

.DESCRIPTION
    This script starts a comprehensive scan of all configured repositories with the -Reset parameter,
    forcing the scanner to re-evaluate every file regardless of previous scan status. The reset is
    critical after enabling DLP policies to ensure all files are checked, not just new or modified
    files. Without -Reset, previously scanned files would be skipped even though DLP policies are
    now active.

.EXAMPLE
    .\Start-DLPScanWithReset.ps1
    
    Starts full rescan with DLP policy evaluation enabled.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Information Protection Scanner configured with repositories
    - For portal-configured scanners: Enable DLP policy rules = On in Content Scan Job settings
    - For local-configured scanners: EnableDLP=On configured (Enable-ScannerDLP.ps1 completed)
    - DLP policies synced (Sync-DLPPolicies.ps1 completed)
    - Scanner service running
    
    Script development orchestrated using GitHub Copilot.

.RESET REQUIREMENT
    - Start-Scan -Reset: Forces full rescan of all files
    - Without -Reset: Scanner skips previously scanned files
    - DLP Evaluation: Only works on files that are actually scanned
    - Critical After: Any DLP policy changes or EnableDLP configuration
#>

[CmdletBinding()]
param()

# =============================================================================
# Configuration: Start DLP-Enabled Scan with Reset
# =============================================================================

Write-Host "`n🔄 Starting DLP-Enabled Scan with Full Reset" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

# Step 1: Verify prerequisites
Write-Host "`n📋 Step 1: Verifying prerequisites..." -ForegroundColor Cyan

# Check scanner configuration and DLP enabled
try {
    $scannerConfig = Get-ScannerContentScan -ErrorAction Stop
    $onlineConfig = Get-ScannerConfiguration -ErrorAction Stop
    
    # Check if scanner is in Online mode (portal-configured)
    if ($onlineConfig.OnlineConfiguration -eq 'On') {
        Write-Host "   ✅ Scanner is portal-configured (OnlineConfiguration = On)" -ForegroundColor Green
        Write-Host "   📋 DLP settings are managed in Purview portal" -ForegroundColor Gray
        Write-Host "   💡 Ensure 'Enable DLP policy rules' is On in Content Scan Job settings" -ForegroundColor Yellow
    } else {
        # Local configuration mode - check EnableDlp setting
        if ($scannerConfig.EnableDlp -ne 'On') {
            Write-Host "   ❌ DLP is not enabled" -ForegroundColor Red
            Write-Host "`n⚠️  Prerequisite Missing:" -ForegroundColor Yellow
            Write-Host "   For local configuration: Run Enable-ScannerDLP.ps1 first" -ForegroundColor Gray
            Write-Host "   For portal configuration: Enable DLP in Content Scan Job settings" -ForegroundColor Gray
            exit 1
        }
        Write-Host "   ✅ DLP is enabled (local configuration)" -ForegroundColor Green
    }
    
    Write-Host "   ContentScanJob: $($scannerConfig.JobName)" -ForegroundColor Gray
    
} catch {
    Write-Host "   ❌ Failed to verify scanner configuration: $_" -ForegroundColor Red
    exit 1
}

# Check scanner service
try {
    $service = Get-Service -Name "MIPScanner" -ErrorAction Stop
    
    if ($service.Status -ne 'Running') {
        Write-Host "   ❌ Scanner service is not running" -ForegroundColor Red
        Write-Host "`n⚠️  Start service first:" -ForegroundColor Yellow
        Write-Host "   Run: Start-Service -Name MIPScanner" -ForegroundColor Gray
        exit 1
    }
    
    Write-Host "   ✅ Scanner service is running" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Scanner service check failed: $_" -ForegroundColor Red
    exit 1
}

# Check for existing scan
Write-Host "`n   Checking for active scan..." -ForegroundColor Gray
try {
    $scannerStatus = Get-AIPScannerStatus -ErrorAction Stop
    
    if ($scannerStatus.ScanStatus -eq 'Running') {
        Write-Host "   ⚠️  Warning: A scan is currently running" -ForegroundColor Yellow
        Write-Host "`n   Current scan details:" -ForegroundColor Gray
        Write-Host "      Status: $($scannerStatus.ScanStatus)" -ForegroundColor Gray
        Write-Host "      Files scanned: $($scannerStatus.ScannedFiles)" -ForegroundColor Gray
        
        Write-Host "`n   ⚠️  Wait for current scan to complete before starting new scan" -ForegroundColor Yellow
        Write-Host "   Monitor with: Get-AIPScannerStatus" -ForegroundColor Gray
        exit 0
    }
    
    Write-Host "   ✅ No active scan detected" -ForegroundColor Green
    
} catch {
    Write-Host "   ⚠️  Could not check scan status: $_" -ForegroundColor Yellow
    Write-Host "   Proceeding with scan initiation..." -ForegroundColor Gray
}

# Step 2: Explain reset requirement
Write-Host "`n📋 Step 2: Understanding -Reset parameter..." -ForegroundColor Cyan

Write-Host "`n   ❓ Why -Reset is Required:" -ForegroundColor Yellow
Write-Host "   =========================" -ForegroundColor Yellow
Write-Host ""
Write-Host "   • Without -Reset:" -ForegroundColor Gray
Write-Host "     Scanner skips files with 'Already scanned' status" -ForegroundColor Gray
Write-Host "     DLP policies not evaluated on previously scanned files" -ForegroundColor Gray
Write-Host ""
Write-Host "   • With -Reset:" -ForegroundColor Gray
Write-Host "     Forces re-evaluation of ALL files" -ForegroundColor Gray
Write-Host "     Applies newly enabled DLP policies to entire repository" -ForegroundColor Gray
Write-Host "     Clears previous scan cache" -ForegroundColor Gray
Write-Host ""
Write-Host "   💡 Reset Required After:" -ForegroundColor Cyan
Write-Host "      - Enabling DLP (EnableDLP = On)" -ForegroundColor Gray
Write-Host "      - Adding/modifying DLP policies" -ForegroundColor Gray
Write-Host "      - Changing policy enforcement mode" -ForegroundColor Gray

# Step 3: Start scan with reset
Write-Host "`n📋 Step 3: Initiating DLP-enabled scan with reset..." -ForegroundColor Cyan
Write-Host "   This will scan all files with DLP policy evaluation" -ForegroundColor Gray

try {
    Start-Scan -Reset -ErrorAction Stop
    Write-Host "   ✅ Scan initiated successfully with -Reset parameter" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to start scan: $_" -ForegroundColor Red
    Write-Host "`n⚠️  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Verify scanner service is running: Get-Service MIPScanner" -ForegroundColor Gray
    Write-Host "   - Check no other scan is active: Get-AIPScannerStatus" -ForegroundColor Gray
    Write-Host "   - Ensure repositories are configured: Get-ScannerRepository" -ForegroundColor Gray
    exit 1
}

# Step 4: Verify scan initialization
Write-Host "`n📋 Step 4: Verifying scan initialization..." -ForegroundColor Cyan
Write-Host "   Waiting for scan to start..." -ForegroundColor Gray
Start-Sleep -Seconds 5

try {
    $scannerStatus = Get-AIPScannerStatus -ErrorAction Stop
    
    Write-Host "`n   Scan Status:" -ForegroundColor Green
    Write-Host "      Status: $($scannerStatus.ScanStatus)" -ForegroundColor Gray
    Write-Host "      Current repository: $($scannerStatus.CurrentRepository)" -ForegroundColor Gray
    
    if ($scannerStatus.ScanStatus -eq 'Running') {
        Write-Host "`n   ✅ Scan is running" -ForegroundColor Green
    } elseif ($scannerStatus.ScanStatus -eq 'Idle') {
        Write-Host "`n   ⚠️  Scan may not have started yet" -ForegroundColor Yellow
        Write-Host "   Check status in 1-2 minutes: Get-AIPScannerStatus" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "   ⚠️  Could not verify scan status: $_" -ForegroundColor Yellow
}

# Step 5: Provide monitoring guidance
Write-Host "`n📊 Scan Monitoring Guidance:" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

Write-Host "`n   Expected Behavior:" -ForegroundColor Yellow
Write-Host "   • All repositories will be scanned from scratch" -ForegroundColor Gray
Write-Host "   • DLP policies evaluated on every file" -ForegroundColor Gray
Write-Host "   • Scan duration similar to OnPrem-02 discovery scan" -ForegroundColor Gray
Write-Host "   • Results appear in DetailedReport_[timestamp].csv" -ForegroundColor Gray

Write-Host "`n   Monitor scan progress:" -ForegroundColor Yellow
Write-Host "   • Run Monitor-DLPScan.ps1 for continuous monitoring" -ForegroundColor Gray
Write-Host "   • Check status manually: Get-AIPScannerStatus" -ForegroundColor Gray
Write-Host "   • View logs in Event Viewer: Application and Services Logs > Azure Information Protection" -ForegroundColor Gray

Write-Host "`n   Scan completion indicators:" -ForegroundColor Yellow
Write-Host "   • Get-AIPScannerStatus shows ScanStatus = 'Idle'" -ForegroundColor Gray
Write-Host "   • New DetailedReport file in C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports" -ForegroundColor Gray
Write-Host "   • All configured repositories show as scanned" -ForegroundColor Gray

Write-Host "`n💡 Important Notes:" -ForegroundColor Cyan
Write-Host "   • This scan re-evaluates ALL files (not just new/changed)" -ForegroundColor Gray
Write-Host "   • DLP policy matches will appear in DetailedReport.csv" -ForegroundColor Gray
Write-Host "   • Enforce=Off means audit-only (no file access blocking yet)" -ForegroundColor Gray
Write-Host "   • OnPrem-04 will enable enforcement mode (Enforce=On)" -ForegroundColor Gray

Write-Host "`n⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Run Monitor-DLPScan.ps1 to track scan progress" -ForegroundColor Gray
Write-Host "   2. Wait for scan completion (status = 'Idle')" -ForegroundColor Gray
Write-Host "   3. Run Get-DLPScanReport.ps1 to analyze DLP detection results" -ForegroundColor Gray
Write-Host "   4. Proceed to OnPrem-04 for DLP activity monitoring" -ForegroundColor Gray

Write-Host "`n✅ DLP Scan with Reset Initiated" -ForegroundColor Green

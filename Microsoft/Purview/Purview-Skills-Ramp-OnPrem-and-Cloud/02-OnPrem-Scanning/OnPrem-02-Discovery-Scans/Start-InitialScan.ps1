<#
.SYNOPSIS
    Starts initial discovery scan and verifies repository synchronization.

.DESCRIPTION
    This script initiates the first discovery scan which pulls the content scan job configuration
    from the Purview portal to the local scanner database. It then verifies that all repositories
    were synchronized successfully by checking the output of Get-ScannerRepository.
    
    The Start-Scan command is critical because Update-AIPScanner only registers the node;
    Start-Scan actually downloads the repository configuration.

.EXAMPLE
    .\Start-InitialScan.ps1
    
    Starts discovery scan and verifies repository synchronization.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Scanner service running
    - Content scan job configured in Purview portal with repositories
    - SMB shares created and accessible
    - NTFS permissions granted to scanner service account
    - Scanner authentication completed (Set-Authentication -OnBehalfOf)
    
    Script development orchestrated using GitHub Copilot.

.SCAN INITIALIZATION
    - Starts first discovery scan
    - Pulls content scan job config from portal to local database
    - Verifies repositories synchronized successfully
    - Displays repository configuration details
#>

[CmdletBinding()]
param()

# =============================================================================
# Start initial discovery scan and verify repository sync.
# =============================================================================

Write-Host "`n🚀 Part 4: Start Scan to Pull Content Scan Job Configuration" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan

# Start scan
Write-Host "`n📋 Starting discovery scan..." -ForegroundColor Cyan
Write-Host "   This pulls content scan job configuration from portal" -ForegroundColor Gray
Write-Host "   Uses authentication tokens cached by Set-Authentication in OnPrem-01" -ForegroundColor Gray

try {
    Start-Scan
    Write-Host "   ✅ Scan started successfully" -ForegroundColor Green
    Write-Host "   ⏳ Scan initialization may take a few moments..." -ForegroundColor Cyan
    
    # Wait for scan to initialize
    Start-Sleep -Seconds 10
    
} catch {
    Write-Host "   ❌ Failed to start scan" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    Write-Host "`n   Troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "   1. Verify scanner service is running: Get-Service MIPScanner" -ForegroundColor Gray
    Write-Host "   2. Check scanner authentication: Run Set-Authentication -OnBehalfOf" -ForegroundColor Gray
    Write-Host "   3. Confirm content scan job exists in Purview portal" -ForegroundColor Gray
    exit 1
}

# Verify repositories synced successfully
Write-Host "`n📋 Verifying repositories synchronized from portal..." -ForegroundColor Cyan

try {
    $repositories = Get-ScannerRepository -ErrorAction Stop
    
    if ($repositories) {
        Write-Host "   ✅ Repositories synchronized successfully" -ForegroundColor Green
        Write-Host "`n   Repository Configuration:" -ForegroundColor Cyan
        
        foreach ($repo in $repositories) {
            Write-Host "`n   📂 Path: $($repo.Path)" -ForegroundColor Yellow
            Write-Host "      EnableDlp: $($repo.EnableDlp)" -ForegroundColor Gray
            Write-Host "      Enforce: $($repo.Enforce)" -ForegroundColor Gray
            Write-Host "      LabelFilesByContent: $($repo.LabelFilesByContent)" -ForegroundColor Gray
            Write-Host "      RelabelFiles: $($repo.RelabelFiles)" -ForegroundColor Gray
            Write-Host "      AllowLabelDowngrade: $($repo.AllowLabelDowngrade)" -ForegroundColor Gray
        }
        
        Write-Host "`n📊 Repository Summary:" -ForegroundColor Cyan
        Write-Host "   Total repositories: $($repositories.Count)" -ForegroundColor Gray
        
    } else {
        Write-Host "   ⚠️  WARNING: No repositories found" -ForegroundColor Yellow
        Write-Host "`n   Possible causes:" -ForegroundColor Yellow
        Write-Host "   1. Start-Scan still initializing (wait 30 seconds and re-run Get-ScannerRepository)" -ForegroundColor Gray
        Write-Host "   2. Content scan job not saved in Purview portal (return to portal and Save)" -ForegroundColor Gray
        Write-Host "   3. Repositories not added to content scan job in portal" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "   ⚠️  Could not retrieve repository configuration" -ForegroundColor Yellow
    Write-Host "   Error: $_" -ForegroundColor Yellow
    Write-Host "`n   This is normal if scan is still initializing" -ForegroundColor Gray
    Write-Host "   Wait 30 seconds and run: Get-ScannerRepository" -ForegroundColor Gray
}

Write-Host "`n✅ Discovery Scan Initiated" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

Write-Host "`n⏱️  Scan Duration Estimate:" -ForegroundColor Cyan
Write-Host "   Lab sample data (3 shares, ~10 files each): 5-10 minutes" -ForegroundColor Gray
Write-Host "   Production environments: 5-30 minutes depending on file count" -ForegroundColor Gray

Write-Host "`n📋 Scan uses authentication tokens from OnPrem-01 setup" -ForegroundColor Cyan
Write-Host "   Cached by: Set-Authentication -OnBehalfOf in OnPrem-01" -ForegroundColor Gray

Write-Host "`n⏭️  Continue with Step 2: Monitor Scan Progress" -ForegroundColor Yellow
Write-Host "   Use Monitor-ScanProgress.ps1 to track scan completion" -ForegroundColor Gray

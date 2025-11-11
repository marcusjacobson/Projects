<#
.SYNOPSIS
    Syncs scanner configuration from Purview portal and restarts scanner service.

.DESCRIPTION
    This script updates the local scanner configuration by downloading the latest content scan job
    settings from the Microsoft Purview portal. It registers the scanner node with the portal cluster,
    restarts the scanner service to load the new configuration, and verifies the service is running.
    
    This step is critical after adding or modifying repositories in the Purview portal to ensure
    the scanner has the latest configuration before executing scans.

.EXAMPLE
    .\Update-ScannerConfiguration.ps1
    
    Updates scanner configuration from Purview portal and restarts the MIPScanner service.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Purview Information Protection scanner client installed
    - Scanner service installed and authenticated
    - Content scan job configured in Purview portal with repositories added
    - Network connectivity to Purview portal
    
    Script development orchestrated using GitHub Copilot.

.CONFIGURATION SYNC
    - Registers scanner node with portal cluster
    - Downloads latest content scan job configuration
    - Restarts scanner service to apply changes
    - Verifies service is running after restart
#>

[CmdletBinding()]
param()

# =============================================================================
# Sync scanner configuration from Purview portal.
# =============================================================================

Write-Host "`n🔄 Part 1: Sync Scanner Configuration from Portal" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Update scanner configuration from portal
Write-Host "`n📋 Downloading latest configuration from Purview portal..." -ForegroundColor Cyan
try {
    Update-AIPScanner
    Write-Host "   ✅ Configuration updated successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to update scanner configuration" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    Write-Host "`n   Troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "   1. Verify network connectivity to Purview portal" -ForegroundColor Gray
    Write-Host "   2. Confirm content scan job exists in portal" -ForegroundColor Gray
    Write-Host "   3. Check scanner authentication is valid" -ForegroundColor Gray
    exit 1
}

# Restart scanner service to load new configuration
Write-Host "`n📋 Restarting scanner service to apply configuration..." -ForegroundColor Cyan
try {
    Restart-Service -Name "MIPScanner" -ErrorAction Stop
    Write-Host "   ✅ Scanner service restarted" -ForegroundColor Green
    
    # Wait for service to stabilize
    Write-Host "   ⏳ Waiting 60 seconds for service to initialize..." -ForegroundColor Cyan
    Start-Sleep -Seconds 60
    
} catch {
    Write-Host "   ❌ Failed to restart scanner service" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    exit 1
}

# Verify service is running
Write-Host "`n📋 Verifying scanner service status..." -ForegroundColor Cyan
try {
    $service = Get-Service -Name "MIPScanner" -ErrorAction Stop
    
    if ($service.Status -eq "Running") {
        Write-Host "   ✅ Scanner service is running" -ForegroundColor Green
        Write-Host "   Status: $($service.Status)" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠️  Scanner service is not running" -ForegroundColor Yellow
        Write-Host "   Status: $($service.Status)" -ForegroundColor Gray
        Write-Host "`n   Check Event Viewer for errors:" -ForegroundColor Yellow
        Write-Host "   Applications and Services Logs > Azure Information Protection" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "   ❌ Could not verify scanner service status" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✅ Scanner Configuration Sync Complete" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host "`n⏭️  Continue with Part 2: Create SMB File Shares" -ForegroundColor Yellow

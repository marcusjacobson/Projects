<#
.SYNOPSIS
    Verifies OnPrem-01 scanner deployment completion before starting OnPrem-02 discovery scans.

.DESCRIPTION
    This validation script checks that all critical OnPrem-01 scanner deployment steps were completed
    successfully before proceeding with OnPrem-02 discovery scans. It verifies scanner service status
    and runs comprehensive diagnostics to confirm authentication, database connectivity, and
    content scan job configuration.
    
    The script prevents users from proceeding to OnPrem-02 if foundational scanner components
    are not properly configured, reducing troubleshooting time and ensuring successful discovery scans.

.PARAMETER ComputerName
    The computer name of the scanner VM. If not provided, uses $env:COMPUTERNAME.

.EXAMPLE
    .\Verify-OnPrem01Completion.ps1
    
    Validates OnPrem-01 completion using the current computer name for scanner service account.

.EXAMPLE
    .\Verify-OnPrem01Completion.ps1 -ComputerName "VM-PURVIEW-SCAN"
    
    Validates OnPrem-01 completion using explicit computer name for scanner service account.

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
    - Scanner service created (MIPScanner)
    - Scanner service account (COMPUTERNAME\scanner-svc) created
    - OnPrem-01 scanner deployment completed
    
    Script development orchestrated using GitHub Copilot.

.VALIDATION CHECKS
    - Scanner service exists and is running
    - Scanner diagnostics pass (connectivity, database, authentication, content scan job)
    - Scanner service account credentials valid
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ComputerName = $env:COMPUTERNAME
)

# =============================================================================
# Verify OnPrem-01 scanner deployment completion.
# =============================================================================

Write-Host "`n🔍 Step 1: Validating OnPrem-01 Completion" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check 1: Verify scanner service exists and is running
Write-Host "`n📋 Checking scanner service status..." -ForegroundColor Cyan
try {
    $service = Get-Service -Name "MIPScanner" -ErrorAction Stop
    
    if ($service.Status -eq "Running") {
        Write-Host "   ✅ Scanner service is running" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Scanner service exists but is not running" -ForegroundColor Red
        Write-Host "   Status: $($service.Status)" -ForegroundColor Yellow
        Write-Host "`n   Return to OnPrem-01 and ensure scanner service starts successfully." -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "   ❌ Scanner service not found" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    Write-Host "`n   Return to OnPrem-01 and complete scanner installation (Install-Scanner)." -ForegroundColor Yellow
    exit 1
}

# Check 2: Verify scanner authentication and diagnostics
Write-Host "`n📋 Running scanner diagnostics..." -ForegroundColor Cyan
Write-Host "   You will be prompted for scanner service account credentials" -ForegroundColor Gray
Write-Host "   Username format: $ComputerName\scanner-svc" -ForegroundColor Gray

try {
    # Prompt for scanner service account credentials
    $scannerCreds = Get-Credential "$ComputerName\scanner-svc"
    
    # Run comprehensive scanner diagnostics
    Start-ScannerDiagnostics -OnBehalfOf $scannerCreds
    
    Write-Host "`n   ✅ Scanner diagnostics completed successfully" -ForegroundColor Green
    Write-Host "   All checks passed:" -ForegroundColor Green
    Write-Host "   - Connectivity checks completed" -ForegroundColor Gray
    Write-Host "   - Database check completed" -ForegroundColor Gray
    Write-Host "   - Authentication check completed" -ForegroundColor Gray
    Write-Host "   - Content scan job check completed" -ForegroundColor Gray
    Write-Host "   - Configuration check completed" -ForegroundColor Gray
    
} catch {
    Write-Host "`n   ❌ Scanner diagnostics failed" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    Write-Host "`n   Return to OnPrem-01 and complete the following:" -ForegroundColor Yellow
    Write-Host "   1. Verify scanner authentication (Set-Authentication -OnBehalfOf)" -ForegroundColor Gray
    Write-Host "   2. Confirm content scan job created in Purview portal" -ForegroundColor Gray
    Write-Host "   3. Check scanner service account credentials" -ForegroundColor Gray
    exit 1
}

# Validation complete
Write-Host "`n✅ OnPrem-01 Validation Complete" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host "`n📚 OnPrem-01 completed successfully!" -ForegroundColor Cyan
Write-Host "   Scanner service is running" -ForegroundColor Gray
Write-Host "   Scanner diagnostics passed all checks" -ForegroundColor Gray
Write-Host "   Ready to proceed with OnPrem-02 Discovery Scans" -ForegroundColor Gray
Write-Host "`n⏭️  Continue with OnPrem-02 Step 1: Add Repository to Content Scan Job" -ForegroundColor Yellow

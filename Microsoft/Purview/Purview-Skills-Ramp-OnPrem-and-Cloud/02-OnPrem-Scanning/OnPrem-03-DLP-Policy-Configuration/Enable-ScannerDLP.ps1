<#
.SYNOPSIS
    Enables DLP policy evaluation in the scanner's content scan job configuration.

.DESCRIPTION
    This configuration script enables Data Loss Prevention (DLP) functionality in the Microsoft
    Information Protection Scanner. It configures the scanner to evaluate files against DLP policies
    by setting EnableDLP=On and specifying the RepositoryOwner for file ownership actions. This is
    a required step before the scanner can enforce DLP policies on on-premises file repositories.

.EXAMPLE
    .\Enable-ScannerDLP.ps1
    
    Enables DLP in the scanner content scan job with automatic computer name detection.

.PARAMETER ComputerName
    Optional computer name override. If not specified, uses $env:COMPUTERNAME.

.EXAMPLE
    .\Enable-ScannerDLP.ps1 -ComputerName "VM-PURVIEW-SCAN"
    
    Enables DLP with specific computer name for RepositoryOwner setting.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Information Protection Scanner installed
    - Scanner service account created (scanner-svc)
    - OnPrem-01 and OnPrem-02 completed
    
    Script development orchestrated using GitHub Copilot.

.DLP CONFIGURATION
    - EnableDLP = On: Enables DLP policy evaluation during scans
    - RepositoryOwner: Sets owner account for DLP "make private" actions
    - Enforce = Off: Keeps scanner in audit mode (no blocking)
    - OnlineConfiguration = Off: Allows PowerShell-based configuration
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ComputerName = $env:COMPUTERNAME
)

# =============================================================================
# Configuration: Enable DLP in Scanner Content Scan Job
# =============================================================================

Write-Host "`n🔐 Enabling DLP in Scanner Content Scan Job" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "`n📋 Computer name: $ComputerName" -ForegroundColor Yellow

# Step 1: Check current DLP configuration
Write-Host "`n📋 Step 1: Checking current DLP configuration..." -ForegroundColor Cyan

try {
    $currentConfig = Get-ScannerContentScan -ErrorAction Stop
    
    Write-Host "   Current Settings:" -ForegroundColor Gray
    Write-Host "      EnableDLP: $($currentConfig.EnableDlp)" -ForegroundColor Gray
    Write-Host "      RepositoryOwner: $($currentConfig.RepositoryOwner)" -ForegroundColor Gray
    Write-Host "      Enforce: $($currentConfig.Enforce)" -ForegroundColor Gray
    
    if ($currentConfig.EnableDlp -eq 'On' -and $currentConfig.RepositoryOwner) {
        Write-Host "`n   ✅ DLP already configured correctly" -ForegroundColor Green
        Write-Host "   No changes needed - skipping configuration" -ForegroundColor Gray
        
        Write-Host "`n⏭️  Next Steps:" -ForegroundColor Yellow
        Write-Host "   DLP is already enabled. Proceed to:" -ForegroundColor Gray
        Write-Host "   1. Run Sync-DLPPolicies.ps1 to download latest policies" -ForegroundColor Gray
        Write-Host "   2. Run Start-DLPScanWithReset.ps1 to test enforcement" -ForegroundColor Gray
        exit 0
    }
    
    if ($currentConfig.EnableDlp -ne 'On') {
        Write-Host "   ⚠️  DLP is not enabled (current: $($currentConfig.EnableDlp))" -ForegroundColor Yellow
    }
    
    if (-not $currentConfig.RepositoryOwner) {
        Write-Host "   ⚠️  RepositoryOwner is not set" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ⚠️  Could not read current configuration: $_" -ForegroundColor Yellow
    Write-Host "   Proceeding with configuration..." -ForegroundColor Gray
}

# Step 2: Disable online configuration
Write-Host "`n📋 Step 2: Setting scanner to PowerShell-based configuration..." -ForegroundColor Cyan

try {
    Set-ScannerConfiguration -OnlineConfiguration Off -ErrorAction Stop
    Write-Host "   ✅ OnlineConfiguration set to Off" -ForegroundColor Green
    Write-Host "   Scanner now accepts PowerShell cmdlet configuration" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Failed to disable online configuration: $_" -ForegroundColor Red
    Write-Host "`n⚠️  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Verify scanner service is running: Get-Service MIPScanner" -ForegroundColor Gray
    Write-Host "   - Check you're running PowerShell as Administrator" -ForegroundColor Gray
    exit 1
}

# Step 3: Enable DLP with RepositoryOwner
Write-Host "`n📋 Step 3: Enabling DLP policy evaluation..." -ForegroundColor Cyan

$repositoryOwner = "$ComputerName\scanner-svc"
Write-Host "   Setting RepositoryOwner: $repositoryOwner" -ForegroundColor Gray

try {
    Set-ScannerContentScan -EnableDLP On -RepositoryOwner $repositoryOwner -ErrorAction Stop
    Write-Host "   ✅ DLP enabled successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to enable DLP: $_" -ForegroundColor Red
    Write-Host "`n⚠️  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Verify scanner-svc account exists: net user scanner-svc" -ForegroundColor Gray
    Write-Host "   - Check computer name is correct: $ComputerName" -ForegroundColor Gray
    Write-Host "   - Ensure scanner service is running" -ForegroundColor Gray
    exit 1
}

# Step 4: Verify configuration applied
Write-Host "`n📋 Step 4: Verifying DLP configuration..." -ForegroundColor Cyan

try {
    $updatedConfig = Get-ScannerContentScan -ErrorAction Stop
    
    Write-Host "   Updated Settings:" -ForegroundColor Green
    Write-Host "      EnableDLP: $($updatedConfig.EnableDlp)" -ForegroundColor Gray
    Write-Host "      RepositoryOwner: $($updatedConfig.RepositoryOwner)" -ForegroundColor Gray
    Write-Host "      Enforce: $($updatedConfig.Enforce)" -ForegroundColor Gray
    
    # Validate settings
    $isValid = ($updatedConfig.EnableDlp -eq 'On') -and 
               ($updatedConfig.RepositoryOwner -eq $repositoryOwner)
    
    if ($isValid) {
        Write-Host "`n   ✅ Configuration validated successfully" -ForegroundColor Green
    } else {
        Write-Host "`n   ⚠️  Configuration validation failed" -ForegroundColor Yellow
        Write-Host "   Settings may not have applied correctly" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "   ⚠️  Could not verify configuration: $_" -ForegroundColor Yellow
}

# Step 5: Explain configuration impact
Write-Host "`n📊 Configuration Impact:" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan

Write-Host "`n   • EnableDLP = On:" -ForegroundColor Yellow
Write-Host "     Scanner will now evaluate files against DLP policies" -ForegroundColor Gray
Write-Host ""
Write-Host "   • RepositoryOwner = $repositoryOwner" -ForegroundColor Yellow
Write-Host "     Sets owner account for DLP 'make private' actions" -ForegroundColor Gray
Write-Host ""
Write-Host "   • Enforce = Off (default):" -ForegroundColor Yellow
Write-Host "     Scanner remains in audit mode (logs matches, no blocking)" -ForegroundColor Gray
Write-Host "     Will be changed to 'On' in OnPrem-04 for enforcement" -ForegroundColor Gray

Write-Host "`n💡 Important Notes:" -ForegroundColor Cyan
Write-Host "   • Without EnableDLP=On, scanner ignores DLP policies" -ForegroundColor Gray
Write-Host "   • Enforce=Off means audit-only mode (safe for testing)" -ForegroundColor Gray
Write-Host "   • RepositoryOwner required for file access blocking" -ForegroundColor Gray

Write-Host "`n⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Run Sync-DLPPolicies.ps1 to download DLP policies from portal" -ForegroundColor Gray
Write-Host "   2. Run Start-DLPScanWithReset.ps1 to perform DLP-enabled scan" -ForegroundColor Gray
Write-Host "   3. Monitor scan with Monitor-DLPScan.ps1" -ForegroundColor Gray
Write-Host "   4. Verify DLP detection with Get-DLPScanReport.ps1" -ForegroundColor Gray

Write-Host "`n✅ DLP Configuration Complete" -ForegroundColor Green

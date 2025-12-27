<#
.SYNOPSIS
    Verifies Microsoft 365 auditing status using Exchange Online PowerShell.

.DESCRIPTION
    This script connects to Exchange Online PowerShell and checks the unified audit
    log ingestion status to confirm whether auditing is enabled for the tenant.
    
    This verification is critical because:
    - Auditing must be enabled for Activity Explorer functionality
    - The Security & Compliance PowerShell cmdlet always returns False (known behavior)
    - Exchange Online PowerShell provides accurate auditing status

.EXAMPLE
    .\Verify-AuditingStatus.ps1
    
    Connects to Exchange Online and displays the auditing status.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Exchange Online PowerShell V3 module (EXO V3)
    - Global Administrator or Compliance Administrator role
    - Internet connectivity to Exchange Online
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Verify Microsoft 365 auditing status using Exchange Online PowerShell
# =============================================================================

# =============================================================================
# Step 1: Connect to Exchange Online
# =============================================================================

Write-Host "🔍 Step 1: Connecting to Exchange Online PowerShell" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green

# Reset module and disable WAM broker to avoid msalruntime DLL issues
# Environment variables must be set BEFORE the module is imported
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
Remove-Module ExchangeOnlineManagement -Force -ErrorAction SilentlyContinue
$env:AZURE_IDENTITY_DISABLE_MSALRUNTIME = "1"
$env:MSAL_DISABLE_WAM = "1"
Import-Module ExchangeOnlineManagement -Force

try {
    Connect-ExchangeOnline -ErrorAction Stop
    Write-Host "   ✅ Connected to Exchange Online successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to connect to Exchange Online: $_" -ForegroundColor Red
    Write-Host "   Please install Exchange Online PowerShell: Install-Module ExchangeOnlineManagement" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 2: Verify Auditing Status
# =============================================================================

Write-Host "`n🔍 Step 2: Checking Unified Audit Log Status" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

try {
    $auditConfig = Get-AdminAuditLogConfig
    $auditStatus = $auditConfig.UnifiedAuditLogIngestionEnabled
    
    if ($auditStatus) {
        Write-Host "   ✅ Auditing is ENABLED" -ForegroundColor Green
        Write-Host "   Status: UnifiedAuditLogIngestionEnabled = True" -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠️  Auditing is DISABLED" -ForegroundColor Yellow
        Write-Host "   Status: UnifiedAuditLogIngestionEnabled = False" -ForegroundColor Cyan
        Write-Host "   Run Enable-AuditingConfiguration.ps1 to enable auditing" -ForegroundColor Yellow
    }
    
    # Display full configuration details
    Write-Host "`n📊 Full Audit Configuration:" -ForegroundColor Cyan
    $auditConfig | Format-List UnifiedAuditLogIngestionEnabled
    
} catch {
    Write-Host "   ❌ Failed to retrieve audit configuration: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Auditing verification complete" -ForegroundColor Green

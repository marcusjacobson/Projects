<#
.SYNOPSIS
    Enables Microsoft 365 unified audit log ingestion using Exchange Online PowerShell.

.DESCRIPTION
    This script connects to Exchange Online PowerShell and enables unified audit log
    ingestion for the tenant. This is required for Activity Explorer functionality
    and DLP activity tracking in Microsoft Purview.
    
    Auditing activation timeline:
    - Initial activation: Immediate
    - Full data collection: 2-24 hours
    - Historical data: NOT collected (only forward from enablement)

.EXAMPLE
    .\Enable-AuditingConfiguration.ps1
    
    Connects to Exchange Online, enables auditing, and verifies the configuration.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Exchange Online PowerShell V3 module (EXO V3)
    - Global Administrator role (required for Set-AdminAuditLogConfig)
    - Internet connectivity to Exchange Online
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Enable Microsoft 365 unified audit log ingestion
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
# Step 2: Enable Auditing
# =============================================================================

Write-Host "`n🔍 Step 2: Enabling Unified Audit Log Ingestion" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

try {
    Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true -ErrorAction Stop
    Write-Host "   ✅ Auditing enabled successfully" -ForegroundColor Green
    Write-Host "   Note: Full activation may take 2-24 hours" -ForegroundColor Yellow
} catch {
    Write-Host "   ❌ Failed to enable auditing: $_" -ForegroundColor Red
    Write-Host "   Verify you have Global Administrator role" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 3: Verify Configuration
# =============================================================================

Write-Host "`n🔍 Step 3: Verifying Auditing Configuration" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

try {
    $auditConfig = Get-AdminAuditLogConfig
    $auditStatus = $auditConfig.UnifiedAuditLogIngestionEnabled
    
    if ($auditStatus) {
        Write-Host "   ✅ Verification successful: Auditing is ENABLED" -ForegroundColor Green
        Write-Host "   Status: UnifiedAuditLogIngestionEnabled = True" -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠️  WARNING: Auditing still shows as disabled" -ForegroundColor Yellow
        Write-Host "   This may indicate a propagation delay - wait 15 minutes and verify again" -ForegroundColor Yellow
    }
    
    # Display full configuration
    Write-Host "`n📊 Current Audit Configuration:" -ForegroundColor Cyan
    $auditConfig | Format-List UnifiedAuditLogIngestionEnabled
    
} catch {
    Write-Host "   ❌ Failed to verify configuration: $_" -ForegroundColor Red
}

Write-Host "`n✅ Auditing enablement complete" -ForegroundColor Green
Write-Host "⏳ Allow 2-24 hours for full audit data collection to activate" -ForegroundColor Yellow

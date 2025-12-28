<#
.SYNOPSIS
    Enables the Unified Audit Log in the tenant.

.DESCRIPTION
    This script connects to Exchange Online using the Service Principal and enables
    Unified Audit Log ingestion. This is a critical "Day Zero" step as it takes
    up to 24 hours to become fully active.

.PARAMETER TenantId
    The Directory (Tenant) ID.

.PARAMETER AppId
    The Application (Client) ID.

.PARAMETER CertificateThumbprint
    The thumbprint of the client certificate.

.PARAMETER Organization
    The onmicrosoft.com domain of the tenant (required for Exchange App-only auth).

.EXAMPLE
    .\Enable-AuditLogging.ps1 -TenantId "..." -AppId "..." -CertificateThumbprint "..." -Organization "contoso.onmicrosoft.com"

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2024-05-22
    
    Requirements:
    - ExchangeOnlineManagement module
    - Service Principal with Exchange.ManageAsApp permission

    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$AppId,

    [Parameter(Mandatory = $true)]
    [string]$CertificateThumbprint,

    [Parameter(Mandatory = $true)]
    [string]$Organization
)

# =============================================================================
# Step 1: Connect to Exchange Online
# =============================================================================

Write-Host "🔌 Step 1: Connecting to Exchange Online" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

try {
    Write-Host "   🚀 Connecting..." -ForegroundColor Cyan
    Connect-ExchangeOnline -AppId $AppId -CertificateThumbprint $CertificateThumbprint -Organization $Organization -ShowBanner:$false
    Write-Host "   ✅ Connected to Exchange Online." -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to connect to Exchange Online: $_" -ForegroundColor Red
    throw
}

# =============================================================================
# Step 2: Enable Audit Log
# =============================================================================

Write-Host "📝 Step 2: Enabling Audit Log" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

try {
    $config = Get-AdminAuditLogConfig
    if ($config.UnifiedAuditLogIngestionEnabled) {
        Write-Host "   ✅ Unified Audit Log is ALREADY enabled." -ForegroundColor Green
    } else {
        Write-Host "   ⏳ Enabling Unified Audit Log (this may take time)..." -ForegroundColor Cyan
        Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
        Write-Host "   ✅ Unified Audit Log enabled successfully." -ForegroundColor Green
        Write-Host "   ⚠️ Note: It may take up to 24 hours for events to appear." -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Failed to enable Audit Log: $_" -ForegroundColor Red
}

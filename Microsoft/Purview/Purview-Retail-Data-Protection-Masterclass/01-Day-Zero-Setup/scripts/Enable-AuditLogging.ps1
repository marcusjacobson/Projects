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
    [Parameter(Mandatory = $false)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$AppId,

    [Parameter(Mandatory = $false)]
    [string]$CertificateThumbprint,

    [Parameter(Mandatory = $false)]
    [string]$Organization
)

# =============================================================================
# Step 0: Configuration Loading
# =============================================================================

# Try to load from global-config.json if parameters are missing
if (-not $TenantId -or -not $AppId -or -not $CertificateThumbprint) {
    $configPath = Join-Path $PSScriptRoot "..\..\templates\global-config.json"
    
    if (Test-Path $configPath) {
        Write-Host "   📂 Loading configuration from global-config.json..." -ForegroundColor Cyan
        $config = Get-Content $configPath | ConvertFrom-Json
        
        # 1. Resolve Tenant ID
        if (-not $TenantId -and $config.tenantId) {
            $TenantId = $config.tenantId
        }
        
        # 2. Resolve Certificate Thumbprint
        if (-not $CertificateThumbprint -and $config.servicePrincipal.certificateName) {
            $certName = $config.servicePrincipal.certificateName
            $cert = Get-ChildItem "Cert:\CurrentUser\My" | Where-Object { $_.Subject -eq "CN=$certName" } | Sort-Object NotAfter -Descending | Select-Object -First 1
            if ($cert) { $CertificateThumbprint = $cert.Thumbprint }
        }
        
        # 3. Resolve App ID
        if (-not $AppId -and $config.servicePrincipal.appId) {
            $AppId = $config.servicePrincipal.appId
        }
        elseif (-not $AppId) {
            $detailsPath = Join-Path $PSScriptRoot "..\..\scripts\ServicePrincipal-Details.txt"
            if (Test-Path $detailsPath) {
                $detailsContent = Get-Content $detailsPath
                foreach ($line in $detailsContent) {
                    if ($line -match "App ID:\s+([a-f0-9-]{36})") {
                        $AppId = $matches[1]
                        break
                    }
                }
            }
        }
    }
}

# 4. Resolve Organization (Domain) via Graph if missing
if (-not $Organization) {
    Write-Host "   🔍 Resolving Organization domain via Microsoft Graph..." -ForegroundColor Cyan
    $connectScript = Join-Path $PSScriptRoot "..\..\scripts\Connect-PurviewGraph.ps1"
    if (Test-Path $connectScript) {
        & $connectScript
        try {
            $domain = Get-MgDomain | Where-Object { $_.IsInitial } | Select-Object -ExpandProperty Id
            $Organization = $domain
            Write-Host "   ✅ Resolved Organization: $Organization" -ForegroundColor Cyan
        } catch {
            Write-Host "   ⚠️ Failed to resolve domain via Graph. Please provide -Organization parameter." -ForegroundColor Yellow
        }
    }
}

# Final Validation
if (-not $TenantId -or -not $AppId -or -not $CertificateThumbprint -or -not $Organization) {
    Write-Host "   ❌ Missing required connection details." -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 1: Connect to Exchange Online
# =============================================================================

Write-Host "🔌 Step 1: Connecting to Exchange Online" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

try {
    Write-Host "   🚀 Connecting (interactive authentication due to EXO 3.9.0 assembly bug)..." -ForegroundColor Cyan
    Connect-ExchangeOnline -ShowBanner:$false
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
        Write-Host "   ⏳ Enabling Unified Audit Log..." -ForegroundColor Cyan
        Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true -ErrorAction Stop
        Write-Host "   ✅ Unified Audit Log enable command completed." -ForegroundColor Green
        Write-Host "   ⚠️ Note: It may take up to 24 hours for events to appear." -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Failed to enable Audit Log: $_" -ForegroundColor Red
    throw
}

# =============================================================================
# Step 3: Verify Configuration
# =============================================================================

Write-Host "`n🔍 Step 3: Verifying Audit Log Configuration" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

try {
    # Wait a moment for the change to propagate
    Start-Sleep -Seconds 5
    
    $auditConfig = Get-AdminAuditLogConfig
    $auditStatus = $auditConfig.UnifiedAuditLogIngestionEnabled
    
    if ($auditStatus -eq $true) {
        Write-Host "   ✅ Verification successful: Auditing is ENABLED" -ForegroundColor Green
        Write-Host "   Status: UnifiedAuditLogIngestionEnabled = True" -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠️  WARNING: Auditing still shows as disabled (value: $auditStatus)" -ForegroundColor Yellow
        Write-Host "   Possible causes:" -ForegroundColor Yellow
        Write-Host "      • Insufficient permissions (requires Global Administrator)" -ForegroundColor Yellow
        Write-Host "      • Propagation delay between command execution and query (wait 5-10 minutes)" -ForegroundColor Yellow
        Write-Host "      • Exchange Online configuration restriction in your tenant" -ForegroundColor Yellow
        Write-Host "`n   💡 Next steps:" -ForegroundColor Cyan
        Write-Host "      1. Wait 5-10 minutes and run this script again" -ForegroundColor White
        Write-Host "      2. Verify with: Get-AdminAuditLogConfig | Format-List UnifiedAuditLogIngestionEnabled" -ForegroundColor White
        Write-Host "      3. If still disabled, contact your tenant administrator" -ForegroundColor White
    }
    
    # Display full configuration for diagnostic purposes
    Write-Host "`n📊 Current Audit Configuration:" -ForegroundColor Cyan
    $auditConfig | Format-List UnifiedAuditLogIngestionEnabled
    
} catch {
    Write-Host "   ❌ Failed to verify configuration: $_" -ForegroundColor Red
}

Write-Host "`n✅ Auditing enablement process complete" -ForegroundColor Green
Write-Host "⏳ Allow 2-24 hours for full audit data collection to activate" -ForegroundColor Yellow

# =============================================================================
# Step 4: Cleanup
# =============================================================================

Write-Host "`n🔌 Step 4: Disconnecting from Exchange Online" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

try {
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "   ✅ Disconnected from Exchange Online." -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Disconnect completed with warnings (this is normal)" -ForegroundColor Yellow
}

<#
.SYNOPSIS
    Connects to Microsoft Graph using a Service Principal with Certificate authentication.

.DESCRIPTION
    This script establishes a session with the Microsoft Graph PowerShell SDK using a Service Principal
    and a client certificate. It is designed to be used as a helper script for other automation tasks
    in the Purview Retail Data Protection Masterclass.

.PARAMETER TenantId
    The Directory (Tenant) ID of your Azure AD tenant.

.PARAMETER AppId
    The Application (Client) ID of your Service Principal.

.PARAMETER CertificateThumbprint
    The thumbprint of the client certificate installed in the current user's store.

.EXAMPLE
    .\Connect-PurviewGraph.ps1 -TenantId "00000000-0000-0000-0000-000000000000" -AppId "11111111-1111-1111-1111-111111111111" -CertificateThumbprint "ABC123DEF456..."

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2024-05-22
    Last Modified: 2024-05-22
    
    Copyright (c) 2024 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft.Graph module installed
    - Certificate installed in Cert:\CurrentUser\My\

    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$AppId,

    [Parameter(Mandatory = $false)]
    [string]$CertificateThumbprint
)

# =============================================================================
# Step 0: Configuration Loading
# =============================================================================

# Try to load from global-config.json if parameters are missing
if (-not $TenantId -or -not $AppId -or -not $CertificateThumbprint) {
    # Adjusted path for root/scripts location
    $configPath = Join-Path $PSScriptRoot "..\templates\global-config.json"
    
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
            # Find the most recent valid certificate with this subject
            $cert = Get-ChildItem "Cert:\CurrentUser\My" | Where-Object { $_.Subject -eq "CN=$certName" } | Sort-Object NotAfter -Descending | Select-Object -First 1
            
            if ($cert) {
                $CertificateThumbprint = $cert.Thumbprint
                Write-Host "   ✅ Found certificate '$certName' in user store." -ForegroundColor Cyan
            } else {
                Write-Host "   ⚠️ Certificate '$certName' not found in CurrentUser\My store." -ForegroundColor Yellow
            }
        }
        
        # 3. Resolve App ID
        # First check if it was manually added to config
        if (-not $AppId -and $config.servicePrincipal.appId) {
            $AppId = $config.servicePrincipal.appId
        }
        # Fallback: Try to read from the generated details file
        elseif (-not $AppId) {
            $detailsPath = Join-Path $PSScriptRoot "ServicePrincipal-Details.txt"
            if (Test-Path $detailsPath) {
                $detailsContent = Get-Content $detailsPath
                foreach ($line in $detailsContent) {
                    if ($line -match "App ID:\s+([a-f0-9-]{36})") {
                        $AppId = $matches[1]
                        Write-Host "   ✅ Found App ID in ServicePrincipal-Details.txt" -ForegroundColor Cyan
                        break
                    }
                }
            }
        }
    }
}

# Final Validation
if (-not $TenantId -or -not $AppId -or -not $CertificateThumbprint) {
    Write-Host "   ❌ Missing required connection details." -ForegroundColor Red
    Write-Host "   Please provide parameters manually or ensure Deploy-ServicePrincipal.ps1 has been run." -ForegroundColor Yellow
    Write-Host "   TenantId: $TenantId"
    Write-Host "   AppId: $AppId"
    Write-Host "   Thumbprint: $CertificateThumbprint"
    exit 1
}
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Check for Microsoft.Graph module
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "   ❌ Microsoft.Graph module not found. Installing..." -ForegroundColor Yellow
    Install-Module Microsoft.Graph -Scope CurrentUser -Force -AllowClobber
    Write-Host "   ✅ Microsoft.Graph module installed." -ForegroundColor Green
} else {
    Write-Host "   ✅ Microsoft.Graph module is already installed." -ForegroundColor Green
}

# =============================================================================
# Step 2: Authentication
# =============================================================================

Write-Host "🔐 Step 2: Authentication" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

try {
    Write-Host "   🚀 Connecting to Microsoft Graph..." -ForegroundColor Cyan
    Connect-MgGraph -ClientId $AppId -TenantId $TenantId -CertificateThumbprint $CertificateThumbprint -NoWelcome
    
    $context = Get-MgContext
    if ($context) {
        Write-Host "   ✅ Successfully connected to tenant: $($context.TenantId)" -ForegroundColor Green
        Write-Host "   ✅ Scopes: $($context.Scopes -join ', ')" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   ❌ Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    throw
}

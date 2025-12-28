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
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$AppId,

    [Parameter(Mandatory = $true)]
    [string]$CertificateThumbprint
)

# =============================================================================
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

<#
.SYNOPSIS
    Connects to SharePoint Online sites using PnP PowerShell for targeted discovery.

.DESCRIPTION
    This script establishes an authenticated connection to SharePoint Online using
    PnP PowerShell, enabling site-specific SIT discovery operations. It supports
    interactive browser-based authentication and validates site access permissions.

.PARAMETER SiteUrl
    The full URL of the SharePoint site to connect to.

.EXAMPLE
    .\Connect-PnPSites.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/Finance"
    
    Connects to the Finance site using interactive authentication.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-17
    Last Modified: 2025-11-17
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7.0+
    - PnP.PowerShell module installed
    - Site Collection Administrator access to target site
    - Internet connectivity for authentication
    
    Script development orchestrated using GitHub Copilot.
#>

#Requires -Version 7.0

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^https://[a-zA-Z0-9-]+\.sharepoint\.com/sites/[a-zA-Z0-9-]+$')]
    [string]$SiteUrl
)

# =============================================================================
# Script Initialization
# =============================================================================

Write-Host "🔗 PnP SharePoint Connection" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Verify PnP PowerShell Module
# =============================================================================

Write-Host "🔍 Step 1: Verify PnP PowerShell Module" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

try {
    $pnpModule = Get-Module PnP.PowerShell -ListAvailable | Select-Object -First 1
    
    if ($null -eq $pnpModule) {
        Write-Host "❌ PnP.PowerShell module not installed" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Install with: Install-Module PnP.PowerShell -Scope CurrentUser -Force" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "   ✅ PnP.PowerShell version $($pnpModule.Version) detected" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to verify PnP.PowerShell module: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 2: Disconnect Existing PnP Session
# =============================================================================

Write-Host "🔌 Step 2: Check Existing PnP Connection" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

try {
    $existingConnection = Get-PnPConnection -ErrorAction SilentlyContinue
    
    if ($null -ne $existingConnection) {
        Write-Host "   ⚠️ Existing PnP connection detected" -ForegroundColor Yellow
        Write-Host "      • Current site: $($existingConnection.Url)" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "   🔌 Disconnecting existing session..." -ForegroundColor Cyan
        
        Disconnect-PnPOnline
        
        Write-Host "   ✅ Disconnected from previous session" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️ No existing PnP connection" -ForegroundColor Cyan
    }
} catch {
    # Ignore errors if no connection exists
    Write-Host "   ℹ️ No active PnP connection to disconnect" -ForegroundColor Cyan
}

Write-Host ""

# =============================================================================
# Step 3: Connect to SharePoint Site
# =============================================================================

Write-Host "🔗 Step 3: Connect to SharePoint Site" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

Write-Host "   📌 Target site: $SiteUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "   ⏳ Initiating interactive authentication..." -ForegroundColor Cyan
Write-Host "   📱 Browser window will open for sign-in" -ForegroundColor Cyan
Write-Host ""

try {
    # Connect using interactive browser-based authentication
    Connect-PnPOnline -Url $SiteUrl -Interactive -ErrorAction Stop
    
    Write-Host "   ✅ Successfully connected to SharePoint site" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Failed to connect to SharePoint site: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "      • Verify the site URL is correct" -ForegroundColor DarkGray
    Write-Host "      • Ensure you have Site Collection Administrator access" -ForegroundColor DarkGray
    Write-Host "      • Check your MFA is configured and working" -ForegroundColor DarkGray
    Write-Host "      • Verify no Conditional Access policies are blocking the connection" -ForegroundColor DarkGray
    exit 1
}

Write-Host ""

# =============================================================================
# Step 4: Verify Connection and Permissions
# =============================================================================

Write-Host "✅ Step 4: Verify Connection and Permissions" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

try {
    # Get connection details
    $connection = Get-PnPConnection
    
    Write-Host "   📊 Connection Details:" -ForegroundColor Cyan
    Write-Host "      • Site URL: $($connection.Url)" -ForegroundColor DarkGray
    Write-Host "      • Connection Type: $($connection.ConnectionType)" -ForegroundColor DarkGray
    Write-Host "      • Tenant: $($connection.Tenant)" -ForegroundColor DarkGray
    Write-Host ""
    
    # Verify site access by querying site properties
    $site = Get-PnPSite -ErrorAction Stop
    
    Write-Host "   📌 Site Information:" -ForegroundColor Cyan
    Write-Host "      • Site ID: $($site.Id)" -ForegroundColor DarkGray
    Write-Host "      • Site URL: $($site.Url)" -ForegroundColor DarkGray
    Write-Host ""
    
    # Check current user permissions
    $web = Get-PnPWeb -ErrorAction Stop
    
    Write-Host "   👤 Site Details:" -ForegroundColor Cyan
    Write-Host "      • Title: $($web.Title)" -ForegroundColor DarkGray
    Write-Host "      • Description: $($web.Description)" -ForegroundColor DarkGray
    Write-Host "      • Last Modified: $($web.LastItemModifiedDate)" -ForegroundColor DarkGray
    Write-Host ""
    
    Write-Host "✅ Connection verified and site accessible" -ForegroundColor Green
    
} catch {
    Write-Host "   ⚠️ Connection established but site access limited: $_" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   💡 You may have connection but insufficient permissions" -ForegroundColor Yellow
    Write-Host "      Ensure you have at least Site Collection Administrator role" -ForegroundColor DarkGray
}

Write-Host ""

# =============================================================================
# Step 5: Connection Summary and Next Steps
# =============================================================================

Write-Host "🎯 Connection Summary" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ PnP connection established successfully" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Enumerate document libraries: .\Get-SiteLibraries.ps1 -SiteUrl '$SiteUrl'" -ForegroundColor DarkGray
Write-Host "   2. Run SIT discovery: .\Search-SharePointSITs.ps1 -SiteUrl '$SiteUrl' -Library 'Documents'" -ForegroundColor DarkGray
Write-Host "   3. When finished, disconnect: Disconnect-PnPOnline" -ForegroundColor DarkGray
Write-Host ""
Write-Host "⚠️ Note: This connection will remain active for subsequent PnP cmdlets" -ForegroundColor Yellow
Write-Host "         Use Get-PnPConnection to verify current connection status" -ForegroundColor Yellow
Write-Host ""

exit 0

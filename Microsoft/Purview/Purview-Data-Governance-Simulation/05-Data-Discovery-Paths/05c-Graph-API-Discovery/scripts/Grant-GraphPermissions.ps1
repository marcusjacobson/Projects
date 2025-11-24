<#
.SYNOPSIS
    Grants Microsoft Graph API permissions for automated sensitive data discovery.

.DESCRIPTION
    This script configures the necessary Microsoft Graph API permissions to enable
    automated discovery of classified content across SharePoint Online using the
    Microsoft Graph eDiscovery APIs. It grants delegated permissions for eDiscovery
    operations, establishing the authentication foundation for Lab 05c automation.

.EXAMPLE
    .\Grant-GraphPermissions.ps1
    
    Grants Graph API permissions interactively with admin consent.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-17
    Last Modified: 2025-11-17
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7.0+
    - Microsoft.Graph PowerShell SDK
    - Azure AD Global Administrator or Application Administrator role
    - Internet connectivity for authentication
    
    Script development orchestrated using GitHub Copilot.

.PERMISSIONS GRANTED
    - eDiscovery.Read.All (Delegated): Read eDiscovery cases and searches
    - eDiscovery.ReadWrite.All (Delegated): Create and manage eDiscovery cases and searches for SIT discovery
    - Sites.Read.All (Delegated): Read SharePoint site information for targeted data discovery
#>

#Requires -Version 7.0

# =============================================================================
# Script Initialization
# =============================================================================

Write-Host "🔐 Microsoft Graph API Permission Grant" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Verify Microsoft Graph SDK Installation
# =============================================================================

Write-Host "🔍 Step 1: Verify Microsoft Graph SDK Installation" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
Write-Host ""

try {
    $graphModule = Get-Module Microsoft.Graph -ListAvailable | Select-Object -First 1
    
    if ($null -eq $graphModule) {
        Write-Host "❌ Microsoft Graph SDK not installed" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Install with: Install-Module Microsoft.Graph -Scope CurrentUser -Force" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "   ✅ Microsoft Graph SDK version $($graphModule.Version) detected" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to verify Microsoft Graph SDK: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 2: Define Required Permissions
# =============================================================================

Write-Host "📋 Step 2: Define Required Permissions" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

$requiredScopes = @(
    "eDiscovery.Read.All",
    "eDiscovery.ReadWrite.All",
    "Sites.Read.All"
)

Write-Host "   📌 Permissions to be granted:" -ForegroundColor Cyan
foreach ($scope in $requiredScopes) {
    Write-Host "      • $scope" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "   💡 eDiscovery permissions: Create and manage eDiscovery cases/searches" -ForegroundColor Yellow
Write-Host "   💡 Sites.Read.All: Query SharePoint sites for targeted data discovery" -ForegroundColor Yellow
Write-Host ""

# =============================================================================
# Step 3: Connect to Microsoft Graph with Admin Consent
# =============================================================================

Write-Host "🔗 Step 3: Connect to Microsoft Graph with Admin Consent" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host ""

Write-Host "   ⏳ Initiating interactive authentication..." -ForegroundColor Cyan
Write-Host "   📱 Browser window will open for admin sign-in and consent" -ForegroundColor Cyan
Write-Host ""

try {
    # Connect with required scopes and request admin consent
    Connect-MgGraph -Scopes $requiredScopes -UseDeviceCode:$false
    
    Write-Host "   ✅ Successfully connected to Microsoft Graph" -ForegroundColor Green
    
    # Verify connection context
    $context = Get-MgContext
    
    if ($null -eq $context) {
        throw "Connection established but context is null"
    }
    
    Write-Host ""
    Write-Host "   📊 Connection Details:" -ForegroundColor Cyan
    Write-Host "      • Tenant ID: $($context.TenantId)" -ForegroundColor DarkGray
    Write-Host "      • Account: $($context.Account)" -ForegroundColor DarkGray
    Write-Host "      • Scopes: $($context.Scopes -join ', ')" -ForegroundColor DarkGray
    
} catch {
    Write-Host "   ❌ Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "      • Ensure you're using a Global Administrator or Application Administrator account" -ForegroundColor DarkGray
    Write-Host "      • Check that MFA is configured and functional" -ForegroundColor DarkGray
    Write-Host "      • Verify network connectivity to login.microsoftonline.com" -ForegroundColor DarkGray
    exit 1
}

Write-Host ""

# =============================================================================
# Step 4: Verify Granted Permissions
# =============================================================================

Write-Host "✅ Step 4: Verify Granted Permissions" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

try {
    $grantedScopes = (Get-MgContext).Scopes
    
    Write-Host "   📊 Permissions Status:" -ForegroundColor Cyan
    
    $allGranted = $true
    foreach ($scope in $requiredScopes) {
        if ($grantedScopes -contains $scope) {
            Write-Host "      ✅ $scope - GRANTED" -ForegroundColor Green
        } else {
            Write-Host "      ❌ $scope - NOT GRANTED" -ForegroundColor Red
            $allGranted = $false
        }
    }
    
    Write-Host ""
    
    if ($allGranted) {
        Write-Host "🎉 All required eDiscovery permissions granted successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Next Steps:" -ForegroundColor Cyan
        Write-Host "   1. Run Test-GraphConnectivity.ps1 to verify eDiscovery API access" -ForegroundColor DarkGray
        Write-Host "   2. Execute Search-GraphSITs.ps1 to perform tenant-wide SIT discovery" -ForegroundColor DarkGray
        Write-Host ""
    } else {
        Write-Host "⚠️ Some permissions were not granted" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "💡 This may be due to:" -ForegroundColor Yellow
        Write-Host "   • Admin consent was declined" -ForegroundColor DarkGray
        Write-Host "   • Insufficient admin privileges" -ForegroundColor DarkGray
        Write-Host "   • Conditional Access policies blocking consent" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "   Try running this script again or consult your Azure AD administrator" -ForegroundColor DarkGray
        exit 1
    }
    
} catch {
    Write-Host "   ❌ Failed to verify permissions: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Script Completion
# =============================================================================

Write-Host "✅ Permission grant completed successfully" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️ Note: You can disconnect from Graph if desired with: Disconnect-MgGraph" -ForegroundColor Yellow
Write-Host "         However, the connection will be used by subsequent Lab 05c scripts" -ForegroundColor Yellow
Write-Host ""

exit 0

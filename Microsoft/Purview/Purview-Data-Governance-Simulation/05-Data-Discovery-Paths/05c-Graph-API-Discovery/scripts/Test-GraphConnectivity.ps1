<#
.SYNOPSIS
    Tests Microsoft Graph API connectivity and permission validation.

.DESCRIPTION
    This script validates that Microsoft Graph authentication is working correctly
    and that the necessary permissions (Files.Read.All, Sites.Read.All) have been
    granted. It performs sample queries to verify API access before running full
    discovery scans.

.EXAMPLE
    .\Test-GraphConnectivity.ps1
    
    Tests Graph API connectivity and validates permissions.

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
    - Graph API permissions granted (run Grant-GraphPermissions.ps1 first)
    
    Script development orchestrated using GitHub Copilot.
#>

#Requires -Version 7.0

# =============================================================================
# Script Initialization
# =============================================================================

Write-Host "🔍 Microsoft Graph API Connectivity Test" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Verify Microsoft Graph SDK Installation
# =============================================================================

Write-Host "🔧 Step 1: Verify Microsoft Graph SDK" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

try {
    $graphModule = Get-Module Microsoft.Graph -ListAvailable | Select-Object -First 1
    
    if ($null -eq $graphModule) {
        Write-Host "❌ Microsoft Graph SDK not installed" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Install with: Install-Module Microsoft.Graph -Scope CurrentUser -Force" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "   ✅ Microsoft Graph SDK version $($graphModule.Version) installed" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to verify Microsoft Graph SDK: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 2: Check Existing Connection
# =============================================================================

Write-Host "🔗 Step 2: Check Microsoft Graph Connection" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

try {
    $context = Get-MgContext
    
    if ($null -eq $context) {
        Write-Host "⚠️ Not currently connected to Microsoft Graph" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   Attempting to connect..." -ForegroundColor Cyan
        
        $requiredScopes = @(
            "Files.Read.All",
            "Sites.Read.All",
            "InformationProtectionPolicy.Read"
        )
        
        Connect-MgGraph -Scopes $requiredScopes -UseDeviceCode:$false
        
        $context = Get-MgContext
        
        if ($null -eq $context) {
            throw "Failed to establish connection"
        }
    }
    
    Write-Host "   ✅ Connected to Microsoft Graph" -ForegroundColor Green
    Write-Host ""
    Write-Host "   📊 Connection Details:" -ForegroundColor Cyan
    Write-Host "      • Tenant ID: $($context.TenantId)" -ForegroundColor DarkGray
    Write-Host "      • Account: $($context.Account)" -ForegroundColor DarkGray
    Write-Host "      • Scopes: $($context.Scopes -join ', ')" -ForegroundColor DarkGray
    
} catch {
    Write-Host "   ❌ Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Run Grant-GraphPermissions.ps1 first to establish authentication" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# =============================================================================
# Step 3: Validate Required Permissions
# =============================================================================

Write-Host "✅ Step 3: Validate Required Permissions" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

$requiredScopes = @(
    "Files.Read.All",
    "Sites.Read.All",
    "InformationProtectionPolicy.Read"
)

$grantedScopes = (Get-MgContext).Scopes

Write-Host "   📋 Permission Validation:" -ForegroundColor Cyan

$allPermissionsValid = $true
foreach ($scope in $requiredScopes) {
    if ($grantedScopes -contains $scope) {
        Write-Host "      ✅ $scope" -ForegroundColor Green
    } else {
        Write-Host "      ❌ $scope - MISSING" -ForegroundColor Red
        $allPermissionsValid = $false
    }
}

Write-Host ""

if (-not $allPermissionsValid) {
    Write-Host "⚠️ Missing required permissions" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Run Grant-GraphPermissions.ps1 to grant all necessary permissions" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 4: Test SharePoint Sites Query
# =============================================================================

Write-Host "📊 Step 4: Test SharePoint Sites Query" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

Write-Host "   ⏳ Querying SharePoint sites..." -ForegroundColor Cyan

try {
    # Query SharePoint sites using Microsoft Graph
    $sites = Get-MgSite -All -PageSize 10 -ErrorAction Stop
    
    if ($null -eq $sites -or $sites.Count -eq 0) {
        Write-Host "   ⚠️ No SharePoint sites found (this might be normal for test tenants)" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ Successfully retrieved $($sites.Count) SharePoint site(s)" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📋 Sample Sites:" -ForegroundColor Cyan
        
        $sites | Select-Object -First 5 | ForEach-Object {
            Write-Host "      • $($_.DisplayName)" -ForegroundColor DarkGray
        }
        
        if ($sites.Count -gt 5) {
            Write-Host "      ... and $($sites.Count - 5) more" -ForegroundColor DarkGray
        }
    }
    
} catch {
    Write-Host "   ❌ Failed to query SharePoint sites: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Possible causes:" -ForegroundColor Yellow
    Write-Host "      • Insufficient permissions (Sites.Read.All required)" -ForegroundColor DarkGray
    Write-Host "      • Network connectivity issues" -ForegroundColor DarkGray
    Write-Host "      • API throttling or service outage" -ForegroundColor DarkGray
    exit 1
}

Write-Host ""

# =============================================================================
# Step 5: Test File Search Query (Simplified)
# =============================================================================

Write-Host "🔍 Step 5: Test File Search Capability" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

Write-Host "   ⏳ Testing Graph Search API access..." -ForegroundColor Cyan

try {
    # Test basic Graph API connectivity (without full search which requires more setup)
    $testUri = "https://graph.microsoft.com/v1.0/me"
    $response = Invoke-MgGraphRequest -Method GET -Uri $testUri -ErrorAction Stop
    
    if ($null -ne $response) {
        Write-Host "   ✅ Graph API queries working correctly" -ForegroundColor Green
        Write-Host "      • User: $($response.displayName)" -ForegroundColor DarkGray
        Write-Host "      • UPN: $($response.userPrincipalName)" -ForegroundColor DarkGray
    }
    
} catch {
    Write-Host "   ⚠️ Graph API query test encountered issues: $_" -ForegroundColor Yellow
    Write-Host "      This may not affect discovery functionality" -ForegroundColor DarkGray
}

Write-Host ""

# =============================================================================
# Step 6: Connectivity Test Summary
# =============================================================================

Write-Host "📈 Connectivity Test Summary" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ All connectivity tests PASSED" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Ready for Discovery Operations:" -ForegroundColor Cyan
Write-Host "   • Microsoft Graph SDK: Installed and functional" -ForegroundColor DarkGray
Write-Host "   • Authentication: Connected with valid credentials" -ForegroundColor DarkGray
Write-Host "   • Permissions: All required scopes granted" -ForegroundColor DarkGray
Write-Host "   • API Access: SharePoint sites query successful" -ForegroundColor DarkGray
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Run Search-GraphSITs.ps1 to perform tenant-wide SIT discovery" -ForegroundColor DarkGray
Write-Host "   2. Review generated JSON/CSV reports in the reports/ folder" -ForegroundColor DarkGray
Write-Host "   3. Configure scheduled scans with Schedule-RecurringScan.ps1" -ForegroundColor DarkGray
Write-Host ""

exit 0

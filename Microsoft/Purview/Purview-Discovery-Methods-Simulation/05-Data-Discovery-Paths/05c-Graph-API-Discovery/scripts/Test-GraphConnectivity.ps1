<#
.SYNOPSIS
    Tests Microsoft Graph API connectivity and permission validation.

.DESCRIPTION
    This script validates that Microsoft Graph authentication is working correctly
    and that the necessary eDiscovery permissions (eDiscovery.Read.All, 
    eDiscovery.ReadWrite.All) have been granted. It performs a test eDiscovery
    case creation and deletion to verify API access before running full discovery scans.

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

.GRAPH API OPERATIONS
    - Validates Microsoft Graph authentication
    - Verifies eDiscovery permission scopes
    - Performs test case creation and deletion to confirm API access
#>

#Requires -Version 7.0

# =============================================================================
# Script Initialization
# =============================================================================

Write-Host "🔍 Microsoft Graph API Connectivity Test" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Load global configuration
$globalConfigPath = Join-Path $PSScriptRoot "..\..\..\global-config.json"

if (-not (Test-Path $globalConfigPath)) {
    Write-Host "❌ Global configuration file not found: $globalConfigPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Ensure global-config.json exists in the repository root" -ForegroundColor Yellow
    exit 1
}

try {
    $globalConfig = Get-Content $globalConfigPath -Raw | ConvertFrom-Json
    Write-Host "✅ Loaded global configuration from: $globalConfigPath" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Failed to load global configuration: $_" -ForegroundColor Red
    exit 1
}

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
            "eDiscovery.Read.All",
            "eDiscovery.ReadWrite.All"
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
    "eDiscovery.Read.All",
    "eDiscovery.ReadWrite.All"
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
# Step 4: Test eDiscovery Case Creation
# =============================================================================

Write-Host "🔬 Step 4: Test eDiscovery Case Creation" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "   ⏳ Creating temporary eDiscovery case..." -ForegroundColor Cyan

try {
    # Create test eDiscovery case to validate permissions
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $testCaseName = "Connectivity-Test-$timestamp"
    
    $testCase = New-MgSecurityCaseEdiscoveryCase `
        -DisplayName $testCaseName `
        -Description "Automated connectivity test - safe to delete" `
        -ErrorAction Stop
    
    if ($null -eq $testCase -or $null -eq $testCase.Id) {
        throw "Case creation returned null or invalid response"
    }
    
    Write-Host "   ✅ Successfully created test eDiscovery case" -ForegroundColor Green
    Write-Host "      • Case ID: $($testCase.Id)" -ForegroundColor DarkGray
    Write-Host "      • Case Name: $testCaseName" -ForegroundColor DarkGray
    Write-Host ""
    
    # Clean up test case
    Write-Host "   ⏳ Cleaning up test case..." -ForegroundColor Cyan
    
    Remove-MgSecurityCaseEdiscoveryCase -EdiscoveryCaseId $testCase.Id -Confirm:$false -ErrorAction Stop
    
    Write-Host "   ✅ Test case deleted successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "   🎯 eDiscovery API access validated:" -ForegroundColor Cyan
    Write-Host "      • Case creation: Working" -ForegroundColor DarkGray
    Write-Host "      • Case deletion: Working" -ForegroundColor DarkGray
    Write-Host "      • Permissions: Correctly configured" -ForegroundColor DarkGray
    
} catch {
    Write-Host "   ❌ Failed to create/delete eDiscovery case: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Possible causes:" -ForegroundColor Yellow
    Write-Host "      • Insufficient permissions (eDiscovery.ReadWrite.All required)" -ForegroundColor DarkGray
    Write-Host "      • Permission consent not completed (check Azure AD admin consent)" -ForegroundColor DarkGray
    Write-Host "      • Network connectivity issues" -ForegroundColor DarkGray
    Write-Host "      • API throttling or service outage" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   Run Grant-GraphPermissions.ps1 to ensure eDiscovery permissions are granted" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# =============================================================================
# Step 5: Connectivity Test Summary
# =============================================================================

Write-Host "📈 Connectivity Test Summary" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ All connectivity tests PASSED" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Ready for eDiscovery Operations:" -ForegroundColor Cyan
Write-Host "   • Microsoft Graph SDK: Installed and functional" -ForegroundColor DarkGray
Write-Host "   • Authentication: Connected with valid credentials" -ForegroundColor DarkGray
Write-Host "   • Permissions: All required eDiscovery scopes granted" -ForegroundColor DarkGray
Write-Host "   • API Access: eDiscovery case creation successful" -ForegroundColor DarkGray
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Run Search-GraphSITs.ps1 to perform tenant-wide SIT discovery" -ForegroundColor DarkGray
Write-Host "   2. Review generated JSON/CSV reports in the reports/ folder" -ForegroundColor DarkGray
Write-Host "   3. Configure scheduled scans with Schedule-RecurringScan.ps1" -ForegroundColor DarkGray
Write-Host ""

exit 0

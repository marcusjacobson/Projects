<#
.SYNOPSIS
    Tests and validates active connections to SharePoint Online and Security & Compliance PowerShell.

.DESCRIPTION
    This utility script provides comprehensive connection health checks for both SharePoint Online
    and Security & Compliance PowerShell services. It validates that active sessions exist,
    verifies connection status, tests basic operations, and reports connection health.
    
    The script is designed to be called before performing operations that require service
    connectivity, enabling early detection of authentication or connectivity issues. It can
    validate individual services or both simultaneously, and supports detailed reporting.
    
    Connection checks performed:
    - SharePoint Online: Verifies PnP connection exists, validates tenant URL, tests basic cmdlet
    - Security & Compliance: Verifies PowerShell session exists, validates connection state
    - Optional: Tests actual service operations (list sites, get compliance rules)
    
    Features:
    - Individual service validation or comprehensive health check
    - Connection state verification (connected, disconnected, expired)
    - Tenant URL validation for SharePoint connections
    - Optional operational testing for deep validation
    - Detailed error reporting and troubleshooting guidance

.PARAMETER TenantUrl
    The expected SharePoint tenant URL for connection validation. Used to verify that the
    active connection is for the correct tenant.

.PARAMETER TestSharePoint
    When specified, tests SharePoint Online connection only.

.PARAMETER TestCompliance
    When specified, tests Security & Compliance PowerShell connection only.

.PARAMETER TestOperations
    When specified, performs actual service operations to validate functional connectivity
    beyond just session existence checks.

.PARAMETER Config
    The configuration object containing environment settings. Used for logging and optional
    automatic tenant URL detection.

.EXAMPLE
    $config = & "$PSScriptRoot\..\Shared-Utilities\Import-GlobalConfig.ps1"
    & "$PSScriptRoot\..\Shared-Utilities\Test-ServiceConnection.ps1" -TenantUrl $config.Environment.TenantUrl -Config $config
    
    Tests both SharePoint and Security & Compliance connections.

.EXAMPLE
    Test-ServiceConnection -TenantUrl "https://contoso.sharepoint.com" -TestSharePoint
    
    Tests only SharePoint Online connection.

.EXAMPLE
    Test-ServiceConnection -TenantUrl "https://contoso.sharepoint.com" -TestOperations
    
    Tests connections with operational validation.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - PnP.PowerShell module v2.0+ (for SharePoint testing)
    - ExchangeOnlineManagement module v3.0+ (for Security & Compliance testing)
    - Active connections to services being tested
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Tests and validates service connections for SharePoint and Security & Compliance.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TenantUrl,
    
    [Parameter(Mandatory = $false)]
    [switch]$TestSharePoint,
    
    [Parameter(Mandatory = $false)]
    [switch]$TestCompliance,
    
    [Parameter(Mandatory = $false)]
    [switch]$TestOperations,
    
    [Parameter(Mandatory = $false)]
    [PSCustomObject]$Config
)

# =============================================================================
# Step 1: Initialize Connection Testing
# =============================================================================

Write-Host "🔍 Step 1: Initialize Connection Testing" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

$testResults = @{
    SharePointConnected      = $false
    SharePointTenantMatch    = $false
    SharePointOperational    = $false
    ComplianceConnected      = $false
    ComplianceSessionState   = $null
    ComplianceOperational    = $false
    OverallStatus            = $false
}

# Determine which services to test (default: both)
$testBothServices = (-not $TestSharePoint -and -not $TestCompliance)

Write-Host "   📋 Testing SharePoint Online: $($testBothServices -or $TestSharePoint)" -ForegroundColor Cyan
Write-Host "   📋 Testing Security & Compliance: $($testBothServices -or $TestCompliance)" -ForegroundColor Cyan
Write-Host "   📋 Operational testing: $TestOperations" -ForegroundColor Cyan

# =============================================================================
# Step 2: Test SharePoint Online Connection
# =============================================================================

if ($testBothServices -or $TestSharePoint) {
    Write-Host ""
    Write-Host "🔍 Step 2: Test SharePoint Online Connection" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    
    try {
        # Check if PnP connection exists
        $pnpConnection = Get-PnPConnection -ErrorAction SilentlyContinue
        
        if ($null -eq $pnpConnection) {
            Write-Host "   ❌ No active SharePoint connection found" -ForegroundColor Red
            Write-Host "   💡 Run Connect-PurviewServices.ps1 to establish connection" -ForegroundColor Yellow
            $testResults.SharePointConnected = $false
        } else {
            Write-Host "   ✅ Active SharePoint connection found" -ForegroundColor Green
            $testResults.SharePointConnected = $true
            
            # Validate tenant URL matches
            if ($pnpConnection.Url -eq $TenantUrl) {
                Write-Host "   ✅ Tenant URL matches expected: $TenantUrl" -ForegroundColor Green
                $testResults.SharePointTenantMatch = $true
            } else {
                Write-Host "   ⚠️  Tenant URL mismatch!" -ForegroundColor Yellow
                Write-Host "      Expected: $TenantUrl" -ForegroundColor Yellow
                Write-Host "      Actual:   $($pnpConnection.Url)" -ForegroundColor Yellow
                $testResults.SharePointTenantMatch = $false
            }
            
            # Test operational connectivity if requested
            if ($TestOperations) {
                Write-Host "   📋 Testing SharePoint operational connectivity..." -ForegroundColor Cyan
                try {
                    $testWeb = Get-PnPWeb -ErrorAction Stop
                    Write-Host "   ✅ SharePoint operational test passed" -ForegroundColor Green
                    Write-Host "      Web Title: $($testWeb.Title)" -ForegroundColor Cyan
                    $testResults.SharePointOperational = $true
                } catch {
                    Write-Host "   ❌ SharePoint operational test failed: $_" -ForegroundColor Red
                    $testResults.SharePointOperational = $false
                }
            } else {
                # Assume operational if connected (not tested)
                $testResults.SharePointOperational = $true
            }
        }
    } catch {
        Write-Host "   ❌ SharePoint connection test failed: $_" -ForegroundColor Red
        $testResults.SharePointConnected = $false
    }
}

# =============================================================================
# Step 3: Test Security & Compliance PowerShell Connection
# =============================================================================

if ($testBothServices -or $TestCompliance) {
    Write-Host ""
    Write-Host "🔍 Step 3: Test Security & Compliance PowerShell Connection" -ForegroundColor Green
    Write-Host "===========================================================" -ForegroundColor Green
    
    try {
        # Check for active Security & Compliance session
        $complianceSession = Get-PSSession | Where-Object { 
            $_.ComputerName -like "*compliance.protection.outlook.com*" -and 
            $_.State -eq "Opened" 
        } | Select-Object -First 1
        
        if ($null -eq $complianceSession) {
            Write-Host "   ❌ No active Security & Compliance PowerShell session found" -ForegroundColor Red
            Write-Host "   💡 Run Connect-PurviewServices.ps1 to establish connection" -ForegroundColor Yellow
            $testResults.ComplianceConnected = $false
        } else {
            Write-Host "   ✅ Active Security & Compliance PowerShell session found" -ForegroundColor Green
            Write-Host "      Session ID: $($complianceSession.Id)" -ForegroundColor Cyan
            Write-Host "      State: $($complianceSession.State)" -ForegroundColor Cyan
            $testResults.ComplianceConnected = $true
            $testResults.ComplianceSessionState = $complianceSession.State
            
            # Test operational connectivity if requested
            if ($TestOperations) {
                Write-Host "   📋 Testing Security & Compliance operational connectivity..." -ForegroundColor Cyan
                try {
                    # Test by retrieving compliance organization config (low-impact query)
                    $orgConfig = Get-OrganizationConfig -ErrorAction Stop
                    Write-Host "   ✅ Security & Compliance operational test passed" -ForegroundColor Green
                    Write-Host "      Organization: $($orgConfig.DisplayName)" -ForegroundColor Cyan
                    $testResults.ComplianceOperational = $true
                } catch {
                    Write-Host "   ❌ Security & Compliance operational test failed: $_" -ForegroundColor Red
                    $testResults.ComplianceOperational = $false
                }
            } else {
                # Assume operational if session is Opened (not tested)
                $testResults.ComplianceOperational = $true
            }
        }
    } catch {
        Write-Host "   ❌ Security & Compliance connection test failed: $_" -ForegroundColor Red
        $testResults.ComplianceConnected = $false
    }
}

# =============================================================================
# Step 4: Overall Connection Status Assessment
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 4: Overall Connection Status Assessment" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

# Determine overall status based on which services were tested
if ($testBothServices) {
    # Both services must be connected and operational
    $testResults.OverallStatus = (
        $testResults.SharePointConnected -and 
        $testResults.SharePointTenantMatch -and 
        $testResults.SharePointOperational -and 
        $testResults.ComplianceConnected -and 
        $testResults.ComplianceOperational
    )
} elseif ($TestSharePoint) {
    # Only SharePoint must be connected and operational
    $testResults.OverallStatus = (
        $testResults.SharePointConnected -and 
        $testResults.SharePointTenantMatch -and 
        $testResults.SharePointOperational
    )
} elseif ($TestCompliance) {
    # Only Security & Compliance must be connected and operational
    $testResults.OverallStatus = (
        $testResults.ComplianceConnected -and 
        $testResults.ComplianceOperational
    )
}

if ($testResults.OverallStatus) {
    Write-Host "   ✅ All tested connections are healthy and operational" -ForegroundColor Green
} else {
    Write-Host "   ❌ One or more connection tests failed" -ForegroundColor Red
    Write-Host "   💡 Review test results above and reconnect as needed" -ForegroundColor Yellow
}

# =============================================================================
# Step 5: Connection Test Summary
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 5: Connection Test Summary" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

if ($testBothServices -or $TestSharePoint) {
    Write-Host "   📊 SharePoint Online:" -ForegroundColor Cyan
    Write-Host "      Connected: $($testResults.SharePointConnected)" -ForegroundColor Cyan
    Write-Host "      Tenant Match: $($testResults.SharePointTenantMatch)" -ForegroundColor Cyan
    Write-Host "      Operational: $($testResults.SharePointOperational)" -ForegroundColor Cyan
}

if ($testBothServices -or $TestCompliance) {
    Write-Host "   📊 Security & Compliance:" -ForegroundColor Cyan
    Write-Host "      Connected: $($testResults.ComplianceConnected)" -ForegroundColor Cyan
    Write-Host "      Session State: $($testResults.ComplianceSessionState)" -ForegroundColor Cyan
    Write-Host "      Operational: $($testResults.ComplianceOperational)" -ForegroundColor Cyan
}

Write-Host "   📊 Overall Status: $($testResults.OverallStatus)" -ForegroundColor Cyan

# =============================================================================
# Step 6: Return Test Results
# =============================================================================

if ($testResults.OverallStatus) {
    Write-Host ""
    Write-Host "✅ Connection testing completed - all connections healthy" -ForegroundColor Green
    return $testResults
} else {
    Write-Host ""
    Write-Host "❌ Connection testing completed - issues detected" -ForegroundColor Red
    throw "Service connection validation failed. Review test results and reconnect as needed."
}

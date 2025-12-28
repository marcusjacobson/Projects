<#
.SYNOPSIS
    Validates environment prerequisites for Purview Discovery Methods Simulation.

.DESCRIPTION
    This script performs comprehensive validation of the local environment to ensure all
    requirements are met before beginning the Purview Discovery Methods Simulation project.
    It checks PowerShell module availability and versions, validates service connectivity,
    confirms administrative permissions, and verifies disk space availability.
    
    The script provides detailed feedback for each validation check and offers remediation
    guidance for any issues detected. It is designed to catch environment issues early
    before attempting resource deployment or data generation operations.
    
    Validation categories:
    - PowerShell module installation and version requirements
    - Service connectivity to SharePoint Online and Security & Compliance
    - Administrative role assignments and permissions
    - Disk space availability for document generation
    - PowerShell version and execution policy
    - Internet connectivity to Microsoft 365 services

.PARAMETER GlobalConfigPath
    Optional path to the global configuration file. If not specified, uses default location.

.PARAMETER SkipConnectivityTests
    When specified, skips actual service connection tests. Useful for validating environment
    without authenticating to Microsoft 365 services.

.PARAMETER DetailedReport
    When specified, generates a detailed validation report with additional diagnostic information.

.EXAMPLE
    .\Test-Prerequisites.ps1
    
    Performs standard prerequisites validation with default configuration.

.EXAMPLE
    .\Test-Prerequisites.ps1 -DetailedReport
    
    Performs validation with detailed diagnostic reporting.

.EXAMPLE
    .\Test-Prerequisites.ps1 -SkipConnectivityTests
    
    Validates local environment without testing service connectivity.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Internet connectivity for Microsoft 365 services
    - Valid global-config.json configuration file
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Validates environment prerequisites for simulation execution.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipConnectivityTests,
    
    [Parameter(Mandatory = $false)]
    [switch]$DetailedReport
)

# =============================================================================
# Step 1: Validate PowerShell Version
# =============================================================================

Write-Host "🔍 Step 1: Validate PowerShell Version" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

$psVersion = $PSVersionTable.PSVersion
Write-Host "   📋 PowerShell Version: $($psVersion.ToString())" -ForegroundColor Cyan

if ($psVersion.Major -ge 7) {
    Write-Host "   ✅ PowerShell 7+ detected (optimal performance)" -ForegroundColor Green
} elseif ($psVersion.Major -eq 5 -and $psVersion.Minor -ge 1) {
    Write-Host "   ✅ PowerShell 5.1 detected (minimum requirement met)" -ForegroundColor Green
} else {
    Write-Host "   ❌ PowerShell version too old: $($psVersion.ToString())" -ForegroundColor Red
    Write-Host "   💡 Please upgrade to PowerShell 5.1+ or PowerShell 7+" -ForegroundColor Yellow
    throw "Insufficient PowerShell version. Minimum requirement: PowerShell 5.1"
}

if ($DetailedReport) {
    Write-Host "   📊 PowerShell Edition: $($PSVersionTable.PSEdition)" -ForegroundColor Cyan
    Write-Host "   📊 OS: $($PSVersionTable.OS)" -ForegroundColor Cyan
}

# =============================================================================
# Step 2: Validate Required PowerShell Modules
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Validate Required PowerShell Modules" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

$validationErrors = @()

# Check PnP.PowerShell module
Write-Host "   📋 Checking PnP.PowerShell module..." -ForegroundColor Cyan
$pnpModule = Get-Module -Name PnP.PowerShell -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

if ($null -eq $pnpModule) {
    Write-Host "   ❌ PnP.PowerShell module not found" -ForegroundColor Red
    Write-Host "   💡 Install with: Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force" -ForegroundColor Yellow
    $validationErrors += "PnP.PowerShell module not installed"
} else {
    $pnpVersion = $pnpModule.Version
    Write-Host "   ✅ PnP.PowerShell module found: v$($pnpVersion.ToString())" -ForegroundColor Green
    
    if ($pnpVersion.Major -lt 2) {
        Write-Host "   ⚠️  PnP.PowerShell version is below v2.0 (v$($pnpVersion.ToString()))" -ForegroundColor Yellow
        Write-Host "   💡 Update with: Update-Module -Name PnP.PowerShell -Force" -ForegroundColor Yellow
        $validationErrors += "PnP.PowerShell version below v2.0"
    }
    
    if ($DetailedReport) {
        Write-Host "   📊 Module Path: $($pnpModule.Path)" -ForegroundColor Cyan
    }
}

# Check ExchangeOnlineManagement module
Write-Host "   📋 Checking ExchangeOnlineManagement module..." -ForegroundColor Cyan
$exoModule = Get-Module -Name ExchangeOnlineManagement -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

if ($null -eq $exoModule) {
    Write-Host "   ❌ ExchangeOnlineManagement module not found" -ForegroundColor Red
    Write-Host "   💡 Install with: Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force" -ForegroundColor Yellow
    $validationErrors += "ExchangeOnlineManagement module not installed"
} else {
    $exoVersion = $exoModule.Version
    Write-Host "   ✅ ExchangeOnlineManagement module found: v$($exoVersion.ToString())" -ForegroundColor Green
    
    if ($exoVersion.Major -lt 3) {
        Write-Host "   ⚠️  ExchangeOnlineManagement version is below v3.0 (v$($exoVersion.ToString()))" -ForegroundColor Yellow
        Write-Host "   💡 Update with: Update-Module -Name ExchangeOnlineManagement -Force" -ForegroundColor Yellow
        $validationErrors += "ExchangeOnlineManagement version below v3.0"
    }
    
    if ($DetailedReport) {
        Write-Host "   📊 Module Path: $($exoModule.Path)" -ForegroundColor Cyan
    }
}

# =============================================================================
# Step 3: Load Global Configuration
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Load Global Configuration" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

try {
    $config = & "$PSScriptRoot\..\..\Shared-Utilities\Import-GlobalConfig.ps1" -GlobalConfigPath $GlobalConfigPath
    Write-Host "   ✅ Global configuration loaded successfully" -ForegroundColor Green
    
    if ($DetailedReport) {
        Write-Host "   📊 Tenant: $($config.Environment.OrganizationName)" -ForegroundColor Cyan
        Write-Host "   📊 Tenant URL: $($config.Environment.TenantUrl)" -ForegroundColor Cyan
        Write-Host "   📊 Scale Level: $($config.Simulation.ScaleLevel)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   ❌ Failed to load global configuration: $_" -ForegroundColor Red
    $validationErrors += "Global configuration load failure"
}

# =============================================================================
# Step 4: Test Service Connectivity
# =============================================================================

if (-not $SkipConnectivityTests) {
    Write-Host ""
    Write-Host "🔍 Step 4: Test Service Connectivity" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    
    Write-Host "   📋 This will prompt for browser-based authentication..." -ForegroundColor Cyan
    
    try {
        # =================================================================
        # IMPORTANT: Test Compliance Center FIRST, before loading Import-PurviewModules
        # Import-PurviewModules loads PnP.PowerShell which initializes MSAL assemblies
        # Once MSAL is loaded, WAM broker is active and env vars won't help
        # This is the same pattern used in Remove-SimulationResources.ps1 which works
        # =================================================================
        
        Write-Host "   📋 Testing Compliance Center connection (for Lab 05 DLP features)..." -ForegroundColor Cyan
        
        # Disable WAM broker BEFORE importing ExchangeOnlineManagement
        $env:AZURE_IDENTITY_DISABLE_MSALRUNTIME = "1"
        $env:MSAL_DISABLE_WAM = "1"
        [System.Environment]::SetEnvironmentVariable("AZURE_IDENTITY_DISABLE_MSALRUNTIME", "1", [System.EnvironmentVariableTarget]::Process)
        
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
        
        try {
            Write-Host "   🌐 Connecting to Security & Compliance Center..." -ForegroundColor Cyan
            Write-Host "   📋 Please sign in when prompted..." -ForegroundColor Cyan
            Connect-IPPSSession -WarningAction SilentlyContinue -ErrorAction Stop
            Write-Host "   ✅ Security & Compliance Center: Connected successfully" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️  Security & Compliance Center: Could not connect" -ForegroundColor Yellow
            Write-Host "   💡 Labs 01-04 will work normally without this connection" -ForegroundColor Cyan
            Write-Host "   💡 Lab 05 SIT resolution and Lab 06 DLP cleanup will have limited functionality" -ForegroundColor Cyan
        }
        
        # NOW load Import-PurviewModules (after Compliance Center connection attempt)
        . "$PSScriptRoot\..\..\Shared-Utilities\Import-PurviewModules.ps1"
        
        # Connect to SharePoint (required for all labs)
        Write-Host "   📋 Connecting to SharePoint..." -ForegroundColor Cyan
        Connect-PurviewServices -Services @("SharePoint") -TenantUrl $config.Environment.TenantUrl -PnPClientId $config.Environment.PnPClientId -Interactive
        
        Write-Host "   ✅ SharePoint connection established successfully" -ForegroundColor Green
        
        # Test SharePoint connection
        $spTest = Test-PurviewConnection -Service "SharePoint"
        if ($spTest.Connected) {
            Write-Host "   ✅ SharePoint Online: $($spTest.Message)" -ForegroundColor Green
        } else {
            Write-Host "   ❌ SharePoint Online: $($spTest.Message)" -ForegroundColor Red
            $validationErrors += "SharePoint connection test failed"
        }
        
    } catch {
        Write-Host "   ❌ Service connectivity test failed: $_" -ForegroundColor Red
        Write-Host "   💡 Common causes:" -ForegroundColor Yellow
        Write-Host "      - Pop-up blocker prevented authentication" -ForegroundColor Yellow
        Write-Host "      - Insufficient permissions (need SharePoint Administrator + Compliance Administrator)" -ForegroundColor Yellow
        Write-Host "      - Network connectivity issues" -ForegroundColor Yellow
        $validationErrors += "Service connection failure: $_"
    }
} else {
    Write-Host ""
    Write-Host "🔍 Step 4: Test Service Connectivity" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "   ⏭️  Connectivity tests skipped (SkipConnectivityTests parameter)" -ForegroundColor Yellow
}

# =============================================================================
# Step 5: Validate Disk Space
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 5: Validate Disk Space" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Determine required disk space based on scale level
$requiredSpaceGB = switch ($config.Simulation.ScaleLevel) {
    "Small"  { 1 }
    "Medium" { 5 }
    "Large"  { 15 }
    default  { 1 }
}

# Get drive where GeneratedDocumentsPath will be created
$documentsPath = $config.Paths.GeneratedDocumentsPath

# Convert relative path to absolute path if necessary
if (-not [System.IO.Path]::IsPathRooted($documentsPath)) {
    $documentsPath = Join-Path (Get-Location) $documentsPath
}

try {
    $driveLetter = Split-Path -Path $documentsPath -Qualifier
    $drive = Get-PSDrive -Name ($driveLetter.TrimEnd(':')) -ErrorAction Stop
    $freeSpaceGB = [Math]::Round($drive.Free / 1GB, 2)
    
    Write-Host "   📊 Drive: $driveLetter" -ForegroundColor Cyan
    Write-Host "   📊 Available Space: $freeSpaceGB GB" -ForegroundColor Cyan
    Write-Host "   📊 Required Space ($($config.Simulation.ScaleLevel) scale): $requiredSpaceGB GB" -ForegroundColor Cyan
    
    if ($freeSpaceGB -ge $requiredSpaceGB) {
        Write-Host "   ✅ Sufficient disk space available" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Insufficient disk space: $freeSpaceGB GB available, $requiredSpaceGB GB required" -ForegroundColor Red
        Write-Host "   💡 Free up disk space or change ScaleLevel in global-config.json to Small" -ForegroundColor Yellow
        $validationErrors += "Insufficient disk space: $freeSpaceGB GB available, $requiredSpaceGB GB required"
    }
} catch {
    Write-Host "   ⚠️  Could not determine disk space: $_" -ForegroundColor Yellow
    Write-Host "   💡 Manual verification recommended" -ForegroundColor Yellow
}

# =============================================================================
# Step 6: Validate Configuration Paths
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 6: Validate Configuration Paths" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$pathsToValidate = @(
    @{Name = "LogDirectory"; Path = $config.Paths.LogDirectory},
    @{Name = "OutputDirectory"; Path = $config.Paths.OutputDirectory},
    @{Name = "GeneratedDocumentsPath"; Path = $config.Paths.GeneratedDocumentsPath},
    @{Name = "ReportsPath"; Path = $config.Paths.ReportsPath}
)

foreach ($pathInfo in $pathsToValidate) {
    $parentPath = Split-Path -Path $pathInfo.Path -Parent
    
    if (Test-Path -Path $parentPath) {
        Write-Host "   ✅ Parent directory accessible: $($pathInfo.Name)" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Parent directory will be created: $($pathInfo.Name)" -ForegroundColor Cyan
    }
    
    if ($DetailedReport) {
        Write-Host "   📊 $($pathInfo.Name): $($pathInfo.Path)" -ForegroundColor Cyan
    }
}

# =============================================================================
# Step 7: Prerequisites Validation Summary
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 7: Prerequisites Validation Summary" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

if ($validationErrors.Count -eq 0) {
    Write-Host "   ✅ All prerequisites validation checks passed" -ForegroundColor Green
    Write-Host "   ✅ Environment ready for Purview Discovery Methods Simulation" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Run Initialize-SimulationEnvironment.ps1 to create directories" -ForegroundColor Cyan
    Write-Host "   2. Proceed to Lab 01 to create SharePoint sites" -ForegroundColor Cyan
    
    exit 0
} else {
    Write-Host "   ❌ Prerequisites validation completed with errors:" -ForegroundColor Red
    foreach ($error in $validationErrors) {
        Write-Host "      • $error" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "   💡 Please resolve the issues above before proceeding" -ForegroundColor Yellow
    Write-Host "   📚 Refer to Lab 00 README.md Troubleshooting section for guidance" -ForegroundColor Yellow
    
    throw "Prerequisites validation failed. Environment not ready for simulation."
}

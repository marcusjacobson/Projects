<#
.SYNOPSIS
    Imports and validates the global configuration file for Purview Data Governance Simulation.

.DESCRIPTION
    This utility script reads the global-config.json file from the project root, validates
    required sections and properties, and returns a PowerShell object for use by all simulation
    scripts. This is the CRITICAL component for environment portability - all scripts must
    call this function to load configuration rather than hardcoding values.
    
    The script supports optional -GlobalConfigPath parameter for multi-tenant consultant
    scenarios where separate config files are maintained for different clients.

.PARAMETER GlobalConfigPath
    Optional path to global configuration file. If not specified, defaults to
    global-config.json in the project root directory.

.PARAMETER ValidateOnly
    Validates configuration structure without returning the config object.
    Useful for prerequisite checks.

.EXAMPLE
    $config = .\Import-GlobalConfig.ps1
    
    Loads configuration from default global-config.json location.

.EXAMPLE
    $config = .\Import-GlobalConfig.ps1 -GlobalConfigPath "C:\Configs\contoso-global-config.json"
    
    Loads configuration from specific client config file (consultant multi-tenant scenario).

.EXAMPLE
    .\Import-GlobalConfig.ps1 -ValidateOnly
    
    Validates configuration structure only without loading into memory.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - global-config.json file at project root or specified path
    
    Script development orchestrated using GitHub Copilot.

.CONFIGURATION STRUCTURE
    Required sections in global-config.json:
    - Environment: TenantUrl, TenantDomain, AdminEmail
    - Simulation: ScaleLevel, ResourcePrefix, DefaultOwner
    - SharePointSites: Array of site definitions
    - BuiltInSITs: Array of SIT selections
    - Paths: LogDirectory, OutputDirectory, GeneratedDocumentsPath
    - Logging: LogLevel, RetainLogDays
#>
#
# =============================================================================
# Import and validate global configuration for complete environment portability.
# =============================================================================

function Import-GlobalConfig {
    [CmdletBinding()]
    param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly
)

# =============================================================================
# Step 1: Determine Configuration File Path
# =============================================================================

Write-Host "🔍 Step 1: Locating Global Configuration File" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

if ([string]::IsNullOrEmpty($GlobalConfigPath)) {
    # Default to project root global-config.json
    $projectRoot = Split-Path -Parent $PSScriptRoot
    $GlobalConfigPath = Join-Path $projectRoot "global-config.json"
    Write-Host "   Using default config path: $GlobalConfigPath" -ForegroundColor Cyan
} else {
    Write-Host "   Using specified config path: $GlobalConfigPath" -ForegroundColor Cyan
}

# Validate file exists
if (-not (Test-Path $GlobalConfigPath)) {
    Write-Host "   ❌ Configuration file not found: $GlobalConfigPath" -ForegroundColor Red
    throw "Global configuration file not found. Please ensure global-config.json exists at project root or provide valid -GlobalConfigPath parameter."
}

Write-Host "   ✅ Configuration file found" -ForegroundColor Green

# =============================================================================
# Step 2: Load Configuration File
# =============================================================================

Write-Host "`n🔍 Step 2: Loading Configuration Content" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

try {
    $configContent = Get-Content -Path $GlobalConfigPath -Raw -ErrorAction Stop
    $config = $configContent | ConvertFrom-Json -ErrorAction Stop
    Write-Host "   ✅ Configuration file loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to load or parse configuration file: $_" -ForegroundColor Red
    throw "Configuration file is not valid JSON. Please verify global-config.json structure."
}

# =============================================================================
# Step 3: Validate Required Sections
# =============================================================================

Write-Host "`n🔍 Step 3: Validating Required Configuration Sections" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

$requiredSections = @("Environment", "Simulation", "SharePointSites", "BuiltInSITs", "Paths", "Logging")
$validationErrors = @()

foreach ($section in $requiredSections) {
    if (-not $config.PSObject.Properties.Name.Contains($section)) {
        $validationErrors += "Missing required section: $section"
        Write-Host "   ❌ Missing section: $section" -ForegroundColor Red
    } else {
        Write-Host "   ✅ Section found: $section" -ForegroundColor Green
    }
}

# =============================================================================
# Step 4: Validate Environment Section
# =============================================================================

Write-Host "`n🔍 Step 4: Validating Environment Section" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

$requiredEnvProps = @("TenantUrl", "TenantDomain", "AdminEmail", "AdminCenterUrl", "OrganizationName", "PnPClientId")

foreach ($prop in $requiredEnvProps) {
    if (-not $config.Environment.PSObject.Properties.Name.Contains($prop)) {
        $validationErrors += "Missing Environment property: $prop"
        Write-Host "   ❌ Missing property: Environment.$prop" -ForegroundColor Red
    } elseif ([string]::IsNullOrWhiteSpace($config.Environment.$prop)) {
        $validationErrors += "Empty Environment property: $prop"
        Write-Host "   ❌ Empty property: Environment.$prop" -ForegroundColor Red
    } else {
        Write-Host "   ✅ Property valid: Environment.$prop = $($config.Environment.$prop)" -ForegroundColor Green
    }
}

# =============================================================================
# Step 5: Validate Simulation Section
# =============================================================================

Write-Host "`n🔍 Step 5: Validating Simulation Section" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$requiredSimProps = @("ScaleLevel", "ResourcePrefix", "DefaultOwner", "NotificationEmail")
$validScaleLevels = @("Small", "Medium", "Large")

foreach ($prop in $requiredSimProps) {
    if (-not $config.Simulation.PSObject.Properties.Name.Contains($prop)) {
        $validationErrors += "Missing Simulation property: $prop"
        Write-Host "   ❌ Missing property: Simulation.$prop" -ForegroundColor Red
    } elseif ([string]::IsNullOrWhiteSpace($config.Simulation.$prop)) {
        $validationErrors += "Empty Simulation property: $prop"
        Write-Host "   ❌ Empty property: Simulation.$prop" -ForegroundColor Red
    } else {
        Write-Host "   ✅ Property valid: Simulation.$prop = $($config.Simulation.$prop)" -ForegroundColor Green
    }
}

# Validate ScaleLevel value
if ($config.Simulation.ScaleLevel -notin $validScaleLevels) {
    $validationErrors += "Invalid ScaleLevel: $($config.Simulation.ScaleLevel). Must be Small, Medium, or Large."
    Write-Host "   ❌ Invalid ScaleLevel: $($config.Simulation.ScaleLevel)" -ForegroundColor Red
} else {
    Write-Host "   ✅ ScaleLevel valid: $($config.Simulation.ScaleLevel)" -ForegroundColor Green
}

# =============================================================================
# Step 6: Validate SharePointSites Array
# =============================================================================

Write-Host "`n🔍 Step 6: Validating SharePointSites Array" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

if ($null -eq $config.SharePointSites -or $config.SharePointSites.Count -eq 0) {
    $validationErrors += "SharePointSites array is empty or missing"
    Write-Host "   ❌ SharePointSites array is empty" -ForegroundColor Red
} else {
    Write-Host "   ✅ SharePointSites contains $($config.SharePointSites.Count) site(s)" -ForegroundColor Green
    
    $siteProps = @("Name", "Template", "Department", "Owner")
    foreach ($site in $config.SharePointSites) {
        foreach ($prop in $siteProps) {
            if (-not $site.PSObject.Properties.Name.Contains($prop)) {
                $validationErrors += "Site missing property: $prop"
                Write-Host "   ⚠️  Site missing property: $prop" -ForegroundColor Yellow
            }
        }
    }
}

# =============================================================================
# Step 7: Validate BuiltInSITs Array
# =============================================================================

Write-Host "`n🔍 Step 7: Validating BuiltInSITs Array" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

if ($null -eq $config.BuiltInSITs -or $config.BuiltInSITs.Count -eq 0) {
    $validationErrors += "BuiltInSITs array is empty or missing"
    Write-Host "   ❌ BuiltInSITs array is empty" -ForegroundColor Red
} else {
    $enabledSITs = ($config.BuiltInSITs | Where-Object { $_.Enabled -eq $true }).Count
    Write-Host "   ✅ BuiltInSITs contains $($config.BuiltInSITs.Count) SIT(s), $enabledSITs enabled" -ForegroundColor Green
}

# =============================================================================
# Step 8: Validate Paths Section
# =============================================================================

Write-Host "`n🔍 Step 8: Validating Paths Section" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

$requiredPaths = @("LogDirectory", "OutputDirectory", "GeneratedDocumentsPath", "ReportsPath")

foreach ($pathProp in $requiredPaths) {
    if (-not $config.Paths.PSObject.Properties.Name.Contains($pathProp)) {
        $validationErrors += "Missing Paths property: $pathProp"
        Write-Host "   ❌ Missing property: Paths.$pathProp" -ForegroundColor Red
    } else {
        Write-Host "   ✅ Property valid: Paths.$pathProp = $($config.Paths.$pathProp)" -ForegroundColor Green
    }
}

# =============================================================================
# Step 9: Validation Summary
# =============================================================================

Write-Host "`n📊 Validation Summary" -ForegroundColor Magenta
Write-Host "=====================" -ForegroundColor Magenta

if ($validationErrors.Count -eq 0) {
    Write-Host "✅ Configuration validation passed - all required sections and properties present" -ForegroundColor Green
    
    if ($ValidateOnly) {
        Write-Host "`n✅ Validation complete (ValidateOnly mode)" -ForegroundColor Green
        exit 0
    }
    
    # Return configuration object
    Write-Host "`n✅ Returning validated configuration object" -ForegroundColor Green
    return $config
    
} else {
    Write-Host "❌ Configuration validation failed with $($validationErrors.Count) error(s):" -ForegroundColor Red
    foreach ($error in $validationErrors) {
        Write-Host "   - $error" -ForegroundColor Red
    }
    throw "Configuration validation failed. Please fix errors in global-config.json and try again."
}
}

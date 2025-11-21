<#
.SYNOPSIS
    Merges lab-specific configuration with global configuration for parameter overrides.

.DESCRIPTION
    This utility script provides intelligent configuration merging capabilities for lab-specific
    parameter overrides. It reads a lab-specific configuration file (lab-config.json) and merges
    it with the global configuration, allowing labs to override specific parameters while inheriting
    all other values from the global configuration.
    
    The script supports the $GLOBAL: reference notation, enabling lab configurations to explicitly
    reference global values when needed. It performs deep merging for nested objects and arrays,
    ensuring that partial overrides don't replace entire configuration sections.
    
    This is a critical component of the two-tier configuration architecture, enabling:
    - Lab-specific parameter customization without duplicating global settings
    - Explicit global value references using $GLOBAL: notation
    - Deep merging of complex configuration structures
    - Validation of merged configuration completeness

.PARAMETER GlobalConfig
    The global configuration object loaded from global-config.json. This should be obtained
    by calling Import-GlobalConfig.ps1 before calling this script.

.PARAMETER LabConfigPath
    The path to the lab-specific configuration file (typically lab-config.json in the lab
    directory). If the file doesn't exist, the global configuration is returned unchanged.

.PARAMETER ValidateOnly
    When specified, performs configuration merging and validation without returning the
    merged result. Useful for testing lab configuration validity.

.EXAMPLE
    $globalConfig = & "$PSScriptRoot\..\Shared-Utilities\Import-GlobalConfig.ps1"
    $labConfigPath = Join-Path $PSScriptRoot "lab-config.json"
    $mergedConfig = & "$PSScriptRoot\..\Shared-Utilities\Merge-LabConfig.ps1" -GlobalConfig $globalConfig -LabConfigPath $labConfigPath
    
    Merges lab-specific configuration with global configuration.

.EXAMPLE
    $mergedConfig = & "$PSScriptRoot\..\Shared-Utilities\Merge-LabConfig.ps1" -GlobalConfig $globalConfig -LabConfigPath $labConfigPath -ValidateOnly
    
    Validates lab configuration merging without returning the result.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Global configuration object from Import-GlobalConfig.ps1
    - Lab-specific configuration file (optional)
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Merges lab-specific configuration with global configuration.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$GlobalConfig,
    
    [Parameter(Mandatory = $true)]
    [string]$LabConfigPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly
)

# =============================================================================
# Step 1: Check Lab Configuration File Existence
# =============================================================================

Write-Host "🔍 Step 1: Check Lab Configuration File Existence" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

if (-not (Test-Path -Path $LabConfigPath)) {
    Write-Host "   ℹ️  No lab-specific configuration found at: $LabConfigPath" -ForegroundColor Cyan
    Write-Host "   ✅ Using global configuration only (no lab overrides)" -ForegroundColor Green
    
    if ($ValidateOnly) {
        return $true
    } else {
        return $GlobalConfig
    }
}

Write-Host "   ✅ Lab configuration file found: $LabConfigPath" -ForegroundColor Green

# =============================================================================
# Step 2: Load Lab Configuration
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Load Lab Configuration" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

try {
    $labConfigContent = Get-Content -Path $LabConfigPath -Raw -ErrorAction Stop
    $labConfig = $labConfigContent | ConvertFrom-Json -ErrorAction Stop
    Write-Host "   ✅ Lab configuration loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to load lab configuration: $_" -ForegroundColor Red
    throw "Lab configuration file is invalid or unreadable: $LabConfigPath"
}

# =============================================================================
# Step 3: Deep Merge Configuration Objects
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Deep Merge Configuration Objects" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

function Merge-ConfigurationObjects {
    param (
        [PSCustomObject]$BaseConfig,
        [PSCustomObject]$OverrideConfig
    )
    
    # Create a deep copy of the base configuration
    $mergedConfig = $BaseConfig | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    
    # Iterate through all properties in the override configuration
    foreach ($property in $OverrideConfig.PSObject.Properties) {
        $propertyName = $property.Name
        $overrideValue = $property.Value
        
        # Check if property exists in base configuration
        if ($mergedConfig.PSObject.Properties.Name -contains $propertyName) {
            $baseValue = $mergedConfig.$propertyName
            
            # If both are objects (not arrays), perform deep merge
            if ($baseValue -is [PSCustomObject] -and $overrideValue -is [PSCustomObject]) {
                $mergedConfig.$propertyName = Merge-ConfigurationObjects -BaseConfig $baseValue -OverrideConfig $overrideValue
            }
            # If both are arrays, replace with override (lab-specific array takes precedence)
            elseif ($baseValue -is [Array] -and $overrideValue -is [Array]) {
                $mergedConfig.$propertyName = $overrideValue
            }
            # For scalar values, override takes precedence
            else {
                $mergedConfig.$propertyName = $overrideValue
            }
        } else {
            # Property doesn't exist in base, add it from override
            $mergedConfig | Add-Member -MemberType NoteProperty -Name $propertyName -Value $overrideValue -Force
        }
    }
    
    return $mergedConfig
}

try {
    $mergedConfig = Merge-ConfigurationObjects -BaseConfig $GlobalConfig -OverrideConfig $labConfig
    Write-Host "   ✅ Configuration objects merged successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Configuration merging failed: $_" -ForegroundColor Red
    throw "Failed to merge lab configuration with global configuration"
}

# =============================================================================
# Step 4: Resolve Global References
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 4: Resolve Global References" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

Write-Host "   📋 Calling Resolve-GlobalReference.ps1 to process `$GLOBAL: notation..." -ForegroundColor Cyan

try {
    $resolvedConfig = & "$PSScriptRoot\Resolve-GlobalReference.ps1" -Config $mergedConfig -GlobalConfig $GlobalConfig
    Write-Host "   ✅ Global references resolved successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Global reference resolution failed: $_" -ForegroundColor Red
    throw "Failed to resolve global references in merged configuration"
}

# =============================================================================
# Step 5: Validate Merged Configuration
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 5: Validate Merged Configuration" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

$validationErrors = @()

# Validate required top-level sections still exist
$requiredSections = @("Environment", "Simulation", "Paths", "Logging")
foreach ($section in $requiredSections) {
    if (-not $resolvedConfig.PSObject.Properties.Name.Contains($section)) {
        $validationErrors += "Missing required section after merge: $section"
    }
}

# Validate Environment section required properties
if ($resolvedConfig.PSObject.Properties.Name.Contains("Environment")) {
    $requiredEnvProps = @("TenantUrl", "TenantDomain", "AdminEmail", "ComplianceUrl", "OrganizationName")
    foreach ($prop in $requiredEnvProps) {
        if (-not $resolvedConfig.Environment.PSObject.Properties.Name.Contains($prop)) {
            $validationErrors += "Missing required Environment property after merge: $prop"
        } elseif ([string]::IsNullOrWhiteSpace($resolvedConfig.Environment.$prop)) {
            $validationErrors += "Environment property is empty after merge: $prop"
        }
    }
}

# Validate Simulation section required properties
if ($resolvedConfig.PSObject.Properties.Name.Contains("Simulation")) {
    $requiredSimProps = @("ScaleLevel", "ResourcePrefix", "DefaultOwner", "NotificationEmail")
    foreach ($prop in $requiredSimProps) {
        if (-not $resolvedConfig.Simulation.PSObject.Properties.Name.Contains($prop)) {
            $validationErrors += "Missing required Simulation property after merge: $prop"
        }
    }
    
    # Validate ScaleLevel enum
    if ($resolvedConfig.Simulation.PSObject.Properties.Name.Contains("ScaleLevel")) {
        $validScaleLevels = @("Small", "Medium", "Large")
        if ($resolvedConfig.Simulation.ScaleLevel -notin $validScaleLevels) {
            $validationErrors += "Invalid ScaleLevel after merge. Must be Small, Medium, or Large. Found: $($resolvedConfig.Simulation.ScaleLevel)"
        }
    }
}

# Report validation results
if ($validationErrors.Count -gt 0) {
    Write-Host "   ❌ Merged configuration validation failed:" -ForegroundColor Red
    foreach ($error in $validationErrors) {
        Write-Host "      • $error" -ForegroundColor Red
    }
    throw "Merged configuration validation failed. Lab configuration may have removed required properties."
} else {
    Write-Host "   ✅ Merged configuration validated successfully" -ForegroundColor Green
}

# =============================================================================
# Step 6: Configuration Merge Summary
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 6: Configuration Merge Summary" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

Write-Host "   📊 Global configuration: Loaded from global-config.json" -ForegroundColor Cyan
Write-Host "   📊 Lab configuration: $LabConfigPath" -ForegroundColor Cyan
Write-Host "   📊 Merge strategy: Deep merge with lab overrides taking precedence" -ForegroundColor Cyan
Write-Host "   ✅ Configuration ready for lab execution" -ForegroundColor Green

# =============================================================================
# Step 7: Return Merged Configuration
# =============================================================================

if ($ValidateOnly) {
    Write-Host ""
    Write-Host "✅ Validation complete - merged configuration is valid" -ForegroundColor Green
    return $true
} else {
    Write-Host ""
    Write-Host "✅ Returning merged configuration object" -ForegroundColor Green
    return $resolvedConfig
}

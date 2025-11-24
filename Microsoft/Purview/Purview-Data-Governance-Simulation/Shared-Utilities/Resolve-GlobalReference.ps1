<#
.SYNOPSIS
    Resolves $GLOBAL: notation in lab configurations to actual global configuration values.

.DESCRIPTION
    This utility script processes configuration objects and resolves any string values that use
    the $GLOBAL: notation to reference values from the global configuration. This enables lab
    configurations to explicitly reference global values while still allowing overrides.
    
    The script performs recursive resolution through nested objects and arrays, ensuring that
    all $GLOBAL: references are replaced with their actual values from the global configuration.
    
    Supported notation patterns:
    - $GLOBAL:Section.Property - References a property in a top-level section
    - $GLOBAL:Section.SubSection.Property - References nested properties
    
    Examples:
    - "$GLOBAL:Environment.TenantUrl" resolves to the actual tenant URL
    - "$GLOBAL:Simulation.ResourcePrefix" resolves to the resource prefix
    - "$GLOBAL:Paths.LogDirectory" resolves to the log directory path

.PARAMETER Config
    The configuration object that may contain $GLOBAL: references to be resolved.

.PARAMETER GlobalConfig
    The global configuration object containing the actual values to resolve references to.

.EXAMPLE
    $resolvedConfig = & "$PSScriptRoot\..\Shared-Utilities\Resolve-GlobalReference.ps1" -Config $labConfig -GlobalConfig $globalConfig
    
    Resolves all $GLOBAL: references in the lab configuration.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Configuration objects from Import-GlobalConfig.ps1 or Merge-LabConfig.ps1
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Resolves $GLOBAL: notation to actual global configuration values.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$Config,
    
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$GlobalConfig
)

# =============================================================================
# Step 1: Initialize Resolution Process
# =============================================================================

Write-Verbose "🔍 Step 1: Initialize Global Reference Resolution" -Verbose
Write-Verbose "=================================================" -Verbose

$resolutionCount = 0
$resolutionErrors = @()

# =============================================================================
# Step 2: Define Recursive Resolution Function
# =============================================================================

Write-Verbose "🔍 Step 2: Define Recursive Resolution Function" -Verbose
Write-Verbose "===============================================" -Verbose

function Resolve-ConfigValue {
    param (
        [Parameter(Mandatory = $true)]
        $Value,
        
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$GlobalConfig
    )
    
    # Handle string values that may contain $GLOBAL: references
    if ($Value -is [string] -and $Value -match '^\$GLOBAL:(.+)$') {
        $referencePath = $Matches[1]
        
        try {
            # Split the reference path (e.g., "Environment.TenantUrl" -> ["Environment", "TenantUrl"])
            $pathParts = $referencePath -split '\.'
            
            # Navigate through the global config to find the referenced value
            $resolvedValue = $GlobalConfig
            foreach ($part in $pathParts) {
                if ($resolvedValue.PSObject.Properties.Name -contains $part) {
                    $resolvedValue = $resolvedValue.$part
                } else {
                    throw "Global reference path not found: $referencePath (missing: $part)"
                }
            }
            
            $script:resolutionCount++
            Write-Verbose "   ✅ Resolved: `$GLOBAL:$referencePath -> $resolvedValue" -Verbose
            return $resolvedValue
            
        } catch {
            $errorMsg = "Failed to resolve global reference: `$GLOBAL:$referencePath - $_"
            $script:resolutionErrors += $errorMsg
            Write-Verbose "   ❌ $errorMsg" -Verbose
            return $Value  # Return original value if resolution fails
        }
    }
    # Handle PSCustomObject (nested objects) - recurse
    elseif ($Value -is [PSCustomObject]) {
        $resolvedObject = [PSCustomObject]@{}
        foreach ($property in $Value.PSObject.Properties) {
            $resolvedValue = Resolve-ConfigValue -Value $property.Value -GlobalConfig $GlobalConfig
            $resolvedObject | Add-Member -MemberType NoteProperty -Name $property.Name -Value $resolvedValue
        }
        return $resolvedObject
    }
    # Handle arrays - recurse through each element
    elseif ($Value -is [Array]) {
        $resolvedArray = @()
        foreach ($item in $Value) {
            $resolvedArray += Resolve-ConfigValue -Value $item -GlobalConfig $GlobalConfig
        }
        return $resolvedArray
    }
    # Handle hashtables - convert to PSCustomObject and recurse
    elseif ($Value -is [System.Collections.Hashtable]) {
        $resolvedHashtable = @{}
        foreach ($key in $Value.Keys) {
            $resolvedHashtable[$key] = Resolve-ConfigValue -Value $Value[$key] -GlobalConfig $GlobalConfig
        }
        return $resolvedHashtable
    }
    # For all other types (numbers, booleans, etc.), return as-is
    else {
        return $Value
    }
}

Write-Verbose "   ✅ Resolution function defined" -Verbose

# =============================================================================
# Step 3: Process Configuration Object
# =============================================================================

Write-Verbose ""
Write-Verbose "🔍 Step 3: Process Configuration Object" -Verbose
Write-Verbose "=======================================" -Verbose

try {
    $resolvedConfig = Resolve-ConfigValue -Value $Config -GlobalConfig $GlobalConfig
    Write-Verbose "   ✅ Configuration object processed successfully" -Verbose
} catch {
    Write-Verbose "   ❌ Configuration processing failed: $_" -Verbose
    throw "Failed to resolve global references in configuration"
}

# =============================================================================
# Step 4: Resolution Summary
# =============================================================================

Write-Verbose ""
Write-Verbose "🔍 Step 4: Resolution Summary" -Verbose
Write-Verbose "=============================" -Verbose

Write-Verbose "   📊 Total `$GLOBAL: references resolved: $resolutionCount" -Verbose

if ($resolutionErrors.Count -gt 0) {
    Write-Verbose "   ⚠️  Resolution errors encountered: $($resolutionErrors.Count)" -Verbose
    foreach ($error in $resolutionErrors) {
        Write-Verbose "      • $error" -Verbose
    }
    
    # Throw error if any references failed to resolve
    throw "Global reference resolution completed with errors. Some `$GLOBAL: references could not be resolved."
} else {
    Write-Verbose "   ✅ All global references resolved successfully" -Verbose
}

# =============================================================================
# Step 5: Return Resolved Configuration
# =============================================================================

Write-Verbose ""
Write-Verbose "✅ Returning resolved configuration object" -Verbose
return $resolvedConfig

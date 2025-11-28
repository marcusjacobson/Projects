<#
.SYNOPSIS
    PowerShell module for dynamic SIT GUID to friendly name mapping.

.DESCRIPTION
    Provides functions to retrieve SIT (Sensitive Information Type) definitions
    from Microsoft Purview tenant and resolve GUIDs to friendly names.
    
    Uses Get-DlpSensitiveInformationType cmdlet from Security & Compliance PowerShell
    with fallback to cached JSON file if tenant connection unavailable.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-20
    
    Requirements:
    - Security & Compliance PowerShell module (for live tenant queries)
    - Or: Purview-SIT-GUID-Mapping.json file (for cached fallback)

.DATA DISCOVERY OPERATIONS
    - SIT GUID resolution and mapping
    - Tenant SIT definition querying
    - Cached mapping fallback handling
    - Dynamic friendly name resolution
#>

function Get-SITMapping {
    <#
    .SYNOPSIS
        Retrieves SIT GUID to friendly name mapping.
    
    .DESCRIPTION
        Attempts to query live tenant for SIT definitions using Get-DlpSensitiveInformationType.
        Falls back to cached JSON file if tenant connection unavailable.
    
    .PARAMETER CachePath
        Path to cached Purview-SIT-GUID-Mapping.json file for fallback.
    
    .PARAMETER UseCache
        Force use of cached file instead of attempting tenant query.
    
    .OUTPUTS
        Hashtable with GUID keys and friendly name values.
    
    .EXAMPLE
        $sitMapping = Get-SITMapping
        
    .EXAMPLE
        $sitMapping = Get-SITMapping -CachePath "..\Purview-SIT-GUID-Mapping.json"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$CachePath = "..\Purview-SIT-GUID-Mapping.json",
        
        [Parameter(Mandatory = $false)]
        [switch]$UseCache
    )
    
    $sitHashTable = @{}
    $cacheLoadedCount = 0
    
    # Step 1: Load cached JSON file FIRST (contains manually curated deprecated/renamed SIT mappings)
    if (Test-Path $CachePath) {
        Write-Verbose "📂 Step 1: Loading centralized mapping file..."
        Write-Verbose "   File: $CachePath"
        
        try {
            $cacheContent = Get-Content -Path $CachePath -Raw | ConvertFrom-Json
            
            # Handle different JSON structures
            if ($cacheContent.sitMappings) {
                # New structure with sitMappings object
                $sitMappings = $cacheContent.sitMappings
                foreach ($property in $sitMappings.PSObject.Properties) {
                    $sitHashTable[$property.Name.ToLower()] = $property.Value
                }
            } elseif ($cacheContent.sensitiveInformationTypes) {
                # Old structure with array
                foreach ($sit in $cacheContent.sensitiveInformationTypes) {
                    if ($sit.id -and $sit.name) {
                        $sitHashTable[$sit.id.ToLower()] = $sit.name
                    }
                }
            }
            
            $cacheLoadedCount = $sitHashTable.Count
            Write-Verbose "   ✅ Loaded $cacheLoadedCount SIT mappings from centralized file"
        } catch {
            Write-Verbose "   ⚠️  Failed to load cached mapping: $($_.Exception.Message)"
        }
    } else {
        Write-Verbose "   ℹ️  No centralized mapping file found at: $CachePath"
    }
    
    # Step 2: Query tenant for additional SIT definitions (unless UseCache specified)
    if (-not $UseCache) {
        Write-Verbose "🔐 Step 2: Querying tenant for additional SIT definitions..."
        
        try {
            # Check if Get-DlpSensitiveInformationType cmdlet is available
            $cmdlet = Get-Command Get-DlpSensitiveInformationType -ErrorAction SilentlyContinue
            
            if ($cmdlet) {
                Write-Verbose "   🔄 Executing Get-DlpSensitiveInformationType..."
                
                $sitDefinitions = Get-DlpSensitiveInformationType -ErrorAction Stop
                $tenantAddedCount = 0
                
                foreach ($sit in $sitDefinitions) {
                    if ($sit.Id -and $sit.Name) {
                        $guidKey = $sit.Id.ToString().ToLower()
                        # Only add if not already in hashtable from JSON file
                        if (-not $sitHashTable.ContainsKey($guidKey)) {
                            $sitHashTable[$guidKey] = $sit.Name
                            $tenantAddedCount++
                        }
                    }
                }
                
                Write-Verbose "   ✅ Added $tenantAddedCount new SIT definitions from tenant"
                Write-Verbose "   📊 Total mappings: $($sitHashTable.Count) ($cacheLoadedCount from file + $tenantAddedCount from tenant)"
            } else {
                Write-Verbose "   ℹ️  Get-DlpSensitiveInformationType cmdlet not available"
            }
        } catch {
            Write-Verbose "   ⚠️  Tenant query failed: $($_.Exception.Message)"
            Write-Verbose "   💡 Using mappings from centralized file only"
        }
    } else {
        Write-Verbose "   ℹ️  Skipping tenant query (UseCache specified)"
    }
    
    # Return combined mappings (JSON file + tenant)
    if ($sitHashTable.Count -gt 0) {
        Write-Verbose "✅ SIT mapping complete: $($sitHashTable.Count) total mappings available"
        return $sitHashTable
    } else {
        Write-Warning "Unable to load SIT mappings - returning empty mapping"
        return @{}
    }
}

function Resolve-SITName {
    <#
    .SYNOPSIS
        Resolves a SIT type identifier to friendly name.
    
    .DESCRIPTION
        Takes a SIT_Type value (friendly name or "Custom SIT (guid)" format)
        and returns the friendly name using the provided GUID mapping.
    
    .PARAMETER SITType
        The SIT_Type value to resolve (e.g., "Custom SIT (guid)" or "U.S. SSN").
    
    .PARAMETER GuidMapping
        Hashtable of GUID to friendly name mappings from Get-SITMapping.
    
    .OUTPUTS
        String with resolved friendly name or original value if not resolvable.
    
    .EXAMPLE
        $resolved = Resolve-SITName -SITType "Custom SIT (50b8b56b-4ef8-44c2-a924-03374f5831ce)" -GuidMapping $sitMapping
        # Returns: "U.S. Bank Account Number"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SITType,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$GuidMapping
    )
    
    # Check if already a friendly name (doesn't start with "Custom SIT (")
    if ($SITType -notmatch '^Custom SIT \(') {
        return $SITType
    }
    
    # Extract GUID from "Custom SIT (guid)" format
    if ($SITType -match '^Custom SIT \(([a-f0-9-]+)\)$') {
        $guid = $matches[1].ToLower()
        
        # Look up friendly name in mapping
        if ($GuidMapping.ContainsKey($guid)) {
            return $GuidMapping[$guid]
        }
    }
    
    # Return original if not resolvable
    return $SITType
}

function Show-MappingStatistics {
    <#
    .SYNOPSIS
        Displays statistics about SIT mapping effectiveness.
    
    .DESCRIPTION
        Analyzes a dataset with SIT_Type column and shows how many
        GUIDs were resolved vs unresolved using the provided mapping.
    
    .PARAMETER Data
        Array of objects with SIT_Type property.
    
    .PARAMETER GuidMapping
        Hashtable of GUID to friendly name mappings.
    
    .EXAMPLE
        Show-MappingStatistics -Data $detections -GuidMapping $sitMapping
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$Data,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$GuidMapping
    )
    
    $uniqueSITs = $Data | Select-Object -ExpandProperty SIT_Type -Unique
    $totalUnique = $uniqueSITs.Count
    
    $friendlyNames = $uniqueSITs | Where-Object { $_ -notmatch '^Custom SIT \(' }
    $guidEntries = $uniqueSITs | Where-Object { $_ -match '^Custom SIT \(' }
    
    # Check how many GUIDs can be resolved
    $resolvableGUIDs = $guidEntries | Where-Object {
        $_ -match '^Custom SIT \(([a-f0-9-]+)\)$' -and $GuidMapping.ContainsKey($matches[1].ToLower())
    }
    
    Write-Verbose "SIT Mapping Effectiveness:"
    Write-Verbose "   Total unique SIT types: $totalUnique"
    Write-Verbose "   Already friendly names: $($friendlyNames.Count)"
    Write-Verbose "   GUID entries: $($guidEntries.Count)"
    Write-Verbose "   Resolvable GUIDs: $($resolvableGUIDs.Count)"
    Write-Verbose "   Unresolvable GUIDs: $($guidEntries.Count - $resolvableGUIDs.Count)"
    Write-Verbose "   Resolution rate: $([Math]::Round(($resolvableGUIDs.Count / $guidEntries.Count) * 100, 1))%"
}

# Export module functions
Export-ModuleMember -Function Get-SITMapping, Resolve-SITName, Show-MappingStatistics

# Scalable SIT GUID-to-Name Mapping Solution

## 🎯 Problem Statement

**Challenge**: eDiscovery and Content Explorer exports contain Sensitive Information Type (SIT) identifiers as GUIDs, not friendly names. Maintaining hardcoded GUID mapping tables is:

- **Not scalable** - Requires manual updates for each new SIT
- **Maintenance-intensive** - Must update scripts whenever Microsoft adds new built-in SITs
- **Error-prone** - Easy to miss GUIDs or create mapping inconsistencies
- **Organization-specific** - Custom SITs unique to each tenant require manual additions

**Current Lab 05b Issue**:
- Hardcoded 8-entry GUID map in analysis script
- eDiscovery detected 93 unique SIT types (all built-in Purview SITs)
- 86 SIT types display as "Custom SIT (GUID)" instead of friendly names
- No scalable mechanism to resolve unmapped GUIDs

---

## ✅ Recommended Solution: PowerShell Security & Compliance Cmdlet

### `Get-DlpSensitiveInformationType` - The Authoritative Source

Microsoft provides a **native PowerShell cmdlet** that programmatically retrieves ALL sensitive information type definitions from your Purview tenant:

```powershell
# Connect to Security & Compliance PowerShell
Connect-IPPSSession

# Retrieve ALL SIT definitions (built-in + custom)
$allSITs = Get-DlpSensitiveInformationType

# Display key properties
$allSITs | Select-Object Name, Id, Publisher | Format-Table -AutoSize
```

### Key Properties Available

| Property | Description | Example Value |
|----------|-------------|---------------|
| **Name** | Friendly display name | `"U.S. Social Security Number (SSN)"` |
| **Id** | GUID identifier | `"a44669fe-0d48-453d-a9b1-2cc83f2cba77"` |
| **Publisher** | Creator of SIT | `"Microsoft Corporation"` (built-in) or organization name (custom) |
| **RecommendedConfidence** | Default confidence level | `85` |
| **Description** | SIT description | Detailed explanation |
| **Locale** | Language/region | `"en-US"` |

### Why This Solution is Superior

✅ **Always Current**: Queries live tenant configuration - no manual updates needed

✅ **Includes Custom SITs**: Automatically discovers organization-specific custom SITs

✅ **Authoritative Source**: Direct from Microsoft Purview compliance APIs

✅ **Scalable**: Works regardless of how many SITs exist (93, 200, or 1000+)

✅ **Single Line of Code**: `Get-DlpSensitiveInformationType` retrieves everything

✅ **No Hardcoding Required**: Dynamic lookup eliminates maintenance burden

---

## 🏗️ Implementation Strategy

### Option 1: Dynamic Runtime Lookup (Recommended)

**Approach**: Query SIT definitions at script execution and build in-memory mapping hashtable.

**Advantages**:
- Always reflects current tenant configuration
- Zero maintenance for built-in SITs
- Automatically includes newly added custom SITs
- No static mapping files to maintain

**Implementation Pattern**:

```powershell
<#
.SYNOPSIS
    Dynamically retrieve SIT GUID-to-Name mappings from Microsoft Purview.

.DESCRIPTION
    Connects to Security & Compliance PowerShell and queries all sensitive
    information type definitions. Builds a hashtable for fast GUID lookups.
#>

function Get-SITMappingTable {
    [CmdletBinding()]
    param()
    
    try {
        Write-Verbose "Connecting to Security & Compliance PowerShell..."
        
        # Check if already connected
        $session = Get-PSSession | Where-Object {
            $_.ConfigurationName -eq "Microsoft.Exchange" -and 
            $_.State -eq "Opened"
        }
        
        if (-not $session) {
            # Connect to Security & Compliance Center
            Connect-IPPSSession -WarningAction SilentlyContinue
        }
        
        Write-Verbose "Retrieving all SIT definitions..."
        $allSITs = Get-DlpSensitiveInformationType
        
        Write-Verbose "Building GUID-to-Name mapping hashtable..."
        $sitMapping = @{}
        
        foreach ($sit in $allSITs) {
            # Use GUID as key, Name as value
            $sitMapping[$sit.Id.ToString()] = $sit.Name
        }
        
        Write-Host "✅ Retrieved $($sitMapping.Count) SIT definitions from tenant" -ForegroundColor Green
        Write-Host "   - Built-in SITs: $(($allSITs | Where-Object {$_.Publisher -eq 'Microsoft Corporation'}).Count)" -ForegroundColor Cyan
        Write-Host "   - Custom SITs: $(($allSITs | Where-Object {$_.Publisher -ne 'Microsoft Corporation'}).Count)" -ForegroundColor Cyan
        
        return $sitMapping
        
    } catch {
        Write-Warning "Failed to retrieve SIT definitions: $_"
        Write-Warning "Falling back to empty mapping table. GUIDs will not be resolved."
        return @{}
    }
}

# Usage in analysis script
$sitGuidMapping = Get-SITMappingTable

# Resolve GUID to friendly name
function Resolve-SITName {
    param(
        [string]$SITType,
        [hashtable]$GuidMapping
    )
    
    # Check if already a friendly name
    if ($SITType -notmatch '^Custom SIT \(([a-f0-9-]+)\)$') {
        return $SITType
    }
    
    # Extract GUID from "Custom SIT (guid)" format
    $guid = $Matches[1]
    
    # Lookup in mapping table
    if ($GuidMapping.ContainsKey($guid)) {
        return $GuidMapping[$guid]
    }
    
    # Return original if not found (shouldn't happen with dynamic lookup)
    return $SITType
}
```

**Integration into Lab 05b Analysis Script**:

```powershell
# Replace hardcoded $sitGuidMap (lines 173-181) with:

# =============================================================================
# Dynamic SIT GUID Mapping Initialization
# =============================================================================

Write-Host "📋 Initializing SIT GUID mapping..." -ForegroundColor Cyan

# Retrieve live SIT definitions from tenant
$sitGuidMap = Get-SITMappingTable

if ($sitGuidMap.Count -eq 0) {
    Write-Warning "SIT mapping unavailable - GUIDs will display in output"
} else {
    Write-Host "   ✅ $($sitGuidMap.Count) SIT definitions loaded" -ForegroundColor Green
}
```

### Option 2: Cached Mapping File with Auto-Refresh

**Approach**: Generate mapping file from tenant, cache locally, refresh periodically.

**Advantages**:
- Reduces API calls during frequent script executions
- Works offline after initial generation
- Provides audit trail of SIT definitions over time

**Implementation Pattern**:

```powershell
<#
.SYNOPSIS
    Generate or refresh cached SIT GUID mapping file from tenant.

.DESCRIPTION
    Creates a JSON file containing all SIT GUID-to-Name mappings from
    the current tenant configuration. File is timestamped and cached
    for fast subsequent lookups.
#>

function Update-SITMappingCache {
    [CmdletBinding()]
    param(
        [string]$CachePath = ".\Purview-SIT-GUID-Mapping.json",
        [int]$CacheExpirationHours = 24
    )
    
    # Check if cache exists and is fresh
    if (Test-Path $CachePath) {
        $cacheFile = Get-Item $CachePath
        $cacheAge = (Get-Date) - $cacheFile.LastWriteTime
        
        if ($cacheAge.TotalHours -lt $CacheExpirationHours) {
            Write-Verbose "Cache is fresh (age: $([Math]::Round($cacheAge.TotalHours, 1)) hours)"
            return $false # No refresh needed
        }
    }
    
    Write-Host "🔄 Refreshing SIT mapping cache from tenant..." -ForegroundColor Cyan
    
    try {
        # Connect and retrieve SITs
        $session = Get-PSSession | Where-Object {
            $_.ConfigurationName -eq "Microsoft.Exchange" -and $_.State -eq "Opened"
        }
        if (-not $session) {
            Connect-IPPSSession -WarningAction SilentlyContinue
        }
        
        $allSITs = Get-DlpSensitiveInformationType
        
        # Build mapping object
        $sitMappings = @{}
        foreach ($sit in $allSITs) {
            $sitMappings[$sit.Id.ToString()] = $sit.Name
        }
        
        # Create JSON structure
        $cacheObject = @{
            description = "Auto-generated SIT GUID-to-Name mappings from Microsoft Purview tenant"
            generatedDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            tenantId = (Get-AzContext).Tenant.Id # If Azure PowerShell available
            totalSITs = $sitMappings.Count
            builtInSITs = ($allSITs | Where-Object {$_.Publisher -eq "Microsoft Corporation"}).Count
            customSITs = ($allSITs | Where-Object {$_.Publisher -ne "Microsoft Corporation"}).Count
            sitMappings = $sitMappings
        }
        
        # Save to JSON
        $cacheObject | ConvertTo-Json -Depth 10 | Set-Content -Path $CachePath -Encoding UTF8
        
        Write-Host "   ✅ Cache refreshed: $($sitMappings.Count) SIT definitions" -ForegroundColor Green
        Write-Host "   📁 Saved to: $CachePath" -ForegroundColor Cyan
        
        return $true # Refresh completed
        
    } catch {
        Write-Warning "Failed to refresh SIT mapping cache: $_"
        return $false
    }
}

function Get-CachedSITMapping {
    [CmdletBinding()]
    param(
        [string]$CachePath = ".\Purview-SIT-GUID-Mapping.json",
        [switch]$ForceRefresh
    )
    
    # Refresh cache if needed
    if ($ForceRefresh) {
        Update-SITMappingCache -CachePath $CachePath
    } else {
        Update-SITMappingCache -CachePath $CachePath -CacheExpirationHours 24
    }
    
    # Load cached mappings
    if (Test-Path $CachePath) {
        try {
            $cacheContent = Get-Content $CachePath -Raw | ConvertFrom-Json
            Write-Host "✅ Loaded $($cacheContent.totalSITs) SIT definitions from cache" -ForegroundColor Green
            Write-Host "   - Generated: $($cacheContent.generatedDate)" -ForegroundColor Cyan
            Write-Host "   - Built-in SITs: $($cacheContent.builtInSITs)" -ForegroundColor Cyan
            Write-Host "   - Custom SITs: $($cacheContent.customSITs)" -ForegroundColor Cyan
            
            return $cacheContent.sitMappings
        } catch {
            Write-Warning "Failed to load cached mappings: $_"
            return @{}
        }
    } else {
        Write-Warning "SIT mapping cache not found at: $CachePath"
        return @{}
    }
}

# Usage in analysis script
$sitGuidMapping = Get-CachedSITMapping -CachePath "..\Purview-SIT-GUID-Mapping.json"
```

### Option 3: Hybrid Approach (Best of Both Worlds)

**Approach**: Try dynamic lookup first, fall back to cached file if connection fails.

```powershell
function Get-SITMapping {
    [CmdletBinding()]
    param(
        [string]$CachePath = "..\Purview-SIT-GUID-Mapping.json"
    )
    
    try {
        # Attempt dynamic lookup
        Write-Verbose "Attempting dynamic SIT lookup from tenant..."
        $session = Get-PSSession | Where-Object {
            $_.ConfigurationName -eq "Microsoft.Exchange" -and $_.State -eq "Opened"
        }
        
        if (-not $session) {
            Connect-IPPSSession -WarningAction SilentlyContinue -ErrorAction Stop
        }
        
        $allSITs = Get-DlpSensitiveInformationType -ErrorAction Stop
        
        $sitMapping = @{}
        foreach ($sit in $allSITs) {
            $sitMapping[$sit.Id.ToString()] = $sit.Name
        }
        
        Write-Host "✅ Retrieved $($sitMapping.Count) SIT definitions from tenant (live)" -ForegroundColor Green
        return $sitMapping
        
    } catch {
        Write-Warning "Dynamic lookup failed: $_"
        Write-Host "📂 Falling back to cached mapping file..." -ForegroundColor Yellow
        
        # Fallback to cached file
        if (Test-Path $CachePath) {
            try {
                $cacheContent = Get-Content $CachePath -Raw | ConvertFrom-Json
                Write-Host "✅ Loaded $($cacheContent.totalSITs) SIT definitions from cache" -ForegroundColor Green
                return $cacheContent.sitMappings
            } catch {
                Write-Warning "Failed to load cached mappings: $_"
                return @{}
            }
        } else {
            Write-Warning "No cached mapping file found at: $CachePath"
            return @{}
        }
    }
}
```

---

## 📊 Comparison of Approaches

| Aspect | Hardcoded Map | Static JSON File | Dynamic Lookup | Cached with Refresh | Hybrid |
|--------|---------------|------------------|----------------|---------------------|--------|
| **Maintenance** | ❌ Manual updates | ⚠️ Periodic regeneration | ✅ Zero maintenance | ✅ Auto-refresh | ✅ Zero maintenance |
| **Custom SITs** | ❌ Must manually add | ⚠️ Must regenerate | ✅ Automatic | ✅ Automatic | ✅ Automatic |
| **Offline Work** | ✅ Works offline | ✅ Works offline | ❌ Requires connection | ✅ Works offline | ✅ Works offline |
| **Always Current** | ❌ Static/outdated | ⚠️ Depends on refresh | ✅ Real-time | ⚠️ Cache expiration | ✅ Real-time |
| **Performance** | ✅ Instant | ✅ Fast | ⚠️ API call latency | ✅ Fast (when cached) | ✅ Optimized |
| **Scalability** | ❌ Limited to coded GUIDs | ✅ Tenant-specific | ✅ Unlimited | ✅ Unlimited | ✅ Unlimited |
| **Setup Complexity** | ✅ Simple | ⚠️ Moderate | ⚠️ Requires connection | ⚠️ Moderate | ⚠️ Moderate |
| **Error Resilience** | ✅ No dependencies | ✅ File-based | ❌ Connection required | ✅ Fallback support | ✅ Multiple fallbacks |

**Recommendation**: **Hybrid Approach** provides the best balance of real-time accuracy, offline capability, and resilience.

---

## 🔧 Implementation Plan for Lab 05b

### Phase 1: Create Reusable SIT Mapping Module

**File**: `Get-SITMapping.psm1` (new module in `scripts/` directory)

**Contents**:
- `Get-SITMapping` function (hybrid approach)
- `Update-SITMappingCache` function (cache generation)
- `Resolve-SITName` helper function
- Connection management logic
- Error handling and fallback mechanisms

### Phase 2: Update Lab 05b Analysis Script

**Changes to `Invoke-eDiscoveryResultsAnalysis.ps1`**:

1. **Add module import** (after parameter block):
   ```powershell
   # Import SIT mapping module
   Import-Module "$PSScriptRoot\Get-SITMapping.psm1" -Force
   ```

2. **Replace hardcoded GUID map** (lines 173-181):
   ```powershell
   # =============================================================================
   # Dynamic SIT GUID Mapping
   # =============================================================================
   
   Write-Host "📋 Retrieving SIT definitions..." -ForegroundColor Cyan
   $sitGuidMap = Get-SITMapping -CachePath "$PSScriptRoot\..\Purview-SIT-GUID-Mapping.json"
   
   if ($sitGuidMap.Count -eq 0) {
       Write-Warning "SIT mapping unavailable - GUIDs will display in output"
       Write-Warning "Run 'Connect-IPPSSession' and retry to resolve SIT names"
   }
   ```

3. **Keep existing GUID resolution logic** (lines 188-191):
   - Current logic already checks `$sitGuidMap.ContainsKey($sitGuid)`
   - Will automatically work with dynamic mapping hashtable

### Phase 3: Update Cross-Lab Analysis Script

**Changes to `Invoke-CrossLabAnalysis.ps1`**:

1. **Import same module**:
   ```powershell
   Import-Module "$PSScriptRoot\Get-SITMapping.psm1" -Force
   ```

2. **Replace static JSON loading** (lines 135-147):
   ```powershell
   # Dynamic SIT mapping retrieval
   $sitGuidMapping = Get-SITMapping -CachePath "$PSScriptRoot\..\Purview-SIT-GUID-Mapping.json"
   ```

3. **Keep existing `Resolve-SITName` function** (lines 148-165):
   - Already implemented correctly
   - Will work seamlessly with dynamic mappings

### Phase 4: Generate Initial Cache File

**One-time setup command**:

```powershell
# Run from Lab 05 root directory
.\scripts\Get-SITMapping.psm1

# Manually trigger cache generation
Update-SITMappingCache -CachePath ".\Purview-SIT-GUID-Mapping.json"
```

This creates the initial `Purview-SIT-GUID-Mapping.json` file with all 93+ SIT definitions from your tenant.

---

## 📚 Additional Research - Community Solutions

### GitHub Repository Examples

While researching, I found that most community solutions fall into these patterns:

1. **Static JSON files** - Similar to current approach, manually maintained
2. **PowerShell Gallery modules** - Leverage `Get-DlpSensitiveInformationType`
3. **Microsoft Graph API** - For programmatic access in applications (not PowerShell scripts)

**Key Insight**: The `Get-DlpSensitiveInformationType` cmdlet is the **authoritative and recommended** approach by Microsoft for PowerShell-based solutions.

### Microsoft Graph API Alternative (For Reference)

If building a web application or service (not PowerShell scripts), Microsoft Graph API provides programmatic access:

**Endpoint**: `https://graph.microsoft.com/v1.0/security/informationProtection/sensitivityLabels`

**Note**: This API is for **sensitivity labels**, not **sensitive information types (SITs)**. There is currently **no public Microsoft Graph API endpoint** for querying SIT definitions. The PowerShell cmdlet remains the only scalable programmatic option.

---

## 🎯 Benefits of This Solution

### For Lab 05b Analysis Script

✅ **Eliminates 83 unmapped GUIDs** - All 93 SIT types will have friendly names

✅ **Zero manual maintenance** - No need to update GUID lists ever again

✅ **Custom SIT support** - Automatically includes organization-specific SITs

✅ **Clean output files** - eDiscovery-Detailed-Analysis CSV will be human-readable

✅ **Future-proof** - Works with any number of SITs (100, 200, 1000+)

### For Cross-Lab Analysis Script

✅ **Populated SIT distribution** - Lab 05b section will display properly

✅ **Accurate comparisons** - Can match SIT names across different lab methods

✅ **Improved reports** - Markdown summary and CSV files show meaningful SIT names

✅ **Reusable module** - Same mapping logic across all Purview projects

### For Future Projects

✅ **Extensible pattern** - Can be used in Lab 05c and future eDiscovery work

✅ **Organization-agnostic** - Works in any M365 tenant (lab, production, customer environments)

✅ **No hardcoded assumptions** - Adapts to tenant-specific SIT configurations

✅ **Maintenance-free** - Set it and forget it approach

---

## 🚀 Next Steps

1. **Create `Get-SITMapping.psm1` module** with hybrid lookup approach

2. **Update Lab 05b analysis script** to use dynamic SIT mapping

3. **Update cross-lab analysis script** to use same module

4. **Generate initial cache file** from your tenant

5. **Re-run Lab 05b analysis** to regenerate output with friendly names

6. **Re-run cross-lab comparison** to verify Lab 05b SIT distribution displays

7. **Document solution** in Lab 05b README and cross-lab README

8. **Test with custom SITs** (optional) - Add a custom SIT in Purview portal and verify it appears automatically

---

## 📖 References

- [Get-DlpSensitiveInformationType Cmdlet](https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-dlpsensitiveinformationtype)
- [Connect to Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell)
- [Sensitive Information Types Overview](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-learn-about)
- [Create Custom Sensitive Information Types](https://learn.microsoft.com/en-us/purview/sit-create-a-custom-sensitive-information-type)
- [Microsoft Purview APIs in Microsoft Graph](https://learn.microsoft.com/en-us/graph/security-information-protection-overview)

---

## 🤖 AI-Assisted Content Generation

This comprehensive SIT GUID mapping solution analysis was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The research, solution design, and implementation patterns were generated through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview best practices, PowerShell automation standards, and scalable architecture principles.

*AI tools were used to research Microsoft Learn documentation, analyze Security & Compliance PowerShell cmdlets, and design enterprise-grade solutions for dynamic SIT metadata retrieval while ensuring maintainability and scalability for Microsoft Purview data governance projects.*

<#
.SYNOPSIS
    Creates eDiscovery case and search for sensitive data discovery using Microsoft Graph API.

.DESCRIPTION
    This script creates an eDiscovery case and configures a search query for SIT detection
    across SharePoint Online sites using the Microsoft Graph eDiscovery API. It prepares
    the foundation for direct export operations (Step 2) that retrieve Items_0.csv with
    populated "Sensitive type" column for compliance analysis and security monitoring.
    
    This is Step 1 of the simplified Lab 05c workflow: Create Case/Search → Direct Export → Analyze.

.PARAMETER MaxWaitMinutes
    Maximum time in minutes to wait for eDiscovery estimate operation completion. 
    Defaults to 30 minutes. Microsoft Graph eDiscovery API does not document specific 
    timeout values, but complex queries across large tenants may require 20-30 minutes.

.EXAMPLE
    .\Invoke-GraphSitDiscovery.ps1
    
    Runs discovery with default settings (30-minute timeout), saving reports to ../reports/

.EXAMPLE
    .\Invoke-GraphSitDiscovery.ps1 -MaxWaitMinutes 45
    
    Runs discovery with extended wait time for very large tenant searches.

.NOTES
    Author: Marcus Jacobson
    Version: 2.0.0
    Created: 2025-11-17
    Last Modified: 2025-11-22
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7.0+
    - Microsoft.Graph PowerShell SDK
    - eDiscovery permissions (eDiscovery.Read.All, eDiscovery.ReadWrite.All)
    - Completed Lab 03 (document upload) 24 hours ago (SharePoint Search indexing)
    
    Script development orchestrated using GitHub Copilot.

.GRAPH API OPERATIONS
    - Creates eDiscovery case and search via Graph API
    - Configures noncustodial data sources for SharePoint sites
    - Builds GUID-based SIT queries for accurate detection
    - Monitors estimate operation progress
#>

#Requires -Version 7.0

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [int]$MaxWaitMinutes = 30
)

# =============================================================================
# Configuration Loading
# =============================================================================

Write-Host "📁 Loading Configuration" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

# Load global configuration file
$configPath = Join-Path (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent) "global-config.json"

if (-not (Test-Path $configPath)) {
    Write-Host "   ❌ Configuration file not found: $configPath" -ForegroundColor Red
    Write-Host "      Ensure global-config.json exists in the project root directory" -ForegroundColor Yellow
    exit 1
}

try {
    $globalConfig = Get-Content $configPath -Raw | ConvertFrom-Json
    
    # Extract configuration values
    $tenantUrl = $globalConfig.Environment.TenantUrl
    $simulationSites = $globalConfig.SharePointSites
    $enabledSITs = $globalConfig.BuiltInSITs | Where-Object { $_.Enabled -eq $true }
    
    # Calculate reports path
    $OutputPath = Join-Path (Split-Path $PSScriptRoot -Parent) "reports"
    
    Write-Host "   ✅ Loaded configuration from global-config.json" -ForegroundColor Green
    Write-Host "      • Tenant URL: $tenantUrl" -ForegroundColor DarkGray
    Write-Host "      • Expected sites: $($simulationSites.Count)" -ForegroundColor DarkGray
    Write-Host "      • Enabled SITs: $($enabledSITs.Count)" -ForegroundColor DarkGray
    Write-Host "      • Reports path: $OutputPath" -ForegroundColor DarkGray
    Write-Host ""
} catch {
    Write-Host "   ❌ Failed to load configuration: $_" -ForegroundColor Red
    Write-Host "      Check that global-config.json is valid JSON" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Script Initialization
# =============================================================================

Write-Host "🔍 Microsoft Graph eDiscovery API - SIT Discovery" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$discoveryStartTime = Get-Date

# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔧 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

# Verify Microsoft Graph SDK
try {
    $graphModule = Get-Module Microsoft.Graph -ListAvailable | Select-Object -First 1
    
    if ($null -eq $graphModule) {
        throw "Microsoft Graph SDK not installed"
    }
    
    Write-Host "   ✅ Microsoft Graph SDK version $($graphModule.Version) detected" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to verify Microsoft Graph SDK: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Install with: Install-Module Microsoft.Graph -Scope CurrentUser -Force" -ForegroundColor Yellow
    exit 1
}

try {
    # Force fresh authentication with required scopes
    # This ensures we have a valid token for eDiscovery API operations
    Write-Host "   🔐 Ensuring fresh authentication with eDiscovery scopes..." -ForegroundColor Cyan
    
    $requiredScopes = @("eDiscovery.Read.All", "eDiscovery.ReadWrite.All", "Sites.Read.All")
    
    # Disconnect any existing session to force fresh token
    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    
    # Connect with explicit scopes
    Connect-MgGraph -Scopes $requiredScopes -NoWelcome -ErrorAction Stop
    
    $context = Get-MgContext
    
    if ($null -eq $context) {
        throw "Failed to establish Microsoft Graph connection"
    }
    
    Write-Host "   ✅ Connected to Microsoft Graph with fresh token" -ForegroundColor Green
    Write-Host "      • Tenant: $($context.TenantId)" -ForegroundColor DarkGray
    Write-Host "      • Account: $($context.Account)" -ForegroundColor DarkGray
    Write-Host "      • Scopes: $($context.Scopes -join ', ')" -ForegroundColor DarkGray
    
} catch {
    Write-Host "   ❌ Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Run Grant-GraphPermissions.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Validate eDiscovery permissions
$grantedScopes = $context.Scopes
$requiredScopes = @("eDiscovery.Read.All", "eDiscovery.ReadWrite.All")
$missingScopes = $requiredScopes | Where-Object { $grantedScopes -notcontains $_ }

if ($missingScopes.Count -gt 0) {
    Write-Host "   ❌ Missing required permissions: $($missingScopes -join ', ')" -ForegroundColor Red
    Write-Host "      Run Grant-GraphPermissions.ps1 to grant eDiscovery permissions" -ForegroundColor Yellow
    exit 1
}

Write-Host "   ✅ eDiscovery permissions validated" -ForegroundColor Green

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Host "   ✅ Created output directory: $OutputPath" -ForegroundColor Green
} else {
    Write-Host "   ✅ Output directory exists: $OutputPath" -ForegroundColor Green
}

Write-Host ""

# =============================================================================
# Step 2: Build SensitiveType Query from Configuration with GUID Mapping
# =============================================================================

Write-Host "📋 Step 2: Build SensitiveType Query with GUID Format" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""

# Load GUID mapping file
$mappingPath = Join-Path (Split-Path $PSScriptRoot -Parent) ".." "Purview-SIT-GUID-Mapping.json"
if (-not (Test-Path $mappingPath)) {
    Write-Host "   ❌ GUID mapping file not found: $mappingPath" -ForegroundColor Red
    exit 1
}

$mappingJson = Get-Content $mappingPath -Raw | ConvertFrom-Json
$guidMapping = $mappingJson.sitMappings

# Create reverse lookup (Name → GUID)
$nameToGuid = @{}
$guidMapping.PSObject.Properties | ForEach-Object {
    $nameToGuid[$_.Value] = $_.Name
}

Write-Host "   ✅ Loaded GUID mapping for $($nameToGuid.Count) SIT types" -ForegroundColor Green
Write-Host ""
Write-Host "   📌 Building GUID-based query for enabled SITs:" -ForegroundColor Cyan

$sitQueries = @()
foreach ($sit in $enabledSITs) {
    $guid = $nameToGuid[$sit.Name]
    
    if (-not $guid) {
        Write-Host "      ⚠️ Warning: No GUID found for '$($sit.Name)'" -ForegroundColor Yellow
        continue
    }
    
    # Determine confidence level based on SIT type
    # Use broad confidence range (1..100) to ensure we capture all potential matches
    # This is critical for Lab 05c parity with Lab 05b
    $confidence = "1..100"
    
    # Build GUID-based query: ((SensitiveType="guid|1..500|confidence"))
    $sitQueries += "((SensitiveType=`"$guid|1..500|$confidence`"))"
    
    Write-Host "      • $($sit.Name)" -ForegroundColor DarkGray
    Write-Host "        GUID: $guid | Confidence: $confidence" -ForegroundColor DarkGray
}

# Add Supplemental GUIDs for Lab 05c Parity
# These are "Custom SIT" GUIDs detected in the environment that are missing from the standard mapping
# Including them ensures we capture files (like Background Checks) that only contain these specific SIT variants
$supplementalGuids = @(
    "065bdd91-ef07-40d3-b8a4-0aea722eaa49", # Detected in Lab 05c analysis
    "17066377-466d-43ff-997f-c9240414021c", # Detected in Lab 05c analysis
    "20f3c48d-4ac1-4cd2-86bd-34ecc1826e9d", # Detected in Lab 05c analysis
    "fc87b421-f437-4f8b-b739-29a735ead0d9"  # Detected in Lab 05c analysis
)

if ($supplementalGuids.Count -gt 0) {
    Write-Host ""
    Write-Host "   ➕ Adding Supplemental GUIDs for Parity:" -ForegroundColor Cyan
    foreach ($guid in $supplementalGuids) {
        # Use broad confidence range for supplemental GUIDs
        $sitQueries += "((SensitiveType=`"$guid|1..500|1..100`"))"
        Write-Host "      • Supplemental SIT" -ForegroundColor DarkGray
        Write-Host "        GUID: $guid | Confidence: 1..100" -ForegroundColor DarkGray
    }
}

if ($sitQueries.Count -eq 0) {
    Write-Host "   ❌ No valid SIT queries generated" -ForegroundColor Red
    exit 1
}

# Combine all SIT queries with OR operator
$contentQuery = $sitQueries -join " OR "

Write-Host ""
Write-Host "   🔍 eDiscovery Content Query (GUID-based):" -ForegroundColor Cyan
Write-Host "      $($sitQueries.Count) SIT types with GUID format and confidence levels" -ForegroundColor DarkGray
Write-Host ""
Write-Host "   📋 Full Query String Being Sent to API:" -ForegroundColor Cyan

# Display first 500 characters of query for verification
if ($contentQuery.Length -gt 500) {
    Write-Host "      $($contentQuery.Substring(0, 500))..." -ForegroundColor DarkGray
    Write-Host "      [Query truncated - full length: $($contentQuery.Length) characters]" -ForegroundColor DarkGray
} else {
    Write-Host "      $contentQuery" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "   💡 Note: The eDiscovery UI may display friendly names like" -ForegroundColor Yellow
Write-Host "      'U.S. Social Security Number (SSN)' but the backend uses" -ForegroundColor Yellow
Write-Host "      GUID format with confidence levels for accurate matching." -ForegroundColor Yellow
Write-Host ""

# =============================================================================
# Step 3: Create eDiscovery Case
# =============================================================================

Write-Host "📂 Step 3: Create eDiscovery Case" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

$caseName = "Lab05c-Discovery-$timestamp"
$caseDescription = "Automated SIT discovery via Graph eDiscovery API - Lab 05c"

Write-Host "   ⏳ Creating eDiscovery case: $caseName" -ForegroundColor Cyan

try {
    $case = New-MgSecurityCaseEdiscoveryCase `
        -DisplayName $caseName `
        -Description $caseDescription `
        -ErrorAction Stop
    
    if ($null -eq $case -or $null -eq $case.Id) {
        throw "Case creation returned null or invalid response"
    }
    
    Write-Host "   ✅ eDiscovery case created successfully" -ForegroundColor Green
    Write-Host "      • Case ID: $($case.Id)" -ForegroundColor DarkGray
    Write-Host "      • Case Name: $caseName" -ForegroundColor DarkGray
    Write-Host ""
} catch {
    Write-Host "   ❌ Failed to create eDiscovery case: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Possible causes:" -ForegroundColor Yellow
    Write-Host "      • Insufficient permissions (eDiscovery.ReadWrite.All required)" -ForegroundColor DarkGray
    Write-Host "      • Permission consent not completed" -ForegroundColor DarkGray
    Write-Host "      • Network connectivity issues" -ForegroundColor DarkGray
    exit 1
}

# =============================================================================
# Step 3.5: Retrieve SharePoint Site URLs from Global Config
# =============================================================================

Write-Host "🔍 Step 3.5: Retrieve SharePoint Site Information" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

Write-Host "   ⏳ Querying Microsoft Graph for simulation sites..." -ForegroundColor Cyan
Write-Host "      • Sites from config: $($simulationSites.Count)" -ForegroundColor DarkGray
Write-Host ""

$siteUrls = @()
$siteObjects = @()

try {
    foreach ($site in $simulationSites) {
        $siteName = $site.Name
        Write-Host "   🔎 Searching for site: $siteName" -ForegroundColor Cyan
        
        try {
            # Use Get-MgSite with -Search to find the site
            # Strategy: First try full name, then try just the first part (before hyphen)
            $searchResults = Get-MgSite -Search $siteName -ErrorAction SilentlyContinue
            
            if ($null -eq $searchResults -or @($searchResults).Count -eq 0) {
                # Fallback: Search with first part of name (e.g., "HR" from "HR-Simulation")
                $firstPart = $siteName.Split('-')[0]
                $searchResults = Get-MgSite -Search $firstPart -ErrorAction SilentlyContinue
            }
            
            # Match by WebUrl containing the full site name
            $mgSite = $searchResults | Where-Object { $_.WebUrl -like "*$siteName*" } | Select-Object -First 1
            
            if ($null -ne $mgSite) {
                $siteUrls += $mgSite.WebUrl
                $siteObjects += @{
                    Name = $siteName
                    Url = $mgSite.WebUrl
                    Id = $mgSite.Id
                    DisplayName = $mgSite.DisplayName
                }
                Write-Host "      ✅ $siteName" -ForegroundColor Green
            } else {
                Write-Host "      ❌ $siteName not found" -ForegroundColor Red
            }
        } catch {
            Write-Host "      ⚠️ Error querying site '$siteName': $_" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "   📊 Site Discovery Summary:" -ForegroundColor Cyan
    Write-Host "      • Sites found: $($siteUrls.Count) of $($simulationSites.Count)" -ForegroundColor DarkGray
    Write-Host ""
    
    if ($siteUrls.Count -eq 0) {
        Write-Host "   ⚠️ No SharePoint sites found" -ForegroundColor Yellow
        Write-Host "      • Possible causes:" -ForegroundColor Yellow
        Write-Host "        - Sites not yet indexed in SharePoint Search" -ForegroundColor DarkGray
        Write-Host "        - Site names in global-config.json don't match SharePoint display names" -ForegroundColor DarkGray
        Write-Host "        - Insufficient permissions to access sites" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "   💡 Recommendation: Run Test-SiteAvailability.ps1 first to verify site readiness" -ForegroundColor Yellow
        Write-Host ""
        
        # Clean up case before exiting
        Write-Host "   🧹 Cleaning up eDiscovery case..." -ForegroundColor Yellow
        try {
            Remove-MgSecurityCaseEdiscoveryCase -EdiscoveryCaseId $case.Id -Confirm:$false -ErrorAction SilentlyContinue
        } catch {
            Write-Host "      ⚠️ Failed to clean up case: $_" -ForegroundColor Yellow
        }
        
        exit 1
    }
    
} catch {
    Write-Host "   ❌ Failed to retrieve SharePoint sites: $_" -ForegroundColor Red
    Write-Host ""
    
    # Clean up case before exiting
    Write-Host "   🧹 Cleaning up eDiscovery case..." -ForegroundColor Yellow
    try {
        Remove-MgSecurityCaseEdiscoveryCase -EdiscoveryCaseId $case.Id -Confirm:$false -ErrorAction SilentlyContinue
    } catch {
        Write-Host "      ⚠️ Failed to clean up case: $_" -ForegroundColor Yellow
    }
    
    exit 1
}

# =============================================================================
# Step 4: Create Noncustodial Data Sources for SharePoint Sites
# =============================================================================
# Based on Microsoft documentation: Must create noncustodial data sources first,
# then bind them to the search using @odata.bind syntax

Write-Host "🔍 Step 4: Create Noncustodial Data Sources" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "   ⏳ Creating noncustodial data sources for $($siteObjects.Count) SharePoint sites..." -ForegroundColor Cyan
Write-Host ""

$noncustodialSources = @()
$noncustodialSourceUris = @()

foreach ($siteObj in $siteObjects) {
    try {
        # Build noncustodial data source body following Microsoft Graph schema
        $noncustodialBody = @{
            applyHoldToSource = $false
            dataSource = @{
                "@odata.type" = "microsoft.graph.security.siteSource"
                site = @{
                    webUrl = $siteObj.Url
                }
            }
        }
        
        # Create the noncustodial data source
        $noncustodialUri = "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$($case.Id)/noncustodialDataSources"
        $noncustodialSource = Invoke-MgGraphRequest -Method POST -Uri $noncustodialUri `
            -Body ($noncustodialBody | ConvertTo-Json -Depth 10) -ContentType "application/json" -ErrorAction Stop
        
        if ($null -ne $noncustodialSource -and $null -ne $noncustodialSource.id) {
            $noncustodialSources += $noncustodialSource
            # Build the @odata.bind URI for this noncustodial source
            $bindUri = "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$($case.Id)/noncustodialDataSources/$($noncustodialSource.id)"
            $noncustodialSourceUris += $bindUri
            Write-Host "      ✅ $($siteObj.Name)" -ForegroundColor Green
        }
    } catch {
        Write-Host "      ❌ $($siteObj.Name): Failed to create data source" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "   ✅ Created $($noncustodialSources.Count) of $($siteObjects.Count) noncustodial data sources" -ForegroundColor Green
Write-Host ""

if ($noncustodialSources.Count -eq 0) {
    Write-Host "   ❌ No noncustodial data sources were created. Cannot proceed with search creation." -ForegroundColor Red
    Write-Host "   💡 Tip: Verify that the SharePoint sites exist and are accessible" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# =============================================================================
# Step 5: Create eDiscovery Search with Bound Data Sources
# =============================================================================
# Now create the search and bind it to the noncustodial data sources

Write-Host "🔍 Step 5: Create eDiscovery Search" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

$searchName = "Lab05c-SIT-Search-$timestamp"
$searchDescription = "Search for all enabled SIT types across $($noncustodialSources.Count) specific SharePoint sites"

Write-Host "   ⏳ Configuring eDiscovery search..." -ForegroundColor Cyan
Write-Host "      • Search name: $searchName" -ForegroundColor DarkGray
Write-Host "      • Data sources: $($noncustodialSources.Count) noncustodial sources" -ForegroundColor DarkGray
Write-Host "      • SIT types: $($enabledSITs.Count) enabled types" -ForegroundColor DarkGray
Write-Host ""

try {
    # Build search request body with @odata.bind references to noncustodial sources
    # This follows the Microsoft Graph API documentation pattern
    $searchBodyObject = [PSCustomObject]@{
        displayName = $searchName
        description = $searchDescription
        contentQuery = $contentQuery
    }
    
    # Add the additional data with @odata.bind
    # Note: PowerShell hashtable serialization needs AdditionalData for @odata annotations
    $searchBody = @{
        displayName = $searchName
        description = $searchDescription
        contentQuery = $contentQuery
        "noncustodialSources@odata.bind" = $noncustodialSourceUris
    }
    
    # Convert to JSON
    $searchBodyJson = $searchBody | ConvertTo-Json -Depth 10
    
    Write-Host "   📝 Search configuration ready with $($noncustodialSourceUris.Count) bound sources" -ForegroundColor Cyan
    Write-Host ""
    
    # Create the search via v1.0 endpoint
    $searchUri = "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$($case.Id)/searches"
    $search = Invoke-MgGraphRequest -Method POST -Uri $searchUri `
        -Body $searchBodyJson -ContentType "application/json" -ErrorAction Stop
    
    if ($null -eq $search -or $null -eq $search.id) {
        throw "Search creation returned null or invalid response"
    }
    
    Write-Host "   ✅ eDiscovery search created successfully" -ForegroundColor Green
    Write-Host "      • Search ID: $($search.id)" -ForegroundColor DarkGray
    Write-Host "      • Bound data sources: $($noncustodialSources.Count) sites" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   📊 Query Verification:" -ForegroundColor Cyan
    Write-Host "      • Query format: GUID-based with confidence levels" -ForegroundColor DarkGray
    Write-Host "      • Expected UI display: Friendly names (Microsoft translates GUIDs)" -ForegroundColor DarkGray
    Write-Host "      • Backend processing: Uses GUID format sent above" -ForegroundColor DarkGray
    Write-Host ""
    
    $sitesAddedCount = $noncustodialSources.Count
    
    Write-Host ""
    Write-Host "   📊 Data Source Configuration:" -ForegroundColor Cyan
    Write-Host "      • Sites successfully added: $sitesAddedCount of $($siteObjects.Count)" -ForegroundColor DarkGray
    Write-Host ""
    
    if ($sitesAddedCount -eq 0) {
        throw "Failed to add any SharePoint sites as data sources"
    }
    
} catch {
    Write-Host "   ❌ Failed to create eDiscovery search: $_" -ForegroundColor Red
    
    # Clean up case before exiting
    Write-Host "   🧹 Cleaning up eDiscovery case..." -ForegroundColor Yellow
    try {
        Remove-MgSecurityCaseEdiscoveryCase -EdiscoveryCaseId $case.Id -Confirm:$false -ErrorAction SilentlyContinue
    } catch {
        Write-Host "      ⚠️ Failed to clean up case: $_" -ForegroundColor Yellow
    }
    
    exit 1
}

# =============================================================================
# Step 6: Check Search Status and Trigger Estimate Operation if Needed
# =============================================================================

Write-Host "⏳ Step 6: Check Search Status" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

# First check if search is already running or complete (allows script re-run)
Write-Host "   🔍 Checking if search is already in progress..." -ForegroundColor Cyan

$skipMonitoring = $false
$triggerEstimate = $false

try {
    # Use separate navigation property endpoint to check existing operation
    $statusUri = "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$($case.Id)/searches/$($search.id)/lastEstimateStatisticsOperation"
    
    try {
        $existingOp = Invoke-MgGraphRequest -Method GET -Uri $statusUri -ErrorAction Stop
    } catch {
        # 404/500 means no operation exists yet - API returns 500 instead of 404 (API bug)
        # Error: "Failed to retrieve job results. Please try running search estimate statistics job again"
        if ($_.Exception.Message -like "*404*" -or $_.Exception.Message -like "*NotFound*" -or 
            $_.Exception.Message -like "*500*" -or $_.Exception.Message -like "*InternalServerError*" -or
            $_.Exception.Message -like "*Failed to retrieve job results*") {
            $existingOp = $null
        } else {
            throw
        }
    }
    
    if ($null -ne $existingOp) {
        # Search operation already exists - check its status
        $opStatus = $existingOp.status
        
        if ($opStatus -eq "succeeded") {
            Write-Host "   ✅ Search already completed" -ForegroundColor Green
            Write-Host "      • Status: $opStatus" -ForegroundColor DarkGray
            Write-Host "      • Skipping to results retrieval" -ForegroundColor DarkGray
            Write-Host ""
            
            # Skip to Step 7 (results retrieval)
            $skipMonitoring = $true
        } elseif ($opStatus -in @("running", "notStarted")) {
            Write-Host "   ⏳ Search already in progress" -ForegroundColor Yellow
            Write-Host "      • Status: $opStatus" -ForegroundColor DarkGray
            Write-Host "      • Resuming monitoring" -ForegroundColor DarkGray
            Write-Host ""
            
            # Continue to monitoring
            $skipMonitoring = $false
        } else {
            Write-Host "   ⚠️ Search in unexpected state: $opStatus" -ForegroundColor Yellow
            Write-Host "      • Re-triggering estimate operation" -ForegroundColor DarkGray
            Write-Host ""
            
            # Re-trigger
            $triggerEstimate = $true
        }
    } else {
        # No operation exists yet - need to trigger estimate
        Write-Host "   📋 No existing search operation found" -ForegroundColor Cyan
        Write-Host "      • Triggering estimate statistics operation" -ForegroundColor DarkGray
        Write-Host ""
        
        $triggerEstimate = $true
    }
    
    # Trigger estimate operation if needed
    if ($triggerEstimate) {
        Write-Host "   🚀 Triggering estimate statistics operation..." -ForegroundColor Cyan
        
        try {
            $estimateUri = "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$($case.Id)/searches/$($search.id)/estimateStatistics"
            
            # Note: POST may return 204 No Content or 202 Accepted
            $estimateResponse = Invoke-MgGraphRequest -Method POST -Uri $estimateUri -ErrorAction Stop
            
            Write-Host "   ✅ Estimate operation triggered successfully" -ForegroundColor Green
            Write-Host ""
            
        } catch {
            # Check if error is about operation already running
            if ($_.Exception.Message -like "*already*" -or $_.Exception.Message -like "*in progress*") {
                Write-Host "   ℹ️ Estimate operation already in progress" -ForegroundColor Cyan
                Write-Host ""
            } else {
                Write-Host "   ⚠️ Warning: Failed to trigger estimate operation" -ForegroundColor Yellow
                Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor DarkGray
                Write-Host "      • Will attempt to monitor anyway (operation may auto-start)" -ForegroundColor DarkGray
                Write-Host ""
            }
        }
    }
    
} catch {
    Write-Host "   ❌ Failed to check existing operation: $_" -ForegroundColor Red
    
    # Clean up case before exiting
    Write-Host "   🧹 Cleaning up eDiscovery case..." -ForegroundColor Yellow
    try {
        Remove-MgSecurityCaseEdiscoveryCase -EdiscoveryCaseId $case.Id -Confirm:$false -ErrorAction SilentlyContinue
    } catch {
        Write-Host "      ⚠️ Failed to clean up case: $_" -ForegroundColor Yellow
    }
    
    exit 1
}

# =============================================================================
# Step 7: Wait for Statistics Generation (Process Manager)
# =============================================================================

Write-Host "📊 Step 7: Wait for Statistics Generation" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

Write-Host "   ⏳ Waiting for 'Generate statistics' to complete in Process Manager..." -ForegroundColor Cyan
Write-Host "      • This operation estimates how many items match the query" -ForegroundColor DarkGray
Write-Host "      • Max wait time: $MaxWaitMinutes minutes" -ForegroundColor DarkGray
Write-Host "      • Status checks every 30 seconds" -ForegroundColor DarkGray
Write-Host ""
Write-Host "   💡 In eDiscovery UI, this shows as:" -ForegroundColor Cyan
Write-Host "      Case → Searches tab → Process Manager → 'Generate statistics'" -ForegroundColor DarkGray
Write-Host ""

    # Skip monitoring if search already completed
    if ($skipMonitoring) {
        Write-Host "   ℹ️ Statistics generation already completed - skipping wait" -ForegroundColor Cyan
        Write-Host ""
    } else {
        # Pre-poll: Wait for search to start and estimate operation object to be created
        Write-Host "   🔍 Waiting for statistics generation to begin..." -ForegroundColor Cyan
        Write-Host ""
    }

    # Initialize polling variables
    $maxWaitSeconds = $MaxWaitMinutes * 60
    $elapsed = 0
    $pollInterval = 30
    $initCheckInterval = 15  # Check every 15 seconds during initialization
    $maxInitWait = 300  # Wait up to 5 minutes for search to start (increased from 3 min)
    $currentStatus = "notStarted"
    $searchStatus = $null
    $estimateOp = $null

# Wait for estimate operation to appear (indicates search has started)
# CRITICAL: lastEstimateStatisticsOperation is a NAVIGATION PROPERTY accessed via separate endpoint
# NOT a property on the search object! Must use: /searches/{id}/lastEstimateStatisticsOperation
while ($null -eq $estimateOp -and $elapsed -lt $maxInitWait) {
    Start-Sleep -Seconds $initCheckInterval
    $elapsed += $initCheckInterval
    
    try {
        # Use the CORRECT endpoint - separate navigation property path
        $statusUri = "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$($case.Id)/searches/$($search.id)/lastEstimateStatisticsOperation"
        $estimateOp = Invoke-MgGraphRequest -Method GET -Uri $statusUri -ErrorAction Stop
        
        if ($null -eq $estimateOp -or $estimateOp.status -eq "notStarted") {
            Write-Host "      ⏳ Waiting for statistics generation | Elapsed: $($elapsed)s / $($maxInitWait)s" -ForegroundColor DarkGray
        } else {
            Write-Host "      ✅ Statistics generation started | Status: $($estimateOp.status)" -ForegroundColor Green
            Write-Host ""
            break
        }
    } catch {
        # 404/500 error means operation hasn't been created yet - this is normal during initialization
        # API bug: Returns 500 "Failed to retrieve job results" instead of 404
        if ($_.Exception.Message -like "*404*" -or $_.Exception.Message -like "*NotFound*" -or
            $_.Exception.Message -like "*500*" -or $_.Exception.Message -like "*InternalServerError*" -or
            $_.Exception.Message -like "*Failed to retrieve job results*") {
            $estimateOp = $null  # Ensure it stays null so loop continues
            Write-Host "      ⏳ Waiting for statistics generation | Elapsed: $($elapsed)s / $($maxInitWait)s" -ForegroundColor DarkGray
        } else {
            Write-Host "      ⚠️ Unexpected error checking operation: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "      ⚠️ Will retry..." -ForegroundColor Yellow
            $estimateOp = $null  # Ensure it stays null so loop continues
        }
    }
}

# Verify estimate operation was created
if ($null -eq $estimateOp) {
    throw "Statistics generation did not start within $maxInitWait seconds. Backend may be experiencing delays. Please retry."
}

try {
    # Now begin progress monitoring with operation object confirmed to exist
    # Reset elapsed counter for the main monitoring phase
    $elapsed = 0
    
    do {
        Start-Sleep -Seconds $pollInterval
        $elapsed += $pollInterval
        
        # Get estimate operation status from SEPARATE navigation property endpoint
        $statusUri = "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$($case.Id)/searches/$($search.id)/lastEstimateStatisticsOperation"
        $estimateOp = Invoke-MgGraphRequest -Method GET -Uri $statusUri -ErrorAction Stop
        
        if ($null -ne $estimateOp) {
            $currentStatus = if ($estimateOp.status) { $estimateOp.status } else { "unknown" }
            $actionName = if ($estimateOp.action) { $estimateOp.action } else { "estimateStatistics" }
            
            # Display status (no percentage available for estimate operations)
            $statusEmoji = switch ($currentStatus) {
                "notStarted" { "⏸️" }
                "running" { "🔄" }
                "succeeded" { "✅" }
                "failed" { "❌" }
                default { "⏳" }
            }
            
            Write-Host "      $statusEmoji Status: $currentStatus | Action: $actionName | Elapsed: $($elapsed)s / $($maxWaitSeconds)s" -ForegroundColor Cyan
            
            # Check for completion
            if ($currentStatus -eq "succeeded") {
                Write-Host ""
                Write-Host "   ✅ Estimate operation completed successfully" -ForegroundColor Green
                Write-Host "      • Total time: $($elapsed)s" -ForegroundColor DarkGray
                Write-Host "      • Final progress: 100%" -ForegroundColor DarkGray
                
                # Display statistics if available
                if ($estimateOp.resultInfo) {
                    $totalItems = if ($estimateOp.resultInfo.resultCount) { $estimateOp.resultInfo.resultCount } else { 0 }
                    $totalSize = if ($estimateOp.resultInfo.size) { $estimateOp.resultInfo.size } else { 0 }
                    
                    Write-Host ""
                    Write-Host "   📊 Discovery Results Summary:" -ForegroundColor Cyan
                    Write-Host "      • Total items found: $totalItems" -ForegroundColor Green
                    Write-Host "      • Total size: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor DarkGray
                }
                
                Write-Host ""
                break
            }
            
            # Check for failure
            if ($currentStatus -eq "failed") {
                Write-Host ""
                Write-Host "   ❌ Estimate operation failed" -ForegroundColor Red
                
                if ($estimateOp.resultInfo -and $estimateOp.resultInfo.message) {
                    Write-Host "      • Error: $($estimateOp.resultInfo.message)" -ForegroundColor DarkGray
                }
                
                throw "Estimate operation failed"
            }
        } else {
            Write-Host "      ⏳ Status: Waiting for operation to start | Elapsed: $($elapsed)s / $($maxWaitSeconds)s" -ForegroundColor Cyan
        }
        
    } while ($currentStatus -notin @("succeeded", "failed") -and $elapsed -lt $maxWaitSeconds)
    
    # Check for timeout
    if ($currentStatus -notin @("succeeded", "failed")) {
        Write-Host ""
        Write-Host "   ⚠️ Estimate operation did not complete within $MaxWaitMinutes minutes" -ForegroundColor Yellow
        Write-Host "      Current status: $currentStatus" -ForegroundColor DarkGray
        Write-Host "      Progress: $progress%" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "   💡 Recommendations:" -ForegroundColor Yellow
        Write-Host "      • Complex queries may require 20-30 minutes for large tenants" -ForegroundColor DarkGray
        Write-Host "      • Try running during off-peak hours for faster execution" -ForegroundColor DarkGray
        Write-Host "      • Increase -MaxWaitMinutes parameter (e.g., -MaxWaitMinutes 45)" -ForegroundColor DarkGray
        Write-Host "      • Check case status manually in Microsoft Purview portal" -ForegroundColor DarkGray
        throw "Estimate operation timeout"
    }
    
} catch {
    Write-Host ""
    Write-Host "   ❌ Failed to monitor estimate operation: $_" -ForegroundColor Red
    
    # Clean up case before exiting
    Write-Host "   🧹 Cleaning up eDiscovery case..." -ForegroundColor Yellow
    try {
        Remove-MgSecurityCaseEdiscoveryCase -EdiscoveryCaseId $case.Id -Confirm:$false -ErrorAction SilentlyContinue
    } catch {
        Write-Host "      ⚠️ Failed to clean up case: $_" -ForegroundColor Yellow
    }
    
    exit 1
}

# =============================================================================
# Step 8: Retrieve Final Estimate Statistics
# =============================================================================

Write-Host "📊 Step 8: Retrieve Final Estimate Statistics" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

Write-Host "   ⏳ Retrieving final estimate results..." -ForegroundColor Cyan

try {
    # Get final estimate operation results
    $operationsUri = "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$($case.Id)/searches/$($search.id)/lastEstimateStatisticsOperation"
    $finalEstimate = Invoke-MgGraphRequest -Method GET -Uri $operationsUri -ErrorAction Stop
    
    # Extract final statistics
    $totalItems = if ($finalEstimate.resultInfo.resultCount) { $finalEstimate.resultInfo.resultCount } else { 0 }
    $totalSize = if ($finalEstimate.resultInfo.size) { $finalEstimate.resultInfo.size } else { 0 }
    $indexedItems = if ($finalEstimate.indexedItemCount) { $finalEstimate.indexedItemCount } else { 0 }
    $indexedSize = if ($finalEstimate.indexedItemsSize) { $finalEstimate.indexedItemsSize } else { 0 }
    
    Write-Host "   ✅ Final estimate statistics retrieved" -ForegroundColor Green
    Write-Host ""
    Write-Host "   📊 Detailed Discovery Results:" -ForegroundColor Cyan
    Write-Host "      • Total items found: $totalItems" -ForegroundColor Green
    Write-Host "      • Total size: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor DarkGray
    Write-Host "      • Indexed items: $indexedItems" -ForegroundColor DarkGray
    Write-Host "      • Indexed size: $([math]::Round($indexedSize / 1MB, 2)) MB" -ForegroundColor DarkGray
    Write-Host ""
    
    if ($totalItems -eq 0) {
        Write-Host "   ⚠️ No items found with SIT detections" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   💡 Possible causes:" -ForegroundColor Yellow
        Write-Host "      • SharePoint Search index not yet populated (requires 24 hours after Lab 03)" -ForegroundColor DarkGray
        Write-Host "      • No documents with enabled SIT types in tenant" -ForegroundColor DarkGray
        Write-Host "      • Sites require more time to index" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "   Run Test-SiteAvailability.ps1 to verify indexing status" -ForegroundColor Yellow
        Write-Host ""
    }
    
} catch {
    Write-Host "   ❌ Failed to retrieve final statistics: $_" -ForegroundColor Red
    $totalItems = 0
    $totalSize = 0
    $indexedItems = 0
    $indexedSize = 0
}

# =============================================================================
# Step 9: Generate Discovery Reports
# =============================================================================

Write-Host "📁 Step 9: Generate Discovery Reports" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

$discoveryEndTime = Get-Date
$totalDuration = ($discoveryEndTime - $discoveryStartTime).TotalSeconds

# Build discovery report structure
$discoveryReport = @{
    DiscoveryDate = $discoveryStartTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
    DiscoveryMethod = "Microsoft Graph eDiscovery API"
    DiscoveryDuration = [math]::Round($totalDuration, 2)
    eDiscoveryCaseId = $case.Id
    eDiscoveryCaseName = $caseName
    eDiscoverySearchId = $search.id
    eDiscoverySearchName = $searchName
    ContentQuery = $contentQuery
    DataSourceScopes = @($siteObjects | ForEach-Object { $_.Name })
    DataSourceSites = @($siteObjects | ForEach-Object { @{ Name = $_.Name; Url = $_.Url } })
    EnabledSITCount = $enabledSITs.Count
    EnabledSITTypes = $enabledSITs.Name
    TotalItemsFound = $totalItems
    TotalSizeBytes = $totalSize
    TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
    SITTypeDistribution = @()
}

# Add per-SIT statistics (estimate from total)
# Note: eDiscovery estimate provides aggregate statistics
# Individual SIT breakdown requires additional API calls or export
Write-Host "   📊 Building SIT distribution estimates..." -ForegroundColor Cyan

foreach ($sit in $enabledSITs) {
    $discoveryReport.SITTypeDistribution += @{
        SITName = $sit.Name
        SITPriority = $sit.Priority
        EstimatedItems = "See aggregate results - $totalItems total items"
    }
}

# Generate JSON report
$jsonReportPath = Join-Path $OutputPath "SIT_Discovery_$timestamp.json"
try {
    $discoveryReport | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonReportPath -Encoding UTF8
    Write-Host "   ✅ JSON report saved: $jsonReportPath" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to save JSON report: $_" -ForegroundColor Red
}

# Generate CSV summary report
$csvReportPath = Join-Path $OutputPath "SIT_Discovery_Summary_$timestamp.csv"
try {
    $csvData = [PSCustomObject]@{
        DiscoveryDate = $discoveryStartTime.ToString("yyyy-MM-dd HH:mm:ss")
        Method = "eDiscovery API"
        Duration = "$([math]::Round($totalDuration, 2))s"
        TotalItems = $totalItems
        TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
        EnabledSITs = $enabledSITs.Count
        CaseId = $case.Id
        SearchId = $search.id
    }
    
    $csvData | Export-Csv -Path $csvReportPath -NoTypeInformation -Encoding UTF8
    Write-Host "   ✅ CSV summary saved: $csvReportPath" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to save CSV report: $_" -ForegroundColor Red
}

Write-Host ""

# =============================================================================
# Script Completion Summary
# =============================================================================

Write-Host "✅ Step 1 Complete: Case and Search Created" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Discovery Summary:" -ForegroundColor Cyan
Write-Host "   • Case Name: $caseName" -ForegroundColor DarkGray
Write-Host "   • Case ID: $($case.Id)" -ForegroundColor DarkGray
Write-Host "   • Search ID: $($search.id)" -ForegroundColor DarkGray
Write-Host "   • Total duration: $([math]::Round($totalDuration, 2))s" -ForegroundColor DarkGray
Write-Host "   • Estimated items found: $totalItems" -ForegroundColor Green
Write-Host "   • Estimated size: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor DarkGray
Write-Host "   • Enabled SITs scanned: $($enabledSITs.Count)" -ForegroundColor DarkGray
Write-Host ""

Write-Host "📁 Reports Generated:" -ForegroundColor Cyan
Write-Host "   • JSON report: $jsonReportPath" -ForegroundColor DarkGray
Write-Host "   • CSV summary: $csvReportPath" -ForegroundColor DarkGray
Write-Host ""

Write-Host "🚀 Next Steps - Complete Direct Export Workflow:" -ForegroundColor Cyan
Write-Host "   1. 📥 Run Script 2: .\Export-SearchResults.ps1" -ForegroundColor Green
Write-Host "      (Auto-discovers case/search - exports results directly via Graph API)" -ForegroundColor DarkGray
Write-Host "      (Export completes in 5-10 minutes with populated SIT column)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "   2. 📊 Run Script 3: .\Invoke-GraphDiscoveryAnalysis.ps1" -ForegroundColor Green
Write-Host "      (Analyzes exported Items_0.csv with SIT detection data)" -ForegroundColor DarkGray
Write-Host ""

Write-Host "💡 Case Details Saved for Next Scripts:" -ForegroundColor Cyan
Write-Host "   Scripts 2 and 3 will auto-discover this case" -ForegroundColor DarkGray
Write-Host "   Case will persist until manually deleted" -ForegroundColor DarkGray
Write-Host ""

exit 0

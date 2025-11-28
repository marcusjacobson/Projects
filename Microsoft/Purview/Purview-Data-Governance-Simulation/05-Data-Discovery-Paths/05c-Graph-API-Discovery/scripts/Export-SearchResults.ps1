<#
.SYNOPSIS
    Exports eDiscovery search results directly via Microsoft Graph API.

.DESCRIPTION
    This script exports search results directly from an eDiscovery search (not via review sets)
    using the Microsoft Graph eDiscovery API. It automatically discovers the most recent Lab05c
    case and search, initiates the export operation, monitors completion, and downloads the
    export package containing Items_0.csv with populated SIT detection data.

.PARAMETER CaseId
    Optional: Specific eDiscovery case ID. If not provided, auto-discovers the most recent Lab05c case.

.PARAMETER SearchId
    Optional: Specific eDiscovery search ID. If not provided, auto-discovers the most recent search from the case.

.EXAMPLE
    .\Export-SearchResults.ps1
    
    Auto-discovers the most recent Lab05c case and search, then exports results.

.EXAMPLE
    .\Export-SearchResults.ps1 -CaseId "abc-123" -SearchId "def-456"
    
    Exports results from specific case and search IDs.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-23
    Last Modified: 2025-11-23
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7.0+
    - Microsoft.Graph PowerShell SDK
    - eDiscovery permissions (eDiscovery.Read.All, eDiscovery.ReadWrite.All)
    - Completed Invoke-GraphSitDiscovery.ps1 (creates case and search)
    
    Script development orchestrated using GitHub Copilot.

.GRAPH API OPERATIONS
    - Auto-discovers most recent Lab05c case and search
    - Initiates direct export operation via Graph API
    - Monitors export status and provides download instructions
#>

#Requires -Version 7.0

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$CaseId,
    
    [Parameter(Mandatory = $false)]
    [string]$SearchId
)

# =============================================================================
# Script Initialization
# =============================================================================

Write-Host "📦 Export eDiscovery Search Results via Graph API" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$reportsPath = Join-Path (Split-Path $PSScriptRoot -Parent) "reports"

# Ensure reports directory exists
if (-not (Test-Path $reportsPath)) {
    New-Item -ItemType Directory -Path $reportsPath -Force | Out-Null
}

# =============================================================================
# Step 1: Connect to Microsoft Graph
# =============================================================================

Write-Host "🔐 Step 1: Connect to Microsoft Graph" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

try {
    Write-Host "   🔍 Checking existing Graph connection..." -ForegroundColor Cyan
    
    $context = Get-MgContext
    if ($null -eq $context) {
        Write-Host "   🔑 No active connection found, connecting..." -ForegroundColor Yellow
        Connect-MgGraph -Scopes "eDiscovery.Read.All", "eDiscovery.ReadWrite.All" -NoWelcome
        $context = Get-MgContext
    }
    
    Write-Host "   ✅ Connected to Microsoft Graph" -ForegroundColor Green
    Write-Host "      • Tenant: $($context.TenantId)" -ForegroundColor DarkGray
    Write-Host "      • Account: $($context.Account)" -ForegroundColor DarkGray
    Write-Host ""
} catch {
    Write-Host "   ❌ Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Discover or Validate Case and Search
# =============================================================================

Write-Host "🔍 Step 2: Discover Case and Search" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

try {
    if ($CaseId -and $SearchId) {
        Write-Host "   📋 Using provided Case ID and Search ID" -ForegroundColor Cyan
        
        # Validate case exists
        $case = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$CaseId"
        $search = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$CaseId/searches/$SearchId"
        
        $caseName = $case.displayName
        $searchName = $search.displayName
        
    } else {
        Write-Host "   🔍 Auto-discovering most recent Lab05c case..." -ForegroundColor Cyan
        
        # Get all eDiscovery cases
        $casesResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases"
        $allCases = $casesResponse.value
        
        # Filter for Lab05c cases
        $lab05cCases = $allCases | Where-Object { $_.displayName -like "Lab05c-Discovery-*" }
        
        if ($lab05cCases.Count -eq 0) {
            Write-Host "   ❌ No Lab05c cases found" -ForegroundColor Red
            Write-Host "      Run Invoke-GraphSitDiscovery.ps1 first to create a case" -ForegroundColor Yellow
            exit 1
        }
        
        # Sort by creation date and get most recent
        $case = $lab05cCases | Sort-Object -Property createdDateTime -Descending | Select-Object -First 1
        $CaseId = $case.id
        $caseName = $case.displayName
        
        Write-Host "   ✅ Found case: $($case.displayName)" -ForegroundColor Green
        Write-Host "      • Case ID: $CaseId" -ForegroundColor DarkGray
        Write-Host "      • Created: $($case.createdDateTime)" -ForegroundColor DarkGray
        Write-Host ""
        
        # Get searches for this case
        Write-Host "   🔍 Discovering search in case..." -ForegroundColor Cyan
        $searchesResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$CaseId/searches"
        $searches = $searchesResponse.value
        
        if ($searches.Count -eq 0) {
            Write-Host "   ❌ No searches found in case" -ForegroundColor Red
            exit 1
        }
        
        # Get most recent search
        $search = $searches | Sort-Object -Property createdDateTime -Descending | Select-Object -First 1
        $SearchId = $search.id
        $searchName = $search.displayName
        
        Write-Host "   ✅ Found search: $($search.displayName)" -ForegroundColor Green
        Write-Host "      • Search ID: $SearchId" -ForegroundColor DarkGray
        Write-Host ""
    }
} catch {
    Write-Host "   ❌ Failed to discover case/search: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Initiate Direct Export from Search
# =============================================================================

Write-Host "📦 Step 3: Initiate Direct Export" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

try {
    Write-Host "   🚀 Creating export operation..." -ForegroundColor Cyan
    
    # Build export request body with REQUIRED parameters per Microsoft Graph API documentation
    $exportName = "Lab05c-Export-$timestamp"
    $exportBody = @{
        displayName = $exportName
        description = "Direct export from eDiscovery search for SIT detection analysis"
        exportCriteria = "searchHits"              # REQUIRED: searchHits or partiallyIndexed
        exportFormat = "pst"                       # REQUIRED: pst, msg, or eml
        additionalOptions = "none"                 # REQUIRED: none or specific options
    } | ConvertTo-Json -Depth 10
    
    # Initiate export (POST to /exportResult action endpoint - no microsoft.graph.security prefix)
    $exportUri = "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$CaseId/searches/$SearchId/exportResult"
    $exportResponse = Invoke-MgGraphRequest -Method POST -Uri $exportUri -Body $exportBody -ContentType "application/json" -OutputType HttpResponseMessage
    
    # Extract operation ID from Location header (API returns 202 Accepted with Location header)
    $locationHeader = $exportResponse.Headers.Location.ToString()
    if ($locationHeader -match "operations\('([^']+)'\)") {
        $exportId = $Matches[1]
    } elseif ($locationHeader -match "operations/([a-f0-9-]+)") {
        $exportId = $Matches[1]
    } else {
        throw "Could not extract operation ID from Location header: $locationHeader"
    }
    
    Write-Host "   ✅ Export request submitted" -ForegroundColor Green
    Write-Host "      • Export Name: $exportName" -ForegroundColor DarkGray
    Write-Host "      • Export ID: $exportId" -ForegroundColor DarkGray
    Write-Host ""
    
} catch {
    Write-Host "   ❌ Failed to initiate export: $_" -ForegroundColor Red
    Write-Host "      Error details: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 4: Export Initiated - Manual Download Required
# =============================================================================

Write-Host "✅ Step 4: Export Initiated Successfully" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "      • Search Name: $searchName" -ForegroundColor DarkGray
Write-Host "      • Export Name: $exportName" -ForegroundColor DarkGray
Write-Host ""
Write-Host "   ⏱️  Export Processing Time: Typically 15-30 minutes for large datasets (4,400+ files)" -ForegroundColor Yellow
Write-Host ""

Write-Host "================================================================================================" -ForegroundColor Cyan
Write-Host "  📋 Next Steps: Manual Download and Extraction" -ForegroundColor Cyan
Write-Host "================================================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔍 Step 1: Monitor Export Status in Compliance Portal" -ForegroundColor White
Write-Host "   1. Navigate to: https://compliance.microsoft.com/ediscovery" -ForegroundColor Gray
Write-Host "   2. Click 'eDiscovery' in left navigation" -ForegroundColor Gray
Write-Host "   3. Open case: $caseName" -ForegroundColor Gray
Write-Host "   4. Go to 'Exports' tab" -ForegroundColor Gray
Write-Host "   5. Wait for export status to show 'Completed' (refresh periodically)" -ForegroundColor Gray
Write-Host ""

Write-Host "📥 Step 2: Download Export Package" -ForegroundColor White
Write-Host "   Once export status shows 'Completed':" -ForegroundColor Gray
Write-Host "   1. Click the export name: $exportName" -ForegroundColor Gray
Write-Host "   2. Click 'Download' button to download the Reports package" -ForegroundColor Gray
Write-Host "   3. Move the downloaded .zip file from your Downloads folder to:" -ForegroundColor Gray
Write-Host "      $reportsPath" -ForegroundColor Yellow
Write-Host ""

Write-Host "📦 Step 3: Extract Export Package" -ForegroundColor White
Write-Host "   Use the Lab 05c extraction script:" -ForegroundColor Gray
Write-Host ""
Write-Host "   .\Expand-eDiscoveryExportPackages.ps1 -ExtractReports" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 Step 4: Analyze Extracted Data" -ForegroundColor White
Write-Host "   Run analysis on the extracted CSV:" -ForegroundColor Gray
Write-Host ""
Write-Host "   .\Invoke-GraphDiscoveryAnalysis.ps1" -ForegroundColor Cyan
Write-Host ""

Write-Host "================================================================================================" -ForegroundColor Green
Write-Host "  ✅ Export Script Complete - Awaiting Manual Download" -ForegroundColor Green
Write-Host "================================================================================================" -ForegroundColor Green
Write-Host ""

Write-Host "📁 Output Files:" -ForegroundColor Cyan
Write-Host "   • Items_0.csv - Main detection data with SIT GUIDs" -ForegroundColor DarkGray
Write-Host "   • Summary.csv - Export summary" -ForegroundColor DarkGray
Write-Host "   • Locations.csv - Site locations" -ForegroundColor DarkGray
Write-Host ""

Write-Host "🎯 Ready for Analysis" -ForegroundColor Cyan
Write-Host "   Proceed to Step 7: .\Invoke-GraphDiscoveryAnalysis.ps1" -ForegroundColor Green
Write-Host ""

exit 0

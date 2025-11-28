<#
.SYNOPSIS
    Investigates existing eDiscovery cases to understand search status and clean up old cases.

.DESCRIPTION
    This diagnostic script:
    - Lists all existing eDiscovery cases in the tenant
    - Shows detailed status of searches within each case
    - Displays lastEstimateStatisticsOperation status for troubleshooting
    - Optionally cleans up old/failed cases

.EXAMPLE
    .\Get-ExistingCases.ps1
    
    Lists all existing cases with detailed search status.

.EXAMPLE
    .\Get-ExistingCases.ps1 -CleanupOldCases
    
    Lists cases and offers to clean up old cases (interactive).

.NOTES
    Author: Marcus Jacobson
    Created: 2025-11-22
    
    Script development orchestrated using GitHub Copilot.

.GRAPH API OPERATIONS
    - Lists all existing eDiscovery cases in the tenant
    - Retrieves detailed search status and estimate operation details
    - Provides cleanup capabilities for old or failed cases
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$CleanupOldCases,
    
    [Parameter(Mandatory = $false)]
    [switch]$ShowSearchDetails
)

# =============================================================================
# Step 1: Connect to Microsoft Graph
# =============================================================================

Write-Host "🔐 Step 1: Connect to Microsoft Graph" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

try {
    Write-Host "   ⏳ Connecting to Microsoft Graph..." -ForegroundColor Cyan
    
    # Connect with eDiscovery permissions
    Connect-MgGraph -Scopes "eDiscovery.Read.All", "eDiscovery.ReadWrite.All" -NoWelcome -ErrorAction Stop
    
    Write-Host "   ✅ Successfully connected to Microsoft Graph" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "   ❌ Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Get All eDiscovery Cases
# =============================================================================

Write-Host "📋 Step 2: Get All eDiscovery Cases" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

try {
    Write-Host "   ⏳ Retrieving all eDiscovery cases..." -ForegroundColor Cyan
    
    $cases = Get-MgSecurityCaseEdiscoveryCase -All -ErrorAction Stop
    
    if ($cases.Count -eq 0) {
        Write-Host "   ℹ️ No eDiscovery cases found in tenant" -ForegroundColor Cyan
        exit 0
    }
    
    Write-Host "   ✅ Found $($cases.Count) eDiscovery case(s)" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host "   ❌ Failed to retrieve eDiscovery cases: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Analyze Each Case
# =============================================================================

Write-Host "🔍 Step 3: Analyze Cases and Searches" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

$caseDetails = @()

foreach ($case in $cases) {
    Write-Host "📁 Case: $($case.DisplayName)" -ForegroundColor Cyan
    Write-Host "   • Case ID: $($case.Id)" -ForegroundColor DarkGray
    Write-Host "   • Status: $($case.Status)" -ForegroundColor DarkGray
    Write-Host "   • Created: $($case.CreatedDateTime)" -ForegroundColor DarkGray
    
    # Get searches for this case
    try {
        $searches = Get-MgSecurityCaseEdiscoveryCaseSearch -EdiscoveryCaseId $case.Id -All -ErrorAction Stop
        
        if ($searches.Count -eq 0) {
            Write-Host "   • Searches: None" -ForegroundColor DarkGray
        } else {
            Write-Host "   • Searches: $($searches.Count)" -ForegroundColor DarkGray
            
            foreach ($search in $searches) {
                Write-Host ""
                Write-Host "   🔎 Search: $($search.DisplayName)" -ForegroundColor Yellow
                Write-Host "      • Search ID: $($search.Id)" -ForegroundColor DarkGray
                Write-Host "      • Created: $($search.CreatedDateTime)" -ForegroundColor DarkGray
                
                # Get detailed search status using REST API
                try {
                    $statusUri = "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$($case.Id)/searches/$($search.Id)"
                    $searchStatus = Invoke-MgGraphRequest -Method GET -Uri $statusUri -ErrorAction Stop
                    
                    # Check for lastEstimateStatisticsOperation (separate navigation property endpoint)
                    try {
                        $opUri = "https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/$($case.Id)/searches/$($search.Id)/lastEstimateStatisticsOperation"
                        $estimateOp = Invoke-MgGraphRequest -Method GET -Uri $opUri -ErrorAction Stop
                    } catch {
                        # 404/500 means operation doesn't exist yet
                        # API bug: Returns 500 "Failed to retrieve job results" instead of 404
                        if ($_.Exception.Message -like "*404*" -or $_.Exception.Message -like "*NotFound*" -or
                            $_.Exception.Message -like "*500*" -or $_.Exception.Message -like "*InternalServerError*" -or
                            $_.Exception.Message -like "*Failed to retrieve job results*") {
                            $estimateOp = $null
                        } else {
                            throw
                        }
                    }
                    
                    if ($null -ne $estimateOp) {
                        Write-Host "      • Estimate Operation Status: $($estimateOp.status)" -ForegroundColor Green
                        Write-Host "      • Progress: $($estimateOp.percentProgress)%" -ForegroundColor DarkGray
                        Write-Host "      • Action: $($estimateOp.action)" -ForegroundColor DarkGray
                        Write-Host "      • Created: $($estimateOp.createdDateTime)" -ForegroundColor DarkGray
                        Write-Host "      • Completed: $($estimateOp.completedDateTime)" -ForegroundColor DarkGray
                        
                        # Show results if available
                        if ($estimateOp.status -eq "succeeded") {
                            Write-Host "      • 📊 Items Found: $($estimateOp.resultInfo.indexedItemsCount)" -ForegroundColor Cyan
                            Write-Host "      • 📊 Size: $([math]::Round($estimateOp.resultInfo.size / 1MB, 2)) MB" -ForegroundColor Cyan
                        }
                    } else {
                        Write-Host "      • Estimate Operation: Not started (null)" -ForegroundColor Yellow
                    }
                    
                    # Store for cleanup consideration
                    $caseDetails += [PSCustomObject]@{
                        CaseName = $case.DisplayName
                        CaseId = $case.Id
                        CaseStatus = $case.Status
                        CaseCreated = $case.CreatedDateTime
                        SearchName = $search.DisplayName
                        SearchId = $search.Id
                        EstimateStatus = if ($estimateOp) { $estimateOp.status } else { "not-started" }
                        ItemsFound = if ($estimateOp -and $estimateOp.status -eq "succeeded") { $estimateOp.resultInfo.indexedItemsCount } else { 0 }
                    }
                    
                } catch {
                    Write-Host "      ⚠️ Could not retrieve detailed search status: $_" -ForegroundColor Yellow
                }
            }
        }
        
    } catch {
        Write-Host "   ⚠️ Could not retrieve searches for this case: $_" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# =============================================================================
# Step 4: Summary and Recommendations
# =============================================================================

Write-Host "📊 Summary" -ForegroundColor Green
Write-Host "==========" -ForegroundColor Green
Write-Host ""

$activeSearches = $caseDetails | Where-Object { $_.EstimateStatus -eq "running" }
$succeededSearches = $caseDetails | Where-Object { $_.EstimateStatus -eq "succeeded" }
$failedSearches = $caseDetails | Where-Object { $_.EstimateStatus -in @("failed", "cancelled") }
$notStartedSearches = $caseDetails | Where-Object { $_.EstimateStatus -eq "not-started" }

Write-Host "   • Total Cases: $($cases.Count)" -ForegroundColor Cyan
Write-Host "   • Total Searches: $($caseDetails.Count)" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Search Status Breakdown:" -ForegroundColor Yellow
Write-Host "   • ✅ Succeeded: $($succeededSearches.Count)" -ForegroundColor Green
Write-Host "   • 🔄 Running: $($activeSearches.Count)" -ForegroundColor Cyan
Write-Host "   • ⏳ Not Started: $($notStartedSearches.Count)" -ForegroundColor Yellow
Write-Host "   • ❌ Failed/Cancelled: $($failedSearches.Count)" -ForegroundColor Red
Write-Host ""

# Show running searches
if ($activeSearches.Count -gt 0) {
    Write-Host "🔄 Currently Running Searches:" -ForegroundColor Cyan
    foreach ($search in $activeSearches) {
        Write-Host "   • $($search.CaseName) / $($search.SearchName)" -ForegroundColor Yellow
        Write-Host "     Created: $($search.CaseCreated)" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "   💡 Tip: One of these may be the search you're waiting for!" -ForegroundColor Green
    Write-Host ""
}

# Show succeeded searches with results
if ($succeededSearches.Count -gt 0) {
    Write-Host "✅ Completed Searches with Results:" -ForegroundColor Green
    foreach ($search in $succeededSearches) {
        Write-Host "   • $($search.CaseName) / $($search.SearchName)" -ForegroundColor Cyan
        Write-Host "     Items Found: $($search.ItemsFound)" -ForegroundColor DarkGray
        Write-Host "     Created: $($search.CaseCreated)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# =============================================================================
# Step 5: Cleanup Old Cases (Optional)
# =============================================================================

if ($CleanupOldCases) {
    Write-Host "🧹 Step 5: Cleanup Old Cases" -ForegroundColor Green
    Write-Host "=============================" -ForegroundColor Green
    Write-Host ""
    
    # Find cases older than 1 day with no running searches
    $cutoffDate = (Get-Date).AddDays(-1)
    $oldCases = $cases | Where-Object {
        $caseId = $_.Id
        $created = [DateTime]::Parse($_.CreatedDateTime)
        $hasRunningSearches = ($caseDetails | Where-Object { $_.CaseId -eq $caseId -and $_.EstimateStatus -eq "running" }).Count -gt 0
        
        $created -lt $cutoffDate -and -not $hasRunningSearches
    }
    
    if ($oldCases.Count -eq 0) {
        Write-Host "   ℹ️ No old cases to clean up" -ForegroundColor Cyan
    } else {
        Write-Host "   Found $($oldCases.Count) old case(s) eligible for cleanup:" -ForegroundColor Yellow
        Write-Host ""
        
        foreach ($oldCase in $oldCases) {
            Write-Host "   • $($oldCase.DisplayName) (Created: $($oldCase.CreatedDateTime))" -ForegroundColor DarkGray
        }
        
        Write-Host ""
        $confirm = Read-Host "   Delete these cases? (yes/no)"
        
        if ($confirm -eq "yes") {
            foreach ($oldCase in $oldCases) {
                try {
                    Write-Host "   🗑️ Deleting: $($oldCase.DisplayName)..." -ForegroundColor Cyan
                    Remove-MgSecurityCaseEdiscoveryCase -EdiscoveryCaseId $oldCase.Id -Confirm:$false -ErrorAction Stop
                    Write-Host "      ✅ Deleted successfully" -ForegroundColor Green
                } catch {
                    Write-Host "      ❌ Failed to delete: $_" -ForegroundColor Red
                }
            }
            Write-Host ""
            Write-Host "   ✅ Cleanup complete" -ForegroundColor Green
        } else {
            Write-Host "   ℹ️ Cleanup cancelled" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
Write-Host "✅ Analysis Complete" -ForegroundColor Green
Write-Host ""

# Disconnect
Disconnect-MgGraph | Out-Null

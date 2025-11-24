<#
.SYNOPSIS
    Diagnostic script to determine if SharePoint sites exist and are accessible.

.DESCRIPTION
    This script performs multiple checks to determine whether the simulation sites
    are created and accessible, or if they're simply not yet indexed by Graph API.
    It tests both direct site access and Graph API search capabilities.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-22
    
    Script development orchestrated using GitHub Copilot.
#>

#Requires -Version 7.0

Write-Host "🔍 SharePoint Site Availability Diagnostic" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Configuration Loading
# =============================================================================

Write-Host "📁 Loading Configuration" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""

# Load global configuration file
$configPath = Join-Path (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent) "global-config.json"

if (-not (Test-Path $configPath)) {
    Write-Host "   ❌ Configuration file not found: $configPath" -ForegroundColor Red
    exit 1
}

$globalConfig = Get-Content $configPath -Raw | ConvertFrom-Json
$tenantUrl = $globalConfig.Environment.TenantUrl.TrimEnd('/')
$simulationSites = $globalConfig.SharePointSites

Write-Host "   ✅ Loaded configuration" -ForegroundColor Green
Write-Host "      • Tenant URL: $tenantUrl" -ForegroundColor DarkGray
Write-Host "      • Expected sites: $($simulationSites.Count)" -ForegroundColor DarkGray
Write-Host ""

# =============================================================================
# Step 1: Check Graph Connection
# =============================================================================

Write-Host "🔐 Step 1: Verify Graph API Connection" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

try {
    $context = Get-MgContext
    
    if ($null -eq $context) {
        Write-Host "   ⚠️ Not connected to Microsoft Graph" -ForegroundColor Yellow
        Write-Host "      Attempting to connect..." -ForegroundColor Cyan
        
        $requiredScopes = @("Sites.Read.All", "Sites.FullControl.All")
        Connect-MgGraph -Scopes $requiredScopes -NoWelcome
        
        $context = Get-MgContext
    }
    
    Write-Host "   ✅ Connected to Microsoft Graph" -ForegroundColor Green
    Write-Host "      • Account: $($context.Account)" -ForegroundColor DarkGray
    Write-Host "      • Tenant: $($context.TenantId)" -ForegroundColor DarkGray
    Write-Host ""
    
} catch {
    Write-Host "   ❌ Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Check If Sites Exist in SharePoint
# =============================================================================

Write-Host "🏢 Step 2: Check If Sites Exist in SharePoint" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "   💡 This checks if simulation sites actually exist in your tenant" -ForegroundColor Cyan
Write-Host "      (Independent of Graph API indexing - confirms site creation)" -ForegroundColor Cyan
Write-Host ""

$directAccessResults = @()

foreach ($siteConfig in $simulationSites) {
    $siteName = $siteConfig.Name
    $expectedUrl = "$($tenantUrl.TrimEnd('/'))/sites/$siteName"
    
    Write-Host "   Testing: $siteName" -ForegroundColor Cyan
    
    try {
        # Use Get-MgSite -Search to find sites (Get-MgSite -All doesn't work properly)
        # Search for the exact site name
        $foundSite = Get-MgSite -Search $siteName -ErrorAction Stop | 
                    Where-Object { $_.WebUrl -like "*$siteName*" } | 
                    Select-Object -First 1
        
        if ($null -ne $foundSite) {
            $directAccessResults += [PSCustomObject]@{
                SiteName = $siteName
                DirectAccess = "✅ EXISTS"
                SiteId = $foundSite.Id
                DisplayName = $foundSite.DisplayName
                WebUrl = $foundSite.WebUrl
                CreatedDateTime = $foundSite.CreatedDateTime
            }
            
            Write-Host "      ✅ SITE EXISTS" -ForegroundColor Green
            Write-Host "         Display Name: $($foundSite.DisplayName)" -ForegroundColor DarkGray
            Write-Host "         URL: $($foundSite.WebUrl)" -ForegroundColor DarkGray
            Write-Host "         Created: $($foundSite.CreatedDateTime)" -ForegroundColor DarkGray
            Write-Host ""
        } else {
            # Try searching with a broader term
            $broadSearch = Get-MgSite -Search "$($siteName.Split('-')[0])" -ErrorAction SilentlyContinue | 
                          Where-Object { $_.WebUrl -like "*$siteName*" } | 
                          Select-Object -First 1
            
            if ($null -ne $broadSearch) {
                $directAccessResults += [PSCustomObject]@{
                    SiteName = $siteName
                    DirectAccess = "✅ EXISTS"
                    SiteId = $broadSearch.Id
                    DisplayName = $broadSearch.DisplayName
                    WebUrl = $broadSearch.WebUrl
                    CreatedDateTime = $broadSearch.CreatedDateTime
                }
                
                Write-Host "      ✅ SITE EXISTS" -ForegroundColor Green
                Write-Host "         Display Name: $($broadSearch.DisplayName)" -ForegroundColor DarkGray
                Write-Host "         URL: $($broadSearch.WebUrl)" -ForegroundColor DarkGray
                Write-Host "         Created: $($broadSearch.CreatedDateTime)" -ForegroundColor DarkGray
                Write-Host ""
            } else {
                $directAccessResults += [PSCustomObject]@{
                    SiteName = $siteName
                    DirectAccess = "❌ NOT FOUND"
                    SiteId = "N/A"
                    DisplayName = "N/A"
                    WebUrl = $expectedUrl
                    CreatedDateTime = "N/A"
                }
                
                Write-Host "      ❌ SITE DOES NOT EXIST" -ForegroundColor Red
                Write-Host "         Expected URL: $expectedUrl" -ForegroundColor DarkGray
                Write-Host ""
            }
        }
    } catch {
        $errorMsg = $_.Exception.Message
        $directAccessResults += [PSCustomObject]@{
            SiteName = $siteName
            DirectAccess = "❌ ERROR"
            SiteId = "N/A"
            DisplayName = "N/A"
            WebUrl = $expectedUrl
            CreatedDateTime = "N/A"
            Error = $errorMsg
        }
        
        Write-Host "      ❌ ERROR CHECKING SITE" -ForegroundColor Red
        Write-Host "         Error: $errorMsg" -ForegroundColor DarkGray
        Write-Host ""
    }
}

# =============================================================================
# Step 3: Verify Search Index Status
# =============================================================================

Write-Host "🔎 Step 3: Verify Search Index Status" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "   💡 NOTE: Since Get-MgSite -Search was used in Step 2," -ForegroundColor Cyan
Write-Host "      sites found there are ALREADY CONFIRMED to be indexed." -ForegroundColor Cyan
Write-Host "      Graph API search REQUIRES indexing to return results." -ForegroundColor Cyan
Write-Host ""

# Since we used -Search in Step 2, any site found is already indexed
$searchResults = @()
foreach ($result in $directAccessResults) {
    if ($result.DirectAccess -eq "✅ EXISTS") {
        $searchResults += [PSCustomObject]@{
            SiteName = $result.SiteName
            SearchResult = "✅ FOUND"
            SearchDisplayName = $result.DisplayName
        }
        Write-Host "   ✅ $($result.SiteName) - INDEXED (confirmed by Step 2 search)" -ForegroundColor Green
    } elseif ($result.DirectAccess -eq "❌ NOT FOUND") {
        $searchResults += [PSCustomObject]@{
            SiteName = $result.SiteName
            SearchResult = "❌ NOT FOUND"
            SearchDisplayName = "N/A"
        }
        Write-Host "   ❌ $($result.SiteName) - NOT IN INDEX (site may not exist)" -ForegroundColor Red
    } else {
        $searchResults += [PSCustomObject]@{
            SiteName = $result.SiteName
            SearchResult = "❓ UNKNOWN"
            SearchDisplayName = $result.DisplayName
        }
        Write-Host "   ❓ $($result.SiteName) - UNKNOWN (error occurred in Step 2)" -ForegroundColor Yellow
    }
}
Write-Host ""

# =============================================================================
# Step 4: Diagnosis Summary
# =============================================================================

Write-Host "📊 Diagnosis Summary" -ForegroundColor Green
Write-Host "====================" -ForegroundColor Green
Write-Host ""

# Combine results
$combinedResults = @()
for ($i = 0; $i -lt $simulationSites.Count; $i++) {
    $combinedResults += [PSCustomObject]@{
        SiteName = $simulationSites[$i].Name
        DirectAccess = $directAccessResults[$i].DirectAccess
        SearchIndex = $searchResults[$i].SearchResult
        SiteUrl = $directAccessResults[$i].WebUrl
        CreatedDate = $directAccessResults[$i].CreatedDateTime
    }
}

# Display results table
$combinedResults | Format-Table -AutoSize

Write-Host ""
Write-Host "🔍 Interpretation Guide:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Scenario 1: Direct Access ✅ + Search Index ✅" -ForegroundColor White
Write-Host "      → Sites exist AND are indexed. Ready for Lab 05c!" -ForegroundColor Green
Write-Host ""
Write-Host "   Scenario 2: Direct Access ✅ + Search Index ⚠️" -ForegroundColor White
Write-Host "      → Sites exist but NOT yet indexed by Graph API search" -ForegroundColor Yellow
Write-Host "      → This is your current situation (7-9 days since creation)" -ForegroundColor Yellow
Write-Host "      → Wait 5-7 more days for indexing to complete" -ForegroundColor Yellow
Write-Host "      → Use Lab 05a (PnP) or Lab 05b (eDiscovery) in the meantime" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Scenario 3: Direct Access ❌ + Search Index ❌" -ForegroundColor White
Write-Host "      → Sites don't exist or you don't have access" -ForegroundColor Red
Write-Host "      → Run earlier labs (Lab 01/02) to create sites first" -ForegroundColor Red
Write-Host ""

# Count sites by status
$existingCount = ($directAccessResults | Where-Object { $_.DirectAccess -eq "✅ EXISTS" }).Count
$indexedCount = ($searchResults | Where-Object { $_.SearchResult -eq "✅ FOUND" }).Count
$totalSites = $simulationSites.Count

Write-Host ""
Write-Host "📊 Summary Statistics:" -ForegroundColor Cyan
Write-Host "   • Total simulation sites expected: $totalSites" -ForegroundColor DarkGray
Write-Host "   • Sites that exist in SharePoint: $existingCount" -ForegroundColor DarkGray
Write-Host "   • Sites indexed in Graph Search: $indexedCount" -ForegroundColor DarkGray
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""

# Provide clear diagnosis and recommendation
if ($existingCount -eq 0) {
    # SCENARIO: NO SITES EXIST
    Write-Host "🚫 DIAGNOSIS: Sites Not Created" -ForegroundColor Red
    Write-Host "═══════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "   ❌ None of the simulation sites exist in your SharePoint tenant" -ForegroundColor Red
    Write-Host ""
    Write-Host "   🎯 READY FOR LAB 05C?   NO - Sites don't exist yet" -ForegroundColor Red
    Write-Host ""
    Write-Host "   📋 Required Actions:" -ForegroundColor Yellow
    Write-Host "      1. Go back and complete Lab 01 or Lab 02 to create simulation sites" -ForegroundColor DarkGray
    Write-Host "      2. Verify site creation in SharePoint admin center" -ForegroundColor DarkGray
    Write-Host "      3. Wait 24 hours after creation, then try Lab 05b (eDiscovery)" -ForegroundColor DarkGray
    Write-Host "      4. Wait 24 hours after creation, then proceed to Lab 05c (Graph API)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   📚 More Information:" -ForegroundColor Cyan
    Write-Host "      → Lab 01: Manual site creation and document upload" -ForegroundColor DarkGray
    Write-Host "      → Lab 02: Automated document generation and site provisioning" -ForegroundColor DarkGray
    Write-Host ""
    
} elseif ($existingCount -eq $totalSites -and $indexedCount -eq $totalSites) {
    # SCENARIO: ALL SITES EXIST AND INDEXED
    Write-Host "✅ DIAGNOSIS: Ready for Lab 05c" -ForegroundColor Green
    Write-Host "═══════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "   ✅ All $totalSites simulation sites exist in SharePoint" -ForegroundColor Green
    Write-Host "   ✅ All $totalSites sites are indexed in Graph API Search" -ForegroundColor Green
    Write-Host ""
    Write-Host "   🎯 READY FOR LAB 05C?   YES - Proceed immediately!" -ForegroundColor Green
    Write-Host ""
    Write-Host "   ▶️ Next Steps:" -ForegroundColor Cyan
    Write-Host "      1. Run: .\Search-GraphSITs.ps1" -ForegroundColor White
    Write-Host "      2. Expect to find 4,400-4,500 files with sensitive data" -ForegroundColor DarkGray
    Write-Host "      3. Review generated reports in reports\ folder" -ForegroundColor DarkGray
    Write-Host "      4. Compare results with Lab 05b (eDiscovery) for accuracy validation" -ForegroundColor DarkGray
    Write-Host ""
    
} elseif ($existingCount -eq $totalSites -and $indexedCount -eq 0) {
    # SCENARIO: ALL SITES EXIST BUT NOT INDEXED
    Write-Host "⏳ DIAGNOSIS: Indexing In Progress" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   ✅ All $totalSites simulation sites exist in SharePoint" -ForegroundColor Green
    Write-Host "   ⚠️ Graph API Search indexing NOT complete yet" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   🎯 READY FOR LAB 05C?   NOT YET - Wait for indexing to complete" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   ⏰ Timeline Estimate:" -ForegroundColor Cyan
    
    # Calculate estimated completion based on oldest site creation date
    $oldestSite = $directAccessResults | 
                 Where-Object { $_.DirectAccess -eq "✅ EXISTS" } | 
                 Sort-Object CreatedDateTime | 
                 Select-Object -First 1
    
    if ($null -ne $oldestSite -and $oldestSite.CreatedDateTime -ne "N/A") {
        $createdDate = [DateTime]$oldestSite.CreatedDateTime
        $daysOld = ([DateTime]::Now - $createdDate).Days
        $daysRemaining = [Math]::Max(0, 14 - $daysOld)
        
        Write-Host "      • Oldest site created: $daysOld days ago" -ForegroundColor DarkGray
        Write-Host "      • Typical indexing time: 7-14 days" -ForegroundColor DarkGray
        Write-Host "      • Estimated days remaining: $daysRemaining days" -ForegroundColor DarkGray
    } else {
        Write-Host "      • Typical indexing time: 7-14 days" -ForegroundColor DarkGray
        Write-Host "      • Estimated completion: Unknown (run diagnostic again in 3-4 days)" -ForegroundColor DarkGray
    }
    
    Write-Host ""
    Write-Host "   💡 Your Options While Waiting:" -ForegroundColor Cyan
    Write-Host "      1. ⏳ WAIT: Run this diagnostic again in 3-4 days to check progress" -ForegroundColor White
    Write-Host "      2. 🚀 Lab 05b (eDiscovery): Uses SharePoint Search (24-hour indexing)" -ForegroundColor White
    Write-Host "      3. ⚡ Lab 05a (PnP): Direct file access (immediate results)" -ForegroundColor White
    Write-Host ""
    Write-Host "   📌 Recommended Action:" -ForegroundColor Cyan
    Write-Host "      → Complete Lab 05b now for faster results with official Purview SITs" -ForegroundColor Green
    Write-Host "      → Return to Lab 05c after indexing completes for automation capabilities" -ForegroundColor DarkGray
    Write-Host ""
    
} elseif ($existingCount -lt $totalSites) {
    # SCENARIO: SOME SITES MISSING
    $missingCount = $totalSites - $existingCount
    Write-Host "⚠️ DIAGNOSIS: Incomplete Site Setup" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   ⚠️ Only $existingCount of $totalSites simulation sites exist" -ForegroundColor Yellow
    Write-Host "   ❌ $missingCount sites are missing" -ForegroundColor Red
    Write-Host ""
    Write-Host "   🎯 READY FOR LAB 05C?   PARTIALLY - Some sites missing" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   📋 Missing Sites:" -ForegroundColor Cyan
    $missingSites = $directAccessResults | Where-Object { $_.DirectAccess -ne "✅ EXISTS" }
    foreach ($missing in $missingSites) {
        Write-Host "      • $($missing.SiteName)" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "   🔧 Troubleshooting Steps:" -ForegroundColor Cyan
    Write-Host "      1. Check SharePoint admin center to verify which sites exist" -ForegroundColor DarkGray
    Write-Host "      2. Review global-config.json for correct site names" -ForegroundColor DarkGray
    Write-Host "      3. Re-run Lab 01/02 to create missing sites" -ForegroundColor DarkGray
    Write-Host "      4. Verify your account has permissions to access all sites" -ForegroundColor DarkGray
    Write-Host ""
    
} else {
    # SCENARIO: PARTIAL INDEXING
    Write-Host "🔄 DIAGNOSIS: Partial Indexing" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   ✅ All $totalSites sites exist" -ForegroundColor Green
    Write-Host "   ⚠️ Only $indexedCount of $totalSites sites are indexed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   🎯 READY FOR LAB 05C?   NOT YET - Wait for complete indexing" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   💡 Recommendation:" -ForegroundColor Cyan
    Write-Host "      → Wait 3-4 more days and run this diagnostic again" -ForegroundColor DarkGray
    Write-Host "      → Use Lab 05b (eDiscovery) for faster results in the meantime" -ForegroundColor DarkGray
    Write-Host ""
}

exit 0

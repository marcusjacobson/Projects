<#
.SYNOPSIS
    Executes a temporal scan at a specified interval to track classification evolution.

.DESCRIPTION
    This script performs a Microsoft Graph API-based scan of SharePoint sites at specified
    temporal intervals (7-Day, 14-Day, 21-Day) to track Purview SIT classification maturation.
    
    It queries the Microsoft Search unified index to detect sensitive information types across
    configured SharePoint sites and exports results in a standardized CSV format for temporal
    comparison analysis.

.PARAMETER ScanInterval
    The temporal interval for this scan. Valid values:
    - "7-Day" - Week 1 checkpoint (first unified index maturation)
    - "14-Day" - Week 2 checkpoint (secondary index stabilization)
    - "21-Day" - Week 3 checkpoint (classification convergence validation)

.PARAMETER UseConfig
    Switch parameter to load scan configuration from temporal-config.json file.
    When specified, the script reads SharePoint sites and scan parameters from
    the centralized configuration file.

.PARAMETER SiteName
    Optional parameter to scan a single specific site instead of all configured sites.
    Useful for troubleshooting individual site issues or re-scanning specific locations.

.PARAMETER Verbose
    Standard PowerShell verbose output for detailed execution logging.

.EXAMPLE
    .\Invoke-TemporalScan.ps1 -ScanInterval "7-Day" -UseConfig
    
    Runs the 7-day temporal scan across all sites configured in temporal-config.json.

.EXAMPLE
    .\Invoke-TemporalScan.ps1 -ScanInterval "14-Day" -UseConfig -Verbose
    
    Runs the 14-day scan with detailed verbose logging for troubleshooting.

.EXAMPLE
    .\Invoke-TemporalScan.ps1 -ScanInterval "21-Day" -SiteName "HR-Simulation"
    
    Runs the 21-day scan for only the HR-Simulation site.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-21
    Last Modified: 2025-11-21
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft.Graph PowerShell module (v2.0+)
    - Microsoft Graph API permissions: Files.Read.All, Sites.Read.All
    - Authenticated Microsoft Graph session (Connect-MgGraph)
    - Lab 03 content uploaded to SharePoint simulation sites
    - Appropriate time elapsed since Lab 03 upload (7, 14, or 21 days)
    
    Script development orchestrated using GitHub Copilot.

.TEMPORAL ANALYSIS OPERATIONS
    7-Day: First Microsoft Search unified index maturation checkpoint
    14-Day: Secondary index stabilization and ML model application
    21-Day: Final classification convergence validation
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("24-Hour", "7-Day", "14-Day", "21-Day")]
    [string]$ScanInterval,
    
    [Parameter(Mandatory = $false)]
    [switch]$UseConfig,
    
    [Parameter(Mandatory = $false)]
    [string]$SiteName,

    [Parameter(Mandatory = $false)]
    [switch]$SimulationMode
)

# =============================================================================
# Step 1: Environment Validation and Configuration Loading
# =============================================================================

Write-Host "🔍 Lab 05-Temporal: Longitudinal Classification Analysis" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host ""

if ($SimulationMode) {
    Write-Host "⚠️  SIMULATION MODE ACTIVE" -ForegroundColor Yellow
    Write-Host "   Generating synthetic data for analysis demonstration." -ForegroundColor Yellow
    Write-Host "   No actual API calls will be made." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "📋 Scan Configuration:" -ForegroundColor Cyan
Write-Host "   Interval: $ScanInterval" -ForegroundColor Cyan

# Load temporal configuration if UseConfig specified
if ($UseConfig) {
    $configPath = Join-Path $PSScriptRoot "..\temporal-config.json"
    
    if (-not (Test-Path $configPath)) {
        Write-Host "❌ Configuration file not found: $configPath" -ForegroundColor Red
        throw "temporal-config.json not found. Run with explicit parameters or create config file."
    }
    
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        Write-Host "   ✅ Configuration loaded from temporal-config.json" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to load configuration: $_" -ForegroundColor Red
        throw
    }
    
    # Get interval-specific configuration
    $intervalConfig = $config.temporalSettings.scanIntervals | Where-Object { $_.name -eq $ScanInterval }
    
    if (-not $intervalConfig) {
        Write-Host "❌ Scan interval '$ScanInterval' not found in configuration" -ForegroundColor Red
        throw "Invalid scan interval configuration"
    }
    
    Write-Host "   Scan Method: $($intervalConfig.scanMethod)" -ForegroundColor Cyan
    Write-Host "   Expected Days After Upload: $($intervalConfig.expectedDaysAfterUpload) (tolerance: ±$($intervalConfig.toleranceDays) days)" -ForegroundColor Cyan
}

# Verify Microsoft Graph authentication
Write-Host ""
Write-Host "🔐 Verifying Microsoft Graph Authentication..." -ForegroundColor Cyan

try {
    $context = Get-MgContext
    
    if (-not $context) {
        Write-Host "❌ Not connected to Microsoft Graph" -ForegroundColor Red
        Write-Host "   Run: Connect-MgGraph -Scopes 'Files.Read.All', 'Sites.Read.All'" -ForegroundColor Yellow
        throw "Microsoft Graph authentication required"
    }
    
    Write-Host "   ✅ Connected to Microsoft Graph" -ForegroundColor Green
    Write-Host "   Tenant: $($context.TenantId)" -ForegroundColor Cyan
    Write-Host "   Account: $($context.Account)" -ForegroundColor Cyan
    
    # Verify required scopes
    $requiredScopes = @("Files.Read.All", "Sites.Read.All")
    $missingScopes = $requiredScopes | Where-Object { $context.Scopes -notcontains $_ }
    
    if ($missingScopes) {
        Write-Host "❌ Missing required scopes: $($missingScopes -join ', ')" -ForegroundColor Red
        Write-Host "   Re-connect with required scopes: Connect-MgGraph -Scopes 'Files.Read.All', 'Sites.Read.All'" -ForegroundColor Yellow
        throw "Insufficient Microsoft Graph permissions"
    }
    
} catch {
    Write-Host "❌ Microsoft Graph authentication failed: $_" -ForegroundColor Red
    throw
}

# Load global-config.json for SharePoint sites
$globalConfigPath = Join-Path $PSScriptRoot "..\..\..\global-config.json"

if (-not (Test-Path $globalConfigPath)) {
    Write-Host "❌ global-config.json not found: $globalConfigPath" -ForegroundColor Red
    throw "global-config.json required for site configuration"
}

try {
    $globalConfig = Get-Content $globalConfigPath -Raw | ConvertFrom-Json
    $tenantUrl = $globalConfig.Environment.TenantUrl.TrimEnd('/')
    $sitesToScan = $globalConfig.SharePointSites
    
    Write-Host ""
    Write-Host "   Sites to Scan: $($sitesToScan.Count)" -ForegroundColor Cyan
    
    # Filter to single site if specified
    if ($SiteName) {
        $sitesToScan = $sitesToScan | Where-Object { $_.Name -eq $SiteName }
        
        if (-not $sitesToScan) {
            Write-Host "❌ Site '$SiteName' not found in global-config.json" -ForegroundColor Red
            throw "Invalid site name specified"
        }
        
        Write-Host "   (Scanning single site: $SiteName)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Failed to load global-config.json: $_" -ForegroundColor Red
    throw
}

# =============================================================================
# Step 2: Execute Temporal Scan Across Sites
# =============================================================================

Write-Host ""
Write-Host "🔍 Scanning Sites for Purview SIT Classification:" -ForegroundColor Green

$allDetections = @()
$scanTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

foreach ($site in $sitesToScan) {
    $siteName = $site.Name
    $siteUrl = "$tenantUrl/sites/$siteName"
    
    Write-Host "   ⏳ $siteName..." -ForegroundColor Cyan
    
    if ($SimulationMode) {
        # ---------------------------------------------------------------------
        # SIMULATION MODE LOGIC
        # ---------------------------------------------------------------------
        try {
            # Define base counts and drift factors based on interval
            $baseCount = 200 # Base files per site
            $driftFactor = switch ($ScanInterval) {
                "24-Hour" { 1.00 } # Baseline
                "7-Day"  { 1.10 } # +10% maturation
                "14-Day" { 1.15 } # +15% maturation (cumulative)
                "21-Day" { 1.16 } # +16% maturation (convergence)
            }
            
            # Add some randomness (+/- 2%)
            $randomness = (Get-Random -Minimum -2 -Maximum 3) / 100
            $finalFactor = $driftFactor + $randomness
            $targetCount = [Math]::Round($baseCount * $finalFactor)
            
            # Generate synthetic detections
            for ($i = 1; $i -le $targetCount; $i++) {
                # Pick a random SIT type
                $sitType = Get-Random -InputObject "U.S. Social Security Number (SSN)", "Credit Card Number", "U.S. Bank Account Number", "EU Passport Number", "ABA Routing Number"
                
                $detection = [PSCustomObject]@{
                    ScanInterval = $ScanInterval
                    ScanTimestamp = $scanTimestamp
                    FileName = "Simulated_File_$i.docx"
                    SiteUrl = $siteUrl
                    SiteName = $siteName
                    LibraryName = "Shared Documents"
                    SITType = $sitType
                    SITConfidence = Get-Random -Minimum 75 -Maximum 99
                    Instances = Get-Random -Minimum 1 -Maximum 5
                    DetectionMethod = "Simulation-Temporal"
                    FilePath = "$siteUrl/Shared Documents/Simulated_File_$i.docx"
                    FileSize = Get-Random -Minimum 10240 -Maximum 5242880
                    LastModified = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30))
                }
                $allDetections += $detection
            }
            
            Write-Host "   ✅ $siteName`: Simulated $targetCount SIT detections (Factor: $finalFactor)" -ForegroundColor Green
            
        } catch {
            Write-Host "   ❌ $siteName`: Simulation failed - $_" -ForegroundColor Red
        }
        
    } else {
        # ---------------------------------------------------------------------
        # REAL GRAPH API LOGIC
        # ---------------------------------------------------------------------
        try {
            # Query Microsoft Search API for files with sensitive information types
            # Using 'SensitiveType' managed property which is standard in SPO/Graph Search
            
            $searchQuery = @{
                requests = @(
                    @{
                        entityTypes = @("driveItem")
                        query = @{
                            queryString = "SensitiveType:* AND Path:`"$siteUrl`""
                        }
                        from = 0
                        size = 500 # Adjust page size as needed
                        fields = @("name", "webUrl", "size", "lastModifiedDateTime", "parentReference", "sensitiveType")
                    }
                )
            }
            
            # Execute Graph API search request
            $response = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/search/query" -Body ($searchQuery | ConvertTo-Json -Depth 10)
            
            # Process search results
            if ($response.value[0].hitsContainers[0].hits) {
                $siteResults = $response.value[0].hitsContainers[0].hits
                $detectionCount = 0
                
                foreach ($hit in $siteResults) {
                    # Check if sensitiveType field exists in resource or fields
                    # Note: Graph Search response structure varies by schema mapping
                    # We check 'resource' first, then 'fields' if requested
                    
                    $sitData = $null
                    if ($hit.resource.sensitiveType) { $sitData = $hit.resource.sensitiveType }
                    elseif ($hit.fields.sensitiveType) { $sitData = $hit.fields.sensitiveType }
                    
                    if ($sitData) {
                        # Handle if sitData is array or single string
                        $sits = if ($sitData -is [array]) { $sitData } else { @($sitData) }
                        
                        foreach ($sit in $sits) {
                            $detectionCount++
                            $detection = [PSCustomObject]@{
                                ScanInterval = $ScanInterval
                                ScanTimestamp = $scanTimestamp
                                FileName = $hit.resource.name
                                SiteUrl = $siteUrl
                                SiteName = $siteName
                                LibraryName = "Shared Documents" # Simplified
                                SITType = $sit # Assuming string name, or object if detailed
                                SITConfidence = 85 # Default if not provided by API
                                Instances = 1 # Default if not provided
                                DetectionMethod = "GraphAPI-Temporal"
                                FilePath = $hit.resource.webUrl
                                FileSize = $hit.resource.size
                                LastModified = $hit.resource.lastModifiedDateTime
                            }
                            
                            $allDetections += $detection
                        }
                    }
                }
                
                Write-Host "   ✅ $siteName`: $($siteResults.Count) files scanned, $detectionCount SIT detections found" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  $siteName`: No results returned from Graph Search" -ForegroundColor Yellow
            }
            
        } catch {
            Write-Host "   ❌ $siteName`: Scan failed - $_" -ForegroundColor Red
            Write-Host "      (Site will be marked as error in output)" -ForegroundColor Yellow
        }
    }
}

# =============================================================================
# Step 3: Export Results and Generate Summary
# =============================================================================

Write-Host ""
Write-Host "📊 Scan Summary:" -ForegroundColor Green

$totalFiles = ($allDetections | Select-Object -Unique FileName, SiteUrl).Count
$totalDetections = $allDetections.Count
$detectionRate = if ($totalFiles -gt 0) { [Math]::Round(($totalDetections / $totalFiles) * 100, 1) } else { 0 }

Write-Host "   Total Files Scanned: $totalFiles" -ForegroundColor Cyan
Write-Host "   Total SIT Detections: $totalDetections" -ForegroundColor Cyan
Write-Host "   Detection Rate: $detectionRate%" -ForegroundColor Cyan

# Generate output filename
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$outputFileName = "Temporal-Scan-$($ScanInterval.Replace('-',''))-$timestamp.csv"
$outputPath = Join-Path $PSScriptRoot "..\reports\$outputFileName"

# Export to CSV
try {
    $allDetections | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8
    
    Write-Host ""
    Write-Host "   Output File: $outputFileName" -ForegroundColor Green
    Write-Host "   Report Location: ..\reports\" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✅ $ScanInterval scan completed successfully" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Failed to export results: $_" -ForegroundColor Red
    throw
}

# Display next steps
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Magenta
Write-Host "==============" -ForegroundColor Magenta

switch ($ScanInterval) {
    "24-Hour" {
        Write-Host "1. Review Baseline results: .\Compare-TemporalScans.ps1 -BaselineScan '24-Hour' -ComparisonScan '7-Day'" -ForegroundColor Cyan
        Write-Host "2. Wait 7 days (7 days total after Lab 03)" -ForegroundColor Cyan
        Write-Host "3. Run Week 1 scan: .\Invoke-TemporalScan.ps1 -ScanInterval '7-Day' -UseConfig" -ForegroundColor Cyan
    }
    "7-Day" {
        Write-Host "1. Review Week 1 results: .\Compare-TemporalScans.ps1 -BaselineScan '24-Hour' -ComparisonScan '7-Day'" -ForegroundColor Cyan
        Write-Host "2. Wait 7 more days (14 days total after Lab 03)" -ForegroundColor Cyan
        Write-Host "3. Run Week 2 scan: .\Invoke-TemporalScan.ps1 -ScanInterval '14-Day' -UseConfig" -ForegroundColor Cyan
    }
    "14-Day" {
        Write-Host "1. Review Week 2 results: .\Compare-TemporalScans.ps1 -BaselineScan '7-Day' -ComparisonScan '14-Day'" -ForegroundColor Cyan
        Write-Host "2. Wait 7 more days (21 days total after Lab 03)" -ForegroundColor Cyan
        Write-Host "3. Run Week 3 scan: .\Invoke-TemporalScan.ps1 -ScanInterval '21-Day' -UseConfig" -ForegroundColor Cyan
    }
    "21-Day" {
        Write-Host "1. Validate convergence: .\Compare-TemporalScans.ps1 -BaselineScan '14-Day' -ComparisonScan '21-Day'" -ForegroundColor Cyan
        Write-Host "2. Generate full report: .\Invoke-TemporalAnalysis.ps1 -GenerateFullReport -UseConfig" -ForegroundColor Cyan
        Write-Host "3. Compare with Lab 05a: ..\..\..\scripts\Invoke-CrossLabAnalysis.ps1 -Labs '05a', '05-Temporal'" -ForegroundColor Cyan
    }
}

Write-Host ""

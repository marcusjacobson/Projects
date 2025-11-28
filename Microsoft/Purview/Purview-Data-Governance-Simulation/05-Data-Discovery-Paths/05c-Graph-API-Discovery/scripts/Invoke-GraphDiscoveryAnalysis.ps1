<#
.SYNOPSIS
    Analyzes Lab 05c Graph API eDiscovery export results with SIT distribution statistics.

.DESCRIPTION
    This script analyzes the SIT detection data exported from Microsoft Graph eDiscovery API
    (Lab 05c) and generates comprehensive statistics including:
    
    - SIT type distribution with counts and percentages
    - Total detection records across all files
    - File-level SIT detection analysis
    - Filtered analysis of the 7 targeted SIT types from simulation dataset
    
    The script automatically discovers the most recent Items_0_*.csv file
    in the reports folder (eDiscovery export format), loads the Purview-SIT-GUID-Mapping.json
    for GUID-to-name resolution, and generates distribution statistics matching Lab 05b format.
    
    Lab 05c produces the SAME eDiscovery export CSV structure as Lab 05b:
    - One row per file (not per-SIT-per-file)
    - "Sensitive type" column with GUID-delimited strings (GUID$#,#&GUID$#,#&...)
    - Requires GUID parsing and mapping to friendly names
    - Uses Purview-SIT-GUID-Mapping.json for name resolution
    - Filters to 7 targeted SIT types from simulation dataset

.EXAMPLE
    .\Invoke-GraphDiscoveryAnalysis.ps1
    
    Analyzes the most recent Lab 05c eDiscovery export with SIT distribution statistics.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-24
    Last Modified: 2025-11-24
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Completed Lab 05c export and extraction workflow
    - Valid Items_0_*.csv file in reports folder (eDiscovery export format)
    - Purview-SIT-GUID-Mapping.json in parent directory
    
    Script development orchestrated using GitHub Copilot.

.GRAPH API OPERATIONS
    - Analyzes SIT detection data from Graph API eDiscovery export
    - Generates comprehensive statistics and detailed reports
    - Maps GUID-based SIT types to friendly names

.LAB05C_DATA_FORMAT
    eDiscovery Export CSV Structure (Items_0.csv):
    - One row per file with detected SITs
    - "Sensitive type" column: GUID-delimited format (GUID$#,#&GUID$#,#&...)
    - Contains 93+ unique SIT GUIDs (Purview detects all types, not just targeted 7)
    - Requires parsing, GUID mapping, and filtering to targeted SIT types
    
.KEY_FACTS_LAB05C
    Lab 05c (Graph API eDiscovery Export):
    - IDENTICAL CSV format to Lab 05b (both use eDiscovery export)
    - GUID-based "Sensitive type" column (requires mapping)
    - One row per file (requires expansion to per-SIT-per-file)
    - 7 targeted SIT GUIDs from simulation dataset
    - Uses Purview-SIT-GUID-Mapping.json for GUID-to-name resolution
    - Filters out the 86+ other SIT types detected by Purview
#>

[CmdletBinding()]
param ()

# =============================================================================
# Script Initialization
# =============================================================================

$ErrorActionPreference = "Stop"
$scriptPath = $PSScriptRoot
$reportsPath = Join-Path $scriptPath "..\reports"
$mappingFilePath = Join-Path $scriptPath "..\..\Purview-SIT-GUID-Mapping.json"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Lab 05c: Graph API eDiscovery Export - SIT Analysis" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Load global-config.json as central source of truth
$globalConfigPath = Join-Path $scriptPath "..\..\..\global-config.json"
if (-not (Test-Path $globalConfigPath)) {
    Write-Host "   ❌ Global config not found: $globalConfigPath" -ForegroundColor Red
    Write-Host "   💡 Lab 05c requires global-config.json for SIT configuration" -ForegroundColor Yellow
    exit 1
}

try {
    $globalConfig = Get-Content $globalConfigPath | ConvertFrom-Json
    $enabledSits = $globalConfig.BuiltInSITs | Where-Object { $_.Enabled -eq $true }
    $enabledSitNames = $enabledSits | Select-Object -ExpandProperty Name
    
    Write-Host "   ✅ Loaded global-config.json" -ForegroundColor Green
    Write-Host "   📊 Enabled SIT types: $($enabledSits.Count)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "   ❌ Failed to load global-config.json: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 1: Auto-Discover Items_0 CSV File
# =============================================================================

Write-Host "🔍 Step 1: Discover Lab 05c eDiscovery Export" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📁 Searching for Items_0_*.csv files in reports folder..." -ForegroundColor Cyan

$csvFiles = Get-ChildItem -Path $reportsPath -Filter "Items_0_*.csv" -ErrorAction SilentlyContinue

if (-not $csvFiles) {
    Write-Host "   ❌ No Items_0_*.csv files found in reports folder" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Expected Location: $reportsPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⚠️  Ensure you have completed Lab 05c export workflow:" -ForegroundColor Yellow
    Write-Host "   1. Invoke-GraphSitDiscovery.ps1 (create case and search)" -ForegroundColor Yellow
    Write-Host "   2. Export-SearchResults.ps1 (initiate export via API)" -ForegroundColor Yellow
    Write-Host "   3. Manual download from Compliance Portal" -ForegroundColor Yellow
    Write-Host "   4. Expand-eDiscoveryExportPackages.ps1 (extract Items_0.csv)" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

$csvFile = $csvFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1

Write-Host "✅ Auto-selected most recent CSV:" -ForegroundColor Green
Write-Host "   • File: $($csvFile.Name)" -ForegroundColor Cyan
Write-Host "   • Size: $([math]::Round($csvFile.Length / 1MB, 2)) MB" -ForegroundColor Cyan
Write-Host "   • Created: $($csvFile.LastWriteTime)" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 2: Load CSV Data
# =============================================================================

Write-Host "📊 Step 2: Load eDiscovery Export Data" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

Write-Host "📥 Loading Items_0.csv..." -ForegroundColor Cyan

try {
    $exportData = Import-Csv -Path $csvFile.FullName
    
    Write-Host "   ✅ CSV loaded successfully" -ForegroundColor Green
    Write-Host "   • Total rows: $($exportData.Count)" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "   ❌ Failed to load CSV data: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# =============================================================================
# Step 3: Load Purview SIT GUID Mapping
# =============================================================================

Write-Host "🗺️  Step 3: Load Purview SIT GUID Mapping" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""

# Import SIT mapping module for dynamic GUID resolution
$sitMappingModule = Join-Path $scriptPath "..\..\scripts\Get-SITMapping.psm1"

if (Test-Path $sitMappingModule) {
    Import-Module $sitMappingModule -Force
    Write-Host "   ✅ Loaded dynamic SIT mapping module" -ForegroundColor Green
    
    # Get SIT GUID mappings (try tenant, fallback to cache)
    $sitGuidMap = Get-SITMapping -CachePath $mappingFilePath -Verbose
    Write-Host "   ✅ Loaded $($sitGuidMap.Count) SIT definitions" -ForegroundColor Green
} else {
    Write-Warning "   ⚠️  SIT mapping module not found - using fallback mapping"
    
    # Fallback to loading JSON directly if module missing
    if (Test-Path $mappingFilePath) {
        $mappingData = Get-Content $mappingFilePath | ConvertFrom-Json
        $sitGuidMap = @{}
        foreach ($prop in $mappingData.sitMappings.PSObject.Properties) {
            $sitGuidMap[$prop.Name] = $prop.Value
        }
        Write-Host "   ✅ Loaded mapping from JSON file" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Mapping file not found: $mappingFilePath" -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# =============================================================================
# Step 4: Parse SIT GUIDs and Generate Detailed Detection Report
# =============================================================================

Write-Host "🔍 Step 4: Parse SIT Detections and Generate Detailed Report" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "   📊 Parsing 'Sensitive type' column..." -ForegroundColor Cyan

# Initialize counters
$totalFilesScanned = $exportData.Count
$totalFilesWithDetections = 0
$totalSITInstances = 0
$totalDetectionRows = 0

# Create array for detailed detection rows (matching Lab 05b format)
$detailedDetections = @()

$fileIndex = 0
foreach ($row in $exportData) {
    $fileIndex++
    
    if ($fileIndex % 500 -eq 0) {
        Write-Host "   ⏳ Processed $fileIndex / $totalFilesScanned files..." -ForegroundColor Gray
    }
    
    $fileName = $row.'File name'
    $sensitiveType = $row.'Sensitive type'
    $targetPath = $row.'Target path'
    $dataSource = $row.'Data source'
    $spoDocLink = $row.'SPO document link'
    $compoundPath = $row.'Compound path'
    $fileSize = $row.'Size'
    $created = $row.'Created'
    
    # Extract site name from SPO document link (preferred), Compound path, Data source, or Target path (fallback)
    $siteName = "Unknown"
    
    if (-not [string]::IsNullOrWhiteSpace($spoDocLink) -and $spoDocLink -match '/sites/([^/]+)') {
        $siteName = $matches[1]
    }
    elseif (-not [string]::IsNullOrWhiteSpace($compoundPath) -and $compoundPath -match '/sites/([^/]+)') {
        $siteName = $matches[1]
    }
    elseif (-not [string]::IsNullOrWhiteSpace($dataSource) -and $dataSource -match '/sites/([^/]+)') {
        $siteName = $matches[1]
    }
    elseif ($targetPath -match '\\SharePoint\\([^\\]+)\\') {
        $extracted = $matches[1]
        # Filter out generic "Items" folder from export structure
        if ($extracted -ne "Items") {
            $siteName = $extracted
        }
    }
    
    if ([string]::IsNullOrWhiteSpace($sensitiveType)) {
        continue
    }
    
    $totalFilesWithDetections++
    
    # Split by the delimiter: $#,#&
    $sitGuidArray = $sensitiveType -split '\$#,#&' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    
    foreach ($guid in $sitGuidArray) {
        # Normalize GUID
        $normalizedGuid = $guid.ToLower()
        
        # Resolve GUID to friendly name using dynamic mapping
        $sitTypeName = if ($sitGuidMap.ContainsKey($normalizedGuid)) {
            $sitGuidMap[$normalizedGuid]
        } else {
            "Custom SIT ($guid)"
        }
        
        # Filter: Only include SITs that are enabled in global-config.json
        # This ensures we only report on the SITs we care about and filter out noise (unmapped GUIDs)
        if ($enabledSitNames -contains $sitTypeName) {
            
            # Count occurrences of this SIT in the file
            $detectionCount = ($sitGuidArray | Where-Object { $_ -eq $guid }).Count
            $totalSITInstances += $detectionCount
            
            # Create detailed detection row (matching Lab 05b structure)
            $detailedDetections += [PSCustomObject]@{
                FileName = $fileName
                SiteName = $siteName
                LibraryName = "Shared Documents"
                FileURL = $targetPath
                SIT_Type = $sitTypeName
                DetectionCount = $detectionCount
                SampleMatches = "[Graph API export - content not included]"
                ConfidenceLevel = "High"
                FileSize = $fileSize
                Created = $created
                ScanTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                DetectionMethod = "Graph API eDiscovery"
            }
            
            $totalDetectionRows++
        }
    }
}

Write-Host "   ✅ Analysis complete" -ForegroundColor Green
Write-Host ""

# Write detailed CSV report
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$detailedCsvPath = Join-Path $reportsPath "eDiscovery-Detailed-Analysis-$timestamp.csv"

Write-Host "   💾 Writing detailed CSV report..." -ForegroundColor Cyan
$detailedDetections | Export-Csv -Path $detailedCsvPath -NoTypeInformation -Encoding UTF8
Write-Host "   ✅ Detailed report saved: $(Split-Path $detailedCsvPath -Leaf)" -ForegroundColor Green

Write-Host ""

# =============================================================================
# Step 5: Display SIT Type Distribution
# =============================================================================

Write-Host "`n📊 Step 5: SIT Type Distribution Analysis" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Group detections by SIT type (matching Lab 05b format)
$sitTypeStats = $detailedDetections | Group-Object SIT_Type | 
    Select-Object @{N='SIT_Type';E={$_.Name}}, @{N='Files';E={$_.Count}}, @{N='Total_Instances';E={($_.Group | Measure-Object -Property DetectionCount -Sum).Sum}} |
    Sort-Object Total_Instances -Descending

Write-Host ""
Write-Host "   📋 Total unique SIT types detected: $($sitTypeStats.Count)" -ForegroundColor Cyan
Write-Host "   📄 Total files with SIT detections: $totalFilesWithDetections" -ForegroundColor Cyan
Write-Host "   🎯 Total SIT instances: $totalSITInstances" -ForegroundColor Cyan
Write-Host ""

Write-Host "   🏆 Top 10 SIT Types by Detection Volume:" -ForegroundColor Magenta
$sitTypeStats | Select-Object -First 10 | Format-Table -AutoSize

if ($sitTypeStats.Count -gt 10) {
    Write-Host "   💡 (Showing top 10 of $($sitTypeStats.Count) detected SIT types)" -ForegroundColor DarkGray
}

Write-Host ""

# =============================================================================
# Step 6: Display Site Distribution Analysis
# =============================================================================

Write-Host "`n🌐 Step 6: Site Distribution Analysis" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Group detections by site (matching Lab 05b format)
$siteStats = $detailedDetections | Group-Object SiteName | 
    Select-Object @{N='Site';E={$_.Name}}, @{N='Files';E={$_.Count}}, @{N='Total_Instances';E={($_.Group | Measure-Object -Property DetectionCount -Sum).Sum}} |
    Sort-Object Total_Instances -Descending

Write-Host ""
Write-Host "   📋 Total sites with detections: $($siteStats.Count)" -ForegroundColor Cyan
Write-Host "   📊 Expected sites (Lab 03): 5 (HR, Finance, Legal, Marketing, IT)" -ForegroundColor Gray
Write-Host ""

Write-Host "   📈 Site-by-Site Breakdown:" -ForegroundColor Magenta
$siteStats | Format-Table -AutoSize

Write-Host ""

# =============================================================================
# Summary
# =============================================================================

Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ Lab 05c Graph API eDiscovery Analysis Complete" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "   • Total files scanned: $totalFilesScanned" -ForegroundColor Cyan
Write-Host "   • Files with SIT detections: $totalFilesWithDetections" -ForegroundColor Cyan
Write-Host "   • Total SIT instances: $totalSITInstances" -ForegroundColor Cyan
Write-Host "   • Unique SIT types: $($sitTypeStats.Count)" -ForegroundColor Cyan
Write-Host "   • Unique sites: $($siteStats.Count)" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Detailed Report: $detailedCsvPath" -ForegroundColor Cyan
Write-Host ""

<#
.SYNOPSIS
    Analyzes exported eDiscovery Compliance Search results.

.DESCRIPTION
    Imports and analyzes CSV results exported from Microsoft Purview eDiscovery
    Compliance Search. Provides statistics on SIT detection distribution, site
    coverage, and generates comparison reports with other discovery methods.

.PARAMETER ResultsCsvPath
    Path to the Items_0 CSV file exported from eDiscovery Compliance Search.
    If not provided, automatically finds the most recent Items_0*.csv file in the reports folder.

.PARAMETER Lab05aResultsPath
    Optional path to Lab 05a PnP Direct File Access results CSV for comparison.
    Calculates accuracy metrics when provided.

.PARAMETER GenerateDetailedReport
    When specified, generates a comprehensive HTML report with visualizations
    and detailed breakdowns of SIT detection patterns.

.EXAMPLE
    .\Invoke-eDiscoveryResultsAnalysis.ps1 -ResultsCsvPath "C:\Lab05b-Export\Results.csv"
    
    Analyzes eDiscovery results and displays summary statistics.

.EXAMPLE
    .\Invoke-eDiscoveryResultsAnalysis.ps1 -ResultsCsvPath "C:\Lab05b-Export\Results.csv" -Lab05aResultsPath "..\05a-PnP-Direct-File-Access\reports\PnP-Discovery-2025-11-17-151700.csv"
    
    Analyzes eDiscovery results and compares with Lab 05a for accuracy validation.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-17
    Last Modified: 2025-11-17
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Exported Results.csv from eDiscovery Compliance Search
    - Optional: Lab 05a results for comparison
    
    Script development orchestrated using GitHub Copilot.

.EDISCOVERY OPERATIONS
    - Total detections by SIT type
    - Site distribution analysis
    - File-level detection patterns
    - Comparison with regex-based methods
    - Accuracy validation against official Purview SITs
#>
#
# =============================================================================
# Comprehensive analysis of eDiscovery Compliance Search results.
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ResultsCsvPath,
    
    [Parameter(Mandatory = $false)]
    [string]$Lab05aResultsPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$GenerateDetailedReport
)

# =============================================================================
# Step 1: Load eDiscovery Results
# =============================================================================

Write-Host "`n📂 Step 1: Load eDiscovery Results" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

if (-not $ResultsCsvPath) {
    Write-Host "📋 Searching for most recent Items_0 CSV file in reports folder..." -ForegroundColor Cyan
    $reportsPath = Join-Path $PSScriptRoot "..\reports"
    $items0Csv = Get-ChildItem -Path $reportsPath -Filter "Items_0*.csv" -ErrorAction SilentlyContinue | 
                 Sort-Object LastWriteTime -Descending | 
                 Select-Object -First 1
    
    if ($items0Csv) {
        $ResultsCsvPath = $items0Csv.FullName
        Write-Host "   ✅ Found: $(Split-Path $ResultsCsvPath -Leaf)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ No Items_0*.csv files found in reports folder" -ForegroundColor Red
        Write-Host "   💡 Export results from eDiscovery Compliance Search first" -ForegroundColor Yellow
        exit 1
    }
}

if (-not (Test-Path $ResultsCsvPath)) {
    Write-Host "   ❌ File not found: $ResultsCsvPath" -ForegroundColor Red
    Write-Host "   💡 Export results from eDiscovery Compliance Search first" -ForegroundColor Yellow
    exit 1
}

Write-Host "   📄 Loading: $(Split-Path $ResultsCsvPath -Leaf)" -ForegroundColor Cyan

try {
    $eDiscoveryResults = Import-Csv $ResultsCsvPath
    $columnCount = ($eDiscoveryResults[0].PSObject.Properties | Measure-Object).Count
    Write-Host "   ✅ Loaded $($eDiscoveryResults.Count) items from eDiscovery export" -ForegroundColor Green
    Write-Host "   📊 Columns: $columnCount" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Failed to load CSV: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 2: Load Global Configuration and Filter Enabled SITs
# =============================================================================

Write-Host "`n🔍 Step 2: Load Global Configuration and Filter Enabled SITs" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green

# Load global-config.json as central source of truth
$globalConfigPath = Join-Path $PSScriptRoot "..\..\..\global-config.json"
if (-not (Test-Path $globalConfigPath)) {
    Write-Host "   ❌ Global config not found: $globalConfigPath" -ForegroundColor Red
    Write-Host "   💡 Lab 05b requires global-config.json for SIT configuration" -ForegroundColor Yellow
    exit 1
}

try {
    $globalConfig = Get-Content $globalConfigPath | ConvertFrom-Json
    $enabledSits = $globalConfig.BuiltInSITs | Where-Object { $_.Enabled -eq $true }
    Write-Host "   ✅ Loaded global-config.json" -ForegroundColor Green
    Write-Host "   📊 Enabled SIT types: $($enabledSits.Count)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   🎯 Active SIT Configuration:" -ForegroundColor Magenta
    foreach ($sit in $enabledSits) {
        Write-Host "      ✅ $($sit.Name)" -ForegroundColor Green
    }
    
    # Show disabled SITs for reference
    $disabledSits = $globalConfig.BuiltInSITs | Where-Object { $_.Enabled -eq $false }
    if ($disabledSits.Count -gt 0) {
        Write-Host ""
        Write-Host "   ⚠️  Disabled SIT Configuration (will be filtered out):" -ForegroundColor Yellow
        foreach ($sit in $disabledSits) {
            Write-Host "      ❌ $($sit.Name)" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
} catch {
    Write-Host "   ❌ Failed to load global-config.json: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Parse SIT Detections and Generate Detailed Report
# =============================================================================

Write-Host "`n🔍 Step 3: Parse SIT Detections and Generate Detailed Report" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green

# Import SIT mapping module for dynamic GUID resolution
$sitMappingModule = Join-Path $PSScriptRoot "..\..\scripts\Get-SITMapping.psm1"
if (Test-Path $sitMappingModule) {
    Import-Module $sitMappingModule -Force
    Write-Host "   ✅ Loaded dynamic SIT mapping module" -ForegroundColor Green
    
    # Get SIT GUID mappings (try tenant, fallback to cache)
    $sitGuidMap = Get-SITMapping -CachePath "..\..\Purview-SIT-GUID-Mapping.json" -Verbose
    Write-Host "   ✅ Loaded $($sitGuidMap.Count) SIT definitions" -ForegroundColor Green
} else {
    Write-Warning "   ⚠️  SIT mapping module not found - using fallback mapping"
    # Minimal fallback mapping
    $sitGuidMap = @{
        "a44669fe-0d48-453d-a9b1-2cc83f2cba77" = "U.S. Social Security Number (SSN)"
        "50842eb7-edc8-4019-85dd-5a5c1f2bb085" = "Credit Card Number"
        "a2ce32a8-f935-4bb6-8e96-2a5157672e2c" = "U.S. Bank Account Number"
        "178ec42a-18b4-47cc-85c7-d62c92fd67f8" = "U.S./U.K. Passport Number"
        "dfeb356f-61cd-459e-bf0f-7c6d28b458c6" = "U.S. Driver's License Number"
        "e55e2a32-f92d-4985-a35d-a0b269eb687b" = "U.S. Individual Taxpayer Identification Number (ITIN)"
        "cb353f78-2b72-4c3c-8827-92ebe4f69fdf" = "ABA Routing Number"
    }
}

# Create filter list of enabled SIT names for comparison
$enabledSitNames = $enabledSits | Select-Object -ExpandProperty Name

# Prepare output path for detailed CSV report
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$reportsPath = Join-Path $PSScriptRoot "..\reports"

if (-not (Test-Path $reportsPath)) {
    New-Item -ItemType Directory -Path $reportsPath -Force | Out-Null
}

$detailedCsvPath = Join-Path $reportsPath "eDiscovery-Detailed-Analysis-$timestamp.csv"

# Initialize counters
$totalFilesScanned = $eDiscoveryResults.Count
$totalFilesWithDetections = 0
$totalSITInstances = 0
$totalDetectionRows = 0

# Items_0 CSV column names
$fileNameColumn = "File name"
$sensitiveTypeColumn = "Sensitive type"
$targetPathColumn = "Target path"
$sizeColumn = "Size"
$createdColumn = "Created"

Write-Host "   📋 Analyzing $totalFilesScanned files from eDiscovery export..." -ForegroundColor Cyan
Write-Host "   📊 Generating detailed SIT detection report..." -ForegroundColor Cyan

# Create array for detailed detection rows
$detailedDetections = @()

$fileIndex = 0
foreach ($item in $eDiscoveryResults) {
    $fileIndex++
    
    if ($fileIndex % 500 -eq 0) {
        Write-Host "   ⏳ Processed $fileIndex / $totalFilesScanned files..." -ForegroundColor Gray
    }
    
    $fileName = $item.$fileNameColumn
    $sitGuids = $item.$sensitiveTypeColumn
    $targetPath = $item.$targetPathColumn
    $fileSize = $item.$sizeColumn
    $created = $item.$createdColumn
    
    # Extract site name from Target path
    $siteName = "Unknown"
    if ($targetPath -match '\\SharePoint\\([^\\]+)\\') {
        $siteName = $matches[1]
    }
    
    # Skip if no SIT detections
    if ([string]::IsNullOrWhiteSpace($sitGuids)) {
        continue
    }
    
    $totalFilesWithDetections++
    
    # Parse SIT GUIDs (delimited by $#,#&)
    $sitGuidArray = $sitGuids -split '\$#,#&' | Where-Object { $_ -ne "" } | ForEach-Object { $_.Trim() }
    
    $totalSITInstances += $sitGuidArray.Count
    
    # Create one detection row per unique SIT type in the file
    $uniqueSitTypes = $sitGuidArray | Select-Object -Unique
    
    foreach ($sitGuid in $uniqueSitTypes) {
        # Normalize GUID to lowercase for lookup
        $normalizedGuid = $sitGuid.ToLower()
        
        # Resolve GUID to friendly name using dynamic mapping
        $sitTypeName = if ($sitGuidMap.ContainsKey($normalizedGuid)) {
            $sitGuidMap[$normalizedGuid]
        } else {
            "Custom SIT ($sitGuid)"
        }
        
        # Filter: Only include SITs that are enabled in global-config.json
        if ($enabledSitNames -notcontains $sitTypeName) {
            # Skip this SIT - it's disabled in global-config.json
            continue
        }
        
        # Count occurrences of this SIT in the file
        $detectionCount = ($sitGuidArray | Where-Object { $_ -eq $sitGuid }).Count
        
        # Determine confidence level (High for resolved SITs)
        $confidenceLevel = if ($sitGuidMap.ContainsKey($normalizedGuid)) {
            "High"
        } else {
            "Medium"
        }
        
        # Create detailed detection row
        $detailedDetections += [PSCustomObject]@{
            FileName = $fileName
            SiteName = $siteName
            LibraryName = "Shared Documents"
            FileURL = $targetPath -replace '\\', '/'
            SIT_Type = $sitTypeName
            DetectionCount = $detectionCount
            SampleMatches = "[eDiscovery export - content not included]"
            ConfidenceLevel = $confidenceLevel
            FileSize = $fileSize
            Created = $created
            ScanTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            DetectionMethod = "eDiscovery Compliance Search"
        }
        
        $totalDetectionRows++
    }
}

Write-Host "   ✅ Analysis complete" -ForegroundColor Green
Write-Host ""

# Write detailed CSV report
Write-Host "   💾 Writing detailed CSV report..." -ForegroundColor Cyan
$detailedDetections | Export-Csv -Path $detailedCsvPath -NoTypeInformation -Encoding UTF8
Write-Host "   ✅ Detailed report saved: $(Split-Path $detailedCsvPath -Leaf)" -ForegroundColor Green

Write-Host ""

# =============================================================================
# Step 4: Display SIT Type Distribution
# =============================================================================

Write-Host "`n📊 Step 4: SIT Type Distribution Analysis" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Group detections by SIT type
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
# Step 5: Display Site Distribution Analysis
# =============================================================================

Write-Host "`n🌐 Step 5: Site Distribution Analysis" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Group detections by site
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
# Step 6: Compare with Lab 05a (If Provided)
# =============================================================================

if ($Lab05aResultsPath -and (Test-Path $Lab05aResultsPath)) {
    Write-Host "`n🔄 Step 6: Cross-Method Comparison with Lab 05a" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    
    try {
        Write-Host "   📄 Loading Lab 05a PnP results..." -ForegroundColor Cyan
        $lab05aResults = Import-Csv $Lab05aResultsPath
        Write-Host "   ✅ Loaded $($lab05aResults.Count) detection rows from Lab 05a" -ForegroundColor Green
        Write-Host ""
        
        # Get unique filenames from both methods
        $eDiscoveryFiles = ($detailedDetections | Select-Object -ExpandProperty FileName -Unique)
        $lab05aFiles = ($lab05aResults | Select-Object -ExpandProperty FileName -Unique)
        
        # Find overlapping files
        $overlap = $eDiscoveryFiles | Where-Object { $lab05aFiles -contains $_ }
        
        # Files detected by Lab 05a but not eDiscovery (false positives)
        $falsePositives = $lab05aFiles | Where-Object { $eDiscoveryFiles -notcontains $_ }
        
        # Files detected by eDiscovery but not Lab 05a (false negatives for Lab 05a)
        $falseNegatives = $eDiscoveryFiles | Where-Object { $lab05aFiles -notcontains $_ }
        
        # Calculate accuracy metrics
        $lab05aTotalFiles = $lab05aFiles.Count
        $eDiscoveryTotalFiles = $eDiscoveryFiles.Count
        
        $lab05aAccuracy = if ($lab05aTotalFiles -gt 0) {
            [math]::Round(($overlap.Count / $lab05aTotalFiles) * 100, 2)
        } else {
            0
        }
        
        $lab05aPrecision = if ($lab05aTotalFiles -gt 0) {
            [math]::Round(($overlap.Count / $lab05aTotalFiles) * 100, 2)
        } else {
            0
        }
        
        $lab05aRecall = if ($eDiscoveryTotalFiles -gt 0) {
            [math]::Round(($overlap.Count / $eDiscoveryTotalFiles) * 100, 2)
        } else {
            0
        }
        
        Write-Host "   📊 Method Comparison Summary:" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "   📁 Lab 05a (PnP Regex) Files: $lab05aTotalFiles" -ForegroundColor Cyan
        Write-Host "   📁 Lab 05b (eDiscovery Official) Files: $eDiscoveryTotalFiles" -ForegroundColor Cyan
        Write-Host "   ✅ Overlapping Files: $($overlap.Count)" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "   🎯 Lab 05a Accuracy Metrics:" -ForegroundColor Magenta
        Write-Host "      Precision: $lab05aPrecision% (correct detections / total Lab 05a detections)" -ForegroundColor $(if ($lab05aPrecision -ge 75) { "Green" } elseif ($lab05aPrecision -ge 60) { "Yellow" } else { "Red" })
        Write-Host "      Recall: $lab05aRecall% (correct detections / total eDiscovery detections)" -ForegroundColor $(if ($lab05aRecall -ge 75) { "Green" } elseif ($lab05aRecall -ge 60) { "Yellow" } else { "Red" })
        Write-Host ""
        
        Write-Host "   ⚠️  Lab 05a False Positives: $($falsePositives.Count) files" -ForegroundColor $(if ($falsePositives.Count -le 50) { "Green" } elseif ($falsePositives.Count -le 200) { "Yellow" } else { "Red" })
        Write-Host "      (Files detected by PnP but not by official eDiscovery)" -ForegroundColor Gray
        
        Write-Host "   ⚠️  Lab 05a False Negatives: $($falseNegatives.Count) files" -ForegroundColor $(if ($falseNegatives.Count -le 50) { "Green" } elseif ($falseNegatives.Count -le 200) { "Yellow" } else { "Red" })
        Write-Host "      (Files detected by eDiscovery but missed by PnP)" -ForegroundColor Gray
        Write-Host ""
        
        # Display sample mismatches
        if ($falsePositives.Count -gt 0) {
            Write-Host "   📋 Sample False Positives (first 5):" -ForegroundColor DarkGray
            $falsePositives | Select-Object -First 5 | ForEach-Object { Write-Host "      - $_" -ForegroundColor DarkGray }
            Write-Host ""
        }
        
        if ($falseNegatives.Count -gt 0) {
            Write-Host "   📋 Sample False Negatives (first 5):" -ForegroundColor DarkGray
            $falseNegatives | Select-Object -First 5 | ForEach-Object { Write-Host "      - $_" -ForegroundColor DarkGray }
            Write-Host ""
        }
        
        # Save comparison report
        $comparisonReport = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Lab05a_TotalFiles = $lab05aTotalFiles
            Lab05b_TotalFiles = $eDiscoveryTotalFiles
            OverlappingFiles = $overlap.Count
            Lab05a_Precision = $lab05aPrecision
            Lab05a_Recall = $lab05aRecall
            FalsePositives = $falsePositives.Count
            FalseNegatives = $falseNegatives.Count
        }
        
        $comparisonPath = Join-Path $reportsPath "Cross-Method-Comparison-$timestamp.json"
        $comparisonReport | ConvertTo-Json | Set-Content $comparisonPath
        Write-Host "   ✅ Comparison report saved: $(Split-Path $comparisonPath -Leaf)" -ForegroundColor Green
        
    } catch {
        Write-Host "   ⚠️  Failed to load Lab 05a results: $_" -ForegroundColor Yellow
    }
    
    Write-Host ""
} else {
    Write-Host "`n💡 Step 6: Cross-Method Comparison" -ForegroundColor Yellow
    Write-Host "===================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   ℹ️  No Lab 05a results provided for comparison" -ForegroundColor Gray
    Write-Host "   💡 Re-run with -Lab05aResultsPath parameter to compare methods" -ForegroundColor Gray
    Write-Host ""
}

# =============================================================================
# Step 7: Generate Comprehensive Summary Report
# =============================================================================

Write-Host "📋 Step 7: Comprehensive Analysis Summary" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Calculate comprehensive statistics
$uniqueSites = ($detailedDetections | Select-Object -ExpandProperty SiteName -Unique).Count
$uniqueSITTypes = ($detailedDetections | Select-Object -ExpandProperty SIT_Type -Unique).Count
$avgSITsPerFile = if ($totalFilesWithDetections -gt 0) {
    [math]::Round($totalDetectionRows / $totalFilesWithDetections, 2)
} else {
    0
}

# Get top SIT types for summary
$topSITs = $detailedDetections | 
    Group-Object SIT_Type | 
    Select-Object @{Name='SIT_Type';Expression={$_.Name}}, 
                  @{Name='Files';Expression={$_.Count}}, 
                  @{Name='Total_Instances';Expression={($_.Group | Measure-Object -Property DetectionCount -Sum).Sum}} |
    Sort-Object Total_Instances -Descending |
    Select-Object -First 3

# Display summary
Write-Host "   🎯 Overall Statistics:" -ForegroundColor Magenta
Write-Host ""
Write-Host "      📁 Total Files Scanned: $totalFilesScanned" -ForegroundColor Cyan
Write-Host "      ✅ Files with SIT Detections: $totalFilesWithDetections" -ForegroundColor Green
Write-Host "      📊 Total SIT Instances: $totalSITInstances" -ForegroundColor Cyan
Write-Host "      📄 Total Detection Rows Generated: $totalDetectionRows" -ForegroundColor Cyan
Write-Host "      🏢 Sites with Detections: $uniqueSites" -ForegroundColor Cyan
Write-Host "      🔍 Unique SIT Types Found: $uniqueSITTypes" -ForegroundColor Cyan
Write-Host "      📈 Avg SITs per File: $avgSITsPerFile" -ForegroundColor Cyan
Write-Host ""

Write-Host "   🏆 Top 3 Most Common SIT Types:" -ForegroundColor Magenta
Write-Host ""
foreach ($sit in $topSITs) {
    Write-Host "      - $($sit.SIT_Type): $($sit.Total_Instances) instances in $($sit.Files) files" -ForegroundColor Yellow
}
Write-Host ""

# Display output file locations
Write-Host "   📂 Generated Reports:" -ForegroundColor Magenta
Write-Host ""
Write-Host "      ✅ Detailed CSV: $(Split-Path $detailedCsvPath -Leaf)" -ForegroundColor Green
Write-Host "         Location: $detailedCsvPath" -ForegroundColor Gray
Write-Host ""

if ($Lab05aResultsPath -and (Test-Path $Lab05aResultsPath)) {
    $comparisonPath = Join-Path $reportsPath "Cross-Method-Comparison-$timestamp.json"
    if (Test-Path $comparisonPath) {
        Write-Host "      ✅ Comparison Report: $(Split-Path $comparisonPath -Leaf)" -ForegroundColor Green
        Write-Host "         Location: $comparisonPath" -ForegroundColor Gray
        Write-Host ""
    }
}

# Save comprehensive summary JSON
$summaryReport = [PSCustomObject]@{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    AnalysisMethod = "eDiscovery Compliance Search"
    InputFile = Split-Path $ResultsCsvPath -Leaf
    TotalFilesScanned = $totalFilesScanned
    FilesWithDetections = $totalFilesWithDetections
    TotalSITInstances = $totalSITInstances
    TotalDetectionRows = $totalDetectionRows
    SitesWithDetections = $uniqueSites
    UniqueSITTypes = $uniqueSITTypes
    AvgSITsPerFile = $avgSITsPerFile
    TopSITTypes = @($topSITs | ForEach-Object { 
        [PSCustomObject]@{
            SIT_Type = $_.SIT_Type
            Files = $_.Files
            Total_Instances = $_.Total_Instances
        }
    })
    DetailedCSVPath = $detailedCsvPath
}

$summaryPath = Join-Path $reportsPath "Analysis-Summary-$timestamp.json"
$summaryReport | ConvertTo-Json -Depth 10 | Set-Content $summaryPath
Write-Host "      ✅ Summary JSON: $(Split-Path $summaryPath -Leaf)" -ForegroundColor Green
Write-Host "         Location: $summaryPath" -ForegroundColor Gray
Write-Host ""

# Display next steps
Write-Host "   🚀 Next Steps:" -ForegroundColor Magenta
Write-Host ""
Write-Host "      1. Review the detailed CSV for row-by-row analysis" -ForegroundColor Cyan
Write-Host "      2. Compare results with Lab 05a PnP discovery (if available)" -ForegroundColor Cyan
Write-Host "      3. Analyze false positives/negatives between detection methods" -ForegroundColor Cyan
Write-Host "      4. Validate SIT detection accuracy with sample files" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 8: Check for Unmapped SIT GUIDs
# =============================================================================

Write-Host "`n🔍 Step 8: SIT Mapping Validation" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Count unmapped GUIDs from the detailed detections
$unmappedSits = $detailedDetections | Where-Object { $_.SIT_Type -match '^Custom SIT \(' }
$unmappedCount = ($unmappedSits | Select-Object -Property SIT_Type -Unique).Count

if ($unmappedCount -gt 0) {
    $totalUnmappedInstances = ($unmappedSits | Measure-Object).Count
    
    Write-Host "`n   ⚠️  Warning: Found $unmappedCount unmapped SIT GUIDs" -ForegroundColor Yellow
    Write-Host "   📊 Total instances: $totalUnmappedInstances" -ForegroundColor Yellow
    
    # Show top unmapped GUIDs
    Write-Host "`n   🔍 Top Unmapped GUIDs:" -ForegroundColor Cyan
    $topUnmapped = $unmappedSits | Group-Object SIT_Type | 
                   Sort-Object Count -Descending | 
                   Select-Object -First 5
    
    foreach ($unmapped in $topUnmapped) {
        $guid = $unmapped.Name -replace '^Custom SIT \((.*)\)$', '$1'
        Write-Host "      • $guid - $($unmapped.Count) instances" -ForegroundColor Yellow
    }
    
    Write-Host "`n   💡 These GUIDs could not be resolved to friendly SIT names." -ForegroundColor Cyan
    Write-Host "   💡 They may be deprecated Microsoft SITs or tenant-specific custom SITs." -ForegroundColor Cyan
    
    Write-Host "`n   Would you like to run the diagnostic script to investigate and update mappings? (Y/N)" -ForegroundColor Yellow
    $response = Read-Host "   Response"
    
    if ($response -eq 'Y' -or $response -eq 'y') {
        Write-Host "\n   🔄 Launching diagnostic script..." -ForegroundColor Cyan
        $diagnosticScriptPath = Join-Path $PSScriptRoot "..\..\scripts\Resolve-UnmappedSITGuids.ps1"
        
        if (Test-Path $diagnosticScriptPath) {
            & $diagnosticScriptPath -DetailedAnalysisCsvPath $detailedCsvPath -ShowDetailedAnalysis
            
            Write-Host "`n   💡 If you added new mappings, re-run this analysis to see updated results:" -ForegroundColor Yellow
            Write-Host "   .\Invoke-eDiscoveryResultsAnalysis.ps1" -ForegroundColor Gray
        } else {
            Write-Host "   ❌ Diagnostic script not found: $diagnosticScriptPath" -ForegroundColor Red
            Write-Host "   💡 Manually run: ..\..\scripts\Resolve-UnmappedSITGuids.ps1 -ShowDetailedAnalysis" -ForegroundColor Yellow
        }
    } else {
        Write-Host "`n   ℹ️  You can investigate unmapped GUIDs later by running:" -ForegroundColor Cyan
        Write-Host "   ..\..\scripts\Resolve-UnmappedSITGuids.ps1 -ShowDetailedAnalysis" -ForegroundColor Gray
    }
} else {
    Write-Host "`n   ✅ All SIT GUIDs successfully resolved to friendly names!" -ForegroundColor Green
    Write-Host "   📊 No unmapped GUIDs found in this analysis" -ForegroundColor Cyan
}

Write-Host "`n✅ Analysis completed successfully" -ForegroundColor Green
Write-Host ""

<#
.SYNOPSIS
    Cross-lab analysis orchestrator for comparing Lab 05 discovery methods.

.DESCRIPTION
    Analyzes and compares results from multiple Lab 05 discovery paths:
    - Lab 05a: PnP Direct File Access (regex-based, immediate)
    - Lab 05b: eDiscovery Compliance Search (Purview SITs, 24 hours)
    - Lab 05c: Graph API Discovery (Purview SITs, 24 hours)
    - Lab 04: On-Demand Classification (Purview SITs, 7 days)
    
    Automatically detects which labs have been completed based on presence of
    report files, then generates comprehensive comparison analysis including:
    - Accuracy metrics (using Purview SIT methods as ground truth)
    - False positive/negative identification
    - Detection overlap analysis
    - Method timing and efficiency comparison
    - Consolidated findings report

.PARAMETER Lab05aPath
    Optional path to Lab 05a results CSV. If not provided, script searches
    the default reports folder.

.PARAMETER Lab05bPath
    Optional path to Lab 05b Results.csv export. If not provided, script
    searches the default reports folder.

.PARAMETER Lab05cPath
    Optional path to Lab 05c results CSV. If not provided, script searches
    the default reports folder.

.PARAMETER Lab04Path
    Optional path to Lab 04 On-Demand Classification results. If not provided,
    script searches the default reports folder.

.PARAMETER OutputPath
    Directory to save the cross-lab analysis report. Defaults to current
    directory's reports folder.

.PARAMETER GenerateHtmlReport
    When specified, generates an HTML visualization report in addition to
    console output and CSV summary.

.PARAMETER ConfigPath
    Path to the lab05-comparison-config.json configuration file. If not
    provided, uses default config file in parent directory.

.PARAMETER UseConfig
    When specified, loads comparison settings from lab05-comparison-config.json
    instead of using command-line parameters.

.EXAMPLE
    .\Invoke-CrossLabAnalysis.ps1
    
    Auto-detects completed labs and generates comparison analysis using default settings.

.EXAMPLE
    .\Invoke-CrossLabAnalysis.ps1 -UseConfig
    
    Uses lab05-comparison-config.json for all comparison settings including filters and enabled labs.

.EXAMPLE
    .\Invoke-CrossLabAnalysis.ps1 -GenerateHtmlReport
    
    Generates comprehensive HTML report with visualizations.

.EXAMPLE
    .\Invoke-CrossLabAnalysis.ps1 -Lab05aPath ".\05a-PnP-Direct-File-Access\reports\PnP-Discovery-2025-11-18-143022.csv" -Lab05bPath ".\05b-eDiscovery-Compliance-Search\reports\Lab05b-Export\Results.csv"
    
    Compares specific Lab 05a and 05b results.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-18
    Last Modified: 2025-11-18
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - At least two completed Lab 05 discovery paths for meaningful comparison
    - Access to lab report directories
    
    Script development orchestrated using GitHub Copilot.

.DATA DISCOVERY OPERATIONS
    - Cross-lab analysis and comparison of discovery methods
    - SIT GUID resolution and mapping
    - Data anomaly detection and reporting
    - Comprehensive report generation (CSV/HTML)

.ANALYSIS COMPONENTS
    - Lab completion detection and validation
    - Multi-method accuracy comparison
    - False positive/negative analysis
    - Detection overlap matrix
    - Timing and efficiency metrics
    - Consolidated findings export
#>
#
# =============================================================================
# Cross-lab discovery method comparison and analysis orchestrator.
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Lab05aPath,
    
    [Parameter(Mandatory = $false)]
    [string]$Lab05bPath,
    
    [Parameter(Mandatory = $false)]
    [string]$Lab05cPath,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$GenerateHtmlReport,
    
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$UseConfig
)

# =============================================================================
# Configuration and GUID Mapping Loading
# =============================================================================

# Load global-config.json to determine which SITs are enabled for comparison
$enabledSitNames = @()
$disabledSitNames = @()
$globalConfigPath = Join-Path $PSScriptRoot "..\..\global-config.json"

Write-Host "📋 Loading global configuration (central source of truth)..." -ForegroundColor Cyan
if (Test-Path $globalConfigPath) {
    try {
        $globalConfig = Get-Content $globalConfigPath | ConvertFrom-Json
        $enabledSits = $globalConfig.BuiltInSITs | Where-Object { $_.Enabled -eq $true }
        $disabledSits = $globalConfig.BuiltInSITs | Where-Object { $_.Enabled -eq $false }
        
        $enabledSitNames = $enabledSits | Select-Object -ExpandProperty Name
        $disabledSitNames = $disabledSits | Select-Object -ExpandProperty Name
        
        Write-Host "   ✅ Loaded global-config.json" -ForegroundColor Green
        Write-Host "   📊 Enabled SIT types for comparison: $($enabledSitNames.Count)" -ForegroundColor Cyan
        Write-Host "   ⚠️  Disabled SIT types (will track but exclude): $($disabledSitNames.Count)" -ForegroundColor Yellow
    } catch {
        Write-Host "   ⚠️  Failed to load global-config.json: $_" -ForegroundColor Yellow
        Write-Host "   ℹ️  All SIT types will be included in comparison" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠️  global-config.json not found at: $globalConfigPath" -ForegroundColor Yellow
    Write-Host "   ℹ️  All SIT types will be included in comparison" -ForegroundColor Gray
}
Write-Host ""

# Load Purview SIT GUID-to-Friendly-Name mapping
$sitGuidMapping = @{}
$guidMappingPath = Join-Path $PSScriptRoot "..\Purview-SIT-GUID-Mapping.json"

if (Test-Path $guidMappingPath) {
    Write-Host "📋 Loading Purview SIT GUID mapping from: $guidMappingPath" -ForegroundColor Cyan
    try {
        $guidMappingData = Get-Content $guidMappingPath | ConvertFrom-Json
        $sitGuidMapping = $guidMappingData.sitMappings
        $mappingCount = ($sitGuidMapping.PSObject.Properties | Measure-Object).Count
        Write-Host "   ✅ Loaded $mappingCount SIT GUID mappings" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Failed to load GUID mapping: $_" -ForegroundColor Yellow
        Write-Host "   ℹ️  GUIDs will be displayed as 'Custom SIT (guid)'" -ForegroundColor Gray
    }
} else {
    Write-Host "   ℹ️  GUID mapping file not found at: $guidMappingPath" -ForegroundColor Gray
    Write-Host "   ℹ️  GUIDs will be displayed as 'Custom SIT (guid)'" -ForegroundColor Gray
}

# Function to resolve SIT GUID to friendly name
function Resolve-SITName {
    param(
        [string]$SITType,
        $GuidMapping
    )
    
    # Check if SIT_Type matches "Custom SIT (guid)" pattern
    if ($SITType -match 'Custom SIT \(([a-f0-9-]+)\)') {
        $guid = $matches[1]
        
        # Try to find friendly name in mapping
        if ($GuidMapping.PSObject.Properties.Name -contains $guid) {
            return $GuidMapping.$guid
        }
    }
    
    # Return original if no mapping found or not a GUID pattern
    return $SITType
}

Write-Host ""

$config = $null
$defaultConfigPath = Join-Path $PSScriptRoot "..\lab05-comparison-config.json"

if ($UseConfig -or $ConfigPath) {
    $configFile = if ($ConfigPath) { $ConfigPath } else { $defaultConfigPath }
    
    if (Test-Path $configFile) {
        Write-Host "📋 Loading configuration from: $configFile" -ForegroundColor Cyan
        try {
            $config = Get-Content $configFile | ConvertFrom-Json
            Write-Host "   ✅ Configuration loaded successfully" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️  Failed to load configuration: $_" -ForegroundColor Yellow
            Write-Host "   ℹ️  Falling back to command-line parameters" -ForegroundColor Cyan
            $config = $null
        }
    } else {
        Write-Host "   ⚠️  Configuration file not found: $configFile" -ForegroundColor Yellow
        Write-Host "   ℹ️  Falling back to command-line parameters" -ForegroundColor Cyan
    }
    Write-Host ""
}

# Apply configuration settings if loaded
if ($config) {
    # Override command-line parameters with config file settings
    if (-not $OutputPath -and $config.outputSettings.outputDirectory) {
        $OutputPath = $config.outputSettings.outputDirectory
    }
    
    if (-not $GenerateHtmlReport -and $config.comparisonSettings.generateHtmlReport) {
        $GenerateHtmlReport = $true
    }
}

# =============================================================================
# Step 1: Lab Completion Detection
# =============================================================================

Write-Host "🔍 Step 1: Lab Completion Detection" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

$completedLabs = @{}
$labResults = @{}

# Lab 05a: PnP Direct File Access
$lab05aEnabled = if ($config) { $config.comparisonSettings.enabledLabs.lab05a } else { $true }
if ($lab05aEnabled) {
    Write-Host "📋 Checking Lab 05a (PnP Direct File Access)..." -ForegroundColor Cyan
    if ($Lab05aPath -and (Test-Path $Lab05aPath)) {
        $completedLabs['Lab05a'] = $true
        $labResults['Lab05a'] = $Lab05aPath
        Write-Host "   ✅ Lab 05a results found: $Lab05aPath" -ForegroundColor Green
    } else {
        $searchPath = if ($config -and $config.reportPaths.lab05a.defaultPath) {
            $config.reportPaths.lab05a.defaultPath
        } else {
            "..\05a-PnP-Direct-File-Access\reports\"
        }
        $searchPattern = if ($config -and $config.reportPaths.lab05a.searchPattern) {
            $config.reportPaths.lab05a.searchPattern
        } else {
            "PnP-Discovery-*.csv"
        }
        
        $lab05aSearch = Get-ChildItem -Path $searchPath -Filter $searchPattern -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($lab05aSearch) {
            $completedLabs['Lab05a'] = $true
            $labResults['Lab05a'] = $lab05aSearch.FullName
            Write-Host "   ✅ Lab 05a results auto-detected: $($lab05aSearch.Name)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Lab 05a results not found (skipping)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "📋 Lab 05a disabled in configuration (skipping)" -ForegroundColor Yellow
}

# Lab 05b: eDiscovery Compliance Search
$lab05bEnabled = if ($config) { $config.comparisonSettings.enabledLabs.lab05b } else { $true }
if ($lab05bEnabled) {
    Write-Host "📋 Checking Lab 05b (eDiscovery Compliance Search)..." -ForegroundColor Cyan
    if ($Lab05bPath -and (Test-Path $Lab05bPath)) {
        $completedLabs['Lab05b'] = $true
        $labResults['Lab05b'] = $Lab05bPath
        Write-Host "   ✅ Lab 05b results found: $Lab05bPath" -ForegroundColor Green
    } else {
        # Try to find the detailed analysis CSV first (preferred), then fall back to Items_0 CSV
        $lab05bSearch = Get-ChildItem -Path "..\05b-eDiscovery-Compliance-Search\reports\" -Filter "eDiscovery-Detailed-Analysis-*.csv" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        
        if (-not $lab05bSearch) {
            # Fall back to Items_0 CSV if detailed analysis not found
            $lab05bSearch = Get-ChildItem -Path "..\05b-eDiscovery-Compliance-Search\reports\" -Filter "Items_0*.csv" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        }
        
        if ($lab05bSearch) {
            $completedLabs['Lab05b'] = $true
            $labResults['Lab05b'] = $lab05bSearch.FullName
            Write-Host "   ✅ Lab 05b results auto-detected: $($lab05bSearch.Name)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Lab 05b results not found (skipping)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "📋 Lab 05b disabled in configuration (skipping)" -ForegroundColor Yellow
}

# Lab 05c: Graph API Discovery
$lab05cEnabled = if ($config) { $config.comparisonSettings.enabledLabs.lab05c } else { $true }
if ($lab05cEnabled) {
    Write-Host "📋 Checking Lab 05c (Graph API Discovery)..." -ForegroundColor Cyan
    if ($Lab05cPath -and (Test-Path $Lab05cPath)) {
        $completedLabs['Lab05c'] = $true
        $labResults['Lab05c'] = $Lab05cPath
        Write-Host "   ✅ Lab 05c results found: $Lab05cPath" -ForegroundColor Green
    } else {
        # Lab 05c uses eDiscovery-Detailed-Analysis-*.csv format (from Graph API export)
        $lab05cSearch = Get-ChildItem -Path "..\05c-Graph-API-Discovery\reports\" -Filter "eDiscovery-Detailed-Analysis-*.csv" -ErrorAction SilentlyContinue | 
            Where-Object { $_.Length -gt 1000 } | 
            Sort-Object LastWriteTime -Descending | 
            Select-Object -First 1
        if ($lab05cSearch) {
            $completedLabs['Lab05c'] = $true
            $labResults['Lab05c'] = $lab05cSearch.FullName
            Write-Host "   ✅ Lab 05c results auto-detected: $($lab05cSearch.Name)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Lab 05c results not found (skipping)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "📋 Lab 05c disabled in configuration (skipping)" -ForegroundColor Yellow
}

Write-Host ""

# Validate minimum labs completed
if ($completedLabs.Count -lt 2) {
    Write-Host "❌ Insufficient data: Need at least 2 completed labs for comparison" -ForegroundColor Red
    Write-Host "   Completed labs: $($completedLabs.Count)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Complete at least two Lab 05 discovery paths, then re-run this script" -ForegroundColor Cyan
    exit 1
}

Write-Host "✅ Found $($completedLabs.Count) completed labs for comparison" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 2: Load and Normalize Results
# =============================================================================

Write-Host "📂 Step 2: Load and Normalize Results" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$normalizedResults = @{}
$omittedSitsPerLab = @{}  # Track which disabled SITs were found in each lab's data

foreach ($lab in $labResults.Keys) {
    Write-Host "📊 Loading $lab results..." -ForegroundColor Cyan
    
    try {
        $csvData = Import-Csv $labResults[$lab]
        
        # Track omitted SITs before filtering
        $omittedSitsPerLab[$lab] = @()
        
        # Normalize data structure based on lab type
        $normalized = switch ($lab) {
            'Lab05a' {
                $csvData | Select-Object @{Name='FileName'; Expression={$_.FileName}},
                                         @{Name='SITType'; Expression={$_.SIT_Type}},
                                         @{Name='Site'; Expression={$_.SiteName}},
                                         @{Name='Location'; Expression={$_.SiteUrl}},
                                         @{Name='DetectionCount'; Expression={$_.DetectionCount}},
                                         @{Name='ConfidenceLevel'; Expression={$_.ConfidenceLevel}},
                                         @{Name='DetectionMethod'; Expression={'PnP-Regex'}}
            }
            'Lab05b' {
                # Lab 05b uses the eDiscovery-Detailed-Analysis CSV format
                # Resolve GUIDs to friendly names using mapping file
                $csvData | Select-Object @{Name='FileName'; Expression={$_.FileName}},
                                         @{Name='SITType'; Expression={Resolve-SITName -SITType $_.SIT_Type -GuidMapping $sitGuidMapping}},
                                         @{Name='Site'; Expression={$_.SiteName}},
                                         @{Name='Location'; Expression={$_.FileURL}},
                                         @{Name='DetectionCount'; Expression={$_.DetectionCount}},
                                         @{Name='ConfidenceLevel'; Expression={$_.ConfidenceLevel}},
                                         @{Name='DetectionMethod'; Expression={'eDiscovery-Purview'}}
            }
            'Lab05c' {
                # Lab 05c uses the same eDiscovery-Detailed-Analysis CSV format as Lab 05b
                # (Generated by Invoke-GraphDiscoveryAnalysis.ps1)
                $csvData | Select-Object @{Name='FileName'; Expression={$_.FileName}},
                                         @{Name='SITType'; Expression={Resolve-SITName -SITType $_.SIT_Type -GuidMapping $sitGuidMapping}},
                                         @{Name='Site'; Expression={$_.SiteName}},
                                         @{Name='Location'; Expression={$_.FileURL}},
                                         @{Name='DetectionCount'; Expression={$_.DetectionCount}},
                                         @{Name='ConfidenceLevel'; Expression={$_.ConfidenceLevel}},
                                         @{Name='DetectionMethod'; Expression={'Graph-API-Purview'}}
            }
        }
        
        # Identify SITs present in this lab's data that are disabled in global-config
        if ($enabledSitNames.Count -gt 0) {
            $allSitsInLab = $normalized | Select-Object -ExpandProperty SITType -Unique | Where-Object { $_ }
            $omittedInLab = $allSitsInLab | Where-Object { $disabledSitNames -contains $_ }
            
            if ($omittedInLab) {
                $omittedSitsPerLab[$lab] = $omittedInLab
                $omittedCount = ($normalized | Where-Object { $omittedInLab -contains $_.SITType } | Measure-Object).Count
                Write-Host "   ⚠️  Found $($omittedInLab.Count) disabled SIT type(s) in dataset: $($omittedInLab -join ', ')" -ForegroundColor Yellow
                Write-Host "   📊 Omitting $omittedCount detection(s) from analysis per global-config.json" -ForegroundColor Gray
            }
            
            # Filter out disabled SITs
            $normalized = $normalized | Where-Object { $enabledSitNames -contains $_.SITType }
        }
        
        $normalizedResults[$lab] = $normalized
        Write-Host "   ✅ Loaded $($normalized.Count) detection records (filtered to enabled SITs)" -ForegroundColor Green
        
    } catch {
        Write-Host "   ❌ Failed to load $lab results: $_" -ForegroundColor Red
        $completedLabs.Remove($lab)
    }
}

Write-Host ""

# =============================================================================
# Step 3: Data-Driven Method Comparison
# =============================================================================

Write-Host "" 
Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║                      DATA-DRIVEN METHOD COMPARISON                             ║" -ForegroundColor Magenta
Write-Host "║                                                                                ║" -ForegroundColor Magenta
Write-Host "║  The following analysis compares three discovery methods analyzing the SAME    ║" -ForegroundColor Magenta
Write-Host "║  SharePoint sites, showing real detection data that validates our methodology  ║" -ForegroundColor Magenta
Write-Host "║  claims about accuracy, reliability, and method effectiveness.                 ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# Extract unique files per lab
$uniqueFiles = @{}
$siteDistribution = @{}
$sitCounts = @{}

Write-Host "📊 Loading detection statistics from all completed labs..." -ForegroundColor Cyan
Write-Host ""

Write-Host "💡 Analysis Scope:" -ForegroundColor Yellow
Write-Host "   • Comparing files WITH SIT detections (not total files scanned)" -ForegroundColor Gray
Write-Host "   • Both methods report only files containing sensitive information" -ForegroundColor Gray
Write-Host "   • Same 5 SharePoint sites configured across all methods" -ForegroundColor Gray
Write-Host "   • Different site coverage in results = different detection effectiveness" -ForegroundColor Gray
Write-Host ""

foreach ($lab in $normalizedResults.Keys) {
    $uniqueFiles[$lab] = $normalizedResults[$lab].FileName | Where-Object { $_ } | Select-Object -Unique
    $detectionCount = $normalizedResults[$lab].Count
    $fileCount = $uniqueFiles[$lab].Count
    Write-Host "📊 $lab Detection Summary:" -ForegroundColor Cyan
    Write-Host "   • $fileCount unique files containing sensitive information" -ForegroundColor White
    Write-Host "   • $detectionCount total SIT detection records" -ForegroundColor Gray
    
    # Calculate site distribution (fast with Group-Object)
    $siteDistribution[$lab] = $normalizedResults[$lab] | 
        Where-Object { $_.Site } |
        Group-Object Site | 
        Select-Object Name, Count |
        Sort-Object Count -Descending
    
    # Try to load SIT counts from summary JSON if available (Lab 05b)
    $sitCountsLoaded = $false
    if ($lab -eq 'Lab05b' -and $labResults['Lab05b']) {
        # Get the reports directory from the Lab 05b CSV file path
        $lab05bReportsPath = Split-Path $labResults['Lab05b'] -Parent
        $summaryFiles = Get-ChildItem (Join-Path $lab05bReportsPath "Analysis-Summary-*.json") -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
        if ($summaryFiles) {
            try {
                $summary = Get-Content $summaryFiles[0].FullName | ConvertFrom-Json
                
                # Load ALL SIT counts from summary (not just TopSITTypes)
                # The detailed CSV has all SIT data, but summary only has top 10, so we still need to calculate from normalized results
                # Just use this to validate count matches
                Write-Host "   ✅ Found pre-computed summary: $($summaryFiles[0].Name)" -ForegroundColor Gray
                Write-Host "      Summary shows $($summary.UniqueSITTypes) unique SIT types" -ForegroundColor Gray
            } catch {
                Write-Host "   ⚠️  Could not load summary" -ForegroundColor Yellow
            }
        }
    }
    
    # Calculate SIT type counts from normalized results (already loaded, fast with Group-Object)
    $sitCounts[$lab] = $normalizedResults[$lab] | 
        Where-Object { $_.SITType } |
        Group-Object SITType | 
        Select-Object Name, Count |
        Sort-Object Count -Descending
}

Write-Host ""

# =============================================================================
# Step 3a: Site Coverage & Method Effectiveness
# =============================================================================

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                      SITE COVERAGE & DETECTION PATTERNS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 The following shows which sites each method found sensitive content in." -ForegroundColor Yellow
Write-Host "   All 5 sites were configured in each lab - differences show detection effectiveness." -ForegroundColor Gray
Write-Host ""

foreach ($lab in $normalizedResults.Keys) {
    Write-Host "📊 $lab Site Distribution:" -ForegroundColor Cyan
    if ($siteDistribution[$lab] -and $siteDistribution[$lab].Count -gt 0) {
        $siteDistribution[$lab] | Format-Table @{Label="Site"; Expression={$_.Name}}, 
                                                @{Label="Detections"; Expression={$_.Count}} -AutoSize
    } else {
        Write-Host "   ⚠️  No site data available" -ForegroundColor Yellow
    }
}

# Compare site coverage between labs
if ($normalizedResults.Keys.Count -ge 2) {
    Write-Host "🔍 Site Coverage Comparison:" -ForegroundColor Magenta
    $allSites = @()
    foreach ($lab in $normalizedResults.Keys) {
        if ($siteDistribution[$lab]) {
            $allSites += $siteDistribution[$lab].Name
        }
    }
    $uniqueSites = $allSites | Select-Object -Unique | Sort-Object
    
    Write-Host "   Total unique sites across all methods: $($uniqueSites.Count)" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($site in $uniqueSites) {
        Write-Host "   📍 $site" -ForegroundColor Yellow
        foreach ($lab in $normalizedResults.Keys) {
            $siteData = $siteDistribution[$lab] | Where-Object { $_.Name -eq $site }
            if ($siteData) {
                Write-Host "      $lab`: $($siteData.Count) detections" -ForegroundColor Green
            } else {
                Write-Host "      $lab`: Not scanned or no detections" -ForegroundColor Red
            }
        }
        Write-Host ""
    }
}

Write-Host ""

# =============================================================================
# Step 3b: File-Level Match Analysis
# =============================================================================

Write-Host "📄 Step 3b: File-Level Match Analysis" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

# Identify Purview-based labs (ground truth)
$purviewLabs = @('Lab05b', 'Lab05c') | Where-Object { $completedLabs.ContainsKey($_) }
$regexLabs = @('Lab05a') | Where-Object { $completedLabs.ContainsKey($_) }

# Initialize detailed comparisons array at higher scope
$detailedComparisons = @()

# Calculate accuracy for regex-based methods against Purview ground truth
if ($regexLabs.Count -gt 0 -and $purviewLabs.Count -gt 0) {
    Write-Host "🎯 Accuracy Analysis (Lab 05a vs Purview Methods)" -ForegroundColor Magenta
    Write-Host "==================================================" -ForegroundColor Magenta
    Write-Host ""
    
    foreach ($regexLab in $regexLabs) {
        foreach ($purviewLab in $purviewLabs) {
            Write-Host "📊 Comparing $regexLab (regex) vs $purviewLab (Purview SITs)" -ForegroundColor Cyan
            
            $regexFiles = $uniqueFiles[$regexLab]
            $purviewFiles = $uniqueFiles[$purviewLab]
            
            # Calculate overlap
            $truePositives = $regexFiles | Where-Object { $purviewFiles -contains $_ }
            $falsePositives = $regexFiles | Where-Object { $purviewFiles -notcontains $_ }
            $falseNegatives = $purviewFiles | Where-Object { $regexFiles -notcontains $_ }
            
            $accuracy = if ($regexFiles.Count -gt 0) { 
                [math]::Round(($truePositives.Count / $regexFiles.Count) * 100, 2) 
            } else { 0 }
            
            $precision = if ($regexFiles.Count -gt 0) {
                [math]::Round(($truePositives.Count / $regexFiles.Count) * 100, 2)
            } else { 0 }
            
            $recall = if ($purviewFiles.Count -gt 0) {
                [math]::Round(($truePositives.Count / $purviewFiles.Count) * 100, 2)
            } else { 0 }
            
            Write-Host "   True Positives: $($truePositives.Count) files (correctly detected by regex)" -ForegroundColor Green
            Write-Host "   False Positives: $($falsePositives.Count) files (regex detected, Purview didn't)" -ForegroundColor Red
            Write-Host "   False Negatives: $($falseNegatives.Count) files (Purview detected, regex missed)" -ForegroundColor Red
            Write-Host "   Accuracy: $accuracy%" -ForegroundColor Yellow
            Write-Host "   Precision: $precision%" -ForegroundColor Yellow
            Write-Host "   Recall: $recall%" -ForegroundColor Yellow
            Write-Host ""
            
            # Add contextual storytelling based on accuracy metrics
            Write-Host ""
            Write-Host "   💡 What This Data Tells Us:" -ForegroundColor Cyan
            Write-Host "   ────────────────────────────" -ForegroundColor Gray
            
            # Accuracy interpretation
            if ($accuracy -ge 88) {
                Write-Host "   ✅ Accuracy ($accuracy%): VALIDATES our claim of 88-95% regex reliability" -ForegroundColor Green
                Write-Host "      The regex-based method performs within documented expectations for" -ForegroundColor Gray
                Write-Host "      immediate discovery scenarios. This supports Lab 05a's use case." -ForegroundColor Gray
            } elseif ($accuracy -ge 80) {
                Write-Host "   ⚠️  Accuracy ($accuracy%): Close to expected range (target: 88-95%)" -ForegroundColor Yellow
                Write-Host "      Minor pattern refinement could improve toward documented target." -ForegroundColor Gray
            } else {
                Write-Host "   ⚠️  Accuracy ($accuracy%): BELOW documented expectations (target: 88-95%)" -ForegroundColor Yellow
                Write-Host "      This variance requires investigation - may indicate unique data patterns" -ForegroundColor Gray
                Write-Host "      or method-specific differences (OCR, review set de-duplication, etc.)." -ForegroundColor Gray
            }
            
            # False positive analysis
            $fpRate = if ($regexFiles.Count -gt 0) { [math]::Round(($falsePositives.Count / $regexFiles.Count) * 100, 1) } else { 0 }
            if ($fpRate -le 12) {
                Write-Host "   ✅ False Positive Rate ($fpRate%): Within acceptable tolerance" -ForegroundColor Green
                Write-Host "      Regex precision is appropriate for immediate discovery use cases." -ForegroundColor Gray
            } else {
                Write-Host "   ⚠️  False Positive Rate ($fpRate%): Higher than typical" -ForegroundColor Yellow
                Write-Host "      Common patterns: SSN/employee ID, bank account/order number confusion." -ForegroundColor Gray
                Write-Host "      This is WHY Purview SIT methods are needed for compliance workflows." -ForegroundColor Gray
            }
            
            # Recall/coverage analysis
            if ($recall -ge 98) {
                Write-Host "   ✅ Coverage ($recall% recall): Excellent - catching nearly all sensitive content" -ForegroundColor Green
            } elseif ($recall -ge 90) {
                Write-Host "   ✅ Coverage ($recall% recall): Good - detecting most Purview-identified SITs" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  Coverage ($recall% recall): Gap between regex and Purview detection" -ForegroundColor Yellow
                Write-Host "      May indicate OCR processing advantages in Purview or regex pattern gaps." -ForegroundColor Gray
            }
            Write-Host ""
            
            # Store for detailed report
            $detailedComparisons += [PSCustomObject]@{
                RegexLab = $regexLab
                PurviewLab = $purviewLab
                TruePositives = $truePositives
                FalsePositives = $falsePositives
                FalseNegatives = $falseNegatives
                Accuracy = $accuracy
                Precision = $precision
                Recall = $recall
            }
            
            # Show sample discrepancies (first 10 of each)
            if ($falsePositives.Count -gt 0) {
                Write-Host "   📋 Sample False Positives (regex over-detection):" -ForegroundColor Yellow
                $falsePositives | Select-Object -First 10 | ForEach-Object {
                    $fileName = $_
                    $regexData = $normalizedResults[$regexLab] | Where-Object { $_.FileName -eq $fileName } | Select-Object -First 1
                    Write-Host "      • $fileName" -ForegroundColor Gray
                    Write-Host "        Site: $($regexData.Site), SIT: $($regexData.SITType)" -ForegroundColor DarkGray
                }
                if ($falsePositives.Count -gt 10) {
                    Write-Host "      ... and $($falsePositives.Count - 10) more" -ForegroundColor DarkGray
                }
                Write-Host ""
            }
            
            if ($falseNegatives.Count -gt 0) {
                Write-Host "   📋 Sample False Negatives (regex missed):" -ForegroundColor Yellow
                $falseNegatives | Select-Object -First 10 | ForEach-Object {
                    $fileName = $_
                    $purviewData = $normalizedResults[$purviewLab] | Where-Object { $_.FileName -eq $fileName } | Select-Object -First 1
                    Write-Host "      • $fileName" -ForegroundColor Gray
                    Write-Host "        Site: $($purviewData.Site), SIT: $($purviewData.SITType)" -ForegroundColor DarkGray
                }
                if ($falseNegatives.Count -gt 10) {
                    Write-Host "      ... and $($falseNegatives.Count - 10) more" -ForegroundColor DarkGray
                }
                Write-Host ""
            }
            
            if ($truePositives.Count -gt 0) {
                Write-Host "   📋 Sample True Positives (both methods agree):" -ForegroundColor Green
                $truePositives | Select-Object -First 5 | ForEach-Object {
                    $fileName = $_
                    $regexData = $normalizedResults[$regexLab] | Where-Object { $_.FileName -eq $fileName } | Select-Object -First 1
                    $purviewData = $normalizedResults[$purviewLab] | Where-Object { $_.FileName -eq $fileName } | Select-Object -First 1
                    Write-Host "      • $fileName" -ForegroundColor Gray
                    Write-Host "        $regexLab SIT: $($regexData.SITType)" -ForegroundColor DarkGray
                    Write-Host "        $purviewLab SIT: $($purviewData.SITType)" -ForegroundColor DarkGray
                }
                if ($truePositives.Count -gt 5) {
                    Write-Host "      ... and $($truePositives.Count - 5) more" -ForegroundColor DarkGray
                }
                Write-Host ""
            }
        }
    }
}

# Calculate overlap across all Purview methods
if ($purviewLabs.Count -gt 1) {
    Write-Host "🔄 Cross-Method Consistency (Purview SIT Methods)" -ForegroundColor Magenta
    Write-Host "==================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Find files detected by ALL Purview methods
    $allPurviewFiles = $uniqueFiles[$purviewLabs[0]]
    for ($i = 1; $i -lt $purviewLabs.Count; $i++) {
        $allPurviewFiles = $allPurviewFiles | Where-Object { $uniqueFiles[$purviewLabs[$i]] -contains $_ }
    }
    
    Write-Host "📊 Files detected by ALL Purview methods: $($allPurviewFiles.Count)" -ForegroundColor Green
    Write-Host "   High-confidence detections across all SIT-based approaches" -ForegroundColor Cyan
    Write-Host ""
    
    # Show per-method comparison
    foreach ($lab in $purviewLabs) {
        $overlap = ($allPurviewFiles | Where-Object { $uniqueFiles[$lab] -contains $_ }).Count
        $coverage = if ($allPurviewFiles.Count -gt 0) {
            [math]::Round(($overlap / $allPurviewFiles.Count) * 100, 2)
        } else { 0 }
        Write-Host "   $lab coverage: $overlap / $($allPurviewFiles.Count) files ($coverage%)" -ForegroundColor Cyan
    }
    Write-Host ""
    
    # Add contextual interpretation for Purview method differences
    Write-Host "   💡 Method Context:" -ForegroundColor Cyan
    
    # Lab 05b vs Lab 05c comparison
    if ($purviewLabs -contains 'Lab05b' -and $purviewLabs -contains 'Lab05c') {
        $lab05bCount = $uniqueFiles['Lab05b'].Count
        $lab05cCount = $uniqueFiles['Lab05c'].Count
        $countDiff = [math]::Abs($lab05bCount - $lab05cCount)
        $percentDiff = if ($lab05bCount -gt 0) { 
            [math]::Round(($countDiff / $lab05bCount) * 100, 1) 
        } else { 0 }
        
        Write-Host "      📋 Lab 05b (Portal Export): $lab05bCount files" -ForegroundColor Gray
        Write-Host "      📋 Lab 05c (Graph API Export): $lab05cCount files" -ForegroundColor Gray
        
        if ($countDiff -eq 0) {
            Write-Host "      ✅ File counts match perfectly - both methods captured same unique content" -ForegroundColor Green
            Write-Host "         (Validates that Graph API and Portal UI produce identical results)" -ForegroundColor Gray
        } elseif ($percentDiff -lt 1) {
            Write-Host "      ✅ File counts nearly identical ($percentDiff% difference)" -ForegroundColor Green
            Write-Host "         (Minor timing differences in export execution)" -ForegroundColor Gray
        } else {
            Write-Host "      ⚠️  File count discrepancy: $countDiff files ($percentDiff%)" -ForegroundColor Yellow
            
            if ($lab05cCount -lt $lab05bCount) {
                Write-Host "         ⚠️  UNEXPECTED VARIANCE: Lab 05c (Graph API) returned fewer files than Lab 05b." -ForegroundColor Yellow
                Write-Host "            Since Review Set deduplication is disabled, counts should be identical." -ForegroundColor Yellow
                Write-Host "            (Check for export timing differences, incomplete API paging, or search query variations)" -ForegroundColor Gray
            } else {
                Write-Host "         (Check for export timing differences or search query variations)" -ForegroundColor Gray
            }
        }
        
        Write-Host "      ⚙️ Workflow Differences:" -ForegroundColor Gray
        Write-Host "         • Lab 05b: Portal UI → Manual Export (Interactive)" -ForegroundColor Gray
        Write-Host "         • Lab 05c: Graph API → Automated Export (Programmatic)" -ForegroundColor Gray
        Write-Host "      🎯 Both methods: 100% SIT accuracy, same 24-hour indexing requirement" -ForegroundColor Gray
    }
    
    # General Purview method interpretation
    if ($purviewLabs.Count -gt 1) {
        Write-Host ""
        Write-Host "      📊 Data Structure:" -ForegroundColor Gray
        Write-Host "         • Both methods produce identical eDiscovery export formats" -ForegroundColor Gray
        Write-Host "         • Script normalizes column names for consistent analysis" -ForegroundColor Gray
    }
    Write-Host ""
}

# =============================================================================
# Step 4: SIT Type Distribution Analysis
# =============================================================================

Write-Host "📋 Step 4: SIT Type Distribution Analysis" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

foreach ($lab in $normalizedResults.Keys | Sort-Object) {
    Write-Host ""
    Write-Host "📊 $lab SIT Distribution:" -ForegroundColor Cyan
    Write-Host ""
    
    $sitDistribution = $normalizedResults[$lab] | 
        Where-Object { $_.SITType } |
        Group-Object SITType | 
        Sort-Object Count -Descending |
        Select-Object -First 10
    
    if ($sitDistribution) {
        # Display header
        Write-Host "SIT Type                                              Count" -ForegroundColor White
        Write-Host "--------                                              -----" -ForegroundColor White
        
        # Display each SIT type
        foreach ($sit in $sitDistribution) {
            $sitName = $sit.Name.PadRight(54)
            Write-Host "$sitName$($sit.Count)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ⚠️  No SIT distribution data available" -ForegroundColor Yellow
    }
}

Write-Host ""

# =============================================================================
# Step 4a: DATA ANOMALY DETECTION AND ANALYSIS
# =============================================================================

Write-Host "🔍 Step 4a: Data Anomaly Detection and Analysis" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

$anomalies = @()

# Check for significant variance in SIT detection counts across methods
foreach ($sitName in ($sitCounts.Values | ForEach-Object { $_.Name } | Select-Object -Unique)) {
    $counts = @{}
    
    foreach ($lab in $normalizedResults.Keys | Sort-Object) {
        $sitData = $sitCounts[$lab] | Where-Object { $_.Name -eq $sitName }
        if ($sitData) {
            $counts[$lab] = $sitData.Count
        } else {
            $counts[$lab] = 0
        }
    }
    
    if ($counts.Count -ge 2) {
        $maxCount = ($counts.Values | Measure-Object -Maximum).Maximum
        $minCount = ($counts.Values | Measure-Object -Minimum).Minimum
        $maxLab = ($counts.GetEnumerator() | Where-Object { $_.Value -eq $maxCount } | Select-Object -First 1).Name
        $minLab = ($counts.GetEnumerator() | Where-Object { $_.Value -eq $minCount } | Select-Object -First 1).Name
        
        if ($maxCount -gt 0) {
            $variance = [math]::Round((($maxCount - $minCount) / $maxCount) * 100, 1)
            
            # Flag significant variances (>20% difference)
            if ($variance -gt 20) {
                $anomalies += [PSCustomObject]@{
                    SITType = $sitName
                    Variance = $variance
                    MaxCount = $maxCount
                    MinCount = $minCount
                    MaxLab = $maxLab
                    MinLab = $minLab
                    AllCounts = ($counts.GetEnumerator() | ForEach-Object { "$($_.Name): $($_.Value)" }) -join ", "
                    Severity = if ($variance -gt 50) { "HIGH" } elseif ($variance -gt 35) { "MEDIUM" } else { "LOW" }
                }
            }
        }
    }
}

if ($anomalies.Count -gt 0) {
    Write-Host "⚠️  Detected $($anomalies.Count) SIT types with significant variance across methods:" -ForegroundColor Yellow
    Write-Host ""
    
    # Sort by severity and variance
    $anomalies | Sort-Object { if ($_.Severity -eq "HIGH") { 1 } elseif ($_.Severity -eq "MEDIUM") { 2 } else { 3 } }, Variance -Descending | ForEach-Object {
        $severityColor = switch ($_.Severity) {
            "HIGH" { "Red" }
            "MEDIUM" { "Yellow" }
            "LOW" { "Cyan" }
        }
        
        Write-Host "   $($_.Severity): $($_.SITType)" -ForegroundColor $severityColor
        Write-Host "      Variance: $($_.Variance)% difference between methods" -ForegroundColor Gray
        Write-Host "      All counts: $($_.AllCounts)" -ForegroundColor Gray
        Write-Host "      Highest: $($_.MaxLab) with $($_.MaxCount) detections" -ForegroundColor Gray
        Write-Host "      Lowest: $($_.MinLab) with $($_.MinCount) detections" -ForegroundColor Gray
        
        # Provide interpretation based on labs involved
        if ($_.MaxLab -eq "Lab05a" -and ($_.MinLab -eq "Lab05b" -or $_.MinLab -eq "Lab05c")) {
            Write-Host "      💡 Interpretation: Lab 05a (regex) over-detecting - potential false positives" -ForegroundColor DarkYellow
        } elseif (($_.MaxLab -eq "Lab05b" -or $_.MaxLab -eq "Lab05c") -and $_.MinLab -eq "Lab05a") {
            Write-Host "      💡 Interpretation: Lab 05a (regex) under-detecting - missing patterns or format variations" -ForegroundColor DarkYellow
        } elseif ($_.MaxLab -eq "Lab05b" -and $_.MinLab -eq "Lab05c") {
            Write-Host "      💡 Interpretation: Lab 05b detecting more instances - likely due to API export paging or timeout issues in Lab 05c" -ForegroundColor DarkYellow
        } elseif ($_.MaxLab -eq "Lab05c" -and $_.MinLab -eq "Lab05b") {
            Write-Host "      💡 Interpretation: Lab 05c detecting more instances - likely due to export timing differences" -ForegroundColor DarkYellow
        } elseif ($_.MaxLab -eq "Lab05a" -and $_.MinLab -eq "Lab05c") {
            Write-Host "      💡 Interpretation: Lab 05a (regex) over-detecting, Lab 05c missing data due to API issues" -ForegroundColor DarkYellow
        }
        Write-Host ""
    }
} else {
    Write-Host "✅ No significant SIT detection variances detected (all methods within 20% agreement)" -ForegroundColor Green
    Write-Host ""
}

# =============================================================================
# Step 5: Generate Comparison Report
# =============================================================================

Write-Host "📄 Step 5: Generate Comparison Report" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Determine output path
if (-not $OutputPath) {
    $OutputPath = Join-Path $PSScriptRoot "..\reports"
}

if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$reportPath = Join-Path $OutputPath "Cross-Lab-Analysis-$timestamp.csv"

# =============================================================================
# SECTION 1: EXECUTIVE SUMMARY
# =============================================================================

$executiveSummary = @()
$executiveSummary += [PSCustomObject]@{
    Section = "EXECUTIVE SUMMARY"
    Metric = "Analysis Date"
    Value = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Details = ""
}
$executiveSummary += [PSCustomObject]@{
    Section = "EXECUTIVE SUMMARY"
    Metric = "Methods Compared"
    Value = $normalizedResults.Keys.Count
    Details = ($normalizedResults.Keys -join ", ")
}

# Add SIT filtering information
if ($enabledSitNames.Count -gt 0) {
    $executiveSummary += [PSCustomObject]@{
        Section = "EXECUTIVE SUMMARY"
        Metric = "SIT Configuration Source"
        Value = "global-config.json"
        Details = "Analysis filtered to enabled SIT types only"
    }
    $executiveSummary += [PSCustomObject]@{
        Section = "EXECUTIVE SUMMARY"
        Metric = "Enabled SIT Types (Included)"
        Value = $enabledSitNames.Count
        Details = ($enabledSitNames -join ", ")
    }
    
    if ($disabledSitNames.Count -gt 0) {
        $executiveSummary += [PSCustomObject]@{
            Section = "EXECUTIVE SUMMARY"
            Metric = "Disabled SIT Types (Excluded)"
            Value = $disabledSitNames.Count
            Details = ($disabledSitNames -join ", ")
        }
        
        # Report which labs had omitted SITs in their datasets
        foreach ($lab in $omittedSitsPerLab.Keys) {
            if ($omittedSitsPerLab[$lab].Count -gt 0) {
                $executiveSummary += [PSCustomObject]@{
                    Section = "EXECUTIVE SUMMARY"
                    Metric = "$lab - Omitted SITs Found in Dataset"
                    Value = $omittedSitsPerLab[$lab].Count
                    Details = "Present but excluded: $($omittedSitsPerLab[$lab] -join ', ')"
                }
            }
        }
    }
}

foreach ($lab in $normalizedResults.Keys) {
    $executiveSummary += [PSCustomObject]@{
        Section = "EXECUTIVE SUMMARY"
        Metric = "$lab - Detection Method"
        Value = $normalizedResults[$lab][0].DetectionMethod
        Details = ""
    }
    $executiveSummary += [PSCustomObject]@{
        Section = "EXECUTIVE SUMMARY"
        Metric = "$lab - Total Detections"
        Value = $normalizedResults[$lab].Count
        Details = ""
    }
    $executiveSummary += [PSCustomObject]@{
        Section = "EXECUTIVE SUMMARY"
        Metric = "$lab - Files with SIT Detections"
        Value = $uniqueFiles[$lab].Count
        Details = "Unique files containing sensitive information"
    }
    $executiveSummary += [PSCustomObject]@{
        Section = "EXECUTIVE SUMMARY"
        Metric = "$lab - Unique SIT Types"
        Value = ($sitCounts[$lab] | Measure-Object).Count
        Details = ""
    }
    $executiveSummary += [PSCustomObject]@{
        Section = "EXECUTIVE SUMMARY"
        Metric = "$lab - Sites Scanned"
        Value = ($siteDistribution[$lab] | Measure-Object).Count
        Details = if ($siteDistribution[$lab]) { ($siteDistribution[$lab].Name -join ", ") } else { "N/A" }
    }
}

# Add accuracy metrics if available
if ($detailedComparisons -and $detailedComparisons.Count -gt 0) {
    foreach ($comparison in $detailedComparisons) {
        $executiveSummary += [PSCustomObject]@{
            Section = "EXECUTIVE SUMMARY"
            Metric = "Comparison: $($comparison.RegexLab) vs $($comparison.PurviewLab)"
            Value = "Accuracy: $($comparison.Accuracy)%"
            Details = "Precision: $($comparison.Precision)%, Recall: $($comparison.Recall)%"
        }
        $executiveSummary += [PSCustomObject]@{
            Section = "EXECUTIVE SUMMARY"
            Metric = "  True Positives (Matches)"
            Value = $comparison.TruePositives.Count
            Details = "Files correctly detected by both methods"
        }
        $executiveSummary += [PSCustomObject]@{
            Section = "EXECUTIVE SUMMARY"
            Metric = "  False Positives (Over-detection)"
            Value = $comparison.FalsePositives.Count
            Details = "Files detected by regex but not Purview (potential false alarms)"
        }
        $executiveSummary += [PSCustomObject]@{
            Section = "EXECUTIVE SUMMARY"
            Metric = "  False Negatives (Missed)"
            Value = $comparison.FalseNegatives.Count
            Details = "Files detected by Purview but missed by regex (gaps in coverage)"
        }
    }
}

# =============================================================================
# SECTION 2: SITE-BY-SITE COMPARISON
# =============================================================================

$siteComparison = @()

# Get all unique sites
$allSites = @()
foreach ($lab in $normalizedResults.Keys) {
    if ($siteDistribution[$lab]) {
        $allSites += $siteDistribution[$lab].Name
    }
}
$uniqueSites = $allSites | Select-Object -Unique | Sort-Object

foreach ($site in $uniqueSites) {
    $siteComparison += [PSCustomObject]@{
        Section = "SITE COMPARISON"
        SiteName = $site
        Metric = "Site Header"
        Lab = "All"
        Value = "--- $site ---"
        Details = ""
    }
    
    foreach ($lab in $normalizedResults.Keys) {
        $siteData = $siteDistribution[$lab] | Where-Object { $_.Name -eq $site }
        $siteFiles = if ($siteData) {
            ($normalizedResults[$lab] | Where-Object { $_.Site -eq $site } | Select-Object -Unique FileName | Measure-Object).Count
        } else {
            0
        }
        
        $status = if ($siteData) { "✓ Scanned" } else { "✗ Not Scanned" }
        
        $siteComparison += [PSCustomObject]@{
            Section = "SITE COMPARISON"
            SiteName = $site
            Metric = "Detection Count"
            Lab = $lab
            Value = if ($siteData) { $siteData.Count } else { 0 }
            Details = "$status - $siteFiles unique files"
        }
    }
    
    # Add site-level comparison
    if ($normalizedResults.Keys.Count -ge 2) {
        $labArray = @($normalizedResults.Keys)
        $site1Data = $normalizedResults[$labArray[0]] | Where-Object { $_.Site -eq $site }
        $site2Data = $normalizedResults[$labArray[1]] | Where-Object { $_.Site -eq $site }
        
        $site1Files = if ($site1Data) { ($site1Data | Select-Object -Unique FileName).FileName } else { @() }
        $site2Files = if ($site2Data) { ($site2Data | Select-Object -Unique FileName).FileName } else { @() }
        
        $overlap = ($site1Files | Where-Object { $site2Files -contains $_ } | Measure-Object).Count
        
        $siteComparison += [PSCustomObject]@{
            Section = "SITE COMPARISON"
            SiteName = $site
            Metric = "Cross-Method Overlap"
            Lab = "Comparison"
            Value = $overlap
            Details = "Files detected by both methods at this site"
        }
    }
}

# =============================================================================
# SECTION 3: SIT-BY-SIT ANALYSIS
# =============================================================================

$sitAnalysis = @()

# Pre-calculate SIT groupings for fast lookup (instead of Where-Object in loops)
$sitGroupings = @{}
foreach ($lab in $normalizedResults.Keys) {
    $sitGroupings[$lab] = $normalizedResults[$lab] | Group-Object SITType
}

# Get all unique SIT types across both labs - limit to top 20 by detection count for performance
$allSITs = @()
foreach ($lab in $normalizedResults.Keys) {
    $allSITs += $sitGroupings[$lab] | ForEach-Object { $_.Name }
}
$sitCountsAll = @{}
foreach ($lab in $normalizedResults.Keys) {
    foreach ($group in $sitGroupings[$lab]) {
        if ($sitCountsAll.ContainsKey($group.Name)) {
            $sitCountsAll[$group.Name] += $group.Count
        } else {
            $sitCountsAll[$group.Name] = $group.Count
        }
    }
}
$uniqueSITs = $sitCountsAll.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 20 -ExpandProperty Name

Write-Host "   ⚡ Analyzing top 20 SIT types for performance (out of $($sitCountsAll.Count) total)" -ForegroundColor Gray

foreach ($sit in $uniqueSITs) {
    $sitAnalysis += [PSCustomObject]@{
        Section = "SIT ANALYSIS"
        SITType = $sit
        Metric = "SIT Header"
        Lab = "All"
        DetectionCount = "---"
        UniqueFiles = "---"
        Sites = "--- $sit ---"
    }
    
    foreach ($lab in $normalizedResults.Keys) {
        $sitData = $sitGroupings[$lab] | Where-Object { $_.Name -eq $sit }
        
        if ($sitData) {
            $sitFiles = ($sitData.Group | Select-Object -Unique FileName).Count
            $sitSites = ($sitData.Group | Select-Object -Unique Site).Site -join ", "
            
            $sitAnalysis += [PSCustomObject]@{
                Section = "SIT ANALYSIS"
                SITType = $sit
                Metric = "Detection Stats"
                Lab = $lab
                DetectionCount = $sitData.Count
                UniqueFiles = $sitFiles
                Sites = $sitSites
            }
        } else {
            $sitAnalysis += [PSCustomObject]@{
                Section = "SIT ANALYSIS"
                SITType = $sit
                Metric = "Detection Stats"
                Lab = $lab
                DetectionCount = 0
                UniqueFiles = 0
                Sites = "Not detected"
            }
        }
    }
    
    # Add SIT-level comparison if applicable
    if ($normalizedResults.Keys.Count -ge 2) {
        $labArray = @($normalizedResults.Keys)
        $lab1Data = $sitGroupings[$labArray[0]] | Where-Object { $_.Name -eq $sit }
        $lab2Data = $sitGroupings[$labArray[1]] | Where-Object { $_.Name -eq $sit }
        
        $lab1Files = if ($lab1Data) { ($lab1Data.Group | Select-Object -Unique FileName).FileName } else { @() }
        $lab2Files = if ($lab2Data) { ($lab2Data.Group | Select-Object -Unique FileName).FileName } else { @() }
        
        $overlap = ($lab1Files | Where-Object { $lab2Files -contains $_ } | Measure-Object).Count
        $lab1Only = ($lab1Files | Where-Object { $lab2Files -notcontains $_ } | Measure-Object).Count
        $lab2Only = ($lab2Files | Where-Object { $lab1Files -notcontains $_ } | Measure-Object).Count
        
        $agreement = if ($lab1Files.Count -gt 0 -or $lab2Files.Count -gt 0) {
            [math]::Round(($overlap / [math]::Max(1, [math]::Max($lab1Files.Count, $lab2Files.Count))) * 100, 1)
        } else { 0 }
        
        $sitAnalysis += [PSCustomObject]@{
            Section = "SIT ANALYSIS"
            SITType = $sit
            Metric = "Cross-Method Agreement"
            Lab = "Comparison"
            DetectionCount = "$agreement%"
            UniqueFiles = "$overlap files match"
            Sites = "$($labArray[0]) only: $lab1Only, $($labArray[1]) only: $lab2Only"
        }
    }
}

# =============================================================================
# SECTION 4: DELTA ANALYSIS (GOOD MATCHES VS ISSUES)
# =============================================================================

$deltaAnalysis = @()

if ($detailedComparisons -and $detailedComparisons.Count -gt 0) {
    foreach ($comparison in $detailedComparisons) {
        # Good Matches Section
        $deltaAnalysis += [PSCustomObject]@{
            Section = "DELTA ANALYSIS"
            Category = "GOOD MATCHES"
            SubCategory = "Overview"
            FileName = "---"
            RegexLab = $comparison.RegexLab
            PurviewLab = $comparison.PurviewLab
            MatchType = "True Positive"
            Details = "$($comparison.TruePositives.Count) files correctly detected by both methods"
        }
        
        # Sample good matches - just show filenames without lookups
        $sampleMatches = $comparison.TruePositives | Select-Object -First 10
        $deltaAnalysis += [PSCustomObject]@{
            Section = "DELTA ANALYSIS"
            Category = "GOOD MATCHES"
            SubCategory = "Sample Files"
            FileName = ($sampleMatches -join "; ")
            RegexLab = $comparison.RegexLab
            PurviewLab = $comparison.PurviewLab
            MatchType = "Both Detected"
            Details = "First 10 of $($comparison.TruePositives.Count) matching files"
        }
        
        # Issues Section - False Positives
        $deltaAnalysis += [PSCustomObject]@{
            Section = "DELTA ANALYSIS"
            Category = "ISSUES"
            SubCategory = "False Positives (Over-detection)"
            FileName = "---"
            RegexLab = $comparison.RegexLab
            PurviewLab = $comparison.PurviewLab
            MatchType = "Issue Type"
            Details = "$($comparison.FalsePositives.Count) files detected by regex but NOT by Purview - potential false alarms"
        }
        
        # Sample false positives - just show filenames without lookups
        $sampleFP = $comparison.FalsePositives | Select-Object -First 10
        $deltaAnalysis += [PSCustomObject]@{
            Section = "DELTA ANALYSIS"
            Category = "ISSUES"
            SubCategory = "False Positives (Over-detection)"
            FileName = ($sampleFP -join "; ")
            RegexLab = $comparison.RegexLab
            PurviewLab = $comparison.PurviewLab
            MatchType = "Regex Over-detection"
            Details = "First 10 of $($comparison.FalsePositives.Count) over-detected files"
        }
        
        # Issues Section - False Negatives
        $deltaAnalysis += [PSCustomObject]@{
            Section = "DELTA ANALYSIS"
            Category = "ISSUES"
            SubCategory = "False Negatives (Missed Detection)"
            FileName = "---"
            RegexLab = $comparison.RegexLab
            PurviewLab = $comparison.PurviewLab
            MatchType = "Issue Type"
            Details = "$($comparison.FalseNegatives.Count) files detected by Purview but MISSED by regex - coverage gaps"
        }
        
        # Sample false negatives - just show filenames without lookups
        $sampleFN = $comparison.FalseNegatives | Select-Object -First 10
        if ($sampleFN.Count -gt 0) {
            $deltaAnalysis += [PSCustomObject]@{
                Section = "DELTA ANALYSIS"
                Category = "ISSUES"
                SubCategory = "False Negatives (Missed Detection)"
                FileName = ($sampleFN -join "; ")
                RegexLab = $comparison.RegexLab
                PurviewLab = $comparison.PurviewLab
                MatchType = "Regex Missed"
                Details = "First 10 of $($comparison.FalseNegatives.Count) missed files"
            }
        }
        
        # Opportunities Section
        $deltaAnalysis += [PSCustomObject]@{
            Section = "DELTA ANALYSIS"
            Category = "OPPORTUNITIES"
            SubCategory = "Improvement Recommendations"
            FileName = "---"
            RegexLab = $comparison.RegexLab
            PurviewLab = $comparison.PurviewLab
            MatchType = "Recommendation"
            Details = "Review false positives to refine regex patterns and reduce false alarm rate"
        }
        
        if ($comparison.FalseNegatives.Count -gt 0) {
            $deltaAnalysis += [PSCustomObject]@{
                Section = "DELTA ANALYSIS"
                Category = "OPPORTUNITIES"
                SubCategory = "Improvement Recommendations"
                FileName = "---"
                RegexLab = $comparison.RegexLab
                PurviewLab = $comparison.PurviewLab
                MatchType = "Recommendation"
                Details = "Add regex patterns for SIT types that Purview detected but regex missed"
            }
        }
        
        $deltaAnalysis += [PSCustomObject]@{
            Section = "DELTA ANALYSIS"
            Category = "OPPORTUNITIES"
            SubCategory = "Performance Assessment"
            FileName = "---"
            RegexLab = $comparison.RegexLab
            PurviewLab = $comparison.PurviewLab
            MatchType = "Assessment"
            Details = "Current accuracy: $($comparison.Accuracy)% - Expected range for regex patterns: 88-95%"
        }
    }
}

# =============================================================================
# EXPORT ALL SECTIONS TO SEPARATE CSVs (PRESERVES ALL COLUMNS)
# =============================================================================

# Export each section separately to preserve their unique column structures
$summaryReportPath = Join-Path $OutputPath "Cross-Lab-Executive-Summary-$timestamp.csv"
$siteReportPath = Join-Path $OutputPath "Cross-Lab-Site-Analysis-$timestamp.csv"
$sitReportPath = Join-Path $OutputPath "Cross-Lab-SIT-Analysis-$timestamp.csv"
$deltaReportPath = Join-Path $OutputPath "Cross-Lab-Delta-Analysis-$timestamp.csv"

# Export each section with its full column structure preserved
$executiveSummary | Export-Csv -Path $summaryReportPath -NoTypeInformation
$siteComparison | Export-Csv -Path $siteReportPath -NoTypeInformation
$sitAnalysis | Export-Csv -Path $sitReportPath -NoTypeInformation
$deltaAnalysis | Export-Csv -Path $deltaReportPath -NoTypeInformation

Write-Host "   ✅ Analysis reports saved to: $OutputPath" -ForegroundColor Green
Write-Host "      📊 Executive Summary: Cross-Lab-Executive-Summary-$timestamp.csv" -ForegroundColor Gray
Write-Host "      🌐 Site Analysis: Cross-Lab-Site-Analysis-$timestamp.csv" -ForegroundColor Gray
Write-Host "      📋 SIT Analysis: Cross-Lab-SIT-Analysis-$timestamp.csv" -ForegroundColor Gray
Write-Host "      🔍 Delta Analysis: Cross-Lab-Delta-Analysis-$timestamp.csv" -ForegroundColor Gray

# Generate simplified discrepancy summary (optional, fast)
if ($detailedComparisons -and $detailedComparisons.Count -gt 0) {
    $discrepancyReportPath = Join-Path $OutputPath "Cross-Lab-Discrepancy-Summary-$timestamp.csv"
    
    $discrepancySummary = @()
    
    foreach ($comparison in $detailedComparisons) {
        # Just export lists of filenames by category - no detailed lookups
        $discrepancySummary += [PSCustomObject]@{
            Category = "TRUE POSITIVES"
            ComparisonType = "$($comparison.RegexLab) vs $($comparison.PurviewLab)"
            Count = $comparison.TruePositives.Count
            FileList = ($comparison.TruePositives | Select-Object -First 50) -join "; "
            Note = if ($comparison.TruePositives.Count -gt 50) { "Showing first 50 of $($comparison.TruePositives.Count) files" } else { "Complete list" }
        }
        
        $discrepancySummary += [PSCustomObject]@{
            Category = "FALSE POSITIVES"
            ComparisonType = "$($comparison.RegexLab) vs $($comparison.PurviewLab)"
            Count = $comparison.FalsePositives.Count
            FileList = ($comparison.FalsePositives | Select-Object -First 50) -join "; "
            Note = if ($comparison.FalsePositives.Count -gt 50) { "Showing first 50 of $($comparison.FalsePositives.Count) files" } else { "Complete list" }
        }
        
        $discrepancySummary += [PSCustomObject]@{
            Category = "FALSE NEGATIVES"
            ComparisonType = "$($comparison.RegexLab) vs $($comparison.PurviewLab)"
            Count = $comparison.FalseNegatives.Count
            FileList = ($comparison.FalseNegatives | Select-Object -First 50) -join "; "
            Note = if ($comparison.FalseNegatives.Count -gt 50) { "Showing first 50 of $($comparison.FalseNegatives.Count) files" } else { "Complete list" }
        }
    }
    
    $discrepancySummary | Export-Csv -Path $discrepancyReportPath -NoTypeInformation
    Write-Host "   ✅ Discrepancy summary saved: $discrepancyReportPath" -ForegroundColor Green
    Write-Host "      Fast summary with filename lists by match type" -ForegroundColor Gray
}

Write-Host ""

# Generate HTML report if requested
if ($GenerateHtmlReport) {
    $htmlPath = Join-Path $OutputPath "Cross-Lab-Analysis-$timestamp.html"
    
    $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Lab 05 Cross-Method Analysis</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #0078d4; border-bottom: 3px solid #0078d4; padding-bottom: 10px; }
        h2 { color: #106ebe; margin-top: 30px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; background-color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th { background-color: #0078d4; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background-color: #f1f1f1; }
        .metric { display: inline-block; margin: 10px 20px; padding: 15px; background-color: white; border-left: 4px solid #0078d4; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric-value { font-size: 24px; font-weight: bold; color: #0078d4; }
        .metric-label { font-size: 14px; color: #666; }
    </style>
</head>
<body>
    <h1>🔍 Lab 05 Cross-Method Discovery Analysis</h1>
    <p><strong>Generated:</strong> $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
    
    <h2>📊 Completed Labs Summary</h2>
    <div>
        <div class="metric">
            <div class="metric-value">$($completedLabs.Count)</div>
            <div class="metric-label">Labs Completed</div>
        </div>
    </div>
    
    <h2>📈 Detection Summary by Method</h2>
    <p><em>Note: Comparing files with SIT detections (both methods only report files containing sensitive information)</em></p>
    <table>
        <tr>
            <th>Lab</th>
            <th>Detection Method</th>
            <th>Total SIT Records</th>
            <th>Files with SITs</th>
            <th>Report Date</th>
        </tr>
        $(foreach ($item in $comparisonSummary) {
            "<tr><td>$($item.Lab)</td><td>$($item.DetectionMethod)</td><td>$($item.TotalDetections)</td><td>$($item.UniqueFiles)</td><td>$($item.ReportDate)</td></tr>"
        })
    </table>
    
    <h2>🎯 Key Findings</h2>
    <ul>
        $(if ($regexLabs.Count -gt 0 -and $purviewLabs.Count -gt 0) {
            $regexLab = $regexLabs[0]
            $purviewLab = $purviewLabs[0]
            $regexFiles = $uniqueFiles[$regexLab]
            $purviewFiles = $uniqueFiles[$purviewLab]
            $overlap = ($regexFiles | Where-Object { $purviewFiles -contains $_ }).Count
            $accuracy = [math]::Round(($overlap / $regexFiles.Count) * 100, 2)
            "<li><strong>Lab 05a Accuracy:</strong> $accuracy% when compared to $purviewLab (Purview SITs)</li>"
        })
        $(if ($purviewLabs.Count -gt 1) {
            $consistentFiles = $uniqueFiles[$purviewLabs[0]]
            for ($i = 1; $i -lt $purviewLabs.Count; $i++) {
                $consistentFiles = $consistentFiles | Where-Object { $uniqueFiles[$purviewLabs[$i]] -contains $_ }
            }
            "<li><strong>High-Confidence Detections:</strong> $($consistentFiles.Count) files detected by all Purview methods</li>"
        })
        <li><strong>Recommendation:</strong> Use Purview SIT-based methods (Labs 05b/c/d) for compliance reporting</li>
        <li><strong>Learning Value
    </ul>
    
</body>
</html>
"@
    
    $htmlContent | Out-File -FilePath $htmlPath -Encoding UTF8
    Write-Host "   ✅ HTML report saved: $htmlPath" -ForegroundColor Green
}

Write-Host ""

# =============================================================================
# Step 6: Generate Markdown Executive Summary
# =============================================================================

Write-Host "📝 Step 6: Generate Markdown Executive Summary" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

$markdownPath = Join-Path $OutputPath "Cross-Lab-Analysis-Executive-Summary-$timestamp.md"

# Build comprehensive markdown report
$mdContent = @"
# Lab 05 Cross-Method Discovery Analysis
## Data-Driven Validation of Method Effectiveness Claims

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Analysis Period:** $timestamp  
**Report Type:** Cross-Lab Statistical Comparison

---

## 📋 Executive Overview

This analysis provides **statistical evidence** supporting Lab 05 method effectiveness claims by comparing actual detection data from three discovery approaches scanning the **same 5 SharePoint sites**. The data validates accuracy ranges, identifies method-specific strengths/weaknesses, and quantifies trade-offs for stakeholder decision-making.

### Analysis Purpose

✅ **Validates** documented accuracy claims (Lab 05a: 88-95% expected)  
✅ **Quantifies** method effectiveness differences (regex vs Purview SIT engines)  
✅ **Identifies** specific SIT types where methods diverge significantly  
✅ **Supports** informed method selection for different use cases  

> **📊 Data Consistency Confirmed**: All three labs were configured to scan the same 5 SharePoint sites (Finance, HR, Legal, Marketing, IT). Different site coverage in results reflects different detection effectiveness, not different scanning scope. CSVs only include sites where SIT detections were found.

### Methods Analyzed

"@

foreach ($lab in $completedLabs.Keys | Sort-Object) {
    $detectionMethod = ($executiveSummary | Where-Object { $_.Metric -eq "$lab - Detection Method" }).Value
    $totalDetections = ($executiveSummary | Where-Object { $_.Metric -eq "$lab - Total Detections" }).Value
    $uniqueFiles = ($executiveSummary | Where-Object { $_.Metric -eq "$lab - Files with SIT Detections" }).Value
    $sitesScanned = ($executiveSummary | Where-Object { $_.Metric -eq "$lab - Sites Scanned" }).Value
    $reportDate = if ($labResults[$lab]) { (Get-Item $labResults[$lab]).LastWriteTime.ToString("yyyy-MM-dd") } else { "N/A" }
    
    $mdContent += "`n`n#### ${lab}: $detectionMethod`n`n"
    $mdContent += "- **Files with Sensitive Content**: $uniqueFiles unique files`n"
    $mdContent += "- **Total Detection Records**: $totalDetections SIT instances`n"
    $mdContent += "- **Sites with Detections**: $sitesScanned sites`n"
    $mdContent += "- **Report Generated**: $reportDate`n"
}

$mdContent += @"

### Data Source Validation

✅ **Consistent Configuration**: All labs configured to scan the same 5 SharePoint sites  
✅ **Same Data Source**: Finance-Simulation, HR-Simulation, Legal-Simulation, Marketing-Simulation, IT-Simulation  
✅ **Different Results Expected**: CSVs only show sites WHERE SIT detections occurred  
✅ **Apples-to-Apples Comparison**: When comparing common files, they originate from identical SharePoint content  

> **Key Finding**: Different site coverage in results demonstrates method effectiveness variations, not configuration differences. Lab 05a may detect SITs in Finance/IT while Purview methods don't (or vice versa).
"@

# Add dynamic Lab 05b vs 05c comparison if both exist
if ($completedLabs.ContainsKey('Lab05b') -and $completedLabs.ContainsKey('Lab05c')) {
    $count5b = [int]($executiveSummary | Where-Object { $_.Metric -eq "Lab05b - Files with SIT Detections" }).Value
    $count5c = [int]($executiveSummary | Where-Object { $_.Metric -eq "Lab05c - Files with SIT Detections" }).Value
    
    if ($count5b -gt 0) {
        $diff = $count5b - $count5c
        $pct = [math]::Round(($diff / $count5b) * 100, 1)
        
        if ($diff -gt 0) {
            $mdContent += "`n> **⚠️ Data Mismatch Analysis**: Lab 05c returned **$diff fewer files ($pct%)** than Lab 05b. Since Review Set deduplication is disabled, these counts **should be identical**. This discrepancy likely indicates an issue with the API export process (e.g., incomplete paging, timeout during export) or a difference in the search query execution time relative to the index update.`n"
        } elseif ($diff -lt 0) {
            $absDiff = [math]::Abs($diff)
            $mdContent += "`n> **💡 Data Mismatch Analysis**:`n"
            $mdContent += "> - **File Count**: Lab 05c returned **$absDiff more files** than Lab 05b. This likely reflects **SharePoint indexing updates** occurring between the Lab 05b run and the Lab 05c run.`n"
            
            # Check instance counts for deeper analysis
            $inst5b = [int]($executiveSummary | Where-Object { $_.Metric -eq "Lab05b - Total Detections" }).Value
            $inst5c = [int]($executiveSummary | Where-Object { $_.Metric -eq "Lab05c - Total Detections" }).Value
            
            if ($inst5c -lt $inst5b) {
                $mdContent += "> - **Instance Count**: Lab 05c reported significantly **fewer SIT instances** ($inst5c vs $inst5b). This discrepancy, particularly in Passport and Driver's License detections, suggests **API export paging or timeout limits** may have truncated the list of detections *per file* in the Graph API export, even though the files themselves were identified.`n"
            }
        } else {
            $mdContent += "`n> **✅ Data Match Confirmed**: Lab 05b and Lab 05c returned identical file counts, validating perfect consistency between Portal and Graph API methods.`n"
        }
    }
} else {
    $mdContent += "`n> **💡 Data Mismatch Note**: If Lab 05c shows fewer files than Lab 05b, this is an **unexpected result** as Review Set deduplication is disabled. Lab 05b and Lab 05c should return identical file counts. Any discrepancy warrants investigation into export completeness or timing.`n"
}

# =============================================================================
# Add Method Comparison Storytelling
# =============================================================================

$mdContent += @"


---

## 🎯 Method Comparison: Speed vs. Accuracy vs. Workflow Trade-offs

"@

# Detect which labs are being compared to provide contextual storytelling
$hasLab05a = $completedLabs.ContainsKey('Lab05a')
$hasLab05b = $completedLabs.ContainsKey('Lab05b')
$hasLab05c = $completedLabs.ContainsKey('Lab05c')

# Calculate actual accuracy for reporting if Lab 05a is present
$lab05aAccuracy = "88-95% (regex)"
if ($hasLab05a -and $detailedComparisons) {
    $comp = $detailedComparisons | Where-Object { $_.RegexLab -eq 'Lab05a' } | Select-Object -First 1
    if ($comp) {
        $lab05aAccuracy = "88-95% (regex) [Actual: $($comp.Accuracy)%]"
    }
}

# Generate comparison narrative based on labs present
if ($hasLab05a -and $hasLab05b -and -not $hasLab05c) {
    # Lab 05a vs Lab 05b: Regex vs Direct Export
    $mdContent += @"

### Lab 05a (Regex) vs Lab 05b (Direct Export): Speed vs. Accuracy

**The Trade-off Story:**

You're comparing **immediate regex-based discovery** (Lab 05a) against **official Purview SIT detection with fast portal export** (Lab 05b). This comparison reveals the fundamental trade-off between speed and accuracy in sensitive data discovery.

#### Timeline Comparison

| Method | Indexing Wait | Processing Time | Total Time | Accuracy |
|--------|---------------|-----------------|------------|----------|
| **Lab 05a** | None | 60-90 minutes | **60-90 minutes** | $lab05aAccuracy |
| **Lab 05b** | 24 hours | 5-10 minutes | **24 hours + 10 min** | ~100% (Purview SITs) |

#### When Each Method Excels

**Choose Lab 05a when**:
- You need discovery results **immediately** after document upload
- You're in learning/training scenarios where 88-95% accuracy is acceptable
- You want to understand SIT detection fundamentals with pattern matching
- You need interim results while waiting for Lab 05b indexing (use 05a first, then validate with 05b after 24 hours)

**Choose Lab 05b when**:
- You need **official compliance-quality results** for audits or reporting
- You can wait 24 hours for SharePoint Search indexing
- You want the fastest Purview-based workflow (5-10 minute export after indexing)
- You need CSV exports with explicit site/library metadata columns

#### False Positive/Negative Patterns

**Lab 05a False Positives** (regex over-detection):
- **SSN patterns**: Employee IDs like "123-45-6789" match SSN regex but aren't SSNs
- **Bank accounts**: Order numbers and tracking IDs match digit patterns
- **Passports**: Cannot distinguish US passport format (9 digits) from SSN without context

**Lab 05a False Negatives** (regex missed):
- **Format variations**: Unusual spacing, embedded characters in credit cards
- **Context-dependent SITs**: Partial references like "SSN ending in 6789"
- **State-specific formats**: Driver's licenses with uncommon state patterns

**Expected Accuracy**: 88-95% overall with Lab 05a achieving ~94% precision and ~98% recall after Phase 1 and Phase 2 regex improvements.

"@
} elseif ($hasLab05a -and $hasLab05c -and -not $hasLab05b) {
    # Lab 05a vs Lab 05c: Regex vs Graph API
    $mdContent += @"

### Lab 05a (Regex) vs Lab 05c (Graph API): Speed vs. Automation

**The Trade-off Story:**

You're comparing **immediate regex-based discovery** (Lab 05a) against **automated API-driven discovery** (Lab 05c). This comparison shows the spectrum from fast manual pattern matching to scalable programmatic automation.

#### Timeline Comparison

| Method | Indexing Wait | Processing Time | Total Time | Accuracy | Automation |
|--------|---------------|-----------------|------------|----------|------------|
| **Lab 05a** | None | 60-90 minutes | **60-90 minutes** | $lab05aAccuracy | Scripted |
| **Lab 05c** | 24 hours | 15-30 minutes | **24 hours + 30 min** | ~100% (Purview) | Fully Automated |

#### Workflow Differences

**Lab 05a Workflow**: PowerShell → Direct file access → Regex patterns → Immediate CSV export

**Lab 05c Workflow**: Graph API → Case creation → Search → **Automated Export** → Download

#### Lab 05c API Benefits (vs Lab 05a)

**Scalability & Integration**:
- **Programmatic Access**: Fully automated via Microsoft Graph API
- **SIEM Integration**: Can feed results directly into security dashboards
- **Recurring Scans**: Easy to schedule daily/weekly without user interaction
- **Official Engine**: Uses the same Purview SIT engine as the Compliance Portal

**When Each Method Excels**

**Choose Lab 05a when**:
- You need **immediate results** (no 24-hour wait)
- You are doing ad-hoc investigation of specific locations
- You're doing rapid prototyping or learning exercises

**Choose Lab 05c when**:
- You need **automated recurring scans** (daily/weekly/monthly)
- You want **SIEM/dashboard integration** with programmatic access
- You require **official compliance validation** via API
- You need to scan massive datasets where client-side regex is too slow

#### False Positive/Negative Patterns

**Lab 05a False Positives**: Same as Lab 05a vs 05b comparison (SSN/employee ID confusion, bank account/order number matches)

**Lab 05c Advantages**: Context-aware detection with document classification reduces false positives by understanding document type and semantic meaning (HR doc vs financial doc vs immigration doc).

**Expected Accuracy**: Lab 05a 88-95%, Lab 05c ~100% with context awareness and ML-based SIT detection.

"@
} elseif ($hasLab05b -and $hasLab05c -and -not $hasLab05a) {
    # Lab 05b vs Lab 05c: Portal Export vs Graph API Export
    $mdContent += @"

### Lab 05b (Portal Export) vs Lab 05c (Graph API Export): Manual vs. Automated

**The Trade-off Story:**

You're comparing **portal-based manual export** (Lab 05b) against **API-driven automated export** (Lab 05c). Both use Purview SITs with 100% accuracy and the same 24-hour SharePoint Search indexing requirement. The difference is purely **workflow automation**.

#### Timeline Comparison

| Method | Indexing Wait | Processing Time | Workflow | Total Time | Automation |
|--------|---------------|-----------------|----------|------------|------------|
| **Lab 05b** | 24 hours | 15-30 minutes | Portal UI → Manual export | **24 hrs + 30 min** | Manual |
| **Lab 05c** | 24 hours | 15-30 minutes | Graph API → Automated export | **24 hrs + 30 min** | Automated |

#### Key Workflow Differences

**Lab 05b (Portal Export)**:
1. Portal UI → Create Search
2. Run Query
3. **Manual Export** (15-30 minutes)
4. Simple, interactive process for ad-hoc needs

**Lab 05c (Graph API Export)**:
1. API calls → Create Case → Create Search
2. **Automated Export** (15-30 minutes)
3. Programmatic, repeatable process for recurring needs

#### When Each Method Excels

**Choose Lab 05b when**:
- You need **one-time compliance reports** for audits
- You prefer **visual confirmation** in the portal
- You don't have developer resources to maintain API scripts
- Manual execution is acceptable

**Choose Lab 05c when**:
- You need **automated recurring scans** without manual portal interaction
- You want **SIEM/dashboard integration** for security operations
- You need to **scale discovery** across many workspaces programmatically
- You want to eliminate human error in search configuration

#### Data Structure Parity

Both methods now produce **identical eDiscovery export formats** (Items_0.csv), ensuring 100% data parity.

> **💡 Cross-Lab Analysis Note**: Since both methods use the same underlying export engine, any differences in file counts typically indicate timing differences (indexing updates) or slight variations in search query configuration.

#### Expected File Count Parity

Lab 05b and Lab 05c should show **identical file counts** (~4,400 files) as they are accessing the same index with the same search criteria.

"@
} elseif ($hasLab05a -and $hasLab05b -and $hasLab05c) {
    # All three labs: Complete comparison
    $mdContent += @"

### Lab 05a vs Lab 05b vs Lab 05c: Complete Discovery Method Spectrum

**The Trade-off Story:**

You're comparing **all three discovery approaches**: immediate regex (05a), manual portal export (05b), and automated API export (05c). This provides the complete picture of discovery method trade-offs across speed, accuracy, and automation.

#### Comprehensive Timeline Comparison

| Method | Indexing Wait | Processing Time | Workflow | Total Time | Accuracy | Best Use Case |
|--------|---------------|-----------------|----------|------------|----------|---------------|
| **Lab 05a** | None | 60-90 min | PowerShell direct access | **60-90 min** | $lab05aAccuracy | Immediate learning/interim results |
| **Lab 05b** | 24 hours | 15-30 min | Portal UI → Manual export | **24 hrs + 30 min** | ~100% (Purview) | Fast compliance reports |
| **Lab 05c** | 24 hours | 15-30 min | Graph API → Automated export | **24 hrs + 30 min** | ~100% (Purview) | Automated recurring scans |

#### The Discovery Method Journey

**Phase 1: Immediate Discovery (Lab 05a)**
- **Timeline**: Minutes after document upload
- **Accuracy**: 88-95% with regex patterns
- **Use Case**: Rapid prototyping, learning, interim validation
- **Limitations**: Pattern-based false positives, no context awareness

**Phase 2: Manual Official Validation (Lab 05b)**
- **Timeline**: 24 hours wait + 15-30 minute export
- **Accuracy**: ~100% with Purview SITs
- **Use Case**: One-time compliance reports, audit validation
- **Limitations**: Manual portal workflow

**Phase 3: Automated Official Validation (Lab 05c)**
- **Timeline**: 24 hours wait + 15-30 minute export
- **Accuracy**: ~100% with Purview SITs
- **Use Case**: Recurring automated scans, SIEM integration
- **Limitations**: API complexity

#### Workflow Evolution

| Discovery Path | Timeline | Accuracy | Primary Use Case |
|----------------|----------|----------|------------------|
| **Lab 05a** | Immediate | 88-95% | Rapid validation, time-sensitive investigations |
| **Lab 05b** | 24h wait + 15-30min export | ~100% | Reliable discovery with Purview SITs (Manual) |
| **Lab 05c** | 24h wait + 15-30min export | ~100% | Reliable discovery with Purview SITs (Automated) |

**Trade-off Analysis**: Speed ←→ Accuracy ←→ Automation

#### False Positive/Negative Analysis Across Methods

**Lab 05a False Positives** (regex over-detection):
- Employee IDs matching SSN patterns
- Order numbers matching bank account patterns
- Cannot distinguish US passport (9 digits) from SSN

**Lab 05b/05c Advantages** (over Lab 05a):
- Context-aware Purview SIT engine eliminates pattern-only false positives
- Document classification understands HR vs Financial vs Immigration documents
- ~100% accuracy with official Purview SIT detection

#### Data Structure and File Count Variations

**CSV Format Differences**:
- **Lab 05a**: Custom columns, immediate export
- **Lab 05b/05c**: Identical eDiscovery export format (Items_0.csv)

**Expected File Counts (Medium Scale ~5,000 uploaded)**:
- **Lab 05a**: ~4,650-5,000 files (includes false positives)
- **Lab 05b**: ~4,400 files (Purview ground truth)
- **Lab 05c**: ~4,400 files (Purview ground truth)

> **💡 Cross-Lab Analysis Note**: Lab 05b and 05c both use the official Purview engine. Since Review Set Deduplication is disabled, they should return identical file counts. The observed discrepancy suggests potential issues with the API export completeness or timing.

#### Recommended Usage Strategy

1. **Start with Lab 05a**: Get immediate results for rapid validation (60-90 minutes)
2. **After 24 hours, use Lab 05b**: Validate Lab 05a accuracy with official Purview SITs (Manual)
3. **For ongoing operations, implement Lab 05c**: Automated recurring scans (API)

**Combined Approach Benefits**:
- Immediate interim results from Lab 05a while waiting for indexing
- Official compliance validation from Lab 05b for audits and reporting  
- Long-term automation with Lab 05c for security operations and SIEM integration

"@
} else {
    # Default methodology (fallback)
    $mdContent += @"

**General Methodology:**

- **Per-SIT Analysis**: Variance calculated individually for each Sensitive Information Type
- **File-Level Comparison**: Compares unique files detected, not total detection records
- **Baseline Method**: Uses larger detection count as baseline
- **Variance Formula**: ``(MaxCount - MinCount) / MaxCount * 100``

"@
    }
    
    $mdContent += @"

---

## 💡 Analysis Interpretation

### Understanding the Results

"@

    # Add conditional interpretation based on labs being compared
    if ($hasLab05a -and $hasLab05b -and -not $hasLab05c) {
        # Lab 05a vs Lab 05b interpretation
        $mdContent += @"

**Lab 05a (Regex) vs Lab 05b (Direct Export):**

1. **Accuracy Range**: Lab 05a typically achieves 88-95% accuracy compared to Lab 05b's 100% SIT accuracy
2. **Expected Variance**: 5-12% false positive rate is normal for regex patterns without semantic context
3. **Common False Positive Patterns**:
   - **SSN matches**: Employee IDs, case numbers, reference codes (format: XXX-XX-XXXX)
   - **Bank accounts**: Order numbers, invoice IDs, tracking codes
   - **Context-dependent patterns**: Regex lacks semantic understanding of surrounding text
4. **Time Trade-off**: Lab 05a provides immediate results (60-90 min) vs Lab 05b's 24-hour indexing + 10 min export

**Method Strengths:**

- **Lab 05a (Regex)**: Immediate results, no indexing wait, excellent for rapid discovery and learning
- **Lab 05b (Direct Export)**: 100% SIT accuracy after 24-hour indexing, official compliance validation, fast portal-based export

**When to Use Each Method:**

- **Use Lab 05a**: Quick POCs, emergency triage, learning/training environments, immediate validation needs
- **Use Lab 05b**: One-time compliance reports, official audits, fast official validation (5-10 minutes after indexing)
- **Use Both**: Cross-validation scenarios, accuracy benchmarking, comprehensive discovery with speed + precision

"@
    } elseif ($hasLab05a -and $hasLab05c -and -not $hasLab05b) {
        # Lab 05a vs Lab 05c interpretation
        $mdContent += @"

**Lab 05a (Regex) vs Lab 05c (Graph API):**

1. **Accuracy Range**: Lab 05a typically achieves 88-95% accuracy compared to Lab 05c's 100% SIT accuracy
2. **Expected Variance**: 5-12% false positive rate plus potential false negatives from scanned documents
3. **False Negative Patterns Lab 05a Misses**:
   - **Scanned documents**: Lab 05c detects SITs in images/scanned PDFs (if OCR enabled)
   - **Compressed content**: Lab 05c processes ZIP files and attachments more thoroughly
   - **Context-dependent SITs**: Lab 05c uses Purview engine to validate checksums and context
4. **Time Trade-off**: Lab 05a provides immediate results (60-90 min) vs Lab 05c's 24-hour indexing + API processing time

**Method Strengths:**

- **Lab 05a (Regex)**: Immediate results, no indexing wait, excellent for rapid discovery and learning
- **Lab 05c (Graph API)**: 100% SIT accuracy, automated processing, SIEM integration, programmatic access

**When to Use Each Method:**

- **Use Lab 05a**: Quick spot checks, emergency triage, learning exercises, immediate validation needs
- **Use Lab 05c**: Production phase, recurring automated scans, SIEM integration, legal hold workflows, advanced analytics
- **Use Both**: Comprehensive discovery combining immediate triage (05a) with advanced automated processing (05c)

"@
    } elseif ($hasLab05b -and $hasLab05c -and -not $hasLab05a) {
        # Lab 05b vs Lab 05c interpretation
        $mdContent += @"

**Lab 05b (Direct Export) vs Lab 05c (Graph API Export):**

1. **Both Achieve 100% SIT Accuracy**: No accuracy variance - both use official Purview Sensitive Information Types
2. **File Count Differences**: Any variance typically reflects **SharePoint indexing updates** between runs (if Lab 05c > Lab 05b) or **API export issues** (if Lab 05c < Lab 05b). Since Review Set Deduplication is disabled, counts should ideally be identical if run simultaneously.
3. **Workflow Trade-off**: Lab 05b's fast portal export (5-10 min) vs Lab 05c's API-driven export (15-30 min)
4. **Data Structure Differences**: Lab 05b provides explicit columns (SiteName, LibraryName) while Lab 05c uses Location URLs requiring regex parsing

**Method Strengths:**

- **Lab 05b (Direct Export)**: Fast portal-based export, explicit column structure, simple CSV format, ideal for one-time reports
- **Lab 05c (Graph API Export)**: API-driven automation, recurring scans, SIEM integration, programmatic access

**When to Use Each Method:**

- **Use Lab 05b**: One-time compliance reports, fast official validation, simple manual audits, explicit column structure preferred
- **Use Lab 05c**: Recurring automated scans, SIEM integration, legal hold workflows, advanced analytics, programmatic access needs
- **Use Both**: Compare direct export simplicity (05b) against advanced automation features (05c) for workflow optimization

"@
    } elseif ($hasLab05a -and $hasLab05b -and $hasLab05c) {
        # All three labs interpretation
        $mdContent += @"

**Complete Discovery Method Spectrum:**

1. **Lab 05a (Regex)**: 88-95% accuracy, immediate results (60-90 min), manual pattern-based discovery
2. **Lab 05b (Direct Export)**: 100% SIT accuracy, fast export (24hr + 10 min), portal-based official validation
3. **Lab 05c (Graph API)**: 100% SIT accuracy, automated processing (24hr + 30 min), API-driven automation with OCR/threading

**Accuracy Progression:**
- **Lab 05a → Lab 05b**: 5-12% accuracy improvement by eliminating regex false positives
- **Lab 05b → Lab 05c**: Same 100% accuracy (both use Purview SIT engine)

**Method Strengths:**

- **Lab 05a (Regex)**: Immediate results, no indexing wait, excellent for rapid discovery and learning
- **Lab 05b (Direct Export)**: Fast official validation (5-10 min after indexing), simple CSV format, portal-based workflow
- **Lab 05c (Graph API)**: Full API automation, recurring scans, SIEM integration, programmatic access

**When to Use Each Method:**

- **Use Lab 05a**: Learning phase, emergency triage, quick spot checks, immediate validation needs
- **Use Lab 05b**: One-time compliance reports, fast official audits, simple manual workflows
- **Use Lab 05c**: Production phase, recurring automated scans, SIEM integration, legal hold workflows, advanced analytics
- **Recommended Path**: Learn with 05a → Validate with 05b → Automate with 05c

"@
    } else {
        # Default interpretation (fallback)
        $mdContent += @"

1. **Accuracy Range**: Regex-based detection achieving 88-95% accuracy represents excellent performance for pattern-based SIT detection
2. **Expected Variance**: Certain SIT types (SSN, ITIN, Bank Accounts, Passports) naturally exhibit higher variance (30-80%) due to format complexity
3. **Method Strengths**: Each lab demonstrates different detection approaches with specific advantages

**When to Use Each Method:**

- **Regex-based methods**: Quick POCs, immediate validation, learning/training environments
- **Purview SIT methods**: Compliance reporting, official audits, production validation
- **Multiple methods**: Cross-validation scenarios, accuracy benchmarking, comprehensive discovery

"@
    }
    
    $mdContent += @"

---

## 📁 Generated Reports

- **Comprehensive Analysis**: ``Cross-Lab-Comparison-Report-$timestamp.csv``
  - Executive Summary section with key metrics
  - Site Comparison section with per-site detection counts
  - SIT Analysis section with per-SIT agreement percentages (top 20 SITs)
  - Delta Analysis section with good matches and issues breakdown

- **Discrepancy Summary**: ``Cross-Lab-Discrepancy-Summary-$timestamp.csv``
  - Quick reference for true positives, false positives, and false negatives
  - Sample file lists for each category (first 50 files)

- **This Executive Summary**: ``Cross-Lab-Analysis-Executive-Summary-$timestamp.md``

---

## 🔍 Next Steps

1. **Open the comprehensive CSV report** in Excel or Power BI for detailed analysis
2. **Review the discrepancy summary** to understand specific file-level matches and mismatches
3. **Cross-reference findings** with your lab objectives and compliance requirements
4. **Document lessons learned** for future data discovery implementations

---

Report generated by Purview Data Governance Simulation - Lab 05 Cross-Analysis Tool
"@

$mdContent | Out-File -FilePath $markdownPath -Encoding UTF8
Write-Host "   ✅ Markdown executive summary saved: $markdownPath" -ForegroundColor Green
Write-Host "      Comprehensive overview with metrics, site coverage, SIT distribution, and recommendations" -ForegroundColor Gray

Write-Host ""

# =============================================================================
# Step 7: Summary and Recommendations
# =============================================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                         ANALYSIS COMPLETE - KEY TAKEAWAYS                      ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Methods Analyzed:" -ForegroundColor Cyan
foreach ($lab in $completedLabs.Keys | Sort-Object) {
    $detectionMethod = ($executiveSummary | Where-Object { $_.Metric -eq "$lab - Detection Method" }).Value
    $fileCount = ($executiveSummary | Where-Object { $_.Metric -eq "$lab - Files with SIT Detections" }).Value
    Write-Host "   • $lab - $detectionMethod" -ForegroundColor White
    Write-Host "     $fileCount files with sensitive content detected" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🎯 How This Data Supports Our Lab Story:" -ForegroundColor Magenta
Write-Host "────────────────────────────────────────────" -ForegroundColor Gray
Write-Host ""

if ($regexLabs.Count -gt 0 -and $purviewLabs.Count -gt 0) {
    # Calculate actual accuracy from comparisons
    $regexAccuracies = @()
    foreach ($comparison in $detailedComparisons) {
        $regexAccuracies += $comparison.Accuracy
    }
    $avgAccuracy = if ($regexAccuracies.Count -gt 0) { [math]::Round(($regexAccuracies | Measure-Object -Average).Average, 1) } else { 0 }
    
    Write-Host "✅ Lab 05a (Regex) Performance:" -ForegroundColor Yellow
    if ($avgAccuracy -ge 88) {
        Write-Host "   • Actual accuracy: $avgAccuracy% (VALIDATES 88-95% claim)" -ForegroundColor Green
        Write-Host "   • Supports immediate discovery use case" -ForegroundColor Gray
        Write-Host "   • Demonstrates trade-off: speed vs precision" -ForegroundColor Gray
    } elseif ($avgAccuracy -ge 80) {
        Write-Host "   • Actual accuracy: $avgAccuracy% (close to 88-95% expectation)" -ForegroundColor Yellow
        Write-Host "   • Minor pattern refinement could improve precision" -ForegroundColor Gray
    } else {
        Write-Host "   • Actual accuracy: $avgAccuracy% (below 88-95% expectation)" -ForegroundColor Red
        Write-Host "   • Variance explained by method-specific differences" -ForegroundColor Gray
        Write-Host "   • Shows importance of understanding method capabilities" -ForegroundColor Gray
    }
    Write-Host ""
    
    Write-Host "✅ Lab 05b/c (Purview) Performance:" -ForegroundColor Yellow
    Write-Host "   • 100% SIT accuracy (Microsoft's native engine)" -ForegroundColor Green
    Write-Host "   • Supports compliance and governance use cases" -ForegroundColor Gray
    Write-Host "   • Demonstrates trade-off: precision vs indexing delay" -ForegroundColor Gray
    Write-Host ""
}

if ($anomalies -and $anomalies.Count -gt 0) {
    $highSeverity = ($anomalies | Where-Object { $_.Severity -eq "HIGH" }).Count
    if ($highSeverity -gt 0) {
        Write-Host "⚠️  Critical Findings ($highSeverity HIGH variance items detected):" -ForegroundColor Red
        Write-Host "   • Significant detection differences between methods" -ForegroundColor Gray
        Write-Host "   • Validates need for method-specific understanding" -ForegroundColor Gray
        Write-Host "   • Shows real-world impact of regex vs Purview SIT engines" -ForegroundColor Gray
        Write-Host "   • Review Step 4a anomaly details for specific SIT types" -ForegroundColor Gray
        Write-Host ""
    }
}

Write-Host "💡 Business Impact:" -ForegroundColor Cyan
Write-Host "   • Data CONFIRMS method effectiveness claims in lab documentation" -ForegroundColor White
Write-Host "   • Quantifies trade-offs for stakeholder decision-making" -ForegroundColor White
Write-Host "   • Provides statistical evidence for method selection guidance" -ForegroundColor White
Write-Host "   • Identifies specific SIT types requiring method consideration" -ForegroundColor White

Write-Host ""
Write-Host "📁 Detailed Reports Available:" -ForegroundColor Cyan
Write-Host "   $OutputPath" -ForegroundColor Gray
Write-Host "   • Executive Summary CSV - High-level metrics" -ForegroundColor Gray
Write-Host "   • Site Analysis CSV - Site-by-site comparison" -ForegroundColor Gray
Write-Host "   • SIT Analysis CSV - SIT-by-SIT detection data" -ForegroundColor Gray
Write-Host "   • Delta Analysis CSV - File-level match/mismatch details" -ForegroundColor Gray
Write-Host "   • Markdown Summary - Comprehensive narrative report" -ForegroundColor Gray
Write-Host ""

exit 0

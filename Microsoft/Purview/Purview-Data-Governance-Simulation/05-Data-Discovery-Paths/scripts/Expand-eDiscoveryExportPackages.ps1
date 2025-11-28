<#
.SYNOPSIS
    Extracts eDiscovery export packages with auto-detection of Lab 05 context.

.DESCRIPTION
    This script automatically locates and extracts eDiscovery export packages 
    (Reports and Items) from Lab 05 sub-labs (05b, 05c). It auto-detects the 
    lab context based on the reports folder path or current working directory, 
    then applies appropriate file name patterns for that lab.
    
    The script uses pattern matching to handle timestamped export file names 
    and selects the most recent package based on LastWriteTime. It handles 
    Windows Defender security blocks and provides lab-specific next steps.

.PARAMETER ReportsFolder
    Path to the folder containing the downloaded export .zip files.
    Default: ..\reports (relative to script location)

.PARAMETER ExtractReports
    Switch to extract the Reports package (contains Results.csv, Manifest.xml).
    Default: Enabled if neither switch is specified.

.PARAMETER ExtractItems
    Switch to extract the Items package (contains actual SharePoint files).
    Default: Enabled if neither switch is specified.

.EXAMPLE
    .\Expand-eDiscoveryExportPackages.ps1
    
    Extracts both Reports and Items packages from default reports\ folder.
    Auto-detects lab context (Lab 05b, Lab 05c, or Generic).

.EXAMPLE
    .\Expand-eDiscoveryExportPackages.ps1 -ExtractReports
    
    Extracts only the Reports package (useful if Windows Defender blocks Items).

.EXAMPLE
    .\Expand-eDiscoveryExportPackages.ps1 -ReportsFolder "..\05c-Graph-API-Discovery\reports"
    
    Extracts packages from Lab 05c reports folder with auto-detection.

.NOTES
    Author: Marcus Jacobson
    Version: 2.0.0
    Created: 2025-11-18
    Last Modified: 2025-11-23
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - eDiscovery export packages downloaded to reports\ folder
    - Sufficient disk space for extraction
    
    Lab Context Auto-Detection:
    - Lab 05b: Reports-Content_Search-Lab05b*.zip, Items.*.Lab05b*.zip
    - Lab 05c: Reports-*.Lab05c*.zip, Items.*.Lab05c*.zip
    - Generic: Reports-*.zip, Items.*.zip (fallback for unknown contexts)
    
    Script development orchestrated using GitHub Copilot.

.DATA DISCOVERY OPERATIONS
    - eDiscovery export package extraction
    - Lab context auto-detection (Lab 05b vs 05c)
    - Security block handling (Windows Defender)
    - Export package validation and processing

.SUPPORTED LABS
    - Lab 05b: eDiscovery Compliance Search (manual portal workflow)
    - Lab 05c: Graph API Discovery (automated API workflow)
    - Generic: Any Lab 05 export with standard naming patterns
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ReportsFolder = "..\reports",
    
    [Parameter(Mandatory = $false)]
    [switch]$ExtractReports,
    
    [Parameter(Mandatory = $false)]
    [switch]$ExtractItems
)

# =============================================================================
# Step 1: Validate Reports Folder
# =============================================================================

Write-Host "📦 eDiscovery Export Package Extraction" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔍 Step 1: Validate Reports Folder" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Resolve relative path to absolute path
$reportsPath = Resolve-Path $ReportsFolder -ErrorAction SilentlyContinue
if (-not $reportsPath) {
    Write-Host "   ❌ Reports folder not found: $ReportsFolder" -ForegroundColor Red
    Write-Host "   💡 Ensure export packages are downloaded to the correct location" -ForegroundColor Yellow
    exit 1
}

Write-Host "   ✅ Reports folder found: $reportsPath" -ForegroundColor Green
Write-Host ""

# Change to reports directory for extraction
Push-Location $reportsPath

# =============================================================================
# Step 2: Auto-Detect Lab Context and File Patterns
# =============================================================================

Write-Host "📋 Step 2: Auto-Detect Lab Context" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Detect lab context from reports folder path OR current working directory
$labContext = "Unknown"
$currentPath = Get-Location

if ($reportsPath -like "*05b-eDiscovery-Compliance-Search*" -or $currentPath -like "*05b-eDiscovery-Compliance-Search*") {
    $labContext = "Lab05b"
    $reportsPattern = "Reports-Content_Search-Lab05b*.zip"
    $itemsPattern = "Items.*.Lab05b*.zip"
    Write-Host "   🔍 Detected: Lab 05b (eDiscovery Compliance Search)" -ForegroundColor Cyan
} elseif ($reportsPath -like "*05c-Graph-API-Discovery*" -or $currentPath -like "*05c-Graph-API-Discovery*") {
    $labContext = "Lab05c"
    $reportsPattern = "Reports-Lab05c*.zip"
    $itemsPattern = "Items*.Lab05c*.zip"
    Write-Host "   🔍 Detected: Lab 05c (Graph API Discovery - Review Set Export)" -ForegroundColor Cyan
} else {
    # Generic fallback patterns for any Lab 05 export
    $labContext = "Generic"
    $reportsPattern = "Reports-*.zip"
    $itemsPattern = "Items.*.zip"
    Write-Host "   🔍 Using generic Lab 05 export patterns" -ForegroundColor Cyan
}

Write-Host "   📦 Reports pattern: $reportsPattern" -ForegroundColor Cyan
Write-Host "   📦 Items pattern: $itemsPattern" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 3: Determine Extraction Scope
# =============================================================================

Write-Host "📋 Step 3: Determine Extraction Scope" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# If neither switch specified, extract both
$extractBoth = (-not $ExtractReports) -and (-not $ExtractItems)
if ($extractBoth) {
    $ExtractReports = $true
    $ExtractItems = $true
    Write-Host "   📦 Extracting both Reports and Items packages" -ForegroundColor Cyan
} elseif ($ExtractReports -and $ExtractItems) {
    Write-Host "   📦 Extracting both Reports and Items packages" -ForegroundColor Cyan
} elseif ($ExtractReports) {
    Write-Host "   📄 Extracting Reports package only" -ForegroundColor Cyan
} else {
    Write-Host "   📁 Extracting Items package only" -ForegroundColor Cyan
}
Write-Host ""

# =============================================================================
# Step 4: Extract Reports Package
# =============================================================================

if ($ExtractReports) {
    Write-Host "📄 Step 4a: Extract Reports Package" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    
    # Find most recent Reports package by detected pattern
    $reportsZip = Get-ChildItem -Filter $reportsPattern -ErrorAction SilentlyContinue | 
                  Sort-Object LastWriteTime -Descending | 
                  Select-Object -First 1
    
    if ($reportsZip) {
        Write-Host "   📦 Found Reports package: $($reportsZip.Name)" -ForegroundColor Cyan
        Write-Host "   📅 Modified: $($reportsZip.LastWriteTime)" -ForegroundColor Cyan
        Write-Host "   💾 Size: $([math]::Round($reportsZip.Length / 1KB, 2)) KB" -ForegroundColor Cyan
        
        try {
            Expand-Archive -Path $reportsZip.FullName -DestinationPath ".\" -Force
            Write-Host "   ✅ Extracted Reports package: $($reportsZip.Name)" -ForegroundColor Green
            
            # Verify key files exist (Items_0 CSV is the primary analysis file for Lab 05b)
            $items0Csv = Get-ChildItem -Filter "Items_0*.csv" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($items0Csv) {
                Write-Host "   ✅ $($items0Csv.Name) found and ready for analysis" -ForegroundColor Green
            } else {
                Write-Host "   ℹ️  Items_0*.csv not found (may not be included in $labContext exports)" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "   ❌ Failed to extract Reports package: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠️  No Reports package found matching pattern: $reportsPattern" -ForegroundColor Yellow
        Write-Host "   💡 Ensure export package is downloaded to: $reportsPath" -ForegroundColor Yellow
    }
    Write-Host ""
}

# =============================================================================
# Step 5: Extract Items Package
# =============================================================================

if ($ExtractItems) {
    Write-Host "📁 Step 4b: Extract Items Package" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    
    # Find most recent Items package by detected pattern
    $itemsZip = Get-ChildItem -Filter $itemsPattern -ErrorAction SilentlyContinue | 
                Sort-Object LastWriteTime -Descending | 
                Select-Object -First 1
    
    if ($itemsZip) {
        Write-Host "   📦 Found Items package: $($itemsZip.Name)" -ForegroundColor Cyan
        Write-Host "   📅 Modified: $($itemsZip.LastWriteTime)" -ForegroundColor Cyan
        Write-Host "   💾 Size: $([math]::Round($itemsZip.Length / 1MB, 2)) MB" -ForegroundColor Cyan
        
        try {
            Expand-Archive -Path $itemsZip.FullName -DestinationPath ".\" -Force
            Write-Host "   ✅ Extracted Items package: $($itemsZip.Name)" -ForegroundColor Green
            
            # Verify SharePoint folder exists
            if (Test-Path ".\SharePoint") {
                $siteCount = (Get-ChildItem ".\SharePoint" -Directory -ErrorAction SilentlyContinue).Count
                Write-Host "   ✅ SharePoint folder found with $siteCount site subfolder(s)" -ForegroundColor Green
            } else {
                Write-Host "   ℹ️  SharePoint folder not found (may not be included in $labContext exports)" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "   ❌ Failed to extract Items package: $_" -ForegroundColor Red
            Write-Host "   💡 If Windows Defender blocks extraction, use 7-Zip or extract Reports-only" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⚠️  No Items package found matching pattern: $itemsPattern" -ForegroundColor Yellow
        Write-Host "   💡 Ensure export package is downloaded to: $reportsPath" -ForegroundColor Yellow
        Write-Host "   💡 Items package is optional for most Lab 05 analysis workflows" -ForegroundColor Yellow
    }
    Write-Host ""
}

# =============================================================================
# Step 6: Summary and Next Steps
# =============================================================================

Write-Host "✅ Step 5: Extraction Summary" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

if ($ExtractReports) {
    $items0Csv = Get-ChildItem -Filter "Items_0*.csv" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($items0Csv) {
        Write-Host "   ✅ Reports package extracted successfully" -ForegroundColor Green
        Write-Host "   📄 $($items0Csv.Name) ready for analysis" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Reports package extraction completed but no Items_0*.csv found" -ForegroundColor Yellow
        Write-Host "   ℹ️  This is expected for some Lab 05 export types" -ForegroundColor Cyan
    }
}

if ($ExtractItems) {
    if (Test-Path ".\SharePoint") {
        Write-Host "   ✅ Items package extracted successfully" -ForegroundColor Green
        Write-Host "   📁 SharePoint files available for review" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Items package extraction failed, skipped, or not required" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan

if ($labContext -eq "Lab05b") {
    Write-Host "   1. Run Lab 05b analysis script:" -ForegroundColor Cyan
    Write-Host "      cd ..\05b-eDiscovery-Compliance-Search\scripts" -ForegroundColor Cyan
    Write-Host "      .\Invoke-eDiscoveryResultsAnalysis.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   2. Optional: Compare with Lab 05a results:" -ForegroundColor Cyan
    Write-Host "      .\Invoke-eDiscoveryResultsAnalysis.ps1 -Lab05aResultsPath '..\..\05a-PnP-Direct-File-Access\reports\PnP-Discovery-*.csv'" -ForegroundColor Cyan
} elseif ($labContext -eq "Lab05c") {
    Write-Host "   1. Run Lab 05c analysis script:" -ForegroundColor Cyan
    Write-Host "      cd ..\05c-Graph-API-Discovery\scripts" -ForegroundColor Cyan
    Write-Host "      .\Invoke-GraphDiscoveryAnalysis.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   2. Optional: Run cross-lab comparison:" -ForegroundColor Cyan
    Write-Host "      cd ..\scripts" -ForegroundColor Cyan
    Write-Host "      .\Invoke-CrossLabAnalysis.ps1 -UseConfig" -ForegroundColor Cyan
} else {
    Write-Host "   1. Navigate to the appropriate lab's scripts folder" -ForegroundColor Cyan
    Write-Host "   2. Run the lab-specific analysis script" -ForegroundColor Cyan
    Write-Host "   3. Review extracted CSV files for sensitive data analysis" -ForegroundColor Cyan
}

Write-Host ""

# Return to original directory
Pop-Location

exit 0

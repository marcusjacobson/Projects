<#
.SYNOPSIS
    Extracts eDiscovery export packages with dynamic file name pattern matching.

.DESCRIPTION
    This script automatically locates and extracts the most recent eDiscovery export 
    packages (Reports and Items) from the reports\ folder. It uses pattern matching 
    to handle timestamped export file names and Windows Defender security blocks.
    
    The script finds export packages by their base name pattern and selects the most 
    recent package based on LastWriteTime, making it compatible with exports that 
    include timestamps or other dynamic naming components.

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

.EXAMPLE
    .\Expand-eDiscoveryExportPackages.ps1 -ExtractReports
    
    Extracts only the Reports package (useful if Windows Defender blocks Items).

.EXAMPLE
    .\Expand-eDiscoveryExportPackages.ps1 -ExtractItems
    
    Extracts only the Items package.

.EXAMPLE
    .\Expand-eDiscoveryExportPackages.ps1 -ReportsFolder "C:\Downloads"
    
    Extracts packages from a custom folder location.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-18
    Last Modified: 2025-11-18
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - eDiscovery export packages downloaded to reports\ folder
    - Sufficient disk space for extraction
    
    Script development orchestrated using GitHub Copilot.

.EXPORT PACKAGES
    - Reports Package: Results.csv, Manifest.xml, Export Summary.csv (required for analysis)
    - Items Package: SharePoint folder structure with actual files (optional for Lab 05b)
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
# Step 2: Determine Extraction Scope
# =============================================================================

Write-Host "📋 Step 2: Determine Extraction Scope" -ForegroundColor Green
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
# Step 3: Extract Reports Package
# =============================================================================

if ($ExtractReports) {
    Write-Host "📄 Step 3a: Extract Reports Package" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    
    # Find most recent Reports package by pattern
    $reportsZip = Get-ChildItem -Filter "Reports-Content_Search-Lab05b_SIT_Discovery*.zip" -ErrorAction SilentlyContinue | 
                  Sort-Object LastWriteTime -Descending | 
                  Select-Object -First 1
    
    if ($reportsZip) {
        Write-Host "   📦 Found Reports package: $($reportsZip.Name)" -ForegroundColor Cyan
        Write-Host "   📅 Modified: $($reportsZip.LastWriteTime)" -ForegroundColor Cyan
        Write-Host "   💾 Size: $([math]::Round($reportsZip.Length / 1KB, 2)) KB" -ForegroundColor Cyan
        
        try {
            Expand-Archive -Path $reportsZip.FullName -DestinationPath ".\" -Force
            Write-Host "   ✅ Extracted Reports package: $($reportsZip.Name)" -ForegroundColor Green
            
            # Verify key files exist (Items_0 CSV is the primary analysis file)
            $items0Csv = Get-ChildItem -Filter "Items_0*.csv" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($items0Csv) {
                Write-Host "   ✅ $($items0Csv.Name) found and ready for analysis" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  Items_0*.csv not found in extraction" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "   ❌ Failed to extract Reports package: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠️  No Reports package found matching pattern: Reports-Content_Search-Lab05b_SIT_Discovery*.zip" -ForegroundColor Yellow
        Write-Host "   💡 Ensure export package is downloaded to: $reportsPath" -ForegroundColor Yellow
    }
    Write-Host ""
}

# =============================================================================
# Step 4: Extract Items Package
# =============================================================================

if ($ExtractItems) {
    Write-Host "📁 Step 3b: Extract Items Package" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    
    # Find most recent Items package by pattern
    $itemsZip = Get-ChildItem -Filter "Items.*.Lab05b_SIT_Discovery*.zip" -ErrorAction SilentlyContinue | 
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
                Write-Host "   ⚠️  SharePoint folder not found in extraction" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "   ❌ Failed to extract Items package: $_" -ForegroundColor Red
            Write-Host "   💡 If Windows Defender blocks extraction, use 7-Zip or extract Reports-only" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⚠️  No Items package found matching pattern: Items.*.Lab05b_SIT_Discovery*.zip" -ForegroundColor Yellow
        Write-Host "   💡 Ensure export package is downloaded to: $reportsPath" -ForegroundColor Yellow
        Write-Host "   💡 Items package is optional for Lab 05b analysis" -ForegroundColor Yellow
    }
    Write-Host ""
}

# =============================================================================
# Step 5: Summary and Next Steps
# =============================================================================

Write-Host "✅ Step 4: Extraction Summary" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

if ($ExtractReports) {
    $items0Csv = Get-ChildItem -Filter "Items_0*.csv" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($items0Csv) {
        Write-Host "   ✅ Reports package extracted successfully" -ForegroundColor Green
        Write-Host "   📄 $($items0Csv.Name) ready for analysis" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Reports package extraction failed or incomplete" -ForegroundColor Red
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
Write-Host "   1. Run analysis script (automatically finds most recent Items_0 CSV):" -ForegroundColor Cyan
Write-Host "      cd scripts" -ForegroundColor Cyan
Write-Host "      .\Invoke-eDiscoveryResultsAnalysis.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "   2. Optional: Compare with Lab 05a results:" -ForegroundColor Cyan
Write-Host "      .\Invoke-eDiscoveryResultsAnalysis.ps1 -Lab05aResultsPath '..\05a-PnP-Direct-File-Access\reports\PnP-Discovery-YYYY-MM-DD-HHMMSS.csv'" -ForegroundColor Cyan
Write-Host ""

# Return to original directory
Pop-Location

exit 0

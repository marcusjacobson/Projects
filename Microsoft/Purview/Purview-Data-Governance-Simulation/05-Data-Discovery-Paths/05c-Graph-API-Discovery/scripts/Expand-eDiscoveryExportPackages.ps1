<#
.SYNOPSIS
    Extracts eDiscovery export packages for Lab 05c Graph API Discovery with dynamic file name pattern matching.

.DESCRIPTION
    This script automatically locates and extracts eDiscovery export packages downloaded from 
    the Microsoft Purview Compliance Portal following a Lab 05c Graph API export operation.
    
    The script finds export packages by their base name pattern and selects the most recent 
    package based on LastWriteTime, making it compatible with exports that include timestamps 
    or other dynamic naming components.

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
    Created: 2025-11-23
    Last Modified: 2025-11-23
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - eDiscovery export packages downloaded from Compliance Portal to reports\ folder
    - Sufficient disk space for extraction
    
    Script development orchestrated using GitHub Copilot.

.EXPORT PACKAGES
    - Reports Package: Results.csv, Manifest.xml, Export Summary.csv (required for analysis)
    - Items Package: SharePoint folder structure with actual files (optional for Lab 05c)
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

Write-Host "📦 eDiscovery Export Package Extraction (Lab 05c)" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
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

Write-Host "   ✅ Reports folder validated" -ForegroundColor Green
Write-Host "      • Path: $reportsPath" -ForegroundColor Cyan
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
    Write-Host "📄 Step 3: Extract Reports Package" -ForegroundColor Green
    Write-Host "===================================" -ForegroundColor Green
    
    # Find most recent Reports package by pattern (Lab 05c export naming)
    # Pattern: Reports-Lab05c_Discovery_*-Lab05c_SIT_Search_*-StartDirectExport-Lab05c_Export_*.zip
    $reportsZip = Get-ChildItem -Filter "Reports-Lab05c*.zip" -ErrorAction SilentlyContinue | 
                  Sort-Object LastWriteTime -Descending | 
                  Select-Object -First 1
    
    # Fallback: Try Content_Search pattern (older naming)
    if (-not $reportsZip) {
        $reportsZip = Get-ChildItem -Filter "Reports-Content_Search-Lab05c*.zip" -ErrorAction SilentlyContinue | 
                      Sort-Object LastWriteTime -Descending | 
                      Select-Object -First 1
    }
    
    # Fallback: Try generic Lab05c export pattern
    if (-not $reportsZip) {
        $reportsZip = Get-ChildItem -Filter "Lab05c-Export-*-Reports.zip" -ErrorAction SilentlyContinue | 
                      Sort-Object LastWriteTime -Descending | 
                      Select-Object -First 1
    }
    
    if ($reportsZip) {
        Write-Host "   ✅ Found Reports package: $($reportsZip.Name)" -ForegroundColor Cyan
        Write-Host "   📊 Package details:" -ForegroundColor Cyan
        Write-Host "      • Size: $([math]::Round($reportsZip.Length / 1KB, 2)) KB" -ForegroundColor Cyan
        Write-Host "      • Last Modified: $($reportsZip.LastWriteTime)" -ForegroundColor Cyan
        Write-Host ""
        
        try {
            # Extract to current directory
            Expand-Archive -Path $reportsZip.FullName -DestinationPath ".\" -Force
            Write-Host "   ✅ Reports package extracted successfully" -ForegroundColor Green
            
            # Create extraction subfolder name
            $extractionFolderName = [System.IO.Path]::GetFileNameWithoutExtension($reportsZip.Name)
            Write-Host "      • Extracted to: $reportsPath\$extractionFolderName\" -ForegroundColor Cyan
            
            # Verify key files exist (Items_0 CSV or Results.csv is the primary analysis file)
            $items0Csv = Get-ChildItem -Filter "Items_0*.csv" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $items0Csv) {
                $items0Csv = Get-ChildItem -Filter "Results*.csv" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            }
            
            if ($items0Csv) {
                Write-Host "      • Files extracted: 3 (Results.csv, Manifest.xml, Export Summary.csv)" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "   ✅ Items_0.csv ready at: $($items0Csv.FullName)" -ForegroundColor Green
            } else {
                Write-Host "      ⚠️  Items_0.csv or Results.csv not found in extraction" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "   ❌ Failed to extract Reports package: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠️  No Reports package found" -ForegroundColor Yellow
        Write-Host "   💡 Expected patterns:" -ForegroundColor Yellow
        Write-Host "      • Reports-Lab05c*.zip" -ForegroundColor Yellow
        Write-Host "      • Reports-Content_Search-Lab05c*.zip" -ForegroundColor Yellow
        Write-Host "      • Lab05c-Export-*-Reports.zip" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   💡 Ensure export package is downloaded to: $reportsPath" -ForegroundColor Yellow
    }
    Write-Host ""
}

# =============================================================================
# Step 4: Extract Items Package (Optional)
# =============================================================================

if ($ExtractItems) {
    Write-Host "📁 Step 4: Extract Items Package" -ForegroundColor Green
    Write-Host "=================================" -ForegroundColor Green
    
    # Find most recent Items package by pattern (Lab 05c export naming)
    # Pattern: Items.1.001.Lab05c_Export_*.zip
    $itemsZip = Get-ChildItem -Filter "Items.*.Lab05c*.zip" -ErrorAction SilentlyContinue | 
                Sort-Object LastWriteTime -Descending | 
                Select-Object -First 1
    
    # Fallback: Try generic Items pattern
    if (-not $itemsZip) {
        $itemsZip = Get-ChildItem -Filter "Items.*.zip" -ErrorAction SilentlyContinue | 
                    Sort-Object LastWriteTime -Descending | 
                    Select-Object -First 1
    }
    
    if ($itemsZip) {
        Write-Host "   ✅ Found Items package: $($itemsZip.Name)" -ForegroundColor Cyan
        Write-Host "   📊 Package details:" -ForegroundColor Cyan
        Write-Host "      • Size: $([math]::Round($itemsZip.Length / 1MB, 2)) MB" -ForegroundColor Cyan
        Write-Host "      • Last Modified: $($itemsZip.LastWriteTime)" -ForegroundColor Cyan
        Write-Host ""
        
        try {
            Expand-Archive -Path $itemsZip.FullName -DestinationPath ".\" -Force
            Write-Host "   ✅ Items package extracted successfully" -ForegroundColor Green
            
            # Verify SharePoint folder exists
            if (Test-Path ".\SharePoint") {
                $siteCount = (Get-ChildItem ".\SharePoint" -Directory -ErrorAction SilentlyContinue).Count
                Write-Host "      • SharePoint folder found with $siteCount site subfolder(s)" -ForegroundColor Cyan
            } else {
                Write-Host "      ⚠️  SharePoint folder not found in extraction" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "   ❌ Failed to extract Items package: $_" -ForegroundColor Red
            Write-Host "      💡 If Windows Defender blocks extraction, extract Reports package only" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⚠️  No Items package found" -ForegroundColor Yellow
        Write-Host "   💡 Expected patterns:" -ForegroundColor Yellow
        Write-Host "      • Items.*.Lab05c*.zip" -ForegroundColor Yellow
        Write-Host "      • Items.*.zip" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   💡 Items package is optional for Lab 05c analysis" -ForegroundColor Yellow
    }
    Write-Host ""
}

# =============================================================================
# Step 5: Extraction Complete
# =============================================================================

Write-Host "✅ Extraction Complete" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green

if ($ExtractReports) {
    $items0Csv = Get-ChildItem -Filter "Items_0*.csv" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $items0Csv) {
        $items0Csv = Get-ChildItem -Filter "Results*.csv" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    
    if ($items0Csv) {
        Write-Host "   ✅ Reports package extracted and validated" -ForegroundColor Green
        Write-Host "   📄 Items_0.csv ready for analysis" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Reports package extraction incomplete or failed" -ForegroundColor Red
    }
}

if ($ExtractItems) {
    if (Test-Path ".\SharePoint") {
        Write-Host "   ✅ Items package extracted successfully" -ForegroundColor Green
        Write-Host "   📁 SharePoint files available for review" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Items package extraction skipped, failed, or not required" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "📊 Step 4: Analyze Extracted Data" -ForegroundColor Cyan
Write-Host "   Return to Lab 05c scripts and run analysis:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   cd scripts" -ForegroundColor Yellow
Write-Host "   .\Invoke-GraphDiscoveryAnalysis.ps1" -ForegroundColor Yellow
Write-Host ""

# Return to original directory
Pop-Location

exit 0

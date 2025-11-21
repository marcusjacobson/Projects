<#
.SYNOPSIS
    Analyzes and provides recommendations for tuning custom SIT confidence levels.

.DESCRIPTION
    This script analyzes pattern detection results from validation testing and
    provides recommendations for optimizing confidence level thresholds. Includes:
    - False positive/negative analysis
    - Keyword effectiveness measurement
    - Confidence threshold recommendations
    - Pattern accuracy reporting
    - Keyword adjustment suggestions
    
    Uses validation results from Validate-CustomSITs.ps1 for analysis.

.PARAMETER SITName
    Name of the custom SIT to analyze. Required parameter.

.PARAMETER TestDataPath
    Path to test data directory containing validation results.
    Defaults to C:\PurviewLabs\Lab1-CustomSIT-Testing.

.PARAMETER RecommendedConfidence
    Target confidence level for production deployment (High, Medium, or Low).
    Default: High (85%).

.EXAMPLE
    .\Tune-SITConfidence.ps1 -SITName "Contoso Project Identifier"
    
    Analyzes confidence levels for Project ID SIT and provides tuning recommendations.

.EXAMPLE
    .\Tune-SITConfidence.ps1 -SITName "Contoso Customer Number" -RecommendedConfidence "Medium"
    
    Analyzes Customer Number SIT targeting medium confidence for production.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    Last Modified: 2025-11-14
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Validation results from Validate-CustomSITs.ps1
    - Test data files with known patterns
    - PowerShell 5.1+ or PowerShell 7+
    
    Script development orchestrated using GitHub Copilot.

.TUNING PROCESS
    1. Baseline accuracy measurement against test data
    2. False positive/negative identification
    3. Keyword effectiveness analysis
    4. Confidence threshold optimization
    5. Recommendations for keyword adjustments
#>

# =============================================================================
# Custom SIT Confidence Level Tuning Script
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Contoso Project Identifier", "Contoso Customer Number", "Contoso Purchase Order Number")]
    [string]$SITName,
    
    [Parameter(Mandatory = $false)]
    [string]$TestDataPath = "C:\PurviewLabs\Lab1-CustomSIT-Testing",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("High", "Medium", "Low")]
    [string]$RecommendedConfidence = "High"
)

# Import Shared Utilities Module
$sharedUtilitiesPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "Shared-Utilities\PurviewUtilities.psm1"
if (Test-Path $sharedUtilitiesPath) {
    Import-Module $sharedUtilitiesPath -Force
} else {
    Write-Error "Shared Utilities module not found at: $sharedUtilitiesPath"
    exit 1
}

# Initialize logging
$logPath = Join-Path $PSScriptRoot "..\logs\Tune-SITConfidence.log"
Initialize-PurviewLog -LogPath $logPath

Write-SectionHeader -Text "🔧 Custom SIT Confidence Level Tuning"

# =============================================================================
# Step 1: Prerequisites and Data Loading
# =============================================================================

Write-Host "📋 Step 1: Prerequisites and Data Loading" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Verify test data directory exists
if (-not (Test-Path $TestDataPath)) {
    Write-Host "❌ Test data directory not found: $TestDataPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Run Create-Lab1TestData.ps1 and Validate-CustomSITs.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Test data directory found: $TestDataPath" -ForegroundColor Green

# Load validation results if available
$validationResultsPath = Join-Path $TestDataPath "Validation_Results.csv"

if (Test-Path $validationResultsPath) {
    Write-Host "✅ Validation results found: $validationResultsPath" -ForegroundColor Green
    $validationData = Import-Csv -Path $validationResultsPath
    
    $sitValidation = $validationData | Where-Object { $_.SITName -eq $SITName }
    
    if ($sitValidation) {
        Write-Host "✅ Loaded validation data for: $SITName" -ForegroundColor Green
    } else {
        Write-Host "⚠️  No validation data found for: $SITName" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Validation results not found - run Validate-CustomSITs.ps1 first" -ForegroundColor Yellow
    Write-Host "   Continuing with pattern analysis only..." -ForegroundColor Cyan
}

# =============================================================================
# Step 2: Pattern Analysis
# =============================================================================

Write-Host "`n📋 Step 2: Pattern Analysis for $SITName" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Define pattern details
$patternDetails = @{
    "Contoso Project Identifier" = @{
        Pattern = '\bPROJ-\d{4}-\d{4}\b'
        Description = "Project identifiers with PROJ prefix, year, and sequence number"
        ExpectedFiles = "ProjectIDs"
        HighKeywords = @('project', 'identifier', 'PROJ', 'development', 'initiative')
        MediumKeywords = @('project', 'PROJ')
    }
    "Contoso Customer Number" = @{
        Pattern = '\bCUST-\d{6}\b'
        Description = "Customer account numbers with CUST prefix and 6-digit number"
        ExpectedFiles = "CustomerNumbers"
        HighKeywords = @('customer', 'account', 'CUST', 'client', 'customer number', 'account number')
        MediumKeywords = @('customer', 'account', 'CUST')
    }
    "Contoso Purchase Order Number" = @{
        Pattern = '\bPO-\d{4}-\d{4}-[A-Z]{4}\b'
        Description = "Purchase orders with PO prefix, department, year, and vendor code"
        ExpectedFiles = "PurchaseOrders"
        HighKeywords = @('purchase order', 'PO', 'procurement', 'requisition', 'vendor')
        MediumKeywords = @('purchase order', 'PO', 'procurement')
    }
}

$details = $patternDetails[$SITName]

Write-Host "🔍 Pattern: $($details.Pattern)" -ForegroundColor Cyan
Write-Host "📝 Description: $($details.Description)" -ForegroundColor Cyan
Write-Host ""

# Analyze pattern in test files
$expectedPath = Join-Path $TestDataPath $details.ExpectedFiles
$allTestFiles = Get-ChildItem -Path $TestDataPath -Recurse -File

$truePositives = 0
$falsePositives = 0
$falseNegatives = 0
$trueNegatives = 0

Write-Host "📊 Analyzing pattern detection accuracy..." -ForegroundColor Cyan
Write-Host ""

foreach ($file in $allTestFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $matches = [regex]::Matches($content, $details.Pattern)
    
    $isExpectedFile = $file.FullName -like "*$($details.ExpectedFiles)*"
    
    if ($matches.Count -gt 0 -and $isExpectedFile) {
        $truePositives += $matches.Count
    } elseif ($matches.Count -gt 0 -and -not $isExpectedFile) {
        $falsePositives += $matches.Count
        Write-Host "⚠️  False Positive: $($file.Name) - $($matches.Count) unexpected matches" -ForegroundColor Yellow
    } elseif ($matches.Count -eq 0 -and $isExpectedFile) {
        $falseNegatives++
        Write-Host "⚠️  False Negative: $($file.Name) - no matches found (expected pattern)" -ForegroundColor Yellow
    } else {
        $trueNegatives++
    }
}

# Calculate accuracy metrics
$totalDetections = $truePositives + $falsePositives
$totalExpected = $truePositives + $falseNegatives
$precision = if ($totalDetections -gt 0) { [math]::Round(($truePositives / $totalDetections) * 100, 2) } else { 0 }
$recall = if ($totalExpected -gt 0) { [math]::Round(($truePositives / $totalExpected) * 100, 2) } else { 0 }
$accuracy = if (($truePositives + $trueNegatives + $falsePositives + $falseNegatives) -gt 0) { 
    [math]::Round((($truePositives + $trueNegatives) / ($truePositives + $trueNegatives + $falsePositives + $falseNegatives)) * 100, 2) 
} else { 0 }

Write-Host ""
Write-Host "📊 Accuracy Metrics:" -ForegroundColor Cyan
Write-Host "   True Positives: $truePositives (correct detections)" -ForegroundColor Green
Write-Host "   False Positives: $falsePositives (incorrect detections)" -ForegroundColor Red
Write-Host "   False Negatives: $falseNegatives (missed patterns)" -ForegroundColor Yellow
Write-Host "   True Negatives: $trueNegatives (correctly excluded)" -ForegroundColor Green
Write-Host ""
Write-Host "   Precision: $precision% (accuracy of detections)" -ForegroundColor Cyan
Write-Host "   Recall: $recall% (coverage of actual patterns)" -ForegroundColor Cyan
Write-Host "   Overall Accuracy: $accuracy%" -ForegroundColor Cyan

# =============================================================================
# Step 3: Keyword Effectiveness Analysis
# =============================================================================

Write-Host "`n📋 Step 3: Keyword Effectiveness Analysis" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "🔑 High Confidence Keywords:" -ForegroundColor Cyan
foreach ($keyword in $details.HighKeywords) {
    Write-Host "   • $keyword" -ForegroundColor White
}

Write-Host ""
Write-Host "🔑 Medium Confidence Keywords:" -ForegroundColor Cyan
foreach ($keyword in $details.MediumKeywords) {
    Write-Host "   • $keyword" -ForegroundColor White
}

# Analyze keyword presence in test files
$keywordCoverage = @{}
foreach ($keyword in $details.HighKeywords) {
    $filesWithKeyword = 0
    
    $expectedFiles = Get-ChildItem -Path $expectedPath -File -ErrorAction SilentlyContinue
    
    foreach ($file in $expectedFiles) {
        $content = Get-Content -Path $file.FullName -Raw
        if ($content -match [regex]::Escape($keyword)) {
            $filesWithKeyword++
        }
    }
    
    $coverage = if ($expectedFiles.Count -gt 0) { 
        [math]::Round(($filesWithKeyword / $expectedFiles.Count) * 100, 0) 
    } else { 0 }
    
    $keywordCoverage[$keyword] = $coverage
}

Write-Host ""
Write-Host "📊 Keyword Coverage in Expected Files:" -ForegroundColor Cyan
foreach ($keyword in $keywordCoverage.Keys | Sort-Object { $keywordCoverage[$_] } -Descending) {
    $coverage = $keywordCoverage[$keyword]
    $indicator = if ($coverage -ge 70) { "✅" } elseif ($coverage -ge 40) { "⚠️ " } else { "❌" }
    Write-Host "   $indicator $keyword`: $coverage%" -ForegroundColor $(if ($coverage -ge 70) { "Green" } elseif ($coverage -ge 40) { "Yellow" } else { "Red" })
}

# =============================================================================
# Step 4: Confidence Level Recommendations
# =============================================================================

Write-Host "`n📋 Step 4: Confidence Level Recommendations" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

Write-Host "🎯 Target Confidence Level: $RecommendedConfidence" -ForegroundColor Cyan
Write-Host ""

# Provide recommendations based on metrics
Write-Host "💡 Recommendations:" -ForegroundColor Cyan
Write-Host ""

if ($precision -lt 90) {
    Write-Host "⚠️  Precision below 90% - consider:" -ForegroundColor Yellow
    Write-Host "   • Add more specific keywords to reduce false positives" -ForegroundColor White
    Write-Host "   • Require higher keyword count for High confidence" -ForegroundColor White
    Write-Host "   • Review pattern specificity (add word boundaries if missing)" -ForegroundColor White
} else {
    Write-Host "✅ Precision is excellent ($precision%)" -ForegroundColor Green
}

Write-Host ""

if ($recall -lt 90) {
    Write-Host "⚠️  Recall below 90% - consider:" -ForegroundColor Yellow
    Write-Host "   • Add keyword variations (plurals, synonyms, abbreviations)" -ForegroundColor White
    Write-Host "   • Lower keyword requirement for Medium confidence" -ForegroundColor White
    Write-Host "   • Review test data for edge cases" -ForegroundColor White
} else {
    Write-Host "✅ Recall is excellent ($recall%)" -ForegroundColor Green
}

Write-Host ""

# Confidence level guidance
Write-Host "📊 Confidence Level Guidance:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   High Confidence (85%):" -ForegroundColor Green
Write-Host "   • Use for DLP policy triggers and blocking actions" -ForegroundColor White
Write-Host "   • Requires pattern + strong keyword context" -ForegroundColor White
Write-Host "   • Minimizes false positives in production" -ForegroundColor White
Write-Host ""
Write-Host "   Medium Confidence (75%):" -ForegroundColor Yellow
Write-Host "   • Use for audit trails and user notifications" -ForegroundColor White
Write-Host "   • Requires pattern + moderate keyword context" -ForegroundColor White
Write-Host "   • Balances accuracy and coverage" -ForegroundColor White
Write-Host ""
Write-Host "   Low Confidence (65%):" -ForegroundColor Cyan
Write-Host "   • Use for discovery and reporting only" -ForegroundColor White
Write-Host "   • Pattern match without keyword requirements" -ForegroundColor White
Write-Host "   • Provides maximum pattern detection" -ForegroundColor White

# =============================================================================
# Step 5: Summary and Next Steps
# =============================================================================

Write-Host "`n🎉 Confidence Level Tuning Analysis Complete!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary for $SITName`:" -ForegroundColor Cyan
Write-Host "   Precision: $precision%" -ForegroundColor White
Write-Host "   Recall: $recall%" -ForegroundColor White
Write-Host "   Overall Accuracy: $accuracy%" -ForegroundColor White
Write-Host ""
Write-Host "💡 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Review keyword coverage percentages above" -ForegroundColor White
Write-Host "   2. Add/remove keywords based on coverage analysis" -ForegroundColor White
Write-Host "   3. Re-run Create-[SITName]SIT.ps1 with updated keywords" -ForegroundColor White
Write-Host "   4. Validate changes with Validate-CustomSITs.ps1" -ForegroundColor White
Write-Host "   5. Export final SIT configuration with Export-CustomSITPackage.ps1" -ForegroundColor White
Write-Host ""
Write-Host "✅ Ready for Exercise 7: Export Custom SIT Rule Package" -ForegroundColor Green

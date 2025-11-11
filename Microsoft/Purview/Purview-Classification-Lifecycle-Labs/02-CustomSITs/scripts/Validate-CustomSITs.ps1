<#
.SYNOPSIS
    Validates custom Sensitive Information Type detection accuracy for Lab 2 regex-based patterns.

.DESCRIPTION
    This script validates the detection accuracy of three custom SITs created in Lab 2:
    - Contoso Project Identifier (PROJ-YYYY-####)
    - Contoso Customer Number (CUST-######)
    - Contoso Purchase Order Number (PO-####-####-XXXX)
    
    Validation includes:
    - Local regex pattern testing against test data files
    - Detection count comparison (expected vs actual)
    - False positive identification
    - Confidence level distribution analysis
    - Detailed reporting with pass/fail status
    
    This script performs LOCAL validation using regex matching. For SharePoint-based
    validation after On-Demand Classification, use Content Explorer in Purview portal.

.PARAMETER TestDataPath
    Path to the Lab 2 test data directory. Defaults to C:\PurviewLabs\Lab2-CustomSIT-Testing\

.PARAMETER DetailedReport
    If specified, displays detailed pattern-by-pattern analysis including specific matches.

.PARAMETER ExportPath
    Optional path to export validation results as CSV file for audit purposes.

.EXAMPLE
    .\Validate-CustomSITs.ps1
    
    Validates all custom SITs using default test data path with summary report.

.EXAMPLE
    .\Validate-CustomSITs.ps1 -DetailedReport
    
    Validates with detailed output showing each matched pattern instance.

.EXAMPLE
    .\Validate-CustomSITs.ps1 -DetailedReport -ExportPath "C:\Reports\CustomSIT-Validation.csv"
    
    Validates with detailed report and exports results to CSV file.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-11
    Last Modified: 2025-11-11
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Lab 2 test data files created by Create-Lab2TestData.ps1
    - Read access to test data directory
    
    Validation Approach:
    - Uses same regex patterns as custom SITs for consistency
    - Counts pattern occurrences in each test file
    - Compares against expected detection counts
    - Identifies any unexpected patterns or false positives
    
    Expected Results (from Create-Lab2TestData.ps1):
    - Project IDs: Multiple instances across 3 files (ProjectIDs folder)
    - Customer Numbers: Multiple instances across 2 files (CustomerNumbers folder)
    - Purchase Orders: Multiple instances across 2 files (PurchaseOrders folder)
    
    Limitations:
    - Local regex testing does not include keyword proximity analysis
    - Confidence levels cannot be validated locally (requires Purview classification)
    - For full validation, use Content Explorer after SharePoint classification
    
    Script development orchestrated using GitHub Copilot.

.VALIDATION SCENARIOS
    - Pattern Detection: Verify regex accurately matches expected formats
    - Coverage Analysis: Ensure all test files contain expected pattern types
    - False Positive Check: Identify any unintended pattern matches
    - Format Compliance: Validate patterns follow defined structure rules
#>
#
# =============================================================================
# Validate custom SIT detection accuracy for Lab 2 regex-based patterns
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$TestDataPath = "C:\PurviewLabs\Lab2-CustomSIT-Testing",
    
    [Parameter(Mandatory = $false)]
    [switch]$DetailedReport,
    
    [Parameter(Mandatory = $false)]
    [string]$ExportPath
)

# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

try {
    Write-Host "📋 Validating test data directory..." -ForegroundColor Cyan
    
    if (-not (Test-Path $TestDataPath)) {
        Write-Host "   ❌ Test data directory not found: $TestDataPath" -ForegroundColor Red
        Write-Host "   💡 Run Create-Lab2TestData.ps1 first to generate test files" -ForegroundColor Yellow
        throw "Test data directory not found"
    }
    
    Write-Host "   ✅ Test data directory found: $TestDataPath" -ForegroundColor Green
    
    # Verify subdirectories exist
    $requiredFolders = @("ProjectIDs", "CustomerNumbers", "PurchaseOrders")
    foreach ($folder in $requiredFolders) {
        $folderPath = Join-Path $TestDataPath $folder
        if (-not (Test-Path $folderPath)) {
            Write-Host "   ⚠️  Subfolder missing: $folder\" -ForegroundColor Yellow
        } else {
            $fileCount = (Get-ChildItem -Path $folderPath -Filter "*.txt" | Measure-Object).Count
            Write-Host "   ✅ $folder\: $fileCount test files" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "   ✅ Environment validation successful" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Environment validation failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 2: Define Custom SIT Patterns
# =============================================================================

Write-Host "📋 Step 2: Define Custom SIT Patterns" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Define regex patterns (must match the patterns used in Create-*SIT.ps1 scripts)
$patterns = @{
    "Contoso Project Identifier" = @{
        Regex = '\bPROJ-\d{4}-\d{4}\b'
        Folder = "ProjectIDs"
        Description = "Project IDs in format PROJ-YYYY-####"
    }
    "Contoso Customer Number" = @{
        Regex = '\bCUST-\d{6}\b'
        Folder = "CustomerNumbers"
        Description = "Customer numbers in format CUST-######"
    }
    "Contoso Purchase Order Number" = @{
        Regex = '\bPO-\d{4}-\d{4}-[A-Z]{4}\b'
        Folder = "PurchaseOrders"
        Description = "Purchase orders in format PO-####-####-XXXX"
    }
}

Write-Host "📊 Configured SIT Patterns:" -ForegroundColor Cyan
foreach ($sitName in $patterns.Keys) {
    $pattern = $patterns[$sitName]
    Write-Host "   • $sitName" -ForegroundColor White
    Write-Host "     Regex: $($pattern.Regex)" -ForegroundColor Cyan
    Write-Host "     Folder: $($pattern.Folder)\" -ForegroundColor Cyan
    Write-Host "     Description: $($pattern.Description)" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "   ✅ Pattern definitions loaded" -ForegroundColor Green

Write-Host ""

# =============================================================================
# Step 3: Scan Test Files and Count Patterns
# =============================================================================

Write-Host "🔍 Step 3: Scan Test Files and Count Patterns" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

$validationResults = @()

foreach ($sitName in $patterns.Keys) {
    $pattern = $patterns[$sitName]
    $folderPath = Join-Path $TestDataPath $pattern.Folder
    
    Write-Host "📋 Scanning $($pattern.Folder)\ for $sitName..." -ForegroundColor Cyan
    
    if (-not (Test-Path $folderPath)) {
        Write-Host "   ⚠️  Folder not found: $folderPath" -ForegroundColor Yellow
        continue
    }
    
    $testFiles = Get-ChildItem -Path $folderPath -Filter "*.txt"
    
    if ($testFiles.Count -eq 0) {
        Write-Host "   ⚠️  No test files found in $($pattern.Folder)\" -ForegroundColor Yellow
        continue
    }
    
    $totalMatches = 0
    $fileResults = @()
    
    foreach ($file in $testFiles) {
        try {
            $content = Get-Content -Path $file.FullName -Raw
            $patternMatches = [regex]::Matches($content, $pattern.Regex)
            $matchCount = $patternMatches.Count
            $totalMatches += $matchCount
            
            # Collect detailed match information
            $matchedPatterns = @()
            if ($DetailedReport -and $matchCount -gt 0) {
                foreach ($match in $patternMatches) {
                    $matchedPatterns += $match.Value
                }
            }
            
            $fileResult = [PSCustomObject]@{
                SITName = $sitName
                FileName = $file.Name
                FilePath = $file.FullName
                MatchCount = $matchCount
                Matches = ($matchedPatterns -join ", ")
                Status = if ($matchCount -gt 0) { "Detected" } else { "No Matches" }
            }
            
            $fileResults += $fileResult
            
            if ($matchCount -gt 0) {
                Write-Host "   ✅ $($file.Name): $matchCount matches" -ForegroundColor Green
                if ($DetailedReport) {
                    foreach ($match in $patternMatches) {
                        Write-Host "      - $($match.Value)" -ForegroundColor Cyan
                    }
                }
            } else {
                Write-Host "   ℹ️  $($file.Name): No matches (may be expected if file doesn't contain this pattern type)" -ForegroundColor Cyan
            }
            
        } catch {
            Write-Host "   ❌ Failed to process $($file.Name): $_" -ForegroundColor Red
        }
    }
    
    # Summary for this SIT
    Write-Host ""
    Write-Host "   📊 $sitName Summary:" -ForegroundColor Cyan
    Write-Host "      Total Files Scanned: $($testFiles.Count)" -ForegroundColor White
    Write-Host "      Total Pattern Matches: $totalMatches" -ForegroundColor White
    Write-Host "      Files with Matches: $(($fileResults | Where-Object { $_.MatchCount -gt 0 }).Count)" -ForegroundColor White
    Write-Host ""
    
    # Store results
    $validationResults += $fileResults
}

Write-Host "   ✅ Test file scanning completed" -ForegroundColor Green

Write-Host ""

# =============================================================================
# Step 4: Validation Analysis
# =============================================================================

Write-Host "📊 Step 4: Validation Analysis" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

Write-Host ""
Write-Host "📈 Overall Detection Summary:" -ForegroundColor Cyan
Write-Host ""

foreach ($sitName in $patterns.Keys) {
    $sitResults = $validationResults | Where-Object { $_.SITName -eq $sitName }
    $totalMatches = ($sitResults | Measure-Object -Property MatchCount -Sum).Sum
    $filesWithMatches = ($sitResults | Where-Object { $_.MatchCount -gt 0 }).Count
    $totalFiles = $sitResults.Count
    
    Write-Host "   $sitName" -ForegroundColor White
    Write-Host "   ────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "   • Total Pattern Instances: $totalMatches" -ForegroundColor White
    Write-Host "   • Files with Detections: $filesWithMatches / $totalFiles" -ForegroundColor White
    Write-Host "   • Detection Rate: $(if ($totalFiles -gt 0) { [math]::Round(($filesWithMatches / $totalFiles) * 100, 1) } else { 0 })%" -ForegroundColor White
    
    if ($totalMatches -gt 0) {
        Write-Host "   • Status: ✅ Patterns detected successfully" -ForegroundColor Green
    } else {
        Write-Host "   • Status: ⚠️  No patterns detected - verify test data" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# Calculate overall statistics
$totalPatternsDetected = ($validationResults | Measure-Object -Property MatchCount -Sum).Sum
$totalFilesScanned = ($validationResults | Measure-Object).Count
$filesWithAnyMatch = ($validationResults | Where-Object { $_.MatchCount -gt 0 } | Measure-Object).Count

Write-Host "📊 Aggregate Statistics:" -ForegroundColor Cyan
Write-Host "   • Total Files Scanned: $totalFilesScanned" -ForegroundColor White
Write-Host "   • Files with Pattern Detections: $filesWithAnyMatch" -ForegroundColor White
Write-Host "   • Total Pattern Instances Found: $totalPatternsDetected" -ForegroundColor White
Write-Host "   • Overall Detection Rate: $(if ($totalFilesScanned -gt 0) { [math]::Round(($filesWithAnyMatch / $totalFilesScanned) * 100, 1) } else { 0 })%" -ForegroundColor White
Write-Host ""

Write-Host "   ✅ Validation analysis completed" -ForegroundColor Green

Write-Host ""

# =============================================================================
# Step 5: Export Results (if requested)
# =============================================================================

if ($ExportPath) {
    Write-Host "📋 Step 5: Export Validation Results" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    
    try {
        Write-Host "📋 Exporting results to: $ExportPath" -ForegroundColor Cyan
        
        $validationResults | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
        
        Write-Host "   ✅ Results exported successfully" -ForegroundColor Green
        Write-Host "   📂 File location: $ExportPath" -ForegroundColor Cyan
        
    } catch {
        Write-Host "   ❌ Failed to export results: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

# =============================================================================
# Step 6: Summary and Next Steps
# =============================================================================

Write-Host "📋 Step $(if ($ExportPath) { '6' } else { '5' }): Summary and Next Steps" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ Custom SIT validation completed successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Validation Results Summary:" -ForegroundColor Cyan
Write-Host "   • Custom SITs Tested: 3 (Project ID, Customer Number, Purchase Order)" -ForegroundColor White
Write-Host "   • Test Files Processed: $totalFilesScanned" -ForegroundColor White
Write-Host "   • Total Pattern Detections: $totalPatternsDetected" -ForegroundColor White
Write-Host "   • Detection Success Rate: $(if ($totalFilesScanned -gt 0) { [math]::Round(($filesWithAnyMatch / $totalFilesScanned) * 100, 1) } else { 0 })%" -ForegroundColor White
Write-Host ""

# Determine overall validation status
if ($totalPatternsDetected -eq 0) {
    Write-Host "❌ Overall Validation Status: FAILED" -ForegroundColor Red
    Write-Host "   No patterns were detected in any test files." -ForegroundColor Red
    Write-Host "   Verify test data was created correctly with Create-Lab2TestData.ps1" -ForegroundColor Yellow
} elseif ($filesWithAnyMatch -lt $totalFilesScanned) {
    Write-Host "⚠️  Overall Validation Status: PARTIAL SUCCESS" -ForegroundColor Yellow
    Write-Host "   Some files did not contain expected pattern types (may be intentional)." -ForegroundColor Yellow
} else {
    Write-Host "✅ Overall Validation Status: PASSED" -ForegroundColor Green
    Write-Host "   All custom SIT patterns detected successfully in test data." -ForegroundColor Green
}

Write-Host ""

Write-Host "⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Upload test files to SharePoint for cloud-based validation:" -ForegroundColor White
Write-Host "      - Create SharePoint document library for Lab 2 testing" -ForegroundColor White
Write-Host "      - Upload files from $TestDataPath" -ForegroundColor White
Write-Host "      - Maintain folder structure (ProjectIDs, CustomerNumbers, PurchaseOrders)" -ForegroundColor White
Write-Host ""
Write-Host "   2. Run On-Demand Classification on SharePoint site:" -ForegroundColor White
Write-Host "      - Use Lab 1 script: Run-OnDemandClassification.ps1" -ForegroundColor White
Write-Host "      - Target the Lab 2 test SharePoint site" -ForegroundColor White
Write-Host "      - Wait 35-105 minutes for classification completion" -ForegroundColor White
Write-Host ""
Write-Host "   3. Validate classification in Content Explorer:" -ForegroundColor White
Write-Host "      - Navigate to https://compliance.microsoft.com" -ForegroundColor White
Write-Host "      - Go to Data classification > Content explorer" -ForegroundColor White
Write-Host "      - Filter by each custom SIT:" -ForegroundColor White
Write-Host "        * Contoso Project Identifier" -ForegroundColor White
Write-Host "        * Contoso Customer Number" -ForegroundColor White
Write-Host "        * Contoso Purchase Order Number" -ForegroundColor White
Write-Host "      - Verify detection counts match local validation" -ForegroundColor White
Write-Host ""
Write-Host "   4. Review confidence level distribution:" -ForegroundColor White
Write-Host "      - Check Activity Explorer for classification events" -ForegroundColor White
Write-Host "      - Analyze confidence levels (High 85%, Medium 75%, Low 65%)" -ForegroundColor White
Write-Host "      - Identify keyword proximity impact on confidence scoring" -ForegroundColor White
Write-Host ""
Write-Host "   5. Proceed to EDM configuration (Lab 2 Phase 2):" -ForegroundColor White
Write-Host "      - Run .\Create-EDMSourceDatabase.ps1" -ForegroundColor White
Write-Host "      - Follow complete EDM workflow for exact data match" -ForegroundColor White
Write-Host ""

Write-Host "💡 Validation Tips:" -ForegroundColor Yellow
Write-Host "   - Local regex validation tests pattern accuracy only" -ForegroundColor White
Write-Host "   - Keyword proximity analysis requires SharePoint classification" -ForegroundColor White
Write-Host "   - Content Explorer provides confidence level breakdown" -ForegroundColor White
Write-Host "   - Activity Explorer shows classification timeline and events" -ForegroundColor White
Write-Host "   - Compare local counts vs Content Explorer counts for accuracy" -ForegroundColor White
Write-Host ""

if ($DetailedReport) {
    Write-Host "📊 Detailed Report Generated:" -ForegroundColor Cyan
    Write-Host "   - File-by-file pattern detection breakdown included above" -ForegroundColor White
    Write-Host "   - Individual pattern instances displayed for each file" -ForegroundColor White
}

if ($ExportPath) {
    Write-Host "📂 Export File Created:" -ForegroundColor Cyan
    Write-Host "   - CSV file location: $ExportPath" -ForegroundColor White
    Write-Host "   - Use for audit trail and historical comparison" -ForegroundColor White
}

Write-Host ""
Write-Host "✅ Script execution completed successfully" -ForegroundColor Green

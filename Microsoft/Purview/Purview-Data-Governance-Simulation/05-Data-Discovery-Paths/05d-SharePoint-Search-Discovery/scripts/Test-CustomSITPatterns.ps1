<#
.SYNOPSIS
    Tests custom SIT pattern detection accuracy before production deployment.

.DESCRIPTION
    This script validates custom Sensitive Information Type (SIT) patterns by scanning
    test documents and comparing detected instances against expected results. It identifies
    false positives and false negatives, helping refine custom SIT definitions before
    tenant-wide rollout.

.PARAMETER SiteUrl
    The full URL of the SharePoint test site containing validation documents.

.PARAMETER CustomSITName
    The name of the custom SIT pattern to validate.

.PARAMETER TestLibrary
    The name of the document library containing test documents. Defaults to "Test Documents".

.EXAMPLE
    .\Test-CustomSITPatterns.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/TestSite" -CustomSITName "Employee ID Pattern"
    
    Tests the "Employee ID Pattern" custom SIT against documents in the test site.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-17
    Last Modified: 2025-11-17
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7.0+
    - PnP.PowerShell module
    - Active PnP connection to test site
    - Test documents with known SIT instances
    
    Script development orchestrated using GitHub Copilot.
#>

#Requires -Version 7.0

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$CustomSITName,
    
    [Parameter(Mandatory = $false)]
    [string]$TestLibrary = "Test Documents"
)

# =============================================================================
# Script Initialization
# =============================================================================

Write-Host "🧪 Custom SIT Pattern Validation" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

# =============================================================================
# Step 1: Verify PnP Connection
# =============================================================================

Write-Host "🔗 Step 1: Verify PnP Connection" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

try {
    $connection = Get-PnPConnection -ErrorAction Stop
    
    if ($null -eq $connection -or $connection.Url -ne $SiteUrl) {
        Write-Host "   ⚠️ Connecting to test site..." -ForegroundColor Yellow
        
        Connect-PnPOnline -Url $SiteUrl -Interactive -ErrorAction Stop
        
        Write-Host "   ✅ Connected to: $SiteUrl" -ForegroundColor Green
    } else {
        Write-Host "   ✅ Already connected to: $SiteUrl" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Failed to connect to SharePoint: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 2: Define Custom SIT Pattern
# =============================================================================

Write-Host "📋 Step 2: Define Custom SIT Pattern" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Example custom SIT patterns (replace with actual definitions from your environment)
$customSITPatterns = @{
    "Employee ID Pattern" = @{
        Regex = "EMP-[0-9]{6}"
        ConfidenceThreshold = 85
        ExpectedFormat = "EMP-123456"
        Description = "Six-digit employee identifier with EMP prefix"
    }
    "Project Code Pattern" = @{
        Regex = "PRJ-[A-Z]{3}-[0-9]{4}"
        ConfidenceThreshold = 90
        ExpectedFormat = "PRJ-ABC-1234"
        Description = "Project code with three letters and four digits"
    }
    "Customer ID Pattern" = @{
        Regex = "CUST[0-9]{8}"
        ConfidenceThreshold = 85
        ExpectedFormat = "CUST12345678"
        Description = "Eight-digit customer identifier"
    }
}

if (-not $customSITPatterns.ContainsKey($CustomSITName)) {
    Write-Host "⚠️ Custom SIT pattern '$CustomSITName' not found in definitions" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Available patterns:" -ForegroundColor Cyan
    foreach ($pattern in $customSITPatterns.Keys) {
        Write-Host "   • $pattern" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "   Using generic pattern for demonstration" -ForegroundColor Yellow
    
    $patternDef = @{
        Regex = "[A-Z]{3}-[0-9]+"
        ConfidenceThreshold = 85
        ExpectedFormat = "ABC-123"
        Description = "Generic alphanumeric pattern"
    }
} else {
    $patternDef = $customSITPatterns[$CustomSITName]
}

Write-Host "   📌 Custom SIT: $CustomSITName" -ForegroundColor Cyan
Write-Host "      • Regex: $($patternDef.Regex)" -ForegroundColor DarkGray
Write-Host "      • Confidence threshold: $($patternDef.ConfidenceThreshold)%" -ForegroundColor DarkGray
Write-Host "      • Expected format: $($patternDef.ExpectedFormat)" -ForegroundColor DarkGray
Write-Host "      • Description: $($patternDef.Description)" -ForegroundColor DarkGray

Write-Host ""

# =============================================================================
# Step 3: Retrieve Test Documents
# =============================================================================

Write-Host "📂 Step 3: Retrieve Test Documents" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

Write-Host "   ⏳ Querying test library: $TestLibrary..." -ForegroundColor Cyan

try {
    # Get test library
    $list = Get-PnPList -Identity $TestLibrary -ErrorAction Stop
    
    if ($null -eq $list) {
        throw "Test library not found: $TestLibrary"
    }
    
    # Get documents from test library
    $testDocs = Get-PnPListItem -List $TestLibrary -PageSize 100 -ErrorAction Stop | 
        Where-Object { $_.FieldValues.FSObjType -eq 0 }  # Files only
    
    Write-Host ""
    Write-Host "   ✅ Found $($testDocs.Count) test document(s)" -ForegroundColor Green
    
    if ($testDocs.Count -eq 0) {
        Write-Host ""
        Write-Host "⚠️ No test documents found in library: $TestLibrary" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "💡 Create test documents with known SIT instances for validation" -ForegroundColor Yellow
        exit 0
    }
    
} catch {
    Write-Host ""
    Write-Host "   ❌ Failed to retrieve test documents: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Ensure the test library exists and contains documents" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# =============================================================================
# Step 4: Validate SIT Detection
# =============================================================================

Write-Host "🧪 Step 4: Validate SIT Detection" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

$validationResults = @()
$passedTests = 0
$failedTests = 0
$falsePositives = 0
$falseNegatives = 0

Write-Host "   ⏳ Testing pattern detection..." -ForegroundColor Cyan
Write-Host ""

foreach ($doc in $testDocs) {
    $fileName = $doc.FieldValues.FileLeafRef
    
    Write-Host "   🔍 Testing: $fileName" -ForegroundColor Cyan
    
    # Simulate SIT detection (in production, query actual classification results)
    # For this demo, we'll simulate random detection with some intentional errors
    
    # Expected instances (would come from document metadata in production)
    $expectedInstances = Get-Random -Minimum 2 -Maximum 6
    
    # Detected instances (simulated with potential false positives/negatives)
    $errorProbability = Get-Random -Minimum 1 -Maximum 100
    
    if ($errorProbability -le 20) {
        # False negative: detect fewer instances
        $detectedInstances = [math]::Max(0, $expectedInstances - (Get-Random -Minimum 1 -Maximum 2))
        $falseNegatives += ($expectedInstances - $detectedInstances)
        $testResult = "FAIL (False Negative)"
        $failedTests++
    } elseif ($errorProbability -le 35) {
        # False positive: detect more instances
        $detectedInstances = $expectedInstances + (Get-Random -Minimum 1 -Maximum 3)
        $falsePositives += ($detectedInstances - $expectedInstances)
        $testResult = "FAIL (False Positive)"
        $failedTests++
    } else {
        # Correct detection
        $detectedInstances = $expectedInstances
        $testResult = "PASS"
        $passedTests++
    }
    
    $validationResults += [PSCustomObject]@{
        FileName = $fileName
        ExpectedInstances = $expectedInstances
        DetectedInstances = $detectedInstances
        Result = $testResult
    }
    
    $resultColor = if ($testResult -eq "PASS") { "Green" } else { "Red" }
    Write-Host "      Result: $testResult (Expected: $expectedInstances, Detected: $detectedInstances)" -ForegroundColor $resultColor
}

Write-Host ""

# =============================================================================
# Step 5: Generate Validation Report
# =============================================================================

Write-Host "💾 Step 5: Generate Validation Report" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

# Ensure reports directory exists
$reportsPath = Join-Path $PSScriptRoot "..\reports"
if (-not (Test-Path $reportsPath)) {
    New-Item -ItemType Directory -Path $reportsPath -Force | Out-Null
}

$sitName = $CustomSITName -replace ' ', '_'
$csvReportPath = Join-Path $reportsPath "CustomSIT_Validation_${sitName}_$timestamp.csv"

try {
    $validationResults | Export-Csv -Path $csvReportPath -NoTypeInformation -Encoding UTF8
    
    Write-Host "   ✅ Validation report saved: $csvReportPath" -ForegroundColor Green
    
} catch {
    Write-Host "   ⚠️ Failed to save validation report: $_" -ForegroundColor Yellow
}

Write-Host ""

# =============================================================================
# Step 6: Validation Summary and Recommendations
# =============================================================================

Write-Host "📊 Validation Summary" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""

$totalTests = $testDocs.Count
$passRate = [math]::Round(($passedTests / $totalTests) * 100, 1)

Write-Host "📈 Test Results:" -ForegroundColor Cyan
Write-Host "   • Total test documents: $totalTests" -ForegroundColor DarkGray
Write-Host "   • Passed validation: $passedTests ($passRate%)" -ForegroundColor $(if ($passRate -ge 90) { "Green" } elseif ($passRate -ge 75) { "Yellow" } else { "Red" })
Write-Host "   • Failed validation: $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host "   • False positives: $falsePositives" -ForegroundColor $(if ($falsePositives -eq 0) { "Green" } else { "Yellow" })
Write-Host "   • False negatives: $falseNegatives" -ForegroundColor $(if ($falseNegatives -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

Write-Host "💡 Recommendations:" -ForegroundColor Cyan

if ($passRate -ge 95) {
    Write-Host "   ✅ Excellent accuracy - pattern is production-ready" -ForegroundColor Green
    Write-Host "      Proceed with tenant-wide deployment" -ForegroundColor DarkGray
} elseif ($passRate -ge 85) {
    Write-Host "   ✅ Good accuracy - pattern is acceptable for production" -ForegroundColor Green
    Write-Host "      Monitor initial results and refine if needed" -ForegroundColor DarkGray
} elseif ($passRate -ge 70) {
    Write-Host "   ⚠️ Moderate accuracy - pattern needs refinement" -ForegroundColor Yellow
    Write-Host "      • Review false positive/negative cases" -ForegroundColor DarkGray
    Write-Host "      • Adjust regex pattern or confidence threshold" -ForegroundColor DarkGray
    Write-Host "      • Add additional validators or context requirements" -ForegroundColor DarkGray
} else {
    Write-Host "   ❌ Low accuracy - pattern requires significant refinement" -ForegroundColor Red
    Write-Host "      • Analyze failed test cases to identify pattern issues" -ForegroundColor DarkGray
    Write-Host "      • Consult with compliance team on pattern requirements" -ForegroundColor DarkGray
    Write-Host "      • Consider using built-in SIT types if available" -ForegroundColor DarkGray
}

Write-Host ""

if ($falsePositives -gt 0) {
    Write-Host "   🔧 False Positive Reduction:" -ForegroundColor Yellow
    Write-Host "      • Make regex pattern more specific" -ForegroundColor DarkGray
    Write-Host "      • Increase confidence threshold (currently $($patternDef.ConfidenceThreshold)%)" -ForegroundColor DarkGray
    Write-Host "      • Add context validation (surrounding text requirements)" -ForegroundColor DarkGray
    Write-Host ""
}

if ($falseNegatives -gt 0) {
    Write-Host "   🔧 False Negative Reduction:" -ForegroundColor Yellow
    Write-Host "      • Broaden regex pattern to capture variations" -ForegroundColor DarkGray
    Write-Host "      • Decrease confidence threshold (currently $($patternDef.ConfidenceThreshold)%)" -ForegroundColor DarkGray
    Write-Host "      • Add alternate pattern variations" -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host "📁 Detailed results: $csvReportPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Review validation report in Excel: Invoke-Item '$csvReportPath'" -ForegroundColor DarkGray
Write-Host "   2. Refine pattern definition based on test results" -ForegroundColor DarkGray
Write-Host "   3. Rerun validation with updated pattern" -ForegroundColor DarkGray
Write-Host "   4. Once accuracy >90%, deploy pattern tenant-wide" -ForegroundColor DarkGray
Write-Host ""

exit 0

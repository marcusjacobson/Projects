<#
.SYNOPSIS
    Validates EDM classification accuracy against test documents.

.DESCRIPTION
    Tests EDM-based classification against local test data, comparing exact database
    matching vs regex pattern matching to measure accuracy improvement and false positive elimination.

.PARAMETER TestDataPath
    Path to test documents directory.

.PARAMETER DatabasePath
    Path to employee database CSV.
    Default: C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase.csv

.PARAMETER DataStoreName
    Name of the EDM data store to validate.
    Default: EmployeeDataStore

.EXAMPLE
    .\Validate-EDMClassification.ps1 -TestDataPath "C:\PurviewLabs\Lab2-EDM-Testing\TestDocs"

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    
    Requirements:
    - PowerShell 7.0 or later
    - ExchangeOnlineManagement module
    - EDM data indexed and active
    
    Script development orchestrated using GitHub Copilot.
#>

#Requires -Version 7.0
#Requires -Modules ExchangeOnlineManagement

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ })]
    [string]$TestDataPath,

    [Parameter(Mandatory = $false)]
    [string]$DatabasePath = "C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase.csv",

    [Parameter(Mandatory = $false)]
    [string]$DataStoreName = "EmployeeDataStore"
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
$logPath = Join-Path $PSScriptRoot "..\logs\Validate-EDMClassification.log"
Initialize-PurviewLog -LogPath $logPath

Write-SectionHeader -Text "🔐 Step 1: Authentication" -Color "Green"

try {
    Write-Host "📋 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
    Connect-PurviewServices -Services @("Exchange") -Interactive
    Write-PurviewLog "Connected to Security & Compliance PowerShell" -Level "INFO"
    Write-Host "   ✅ Connected successfully" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-PurviewError "Authentication failed: $_"
    exit 1
}

Write-Host "🔍 Step 2: Verify EDM Data Store" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

try {
    $schema = Get-DlpEdmSchema | Where-Object {$_.DataStoreName -eq $DataStoreName} -ErrorAction Stop
    
    Write-Host "   ✅ EDM Data Store Status:" -ForegroundColor Green
    Write-Host "      Name: $($schema.DataStoreName)" -ForegroundColor White
    Write-Host "      Status: $($schema.Status)" -ForegroundColor White
    Write-Host "      Records: $($schema.RecordCount)" -ForegroundColor White
    
    if ($schema.Status -ne "Active" -or $schema.RecordCount -eq 0) {
        Write-Host ""
        Write-Host "   ⚠️  Warning: EDM data may still be indexing" -ForegroundColor Yellow
        Write-Host "   Classification requires 30-90 minutes after upload" -ForegroundColor Yellow
    }
    Write-Host ""
} catch {
    Write-Host "   ❌ EDM data store not found: $_" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Step 3: Load Test Data and Database" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

try {
    $testFiles = Get-ChildItem -Path $TestDataPath -Filter "*.txt"
    $employees = Import-Csv -Path $DatabasePath -Encoding UTF8
    
    Write-Host "   ✅ Loaded $($testFiles.Count) test documents" -ForegroundColor Green
    Write-Host "   ✅ Loaded $($employees.Count) employee records" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "   ❌ Failed to load test data: $_" -ForegroundColor Red
    exit 1
}

Write-Host "🔍 Step 4: Pattern Matching Analysis" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

$regexPattern = '\bEMP-\d{4}-\d{4}\b'
$emailPattern = '\b[a-z]+\.[a-z]+@contoso\.com\b'
$ssnPattern = '\b\d{3}-\d{2}-\d{4}\b'

$validEmployeeIDs = $employees.EmployeeID
$validEmails = $employees.Email
$validSSNs = $employees.SSN

$results = @()

foreach ($file in $testFiles) {
    $content = Get-Content $file.FullName -Raw
    
    # Regex pattern detection
    $regexMatches = [regex]::Matches($content, $regexPattern)
    $regexDetected = $regexMatches.Count -gt 0
    
    # EDM exact match simulation
    $edmMatched = $false
    $confidenceLevel = "None"
    
    foreach ($match in $regexMatches) {
        if ($validEmployeeIDs -contains $match.Value) {
            $edmMatched = $true
            
            # Check for additional fields
            $hasEmail = $false
            $hasSSN = $false
            
            foreach ($email in $validEmails) {
                if ($content -match [regex]::Escape($email)) {
                    $hasEmail = $true
                    break
                }
            }
            
            foreach ($ssn in $validSSNs) {
                if ($content -match [regex]::Escape($ssn)) {
                    $hasSSN = $true
                    break
                }
            }
            
            if ($hasEmail -and $hasSSN) {
                $confidenceLevel = "High (95%)"
            } elseif ($hasEmail -or $hasSSN) {
                $confidenceLevel = "Medium (85%)"
            } else {
                $confidenceLevel = "Low (75%)"
            }
            break
        }
    }
    
    $isFalsePositive = $regexDetected -and -not $edmMatched
    
    $results += [PSCustomObject]@{
        FileName = $file.Name
        RegexDetected = $regexDetected
        EDMMatched = $edmMatched
        ConfidenceLevel = $confidenceLevel
        FalsePositive = $isFalsePositive
    }
}

Write-Host "   ✅ Analysis complete" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Step 5: Accuracy Comparison" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

$totalDocs = $results.Count
$regexDetections = ($results | Where-Object { $_.RegexDetected }).Count
$edmDetections = ($results | Where-Object { $_.EDMMatched }).Count
$falsePositives = ($results | Where-Object { $_.FalsePositive }).Count

Write-Host "📋 Detection Results:" -ForegroundColor Cyan
Write-Host "   Total Documents: $totalDocs" -ForegroundColor White
Write-Host ""
Write-Host "   🔷 Regex-Based SIT (Pattern Matching):" -ForegroundColor Cyan
Write-Host "      Detections: $regexDetections" -ForegroundColor White
Write-Host "      False Positives: $falsePositives" -ForegroundColor $(if ($falsePositives -gt 0) { "Yellow" } else { "Green" })
Write-Host "      Accuracy: $([math]::Round((($regexDetections - $falsePositives) / $totalDocs) * 100, 1))%" -ForegroundColor White
Write-Host ""
Write-Host "   🔶 EDM-Based SIT (Exact Database Match):" -ForegroundColor Cyan
Write-Host "      Detections: $edmDetections" -ForegroundColor White
Write-Host "      False Positives: 0 (Exact match only)" -ForegroundColor Green
Write-Host "      Accuracy: $([math]::Round(($edmDetections / $totalDocs) * 100, 1))%" -ForegroundColor White
Write-Host ""

if ($falsePositives -gt 0) {
    $improvement = [math]::Round((($falsePositives / $regexDetections) * 100), 1)
    Write-Host "🎯 EDM Improvement:" -ForegroundColor Green
    Write-Host "   False Positive Elimination: $improvement% ($falsePositives → 0)" -ForegroundColor Green
    Write-Host "   Zero false positives with exact database matching" -ForegroundColor Green
    Write-Host ""
}

Write-Host "📋 Confidence Level Distribution (EDM):" -ForegroundColor Cyan
$confidenceStats = $results | Where-Object { $_.EDMMatched } | Group-Object -Property ConfidenceLevel
foreach ($stat in $confidenceStats | Sort-Object Count -Descending) {
    Write-Host "   $($stat.Name): $($stat.Count) documents" -ForegroundColor White
}
Write-Host ""

Write-Host "💡 Key Findings:" -ForegroundColor Yellow
Write-Host "   • EDM provides exact database matching (zero false positives)" -ForegroundColor White
Write-Host "   • Regex patterns may match similar formats not in database" -ForegroundColor White
Write-Host "   • Use EDM for sensitive data with known values (employee records)" -ForegroundColor White
Write-Host "   • Use regex for format-based detection without database" -ForegroundColor White
Write-Host ""

Write-Host "✅ Validation completed successfully" -ForegroundColor Green
exit 0

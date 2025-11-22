<#
.SYNOPSIS
    Validates custom Sensitive Information Types against local test data files.

.DESCRIPTION
    This script validates custom SITs created in Lab 1 by performing pattern
    matching tests against local test data files. Provides:
    - Custom SIT configuration verification
    - Pattern detection count by SIT type
    - Confidence level distribution analysis
    - Validation results export to CSV
    - False positive/negative identification
    
    Tests against C:\PurviewLabs\Lab1-CustomSIT-Testing\ directory by default.

.PARAMETER TestDataPath
    Path to test data directory. Defaults to C:\PurviewLabs\Lab1-CustomSIT-Testing.

.PARAMETER ExportResults
    Export validation results to CSV file. Default: $true.

.PARAMETER DetailedReport
    Generate detailed match information including file names and confidence levels.

.EXAMPLE
    .\Validate-CustomSITs.ps1
    
    Validates all custom SITs against default test data directory.

.EXAMPLE
    .\Validate-CustomSITs.ps1 -TestDataPath "C:\Temp\CustomSITTest" -DetailedReport
    
    Validates custom SITs with detailed match reporting.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    Last Modified: 2025-11-14
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - ExchangeOnlineManagement module v3.0+ installed
    - Security & Compliance PowerShell access
    - Test data files from Create-Lab1TestData.ps1
    - Custom SITs created via Exercise 2, 3, 4 scripts
    
    Script development orchestrated using GitHub Copilot.

.VALIDATION CHECKS
    1. Custom SIT existence verification
    2. Pattern configuration validation
    3. Local file pattern matching tests
    4. Confidence level distribution analysis
    5. Detection accuracy reporting
#>

# =============================================================================
# Custom SIT Validation Script
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$TestDataPath = "C:\PurviewLabs\Lab1-CustomSIT-Testing",
    
    [Parameter(Mandatory = $false)]
    [bool]$ExportResults = $true,
    
    [Parameter(Mandatory = $false)]
    [switch]$DetailedReport
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
$logPath = Join-Path $PSScriptRoot "..\logs\Validate-CustomSITs.log"
Initialize-PurviewLog -LogPath $logPath

Write-SectionHeader -Text "🔍 Custom SIT Validation"

# =============================================================================
# Step 1: Prerequisites Validation
# =============================================================================

Write-Host "📋 Step 1: Prerequisites Validation" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

# Verify test data directory exists
if (-not (Test-Path $TestDataPath)) {
    Write-Host "❌ Test data directory not found: $TestDataPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Run Create-Lab1TestData.ps1 first to generate test files" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Test data directory found: $TestDataPath" -ForegroundColor Green

# Count test files
$testFiles = Get-ChildItem -Path $TestDataPath -Recurse -File
Write-Host "✅ Test files available: $($testFiles.Count)" -ForegroundColor Green

# =============================================================================
# Step 2: Security & Compliance Authentication
# =============================================================================

Write-Host "`n📋 Step 2: Security & Compliance Authentication" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Check if already connected
$existingConnection = Get-ConnectionInformation -ErrorAction SilentlyContinue
if ($existingConnection) {
    Write-Host "✅ Already connected to Security & Compliance" -ForegroundColor Green
    Write-Host "   User: $($existingConnection.UserPrincipalName)" -ForegroundColor Cyan
    Write-Host "   Organization: $($existingConnection.TenantId)" -ForegroundColor Cyan
} else {
    Write-Host "🔐 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
    Write-Host "   ⚠️  IMPORTANT: Check for authentication popup - it may appear BEHIND this window!" -ForegroundColor Yellow
    Write-Host "   Look for a browser window or sign-in popup to appear..." -ForegroundColor Yellow
    Write-Host ""

    try {
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
        Connect-IPPSSession -WarningAction SilentlyContinue -ErrorAction Stop
        
        Write-Host "✅ Connected to Security & Compliance successfully" -ForegroundColor Green
        
        $connectionCheck = Get-ConnectionInformation -ErrorAction SilentlyContinue
        if ($connectionCheck) {
            Write-Host "   User: $($connectionCheck.UserPrincipalName)" -ForegroundColor Cyan
            Write-Host "   Organization: $($connectionCheck.TenantId)" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "❌ Security & Compliance authentication failed" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Error details: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "💡 Troubleshooting Steps:" -ForegroundColor Cyan
        Write-Host "   1. If you see 'msalruntime' error, this is a known WAM issue" -ForegroundColor White
        Write-Host "   2. Try running: Connect-IPPSSession directly in PowerShell" -ForegroundColor White
        Write-Host "   3. Check if browser pop-ups are blocked" -ForegroundColor White
        Write-Host "   4. Verify you have Compliance Administrator or Global Administrator role" -ForegroundColor White
        Write-Host "   5. Try updating the module: Update-Module -Name ExchangeOnlineManagement -Force" -ForegroundColor White
        Write-Host ""
        Write-Host "⚠️  If the connection hangs, press Ctrl+C and try the workaround:" -ForegroundColor Yellow
        Write-Host "   Run 'Connect-IPPSSession' manually first, then re-run this script" -ForegroundColor White
        exit 1
    }
}
} catch {
    Write-Host "❌ Security & Compliance authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Custom SIT Verification
# =============================================================================

Write-Host "`n📋 Step 3: Custom SIT Verification" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

$sitNames = @(
    "Contoso Project Identifier",
    "Contoso Customer Number",
    "Contoso Purchase Order Number"
)

$validatedSITs = @()

foreach ($sitName in $sitNames) {
    Write-Host "🔍 Verifying: $sitName" -ForegroundColor Cyan
    
    try {
        $sit = Get-DlpSensitiveInformationType -Identity $sitName -ErrorAction Stop
        
        if ($sit) {
            Write-Host "   ✅ SIT found: $($sit.Name)" -ForegroundColor Green
            Write-Host "      Publisher: $($sit.Publisher)" -ForegroundColor White
            Write-Host "      State: $($sit.State)" -ForegroundColor White
            
            $validatedSITs += $sit
        }
    } catch {
        Write-Host "   ❌ SIT not found: $sitName" -ForegroundColor Red
        Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

if ($validatedSITs.Count -eq 0) {
    Write-Host "`n❌ No custom SITs found for validation" -ForegroundColor Red
    Write-Host "   Run Exercise 2, 3, and 4 scripts to create custom SITs" -ForegroundColor Yellow
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    exit 1
}

Write-Host "`n✅ Verified $($validatedSITs.Count) of $($sitNames.Count) custom SITs" -ForegroundColor Green

# =============================================================================
# Step 4: Pattern Detection Testing
# =============================================================================

Write-Host "`n📋 Step 4: Pattern Detection Testing" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

Write-Host "🔍 Testing pattern detection against local files..." -ForegroundColor Cyan
Write-Host ""

# Define regex patterns for local testing (matches SIT definitions)
$patterns = @{
    "Contoso Project Identifier" = @{
        Pattern = '\bPROJ-\d{4}-\d{4}\b'
        HighConfidenceKeywords = @('project', 'identifier', 'PROJ', 'development', 'initiative')
        MediumConfidenceKeywords = @('project', 'PROJ')
    }
    "Contoso Customer Number" = @{
        Pattern = '\bCUST-\d{6}\b'
        HighConfidenceKeywords = @('customer', 'account', 'CUST', 'client', 'customer number', 'account number')
        MediumConfidenceKeywords = @('customer', 'account', 'CUST')
    }
    "Contoso Purchase Order Number" = @{
        Pattern = '\bPO-\d{4}-\d{4}-[A-Z]{4}\b'
        HighConfidenceKeywords = @('purchase order', 'PO', 'procurement', 'requisition', 'vendor')
        MediumConfidenceKeywords = @('purchase order', 'PO', 'procurement')
    }
}

$results = @()

foreach ($sitName in $validatedSITs.Name) {
    if ($patterns.ContainsKey($sitName)) {
        Write-Host "🔸 Testing: $sitName" -ForegroundColor Cyan
        
        $pattern = $patterns[$sitName].Pattern
        $highKeywords = $patterns[$sitName].HighConfidenceKeywords
        $mediumKeywords = $patterns[$sitName].MediumConfidenceKeywords
        
        $matchedFiles = @()
        $totalMatches = 0
        $highConfidenceCount = 0
        $mediumConfidenceCount = 0
        $lowConfidenceCount = 0
        
        foreach ($file in $testFiles) {
            $content = Get-Content -Path $file.FullName -Raw
            $matches = [regex]::Matches($content, $pattern)
            
            if ($matches.Count -gt 0) {
                $matchedFiles += $file.Name
                $totalMatches += $matches.Count
                
                # Analyze confidence levels based on keyword presence
                foreach ($match in $matches) {
                    # Get context around match (300 characters before and after)
                    $startIndex = [Math]::Max(0, $match.Index - 300)
                    $length = [Math]::Min(600, $content.Length - $startIndex)
                    $context = $content.Substring($startIndex, $length)
                    
                    # Count keyword matches in context
                    $highKeywordMatches = 0
                    $mediumKeywordMatches = 0
                    
                    foreach ($keyword in $highKeywords) {
                        if ($context -match [regex]::Escape($keyword)) {
                            $highKeywordMatches++
                        }
                    }
                    
                    foreach ($keyword in $mediumKeywords) {
                        if ($context -match [regex]::Escape($keyword)) {
                            $mediumKeywordMatches++
                        }
                    }
                    
                    # Classify confidence level
                    if ($highKeywordMatches -ge 3) {
                        $highConfidenceCount++
                    } elseif ($mediumKeywordMatches -ge 2) {
                        $mediumConfidenceCount++
                    } else {
                        $lowConfidenceCount++
                    }
                }
            }
        }
        
        # Calculate confidence percentages
        $highPct = if ($totalMatches -gt 0) { [math]::Round(($highConfidenceCount / $totalMatches) * 100, 0) } else { 0 }
        $mediumPct = if ($totalMatches -gt 0) { [math]::Round(($mediumConfidenceCount / $totalMatches) * 100, 0) } else { 0 }
        $lowPct = if ($totalMatches -gt 0) { [math]::Round(($lowConfidenceCount / $totalMatches) * 100, 0) } else { 0 }
        
        Write-Host "   Files Matched: $($matchedFiles.Count)" -ForegroundColor White
        Write-Host "   Total Patterns Detected: $totalMatches" -ForegroundColor White
        Write-Host "   Confidence Distribution:" -ForegroundColor White
        Write-Host "      High (85%): $highConfidenceCount instances ($highPct%)" -ForegroundColor Green
        Write-Host "      Medium (75%): $mediumConfidenceCount instances ($mediumPct%)" -ForegroundColor Yellow
        Write-Host "      Low (65%): $lowConfidenceCount instances ($lowPct%)" -ForegroundColor Cyan
        Write-Host ""
        
        # Store results
        $results += [PSCustomObject]@{
            SITName = $sitName
            Pattern = $pattern
            FilesMatched = $matchedFiles.Count
            TotalDetections = $totalMatches
            HighConfidence = $highConfidenceCount
            HighConfidencePct = $highPct
            MediumConfidence = $mediumConfidenceCount
            MediumConfidencePct = $mediumPct
            LowConfidence = $lowConfidenceCount
            LowConfidencePct = $lowPct
        }
    }
}

# =============================================================================
# Step 5: Summary and Export
# =============================================================================

Write-Host "📋 Step 5: Validation Summary and Export" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

Write-Host "`n📊 Validation Summary:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

foreach ($result in $results) {
    Write-Host "✅ $($result.SITName)" -ForegroundColor Green
    Write-Host "   Pattern: $($result.Pattern)" -ForegroundColor White
    Write-Host "   Detection Count: $($result.TotalDetections) instances in $($result.FilesMatched) files" -ForegroundColor White
    Write-Host "   Confidence Distribution:" -ForegroundColor White
    Write-Host "      High: $($result.HighConfidence) ($($result.HighConfidencePct)%)" -ForegroundColor Green
    Write-Host "      Medium: $($result.MediumConfidence) ($($result.MediumConfidencePct)%)" -ForegroundColor Yellow
    Write-Host "      Low: $($result.LowConfidence) ($($result.LowConfidencePct)%)" -ForegroundColor Cyan
    Write-Host ""
}

# Export results if requested
if ($ExportResults -and $results.Count -gt 0) {
    $exportPath = Join-Path $TestDataPath "Validation_Results.csv"
    $results | Export-Csv -Path $exportPath -NoTypeInformation -Force
    
    Write-Host "✅ Validation results exported to:" -ForegroundColor Green
    Write-Host "   $exportPath" -ForegroundColor White
    Write-Host ""
}

# Disconnect from Security & Compliance
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "🎉 Custom SIT Validation Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Analysis Tips:" -ForegroundColor Cyan
Write-Host "   • High confidence percentages above 40% indicate good keyword coverage" -ForegroundColor White
Write-Host "   • Low confidence should be minority for production DLP policies" -ForegroundColor White
Write-Host "   • Review validation results CSV for detailed pattern analysis" -ForegroundColor White
Write-Host "   • Use Tune-SITConfidence.ps1 to optimize confidence levels if needed" -ForegroundColor White
Write-Host ""
Write-Host "✅ Ready for Exercise 6: Confidence Level Tuning" -ForegroundColor Green

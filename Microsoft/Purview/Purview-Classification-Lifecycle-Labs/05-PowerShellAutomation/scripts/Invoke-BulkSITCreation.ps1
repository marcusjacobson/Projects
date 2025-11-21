<#
.SYNOPSIS
    Batch creation engine for custom Sensitive Information Types from CSV configuration with
    validation, duplicate detection, and comprehensive error handling.

.DESCRIPTION
    This script implements enterprise-grade batch SIT creation automation for Microsoft Purview
    Data Loss Prevention. It reads SIT definitions from a CSV configuration file and creates
    multiple regex-based custom Sensitive Information Types in a single operation. The script includes:
    
    - CSV format validation before creating any SITs
    - Duplicate detection to skip SITs that already exist
    - Individual SIT validation with confidence level checking
    - Comprehensive error handling that continues processing after individual failures
    - Summary reporting showing created SITs, duplicates skipped, and errors encountered
    
    The bulk SIT creation engine is designed for scenarios where multiple custom SITs need to be
    deployed consistently across environments or when onboarding new data classification requirements.

.PARAMETER SitDefinitionCsv
    Path to CSV file with SIT definitions. The CSV must have columns: Name, Pattern, Confidence, Description.
    
    Example CSV format:
    Name,Pattern,Confidence,Description
    Employee Badge ID,\b[E][0-9]{6}\b,85,Six-digit employee badge numbers starting with E
    Project Code,\b[P][R][J]-[0-9]{4}\b,90,Project codes in format PRJ-1234
    Account Number,\b[A][C][C][T]-[0-9]{8}\b,88,Eight-digit account numbers with ACCT prefix

.PARAMETER ValidateOnly
    Validate CSV format and SIT definitions without creating any SITs. Use this parameter to
    test configuration before running the actual creation. Default is $false.

.PARAMETER SkipDuplicates
    Skip SITs that already exist in the tenant instead of failing. Default is $true. Set to
    $false if you want the script to fail when encountering existing SITs.

.PARAMETER LogPath
    Path to write detailed operation logs. Default is ".\logs\bulk-sit-creation.log".
    The log file includes timestamps, SIT names, creation status, and error details.

.EXAMPLE
    .\Invoke-BulkSITCreation.ps1 -SitDefinitionCsv ".\configs\custom-sits.csv"
    
    Create SITs from CSV configuration with default settings (skip duplicates, create all valid SITs).

.EXAMPLE
    .\Invoke-BulkSITCreation.ps1 -SitDefinitionCsv ".\configs\custom-sits.csv" -ValidateOnly
    
    Validate CSV format and SIT definitions without creating any SITs.

.EXAMPLE
    .\Invoke-BulkSITCreation.ps1 -SitDefinitionCsv ".\configs\custom-sits.csv" -SkipDuplicates:$false
    
    Create SITs but fail if any duplicates are found (strict mode).

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-09
    Last Modified: 2025-01-09
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - ExchangeOnlineManagement module version 3.4.0 or higher
    - Microsoft Purview Data Loss Prevention administrator permissions
    - CSV file with SIT definitions (Name, Pattern, Confidence, Description columns)
    - Sufficient disk space for log files
    
    Script development orchestrated using GitHub Copilot.

.BULK OPERATION ARCHITECTURE
    - CSV validation: Pre-validates format before creating any SITs
    - Duplicate detection: Checks for existing SITs to avoid conflicts
    - Confidence validation: Ensures confidence levels are between 65-100
    - Error handling: Continues processing after individual SIT failures
    - Summary reporting: Shows created, duplicates, errors with counts
#>

#
# =============================================================================
# Batch SIT creation engine for enterprise-scale custom SIT deployment.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Path to CSV file with SIT definitions")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$SitDefinitionCsv,

    [Parameter(Mandatory = $false, HelpMessage = "Validate CSV without creating SITs")]
    [switch]$ValidateOnly,

    [Parameter(Mandatory = $false, HelpMessage = "Skip SITs that already exist")]
    [bool]$SkipDuplicates = $true,

    [Parameter(Mandatory = $false, HelpMessage = "Path for detailed operation logs")]
    [string]$LogPath = ".\logs\bulk-sit-creation.log"
)

# =============================================================================
# Action 1: Environment Setup and Validation
# =============================================================================

Write-Host "🚀 Bulk SIT Creation Engine - Starting" -ForegroundColor Magenta
Write-Host "=======================================" -ForegroundColor Magenta
Write-Host ""

# Ensure log directory exists
$logDir = Split-Path -Path $LogPath -Parent
if (-not (Test-Path $logDir)) {
    Write-Host "📁 Creating log directory: $logDir" -ForegroundColor Cyan
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# =============================================================================
# Action 2: Module Validation
# =============================================================================

Write-Host "🔍 Action 2: Module Validation" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Checking for required ExchangeOnlineManagement module..." -ForegroundColor Cyan
try {
    $eomModule = Get-Module -ListAvailable -Name ExchangeOnlineManagement | Sort-Object Version -Descending | Select-Object -First 1
    if ($eomModule) {
        Write-Host "   ✅ ExchangeOnlineManagement version $($eomModule.Version) found" -ForegroundColor Green
    } else {
        throw "ExchangeOnlineManagement module not found. Install with: Install-Module ExchangeOnlineManagement -Scope CurrentUser"
    }
} catch {
    Write-Host "   ❌ Module validation failed: $_" -ForegroundColor Red
    exit 1
}

Import-Module ExchangeOnlineManagement -ErrorAction Stop
Write-Host "   ✅ ExchangeOnlineManagement module imported successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Action 3: CSV Configuration Loading and Validation
# =============================================================================

Write-Host "🔍 Action 3: CSV Configuration Loading and Validation" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Loading SIT definitions from CSV: $SitDefinitionCsv" -ForegroundColor Cyan
try {
    $sitDefinitions = Import-Csv -Path $SitDefinitionCsv -ErrorAction Stop
    
    if (-not $sitDefinitions) {
        throw "CSV file is empty or could not be read"
    }
    
    # Validate required columns
    $requiredColumns = @("Name", "Pattern", "Confidence", "Description")
    $csvColumns = $sitDefinitions[0].PSObject.Properties.Name
    $missingColumns = $requiredColumns | Where-Object { $_ -notin $csvColumns }
    
    if ($missingColumns) {
        throw "CSV file is missing required columns: $($missingColumns -join ', ')"
    }
    
    $totalSITs = $sitDefinitions.Count
    Write-Host "   ✅ Loaded $totalSITs SIT definitions from CSV" -ForegroundColor Green
    Write-Host ""
    
    # Validate each SIT definition
    Write-Host "📋 Validating SIT definitions..." -ForegroundColor Cyan
    $validationErrors = @()
    
    foreach ($sit in $sitDefinitions) {
        # Validate confidence level (must be between 65-100)
        if ([int]$sit.Confidence -lt 65 -or [int]$sit.Confidence -gt 100) {
            $validationErrors += "SIT '$($sit.Name)': Confidence must be between 65-100 (found: $($sit.Confidence))"
        }
        
        # Validate pattern is not empty
        if ([string]::IsNullOrWhiteSpace($sit.Pattern)) {
            $validationErrors += "SIT '$($sit.Name)': Pattern cannot be empty"
        }
        
        # Validate name is not empty
        if ([string]::IsNullOrWhiteSpace($sit.Name)) {
            $validationErrors += "Invalid SIT: Name cannot be empty"
        }
    }
    
    if ($validationErrors.Count -gt 0) {
        Write-Host "   ❌ Validation failed with $($validationErrors.Count) errors:" -ForegroundColor Red
        foreach ($error in $validationErrors) {
            Write-Host "      • $error" -ForegroundColor Red
        }
        exit 1
    }
    
    Write-Host "   ✅ All SIT definitions validated successfully" -ForegroundColor Green
    Write-Host ""
    
    # Display first 5 SITs for confirmation
    Write-Host "📋 First 5 SITs to create:" -ForegroundColor Cyan
    $sitDefinitions | Select-Object -First 5 | ForEach-Object {
        Write-Host "   • Name: $($_.Name)" -ForegroundColor Gray
        Write-Host "     Pattern: $($_.Pattern)" -ForegroundColor Gray
        Write-Host "     Confidence: $($_.Confidence)" -ForegroundColor Gray
        Write-Host "     Description: $($_.Description)" -ForegroundColor Gray
        Write-Host ""
    }
    if ($totalSITs -gt 5) {
        Write-Host "   ... and $($totalSITs - 5) more SITs" -ForegroundColor Gray
        Write-Host ""
    }
    
} catch {
    Write-Host "   ❌ CSV loading/validation failed: $_" -ForegroundColor Red
    exit 1
}

# Exit if validation only mode
if ($ValidateOnly) {
    Write-Host "✅ Validation complete (no SITs created due to -ValidateOnly flag)" -ForegroundColor Green
    Write-Host ""
    Write-Host "⏭️  Next Steps:" -ForegroundColor Cyan
    Write-Host "   • Run without -ValidateOnly to create the SITs" -ForegroundColor Gray
    Write-Host "   • Review CSV file if any validation errors were found" -ForegroundColor Gray
    exit 0
}

# =============================================================================
# Action 4: Security & Compliance Connection
# =============================================================================

Write-Host "🔍 Action 4: Security & Compliance Connection" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""

Write-Host "🔐 Connecting to Security & Compliance PowerShell (interactive authentication)..." -ForegroundColor Cyan
try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Host "   ✅ Connected to Security & Compliance successfully" -ForegroundColor Green
    
    # Test connection
    Get-DlpSensitiveInformationType -ResultSize 1 | Out-Null
    Write-Host "   ✅ Connection verified" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Connection failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "⚠️  Common connection issues:" -ForegroundColor Yellow
    Write-Host "   • Ensure you have DLP admin permissions in Microsoft Purview" -ForegroundColor Yellow
    Write-Host "   • Check that your account has appropriate licenses" -ForegroundColor Yellow
    Write-Host "   • Verify MFA is configured correctly for your account" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# =============================================================================
# Action 5: Duplicate Detection
# =============================================================================

Write-Host "🔍 Action 5: Duplicate Detection" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Retrieving existing custom SITs for duplicate detection..." -ForegroundColor Cyan
try {
    $existingSITs = Get-DlpSensitiveInformationType -ErrorAction Stop | 
                    Where-Object { $_.Publisher -ne "Microsoft Corporation" }
    
    $existingSITNames = $existingSITs | ForEach-Object { $_.Name }
    
    Write-Host "   ✅ Found $($existingSITs.Count) existing custom SITs" -ForegroundColor Green
    
    # Check for duplicates in CSV
    $duplicates = $sitDefinitions | Where-Object { $_.Name -in $existingSITNames }
    
    if ($duplicates.Count -gt 0) {
        if ($SkipDuplicates) {
            Write-Host "   ⚠️  Found $($duplicates.Count) duplicate SITs (will skip):" -ForegroundColor Yellow
            $duplicates | ForEach-Object {
                Write-Host "      • $($_.Name)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   ❌ Found $($duplicates.Count) duplicate SITs (failing due to -SkipDuplicates=`$false):" -ForegroundColor Red
            $duplicates | ForEach-Object {
                Write-Host "      • $($_.Name)" -ForegroundColor Red
            }
            exit 1
        }
    } else {
        Write-Host "   ✅ No duplicates found - all SITs are new" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️  Warning: Could not retrieve existing SITs: $_" -ForegroundColor Yellow
    Write-Host "   Proceeding with SIT creation (duplicates may cause errors)" -ForegroundColor Yellow
}
Write-Host ""

# =============================================================================
# Action 6: Bulk SIT Creation
# =============================================================================

Write-Host "🔍 Action 6: Bulk SIT Creation" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Creating $totalSITs custom SITs..." -ForegroundColor Cyan
Write-Host ""

# Initialize tracking variables
$results = @()
$processedCount = 0
$successCount = 0
$skippedCount = 0
$failureCount = 0
$startTime = Get-Date

# Process each SIT
$sitIndex = 0
foreach ($sit in $sitDefinitions) {
    $sitIndex++
    $percentComplete = [math]::Round(($sitIndex / $totalSITs) * 100, 1)
    
    Write-Progress -Activity "Bulk SIT Creation Progress" `
                   -Status "Processing SIT $sitIndex of $totalSITs | Success: $successCount | Skipped: $skippedCount | Failed: $failureCount" `
                   -PercentComplete $percentComplete `
                   -CurrentOperation "Creating: $($sit.Name)"
    
    Write-Host "[$sitIndex/$totalSITs] Creating SIT: $($sit.Name)" -ForegroundColor Cyan
    
    $sitResult = [PSCustomObject]@{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Name = $sit.Name
        Pattern = $sit.Pattern
        Confidence = $sit.Confidence
        Description = $sit.Description
        Status = "Unknown"
        ErrorMessage = ""
    }
    
    # Check for duplicate
    if ($sit.Name -in $existingSITNames) {
        if ($SkipDuplicates) {
            $sitResult.Status = "Skipped-Duplicate"
            $skippedCount++
            Write-Host "   ⚠️  Skipped (already exists)" -ForegroundColor Yellow
        } else {
            $sitResult.Status = "Failed-Duplicate"
            $sitResult.ErrorMessage = "SIT already exists"
            $failureCount++
            Write-Host "   ❌ Failed (already exists)" -ForegroundColor Red
        }
    } else {
        try {
            # Create the custom SIT using regex pattern
            New-DlpSensitiveInformationType `
                -Name $sit.Name `
                -Description $sit.Description `
                -Patterns @{
                    Pattern = $sit.Pattern
                    Confidence = [int]$sit.Confidence
                } `
                -ErrorAction Stop | Out-Null
            
            $sitResult.Status = "Success"
            $successCount++
            Write-Host "   ✅ Created successfully (Confidence: $($sit.Confidence))" -ForegroundColor Green
            
        } catch {
            $sitResult.Status = "Failed"
            $sitResult.ErrorMessage = $_.Exception.Message
            $failureCount++
            Write-Host "   ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    $results += $sitResult
    $processedCount++
    Write-Host ""
}

Write-Progress -Activity "Bulk SIT Creation Progress" -Completed

# =============================================================================
# Action 7: Results Summary and Logging
# =============================================================================

Write-Host "🔍 Action 7: Results Summary and Logging" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

$totalExecutionTime = (Get-Date) - $startTime

Write-Host "📊 Bulk SIT Creation Summary" -ForegroundColor Cyan
Write-Host "   • Total SITs processed: $processedCount" -ForegroundColor Gray
Write-Host "   • Successfully created: $successCount" -ForegroundColor Green
Write-Host "   • Skipped (duplicates): $skippedCount" -ForegroundColor Yellow
Write-Host "   • Failed: $failureCount" -ForegroundColor $(if ($failureCount -gt 0) { "Red" } else { "Gray" })
Write-Host "   • Success rate: $([math]::Round(($successCount / ($processedCount - $skippedCount)) * 100, 1))%" -ForegroundColor Gray
Write-Host "   • Total execution time: {0:mm}m {0:ss}s" -f $totalExecutionTime -ForegroundColor Gray
Write-Host ""

# Export results to CSV log
Write-Host "📋 Exporting detailed results to CSV log: $LogPath" -ForegroundColor Cyan
try {
    $results | Export-Csv -Path $LogPath -NoTypeInformation -Append -ErrorAction Stop
    Write-Host "   ✅ Results exported successfully" -ForegroundColor Green
    Write-Host "   📁 Log file: $LogPath" -ForegroundColor Gray
} catch {
    Write-Host "   ⚠️  Warning: Failed to export results to CSV: $_" -ForegroundColor Yellow
}
Write-Host ""

# Display created SITs
if ($successCount -gt 0) {
    Write-Host "✅ Successfully Created SITs ($successCount):" -ForegroundColor Green
    $createdSITs = $results | Where-Object { $_.Status -eq "Success" }
    foreach ($createdSIT in $createdSITs) {
        Write-Host "   • $($createdSIT.Name)" -ForegroundColor Green
        Write-Host "     Pattern: $($createdSIT.Pattern)" -ForegroundColor Gray
        Write-Host "     Confidence: $($createdSIT.Confidence)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Display failed SITs if any
if ($failureCount -gt 0) {
    Write-Host "❌ Failed SITs ($failureCount):" -ForegroundColor Red
    $failedSITs = $results | Where-Object { $_.Status -like "Failed*" }
    foreach ($failedSIT in $failedSITs) {
        Write-Host "   • $($failedSIT.Name)" -ForegroundColor Red
        Write-Host "     Error: $($failedSIT.ErrorMessage)" -ForegroundColor Gray
    }
    Write-Host ""
}

# =============================================================================
# Action 8: Completion
# =============================================================================

Write-Host "✅ Bulk SIT Creation Completed" -ForegroundColor Green
Write-Host ""
Write-Host "⏭️  Next Steps:" -ForegroundColor Cyan
Write-Host "   • Review the CSV log for detailed operation results" -ForegroundColor Gray
Write-Host "   • Verify created SITs in Microsoft Purview compliance portal" -ForegroundColor Gray
Write-Host "   • Test new SITs with sample content to validate pattern matching" -ForegroundColor Gray
Write-Host "   • Create DLP policies using the new custom SITs" -ForegroundColor Gray
Write-Host ""

Disconnect-ExchangeOnline -Confirm:$false

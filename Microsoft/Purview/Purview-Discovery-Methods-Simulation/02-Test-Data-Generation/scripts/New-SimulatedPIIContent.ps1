<#
.SYNOPSIS
    Generates simulated documents containing passport, driver's license, and ITIN patterns.

.DESCRIPTION
    This script creates realistic identity documents for the Purview Discovery Methods Simulation
    containing U.S. Passport numbers, Driver's License numbers, and Individual Taxpayer
    Identification Numbers (ITIN) that will be detected by Microsoft Purview's built-in
    identity-related Sensitive Information Types.
    
    Generated document types include:
    - Passport application forms
    - Driver's license records
    - ITIN tax documentation
    - Identity verification forms
    - Background check documents
    - Immigration paperwork
    - State ID records
    
    Documents support multiple U.S. state driver's license formats and realistic
    passport/ITIN patterns for comprehensive classification testing.

.PARAMETER GlobalConfigPath
    Optional path to the global configuration file.

.PARAMETER DocumentCount
    Optional override for number of identity documents to generate.

.PARAMETER SITTypes
    Optional array to specify which SIT types to focus on (Passport, DriverLicense, ITIN).

.PARAMETER SkipExisting
    When specified, skips generation if identity documents already exist.

.PARAMETER Force
    When specified, regenerates all identity documents.

.EXAMPLE
    .\New-SimulatedPIIContent.ps1
    
    Generates identity documents with all SIT types.

.EXAMPLE
    .\New-SimulatedPIIContent.ps1 -SITTypes "Passport","DriverLicense"
    
    Generates only passport and driver's license documents.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Global configuration file properly configured
    
    Script development orchestrated using GitHub Copilot.

.TEST DATA GENERATION OPERATIONS
    - Passport Number Generation (9-digit and Letter+7-digit formats)
    - Driver's License Simulation (State-specific formats: CA, TX, NY, FL, etc.)
    - ITIN Generation (Valid range validation)
    - Identity Document Creation (Applications, Verifications, Records)
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath,
    
    [Parameter(Mandatory = $false)]
    [int]$DocumentCount,
    
    [Parameter(Mandatory = $false)]
    [string[]]$SITTypes = @("Passport", "DriverLicense", "ITIN"),
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipExisting,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# =============================================================================
# Step 1: Load Configuration
# =============================================================================

Write-Host "🔍 Step 1: Load Configuration" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

try {
    $config = & "$PSScriptRoot\..\..\Shared-Utilities\Import-GlobalConfig.ps1" -GlobalConfigPath $GlobalConfigPath
    Write-Host "   ✅ Configuration loaded successfully" -ForegroundColor Green
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Configuration loaded for PII document generation" -Level Info -Config $config -ScriptName "New-SimulatedPIIContent"
} catch {
    Write-Host "   ❌ Failed to load configuration: $_" -ForegroundColor Red
    throw "Configuration load failure"
}

# Determine document count (19% for identity/legal scenario)
if ($DocumentCount -gt 0) {
    $piiDocCount = $DocumentCount
} else {
    $totalDocs = $config.DocumentGeneration.TotalDocuments
    $piiDocCount = [math]::Round($totalDocs * 0.19)
}

Write-Host "   ✅ Identity document count (19% of total): $piiDocCount" -ForegroundColor Green
Write-Host "   ✅ SIT types enabled: $($SITTypes -join ', ')" -ForegroundColor Green

# Create output directory
$piiOutputPath = Join-Path $config.Paths.GeneratedDocumentsPath "Identity"

if (-not (Test-Path $piiOutputPath)) {
    New-Item -Path $piiOutputPath -ItemType Directory -Force | Out-Null
    Write-Host "   ✅ Created Identity output directory" -ForegroundColor Green
} else {
    if ($SkipExisting -and -not $Force) {
        $existingFiles = Get-ChildItem -Path $piiOutputPath -File
        if ($existingFiles.Count -gt 0) {
            Write-Host "   ℹ️  Identity documents already exist - skipping" -ForegroundColor Cyan
            exit 0
        }
    }
    
    if ($Force) {
        Write-Host "   🔧 Force mode - clearing existing documents..." -ForegroundColor Cyan
        Remove-Item -Path "$piiOutputPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# =============================================================================
# Step 2: Prepare Identity Data Templates
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Prepare Identity Data Templates" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Function to generate passport number
function New-SimulatedPassport {
    $format = Get-Random -Minimum 0 -Maximum 2
    
    if ($format -eq 0) {
        # 9-digit format
        $number = ""
        for ($i = 0; $i -lt 9; $i++) {
            $number += (Get-Random -Minimum 0 -Maximum 10)
        }
        return $number
    } else {
        # Letter + 7 digits format (older)
        $letter = [char](Get-Random -Minimum 65 -Maximum 91)
        $number = ""
        for ($i = 0; $i -lt 7; $i++) {
            $number += (Get-Random -Minimum 0 -Maximum 10)
        }
        return "$letter$number"
    }
}

# Function to generate driver's license by state
function New-SimulatedDriverLicense {
    param([string]$State)
    
    switch ($State) {
        "CA" {
            # California: 1 letter + 7 digits
            $letter = [char](Get-Random -Minimum 65 -Maximum 91)
            $number = ""
            for ($i = 0; $i -lt 7; $i++) { $number += (Get-Random -Minimum 0 -Maximum 10) }
            return "$letter$number"
        }
        "TX" {
            # Texas: 8 digits
            $number = ""
            for ($i = 0; $i -lt 8; $i++) { $number += (Get-Random -Minimum 0 -Maximum 10) }
            return $number
        }
        "NY" {
            # New York: 1 letter + 7 digits or 9 digits
            if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) {
                $letter = [char](Get-Random -Minimum 65 -Maximum 91)
                $number = ""
                for ($i = 0; $i -lt 7; $i++) { $number += (Get-Random -Minimum 0 -Maximum 10) }
                return "$letter$number"
            } else {
                $number = ""
                for ($i = 0; $i -lt 9; $i++) { $number += (Get-Random -Minimum 0 -Maximum 10) }
                return $number
            }
        }
        "FL" {
            # Florida: 1 letter + 12 digits
            $letter = [char](Get-Random -Minimum 65 -Maximum 91)
            $number = ""
            for ($i = 0; $i -lt 12; $i++) { $number += (Get-Random -Minimum 0 -Maximum 10) }
            return "$letter$number"
        }
        default {
            # Generic: 1 letter + 7 digits
            $letter = [char](Get-Random -Minimum 65 -Maximum 91)
            $number = ""
            for ($i = 0; $i -lt 7; $i++) { $number += (Get-Random -Minimum 0 -Maximum 10) }
            return "$letter$number"
        }
    }
}

# Function to generate ITIN
function New-SimulatedITIN {
    $firstDigit = 9
    $secondDigit = Get-Random -Minimum 0 -Maximum 10
    $thirdDigit = Get-Random -Minimum 0 -Maximum 10
    
    # Fourth and fifth digits: 70-88, 90-92, 94-99
    $validRanges = @(70..88) + @(90..92) + @(94..99)
    $middleTwo = $validRanges[(Get-Random -Minimum 0 -Maximum $validRanges.Count)]
    
    $lastFour = Get-Random -Minimum 1 -Maximum 10000
    
    return "{0}{1}{2}-{3:00}-{4:0000}" -f $firstDigit, $secondDigit, $thirdDigit, $middleTwo, $lastFour
}

$states = @("CA", "TX", "NY", "FL", "IL", "PA", "OH", "GA", "NC", "MI")

Write-Host "   ✅ Identity data generation functions loaded" -ForegroundColor Green

# =============================================================================
# Step 3: Generate Identity Documents
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Generate Identity Documents" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

$startTime = Get-Date
$generatedDocs = @()
$passportCount = 0
$driverLicenseCount = 0
$itinCount = 0

$documentTypes = @(
    @{ Type = "PassportApplication"; Template = "Passport Application - {0}"; PassportCount = 2; DLCount = 0; ITINCount = 0 }
    @{ Type = "DriverLicenseRecord"; Template = "Driver License Record - {0}"; PassportCount = 0; DLCount = 3; ITINCount = 0 }
    @{ Type = "ITINTaxForm"; Template = "ITIN Tax Documentation - {0}"; PassportCount = 0; DLCount = 0; ITINCount = 4 }
    @{ Type = "IdentityVerification"; Template = "Identity Verification - {0}"; PassportCount = 1; DLCount = 2; ITINCount = 0 }
    @{ Type = "BackgroundCheck"; Template = "Background Check - {0}"; PassportCount = 1; DLCount = 2; ITINCount = 1 }
    @{ Type = "ImmigrationForm"; Template = "Immigration Form - {0}"; PassportCount = 3; DLCount = 0; ITINCount = 2 }
    @{ Type = "StateIDRecord"; Template = "State ID Record - {0}"; PassportCount = 0; DLCount = 4; ITINCount = 0 }
)

for ($i = 0; $i -lt $piiDocCount; $i++) {
    & "$PSScriptRoot\..\..\Shared-Utilities\Get-SimulationProgress.ps1" `
        -Activity "Generating Identity Documents" `
        -TotalItems $piiDocCount `
        -ProcessedItems $i `
        -StartTime $startTime
    
    $docType = $documentTypes[(Get-Random -Minimum 0 -Maximum $documentTypes.Count)]
    $extension = @("docx", "xlsx", "pdf", "txt")[(Get-Random -Minimum 0 -Maximum 4)]
    $timestamp = (Get-Date).AddDays(-1 * (Get-Random -Minimum 1 -Maximum 365)).ToString("yyyy-MM-dd")
    $fileName = "{0}_{1:00000}_{2}.{3}" -f $docType.Type, ($i + 1), $timestamp, $extension
    $filePath = Join-Path $piiOutputPath $fileName
    
    $content = @"
$($config.Simulation.CompanyPrefix) - Legal/HR Department
$($docType.Template -f $timestamp)

Document Information:
--------------------
Document Type: $($docType.Type)
Document ID: ID-$($i + 20001)
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Identity Information:
--------------------
"@

    # Add passport numbers
    if ($SITTypes -contains "Passport") {
        for ($j = 0; $j -lt $docType.PassportCount; $j++) {
            $passport = New-SimulatedPassport
            $content += "`nU.S. Passport Number: $passport"
            $passportCount++
        }
    }
    
    # Add driver's license numbers
    if ($SITTypes -contains "DriverLicense") {
        for ($j = 0; $j -lt $docType.DLCount; $j++) {
            $state = $states[(Get-Random -Minimum 0 -Maximum $states.Count)]
            $dlNumber = New-SimulatedDriverLicense -State $state
            $content += "`nDriver's License ($state): $dlNumber"
            $driverLicenseCount++
        }
    }
    
    # Add ITIN numbers
    if ($SITTypes -contains "ITIN") {
        for ($j = 0; $j -lt $docType.ITINCount; $j++) {
            $itin = New-SimulatedITIN
            $content += "`nIndividual Taxpayer ID (ITIN): $itin"
            $itinCount++
        }
    }
    
    $content += @"


Document Status: Active
Processing Date: $timestamp

---
Confidential Identity Information
$($config.Simulation.CompanyPrefix) - Generated: $(Get-Date -Format 'yyyy-MM-dd')
"@

    try {
        $content | Out-File -FilePath $filePath -Force -Encoding UTF8
        
        $generatedDocs += @{
            FileName = $fileName
            FileType = $extension
            DocumentType = $docType.Type
            PassportCount = $docType.PassportCount
            DLCount = $docType.DLCount
            ITINCount = $docType.ITINCount
        }
    } catch {
        Write-Host "   ⚠️  Failed to create: $fileName" -ForegroundColor Yellow
    }
}

& "$PSScriptRoot\..\..\Shared-Utilities\Get-SimulationProgress.ps1" -Activity "Generating Identity Documents" -Completed | Out-Null

Write-Host "   ✅ $piiDocCount identity documents generated" -ForegroundColor Green

# =============================================================================
# Step 4: Generation Summary
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 4: Generation Summary" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

$duration = (Get-Date) - $startTime

Write-Host "   📊 Total Identity Documents: $($generatedDocs.Count)" -ForegroundColor Cyan
Write-Host "   📊 Passport Numbers: $passportCount" -ForegroundColor Cyan
Write-Host "   📊 Driver's License Numbers: $driverLicenseCount" -ForegroundColor Cyan
Write-Host "   📊 ITIN Numbers: $itinCount" -ForegroundColor Cyan
Write-Host "   ⏱️  Generation Time: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan

$report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    DocumentType = "Identity"
    TotalDocuments = $generatedDocs.Count
    PassportCount = $passportCount
    DriverLicenseCount = $driverLicenseCount
    ITINCount = $itinCount
    OutputPath = $piiOutputPath
}

$reportPath = Join-Path $config.Paths.ReportsPath "identity-document-generation-report-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').json"

try {
    $report | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath -Force -Encoding UTF8
    Write-Host ""
    Write-Host "   ✅ Report saved: $(Split-Path $reportPath -Leaf)" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not save report: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Identity document generation completed successfully" -ForegroundColor Green
& "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Identity documents generated: $($generatedDocs.Count) documents" -Level Success -Config $config -ScriptName "New-SimulatedPIIContent"

exit 0

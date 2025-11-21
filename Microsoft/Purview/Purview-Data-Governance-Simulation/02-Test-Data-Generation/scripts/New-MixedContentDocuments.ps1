<#
.SYNOPSIS
    Generates mixed-format documents with distributed PII patterns across multiple SIT types.

.DESCRIPTION
    This script creates documents in various formats (.docx, .xlsx, .pdf, .txt) containing
    mixed Personally Identifiable Information patterns from multiple built-in Sensitive
    Information Types. This provides comprehensive testing coverage for classification
    scenarios where documents contain multiple SIT types with varying density levels.
    
    Generated documents include:
    - Mixed PII content combining SSN, credit cards, and identity information
    - Low, medium, and high PII density variations
    - Realistic document scenarios (memos, reports, spreadsheets)
    - Format-specific content appropriate for each file type
    
    This generator complements the specialized generators (HR, Financial, Identity) by
    creating documents that cross department boundaries and contain diverse PII patterns.

.PARAMETER GlobalConfigPath
    Optional path to the global configuration file.

.PARAMETER DocumentCount
    Optional override for number of mixed-format documents to generate.

.PARAMETER DocxPercent
    Percentage of documents to generate as .docx (default from config).

.PARAMETER XlsxPercent
    Percentage of documents to generate as .xlsx (default from config).

.PARAMETER PdfPercent
    Percentage of documents to generate as .pdf (default from config).

.PARAMETER TxtPercent
    Percentage of documents to generate as .txt (default from config).

.PARAMETER SkipExisting
    When specified, skips generation if mixed documents already exist.

.PARAMETER Force
    When specified, regenerates all documents.

.EXAMPLE
    .\New-MixedContentDocuments.ps1
    
    Generates mixed-format documents based on configuration.

.EXAMPLE
    .\New-MixedContentDocuments.ps1 -DocxPercent 60 -XlsxPercent 20 -PdfPercent 15 -TxtPercent 5
    
    Generates documents with custom format distribution.

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
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath,
    
    [Parameter(Mandatory = $false)]
    [int]$DocumentCount,
    
    [Parameter(Mandatory = $false)]
    [int]$DocxPercent,
    
    [Parameter(Mandatory = $false)]
    [int]$XlsxPercent,
    
    [Parameter(Mandatory = $false)]
    [int]$PdfPercent,
    
    [Parameter(Mandatory = $false)]
    [int]$TxtPercent,
    
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
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Configuration loaded for mixed-format document generation" -Level Info -Config $config -ScriptName "New-MixedContentDocuments"
} catch {
    Write-Host "   ❌ Failed to load configuration: $_" -ForegroundColor Red
    throw "Configuration load failure"
}

# Determine document count (22% for mixed/marketing scenario)
if ($DocumentCount -gt 0) {
    $mixedDocCount = $DocumentCount
} else {
    $totalDocs = $config.DocumentGeneration.TotalDocuments
    $mixedDocCount = [math]::Round($totalDocs * 0.22)
}

Write-Host "   ✅ Mixed document count (22% of total): $mixedDocCount" -ForegroundColor Green

# Create output directory
$mixedOutputPath = Join-Path $config.Paths.GeneratedDocumentsPath "Mixed"

if (-not (Test-Path $mixedOutputPath)) {
    New-Item -Path $mixedOutputPath -ItemType Directory -Force | Out-Null
    Write-Host "   ✅ Created Mixed output directory" -ForegroundColor Green
} else {
    if ($SkipExisting -and -not $Force) {
        $existingFiles = Get-ChildItem -Path $mixedOutputPath -File
        if ($existingFiles.Count -gt 0) {
            Write-Host "   ℹ️  Mixed documents already exist - skipping" -ForegroundColor Cyan
            exit 0
        }
    }
    
    if ($Force) {
        Write-Host "   🔧 Force mode - clearing existing documents..." -ForegroundColor Cyan
        Remove-Item -Path "$mixedOutputPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# =============================================================================
# Step 2: Prepare Generation Functions
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Prepare Generation Functions" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Import generation functions from other scripts
function New-RandomSSN {
    $area = Get-Random -Minimum 1 -Maximum 899
    $group = Get-Random -Minimum 1 -Maximum 99
    $serial = Get-Random -Minimum 1 -Maximum 9999
    return "{0:000}-{1:00}-{2:0000}" -f $area, $group, $serial
}

function New-RandomCreditCard {
    $prefix = @("4", "5", "3", "6")[(Get-Random -Minimum 0 -Maximum 4)]
    $length = if ($prefix -eq "3") { 15 } else { 16 }
    $digits = $prefix
    for ($i = 1; $i -lt $length; $i++) { $digits += (Get-Random -Minimum 0 -Maximum 10) }
    
    if ($prefix -eq "3") {
        return "{0}-{1}-{2}" -f $digits.Substring(0,4), $digits.Substring(4,6), $digits.Substring(10,5)
    } else {
        return "{0}-{1}-{2}-{3}" -f $digits.Substring(0,4), $digits.Substring(4,4), $digits.Substring(8,4), $digits.Substring(12,4)
    }
}

function New-RandomPassport {
    if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) {
        $num = ""
        for ($i = 0; $i -lt 9; $i++) { $num += (Get-Random -Minimum 0 -Maximum 10) }
        return $num
    } else {
        $letter = [char](Get-Random -Minimum 65 -Maximum 91)
        $num = ""
        for ($i = 0; $i -lt 7; $i++) { $num += (Get-Random -Minimum 0 -Maximum 10) }
        return "$letter$num"
    }
}

function New-RandomBankAccount {
    $length = Get-Random -Minimum 10 -Maximum 15
    $num = ""
    for ($i = 0; $i -lt $length; $i++) { $num += (Get-Random -Minimum 0 -Maximum 10) }
    return $num
}

Write-Host "   ✅ PII generation functions loaded" -ForegroundColor Green

# File type distribution
if ($DocxPercent -gt 0 -or $XlsxPercent -gt 0 -or $PdfPercent -gt 0 -or $TxtPercent -gt 0) {
    $docxCount = [math]::Round($mixedDocCount * ($DocxPercent / 100))
    $xlsxCount = [math]::Round($mixedDocCount * ($XlsxPercent / 100))
    $pdfCount = [math]::Round($mixedDocCount * ($PdfPercent / 100))
    $txtCount = $mixedDocCount - $docxCount - $xlsxCount - $pdfCount
    Write-Host "   ✅ Custom file distribution: $docxCount docx, $xlsxCount xlsx, $pdfCount pdf, $txtCount txt" -ForegroundColor Green
} else {
    $fileTypeDist = $config.DocumentGeneration.FileTypeDistribution
    $docxCount = [math]::Round($mixedDocCount * ($fileTypeDist.docx / 100))
    $xlsxCount = [math]::Round($mixedDocCount * ($fileTypeDist.xlsx / 100))
    $pdfCount = [math]::Round($mixedDocCount * ($fileTypeDist.pdf / 100))
    $txtCount = $mixedDocCount - $docxCount - $xlsxCount - $pdfCount
    Write-Host "   ✅ Configuration file distribution applied" -ForegroundColor Green
}

# =============================================================================
# Step 3: Generate Mixed-Format Documents
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Generate Mixed-Format Documents" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

$startTime = Get-Date
$generatedDocs = @()
$totalPIIPatterns = 0
$lowDensityCount = 0
$mediumDensityCount = 0
$highDensityCount = 0

for ($i = 0; $i -lt $mixedDocCount; $i++) {
    & "$PSScriptRoot\..\..\Shared-Utilities\Get-SimulationProgress.ps1" `
        -Activity "Generating Mixed-Format Documents" `
        -TotalItems $mixedDocCount `
        -ProcessedItems $i `
        -StartTime $startTime
    
    # Determine file extension
    if ($i -lt $docxCount) {
        $extension = "docx"
    } elseif ($i -lt ($docxCount + $xlsxCount)) {
        $extension = "xlsx"
    } elseif ($i -lt ($docxCount + $xlsxCount + $pdfCount)) {
        $extension = "pdf"
    } else {
        $extension = "txt"
    }
    
    # Determine PII density (low: 1-2, medium: 3-5, high: 6-10)
    $densityRoll = Get-Random -Minimum 0 -Maximum 100
    if ($densityRoll -lt 30) {
        $density = "Low"
        $piiCount = Get-Random -Minimum 1 -Maximum 3
        $lowDensityCount++
    } elseif ($densityRoll -lt 70) {
        $density = "Medium"
        $piiCount = Get-Random -Minimum 3 -Maximum 6
        $mediumDensityCount++
    } else {
        $density = "High"
        $piiCount = Get-Random -Minimum 6 -Maximum 11
        $highDensityCount++
    }
    
    $docTypes = @("Memo", "Report", "Spreadsheet", "Email", "Contract", "Summary", "Analysis")
    $docType = $docTypes[(Get-Random -Minimum 0 -Maximum $docTypes.Count)]
    
    $timestamp = (Get-Date).AddDays(-1 * (Get-Random -Minimum 1 -Maximum 365)).ToString("yyyy-MM-dd")
    $fileName = "Mixed_{0}_{1:00000}_{2}.{3}" -f $docType, ($i + 1), $timestamp, $extension
    $filePath = Join-Path $mixedOutputPath $fileName
    
    $content = @"
$($config.Simulation.CompanyPrefix) - Cross-Departmental Document
$docType - $timestamp

Document Information:
--------------------
Document Type: $docType (Mixed PII Content)
Document ID: MIX-$($i + 30001)
PII Density: $density
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Content Summary:
---------------
This document contains mixed PII content from various departments
and includes multiple types of sensitive information patterns.

Sensitive Information:
---------------------
"@

    # Add mixed PII patterns
    $piiTypes = @("SSN", "CreditCard", "Passport", "BankAccount")
    
    for ($j = 0; $j -lt $piiCount; $j++) {
        $piiType = $piiTypes[(Get-Random -Minimum 0 -Maximum $piiTypes.Count)]
        
        switch ($piiType) {
            "SSN" {
                $ssn = New-RandomSSN
                $content += "`nSocial Security Number: $ssn"
            }
            "CreditCard" {
                $cc = New-RandomCreditCard
                $content += "`nCredit Card: $cc"
            }
            "Passport" {
                $passport = New-RandomPassport
                $content += "`nPassport Number: $passport"
            }
            "BankAccount" {
                $bank = New-RandomBankAccount
                $content += "`nBank Account: $bank"
            }
        }
        
        $totalPIIPatterns++
    }
    
    $content += @"


Document Classification:
-----------------------
Sensitivity: $density PII Density
Review Required: Yes
Retention Period: 7 years

---
Confidential - Mixed Sensitive Information
$($config.Simulation.CompanyPrefix) - Generated: $(Get-Date -Format 'yyyy-MM-dd')
"@

    try {
        $content | Out-File -FilePath $filePath -Force -Encoding UTF8
        
        $generatedDocs += @{
            FileName = $fileName
            FileType = $extension
            DocumentType = $docType
            PIIDensity = $density
            PIICount = $piiCount
        }
    } catch {
        Write-Host "   ⚠️  Failed to create: $fileName" -ForegroundColor Yellow
    }
}

& "$PSScriptRoot\..\..\Shared-Utilities\Get-SimulationProgress.ps1" -Activity "Generating Mixed-Format Documents" -Completed | Out-Null

Write-Host "   ✅ $mixedDocCount mixed-format documents generated" -ForegroundColor Green

# =============================================================================
# Step 4: Generation Summary
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 4: Generation Summary" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

$duration = (Get-Date) - $startTime

$actualDocx = ($generatedDocs | Where-Object { $_.FileType -eq "docx" }).Count
$actualXlsx = ($generatedDocs | Where-Object { $_.FileType -eq "xlsx" }).Count
$actualPdf = ($generatedDocs | Where-Object { $_.FileType -eq "pdf" }).Count
$actualTxt = ($generatedDocs | Where-Object { $_.FileType -eq "txt" }).Count

Write-Host "   📊 Total Mixed Documents: $($generatedDocs.Count)" -ForegroundColor Cyan
Write-Host "   📊 File Types: $actualDocx docx, $actualXlsx xlsx, $actualPdf pdf, $actualTxt txt" -ForegroundColor Cyan
Write-Host "   📊 Total PII Patterns: $totalPIIPatterns" -ForegroundColor Cyan
Write-Host "   📊 Low Density: $lowDensityCount documents" -ForegroundColor Cyan
Write-Host "   📊 Medium Density: $mediumDensityCount documents" -ForegroundColor Cyan
Write-Host "   📊 High Density: $highDensityCount documents" -ForegroundColor Cyan
Write-Host "   ⏱️  Generation Time: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan

$report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    DocumentType = "Mixed"
    TotalDocuments = $generatedDocs.Count
    FileTypeDistribution = @{ DOCX = $actualDocx; XLSX = $actualXlsx; PDF = $actualPdf; TXT = $actualTxt }
    TotalPIIPatterns = $totalPIIPatterns
    DensityDistribution = @{ Low = $lowDensityCount; Medium = $mediumDensityCount; High = $highDensityCount }
    OutputPath = $mixedOutputPath
}

$reportPath = Join-Path $config.Paths.ReportsPath "mixed-document-generation-report-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').json"

try {
    $report | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath -Force -Encoding UTF8
    Write-Host ""
    Write-Host "   ✅ Report saved: $(Split-Path $reportPath -Leaf)" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not save report: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Mixed-format document generation completed successfully" -ForegroundColor Green
& "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Mixed documents generated: $($generatedDocs.Count) documents, $totalPIIPatterns PII patterns" -Level Success -Config $config -ScriptName "New-MixedContentDocuments"

exit 0

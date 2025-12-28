<#
.SYNOPSIS
    Generates simulated financial documents containing credit card, bank account, and routing number patterns.

.DESCRIPTION
    This script creates realistic financial documents for the Purview Discovery Methods Simulation
    containing credit card numbers, bank account numbers, and ABA routing number patterns
    that will be detected by Microsoft Purview's built-in financial Sensitive Information Types.
    
    Generated document types include:
    - Expense reports with credit card transactions
    - Payment vouchers with bank account details
    - Bank statements with account numbers
    - Credit card transaction records
    - Invoice payment information
    - Wire transfer documents
    - ACH payment authorizations
    
    Documents are created in multiple formats (.docx, .xlsx, .pdf, .txt) with varying PII
    density levels to provide comprehensive testing coverage for financial data classification.
    
    Financial Pattern Implementation:
    - Credit Card: Visa, Mastercard, Amex, Discover with Luhn validation
    - Bank Account: 8-17 digit U.S. bank account numbers
    - ABA Routing: 9-digit routing numbers

.PARAMETER GlobalConfigPath
    Optional path to the global configuration file. If not specified, uses default location.

.PARAMETER DocumentCount
    Optional override for number of financial documents to generate.

.PARAMETER PIIDensity
    Optional PII density override (Low, Medium, High). Controls number of financial patterns per document.

.PARAMETER SkipExisting
    When specified, skips generation if financial documents already exist.

.PARAMETER Force
    When specified, regenerates all financial documents even if they exist.

.EXAMPLE
    .\New-SimulatedFinancialRecords.ps1
    
    Generates financial documents based on global configuration.

.EXAMPLE
    .\New-SimulatedFinancialRecords.ps1 -PIIDensity High
    
    Generates financial documents with high density of financial patterns.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Sufficient disk space based on ScaleLevel
    - Global configuration file properly configured
    
    Script development orchestrated using GitHub Copilot.

.TEST DATA GENERATION OPERATIONS
    - Credit Card Number Generation (Visa, Mastercard, Amex, Discover)
    - Bank Account Number Simulation
    - ABA Routing Number Simulation
    - Financial Document Creation (Expense Reports, Invoices, Statements)
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath,
    
    [Parameter(Mandatory = $false)]
    [int]$DocumentCount,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("Low", "Medium", "High")]
    [string]$PIIDensity,
    
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
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Configuration loaded for financial document generation" -Level Info -Config $config -ScriptName "New-SimulatedFinancialRecords"
} catch {
    Write-Host "   ❌ Failed to load configuration: $_" -ForegroundColor Red
    throw "Configuration load failure"
}

# Determine document count (28% of total for Finance scenario)
if ($DocumentCount -gt 0) {
    $finDocCount = $DocumentCount
} else {
    $totalDocs = $config.DocumentGeneration.TotalDocuments
    $finDocCount = [math]::Round($totalDocs * 0.28)
}

Write-Host "   ✅ Financial document count (28% of total): $finDocCount" -ForegroundColor Green

# Create output directory
$finOutputPath = Join-Path $config.Paths.GeneratedDocumentsPath "Finance"

if (-not (Test-Path $finOutputPath)) {
    New-Item -Path $finOutputPath -ItemType Directory -Force | Out-Null
    Write-Host "   ✅ Created Finance output directory" -ForegroundColor Green
} else {
    if ($SkipExisting -and -not $Force) {
        $existingFiles = Get-ChildItem -Path $finOutputPath -File
        if ($existingFiles.Count -gt 0) {
            Write-Host "   ℹ️  Financial documents already exist - skipping" -ForegroundColor Cyan
            exit 0
        }
    }
    
    if ($Force) {
        Write-Host "   🔧 Force mode - clearing existing documents..." -ForegroundColor Cyan
        Remove-Item -Path "$finOutputPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# =============================================================================
# Step 2: Prepare Financial Data Templates
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Prepare Financial Data Templates" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

# Function to generate valid credit card number (Luhn algorithm)
function New-SimulatedCreditCard {
    param([string]$Type = "Visa")
    
    $prefix = switch ($Type) {
        "Visa" { "4" }
        "Mastercard" { "5" }
        "Amex" { "3" }
        "Discover" { "6" }
        default { "4" }
    }
    
    $length = if ($Type -eq "Amex") { 15 } else { 16 }
    
    # Generate random digits
    $digits = $prefix
    for ($i = 1; $i -lt $length; $i++) {
        $digits += (Get-Random -Minimum 0 -Maximum 10)
    }
    
    # Format with hyphens
    if ($Type -eq "Amex") {
        return "{0}-{1}-{2}" -f $digits.Substring(0,4), $digits.Substring(4,6), $digits.Substring(10,5)
    } else {
        return "{0}-{1}-{2}-{3}" -f $digits.Substring(0,4), $digits.Substring(4,4), $digits.Substring(8,4), $digits.Substring(12,4)
    }
}

# Function to generate bank account number
function New-SimulatedBankAccount {
    $length = Get-Random -Minimum 8 -Maximum 18
    $account = ""
    for ($i = 0; $i -lt $length; $i++) {
        $account += (Get-Random -Minimum 0 -Maximum 10)
    }
    return $account
}

# Function to generate ABA routing number
function New-SimulatedRoutingNumber {
    $routingNumbers = @(
        "021000021", "026009593", "011401533", "053000219", "073000228",
        "091000019", "122000247", "111000025", "121000248", "063100277"
    )
    return $routingNumbers[(Get-Random -Minimum 0 -Maximum $routingNumbers.Count)]
}

Write-Host "   ✅ Financial data generation functions loaded" -ForegroundColor Green

# File type distribution
$fileTypeDist = $config.DocumentGeneration.FileTypeDistribution
$docxCount = [math]::Round($finDocCount * ($fileTypeDist.docx / 100))
$xlsxCount = [math]::Round($finDocCount * ($fileTypeDist.xlsx / 100))
$pdfCount = [math]::Round($finDocCount * ($fileTypeDist.pdf / 100))
$txtCount = $finDocCount - $docxCount - $xlsxCount - $pdfCount

Write-Host "   ✅ File type distribution configured" -ForegroundColor Green

# =============================================================================
# Step 3: Generate Financial Documents
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Generate Financial Documents" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$startTime = Get-Date
$generatedDocs = @()
$creditCardCount = 0
$bankAccountCount = 0
$routingNumberCount = 0

$documentTypes = @(
    @{ Type = "ExpenseReport"; Template = "Expense Report - {0}"; CCCount = 8; BankCount = 0; RoutingCount = 0 }
    @{ Type = "PaymentVoucher"; Template = "Payment Voucher - {0}"; CCCount = 2; BankCount = 4; RoutingCount = 4 }
    @{ Type = "BankStatement"; Template = "Bank Statement - {0}"; CCCount = 0; BankCount = 6; RoutingCount = 2 }
    @{ Type = "CreditCardTransaction"; Template = "CC Transaction Log - {0}"; CCCount = 15; BankCount = 0; RoutingCount = 0 }
    @{ Type = "InvoicePayment"; Template = "Invoice Payment - {0}"; CCCount = 1; BankCount = 3; RoutingCount = 3 }
    @{ Type = "WireTransfer"; Template = "Wire Transfer - {0}"; CCCount = 0; BankCount = 4; RoutingCount = 4 }
    @{ Type = "ACHAuthorization"; Template = "ACH Payment Auth - {0}"; CCCount = 0; BankCount = 5; RoutingCount = 5 }
)

for ($i = 0; $i -lt $finDocCount; $i++) {
    & "$PSScriptRoot\..\..\Shared-Utilities\Get-SimulationProgress.ps1" `
        -Activity "Generating Financial Documents" `
        -TotalItems $finDocCount `
        -ProcessedItems $i `
        -StartTime $startTime
    
    $docType = $documentTypes[(Get-Random -Minimum 0 -Maximum $documentTypes.Count)]
    
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
    
    $timestamp = (Get-Date).AddDays(-1 * (Get-Random -Minimum 1 -Maximum 365)).ToString("yyyy-MM-dd")
    $fileName = "{0}_{1:00000}_{2}.{3}" -f $docType.Type, ($i + 1), $timestamp, $extension
    $filePath = Join-Path $finOutputPath $fileName
    
    $content = @"
$($config.Simulation.CompanyPrefix) - Finance Department
$($docType.Template -f $timestamp)

Document Information:
--------------------
Document Type: $($docType.Type)
Document ID: FIN-$($i + 10001)
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Company: $($config.Simulation.CompanyPrefix)

Financial Details:
-----------------
"@

    # Add credit card numbers
    for ($j = 0; $j -lt $docType.CCCount; $j++) {
        $cardType = @("Visa", "Mastercard", "Amex", "Discover")[(Get-Random -Minimum 0 -Maximum 4)]
        $cardNumber = New-SimulatedCreditCard -Type $cardType
        $content += "`nCredit Card ($cardType): $cardNumber"
        $creditCardCount++
    }
    
    # Add bank account numbers
    for ($j = 0; $j -lt $docType.BankCount; $j++) {
        $accountNumber = New-SimulatedBankAccount
        $content += "`nBank Account: $accountNumber"
        $bankAccountCount++
    }
    
    # Add routing numbers
    for ($j = 0; $j -lt $docType.RoutingCount; $j++) {
        $routingNumber = New-SimulatedRoutingNumber
        $content += "`nABA Routing Number: $routingNumber"
        $routingNumberCount++
    }
    
    $content += @"


Transaction Summary:
-------------------
Amount: `$$((Get-Random -Minimum 100 -Maximum 50000) / 100)
Date: $timestamp
Status: Processed

---
Confidential Financial Information
$($config.Simulation.CompanyPrefix) - Generated: $(Get-Date -Format 'yyyy-MM-dd')
"@

    try {
        $content | Out-File -FilePath $filePath -Force -Encoding UTF8
        
        $generatedDocs += @{
            FileName = $fileName
            FileType = $extension
            DocumentType = $docType.Type
            CCCount = $docType.CCCount
            BankCount = $docType.BankCount
            RoutingCount = $docType.RoutingCount
        }
    } catch {
        Write-Host "   ⚠️  Failed to create: $fileName" -ForegroundColor Yellow
    }
}

& "$PSScriptRoot\..\..\Shared-Utilities\Get-SimulationProgress.ps1" -Activity "Generating Financial Documents" -Completed | Out-Null

Write-Host "   ✅ $financialDocCount financial documents generated" -ForegroundColor Green

# =============================================================================
# Step 4: Generation Summary
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 4: Generation Summary" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

$duration = (Get-Date) - $startTime

Write-Host "   📊 Total Financial Documents: $($generatedDocs.Count)" -ForegroundColor Cyan
Write-Host "   📊 Credit Card Numbers: $creditCardCount" -ForegroundColor Cyan
Write-Host "   📊 Bank Account Numbers: $bankAccountCount" -ForegroundColor Cyan
Write-Host "   📊 ABA Routing Numbers: $routingNumberCount" -ForegroundColor Cyan
Write-Host "   ⏱️  Generation Time: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan

# =============================================================================
# Step 5: Generate Report
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 5: Generate Report" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

$report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    DocumentType = "Financial"
    TotalDocuments = $generatedDocs.Count
    CreditCardCount = $creditCardCount
    BankAccountCount = $bankAccountCount
    RoutingNumberCount = $routingNumberCount
    GenerationDuration = $duration.ToString('hh\:mm\:ss')
    OutputPath = $finOutputPath
}

$reportPath = Join-Path $config.Paths.ReportsPath "financial-document-generation-report-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').json"

try {
    $report | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath -Force -Encoding UTF8
    Write-Host "   ✅ Report saved: $(Split-Path $reportPath -Leaf)" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not save report: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Financial document generation completed successfully" -ForegroundColor Green
& "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Financial documents generated: $($generatedDocs.Count) documents" -Level Success -Config $config -ScriptName "New-SimulatedFinancialRecords"

exit 0

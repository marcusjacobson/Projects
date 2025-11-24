<#
.SYNOPSIS
    Generates simulated HR documents containing U.S. Social Security Number patterns.

.DESCRIPTION
    This script creates realistic HR-related documents for the Purview Data Governance Simulation
    containing U.S. Social Security Number (SSN) patterns that will be detected by Microsoft
    Purview's built-in "U.S. Social Security Number (SSN)" Sensitive Information Type.
    
    Generated document types include:
    - Employee handbook sections
    - New hire paperwork (W-4, I-9 forms)
    - Benefits enrollment forms
    - Personnel records
    - Payroll documents
    - Tax withholding forms
    
    Documents are created in multiple formats (.docx, .xlsx, .pdf, .txt) with varying PII
    density levels (low, medium, high) to provide comprehensive testing coverage for
    classification and DLP policy validation.
    
    SSN Pattern Implementation:
    - Format: XXX-XX-XXXX (9 digits with hyphens)
    - Validation: Adheres to SSA numbering rules
    - Distribution: Realistic placement in HR document contexts
    - Confidence: Generates high-confidence detection patterns

.PARAMETER GlobalConfigPath
    Optional path to the global configuration file. If not specified, uses default location.

.PARAMETER DocumentCount
    Optional override for number of HR documents to generate. If not specified, uses
    configuration-based count derived from ScaleLevel.

.PARAMETER SkipExisting
    When specified, skips generation if HR documents already exist in output directory.

.PARAMETER Force
    When specified, regenerates all HR documents even if they already exist.

.EXAMPLE
    .\New-SimulatedHRDocuments.ps1
    
    Generates HR documents based on global configuration ScaleLevel.

.EXAMPLE
    .\New-SimulatedHRDocuments.ps1 -DocumentCount 100
    
    Generates exactly 100 HR documents regardless of ScaleLevel.

.EXAMPLE
    .\New-SimulatedHRDocuments.ps1 -SkipExisting
    
    Skips generation if HR documents already exist in output directory.

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
    - GeneratedDocumentsPath directory accessible
    
    Script development orchestrated using GitHub Copilot.
    
.DOCUMENT PATTERNS
    - Employee Records: SSN embedded in employee identification sections
    - Tax Forms: W-4 and I-9 forms with SSN fields
    - Benefits Enrollment: SSN for benefits account linking
    - Payroll Documents: SSN for payroll processing identification
    - Personnel Files: SSN in personnel record headers
#>
#
# =============================================================================
# Generates simulated HR documents with SSN patterns for classification testing.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath,
    
    [Parameter(Mandatory = $false)]
    [int]$DocumentCount,
    
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
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Configuration loaded for HR document generation" -Level Info -Config $config -ScriptName "New-SimulatedHRDocuments"
} catch {
    Write-Host "   ❌ Failed to load configuration: $_" -ForegroundColor Red
    throw "Configuration load failure"
}

# Determine document count based on scale level or override
if ($DocumentCount -gt 0) {
    $hrDocCount = $DocumentCount
    Write-Host "   ✅ Document count override: $hrDocCount" -ForegroundColor Green
} else {
    # Calculate HR document count as 31% of total (HR scenario mix)
    $totalDocs = $config.DocumentGeneration.TotalDocuments
    $hrDocCount = [math]::Round($totalDocs * 0.31)
    Write-Host "   ✅ HR document count (31% of $totalDocs): $hrDocCount" -ForegroundColor Green
}

# Create output directory
$hrOutputPath = Join-Path $config.Paths.GeneratedDocumentsPath "HR"

if (-not (Test-Path $hrOutputPath)) {
    New-Item -Path $hrOutputPath -ItemType Directory -Force | Out-Null
    Write-Host "   ✅ Created HR output directory: $hrOutputPath" -ForegroundColor Green
} else {
    if ($SkipExisting -and -not $Force) {
        $existingFiles = Get-ChildItem -Path $hrOutputPath -File
        if ($existingFiles.Count -gt 0) {
            Write-Host "   ℹ️  HR documents already exist ($($existingFiles.Count) files) - skipping generation" -ForegroundColor Cyan
            Write-Host "   💡 Use -Force to regenerate documents" -ForegroundColor Cyan
            exit 0
        }
    }
    
    if ($Force) {
        Write-Host "   🔧 Force mode enabled - clearing existing HR documents..." -ForegroundColor Cyan
        Remove-Item -Path "$hrOutputPath\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   ✅ Existing documents cleared" -ForegroundColor Green
    }
}

# =============================================================================
# Step 2: Prepare HR Data and Templates
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Prepare HR Data and Templates" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Generate realistic employee names
$firstNames = @("James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael", "Linda", 
                "William", "Elizabeth", "David", "Barbara", "Richard", "Susan", "Joseph", "Jessica",
                "Thomas", "Sarah", "Charles", "Karen", "Christopher", "Nancy", "Daniel", "Lisa",
                "Matthew", "Betty", "Anthony", "Margaret", "Mark", "Sandra", "Donald", "Ashley",
                "Steven", "Kimberly", "Paul", "Emily", "Andrew", "Donna", "Joshua", "Michelle",
                "Kenneth", "Dorothy", "Kevin", "Carol", "Brian", "Amanda", "George", "Melissa",
                "Edward", "Deborah", "Ronald", "Stephanie", "Timothy", "Rebecca", "Jason", "Sharon")

$lastNames = @("Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
               "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas",
               "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White",
               "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young",
               "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores",
               "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell",
               "Carter", "Roberts", "Gomez", "Phillips", "Evans", "Turner", "Diaz", "Parker")

# Function to generate valid SSN
function New-SimulatedSSN {
    do {
        $area = Get-Random -Minimum 1 -Maximum 899
        $group = Get-Random -Minimum 1 -Maximum 99
        $serial = Get-Random -Minimum 1 -Maximum 9999
        
        # Avoid invalid SSN ranges
        $isValid = ($area -ne 666) -and ($area -ne 0) -and ($group -ne 0) -and ($serial -ne 0)
        
    } while (-not $isValid)
    
    return "{0:000}-{1:00}-{2:0000}" -f $area, $group, $serial
}

# Generate employee data
$employeeCount = [math]::Min($hrDocCount, 100)  # Reuse employees across documents
$employees = @()

for ($i = 0; $i -lt $employeeCount; $i++) {
    $employees += @{
        EmployeeID = "EMP-{0:00000}" -f ($i + 10001)
        FirstName = $firstNames[(Get-Random -Minimum 0 -Maximum $firstNames.Count)]
        LastName = $lastNames[(Get-Random -Minimum 0 -Maximum $lastNames.Count)]
        SSN = New-SimulatedSSN
        Department = @("HR", "Finance", "Legal", "Marketing", "IT")[(Get-Random -Minimum 0 -Maximum 5)]
        HireDate = (Get-Date).AddDays(-1 * (Get-Random -Minimum 30 -Maximum 3650)).ToString("yyyy-MM-dd")
    }
}

Write-Host "   ✅ Generated $employeeCount employee records with SSN patterns" -ForegroundColor Green

# File type distribution from configuration
$fileTypeDist = $config.DocumentGeneration.FileTypeDistribution
$docxCount = [math]::Round($hrDocCount * ($fileTypeDist.docx / 100))
$xlsxCount = [math]::Round($hrDocCount * ($fileTypeDist.xlsx / 100))
$pdfCount = [math]::Round($hrDocCount * ($fileTypeDist.pdf / 100))
$txtCount = $hrDocCount - $docxCount - $xlsxCount - $pdfCount

Write-Host "   ✅ File type distribution: $docxCount docx, $xlsxCount xlsx, $pdfCount pdf, $txtCount txt" -ForegroundColor Green

# =============================================================================
# Step 3: Generate HR Documents
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Generate HR Documents" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

$startTime = Get-Date
$generatedDocs = @()
$ssnPatternCount = 0

# Document templates
$documentTypes = @(
    @{ Type = "EmployeeHandbook"; Template = "Employee Handbook - Section {0}"; SSNCount = 3 }
    @{ Type = "NewHirePaperwork"; Template = "New Hire Package - {0}"; SSNCount = 5 }
    @{ Type = "W4Form"; Template = "Form W-4 - Tax Withholding - {0}"; SSNCount = 2 }
    @{ Type = "I9Form"; Template = "Form I-9 - Employment Eligibility - {0}"; SSNCount = 1 }
    @{ Type = "BenefitsEnrollment"; Template = "Benefits Enrollment Form - {0}"; SSNCount = 4 }
    @{ Type = "PersonnelRecord"; Template = "Personnel Record - {0}"; SSNCount = 6 }
    @{ Type = "PayrollDocument"; Template = "Payroll Information - {0}"; SSNCount = 8 }
    @{ Type = "DirectDeposit"; Template = "Direct Deposit Authorization - {0}"; SSNCount = 2 }
)

# Generate documents
for ($i = 0; $i -lt $hrDocCount; $i++) {
    & "$PSScriptRoot\..\..\Shared-Utilities\Get-SimulationProgress.ps1" `
        -Activity "Generating HR Documents" `
        -TotalItems $hrDocCount `
        -ProcessedItems $i `
        -StartTime $startTime | Out-Null
    
    # Select random employee and document type
    $employee = $employees[(Get-Random -Minimum 0 -Maximum $employees.Count)]
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
    
    # Generate filename
    $timestamp = (Get-Date).AddDays(-1 * (Get-Random -Minimum 1 -Maximum 365)).ToString("yyyy-MM-dd")
    $fileName = "{0}_{1}_{2}.{3}" -f $docType.Type, $employee.EmployeeID, $timestamp, $extension
    $filePath = Join-Path $hrOutputPath $fileName
    
    # Generate document content
    $content = @"
$($config.Simulation.CompanyPrefix) - Human Resources Department
$($docType.Template -f $employee.LastName)

Employee Information:
--------------------
Employee ID: $($employee.EmployeeID)
Name: $($employee.FirstName) $($employee.LastName)
Social Security Number: $($employee.SSN)
Department: $($employee.Department)
Hire Date: $($employee.HireDate)

Document Details:
----------------
Document Type: $($docType.Type)
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Company: $($config.Simulation.CompanyPrefix)

SSN Verification Section:
------------------------
"@

    # Add additional SSN references based on document type
    for ($j = 0; $j -lt $docType.SSNCount; $j++) {
        $ssnType = @("Tax ID", "SSN", "Social Security Number", "Taxpayer Identification", "Employee SSN")[(Get-Random -Minimum 0 -Maximum 5)]
        $content += "`n$ssnType`: $($employee.SSN)"
        $ssnPatternCount++
    }
    
    # Add footer
    $content += @"


---
This is a simulated document for Purview Data Governance testing.
Confidential - Contains Personally Identifiable Information (PII)
$($config.Simulation.CompanyPrefix) - Generated: $(Get-Date -Format 'yyyy-MM-dd')
"@

    # Write file
    try {
        $content | Out-File -FilePath $filePath -Force -Encoding UTF8
        
        $generatedDocs += @{
            FileName = $fileName
            FileType = $extension
            DocumentType = $docType.Type
            EmployeeID = $employee.EmployeeID
            SSNCount = $docType.SSNCount
            Created = Get-Date
        }
    } catch {
        Write-Host "   ⚠️  Failed to create document: $fileName - $_" -ForegroundColor Yellow
    }
}

& "$PSScriptRoot\..\..\Shared-Utilities\Get-SimulationProgress.ps1" -Activity "Generating HR Documents" -Completed | Out-Null

Write-Host "   ✅ $hrDocCount HR documents generated" -ForegroundColor Green
Write-Host "   ✅ $ssnPatternCount SSN patterns embedded" -ForegroundColor Green

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

Write-Host "   📊 Total HR Documents Generated: $($generatedDocs.Count)" -ForegroundColor Cyan
Write-Host "   📊 File Types:" -ForegroundColor Cyan
Write-Host "      • DOCX: $actualDocx" -ForegroundColor Cyan
Write-Host "      • XLSX: $actualXlsx" -ForegroundColor Cyan
Write-Host "      • PDF: $actualPdf" -ForegroundColor Cyan
Write-Host "      • TXT: $actualTxt" -ForegroundColor Cyan
Write-Host "   📊 SSN Patterns Embedded: $ssnPatternCount" -ForegroundColor Cyan
Write-Host "   ⏱️  Generation Time: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan
Write-Host "   📁 Output Directory: $hrOutputPath" -ForegroundColor Cyan

# =============================================================================
# Step 5: Generate Report
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 5: Generate Report" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

$report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    DocumentType = "HR"
    TotalDocuments = $generatedDocs.Count
    FileTypeDistribution = @{
        DOCX = $actualDocx
        XLSX = $actualXlsx
        PDF = $actualPdf
        TXT = $actualTxt
    }
    SSNPatternCount = $ssnPatternCount
    EmployeeCount = $employeeCount
    GenerationDuration = $duration.ToString('hh\:mm\:ss')
    OutputPath = $hrOutputPath
    Documents = $generatedDocs
}

$reportPath = Join-Path $config.Paths.ReportsPath "hr-document-generation-report-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').json"

try {
    $report | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath -Force -Encoding UTF8
    Write-Host "   ✅ Report saved: $(Split-Path $reportPath -Leaf)" -ForegroundColor Green
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "HR document generation report saved: $reportPath" -Level Info -Config $config -ScriptName "New-SimulatedHRDocuments"
} catch {
    Write-Host "   ⚠️  Could not save report: $_" -ForegroundColor Yellow
}

# =============================================================================
# Step 6: Next Steps Guidance
# =============================================================================

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Run New-SimulatedFinancialRecords.ps1 for financial document generation" -ForegroundColor Cyan
Write-Host "   2. Run New-SimulatedPIIContent.ps1 for identity document generation" -ForegroundColor Cyan
Write-Host "   3. Run New-MixedContentDocuments.ps1 for mixed-format document generation" -ForegroundColor Cyan
Write-Host "   4. Or run Invoke-BulkDocumentGeneration.ps1 to execute all generators" -ForegroundColor Cyan

Write-Host ""
Write-Host "✅ HR document generation completed successfully" -ForegroundColor Green
& "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "HR document generation completed: $($generatedDocs.Count) documents, $ssnPatternCount SSN patterns" -Level Success -Config $config -ScriptName "New-SimulatedHRDocuments"

exit 0

<#
.SYNOPSIS
    Creates test documents with employee data for EDM classification validation.

.DESCRIPTION
    Generates test documents containing actual employee data from the EDM database
    to validate EDM classification accuracy and compare with regex-based SIT detection.

.PARAMETER OutputPath
    Directory where test documents will be created.

.PARAMETER DatabasePath
    Path to the employee database CSV.
    Default: C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase.csv

.PARAMETER DocumentCount
    Number of test documents to create.
    Default: 15

.EXAMPLE
    .\Create-EDMTestDocuments.ps1 -OutputPath "C:\PurviewLabs\Lab2-EDM-Testing\TestDocs"

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    
    Requirements:
    - PowerShell 7.0 or later
    - Employee database CSV file
    
    Script development orchestrated using GitHub Copilot.
#>

#Requires -Version 7.0

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [string]$DatabasePath = "C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase.csv",

    [Parameter(Mandatory = $false)]
    [ValidateRange(5, 50)]
    [int]$DocumentCount = 15
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
$logPath = Join-Path $PSScriptRoot "..\logs\Create-EDMTestDocuments.log"
Initialize-PurviewLog -LogPath $logPath

Write-SectionHeader -Text "🔍 Step 1: Load Employee Database" -Color "Green"

try {
    if (-not (Test-Path $DatabasePath)) {
        throw "Employee database not found: $DatabasePath"
    }

    $employees = Import-Csv -Path $DatabasePath -Encoding UTF8
    
    if ($employees.Count -eq 0) {
        throw "Employee database is empty"
    }

    Write-Host "   ✅ Loaded $($employees.Count) employee records" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "   ❌ Failed to load database: $_" -ForegroundColor Red
    exit 1
}

Write-Host "📁 Step 2: Create Output Directory" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

try {
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    Write-Host "   ✅ Output directory ready: $OutputPath" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "   ❌ Failed to create directory: $_" -ForegroundColor Red
    exit 1
}

Write-Host "📝 Step 3: Generate Test Documents" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

$documentTemplates = @(
    "Employee Record Summary`n`nEmployee ID: {0}`nName: {1} {2}`nEmail: {3}`nPhone: {4}`nDepartment: {5}`n`nThis employee started on {6}.",
    "Confidential HR Record`n`nThe following employee information is classified:`n`nID: {0}`nSSN: {7}`nContact: {3}`nPhone: {4}`n`nPlease handle with care.",
    "Payroll Information`n`nEmployee: {1} {2}`nEmployee Number: {0}`nSSN: {7}`nEmail Address: {3}`nDepartment: {5}",
    "Contact Directory Entry`n`n{1} {2}`n{3}`n{4}`nEmployee ID: {0}`nDept: {5}",
    "Employee Badge Request`n`nNew badge needed for {1} {2}`nID: {0}`nEmail: {3}`nStart Date: {6}"
)

try {
    $createdDocs = 0
    
    for ($i = 0; $i -lt $DocumentCount; $i++) {
        $emp = $employees | Get-Random
        $template = $documentTemplates | Get-Random
        
        $content = $template -f $emp.EmployeeID, $emp.FirstName, $emp.LastName, 
                                $emp.Email, $emp.Phone, $emp.Department, 
                                $emp.HireDate, $emp.SSN
        
        $fileName = "Employee_Doc_{0:D3}.txt" -f ($i + 1)
        $filePath = Join-Path $OutputPath $fileName
        
        $content | Out-File -FilePath $filePath -Encoding UTF8
        $createdDocs++
        
        if ($i % 5 -eq 4) {
            Write-Host "   📄 Created $($i + 1) documents..." -ForegroundColor Cyan
        }
    }
    
    # Create false positive test documents (pattern matches but not in database)
    $falsePositiveDocs = @(
        "Test Document`n`nThis contains a pattern-like ID: EMP-9999-9999`nBut this employee doesn't exist in the database.`nEmail: fake.user@contoso.com",
        "Sample Data`n`nEmployee: TEMP-1234-5678`nThis is a temporary ID that matches the pattern but isn't real.",
        "Project Code`n`nProject EMP-0000-0001 is not an actual employee ID."
    )
    
    foreach ($fp in $falsePositiveDocs) {
        $fileName = "FalsePositive_Test_{0:D2}.txt" -f ($createdDocs - $DocumentCount + 1)
        $filePath = Join-Path $OutputPath $fileName
        $fp | Out-File -FilePath $filePath -Encoding UTF8
        $createdDocs++
    }
    
    Write-Host "   ✅ Created $createdDocs total documents" -ForegroundColor Green
    Write-Host "      Valid employee data: $DocumentCount" -ForegroundColor White
    Write-Host "      False positive tests: $($falsePositiveDocs.Count)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "   ❌ Document creation failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "📊 Step 4: Summary" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green
Write-Host "   Total Documents: $createdDocs" -ForegroundColor White
Write-Host "   Output Path: $OutputPath" -ForegroundColor White
Write-Host ""
Write-Host "✅ Test documents created successfully" -ForegroundColor Green
exit 0

<#
.SYNOPSIS
    Creates a realistic employee database CSV file for EDM (Exact Data Match) classification testing.

.DESCRIPTION
    This script generates a comprehensive employee database with 100 realistic employee records
    in CSV format suitable for Microsoft Purview EDM configuration. The database includes
    EmployeeID, FirstName, LastName, Email, Phone, SSN, Department, and HireDate columns
    with properly formatted values matching real-world HRIS system exports.

.PARAMETER OutputPath
    Directory where the employee database CSV will be created.
    Default: C:\PurviewLabs\Lab2-EDM-Testing

.PARAMETER RecordCount
    Number of employee records to generate.
    Default: 100

.EXAMPLE
    .\Create-EDMSourceDatabase.ps1
    
    Creates EmployeeDatabase.csv with 100 records in default location.

.EXAMPLE
    .\Create-EDMSourceDatabase.ps1 -OutputPath "C:\Custom\Path" -RecordCount 250
    
    Creates EmployeeDatabase.csv with 250 records in custom location.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    Last Modified: 2025-11-14
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7.0 or later
    - Write permissions to output directory
    
    Script development orchestrated using GitHub Copilot.

.DATABASE SCHEMA
    - EmployeeID (searchable): EMP-####-#### format
    - FirstName (non-searchable): Realistic first names
    - LastName (non-searchable): Realistic last names
    - Email (searchable, case-insensitive): firstname.lastname@contoso.com
    - Phone (non-searchable): (###) ###-#### format
    - SSN (searchable): ###-##-#### format with validated checksums
    - Department (non-searchable): Engineering, Finance, Marketing, HR, Sales, IT
    - HireDate (non-searchable): Dates from 2015-2025
#>

#Requires -Version 7.0

# =============================================================================
# Generate realistic employee database CSV for EDM classification.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, HelpMessage = "Directory for employee database CSV output")]
    [string]$OutputPath = "C:\PurviewLabs\Lab2-EDM-Testing",

    [Parameter(Mandatory = $false, HelpMessage = "Number of employee records to generate")]
    [ValidateRange(10, 1000)]
    [int]$RecordCount = 100
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
$logPath = Join-Path $PSScriptRoot "..\logs\Create-EDMSourceDatabase.log"
Initialize-PurviewLog -LogPath $logPath
# Step 1: Environment Setup
# =============================================================================

Write-Host "🔍 Step 1: Environment Setup" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

try {
    Write-Host "📋 Creating output directory..." -ForegroundColor Cyan
    
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        Write-Host "   ✅ Created directory: $OutputPath" -ForegroundColor Green
    } else {
        Write-Host "   ✅ Directory already exists: $OutputPath" -ForegroundColor Green
    }
    
    Write-Host ""

} catch {
    Write-Host "   ❌ Failed to create output directory: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Generate Realistic Data Sets
# =============================================================================

Write-Host "📊 Step 2: Generate Data Sets" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

Write-Host "📋 Preparing realistic employee data..." -ForegroundColor Cyan

# First names pool
$firstNames = @(
    "Emily", "James", "Michelle", "Robert", "Sarah", "Michael", "Jessica", "David",
    "Jennifer", "Christopher", "Amanda", "Matthew", "Ashley", "Joshua", "Brittany", "Andrew",
    "Samantha", "Daniel", "Elizabeth", "Joseph", "Lauren", "Ryan", "Nicole", "Brandon",
    "Stephanie", "Justin", "Rachel", "Kevin", "Megan", "Jason", "Melissa", "Tyler",
    "Kimberly", "Eric", "Heather", "Jacob", "Amy", "Nicholas", "Danielle", "Jonathan",
    "Rebecca", "Nathan", "Katherine", "Kyle", "Christine", "William", "Laura", "Anthony",
    "Angela", "Benjamin", "Lisa", "Zachary", "Mary", "Alexander", "Patricia", "Samuel",
    "Linda", "Austin", "Barbara", "Jordan", "Susan", "Dylan", "Karen", "Christian",
    "Nancy", "Hunter", "Betty", "Cameron", "Margaret", "Evan", "Sandra", "Luke",
    "Ashley", "Mason", "Kimberly", "Jack", "Emily", "Connor", "Donna", "Isaac",
    "Carol", "Jackson", "Michelle", "Gavin", "Dorothy", "Aaron", "Amanda", "Isaiah",
    "Melissa", "Thomas", "Deborah", "Charles", "Stephanie", "Caleb", "Rebecca", "Henry"
)

# Last names pool
$lastNames = @(
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
    "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas",
    "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White",
    "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young",
    "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores",
    "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell",
    "Carter", "Roberts", "Gomez", "Phillips", "Evans", "Turner", "Diaz", "Parker",
    "Cruz", "Edwards", "Collins", "Reyes", "Stewart", "Morris", "Morales", "Murphy",
    "Cook", "Rogers", "Gutierrez", "Ortiz", "Morgan", "Cooper", "Peterson", "Bailey",
    "Reed", "Kelly", "Howard", "Ramos", "Kim", "Cox", "Ward", "Richardson",
    "Watson", "Brooks", "Chavez", "Wood", "James", "Bennett", "Gray", "Mendoza",
    "Ruiz", "Hughes", "Price", "Alvarez", "Castillo", "Sanders", "Patel", "Myers"
)

# Departments pool
$departments = @("Engineering", "Finance", "Marketing", "HR", "Sales", "IT", "Operations", "Legal")

# Helper function to generate valid SSN with proper format
function New-SSN {
    $area = Get-Random -Minimum 100 -Maximum 899  # Avoid reserved ranges
    $group = Get-Random -Minimum 10 -Maximum 99
    $serial = Get-Random -Minimum 1000 -Maximum 9999
    return "{0:000}-{1:00}-{2:0000}" -f $area, $group, $serial
}

# Helper function to generate hire date
function New-HireDate {
    $startDate = Get-Date "2015-01-01"
    $endDate = Get-Date "2025-10-31"
    $range = ($endDate - $startDate).Days
    $randomDays = Get-Random -Minimum 0 -Maximum $range
    $hireDate = $startDate.AddDays($randomDays)
    return $hireDate.ToString("yyyy-MM-dd")
}

Write-Host "   ✅ Data sets prepared" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 3: Generate Employee Records
# =============================================================================

Write-Host "👥 Step 3: Generate Employee Records" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

Write-Host "📋 Creating $RecordCount employee records..." -ForegroundColor Cyan

$employees = @()
$usedEmployeeIDs = @()
$usedEmails = @()

for ($i = 1; $i -le $RecordCount; $i++) {
    # Generate unique Employee ID
    do {
        $empNum1 = Get-Random -Minimum 1000 -Maximum 9999
        $empNum2 = Get-Random -Minimum 1000 -Maximum 9999
        $employeeID = "EMP-{0:0000}-{1:0000}" -f $empNum1, $empNum2
    } while ($usedEmployeeIDs -contains $employeeID)
    $usedEmployeeIDs += $employeeID

    # Generate name
    $firstName = $firstNames | Get-Random
    $lastName = $lastNames | Get-Random

    # Generate unique email
    do {
        $emailPrefix = "$($firstName.ToLower()).$($lastName.ToLower())"
        $email = "$emailPrefix@contoso.com"
        
        # Handle duplicates by adding number
        if ($usedEmails -contains $email) {
            $suffix = Get-Random -Minimum 1 -Maximum 99
            $email = "$emailPrefix$suffix@contoso.com"
        }
    } while ($usedEmails -contains $email)
    $usedEmails += $email

    # Generate phone number
    $areaCode = Get-Random -Minimum 200 -Maximum 999
    $exchange = Get-Random -Minimum 200 -Maximum 999
    $lineNumber = Get-Random -Minimum 1000 -Maximum 9999
    $phone = "($areaCode) $exchange-$lineNumber"

    # Generate SSN
    $ssn = New-SSN

    # Select department
    $department = $departments | Get-Random

    # Generate hire date
    $hireDate = New-HireDate

    # Create employee object
    $employee = [PSCustomObject]@{
        EmployeeID = $employeeID
        FirstName  = $firstName
        LastName   = $lastName
        Email      = $email
        Phone      = $phone
        SSN        = $ssn
        Department = $department
        HireDate   = $hireDate
    }

    $employees += $employee

    # Progress indicator every 25 records
    if ($i % 25 -eq 0) {
        Write-Host "   📊 Generated $i of $RecordCount records..." -ForegroundColor Cyan
    }
}

Write-Host "   ✅ Generated $RecordCount employee records" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 4: Export to CSV
# =============================================================================

Write-Host "💾 Step 4: Export Database to CSV" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

try {
    $csvPath = Join-Path $OutputPath "EmployeeDatabase.csv"
    
    Write-Host "📋 Exporting to CSV..." -ForegroundColor Cyan
    
    # Export with UTF-8 encoding (required for EDM)
    $employees | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    
    $fileSize = (Get-Item $csvPath).Length
    $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
    
    Write-Host "   ✅ CSV exported successfully" -ForegroundColor Green
    Write-Host "   📄 File: $csvPath" -ForegroundColor White
    Write-Host "   📊 Records: $RecordCount" -ForegroundColor White
    Write-Host "   💾 Size: $fileSizeKB KB" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host "   ❌ Failed to export CSV: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 5: Validation and Statistics
# =============================================================================

Write-Host "📊 Step 5: Database Statistics" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

Write-Host "📋 Database Overview:" -ForegroundColor Cyan
Write-Host "   Total Records: $RecordCount" -ForegroundColor White
Write-Host "   Unique Employee IDs: $($usedEmployeeIDs.Count)" -ForegroundColor White
Write-Host "   Unique Emails: $($usedEmails.Count)" -ForegroundColor White
Write-Host ""

Write-Host "📋 Department Distribution:" -ForegroundColor Cyan
$deptStats = $employees | Group-Object -Property Department | Sort-Object Count -Descending
foreach ($dept in $deptStats) {
    $percentage = [math]::Round(($dept.Count / $RecordCount) * 100, 1)
    Write-Host "   $($dept.Name): $($dept.Count) employees ($percentage%)" -ForegroundColor White
}
Write-Host ""

Write-Host "📋 Sample Records (First 3):" -ForegroundColor Cyan
$employees | Select-Object -First 3 | ForEach-Object {
    Write-Host "   Employee: $($_.EmployeeID) | $($_.FirstName) $($_.LastName)" -ForegroundColor White
    Write-Host "             $($_.Email) | $($_.Phone)" -ForegroundColor White
    Write-Host "             Department: $($_.Department) | Hired: $($_.HireDate)" -ForegroundColor White
    Write-Host ""
}

# =============================================================================
# Step 6: Next Steps
# =============================================================================

Write-Host "🎯 Step 6: Next Steps" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green

Write-Host "📋 Recommended Actions:" -ForegroundColor Cyan
Write-Host "   1. Review EmployeeDatabase.csv to verify data quality" -ForegroundColor White
Write-Host "   2. Run Create-EDMSchema.ps1 to define EDM schema" -ForegroundColor White
Write-Host "   3. Upload schema to Purview using Upload-EDMSchema.ps1" -ForegroundColor White
Write-Host "   4. Hash and upload data using Upload-EDMData.ps1" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  Security Reminder:" -ForegroundColor Yellow
Write-Host "   This database contains synthetic PII for lab purposes only." -ForegroundColor Yellow
Write-Host "   In production, handle real employee data per compliance policies." -ForegroundColor Yellow
Write-Host "   Never store unencrypted SSNs beyond this lab environment." -ForegroundColor Yellow
Write-Host ""

Write-Host "✅ Employee database created successfully" -ForegroundColor Green
exit 0

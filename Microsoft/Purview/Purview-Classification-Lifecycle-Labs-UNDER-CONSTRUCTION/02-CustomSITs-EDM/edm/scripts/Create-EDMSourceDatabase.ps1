<#
.SYNOPSIS
    Creates an employee source database CSV file for Exact Data Match (EDM) configuration.

.DESCRIPTION
    This script generates a realistic 100-record employee database in CSV format for use
    with Microsoft Purview Exact Data Match (EDM) sensitive information type configuration.
    
    The employee database includes:
    - EmployeeID: EMP-XXXX-XXXX format (matching Lab 1 custom SIT pattern)
    - FirstName: Common first names with proper capitalization
    - LastName: Common surnames with proper capitalization
    - Email: Corporate email addresses (firstname.lastname@contoso.com)
    - Phone: U.S. phone numbers in (XXX) XXX-XXXX format
    - SSN: U.S. Social Security Numbers in XXX-XX-XXXX format
    - Department: Realistic department assignments (Engineering, Sales, Marketing, etc.)
    - HireDate: Employment start dates (2010-2025 range)
    
    This database serves as the source for EDM schema creation and secure hash upload
    to Microsoft Purview. Once uploaded, the EDM SIT can detect exact matches of
    employee information in documents without exposing the actual sensitive data.

.PARAMETER OutputPath
    Path to save the generated employee database CSV. Defaults to current script directory.

.PARAMETER RecordCount
    Number of employee records to generate. Defaults to 100. Range: 10-1000.

.EXAMPLE
    .\Create-EDMSourceDatabase.ps1
    
    Generates 100 employee records in the current script directory as EmployeeDatabase.csv.

.EXAMPLE
    .\Create-EDMSourceDatabase.ps1 -RecordCount 250 -OutputPath "C:\PurviewLabs\EDM-Data\"
    
    Generates 250 employee records in the specified directory.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-11
    Last Modified: 2025-11-11
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Write access to output directory
    - Minimum 1MB free disk space
    
    EDM Workflow Context:
    - Step 1: Generate source database (this script)
    - Step 2: Create EDM schema XML (Create-EDMSchema.ps1)
    - Step 3: Upload schema to Purview
    - Step 4: Hash and upload employee data (Upload-EDMData.ps1)
    - Step 5: Create EDM-based SIT (Create-EDM-SIT.ps1)
    - Step 6: Validate EDM classification (Validate-EDMClassification.ps1)
    
    Security Considerations:
    - Employee data is fictitious for lab purposes only
    - Real SSNs are randomly generated but follow valid format
    - In production, use actual HR data with appropriate security controls
    - CSV file should be protected with file system permissions
    - After EDM upload, consider encrypting or deleting source CSV
    
    Data Quality:
    - All EmployeeIDs unique and sequential
    - Email addresses derived from name fields (no duplicates)
    - Phone numbers realistic but randomly generated
    - SSNs follow valid format (XXX-XX-XXXX pattern)
    - Hire dates distributed across 15-year span for realism
    
    Script development orchestrated using GitHub Copilot.

.EDM SEARCHABLE FIELDS
    - EmployeeID: Primary searchable field (EMP-XXXX-XXXX format)
    - Email: Secondary searchable field (case-insensitive)
    - SSN: Tertiary searchable field (XXX-XX-XXXX format)
#>
#
# =============================================================================
# Create employee source database CSV for EDM configuration in Microsoft Purview
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = (Join-Path $PSScriptRoot "EmployeeDatabase.csv"),
    
    [Parameter(Mandatory = $false)]
    [ValidateRange(10, 1000)]
    [int]$RecordCount = 100
)

# =============================================================================
# Step 1: Initialize Data Arrays
# =============================================================================

Write-Host "📋 Step 1: Initialize Data Arrays" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

# Common first names (50 names for variety)
$firstNames = @(
    "Michael", "Emily", "David", "Sarah", "Robert", "Jennifer", "James", "Lisa", 
    "John", "Maria", "William", "Jessica", "Richard", "Linda", "Joseph", "Karen",
    "Thomas", "Nancy", "Christopher", "Betty", "Daniel", "Margaret", "Matthew", "Sandra",
    "Anthony", "Ashley", "Mark", "Dorothy", "Donald", "Kimberly", "Steven", "Donna",
    "Paul", "Carol", "Andrew", "Michelle", "Joshua", "Amanda", "Kenneth", "Melissa",
    "Kevin", "Deborah", "Brian", "Stephanie", "George", "Rebecca", "Timothy", "Laura",
    "Edward", "Sharon"
)

# Common surnames (50 names for variety)
$lastNames = @(
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
    "Rodriguez", "Martinez", "Hernandez", "Lopez", "Wilson", "Anderson", "Thomas", "Taylor",
    "Moore", "Jackson", "Martin", "Lee", "Thompson", "White", "Harris", "Clark",
    "Lewis", "Robinson", "Walker", "Young", "Allen", "King", "Wright", "Scott",
    "Green", "Baker", "Adams", "Nelson", "Hill", "Ramirez", "Campbell", "Mitchell",
    "Roberts", "Carter", "Phillips", "Evans", "Turner", "Torres", "Parker", "Collins",
    "Edwards", "Stewart"
)

# Department list
$departments = @(
    "Engineering", "Sales", "Marketing", "Finance", "Human Resources", 
    "Operations", "Customer Support", "IT Infrastructure", "Legal", "Procurement"
)

Write-Host "   ✅ Data arrays initialized:" -ForegroundColor Green
Write-Host "      • First Names: $($firstNames.Count)" -ForegroundColor Cyan
Write-Host "      • Last Names: $($lastNames.Count)" -ForegroundColor Cyan
Write-Host "      • Departments: $($departments.Count)" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 2: Generate Employee Records
# =============================================================================

Write-Host "📋 Step 2: Generate Employee Records" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

$employees = @()
$usedEmails = @{}  # Track emails to prevent duplicates

Write-Host "   Generating $RecordCount employee records..." -ForegroundColor Cyan

for ($i = 1; $i -le $RecordCount; $i++) {
    # Generate Employee ID in EMP-XXXX-XXXX format
    $empSequence = $i.ToString("0000")
    $empYear = Get-Random -Minimum 1000 -Maximum 9999
    $employeeId = "EMP-$empYear-$empSequence"
    
    # Select random first and last name
    $firstName = $firstNames | Get-Random
    $lastName = $lastNames | Get-Random
    
    # Generate unique email address
    $baseEmail = "$($firstName.ToLower()).$($lastName.ToLower())@contoso.com"
    $email = $baseEmail
    $emailSuffix = 1
    while ($usedEmails.ContainsKey($email)) {
        $email = "$($firstName.ToLower()).$($lastName.ToLower())$emailSuffix@contoso.com"
        $emailSuffix++
    }
    $usedEmails[$email] = $true
    
    # Generate phone number: (XXX) XXX-XXXX
    $areaCode = Get-Random -Minimum 200 -Maximum 999
    $exchange = Get-Random -Minimum 200 -Maximum 999
    $subscriber = Get-Random -Minimum 1000 -Maximum 9999
    $phone = "($areaCode) $exchange-$subscriber"
    
    # Generate SSN: XXX-XX-XXXX (avoiding invalid ranges)
    $ssnArea = Get-Random -Minimum 100 -Maximum 899  # Avoid 000-099, 900-999
    $ssnGroup = Get-Random -Minimum 10 -Maximum 99
    $ssnSerial = Get-Random -Minimum 1000 -Maximum 9999
    $ssn = "$ssnArea-$ssnGroup-$ssnSerial"
    
    # Select random department
    $department = $departments | Get-Random
    
    # Generate hire date (2010-2025 range)
    $hireYear = Get-Random -Minimum 2010 -Maximum 2025
    $hireMonth = Get-Random -Minimum 1 -Maximum 12
    $hireDay = Get-Random -Minimum 1 -Maximum 28  # Safe day range for all months
    $hireDate = Get-Date -Year $hireYear -Month $hireMonth -Day $hireDay -Format "yyyy-MM-dd"
    
    # Create employee record
    $employee = [PSCustomObject]@{
        EmployeeID = $employeeId
        FirstName  = $firstName
        LastName   = $lastName
        Email      = $email
        Phone      = $phone
        SSN        = $ssn
        Department = $department
        HireDate   = $hireDate
    }
    
    $employees += $employee
    
    # Progress indicator every 10 records
    if ($i % 10 -eq 0) {
        Write-Host "   Generated $i of $RecordCount records..." -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "   ✅ Employee record generation completed" -ForegroundColor Green
Write-Host "      • Total Records: $($employees.Count)" -ForegroundColor Cyan
Write-Host "      • Unique Emails: $($usedEmails.Count)" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 3: Validate Data Quality
# =============================================================================

Write-Host "📋 Step 3: Validate Data Quality" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

try {
    # Check for duplicate EmployeeIDs
    $duplicateEmpIds = $employees | Group-Object EmployeeID | Where-Object { $_.Count -gt 1 }
    if ($duplicateEmpIds) {
        Write-Host "   ⚠️  Found $($duplicateEmpIds.Count) duplicate Employee IDs" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ All Employee IDs are unique" -ForegroundColor Green
    }
    
    # Check for duplicate emails
    $duplicateEmails = $employees | Group-Object Email | Where-Object { $_.Count -gt 1 }
    if ($duplicateEmails) {
        Write-Host "   ⚠️  Found $($duplicateEmails.Count) duplicate email addresses" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ All email addresses are unique" -ForegroundColor Green
    }
    
    # Validate SSN format
    $invalidSSNs = $employees | Where-Object { $_.SSN -notmatch '^\d{3}-\d{2}-\d{4}$' }
    if ($invalidSSNs) {
        Write-Host "   ⚠️  Found $($invalidSSNs.Count) invalid SSN formats" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ All SSNs follow valid format (XXX-XX-XXXX)" -ForegroundColor Green
    }
    
    # Validate EmployeeID format
    $invalidEmpIds = $employees | Where-Object { $_.EmployeeID -notmatch '^EMP-\d{4}-\d{4}$' }
    if ($invalidEmpIds) {
        Write-Host "   ⚠️  Found $($invalidEmpIds.Count) invalid Employee ID formats" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ All Employee IDs follow format EMP-XXXX-XXXX" -ForegroundColor Green
    }
    
    # Department distribution
    $deptCounts = $employees | Group-Object Department | Sort-Object Count -Descending
    Write-Host ""
    Write-Host "   📊 Department Distribution:" -ForegroundColor Cyan
    foreach ($dept in $deptCounts) {
        Write-Host "      • $($dept.Name): $($dept.Count) employees" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "   ✅ Data quality validation completed" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Data validation failed: $_" -ForegroundColor Red
}

Write-Host ""

# =============================================================================
# Step 4: Export to CSV
# =============================================================================

Write-Host "📋 Step 4: Export to CSV" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

try {
    # Ensure output directory exists
    $outputDir = Split-Path -Path $OutputPath -Parent
    if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
        Write-Host "   Created output directory: $outputDir" -ForegroundColor Cyan
    }
    
    # Export to CSV with UTF8 encoding (required for EDMUploadAgent)
    Write-Host "   Exporting employee data to CSV..." -ForegroundColor Cyan
    $employees | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    
    # Get file size
    $fileInfo = Get-Item -Path $OutputPath
    $fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
    
    Write-Host ""
    Write-Host "   ✅ CSV export completed successfully" -ForegroundColor Green
    Write-Host "      • File Path: $OutputPath" -ForegroundColor Cyan
    Write-Host "      • File Size: $fileSizeKB KB" -ForegroundColor Cyan
    Write-Host "      • Record Count: $($employees.Count)" -ForegroundColor Cyan
    Write-Host "      • Encoding: UTF-8" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ CSV export failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 5: Display Sample Records
# =============================================================================

Write-Host "📋 Step 5: Display Sample Records" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

Write-Host ""
Write-Host "   📊 Sample Employee Records (First 3):" -ForegroundColor Cyan
Write-Host ""

$sampleRecords = $employees | Select-Object -First 3
foreach ($record in $sampleRecords) {
    Write-Host "   Employee: $($record.FirstName) $($record.LastName)" -ForegroundColor White
    Write-Host "   ├─ Employee ID: $($record.EmployeeID)" -ForegroundColor Cyan
    Write-Host "   ├─ Email: $($record.Email)" -ForegroundColor Cyan
    Write-Host "   ├─ Phone: $($record.Phone)" -ForegroundColor Cyan
    Write-Host "   ├─ SSN: $($record.SSN)" -ForegroundColor Cyan
    Write-Host "   ├─ Department: $($record.Department)" -ForegroundColor Cyan
    Write-Host "   └─ Hire Date: $($record.HireDate)" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "   💡 Note: Full dataset contains $($employees.Count) records" -ForegroundColor Yellow

Write-Host ""

# =============================================================================
# Step 6: Summary and Next Steps
# =============================================================================

Write-Host "📋 Step 6: Summary and Next Steps" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ Employee database creation completed successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Database Summary:" -ForegroundColor Cyan
Write-Host "   • Total Records: $($employees.Count)" -ForegroundColor White
Write-Host "   • Searchable Fields: EmployeeID, Email, SSN" -ForegroundColor White
Write-Host "   • Additional Fields: FirstName, LastName, Phone, Department, HireDate" -ForegroundColor White
Write-Host "   • File Location: $OutputPath" -ForegroundColor White
Write-Host "   • File Format: CSV (UTF-8 encoding)" -ForegroundColor White
Write-Host ""

Write-Host "⏭️  Next Steps - EDM Configuration Workflow:" -ForegroundColor Yellow
Write-Host "   1. Create EDM schema XML definition:" -ForegroundColor White
Write-Host "      - Run .\Create-EDMSchema.ps1" -ForegroundColor White
Write-Host "      - Define searchable fields (EmployeeID, Email, SSN)" -ForegroundColor White
Write-Host "      - Specify data store name: EmployeeDataStore" -ForegroundColor White
Write-Host ""
Write-Host "   2. Upload EDM schema to Purview:" -ForegroundColor White
Write-Host "      - Use Security & Compliance PowerShell" -ForegroundColor White
Write-Host "      - New-DlpEdmSchema cmdlet" -ForegroundColor White
Write-Host "      - Wait 5-10 minutes for schema replication" -ForegroundColor White
Write-Host ""
Write-Host "   3. Hash and upload employee data:" -ForegroundColor White
Write-Host "      - Run .\Upload-EDMData.ps1" -ForegroundColor White
Write-Host "      - Uses EDMUploadAgent.exe for secure hashing" -ForegroundColor White
Write-Host "      - SHA-256 hash uploaded to Microsoft secure enclave" -ForegroundColor White
Write-Host "      - Original data never leaves your environment" -ForegroundColor White
Write-Host ""
Write-Host "   4. Create EDM-based custom SIT:" -ForegroundColor White
Write-Host "      - Run .\Create-EDM-SIT.ps1" -ForegroundColor White
Write-Host "      - Links SIT to EmployeeDataStore" -ForegroundColor White
Write-Host "      - Enables exact match classification" -ForegroundColor White
Write-Host ""
Write-Host "   5. Validate EDM classification:" -ForegroundColor White
Write-Host "      - Run .\Validate-EDMClassification.ps1" -ForegroundColor White
Write-Host "      - Compare EDM vs regex accuracy" -ForegroundColor White
Write-Host "      - Measure false positive reduction" -ForegroundColor White
Write-Host ""

Write-Host "💡 EDM Security Model:" -ForegroundColor Yellow
Write-Host "   - Source CSV contains plaintext sensitive data" -ForegroundColor White
Write-Host "   - EDMUploadAgent hashes data with SHA-256 (one-way hash)" -ForegroundColor White
Write-Host "   - Only hashes uploaded to Microsoft secure enclave" -ForegroundColor White
Write-Host "   - Classification uses hash matching (no plaintext exposure)" -ForegroundColor White
Write-Host "   - Source CSV can be encrypted/deleted after upload" -ForegroundColor White
Write-Host ""

Write-Host "🔒 Security Recommendations:" -ForegroundColor Yellow
Write-Host "   - Restrict file system permissions on CSV file" -ForegroundColor White
Write-Host "   - Consider encrypting CSV after EDM upload" -ForegroundColor White
Write-Host "   - Use separate account for EDM schema/data management" -ForegroundColor White
Write-Host "   - Audit EDM data refresh operations regularly" -ForegroundColor White
Write-Host "   - Rotate EDM data periodically (quarterly/semi-annually)" -ForegroundColor White
Write-Host ""

Write-Host "✅ Script execution completed successfully" -ForegroundColor Green

<#
.SYNOPSIS
    Creates sample test data files with sensitive information types for Purview scanner discovery.

.DESCRIPTION
    This script creates three categories of test data files in the C:\PurviewScanner directory:
    - Finance folder: Credit card data (3 transactions)
    - HR folder: Personal Identifiable Information including SSNs (3 employees)
    - Projects folder: Old archived data timestamped 3+ years ago
    
    Each file contains realistic business document content with embedded sensitive
    information types that Purview scanner will detect in later labs.

.EXAMPLE
    .\Create-SampleTestData.ps1
    
    Creates all three test data files with appropriate sensitive information patterns.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1+ or PowerShell 7+
    - Administrator privileges (for folder/file creation)
    - C:\PurviewScanner directory must exist with Finance, HR, and Projects subfolders
    
    Sample Data Categories:
    - Finance: Credit card numbers (Visa, Mastercard, American Express patterns)
    - HR: Social Security Numbers, PII (names, addresses, phone numbers)
    - Projects: Archived sensitive data with old timestamps for data retention testing
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Create sample test data files with embedded sensitive information types
# =============================================================================

# =============================================================================
# Step 1: Create Finance Folder Sample Data
# =============================================================================

Write-Host "📋 Step 1: Creating Finance Sample Data" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$financeContent = @"
ACME CORPORATION - CUSTOMER PAYMENT RECORDS
Generated: $(Get-Date -Format 'yyyy-MM-dd')
Classification: CONFIDENTIAL

CUSTOMER PAYMENT INFORMATION

Transaction ID: TXN-2024-001
Customer Name: John Smith
Email: john.smith@email.com
Credit Card Number: 4532-1234-5678-9010
Expiration Date: 12/2026
CVV: 123
Amount: `$5,000.00
Date: 2024-10-15

Transaction ID: TXN-2024-002
Customer Name: Jane Doe
Email: jane.doe@email.com
Credit Card Number: 5425-2334-5566-7788
Expiration Date: 03/2027
CVV: 456
Amount: `$3,250.00
Date: 2024-10-16

Transaction ID: TXN-2024-003
Customer Name: Robert Johnson
Email: robert.j@email.com
Credit Card Number: 3782-822463-10005
Expiration Date: 08/2025
CVV: 789
Amount: `$1,875.50
Date: 2024-10-17
"@

$financeContent | Out-File -FilePath "C:\PurviewScanner\Finance\CustomerPayments.txt" -Encoding UTF8
Write-Host "   ✅ Finance sample created: CustomerPayments.txt (Credit Cards)" -ForegroundColor Green

# =============================================================================
# Step 2: Create HR Folder Sample Data
# =============================================================================

Write-Host "`n📋 Step 2: Creating HR Sample Data" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

$hrContent = @"
ACME CORPORATION - EMPLOYEE PERSONAL RECORDS
HR Department - RESTRICTED ACCESS
Last Updated: $(Get-Date -Format 'yyyy-MM-dd')

EMPLOYEE INFORMATION DATABASE

Employee ID: EMP-001
Full Name: Sarah Johnson
Social Security Number: 123-45-6789
Date of Birth: 01/15/1985
Home Address: 123 Main Street, Anytown, ST 12345
Phone Number: (555) 123-4567
Email: sarah.johnson@acme.com
Hire Date: 03/10/2020
Department: Engineering
Salary: `$95,000

Employee ID: EMP-002
Full Name: Michael Chen
Social Security Number: 987-65-4321
Date of Birth: 08/22/1990
Home Address: 456 Oak Avenue, Somewhere, ST 67890
Phone Number: (555) 987-6543
Email: michael.chen@acme.com
Hire Date: 06/15/2019
Department: Finance
Salary: `$88,000

Employee ID: EMP-003
Full Name: Emily Rodriguez
Social Security Number: 456-78-9012
Date of Birth: 11/30/1988
Home Address: 789 Pine Road, Another Town, ST 11223
Phone Number: (555) 456-7890
Email: emily.rodriguez@acme.com
Hire Date: 01/20/2021
Department: Marketing
Salary: `$72,000
"@

$hrContent | Out-File -FilePath "C:\PurviewScanner\HR\EmployeeRecords.txt" -Encoding UTF8
Write-Host "   ✅ HR sample created: EmployeeRecords.txt (SSN, PII)" -ForegroundColor Green

# =============================================================================
# Step 3: Create Projects Folder Sample Data (Old Archived)
# =============================================================================

Write-Host "`n📋 Step 3: Creating Projects Sample Data (Archived)" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

$projectContent = @"
PROJECT PHOENIX - ARCHIVED TECHNICAL DOCUMENTATION
Status: ARCHIVED - DEPRECATED
Last Access: 2020-01-15
Classification: CONFIDENTIAL - DO NOT DISTRIBUTE

LEGACY SYSTEM INFORMATION

Project Code: PHOENIX-2019
Classification Level: Highly Confidential
Data Retention: EXPIRED - CANDIDATE FOR DELETION

TECHNICAL SPECIFICATIONS:
- Internal Server IP: 192.168.100.50
- Database Connection: SERVER=db-prod-01;UID=sa;PWD=P@ssw0rd123
- API Key: SAMPLE_API_KEY_NOT_REAL_12345ABCDEF67890
- Encryption Key: AES256_KEY_0x4B3F9E2D8C1A7F5E

PROPRIETARY ALGORITHMS:
The Phoenix algorithm uses a three-stage processing pipeline:
1. Data ingestion with AES-256 encryption
2. Processing using proprietary compression (Patent Pending)
3. Output to secure storage with versioning

CUSTOMER DATA SAMPLES:
Customer 001: Social Security: 111-22-3333
Customer 002: Credit Card: 4111-1111-1111-1111

WARNING: THIS PROJECT WAS DECOMMISSIONED IN 2020
ALL SYSTEMS SHUT DOWN - DATA SHOULD BE ARCHIVED OR DELETED
RETENTION POLICY: 3 YEARS FROM LAST ACCESS
CURRENT STATUS: PAST RETENTION PERIOD - DELETION CANDIDATE
"@

$projectContent | Out-File -FilePath "C:\PurviewScanner\Projects\PhoenixProject.txt" -Encoding UTF8
Write-Host "   ✅ Projects sample created: PhoenixProject.txt" -ForegroundColor Green

# Set file to 3+ years old (simulates old data discovery)
$oldFile = Get-Item "C:\PurviewScanner\Projects\PhoenixProject.txt"
$oldDate = (Get-Date).AddYears(-3).AddMonths(-2)
$oldFile.LastWriteTime = $oldDate
$oldFile.LastAccessTime = $oldDate
$oldFile.CreationTime = $oldDate

Write-Host "   ✅ File timestamp set to 3+ years old for data retention testing" -ForegroundColor Green

# =============================================================================
# Step 4: Validation Summary
# =============================================================================

Write-Host "`n✅ Sample files created successfully" -ForegroundColor Green
Write-Host "`nFiles created:" -ForegroundColor Cyan
Write-Host "  - C:\PurviewScanner\Finance\CustomerPayments.txt (Credit Cards)" -ForegroundColor Yellow
Write-Host "  - C:\PurviewScanner\HR\EmployeeRecords.txt (SSN, PII)" -ForegroundColor Yellow
Write-Host "  - C:\PurviewScanner\Projects\PhoenixProject.txt (Old data, 3+ years)" -ForegroundColor Yellow

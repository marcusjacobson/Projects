<#
.SYNOPSIS
    Creates sample test data files with sensitive information types for Purview classification testing.

.DESCRIPTION
    This script creates three categories of test data files in the C:\PurviewLabs directory
    for use in Microsoft Purview Classification & Lifecycle Labs:
    
    - Finance folder: Customer payment records with credit card numbers (Visa, Mastercard, Amex)
    - HR folder: Employee information with Social Security Numbers and personal contact details
    - Projects folder: Archived project documentation with old timestamps for retention testing
    
    Each file contains realistic business document content with embedded sensitive information types
    that Purview classification engine will detect during On-Demand Classification scans.
    
    The generated files are designed for Lab 1 (On-Demand Classification) but are also used
    throughout Labs 2-4 for SIT testing, retention policies, and PowerShell automation.

.EXAMPLE
    .\Create-PurviewLabTestData.ps1
    
    Creates all three test data files with embedded credit card numbers, SSNs, and employee IDs
    in C:\PurviewLabs directory structure.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-11
    Last Modified: 2025-11-11
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Administrator privileges for C:\ directory creation
    - Minimum 10MB free disk space
    
    Test Data Categories:
    - Finance: Credit card numbers (Visa 4xxx, Mastercard 5xxx, Amex 3xxx patterns)
    - HR: Social Security Numbers (XXX-XX-XXXX format), employee contact information
    - Projects: Archived sensitive data with 3+ year old timestamps for retention policy testing
    
    Script development orchestrated using GitHub Copilot.

.TEST SCENARIOS
    - Sensitive Information Type Detection: Built-in SITs (Credit Card, SSN) and custom SITs (Employee ID)
    - On-Demand Classification: Manual re-indexing and classification validation
    - Content Explorer: Document discovery and classification result validation
    - Retention Policies: Aged data for retention trigger testing
#>
#
# =============================================================================
# Create sample test data files with embedded sensitive information types for
# Microsoft Purview classification and lifecycle management testing
# =============================================================================

# =============================================================================
# Step 1: Create Directory Structure
# =============================================================================

Write-Host "📋 Step 1: Creating Purview Labs Directory Structure" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green

$labsRoot = "C:\PurviewLabs"

try {
    # Create root directory
    if (-not (Test-Path $labsRoot)) {
        New-Item -Path $labsRoot -ItemType Directory -Force | Out-Null
        Write-Host "   ✅ Created root directory: $labsRoot" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Root directory already exists: $labsRoot" -ForegroundColor Cyan
    }
    
    # Create subdirectories
    $subdirs = @("Finance", "HR", "Projects")
    foreach ($dir in $subdirs) {
        $dirPath = Join-Path $labsRoot $dir
        if (-not (Test-Path $dirPath)) {
            New-Item -Path $dirPath -ItemType Directory -Force | Out-Null
            Write-Host "   ✅ Created subdirectory: $dir\" -ForegroundColor Green
        } else {
            Write-Host "   ℹ️  Subdirectory already exists: $dir\" -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
    Write-Host "   ✅ Directory structure created successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to create directory structure: $_" -ForegroundColor Red
    throw
}

Write-Host ""

# =============================================================================
# Step 2: Create Finance Folder Sample Data
# =============================================================================

Write-Host "📋 Step 2: Creating Finance Sample Data" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$financeContent = @"
CONTOSO CORPORATION - CUSTOMER PAYMENT RECORDS
===============================================
Classification: CONFIDENTIAL - INTERNAL USE ONLY
Generated: $(Get-Date -Format 'yyyy-MM-dd')
Department: Finance

CUSTOMER PAYMENT INFORMATION

Transaction ID: TXN-2025-001
Customer Name: Michael Anderson
Employee ID: EMP-2345-6789
Email: michael.anderson@email.com
Credit Card Number: 4532-1234-5678-9010
Expiration Date: 12/2027
CVV: 123
Amount: `$5,250.00
Payment Date: 2025-11-01
Status: PROCESSED

Transaction ID: TXN-2025-002
Customer Name: Sarah Martinez
Employee ID: EMP-3456-7890
Email: sarah.martinez@email.com
Credit Card Number: 5425-2334-5566-7788
Expiration Date: 03/2028
CVV: 456
Amount: `$3,750.00
Payment Date: 2025-11-02
Status: PROCESSED

Transaction ID: TXN-2025-003
Customer Name: David Thompson
Employee ID: EMP-4567-8901
Email: david.thompson@email.com
Credit Card Number: 3782-822463-10005
Expiration Date: 06/2027
CVV: 7890
Amount: `$8,900.00
Payment Date: 2025-11-03
Status: PROCESSED

Transaction ID: TXN-2025-004
Customer Name: Jennifer Lee
Employee ID: EMP-5678-9012
Email: jennifer.lee@email.com
Credit Card Number: 4916-3385-0279-1043
Expiration Date: 09/2026
CVV: 234
Amount: `$2,150.00
Payment Date: 2025-11-04
Status: PENDING

Transaction ID: TXN-2025-005
Customer Name: Robert Williams
Employee ID: EMP-6789-0123
Email: robert.williams@email.com
Credit Card Number: 5520-4478-9032-6741
Expiration Date: 01/2029
CVV: 567
Amount: `$6,425.00
Payment Date: 2025-11-05
Status: PROCESSED

PAYMENT PROCESSING NOTES:
- All transactions processed through secure payment gateway
- Credit card information encrypted at rest and in transit
- Compliance with PCI-DSS requirements maintained
- Fraud detection systems active on all accounts
- Monthly reconciliation required for audit purposes

INTERNAL CONTROLS:
- Dual authorization required for transactions over `$10,000
- Weekly review of all pending transactions by Finance Manager
- Quarterly audit of payment processing procedures
- Annual PCI-DSS compliance certification renewal

For questions contact: finance-team@contoso.com
Security Classification: CONFIDENTIAL
Retention Period: 7 years from transaction date
"@

$financeFile = Join-Path $labsRoot "Finance\CustomerPayments.txt"
try {
    Set-Content -Path $financeFile -Value $financeContent -Encoding UTF8
    Write-Host "   ✅ Created file: Finance\CustomerPayments.txt" -ForegroundColor Green
    Write-Host "   📊 File size: $((Get-Item $financeFile).Length) bytes" -ForegroundColor Cyan
    Write-Host "   🔍 Contains: 5 credit card numbers (Visa, Mastercard, Amex)" -ForegroundColor Cyan
    Write-Host "   🔍 Contains: 5 custom Employee ID patterns (EMP-XXXX-XXXX)" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Failed to create Finance sample file: $_" -ForegroundColor Red
    throw
}

Write-Host ""

# =============================================================================
# Step 3: Create HR Folder Sample Data
# =============================================================================

Write-Host "📋 Step 3: Creating HR Sample Data" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

$hrContent = @"
CONTOSO CORPORATION - EMPLOYEE RECORDS DATABASE
================================================
Classification: HIGHLY CONFIDENTIAL - HR ONLY
Generated: $(Get-Date -Format 'yyyy-MM-dd')
Department: Human Resources

EMPLOYEE PERSONAL INFORMATION

Employee ID: EMP-1234-5678
Full Name: Emily Rodriguez
Social Security Number: 123-45-6789
Date of Birth: 1985-03-15
Home Address: 123 Main Street, Seattle, WA 98101
Phone Number: (206) 555-1234
Email: emily.rodriguez@contoso.com
Hire Date: 2020-01-15
Department: Engineering
Position: Senior Software Engineer
Salary: `$125,000
Emergency Contact: Maria Rodriguez (Mother) - (206) 555-5678

Employee ID: EMP-2345-6789
Full Name: James Patterson
Social Security Number: 234-56-7890
Date of Birth: 1978-07-22
Home Address: 456 Oak Avenue, Portland, OR 97201
Phone Number: (503) 555-2345
Email: james.patterson@contoso.com
Hire Date: 2018-06-01
Department: Finance
Position: Financial Controller
Salary: `$145,000
Emergency Contact: Linda Patterson (Spouse) - (503) 555-6789

Employee ID: EMP-3456-7890
Full Name: Michelle Chen
Social Security Number: 345-67-8901
Date of Birth: 1990-11-08
Home Address: 789 Pine Road, San Francisco, CA 94102
Phone Number: (415) 555-3456
Email: michelle.chen@contoso.com
Hire Date: 2022-03-10
Department: Marketing
Position: Marketing Manager
Salary: `$115,000
Emergency Contact: David Chen (Spouse) - (415) 555-7890

Employee ID: EMP-4567-8901
Full Name: Christopher Davis
Social Security Number: 456-78-9012
Date of Birth: 1982-05-30
Home Address: 321 Elm Street, Austin, TX 78701
Phone Number: (512) 555-4567
Email: christopher.davis@contoso.com
Hire Date: 2019-09-20
Department: Sales
Position: Regional Sales Director
Salary: `$135,000
Emergency Contact: Jennifer Davis (Spouse) - (512) 555-8901

Employee ID: EMP-5678-9012
Full Name: Amanda Wilson
Social Security Number: 567-89-0123
Date of Birth: 1995-02-18
Home Address: 654 Maple Drive, Boston, MA 02101
Phone Number: (617) 555-5678
Email: amanda.wilson@contoso.com
Hire Date: 2023-01-05
Department: Human Resources
Position: HR Generalist
Salary: `$85,000
Emergency Contact: Thomas Wilson (Father) - (617) 555-9012

HR COMPLIANCE NOTES:
- All employee data maintained in accordance with federal and state regulations
- Social Security Numbers encrypted in HRIS system
- Annual background checks completed for all employees
- I-9 forms and work authorization documentation on file
- Benefits enrollment and COBRA administration tracked

DATA RETENTION POLICY:
- Active employee records: Maintained indefinitely
- Terminated employee records: 7 years after separation date
- Payroll records: 7 years after final payment
- Benefits records: Duration of coverage plus 6 years

ACCESS RESTRICTIONS:
- HR Director and CHRO: Full access to all employee records
- HR Generalists: Access to assigned department employees only
- Managers: Limited access to direct reports (no SSN or salary data)
- Employees: Self-service access to personal information only

For questions contact: hr-confidential@contoso.com
Security Classification: HIGHLY CONFIDENTIAL
Data Protection: Covered by GDPR, CCPA, and SOX regulations
"@

$hrFile = Join-Path $labsRoot "HR\EmployeeRecords.txt"
try {
    Set-Content -Path $hrFile -Value $hrContent -Encoding UTF8
    Write-Host "   ✅ Created file: HR\EmployeeRecords.txt" -ForegroundColor Green
    Write-Host "   📊 File size: $((Get-Item $hrFile).Length) bytes" -ForegroundColor Cyan
    Write-Host "   🔍 Contains: 5 Social Security Numbers (XXX-XX-XXXX)" -ForegroundColor Cyan
    Write-Host "   🔍 Contains: 5 Employee IDs, phone numbers, addresses" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Failed to create HR sample file: $_" -ForegroundColor Red
    throw
}

Write-Host ""

# =============================================================================
# Step 4: Create Projects Folder Sample Data (Aged Data)
# =============================================================================

Write-Host "📋 Step 4: Creating Projects Sample Data (Archived)" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

$projectsContent = @"
PROJECT LEGACY ARCHIVE - TECHNICAL DOCUMENTATION
=================================================
Status: ARCHIVED - DEPRECATED SYSTEM
Last Access: 2020-01-15
Classification: CONFIDENTIAL - DO NOT DISTRIBUTE
Project Code: LEGACY-2019-PHOENIX

LEGACY SYSTEM DECOMMISSION DOCUMENTATION

Project Name: Phoenix Migration System
Project Code: LEGACY-2019-PHOENIX
Original Start Date: 2018-06-01
Completion Date: 2019-12-31
Archival Date: 2020-01-15
Data Retention: EXPIRED - CANDIDATE FOR DELETION (5+ years old)

TECHNICAL SPECIFICATIONS:

Legacy Database Credentials:
- Server: legacy-db-prod-01.contoso.local
- Database Name: Phoenix_Production
- Admin Username: phoenix_admin
- Admin Password: [REDACTED - See KeePass vault]
- Connection String: SERVER=legacy-db-prod-01;UID=sa;PWD=[REDACTED]

API Integration Keys:
- Primary API Key: LEGACY_API_KEY_PHOENIX_12345ABCDEF67890
- Secondary API Key: BACKUP_KEY_98765FEDCBA54321
- Encryption Salt: AES256_SALT_0x4B3F9E2D8C1A7F5E
- JWT Secret: [REDACTED - See Azure Key Vault]

Employee Access Records:
- Project Manager: Emily Rodriguez (EMP-1234-5678) - SSN: 123-45-6789
- Tech Lead: James Patterson (EMP-2345-6789) - SSN: 234-56-7890
- Developer 1: Michelle Chen (EMP-3456-7890) - SSN: 345-67-8901

Customer Payment Information (Test Data):
- Test Credit Card 1: 4532-1111-2222-3333 (Visa - expired 2020)
- Test Credit Card 2: 5425-4444-5555-6666 (Mastercard - expired 2020)
- Test Credit Card 3: 3782-888888-99999 (Amex - expired 2020)

PROPRIETARY ALGORITHMS:

The Phoenix algorithm used a three-stage processing pipeline:

Stage 1: Data Ingestion
- Input validation with regex pattern: ^[A-Z0-9]{8,16}$
- AES-256 encryption applied to sensitive fields
- Hashing algorithm: SHA-512 with custom salt
- Compression: GZIP Level 9 for storage optimization

Stage 2: Transformation Engine
- XML to JSON conversion using custom XSLT templates
- Data normalization using Luhn algorithm for credit card validation
- SSN format validation: XXX-XX-XXXX pattern enforcement
- Employee ID standardization: EMP-XXXX-XXXX format

Stage 3: Output Generation
- PDF report generation with embedded watermarks
- Encrypted file transmission via SFTP (port 22)
- Audit log creation with SHA-256 checksums
- Retention tag application: 3-year lifecycle policy

SECURITY CONTROLS (NOW DEPRECATED):

1. Authentication Method: LDAP bind to legacy AD domain
   - Domain: contoso.local (DECOMMISSIONED)
   - LDAP Server: dc01.contoso.local (OFFLINE)

2. Authorization Model: Role-Based Access Control (RBAC)
   - Admin Role: Full system access
   - Manager Role: Read-only dashboard access
   - Auditor Role: Log review only

3. Data Protection: At-rest and in-transit encryption
   - TLS 1.2 for API communications (outdated - should be TLS 1.3)
   - BitLocker encryption on legacy servers (servers decommissioned)

DECOMMISSION NOTES:

System Shutdown Date: 2019-12-31 23:59:59 UTC
Data Migration Status: COMPLETE (migrated to Cloud Platform v2.0)
Backup Retention: 5 years from shutdown date (EXPIRES: 2024-12-31)
Legal Hold Status: NONE - Safe to purge after retention expiration

DISPOSAL CHECKLIST:
☑ All production data migrated to new system
☑ Legacy servers powered down and wiped
☑ Database backups encrypted and archived to cold storage
☑ API keys and credentials revoked from all systems
☑ Documentation archived to SharePoint Online
☐ PENDING: Final data deletion after 5-year retention (DUE: 2024-12-31)

CONTACTS (ARCHIVED):
- Project Sponsor: John Smith (RETIRED 2021)
- System Administrator: Jane Doe (TRANSFERRED 2022)
- Compliance Officer: Robert Johnson (CURRENT)

LEGAL NOTICE:
This document contains confidential and proprietary information of Contoso Corporation.
Unauthorized disclosure or use is prohibited. Retention period: 5 years from archival date.
After retention expiration, this document is subject to secure deletion in accordance with
company data retention policies and regulatory requirements (SOX, GDPR, CCPA).

Document Classification: CONFIDENTIAL - ARCHIVED
Retention Expiration Date: 2025-01-15 (OVERDUE - SHOULD BE DELETED)
Last Reviewed: 2020-01-15
Next Review: NOT SCHEDULED (Retention expired)
"@

$projectsFile = Join-Path $labsRoot "Projects\LegacySystemDocumentation.txt"
try {
    Set-Content -Path $projectsFile -Value $projectsContent -Encoding UTF8
    
    # Set file timestamps to 5+ years ago for retention policy testing
    $oldDate = (Get-Date).AddYears(-5).AddMonths(-2)
    (Get-Item $projectsFile).CreationTime = $oldDate
    (Get-Item $projectsFile).LastWriteTime = $oldDate
    (Get-Item $projectsFile).LastAccessTime = $oldDate
    
    Write-Host "   ✅ Created file: Projects\LegacySystemDocumentation.txt" -ForegroundColor Green
    Write-Host "   📊 File size: $((Get-Item $projectsFile).Length) bytes" -ForegroundColor Cyan
    Write-Host "   🔍 Contains: Archived project documentation with expired retention" -ForegroundColor Cyan
    Write-Host "   📅 File timestamps set to: $($oldDate.ToString('yyyy-MM-dd'))" -ForegroundColor Cyan
    Write-Host "   ⏱️  Age: 5+ years old (retention policy test data)" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Failed to create Projects sample file: $_" -ForegroundColor Red
    throw
}

Write-Host ""

# =============================================================================
# Step 5: Display Summary and Next Steps
# =============================================================================

Write-Host "📋 Step 5: Summary and Next Steps" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ Sample test data creation completed successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "📂 Created Files:" -ForegroundColor Cyan
Write-Host "   - Finance\CustomerPayments.txt (5 credit cards, 5 employee IDs)" -ForegroundColor White
Write-Host "   - HR\EmployeeRecords.txt (5 SSNs, 5 employee IDs, PII)" -ForegroundColor White
Write-Host "   - Projects\LegacySystemDocumentation.txt (archived data, 5+ years old)" -ForegroundColor White
Write-Host ""

Write-Host "📊 Total Files Created: 3" -ForegroundColor Cyan
Write-Host "📦 Total Directory Size: $([math]::Round((Get-ChildItem -Path $labsRoot -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1KB, 2)) KB" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔍 Sensitive Information Types Embedded:" -ForegroundColor Cyan
Write-Host "   - Built-in SITs:" -ForegroundColor White
Write-Host "     • Credit Card Number (Visa, Mastercard, Amex): 10 instances" -ForegroundColor White
Write-Host "     • U.S. Social Security Number (SSN): 8 instances" -ForegroundColor White
Write-Host "   - Custom SIT Patterns (for Lab 2):" -ForegroundColor White
Write-Host "     • Employee ID (EMP-XXXX-XXXX): 15 instances" -ForegroundColor White
Write-Host "     • Archived data with 5+ year timestamps (retention testing)" -ForegroundColor White
Write-Host ""

Write-Host "⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Upload these files to your SharePoint site (Purview Classification Lab)" -ForegroundColor White
Write-Host "   2. Create three document library folders: Finance, HR, Projects" -ForegroundColor White
Write-Host "   3. Upload corresponding files from C:\PurviewLabs\ to each SharePoint folder" -ForegroundColor White
Write-Host "   4. Return to Lab 1 README.md Step 2 to create custom SIT" -ForegroundColor White
Write-Host "   5. Run On-Demand Classification scan on SharePoint site" -ForegroundColor White
Write-Host ""

Write-Host "💡 Production Tip:" -ForegroundColor Yellow
Write-Host "   Use PnP PowerShell or SharePoint Online Management Shell for bulk" -ForegroundColor White
Write-Host "   file uploads to multiple sites efficiently in enterprise environments." -ForegroundColor White
Write-Host ""

Write-Host "✅ Script execution completed successfully" -ForegroundColor Green

<#
.SYNOPSIS
    Creates local test data files for Lab 1 custom SIT pattern validation.

.DESCRIPTION
    This script generates test documents with embedded sensitive data patterns
    for local validation of custom Sensitive Information Types before SharePoint
    deployment. Creates 15 test files with:
    - Project IDs (PROJ-2025-####)
    - Customer Numbers (CUST-######)
    - Purchase Order Numbers (PO-####-####-XXXX)
    
    Files are created in C:\PurviewLabs\Lab1-CustomSIT-Testing\ directory
    structure for immediate pattern testing without SharePoint indexing delays.

.PARAMETER OutputPath
    Directory path for test data generation. Defaults to C:\PurviewLabs\Lab1-CustomSIT-Testing.

.PARAMETER Verbose
    Show detailed progress during execution.

.EXAMPLE
    .\Create-Lab1TestData.ps1
    
    Creates 15 test documents with custom SIT patterns in default directory.

.EXAMPLE
    .\Create-Lab1TestData.ps1 -OutputPath "C:\Temp\CustomSITTest" -Verbose
    
    Creates test documents in specified directory with verbose output.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    Last Modified: 2025-11-14
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Write access to output directory
    
    Script development orchestrated using GitHub Copilot.

.TEST DATA PATTERNS
    Project IDs: PROJ-2025-#### (engineering, marketing, finance projects)
    Customer Numbers: CUST-###### (6-digit customer identifiers)
    Purchase Order Numbers: PO-####-####-XXXX (department-year-sequence-vendor)
#>

# =============================================================================
# Lab 1 Test Data Generation for Custom SIT Pattern Validation
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "C:\PurviewLabs\Lab1-CustomSIT-Testing"
)

Write-Host "📋 Lab 1 Test Data Generation" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Directory Structure Creation
# =============================================================================

Write-Host "`n📋 Step 1: Creating Directory Structure" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

try {
    if (Test-Path $OutputPath) {
        Write-Host "⚠️  Output directory already exists: $OutputPath" -ForegroundColor Yellow
        Write-Host "   Cleaning existing directory..." -ForegroundColor Cyan
        Remove-Item $OutputPath -Recurse -Force
    }
    
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    New-Item -ItemType Directory -Path "$OutputPath\ProjectIDs" -Force | Out-Null
    New-Item -ItemType Directory -Path "$OutputPath\CustomerNumbers" -Force | Out-Null
    New-Item -ItemType Directory -Path "$OutputPath\PurchaseOrders" -Force | Out-Null
    
    Write-Host "✅ Created directory structure: $OutputPath" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create directory structure: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Generate Project ID Test Files
# =============================================================================

Write-Host "`n📋 Step 2: Generating Project ID Test Files" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

$projectIDFiles = @(
    @{ Name = "Engineering_Project_Proposal.txt"; Content = @"
Engineering Project Proposal - Q1 2025
======================================

Project Identifier: PROJ-2025-1001
Department: Software Engineering
Budget: `$500,000

Project Overview:
This engineering project PROJ-2025-1001 focuses on cloud infrastructure
development initiative for enterprise customers.

Related Projects:
- PROJ-2025-1002 (API Gateway Development)
- PROJ-2025-1003 (Microservices Migration)

Project Manager: engineering.pm@contoso.com
Approval Status: Pending Executive Review
"@ }
    @{ Name = "Marketing_Campaign_Plan.txt"; Content = @"
Marketing Campaign Plan - 2025
==============================

Campaign Identifier: PROJ-2025-2001
Department: Marketing
Timeline: January - June 2025

Campaign Details:
Marketing project PROJ-2025-2001 initiative focuses on digital transformation
and customer engagement strategies.

Sub-Projects:
- PROJ-2025-2002 (Social Media Campaign)
- PROJ-2025-2003 (Email Marketing Automation)
- PROJ-2025-2004 (Customer Analytics Dashboard)

Campaign Manager: marketing.lead@contoso.com
Budget Approval: `$250,000
"@ }
    @{ Name = "Finance_System_Upgrade.txt"; Content = @"
Finance System Upgrade Proposal
===============================

Project Code: PROJ-2025-3001
Department: Finance
Priority: High

Project Description:
Finance project PROJ-2025-3001 development initiative aims to modernize
accounting systems and financial reporting capabilities.

Related Initiatives:
- PROJ-2025-3002 (Payment Processing Enhancement)
- PROJ-2025-3003 (Audit Trail Implementation)

Project Sponsor: CFO
Estimated Completion: December 2025
"@ }
    @{ Name = "HR_Portal_Redesign.txt"; Content = @"
HR Portal Redesign Project
==========================

Project Number: PROJ-2025-4001
Department: Human Resources
Phase: Planning

Scope:
HR project PROJ-2025-4001 initiative includes employee self-service
portal development and benefits management system.

Dependencies:
- PROJ-2025-4002 (Authentication System Upgrade)
- PROJ-2025-4003 (Employee Database Migration)

Project Lead: hr.director@contoso.com
Start Date: March 1, 2025
"@ }
    @{ Name = "IT_Security_Assessment.txt"; Content = @"
IT Security Assessment Project
==============================

Project Identifier: PROJ-2025-5001
Department: Information Technology
Classification: Confidential

Assessment Scope:
Security project PROJ-2025-5001 development initiative encompasses
comprehensive vulnerability assessment and penetration testing.

Related Projects:
- PROJ-2025-5002 (Security Monitoring Enhancement)
- PROJ-2025-5003 (Incident Response Plan Update)

Security Lead: security@contoso.com
Completion Target: Q2 2025
"@ }
)

Write-Host "📄 Creating Project ID test documents..." -ForegroundColor Cyan

foreach ($file in $projectIDFiles) {
    $filePath = Join-Path "$OutputPath\ProjectIDs" $file.Name
    Set-Content -Path $filePath -Value $file.Content -Encoding UTF8
}

Write-Host "✅ Created $($projectIDFiles.Count) Project ID test files" -ForegroundColor Green

# =============================================================================
# Step 3: Generate Customer Number Test Files
# =============================================================================

Write-Host "`n📋 Step 3: Generating Customer Number Test Files" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

$customerNumberFiles = @(
    @{ Name = "Premium_Customer_Account.txt"; Content = @"
Premium Customer Account Summary
================================

Customer Account: CUST-123456
Account Type: Premium Business
Status: Active

Account Details:
Customer CUST-123456 has maintained premium status since 2020.
Account number CUST-123456 includes priority support and dedicated
account manager services.

Related Accounts:
- CUST-123457 (Subsidiary Account)
- CUST-123458 (Partner Integration)

Account Manager: premium.accounts@contoso.com
Annual Revenue: `$1,250,000
"@ }
    @{ Name = "Standard_Customer_Profile.txt"; Content = @"
Standard Customer Profile
=========================

Customer Number: CUST-234567
Account Type: Standard Business
Established: January 2023

Profile Information:
Customer account CUST-234567 maintains standard service level agreement
with quarterly business reviews.

Additional Customer References:
- CUST-234568 (Billing Contact)
- CUST-234569 (Technical Contact)

Customer Success Manager: customer.success@contoso.com
Support Tier: Standard
"@ }
    @{ Name = "Enterprise_Client_Record.txt"; Content = @"
Enterprise Client Record
========================

Client Number: CUST-345678
Account Type: Enterprise
Industry: Technology

Client Overview:
Enterprise client CUST-345678 represents our largest technology sector
customer with multi-year strategic partnership.

Associated Client Numbers:
- CUST-345679 (Regional Office - East)
- CUST-345680 (Regional Office - West)
- CUST-345681 (Development Environment)

Account Executive: enterprise.sales@contoso.com
Contract Value: `$5,000,000 (3-year agreement)
"@ }
    @{ Name = "Small_Business_Account.txt"; Content = @"
Small Business Account Information
==================================

Account Identifier: CUST-456789
Business Type: Small Business
Employee Count: 15-50

Business Details:
Small business customer CUST-456789 joined in 2024 with growth plan
subscription. Customer number CUST-456789 qualifies for small business
support programs and training resources.

Growth Opportunities:
- Upgrade path available for CUST-456789
- Additional services recommended

Business Development: smb.sales@contoso.com
Monthly Subscription: `$2,500
"@ }
    @{ Name = "Government_Agency_Account.txt"; Content = @"
Government Agency Account
=========================

Agency Account: CUST-567890
Sector: Public Sector
Compliance Level: FedRAMP High

Agency Information:
Government customer CUST-567890 requires enhanced security controls
and compliance reporting. Account CUST-567890 operates under strict
regulatory requirements.

Related Agency Accounts:
- CUST-567891 (Contractor Portal Access)
- CUST-567892 (Audit Reporting System)

Government Sales Lead: gov.sales@contoso.com
Contract Type: Federal Acquisition Regulation (FAR)
"@ }
)

Write-Host "📄 Creating Customer Number test documents..." -ForegroundColor Cyan

foreach ($file in $customerNumberFiles) {
    $filePath = Join-Path "$OutputPath\CustomerNumbers" $file.Name
    Set-Content -Path $filePath -Value $file.Content -Encoding UTF8
}

Write-Host "✅ Created $($customerNumberFiles.Count) Customer Number test files" -ForegroundColor Green

# =============================================================================
# Step 4: Generate Purchase Order Test Files
# =============================================================================

Write-Host "`n📋 Step 4: Generating Purchase Order Test Files" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

$purchaseOrderFiles = @(
    @{ Name = "Engineering_Hardware_Purchase.txt"; Content = @"
Engineering Hardware Purchase Order
====================================

Purchase Order Number: PO-3200-2025-ACME
Department: Engineering (3200)
Fiscal Year: 2025
Vendor: ACME Technology Solutions

Order Details:
Procurement purchase order PO-3200-2025-ACME issued for server hardware
and networking equipment. PO PO-3200-2025-ACME includes standard warranty
and installation services.

Related POs:
- PO-3200-2025-DELL (Additional Equipment)
- PO-3200-2025-CISCO (Network Infrastructure)

Requisition Contact: engineering.procurement@contoso.com
Total Amount: `$125,000
Approval Date: January 15, 2025
"@ }
    @{ Name = "Marketing_Software_License.txt"; Content = @"
Marketing Software License Purchase
====================================

Purchase Order: PO-4100-2025-MSFT
Department: Marketing (4100)
Fiscal Year: 2025
Vendor Code: MSFT (Microsoft Corporation)

License Details:
Marketing purchase order PO-4100-2025-MSFT for enterprise software
licensing and cloud services. Vendor PO-4100-2025-MSFT provides
annual subscription with premier support.

Additional Purchases:
- PO-4100-2025-ADBE (Adobe Creative Cloud)
- PO-4100-2025-SFDC (Salesforce CRM)

Purchasing Manager: marketing.ops@contoso.com
Annual Cost: `$85,000
Renewal Date: January 2026
"@ }
    @{ Name = "Finance_Professional_Services.txt"; Content = @"
Finance Professional Services Agreement
=======================================

PO Number: PO-5300-2025-KPMG
Department: Finance (5300)
Year: 2025
Vendor: KPMG (Audit Services)

Service Agreement:
Finance purchase order PO-5300-2025-KPMG requisition covers annual
audit and tax advisory services. Vendor PO-5300-2025-KPMG provides
comprehensive financial consulting.

Related Service Orders:
- PO-5300-2025-DTTL (Deloitte Consulting)
- PO-5300-2025-PWCG (PwC Tax Services)

Finance Director: finance.director@contoso.com
Contract Value: `$250,000
Service Period: January - December 2025
"@ }
    @{ Name = "HR_Training_Program.txt"; Content = @"
HR Training Program Purchase Order
===================================

Purchase Order: PO-6400-2025-LNKI
Department: Human Resources (6400)
Fiscal Year: 2025
Vendor: LNKI (LinkedIn Learning)

Program Details:
HR procurement purchase order PO-6400-2025-LNKI for enterprise
training platform and professional development resources.

Training Vendor POs:
- PO-6400-2025-PLUR (Pluralsight)
- PO-6400-2025-UDEM (Udemy Business)

HR Operations: hr.training@contoso.com
Annual Investment: `$45,000
Employee Count: 500 licenses
"@ }
    @{ Name = "IT_Cloud_Services.txt"; Content = @"
IT Cloud Services Purchase Order
=================================

PO Identifier: PO-7500-2025-AMZN
Department: Information Technology (7500)
Fiscal Year: 2025
Vendor Code: AMZN (Amazon Web Services)

Cloud Services:
IT purchase order PO-7500-2025-AMZN requisition for cloud infrastructure
and managed services. Vendor PO-7500-2025-AMZN provides compute, storage,
and database services with 24/7 support.

Additional Cloud Vendors:
- PO-7500-2025-GOOG (Google Cloud Platform)
- PO-7500-2025-AZUR (Microsoft Azure)

IT Director: it.operations@contoso.com
Monthly Budget: `$75,000
Commitment: 12-month contract
"@ }
)

Write-Host "📄 Creating Purchase Order test documents..." -ForegroundColor Cyan

foreach ($file in $purchaseOrderFiles) {
    $filePath = Join-Path "$OutputPath\PurchaseOrders" $file.Name
    Set-Content -Path $filePath -Value $file.Content -Encoding UTF8
}

Write-Host "✅ Created $($purchaseOrderFiles.Count) Purchase Order test files" -ForegroundColor Green

# =============================================================================
# Step 5: Summary and Validation
# =============================================================================

Write-Host "`n📋 Step 5: Summary and Validation" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

$totalFiles = $projectIDFiles.Count + $customerNumberFiles.Count + $purchaseOrderFiles.Count

Write-Host "`n✅ Test Data Generation Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "   Total Files Created: $totalFiles" -ForegroundColor White
Write-Host "   Project IDs: $($projectIDFiles.Count) files" -ForegroundColor White
Write-Host "   Customer Numbers: $($customerNumberFiles.Count) files" -ForegroundColor White
Write-Host "   Purchase Orders: $($purchaseOrderFiles.Count) files" -ForegroundColor White
Write-Host ""
Write-Host "📂 Output Location:" -ForegroundColor Cyan
Write-Host "   $OutputPath" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Pattern Summary:" -ForegroundColor Cyan
Write-Host "   • Project IDs: PROJ-2025-#### (15 instances)" -ForegroundColor White
Write-Host "   • Customer Numbers: CUST-###### (12 instances)" -ForegroundColor White
Write-Host "   • Purchase Orders: PO-####-####-XXXX (10 instances)" -ForegroundColor White
Write-Host ""
Write-Host "💡 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Create custom SITs using Exercise 2, 3, and 4 scripts" -ForegroundColor White
Write-Host "   2. Run Validate-CustomSITs.ps1 to test pattern detection" -ForegroundColor White
Write-Host "   3. Review validation results and tune confidence levels" -ForegroundColor White
Write-Host ""
Write-Host "✅ Ready to proceed with Exercise 2: Create Project ID Custom SIT" -ForegroundColor Green

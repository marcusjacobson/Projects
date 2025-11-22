<#
.SYNOPSIS
    Creates SharePoint test site and uploads sample documents for Purview Classification Labs.

.DESCRIPTION
    This script performs the initial SharePoint setup for the Purview Classification
    Lifecycle Labs by:
    1. Prompting for SharePoint site URL (extracts tenant automatically)
    2. Creating SharePoint Communication Site "Purview Classification Lab"
    3. Creating document library folder structure (Finance, HR, Projects)
    4. Generating 20 sample documents with embedded sensitive data patterns
    5. Uploading files to SharePoint to trigger automatic indexing (15-30 minutes)
    
    This script initiates time-sensitive background operations that enable seamless
    progression through Labs 1-4 without active waiting periods.

.PARAMETER Verbose
    Show detailed progress during execution.

.EXAMPLE
    .\Initialize-SharePointTestSite.ps1 -Verbose
    
    Prompts for SharePoint site URL, creates site and folder structure, generates
    sample documents, and uploads to SharePoint for automatic indexing.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-13
    Last Modified: 2025-11-13
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PnP PowerShell module installed (Install-Module PnP.PowerShell)
    - SharePoint Online access with site creation permissions
    - PowerShell 5.1+ or PowerShell 7+
    
    Script development orchestrated using GitHub Copilot.

.SITE STRUCTURE
    Site: Purview Classification Lab (Communication Site)
    Library: Documents (root SharePoint library)
    - Folder: Finance (financial documents with credit cards, SSNs)
    - Folder: HR (employee documents with employee IDs, emails)
    - Folder: Projects (project documents with customer numbers, project codes)
#>

# =============================================================================
# SharePoint Test Site Initialization for Purview Classification Labs
# =============================================================================

Write-Host "🚀 SharePoint Test Site Initialization" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Tenant and Site Configuration
# =============================================================================

Write-Host "📋 Step 1: Tenant and Site Configuration" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Prompt for tenant name only
$tenantName = Read-Host "Enter your tenant name (e.g., 'contoso' from contoso.sharepoint.com)"

# Validate tenant name
if ([string]::IsNullOrWhiteSpace($tenantName)) {
    Write-Host "❌ Tenant name cannot be empty" -ForegroundColor Red
    exit 1
}

# Construct URLs
$tenantUrl = "https://$tenantName.sharepoint.com"
$adminUrl = "https://$tenantName-admin.sharepoint.com"
$siteName = "PurviewClassificationLab"
$siteUrl = "$tenantUrl/sites/$siteName"

Write-Host "✅ Tenant: $tenantName" -ForegroundColor Green
Write-Host "✅ Site to create: $siteUrl" -ForegroundColor Green

# =============================================================================
# Step 2: Entra ID App Registration
# =============================================================================

Write-Host "`n📋 Step 2: Entra ID App Registration" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Check for existing app registration in environment variable
if ($env:ENTRAID_APP_ID) {
    Write-Host "✅ Found existing Entra ID app registration: $env:ENTRAID_APP_ID" -ForegroundColor Green
    $appClientId = $env:ENTRAID_APP_ID
} else {
    Write-Host "⚠️  No Entra ID app registration found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "PnP PowerShell requires an Entra ID app registration for interactive authentication." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Choose registration method:" -ForegroundColor Cyan
    Write-Host "  1. Automatic registration (PowerShell 7.4+ with PnP.PowerShell cmdlet)" -ForegroundColor White
    Write-Host "  2. Manual registration (Azure Portal - detailed instructions provided)" -ForegroundColor White
    Write-Host "  3. Skip (I already have a Client ID)" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Enter choice (1, 2, or 3)"
    
    switch ($choice) {
        "1" {
            Write-Host "`n🔄 Attempting automatic registration..." -ForegroundColor Cyan
            try {
                $appName = "PnP-PowerShell-InteractiveLogin-$tenantName"
                Register-PnPEntraIDAppForInteractiveLogin -ApplicationName $appName -Tenant "$tenantName.onmicrosoft.com" -Interactive
                Write-Host "✅ App registered successfully" -ForegroundColor Green
                Write-Host "📋 Check the output above for your Client ID (Application ID)" -ForegroundColor Cyan
                $appClientId = Read-Host "Enter the Client ID from the registration output"
            } catch {
                Write-Host "❌ Automatic registration failed: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "   Try manual registration (option 2) or provide existing Client ID (option 3)" -ForegroundColor Yellow
                exit 1
            }
        }
        "2" {
            Write-Host "`n📋 Manual Azure Portal Registration Instructions:" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "1. Navigate to portal.azure.com → Microsoft Entra ID → App registrations" -ForegroundColor White
            Write-Host "2. Click 'New registration'" -ForegroundColor White
            Write-Host "3. Name: 'PnP-PowerShell-InteractiveLogin'" -ForegroundColor White
            Write-Host "4. Supported account types: 'Accounts in this organizational directory only'" -ForegroundColor White
            Write-Host "5. Redirect URI: Select 'Public client/native (mobile & desktop)'" -ForegroundColor White
            Write-Host "   URI: http://localhost" -ForegroundColor White
            Write-Host "6. Click 'Register'" -ForegroundColor White
            Write-Host "7. Copy the 'Application (client) ID' from the Overview page" -ForegroundColor White
            Write-Host "8. Go to 'API permissions' → 'Add a permission'" -ForegroundColor White
            Write-Host "9. Select 'SharePoint' → 'Delegated permissions' → Check 'AllSites.FullControl'" -ForegroundColor White
            Write-Host "10. Click 'Add permissions'" -ForegroundColor White
            Write-Host ""
            $appClientId = Read-Host "Enter the Application (client) ID from Azure Portal"
        }
        "3" {
            Write-Host "`n📋 Using existing Client ID" -ForegroundColor Cyan
            $appClientId = Read-Host "Enter your existing Entra ID App Registration Client ID"
        }
        default {
            Write-Host "❌ Invalid choice" -ForegroundColor Red
            exit 1
        }
    }
    
    # Validate Client ID format (should be a GUID)
    if ($appClientId -notmatch '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
        Write-Host "❌ Invalid Client ID format (should be a GUID like 12345678-1234-1234-1234-123456789abc)" -ForegroundColor Red
        exit 1
    }
    
    # Save for future runs
    $env:ENTRAID_APP_ID = $appClientId
    Write-Host "✅ Client ID saved to environment variable for future runs" -ForegroundColor Green
}

# =============================================================================
# Step 3: SharePoint Admin Authentication
# =============================================================================

Write-Host "`n📋 Step 3: SharePoint Admin Authentication" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

try {
    Write-Host "🔐 Connecting to SharePoint Admin Center..." -ForegroundColor Cyan
    Write-Host "   (Browser window will open for authentication)" -ForegroundColor Yellow
    
    # Connect to SharePoint Admin Center to create site using app registration
    Connect-PnPOnline -Url $adminUrl -Interactive -ClientId $appClientId
    
    Write-Host "✅ Connected to SharePoint Admin successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ SharePoint Admin authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Verify you have SharePoint Administrator or Global Administrator role" -ForegroundColor Yellow
    Write-Host "   If using manual registration, ensure API permissions were granted" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 4: Create SharePoint Communication Site
# =============================================================================

Write-Host "`n📋 Step 4: Creating SharePoint Communication Site" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

try {
    # Check if site already exists
    Write-Host "🔍 Checking if site already exists..." -ForegroundColor Cyan
    
    $existingSite = Get-PnPTenantSite -Url $siteUrl -ErrorAction SilentlyContinue
    
    if ($existingSite) {
        Write-Host "⚠️  Site already exists at: $siteUrl" -ForegroundColor Yellow
        Write-Host "   Connecting to existing site for document upload..." -ForegroundColor Cyan
    } else {
        Write-Host "🚀 Creating new Communication Site: $siteName" -ForegroundColor Cyan
        
        # Create Communication Site
        New-PnPSite -Type CommunicationSite `
            -Title "Purview Classification Lab" `
            -Url $siteUrl `
            -Description "Test site for Microsoft Purview Classification Lifecycle Labs" `
            -SiteDesign "Topic" `
            -Lcid 1033
        
        Write-Host "✅ Site created successfully: $siteUrl" -ForegroundColor Green
        
        # Wait a few seconds for site provisioning to complete
        Write-Host "   ⏱️  Waiting for site provisioning to complete..." -ForegroundColor Cyan
        Start-Sleep -Seconds 10
    }
    
    # Disconnect from admin and reconnect to the actual site
    Disconnect-PnPOnline
    
    Write-Host "🔐 Connecting to site for document operations..." -ForegroundColor Cyan
    Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $appClientId
    
    Write-Host "✅ Connected to site: $siteUrl" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Failed to create or connect to site: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Verify you have permissions to create sites in your tenant" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 5: Document Library Folder Structure Creation
# =============================================================================

Write-Host "`n📋 Step 5: Creating Document Library Structure" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

$folders = @("Finance", "HR", "Projects")

foreach ($folder in $folders) {
    try {
        # Check if folder already exists
        $existingFolder = Get-PnPFolder -Url "Shared Documents/$folder" -ErrorAction SilentlyContinue
        
        if ($existingFolder) {
            Write-Host "⚠️  Folder '$folder' already exists - skipping" -ForegroundColor Yellow
        } else {
            Add-PnPFolder -Name $folder -Folder "Shared Documents" | Out-Null
            Write-Host "✅ Created folder: $folder" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Failed to create folder '$folder': $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =============================================================================
# Step 6: Sample Document Generation
# =============================================================================

Write-Host "`n📋 Step 6: Generating Sample Documents" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Create temporary directory for sample files
$tempPath = Join-Path $env:TEMP "PurviewClassificationLab"
if (Test-Path $tempPath) {
    Remove-Item $tempPath -Recurse -Force
}
New-Item -ItemType Directory -Path $tempPath | Out-Null

Write-Host "📄 Generating documents with sensitive data patterns..." -ForegroundColor Cyan

# Finance folder documents (6 files with credit cards, SSNs)
$financeFiles = @(
    @{ Name = "Financial_Report_Q1_2025.txt"; Content = @"
Financial Report - Q1 2025
==========================
Revenue Summary: `$2.5M

Customer Payment Details:
- Customer 001: Credit Card 4532-1234-5678-9010 (Visa)
- Customer 002: Credit Card 5425-2345-6789-0123 (Mastercard)
- Customer 003: SSN 123-45-6789 for tax purposes

Employee Financial Data:
- CFO: SSN 234-56-7890, Employee ID: EMP-2024-1001
- Accountant: EMP-2024-1002, SSN 345-67-8901
"@ }
    @{ Name = "Credit_Card_Transactions_Jan.txt"; Content = @"
Credit Card Transactions - January 2025
=======================================
Transaction Log:

01/05/2025: 4916-1234-5678-9012 - `$150.00
01/12/2025: 3782-234567-89012 (Amex) - `$2,500.00
01/18/2025: 5425-3456-7890-1234 - `$75.00
01/25/2025: 4532-4567-8901-2345 - `$300.00

Customer Contact: john.doe@contoso.com
Phone: (555) 123-4567
"@ }
    @{ Name = "Tax_Documents_2024.txt"; Content = @"
Tax Documentation - 2024 Filing
===============================
Company Tax ID: 12-3456789

Employee Tax Information:
1. Jane Smith - SSN: 456-78-9012, CUST-123456
2. Bob Johnson - SSN: 567-89-0123, CUST-234567
3. Alice Williams - SSN: 678-90-1234, CUST-345678

Quarterly Payments:
Q1: Credit Card 4532-5678-9012-3456
Q2: Credit Card 5425-4567-8901-2345
"@ }
    @{ Name = "Payment_Processing_Feb.txt"; Content = @"
Payment Processing Report - February
====================================
Total Payments: `$125,000

Method Breakdown:
- Credit Card 4916-2345-6789-0123: `$45,000
- Credit Card 3714-234567-89012: `$30,000
- Credit Card 6011-3456-7890-1234: `$50,000

Customer Numbers:
- CUST-456789
- CUST-567890
- CUST-678901
"@ }
    @{ Name = "Vendor_Payments_March.txt"; Content = @"
Vendor Payment Schedule - March 2025
====================================
Payment Details:

Vendor A: Credit Card 5425-5678-9012-3456
Vendor B: Credit Card 4532-6789-0123-4567
Vendor C: Credit Card 4916-3456-7890-1234

Contact: finance@contoso.com
Approval: CFO (SSN: 789-01-2345)
"@ }
    @{ Name = "Customer_Account_Summary.txt"; Content = @"
Customer Account Summary
========================
As of April 2025

Premium Accounts:
- CUST-789012 - Credit Card 4532-7890-1234-5678
- CUST-890123 - Credit Card 5425-6789-0123-4567
- CUST-901234 - SSN 890-12-3456 (Business Owner)

Standard Accounts:
- CUST-012345 - Credit Card 4916-4567-8901-2345
"@ }
)

# HR folder documents (7 files with employee IDs, SSNs, emails)
$hrFiles = @(
    @{ Name = "Employee_Directory_2025.txt"; Content = @"
Employee Directory - 2025
=========================
Active Employees:

1. John Smith
   Employee ID: EMP-2024-1003
   Email: john.smith@contoso.com
   Phone: (555) 234-5678
   SSN: 901-23-4567

2. Sarah Johnson
   Employee ID: EMP-2024-1004
   Email: sarah.johnson@contoso.com
   SSN: 012-34-5678

3. Michael Brown
   Employee ID: EMP-2024-1005
   Email: michael.brown@contoso.com
   Phone: (555) 345-6789
"@ }
    @{ Name = "New_Hire_Onboarding_Q1.txt"; Content = @"
New Hire Onboarding - Q1 2025
==============================
Onboarding Schedule:

Week 1 - January:
- Emily Davis (EMP-2025-2001)
  SSN: 123-45-6780
  Email: emily.davis@contoso.com

Week 2 - February:
- David Wilson (EMP-2025-2002)
  SSN: 234-56-7891
  Email: david.wilson@contoso.com

Week 3 - March:
- Lisa Anderson (EMP-2025-2003)
  SSN: 345-67-8902
  Email: lisa.anderson@contoso.com
"@ }
    @{ Name = "Performance_Reviews_Annual.txt"; Content = @"
Annual Performance Reviews - 2024
=================================
Review Period: January 1 - December 31, 2024

Manager: Robert Thompson
Employee ID: EMP-2023-5001
SSN: 456-78-9013

Direct Reports:
1. EMP-2024-1006 - Rating: Exceeds Expectations
2. EMP-2024-1007 - Rating: Meets Expectations
3. EMP-2024-1008 - Rating: Exceeds Expectations

Contact: hr@contoso.com
"@ }
    @{ Name = "Benefits_Enrollment_2025.txt"; Content = @"
Benefits Enrollment Summary - 2025
==================================
Enrollment Period: November 2024

Enrolled Employees:
- Jennifer Martinez (EMP-2024-3001)
  SSN: 567-89-0124
  Email: jennifer.martinez@contoso.com
  Plan: Premium Health + Dental

- Christopher Garcia (EMP-2024-3002)
  SSN: 678-90-1235
  Email: christopher.garcia@contoso.com
  Plan: Standard Health

- Amanda Rodriguez (EMP-2024-3003)
  SSN: 789-01-2346
"@ }
    @{ Name = "Termination_Records_Q4.txt"; Content = @"
Employee Termination Records - Q4 2024
======================================
HR Department - Confidential

October Terminations:
- Daniel Lee (EMP-2022-4001)
  SSN: 890-12-3457
  Last Day: 10/15/2024
  Reason: Resignation

November Terminations:
- Michelle White (EMP-2021-4002)
  SSN: 901-23-4568
  Last Day: 11/30/2024
  Reason: Retirement

December Terminations:
- Kevin Harris (EMP-2023-4003)
  SSN: 012-34-5679
"@ }
    @{ Name = "Payroll_Processing_April.txt"; Content = @"
Payroll Processing - April 2025
===============================
Payroll Administrator: HR Department

Employee Payment Details:
1. Nancy Clark (EMP-2024-5001)
   SSN: 123-45-6791
   Gross: `$8,500
   Net: `$6,200

2. Steven Lewis (EMP-2024-5002)
   SSN: 234-56-7802
   Gross: `$7,200
   Net: `$5,400

3. Patricia Walker (EMP-2024-5003)
   SSN: 345-67-8913
   Gross: `$9,100
"@ }
    @{ Name = "Training_Attendance_Q2.txt"; Content = @"
Training Attendance Report - Q2 2025
====================================
Training Coordinator: hr-training@contoso.com

Compliance Training (April 15):
- Brian Hall (EMP-2024-6001) - Completed
- Rebecca Young (EMP-2024-6002) - Completed
- Jason Allen (EMP-2024-6003) - No Show

Security Training (May 20):
- Karen King (EMP-2024-6004, SSN: 456-78-9024)
- Timothy Wright (EMP-2024-6005, SSN: 567-89-0135)

Contact: training@contoso.com
"@ }
)

# Projects folder documents (7 files with customer numbers, project codes)
$projectFiles = @(
    @{ Name = "Project_Alpha_Overview.txt"; Content = @"
Project Alpha - Overview
========================
Project Code: PROJ-2025-1001
Start Date: January 2025

Team Members:
- Project Manager: EMP-2024-7001
- Lead Developer: EMP-2024-7002
- Business Analyst: EMP-2024-7003

Customer Accounts:
- Primary: CUST-111222
- Secondary: CUST-222333
- Tertiary: CUST-333444

Budget: `$250,000
Timeline: 6 months
"@ }
    @{ Name = "Project_Beta_Status.txt"; Content = @"
Project Beta - Status Report
============================
Project Code: PROJ-2025-1002
Status: In Progress (75% Complete)

Assigned Resources:
- Project Manager: john.pm@contoso.com
- Developer Team: EMP-2024-7004, EMP-2024-7005
- QA Team: EMP-2024-7006

Customer Information:
- CUST-444555 (Primary Contact)
- CUST-555666 (Billing Contact)

Next Milestone: June 15, 2025
Contact: projects@contoso.com
"@ }
    @{ Name = "Project_Gamma_Requirements.txt"; Content = @"
Project Gamma - Requirements Document
=====================================
Project Code: PROJ-2025-1003
Phase: Requirements Gathering

Stakeholders:
- Executive Sponsor: SSN 678-90-2346
- Product Owner: EMP-2024-7007
- Technical Lead: EMP-2024-7008

Customer Requirements (CUST-666777):
1. API Integration - Priority High
2. Data Migration - Priority Medium
3. UI Redesign - Priority Low

Additional Customers:
- CUST-777888 (Partner Integration)
- CUST-888999 (Reporting Module)
"@ }
    @{ Name = "Project_Delta_Timeline.txt"; Content = @"
Project Delta - Timeline & Milestones
=====================================
Project Code: PROJ-2025-1004
Duration: January - August 2025

Phase 1 (Jan-Feb): Planning
- Team Lead: EMP-2024-7009
- Customer: CUST-999000

Phase 2 (Mar-May): Development
- Development Team: EMP-2024-7010, EMP-2024-7011
- Customer: CUST-000111

Phase 3 (Jun-Aug): Testing & Deployment
- QA Lead: EMP-2024-7012
- Customer: CUST-111000

Project Manager: jane.pm@contoso.com
"@ }
    @{ Name = "Project_Epsilon_Budget.txt"; Content = @"
Project Epsilon - Budget Analysis
=================================
Project Code: PROJ-2025-1005
Budget Owner: EMP-2024-7013

Cost Breakdown:
Personnel: `$180,000
- Team Member 1: EMP-2024-7014
- Team Member 2: EMP-2024-7015
- Team Member 3: EMP-2024-7016

Infrastructure: `$45,000
- Cloud Services: CUST-222000 (Vendor Account)
- Licensing: CUST-333111 (Software Vendor)

Customer Billing:
- CUST-444222 (Primary)
- CUST-555333 (Secondary)

Finance Contact: SSN 789-01-3457
Approval: Credit Card 4532-8901-2345-6789
"@ }
    @{ Name = "Project_Zeta_Risks.txt"; Content = @"
Project Zeta - Risk Assessment
==============================
Project Code: PROJ-2025-1006
Risk Manager: EMP-2024-7017

Critical Risks:
1. Resource Availability
   - Developer: EMP-2024-7018
   - Designer: EMP-2024-7019

2. Customer Dependencies
   - CUST-666444 (External API)
   - CUST-777555 (Data Provider)

3. Budget Constraints
   - Contingency Fund: `$25,000
   - Emergency Contact: SSN 890-12-4568

Escalation Contact: risks@contoso.com
Phone: (555) 456-7890
"@ }
    @{ Name = "Project_Eta_Deliverables.txt"; Content = @"
Project Eta - Deliverables Tracking
===================================
Project Code: PROJ-2025-1007
Program Manager: program.manager@contoso.com

Deliverable 1: Requirements Document
- Owner: EMP-2024-7020
- Customer: CUST-888666
- Status: Completed

Deliverable 2: Design Specifications
- Owner: EMP-2024-7021
- Customer: CUST-999777
- Status: In Progress

Deliverable 3: Implementation
- Team: EMP-2024-7022, EMP-2024-7023, EMP-2024-7024
- Customer: CUST-000888
- Status: Not Started

Financial Approval: SSN 901-23-5679
Purchase Order: Credit Card 5425-7890-1234-5678
"@ }
)

# Generate Finance files
Write-Host "   📊 Generating Finance documents..." -ForegroundColor Cyan
foreach ($file in $financeFiles) {
    $filePath = Join-Path $tempPath "Finance\$($file.Name)"
    New-Item -ItemType Directory -Path (Split-Path $filePath -Parent) -Force | Out-Null
    Set-Content -Path $filePath -Value $file.Content -Encoding UTF8
}
Write-Host "   ✅ Created $($financeFiles.Count) Finance documents" -ForegroundColor Green

# Generate HR files
Write-Host "   👥 Generating HR documents..." -ForegroundColor Cyan
foreach ($file in $hrFiles) {
    $filePath = Join-Path $tempPath "HR\$($file.Name)"
    New-Item -ItemType Directory -Path (Split-Path $filePath -Parent) -Force | Out-Null
    Set-Content -Path $filePath -Value $file.Content -Encoding UTF8
}
Write-Host "   ✅ Created $($hrFiles.Count) HR documents" -ForegroundColor Green

# Generate Projects files
Write-Host "   🎯 Generating Projects documents..." -ForegroundColor Cyan
foreach ($file in $projectFiles) {
    $filePath = Join-Path $tempPath "Projects\$($file.Name)"
    New-Item -ItemType Directory -Path (Split-Path $filePath -Parent) -Force | Out-Null
    Set-Content -Path $filePath -Value $file.Content -Encoding UTF8
}
Write-Host "   ✅ Created $($projectFiles.Count) Projects documents" -ForegroundColor Green

$totalFiles = $financeFiles.Count + $hrFiles.Count + $projectFiles.Count
Write-Host "`n✅ Generated $totalFiles sample documents in $tempPath" -ForegroundColor Green

# =============================================================================
# Step 7: Upload Files to SharePoint
# =============================================================================

Write-Host "`n📋 Step 7: Uploading Files to SharePoint" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

$uploadedCount = 0

# Upload Finance files
Write-Host "📤 Uploading Finance documents..." -ForegroundColor Cyan
foreach ($file in $financeFiles) {
    try {
        $sourceFile = Join-Path $tempPath "Finance\$($file.Name)"
        Add-PnPFile -Path $sourceFile -Folder "Shared Documents/Finance" | Out-Null
        $uploadedCount++
    } catch {
        Write-Host "   ⚠️  Failed to upload $($file.Name): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
Write-Host "✅ Uploaded $($financeFiles.Count) files to Finance folder" -ForegroundColor Green

# Upload HR files
Write-Host "📤 Uploading HR documents..." -ForegroundColor Cyan
foreach ($file in $hrFiles) {
    try {
        $sourceFile = Join-Path $tempPath "HR\$($file.Name)"
        Add-PnPFile -Path $sourceFile -Folder "Shared Documents/HR" | Out-Null
        $uploadedCount++
    } catch {
        Write-Host "   ⚠️  Failed to upload $($file.Name): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
Write-Host "✅ Uploaded $($hrFiles.Count) files to HR folder" -ForegroundColor Green

# Upload Projects files
Write-Host "📤 Uploading Projects documents..." -ForegroundColor Cyan
foreach ($file in $projectFiles) {
    try {
        $sourceFile = Join-Path $tempPath "Projects\$($file.Name)"
        Add-PnPFile -Path $sourceFile -Folder "Shared Documents/Projects" | Out-Null
        $uploadedCount++
    } catch {
        Write-Host "   ⚠️  Failed to upload $($file.Name): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
Write-Host "✅ Uploaded $($projectFiles.Count) files to Projects folder" -ForegroundColor Green

Write-Host "`n✅ Total files uploaded: $uploadedCount of $totalFiles" -ForegroundColor Green

# =============================================================================
# Step 8: Cleanup and Summary
# =============================================================================

Write-Host "`n📋 Step 8: Cleanup and Summary" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

# Clean up temporary directory
try {
    Remove-Item $tempPath -Recurse -Force
    Write-Host "✅ Cleaned up temporary files" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not clean up temporary directory: $tempPath" -ForegroundColor Yellow
}

# Disconnect from SharePoint
Disconnect-PnPOnline

Write-Host "`n🎉 SharePoint Test Site Initialization Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "⏱️  Background Indexing Started:" -ForegroundColor Cyan
Write-Host "   SharePoint will index these documents over the next 15-30 minutes." -ForegroundColor White
Write-Host "   Continue to Exercise 3 immediately - no need to wait!" -ForegroundColor Yellow
Write-Host ""
Write-Host "🎯 Site URL: $siteUrl" -ForegroundColor Cyan
Write-Host "   Save this URL - you'll use it in Labs 1, 3, 4, and 5." -ForegroundColor White
Write-Host ""
Write-Host "📊 Document Summary:" -ForegroundColor Cyan
Write-Host "   Finance folder: $($financeFiles.Count) documents" -ForegroundColor White
Write-Host "   HR folder: $($hrFiles.Count) documents" -ForegroundColor White
Write-Host "   Projects folder: $($projectFiles.Count) documents" -ForegroundColor White
Write-Host "   Total: $totalFiles documents with embedded sensitive data patterns" -ForegroundColor White
Write-Host ""
Write-Host "✅ Ready for Lab 1: Custom Sensitive Information Types" -ForegroundColor Green

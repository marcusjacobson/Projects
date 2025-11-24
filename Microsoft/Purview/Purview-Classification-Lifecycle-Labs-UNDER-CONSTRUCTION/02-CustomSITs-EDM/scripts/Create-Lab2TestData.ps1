<#
.SYNOPSIS
    Creates test data files with custom pattern examples for Lab 2 Custom SIT validation.

.DESCRIPTION
    This script generates test documents containing organization-specific identifier patterns
    for validating custom Sensitive Information Types (SITs) in Microsoft Purview:
    
    - Project IDs: PROJ-YYYY-#### format (engineering, marketing, finance projects)
    - Customer Numbers: CUST-###### format (6-digit customer identifiers)
    - Purchase Order Numbers: PO-####-####-XXXX format (dept-year-sequence-vendor)
    
    Each pattern type is embedded in realistic business documents with appropriate context
    and keywords to test both pattern matching and keyword-based confidence scoring.
    
    The generated files are designed for Lab 2 (Custom SITs) regex pattern validation
    and can be uploaded to SharePoint for On-Demand Classification testing.

.EXAMPLE
    .\Create-Lab2TestData.ps1
    
    Creates all test data files with Project ID, Customer Number, and Purchase Order patterns
    in C:\PurviewLabs\Lab2-CustomSIT-Testing\ directory structure.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-11
    Last Modified: 2025-11-11
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Administrator privileges for C:\ directory creation (or modify path)
    - Minimum 5MB free disk space
    
    Test Data Patterns:
    - Project IDs: PROJ-2025-#### (engineering, marketing, finance projects)
    - Customer Numbers: CUST-###### (6-digit account identifiers)
    - Purchase Orders: PO-####-####-XXXX (department-year-sequence-vendor codes)
    
    Pattern Design:
    - Each file contains 3-5 pattern instances for statistical validation
    - Keywords embedded for context-aware confidence level testing
    - Realistic business document formatting for accuracy testing
    
    Script development orchestrated using GitHub Copilot.

.TEST SCENARIOS
    - Regex Pattern Validation: Verify custom SIT pattern matching accuracy
    - Keyword Context Testing: Validate confidence level scoring with/without keywords
    - False Positive Detection: Test pattern specificity and boundary conditions
    - SharePoint Classification: Upload files for On-Demand Classification validation
#>
#
# =============================================================================
# Create test data files with custom patterns for Lab 2 Custom SIT validation
# in Microsoft Purview Information Protection
# =============================================================================

# =============================================================================
# Step 1: Create Directory Structure
# =============================================================================

Write-Host "📋 Step 1: Creating Lab 2 Test Data Directory Structure" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green

$labsRoot = "C:\PurviewLabs\Lab2-CustomSIT-Testing"

try {
    # Create root directory
    if (-not (Test-Path $labsRoot)) {
        New-Item -Path $labsRoot -ItemType Directory -Force | Out-Null
        Write-Host "   ✅ Created root directory: $labsRoot" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Root directory already exists: $labsRoot" -ForegroundColor Cyan
    }
    
    # Create subdirectories for each pattern type
    $subdirs = @("ProjectIDs", "CustomerNumbers", "PurchaseOrders")
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
# Step 2: Create Project ID Test Files
# =============================================================================

Write-Host "📋 Step 2: Creating Project ID Test Files" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

$projectFiles = @(
    @{
        Name = "EngineeringProject_CloudMigration.txt"
        Content = @"
CONTOSO CORPORATION - ENGINEERING PROJECT DOCUMENTATION
========================================================
Classification: CONFIDENTIAL - INTERNAL USE ONLY
Generated: $(Get-Date -Format 'yyyy-MM-dd')
Department: Engineering

CLOUD MIGRATION INITIATIVE - PROJECT OVERVIEW

Project Identifier: PROJ-2025-1001
Project Name: Azure Cloud Migration Initiative
Project Manager: Sarah Chen
Department: Engineering Infrastructure
Start Date: 2025-01-15
End Date: 2025-12-31
Budget: `$2,500,000

PROJECT TEAM ASSIGNMENTS

Lead Architect: PROJ-2025-1001-LEAD
Development Team Lead: Engineering project PROJ-2025-1002 coordinator
DevOps Engineer: Assigned to initiative PROJ-2025-1003
Security Consultant: Project identifier PROJ-2025-1004 specialist

PROJECT MILESTONES

Phase 1: Infrastructure Assessment (PROJ-2025-1001-P1)
- Complete infrastructure audit by Q1 2025
- Document current state architecture
- Identify migration dependencies

Phase 2: Cloud Environment Setup (PROJ-2025-1001-P2)
- Provision Azure resources for development project PROJ-2025-1005
- Configure networking and security boundaries
- Establish CI/CD pipelines

Phase 3: Application Migration (PROJ-2025-1001-P3)
- Migrate web applications to Azure App Service
- Database migration to Azure SQL Database
- Configure Azure Active Directory integration

RELATED PROJECTS

Parent Initiative: Digital Transformation (PROJ-2024-5000)
Dependency: Network Modernization (PROJ-2025-0950)
Integration: Security Compliance Upgrade (PROJ-2025-1100)

RISK ASSESSMENT

High Priority Risks:
- Timeline compression for project PROJ-2025-1001 delivery
- Resource allocation conflicts with PROJ-2025-0800 team
- Third-party vendor delays affecting development initiative

Mitigation Strategies:
- Weekly project review meetings for all PROJ-2025-#### identifiers
- Cross-functional team coordination with project leads
- Escalation path to VP Engineering for project blockers

BUDGET BREAKDOWN

Infrastructure: `$1,200,000 (Project PROJ-2025-1001-INFRA)
Development: `$800,000 (Project PROJ-2025-1001-DEV)
Security & Compliance: `$300,000 (Project PROJ-2025-1001-SEC)
Contingency: `$200,000 (Project PROJ-2025-1001-CONT)

APPROVAL CHAIN

Engineering Director: Approved - PROJ-2025-1001
VP Engineering: Approved - Project authorization granted
CFO: Budget approved for engineering project initiatives
CTO: Strategic alignment confirmed for development project

NOTES

All project documentation must reference PROJ-2025-1001 identifier.
Weekly status reports required for all project team members.
Change requests processed through project management office.

For questions contact: engineering-projects@contoso.com
Security Classification: CONFIDENTIAL
Project Code: PROJ-2025-1001
"@
    },
    @{
        Name = "MarketingCampaign_ProductLaunch.txt"
        Content = @"
CONTOSO CORPORATION - MARKETING CAMPAIGN DOCUMENTATION
=======================================================
Classification: CONFIDENTIAL - MARKETING ONLY
Generated: $(Get-Date -Format 'yyyy-MM-dd')
Department: Marketing

PRODUCT LAUNCH CAMPAIGN - Q2 2025

Project Identifier: PROJ-2025-2001
Campaign Name: AI Security Suite Product Launch
Campaign Manager: Michael Rodriguez
Department: Product Marketing
Launch Date: 2025-06-01
Campaign Duration: 6 months
Budget: `$1,500,000

CAMPAIGN COMPONENTS

Digital Marketing: Project PROJ-2025-2002 (social media, email campaigns)
Content Creation: Marketing project PROJ-2025-2003 (blogs, whitepapers, videos)
Event Management: Project PROJ-2025-2004 (webinars, conferences, trade shows)
Partner Enablement: PROJ-2025-2005 initiative (channel partner training)

TARGET AUDIENCE SEGMENTS

Enterprise Customers: Project identifier PROJ-2025-2006 segment
Mid-Market Businesses: Marketing project PROJ-2025-2007 focus
Technology Partners: Initiative PROJ-2025-2008 outreach
Industry Analysts: Project PROJ-2025-2009 relationship management

CREATIVE ASSETS

Brand Guidelines: PROJ-2025-2001-BRAND
Logo Variations: Project PROJ-2025-2001-LOGO
Messaging Framework: Marketing initiative PROJ-2025-2010
Value Proposition: Project identifier PROJ-2025-2011

MEDIA PLAN

Paid Search: `$400,000 (PROJ-2025-2002-SEM)
Social Media Ads: `$350,000 (PROJ-2025-2002-SOCIAL)
Display Advertising: `$250,000 (PROJ-2025-2002-DISPLAY)
Content Syndication: `$200,000 (PROJ-2025-2002-CONTENT)

PERFORMANCE METRICS

Lead Generation Target: 5,000 MQLs (Project PROJ-2025-2001 KPI)
Pipeline Value Target: `$25M (Marketing project target)
Customer Acquisition: 250 new customers (Initiative goal)
Brand Awareness Lift: 40% (Project measurement criteria)

DEPENDENCIES

Product Development: PROJ-2025-1050 (feature completion required)
Sales Enablement: PROJ-2025-3100 (training materials)
Partner Marketing: PROJ-2025-3200 (co-marketing programs)

TIMELINE

Pre-Launch (Months 1-2): Project PROJ-2025-2001 preparation phase
Launch (Month 3): Marketing initiative PROJ-2025-2001 activation
Growth (Months 4-5): Project optimization and scaling
Evaluation (Month 6): Initiative assessment and reporting

For questions contact: marketing-campaigns@contoso.com
Security Classification: CONFIDENTIAL
Marketing Project Code: PROJ-2025-2001
"@
    },
    @{
        Name = "FinanceInitiative_CostOptimization.txt"
        Content = @"
CONTOSO CORPORATION - FINANCE INITIATIVE DOCUMENTATION
=======================================================
Classification: HIGHLY CONFIDENTIAL - FINANCE ONLY
Generated: $(Get-Date -Format 'yyyy-MM-dd')
Department: Finance

COST OPTIMIZATION INITIATIVE - FY2025

Project Identifier: PROJ-2025-5001
Initiative Name: Enterprise Cost Optimization Program
Program Manager: Jennifer Lee
Department: Finance Operations
Start Date: 2025-02-01
Completion Target: 2025-11-30
Target Savings: `$5,000,000

OPTIMIZATION WORKSTREAMS

Vendor Consolidation: Project PROJ-2025-5002 (reduce supplier count 30%)
Cloud Cost Management: Finance project PROJ-2025-5003 (optimize Azure/AWS spend)
Process Automation: Initiative PROJ-2025-5004 (eliminate manual processes)
Real Estate Optimization: Project identifier PROJ-2025-5005 (office space reduction)

ANALYSIS PHASES

Phase 1: Baseline Assessment (PROJ-2025-5001-P1)
- Current spend analysis by category
- Identify top 100 vendors by spend
- Benchmark against industry standards
- Project PROJ-2025-5001 financial modeling

Phase 2: Opportunity Identification (PROJ-2025-5001-P2)
- Vendor negotiation opportunities
- Technology consolidation options
- Process improvement initiatives
- Quick wins for project delivery

Phase 3: Implementation (PROJ-2025-5001-P3)
- Execute vendor renegotiations
- Deploy automation solutions
- Consolidate technology platforms
- Track savings for finance project

COST CATEGORIES

IT Infrastructure: `$2M savings target (Project PROJ-2025-5010)
Professional Services: `$1.5M target (Finance initiative PROJ-2025-5011)
Software Licenses: `$1M target (Project PROJ-2025-5012)
Facilities: `$500K target (Initiative PROJ-2025-5013)

GOVERNANCE STRUCTURE

Steering Committee: Monthly reviews of project PROJ-2025-5001 progress
Finance Leadership: Weekly check-ins on initiative metrics
Business Unit Leaders: Quarterly savings validation
CFO: Executive sponsor for finance project

RISK MITIGATION

Service Disruption Risk: Project PROJ-2025-5001 continuity planning
Vendor Relationship Risk: Negotiation strategy for initiative
Employee Impact: Change management for project implementation
Compliance Risk: Legal review of all finance project contracts

EXPECTED OUTCOMES

Year 1 Savings: `$5M (Project PROJ-2025-5001 target)
Year 2 Run Rate: `$7.5M annually (Initiative projection)
Process Efficiency: 25% reduction in manual work
Vendor Count: Reduce from 500 to 350 suppliers

For questions contact: finance-initiatives@contoso.com
Security Classification: HIGHLY CONFIDENTIAL
Finance Project Code: PROJ-2025-5001
"@
    }
)

$projectIDCount = 0
foreach ($file in $projectFiles) {
    $filePath = Join-Path $labsRoot "ProjectIDs\$($file.Name)"
    try {
        Set-Content -Path $filePath -Value $file.Content -Encoding UTF8
        $patternCount = ([regex]::Matches($file.Content, 'PROJ-\d{4}-\d{4}')).Count
        $projectIDCount += $patternCount
        
        Write-Host "   ✅ Created file: ProjectIDs\$($file.Name)" -ForegroundColor Green
        Write-Host "      📊 Contains $patternCount Project ID patterns" -ForegroundColor Cyan
    } catch {
        Write-Host "   ❌ Failed to create file $($file.Name): $_" -ForegroundColor Red
        throw
    }
}

Write-Host ""
Write-Host "   ✅ Project ID files created successfully" -ForegroundColor Green
Write-Host "   📊 Total Project ID patterns embedded: $projectIDCount" -ForegroundColor Cyan

Write-Host ""

# =============================================================================
# Step 3: Create Customer Number Test Files
# =============================================================================

Write-Host "📋 Step 3: Creating Customer Number Test Files" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

$customerFiles = @(
    @{
        Name = "CustomerAccounts_EnterpriseClients.txt"
        Content = @"
CONTOSO CORPORATION - CUSTOMER ACCOUNT REGISTRY
================================================
Classification: CONFIDENTIAL - SALES USE ONLY
Generated: $(Get-Date -Format 'yyyy-MM-dd')
Department: Sales Operations

ENTERPRISE CLIENT ACCOUNTS - ACTIVE STATUS

Customer Account: CUST-100234
Company Name: Fabrikam Industries Inc.
Account Manager: Robert Chen
Contract Value: `$2,500,000
Renewal Date: 2026-03-15
Account Status: Active - Strategic

Customer Account: CUST-100567
Company Name: Tailspin Toys Corporation
Account Manager: Sarah Martinez
Contract Value: `$1,800,000
Renewal Date: 2025-12-31
Account Status: Active - Key Account

Customer Account: CUST-100891
Company Name: Northwind Traders LLC
Account Manager: Michael Johnson
Contract Value: `$3,200,000
Renewal Date: 2026-06-30
Account Status: Active - Enterprise

Customer Account: CUST-101123
Company Name: Adventure Works Cycles
Account Manager: Emily Rodriguez
Contract Value: `$950,000
Renewal Date: 2025-09-15
Account Status: Active - Growth

Customer Account: CUST-101456
Company Name: Proseware Systems Inc.
Account Manager: David Thompson
Contract Value: `$1,250,000
Renewal Date: 2026-01-31
Account Status: Active - Standard

ACCOUNT RELATIONSHIP HIERARCHY

Parent Account: CUST-100234 (Fabrikam Industries)
- Subsidiary: CUST-100235 (Fabrikam Europe GmbH)
- Subsidiary: CUST-100236 (Fabrikam Asia Pacific Ltd)

Parent Account: CUST-100567 (Tailspin Toys)
- Division: CUST-100568 (Tailspin Retail Division)
- Division: CUST-100569 (Tailspin Manufacturing)

REVENUE TRACKING

Q1 2025 Revenue by Customer:
- CUST-100234: `$625,000
- CUST-100567: `$450,000
- CUST-100891: `$800,000
- CUST-101123: `$237,500
- CUST-101456: `$312,500

YTD Total: `$2,425,000

CUSTOMER ENGAGEMENT METRICS

Customer CUST-100234: 45 support tickets, 98% satisfaction
Customer CUST-100567: 28 support tickets, 95% satisfaction
Customer CUST-100891: 62 support tickets, 97% satisfaction
Customer CUST-101123: 15 support tickets, 94% satisfaction
Customer CUST-101456: 22 support tickets, 96% satisfaction

RENEWAL PIPELINE

High Priority Renewals:
- Account CUST-100567 renewal due 2025-12-31 (6 months out)
- Account CUST-101123 renewal due 2025-09-15 (strategic importance)

Executive Relationship Required:
- Customer CUST-100891 (enterprise tier, executive sponsor needed)
- Customer CUST-100234 (multi-year negotiation in progress)

UPSELL OPPORTUNITIES

Customer CUST-100234: Additional licenses (potential `$500K)
Customer CUST-100891: Professional services (potential `$750K)
Customer CUST-101456: Training programs (potential `$150K)

For questions contact: sales-operations@contoso.com
Security Classification: CONFIDENTIAL
Customer Data Sensitivity: HIGH
"@
    },
    @{
        Name = "CustomerSupport_TicketAssignments.txt"
        Content = @"
CONTOSO CORPORATION - CUSTOMER SUPPORT TICKET REGISTRY
=======================================================
Classification: CONFIDENTIAL - SUPPORT USE ONLY
Generated: $(Get-Date -Format 'yyyy-MM-dd')
Department: Customer Support

ACTIVE SUPPORT TICKETS - PRIORITY ESCALATION

Ticket #12345: Customer number CUST-102001 - Critical issue
Priority: P1 (Critical)
Issue: Production system outage affecting 500 users
Assigned To: Senior Support Engineer - Team Alpha
Status: In Progress
SLA: 4-hour response, 24-hour resolution

Ticket #12346: Customer CUST-102045 - High priority
Priority: P2 (High)
Issue: Performance degradation in reporting module
Assigned To: Support Specialist - Team Beta
Status: Investigating
SLA: 8-hour response, 72-hour resolution

Ticket #12347: Account CUST-102089 - Medium priority
Priority: P3 (Medium)
Issue: Feature request for custom dashboard
Assigned To: Product Support - Team Gamma
Status: Needs Clarification
SLA: 24-hour response, 5-day resolution

Ticket #12348: Client account CUST-102134 - Low priority
Priority: P4 (Low)
Issue: Documentation request for API integration
Assigned To: Technical Writer - Documentation Team
Status: Assigned
SLA: 48-hour response, 10-day resolution

Ticket #12349: Customer CUST-102178 - Critical escalation
Priority: P1 (Critical)
Issue: Data synchronization failure causing data loss
Assigned To: Engineering Escalation - Platform Team
Status: Emergency Response
SLA: 2-hour response, 12-hour resolution

CUSTOMER SATISFACTION TRACKING

Customer CUST-102001: 
- Open Tickets: 3
- Closed Tickets (30 days): 15
- Average Resolution Time: 6 hours
- Satisfaction Score: 92%

Customer CUST-102045:
- Open Tickets: 1
- Closed Tickets (30 days): 8
- Average Resolution Time: 18 hours
- Satisfaction Score: 88%

Customer CUST-102089:
- Open Tickets: 2
- Closed Tickets (30 days): 12
- Average Resolution Time: 24 hours
- Satisfaction Score: 95%

ESCALATION PATH

Account CUST-102001: Escalated to VP Support (production impact)
Account CUST-102178: Engineering team engaged (data integrity issue)
Customer CUST-102045: Account manager notified (SLA risk)

FOLLOW-UP REQUIRED

Client CUST-102134: Schedule technical review call
Customer CUST-102089: Feature roadmap discussion needed
Account CUST-102001: Post-incident review scheduled

For questions contact: customer-support@contoso.com
Security Classification: CONFIDENTIAL
Customer Support Data: RESTRICTED ACCESS
"@
    }
)

$customerNumberCount = 0
foreach ($file in $customerFiles) {
    $filePath = Join-Path $labsRoot "CustomerNumbers\$($file.Name)"
    try {
        Set-Content -Path $filePath -Value $file.Content -Encoding UTF8
        $patternCount = ([regex]::Matches($file.Content, 'CUST-\d{6}')).Count
        $customerNumberCount += $patternCount
        
        Write-Host "   ✅ Created file: CustomerNumbers\$($file.Name)" -ForegroundColor Green
        Write-Host "      📊 Contains $patternCount Customer Number patterns" -ForegroundColor Cyan
    } catch {
        Write-Host "   ❌ Failed to create file $($file.Name): $_" -ForegroundColor Red
        throw
    }
}

Write-Host ""
Write-Host "   ✅ Customer Number files created successfully" -ForegroundColor Green
Write-Host "   📊 Total Customer Number patterns embedded: $customerNumberCount" -ForegroundColor Cyan

Write-Host ""

# =============================================================================
# Step 4: Create Purchase Order Test Files
# =============================================================================

Write-Host "📋 Step 4: Creating Purchase Order Test Files" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

$poFiles = @(
    @{
        Name = "PurchaseOrders_ITEquipment.txt"
        Content = @"
CONTOSO CORPORATION - PURCHASE ORDER REGISTRY
==============================================
Classification: CONFIDENTIAL - PROCUREMENT USE ONLY
Generated: $(Get-Date -Format 'yyyy-MM-dd')
Department: Procurement

IT EQUIPMENT PURCHASE ORDERS - FY2025

Purchase Order: PO-3200-2025-DELL
Vendor: Dell Technologies Inc.
Department: IT Infrastructure (Code: 3200)
Description: Laptop computers for engineering team (50 units)
Order Date: 2025-02-15
Expected Delivery: 2025-03-30
Total Amount: `$125,000
Approver: IT Director
Status: Approved - In Transit

Purchase Order: PO-3200-2025-LNVO
Vendor: Lenovo Group Limited
Department: IT Infrastructure (Code: 3200)
Description: Desktop workstations for design team (25 units)
Order Date: 2025-03-01
Expected Delivery: 2025-04-15
Total Amount: `$87,500
Approver: IT Director
Status: Approved - Pending Shipment

Purchase Order: PO-3200-2025-MSFT
Vendor: Microsoft Corporation
Department: IT Infrastructure (Code: 3200)
Description: Microsoft 365 E5 licenses (500 users, annual)
Order Date: 2025-01-10
Renewal Date: 2026-01-10
Total Amount: `$180,000
Approver: CIO
Status: Approved - Active Subscription

Purchase Order: PO-3200-2025-CSCO
Vendor: Cisco Systems Inc.
Department: IT Infrastructure (Code: 3200)
Description: Network switches and routers (15 units)
Order Date: 2025-02-20
Expected Delivery: 2025-04-05
Total Amount: `$95,000
Approver: Network Manager
Status: Approved - Manufacturing

Purchase Order: PO-3200-2025-VMWR
Vendor: VMware Inc.
Department: IT Infrastructure (Code: 3200)
Description: VMware vSphere Enterprise Plus licenses (100 cores)
Order Date: 2025-03-15
Renewal Date: 2026-03-15
Total Amount: `$65,000
Approver: IT Director
Status: Approved - Processing

DEPARTMENT BUDGET ALLOCATION

IT Infrastructure (3200): FY2025 Budget `$2,500,000
Q1 Spend: `$552,500 (Purchase orders listed above)
Remaining Budget: `$1,947,500
Budget Utilization: 22%

APPROVAL WORKFLOW

All purchase orders PO-3200-YYYY-#### require IT Director approval
Purchase orders exceeding `$100,000 require CIO sign-off
Vendor procurement follows standard requisition process
Three-quote requirement for purchases over `$50,000

VENDOR PERFORMANCE TRACKING

Vendor DELL (PO-3200-2025-DELL): On-time delivery 95%
Vendor LNVO (PO-3200-2025-LNVO): Quality rating 4.5/5.0
Vendor MSFT (PO-3200-2025-MSFT): Support satisfaction 90%
Vendor CSCO (PO-3200-2025-CSCO): Pricing competitiveness: Good
Vendor VMWR (PO-3200-2025-VMWR): Contract renewal in progress

For questions contact: procurement@contoso.com
Security Classification: CONFIDENTIAL
Procurement Data: RESTRICTED
"@
    },
    @{
        Name = "PurchaseOrders_MarketingServices.txt"
        Content = @"
CONTOSO CORPORATION - PURCHASE ORDER REGISTRY
==============================================
Classification: CONFIDENTIAL - PROCUREMENT USE ONLY
Generated: $(Get-Date -Format 'yyyy-MM-dd')
Department: Procurement

MARKETING SERVICES PURCHASE ORDERS - FY2025

Purchase Order: PO-4100-2025-GOOG
Vendor: Google LLC (Google Ads)
Department: Marketing (Code: 4100)
Description: Digital advertising campaign - Q2 2025
Order Date: 2025-04-01
Campaign Duration: 3 months (Q2 2025)
Total Amount: `$250,000
Approver: VP Marketing
Status: Approved - Campaign Active

Purchase Order: PO-4100-2025-META
Vendor: Meta Platforms Inc. (Facebook/Instagram)
Department: Marketing (Code: 4100)
Description: Social media advertising - Product launch campaign
Order Date: 2025-03-15
Campaign Duration: 6 months
Total Amount: `$180,000
Approver: Marketing Director
Status: Approved - Setup Phase

Purchase Order: PO-4100-2025-SFDC
Vendor: Salesforce.com Inc.
Department: Marketing (Code: 4100)
Description: Marketing Cloud licenses and implementation (100 users)
Order Date: 2025-02-01
Subscription Term: Annual
Total Amount: `$120,000
Approver: VP Marketing
Status: Approved - Implementation In Progress

Purchase Order: PO-4100-2025-CNVA
Vendor: Canva Pty Ltd
Department: Marketing (Code: 4100)
Description: Canva Pro team licenses (50 users, annual)
Order Date: 2025-01-15
Renewal Date: 2026-01-15
Total Amount: `$15,000
Approver: Creative Director
Status: Approved - Active Subscription

Purchase Order: PO-4100-2025-ADBE
Vendor: Adobe Inc.
Department: Marketing (Code: 4100)
Description: Adobe Creative Cloud for teams (25 licenses, annual)
Order Date: 2025-01-20
Renewal Date: 2026-01-20
Total Amount: `$45,000
Approver: Creative Director
Status: Approved - Active

CAMPAIGN BUDGET TRACKING

Marketing Department (4100): FY2025 Budget `$3,000,000
Q1-Q2 Committed Spend: `$610,000 (Purchase orders above)
Remaining Budget: `$2,390,000
Budget Utilization: 20%

VENDOR RELATIONSHIP STATUS

Google Ads (PO-4100-2025-GOOG): Platinum partner status
Meta Platforms (PO-4100-2025-META): Strategic partner
Salesforce (PO-4100-2025-SFDC): Implementation partner
Canva (PO-4100-2025-CNVA): Team plan active
Adobe (PO-4100-2025-ADBE): Enterprise licensing agreement

APPROVAL REQUIREMENTS

All procurement requisitions for marketing require VP approval
Digital advertising spend over `$100K requires CFO review
Software subscriptions require IT Security approval
Multi-year contracts require Legal Department review

For questions contact: marketing-procurement@contoso.com
Security Classification: CONFIDENTIAL
Marketing Procurement: INTERNAL USE ONLY
"@
    }
)

$poNumberCount = 0
foreach ($file in $poFiles) {
    $filePath = Join-Path $labsRoot "PurchaseOrders\$($file.Name)"
    try {
        Set-Content -Path $filePath -Value $file.Content -Encoding UTF8
        $patternCount = ([regex]::Matches($file.Content, 'PO-\d{4}-\d{4}-[A-Z]{4}')).Count
        $poNumberCount += $patternCount
        
        Write-Host "   ✅ Created file: PurchaseOrders\$($file.Name)" -ForegroundColor Green
        Write-Host "      📊 Contains $patternCount Purchase Order patterns" -ForegroundColor Cyan
    } catch {
        Write-Host "   ❌ Failed to create file $($file.Name): $_" -ForegroundColor Red
        throw
    }
}

Write-Host ""
Write-Host "   ✅ Purchase Order files created successfully" -ForegroundColor Green
Write-Host "   📊 Total Purchase Order patterns embedded: $poNumberCount" -ForegroundColor Cyan

Write-Host ""

# =============================================================================
# Step 5: Display Summary and Next Steps
# =============================================================================

Write-Host "📋 Step 5: Summary and Next Steps" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ Lab 2 test data creation completed successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "📂 Created Files:" -ForegroundColor Cyan
Write-Host "   ProjectIDs:" -ForegroundColor White
Write-Host "   - EngineeringProject_CloudMigration.txt" -ForegroundColor White
Write-Host "   - MarketingCampaign_ProductLaunch.txt" -ForegroundColor White
Write-Host "   - FinanceInitiative_CostOptimization.txt" -ForegroundColor White
Write-Host ""
Write-Host "   CustomerNumbers:" -ForegroundColor White
Write-Host "   - CustomerAccounts_EnterpriseClients.txt" -ForegroundColor White
Write-Host "   - CustomerSupport_TicketAssignments.txt" -ForegroundColor White
Write-Host ""
Write-Host "   PurchaseOrders:" -ForegroundColor White
Write-Host "   - PurchaseOrders_ITEquipment.txt" -ForegroundColor White
Write-Host "   - PurchaseOrders_MarketingServices.txt" -ForegroundColor White
Write-Host ""

Write-Host "📊 Pattern Statistics:" -ForegroundColor Cyan
Write-Host "   • Project IDs (PROJ-YYYY-####): $projectIDCount instances" -ForegroundColor White
Write-Host "   • Customer Numbers (CUST-######): $customerNumberCount instances" -ForegroundColor White
Write-Host "   • Purchase Orders (PO-####-####-XXXX): $poNumberCount instances" -ForegroundColor White
Write-Host "   • Total Patterns: $($projectIDCount + $customerNumberCount + $poNumberCount) across 7 files" -ForegroundColor White
Write-Host ""

$totalSize = (Get-ChildItem -Path $labsRoot -Recurse -File | Measure-Object -Property Length -Sum).Sum
Write-Host "📦 Total Directory Size: $([math]::Round($totalSize / 1KB, 2)) KB" -ForegroundColor Cyan
Write-Host ""

Write-Host "⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Create custom SITs for each pattern type:" -ForegroundColor White
Write-Host "      - Run .\Create-ProjectIDSIT.ps1" -ForegroundColor White
Write-Host "      - Run .\Create-CustomerNumberSIT.ps1" -ForegroundColor White
Write-Host "      - Run .\Create-PurchaseOrderSIT.ps1" -ForegroundColor White
Write-Host ""
Write-Host "   2. Upload test files to SharePoint for classification testing" -ForegroundColor White
Write-Host ""
Write-Host "   3. Run On-Demand Classification scan on SharePoint site" -ForegroundColor White
Write-Host ""
Write-Host "   4. Validate custom SIT detection:" -ForegroundColor White
Write-Host "      - Run .\Validate-CustomSITs.ps1 -TestDataPath '$labsRoot'" -ForegroundColor White
Write-Host ""
Write-Host "   5. Review results in Content Explorer (Purview Compliance Portal)" -ForegroundColor White
Write-Host ""

Write-Host "💡 Production Tips:" -ForegroundColor Yellow
Write-Host "   - Test patterns locally before uploading to SharePoint" -ForegroundColor White
Write-Host "   - Use these files to validate regex accuracy and keyword effectiveness" -ForegroundColor White
Write-Host "   - Monitor false positive rate in Activity Explorer after deployment" -ForegroundColor White
Write-Host "   - Adjust confidence levels based on real-world classification results" -ForegroundColor White
Write-Host ""

Write-Host "✅ Script execution completed successfully" -ForegroundColor Green

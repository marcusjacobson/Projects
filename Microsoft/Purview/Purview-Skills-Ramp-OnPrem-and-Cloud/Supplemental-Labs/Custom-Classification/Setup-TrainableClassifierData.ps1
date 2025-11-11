<#
.SYNOPSIS
    Complete setup for trainable classifier training data in SharePoint.

.DESCRIPTION
    This script performs the complete setup for custom trainable classifier training:
    1. Creates Classifier_Training library in SharePoint
    2. Creates two folders: FinancialReports_Positive and BusinessDocs_Negative
    3. Generates 100 positive samples (financial reports)
    4. Generates 200 negative samples (non-financial business documents)
    5. Uploads all training documents to appropriate folders

.PARAMETER UseParametersFile
    Not applicable for this script - prompts for SharePoint site URL interactively.

.EXAMPLE
    .\Setup-TrainableClassifierData.ps1
    
    Prompts for SharePoint site URL, guides through Entra ID app registration if needed,
    creates library structure, and generates all 300 training documents.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-09
    Last Modified: 2025-11-09
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PnP PowerShell module installed (Install-Module PnP.PowerShell)
    - SharePoint Online access with site owner/member permissions
    - PowerShell 5.1+ or PowerShell 7+
    
    Script development orchestrated using GitHub Copilot.

.TRAINING STRUCTURE
    Library: Classifier_Training
    - Folder: FinancialReports_Positive (100 financial report documents)
    - Folder: BusinessDocs_Negative (200 business document samples)
#>

# =============================================================================
# Complete Trainable Classifier Training Data Setup
# =============================================================================

Write-Host "🚀 Trainable Classifier Training Data Setup" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: SharePoint Site URL Collection
# =============================================================================

Write-Host "📋 Step 1: SharePoint Site Configuration" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

$siteUrl = Read-Host "Enter your SharePoint site URL (e.g., https://[YourTenant].sharepoint.com/sites/[YourSiteName])"

# Extract tenant from URL for authentication
if ($siteUrl -match '//([^\.]+)\.sharepoint\.com') {
    $tenant = "$($matches[1]).onmicrosoft.com"
    Write-Host "✅ Detected tenant: $tenant" -ForegroundColor Green
} else {
    Write-Host "❌ Invalid SharePoint URL format" -ForegroundColor Red
    exit 1
}

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
                $appName = "PnP-PowerShell-InteractiveLogin-$tenant"
                Register-PnPEntraIDAppForInteractiveLogin -ApplicationName $appName -Tenant $tenant -Interactive
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
# Step 3: SharePoint Authentication
# =============================================================================

Write-Host "`n📋 Step 3: SharePoint Authentication" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

Write-Host "Choose authentication method:" -ForegroundColor Cyan
Write-Host "  1. Interactive Browser (recommended)" -ForegroundColor White
Write-Host "  2. Device Code (for remote/terminal sessions)" -ForegroundColor White
Write-Host ""

$authMethod = Read-Host "Enter choice (1 or 2)"

try {
    if ($authMethod -eq "1") {
        Write-Host "🔄 Connecting via Interactive Browser..." -ForegroundColor Cyan
        Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $appClientId -ErrorAction Stop
    } else {
        Write-Host "🔄 Connecting via Device Code..." -ForegroundColor Cyan
        Write-Host "   You will receive a device code to enter at https://microsoft.com/devicelogin" -ForegroundColor Yellow
        Connect-PnPOnline -Url $siteUrl -DeviceLogin -ClientId $appClientId -Tenant $tenant -ErrorAction Stop
    }
    Write-Host "✅ Connected to SharePoint successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to connect to SharePoint: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Verify the site URL is correct and accessible" -ForegroundColor Gray
    Write-Host "   - Ensure your account has permissions to the site" -ForegroundColor Gray
    Write-Host "   - Check that the Entra ID app registration has SharePoint API permissions" -ForegroundColor Gray
    Write-Host "   - Try the alternative authentication method" -ForegroundColor Gray
    exit 1
}

# =============================================================================
# Step 4: Create Library and Folder Structure
# =============================================================================

Write-Host "`n📋 Step 4: Creating Library Structure" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Check if library already exists
$existingLib = Get-PnPList -Identity "Classifier_Training" -ErrorAction SilentlyContinue

if ($existingLib) {
    Write-Host "⚠️  Classifier_Training library already exists" -ForegroundColor Yellow
    $overwrite = Read-Host "Delete and recreate? (y/n)"
    if ($overwrite -eq 'y') {
        Remove-PnPList -Identity "Classifier_Training" -Force
        Write-Host "✅ Deleted existing library" -ForegroundColor Green
    } else {
        Write-Host "❌ Cannot proceed with existing library - exiting" -ForegroundColor Red
        exit 1
    }
}

# Create library
Write-Host "🔄 Creating Classifier_Training library..." -ForegroundColor Cyan
New-PnPList -Title "Classifier_Training" -Template DocumentLibrary | Out-Null
Write-Host "✅ Library created" -ForegroundColor Green

# Create folders
Write-Host "🔄 Creating FinancialReports_Positive folder..." -ForegroundColor Cyan
Add-PnPFolder -Name "FinancialReports_Positive" -Folder "Classifier_Training" | Out-Null
Write-Host "✅ Positive samples folder created" -ForegroundColor Green

Write-Host "🔄 Creating BusinessDocs_Negative folder..." -ForegroundColor Cyan
Add-PnPFolder -Name "BusinessDocs_Negative" -Folder "Classifier_Training" | Out-Null
Write-Host "✅ Negative samples folder created" -ForegroundColor Green

# =============================================================================
# Step 5: Generate Positive Training Samples (Financial Reports)
# =============================================================================

Write-Host "`n📋 Step 5: Generating Positive Training Samples" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host "🔄 Creating 100 financial report documents..." -ForegroundColor Cyan

1..100 | ForEach-Object {
    $reportNumber = $_
    $quarter = "Q$((Get-Random -Minimum 1 -Maximum 5))"
    $year = Get-Random -Minimum 2022 -Maximum 2025
    $revenue = (Get-Random -Minimum 5000000 -Maximum 50000000)
    $expenses = [int]($revenue * ((Get-Random -Minimum 60 -Maximum 85) / 100))
    $netIncome = $revenue - $expenses
    $grossMargin = [math]::Round((($revenue - $expenses) / $revenue) * 100, 2)
    
    $content = @"
CONTOSO CORPORATION
QUARTERLY FINANCIAL REPORT
$quarter $year

EXECUTIVE SUMMARY

This report presents Contoso Corporation's financial performance for $quarter $year.
The company achieved strong revenue growth and maintained healthy profit margins.

FINANCIAL HIGHLIGHTS

Revenue: `$$($revenue.ToString('N0'))
Operating Expenses: `$$($expenses.ToString('N0'))
Net Income: `$$($netIncome.ToString('N0'))
Gross Margin: $grossMargin%

BALANCE SHEET SUMMARY

Assets:
- Current Assets: `$$((Get-Random -Minimum 10000000 -Maximum 30000000).ToString('N0'))
- Fixed Assets: `$$((Get-Random -Minimum 20000000 -Maximum 50000000).ToString('N0'))
- Total Assets: `$$((Get-Random -Minimum 30000000 -Maximum 80000000).ToString('N0'))

Liabilities:
- Current Liabilities: `$$((Get-Random -Minimum 5000000 -Maximum 15000000).ToString('N0'))
- Long-term Liabilities: `$$((Get-Random -Minimum 10000000 -Maximum 25000000).ToString('N0'))
- Total Liabilities: `$$((Get-Random -Minimum 15000000 -Maximum 40000000).ToString('N0'))

Shareholder Equity: `$$((Get-Random -Minimum 15000000 -Maximum 40000000).ToString('N0'))

CASH FLOW STATEMENT

Operating Activities: `$$((Get-Random -Minimum 3000000 -Maximum 10000000).ToString('N0'))
Investing Activities: `$$((Get-Random -Minimum -2000000 -Maximum 2000000).ToString('N0'))
Financing Activities: `$$((Get-Random -Minimum -1000000 -Maximum 1000000).ToString('N0'))

KEY FINANCIAL RATIOS

Return on Equity (ROE): $((Get-Random -Minimum 10 -Maximum 25))%
Return on Assets (ROA): $((Get-Random -Minimum 5 -Maximum 15))%
Debt-to-Equity Ratio: $([math]::Round((Get-Random) + 0.3, 2))
Current Ratio: $([math]::Round((Get-Random) + 1.5, 2))

This financial report contains confidential information and is intended for internal use only.

END OF REPORT
"@
    
    # Create and upload
    $fileName = "Financial_Report_${quarter}_${year}_${reportNumber}.txt"
    $tempPath = "$env:TEMP\$fileName"
    $content | Out-File -FilePath $tempPath -Encoding UTF8
    
    Add-PnPFile -Path $tempPath -Folder "Classifier_Training/FinancialReports_Positive" | Out-Null
    Remove-Item -Path $tempPath -Force
    
    if ($reportNumber % 10 -eq 0) {
        Write-Host "   Created $reportNumber financial reports..." -ForegroundColor Cyan
    }
}

Write-Host "✅ Created 100 positive training samples (financial reports)" -ForegroundColor Green

# =============================================================================
# Step 6: Generate Negative Training Samples (Business Documents)
# =============================================================================

Write-Host "`n📋 Step 6: Generating Negative Training Samples" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host "🔄 Creating 200 business document samples..." -ForegroundColor Cyan

# Document templates for negative samples
$documentTypes = @(
    @{Type="Meeting Minutes"; Template="MEETING MINUTES`n`nDate: {date}`nAttendees: {attendees}`nTopic: {discussion}`n`nAgenda:`n1. Opening remarks`n2. Review of previous action items`n3. New business discussion`n4. Action items assignment`n`nDiscussion:`n{discussion}`n`nAction Items:`n- Follow up on pending tasks`n- Schedule next meeting`n- Update documentation"},
    @{Type="Marketing Plan"; Template="MARKETING CAMPAIGN PLAN`n`nCampaign: {campaign}`nTarget Audience: {audience}`nBudget: {budget}`nTimeline: {timeline}`n`nObjectives:`n- Increase brand awareness`n- Generate qualified leads`n- Drive customer engagement`n`nChannels:`n- Social media`n- Email marketing`n- Content marketing`n- Paid advertising`n`nMetrics:`n- Impressions`n- Click-through rate`n- Conversion rate`n- Return on investment"},
    @{Type="HR Policy"; Template="HUMAN RESOURCES POLICY`n`nPolicy Name: {policy}`nEffective Date: {date}`n`nPurpose:`nThis policy establishes guidelines for {purpose}.`n`nScope:`nApplies to all employees, contractors, and temporary staff.`n`nProcedures:`n1. {procedure1}`n2. {procedure2}`n3. {procedure3}`n`nCompliance:`nEmployees must comply with this policy. Violations may result in disciplinary action."},
    @{Type="Technical Documentation"; Template="TECHNICAL SPECIFICATION`n`nSystem: {system}`nVersion: {version}`n`nArchitecture Overview:`n{architecture}`n`nComponents:`n- Frontend: {frontend}`n- Backend: {backend}`n- Database: {database}`n`nAPI Endpoints:`n- GET /api/{endpoint1}`n- POST /api/{endpoint2}`n`nSecurity Requirements:`n- Authentication: OAuth 2.0`n- Authorization: Role-based access control`n- Encryption: TLS 1.3"},
    @{Type="Project Status"; Template="PROJECT STATUS REPORT`n`nProject: {project}`nStatus: {status}`nCompletion: {completion}%`n`nMilestones:`n- {milestone1} - Completed`n- {milestone2} - In Progress`n- {milestone3} - Pending`n`nRisks and Issues:`n- {risk1}`n- {risk2}`n`nNext Steps:`n- {nextstep1}`n- {nextstep2}"},
    @{Type="Sales Proposal"; Template="SALES PROPOSAL`n`nClient: {client}`nSolution: {solution}`n`nExecutive Summary:`n{summary}`n`nProposed Solution:`n{solution_detail}`n`nPricing:`n- Base Package: {price1}`n- Premium Package: {price2}`n- Enterprise Package: {price3}`n`nImplementation Timeline:`n{timeline}`n`nTerms and Conditions:`n{terms}"}
)

1..200 | ForEach-Object {
    $docNumber = $_
    $docType = Get-Random -InputObject $documentTypes
    
    # Replace template placeholders with random data
    $content = $docType.Template
    $content = $content -replace '\{date\}', (Get-Date -Format 'yyyy-MM-dd')
    $content = $content -replace '\{attendees\}', ((1..(Get-Random -Minimum 3 -Maximum 8) | ForEach-Object { "Person $_" }) -join ', ')
    $content = $content -replace '\{discussion\}', "Discussion about $(Get-Random -InputObject @('strategy', 'operations', 'planning', 'improvements'))"
    $content = $content -replace '\{campaign\}', "Campaign $(Get-Random -Minimum 100 -Maximum 999)"
    $content = $content -replace '\{audience\}', (Get-Random -InputObject @('Enterprise customers', 'Small businesses', 'Consumers', 'Partners'))
    $content = $content -replace '\{budget\}', "`$$((Get-Random -Minimum 10000 -Maximum 100000).ToString('N0'))"
    $content = $content -replace '\{timeline\}', "$(Get-Random -Minimum 3 -Maximum 12) months"
    $content = $content -replace '\{policy\}', (Get-Random -InputObject @('Remote Work', 'Time Off', 'Code of Conduct', 'Data Security'))
    $content = $content -replace '\{purpose\}', (Get-Random -InputObject @('employee conduct', 'work arrangements', 'leave management', 'security practices'))
    $content = $content -replace '\{procedure\d\}', "Procedure step $(Get-Random -Minimum 1 -Maximum 10)"
    $content = $content -replace '\{system\}', "System-$(Get-Random -Minimum 100 -Maximum 999)"
    $content = $content -replace '\{version\}', "v$(Get-Random -Minimum 1 -Maximum 5).$(Get-Random -Minimum 0 -Maximum 9)"
    $content = $content -replace '\{architecture\}', "Cloud-based $(Get-Random -InputObject @('microservices', 'monolithic', 'serverless')) architecture"
    $content = $content -replace '\{frontend\}', (Get-Random -InputObject @('React', 'Angular', 'Vue.js'))
    $content = $content -replace '\{backend\}', (Get-Random -InputObject @('Node.js', '.NET Core', 'Python'))
    $content = $content -replace '\{database\}', (Get-Random -InputObject @('SQL Server', 'PostgreSQL', 'MongoDB'))
    $content = $content -replace '\{endpoint\d\}', "endpoint$(Get-Random -Minimum 1 -Maximum 99)"
    $content = $content -replace '\{project\}', "Project-$(Get-Random -Minimum 1000 -Maximum 9999)"
    $content = $content -replace '\{status\}', (Get-Random -InputObject @('On Track', 'At Risk', 'Behind Schedule'))
    $content = $content -replace '\{completion\}', (Get-Random -Minimum 25 -Maximum 95)
    $content = $content -replace '\{milestone\d\}', "Milestone $(Get-Random -Minimum 1 -Maximum 5)"
    $content = $content -replace '\{risk\d\}', "Risk: $(Get-Random -InputObject @('Resource availability', 'Technical complexity', 'Budget constraints'))"
    $content = $content -replace '\{nextstep\d\}', "Next step: $(Get-Random -InputObject @('Review requirements', 'Update timeline', 'Schedule meeting'))"
    $content = $content -replace '\{client\}', "Client-$(Get-Random -Minimum 100 -Maximum 999)"
    $content = $content -replace '\{solution\}', (Get-Random -InputObject @('Cloud Migration', 'Digital Transformation', 'Security Enhancement'))
    $content = $content -replace '\{summary\}', "Comprehensive solution for business needs"
    $content = $content -replace '\{solution_detail\}', "Detailed implementation plan with milestones"
    $content = $content -replace '\{price\d\}', "`$$((Get-Random -Minimum 50000 -Maximum 500000).ToString('N0'))"
    $content = $content -replace '\{terms\}', "Standard terms and conditions apply"
    
    # Create and upload
    $fileName = "$($docType.Type -replace ' ', '_')_${docNumber}.txt"
    $tempPath = "$env:TEMP\$fileName"
    $content | Out-File -FilePath $tempPath -Encoding UTF8
    
    Add-PnPFile -Path $tempPath -Folder "Classifier_Training/BusinessDocs_Negative" | Out-Null
    Remove-Item -Path $tempPath -Force
    
    if ($docNumber % 20 -eq 0) {
        Write-Host "   Created $docNumber business documents..." -ForegroundColor Cyan
    }
}

Write-Host "✅ Created 200 negative training samples (business documents)" -ForegroundColor Green

# =============================================================================
# Step 7: Setup Complete
# =============================================================================

Write-Host "`n🎉 Setup Complete!" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Training Data Summary:" -ForegroundColor Cyan
Write-Host "   Library: Classifier_Training" -ForegroundColor White
Write-Host "   - FinancialReports_Positive: 100 financial report documents" -ForegroundColor White
Write-Host "   - BusinessDocs_Negative: 200 business document samples" -ForegroundColor White
Write-Host ""
Write-Host "⏱️  Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Wait 1 hour for SharePoint to index the documents" -ForegroundColor White
Write-Host "   2. Verify indexing by searching for 'revenue' in SharePoint search" -ForegroundColor White
Write-Host "   3. Create trainable classifier in Microsoft Purview portal" -ForegroundColor White
Write-Host "   4. Select FinancialReports_Positive folder for positive samples" -ForegroundColor White
Write-Host "   5. Select BusinessDocs_Negative folder for negative samples" -ForegroundColor White
Write-Host ""
Write-Host "🔗 SharePoint Site: $siteUrl" -ForegroundColor Cyan
Write-Host ""

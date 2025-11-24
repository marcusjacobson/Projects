<#
.SYNOPSIS
    Complete setup for trainable classifier training data in SharePoint.

.DESCRIPTION
    This script performs the complete setup for custom trainable classifier training:
    1. Creates two folders in the root Documents library: FinancialReports_Positive and BusinessDocs_Negative
    2. Generates 100 positive samples (financial reports)
    3. Generates 200 negative samples (non-financial business documents)
    4. Uploads all training documents to appropriate folders in the Documents library

.PARAMETER UseParametersFile
    Not applicable for this script - prompts for SharePoint site URL interactively.

.EXAMPLE
    .\Setup-TrainableClassifierData.ps1
    
    Prompts for SharePoint site URL, guides through Entra ID app registration if needed,
    creates folder structure in Documents library, and generates all 300 training documents.

.NOTES
    Author: Marcus Jacobson
    Version: 1.1.0
    Created: 2025-11-09
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PnP PowerShell module installed (Install-Module PnP.PowerShell)
    - SharePoint Online access with site owner/member permissions
    - PowerShell 5.1+ or PowerShell 7+
    
    Script development orchestrated using GitHub Copilot.

.TRAINING STRUCTURE
    Library: Documents (root SharePoint library)
    - Folder: FinancialReports_Positive (100 financial report documents)
    - Folder: BusinessDocs_Negative (200 business document samples)
    
    CRITICAL: Folders MUST be in the root Documents library for Purview trainable 
    classifiers to recognize them. Custom libraries or nested structures will not work.
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
# Step 4: Create Folder Structure in Documents Library
# =============================================================================

Write-Host "`n📋 Step 4: Creating Folder Structure in Documents Library" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green

Write-Host "⚠️  CRITICAL: Training data folders MUST be in the root Documents library" -ForegroundColor Yellow
Write-Host "   Creating folders in a custom library will prevent Purview from recognizing them" -ForegroundColor Gray
Write-Host ""

# Check if Documents library exists (it should on all SharePoint sites)
$documentsLib = Get-PnPList -Identity "Documents" -ErrorAction SilentlyContinue

if (-not $documentsLib) {
    Write-Host "❌ Documents library not found on this site" -ForegroundColor Red
    Write-Host "   This is unexpected - all SharePoint sites should have a Documents library" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found Documents library" -ForegroundColor Green

# Check if folders already exist
$existingPositive = Get-PnPFolder -Url "Shared Documents/FinancialReports_Positive" -ErrorAction SilentlyContinue
$existingNegative = Get-PnPFolder -Url "Shared Documents/BusinessDocs_Negative" -ErrorAction SilentlyContinue

if ($existingPositive -or $existingNegative) {
    Write-Host "⚠️  Training data folders already exist in Documents library" -ForegroundColor Yellow
    $overwrite = Read-Host "Delete and recreate folders? (y/n)"
    if ($overwrite -eq 'y') {
        if ($existingPositive) {
            Remove-PnPFolder -Name "FinancialReports_Positive" -Folder "Shared Documents" -Force
            Write-Host "✅ Deleted existing FinancialReports_Positive folder" -ForegroundColor Green
        }
        if ($existingNegative) {
            Remove-PnPFolder -Name "BusinessDocs_Negative" -Folder "Shared Documents" -Force
            Write-Host "✅ Deleted existing BusinessDocs_Negative folder" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ Cannot proceed with existing folders - exiting" -ForegroundColor Red
        exit 1
    }
}

# Create folders in Documents library
Write-Host "🔄 Creating FinancialReports_Positive folder in Documents library..." -ForegroundColor Cyan
Add-PnPFolder -Name "FinancialReports_Positive" -Folder "Shared Documents" | Out-Null
Write-Host "✅ Positive samples folder created in Documents" -ForegroundColor Green

Write-Host "🔄 Creating BusinessDocs_Negative folder in Documents library..." -ForegroundColor Cyan
Add-PnPFolder -Name "BusinessDocs_Negative" -Folder "Shared Documents" | Out-Null
Write-Host "✅ Negative samples folder created in Documents" -ForegroundColor Green

# =============================================================================
# Step 5: Generate Positive Training Samples (Financial Reports)
# =============================================================================

Write-Host "`n📋 Step 5: Generating Positive Training Samples (ENHANCED)" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "🔄 Creating 100 HIGHLY SPECIFIC financial report documents..." -ForegroundColor Cyan
Write-Host "📊 Using professional SEC-style quarterly report format" -ForegroundColor Cyan

# Report type templates for maximum specificity
$reportTypes = @(
    @{Name="10-Q"; Title="QUARTERLY REPORT PURSUANT TO SECTION 13 OR 15(d)"; Header="FORM 10-Q"; Regulatory="Securities Exchange Act of 1934"},
    @{Name="10-K"; Title="ANNUAL REPORT PURSUANT TO SECTION 13 OR 15(d)"; Header="FORM 10-K"; Regulatory="Securities Exchange Act of 1934"},
    @{Name="8-K"; Title="CURRENT REPORT PURSUANT TO SECTION 13 OR 15(d)"; Header="FORM 8-K"; Regulatory="Securities Exchange Act of 1934"},
    @{Name="Earnings"; Title="QUARTERLY EARNINGS RELEASE"; Header="EARNINGS ANNOUNCEMENT"; Regulatory="SEC Regulation FD"},
    @{Name="MD&A"; Title="MANAGEMENT'S DISCUSSION AND ANALYSIS OF FINANCIAL CONDITION"; Header="MD&A SECTION"; Regulatory="Item 2 - MD&A"}
)

1..100 | ForEach-Object {
    $reportNumber = $_
    $reportType = $reportTypes[(Get-Random -Minimum 0 -Maximum $reportTypes.Count)]
    $quarter = "Q$((Get-Random -Minimum 1 -Maximum 5))"
    $year = Get-Random -Minimum 2022 -Maximum 2025
    $fiscalQuarter = "FY$(Get-Random -Minimum 2022 -Maximum 2025)-$quarter"
    $filingDate = Get-Date -Year $year -Month (Get-Random -Minimum 1 -Maximum 12) -Day (Get-Random -Minimum 1 -Maximum 28) -Format "MM/dd/yyyy"
    
    # Generate comprehensive financial metrics
    $revenue = (Get-Random -Minimum 50000000 -Maximum 500000000)
    $costOfRevenue = [int]($revenue * ((Get-Random -Minimum 45 -Maximum 65) / 100))
    $grossProfit = $revenue - $costOfRevenue
    $operatingExpenses = [int]($revenue * ((Get-Random -Minimum 20 -Maximum 35) / 100))
    $operatingIncome = $grossProfit - $operatingExpenses
    $interestExpense = [int]($revenue * ((Get-Random -Minimum 1 -Maximum 5) / 100))
    $taxExpense = [int]($operatingIncome * ((Get-Random -Minimum 18 -Maximum 28) / 100))
    $netIncome = $operatingIncome - $interestExpense - $taxExpense
    $eps = [math]::Round($netIncome / 10000000, 2)
    $dilutedEPS = [math]::Round($eps * 0.98, 2)
    
    # Balance sheet items
    $cashAndEquivalents = [int]($revenue * ((Get-Random -Minimum 30 -Maximum 60) / 100))
    $accountsReceivable = [int]($revenue * ((Get-Random -Minimum 15 -Maximum 25) / 100))
    $inventory = [int]($revenue * ((Get-Random -Minimum 10 -Maximum 20) / 100))
    $totalCurrentAssets = $cashAndEquivalents + $accountsReceivable + $inventory + (Get-Random -Minimum 5000000 -Maximum 15000000)
    $ppe = (Get-Random -Minimum 100000000 -Maximum 300000000)
    $intangibleAssets = (Get-Random -Minimum 50000000 -Maximum 150000000)
    $totalAssets = $totalCurrentAssets + $ppe + $intangibleAssets + (Get-Random -Minimum 20000000 -Maximum 50000000)
    
    $accountsPayable = [int]($revenue * ((Get-Random -Minimum 10 -Maximum 15) / 100))
    $shortTermDebt = (Get-Random -Minimum 20000000 -Maximum 80000000)
    $totalCurrentLiabilities = $accountsPayable + $shortTermDebt + (Get-Random -Minimum 10000000 -Maximum 30000000)
    $longTermDebt = (Get-Random -Minimum 100000000 -Maximum 250000000)
    $totalLiabilities = $totalCurrentLiabilities + $longTermDebt + (Get-Random -Minimum 20000000 -Maximum 50000000)
    $shareholderEquity = $totalAssets - $totalLiabilities
    
    # Cash flow statement
    $operatingCashFlow = [int]($netIncome * ((Get-Random -Minimum 110 -Maximum 140) / 100))
    $investingCashFlow = (Get-Random -Minimum -50000000 -Maximum -10000000)
    $financingCashFlow = (Get-Random -Minimum -30000000 -Maximum 30000000)
    $netCashChange = $operatingCashFlow + $investingCashFlow + $financingCashFlow
    
    # Financial ratios
    $currentRatio = [math]::Round($totalCurrentAssets / $totalCurrentLiabilities, 2)
    $quickRatio = [math]::Round(($totalCurrentAssets - $inventory) / $totalCurrentLiabilities, 2)
    $debtToEquity = [math]::Round($totalLiabilities / $shareholderEquity, 2)
    $roe = [math]::Round(($netIncome / $shareholderEquity) * 100, 2)
    $roa = [math]::Round(($netIncome / $totalAssets) * 100, 2)
    $profitMargin = [math]::Round(($netIncome / $revenue) * 100, 2)
    $grossMargin = [math]::Round(($grossProfit / $revenue) * 100, 2)
    $operatingMargin = [math]::Round(($operatingIncome / $revenue) * 100, 2)
    
    $content = @"
================================================================================
                            UNITED STATES
                  SECURITIES AND EXCHANGE COMMISSION
                        Washington, D.C. 20549

                              $($reportType.Header)

                 $($reportType.Title)
                     OF THE $($reportType.Regulatory)

For the fiscal period ended: $filingDate
Commission File Number: 001-$(Get-Random -Minimum 10000 -Maximum 99999)

================================================================================

                           CONTOSO CORPORATION
           (Exact name of registrant as specified in its charter)

       Delaware                                      $(Get-Random -Minimum 10 -Maximum 99)-$(Get-Random -Minimum 1000000 -Maximum 9999999)
(State of incorporation)                        (I.R.S. Employer ID Number)

  One Contoso Plaza, Redmond, WA 98052           (425) 555-$(Get-Random -Minimum 1000 -Maximum 9999)
(Address of principal executive offices)         (Registrant's telephone number)

================================================================================

ITEM 1. FINANCIAL STATEMENTS (UNAUDITED)

                           CONTOSO CORPORATION
             CONDENSED CONSOLIDATED STATEMENTS OF OPERATIONS
                    (In thousands, except per share data)
                              (Unaudited)

                                                       Three Months Ended
                                                         $filingDate
                                                    ----------------------
Revenue:
  Product revenue                                    `$   $(($revenue * 0.7).ToString('N0'))
  Services revenue                                       $(($revenue * 0.3).ToString('N0'))
                                                    ----------------------
    Total revenue                                        $($revenue.ToString('N0'))

Cost of revenue:
  Cost of product revenue                                $(($costOfRevenue * 0.6).ToString('N0'))
  Cost of services revenue                               $(($costOfRevenue * 0.4).ToString('N0'))
                                                    ----------------------
    Total cost of revenue                                $($costOfRevenue.ToString('N0'))
                                                    ----------------------

Gross profit                                             $($grossProfit.ToString('N0'))
Gross margin                                             $grossMargin%

Operating expenses:
  Research and development                               $(($operatingExpenses * 0.45).ToString('N0'))
  Sales and marketing                                    $(($operatingExpenses * 0.35).ToString('N0'))
  General and administrative                             $(($operatingExpenses * 0.20).ToString('N0'))
                                                    ----------------------
    Total operating expenses                             $($operatingExpenses.ToString('N0'))
                                                    ----------------------

Operating income                                         $($operatingIncome.ToString('N0'))
Operating margin                                         $operatingMargin%

Other income (expense):
  Interest expense                                       $((-$interestExpense).ToString('N0'))
  Other income, net                                      $((Get-Random -Minimum 1000000 -Maximum 5000000).ToString('N0'))
                                                    ----------------------

Income before income taxes                               $(($operatingIncome - $interestExpense).ToString('N0'))
Provision for income taxes                               $((-$taxExpense).ToString('N0'))
Effective tax rate                                       $([math]::Round(($taxExpense / ($operatingIncome - $interestExpense)) * 100, 1))%
                                                    ----------------------

Net income                                           `$   $($netIncome.ToString('N0'))
                                                    ======================

Earnings per share:
  Basic                                              `$   $eps
  Diluted                                            `$   $dilutedEPS

Weighted-average shares outstanding:
  Basic                                                  $((Get-Random -Minimum 8000000 -Maximum 12000000).ToString('N0'))
  Diluted                                                $((Get-Random -Minimum 9000000 -Maximum 13000000).ToString('N0'))

================================================================================

                           CONTOSO CORPORATION
              CONDENSED CONSOLIDATED BALANCE SHEETS
                         (In thousands)
                           (Unaudited)

                                                         As of
                                                      $filingDate
                                                   ----------------
ASSETS

Current assets:
  Cash and cash equivalents                        `$  $($cashAndEquivalents.ToString('N0'))
  Short-term investments                               $((Get-Random -Minimum 50000000 -Maximum 150000000).ToString('N0'))
  Accounts receivable, net                             $($accountsReceivable.ToString('N0'))
  Inventories                                          $($inventory.ToString('N0'))
  Prepaid expenses and other                           $((Get-Random -Minimum 5000000 -Maximum 15000000).ToString('N0'))
                                                   ----------------
    Total current assets                               $($totalCurrentAssets.ToString('N0'))

Property, plant and equipment, net                     $($ppe.ToString('N0'))
Goodwill                                               $((Get-Random -Minimum 80000000 -Maximum 200000000).ToString('N0'))
Intangible assets, net                                 $($intangibleAssets.ToString('N0'))
Other long-term assets                                 $((Get-Random -Minimum 20000000 -Maximum 50000000).ToString('N0'))
                                                   ----------------
    Total assets                                   `$  $($totalAssets.ToString('N0'))
                                                   ================

LIABILITIES AND STOCKHOLDERS' EQUITY

Current liabilities:
  Accounts payable                                 `$  $($accountsPayable.ToString('N0'))
  Accrued compensation                                 $((Get-Random -Minimum 10000000 -Maximum 30000000).ToString('N0'))
  Short-term debt                                      $($shortTermDebt.ToString('N0'))
  Other current liabilities                            $((Get-Random -Minimum 15000000 -Maximum 35000000).ToString('N0'))
                                                   ----------------
    Total current liabilities                          $($totalCurrentLiabilities.ToString('N0'))

Long-term debt, net                                    $($longTermDebt.ToString('N0'))
Deferred income taxes                                  $((Get-Random -Minimum 15000000 -Maximum 40000000).ToString('N0'))
Other long-term liabilities                            $((Get-Random -Minimum 10000000 -Maximum 25000000).ToString('N0'))
                                                   ----------------
    Total liabilities                                  $($totalLiabilities.ToString('N0'))

Stockholders' equity:
  Common stock and paid-in capital                     $((Get-Random -Minimum 50000000 -Maximum 150000000).ToString('N0'))
  Retained earnings                                    $(($shareholderEquity * 0.8).ToString('N0'))
  Accumulated other comprehensive income               $(($shareholderEquity * 0.2).ToString('N0'))
                                                   ----------------
    Total stockholders' equity                         $($shareholderEquity.ToString('N0'))
                                                   ----------------
    Total liabilities and stockholders' equity     `$  $($totalAssets.ToString('N0'))
                                                   ================

================================================================================

                           CONTOSO CORPORATION
           CONDENSED CONSOLIDATED STATEMENTS OF CASH FLOWS
                         (In thousands)
                           (Unaudited)

                                                       Three Months Ended
                                                         $filingDate
                                                     ------------------
Operating activities:
  Net income                                         `$  $($netIncome.ToString('N0'))
  Adjustments to reconcile net income to cash:
    Depreciation and amortization                        $((Get-Random -Minimum 15000000 -Maximum 35000000).ToString('N0'))
    Stock-based compensation                             $((Get-Random -Minimum 10000000 -Maximum 25000000).ToString('N0'))
    Deferred income taxes                                $((Get-Random -Minimum -5000000 -Maximum 5000000).ToString('N0'))
    Changes in operating assets and liabilities:
      Accounts receivable                                $((Get-Random -Minimum -15000000 -Maximum -5000000).ToString('N0'))
      Inventories                                        $((Get-Random -Minimum -10000000 -Maximum 10000000).ToString('N0'))
      Accounts payable and accrued liabilities           $((Get-Random -Minimum 5000000 -Maximum 20000000).ToString('N0'))
                                                     ------------------
    Cash provided by operating activities                $($operatingCashFlow.ToString('N0'))

Investing activities:
  Additions to property and equipment                    $(($investingCashFlow * 0.6).ToString('N0'))
  Acquisitions, net of cash acquired                     $(($investingCashFlow * 0.4).ToString('N0'))
  Purchases of investments                               $((Get-Random -Minimum -30000000 -Maximum -10000000).ToString('N0'))
  Sales of investments                                   $((Get-Random -Minimum 10000000 -Maximum 30000000).ToString('N0'))
                                                     ------------------
    Cash used in investing activities                    $($investingCashFlow.ToString('N0'))

Financing activities:
  Proceeds from issuance of debt                         $((Get-Random -Minimum 0 -Maximum 50000000).ToString('N0'))
  Repayment of debt                                      $((Get-Random -Minimum -40000000 -Maximum 0).ToString('N0'))
  Dividends paid                                         $((Get-Random -Minimum -20000000 -Maximum -5000000).ToString('N0'))
  Repurchases of common stock                            $((Get-Random -Minimum -30000000 -Maximum 0).ToString('N0'))
                                                     ------------------
    Cash provided by (used in) financing activities      $($financingCashFlow.ToString('N0'))
                                                     ------------------

Net increase in cash and equivalents                     $($netCashChange.ToString('N0'))
Cash and equivalents, beginning of period                $(($cashAndEquivalents - $netCashChange).ToString('N0'))
                                                     ------------------
Cash and equivalents, end of period                  `$  $($cashAndEquivalents.ToString('N0'))
                                                     ==================

================================================================================

ITEM 2. MANAGEMENT'S DISCUSSION AND ANALYSIS OF FINANCIAL CONDITION
        AND RESULTS OF OPERATIONS

OVERVIEW

We are a leading technology company focused on delivering innovative software,
devices, and cloud services that empower people and organizations worldwide.
Our business is organized into three segments: Productivity and Business
Processes, Intelligent Cloud, and More Personal Computing.

RESULTS OF OPERATIONS

Revenue increased $([math]::Round((Get-Random -Minimum 5 -Maximum 20), 1))% compared to the prior year period, driven by strong
commercial cloud revenue growth. Our commercial cloud gross margin percentage
improved year-over-year, primarily due to improvements in Azure and
improvements across our commercial cloud portfolio.

KEY PERFORMANCE INDICATORS AND NON-GAAP FINANCIAL MEASURES

We use certain key performance indicators (KPIs) and non-GAAP financial
measures to evaluate performance:

- Current Ratio: $currentRatio (measure of liquidity)
- Quick Ratio: $quickRatio (acid-test ratio)
- Debt-to-Equity Ratio: $debtToEquity
- Return on Equity (ROE): $roe%
- Return on Assets (ROA): $roa%
- Net Profit Margin: $profitMargin%
- Gross Margin: $grossMargin%
- Operating Margin: $operatingMargin%

LIQUIDITY AND CAPITAL RESOURCES

Cash and cash equivalents totaled `$$($cashAndEquivalents.ToString('N0')) thousand as of $filingDate.
Our principal sources of liquidity are cash from operations and access to
capital markets. We believe that existing cash, cash equivalents, short-term
investments, and cash flows from operations, together with access to capital
markets, will be sufficient to fund our operating activities, capital
expenditures, acquisition activities, and other liquidity requirements for
at least the next 12 months.

CRITICAL ACCOUNTING POLICIES AND ESTIMATES

The preparation of financial statements in conformity with generally accepted
accounting principles (GAAP) requires management to make estimates and
assumptions. These estimates and assumptions affect reported amounts of assets,
liabilities, revenue, and expenses, as well as disclosures of contingent
liabilities. Actual results may differ from these estimates.

FORWARD-LOOKING STATEMENTS

This report contains forward-looking statements within the meaning of the
Private Securities Litigation Reform Act of 1995. These statements are based
on current expectations and are subject to risks and uncertainties that could
cause actual results to differ materially.

================================================================================

CERTIFICATIONS

I, John Doe, Chief Executive Officer, certify that:

1. I have reviewed this quarterly report on $($reportType.Header);
2. Based on my knowledge, this report does not contain any untrue statement
   of a material fact or omit to state a material fact;
3. Based on my knowledge, the financial statements fairly present the
   financial condition and results of operations;
4. The registrant's other certifying officer and I are responsible for
   establishing and maintaining disclosure controls and procedures;
5. We have evaluated the effectiveness of disclosure controls and procedures
   as of the end of the period covered by this report.

Date: $filingDate

This report contains confidential and proprietary financial information.
Unauthorized distribution is prohibited.

Prepared in accordance with:
- Generally Accepted Accounting Principles (GAAP)
- SEC Regulation S-K
- Sarbanes-Oxley Act of 2002
- FASB Accounting Standards Codification

================================================================================
                                END OF REPORT
================================================================================
"@
    
    # Create and upload with descriptive filename
    $fileName = "$($reportType.Name)_Financial_Report_${fiscalQuarter}_${reportNumber}.txt"
    $tempPath = "$env:TEMP\$fileName"
    $content | Out-File -FilePath $tempPath -Encoding UTF8
    
    Add-PnPFile -Path $tempPath -Folder "Shared Documents/FinancialReports_Positive" | Out-Null
    Remove-Item -Path $tempPath -Force
    
    if ($reportNumber % 10 -eq 0) {
        Write-Host "   Created $reportNumber SEC-style financial reports..." -ForegroundColor Cyan
    }
}

Write-Host "✅ Created 100 HIGHLY SPECIFIC positive training samples (SEC-style financial reports)" -ForegroundColor Green

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
    
    Add-PnPFile -Path $tempPath -Folder "Shared Documents/BusinessDocs_Negative" | Out-Null
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
Write-Host "   Library: Documents (root SharePoint library)" -ForegroundColor White
Write-Host "   - FinancialReports_Positive: 100 financial report documents" -ForegroundColor White
Write-Host "   - BusinessDocs_Negative: 200 business document samples" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  CRITICAL: Folders are in the root Documents library (required for Purview)" -ForegroundColor Yellow
Write-Host ""
Write-Host "⏱️  Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Wait 1 hour for SharePoint to index the documents" -ForegroundColor White
Write-Host "   2. Verify indexing by searching for 'revenue' in SharePoint search" -ForegroundColor White
Write-Host "   3. Create trainable classifier in Microsoft Purview portal" -ForegroundColor White
Write-Host "   4. Select your SharePoint site → Documents library" -ForegroundColor White
Write-Host "   5. Select FinancialReports_Positive folder for positive samples" -ForegroundColor White
Write-Host "   6. Select BusinessDocs_Negative folder for negative samples" -ForegroundColor White
Write-Host ""
Write-Host "🔗 SharePoint Site: $siteUrl" -ForegroundColor Cyan
Write-Host "🔗 Direct Link: $siteUrl/Shared%20Documents/Forms/AllItems.aspx" -ForegroundColor Cyan
Write-Host ""

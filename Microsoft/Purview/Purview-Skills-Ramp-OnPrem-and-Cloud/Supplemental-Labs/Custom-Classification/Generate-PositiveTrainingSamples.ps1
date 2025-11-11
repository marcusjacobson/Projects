# Generate-PositiveTrainingSamples.ps1
# Generates 100 synthetic financial report documents for trainable classifier positive training samples

# Prompt for SharePoint site URL
$siteUrl = Read-Host "Enter your SharePoint site URL (e.g., https://[YourTenant].sharepoint.com/sites/[YourSiteName])"

# Extract tenant from URL
if ($siteUrl -match '//([^\.]+)\.sharepoint\.com') {
    $tenant = "$($matches[1]).onmicrosoft.com"
    Write-Host "   Detected tenant: $tenant" -ForegroundColor Gray
} else {
    $tenant = Read-Host "Enter your tenant (e.g., contoso.onmicrosoft.com)"
}

# Check for Entra ID App Registration
Write-Host "`nChecking Entra ID App Registration..." -ForegroundColor Cyan

$appName = "PnP PowerShell Interactive"
$appClientId = $null

# Check if environment variable already set (from previous session)
if ($env:ENTRAID_APP_ID) {
    Write-Host "   Environment variable already set: $env:ENTRAID_APP_ID" -ForegroundColor Green
    $appClientId = $env:ENTRAID_APP_ID
} else {
    Write-Host "   No app registration found (environment variable not set)" -ForegroundColor Yellow
    Write-Host "   You need to register an Entra ID app for PnP PowerShell" -ForegroundColor Yellow
    Write-Host ""
    
    # Prompt user for registration method
    Write-Host "   Choose app registration method:" -ForegroundColor Cyan
    Write-Host "   1. Automatic (PowerShell 7.4+ required, uses PnP cmdlet)" -ForegroundColor White
    Write-Host "   2. Manual (Works with ALL PowerShell versions, use Azure Portal)" -ForegroundColor White
    Write-Host "   3. Skip (I already have a Client ID)" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "   Enter choice (1, 2, or 3)"
    
    switch ($choice) {
        "1" {
            # Automatic registration
            Write-Host ""
            Write-Host "   Attempting automatic app registration..." -ForegroundColor Cyan
            Write-Host "   This requires PowerShell 7.4+ and will open a browser for authentication" -ForegroundColor Gray
            Write-Host ""
            
            try {
                Register-PnPEntraIDAppForInteractiveLogin -ApplicationName $appName -Tenant $tenant -ErrorAction Stop
                
                Write-Host ""
                Write-Host "   ✅ App registration created successfully!" -ForegroundColor Green
                Write-Host "   ⚠️ You need to copy the Client ID from the output above" -ForegroundColor Yellow
                Write-Host ""
                
                $appClientId = Read-Host "   Enter the Client ID (Application ID) from the output above"
                
            } catch {
                Write-Host ""
                Write-Host "   ❌ Automatic registration failed: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "   This likely means your PowerShell version is older than 7.4" -ForegroundColor Yellow
                Write-Host "   Falling back to manual registration instructions..." -ForegroundColor Yellow
                Write-Host ""
                $choice = "2"
            }
        }
        "2" {
            # Manual registration instructions
            Write-Host ""
            Write-Host "   📋 Manual App Registration Steps:" -ForegroundColor Yellow
            Write-Host "   1. Go to https://portal.azure.com" -ForegroundColor White
            Write-Host "   2. Navigate: Entra ID -> App registrations -> + New registration" -ForegroundColor White
            Write-Host "   3. Name: $appName" -ForegroundColor White
            Write-Host "   4. Account type: Single tenant" -ForegroundColor White
            Write-Host "   5. Redirect URI: Public client/native -> http://localhost" -ForegroundColor White
            Write-Host "   6. Click Register, then COPY the Application (client) ID" -ForegroundColor White
            Write-Host "   7. Add API Permissions:" -ForegroundColor White
            Write-Host "      - SharePoint: AllSites.FullControl, User.ReadWrite.All (Delegated)" -ForegroundColor Gray
            Write-Host "      - Microsoft Graph: Group.ReadWrite.All, User.ReadWrite.All (Delegated)" -ForegroundColor Gray
            Write-Host "   8. Grant admin consent" -ForegroundColor White
            Write-Host "   9. Authentication -> Allow public client flows -> Yes" -ForegroundColor White
            Write-Host ""
            
            $appClientId = Read-Host "   Enter the Client ID (Application ID) from Azure Portal"
        }
        "3" {
            # User already has Client ID
            Write-Host ""
            $appClientId = Read-Host "   Enter your existing Client ID (Application ID)"
        }
        default {
            Write-Host ""
            Write-Host "   ❌ Invalid choice. Exiting..." -ForegroundColor Red
            exit 1
        }
    }
    
    # Validate Client ID format (GUID)
    if ($appClientId -notmatch '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
        Write-Host ""
        Write-Host "   ❌ Invalid Client ID format. Expected GUID format: 12345678-1234-1234-1234-123456789012" -ForegroundColor Red
        Write-Host "   Exiting..." -ForegroundColor Red
        exit 1
    }
    
    # Save to environment variable for future sessions
    $env:ENTRAID_APP_ID = $appClientId
    Write-Host ""
    Write-Host "   ✅ Environment variable set: ENTRAID_APP_ID = $appClientId" -ForegroundColor Green
}

# Connect to SharePoint Online with authentication choice
Write-Host "`nConnecting to SharePoint Online..." -ForegroundColor Cyan
$authMethod = Read-Host "Authentication method? (1=Interactive Browser, 2=Device Code)"

try {
    if ($authMethod -eq "1") {
        # Interactive browser-based authentication (best for standalone PowerShell)
        Write-Host "   Opening browser for authentication..." -ForegroundColor Gray
        Connect-PnPOnline -Url $siteUrl -Interactive -ErrorAction Stop
    } else {
        # Device code flow (best for VS Code terminal, SSH, Cloud Shell)
        Write-Host "   Using device code authentication (no browser spawning required)." -ForegroundColor Gray
        Write-Host "   A code will be displayed below - it's automatically copied to your clipboard." -ForegroundColor Gray
        Write-Host "   Open https://microsoft.com/devicelogin in a browser and paste the code." -ForegroundColor Gray
        Write-Host ""
        Connect-PnPOnline -Url $siteUrl -DeviceLogin -Tenant $tenant -ErrorAction Stop
    }
    
    Write-Host "✅ Connected to SharePoint successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to connect: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Verify `$env:ENTRAID_APP_ID is set to YOUR app's Client ID" -ForegroundColor Gray
    Write-Host "      Current value: $env:ENTRAID_APP_ID" -ForegroundColor Gray
    Write-Host "   2. Verify you have permissions (Site Owner or Site Collection Admin)" -ForegroundColor Gray
    Write-Host "   3. Check the site URL is correct" -ForegroundColor Gray
    Write-Host "   4. Ensure admin consent was granted for the Entra ID app" -ForegroundColor Gray
    Write-Host "   5. Verify 'Allow public client flows' is set to Yes in app settings" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   See app registration instructions above if you haven't created the app yet." -ForegroundColor Gray
    exit 1
}

Write-Host "`n🔄 Generating 100 positive training samples (financial reports)..." -ForegroundColor Cyan

# Generate 100 positive samples (financial reports)
1..100 | ForEach-Object {
    $reportNumber = $_
    $quarter = "Q$((Get-Random -Minimum 1 -Maximum 4))"
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
EBITDA: `$$((Get-Random -Minimum 1000000 -Maximum 10000000).ToString('N0'))

BALANCE SHEET SUMMARY

Total Assets: `$$((Get-Random -Minimum 50000000 -Maximum 200000000).ToString('N0'))
Total Liabilities: `$$((Get-Random -Minimum 20000000 -Maximum 100000000).ToString('N0'))
Shareholders' Equity: `$$((Get-Random -Minimum 30000000 -Maximum 100000000).ToString('N0'))

INCOME STATEMENT

Revenue
  Product Sales: `$$((Get-Random -Minimum 2000000 -Maximum 20000000).ToString('N0'))
  Service Revenue: `$$((Get-Random -Minimum 1000000 -Maximum 10000000).ToString('N0'))
  Other Income: `$$((Get-Random -Minimum 100000 -Maximum 1000000).ToString('N0'))

Expenses
  Cost of Goods Sold: `$$((Get-Random -Minimum 2000000 -Maximum 15000000).ToString('N0'))
  Sales & Marketing: `$$((Get-Random -Minimum 1000000 -Maximum 8000000).ToString('N0'))
  Research & Development: `$$((Get-Random -Minimum 500000 -Maximum 5000000).ToString('N0'))
  General & Administrative: `$$((Get-Random -Minimum 500000 -Maximum 3000000).ToString('N0'))

CASH FLOW STATEMENT

Operating Activities: `$$((Get-Random -Minimum 1000000 -Maximum 10000000).ToString('N0'))
Investing Activities: -`$$((Get-Random -Minimum 500000 -Maximum 5000000).ToString('N0'))
Financing Activities: -`$$((Get-Random -Minimum 200000 -Maximum 2000000).ToString('N0'))

MANAGEMENT DISCUSSION

The $quarter $year quarter demonstrated solid financial performance with revenue growth
driven by increased product sales and expanding service offerings. Operating margins
remained strong due to operational efficiency improvements and cost management initiatives.

Looking forward, we anticipate continued revenue growth in the next quarter supported
by new product launches and market expansion strategies.

FINANCIAL METRICS

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
        Write-Host "   Created $reportNumber financial report samples..." -ForegroundColor Cyan
    }
}

Write-Host "`n✅ Created 100 positive training samples (financial reports)" -ForegroundColor Green
Write-Host "`n📊 Sample Details:" -ForegroundColor Cyan
Write-Host "   - Document type: Quarterly financial reports" -ForegroundColor White
Write-Host "   - Content: Revenue, expenses, balance sheets, financial metrics" -ForegroundColor White
Write-Host "   - Date range: Q1-Q4, 2022-2025" -ForegroundColor White
Write-Host "   - Target location: Classifier_Training/FinancialReports_Positive" -ForegroundColor White
Write-Host "   - Purpose: Trainable classifier positive samples" -ForegroundColor White

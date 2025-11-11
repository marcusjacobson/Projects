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
                Write-Host "   [OK] App registration created successfully!" -ForegroundColor Green
                Write-Host "   [!] You need to copy the Client ID from the output above" -ForegroundColor Yellow
                Write-Host ""
                
                $appClientId = Read-Host "   Enter the Client ID (Application ID) from the output above"
                
            } catch {
                Write-Host ""
                Write-Host "   [ERROR] Automatic registration failed: $($_.Exception.Message)" -ForegroundColor Red
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
            Write-Host "   [ERROR] Invalid choice. Exiting..." -ForegroundColor Red
            return
        }
    }
    
    # Validate Client ID format (GUID)
    if ($appClientId -notmatch '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
        Write-Host ""
        Write-Host "   [ERROR] Invalid Client ID format. Expected GUID format: 12345678-1234-1234-1234-123456789012" -ForegroundColor Red
        Write-Host "   Exiting..." -ForegroundColor Red
        return
    }
    
    # Save to environment variable for future sessions
    $env:ENTRAID_APP_ID = $appClientId
    Write-Host ""
    Write-Host "   [OK] Environment variable set: ENTRAID_APP_ID = $appClientId" -ForegroundColor Green
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
    return
}

# Prompt for document library name
Write-Host "`nDocument Library Selection..." -ForegroundColor Cyan
Write-Host "   Common library names:" -ForegroundColor Gray
Write-Host "   - 'Shared Documents' (default library in most sites)" -ForegroundColor Gray
Write-Host "   - 'Documents' (alternative default)" -ForegroundColor Gray
Write-Host "   - Your custom library name" -ForegroundColor Gray
Write-Host ""

$libraryName = Read-Host "Enter document library name (default: 'Shared Documents')"
if ([string]::IsNullOrWhiteSpace($libraryName)) {
    $libraryName = "Shared Documents"
}

Write-Host "   Using library: $libraryName" -ForegroundColor Green

# Sample sensitive data patterns
$creditCards = @(
    "4532-1234-5678-9010", "5425-2334-3010-9876", "3782-822463-10005",
    "6011-1111-1111-1117", "3056-9309-0259-04", "4916-3385-0975-3862"
)

$ssns = @(
    "123-45-6789", "987-65-4321", "456-78-9012", 
    "234-56-7890", "345-67-8901", "567-89-0123"
)

$names = @(
    "John Smith", "Jane Doe", "Michael Johnson", "Sarah Williams",
    "David Brown", "Emily Davis", "Robert Miller", "Lisa Wilson"
)

# Initialize Word COM object (required for .docx creation)
Write-Host "`nInitializing Microsoft Word..." -ForegroundColor Cyan

# Function to create and initialize Word application
function Initialize-WordApplication {
    try {
        $wordApp = New-Object -ComObject Word.Application
        $wordApp.Visible = $false
        $wordApp.DisplayAlerts = 0  # wdAlertsNone
        return $wordApp
    } catch {
        Write-Host "   ❌ Failed to initialize Word: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Function to safely clean up Word application
function Close-WordApplication {
    param($wordApp)
    
    if ($null -ne $wordApp) {
        try {
            $wordApp.Quit()
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wordApp) | Out-Null
        } catch {
            # Suppress cleanup errors
        }
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}

# Initialize first Word instance
$word = Initialize-WordApplication
if ($null -eq $word) {
    Write-Host "   📋 Requirement: Microsoft Word must be installed on this machine" -ForegroundColor Yellow
    Write-Host "   💡 Alternative: Run this script on a machine with Microsoft Word installed" -ForegroundColor Yellow
    return
}
Write-Host "   ✅ Word COM object initialized" -ForegroundColor Green

# Generate 1000 documents with varying sensitive content
$successCount = 0
$failCount = 0

1..1000 | ForEach-Object {
    $docNumber = $_
    
    # Recreate Word application every 100 documents to prevent COM exhaustion
    if ($docNumber % 100 -eq 1 -and $docNumber -gt 1) {
        Write-Host "   🔄 Refreshing Word COM object (document $docNumber)..." -ForegroundColor Gray
        Close-WordApplication -wordApp $word
        Start-Sleep -Milliseconds 500
        $word = Initialize-WordApplication
        
        if ($null -eq $word) {
            Write-Warning "Failed to reinitialize Word at document $docNumber. Stopping..."
            return
        }
    }
    
    # Randomly decide content type (40% sensitive, 60% normal)
    $includeSensitive = (Get-Random -Maximum 100) -lt 40
    
    if ($includeSensitive) {
        # Create document with sensitive data
        $content = @"
Financial Report - Document $docNumber
Date: $(Get-Date -Format 'yyyy-MM-dd')

Customer Information:
Name: $(Get-Random -InputObject $names)
SSN: $(Get-Random -InputObject $ssns)
Credit Card: $(Get-Random -InputObject $creditCards)

Account Balance: `$$((Get-Random -Minimum 1000 -Maximum 50000))
Transaction History: Approved for $(Get-Random -Minimum 5 -Maximum 20) transactions.

This document contains confidential customer data for internal use only.
"@
    } else {
        # Create normal document
        $content = @"
General Report - Document $docNumber
Date: $(Get-Date -Format 'yyyy-MM-dd')

Summary: This is a general business document without sensitive information.
Status: $(Get-Random -InputObject @('Active', 'Pending', 'Completed'))
Department: $(Get-Random -InputObject @('Marketing', 'Sales', 'Operations'))

No confidential data included in this document.
"@
    }
    
    # Create Word document locally
    $fileName = "TestDoc_$docNumber.docx"
    $tempPath = "$env:TEMP\$fileName"
    
    try {
        # Validate Word application is still available
        if ($null -eq $word) {
            throw "Word application object is null"
        }
        
        # Create new Word document
        $doc = $word.Documents.Add()
        
        # Validate document was created
        if ($null -eq $doc) {
            throw "Failed to create Word document object"
        }
        
        # Add content using Range instead of Content.Text for better reliability
        $range = $doc.Range()
        $range.Text = $content
        
        # Save and close document
        $doc.SaveAs([ref]$tempPath)
        $doc.Close($false)  # Close without saving again
        
        # Release document COM object immediately
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($doc) | Out-Null
        
        # Upload to SharePoint with date variation (distribute across 3 years)
        $daysBack = Get-Random -Minimum 0 -Maximum 1095  # 0-3 years
        $fileDate = (Get-Date).AddDays(-$daysBack)
        
        Add-PnPFile -Path $tempPath -Folder $libraryName -ErrorAction Stop | Out-Null
        
        # Update Created date for realistic distribution
        $uploadedItem = Get-PnPListItem -List $libraryName -Query "<View><Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='Text'>$fileName</Value></Eq></Where></Query></View>"
        if ($uploadedItem) {
            Set-PnPListItem -List $libraryName -Identity $uploadedItem.Id -Values @{
                "Created" = $fileDate
                "Modified" = $fileDate.AddDays((Get-Random -Minimum 1 -Maximum 30))
            } | Out-Null
        }
        
        # Clean up temp file
        Remove-Item -Path $tempPath -Force -ErrorAction SilentlyContinue
        
        $successCount++
        
    } catch {
        $failCount++
        Write-Warning "Failed to create/upload document $docNumber : $($_.Exception.Message)"
        
        # Attempt to recreate Word if we have too many consecutive failures
        if ($failCount % 5 -eq 0) {
            Write-Host "   ⚠️ Multiple failures detected. Attempting Word reset..." -ForegroundColor Yellow
            Close-WordApplication -wordApp $word
            Start-Sleep -Milliseconds 1000
            $word = Initialize-WordApplication
        }
    }
    
    # Progress indicator every 50 files
    if ($docNumber % 50 -eq 0) {
        Write-Host "Created $docNumber documents ($successCount successful, $failCount failed)..." -ForegroundColor Cyan
    }
}

# Clean up Word COM object
Write-Host "`nCleaning up Word COM object..." -ForegroundColor Cyan
Close-WordApplication -wordApp $word

Write-Host "✅ Completed: $successCount documents uploaded successfully, $failCount failed" -ForegroundColor Green
Write-Host "   Expected sensitive documents: ~$([math]::Round($successCount * 0.4))" -ForegroundColor Gray

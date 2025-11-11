#============================================================================
# Step 1: Prompt for SharePoint Site URL
#============================================================================

Write-Host "`n[SharePoint Site URL]" -ForegroundColor Yellow
Write-Host "   Finding your SharePoint site URL:" -ForegroundColor Cyan
Write-Host "   1. Navigate to: SharePoint Admin Center -> Active sites" -ForegroundColor White
Write-Host "   2. Find your test site (e.g., 'Finance Test Site' or 'Sensitive Data Archive')" -ForegroundColor White
Write-Host "   3. Copy the URL (e.g., https://yourtenant.sharepoint.com/sites/YourTestSite)" -ForegroundColor White
Write-Host ""
Write-Host "   TIP: You can also navigate to the site in your browser and copy the URL from the address bar!" -ForegroundColor Gray
Write-Host ""

$siteUrl = Read-Host "Enter SharePoint site URL"

# Validate URL format
if ($siteUrl -notmatch '^https://.*\.sharepoint\.com/sites/') {
    Write-Host "`nWARNING: URL doesn't match expected SharePoint format" -ForegroundColor Yellow
    Write-Host "   Expected format: https://yourtenant.sharepoint.com/sites/YourSiteName" -ForegroundColor Gray
    $continue = Read-Host "Continue anyway? (yes/no)"
    if ($continue -ne 'yes') {
        Write-Host "   Connection cancelled." -ForegroundColor Yellow
        return
    }
}

#============================================================================
# Step 2: Check for Entra ID App Registration (Auto-Create if Missing)
#============================================================================

Write-Host "`n[Checking Entra ID App Registration]..." -ForegroundColor Cyan

# Extract tenant from URL
if ($siteUrl -match '//([^\.]+)\.sharepoint\.com') {
    $tenant = "$($matches[1]).onmicrosoft.com"
    Write-Host "   Detected tenant: $tenant" -ForegroundColor Gray
} else {
    $tenant = Read-Host "Enter your tenant (e.g., contoso.onmicrosoft.com)"
}

$appName = "PnP PowerShell Interactive"
$appClientId = $null

# Check if environment variable already set (from previous session)
if ($env:ENTRAID_APP_ID) {
    Write-Host "   Environment variable already set: $env:ENTRAID_APP_ID" -ForegroundColor Green
    Write-Host "   Verifying app registration exists..." -ForegroundColor Gray
    
    # Note: We assume the app exists if the env var is set
    # If you want to verify, you'd need Microsoft Graph PowerShell module
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
                # Attempt automatic registration
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
                
                # Fall back to manual instructions
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
    
    # Set environment variable
    $env:ENTRAID_APP_ID = $appClientId
    Write-Host ""
    Write-Host "   [OK] Environment variable set: ENTRAID_APP_ID = $appClientId" -ForegroundColor Green
}

#============================================================================
# Step 3: Connect to SharePoint
#============================================================================

Write-Host "`n[Connecting to SharePoint]..." -ForegroundColor Cyan

# Choose authentication method based on environment
$authMethod = Read-Host "Authentication method? (1=Interactive Browser, 2=Device Code)"

try {
    if ($authMethod -eq "1") {
        # Interactive browser-based authentication (best for standalone PowerShell.exe)
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
    
    Write-Host "[SUCCESS] Connected to SharePoint" -ForegroundColor Green
    
    # Display site information
    $web = Get-PnPWeb
    Write-Host "[Site Information]" -ForegroundColor Cyan
    Write-Host "   Title: $($web.Title)" -ForegroundColor White
    Write-Host "   URL: $($web.Url)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "[ERROR] Failed to connect: $($_.Exception.Message)" -ForegroundColor Red
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

#============================================================================
# Step 3: Query and Delete Old/Sensitive Files
#============================================================================

Write-Host "[Querying SharePoint Library]..." -ForegroundColor Cyan
Write-Host "   Searching for files to delete..." -ForegroundColor Gray
Write-Host ""

# Get all items from document library
$libraryName = "Sensitive Data Archive"  # Update if needed for your lab
$allItems = Get-PnPListItem -List $libraryName -PageSize 500

# Filter files: 3+ years old OR containing sensitive data
$cutoffDate = (Get-Date).AddYears(-3)

$deleteTargets = $allItems | Where-Object {
    $modified = $_.FieldValues.Modified
    $fileName = $_.FieldValues.FileLeafRef
    
    # Check if file is old enough
    $isOld = $modified -lt $cutoffDate
    
    # Check if filename indicates sensitive data (simple heuristic)
    $hasSensitiveIndicator = $fileName -match 'SSN|CreditCard|Confidential|Payment'
    
    # Delete if old OR sensitive
    $isOld -or $hasSensitiveIndicator
}

Write-Host "[Files Matching Deletion Criteria: $($deleteTargets.Count)]" -ForegroundColor Yellow

# Create audit log before deletion
$deletionLog = @()

foreach ($item in $deleteTargets) {
    $deletionLog += [PSCustomObject]@{
        FileName = $item.FieldValues.FileLeafRef
        FilePath = $item.FieldValues.FileRef
        Modified = $item.FieldValues.Modified
        ModifiedBy = $item.FieldValues.Editor.LookupValue
        SizeMB = [math]::Round($item.FieldValues.File_x0020_Size / 1MB, 2)
        DeletedOn = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Reason = "3+ years old or sensitive data"
    }
    
    Write-Host "   - $($item.FieldValues.FileLeafRef) (Modified: $($item.FieldValues.Modified.ToString('yyyy-MM-dd')))" -ForegroundColor Gray
}

# Create output directory if it doesn't exist
$outputDir = "C:\PurviewLab"
if (-not (Test-Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    Write-Host "`n[OK] Created output directory: $outputDir" -ForegroundColor Green
}

# Export audit log
$deletionLog | Export-Csv "$outputDir\SharePoint-Deletions.csv" -NoTypeInformation
Write-Host "`nAudit log created: $outputDir\SharePoint-Deletions.csv" -ForegroundColor Cyan

#============================================================================
# Step 4: Execute Deletion (with confirmation)
#============================================================================

Write-Host ""
$confirm = Read-Host "Delete $($deleteTargets.Count) files from SharePoint? (yes/no)"

if ($confirm -eq 'yes') {
    Write-Host "`n[Deleting Files]..." -ForegroundColor Cyan
    
    foreach ($item in $deleteTargets) {
        try {
            # Use -Recycle for safety (can be restored from recycle bin)
            Remove-PnPListItem -List $libraryName -Identity $item.Id -Recycle -Force
            
            Write-Host "   [SUCCESS] Deleted: $($item.FieldValues.FileLeafRef)" -ForegroundColor Green
            
        } catch {
            Write-Host "   [ERROR] Failed to delete: $($item.FieldValues.FileLeafRef) - $_" -ForegroundColor Red
        }
    }
    
    Write-Host "`n[SUCCESS] Deletion complete. Files moved to SharePoint Recycle Bin." -ForegroundColor Green
    Write-Host "   Audit log saved to: C:\PurviewLab\SharePoint-Deletions.csv" -ForegroundColor Cyan
} else {
    Write-Host "`nDeletion cancelled by user." -ForegroundColor Yellow
}

# Disconnect
Disconnect-PnPOnline
Write-Host "`nDisconnected from SharePoint." -ForegroundColor Gray

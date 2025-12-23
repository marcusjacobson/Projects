<#
.SYNOPSIS
    Grants PnP PowerShell app permissions to SharePoint sites.

.DESCRIPTION
    This script explicitly registers the PnP PowerShell app registration with SharePoint
    sites to enable file upload operations. When sites are created separately from upload
    operations, the app may not have site-level permissions even when tenant-level
    AllSites.FullControl permissions exist.
    
    This script uses the SharePoint Admin Center to grant the app principal explicit
    permissions at each site collection.

.PARAMETER GlobalConfigPath
    Optional path to the global configuration file. If not specified, uses default location.

.EXAMPLE
    .\Grant-AppSitePermissions.ps1
    
    Grants app permissions to all sites defined in global-config.json.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - PnP.PowerShell module v2.0+
    - SharePoint Administrator permissions
    - App registration with AllSites.FullControl permissions
    
    Script development orchestrated using GitHub Copilot.

.DOCUMENT UPLOAD OPERATIONS
    - App Registration Permission Granting
    - SharePoint Admin Center Connection
    - Site Collection Permission Management
    - Service Principal Verification
#>
#
# =============================================================================
# Grant PnP PowerShell app permissions to SharePoint site collections.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath
)

# =============================================================================
# Step 1: Load Configuration
# =============================================================================

Write-Host "🔍 Step 1: Load Configuration" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

# Import shared modules
. "$PSScriptRoot\..\..\Shared-Utilities\Import-PurviewModules.ps1"

# Import the config loading function
. "$PSScriptRoot\..\..\Shared-Utilities\Import-GlobalConfig.ps1"

try {
    # Call the function to get config
    $config = Import-GlobalConfig -GlobalConfigPath $GlobalConfigPath
    Write-Host "   ✅ Configuration loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to load configuration: $($_.Exception.Message)" -ForegroundColor Red
    throw "Configuration load failure"
}

$clientId = $config.Environment.PnPClientId

if ([string]::IsNullOrWhiteSpace($clientId)) {
    Write-Host "   ❌ PnPClientId not found in configuration" -ForegroundColor Red
    Write-Host "   💡 Please ensure global-config.json has Environment.PnPClientId defined" -ForegroundColor Yellow
    exit 1
}

$tenantUrl = $config.Environment.TenantUrl.TrimEnd('/')

Write-Host "   ✅ App Registration: $clientId" -ForegroundColor Green
Write-Host "   ✅ Tenant URL: $tenantUrl" -ForegroundColor Green
Write-Host "   ✅ Sites to configure: $($config.SharePointSites.Count)" -ForegroundColor Green

# =============================================================================
# Step 2: Get App Service Principal Information
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Get App Service Principal Information" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

Write-Host "   🔍 Looking up service principal for app $clientId..." -ForegroundColor Cyan

try {
    # Get the service principal for the app registration
    $spOutput = az ad sp show --id $clientId --output json 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ❌ Azure CLI command failed with exit code $LASTEXITCODE" -ForegroundColor Red
        Write-Host "   Output: $spOutput" -ForegroundColor Yellow
        throw "Failed to query service principal"
    }
    
    $spInfo = $spOutput | ConvertFrom-Json
    
    if ($null -eq $spInfo) {
        Write-Host "   ❌ Service principal not found for app $clientId" -ForegroundColor Red
        throw "Service principal not found"
    }
    
    $servicePrincipalId = $spInfo.id
    $displayName = $spInfo.displayName
    
    Write-Host "   ✅ Service Principal: $displayName" -ForegroundColor Green
    Write-Host "   ✅ Service Principal ID: $servicePrincipalId" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Failed to get service principal: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   💡 Ensure you're logged in with Azure CLI: az login" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 3: Grant App Permissions at Site Collection Level
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Grant App Permissions at Site Collection Level" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

Write-Host "   🔐 Connecting to SharePoint Admin Center..." -ForegroundColor Cyan

try {
    # Connect to admin center using Interactive authentication
    Connect-PurviewServices -Services @("SharePoint") -TenantUrl $config.Environment.AdminCenterUrl -PnPClientId $clientId -Interactive
    Write-Host "   ✅ Connected to Admin Center" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to connect to Admin Center: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$successCount = 0
$failureCount = 0

foreach ($site in $config.SharePointSites) {
    $siteUrl = "$tenantUrl/sites/$($site.Name)"
    Write-Host ""
    Write-Host "   📋 Processing site: $($site.Name)" -ForegroundColor Cyan
    Write-Host "      URL: $siteUrl" -ForegroundColor Cyan
    
    try {
        # Grant the app FullControl at site collection level using Grant-PnPAzureADAppSitePermission
        Write-Host "      🔧 Granting FullControl permission to app..." -ForegroundColor Cyan
        
        Grant-PnPAzureADAppSitePermission `
            -AppId $clientId `
            -DisplayName $displayName `
            -Site $siteUrl `
            -Permissions FullControl `
            -ErrorAction Stop
        
        Write-Host "      ✅ App permissions granted successfully" -ForegroundColor Green
        $successCount++
        
    } catch {
        Write-Host "      ❌ Failed to grant app permissions: $($_.Exception.Message)" -ForegroundColor Red
        $failureCount++
    }
}

# =============================================================================
# Step 4: Verify App Permissions
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 4: Verify App Permissions" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

Write-Host "   🔍 Verifying app permissions on each site..." -ForegroundColor Cyan

foreach ($site in $config.SharePointSites) {
    $siteUrl = "$tenantUrl/sites/$($site.Name)"
    
    try {
        # Connect to the site to verify permissions
        Connect-PurviewServices -Services @("SharePoint") -TenantUrl $siteUrl -PnPClientId $clientId -Interactive
        
        # Try to get site information (if this works, permissions are good)
        $web = Get-PnPWeb -ErrorAction Stop
        Write-Host "   ✅ $($site.Name): App can access site ($($web.Title))" -ForegroundColor Green
        
    } catch {
        Write-Host "   ⚠️  $($site.Name): Verification failed - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# =============================================================================
# Step 5: Summary
# =============================================================================

Write-Host ""
Write-Host "🎯 Permission Grant Summary:" -ForegroundColor Cyan
Write-Host "   📊 Sites Processed: $($config.SharePointSites.Count)" -ForegroundColor Cyan
Write-Host "   📊 Successful Grants: $successCount" -ForegroundColor Cyan
Write-Host "   📊 Failed Grants: $failureCount" -ForegroundColor Cyan

if ($failureCount -gt 0) {
    Write-Host ""
    Write-Host "⚠️  Some sites failed permission grant. Review errors above." -ForegroundColor Yellow
    Write-Host "💡 You may need to wait a few minutes and run this script again." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host ""
    Write-Host "✅ App permissions granted successfully to all sites" -ForegroundColor Green
    Write-Host "🎯 Next Step: Run Invoke-BulkDocumentUpload.ps1 to upload documents" -ForegroundColor Cyan
    exit 0
}

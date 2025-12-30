<#
.SYNOPSIS
    Creates SharePoint site for Retail Operations DLP testing.

.DESCRIPTION
    This script creates a SharePoint Team Site for hosting retail customer test data.
    Uses PnP.PowerShell with service principal authentication (certificate-based)
    for automated, non-interactive deployment.

.EXAMPLE
    .\New-RetailSite.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 3.0.0
    Created: 2025-12-29
    Last Modified: 2025-12-30
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param()

# =============================================================================
# Step 1: Load Configuration
# =============================================================================

Write-Host "`n🔍 Step 1: Load Configuration" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptPath)
$configPath = Join-Path $projectRoot "templates\global-config.json"

if (-not (Test-Path $configPath)) {
    Write-Host "❌ Configuration file not found: $configPath" -ForegroundColor Red
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
Write-Host "✅ Configuration loaded" -ForegroundColor Green
Write-Host "   📋 Tenant: $($config.sharePointRootUrl)" -ForegroundColor Cyan

# =============================================================================
# Step 2: Connect to SharePoint
# =============================================================================

Write-Host "`n🔍 Step 2: Connect to SharePoint" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

$tenantUrl = $config.sharePointRootUrl.TrimEnd('/')
$tenantId = $config.tenantId

# Get app registration details from service principal config
$appId = "497be3e7-9fe4-444c-beaa-3d486889d1c3"  # From global-config servicePrincipal

# Get certificate thumbprint from local certificate store
Write-Host "   🔍 Looking for certificate in local store..." -ForegroundColor Cyan
$cert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=PurviewAutomationCert" } | Sort-Object NotAfter -Descending | Select-Object -First 1

if (-not $cert) {
    Write-Host "❌ Certificate not found in certificate store" -ForegroundColor Red
    Write-Host "   Expected: CN=PurviewAutomationCert" -ForegroundColor Yellow
    exit 1
}

Write-Host "   ✅ Found certificate (expires: $($cert.NotAfter))" -ForegroundColor Green
Write-Host "   🔐 Connecting with service principal..." -ForegroundColor Cyan

try {
    # Disconnect any existing session (suppress all errors)
    try { Disconnect-PnPOnline } catch { }
    
    # Connect with service principal using certificate thumbprint
    Connect-PnPOnline -Url $tenantUrl -ClientId $appId -Thumbprint $cert.Thumbprint -Tenant $tenantId -ErrorAction Stop
    Write-Host "   ✅ Connected to SharePoint with service principal" -ForegroundColor Green
} catch {
    Write-Host "❌ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    
    # Provide helpful troubleshooting
    if ($_.Exception.Message -like "*certificate*") {
        Write-Host "`n💡 Certificate issue detected" -ForegroundColor Yellow
        Write-Host "   Certificate thumbprint: $($cert.Thumbprint)" -ForegroundColor Yellow
        Write-Host "   Ensure certificate is uploaded to app registration in Azure Portal" -ForegroundColor Cyan
    }
    exit 1
}

# =============================================================================
# Step 3: Create Site
# =============================================================================

Write-Host "`n🔍 Step 3: Create SharePoint Site" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

$siteUrl = "$tenantUrl/sites/$($config.sharePointSite.name)"
$siteTitle = $config.sharePointSite.title
$siteOwner = $config.sharePointSite.owner

Write-Host "📋 URL: $siteUrl" -ForegroundColor Cyan
Write-Host "📋 Title: $siteTitle" -ForegroundColor Cyan
Write-Host "📋 Owner: $siteOwner" -ForegroundColor Cyan

# Check if site exists
try {
    $existingSite = Get-PnPTenantSite -Url $siteUrl -ErrorAction SilentlyContinue
    
    if ($existingSite) {
        Write-Host "✅ Site already exists" -ForegroundColor Green
        Write-Host "   Title: $($existingSite.Title)" -ForegroundColor Cyan
    } else {
        Write-Host "`n🚀 Creating site (may take 1-2 minutes)..." -ForegroundColor Cyan
        
        # Create site without description parameter (can cause null reference errors)
        $newSite = New-PnPSite `
            -Type TeamSite `
            -Title $siteTitle `
            -Alias $config.sharePointSite.name `
            -ErrorAction Stop
        
        Write-Host "✅ Site created successfully!" -ForegroundColor Green
        
        # Add configured owner as site admin
        Write-Host "`n👤 Adding site owner..." -ForegroundColor Cyan
        try {
            Set-PnPTenantSite -Url $siteUrl -Owners $siteOwner -ErrorAction Stop
            Write-Host "✅ Added $siteOwner as site owner" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Could not add owner automatically: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "   You may need to add owners manually in SharePoint admin center" -ForegroundColor Yellow
        }
        
        Write-Host "`n📊 Site Details:" -ForegroundColor Cyan
        Write-Host "   URL:   $newSite" -ForegroundColor White
        Write-Host "   Title: $siteTitle" -ForegroundColor White
        Write-Host "   Owner: $siteOwner" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Site creation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Script complete" -ForegroundColor Green
Disconnect-PnPOnline

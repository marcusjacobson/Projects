<#
.SYNOPSIS
    Uploads generated test data to SharePoint Online or OneDrive.

.DESCRIPTION
    This script takes the output from Generate-RetailData.ps1 and uploads it to a specified
    SharePoint Site or the current user's OneDrive. This populates the tenant with
    sensitive data to test DLP scanning.

.PARAMETER SourcePath
    Path to the local file(s) to upload.

.PARAMETER SiteUrl
    The URL of the SharePoint site (e.g., https://contoso.sharepoint.com/sites/RetailOps).
    If omitted, attempts to upload to the user's OneDrive root.

.PARAMETER TenantId
    The Directory (Tenant) ID.

.PARAMETER AppId
    The Application (Client) ID.

.PARAMETER CertificateThumbprint
    The thumbprint of the client certificate.

.EXAMPLE
    .\Upload-TestDocs.ps1 -SourcePath ".\Output\CustomerDB.csv" -SiteUrl "https://contoso.sharepoint.com/sites/RetailOps" ...

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2024-05-22
    
    Requirements:
    - Microsoft.Graph module
    - Service Principal with Files.ReadWrite.All and Sites.ReadWrite.All

    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $false)]
    [string]$SiteUrl,

    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$AppId,

    [Parameter(Mandatory = $true)]
    [string]$CertificateThumbprint
)

# Import Connection Helper
$connectScript = Join-Path $PSScriptRoot "..\00-Prerequisites\Connect-PurviewGraph.ps1"
if (Test-Path $connectScript) {
    . $connectScript -TenantId $TenantId -AppId $AppId -CertificateThumbprint $CertificateThumbprint
} else {
    Throw "Connection script not found at $connectScript"
}

# =============================================================================
# Step 1: Resolve Target
# =============================================================================

Write-Host "🎯 Step 1: Resolving Target Location" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

$driveId = $null

if ([string]::IsNullOrWhiteSpace($SiteUrl)) {
    Write-Host "   ℹ️ No SiteUrl provided. Targeting User's OneDrive (via App-only is complex, defaulting to root site drive for demo)..." -ForegroundColor Yellow
    # App-only auth accessing a specific user's OneDrive requires User ID. 
    # For simplicity in this lab, we'll target the Root SharePoint Site's default drive.
    
    Write-Host "   🔍 Finding Root Site Default Drive..." -ForegroundColor Cyan
    $site = Get-MgSite -SiteId "root"
    $drives = Get-MgSiteDrive -SiteId $site.Id
    $driveId = $drives[0].Id
    Write-Host "   ✅ Target: Root Site Drive ($($drives[0].Name))" -ForegroundColor Green
} else {
    Write-Host "   🔍 Finding Site: $SiteUrl" -ForegroundColor Cyan
    # Extract hostname and relative path
    # Graph API requires site ID lookup. 
    # Pattern: hostname:/sites/sitename
    
    try {
        # Simple regex to extract hostname and path
        if ($SiteUrl -match "https://([^/]+)(/.*)?") {
            $hostname = $matches[1]
            $sitePath = $matches[2]
            if (-not $sitePath) { $sitePath = "/" }
            
            # Construct Graph Site ID lookup string
            # Note: This is a simplified lookup.
            $siteIdStr = "$hostname`:$sitePath"
            $site = Get-MgSite -SiteId $siteIdStr
            
            $drives = Get-MgSiteDrive -SiteId $site.Id
            $driveId = $drives[0].Id # Default Document Library
            Write-Host "   ✅ Target: Site '$($site.DisplayName)' - Drive '$($drives[0].Name)'" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ Failed to resolve site. Ensure URL is correct and App has permissions." -ForegroundColor Red
        throw
    }
}

# =============================================================================
# Step 2: Upload File
# =============================================================================

Write-Host "🚀 Step 2: Uploading File" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

if (Test-Path $SourcePath) {
    $fileName = Split-Path $SourcePath -Leaf
    Write-Host "   ⏳ Uploading '$fileName'..." -ForegroundColor Cyan
    
    try {
        # Upload to root of the drive
        New-MgDriveItem -DriveId $driveId -Name $fileName -Content (Get-Content $SourcePath -Raw) -Path "/" -Force
        Write-Host "   ✅ File uploaded successfully." -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Upload failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ Source file not found: $SourcePath" -ForegroundColor Red
}

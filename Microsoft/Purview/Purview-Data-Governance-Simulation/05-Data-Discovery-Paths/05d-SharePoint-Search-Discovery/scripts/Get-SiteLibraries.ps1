<#
.SYNOPSIS
    Enumerates document libraries in a SharePoint site to identify discovery targets.

.DESCRIPTION
    This script lists all document libraries in the connected SharePoint site,
    displaying item counts, storage usage, and last modified dates. It helps identify
    high-priority libraries for targeted SIT discovery operations.

.PARAMETER SiteUrl
    The full URL of the SharePoint site to enumerate libraries from.

.EXAMPLE
    .\Get-SiteLibraries.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/Finance"
    
    Lists all document libraries in the Finance site.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-17
    Last Modified: 2025-11-17
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7.0+
    - PnP.PowerShell module
    - Active PnP connection (run Connect-PnPSites.ps1 first)
    
    Script development orchestrated using GitHub Copilot.
#>

#Requires -Version 7.0

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl
)

# =============================================================================
# Script Initialization
# =============================================================================

Write-Host "📚 SharePoint Document Library Enumeration" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Verify PnP Connection
# =============================================================================

Write-Host "🔗 Step 1: Verify PnP Connection" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

try {
    $connection = Get-PnPConnection -ErrorAction Stop
    
    if ($null -eq $connection) {
        Write-Host "❌ Not connected to SharePoint" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Run Connect-PnPSites.ps1 first: .\Connect-PnPSites.ps1 -SiteUrl '$SiteUrl'" -ForegroundColor Yellow
        exit 1
    }
    
    # Verify connected to correct site
    if ($connection.Url -ne $SiteUrl) {
        Write-Host "⚠️ Connected to different site: $($connection.Url)" -ForegroundColor Yellow
        Write-Host "   Expected: $SiteUrl" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "   Reconnecting to target site..." -ForegroundColor Cyan
        
        Connect-PnPOnline -Url $SiteUrl -Interactive -ErrorAction Stop
        
        Write-Host "   ✅ Connected to correct site" -ForegroundColor Green
    } else {
        Write-Host "   ✅ Connected to: $($connection.Url)" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Failed to verify PnP connection: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 2: Retrieve Site Information
# =============================================================================

Write-Host "🔍 Step 2: Retrieve Site Information" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

try {
    $web = Get-PnPWeb -Includes Title, Description -ErrorAction Stop
    
    Write-Host "   📌 Site: $($web.Title)" -ForegroundColor Cyan
    if (-not [string]::IsNullOrEmpty($web.Description)) {
        Write-Host "      Description: $($web.Description)" -ForegroundColor DarkGray
    }
    Write-Host "      URL: $SiteUrl" -ForegroundColor DarkGray
    
} catch {
    Write-Host "   ⚠️ Failed to retrieve site information: $_" -ForegroundColor Yellow
}

Write-Host ""

# =============================================================================
# Step 3: Enumerate Document Libraries
# =============================================================================

Write-Host "📚 Step 3: Enumerate Document Libraries" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "   ⏳ Querying document libraries..." -ForegroundColor Cyan

try {
    # Get all document libraries (exclude hidden system libraries)
    $libraries = Get-PnPList -ErrorAction Stop | 
        Where-Object { 
            $_.BaseTemplate -eq 101 -and  # Document library template
            -not $_.Hidden -and
            $_.ItemCount -gt 0            # Only libraries with content
        }
    
    if ($null -eq $libraries -or $libraries.Count -eq 0) {
        Write-Host ""
        Write-Host "⚠️ No document libraries with content found" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "💡 This site may:" -ForegroundColor Yellow
        Write-Host "   • Have no document libraries" -ForegroundColor DarkGray
        Write-Host "   • Have only empty libraries" -ForegroundColor DarkGray
        Write-Host "   • Restrict access to libraries" -ForegroundColor DarkGray
        exit 0
    }
    
    Write-Host ""
    Write-Host "   ✅ Found $($libraries.Count) document librar$(if ($libraries.Count -eq 1) { 'y' } else { 'ies' })" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "   ❌ Failed to enumerate libraries: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 4: Display Library Details
# =============================================================================

Write-Host "📊 Step 4: Library Details" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green
Write-Host ""

# Create results array for formatted display
$libraryDetails = @()

foreach ($library in $libraries) {
    try {
        # Calculate size in MB/GB
        $sizeInBytes = 0
        $items = Get-PnPListItem -List $library.Title -PageSize 1000 -ErrorAction SilentlyContinue
        
        foreach ($item in $items) {
            if ($item.FieldValues.File_x0020_Size) {
                $sizeInBytes += $item.FieldValues.File_x0020_Size
            }
        }
        
        $sizeInGB = [math]::Round($sizeInBytes / 1GB, 2)
        $sizeInMB = [math]::Round($sizeInBytes / 1MB, 2)
        
        $sizeDisplay = if ($sizeInGB -gt 0.1) { "$sizeInGB GB" } else { "$sizeInMB MB" }
        
        $libraryDetails += [PSCustomObject]@{
            LibraryName = $library.Title
            ItemCount = $library.ItemCount
            Size = $sizeDisplay
            LastModified = $library.LastItemModifiedDate
        }
        
    } catch {
        # If detailed size calc fails, just show basic info
        $libraryDetails += [PSCustomObject]@{
            LibraryName = $library.Title
            ItemCount = $library.ItemCount
            Size = "N/A"
            LastModified = $library.LastItemModifiedDate
        }
    }
}

# Display formatted table
$libraryDetails | Sort-Object ItemCount -Descending | Format-Table -AutoSize

Write-Host ""

# =============================================================================
# Step 5: Provide Discovery Recommendations
# =============================================================================

Write-Host "💡 Step 5: Discovery Recommendations" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Identify top 3 libraries by item count
$topLibraries = $libraryDetails | Sort-Object ItemCount -Descending | Select-Object -First 3

Write-Host "   📌 Recommended Priority Libraries (highest document counts):" -ForegroundColor Cyan

$priority = 1
foreach ($lib in $topLibraries) {
    Write-Host "      $priority. $($lib.LibraryName) ($($lib.ItemCount) items)" -ForegroundColor DarkGray
    $priority++
}

Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Run SIT discovery on priority libraries:" -ForegroundColor DarkGray

foreach ($lib in $topLibraries) {
    Write-Host "   .\Search-SharePointSITs.ps1 -SiteUrl '$SiteUrl' -Library '$($lib.LibraryName)'" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "   Or run discovery on all libraries sequentially:" -ForegroundColor DarkGray
Write-Host "   Get-PnPList | Where-Object { `$_.BaseTemplate -eq 101 } | ForEach-Object { .\Search-SharePointSITs.ps1 -SiteUrl '$SiteUrl' -Library `$_.Title }" -ForegroundColor DarkGray

Write-Host ""

exit 0

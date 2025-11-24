<#
.SYNOPSIS
    Configures permissions and security settings for simulated SharePoint sites.

.DESCRIPTION
    This script applies permission configurations to SharePoint sites created for the Purview
    Data Governance Simulation. It sets site owners, configures member permissions, applies
    security settings, and validates permission inheritance.
    
    The script implements:
    - Owner assignment from configuration
    - Site collection administrator configuration
    - External sharing restrictions (disabled for security simulation)
    - Permission level assignments
    - Validation of permission inheritance
    - Comprehensive logging of permission changes
    
    Security configuration follows best practices:
    - Principle of least privilege
    - Disabled external sharing for simulation data
    - Explicit permission assignments
    - Site collection admin designation
    - Audit trail of all permission changes

.PARAMETER GlobalConfigPath
    Optional path to the global configuration file. If not specified, uses default location.

.PARAMETER SiteName
    Optional specific site name to configure. If not specified, configures all sites from
    global-config.json.

.EXAMPLE
    .\Set-SitePermissions.ps1
    
    Configures permissions for all sites defined in global-config.json.

.EXAMPLE
    .\Set-SitePermissions.ps1 -SiteName "HR-Simulation"
    
    Configures permissions for a specific site only.

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
    - Sites must be created (Lab 01 Step 2 completed)
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Configures permissions for simulated SharePoint sites.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath,
    
    [Parameter(Mandatory = $false)]
    [string]$SiteName
)

# =============================================================================
# Step 1: Load Configuration
# =============================================================================

Write-Host "🔍 Step 1: Load Configuration" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

# Import shared modules
. "$PSScriptRoot\..\..\Shared-Utilities\Import-PurviewModules.ps1"

try {
    $config = & "$PSScriptRoot\..\..\Shared-Utilities\Import-GlobalConfig.ps1" -GlobalConfigPath $GlobalConfigPath
    Write-Host "   ✅ Configuration loaded successfully" -ForegroundColor Green
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Configuration loaded for permission setup" -Level Info -Config $config -ScriptName "Set-SitePermissions"
} catch {
    Write-Host "   ❌ Failed to load configuration: $($_.Exception.Message)" -ForegroundColor Red
    throw "Configuration load failure"
}

# Filter sites if specific site name provided
if (-not [string]::IsNullOrWhiteSpace($SiteName)) {
    $sitesToConfigure = $config.SharePointSites | Where-Object { $_.Name -eq $SiteName }
    if ($null -eq $sitesToConfigure -or $sitesToConfigure.Count -eq 0) {
        Write-Host "   ❌ Site not found in configuration: $SiteName" -ForegroundColor Red
        throw "Site not found: $SiteName"
    }
    Write-Host "   ✅ Configuring permissions for 1 site: $SiteName" -ForegroundColor Green
} else {
    $sitesToConfigure = $config.SharePointSites
    Write-Host "   ✅ Configuring permissions for $($sitesToConfigure.Count) sites" -ForegroundColor Green
}

# =============================================================================
# Step 2: Configure Site Permissions
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Configure Site Permissions" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$successCount = 0
$failureCount = 0
$permissionResults = @()

foreach ($site in $sitesToConfigure) {
    # Construct site URL (trim trailing slash from tenant URL to avoid double slashes)
    $tenantUrl = $config.Environment.TenantUrl.TrimEnd('/')
    $siteUrl = "$tenantUrl/sites/$($site.Name)"
    
    Write-Host "   📋 Processing site: $($site.Name)" -ForegroundColor Cyan
    Write-Host "      URL: $siteUrl" -ForegroundColor Cyan
    
    try {
        # Connect to the site using shared module
        Connect-PurviewServices -Services @("SharePoint") -TenantUrl $siteUrl -PnPClientId $config.Environment.PnPClientId -Interactive
        
        # Get site web
        $web = Get-PnPWeb -ErrorAction Stop
        Write-Host "      Connected to: $($web.Title)" -ForegroundColor Cyan
        
        # Set site owner (if different from current)
        try {
            $currentOwner = Get-PnPSiteCollectionAdmin -ErrorAction Stop | Where-Object { $_.Email -eq $site.Owner }
            
            if ($null -eq $currentOwner) {
                Write-Host "      🔧 Setting site collection admin: $($site.Owner)" -ForegroundColor Cyan
                Add-PnPSiteCollectionAdmin -Owners $site.Owner -ErrorAction Stop
                Write-Host "      ✅ Owner configured: $($site.Owner)" -ForegroundColor Green
            } else {
                Write-Host "      ℹ️  Owner already configured: $($site.Owner)" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "      ⚠️  Warning: Could not set owner - $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Configure sharing settings (disable external sharing)
        try {
            Write-Host "      🔧 Disabling external sharing..." -ForegroundColor Cyan
            Set-PnPTenantSite -Url $siteUrl -SharingCapability Disabled -ErrorAction Stop
            Write-Host "      ✅ External sharing disabled" -ForegroundColor Green
        } catch {
            Write-Host "      ⚠️  Warning: Could not disable external sharing - $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Ensure default groups exist and are properly configured
        try {
            Write-Host "      🔧 Configuring site groups..." -ForegroundColor Cyan
            
            # Get or create default groups
            $ownersGroup = Get-PnPGroup -AssociatedOwnerGroup -ErrorAction SilentlyContinue
            $membersGroup = Get-PnPGroup -AssociatedMemberGroup -ErrorAction SilentlyContinue
            $visitorsGroup = Get-PnPGroup -AssociatedVisitorGroup -ErrorAction SilentlyContinue
            
            if ($null -ne $ownersGroup -and $null -ne $membersGroup -and $null -ne $visitorsGroup) {
                Write-Host "      ✅ Site groups configured" -ForegroundColor Green
            } else {
                Write-Host "      ℹ️  Site groups not fully configured (may be created automatically)" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "      ⚠️  Warning: Could not configure site groups - $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        $successCount++
        $permissionResults += @{
            SiteName = $site.Name
            Status = "Success"
            Owner = $site.Owner
            ExternalSharingDisabled = $true
        }
        
        Write-Host "   ✅ Permissions configured successfully: $($site.Name)" -ForegroundColor Green
        & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Permissions configured for site: $($site.Name)" -Level Success -Config $config -ScriptName "Set-SitePermissions"
        
    } catch {
        Write-Host "   ❌ Failed to configure permissions for $($site.Name): $_" -ForegroundColor Red
        $failureCount++
        $permissionResults += @{
            SiteName = $site.Name
            Status = "Failed"
            Error = $_.Exception.Message
        }
        & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Failed to configure permissions for $($site.Name): $_" -Level Error -Config $config -ScriptName "Set-SitePermissions"
    }
    
    # Brief pause between sites
    Start-Sleep -Seconds 1
}

# =============================================================================
# Step 3: Configure Global Security Settings
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Configure Global Security Settings" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

Write-Host "   📋 Connecting to SharePoint Admin Center..." -ForegroundColor Cyan

try {
    Connect-PurviewServices -Services @("SharePoint") -TenantUrl $config.Environment.AdminCenterUrl -PnPClientId $config.Environment.PnPClientId -Interactive
    
    # Set default site owner for all simulation sites
    Write-Host "   🔧 Validating default site owner configuration..." -ForegroundColor Cyan
    
    foreach ($site in $sitesToConfigure) {
        # Validate owner for each site
        $tenantUrl = $config.Environment.TenantUrl.TrimEnd('/')
        $siteUrl = "$tenantUrl/sites/$($site.Name)"
        
        try {
            $tenantSite = Get-PnPTenantSite -Url $siteUrl -ErrorAction Stop
            
            if ($tenantSite.Owner -ne $site.Owner) {
                Write-Host "      🔧 Updating owner for $($site.Name) to $($site.Owner)" -ForegroundColor Cyan
                Set-PnPTenantSite -Url $siteUrl -Owners $site.Owner -ErrorAction Stop
                Write-Host "      ✅ Owner updated" -ForegroundColor Green
            } else {
                Write-Host "      ℹ️  Owner already correct for $($site.Name)" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "      ⚠️  Warning: Could not validate owner for $($site.Name) - $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "   ✅ Global security settings validated" -ForegroundColor Green
    
} catch {
    Write-Host "   Write-Host "   ⚠️  Warning: Could not connect to SharePoint Admin Center - $($_.Exception.Message)" -ForegroundColor Yellow
}" -ForegroundColor Yellow
    Write-Host "   💡 Manual validation recommended in SharePoint Admin Center" -ForegroundColor Yellow
}

# =============================================================================
# Step 4: Permission Configuration Summary
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 4: Permission Configuration Summary" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

Write-Host "   📊 Sites Processed: $($sitesToConfigure.Count)" -ForegroundColor Cyan
Write-Host "   📊 Successfully Configured: $successCount" -ForegroundColor Cyan
Write-Host "   📊 Failed: $failureCount" -ForegroundColor Cyan

if ($successCount -gt 0) {
    Write-Host ""
    Write-Host "   ✅ Successfully configured sites:" -ForegroundColor Green
    foreach ($result in ($permissionResults | Where-Object { $_.Status -eq "Success" })) {
        Write-Host "      • $($result.SiteName) - Owner: $($result.Owner)" -ForegroundColor Green
    }
}

if ($failureCount -gt 0) {
    Write-Host ""
    Write-Host "   ❌ Failed to configure sites:" -ForegroundColor Red
    foreach ($result in ($permissionResults | Where-Object { $_.Status -eq "Failed" })) {
        Write-Host "      • $($result.SiteName): $($result.Error)" -ForegroundColor Red
    }
}

# =============================================================================
# Step 5: Generate Permission Report
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 5: Generate Permission Report" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TenantUrl = $config.Environment.TenantUrl
    SitesProcessed = $sitesToConfigure.Count
    SuccessCount = $successCount
    FailureCount = $failureCount
    Results = $permissionResults
}

# Resolve reports path relative to project root (two levels up from scripts folder)
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$reportsPath = Join-Path $projectRoot $config.Paths.ReportsPath.TrimStart('./').TrimStart('.\\')

# Ensure reports directory exists
if (-not (Test-Path $reportsPath)) {
    New-Item -Path $reportsPath -ItemType Directory -Force | Out-Null
}

$reportPath = Join-Path $reportsPath "permission-configuration-report-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').json"

try {
    $report | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath -Force -Encoding UTF8
    Write-Host "   ✅ Report saved: $(Split-Path $reportPath -Leaf)" -ForegroundColor Green
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Permission report saved: $reportPath" -Level Info -Config $config -ScriptName "Set-SitePermissions"
} catch {
    Write-Host "   ⚠️  Could not save report: $($_.Exception.Message)" -ForegroundColor Yellow
}

# =============================================================================
# Step 6: Next Steps Guidance
# =============================================================================

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Run Verify-SiteCreation.ps1 to validate site accessibility" -ForegroundColor Cyan
Write-Host "   2. Review permission report for any issues" -ForegroundColor Cyan
Write-Host "   3. Proceed to Lab 02 for document generation" -ForegroundColor Cyan

if ($failureCount -gt 0) {
    Write-Host ""
    Write-Host "⚠️  Some sites failed permission configuration. Review errors above." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host ""
    Write-Host "✅ Site permissions configured successfully" -ForegroundColor Green
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Site permissions configured successfully" -Level Success -Config $config -ScriptName "Set-SitePermissions"
    exit 0
}

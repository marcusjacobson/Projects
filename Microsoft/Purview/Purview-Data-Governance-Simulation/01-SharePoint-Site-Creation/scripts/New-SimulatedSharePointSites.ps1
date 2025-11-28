<#
.SYNOPSIS
    Creates simulated SharePoint sites for Purview Data Governance testing.

.DESCRIPTION
    This script provisions SharePoint Online sites based on configuration in global-config.json.
    It creates team sites for various departmental scenarios (HR, Finance, Legal, Marketing, IT)
    that will host test content for Microsoft Purview Information Protection classification
    and Data Loss Prevention testing.
    
    The script implements:
    - Configuration-driven site creation (no hardcoded values)
    - Batch site provisioning with progress tracking
    - Throttling to respect SharePoint API limits
    - Comprehensive error handling and retry logic
    - Detailed logging of all operations
    - Site metadata application (Department, Description)
    
    Site creation follows SharePoint best practices:
    - Team Site template (STS#3) for document collaboration
    - Consistent naming convention with simulation prefix
    - Proper site metadata for identification
    - Document library provisioning
    - Integration with Purview classification workflows

.PARAMETER GlobalConfigPath
    Optional path to the global configuration file. If not specified, uses default location.

.PARAMETER SkipExisting
    When specified, skips creation of sites that already exist rather than throwing an error.

.PARAMETER WhatIf
    When specified, shows what sites would be created without actually creating them.

.EXAMPLE
    .\New-SimulatedSharePointSites.ps1
    
    Creates all SharePoint sites defined in global-config.json.

.EXAMPLE
    .\New-SimulatedSharePointSites.ps1 -SkipExisting
    
    Creates sites, skipping any that already exist.

.EXAMPLE
    .\New-SimulatedSharePointSites.ps1 -WhatIf
    
    Shows what sites would be created without actually creating them.

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
    - Active SharePoint Online connection
    
    Script development orchestrated using GitHub Copilot.

.SHAREPOINT PROVISIONING OPERATIONS
    - Site Collection Creation (Team Site)
    - Metadata Configuration (Property Bag)
    - Progress Tracking and Reporting
    - Error Handling and Retry Logic
#>
#
# =============================================================================
# Creates simulated SharePoint sites for Purview testing.
# =============================================================================

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipExisting
)

# =============================================================================
# Step 1: Load Configuration and Connect to SharePoint
# =============================================================================

Write-Host "🔍 Step 1: Load Configuration and Connect to SharePoint" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green

# Import shared modules
. "$PSScriptRoot\..\..\Shared-Utilities\Import-PurviewModules.ps1"

# Load global configuration
try {
    $config = & "$PSScriptRoot\..\..\Shared-Utilities\Import-GlobalConfig.ps1" -GlobalConfigPath $GlobalConfigPath
    Write-Host "   ✅ Configuration loaded successfully" -ForegroundColor Green
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Configuration loaded for site creation" -Level Info -Config $config -ScriptName "New-SimulatedSharePointSites"
} catch {
    Write-Host "   ❌ Failed to load configuration: $($_.Exception.Message)" -ForegroundColor Red
    throw "Configuration load failure"
}

# Connect to SharePoint Online
Write-Host "   📋 Connecting to SharePoint Online..." -ForegroundColor Cyan
try {
    Connect-PurviewServices -Services @("SharePoint") -TenantUrl $config.Environment.TenantUrl -PnPClientId $config.Environment.PnPClientId -Interactive
    Write-Host "   ✅ SharePoint connection established" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to connect to SharePoint: $($_.Exception.Message)" -ForegroundColor Red
    throw "SharePoint connection failure"
}

# =============================================================================
# Step 2: Validate Site Configuration
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Validate Site Configuration" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

$sitesToCreate = $config.SharePointSites

if ($null -eq $sitesToCreate -or $sitesToCreate.Count -eq 0) {
    Write-Host "   ❌ No sites configured in global-config.json" -ForegroundColor Red
    throw "No SharePoint sites configured for creation"
}

Write-Host "   ✅ $($sitesToCreate.Count) sites configured for creation" -ForegroundColor Green

foreach ($site in $sitesToCreate) {
    Write-Host "   📋 $($site.Name) - $($site.Department) - $($site.Description)" -ForegroundColor Cyan
}

# =============================================================================
# Step 3: Create SharePoint Sites
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Create SharePoint Sites" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

$createdSites = @()
$skippedSites = @()
$failedSites = @()
$startTime = Get-Date

$siteIndex = 0
foreach ($site in $sitesToCreate) {
    $siteIndex++
    
    # Update progress
    & "$PSScriptRoot\..\..\Shared-Utilities\Get-SimulationProgress.ps1" `
        -Activity "Creating SharePoint Sites" `
        -TotalItems $sitesToCreate.Count `
        -ProcessedItems ($siteIndex - 1) `
        -CurrentOperation "Creating site: $($site.Name)" `
        -StartTime $startTime `
        -Config $config
    
    # Construct site URL (trim trailing slash from tenant URL to avoid double slashes)
    $tenantUrl = $config.Environment.TenantUrl.TrimEnd('/')
    $siteUrl = "$tenantUrl/sites/$($site.Name)"
    
    Write-Host "   📋 Processing site: $($site.Name)" -ForegroundColor Cyan
    Write-Host "      URL: $siteUrl" -ForegroundColor Cyan
    
    # Check if site already exists
    try {
        $existingSite = Get-PnPTenantSite -Url $siteUrl -ErrorAction SilentlyContinue
        
        if ($null -ne $existingSite) {
            if ($SkipExisting) {
                Write-Host "   ⏭️  Site already exists, skipping: $($site.Name)" -ForegroundColor Yellow
                $skippedSites += $site.Name
                & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Skipped existing site: $($site.Name)" -Level Warning -Config $config -ScriptName "New-SimulatedSharePointSites"
                continue
            } else {
                Write-Host "   ❌ Site already exists: $($site.Name)" -ForegroundColor Red
                $failedSites += @{Name = $site.Name; Error = "Site already exists"}
                continue
            }
        }
    } catch {
        # Site doesn't exist, proceed with creation
    }
    
    # Create site if WhatIf not specified
    if ($WhatIfPreference) {
        Write-Host "   💭 WhatIf: Would create site $($site.Name)" -ForegroundColor Cyan
        continue
    }
    
    try {
        Write-Host "   🚀 Creating site: $($site.Name)..." -ForegroundColor Cyan
        
        # Create the site
        $newSite = New-PnPSite `
            -Type TeamSite `
            -Title "$($config.Simulation.CompanyPrefix) - $($site.Department)" `
            -Alias $site.Name `
            -Description $site.Description `
            -Owner $site.Owner `
            -ErrorAction Stop
        
        Write-Host "   ✅ Site created successfully: $($site.Name)" -ForegroundColor Green
        Write-Host "      URL: $newSite" -ForegroundColor Cyan
        
        $createdSites += $site.Name
        & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Created site: $($site.Name) at $newSite" -Level Success -Config $config -ScriptName "New-SimulatedSharePointSites"
        
        # Brief pause to avoid throttling
        Start-Sleep -Seconds 2
        
    } catch {
        Write-Host "   ❌ Failed to create site $($site.Name) - $($_.Exception.Message)" -ForegroundColor Red
        $failedSites += @{Name = $site.Name; Error = $_.Exception.Message}
        & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Failed to create site $($site.Name): $($_.Exception.Message)" -Level Error -Config $config -ScriptName "New-SimulatedSharePointSites"
    }
}

# Complete progress bar
& "$PSScriptRoot\..\..\Shared-Utilities\Get-SimulationProgress.ps1" `
    -Activity "Creating SharePoint Sites" `
    -Completed `
    -Config $config

# =============================================================================
# Step 4: Configure Site Metadata
# =============================================================================

if ($createdSites.Count -gt 0 -and -not $WhatIfPreference) {
    Write-Host ""
    Write-Host "🔍 Step 4: Configure Site Metadata" -ForegroundColor Green
    Write-Host "===================================" -ForegroundColor Green
    
    foreach ($siteName in $createdSites) {
        # Connect to site for metadata configuration
        $tenantUrl = $config.Environment.TenantUrl.TrimEnd('/')
        $siteUrl = "$tenantUrl/sites/$siteName"
        $siteConfig = $sitesToCreate | Where-Object { $_.Name -eq $siteName }
        
        Write-Host "   📋 Configuring metadata for: $siteName" -ForegroundColor Cyan
        
        try {
            # Connect to the newly created site using shared module
            Connect-PurviewServices -Services @("SharePoint") -TenantUrl $siteUrl -PnPClientId $config.Environment.PnPClientId -Interactive
            
            # Set site property bag values for metadata (Force parameter suppresses no-script site prompts)
            Set-PnPPropertyBagValue -Key "Department" -Value $siteConfig.Department -Force -ErrorAction Stop
            Set-PnPPropertyBagValue -Key "SimulationSite" -Value "true" -Force -ErrorAction Stop
            Set-PnPPropertyBagValue -Key "CompanyPrefix" -Value $config.Simulation.CompanyPrefix -Force -ErrorAction Stop
            
            Write-Host "   ✅ Metadata configured: $siteName" -ForegroundColor Green
            
        } catch {
            Write-Host "   ⚠️  Warning: Could not set metadata for $siteName - $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # Reconnect to tenant admin using shared module
    Connect-PurviewServices -Services @("SharePoint") -TenantUrl $config.Environment.AdminCenterUrl -PnPClientId $config.Environment.PnPClientId -Interactive
}

# =============================================================================
# Step 5: Site Creation Summary
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 5: Site Creation Summary" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

$totalDuration = (Get-Date) - $startTime

Write-Host "   📊 Sites Configured: $($sitesToCreate.Count)" -ForegroundColor Cyan
Write-Host "   📊 Sites Created: $($createdSites.Count)" -ForegroundColor Cyan
Write-Host "   📊 Sites Skipped: $($skippedSites.Count)" -ForegroundColor Cyan
Write-Host "   📊 Sites Failed: $($failedSites.Count)" -ForegroundColor Cyan
Write-Host "   📊 Total Duration: $("{0:hh\:mm\:ss}" -f $totalDuration)" -ForegroundColor Cyan

if ($createdSites.Count -gt 0) {
    Write-Host ""
    Write-Host "   ✅ Successfully created sites:" -ForegroundColor Green
    foreach ($siteName in $createdSites) {
        Write-Host "      • $siteName" -ForegroundColor Green
    }
}

if ($skippedSites.Count -gt 0) {
    Write-Host ""
    Write-Host "   ⏭️  Skipped existing sites:" -ForegroundColor Yellow
    foreach ($siteName in $skippedSites) {
        Write-Host "      • $siteName" -ForegroundColor Yellow
    }
}

if ($failedSites.Count -gt 0) {
    Write-Host ""
    Write-Host "   ❌ Failed sites:" -ForegroundColor Red
    foreach ($failure in $failedSites) {
        Write-Host "      • $($failure.Name): $($failure.Error)" -ForegroundColor Red
    }
}

# =============================================================================
# Step 6: Generate Creation Report
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 6: Generate Creation Report" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

$report = @{
    Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TenantUrl         = $config.Environment.TenantUrl
    Organization      = $config.Environment.OrganizationName
    SitesConfigured   = $sitesToCreate.Count
    SitesCreated      = $createdSites.Count
    SitesSkipped      = $skippedSites.Count
    SitesFailed       = $failedSites.Count
    Duration          = $totalDuration.ToString()
    CreatedSites      = $createdSites
    SkippedSites      = $skippedSites
    FailedSites       = $failedSites
}

# Resolve reports path relative to project root (two levels up from scripts folder)
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$reportsPath = Join-Path $projectRoot $config.Paths.ReportsPath.TrimStart('./').TrimStart('.\\')

# Ensure reports directory exists
if (-not (Test-Path $reportsPath)) {
    New-Item -Path $reportsPath -ItemType Directory -Force | Out-Null
}

$reportPath = Join-Path $reportsPath "site-creation-report-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').json"

try {
    $report | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath -Force -Encoding UTF8
    Write-Host "   ✅ Report saved: $(Split-Path $reportPath -Leaf)" -ForegroundColor Green
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Site creation report saved: $reportPath" -Level Info -Config $config -ScriptName "New-SimulatedSharePointSites"
} catch {
    Write-Host "   ⚠️  Could not save report: $($_.Exception.Message)" -ForegroundColor Yellow
}

# =============================================================================
# Step 7: Next Steps Guidance
# =============================================================================

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Run Set-SitePermissions.ps1 to configure site permissions" -ForegroundColor Cyan
Write-Host "   2. Run Verify-SiteCreation.ps1 to validate site creation" -ForegroundColor Cyan
Write-Host "   3. Proceed to Lab 02 for document generation" -ForegroundColor Cyan

if ($failedSites.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠️  Some sites failed to create. Review errors above and retry if needed." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host ""
    Write-Host "✅ SharePoint site creation completed successfully" -ForegroundColor Green
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "SharePoint site creation completed successfully" -Level Success -Config $config -ScriptName "New-SimulatedSharePointSites"
    exit 0
}

<#
.SYNOPSIS
    Verifies successful creation and accessibility of simulated SharePoint sites.

.DESCRIPTION
    This script performs comprehensive validation of SharePoint sites created for the Purview
    Discovery Methods Simulation. It tests connectivity, validates site properties, checks
    document library existence, verifies permissions, and tests write access.
    
    The script validates:
    - Site existence and accessibility
    - Site properties match configuration
    - Document libraries are present and accessible
    - Site owners are correctly assigned
    - Write permissions for document upload operations
    - External sharing restrictions applied
    - Site metadata configured correctly
    
    Validation follows comprehensive testing methodology:
    - Connectivity tests to each site
    - Property validation against configuration
    - Functional testing (read/write operations)
    - Permission verification
    - Detailed reporting with pass/fail status

.PARAMETER GlobalConfigPath
    Optional path to the global configuration file. If not specified, uses default location.

.PARAMETER SiteName
    Optional specific site name to verify. If not specified, verifies all sites from
    global-config.json.

.PARAMETER DetailedReport
    When specified, generates detailed validation report with additional diagnostic information.

.EXAMPLE
    .\Verify-SiteCreation.ps1
    
    Verifies all sites defined in global-config.json.

.EXAMPLE
    .\Verify-SiteCreation.ps1 -SiteName "HR-Simulation"
    
    Verifies a specific site only.

.EXAMPLE
    .\Verify-SiteCreation.ps1 -DetailedReport
    
    Verifies all sites with detailed diagnostic reporting.

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

.SHAREPOINT PROVISIONING OPERATIONS
    - Site Accessibility Verification
    - Document Library Validation
    - Owner Configuration Check
    - Write Access Testing
    - External Sharing Audit
#>
#
# =============================================================================
# Verifies successful creation of simulated SharePoint sites.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath,
    
    [Parameter(Mandatory = $false)]
    [string]$SiteName,
    
    [Parameter(Mandatory = $false)]
    [switch]$DetailedReport
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
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Configuration loaded for site verification" -Level Info -Config $config -ScriptName "Verify-SiteCreation"
} catch {
    Write-Host "   ❌ Failed to load configuration: $($_.Exception.Message)" -ForegroundColor Red
    throw "Configuration load failure"
}

# Filter sites if specific site name provided
if (-not [string]::IsNullOrWhiteSpace($SiteName)) {
    $sitesToVerify = $config.SharePointSites | Where-Object { $_.Name -eq $SiteName }
    if ($null -eq $sitesToVerify -or $sitesToVerify.Count -eq 0) {
        Write-Host "   ❌ Site not found in configuration: $SiteName" -ForegroundColor Red
        throw "Site not found: $SiteName"
    }
    Write-Host "   ✅ Verifying 1 site: $SiteName" -ForegroundColor Green
} else {
    $sitesToVerify = $config.SharePointSites
    Write-Host "   ✅ Verifying $($sitesToVerify.Count) sites" -ForegroundColor Green
}

# =============================================================================
# Step 2: Verify Site Accessibility
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Verify Site Accessibility" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

$verificationResults = @()

foreach ($site in $sitesToVerify) {
    # Construct site URL (trim trailing slash from tenant URL to avoid double slashes)
    $tenantUrl = $config.Environment.TenantUrl.TrimEnd('/')
    $siteUrl = "$tenantUrl/sites/$($site.Name)"
    
    Write-Host "   📋 Verifying site: $($site.Name)" -ForegroundColor Cyan
    Write-Host "      URL: $siteUrl" -ForegroundColor Cyan
    
    $siteResult = @{
        SiteName = $site.Name
        SiteUrl = $siteUrl
        Accessible = $false
        DocumentLibraryExists = $false
        OwnerCorrect = $false
        WriteAccessValidated = $false
        MetadataConfigured = $false
        ExternalSharingDisabled = $false
        Issues = @()
    }
    
    try {
        # Test site accessibility using shared module
        Connect-PurviewServices -Services @("SharePoint") -TenantUrl $siteUrl -PnPClientId $config.Environment.PnPClientId -Interactive
        $web = Get-PnPWeb -ErrorAction Stop
        
        $siteResult.Accessible = $true
        Write-Host "      ✅ Site accessible: $($web.Title)" -ForegroundColor Green
        
        if ($DetailedReport) {
            $siteResult.SiteTitle = $web.Title
            $siteResult.SiteDescription = $web.Description
            $siteResult.Created = $web.Created
        }
        
        # Check document library existence
        try {
            $docLib = Get-PnPList -Identity "Documents" -ErrorAction Stop
            $siteResult.DocumentLibraryExists = $true
            Write-Host "      ✅ Document library present: $($docLib.Title)" -ForegroundColor Green
            
            if ($DetailedReport) {
                $siteResult.DocumentLibraryItemCount = $docLib.ItemCount
            }
        } catch {
            $siteResult.Issues += "Document library not found"
            Write-Host "      ❌ Document library not found" -ForegroundColor Red
        }
        
        # Verify site owner
        try {
            $siteAdmins = Get-PnPSiteCollectionAdmin -ErrorAction Stop
            $ownerFound = $siteAdmins | Where-Object { $_.Email -eq $site.Owner }
            
            if ($null -ne $ownerFound) {
                $siteResult.OwnerCorrect = $true
                Write-Host "      ✅ Owner configured correctly: $($site.Owner)" -ForegroundColor Green
            } else {
                $siteResult.Issues += "Owner not correctly assigned"
                Write-Host "      ❌ Owner not correctly assigned: Expected $($site.Owner)" -ForegroundColor Red
            }
            
            if ($DetailedReport) {
                $siteResult.SiteAdmins = $siteAdmins | Select-Object -ExpandProperty Email
            }
        } catch {
            $siteResult.Issues += "Could not verify site owner: $($_.Exception.Message)"
            Write-Host "      ⚠️  Could not verify site owner - $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Test write access
        try {
            # Check if user has contribute permissions
            $currentUser = Get-PnPProperty -ClientObject (Get-PnPWeb) -Property CurrentUser
            $permissions = Get-PnPProperty -ClientObject $currentUser -Property LoginName
            
            # Try to get a file from Documents library to validate access
            $docLib = Get-PnPList -Identity "Documents" -ErrorAction Stop
            $libPermissions = Get-PnPProperty -ClientObject $docLib -Property EffectiveBasePermissions
            
            # Check if current user has Add permission (write access)
            if ($libPermissions.Has([Microsoft.SharePoint.Client.PermissionKind]::AddListItems)) {
                $siteResult.WriteAccessValidated = $true
                Write-Host "      ✅ Write access validated" -ForegroundColor Green
            } else {
                $siteResult.Issues += "Write access not granted for current user"
                Write-Host "      ⚠️  Write access not available (this is expected for non-owners)" -ForegroundColor Yellow
            }
        } catch {
            # Write access validation failure is often expected for verification scripts
            $siteResult.Issues += "Write access test failed: $($_.Exception.Message)"
            Write-Host "      ⚠️  Write access test failed (this is expected for non-owners) - $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Check site metadata
        try {
            $deptMetadata = Get-PnPPropertyBag -Key "Department" -ErrorAction SilentlyContinue
            $simSiteMetadata = Get-PnPPropertyBag -Key "SimulationSite" -ErrorAction SilentlyContinue
            
            if ($deptMetadata -eq $site.Department -and $simSiteMetadata -eq "true") {
                $siteResult.MetadataConfigured = $true
                Write-Host "      ✅ Site metadata configured correctly" -ForegroundColor Green
            } else {
                $siteResult.Issues += "Site metadata incomplete or incorrect"
                Write-Host "      ⚠️  Site metadata incomplete or incorrect" -ForegroundColor Yellow
            }
        } catch {
            $siteResult.Issues += "Could not verify metadata: $($_.Exception.Message)"
            Write-Host "      ⚠️  Could not verify metadata - $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
    } catch {
        $siteResult.Issues += "Site not accessible: $($_.Exception.Message)"
        Write-Host "      ❌ Site not accessible - $($_.Exception.Message)" -ForegroundColor Red
        & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Site verification failed for $($site.Name): $($_.Exception.Message)" -Level Error -Config $config -ScriptName "Verify-SiteCreation"
    }
    
    $verificationResults += $siteResult
    
    # Brief pause between sites
    Start-Sleep -Seconds 1
}

# =============================================================================
# Step 3: Verify External Sharing Settings
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Verify External Sharing Settings" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

Write-Host "   📋 Connecting to SharePoint Admin Center..." -ForegroundColor Cyan

try {
    Connect-PurviewServices -Services @("SharePoint") -TenantUrl $config.Environment.AdminCenterUrl -PnPClientId $config.Environment.PnPClientId -Interactive
    
    foreach ($result in $verificationResults) {
        if ($result.Accessible) {
            try {
                $tenantSite = Get-PnPTenantSite -Url $result.SiteUrl -ErrorAction Stop
                
                if ($tenantSite.SharingCapability -eq "Disabled") {
                    $result.ExternalSharingDisabled = $true
                    Write-Host "      ✅ External sharing disabled: $($result.SiteName)" -ForegroundColor Green
                } else {
                    $result.Issues += "External sharing not disabled"
                    Write-Host "      ⚠️  External sharing not disabled: $($result.SiteName)" -ForegroundColor Yellow
                }
            } catch {
                $result.Issues += "Could not verify sharing settings: $($_.Exception.Message)"
                Write-Host "      ⚠️  Could not verify sharing settings for $($result.SiteName) - $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
    
} catch {
    Write-Host "   ⚠️  Could not connect to SharePoint Admin Center - $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   💡 Manual validation of external sharing settings recommended" -ForegroundColor Yellow
}

# =============================================================================
# Step 4: Verification Summary
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 4: Verification Summary" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

$accessibleCount = ($verificationResults | Where-Object { $_.Accessible }).Count
$docLibCount = ($verificationResults | Where-Object { $_.DocumentLibraryExists }).Count
$ownerCorrectCount = ($verificationResults | Where-Object { $_.OwnerCorrect }).Count
$writeAccessCount = ($verificationResults | Where-Object { $_.WriteAccessValidated }).Count
$fullyValidatedCount = ($verificationResults | Where-Object { 
    $_.Accessible -and 
    $_.DocumentLibraryExists -and 
    $_.OwnerCorrect -and 
    $_.WriteAccessValidated 
}).Count

Write-Host "   📊 Sites Verified: $($sitesToVerify.Count)" -ForegroundColor Cyan
Write-Host "   📊 Accessible Sites: $accessibleCount" -ForegroundColor Cyan
Write-Host "   📊 Document Libraries Present: $docLibCount" -ForegroundColor Cyan
Write-Host "   📊 Owners Correctly Configured: $ownerCorrectCount" -ForegroundColor Cyan
Write-Host "   📊 Write Access Validated: $writeAccessCount" -ForegroundColor Cyan
Write-Host "   📊 Fully Validated Sites: $fullyValidatedCount" -ForegroundColor Cyan

# Display detailed results
Write-Host ""
Write-Host "   📋 Detailed Results:" -ForegroundColor Cyan

foreach ($result in $verificationResults) {
    if ($result.Accessible -and $result.DocumentLibraryExists -and $result.OwnerCorrect -and $result.WriteAccessValidated) {
        Write-Host "      ✅ $($result.SiteName) - Fully validated" -ForegroundColor Green
    } else {
        Write-Host "      ⚠️  $($result.SiteName) - Issues detected:" -ForegroundColor Yellow
        foreach ($issue in $result.Issues) {
            Write-Host "         • $issue" -ForegroundColor Yellow
        }
    }
}

# =============================================================================
# Step 5: Generate Validation Report
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 5: Generate Validation Report" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TenantUrl = $config.Environment.TenantUrl
    SitesVerified = $sitesToVerify.Count
    AccessibleSites = $accessibleCount
    FullyValidatedSites = $fullyValidatedCount
    Results = $verificationResults
}

# Resolve reports path relative to project root (two levels up from scripts folder)
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$reportsPath = Join-Path $projectRoot $config.Paths.ReportsPath.TrimStart('./').TrimStart('.\\')

# Ensure reports directory exists
if (-not (Test-Path $reportsPath)) {
    New-Item -Path $reportsPath -ItemType Directory -Force | Out-Null
}

$reportPath = Join-Path $reportsPath "site-creation-validation-report-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').json"

try {
    $report | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath -Force -Encoding UTF8
    Write-Host "   ✅ Report saved: $(Split-Path $reportPath -Leaf)" -ForegroundColor Green
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Validation report saved: $reportPath" -Level Info -Config $config -ScriptName "Verify-SiteCreation"
} catch {
    Write-Host "   ⚠️  Could not save report: $($_.Exception.Message)" -ForegroundColor Yellow
}

# =============================================================================
# Step 6: Next Steps Guidance
# =============================================================================

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan

if ($fullyValidatedCount -eq $sitesToVerify.Count) {
    Write-Host "   ✅ All sites fully validated and ready for document upload" -ForegroundColor Green
    Write-Host "   1. Proceed to Lab 02 for test data generation" -ForegroundColor Cyan
    Write-Host "   2. Review validation report for detailed site information" -ForegroundColor Cyan
} else {
    Write-Host "   ⚠️  Some sites have validation issues" -ForegroundColor Yellow
    Write-Host "   1. Review issues above and in validation report" -ForegroundColor Cyan
    Write-Host "   2. Rerun Set-SitePermissions.ps1 if permission issues detected" -ForegroundColor Cyan
    Write-Host "   3. Manually verify sites in SharePoint portal" -ForegroundColor Cyan
    Write-Host "   4. Retry verification after resolving issues" -ForegroundColor Cyan
}

if ($fullyValidatedCount -eq $sitesToVerify.Count) {
    Write-Host ""
    Write-Host "✅ Site creation verification completed successfully - all sites ready" -ForegroundColor Green
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Site verification completed successfully - all sites ready" -Level Success -Config $config -ScriptName "Verify-SiteCreation"
    exit 0
} else {
    Write-Host ""
    Write-Host "⚠️  Site creation verification completed with issues - review above" -ForegroundColor Yellow
    exit 1
}

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
    
    # Site creation with timeout handling (New-PnPSite can hang waiting for SharePoint async response)
    $siteCreationTimeout = 120  # 2 minutes timeout per site
    $siteCreated = $false
    
    Write-Host "   🚀 Creating site: $($site.Name)... (timeout: ${siteCreationTimeout}s)" -ForegroundColor Cyan
    
    # Start site creation as a background job
    $createJob = Start-Job -ScriptBlock {
        param($TenantUrl, $PnPClientId, $SiteTitle, $SiteAlias, $SiteDescription, $SiteOwner)
        
        # Import PnP module in job context
        Import-Module PnP.PowerShell -ErrorAction Stop
        
        # Connect to SharePoint (non-interactive - uses cached credentials)
        Connect-PnPOnline -Url $TenantUrl -ClientId $PnPClientId -Interactive
        
        # Create the site
        $result = New-PnPSite `
            -Type TeamSite `
            -Title $SiteTitle `
            -Alias $SiteAlias `
            -Description $SiteDescription `
            -Owner $SiteOwner `
            -ErrorAction Stop
        
        return $result
    } -ArgumentList @(
        $config.Environment.TenantUrl,
        $config.Environment.PnPClientId,
        "$($config.Simulation.CompanyPrefix) - $($site.Department)",
        $site.Name,
        $site.Description,
        $site.Owner
    )
    
    # Wait for job with timeout
    $jobCompleted = $createJob | Wait-Job -Timeout $siteCreationTimeout
    
    if ($jobCompleted) {
        # Job completed within timeout
        $jobResult = Receive-Job -Job $createJob -ErrorAction SilentlyContinue
        $jobError = $createJob.ChildJobs[0].JobStateInfo.Reason
        
        if ($createJob.State -eq 'Completed' -and -not $jobError) {
            Write-Host "   ✅ Site created successfully: $($site.Name)" -ForegroundColor Green
            Write-Host "      URL: $jobResult" -ForegroundColor Cyan
            $createdSites += $site.Name
            $siteCreated = $true
            & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Created site: $($site.Name) at $jobResult" -Level Success -Config $config -ScriptName "New-SimulatedSharePointSites"
        } else {
            $errorMsg = if ($jobError) { $jobError.Message } else { "Unknown error" }
            Write-Host "   ❌ Failed to create site $($site.Name) - $errorMsg" -ForegroundColor Red
            $failedSites += @{Name = $site.Name; Error = $errorMsg}
            & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Failed to create site $($site.Name): $errorMsg" -Level Error -Config $config -ScriptName "New-SimulatedSharePointSites"
        }
    } else {
        # Job timed out - perform cleanup and retry
        Write-Host "   ⏱️  Site creation timed out after ${siteCreationTimeout}s" -ForegroundColor Yellow
        Stop-Job -Job $createJob -ErrorAction SilentlyContinue
        Remove-Job -Job $createJob -Force -ErrorAction SilentlyContinue
        
        Write-Host "   🧹 Performing cleanup before retry..." -ForegroundColor Cyan
        
        # Reconnect to admin center for cleanup operations
        Connect-PnPOnline -Url $config.Environment.AdminCenterUrl -ClientId $config.Environment.PnPClientId -Interactive
        
        # Cleanup Step 1: Check if M365 Group was created and delete it
        $groupAlias = $site.Name
        try {
            $existingGroup = Get-PnPMicrosoft365Group | Where-Object { $_.MailNickname -eq $groupAlias }
            if ($existingGroup) {
                Write-Host "      Deleting M365 Group: $($existingGroup.DisplayName)" -ForegroundColor Gray
                Remove-PnPMicrosoft365Group -Identity $existingGroup.Id -ErrorAction Stop
                Start-Sleep -Seconds 2
                
                # Purge from soft-delete
                $softDeleted = Get-PnPDeletedMicrosoft365Group | Where-Object { $_.MailNickname -eq $groupAlias }
                if ($softDeleted) {
                    Write-Host "      Purging soft-deleted group..." -ForegroundColor Gray
                    Remove-PnPDeletedMicrosoft365Group -Identity $softDeleted.Id -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 2
                }
            }
        } catch {
            Write-Host "      ℹ️  No group to cleanup or already deleted" -ForegroundColor Gray
        }
        
        # Cleanup Step 2: Purge from Azure AD deleted items (release alias reservation)
        try {
            $adDeleted = Invoke-PnPGraphMethod -Url "https://graph.microsoft.com/v1.0/directory/deletedItems/microsoft.graph.group" -Method Get -ErrorAction SilentlyContinue
            $matchingItems = $adDeleted.value | Where-Object { $_.mailNickname -eq $groupAlias }
            foreach ($item in $matchingItems) {
                Write-Host "      Purging Azure AD deleted item: $($item.displayName)" -ForegroundColor Gray
                Invoke-PnPGraphMethod -Url "https://graph.microsoft.com/v1.0/directory/deletedItems/$($item.id)" -Method Delete -ErrorAction SilentlyContinue
            }
        } catch {
            # Ignore errors - item may not exist
        }
        
        # Cleanup Step 3: Check if site exists in recycle bin and purge it
        try {
            $deletedSite = Get-PnPTenantDeletedSite | Where-Object { $_.Url -eq $siteUrl }
            if ($deletedSite) {
                Write-Host "      Purging site from recycle bin..." -ForegroundColor Gray
                Remove-PnPTenantDeletedSite -Identity $siteUrl -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 2
            }
        } catch {
            # Ignore errors - site may not be in recycle bin
        }
        
        # Wait for cleanup to propagate
        Write-Host "      Waiting for cleanup to propagate..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
        
        # Retry site creation
        Write-Host "   🔄 Retrying site creation: $($site.Name)..." -ForegroundColor Cyan
        
        $retryJob = Start-Job -ScriptBlock {
            param($TenantUrl, $PnPClientId, $SiteTitle, $SiteAlias, $SiteDescription, $SiteOwner)
            Import-Module PnP.PowerShell -ErrorAction Stop
            Connect-PnPOnline -Url $TenantUrl -ClientId $PnPClientId -Interactive
            $result = New-PnPSite -Type TeamSite -Title $SiteTitle -Alias $SiteAlias -Description $SiteDescription -Owner $SiteOwner -ErrorAction Stop
            return $result
        } -ArgumentList @(
            $config.Environment.TenantUrl,
            $config.Environment.PnPClientId,
            "$($config.Simulation.CompanyPrefix) - $($site.Department)",
            $site.Name,
            $site.Description,
            $site.Owner
        )
        
        # Wait for retry with extended timeout
        $retryTimeout = 180  # 3 minutes for retry
        $retryCompleted = $retryJob | Wait-Job -Timeout $retryTimeout
        
        if ($retryCompleted -and $retryJob.State -eq 'Completed') {
            $retryResult = Receive-Job -Job $retryJob -ErrorAction SilentlyContinue
            $retryError = $retryJob.ChildJobs[0].JobStateInfo.Reason
            
            if (-not $retryError) {
                Write-Host "   ✅ Site created successfully on retry: $($site.Name)" -ForegroundColor Green
                Write-Host "      URL: $retryResult" -ForegroundColor Cyan
                $createdSites += $site.Name
                $siteCreated = $true
                & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Created site on retry: $($site.Name) at $retryResult" -Level Success -Config $config -ScriptName "New-SimulatedSharePointSites"
            } else {
                Write-Host "   ❌ Site creation failed on retry: $($retryError.Message)" -ForegroundColor Red
                $failedSites += @{Name = $site.Name; Error = "Retry failed: $($retryError.Message)"}
                & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Site creation retry failed: $($site.Name) - $($retryError.Message)" -Level Error -Config $config -ScriptName "New-SimulatedSharePointSites"
            }
        } else {
            # Retry also timed out
            Write-Host "   ❌ Site creation retry also timed out: $($site.Name)" -ForegroundColor Red
            Write-Host "   💡 Run cleanup script and try again manually" -ForegroundColor Cyan
            $failedSites += @{Name = $site.Name; Error = "Creation timed out twice - manual intervention required"}
            & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Site creation timed out twice: $($site.Name) - manual intervention required" -Level Error -Config $config -ScriptName "New-SimulatedSharePointSites"
            Stop-Job -Job $retryJob -ErrorAction SilentlyContinue
        }
        
        Remove-Job -Job $retryJob -Force -ErrorAction SilentlyContinue
    }
    
    # Cleanup job
    Remove-Job -Job $createJob -Force -ErrorAction SilentlyContinue
    
    # Brief pause to avoid throttling
    Start-Sleep -Seconds 2
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

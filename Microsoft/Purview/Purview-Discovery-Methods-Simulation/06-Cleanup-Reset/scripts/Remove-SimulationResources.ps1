<#
.SYNOPSIS
    Removes simulation resources from Microsoft Purview and SharePoint environment.

.DESCRIPTION
    Safely removes simulation resources including DLP policies, SharePoint sites, test
    documents, and classification jobs. Implements dependency-aware deletion order,
    provides confirmation prompts, and validates successful removal at each stage.
    
    This script supports targeted removal of specific resource types or comprehensive
    cleanup of all simulation artifacts. Use -WhatIf for preview before execution.

.PARAMETER ResourceType
    Type of resources to remove. Options: DLPPolicies, Documents, Sites, All.

.PARAMETER Force
    Bypasses confirmation prompts. Use with caution.

.PARAMETER WhatIf
    Shows what would be removed without making any changes.

.PARAMETER SkipRecycleBin
    Permanently deletes resources without using recycle bin (SharePoint sites only).

.EXAMPLE
    .\Remove-SimulationResources.ps1
    
    Removes all simulation resources (DLP Rules → DLP Policies → Documents → Sites)
    with confirmation prompts. Preserves scripts, documentation, and archived reports.

.EXAMPLE
    .\Remove-SimulationResources.ps1 -ResourceType "DLPPolicies" -WhatIf
    
    Previews DLP policy removal without making changes.

.EXAMPLE
    .\Remove-SimulationResources.ps1 -ResourceType "All"
    
    Removes all simulation resources with confirmation prompts (same as no parameter).

.EXAMPLE
    .\Remove-SimulationResources.ps1 -ResourceType "Sites" -Force
    
    Removes SharePoint sites without confirmation prompts.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Global Administrator or appropriate deletion permissions
    - PnP.PowerShell module for SharePoint operations
    - ExchangeOnlineManagement module for DLP operations
    - PowerShell 5.1+ or PowerShell 7+
    
    Script development orchestrated using GitHub Copilot.

.RESOURCE TYPES
    - DLPPolicies: DLP policies and rules
    - Documents: Test documents in SharePoint sites
    - Sites: SharePoint simulation sites
    - All: All simulation resources (comprehensive cleanup) - DEFAULT when no ResourceType specified

.PRESERVED RESOURCES
    When running comprehensive cleanup (All), the following are preserved:
    - Global Configuration: Project structure remains for future use
    - Scripts: All PowerShell scripts preserved for reference
    - Archived Reports: Reports saved before cleanup (if archived)
    - Documentation: README files and guides remain intact
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $false)]
    [ValidateSet("DLPPolicies", "Documents", "Sites", "All")]
    [string]$ResourceType = "All",
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipRecycleBin
)

# =============================================================================
# Action 1: Environment Setup and Safety Checks
# =============================================================================

Write-Host "🗑️  Simulation Resource Removal" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# Load global configuration
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleRoot = Split-Path -Parent $scriptPath
$projectRoot = Split-Path -Parent $moduleRoot
. (Join-Path $projectRoot "Shared-Utilities\Import-GlobalConfig.ps1")
$config = Import-GlobalConfig

# Load simulation logger
. (Join-Path $projectRoot "Shared-Utilities\Write-SimulationLog.ps1")

Write-SimulationLog -Message "Starting resource removal: $ResourceType" -Level "Warning"

Write-Host "`n⚠️  WARNING: Destructive Operation" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow
Write-Host "This will permanently remove simulation resources." -ForegroundColor Yellow
Write-Host "Resource Type: $ResourceType" -ForegroundColor Yellow
Write-Host "Force Mode: $($Force.IsPresent)" -ForegroundColor Yellow
Write-Host "What If Mode: $($WhatIfPreference.IsPresent)" -ForegroundColor Yellow

if (-not $Force -and -not $WhatIfPreference) {
    $confirmation = Read-Host "`nType 'DELETE' to confirm removal"
    if ($confirmation -ne "DELETE") {
        Write-Host "❌ Operation cancelled" -ForegroundColor Red
        Write-SimulationLog -Message "Resource removal cancelled by user" -Level "Info"
        exit 0
    }
}

# =============================================================================
# Action 2: Remove DLP Policies and Rules
# =============================================================================

if ($ResourceType -eq "DLPPolicies" -or $ResourceType -eq "All") {
    Write-Host "`n🔐 Removing DLP Policies and Rules..." -ForegroundColor Cyan
    
    try {
        # Disable WAM broker BEFORE importing module to avoid msalruntime DLL issues
        $env:AZURE_IDENTITY_DISABLE_MSALRUNTIME = "1"
        $env:MSAL_DISABLE_WAM = "1"
        [System.Environment]::SetEnvironmentVariable("AZURE_IDENTITY_DISABLE_MSALRUNTIME", "1", [System.EnvironmentVariableTarget]::Process)
        
        # Now import module with WAM disabled
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
        
        # Check for existing compliance session
        $existingSession = Get-PSSession | Where-Object { 
            $_.ComputerName -like "*compliance.protection.outlook.com*" -and 
            $_.State -eq "Opened" 
        } | Select-Object -First 1
        
        if ($null -ne $existingSession) {
            Write-Host "   ℹ️  Existing Compliance Center session found - reusing" -ForegroundColor Cyan
        } else {
            Write-Host "   🌐 Connecting to Security & Compliance Center..." -ForegroundColor Cyan
            Write-Host "   📋 Please sign in when prompted..." -ForegroundColor Cyan
            
            $connected = $false
            
            # Method 1: Try REST API connection first (modern, no Basic auth needed)
            try {
                Write-Host "   📋 Attempting modern authentication..." -ForegroundColor Gray
                Connect-IPPSSession -WarningAction SilentlyContinue -ErrorAction Stop
                $connected = $true
                Write-Host "   ✅ Connected via modern authentication" -ForegroundColor Green
            } catch {
                Write-Host "   ⚠️  Modern auth failed: $($_.Exception.Message -replace '[\r\n]+', ' ' -replace '.{80,}', '$&...')" -ForegroundColor Yellow
            }
            
            # Method 2: Try Remote PowerShell session (requires Basic auth in WinRM)
            if (-not $connected) {
                try {
                    Write-Host "   📋 Trying Remote PowerShell session..." -ForegroundColor Gray
                    Connect-IPPSSession -UseRPSSession -WarningAction SilentlyContinue -ErrorAction Stop
                    $connected = $true
                    Write-Host "   ✅ Connected via Remote PowerShell" -ForegroundColor Green
                } catch {
                    Write-Host "   ⚠️  Remote PowerShell failed: $($_.Exception.Message -replace '[\r\n]+', ' ')" -ForegroundColor Yellow
                }
            }
            
            if (-not $connected) {
                throw "Unable to connect to Security & Compliance Center. Please ensure you have the necessary permissions and try running: winrm quickconfig"
            }
        }
        
        # Find simulation DLP policies
        $simulationPolicies = Get-DlpCompliancePolicy | Where-Object { $_.Name -like "*Simulation*" }
        
        if ($simulationPolicies.Count -eq 0) {
            Write-Host "   ℹ️  No simulation DLP policies found" -ForegroundColor Gray
        } else {
            Write-Host "   Found $($simulationPolicies.Count) simulation DLP policies" -ForegroundColor Gray
            
            foreach ($policy in $simulationPolicies) {
                Write-Host "`n   Processing: $($policy.Name)" -ForegroundColor Cyan
                
                # Remove rules first
                $rules = Get-DlpComplianceRule -Policy $policy.Name -ErrorAction SilentlyContinue
                
                if ($rules) {
                    Write-Host "      Removing $($rules.Count) rule(s)..." -ForegroundColor Gray
                    
                    foreach ($rule in $rules) {
                        if ($PSCmdlet.ShouldProcess($rule.Name, "Remove DLP Rule")) {
                            try {
                                Remove-DlpComplianceRule -Identity $rule.Name -Confirm:$false -ErrorAction Stop
                                Write-Host "      ✅ Removed rule: $($rule.Name)" -ForegroundColor Green
                                Write-SimulationLog -Message "Removed DLP rule: $($rule.Name)" -Level "Info"
                            } catch {
                                Write-Host "      ⚠️  Failed to remove rule $($rule.Name): $_" -ForegroundColor Yellow
                                Write-SimulationLog -Message "Failed to remove DLP rule $($rule.Name): $_" -Level "Warning"
                            }
                        }
                    }
                    
                    # Wait for rule removal to propagate
                    Write-Host "      Waiting for rule removal to propagate..." -ForegroundColor Gray
                    Start-Sleep -Seconds 10
                }
                
                # Remove policy
                if ($PSCmdlet.ShouldProcess($policy.Name, "Remove DLP Policy")) {
                    try {
                        Remove-DlpCompliancePolicy -Identity $policy.Name -Confirm:$false -ErrorAction Stop
                        Write-Host "   ✅ Removed policy: $($policy.Name)" -ForegroundColor Green
                        Write-SimulationLog -Message "Removed DLP policy: $($policy.Name)" -Level "Info"
                    } catch {
                        Write-Host "   ⚠️  Failed to remove policy $($policy.Name): $_" -ForegroundColor Yellow
                        Write-SimulationLog -Message "Failed to remove DLP policy $($policy.Name): $_" -Level "Warning"
                    }
                }
            }
        }
        
        # Disconnect
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        
    } catch {
        Write-Host "   ❌ Error during DLP removal: $_" -ForegroundColor Red
        Write-SimulationLog -Message "Error during DLP removal: $_" -Level "Error"
    }
}

# =============================================================================
# Action 3: Remove Documents from SharePoint Sites
# =============================================================================

if ($ResourceType -eq "Documents" -or $ResourceType -eq "All") {
    Write-Host "`n📄 Removing Documents from SharePoint Sites..." -ForegroundColor Cyan
    
    # Import shared modules for SharePoint connection
    . "$PSScriptRoot\..\..\Shared-Utilities\Import-PurviewModules.ps1"
    
    try {
        # Get SharePoint sites from configuration
        $sitesToProcess = $config.SharePointSites
        $tenantUrl = $config.Environment.TenantUrl.TrimEnd('/')
        
        foreach ($siteConfig in $sitesToProcess) {
            $siteName = $siteConfig.Name
            $siteUrl = "$tenantUrl/sites/$siteName"
            
            Write-Host "`n   Processing site: $siteName" -ForegroundColor Cyan
            
            try {
                # Connect to site
                Connect-PurviewServices -Services @("SharePoint") -TenantUrl $siteUrl -PnPClientId $config.Environment.PnPClientId -Interactive
                
                # Test if site is accessible
                $web = Get-PnPWeb -ErrorAction Stop
                
                # Get all documents
                $documents = Get-PnPListItem -List "Documents" -PageSize 500 -ErrorAction SilentlyContinue
                
                if ($null -eq $documents -or $documents.Count -eq 0) {
                    Write-Host "      ℹ️  No documents found in $siteName" -ForegroundColor Gray
                } else {
                    Write-Host "      Found $($documents.Count) documents" -ForegroundColor Gray
                    
                    $removedCount = 0
                    $failedCount = 0
                    
                    foreach ($doc in $documents) {
                        $fileName = $doc.FieldValues.FileLeafRef
                        
                        if ($PSCmdlet.ShouldProcess($fileName, "Remove Document")) {
                            try {
                                Remove-PnPListItem -List "Documents" -Identity $doc.Id -Force -ErrorAction Stop
                                $removedCount++
                                
                                if ($removedCount % 100 -eq 0) {
                                    Write-Host "      Progress: $removedCount/$($documents.Count) documents removed" -ForegroundColor Gray
                                }
                            } catch {
                                $failedCount++
                                Write-SimulationLog -Message "Failed to remove document $fileName`: $_" -Level "Warning"
                            }
                        }
                    }
                    
                    Write-Host "      ✅ Removed $removedCount documents ($failedCount failed)" -ForegroundColor Green
                    Write-SimulationLog -Message "Removed $removedCount documents from $siteName" -Level "Info"
                    
                    # Empty recycle bin
                    if ($PSCmdlet.ShouldProcess($siteName, "Empty Recycle Bin")) {
                        Write-Host "      Emptying recycle bin..." -ForegroundColor Gray
                        Clear-PnPRecycleBinItem -All -Force -ErrorAction SilentlyContinue
                        Write-Host "      ✅ Recycle bin emptied" -ForegroundColor Green
                    }
                }
                
                Disconnect-PnPOnline -ErrorAction SilentlyContinue
                
            } catch {
                # Check if site doesn't exist or was already deleted
                if ($_.Exception.Message -like "*does not exist*" -or 
                    $_.Exception.Message -like "*404*" -or 
                    $_.Exception.Message -like "*Cannot find site*" -or
                    $_.Exception.Message -like "*Site not found*" -or
                    $_.Exception.Message -like "*NotFound*") {
                    Write-Host "      ℹ️  Site $siteName not found or already deleted - skipping" -ForegroundColor Gray
                } else {
                    Write-Host "      ⚠️  Error processing $siteName`: $_" -ForegroundColor Yellow
                    Write-SimulationLog -Message "Error removing documents from $siteName`: $_" -Level "Warning"
                }
            }
        }
        
    } catch {
        Write-Host "   ❌ Error during document removal: $_" -ForegroundColor Red
        Write-SimulationLog -Message "Error during document removal: $_" -Level "Error"
    }
}

# =============================================================================
# Action 4: Remove SharePoint Sites (Complete Multi-Phase Cleanup)
# =============================================================================

if ($ResourceType -eq "Sites" -or $ResourceType -eq "All") {
    Write-Host "`n🌐 Removing SharePoint Sites (Multi-Phase Cleanup)..." -ForegroundColor Cyan
    Write-Host "   This process ensures complete removal with no alias reservations left behind" -ForegroundColor Gray
    
    try {
        # Import shared modules (if not already loaded)
        if (-not (Get-Command Connect-PurviewServices -ErrorAction SilentlyContinue)) {
            . "$PSScriptRoot\..\..\Shared-Utilities\Import-PurviewModules.ps1"
        }
        
        # Connect to SharePoint Admin using shared module
        $tenantUrl = $config.Environment.TenantUrl.TrimEnd('/')
        $adminUrl = $config.Environment.AdminCenterUrl
        $companyPrefix = $config.Simulation.CompanyPrefix
        
        Write-Host "   Connecting to SharePoint Admin: $adminUrl" -ForegroundColor Gray
        Connect-PurviewServices -Services @("SharePoint") -TenantUrl $adminUrl -PnPClientId $config.Environment.PnPClientId -Interactive
        Write-Host "   ✅ Connected to SharePoint Admin" -ForegroundColor Green
        
        # Get SharePoint sites from configuration
        $sitesToProcess = $config.SharePointSites
        
        # =========================================================================
        # Phase 1: Delete M365 Groups (this removes group-connected sites)
        # =========================================================================
        Write-Host "`n   📋 Phase 1: Removing M365 Groups..." -ForegroundColor Cyan
        
        # Find groups by company prefix and simulation pattern
        $simulationGroups = Get-PnPMicrosoft365Group | Where-Object { 
            $_.DisplayName -match "$companyPrefix|Simulation" 
        }
        
        if ($simulationGroups.Count -eq 0) {
            Write-Host "      ℹ️  No M365 groups found matching simulation pattern" -ForegroundColor Gray
        } else {
            Write-Host "      Found $($simulationGroups.Count) M365 groups to remove" -ForegroundColor Gray
            
            foreach ($group in $simulationGroups) {
                if ($PSCmdlet.ShouldProcess($group.DisplayName, "Remove M365 Group")) {
                    try {
                        Remove-PnPMicrosoft365Group -Identity $group.Id -ErrorAction Stop
                        Write-Host "      ✅ Deleted group: $($group.DisplayName)" -ForegroundColor Green
                        Write-SimulationLog -Message "Deleted M365 Group: $($group.DisplayName)" -Level "Info"
                    } catch {
                        Write-Host "      ⚠️  Failed to delete group $($group.DisplayName): $_" -ForegroundColor Yellow
                    }
                }
            }
        }
        
        # Brief pause for propagation
        Start-Sleep -Seconds 3
        
        # =========================================================================
        # Phase 2: Permanently Delete Soft-Deleted M365 Groups
        # =========================================================================
        Write-Host "`n   📋 Phase 2: Purging Soft-Deleted M365 Groups..." -ForegroundColor Cyan
        
        $softDeletedGroups = Get-PnPDeletedMicrosoft365Group | Where-Object { 
            $_.DisplayName -match "$companyPrefix|Simulation" 
        }
        
        if ($softDeletedGroups.Count -eq 0) {
            Write-Host "      ℹ️  No soft-deleted groups found" -ForegroundColor Gray
        } else {
            Write-Host "      Found $($softDeletedGroups.Count) soft-deleted groups to purge" -ForegroundColor Gray
            
            foreach ($group in $softDeletedGroups) {
                if ($PSCmdlet.ShouldProcess($group.DisplayName, "Permanently Delete Soft-Deleted Group")) {
                    try {
                        Remove-PnPDeletedMicrosoft365Group -Identity $group.Id -ErrorAction Stop
                        Write-Host "      ✅ Purged soft-deleted group: $($group.DisplayName)" -ForegroundColor Green
                        Write-SimulationLog -Message "Purged soft-deleted group: $($group.DisplayName)" -Level "Info"
                    } catch {
                        Write-Host "      ⚠️  Failed to purge group $($group.DisplayName): $_" -ForegroundColor Yellow
                    }
                }
            }
        }
        
        # Brief pause for propagation
        Start-Sleep -Seconds 3
        
        # =========================================================================
        # Phase 3: Purge Azure AD Deleted Items (Critical for Alias Release)
        # =========================================================================
        Write-Host "`n   📋 Phase 3: Purging Azure AD Deleted Items (releases alias reservations)..." -ForegroundColor Cyan
        
        try {
            $adDeletedItems = Invoke-PnPGraphMethod -Url "https://graph.microsoft.com/v1.0/directory/deletedItems/microsoft.graph.group" -Method Get -ErrorAction Stop
            $simulationDeletedItems = $adDeletedItems.value | Where-Object { 
                $_.displayName -match "$companyPrefix|Simulation" 
            }
            
            if ($simulationDeletedItems.Count -eq 0) {
                Write-Host "      ℹ️  No Azure AD deleted items found" -ForegroundColor Gray
            } else {
                Write-Host "      Found $($simulationDeletedItems.Count) Azure AD deleted items to purge" -ForegroundColor Gray
                
                foreach ($item in $simulationDeletedItems) {
                    if ($PSCmdlet.ShouldProcess($item.displayName, "Permanently Delete from Azure AD")) {
                        try {
                            Invoke-PnPGraphMethod -Url "https://graph.microsoft.com/v1.0/directory/deletedItems/$($item.id)" -Method Delete -ErrorAction Stop
                            Write-Host "      ✅ Purged Azure AD item: $($item.displayName)" -ForegroundColor Green
                            Write-SimulationLog -Message "Purged Azure AD deleted item: $($item.displayName)" -Level "Info"
                        } catch {
                            Write-Host "      ⚠️  Failed to purge Azure AD item $($item.displayName): $_" -ForegroundColor Yellow
                        }
                    }
                }
            }
        } catch {
            Write-Host "      ⚠️  Could not query Azure AD deleted items: $_" -ForegroundColor Yellow
        }
        
        # Brief pause for propagation
        Start-Sleep -Seconds 3
        
        # =========================================================================
        # Phase 4: Purge Tenant Deleted Sites (SharePoint Recycle Bin)
        # =========================================================================
        Write-Host "`n   📋 Phase 4: Purging Tenant Deleted Sites (SharePoint recycle bin)..." -ForegroundColor Cyan
        
        $deletedSites = Get-PnPTenantDeletedSite | Where-Object { 
            $_.Url -match "Simulation" 
        }
        
        if ($deletedSites.Count -eq 0) {
            Write-Host "      ℹ️  No deleted sites in recycle bin" -ForegroundColor Gray
        } else {
            Write-Host "      Found $($deletedSites.Count) deleted sites to permanently remove" -ForegroundColor Gray
            
            foreach ($site in $deletedSites) {
                if ($PSCmdlet.ShouldProcess($site.Url, "Permanently Delete from Recycle Bin")) {
                    try {
                        Remove-PnPTenantDeletedSite -Identity $site.Url -Force -ErrorAction Stop
                        Write-Host "      ✅ Purged deleted site: $($site.Url)" -ForegroundColor Green
                        Write-SimulationLog -Message "Purged deleted site: $($site.Url)" -Level "Info"
                    } catch {
                        Write-Host "      ⚠️  Failed to purge deleted site $($site.Url): $_" -ForegroundColor Yellow
                    }
                }
            }
        }
        
        # Brief pause for propagation
        Start-Sleep -Seconds 3
        
        # =========================================================================
        # Phase 5: Remove Any Remaining Active Sites (including orphans)
        # =========================================================================
        Write-Host "`n   📋 Phase 5: Removing Any Remaining Active Sites..." -ForegroundColor Cyan
        
        # Find all simulation sites (including orphans with number suffixes like "2", "9", etc.)
        $activeSites = Get-PnPTenantSite | Where-Object { 
            $_.Url -match "Simulation" 
        }
        
        if ($activeSites.Count -eq 0) {
            Write-Host "      ℹ️  No active simulation sites found" -ForegroundColor Gray
        } else {
            Write-Host "      Found $($activeSites.Count) active sites to remove" -ForegroundColor Gray
            
            foreach ($site in $activeSites) {
                $siteName = $site.Url -replace ".*/sites/", ""
                
                if ($PSCmdlet.ShouldProcess($siteName, "Remove Active Site")) {
                    Write-Host "      Processing: $siteName" -ForegroundColor Cyan
                    
                    # Check if site has a GroupId (group-connected site)
                    if ($site.GroupId -and $site.GroupId -ne [Guid]::Empty -and $site.GroupId -ne "00000000-0000-0000-0000-000000000000") {
                        Write-Host "         Site has GroupId: $($site.GroupId) - checking if group exists..." -ForegroundColor Gray
                        
                        # Try to delete the group first
                        try {
                            Remove-PnPMicrosoft365Group -Identity $site.GroupId -ErrorAction Stop
                            Write-Host "         ✅ Deleted associated M365 Group" -ForegroundColor Green
                        } catch {
                            # Group doesn't exist - site is orphaned
                            if ($_.Exception.Message -like "*NotFound*" -or $_.Exception.Message -like "*does not exist*") {
                                Write-Host "         ℹ️  Group already deleted - site is orphaned" -ForegroundColor Gray
                            } else {
                                Write-Host "         ⚠️  Group deletion failed: $($_.Exception.Message)" -ForegroundColor Yellow
                            }
                        }
                        
                        # Wait for group deletion to propagate
                        Start-Sleep -Seconds 5
                        
                        # Try to delete the site directly
                        try {
                            Remove-PnPTenantSite -Url $site.Url -Force -SkipRecycleBin -ErrorAction Stop
                            Write-Host "         ✅ Site removed: $siteName" -ForegroundColor Green
                            Write-SimulationLog -Message "Removed site: $siteName" -Level "Info"
                        } catch {
                            if ($_.Exception.Message -like "*belongs to a Microsoft 365 group*") {
                                Write-Host "         ⚠️  Site still shows group association (SharePoint cache delay)" -ForegroundColor Yellow
                                Write-Host "         💡 This site will be cleaned up on next run after cache syncs" -ForegroundColor Cyan
                                Write-SimulationLog -Message "Site $siteName has stale group association - retry later" -Level "Warning"
                            } else {
                                Write-Host "         ⚠️  Failed to remove site: $($_.Exception.Message)" -ForegroundColor Yellow
                            }
                        }
                    } else {
                        # Standard site (not group-connected) - remove directly
                        try {
                            Remove-PnPTenantSite -Url $site.Url -Force -SkipRecycleBin -ErrorAction Stop
                            Write-Host "         ✅ Site removed: $siteName" -ForegroundColor Green
                            Write-SimulationLog -Message "Removed site: $siteName" -Level "Info"
                        } catch {
                            Write-Host "         ⚠️  Failed to remove site: $($_.Exception.Message)" -ForegroundColor Yellow
                        }
                    }
                }
            }
        }
        
        # =========================================================================
        # Phase 5b: Final Recycle Bin Purge (catch any sites deleted in Phase 5)
        # =========================================================================
        Write-Host "`n   📋 Phase 5b: Final Recycle Bin Purge..." -ForegroundColor Cyan
        
        # Brief pause to let deletions propagate to recycle bin
        Start-Sleep -Seconds 3
        
        $finalDeletedSites = Get-PnPTenantDeletedSite | Where-Object { 
            $_.Url -match "Simulation" 
        }
        
        if ($finalDeletedSites.Count -eq 0) {
            Write-Host "      ℹ️  No sites in recycle bin" -ForegroundColor Gray
        } else {
            Write-Host "      Found $($finalDeletedSites.Count) sites in recycle bin to purge" -ForegroundColor Gray
            
            foreach ($site in $finalDeletedSites) {
                if ($PSCmdlet.ShouldProcess($site.Url, "Final Purge from Recycle Bin")) {
                    try {
                        Remove-PnPTenantDeletedSite -Identity $site.Url -Force -ErrorAction Stop
                        Write-Host "      ✅ Purged: $($site.Url)" -ForegroundColor Green
                        Write-SimulationLog -Message "Final purge - deleted site: $($site.Url)" -Level "Info"
                    } catch {
                        Write-Host "      ⚠️  Failed to purge $($site.Url): $_" -ForegroundColor Yellow
                    }
                }
            }
        }
        
        # =========================================================================
        # Phase 6: Final Verification
        # =========================================================================
        Write-Host "`n   📋 Phase 6: Final Verification..." -ForegroundColor Cyan
        
        # Reconnect to ensure fresh data
        Start-Sleep -Seconds 3
        
        $remainingSites = Get-PnPTenantSite | Where-Object { $_.Url -match "Simulation" }
        $remainingDeleted = Get-PnPTenantDeletedSite | Where-Object { $_.Url -match "Simulation" }
        $remainingGroups = Get-PnPMicrosoft365Group | Where-Object { $_.DisplayName -match "$companyPrefix|Simulation" }
        $remainingSoftDeleted = Get-PnPDeletedMicrosoft365Group | Where-Object { $_.DisplayName -match "$companyPrefix|Simulation" }
        
        Write-Host "`n   📊 Cleanup Status:" -ForegroundColor Cyan
        Write-Host "      Active Sites: $($remainingSites.Count)" -ForegroundColor $(if ($remainingSites.Count -eq 0) { "Green" } else { "Yellow" })
        Write-Host "      Deleted Sites (recycle bin): $($remainingDeleted.Count)" -ForegroundColor $(if ($remainingDeleted.Count -eq 0) { "Green" } else { "Yellow" })
        Write-Host "      M365 Groups: $($remainingGroups.Count)" -ForegroundColor $(if ($remainingGroups.Count -eq 0) { "Green" } else { "Yellow" })
        Write-Host "      Soft-Deleted Groups: $($remainingSoftDeleted.Count)" -ForegroundColor $(if ($remainingSoftDeleted.Count -eq 0) { "Green" } else { "Yellow" })
        
        if ($remainingSites.Count -eq 0 -and $remainingDeleted.Count -eq 0 -and $remainingGroups.Count -eq 0 -and $remainingSoftDeleted.Count -eq 0) {
            Write-Host "`n   ✅ Complete cleanup successful - all resources removed!" -ForegroundColor Green
            Write-SimulationLog -Message "Complete SharePoint cleanup successful" -Level "Success"
        } else {
            Write-Host "`n   ⚠️  Some resources remain - may require cache sync time or manual intervention" -ForegroundColor Yellow
            
            if ($remainingSites.Count -gt 0) {
                Write-Host "      Remaining sites:" -ForegroundColor Yellow
                $remainingSites | ForEach-Object { Write-Host "         - $($_.Url)" -ForegroundColor Gray }
            }
            
            Write-Host "`n   💡 Tip: Wait 15-30 minutes for SharePoint/Azure AD cache sync, then run cleanup again" -ForegroundColor Cyan
            Write-SimulationLog -Message "Partial cleanup - some resources remain pending cache sync" -Level "Warning"
        }
        
        Disconnect-PnPOnline -ErrorAction SilentlyContinue
        
    } catch {
        Write-Host "   ❌ Error during site removal: $_" -ForegroundColor Red
        Write-SimulationLog -Message "Error during site removal: $_" -Level "Error"
    }
}

# =============================================================================
# Action 5: Generate Removal Summary
# =============================================================================

Write-Host "`n✅ Resource Removal Complete" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

Write-Host "`n📊 Removal Summary:" -ForegroundColor Cyan
Write-Host "   Resource Type: $ResourceType" -ForegroundColor Gray
Write-Host "   Operation Mode: $(if ($WhatIfPreference) { 'Preview (WhatIf)' } elseif ($Force) { 'Force' } else { 'Interactive' })" -ForegroundColor Gray
Write-Host "   Status: $(if ($WhatIfPreference) { 'No changes made' } else { 'Resources removed' })" -ForegroundColor Gray

Write-Host "`n💡 Next Steps:" -ForegroundColor Cyan

if ($ResourceType -eq "DLPPolicies") {
    Write-Host "   1. Verify DLP policies removed in Compliance Portal" -ForegroundColor Gray
    Write-Host "   2. Continue with document removal if needed" -ForegroundColor Gray
    Write-Host "   3. Run Test-CleanupCompletion.ps1 to verify" -ForegroundColor Gray
} elseif ($ResourceType -eq "Documents") {
    Write-Host "   1. Verify documents removed from SharePoint sites" -ForegroundColor Gray
    Write-Host "   2. Continue with site removal if needed" -ForegroundColor Gray
    Write-Host "   3. Run Test-CleanupCompletion.ps1 to verify" -ForegroundColor Gray
} elseif ($ResourceType -eq "Sites") {
    Write-Host "   1. Verify sites removed in SharePoint Admin Center" -ForegroundColor Gray
    Write-Host "   2. Check recycle bin if not permanently deleted" -ForegroundColor Gray
    Write-Host "   3. Run Test-CleanupCompletion.ps1 to verify" -ForegroundColor Gray
} else {
    Write-Host "   1. Run Test-CleanupCompletion.ps1 to verify all resources removed" -ForegroundColor Gray
    Write-Host "   2. Proceed to Reset-Environment.ps1 for complete reset" -ForegroundColor Gray
    Write-Host "   3. Review archived reports and documentation" -ForegroundColor Gray
}

Write-SimulationLog -Message "Resource removal completed: $ResourceType" -Level "Info"

exit 0

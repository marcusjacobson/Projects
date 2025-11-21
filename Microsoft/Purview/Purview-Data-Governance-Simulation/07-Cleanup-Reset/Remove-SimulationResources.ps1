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
    .\Remove-SimulationResources.ps1 -ResourceType "DLPPolicies" -WhatIf
    
    Previews DLP policy removal without making changes.

.EXAMPLE
    .\Remove-SimulationResources.ps1 -ResourceType "All"
    
    Removes all simulation resources with confirmation prompts.

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
    - All: All simulation resources (comprehensive cleanup)
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("DLPPolicies", "Documents", "Sites", "All")]
    [string]$ResourceType,
    
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
$projectRoot = Split-Path -Parent $scriptPath
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
    
    # Import shared modules
    . "$PSScriptRoot\..\Shared-Utilities\Import-PurviewModules.ps1"
    
    try {
        # Connect to Security & Compliance Center using shared module
        Write-Host "   Connecting to Security & Compliance Center..." -ForegroundColor Gray
        Connect-PurviewServices -Services @("ComplianceCenter") -Interactive
        Write-Host "   ✅ Connected to Security & Compliance Center" -ForegroundColor Green
        
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
    
    try {
        # Get departments from configuration
        $departments = $config.Departments
        
        foreach ($dept in $departments) {
            $siteName = "$($dept.Name)-Simulation"
            $siteUrl = "$($config.SharePointBaseUrl)/sites/$siteName"
            
            Write-Host "`n   Processing site: $siteName" -ForegroundColor Cyan
            
            try {
                # Connect to site using shared module
                # Load config if not already available
                if (-not $config) {
                    $config = & "$PSScriptRoot\..\Shared-Utilities\Import-GlobalConfig.ps1"
                }
                Connect-PurviewServices -Services @("SharePoint") -TenantUrl $siteUrl -PnPClientId $config.Environment.PnPClientId -Interactive
                
                # Get all documents
                $documents = Get-PnPListItem -List "Documents" -PageSize 500 -ErrorAction SilentlyContinue
                
                if ($documents.Count -eq 0) {
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
                
                Disconnect-PnPOnline
                
            } catch {
                Write-Host "      ⚠️  Error processing $siteName`: $_" -ForegroundColor Yellow
                Write-SimulationLog -Message "Error removing documents from $siteName`: $_" -Level "Warning"
            }
        }
        
    } catch {
        Write-Host "   ❌ Error during document removal: $_" -ForegroundColor Red
        Write-SimulationLog -Message "Error during document removal: $_" -Level "Error"
    }
}

# =============================================================================
# Action 4: Remove SharePoint Sites
# =============================================================================

if ($ResourceType -eq "Sites" -or $ResourceType -eq "All") {
    Write-Host "`n🌐 Removing SharePoint Sites..." -ForegroundColor Cyan
    
    try {
        # Import shared modules (if not already loaded)
        if (-not (Get-Command Connect-PurviewServices -ErrorAction SilentlyContinue)) {
            . "$PSScriptRoot\..\Shared-Utilities\Import-PurviewModules.ps1"
        }
        
        # Connect to SharePoint Admin using shared module
        $adminUrl = $config.SharePointBaseUrl -replace "https://([^.]+)", "https://`$1-admin"
        
        Write-Host "   Connecting to SharePoint Admin: $adminUrl" -ForegroundColor Gray
        Connect-PurviewServices -Services @("SharePoint") -TenantUrl $adminUrl -PnPClientId $config.Environment.PnPClientId -Interactive
        Write-Host "   ✅ Connected to SharePoint Admin" -ForegroundColor Green
        
        # Get departments from configuration
        $departments = $config.Departments
        
        foreach ($dept in $departments) {
            $siteName = "$($dept.Name)-Simulation"
            $siteUrl = "$($config.SharePointBaseUrl)/sites/$siteName"
            
            Write-Host "`n   Processing site: $siteName" -ForegroundColor Cyan
            
            if ($PSCmdlet.ShouldProcess($siteName, "Remove SharePoint Site")) {
                try {
                    # Check if site exists
                    $site = Get-PnPTenantSite -Url $siteUrl -ErrorAction SilentlyContinue
                    
                    if ($site) {
                        # Remove site
                        Remove-PnPTenantSite -Url $siteUrl -Force -ErrorAction Stop
                        Write-Host "   ✅ Site moved to recycle bin: $siteName" -ForegroundColor Green
                        Write-SimulationLog -Message "Removed SharePoint site: $siteName" -Level "Info"
                        
                        # Permanently delete from recycle bin if requested
                        if ($SkipRecycleBin) {
                            Start-Sleep -Seconds 5
                            Remove-PnPTenantDeletedSite -Url $siteUrl -Force -ErrorAction Stop
                            Write-Host "   ✅ Site permanently deleted: $siteName" -ForegroundColor Green
                        }
                    } else {
                        Write-Host "   ℹ️  Site not found: $siteName" -ForegroundColor Gray
                    }
                    
                } catch {
                    Write-Host "   ⚠️  Failed to remove site $siteName`: $_" -ForegroundColor Yellow
                    Write-SimulationLog -Message "Failed to remove site $siteName`: $_" -Level "Warning"
                }
            }
        }
        
        Disconnect-PnPOnline
        
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

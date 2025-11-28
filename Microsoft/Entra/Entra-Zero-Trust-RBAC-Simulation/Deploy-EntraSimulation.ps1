<#
.SYNOPSIS
    Orchestrates the deployment of the entire Entra Zero Trust RBAC Simulation.

.DESCRIPTION
    Sequentially executes all deployment scripts from Lab 00 to Lab 08.
    Validates successful execution of each step before proceeding.
    This is the "Big Green Button" to deploy the entire simulation.

.EXAMPLE
    .\Deploy-EntraSimulation.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-28
    Last Modified: 2025-11-28
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    - Global Administrator privileges
    
    Script development orchestrated using GitHub Copilot.

.SPECIALIZED_SECTION
    PHASES
    - Phase 0: Prerequisites & Monitoring
    - Phase 1: Identity Foundation
    - Phase 2: Delegated Administration
    - Phase 3: App Integration
    - Phase 4: RBAC & PIM
    - Phase 5: Entitlement Management
    - Phase 6: Identity Security
    - Phase 7: Lifecycle Governance
    - Phase 8: Final Validation
#>
#
# =============================================================================
# Phase 1: Orchestrate Full Deployment
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    # Connect to Graph first
    . "$PSScriptRoot\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🚀 Starting Full Entra Zero Trust RBAC Simulation Deployment..." -ForegroundColor Magenta
    Write-Host "=============================================================" -ForegroundColor Magenta

    $deploymentSteps = @(
        # Lab 00
        @{ Path = "00-Prerequisites-and-Monitoring\scripts\Validate-Prerequisites.ps1"; Name = "Lab 00: Validate Prerequisites" },
        @{ Path = "00-Prerequisites-and-Monitoring\scripts\Deploy-LogAnalytics.ps1"; Name = "Lab 00: Deploy Log Analytics" },
        @{ Path = "00-Prerequisites-and-Monitoring\scripts\Configure-DiagnosticSettings.ps1"; Name = "Lab 00: Configure Diagnostic Settings" },

        # Lab 01
        @{ Path = "01-Identity-Foundation\scripts\Deploy-IdentityHierarchy.ps1"; Name = "Lab 01: Deploy Identity Hierarchy" },
        @{ Path = "01-Identity-Foundation\scripts\Configure-TenantHardening.ps1"; Name = "Lab 01: Configure Tenant Hardening" },
        @{ Path = "01-Identity-Foundation\scripts\Deploy-BreakGlassAccounts.ps1"; Name = "Lab 01: Deploy Break Glass Accounts" },
        @{ Path = "01-Identity-Foundation\scripts\Configure-GroupBasedLicensing.ps1"; Name = "Lab 01: Configure Group Based Licensing" },

        # Lab 02
        @{ Path = "02-Delegated-Administration\scripts\Deploy-AdministrativeUnits.ps1"; Name = "Lab 02: Deploy Administrative Units" },
        @{ Path = "02-Delegated-Administration\scripts\Configure-RestrictedManagementAUs.ps1"; Name = "Lab 02: Configure Restricted Management AUs" },

        # Lab 03
        @{ Path = "03-App-Integration\scripts\Deploy-ReportingServicePrincipal.ps1"; Name = "Lab 03: Deploy Reporting Service Principal" },
        @{ Path = "03-App-Integration\scripts\Configure-AppConsentGovernance.ps1"; Name = "Lab 03: Configure App Consent Governance" },

        # Lab 04
        @{ Path = "04-RBAC-and-PIM\scripts\Deploy-CustomRoles.ps1"; Name = "Lab 04: Deploy Custom Roles" },
        @{ Path = "04-RBAC-and-PIM\scripts\Configure-PIM-Roles.ps1"; Name = "Lab 04: Configure PIM Roles" },
        @{ Path = "04-RBAC-and-PIM\scripts\Configure-PIM-Groups.ps1"; Name = "Lab 04: Configure PIM Groups" },

        # Lab 05
        @{ Path = "05-Entitlement-Management\scripts\Deploy-AccessPackages.ps1"; Name = "Lab 05: Deploy Access Packages" },
        @{ Path = "05-Entitlement-Management\scripts\Configure-ExternalGovernance.ps1"; Name = "Lab 05: Configure External Governance" },

        # Lab 06
        @{ Path = "06-Identity-Security\scripts\Configure-AuthMethods.ps1"; Name = "Lab 06: Configure Auth Methods" },
        @{ Path = "06-Identity-Security\scripts\Deploy-CAPolicies.ps1"; Name = "Lab 06: Deploy Conditional Access Policies" },
        @{ Path = "06-Identity-Security\scripts\Configure-IdentityProtection.ps1"; Name = "Lab 06: Configure Identity Protection" },
        @{ Path = "06-Identity-Security\scripts\Deploy-AuthEnforcement.ps1"; Name = "Lab 06: Deploy Auth Enforcement" },

        # Lab 07
        @{ Path = "07-Lifecycle-Governance\scripts\Deploy-AccessReviews.ps1"; Name = "Lab 07: Deploy Access Reviews" },
        @{ Path = "07-Lifecycle-Governance\scripts\Configure-LifecycleWorkflows.ps1"; Name = "Lab 07: Configure Lifecycle Workflows" },

        # Lab 08
        @{ Path = "08-Validation-and-Reporting\scripts\Validate-AllLabs.ps1"; Name = "Lab 08: Final Validation" }
    )

    foreach ($step in $deploymentSteps) {
        $fullPath = Join-Path $PSScriptRoot $step.Path
        
        if (Test-Path $fullPath) {
            Write-Host "`n🚀 Executing: $($step.Name)..." -ForegroundColor Blue
            
            try {
                # Execute the script
                if ($UseParametersFile) {
                    & $fullPath -UseParametersFile
                } else {
                    & $fullPath
                }

                # Check exit code
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "❌ Step Failed: $($step.Name). Exit Code: $LASTEXITCODE" -ForegroundColor Red
                    $response = Read-Host "Do you want to continue anyway? (y/n)"
                    if ($response -ne 'y') {
                        Write-Error "Deployment aborted at step: $($step.Name)"
                        exit 1
                    }
                } else {
                    Write-Host "✅ Step Complete: $($step.Name)" -ForegroundColor Green
                }
            } catch {
                Write-Host "❌ Exception during step: $($step.Name). Error: $_" -ForegroundColor Red
                $response = Read-Host "Do you want to continue anyway? (y/n)"
                if ($response -ne 'y') {
                    Write-Error "Deployment aborted at step: $($step.Name)"
                    exit 1
                }
            }
        } else {
            Write-Warning "⚠️ Script not found: $fullPath"
            $response = Read-Host "Do you want to continue anyway? (y/n)"
            if ($response -ne 'y') {
                exit 1
            }
        }
    }

    Write-Host "`n✅✅✅ Full Simulation Deployment Complete! ✅✅✅" -ForegroundColor Green
}

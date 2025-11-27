<#
.SYNOPSIS
    Removes ALL simulation resources.

.DESCRIPTION
    The "Big Red Button". Deletes all resources created by the Entra Zero Trust RBAC Simulation.
    Prompts for confirmation before execution.

.EXAMPLE
    .\Nuke-Simulation.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-24
    Last Modified: 2025-11-24
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    
    Script development orchestrated using GitHub Copilot.

.SPECIALIZED_SECTION
    CLEANUP OPERATIONS
    - Scope: All simulation resources (Users, Groups, Policies)
    - Safety: Confirmation prompt required
    - Method: Forceful deletion
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Switch]$Force,
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "⚠️  WARNING: This script will delete ALL resources created by the simulation." -ForegroundColor Red
    Write-Host "   It will execute the cleanup scripts for Labs 07 down to 01."
    
    if (-not $Force -and -not $PSCmdlet.ShouldProcess("All Simulation Resources", "Delete")) {
        return
    }

    if (-not $Force) {
        $confirm = Read-Host "Are you sure you want to proceed? (y/n)"
        if ($confirm -ne 'y') {
            Write-Host "Aborted." -ForegroundColor Yellow
            return
        }
    }

    Write-Host "🚀 Nuking Simulation Resources..." -ForegroundColor Red

    $scripts = @(
        @{ Path = "..\..\07-Lifecycle-Governance\scripts\Remove-LifecycleGovernance.ps1"; Name = "Lab 07: Lifecycle Governance" },
        @{ Path = "..\..\06-Identity-Security\scripts\Remove-IdentitySecurity.ps1"; Name = "Lab 06: Identity Security" },
        @{ Path = "..\..\05-Entitlement-Management\scripts\Remove-EntitlementMgmt.ps1"; Name = "Lab 05: Entitlement Management" },
        @{ Path = "..\..\04-RBAC-and-PIM\scripts\Remove-RBAC-PIM.ps1"; Name = "Lab 04: RBAC & PIM" },
        @{ Path = "..\..\03-App-Integration\scripts\Remove-AppIntegration.ps1"; Name = "Lab 03: App Integration" },
        @{ Path = "..\..\02-Delegated-Administration\scripts\Remove-DelegatedAdmin.ps1"; Name = "Lab 02: Delegated Admin" },
        @{ Path = "..\..\01-Identity-Foundation\scripts\Remove-IdentityFoundation.ps1"; Name = "Lab 01: Identity Foundation" }
    )

    foreach ($script in $scripts) {
        $fullPath = Join-Path $PSScriptRoot $script.Path
        if (Test-Path $fullPath) {
            Write-Host "   Calling Cleanup for $($script.Name)..." -ForegroundColor Yellow
            if ($PSCmdlet.ShouldProcess($script.Name, "Execute Cleanup Script")) {
                try {
                    & $fullPath -UseParametersFile
                } catch {
                    Write-Host "   ❌ Error running $($script.Name): $_" -ForegroundColor Red
                }
            }
        } else {
            Write-Warning "   ⚠️ Script not found: $fullPath"
        }
    }

    Write-Host "✅ Cleanup Sequence Complete." -ForegroundColor Green
}

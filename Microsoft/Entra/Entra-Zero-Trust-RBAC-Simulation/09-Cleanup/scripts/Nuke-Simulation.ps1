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

[CmdletBinding()]
param(
    [Switch]$Force,
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    # Load Parameters
    $paramsPath = Join-Path $PSScriptRoot "..\infra\module.parameters.json"
    if ($UseParametersFile -or (Test-Path $paramsPath)) {
        if (Test-Path $paramsPath) {
            Write-Host "📂 Loading parameters from $paramsPath..." -ForegroundColor Cyan
            $jsonParams = Get-Content $paramsPath | ConvertFrom-Json
            
            $CaPolicyFilter = $jsonParams."Nuke-Simulation".caPolicyFilter
            $WorkflowFilter = $jsonParams."Nuke-Simulation".workflowFilter
            $AccessReviewFilter = $jsonParams."Nuke-Simulation".accessReviewFilter
            $CustomRoleFilter = $jsonParams."Nuke-Simulation".customRoleFilter
            $AdminUnitFilter = $jsonParams."Nuke-Simulation".adminUnitFilter
            $ServicePrincipalFilter = $jsonParams."Nuke-Simulation".servicePrincipalFilter
            $GroupFilter = $jsonParams."Nuke-Simulation".groupFilter
            $UserFilter = $jsonParams."Nuke-Simulation".userFilter
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "⚠️  WARNING: This script will delete ALL resources created by the simulation." -ForegroundColor Red
    Write-Host "   - Users (breakglass*, admin-*, user-*)"
    Write-Host "   - Groups (GRP-SEC-*, GRP-M365-*)"
    Write-Host "   - Admin Units (AU-*)"
    Write-Host "   - Custom Roles (Role-Custom-*)"
    Write-Host "   - CA Policies (CA-0*)"
    Write-Host "   - Entitlement Mgmt (Catalogs, Packages)"
    Write-Host "   - Access Reviews (AR-*)"
    Write-Host "   - Lifecycle Workflows (WF-*)"
    Write-Host "   - Service Principals (SP-App-*)"
    
    if (-not $Force) {
        $confirm = Read-Host "Are you sure you want to proceed? (y/n)"
        if ($confirm -ne 'y') {
            Write-Host "Aborted." -ForegroundColor Yellow
            return
        }
    }

    Write-Host "🚀 Nuking Simulation Resources..." -ForegroundColor Red

    # Helper
    function Remove-Resource ($Type, $Uri, $DeleteUriTemplate) {
        Write-Host "   Scanning for $Type..." -NoNewline
        try {
            $response = Invoke-MgGraphRequest -Method GET -Uri $Uri
            $items = $response.value
            
            if ($items) {
                Write-Host " Found $($items.Count). Deleting..." -ForegroundColor Yellow
                foreach ($item in $items) {
                    try {
                        $delUri = $DeleteUriTemplate -f $item.id
                        Invoke-MgGraphRequest -Method DELETE -Uri $delUri
                        Write-Host "     - Deleted '$($item.displayName ?? $item.userPrincipalName)'" -ForegroundColor Gray
                    } catch {
                        Write-Host "     ❌ Failed to delete '$($item.displayName ?? $item.userPrincipalName)': $_" -ForegroundColor Red
                    }
                }
            } else {
                Write-Host " None found." -ForegroundColor Green
            }
        } catch {
            Write-Host " Error scanning: $_" -ForegroundColor Red
        }
    }

    # 1. CA Policies
    Remove-Resource "CA Policies" "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=$CaPolicyFilter" "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies/{0}"

    # 2. Lifecycle Workflows
    Remove-Resource "Lifecycle Workflows" "https://graph.microsoft.com/v1.0/identityGovernance/lifecycleWorkflows/workflows?`$filter=$WorkflowFilter" "https://graph.microsoft.com/v1.0/identityGovernance/lifecycleWorkflows/workflows/{0}"

    # 3. Access Reviews
    # Need to stop first?
    Write-Host "   Scanning for Access Reviews..." -NoNewline
    $arUri = "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions?`$filter=$AccessReviewFilter"
    $arRes = Invoke-MgGraphRequest -Method GET -Uri $arUri
    $ars = $arRes.value
    if ($ars) {
        Write-Host " Found $($ars.Count). Deleting..." -ForegroundColor Yellow
        foreach ($ar in $ars) {
            try {
                Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions/$($ar.id)/stop"
                Start-Sleep -Seconds 1
                Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions/$($ar.id)"
                Write-Host "     - Deleted '$($ar.displayName)'" -ForegroundColor Gray
            } catch {
                Write-Host "     ❌ Failed to delete '$($ar.displayName)': $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Host " None found." -ForegroundColor Green
    }

    # 4. Entitlement Mgmt (Call Lab 05 script if exists)
    $lab05Script = "$PSScriptRoot\..\..\05-Entitlement-Management\scripts\Remove-EntitlementMgmt.ps1"
    if (Test-Path $lab05Script) {
        Write-Host "   Calling Lab 05 Cleanup..." -ForegroundColor Yellow
        & $lab05Script -UseParametersFile
    }

    # 5. Custom Roles
    Remove-Resource "Custom Roles" "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$filter=$CustomRoleFilter" "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions/{0}"

    # 6. Admin Units
    Remove-Resource "Admin Units" "https://graph.microsoft.com/v1.0/directory/administrativeUnits?`$filter=$AdminUnitFilter" "https://graph.microsoft.com/v1.0/directory/administrativeUnits/{0}"

    # 7. Service Principals
    Remove-Resource "Service Principals" "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=$ServicePrincipalFilter" "https://graph.microsoft.com/v1.0/servicePrincipals/{0}"

    # 8. Groups
    Remove-Resource "Groups" "https://graph.microsoft.com/v1.0/groups?`$filter=$GroupFilter" "https://graph.microsoft.com/v1.0/groups/{0}"

    # 9. Users
    Remove-Resource "Users" "https://graph.microsoft.com/v1.0/users?`$filter=$UserFilter" "https://graph.microsoft.com/v1.0/users/{0}"

    Write-Host "✅ Cleanup Complete." -ForegroundColor Green
}

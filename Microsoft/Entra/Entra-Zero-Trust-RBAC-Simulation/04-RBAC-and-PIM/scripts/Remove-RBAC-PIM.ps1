<#
.SYNOPSIS
    Removes resources created in Lab 04.

.EXAMPLE
    .\Remove-RBAC-PIM.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-28
    Last Modified: 2025-11-28
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Removes resources created in Lab 04.
# =============================================================================

[CmdletBinding()]
param(
    [switch]$Force,
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
            $CustomRoleName = $jsonParams."Remove-RBAC-PIM".roleName
            $PimGroupName = $jsonParams."Configure-PIM-Groups".groupName
            $PimRoleName = $jsonParams."Configure-PIM-Roles".roleName
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    if (-not $Force) {
        $confirm = Read-Host "⚠️  Are you sure you want to remove Custom Roles and PIM settings? (y/n)"
        if ($confirm -ne 'y') { return }
    }

    Write-Host "🚀 Removing RBAC and PIM Configurations..." -ForegroundColor Cyan

    # 1. Remove Custom Role
    $uri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$filter=displayName eq '$CustomRoleName'"
    $roleResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
    $role = $roleResponse.value | Select-Object -First 1
    
    if ($role) {
        $deleteUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions/$($role.id)"
        Invoke-MgGraphRequest -Method DELETE -Uri $deleteUri
        Write-Host "   ✅ Removed Custom Role '$CustomRoleName'" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Custom Role '$CustomRoleName' not found." -ForegroundColor Yellow
    }

    # 2. Remove PIM Group
    $groupUri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$PimGroupName'"
    $groupResponse = Invoke-MgGraphRequest -Method GET -Uri $groupUri
    $group = $groupResponse.value | Select-Object -First 1

    if ($group) {
        $deleteGroupUri = "https://graph.microsoft.com/v1.0/groups/$($group.id)"
        Invoke-MgGraphRequest -Method DELETE -Uri $deleteGroupUri
        Write-Host "   ✅ Removed PIM Group '$PimGroupName'" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  PIM Group '$PimGroupName' not found." -ForegroundColor Yellow
    }

    # 3. Remove Self-PIM Assignment (Global Admin)
    $currentContext = Get-MgContext
    if ($currentContext -and $currentContext.Account) {
        $currentUserUPN = $currentContext.Account
        
        # Get User ID
        $uUri = "https://graph.microsoft.com/v1.0/users?`$filter=userPrincipalName eq '$currentUserUPN'"
        $uResp = Invoke-MgGraphRequest -Method GET -Uri $uUri
        $uObj = $uResp.value | Select-Object -First 1

        # Get Role Definition ID
        $rUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$filter=displayName eq '$PimRoleName'"
        $rResp = Invoke-MgGraphRequest -Method GET -Uri $rUri
        $rDef = $rResp.value | Select-Object -First 1

        if ($uObj -and $rDef) {
            # Find Eligibility Schedule
            $eligUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilitySchedules?`$filter=principalId eq '$($uObj.id)' and roleDefinitionId eq '$($rDef.id)'"
            $eligResp = Invoke-MgGraphRequest -Method GET -Uri $eligUri
            $eligibility = $eligResp.value | Select-Object -First 1

            if ($eligibility) {
                # To remove, we need to revoke the schedule
                # Note: Revoking via API can be complex (requires roleAssignmentScheduleInstances or roleEligibilityScheduleRequests with 'AdminRemove')
                
                $revokeUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilityScheduleRequests"
                $body = @{
                    action = "adminRemove"
                    principalId = $uObj.id
                    roleDefinitionId = $rDef.id
                    directoryScopeId = "/"
                    justification = "Cleanup Lab 04"
                }
                
                try {
                    Invoke-MgGraphRequest -Method POST -Uri $revokeUri -Body $body
                    Write-Host "   ✅ Removed PIM Eligibility for '$PimRoleName' ($currentUserUPN)" -ForegroundColor Green
                } catch {
                    Write-Warning "   ⚠️  Failed to remove PIM Eligibility: $_"
                }
            } else {
                Write-Host "   ℹ️  No PIM Eligibility found for '$PimRoleName'." -ForegroundColor Yellow
            }
        }
    }

    # 4. Warnings about Non-Reversed Settings
    Write-Host "`n⚠️  IMPORTANT CLEANUP NOTES:" -ForegroundColor Yellow
    Write-Host "   1. PIM Policy Settings (MFA, Approval, Duration) for '$PimRoleName' were NOT reverted." -ForegroundColor Gray
    Write-Host "      - You must manually reset these in the Entra Portal if desired." -ForegroundColor Gray
    Write-Host "   2. Any permanent role assignments made outside this script remain." -ForegroundColor Gray
    
    Write-Host "✅ Cleanup Complete." -ForegroundColor Green
}

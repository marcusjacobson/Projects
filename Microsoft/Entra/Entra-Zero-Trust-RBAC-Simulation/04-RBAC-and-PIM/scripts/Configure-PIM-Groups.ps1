<#
.SYNOPSIS
    Configures PIM for Groups.

.DESCRIPTION
    Assigns 'Exchange Administrator' role to 'GRP-SEC-IT'.
    Demonstrates how to use a group for role assignment.
    Note: Configuring 'Eligible' membership for the group itself (PIM for Groups) 
    often requires Beta endpoints. This script sets up the foundation.

.EXAMPLE
    .\Configure-PIM-Groups.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 04-RBAC-and-PIM
#>

[CmdletBinding()]
param(
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
            
            $GroupName = $jsonParams."Configure-PIM-Groups".groupName
            $RoleName = $jsonParams."Configure-PIM-Groups".roleName
            $EligibleUser = $jsonParams."Configure-PIM-Groups".eligibleUser
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Configuring PIM for Groups..." -ForegroundColor Cyan

    # 1. Get Group
    $groupUri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$GroupName'"
    $groupResponse = Invoke-MgGraphRequest -Method GET -Uri $groupUri
    $group = $groupResponse.value | Select-Object -First 1
    
    if (-not $group) {
        Throw "Group '$GroupName' not found."
    }

    # 2. Get Role Definition (Template)
    $roleUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$filter=displayName eq '$RoleName'"
    $roleResponse = Invoke-MgGraphRequest -Method GET -Uri $roleUri
    $roleDef = $roleResponse.value | Select-Object -First 1
    
    if (-not $roleDef) {
        Throw "Role '$RoleName' not found."
    }

    # 3. Assign Role to Group (Active Assignment)
    try {
        $body = @{
            action = "adminAssign"
            justification = "PIM for Groups Setup"
            roleDefinitionId = $roleDef.id
            directoryScopeId = "/"
            principalId = $group.id
            scheduleInfo = @{
                startDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                expiration = @{
                    type = "NoExpiration"
                }
            }
            assignmentType = "Assigned" # Active
        }

        $null = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignmentScheduleRequests" -Body $body
        Write-Host "   ✅ Assigned '$RoleName' to '$GroupName' (Active)." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to assign role to group: $_"
    }

    # 4. Instructions for PIM for Groups (Member Eligibility)
    Write-Host "`nℹ️  PIM for Groups Configuration:" -ForegroundColor Cyan
    Write-Host "   The group '$GroupName' now has the '$RoleName' role."
    Write-Host "   To complete the setup (make users eligible to join the group):"
    Write-Host "   1. Go to Entra Admin Center > Identity Governance > PIM > Groups"
    Write-Host "   2. Select '$GroupName'"
    Write-Host "   3. Add '$EligibleUser' as an 'Eligible' member."
    Write-Host "   (This step requires P2 and is best done in the portal for this simulation)" -ForegroundColor Yellow
}

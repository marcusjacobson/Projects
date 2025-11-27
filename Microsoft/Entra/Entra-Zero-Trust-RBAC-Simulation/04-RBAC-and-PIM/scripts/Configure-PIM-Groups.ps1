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
            $Justification = $jsonParams."Configure-PIM-Groups".justification
            $EligibleAssignmentDurationYears = [int]$jsonParams."Configure-PIM-Groups".eligibleAssignmentDurationYears
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Configuring PIM for Groups..." -ForegroundColor Cyan

    # 1. Get or Create Group
    $groupUri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$GroupName'"
    $groupResponse = Invoke-MgGraphRequest -Method GET -Uri $groupUri
    $group = $groupResponse.value | Select-Object -First 1
    
    if (-not $group) {
        Write-Host "   ℹ️  Group '$GroupName' not found. Creating..." -ForegroundColor Cyan
        $groupBody = @{
            displayName = $GroupName
            mailEnabled = $false
            mailNickname = $GroupName -replace '\s+',''
            securityEnabled = $true
            isAssignableToRole = $true
            description = "PIM Managed Group for $RoleName"
        }
        $group = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups" -Body $groupBody
        Write-Host "   ✅ Created Role-Assignable Group '$GroupName'" -ForegroundColor Green
        Write-Host "   ⏳ Waiting 30 seconds for group replication..." -ForegroundColor Cyan
        Start-Sleep -Seconds 30
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
            justification = $Justification
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

    # 4. Configure PIM for Groups (Member Eligibility)
    Write-Host "`n🚀 Configuring PIM Member Eligibility for '$GroupName'..." -ForegroundColor Cyan
    
    # Get Eligible User
    $userUri = "https://graph.microsoft.com/v1.0/users?`$filter=startswith(userPrincipalName, '$EligibleUser')"
    $userResponse = Invoke-MgGraphRequest -Method GET -Uri $userUri
    $user = $userResponse.value | Select-Object -First 1
    
    if (-not $user) {
        Write-Error "User '$EligibleUser' not found."
    }
    else {
        try {
            $pimUri = "https://graph.microsoft.com/v1.0/identityGovernance/privilegedAccess/group/eligibilityScheduleRequests"
            
            $startDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            $endDateTime = (Get-Date).AddYears($EligibleAssignmentDurationYears).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

            $memberBody = @{
                accessId = "member"
                principalId = $user.id
                groupId = $group.id
                action = "AdminAssign"
                scheduleInfo = @{
                    startDateTime = $startDateTime
                    expiration = @{
                        type = "AfterDateTime"
                        endDateTime = $endDateTime
                    }
                }
                justification = $Justification
            }

            Invoke-MgGraphRequest -Method POST -Uri $pimUri -Body $memberBody
            Write-Host "   ✅ Assigned '$EligibleUser' as Eligible Member of '$GroupName'." -ForegroundColor Green
        }
        catch {
            $err = $_.Exception.Message
            if ($err -match "Role assignment already exists") {
                Write-Host "   ℹ️  User '$EligibleUser' is already an eligible member." -ForegroundColor Yellow
            }
            elseif ($err -match "Resource type not supported") {
                Write-Warning "   ⚠️  PIM is not enabled for group '$GroupName'. Please onboard the group in the portal."
            }
            else {
                Write-Error "Failed to assign eligible member: $err"
            }
        }
    }
}

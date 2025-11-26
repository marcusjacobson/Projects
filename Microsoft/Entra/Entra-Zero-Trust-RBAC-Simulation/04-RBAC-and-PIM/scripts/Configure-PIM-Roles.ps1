<#
.SYNOPSIS
    Configures PIM settings for the Global Administrator role.

.DESCRIPTION
    Updates the PIM policy for Global Admin to require:
    - MFA on activation
    - Justification
    - Approval by USR-CISO
    - Max duration of 4 hours

.EXAMPLE
    .\Configure-PIM-Roles.ps1

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
            
            $RoleName = $jsonParams."Configure-PIM-Roles".roleName
            $ApproverUser = $jsonParams."Configure-PIM-Roles".approverUser
            $MaxDuration = $jsonParams."Configure-PIM-Roles".maxDuration
            $RequireMfa = $jsonParams."Configure-PIM-Roles".requireMfa
            $RequireJustification = $jsonParams."Configure-PIM-Roles".requireJustification
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Configuring PIM for '$RoleName'..." -ForegroundColor Cyan

    # 1. Get Role Definition
    $roleUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$filter=displayName eq '$RoleName'"
    $roleResponse = Invoke-MgGraphRequest -Method GET -Uri $roleUri
    $roleDef = $roleResponse.value | Select-Object -First 1
    if (-not $roleDef) { Throw "Role '$RoleName' not found." }

    # 2. Get the PIM Policy for this Role
    # Filter by roleDefinitionId
    $policyUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleManagementPolicies?`$filter=scopeId eq '/' and scopeType eq 'Directory' and roleDefinitionId eq '$($roleDef.id)'"
    $policyResponse = Invoke-MgGraphRequest -Method GET -Uri $policyUri
    $targetPolicy = $policyResponse.value | Select-Object -First 1
    
    if (-not $targetPolicy) {
        Write-Warning "Could not find PIM policy for '$RoleName'. PIM might not be initialized."
        return
    }

    Write-Host "   Found Policy: $($targetPolicy.displayName)"

    # 3. Update Rules
    $rulesUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleManagementPolicies/$($targetPolicy.id)/rules"
    $rulesResponse = Invoke-MgGraphRequest -Method GET -Uri $rulesUri
    $rules = $rulesResponse.value
    
    foreach ($rule in $rules) {
        # A. Activation Rule (MFA, Justification)
        if ($rule.target.caller -eq "EndUser" -and $rule.target.operations -contains "All") {
            
            if ($rule."@odata.type" -eq "#microsoft.graph.unifiedRoleManagementPolicyEnablementRule") {
                # Update Enablement Rule
                $enabledRules = @()
                if ($RequireMfa) { $enabledRules += "MultiFactorAuthentication" }
                if ($RequireJustification) { $enabledRules += "Justification" }

                $body = @{
                    enabledRules = $enabledRules
                }
                
                Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleManagementPolicies/$($targetPolicy.id)/rules/$($rule.id)" -Body $body
                Write-Host "   ✅ Updated Activation Rule (MFA: $RequireMfa, Justification: $RequireJustification)." -ForegroundColor Green
            }
            
            if ($rule."@odata.type" -eq "#microsoft.graph.unifiedRoleManagementPolicyExpirationRule") {
                # Update Expiration (Max Duration)
                $body = @{
                    maximumDuration = $MaxDuration
                }
                Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleManagementPolicies/$($targetPolicy.id)/rules/$($rule.id)" -Body $body
                Write-Host "   ✅ Updated Expiration Rule ($MaxDuration)." -ForegroundColor Green
            }
            
            if ($rule."@odata.type" -eq "#microsoft.graph.unifiedRoleManagementPolicyApprovalRule") {
                # Update Approval (Add Approver)
                # Find Approver User
                $userUri = "https://graph.microsoft.com/v1.0/users?`$filter=userPrincipalName startswith '$ApproverUser'"
                $userResponse = Invoke-MgGraphRequest -Method GET -Uri $userUri
                $approver = $userResponse.value | Select-Object -First 1
                
                if ($approver) {
                    $setting = @{
                        isApprovalRequired = $true
                        isEntityGroup = $false
                        steps = @(
                            @{
                                assignedToMe = $true
                                primaryApprovers = @(
                                    @{
                                        id = $approver.id
                                        "@odata.type" = "#microsoft.graph.directoryObject"
                                    }
                                )
                            }
                        )
                    }
                    
                    $body = @{ setting = $setting }
                    
                    try {
                        Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleManagementPolicies/$($targetPolicy.id)/rules/$($rule.id)" -Body $body
                        Write-Host "   ✅ Updated Approval Rule (Approver: $ApproverUser)." -ForegroundColor Green
                    }
                    catch {
                        Write-Warning "Failed to update Approval Rule: $_"
                    }
                } else {
                    Write-Warning "Approver user '$ApproverUser' not found."
                }
            }
        }
    }
    
    Write-Host "✅ PIM Configuration Complete." -ForegroundColor Green
}

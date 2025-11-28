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
# Configures PIM settings for the Global Administrator role.
# =============================================================================

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
    # Note: We use the 'policies/roleManagementPolicyAssignments' endpoint to find the policy ID.
    
    $assignmentUri = "https://graph.microsoft.com/v1.0/policies/roleManagementPolicyAssignments?`$filter=roleDefinitionId eq '$($roleDef.id)' and scopeId eq '/' and scopeType eq 'Directory'"
    
    try {
        $assignmentResponse = Invoke-MgGraphRequest -Method GET -Uri $assignmentUri -ErrorAction Stop
        $assignment = $assignmentResponse.value | Select-Object -First 1
        
        if ($assignment) {
            $policyId = $assignment.policyId
            # Fetch the policy object for display name (optional but good for verification)
            $policyUri = "https://graph.microsoft.com/v1.0/policies/roleManagementPolicies/$policyId"
            $policyResponse = Invoke-MgGraphRequest -Method GET -Uri $policyUri
            $targetPolicy = $policyResponse
        } else {
            $targetPolicy = $null
        }
    }
    catch {
        Write-Warning "   ⚠️  Unable to access PIM Policies via API: $_"
        Write-Warning "   ℹ️  Skipping Policy Configuration (MFA/Approval). Please configure manually in PIM."
        $targetPolicy = $null
    }
    
    if ($targetPolicy) {
        Write-Host "   Found Policy: $($targetPolicy.displayName)"

        # 3. Update Rules
        $rulesUri = "https://graph.microsoft.com/v1.0/policies/roleManagementPolicies/$($targetPolicy.id)/rules"
        $rulesResponse = Invoke-MgGraphRequest -Method GET -Uri $rulesUri
        $rules = $rulesResponse.value
        
        foreach ($rule in $rules) {
            # ...existing code...
            # (Keep existing rule update logic)
            # ...existing code...
            if ($rule.target.caller -eq "EndUser" -and $rule.target.operations -contains "All") {
                
                if ($rule."@odata.type" -eq "#microsoft.graph.unifiedRoleManagementPolicyEnablementRule") {
                    # Update Enablement Rule
                    $enabledRules = @()
                    if ($RequireMfa) { $enabledRules += "MultiFactorAuthentication" }
                    if ($RequireJustification) { $enabledRules += "Justification" }

                    $body = @{
                        "@odata.type" = "#microsoft.graph.unifiedRoleManagementPolicyEnablementRule"
                        enabledRules = $enabledRules
                    }
                    
                    Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/roleManagementPolicies/$($targetPolicy.id)/rules/$($rule.id)" -Body $body
                    Write-Host "   ✅ Updated Activation Rule (MFA: $RequireMfa, Justification: $RequireJustification)." -ForegroundColor Green
                }
                
                if ($rule."@odata.type" -eq "#microsoft.graph.unifiedRoleManagementPolicyExpirationRule") {
                    # Update Expiration (Max Duration)
                    $body = @{
                        "@odata.type" = "#microsoft.graph.unifiedRoleManagementPolicyExpirationRule"
                        maximumDuration = $MaxDuration
                        isExpirationRequired = $true
                    }
                    Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/roleManagementPolicies/$($targetPolicy.id)/rules/$($rule.id)" -Body $body
                    Write-Host "   ✅ Updated Expiration Rule ($MaxDuration)." -ForegroundColor Green
                }
                
                if ($rule."@odata.type" -eq "#microsoft.graph.unifiedRoleManagementPolicyApprovalRule") {
                    # Update Approval (Add Approver)
                    # Find Approver User
                    $userUri = "https://graph.microsoft.com/v1.0/users?`$filter=startswith(userPrincipalName, '$ApproverUser')"
                    $userResponse = Invoke-MgGraphRequest -Method GET -Uri $userUri
                    $approver = $userResponse.value | Select-Object -First 1
                    
                    if ($approver) {
                        $setting = @{
                            isApprovalRequired = $true
                            approvalMode = "SingleStage"
                            isRequestorJustificationRequired = $true
                            isApprovalRequiredForExtension = $false
                            approvalStages = @(
                                @{
                                    approvalStageTimeOutInDays = 1
                                    isApproverJustificationRequired = $true
                                    isEscalationEnabled = $false
                                    escalationTimeInMinutes = 0
                                    escalationApprovers = @()
                                    primaryApprovers = @(
                                        @{
                                            "@odata.type" = "#microsoft.graph.singleUser"
                                            userId = $approver.id
                                            description = "CISO Approval"
                                        }
                                    )
                                }
                            )
                        }
                        
                        $body = @{ 
                            "@odata.type" = "#microsoft.graph.unifiedRoleManagementPolicyApprovalRule"
                            setting = $setting 
                        }
                        
                        # Debug: Print JSON
                        # $body | ConvertTo-Json -Depth 10 | Write-Host

                        try {
                            Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/roleManagementPolicies/$($targetPolicy.id)/rules/$($rule.id)" -Body $body
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
    }
    
    # 4. Ensure Current User is Eligible (Self-PIM)
    $currentContext = Get-MgContext
    if ($currentContext -and $currentContext.Account) {
        $currentUserUPN = $currentContext.Account
        Write-Host "`n🚀 Checking PIM eligibility for current user ($currentUserUPN)..." -ForegroundColor Cyan
        
        # Get User Object
        $uUri = "https://graph.microsoft.com/v1.0/users?`$filter=userPrincipalName eq '$currentUserUPN'"
        $uResp = Invoke-MgGraphRequest -Method GET -Uri $uUri
        $uObj = $uResp.value | Select-Object -First 1
        
        if ($uObj) {
            # Check if already Eligible
            $eligUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilitySchedules?`$filter=principalId eq '$($uObj.id)' and roleDefinitionId eq '$($roleDef.id)'"
            $eligResp = Invoke-MgGraphRequest -Method GET -Uri $eligUri
            $isEligible = $eligResp.value | Select-Object -First 1
            
            if (-not $isEligible) {
                Write-Host "   ℹ️  Current user is not eligible for '$RoleName'. Creating assignment..." -ForegroundColor Cyan
                
                $scheduleUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilityScheduleRequests"
                $body = @{
                    action = "adminAssign"
                    justification = "Self-PIM Assignment for Lab"
                    roleDefinitionId = $roleDef.id
                    directoryScopeId = "/"
                    principalId = $uObj.id
                    scheduleInfo = @{
                        startDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                        expiration = @{
                            type = "AfterDateTime"
                            endDateTime = (Get-Date).AddYears(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                        }
                    }
                }
                
                try {
                    $null = Invoke-MgGraphRequest -Method POST -Uri $scheduleUri -Body $body
                    Write-Host "   ✅ Assigned '$RoleName' eligibility to $currentUserUPN." -ForegroundColor Green
                    Write-Host "   ⚠️  IMPORTANT: You likely still have a PERMANENT assignment." -ForegroundColor Yellow
                    Write-Host "   ⚠️  To test PIM, you must manually remove your permanent assignment in the portal." -ForegroundColor Yellow
                } catch {
                    Write-Error "Failed to assign eligibility: $_"
                }
            } else {
                Write-Host "   ✅ User '$currentUserUPN' is already eligible for '$RoleName'." -ForegroundColor Green
            }
        }
    }

    Write-Host "✅ PIM Configuration Complete." -ForegroundColor Green
}

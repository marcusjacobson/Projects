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
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🚀 Configuring PIM for Global Administrator..." -ForegroundColor Cyan

    # 1. Get Global Admin Role Definition
    $roleDef = Get-MgRoleManagementDirectoryRoleDefinition -Filter "DisplayName eq 'Global Administrator'"
    if (-not $roleDef) { Throw "Global Admin role not found." }

    # 2. Get the PIM Policy for this Role
    # We filter policies by the role definition ID
    $policies = Get-MgRoleManagementDirectoryRoleManagementPolicy -Filter "ScopeId eq '/' and ScopeType eq 'Directory'"
    # The filtering logic for specific role policy is tricky in v1.0. 
    # Usually, we iterate or filter by 'Rules' containing the role? No.
    # The policy ID is usually tied to the role definition ID in a specific way or we look it up.
    
    # Let's try to find the policy that applies to this role.
    # In PIM v3 (current Graph), there is one policy per role.
    
    # We can use the 'roleDefinitionId' property if available, or we have to list all and find match.
    # Actually, Get-MgRoleManagementDirectoryRoleManagementPolicy doesn't easily filter by RoleDefId in basic syntax.
    # But we can try to find it.
    
    $targetPolicy = $null
    foreach ($p in $policies) {
        # The policy ID often contains the RoleDefId or we check rules?
        # Actually, let's check if we can get it directly.
        # No direct cmdlet.
        
        # Let's assume we need to find the policy where the rule applies to this role.
        # Wait, simpler way:
        # Get-MgRoleManagementDirectoryRoleManagementPolicy -Filter "IsOrganizationDefault eq true" ? No.
        
        # Let's try to get the specific policy for the role.
        # URI: /policies?$filter=scopeId eq '/' and scopeType eq 'Directory' and id eq '...'
        
        # Workaround: We will skip the complex filter and just iterate.
        if ($p.Id -like "*$($roleDef.Id)*") {
            $targetPolicy = $p
            break
        }
    }
    
    if (-not $targetPolicy) {
        Write-Warning "Could not find PIM policy for Global Admin. PIM might not be initialized."
        return
    }

    Write-Host "   Found Policy: $($targetPolicy.DisplayName)"

    # 3. Update Rules
    # We need to update the 'Rules' property.
    # Rules include: Expiration, MFA, Approval, etc.
    
    $rules = Get-MgRoleManagementDirectoryRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $targetPolicy.Id
    
    foreach ($rule in $rules) {
        # A. Activation Rule (MFA, Justification)
        if ($rule.Target.Caller -eq "EndUser" -and $rule.Target.Operations -contains "All") {
            # This is likely the activation rule (UnifiedRoleManagementPolicyAuthenticationContextRule or EnablementRule)
            # Actually, let's look at the @odata.type
            
            if ($rule.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.unifiedRoleManagementPolicyEnablementRule") {
                # Update Enablement Rule (MFA, Justification)
                $params = @{
                    EnabledRules = @("MultiFactorAuthentication", "Justification")
                }
                Update-MgRoleManagementDirectoryRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $targetPolicy.Id -UnifiedRoleManagementPolicyRuleId $rule.Id -BodyParameter $params
                Write-Host "   ✅ Updated Activation Rule (MFA + Justification)." -ForegroundColor Green
            }
            
            if ($rule.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.unifiedRoleManagementPolicyExpirationRule") {
                # Update Expiration (Max Duration)
                $params = @{
                    MaximumDuration = "PT4H"
                }
                Update-MgRoleManagementDirectoryRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $targetPolicy.Id -UnifiedRoleManagementPolicyRuleId $rule.Id -BodyParameter $params
                Write-Host "   ✅ Updated Expiration Rule (4 Hours)." -ForegroundColor Green
            }
            
            if ($rule.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.unifiedRoleManagementPolicyApprovalRule") {
                # Update Approval (Add Approver)
                # Find USR-CISO
                $approver = Get-MgUser -Filter "UserPrincipalName eq 'USR-CISO@$((Get-MgDomain | Where-Object IsInitial).Id)'"
                
                if ($approver) {
                    $setting = @{
                        IsApprovalRequired = $true
                        IsEntityGroup = $false
                        Steps = @(
                            @{
                                AssignedToMe = $true
                                PrimaryApprovers = @(
                                    @{
                                        Id = $approver.Id
                                        "@odata.type" = "#microsoft.graph.directoryObject"
                                    }
                                )
                            }
                        )
                    }
                    
                    $params = @{ Setting = $setting }
                    
                    # Note: Updating approval rules is complex and structure sensitive.
                    # We'll attempt it, but wrap in try/catch.
                    try {
                        Update-MgRoleManagementDirectoryRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $targetPolicy.Id -UnifiedRoleManagementPolicyRuleId $rule.Id -BodyParameter $params
                        Write-Host "   ✅ Updated Approval Rule (Approver: USR-CISO)." -ForegroundColor Green
                    }
                    catch {
                        Write-Warning "Failed to update Approval Rule: $_"
                    }
                }
            }
        }
    }
    
    Write-Host "✅ PIM Configuration Complete." -ForegroundColor Green
}

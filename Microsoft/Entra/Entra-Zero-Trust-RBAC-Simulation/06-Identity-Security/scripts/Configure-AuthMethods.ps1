<#
.SYNOPSIS
    Configures Authentication Methods.

.DESCRIPTION
    Enables FIDO2 Security Keys and Microsoft Authenticator for all users.
    Sets the state to 'Enabled'.

.EXAMPLE
    .\Configure-AuthMethods.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 06-Identity-Security
#>

[CmdletBinding()]
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🚀 Configuring Authentication Methods..." -ForegroundColor Cyan

    # 1. Enable FIDO2
    Write-Host "   Configuring FIDO2..." -ForegroundColor Gray
    try {
        $fidoParams = @{
            State = "enabled"
            ExcludeTargets = @()
            IncludeTargets = @(
                @{
                    TargetType = "group"
                    Id = "all_users" # Virtual group 'all_users' often works in policy, or we need a real group.
                    # Actually, for Auth Methods, we usually target a specific group or 'all_users' isn't a valid GUID.
                    # We should use 'All Users' target type if available, or a specific group.
                    # Let's use the 'All Users' dynamic group if we have one, or just a static group 'GRP-SEC-AllUsers' created in Lab 01?
                    # Lab 01 created 'GRP-SEC-AllUsers' (Dynamic). Let's use that.
                }
            )
        }
        
        # Fetch GRP-SEC-AllUsers
        $allUsersGroup = Get-MgGroup -Filter "DisplayName eq 'GRP-SEC-AllUsers'" -ErrorAction SilentlyContinue
        if ($allUsersGroup) {
            $target = @{
                TargetType = "group"
                Id = $allUsersGroup.Id
                IsRegistrationRequired = $false
                KeyRestrictions = $null
            }
            
            # Update FIDO2 Policy
            # Note: Graph API for Auth Methods is specific.
            # PATCH /policies/authenticationMethodsPolicy/authenticationMethodConfigurations/fido2
            
            $params = @{
                State = "enabled"
                IncludeTargets = @($target)
            }
            
            Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId "fido2" -BodyParameter $params
            Write-Host "   ✅ Enabled FIDO2 for 'GRP-SEC-AllUsers'" -ForegroundColor Green
        } else {
            Write-Warning "   ⚠️ 'GRP-SEC-AllUsers' not found. Skipping FIDO2 config."
        }
    }
    catch {
        Write-Warning "   ⚠️ Failed to configure FIDO2: $_"
    }

    # 2. Enable Microsoft Authenticator
    Write-Host "   Configuring Microsoft Authenticator..." -ForegroundColor Gray
    try {
        if ($allUsersGroup) {
            $target = @{
                TargetType = "group"
                Id = $allUsersGroup.Id
                AuthenticationMode = "any" # Push, Passwordless, etc.
            }
            
            $params = @{
                State = "enabled"
                IncludeTargets = @($target)
            }
            
            Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId "microsoftAuthenticator" -BodyParameter $params
            Write-Host "   ✅ Enabled Microsoft Authenticator for 'GRP-SEC-AllUsers'" -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "   ⚠️ Failed to configure Microsoft Authenticator: $_"
    }
}

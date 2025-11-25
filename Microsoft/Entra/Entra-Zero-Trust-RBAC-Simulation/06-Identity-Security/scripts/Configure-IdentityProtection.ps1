<#
.SYNOPSIS
    Configures Identity Protection via Conditional Access.

.DESCRIPTION
    Creates CA policies for User Risk and Sign-in Risk.
    - CA-03-Block-HighUserRisk
    - CA-04-MFA-MediumSigninRisk
    Sets state to 'ReportOnly'.

.EXAMPLE
    .\Configure-IdentityProtection.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 06-Identity-Security
#>

[CmdletBinding()]
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🚀 Configuring Identity Protection Policies..." -ForegroundColor Cyan

    $bgUser = Get-MgUser -Filter "startsWith(UserPrincipalName, 'breakglass')" -ErrorAction SilentlyContinue
    $excludeUsers = if ($bgUser) { @($bgUser.Id) } else { @() }

    # Policy 3: Block High User Risk
    $polName3 = "CA-03-Block-HighUserRisk"
    $pol3 = Get-MgIdentityConditionalAccessPolicy -Filter "DisplayName eq '$polName3'" -ErrorAction SilentlyContinue
    
    if (-not $pol3) {
        $conditions3 = @{
            Applications = @{ IncludeApplications = @("All") }
            Users = @{
                IncludeUsers = @("All")
                ExcludeUsers = $excludeUsers
            }
            UserRiskLevels = @("high")
        }
        
        $grant3 = @{
            BuiltInControls = @("block")
            Operator = "OR"
        }

        New-MgIdentityConditionalAccessPolicy -DisplayName $polName3 `
            -State "ReportOnly" `
            -Conditions $conditions3 `
            -GrantControls $grant3
            
        Write-Host "   ✅ Created Policy '$polName3' (Report-Only)" -ForegroundColor Green
    }

    # Policy 4: MFA for Medium+ Sign-in Risk
    $polName4 = "CA-04-MFA-MediumSigninRisk"
    $pol4 = Get-MgIdentityConditionalAccessPolicy -Filter "DisplayName eq '$polName4'" -ErrorAction SilentlyContinue
    
    if (-not $pol4) {
        $conditions4 = @{
            Applications = @{ IncludeApplications = @("All") }
            Users = @{
                IncludeUsers = @("All")
                ExcludeUsers = $excludeUsers
            }
            SignInRiskLevels = @("medium", "high")
        }
        
        $grant4 = @{
            BuiltInControls = @("mfa")
            Operator = "OR"
        }

        New-MgIdentityConditionalAccessPolicy -DisplayName $polName4 `
            -State "ReportOnly" `
            -Conditions $conditions4 `
            -GrantControls $grant4
            
        Write-Host "   ✅ Created Policy '$polName4' (Report-Only)" -ForegroundColor Green
    }
}

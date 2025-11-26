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
            
            $PolicyNameHighRisk = $jsonParams."Configure-IdentityProtection".policyNameHighRisk
            $PolicyNameMediumRisk = $jsonParams."Configure-IdentityProtection".policyNameMediumRisk
            $BreakGlassPrefix = $jsonParams."Configure-IdentityProtection".breakGlassPrefix
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Configuring Identity Protection Policies..." -ForegroundColor Cyan

    # Get Break Glass Account to exclude
    $bgUri = "https://graph.microsoft.com/v1.0/users?`$filter=startsWith(userPrincipalName, '$BreakGlassPrefix')"
    $bgResponse = Invoke-MgGraphRequest -Method GET -Uri $bgUri
    $bgUser = $bgResponse.value | Select-Object -First 1
    $excludeUsers = if ($bgUser) { @($bgUser.id) } else { @() }

    # Policy 3: Block High User Risk
    $pol3Uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$PolicyNameHighRisk'"
    $pol3Response = Invoke-MgGraphRequest -Method GET -Uri $pol3Uri
    $pol3 = $pol3Response.value | Select-Object -First 1
    
    if (-not $pol3) {
        $conditions3 = @{
            applications = @{ includeApplications = @("All") }
            users = @{
                includeUsers = @("All")
                excludeUsers = $excludeUsers
            }
            userRiskLevels = @("high")
        }
        
        $grant3 = @{
            builtInControls = @("block")
            operator = "OR"
        }

        $body = @{
            displayName = $PolicyNameHighRisk
            state = "ReportOnly"
            conditions = $conditions3
            grantControls = $grant3
        }

        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $body
        Write-Host "   ✅ Created Policy '$PolicyNameHighRisk' (Report-Only)" -ForegroundColor Green
    }

    # Policy 4: MFA for Medium+ Sign-in Risk
    $pol4Uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$PolicyNameMediumRisk'"
    $pol4Response = Invoke-MgGraphRequest -Method GET -Uri $pol4Uri
    $pol4 = $pol4Response.value | Select-Object -First 1
    
    if (-not $pol4) {
        $conditions4 = @{
            applications = @{ includeApplications = @("All") }
            users = @{
                includeUsers = @("All")
                excludeUsers = $excludeUsers
            }
            signInRiskLevels = @("medium", "high")
        }
        
        $grant4 = @{
            builtInControls = @("mfa")
            operator = "OR"
        }

        $body = @{
            displayName = $PolicyNameMediumRisk
            state = "ReportOnly"
            conditions = $conditions4
            grantControls = $grant4
        }

        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $body
        Write-Host "   ✅ Created Policy '$PolicyNameMediumRisk' (Report-Only)" -ForegroundColor Green
    }
}

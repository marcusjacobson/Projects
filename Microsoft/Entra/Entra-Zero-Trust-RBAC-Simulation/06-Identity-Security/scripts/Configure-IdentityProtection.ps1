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
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-08-04
    Last Modified: 2025-08-04
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    
    Script development orchestrated using GitHub Copilot.

.SPECIALIZED_SECTION
    IDENTITY PROTECTION
    - User risk policies
    - Sign-in risk policies
    - Risk-based remediation
#>
#
# =============================================================================
# Step 3: Configure Identity Protection
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🔸 Step 3: Configure Identity Protection" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green

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

    # Get Break Glass Accounts to exclude
    $bgUri = "https://graph.microsoft.com/v1.0/users?`$filter=startsWith(userPrincipalName, '$BreakGlassPrefix')"
    $bgResponse = Invoke-MgGraphRequest -Method GET -Uri $bgUri
    $bgUsers = $bgResponse.value
    $excludeUsers = if ($bgUsers) { @($bgUsers.id) } else { @() }

    # Policy 3: Block High User Risk
    try {
        $pol3Uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$PolicyNameHighRisk'"
        $pol3Response = Invoke-MgGraphRequest -Method GET -Uri $pol3Uri
        $pol3 = $pol3Response.value | Select-Object -First 1
        
        if (-not $pol3) {
            $conditions3 = @{
                applications = @{ 
                    includeApplications = @("All")
                    excludeApplications = @()
                }
                users = @{
                    includeUsers = @("All")
                    excludeUsers = @($excludeUsers)
                    includeGroups = @()
                    excludeGroups = @()
                }
                userRiskLevels = @("high")
            }
            
            $grant3 = @{
                builtInControls = @("block")
                operator = "OR"
            }

            $body = @{
                displayName = $PolicyNameHighRisk
                state = "enabledForReportingButNotEnforced"
                conditions = $conditions3
                grantControls = $grant3
            }

            $jsonBody = $body | ConvertTo-Json -Depth 10
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $jsonBody -ContentType "application/json"
            Write-Host "   ✅ Created Policy '$PolicyNameHighRisk' (Report-Only)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Policy '$PolicyNameHighRisk' already exists. Skipping." -ForegroundColor Yellow
        }
    } catch {
        Write-Error "   ❌ Failed to create Policy '$PolicyNameHighRisk': $_"
    }

    # Policy 4: MFA for Medium+ Sign-in Risk
    try {
        $pol4Uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$PolicyNameMediumRisk'"
        $pol4Response = Invoke-MgGraphRequest -Method GET -Uri $pol4Uri
        $pol4 = $pol4Response.value | Select-Object -First 1
        
        if (-not $pol4) {
            $conditions4 = @{
                applications = @{ 
                    includeApplications = @("All")
                    excludeApplications = @()
                }
                users = @{
                    includeUsers = @("All")
                    excludeUsers = @($excludeUsers)
                    includeGroups = @()
                    excludeGroups = @()
                }
                signInRiskLevels = @("medium", "high")
            }
            
            $grant4 = @{
                builtInControls = @("mfa")
                operator = "OR"
            }

            $body = @{
                displayName = $PolicyNameMediumRisk
                state = "enabledForReportingButNotEnforced"
                conditions = $conditions4
                grantControls = $grant4
            }

            $jsonBody = $body | ConvertTo-Json -Depth 10
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $jsonBody -ContentType "application/json"
            Write-Host "   ✅ Created Policy '$PolicyNameMediumRisk' (Report-Only)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Policy '$PolicyNameMediumRisk' already exists. Skipping." -ForegroundColor Yellow
        }
    } catch {
        Write-Error "   ❌ Failed to create Policy '$PolicyNameMediumRisk': $_"
    }
}

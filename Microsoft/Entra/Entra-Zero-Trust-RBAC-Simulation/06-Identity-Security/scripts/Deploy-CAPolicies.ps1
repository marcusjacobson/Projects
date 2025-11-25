<#
.SYNOPSIS
    Deploys Conditional Access Policies in Report-Only mode.

.DESCRIPTION
    Creates 'CA-01-RequireMFA-Admins' and 'CA-02-BlockLegacyAuth'.
    Excludes Break Glass accounts.
    Sets state to 'ReportOnly'.

.EXAMPLE
    .\Deploy-CAPolicies.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-24
    Last Modified: 2025-11-24
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    - Entra ID P2 License (for Report-Only)
    
    Script development orchestrated using GitHub Copilot.

.SPECIALIZED_SECTION
    ZERO TRUST POLICIES
    - CA-01: Require MFA for Admins (Report-Only)
    - CA-02: Block Legacy Authentication (Report-Only)
    - Safety: Break Glass Account Exclusion
#>

[CmdletBinding()]
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🚀 Deploying Conditional Access Policies..." -ForegroundColor Cyan

    # Get Break Glass Account to exclude
    $bgUri = "https://graph.microsoft.com/v1.0/users?`$filter=startsWith(userPrincipalName, 'breakglass')"
    $bgResponse = Invoke-MgGraphRequest -Method GET -Uri $bgUri
    $bgUser = $bgResponse.value | Select-Object -First 1
    
    $excludeUsers = if ($bgUser) { @($bgUser.id) } else { @() }
    
    if ($excludeUsers.Count -eq 0) {
        Write-Warning "⚠️ No Break Glass account found! Policies will be created without exclusion (Risky!)."
    } else {
        Write-Host "   ℹ️ Excluding Break Glass Account: $($bgUser.userPrincipalName)" -ForegroundColor Gray
    }

    # Policy 1: Require MFA for Admins
    $polName1 = "CA-01-RequireMFA-Admins"
    $pol1Uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$polName1'"
    $pol1Response = Invoke-MgGraphRequest -Method GET -Uri $pol1Uri
    $pol1 = $pol1Response.value | Select-Object -First 1
    
    if (-not $pol1) {
        $conditions1 = @{
            applications = @{ includeApplications = @("All") }
            users = @{
                includeRoles = @("62e90394-69f5-4237-9190-012177145e10") # Global Admin Template ID
                excludeUsers = $excludeUsers
            }
            clientAppTypes = @("all")
        }
        
        $grant1 = @{
            builtInControls = @("mfa")
            operator = "OR"
        }

        $body = @{
            displayName = $polName1
            state = "ReportOnly"
            conditions = $conditions1
            grantControls = $grant1
        }

        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $body
        Write-Host "   ✅ Created Policy '$polName1' (Report-Only)" -ForegroundColor Green
    }

    # Policy 2: Block Legacy Auth
    $polName2 = "CA-02-BlockLegacyAuth"
    $pol2Uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$polName2'"
    $pol2Response = Invoke-MgGraphRequest -Method GET -Uri $pol2Uri
    $pol2 = $pol2Response.value | Select-Object -First 1
    
    if (-not $pol2) {
        $conditions2 = @{
            applications = @{ includeApplications = @("All") }
            users = @{
                includeUsers = @("All")
                excludeUsers = $excludeUsers
            }
            clientAppTypes = @("exchangeActiveSync", "other")
        }
        
        $grant2 = @{
            builtInControls = @("block")
            operator = "OR"
        }

        $body = @{
            displayName = $polName2
            state = "ReportOnly"
            conditions = $conditions2
            grantControls = $grant2
        }

        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $body
        Write-Host "   ✅ Created Policy '$polName2' (Report-Only)" -ForegroundColor Green
    }
}

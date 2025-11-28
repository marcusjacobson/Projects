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
#
# =============================================================================
# Step 1: Deploy Conditional Access Policies
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🔸 Step 1: Deploy Conditional Access Policies" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green

    # Load Parameters
    $paramsPath = Join-Path $PSScriptRoot "..\infra\module.parameters.json"
    if ($UseParametersFile -or (Test-Path $paramsPath)) {
        if (Test-Path $paramsPath) {
            Write-Host "📂 Loading parameters from $paramsPath..." -ForegroundColor Cyan
            $jsonParams = Get-Content $paramsPath | ConvertFrom-Json
            
            $PolicyNameMfaAdmins = $jsonParams."Deploy-CAPolicies".policyNameMfaAdmins
            $PolicyNameBlockLegacy = $jsonParams."Deploy-CAPolicies".policyNameBlockLegacy
            $BreakGlassPrefix = $jsonParams."Deploy-CAPolicies".breakGlassPrefix
            $GlobalAdminRoleId = $jsonParams."Deploy-CAPolicies".globalAdminRoleId
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Deploying Conditional Access Policies..." -ForegroundColor Cyan

    # Get Break Glass Accounts to exclude
    $bgUri = "https://graph.microsoft.com/v1.0/users?`$filter=startsWith(userPrincipalName, '$BreakGlassPrefix')"
    $bgResponse = Invoke-MgGraphRequest -Method GET -Uri $bgUri
    $bgUsers = $bgResponse.value
    
    $excludeUsers = if ($bgUsers) { @($bgUsers.id) } else { @() }
    
    if ($excludeUsers.Count -eq 0) {
        Write-Warning "⚠️ No Break Glass accounts found! Policies will be created without exclusion (Risky!)."
    } else {
        Write-Host "   ℹ️ Excluding Break Glass Accounts: $($bgUsers.userPrincipalName -join ', ')" -ForegroundColor Gray
    }

    # Policy 1: Require MFA for Admins
    try {
        $pol1Uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$PolicyNameMfaAdmins'"
        $pol1Response = Invoke-MgGraphRequest -Method GET -Uri $pol1Uri
        $pol1 = $pol1Response.value | Select-Object -First 1
        
        if (-not $pol1) {
            $conditions1 = @{
                applications = @{ 
                    includeApplications = @("All")
                    excludeApplications = @()
                }
                users = @{
                    includeRoles = @($GlobalAdminRoleId)
                    excludeUsers = @($excludeUsers)
                    includeUsers = @()
                    includeGroups = @()
                    excludeGroups = @()
                }
                clientAppTypes = @("all")
            }
            
            $grant1 = @{
                builtInControls = @("mfa")
                operator = "OR"
            }

            $body = @{
                displayName = $PolicyNameMfaAdmins
                state = "enabledForReportingButNotEnforced"
                conditions = $conditions1
                grantControls = $grant1
            }

            $jsonBody = $body | ConvertTo-Json -Depth 10
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $jsonBody -ContentType "application/json"
            Write-Host "   ✅ Created Policy '$PolicyNameMfaAdmins' (Report-Only)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Policy '$PolicyNameMfaAdmins' already exists. Skipping." -ForegroundColor Yellow
        }
    } catch {
        Write-Error "   ❌ Failed to create Policy '$PolicyNameMfaAdmins': $_"
    }

    # Policy 2: Block Legacy Auth
    try {
        $pol2Uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$PolicyNameBlockLegacy'"
        $pol2Response = Invoke-MgGraphRequest -Method GET -Uri $pol2Uri
        $pol2 = $pol2Response.value | Select-Object -First 1
        
        if (-not $pol2) {
            $conditions2 = @{
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
                clientAppTypes = @("exchangeActiveSync", "other")
            }
            
            $grant2 = @{
                builtInControls = @("block")
                operator = "OR"
            }

            $body = @{
                displayName = $PolicyNameBlockLegacy
                state = "enabledForReportingButNotEnforced"
                conditions = $conditions2
                grantControls = $grant2
            }

            $jsonBody = $body | ConvertTo-Json -Depth 10
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $jsonBody -ContentType "application/json"
            Write-Host "   ✅ Created Policy '$PolicyNameBlockLegacy' (Report-Only)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Policy '$PolicyNameBlockLegacy' already exists. Skipping." -ForegroundColor Yellow
        }
    } catch {
        Write-Error "   ❌ Failed to create Policy '$PolicyNameBlockLegacy': $_"
    }
}

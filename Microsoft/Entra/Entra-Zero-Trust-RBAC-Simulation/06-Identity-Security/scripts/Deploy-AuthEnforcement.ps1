<#
.SYNOPSIS
    Deploys Conditional Access Policies to enforce specific Authentication Methods.

.DESCRIPTION
    Creates 'CA-05-Enforce-Authenticator-AllUsers' and 'CA-06-Enforce-FIDO2-Privileged'.
    Uses Authentication Strengths to enforce specific methods.
    Excludes Break Glass accounts.
    Sets state to 'ReportOnly'.

.EXAMPLE
    .\Deploy-AuthEnforcement.ps1

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
            
            $PolicyNameAuthenticator = $jsonParams."Deploy-AuthEnforcement".policyNameEnforceAuthenticator
            $PolicyNameFido2 = $jsonParams."Deploy-AuthEnforcement".policyNameEnforceFido2
            $BreakGlassPrefix = $jsonParams."Deploy-AuthEnforcement".breakGlassPrefix
            $GlobalAdminRoleId = $jsonParams."Deploy-AuthEnforcement".globalAdminRoleId
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Deploying Authentication Enforcement Policies..." -ForegroundColor Cyan

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

    # Get Authentication Strengths
    $strengthsUri = "https://graph.microsoft.com/v1.0/policies/authenticationStrengthPolicies"
    $strengthsResponse = Invoke-MgGraphRequest -Method GET -Uri $strengthsUri
    $strengths = $strengthsResponse.value

    # Find "Phishing Resistant MFA" (for FIDO2)
    $phishingResistant = $strengths | Where-Object { $_.displayName -eq "Phishing-resistant MFA" }
    if (-not $phishingResistant) { Throw "Could not find 'Phishing-resistant MFA' strength." }
    $phishingResistantId = $phishingResistant.id

    # Find "Multifactor authentication" (for Authenticator - standard MFA)
    # Note: To strictly enforce Authenticator over SMS, we would need a custom strength. 
    # For this simulation, we use standard MFA strength, assuming SMS is disabled or deprioritized.
    $mfaStrength = $strengths | Where-Object { $_.displayName -eq "Multifactor authentication" }
    if (-not $mfaStrength) { Throw "Could not find 'Multifactor authentication' strength." }
    $mfaStrengthId = $mfaStrength.id

    # Policy 5: Enforce Authenticator (MFA) for All Users
    try {
        $pol5Uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$PolicyNameAuthenticator'"
        $pol5Response = Invoke-MgGraphRequest -Method GET -Uri $pol5Uri
        $pol5 = $pol5Response.value | Select-Object -First 1
        
        if (-not $pol5) {
            $conditions5 = @{
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
                clientAppTypes = @("all")
            }
            
            $grant5 = @{
                operator = "OR"
                authenticationStrength = @{
                    id = $mfaStrengthId
                }
            }

            $body = @{
                displayName = $PolicyNameAuthenticator
                state = "enabledForReportingButNotEnforced"
                conditions = $conditions5
                grantControls = $grant5
            }

            $jsonBody = $body | ConvertTo-Json -Depth 10
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $jsonBody -ContentType "application/json"
            Write-Host "   ✅ Created Policy '$PolicyNameAuthenticator' (Report-Only)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Policy '$PolicyNameAuthenticator' already exists. Skipping." -ForegroundColor Yellow
        }
    } catch {
        Write-Error "   ❌ Failed to create Policy '$PolicyNameAuthenticator': $_"
    }

    # Policy 6: Enforce FIDO2 (Phishing Resistant) for Privileged Users
    try {
        $pol6Uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$PolicyNameFido2'"
        $pol6Response = Invoke-MgGraphRequest -Method GET -Uri $pol6Uri
        $pol6 = $pol6Response.value | Select-Object -First 1
        
        if (-not $pol6) {
            $conditions6 = @{
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
            
            $grant6 = @{
                operator = "OR"
                authenticationStrength = @{
                    id = $phishingResistantId
                }
            }

            $body = @{
                displayName = $PolicyNameFido2
                state = "enabledForReportingButNotEnforced"
                conditions = $conditions6
                grantControls = $grant6
            }

            $jsonBody = $body | ConvertTo-Json -Depth 10
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -Body $jsonBody -ContentType "application/json"
            Write-Host "   ✅ Created Policy '$PolicyNameFido2' (Report-Only)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Policy '$PolicyNameFido2' already exists. Skipping." -ForegroundColor Yellow
        }
    } catch {
        Write-Error "   ❌ Failed to create Policy '$PolicyNameFido2': $_"
    }
}

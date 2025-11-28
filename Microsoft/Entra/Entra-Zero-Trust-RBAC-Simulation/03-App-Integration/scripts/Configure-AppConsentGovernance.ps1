<#
.SYNOPSIS
    Configures Application Consent Governance.

.DESCRIPTION
    Restricts users from registering new applications.
    Configures user consent settings to block unverified apps.
    Enables the Admin Consent Workflow.

.EXAMPLE
    .\Configure-AppConsentGovernance.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-24
    Last Modified: 2025-11-24
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    
    Script development orchestrated using GitHub Copilot.

.SPECIALIZED_SECTION
    GOVERNANCE CONTROLS
    - App Registration: Restricted to Admins
    - User Consent: Blocked/Restricted
    - Admin Consent Workflow: Enabled (7 day expiration)
#>
#
# =============================================================================
# Configures Application Consent Governance.
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    # Connect to Graph
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    # Load Parameters
    $paramsPath = Join-Path $PSScriptRoot "..\infra\module.parameters.json"
    if ($UseParametersFile -or (Test-Path $paramsPath)) {
        if (Test-Path $paramsPath) {
            Write-Host "📂 Loading parameters from $paramsPath..." -ForegroundColor Cyan
            $jsonParams = Get-Content $paramsPath | ConvertFrom-Json
            
            $ExpirationDays = $jsonParams."Configure-AppConsentGovernance".notifyReviewersExpirationInDays
            $EnableAdminConsent = $jsonParams."Configure-AppConsentGovernance".enableAdminConsentRequests
            $BlockRiskyApps = $jsonParams."Configure-AppConsentGovernance".blockUserConsentForRiskyApps
            $RestrictAppRegistration = [System.Convert]::ToBoolean($jsonParams."Configure-AppConsentGovernance".restrictAppRegistration)
            $BlockUserConsent = [System.Convert]::ToBoolean($jsonParams."Configure-AppConsentGovernance".blockUserConsent)
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Configuring App Consent Governance..." -ForegroundColor Cyan

    # 1. Restrict App Registration (Users can register applications = No)
    try {
        # Get Authorization Policy via REST
        # Note: The endpoint returns a collection, but there is only one policy named 'authorizationPolicy'
        $authPolicyResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy"
        # The response is the object itself, not a collection wrapper for this specific singleton endpoint in some contexts,
        # but usually it's a collection. Let's handle both.
        if ($authPolicyResponse.value) {
            $authPolicy = $authPolicyResponse.value | Select-Object -First 1
        } else {
            $authPolicy = $authPolicyResponse
        }
        
        $params = @{
            defaultUserRolePermissions = @{
                allowedToCreateApps = -not $RestrictAppRegistration
            }
        }
        
        # The endpoint is a singleton, so we patch the base URI directly
        Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy" -Body $params
        if ($RestrictAppRegistration) {
            Write-Host "   ✅ Restricted App Registration for non-admins." -ForegroundColor Green
        } else {
            Write-Host "   ✅ Allowed App Registration for non-admins." -ForegroundColor Green
        }
    }
    catch {
        Write-Error "Failed to update Authorization Policy: $_"
    }

    # 2. Configure Consent Policy (Users can consent to apps...)
    if ($BlockUserConsent) {
        try {
            # Get current policy to preserve other permission grants (like Teams/Chat)
            $currentPolicy = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy"
            $currentGrants = $currentPolicy.defaultUserRolePermissions.permissionGrantPoliciesAssigned
            
            # Filter out any 'ManagePermissionGrantsForSelf' policies (which allow user consent)
            # Keep 'ManagePermissionGrantsForOwnedResource' policies (Teams/Chat)
            # Explicitly cast to string to avoid serialization issues with PS objects
            $newGrants = @($currentGrants | Where-Object { $_ -notlike "ManagePermissionGrantsForSelf.*" } | ForEach-Object { "$_" })
            
            $params = @{
                defaultUserRolePermissions = @{
                    permissionGrantPoliciesAssigned = $newGrants
                }
            }
            
            Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy" -Body $params
            Write-Host "   ✅ Blocked all user consent (Admin approval required)." -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to configure Consent Policy: $_"
        }
    }

    # 3. Enable Admin Consent Workflow
    try {
        # Use the modern adminConsentRequestPolicy API instead of legacy directorySettings
        # Endpoint: https://graph.microsoft.com/v1.0/policies/adminConsentRequestPolicy
        
        # Get the current user to set as the reviewer (Safe fallback for lab environments)
        # The API is strict about role queries, so assigning the current admin user is more reliable for simulation.
        $meResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/me"
        $userId = $meResponse.id
        
        $body = @{
            isEnabled = $EnableAdminConsent
            notifyReviewers = $true
            remindersEnabled = $true
            requestDurationInDays = $ExpirationDays
            reviewers = @(
                @{
                    query = "/users/$userId"
                    queryType = "MicrosoftGraph"
                }
            )
        }

        Invoke-MgGraphRequest -Method PUT -Uri "https://graph.microsoft.com/v1.0/policies/adminConsentRequestPolicy" -Body $body
        Write-Host "   ✅ Enabled Admin Consent Workflow (Reviewer: Current User)." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to configure Admin Consent Workflow: $_"
    }
}

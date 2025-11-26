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
        $authPolicyResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy"
        $authPolicy = $authPolicyResponse
        
        $params = @{
            defaultUserRolePermissions = @{
                allowedToCreateApps = $false
            }
        }
        
        Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy/$($authPolicy.id)" -Body $params
        Write-Host "   ✅ Restricted App Registration for non-admins." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to update Authorization Policy: $_"
    }

    # 2. Configure Consent Policy (Users can consent to apps...)
    try {
        # Block all user consent via REST
        $params = @{
            permissionGrantPolicyIdsAssignedToDefaultUserRole = @()
        }
        Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy/$($authPolicy.id)" -Body $params
        Write-Host "   ✅ Blocked all user consent (Admin approval required)." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to configure Consent Policy: $_"
    }

    # 3. Enable Admin Consent Workflow
    try {
        # Get Template via REST
        $templatesResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/directorySettingTemplates?`$filter=displayName eq 'Consent Policy Settings'"
        $template = $templatesResponse.value | Select-Object -First 1
        
        if ($template) {
            # Check existing settings via REST
            $settingsResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/directorySettings?`$filter=templateId eq '$($template.id)'"
            $settings = $settingsResponse.value | Select-Object -First 1
            
            $values = @(
                @{ name = "EnableAdminConsentRequests"; value = $EnableAdminConsent },
                @{ name = "ConstrainGroupSpecificConsentToMembersOfGroupId"; value = "" },
                @{ name = "BlockUserConsentForRiskyApps"; value = $BlockRiskyApps },
                @{ name = "NotifyReviewersExpirationInDays"; value = $ExpirationDays },
                @{ name = "NotifyReviewersType"; value = "Role" },
                @{ name = "PrimaryAdminConsentReviewers"; value = "" }
            )

            if ($settings) {
                Write-Host "   ℹ️  Consent Settings already exist. Skipping update to avoid overwrite." -ForegroundColor Yellow
            }
            else {
                # Create via REST
                $body = @{
                    templateId = $template.id
                    values = $values
                }
                Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/directorySettings" -Body $body
                Write-Host "   ✅ Enabled Admin Consent Workflow." -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Warning "Failed to configure Admin Consent Workflow: $_"
    }
}

<#
.SYNOPSIS
    Configures Authentication Methods.

.DESCRIPTION
    Enables FIDO2 Security Keys and Microsoft Authenticator for all users.
    Sets the state to 'Enabled'.

.EXAMPLE
    .\Configure-AuthMethods.ps1

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
    AUTHENTICATION METHODS
    - FIDO2 configuration
    - Microsoft Authenticator settings
    - Policy targeting
#>
#
# =============================================================================
# Step 2: Configure Authentication Methods
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🔸 Step 2: Configure Authentication Methods" -ForegroundColor Green
    Write-Host "===========================================" -ForegroundColor Green

    # Load Parameters
    $paramsPath = Join-Path $PSScriptRoot "..\infra\module.parameters.json"
    if ($UseParametersFile -or (Test-Path $paramsPath)) {
        if (Test-Path $paramsPath) {
            Write-Host "📂 Loading parameters from $paramsPath..." -ForegroundColor Cyan
            $jsonParams = Get-Content $paramsPath | ConvertFrom-Json
            
            # $TargetGroupName = $jsonParams."Configure-AuthMethods".targetGroupName # Deprecated: Now targeting All Users
            $EnableFido2 = $jsonParams."Configure-AuthMethods".enableFido2
            $EnableMicrosoftAuthenticator = $jsonParams."Configure-AuthMethods".enableMicrosoftAuthenticator
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Configuring Authentication Methods..." -ForegroundColor Cyan

    # Target "All Users" directly (Best Practice: Enable broadly, enforce via CA)
    $TargetName = "All Users"
    $TargetId = "all_users"

    # 1. Enable FIDO2
    if ($EnableFido2) {
        Write-Host "   Configuring FIDO2..." -ForegroundColor Gray
        try {
            $target = @{
                targetType = "group"
                id = $TargetId
                isRegistrationRequired = $false
                keyRestrictions = $null
            }
            
            $body = @{
                state = "enabled"
                includeTargets = @($target)
            }
            
            $jsonBody = $body | ConvertTo-Json -Depth 10
            Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/fido2" -Body $jsonBody -ContentType "application/json"
            Write-Host "   ✅ Enabled FIDO2 for '$TargetName'" -ForegroundColor Green
        }
        catch {
            Write-Error "   ❌ Failed to configure FIDO2: $_"
        }
    }

    # 2. Enable Microsoft Authenticator
    if ($EnableMicrosoftAuthenticator) {
        Write-Host "   Configuring Microsoft Authenticator..." -ForegroundColor Gray
        try {
            $target = @{
                targetType = "group"
                id = $TargetId
                authenticationMode = "any"
            }
            
            $body = @{
                state = "enabled"
                includeTargets = @($target)
            }
            
            $jsonBody = $body | ConvertTo-Json -Depth 10
            Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/microsoftAuthenticator" -Body $jsonBody -ContentType "application/json"
            Write-Host "   ✅ Enabled Microsoft Authenticator for '$TargetName'" -ForegroundColor Green
        }
        catch {
            Write-Error "   ❌ Failed to configure Microsoft Authenticator: $_"
        }
    }
}

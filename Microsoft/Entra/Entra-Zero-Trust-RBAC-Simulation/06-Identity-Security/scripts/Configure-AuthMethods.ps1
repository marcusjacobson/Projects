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
            
            $TargetGroupName = $jsonParams."Configure-AuthMethods".targetGroupName
            $EnableFido2 = $jsonParams."Configure-AuthMethods".enableFido2
            $EnableMicrosoftAuthenticator = $jsonParams."Configure-AuthMethods".enableMicrosoftAuthenticator
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Configuring Authentication Methods..." -ForegroundColor Cyan

    # Fetch Target Group
    $groupUri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$TargetGroupName'"
    $groupResponse = Invoke-MgGraphRequest -Method GET -Uri $groupUri
    $allUsersGroup = $groupResponse.value | Select-Object -First 1

    if (-not $allUsersGroup) {
        Write-Warning "   ⚠️ '$TargetGroupName' not found. Skipping configuration."
        return
    }

    # 1. Enable FIDO2
    if ($EnableFido2) {
        Write-Host "   Configuring FIDO2..." -ForegroundColor Gray
        try {
            $target = @{
                targetType = "group"
                id = $allUsersGroup.id
                isRegistrationRequired = $false
                keyRestrictions = $null
            }
            
            $body = @{
                state = "enabled"
                includeTargets = @($target)
            }
            
            Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/fido2" -Body $body
            Write-Host "   ✅ Enabled FIDO2 for '$TargetGroupName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "   ⚠️ Failed to configure FIDO2: $_"
        }
    }

    # 2. Enable Microsoft Authenticator
    if ($EnableMicrosoftAuthenticator) {
        Write-Host "   Configuring Microsoft Authenticator..." -ForegroundColor Gray
        try {
            $target = @{
                targetType = "group"
                id = $allUsersGroup.id
                authenticationMode = "any"
            }
            
            $body = @{
                state = "enabled"
                includeTargets = @($target)
            }
            
            Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/microsoftAuthenticator" -Body $body
            Write-Host "   ✅ Enabled Microsoft Authenticator for '$TargetGroupName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "   ⚠️ Failed to configure Microsoft Authenticator: $_"
        }
    }
}

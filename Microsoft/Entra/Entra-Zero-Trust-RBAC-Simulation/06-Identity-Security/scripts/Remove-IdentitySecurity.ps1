<#
.SYNOPSIS
    Removes Identity Security configurations.

.DESCRIPTION
    Deletes Conditional Access policies created in this module.
    - CA-01-RequireMFA-Admins
    - CA-02-BlockLegacyAuth
    - CA-03-Block-HighUserRisk
    - CA-04-MFA-MediumSigninRisk
    
    Optionally disables FIDO2 and Microsoft Authenticator methods (commented out by default to avoid disrupting tenant-wide settings).

.EXAMPLE
    .\Remove-IdentitySecurity.ps1

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
            
            $PolicyNameMfaAdmins = $jsonParams."Deploy-CAPolicies".policyNameMfaAdmins
            $PolicyNameBlockLegacy = $jsonParams."Deploy-CAPolicies".policyNameBlockLegacy
            $PolicyNameHighRisk = $jsonParams."Configure-IdentityProtection".policyNameHighRisk
            $PolicyNameMediumRisk = $jsonParams."Configure-IdentityProtection".policyNameMediumRisk
            $PolicyNameAuthenticator = $jsonParams."Deploy-AuthEnforcement".policyNameEnforceAuthenticator
            $PolicyNameFido2 = $jsonParams."Deploy-AuthEnforcement".policyNameEnforceFido2
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Removing Identity Security Configurations..." -ForegroundColor Cyan

    $policiesToDelete = @(
        $PolicyNameMfaAdmins,
        $PolicyNameBlockLegacy,
        $PolicyNameHighRisk,
        $PolicyNameMediumRisk,
        $PolicyNameAuthenticator,
        $PolicyNameFido2
    )

    foreach ($policyName in $policiesToDelete) {
        Write-Host "   🔍 Checking for policy '$policyName'..." -ForegroundColor Gray
        try {
            $uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$policyName'"
            $response = Invoke-MgGraphRequest -Method GET -Uri $uri
            $policy = $response.value | Select-Object -First 1

            if ($policy) {
                Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies/$($policy.id)"
                Write-Host "   🗑️ Deleted policy '$policyName'" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️ Policy '$policyName' not found." -ForegroundColor Yellow
            }
        }
        catch {
            Write-Warning "   ❌ Failed to delete policy '$policyName': $_"
        }
    }

    Write-Host "   ℹ️ Note: Authentication Methods (FIDO2, Authenticator) were NOT disabled to prevent accidental lockout or disruption. Please disable them manually if needed." -ForegroundColor Gray
}

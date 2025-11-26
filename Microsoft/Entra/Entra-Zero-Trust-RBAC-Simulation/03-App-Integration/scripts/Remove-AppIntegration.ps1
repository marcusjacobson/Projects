<#
.SYNOPSIS
    Removes resources created in Lab 03.

.EXAMPLE
    .\Remove-AppIntegration.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 03-App-Integration
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$RevertGovernance,
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
            $AppName = $jsonParams."Deploy-ReportingServicePrincipal".appName
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    # 1. Remove App Registration
    if (-not $Force) {
        $confirm = Read-Host "⚠️  Are you sure you want to delete the Reporting App '$AppName'? (y/n)"
        if ($confirm -ne 'y') { return }
    }

    Write-Host "🚀 Removing App Integration..." -ForegroundColor Cyan

    $uri = "https://graph.microsoft.com/v1.0/applications?`$filter=displayName eq '$AppName'"
    $appResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
    $app = $appResponse.value | Select-Object -First 1
    
    if ($app) {
        $deleteUri = "https://graph.microsoft.com/v1.0/applications/$($app.id)"
        Invoke-MgGraphRequest -Method DELETE -Uri $deleteUri
        Write-Host "   ✅ Removed App '$AppName'" -ForegroundColor Green
    }
    else {
        Write-Host "   ℹ️  App '$AppName' not found." -ForegroundColor Yellow
    }
    
    # 2. Revert Governance Settings (Optional)
    if ($RevertGovernance) {
        Write-Host "   Reverting Governance Settings..." -ForegroundColor Cyan
        
        # Disable Admin Consent Workflow
        try {
            $body = @{ isEnabled = $false }
            Invoke-MgGraphRequest -Method PUT -Uri "https://graph.microsoft.com/v1.0/policies/adminConsentRequestPolicy" -Body $body
            Write-Host "   ✅ Disabled Admin Consent Workflow." -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to disable Admin Consent Workflow: $_"
        }

        # Reset App Registration Restriction (Allow users to register apps)
        try {
            $params = @{
                defaultUserRolePermissions = @{
                    allowedToCreateApps = $true
                }
            }
            Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy" -Body $params
            Write-Host "   ✅ Allowed App Registration for non-admins (Default)." -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to reset Authorization Policy: $_"
        }
        
        Write-Host "   ℹ️  Note: User Consent settings (permissionGrantPoliciesAssigned) were NOT reset to default as this varies by tenant." -ForegroundColor Yellow
    }
    else {
        Write-Host "   ℹ️  Governance settings were NOT reverted. Use -RevertGovernance to reset them." -ForegroundColor Cyan
    }
}

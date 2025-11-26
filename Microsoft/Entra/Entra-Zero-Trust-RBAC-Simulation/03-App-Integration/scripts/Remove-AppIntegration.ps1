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
            $AppName = $jsonParams."Remove-AppIntegration".appName
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

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
    
    # Note: We don't revert the Consent Policy settings automatically as they are tenant-wide and might affect other things.
    Write-Host "   ℹ️  Consent Policy settings were NOT reverted. Please check Authorization Policy manually if needed." -ForegroundColor Cyan
}

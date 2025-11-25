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
    [switch]$Force
)

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    if (-not $Force) {
        $confirm = Read-Host "⚠️  Are you sure you want to delete the Reporting App? (y/n)"
        if ($confirm -ne 'y') { return }
    }

    Write-Host "🚀 Removing App Integration..." -ForegroundColor Cyan

    $appName = "APP-Reporting-Automation"
    $app = Get-MgApplication -Filter "DisplayName eq '$appName'" -ErrorAction SilentlyContinue
    
    if ($app) {
        Remove-MgApplication -ApplicationId $app.Id
        Write-Host "   ✅ Removed App '$appName'" -ForegroundColor Green
    }
    else {
        Write-Host "   ℹ️  App '$appName' not found." -ForegroundColor Yellow
    }
    
    # Note: We don't revert the Consent Policy settings automatically as they are tenant-wide and might affect other things.
    Write-Host "   ℹ️  Consent Policy settings were NOT reverted. Please check Authorization Policy manually if needed." -ForegroundColor Cyan
}

<#
.SYNOPSIS
    Removes Administrative Units created in Lab 02.

.EXAMPLE
    .\Remove-DelegatedAdmin.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 02-Delegated-Administration
#>

[CmdletBinding()]
param(
    [switch]$Force
)

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    if (-not $Force) {
        $confirm = Read-Host "⚠️  Are you sure you want to delete all simulation Administrative Units? (y/n)"
        if ($confirm -ne 'y') { return }
    }

    Write-Host "🚀 Removing Administrative Units..." -ForegroundColor Cyan

    $aus = Get-MgDirectoryAdministrativeUnit -Filter "startsWith(displayName, 'AU-')" -All
    
    foreach ($au in $aus) {
        Write-Host "   Removing AU: $($au.DisplayName)"
        try {
            Remove-MgDirectoryAdministrativeUnit -AdministrativeUnitId $au.Id -ErrorAction Stop
            Write-Host "   ✅ Removed." -ForegroundColor Green
        }
        catch {
            Write-Error "   ❌ Failed to remove $($au.DisplayName): $_"
        }
    }
    
    Write-Host "✅ Cleanup Complete." -ForegroundColor Green
}

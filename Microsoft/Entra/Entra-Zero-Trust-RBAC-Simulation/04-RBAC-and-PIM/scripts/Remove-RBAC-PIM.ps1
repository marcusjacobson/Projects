<#
.SYNOPSIS
    Removes resources created in Lab 04.

.EXAMPLE
    .\Remove-RBAC-PIM.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 04-RBAC-and-PIM
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
            $RoleName = $jsonParams."Remove-RBAC-PIM".roleName
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    if (-not $Force) {
        $confirm = Read-Host "⚠️  Are you sure you want to remove Custom Roles and PIM settings? (y/n)"
        if ($confirm -ne 'y') { return }
    }

    Write-Host "🚀 Removing RBAC and PIM Configurations..." -ForegroundColor Cyan

    # 1. Remove Custom Role
    $uri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$filter=displayName eq '$RoleName'"
    $roleResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
    $role = $roleResponse.value | Select-Object -First 1
    
    if ($role) {
        $deleteUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions/$($role.id)"
        Invoke-MgGraphRequest -Method DELETE -Uri $deleteUri
        Write-Host "   ✅ Removed Custom Role '$RoleName'" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Custom Role '$RoleName' not found." -ForegroundColor Yellow
    }

    # 2. Revert PIM Settings (Optional/Complex)
    # We generally don't revert PIM settings in cleanup as it's destructive to default policies.
    Write-Host "   ℹ️  PIM Policies for Global Admin were NOT reverted to default." -ForegroundColor Yellow
    Write-Host "   ℹ️  Role assignments to groups were NOT removed (will be cleaned up when Group is deleted)." -ForegroundColor Yellow
    
    Write-Host "✅ Cleanup Complete." -ForegroundColor Green
}

<#
.SYNOPSIS
    Removes resources created in Lab 01.

.DESCRIPTION
    Deletes users (USR-*), groups (GRP-SEC-*), and Break Glass accounts.
    Reverts tenant hardening settings (optional/manual).

.EXAMPLE
    .\Remove-IdentityFoundation.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 01-Identity-Foundation
#>

[CmdletBinding()]
param(
    [switch]$Force
)

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    if (-not $Force) {
        $confirm = Read-Host "⚠️  Are you sure you want to delete all simulation users and groups? (y/n)"
        if ($confirm -ne 'y') { return }
    }

    Write-Host "🚀 Starting Cleanup..." -ForegroundColor Cyan

    # 1. Remove Users
    $users = Get-MgUser -Filter "startsWith(userPrincipalName, 'USR-') or startsWith(userPrincipalName, 'ADM-BG-')" -All
    foreach ($u in $users) {
        Write-Host "   Removing User: $($u.UserPrincipalName)"
        Remove-MgUser -UserId $u.Id -ErrorAction SilentlyContinue
    }

    # 2. Remove Groups
    $groups = Get-MgGroup -Filter "startsWith(displayName, 'GRP-SEC-')" -All
    foreach ($g in $groups) {
        Write-Host "   Removing Group: $($g.DisplayName)"
        Remove-MgGroup -GroupId $g.Id -ErrorAction SilentlyContinue
    }

    Write-Host "✅ Cleanup Complete." -ForegroundColor Green
}

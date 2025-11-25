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
    [switch]$Force
)

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    if (-not $Force) {
        $confirm = Read-Host "⚠️  Are you sure you want to remove Custom Roles and PIM settings? (y/n)"
        if ($confirm -ne 'y') { return }
    }

    Write-Host "🚀 Removing RBAC and PIM Configurations..." -ForegroundColor Cyan

    # 1. Remove Custom Role
    $roleName = "ROLE-Tier1-Helpdesk"
    $role = Get-MgRoleManagementDirectoryRoleDefinition -Filter "DisplayName eq '$roleName'" -ErrorAction SilentlyContinue
    
    if ($role) {
        Remove-MgRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $role.Id
        Write-Host "   ✅ Removed Custom Role '$roleName'" -ForegroundColor Green
    }

    # 2. Revert PIM Settings (Optional/Complex)
    # We generally don't revert PIM settings in cleanup as it's destructive to default policies.
    Write-Host "   ℹ️  PIM Policies for Global Admin were NOT reverted to default." -ForegroundColor Yellow
    Write-Host "   ℹ️  Role assignments to groups were NOT removed (will be cleaned up when Group is deleted)." -ForegroundColor Yellow
    
    Write-Host "✅ Cleanup Complete." -ForegroundColor Green
}

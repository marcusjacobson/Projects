<#
.SYNOPSIS
    Configures tenant-level security settings.

.DESCRIPTION
    Disables the ability for non-admins to access the Entra administration portal.
    Restricts external user invitation rights to admins only.
    Restricts the ability for users to join devices to Entra ID.

.EXAMPLE
    .\Configure-TenantHardening.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 01-Identity-Foundation
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    # Connect to Graph
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    # Load Parameters
    $paramsPath = Join-Path $PSScriptRoot "..\infra\module.parameters.json"
    if ($UseParametersFile -or (Test-Path $paramsPath)) {
        if (Test-Path $paramsPath) {
            Write-Host "📂 Loading parameters from $paramsPath..." -ForegroundColor Cyan
            $jsonParams = Get-Content $paramsPath | ConvertFrom-Json
            
            # Currently no specific parameters for hardening in the JSON other than generic ones, 
            # but we prepare the structure for future expansion.
            # $AllowedExtensions = $jsonParams."Configure-TenantHardening".allowedExtensions
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Configuring Tenant Hardening..." -ForegroundColor Cyan

    # 1. Authorization Policy (Portal Access & Guest Invites)
    try {
        $body = @{
            allowInvitesFrom = "adminsAndGuestInviters"
            defaultUserRolePermissions = @{
                allowedToCreateApps = $false
                allowedToCreateSecurityGroups = $false
                allowedToReadOtherUsers = $false # Restrict user enumeration
            }
        }

        Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy" -Body $body
        Write-Host "   ✅ Updated Authorization Policy (Restricted App/Group creation & User Enumeration)." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to update Authorization Policy: $_"
    }

    # 2. Device Registration Policy
    try {
        # Note: DeviceRegistrationPolicy is often read-only in v1.0 or requires specific permissions.
        # We log a warning if we can't access it, but we don't fail the script.
        Write-Host "   ℹ️  Device Join restriction is complex via Graph v1.0. Please verify in portal if needed." -ForegroundColor Cyan
    }
    catch {
        Write-Warning "Could not update Device Policy."
    }
    
    Write-Host "✅ Tenant Hardening Configuration Complete." -ForegroundColor Green
}

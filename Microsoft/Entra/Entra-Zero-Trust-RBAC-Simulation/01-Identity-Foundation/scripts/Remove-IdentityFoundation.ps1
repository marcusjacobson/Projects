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
    [switch]$Force,
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    # Connect to Graph
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    if (-not $Force) {
        $confirm = Read-Host "⚠️  Are you sure you want to delete all simulation users and groups? (y/n)"
        if ($confirm -ne 'y') { return }
    }

    Write-Host "🚀 Starting Cleanup..." -ForegroundColor Cyan

    # 1. Remove Users
    # Filter: startsWith 'USR-' OR 'ADM-BG-'
    # Note: OData filter syntax for OR with startsWith
    $uri = "https://graph.microsoft.com/v1.0/users?`$filter=startsWith(userPrincipalName, 'USR-') or startsWith(userPrincipalName, 'ADM-BG-')"
    $usersResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
    $users = $usersResponse.value

    foreach ($u in $users) {
        Write-Host "   Removing User: $($u.userPrincipalName)"
        try {
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/users/$($u.id)"
        } catch {
            # Check the full error record string as Invoke-MgGraphRequest errors are verbose
            $errString = $_.ToString()
            if ($errString -like "*restricted management administrative unit*" -or $errString -like "*Authorization_RequestDenied*") {
                Write-Host "      🔒 User is protected by Restricted Management AU. Skipping deletion." -ForegroundColor Yellow
            } else {
                Write-Warning "Failed to remove user $($u.userPrincipalName): $_"
            }
        }
    }

    # 2. Remove Groups
    # We select assignedLicenses to check if we need to remove them before deleting the group
    $uri = "https://graph.microsoft.com/v1.0/groups?`$filter=startsWith(displayName, 'GRP-SEC-')&`$select=id,displayName,assignedLicenses"
    $groupsResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
    $groups = $groupsResponse.value

    foreach ($g in $groups) {
        Write-Host "   Removing Group: $($g.displayName)"
        try {
            # Check for licenses and remove if present
            if ($g.assignedLicenses.Count -gt 0) {
                Write-Host "      ⚠️  Removing assigned licenses first..." -ForegroundColor Yellow
                # Force array type for JSON serialization
                $skuIdsToRemove = @($g.assignedLicenses | ForEach-Object { $_.skuId })
                
                $body = @{
                    addLicenses = @()
                    removeLicenses = $skuIdsToRemove
                }
                
                Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups/$($g.id)/assignLicense" -Body $body
            }

            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/groups/$($g.id)"
        } catch {
            Write-Warning "Failed to remove group $($g.displayName): $_"
        }
    }

    Write-Host "✅ Cleanup Complete." -ForegroundColor Green
}

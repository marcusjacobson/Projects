<#
.SYNOPSIS
    Deploys a Restricted Management Administrative Unit.

.DESCRIPTION
    Creates 'AU-SEC-Restricted' with restricted management enabled.
    Adds the Break Glass accounts to this AU.
    This prevents standard Global Admins from modifying these sensitive accounts.

.EXAMPLE
    .\Configure-RestrictedManagementAUs.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 02-Delegated-Administration
#>

[CmdletBinding()]
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    $auName = "AU-SEC-Restricted"
    
    Write-Host "🚀 Deploying Restricted Management AU..." -ForegroundColor Cyan

    try {
        $existing = Get-MgDirectoryAdministrativeUnit -Filter "DisplayName eq '$auName'" -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "   ⚠️  AU '$auName' already exists." -ForegroundColor Yellow
            $auId = $existing.Id
        }
        else {
            # Create with IsMemberManagementRestricted = $true
            # Note: This property might require beta endpoint or specific payload structure depending on SDK version.
            # v1.0 supports it.
            
            $params = @{
                DisplayName = $auName
                Description = "Restricted Management for Break Glass Accounts"
                IsMemberManagementRestricted = $true
            }
            
            $au = New-MgDirectoryAdministrativeUnit -BodyParameter $params
            Write-Host "   ✅ Created Restricted AU '$auName'" -ForegroundColor Green
            $auId = $au.Id
        }

        # Add Break Glass Accounts
        $bgAccounts = Get-MgUser -Filter "startsWith(userPrincipalName, 'ADM-BG-')" -All
        
        foreach ($acc in $bgAccounts) {
            try {
                New-MgDirectoryAdministrativeUnitMemberByRef -AdministrativeUnitId $auId -BodyParameter @{ "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($acc.Id)" } -ErrorAction SilentlyContinue
                Write-Host "   ✅ Added '$($acc.UserPrincipalName)' to Restricted AU" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to add $($acc.UserPrincipalName): $_"
            }
        }
    }
    catch {
        Write-Error "Failed to deploy Restricted AU: $_"
    }
}

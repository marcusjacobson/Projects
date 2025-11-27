<#
.SYNOPSIS
    Removes Entitlement Management resources.

.DESCRIPTION
    Deletes Assignment Policies, Access Packages, Catalogs, and Connected Orgs created by the lab.

.EXAMPLE
    .\Remove-EntitlementMgmt.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 05-Entitlement-Management
#>

[CmdletBinding()]
param(
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
            
            $CatName = $jsonParams."Remove-EntitlementMgmt".catalogName
            $OrgName = $jsonParams."Remove-EntitlementMgmt".orgName
            $Packages = $jsonParams."Remove-EntitlementMgmt".packages
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🗑️ Cleaning up Entitlement Management..." -ForegroundColor Yellow

    # Helper to remove package
    function Remove-Package ($pkgName) {
        $pkgUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackages?`$filter=displayName eq '$pkgName'"
        $pkgResponse = Invoke-MgGraphRequest -Method GET -Uri $pkgUri
        $pkg = $pkgResponse.value | Select-Object -First 1
        
        if ($pkg) {
            # Remove policies first
            # Use beta endpoint and correct entity set name 'accessPackageAssignmentPolicies'
            $polUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignmentPolicies?`$filter=accessPackageId eq '$($pkg.id)'"
            $polResponse = Invoke-MgGraphRequest -Method GET -Uri $polUri
            $policies = $polResponse.value
            
            foreach ($pol in $policies) {
                Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignmentPolicies/$($pol.id)" -ErrorAction SilentlyContinue
                Write-Host "   - Removed Policy '$($pol.displayName)'" -ForegroundColor Gray
            }
            
            # Remove package
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackages/$($pkg.id)" -ErrorAction SilentlyContinue
            Write-Host "   ✅ Removed Package '$pkgName'" -ForegroundColor Green
        }
    }

    foreach ($pkg in $Packages) {
        Remove-Package $pkg
    }

    # Remove Catalog
    # Use v1.0 endpoint for catalogs as it is stable and consistent with deployment
    $catUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/catalogs?`$filter=displayName eq '$CatName'"
    $catResponse = Invoke-MgGraphRequest -Method GET -Uri $catUri
    $cat = $catResponse.value | Select-Object -First 1
    
    if ($cat) {
        # Check for and remove resources from catalog
        # Use beta endpoint for resources as v1.0 has issues in this tenant
        $resUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageCatalogs/$($cat.id)/accessPackageResources"
        $resResponse = Invoke-MgGraphRequest -Method GET -Uri $resUri
        $resources = $resResponse.value

        foreach ($res in $resources) {
            try {
                $params = @{
                    catalogId = $cat.id
                    requestType = "AdminRemove"
                    accessPackageResource = @{
                        id = $res.id
                    }
                }
                Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageResourceRequests" -Body $params
                Write-Host "   - Removed Resource '$($res.displayName)' from Catalog" -ForegroundColor Gray
            }
            catch {
                Write-Warning "   ⚠️ Failed to remove resource '$($res.displayName)' from catalog: $_"
            }
        }

        try {
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/catalogs/$($cat.id)" -ErrorAction Stop
            Write-Host "   ✅ Removed Catalog '$CatName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "   ⚠️ Could not remove Catalog '$CatName'. It might not be empty."
            Write-Warning "   $_"
        }
    }

    # Remove Connected Org
    $orgUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/connectedOrganizations?`$filter=displayName eq '$OrgName'"
    $orgResponse = Invoke-MgGraphRequest -Method GET -Uri $orgUri
    $org = $orgResponse.value | Select-Object -First 1
    
    if ($org) {
        Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/connectedOrganizations/$($org.id)" -ErrorAction SilentlyContinue
        Write-Host "   ✅ Removed Connected Org '$OrgName'" -ForegroundColor Green
    }
}

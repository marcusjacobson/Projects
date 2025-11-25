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
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🗑️ Cleaning up Entitlement Management..." -ForegroundColor Yellow

    # Helper to remove package
    function Remove-Package ($pkgName) {
        $pkg = Get-MgEntitlementManagementAccessPackage -Filter "DisplayName eq '$pkgName'" -ErrorAction SilentlyContinue
        if ($pkg) {
            # Remove policies first
            $policies = Get-MgEntitlementManagementAccessPackageAssignmentPolicy -Filter "AccessPackage/Id eq '$($pkg.Id)'"
            foreach ($pol in $policies) {
                Remove-MgEntitlementManagementAccessPackageAssignmentPolicy -AccessPackageAssignmentPolicyId $pol.Id -ErrorAction SilentlyContinue
                Write-Host "   - Removed Policy '$($pol.DisplayName)'" -ForegroundColor Gray
            }
            
            # Remove package
            Remove-MgEntitlementManagementAccessPackage -AccessPackageId $pkg.Id -ErrorAction SilentlyContinue
            Write-Host "   ✅ Removed Package '$pkgName'" -ForegroundColor Green
        }
    }

    Remove-Package "PKG-Marketing-Campaign"
    Remove-Package "PKG-Partner-Collab"

    # Remove Catalog
    $catName = "CAT-Marketing"
    $cat = Get-MgEntitlementManagementAccessPackageCatalog -Filter "DisplayName eq '$catName'" -ErrorAction SilentlyContinue
    if ($cat) {
        # Catalog must be empty? Usually packages are gone, but resources might remain.
        # Resources are linked to catalog.
        # We might need to remove resource requests?
        # Deleting catalog usually fails if not empty.
        
        # Try force delete or just delete
        try {
            Remove-MgEntitlementManagementAccessPackageCatalog -AccessPackageCatalogId $cat.Id -ErrorAction Stop
            Write-Host "   ✅ Removed Catalog '$catName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "   ⚠️ Could not remove Catalog '$catName'. It might not be empty."
            Write-Warning "   $_"
        }
    }

    # Remove Connected Org
    $orgName = "Partner Corp"
    $org = Get-MgEntitlementManagementConnectedOrganization -Filter "DisplayName eq '$orgName'" -ErrorAction SilentlyContinue
    if ($org) {
        Remove-MgEntitlementManagementConnectedOrganization -ConnectedOrganizationId $org.Id -ErrorAction SilentlyContinue
        Write-Host "   ✅ Removed Connected Org '$orgName'" -ForegroundColor Green
    }
}

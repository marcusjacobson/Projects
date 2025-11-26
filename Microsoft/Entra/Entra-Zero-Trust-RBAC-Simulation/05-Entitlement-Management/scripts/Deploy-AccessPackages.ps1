<#
.SYNOPSIS
    Deploys Entitlement Management resources.

.DESCRIPTION
    Creates a Catalog 'CAT-Marketing'.
    Adds 'GRP-SEC-Marketing' to the catalog.
    Creates an Access Package 'PKG-Marketing-Campaign'.
    Creates an Assignment Policy allowing internal users to request access.

.EXAMPLE
    .\Deploy-AccessPackages.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-24
    Last Modified: 2025-11-24
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    - Entra ID P2 License
    
    Script development orchestrated using GitHub Copilot.

.SPECIALIZED_SECTION
    IGA CONFIGURATION
    - Catalog: CAT-Marketing
    - Access Package: PKG-Marketing-Campaign
    - Policy: Internal Users (Auto-approval for simulation)
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
            
            $CatName = $jsonParams."Deploy-AccessPackages".catalogName
            $GroupName = $jsonParams."Deploy-AccessPackages".groupName
            $PkgName = $jsonParams."Deploy-AccessPackages".packageName
            $PolicyName = $jsonParams."Deploy-AccessPackages".policyName
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Deploying Access Packages..." -ForegroundColor Cyan

    # 1. Create Catalog
    $catUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/catalogs?`$filter=displayName eq '$CatName'"
    $catResponse = Invoke-MgGraphRequest -Method GET -Uri $catUri
    $cat = $catResponse.value | Select-Object -First 1
    
    if (-not $cat) {
        $body = @{
            displayName = $CatName
            description = "Marketing Resources"
        }
        $cat = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/catalogs" -Body $body
        Write-Host "   ✅ Created Catalog '$CatName'" -ForegroundColor Green
    }

    # 2. Add Resource (Group) to Catalog
    $groupUri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$GroupName'"
    $groupResponse = Invoke-MgGraphRequest -Method GET -Uri $groupUri
    $group = $groupResponse.value | Select-Object -First 1
    
    try {
        $params = @{
            catalogId = $cat.id
            requestType = "AdminAdd"
            accessPackageResource = @{
                originId = $group.id
                originSystem = "AadGroup"
            }
        }
        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackageResourceRequests" -Body $params
        Write-Host "   ✅ Added '$GroupName' to Catalog." -ForegroundColor Green
    }
    catch {
        Write-Verbose "Resource likely already in catalog: $_"
    }

    # 3. Create Access Package
    $pkgUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackages?`$filter=displayName eq '$PkgName' and catalog/id eq '$($cat.id)'"
    $pkgResponse = Invoke-MgGraphRequest -Method GET -Uri $pkgUri
    $pkg = $pkgResponse.value | Select-Object -First 1
    
    if (-not $pkg) {
        $body = @{
            displayName = $PkgName
            description = "Access to Marketing Campaign Resources"
            catalogId = $cat.id
        }
        $pkg = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackages" -Body $body
        Write-Host "   ✅ Created Access Package '$PkgName'" -ForegroundColor Green
    }

    # 4. Add Resource Role to Package
    # Find resource in catalog
    $resUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackageResources?`$filter=originId eq '$($group.id)'"
    $resResponse = Invoke-MgGraphRequest -Method GET -Uri $resUri
    $res = $resResponse.value | Select-Object -First 1
    
    # Find "Member" role
    $rolesUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackageResources/$($res.id)/roles"
    $rolesResponse = Invoke-MgGraphRequest -Method GET -Uri $rolesUri
    $role = $rolesResponse.value | Where-Object { $_.displayName -eq "Member" } | Select-Object -First 1
    
    if ($role) {
        try {
            $params = @{
                accessPackageId = $pkg.id
                accessPackageResourceRole = @{
                    id = $role.id
                    originId = $role.originId
                    originSystem = "AadGroup"
                    accessPackageResource = @{
                        id = $res.id
                        originId = $res.originId
                        originSystem = "AadGroup"
                    }
                }
            }
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackageResourceRoleScopes" -Body $params
            Write-Host "   ✅ Linked Group Member role to Package." -ForegroundColor Green
        }
        catch {
            # Ignore if already linked
        }
    }

    # 5. Create Assignment Policy
    
    try {
        $params = @{
            accessPackageId = $pkg.id
            displayName = $PolicyName
            description = "Allow internal users to request"
            accessReviewSettings = $null
            requestorSettings = @{
                scopeType = "AllExistingDirectoryMemberUsers"
                acceptRequests = $true
            }
            requestApprovalSettings = @{
                isApprovalRequired = $false
            }
            expiration = @{
                type = "NoExpiration"
            }
        }
        
        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/assignmentPolicies" -Body $params
        Write-Host "   ✅ Created Assignment Policy '$PolicyName'." -ForegroundColor Green
    }
    catch {
        Write-Verbose "Policy creation failed (might exist): $_"
    }
}

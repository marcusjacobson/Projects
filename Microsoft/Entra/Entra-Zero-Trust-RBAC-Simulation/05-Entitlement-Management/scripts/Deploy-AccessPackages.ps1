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
#
# =============================================================================
# Step 1: Deploy Access Packages
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🔸 Step 1: Deploy Access Packages" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green

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

    # DEBUG: Check Scopes and Catalog
    $ctx = Get-MgContext
    Write-Host "🔍 Current Scopes: $($ctx.Scopes -join ', ')" -ForegroundColor Gray
    
    # 1. Create Catalog
    $catUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/catalogs?`$filter=displayName eq '$CatName'"
    $catResponse = Invoke-MgGraphRequest -Method GET -Uri $catUri
    $cat = $catResponse.value | Select-Object -First 1
    
    if ($cat) {
        Write-Host "   ℹ️ Found existing Catalog: '$($cat.displayName)' (ID: $($cat.id))" -ForegroundColor Gray
    }

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
        # Use beta endpoint for resource requests as v1.0 seems to have issues
        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageResourceRequests" -Body $params
        Write-Host "   ✅ Added '$GroupName' to Catalog." -ForegroundColor Green
    }
    catch {
        if ($_ -match "ResourceAlreadyOnboarded" -or $_.Exception.Message -match "ResourceAlreadyOnboarded") {
            Write-Host "   ℹ️ Resource '$GroupName' is already in the catalog." -ForegroundColor Gray
        } else {
            Write-Warning "Failed to add resource to catalog: $_"
        }
    }

    # 3. Create Access Package
    $pkgUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackages?`$filter=displayName eq '$PkgName' and catalog/id eq '$($cat.id)'"
    $pkgResponse = Invoke-MgGraphRequest -Method GET -Uri $pkgUri
    $pkg = $pkgResponse.value | Select-Object -First 1
    
    if (-not $pkg) {
        try {
            $body = @{
                displayName = $PkgName
                description = "Access to Marketing Campaign Resources"
                catalogId = $cat.id
            }
            # Use beta endpoint for package creation to avoid potential v1.0 issues
            $pkg = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackages" -Body $body
            Write-Host "   ✅ Created Access Package '$PkgName'" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to create Access Package: $_"
            return # Stop execution if package creation fails
        }
    }

    # 4. Add Resource Role to Package
    # Find resource in catalog
    # Use beta endpoint via Catalog relationship (Global filter is 403 Forbidden)
    $resUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageCatalogs/$($cat.id)/accessPackageResources?`$filter=originId eq '$($group.id)'"
    $resResponse = Invoke-MgGraphRequest -Method GET -Uri $resUri
    $res = $resResponse.value | Select-Object -First 1
    
    if (-not $res) {
        Write-Warning "Resource not found in catalog. Ensure step 2 completed successfully."
    } else {
        # Find "Member" role
        # Use beta endpoint for roles via Catalog Scope with Filter (The only method that works for this tenant)
        $rolesUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageCatalogs/$($cat.id)/accessPackageResourceRoles?`$filter=accessPackageResource/originSystem eq 'AadGroup' and accessPackageResource/originId eq '$($group.id)'"
        $rolesResponse = Invoke-MgGraphRequest -Method GET -Uri $rolesUri
        $role = $rolesResponse.value | Where-Object { $_.displayName -eq "Member" } | Select-Object -First 1
        
        if ($role) {
            # Check if already linked
            $existingScopesUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackages/$($pkg.id)/accessPackageResourceRoleScopes?`$expand=accessPackageResourceRole"
            $existingScopesResponse = Invoke-MgGraphRequest -Method GET -Uri $existingScopesUri
            $existingScope = $existingScopesResponse.value | Where-Object { $_.accessPackageResourceRole.originId -eq $role.originId }

            if ($existingScope) {
                Write-Host "   ℹ️ Role '$($role.displayName)' is already linked to package." -ForegroundColor Gray
            } else {
                try {
                    $params = @{
                        accessPackageResourceRole = @{
                            originId = $role.originId
                            originSystem = "AadGroup"
                            accessPackageResource = @{
                                id = $res.id
                                originId = $res.originId
                                originSystem = "AadGroup"
                            }
                        }
                        accessPackageResourceScope = @{
                            originId = $res.originId
                            originSystem = "AadGroup"
                            accessPackageResource = @{
                                id = $res.id
                                originId = $res.originId
                                originSystem = "AadGroup"
                            }
                        }
                    }
                    # Use beta endpoint for role scopes via Package Navigation (Top-level endpoint is missing)
                    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackages/$($pkg.id)/accessPackageResourceRoleScopes" -Body $params
                    Write-Host "   ✅ Linked Group Member role to Package." -ForegroundColor Green
                }
                catch {
                    Write-Warning "Failed to link resource role: $_"
                }
            }
        } else {
            Write-Warning "Could not find 'Member' role for resource $($res.id)"
        }
    }

    # 5. Create Assignment Policy
    $policyUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignmentPolicies?`$filter=accessPackageId eq '$($pkg.id)' and displayName eq '$PolicyName'"
    $policyResponse = Invoke-MgGraphRequest -Method GET -Uri $policyUri
    $existingPolicy = $policyResponse.value | Select-Object -First 1

    if ($existingPolicy) {
        Write-Host "   ℹ️ Assignment Policy '$PolicyName' already exists." -ForegroundColor Gray
    } else {
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
            
            # Use beta endpoint for assignment policies (Entity set name is accessPackageAssignmentPolicies)
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignmentPolicies" -Body $params
            Write-Host "   ✅ Created Assignment Policy '$PolicyName'." -ForegroundColor Green
        }
        catch {
            Write-Warning "Policy creation failed: $_"
        }
    }
}

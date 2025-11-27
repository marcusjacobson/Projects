<#
.SYNOPSIS
    Configures External Governance via Entitlement Management.

.DESCRIPTION
    Creates a Connected Organization 'Partner Corp'.
    Creates an Access Package 'PKG-Partner-Collab'.
    Creates an Assignment Policy allowing users from the Connected Org to request access.
    Requires approval (simulated).

.EXAMPLE
    .\Configure-ExternalGovernance.ps1

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
            
            $OrgName = $jsonParams."Configure-ExternalGovernance".orgName
            $Domain = $jsonParams."Configure-ExternalGovernance".domain
            $CatName = $jsonParams."Configure-ExternalGovernance".catalogName
            $PkgName = $jsonParams."Configure-ExternalGovernance".packageName
            $PolicyName = $jsonParams."Configure-ExternalGovernance".policyName
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Configuring External Governance..." -ForegroundColor Cyan

    # 1. Create Connected Organization
    $orgUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/connectedOrganizations?`$filter=displayName eq '$OrgName'"
    $orgResponse = Invoke-MgGraphRequest -Method GET -Uri $orgUri
    $connectedOrg = $orgResponse.value | Select-Object -First 1
    
    if (-not $connectedOrg) {
        try {
            $body = @{
                displayName = $OrgName
                description = "Simulated Partner Organization"
                identitySources = @(
                    @{
                        "@odata.type" = "#microsoft.graph.domainIdentitySource"
                        displayName = $Domain
                        domainName = $Domain
                    }
                )
                state = "proposed"
            }
            $connectedOrg = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/connectedOrganizations" -Body $body
            Write-Host "   ✅ Created Connected Org '$OrgName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "   ⚠️ Could not create Connected Org (Domain validation likely failed). Skipping policy creation for it."
            Write-Warning "   Error: $_"
            return
        }
    } else {
        Write-Host "   ℹ️ Connected Org '$OrgName' already exists." -ForegroundColor Gray
    }

    # 2. Create Access Package for External
    $catUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/catalogs?`$filter=displayName eq '$CatName'"
    $catResponse = Invoke-MgGraphRequest -Method GET -Uri $catUri
    $cat = $catResponse.value | Select-Object -First 1
    if (-not $cat) { Write-Error "Catalog '$CatName' not found. Run Deploy-AccessPackages.ps1 first."; return }

    $pkgUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackages?`$filter=displayName eq '$PkgName' and catalog/id eq '$($cat.id)'"
    $pkgResponse = Invoke-MgGraphRequest -Method GET -Uri $pkgUri
    $pkg = $pkgResponse.value | Select-Object -First 1
    
    if (-not $pkg) {
        try {
            $body = @{
                displayName = $PkgName
                description = "External Collaboration"
                catalogId = $cat.id
            }
            # Use beta endpoint for package creation to avoid potential v1.0 issues
            $pkg = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackages" -Body $body
            Write-Host "   ✅ Created Access Package '$PkgName'" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to create Access Package: $_"
            return
        }
    }

    # 3. Create Policy for Connected Org
    # Get Current User for Approver
    $me = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/me"
    
    $policyUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignmentPolicies?`$filter=accessPackageId eq '$($pkg.id)' and displayName eq '$PolicyName'"
    $policyResponse = Invoke-MgGraphRequest -Method GET -Uri $policyUri
    $existingPolicy = $policyResponse.value | Select-Object -First 1

    if ($existingPolicy) {
        Write-Host "   ℹ️ Assignment Policy '$PolicyName' already exists." -ForegroundColor Gray
    } else {
        try {
            $body = @{
                accessPackageId = $pkg.id
                displayName = $PolicyName
                description = "Allow partner users to request"
                accessReviewSettings = $null
                requestorSettings = @{
                    scopeType = "SpecificConnectedOrganizationSubjects"
                    acceptRequests = $true
                    allowedRequestors = @(
                        @{
                            "@odata.type" = "#microsoft.graph.connectedOrganizationMembers"
                            connectedOrganizationId = $connectedOrg.id
                            description = $connectedOrg.displayName
                        }
                    )
                }
                requestApprovalSettings = @{
                    isApprovalRequired = $true
                    approvalStages = @(
                        @{
                            approvalStageTimeOutInDays = 14
                            isApproverJustificationRequired = $true
                            isEscalationEnabled = $false
                            primaryApprovers = @(
                                @{
                                    "@odata.type" = "#microsoft.graph.singleUser"
                                    userId = $me.id
                                }
                            )
                        }
                    )
                }
                expiration = @{
                    type = "AfterDuration"
                    duration = "P30D"
                }
            }
            
            # Use beta endpoint for assignment policies (Entity set name is accessPackageAssignmentPolicies)
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignmentPolicies" -Body $body
            Write-Host "   ✅ Created Policy '$PolicyName' with Approval." -ForegroundColor Green
        }
        catch {
            Write-Warning "Policy creation failed: $_"
        }
    }
}

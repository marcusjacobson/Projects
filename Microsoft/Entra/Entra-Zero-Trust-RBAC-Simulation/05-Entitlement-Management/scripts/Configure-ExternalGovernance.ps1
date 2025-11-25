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
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🚀 Configuring External Governance..." -ForegroundColor Cyan

    # 1. Create Connected Organization
    $orgName = "Partner Corp"
    $domain = "partner.example.com"
    
    $connectedOrg = Get-MgEntitlementManagementConnectedOrganization -Filter "DisplayName eq '$orgName'" -ErrorAction SilentlyContinue
    if (-not $connectedOrg) {
        # Note: In a real scenario, this validates the domain. In simulation, it might fail if domain is unreachable or invalid.
        # We will try to create it with a 'Proposed' state if possible, or just skip if it fails validation.
        try {
            $params = @{
                DisplayName = $orgName
                Description = "Simulated Partner Organization"
                IdentitySources = @(
                    @{
                        "@odata.type" = "#microsoft.graph.domainIdentitySource"
                        DisplayName = $domain
                        DomainName = $domain
                    }
                )
                State = "Proposed" # Proposed allows creation without full validation sometimes, or just logical representation
            }
            $connectedOrg = New-MgEntitlementManagementConnectedOrganization -BodyParameter $params -ErrorAction Stop
            Write-Host "   ✅ Created Connected Org '$orgName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "   ⚠️ Could not create Connected Org (Domain validation likely failed). Skipping policy creation for it."
            Write-Warning "   Error: $_"
            return
        }
    } else {
        Write-Host "   ℹ️ Connected Org '$orgName' already exists." -ForegroundColor Gray
    }

    # 2. Create Access Package for External
    $catName = "CAT-Marketing" # Reuse catalog
    $cat = Get-MgEntitlementManagementAccessPackageCatalog -Filter "DisplayName eq '$catName'"
    if (-not $cat) { Write-Error "Catalog not found. Run Deploy-AccessPackages.ps1 first."; return }

    $pkgName = "PKG-Partner-Collab"
    $pkg = Get-MgEntitlementManagementAccessPackage -Filter "DisplayName eq '$pkgName'" -ErrorAction SilentlyContinue
    if (-not $pkg) {
        $pkg = New-MgEntitlementManagementAccessPackage -DisplayName $pkgName -Description "External Collaboration" -CatalogId $cat.Id
        Write-Host "   ✅ Created Access Package '$pkgName'" -ForegroundColor Green
    }

    # 3. Create Policy for Connected Org
    $policyName = "Partner Access Policy"
    try {
        $params = @{
            AccessPackageId = $pkg.Id
            DisplayName = $policyName
            Description = "Allow partner users to request"
            RequestorSettings = @{
                ScopeType = "SpecificConnectedOrganizationSubjects"
                ConnectedOrganizationId = $connectedOrg.Id
                AcceptRequests = $true
            }
            RequestApprovalSettings = @{
                IsApprovalRequired = $true
                ApprovalStages = @(
                    @{
                        ApprovalStageTimeOutInDays = 14
                        IsApproverJustificationRequired = $true
                        IsEscalationEnabled = $false
                        PrimaryApprover = @{
                            "@odata.type" = "#microsoft.graph.singleUser"
                            UserId = (Get-MgContext).Account # Self-approval for simulation
                        }
                    }
                )
            }
            Expiration = @{
                Type = "AfterDuration"
                Duration = "P30D"
            }
        }
        
        New-MgEntitlementManagementAccessPackageAssignmentPolicy -BodyParameter $params
        Write-Host "   ✅ Created Policy '$policyName' with Approval." -ForegroundColor Green
    }
    catch {
        Write-Verbose "Policy creation failed: $_"
    }
}

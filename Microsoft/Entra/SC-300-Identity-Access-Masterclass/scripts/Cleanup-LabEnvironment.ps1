<#
.SYNOPSIS
    Cleans up resources created during the SC-300 Masterclass labs.

.DESCRIPTION
    This script removes the test users, groups, and administrative units created
    during the simulation labs to return the tenant to a clean state.
    
    The script:
    1. Connects to Microsoft Graph.
    2. Removes specific test users (Alex, Bianca, Christie, David).
    3. Removes specific dynamic groups.
    4. Removes the "Paris Branch" Administrative Unit.

.PARAMETER Force
    Skips confirmation prompts.

.EXAMPLE
    .\Cleanup-LabEnvironment.ps1 -Force
    
    Removes all lab resources without prompting.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-05-20
    Last Modified: 2025-05-20
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft.Graph PowerShell module
    - Global Administrator role
    
    Script development orchestrated using GitHub Copilot.

.CLEANUP TARGETS
    - Users: Alex Wilber, Bianca Pisani, Christie Cline, David So
    - Groups: Dynamic-Sales-Team, Dynamic-Marketing-Team, Project-Alpha, SAML-App-SelfService-Users
    - Admin Units: Paris Branch
    - Named Locations: Corporate Head Office
    - CA Policies: CA001-*, CA002-*, CA003-*
    - Applications: Contoso HR Portal, Contoso SAML App
    - Entitlement Management: Marketing Resources (Catalog), Marketing Starter Pack (Access Package)
#>
#
# =============================================================================
# Cleanup-LabEnvironment.ps1
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# =============================================================================
# Step 1: Connect to Microsoft Graph
# =============================================================================

Write-Host "🔍 Step 1: Connect to Microsoft Graph" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

try {
    Write-Host "🚀 Connecting to Microsoft Graph..." -ForegroundColor Cyan
    Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "Policy.Read.All", "Policy.ReadWrite.ConditionalAccess", "Application.ReadWrite.All", "EntitlementManagement.ReadWrite.All" -ErrorAction Stop
    Write-Host "   ✅ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Connection failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Remove Users
# =============================================================================

Write-Host "🔍 Step 2: Remove Users" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green

$targetUsers = @("Alex Wilber", "Bianca Pisani", "Christie Cline", "David So")

foreach ($userName in $targetUsers) {
    try {
        $user = Get-MgUser -Filter "DisplayName eq '$userName'" -ErrorAction SilentlyContinue
        if ($user) {
            Write-Host "📋 Removing user: $userName" -ForegroundColor Cyan
            Remove-MgUser -UserId $user.Id -ErrorAction Stop
            Write-Host "   ✅ Removed user: $userName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ User not found: $userName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove user '$userName': $_" -ForegroundColor Red
    }
}

# =============================================================================
# Step 3: Remove Groups
# =============================================================================

Write-Host "🔍 Step 3: Remove Groups" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

$targetGroups = @("Dynamic-Sales-Team", "Dynamic-Marketing-Team", "Project-Alpha", "SAML-App-SelfService-Users")

foreach ($groupName in $targetGroups) {
    try {
        $group = Get-MgGroup -Filter "DisplayName eq '$groupName'" -ErrorAction SilentlyContinue
        if ($group) {
            Write-Host "📋 Removing group: $groupName" -ForegroundColor Cyan
            Remove-MgGroup -GroupId $group.Id -ErrorAction Stop
            Write-Host "   ✅ Removed group: $groupName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Group not found: $groupName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove group '$groupName': $_" -ForegroundColor Red
    }
}

# =============================================================================
# Step 4: Remove Administrative Units
# =============================================================================

Write-Host "🔍 Step 4: Remove Administrative Units" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$targetAUs = @("Paris Branch")

foreach ($auName in $targetAUs) {
    try {
        $au = Get-MgDirectoryAdministrativeUnit -Filter "DisplayName eq '$auName'" -ErrorAction SilentlyContinue
        if ($au) {
            Write-Host "📋 Removing Admin Unit: $auName" -ForegroundColor Cyan
            Remove-MgDirectoryAdministrativeUnit -AdministrativeUnitId $au.Id -ErrorAction Stop
            Write-Host "   ✅ Removed Admin Unit: $auName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Admin Unit not found: $auName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove Admin Unit '$auName': $_" -ForegroundColor Red
    }
}

# =============================================================================
# Step 5: Remove Conditional Access Policies & Named Locations
# =============================================================================

Write-Host "🔍 Step 5: Remove CA Policies & Locations" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Remove Policies
$targetPolicies = @("CA001-Require MFA for Admins", "CA002-Block Legacy Auth", "CA003-Sales MFA External", "CA004-Remediate High User Risk", "CA005-Remediate Medium+ Sign-in Risk")

foreach ($policyName in $targetPolicies) {
    try {
        $policy = Get-MgIdentityConditionalAccessPolicy -Filter "DisplayName eq '$policyName'" -ErrorAction SilentlyContinue
        if ($policy) {
            Write-Host "📋 Removing CA Policy: $policyName" -ForegroundColor Cyan
            Remove-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $policy.Id -ErrorAction Stop
            Write-Host "   ✅ Removed CA Policy: $policyName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ CA Policy not found: $policyName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove CA Policy '$policyName': $_" -ForegroundColor Red
    }
}

# Wait for propagation to allow Named Location deletion
Write-Host "⏳ Waiting 15 seconds for policy deletion propagation..." -ForegroundColor Cyan
Start-Sleep -Seconds 15

# Remove Named Locations
$targetLocations = @("Corporate Head Office")

foreach ($locName in $targetLocations) {
    try {
        $loc = Get-MgIdentityConditionalAccessNamedLocation -Filter "DisplayName eq '$locName'" -ErrorAction SilentlyContinue
        if ($loc) {
            Write-Host "📋 Processing Named Location: $locName" -ForegroundColor Cyan
            
            # Force update to untrusted using REST API for reliability
            try {
                Write-Host "   🔄 Ensuring Location is Untrusted..." -ForegroundColor Cyan
                
                # Default to IP Named Location (Lab 06)
                $odataType = "#microsoft.graph.ipNamedLocation"
                
                # Check if it's a Country location by property presence
                if ($loc | Get-Member -Name "CountriesAndRegions") {
                    $odataType = "#microsoft.graph.countryNamedLocation"
                }

                $params = @{ 
                    "@odata.type" = $odataType
                    isTrusted = $false 
                }
                
                Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations/$($loc.Id)" -Body $params -ErrorAction Stop
                
                Write-Host "   ⏳ Waiting 30 seconds for trust update propagation..." -ForegroundColor Cyan
                Start-Sleep -Seconds 30
            } catch {
                Write-Host "   ⚠️ Note: Could not update trust status (ignoring): $_" -ForegroundColor Yellow
            }

            Write-Host "   🗑️ Removing Named Location..." -ForegroundColor Cyan
            Remove-MgIdentityConditionalAccessNamedLocation -NamedLocationId $loc.Id -ErrorAction Stop
            Write-Host "   ✅ Removed Named Location: $locName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Named Location not found: $locName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove Named Location '$locName': $_" -ForegroundColor Red
    }
}

# =============================================================================
# Step 6: Remove Applications (App Registrations & Enterprise Apps)
# =============================================================================

Write-Host "🔍 Step 6: Remove Applications" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

$targetApps = @("Contoso HR Portal", "Contoso SAML App")

foreach ($appName in $targetApps) {
    # Remove App Registration First (Unlocks SP deletion constraints)
    try {
        $app = Get-MgApplication -Filter "DisplayName eq '$appName'" -ErrorAction SilentlyContinue
        if ($app) {
            Write-Host "📋 Removing App Registration: $appName" -ForegroundColor Cyan
            Remove-MgApplication -ApplicationId $app.Id -ErrorAction Stop
            Write-Host "   ✅ Removed App Registration: $appName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ App Registration not found: $appName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove App Registration '$appName': $_" -ForegroundColor Red
    }

    # Remove Service Principal (Enterprise App)
    try {
        $sp = Get-MgServicePrincipal -Filter "DisplayName eq '$appName'" -ErrorAction SilentlyContinue
        if ($sp) {
            Write-Host "📋 Removing Service Principal: $appName" -ForegroundColor Cyan
            Remove-MgServicePrincipal -ServicePrincipalId $sp.Id -ErrorAction Stop
            Write-Host "   ✅ Removed Service Principal: $appName" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ Failed to remove Service Principal '$appName': $_" -ForegroundColor Red
    }
}

# =============================================================================
# Step 7: Remove Entitlement Management Resources
# =============================================================================

Write-Host "🔍 Step 7: Remove Entitlement Management" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Remove Access Packages
$targetPackages = @("Marketing Starter Pack")

foreach ($pkgName in $targetPackages) {
    try {
        $pkg = Get-MgEntitlementManagementAccessPackage -Filter "DisplayName eq '$pkgName'" -ErrorAction SilentlyContinue
        if ($pkg) {
            Write-Host "📋 Removing Access Package: $pkgName" -ForegroundColor Cyan
            # Access Packages might have assignments that need to be removed first, but force delete isn't always simple via Graph.
            # We'll try standard removal.
            Remove-MgEntitlementManagementAccessPackage -AccessPackageId $pkg.Id -ErrorAction Stop
            Write-Host "   ✅ Removed Access Package: $pkgName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Access Package not found: $pkgName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove Access Package '$pkgName': $_" -ForegroundColor Red
    }
}

# Remove Catalogs
$targetCatalogs = @("Marketing Resources")

foreach ($catName in $targetCatalogs) {
    try {
        $cat = Get-MgEntitlementManagementCatalog -Filter "DisplayName eq '$catName'" -ErrorAction SilentlyContinue
        if ($cat) {
            Write-Host "📋 Removing Catalog: $catName" -ForegroundColor Cyan
            Remove-MgEntitlementManagementCatalog -AccessPackageCatalogId $cat.Id -ErrorAction Stop
            Write-Host "   ✅ Removed Catalog: $catName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Catalog not found: $catName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove Catalog '$catName': $_" -ForegroundColor Red
    }
}

Write-Host "✅ Cleanup completed" -ForegroundColor Blue

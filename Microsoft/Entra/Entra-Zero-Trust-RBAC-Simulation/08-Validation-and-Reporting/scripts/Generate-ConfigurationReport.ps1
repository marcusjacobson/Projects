<#
.SYNOPSIS
    Generates a configuration report.

.DESCRIPTION
    Exports the current state of Users, Groups, Roles, Policies, and Governance settings to a JSON file.
    Saves to '..\reports\ConfigurationReport-YYYYMMDD.json'.

.EXAMPLE
    .\Generate-ConfigurationReport.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 08-Validation-and-Reporting
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
            
            $ReportPath = $jsonParams."Generate-ConfigurationReport".reportPath
            $GroupFilter = $jsonParams."Generate-ConfigurationReport".groupFilter
            $UserFilter = $jsonParams."Generate-ConfigurationReport".userFilter
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Generating Configuration Report..." -ForegroundColor Cyan

    $report = @{
        GeneratedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        TenantId = (Get-MgContext).TenantId
        Modules = @{}
    }

    # Lab 01: Identity Foundation
    Write-Host "   Gathering Identity Foundation data..." -ForegroundColor Gray
    
    $groupsUri = "https://graph.microsoft.com/v1.0/groups?`$filter=$GroupFilter&`$select=displayName,id,groupTypes"
    $groupsRes = Invoke-MgGraphRequest -Method GET -Uri $groupsUri
    
    $usersUri = "https://graph.microsoft.com/v1.0/users?`$filter=$UserFilter&`$select=userPrincipalName,id"
    $usersRes = Invoke-MgGraphRequest -Method GET -Uri $usersUri

    $report.Modules["01-Identity-Foundation"] = @{
        Groups = $groupsRes.value
        BreakGlass = $usersRes.value
    }

    # Lab 02: Delegated Admin
    Write-Host "   Gathering Admin Units..." -ForegroundColor Gray
    $auUri = "https://graph.microsoft.com/v1.0/directory/administrativeUnits?`$select=displayName,id,description"
    $auRes = Invoke-MgGraphRequest -Method GET -Uri $auUri
    $report.Modules["02-Delegated-Admin"] = @{
        AdminUnits = $auRes.value
    }

    # Lab 03: App Integration
    Write-Host "   Gathering App Integration data..." -ForegroundColor Gray
    $spUri = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=startsWith(displayName, 'APP-')&`$select=displayName,appId,id"
    $spRes = Invoke-MgGraphRequest -Method GET -Uri $spUri
    $report.Modules["03-App-Integration"] = @{
        ServicePrincipals = $spRes.value
    }

    # Lab 04: RBAC & PIM
    Write-Host "   Gathering Roles and PIM Groups..." -ForegroundColor Gray
    $rolesUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$filter=isBuiltIn eq false&`$select=displayName,id,description"
    $rolesRes = Invoke-MgGraphRequest -Method GET -Uri $rolesUri
    
    $pimGroupUri = "https://graph.microsoft.com/v1.0/groups?`$filter=startsWith(displayName, 'GRP-PIM-')&`$select=displayName,id"
    $pimGroupRes = Invoke-MgGraphRequest -Method GET -Uri $pimGroupUri

    $report.Modules["04-RBAC"] = @{
        CustomRoles = $rolesRes.value
        PIMGroups = $pimGroupRes.value
    }

    # Lab 05: Entitlement Management
    Write-Host "   Gathering Entitlement Management data..." -ForegroundColor Gray
    $catUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/catalogs?`$select=displayName,id"
    $catRes = Invoke-MgGraphRequest -Method GET -Uri $catUri
    
    $pkgUri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackages?`$select=displayName,id,description"
    $pkgRes = Invoke-MgGraphRequest -Method GET -Uri $pkgUri

    $report.Modules["05-Entitlement-Management"] = @{
        Catalogs = $catRes.value
        AccessPackages = $pkgRes.value
    }

    # Lab 06: Security
    Write-Host "   Gathering Security Policies..." -ForegroundColor Gray
    $caUri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$select=displayName,state,id"
    $caRes = Invoke-MgGraphRequest -Method GET -Uri $caUri
    $report.Modules["06-Identity-Security"] = @{
        CAPolicies = $caRes.value
    }

    # Lab 07: Lifecycle Governance
    Write-Host "   Gathering Governance data..." -ForegroundColor Gray
    $arUri = "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions?`$select=displayName,id,status"
    $arRes = Invoke-MgGraphRequest -Method GET -Uri $arUri
    
    $wfUri = "https://graph.microsoft.com/v1.0/identityGovernance/lifecycleWorkflows/workflows?`$select=displayName,id,category,isEnabled"
    $wfRes = Invoke-MgGraphRequest -Method GET -Uri $wfUri

    $report.Modules["07-Lifecycle-Governance"] = @{
        AccessReviews = $arRes.value
        LifecycleWorkflows = $wfRes.value
    }

    # Export
    $reportDir = Join-Path $PSScriptRoot $ReportPath
    if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir | Out-Null }
    
    $fileName = "ConfigurationReport-$(Get-Date -Format 'yyyyMMdd-HHmm').json"
    $filePath = Join-Path $reportDir $fileName
    
    $report | ConvertTo-Json -Depth 5 | Set-Content -Path $filePath
    
    Write-Host "   ✅ Report saved to: $filePath" -ForegroundColor Green
}

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
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🚀 Generating Configuration Report..." -ForegroundColor Cyan

    $report = @{
        GeneratedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        TenantId = (Get-MgContext).TenantId
        Modules = @{}
    }

    # Lab 01: Identity Foundation
    Write-Host "   Gathering Identity Foundation data..." -ForegroundColor Gray
    $report.Modules["01-Identity-Foundation"] = @{
        Groups = (Get-MgGroup -Filter "startsWith(DisplayName, 'GRP-SEC-')" -All | Select-Object DisplayName, Id, GroupTypes)
        BreakGlass = (Get-MgUser -Filter "startsWith(UserPrincipalName, 'breakglass')" | Select-Object UserPrincipalName, Id)
    }

    # Lab 02: Delegated Admin
    Write-Host "   Gathering Admin Units..." -ForegroundColor Gray
    $report.Modules["02-Delegated-Admin"] = @{
        AdminUnits = (Get-MgDirectoryAdministrativeUnit -All | Select-Object DisplayName, Id, Description)
    }

    # Lab 04: RBAC
    Write-Host "   Gathering Roles..." -ForegroundColor Gray
    $report.Modules["04-RBAC"] = @{
        CustomRoles = (Get-MgRoleManagementDirectoryRoleDefinition -Filter "IsBuiltIn eq false" -All | Select-Object DisplayName, Id, Description)
    }

    # Lab 06: Security
    Write-Host "   Gathering Security Policies..." -ForegroundColor Gray
    $report.Modules["06-Identity-Security"] = @{
        CAPolicies = (Get-MgIdentityConditionalAccessPolicy -All | Select-Object DisplayName, State, Id)
    }

    # Export
    $reportDir = "$PSScriptRoot\..\reports"
    if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir | Out-Null }
    
    $fileName = "ConfigurationReport-$(Get-Date -Format 'yyyyMMdd-HHmm').json"
    $filePath = Join-Path $reportDir $fileName
    
    $report | ConvertTo-Json -Depth 5 | Set-Content -Path $filePath
    
    Write-Host "   ✅ Report saved to: $filePath" -ForegroundColor Green
}

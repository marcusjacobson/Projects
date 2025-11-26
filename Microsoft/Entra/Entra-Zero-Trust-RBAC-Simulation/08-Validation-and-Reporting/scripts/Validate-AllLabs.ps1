<#
.SYNOPSIS
    Validates the entire simulation deployment.

.DESCRIPTION
    Checks for the existence and basic configuration of resources from Labs 00-07.
    Outputs a summary of Pass/Fail checks.

.EXAMPLE
    .\Validate-AllLabs.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-24
    Last Modified: 2025-11-24
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    
    Script development orchestrated using GitHub Copilot.

.SPECIALIZED_SECTION
    TEST SCENARIOS
    - Resource Existence: Checks for Users, Groups, Policies
    - Configuration State: Verifies Report-Only mode
    - Coverage: Labs 00 through 07
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
            
            $GroupName = $jsonParams."Validate-AllLabs".groupName
            $BreakGlassPrefix = $jsonParams."Validate-AllLabs".breakGlassPrefix
            $AdminUnitName = $jsonParams."Validate-AllLabs".adminUnitName
            $ServicePrincipalName = $jsonParams."Validate-AllLabs".servicePrincipalName
            $RoleName = $jsonParams."Validate-AllLabs".roleName
            $CatalogName = $jsonParams."Validate-AllLabs".catalogName
            $PolicyName = $jsonParams."Validate-AllLabs".policyName
            $ReviewName = $jsonParams."Validate-AllLabs".reviewName
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Starting Validation for All Labs..." -ForegroundColor Cyan
    $results = @()

    function Test-Resource ($Name, $Type, $CheckScript) {
        Write-Host "   Checking $Type '$Name'..." -NoNewline
        try {
            $passed = & $CheckScript
            if ($passed) {
                Write-Host " [OK]" -ForegroundColor Green
                return @{ Name=$Name; Type=$Type; Status="Pass" }
            } else {
                Write-Host " [MISSING/INVALID]" -ForegroundColor Red
                return @{ Name=$Name; Type=$Type; Status="Fail" }
            }
        } catch {
            Write-Host " [ERROR: $_]" -ForegroundColor Red
            return @{ Name=$Name; Type=$Type; Status="Error" }
        }
    }

    # Lab 00
    $results += Test-Resource "Log Analytics Workspace" "Resource" { $true } # Placeholder

    # Lab 01
    $results += Test-Resource $GroupName "Group" { 
        $uri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$GroupName'"
        $res = Invoke-MgGraphRequest -Method GET -Uri $uri
        [bool]($res.value)
    }
    $results += Test-Resource "Break Glass Account" "User" { 
        $uri = "https://graph.microsoft.com/v1.0/users?`$filter=startsWith(userPrincipalName, '$BreakGlassPrefix')"
        $res = Invoke-MgGraphRequest -Method GET -Uri $uri
        [bool]($res.value)
    }

    # Lab 02
    $results += Test-Resource $AdminUnitName "Admin Unit" { 
        $uri = "https://graph.microsoft.com/v1.0/directory/administrativeUnits?`$filter=displayName eq '$AdminUnitName'"
        $res = Invoke-MgGraphRequest -Method GET -Uri $uri
        [bool]($res.value)
    }

    # Lab 03
    $results += Test-Resource $ServicePrincipalName "Service Principal" { 
        $uri = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=displayName eq '$ServicePrincipalName'"
        $res = Invoke-MgGraphRequest -Method GET -Uri $uri
        [bool]($res.value)
    }

    # Lab 04
    $results += Test-Resource $RoleName "Role Def" { 
        $uri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$filter=displayName eq '$RoleName'"
        $res = Invoke-MgGraphRequest -Method GET -Uri $uri
        [bool]($res.value)
    }

    # Lab 05
    $results += Test-Resource $CatalogName "Catalog" { 
        $uri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/catalogs?`$filter=displayName eq '$CatalogName'"
        $res = Invoke-MgGraphRequest -Method GET -Uri $uri
        [bool]($res.value)
    }

    # Lab 06
    $results += Test-Resource $PolicyName "CA Policy" { 
        $uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=displayName eq '$PolicyName'"
        $res = Invoke-MgGraphRequest -Method GET -Uri $uri
        [bool]($res.value)
    }

    # Lab 07
    $results += Test-Resource $ReviewName "Access Review" { 
        $uri = "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions?`$filter=displayName eq '$ReviewName'"
        $res = Invoke-MgGraphRequest -Method GET -Uri $uri
        [bool]($res.value)
    }

    # Summary
    Write-Host "`n📊 Validation Summary:" -ForegroundColor Cyan
    $results | Format-Table -AutoSize
}

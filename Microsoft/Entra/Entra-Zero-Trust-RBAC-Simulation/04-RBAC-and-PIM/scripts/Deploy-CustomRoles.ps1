<#
.SYNOPSIS
    Deploys a Custom Role Definition.

.DESCRIPTION
    Creates 'ROLE-Tier1-Helpdesk' with permissions to reset passwords and invalidate tokens.
    This role is designed for Level 1 support staff.

.EXAMPLE
    .\Deploy-CustomRoles.ps1

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
    ROLE DEFINITION
    - Name: ROLE-Tier1-Helpdesk
    - Permissions: password/update, invalidateAllRefreshTokens
    - Scope: Directory-wide (can be scoped to AU)
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
            
            $RoleName = $jsonParams."Deploy-CustomRoles".roleName
            $Description = $jsonParams."Deploy-CustomRoles".description
            $Permissions = $jsonParams."Deploy-CustomRoles".permissions
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }
    
    Write-Host "🚀 Deploying Custom Role '$RoleName'..." -ForegroundColor Cyan

    try {
        # Check existence via REST
        $uri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$filter=displayName eq '$RoleName'"
        $existingResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
        $existing = $existingResponse.value | Select-Object -First 1

        if ($existing) {
            Write-Host "   ⚠️  Role '$RoleName' already exists." -ForegroundColor Yellow
        }
        else {
            $perms = @(
                @{
                    allowedResourceActions = $Permissions
                }
            )

            $body = @{
                displayName = $RoleName
                description = $Description
                rolePermissions = $perms
                isEnabled = $true
                templateId = [Guid]::NewGuid().ToString() # Required for custom roles
            }

            $null = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions" -Body $body
            Write-Host "   ✅ Created Custom Role '$RoleName'" -ForegroundColor Green
        }
    }
    catch {
        Write-Error "Failed to create custom role: $_"
    }
}

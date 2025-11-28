<#
.SYNOPSIS
    Deploys a Restricted Management Administrative Unit.

.DESCRIPTION
    Creates 'AU-SEC-Restricted' with restricted management enabled.
    Adds the Break Glass accounts to this AU.
    This prevents standard Global Admins from modifying these sensitive accounts.

.EXAMPLE
    .\Configure-RestrictedManagementAUs.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-28
    Last Modified: 2025-11-28
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Deploys a Restricted Management Administrative Unit.
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    # Connect to Graph
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    # Load Parameters
    $paramsPath = Join-Path $PSScriptRoot "..\infra\module.parameters.json"
    if ($UseParametersFile -or (Test-Path $paramsPath)) {
        if (Test-Path $paramsPath) {
            Write-Host "📂 Loading parameters from $paramsPath..." -ForegroundColor Cyan
            $jsonParams = Get-Content $paramsPath | ConvertFrom-Json
            
            $AuName = $jsonParams."Configure-RestrictedManagementAUs".auName
            $Description = $jsonParams."Configure-RestrictedManagementAUs".description
            $RestrictedAccounts = $jsonParams."Configure-RestrictedManagementAUs".restrictedAccounts
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }
    
    Write-Host "🚀 Deploying Restricted Management AU..." -ForegroundColor Cyan

    # Helper function for retries
    function Invoke-GraphRequestWithRetry {
        param(
            [string]$Method,
            [string]$Uri,
            [hashtable]$Body,
            [int]$MaxRetries = 3
        )
        
        $retry = 0
        $success = $false
        $response = $null
        
        while (-not $success -and $retry -lt $MaxRetries) {
            try {
                if ($Body) {
                    $response = Invoke-MgGraphRequest -Method $Method -Uri $Uri -Body $Body -ErrorAction Stop
                } else {
                    $response = Invoke-MgGraphRequest -Method $Method -Uri $Uri -ErrorAction Stop
                }
                $success = $true
            }
            catch {
                $retry++
                if ($retry -eq $MaxRetries) {
                    throw $_
                }
                Write-Warning "   ⚠️  Connection failed. Retrying ($retry/$MaxRetries)..."
                Start-Sleep -Seconds 2
            }
        }
        return $response
    }

    try {
        # Check existence via REST
        $uri = "https://graph.microsoft.com/v1.0/directory/administrativeUnits?`$filter=displayName eq '$AuName'"
        $existingResponse = Invoke-GraphRequestWithRetry -Method GET -Uri $uri
        $existing = $existingResponse.value | Select-Object -First 1

        if ($existing) {
            Write-Host "   ⚠️  AU '$AuName' already exists." -ForegroundColor Yellow
            $auId = $existing.id
        }
        else {
            # Create with IsMemberManagementRestricted = $true
            $body = @{
                displayName = $AuName
                description = $Description
                isMemberManagementRestricted = $true
            }
            
            $au = Invoke-GraphRequestWithRetry -Method POST -Uri "https://graph.microsoft.com/v1.0/directory/administrativeUnits" -Body $body
            Write-Host "   ✅ Created Restricted AU '$AuName'" -ForegroundColor Green
            $auId = $au.id
        }

        # Add Break Glass Accounts
        foreach ($accName in $RestrictedAccounts) {
            try {
                # Find user by mailNickname to be domain-agnostic
                $userUri = "https://graph.microsoft.com/v1.0/users?`$filter=mailNickname eq '$accName'"
                $userResponse = Invoke-GraphRequestWithRetry -Method GET -Uri $userUri
                $user = $userResponse.value | Select-Object -First 1

                if ($user) {
                    $memberBody = @{
                        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($user.id)"
                    }
                    Invoke-GraphRequestWithRetry -Method POST -Uri "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$auId/members/`$ref" -Body $memberBody
                    Write-Host "   ✅ Added '$($user.userPrincipalName)' to Restricted AU" -ForegroundColor Green
                } else {
                    Write-Warning "User '$accName' not found."
                }
            }
            catch {
                Write-Warning "Failed to add ${accName}: $_"
            }
        }
    }
    catch {
        Write-Error "Failed to deploy Restricted AU: $_"
    }
}

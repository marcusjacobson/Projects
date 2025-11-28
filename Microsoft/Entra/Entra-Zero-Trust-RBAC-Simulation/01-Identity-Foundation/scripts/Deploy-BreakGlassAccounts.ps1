<#
.SYNOPSIS
    Creates Emergency Access (Break Glass) accounts.

.DESCRIPTION
    Creates two cloud-only accounts with the Global Administrator role.
    These accounts are critical for tenant recovery if Conditional Access misconfiguration occurs.
    Naming convention: ADM-BG-01, ADM-BG-02.

.EXAMPLE
    .\Deploy-BreakGlassAccounts.ps1

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
# Creates Emergency Access (Break Glass) accounts.
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

begin {
    function New-RandomPassword {
        $upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        $lower = "abcdefghijklmnopqrstuvwxyz"
        $digits = "0123456789"
        $special = "!@#$%^&*"
        
        $password = @()
        $password += $upper[(Get-Random -Maximum $upper.Length)]
        $password += $lower[(Get-Random -Maximum $lower.Length)]
        $password += $digits[(Get-Random -Maximum $digits.Length)]
        $password += $special[(Get-Random -Maximum $special.Length)]
        
        $allChars = $upper + $lower + $digits + $special
        for ($i = 0; $i -lt 12; $i++) {
            $password += $allChars[(Get-Random -Maximum $allChars.Length)]
        }
        
        return ($password | Sort-Object { Get-Random }) -join ''
    }
}

process {
    # Connect to Graph
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    # Load Parameters
    $paramsPath = Join-Path $PSScriptRoot "..\infra\module.parameters.json"
    if ($UseParametersFile -or (Test-Path $paramsPath)) {
        if (Test-Path $paramsPath) {
            Write-Host "📂 Loading parameters from $paramsPath..." -ForegroundColor Cyan
            $jsonParams = Get-Content $paramsPath | ConvertFrom-Json
            
            $Accounts = $jsonParams."Deploy-BreakGlassAccounts".accounts
            $UsageLocation = $jsonParams.global.location
            $CustomDomain = $jsonParams.global.customDomain
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    # Get Domain via REST
    $domainsResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/domains"
    $verifiedDomains = $domainsResponse.value | Where-Object { $_.isVerified }
    $initialDomain = ($domainsResponse.value | Where-Object { $_.isInitial }).id
    
    $Domain = $initialDomain # Default
    
    if (-not [string]::IsNullOrWhiteSpace($CustomDomain)) {
        $found = $verifiedDomains | Where-Object { $_.id -eq $CustomDomain }
        if ($found) {
            $Domain = $CustomDomain
            Write-Host "   ✅ Using Custom Domain: $Domain" -ForegroundColor Green
        } else {
            Write-Warning "   ⚠️  Custom domain '$CustomDomain' not found or not verified. Falling back to $initialDomain"
        }
    } else {
        Write-Host "   ℹ️  Using Initial Domain: $Domain" -ForegroundColor Cyan
    }

    Write-Host "🚀 Deploying Break Glass Accounts..." -ForegroundColor Cyan

    foreach ($acc in $Accounts) {
        # Handle both string array (from JSON) and object array (if expanded later)
        if ($acc.PSObject.Properties.Match('name').Count) {
            $accName = $acc.name
        } else {
            $accName = $acc
        }

        $upn = "$accName@$Domain"
        
        # Generate Random Password
        $randomPassword = New-RandomPassword

        $PasswordProfile = @{
            password = $randomPassword
            forceChangePasswordNextSignIn = $false # BG accounts usually don't expire/change often
        }
        
        try {
            # Check existence
            $uri = "https://graph.microsoft.com/v1.0/users?`$filter=userPrincipalName eq '$upn'"
            $existingResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
            $existing = $existingResponse.value | Select-Object -First 1

            if ($existing) {
                Write-Host "   ⚠️  Account '$upn' already exists." -ForegroundColor Yellow
                $userId = $existing.id
            }
            else {
                # Create
                $userParams = @{
                    displayName = $accName
                    userPrincipalName = $upn
                    mailNickname = $accName
                    accountEnabled = $true
                    passwordProfile = $PasswordProfile
                    usageLocation = $UsageLocation
                }
                
                # Debug
                # Write-Host "Debug Body: $($userParams | ConvertTo-Json -Depth 5)" -ForegroundColor DarkGray

                $newUser = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/users" -Body $userParams
                Write-Host "   ✅ Created Account '$upn'" -ForegroundColor Green
                Write-Host "      🔑 Password: $randomPassword" -ForegroundColor Yellow
                $userId = $newUser.id
            }

            # Assign Global Admin Role
            # 1. Get Role Definition
            $roleUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$filter=displayName eq 'Global Administrator'"
            $roleDef = Invoke-MgGraphRequest -Method GET -Uri $roleUri
            $roleId = $roleDef.value[0].id

            # 2. Assign Role
            # Check if already assigned
            $assignmentsUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?`$filter=principalId eq '$userId' and roleDefinitionId eq '$roleId'"
            $assignments = Invoke-MgGraphRequest -Method GET -Uri $assignmentsUri
            
            if ($assignments.value.Count -eq 0) {
                $assignmentBody = @{
                    "@odata.type" = "#microsoft.graph.unifiedRoleAssignment"
                    principalId = $userId
                    roleDefinitionId = $roleId
                    directoryScopeId = "/"
                }
                $null = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments" -Body $assignmentBody
                Write-Host "      ✅ Assigned Global Admin role to $upn" -ForegroundColor Green
            } else {
                Write-Host "      ⚠️  Global Admin role already assigned." -ForegroundColor Yellow
            }
        }
        catch {
            Write-Error "Failed to process account ${upn}: $_"
        }
    }

    Write-Host "`n⚠️  IMPORTANT: Store these credentials securely (e.g., Password Manager, Physical Safe)." -ForegroundColor Red
}

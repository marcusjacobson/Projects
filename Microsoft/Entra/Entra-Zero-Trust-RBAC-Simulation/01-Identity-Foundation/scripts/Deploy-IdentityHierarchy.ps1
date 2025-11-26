<#
.SYNOPSIS
    Deploys the core user and group hierarchy for the simulation.

.DESCRIPTION
    Creates a set of standard users and security groups based on a fictional business structure.
    Enforces 'USR-' and 'GRP-' naming conventions.
    Adds users to their respective departmental groups.

.EXAMPLE
    .\Deploy-IdentityHierarchy.ps1

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
    IDENTITY STRUCTURE
    - Departments: IT, HR, Finance, Marketing, Executive
    - Naming Convention: USR-[Role], GRP-SEC-[Dept]
    - Security: ForceChangePasswordNextSignIn enabled
#>

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
        for ($i = 0; $i -lt 8; $i++) {
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
            
            $Departments = $jsonParams."Deploy-IdentityHierarchy".departments
            $Users = $jsonParams."Deploy-IdentityHierarchy".users
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
    
    # 1. Define Departments and Groups
    Write-Host "🚀 Creating Departmental Groups..." -ForegroundColor Cyan
    
    $GroupMap = @{} # To store Group IDs

    foreach ($dept in $Departments) {
        $groupName = "GRP-SEC-$dept"
        $cleanNickname = $groupName -replace '\s+',''
        $desc = "Security Group for $dept Department"
        
        try {
            # Check existence via REST
            $uri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$groupName'"
            $existingResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
            $existing = $existingResponse.value | Select-Object -First 1

            if ($existing) {
                Write-Host "   ⚠️  Group '$groupName' already exists." -ForegroundColor Yellow
                $GroupMap[$dept] = $existing.id
            }
            else {
                # Create via REST
                $body = @{
                    displayName = $groupName
                    mailEnabled = $false
                    mailNickname = $cleanNickname
                    securityEnabled = $true
                    description = $desc
                }
                $group = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups" -Body $body
                Write-Host "   ✅ Created Group '$groupName'" -ForegroundColor Green
                $GroupMap[$dept] = $group.id
            }
        }
        catch {
            Write-Error "Failed to create group ${groupName}: $_"
        }
    }

    # 2. Define Users
    Write-Host "`n🚀 Creating Users..." -ForegroundColor Cyan

    foreach ($u in $Users) {
        $cleanName = $u.name -replace '\s+',''
        $upn = "$($cleanName)@$Domain"
        $nickname = $cleanName.ToLower()
        
        # Generate Random Password
        $randomPassword = New-RandomPassword
        
        $PasswordProfile = @{
            password = $randomPassword
            forceChangePasswordNextSignIn = $true
        }
        
        try {
            # Check existence via REST
            $uri = "https://graph.microsoft.com/v1.0/users?`$filter=userPrincipalName eq '$upn'"
            $existingResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
            $existing = $existingResponse.value | Select-Object -First 1

            if ($existing) {
                Write-Host "   ⚠️  User '$upn' already exists." -ForegroundColor Yellow
                $userId = $existing.id
            }
            else {
                # Create via REST
                $userParams = @{
                    displayName = $u.name
                    userPrincipalName = $upn
                    mailNickname = $nickname
                    accountEnabled = $true
                    passwordProfile = $PasswordProfile
                    jobTitle = $u.title
                    department = $u.dept
                    usageLocation = $UsageLocation
                }
                
                $newUser = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/users" -Body $userParams
                Write-Host "   ✅ Created User '$upn'" -ForegroundColor Green
                $userId = $newUser.id
            }

            # Add to Department Group
            $groupId = $GroupMap[$u.dept]
            if ($groupId) {
                try {
                    # Add member via REST ($ref)
                    $memberBody = @{
                        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$userId"
                    }
                    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/members/`$ref" -Body $memberBody -ErrorAction SilentlyContinue
                }
                catch {
                    # Ignore if already member
                }
            }
        }
        catch {
            Write-Error "Failed to create user ${upn}: $_"
        }
    }
    
    Write-Host "`n✅ Identity Hierarchy Deployment Complete." -ForegroundColor Green
}

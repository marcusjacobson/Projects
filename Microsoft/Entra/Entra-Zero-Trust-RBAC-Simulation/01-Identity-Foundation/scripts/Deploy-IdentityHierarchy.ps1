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
param()

process {
    # Connect to Graph
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    # Get Domain via REST
    $domains = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/domains"
    $Domain = ($domains.value | Where-Object { $_.isInitial }).id
    
    $PasswordProfile = @{
        password = "P@ssword123!"
        forceChangePasswordNextSignIn = $true
    }

    # 1. Define Departments and Groups
    $Departments = @("IT", "HR", "Finance", "Marketing", "Executive")
    
    Write-Host "🚀 Creating Departmental Groups..." -ForegroundColor Cyan
    
    $GroupMap = @{} # To store Group IDs

    foreach ($dept in $Departments) {
        $groupName = "GRP-SEC-$dept"
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
                    mailNickname = $groupName
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
    $Users = @(
        @{ Name = "USR-CEO"; Title = "CEO"; Dept = "Executive" },
        @{ Name = "USR-CISO"; Title = "CISO"; Dept = "Executive" },
        @{ Name = "USR-IT-Director"; Title = "IT Director"; Dept = "IT" },
        @{ Name = "USR-IT-Admin"; Title = "System Administrator"; Dept = "IT" },
        @{ Name = "USR-IT-Helpdesk"; Title = "Helpdesk Technician"; Dept = "IT" },
        @{ Name = "USR-HR-Director"; Title = "HR Director"; Dept = "HR" },
        @{ Name = "USR-HR-Manager"; Title = "HR Manager"; Dept = "HR" },
        @{ Name = "USR-Fin-Director"; Title = "Finance Director"; Dept = "Finance" },
        @{ Name = "USR-Fin-Analyst"; Title = "Financial Analyst"; Dept = "Finance" },
        @{ Name = "USR-Mkt-Director"; Title = "Marketing Director"; Dept = "Marketing" },
        @{ Name = "USR-Mkt-Specialist"; Title = "Marketing Specialist"; Dept = "Marketing" }
    )

    Write-Host "`n🚀 Creating Users..." -ForegroundColor Cyan

    foreach ($u in $Users) {
        $upn = "$($u.Name)@$Domain"
        
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
                    displayName = $u.Name
                    userPrincipalName = $upn
                    mailNickname = $u.Name
                    accountEnabled = $true
                    passwordProfile = $PasswordProfile
                    jobTitle = $u.Title
                    department = $u.Dept
                    usageLocation = "US"
                }
                
                $newUser = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/users" -Body $userParams
                Write-Host "   ✅ Created User '$upn'" -ForegroundColor Green
                $userId = $newUser.id
            }

            # Add to Department Group
            $groupId = $GroupMap[$u.Dept]
            if ($groupId) {
                try {
                    # Add member via REST ($ref)
                    $memberBody = @{
                        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$userId"
                    }
                    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/members/`$ref" -Body $memberBody -ErrorAction SilentlyContinue
                    Write-Verbose "Added $upn to $($u.Dept) group."
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
    Write-Host "   Default Password: P@ssword123!" -ForegroundColor Yellow
}

<#
.SYNOPSIS
    Deploys Administrative Units and populates them.

.DESCRIPTION
    Creates AUs for IT, HR, Finance, and Marketing.
    Adds users and groups to these AUs based on their naming convention/department.

.EXAMPLE
    .\Deploy-AdministrativeUnits.ps1

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
    DELEGATION MODEL
    - Scope: Departmental Administrative Units (AUs)
    - Membership: Static assignment (Simulation limitation)
    - Targets: Users and Groups by department
#>

[CmdletBinding()]
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    $Departments = @("IT", "HR", "Finance", "Marketing")

    Write-Host "🚀 Deploying Administrative Units..." -ForegroundColor Cyan

    foreach ($dept in $Departments) {
        $auName = "AU-$dept"
        $desc = "Administrative Unit for $dept"

        try {
            # 1. Create AU via REST
            $uri = "https://graph.microsoft.com/v1.0/directory/administrativeUnits?`$filter=displayName eq '$auName'"
            $existingResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
            $existing = $existingResponse.value | Select-Object -First 1

            if ($existing) {
                Write-Host "   ⚠️  AU '$auName' already exists." -ForegroundColor Yellow
                $auId = $existing.id
            }
            else {
                $body = @{
                    displayName = $auName
                    description = $desc
                }
                $au = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/directory/administrativeUnits" -Body $body
                Write-Host "   ✅ Created AU '$auName'" -ForegroundColor Green
                $auId = $au.id
            }

            # 2. Add Users (USR-$dept-*)
            # Filter users by department name via REST
            $usersUri = "https://graph.microsoft.com/v1.0/users?`$filter=department eq '$dept'"
            $usersResponse = Invoke-MgGraphRequest -Method GET -Uri $usersUri
            $users = $usersResponse.value
            
            foreach ($u in $users) {
                try {
                    $memberBody = @{
                        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($u.id)"
                    }
                    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$auId/members/`$ref" -Body $memberBody -ErrorAction SilentlyContinue
                    Write-Verbose "Added $($u.userPrincipalName) to $auName"
                } catch {}
            }
            
            Write-Host "   ✅ Populated '$auName' with $($users.Count) users." -ForegroundColor Green

            # 3. Add Groups (GRP-SEC-$dept)
            $groupName = "GRP-SEC-$dept"
            $groupUri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$groupName'"
            $groupResponse = Invoke-MgGraphRequest -Method GET -Uri $groupUri
            $group = $groupResponse.value | Select-Object -First 1

            if ($group) {
                try {
                    $memberBody = @{
                        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($group.id)"
                    }
                    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$auId/members/`$ref" -Body $memberBody -ErrorAction SilentlyContinue
                    Write-Host "   ✅ Added Group '$groupName' to '$auName'" -ForegroundColor Green
                } catch {}
            }

        }
        catch {
            Write-Error "Failed to process AU ${auName}: $_"
        }
    }
}

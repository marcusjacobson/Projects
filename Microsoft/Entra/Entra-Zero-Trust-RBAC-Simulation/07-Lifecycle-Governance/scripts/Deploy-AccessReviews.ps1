<#
.SYNOPSIS
    Deploys Access Reviews.

.DESCRIPTION
    Creates an Access Review for all Guest users.
    Reviewers: Self-review.
    Frequency: Quarterly.

.EXAMPLE
    .\Deploy-AccessReviews.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-24
    Last Modified: 2025-11-24
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    - Entra ID P2 License
    
    Script development orchestrated using GitHub Copilot.

.SPECIALIZED_SECTION
    REVIEW CONFIGURATION
    - Target: All Guest Users
    - Reviewer: Self-Review (or Admin fallback)
    - Frequency: Quarterly
    - Auto-Apply: Disabled (for safety)
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
            
            $ReviewName = $jsonParams."Deploy-AccessReviews".reviewName
            $ReviewDescription = $jsonParams."Deploy-AccessReviews".reviewDescription
            $GuestGroupName = $jsonParams."Deploy-AccessReviews".guestGroupName
            $ReviewDurationDays = $jsonParams."Deploy-AccessReviews".reviewDurationDays
            $ReviewIntervalMonths = $jsonParams."Deploy-AccessReviews".reviewIntervalMonths
            
            $AdminReviewName = $jsonParams."Deploy-AccessReviews".adminReviewName
            $AdminReviewDescription = $jsonParams."Deploy-AccessReviews".adminReviewDescription
            $AdminGroupName = $jsonParams."Deploy-AccessReviews".adminGroupName
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Deploying Access Reviews..." -ForegroundColor Cyan

    # Resolve Admin ID (Reviewer)
    $adminId = (Get-MgContext).Account
    if ($adminId -match "@") {
        $uUri = "https://graph.microsoft.com/v1.0/users/$adminId"
        $uRes = Invoke-MgGraphRequest -Method GET -Uri $uUri
        $adminId = $uRes.id
    }

    # 1. Ensure Dynamic Group for Guests Exists
    # (Direct query for 'All Guests' in Access Reviews is restricted, so we review a Dynamic Group instead)
    $groupUri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$GuestGroupName'"
    $groupRes = Invoke-MgGraphRequest -Method GET -Uri $groupUri
    $guestGroup = $groupRes.value | Select-Object -First 1
    
    if (-not $guestGroup) {
        Write-Host "   Creating Dynamic Group '$GuestGroupName'..." -ForegroundColor Gray
        try {
            $groupBody = @{
                displayName = $GuestGroupName
                description = "Dynamic group containing all guest users for Access Reviews"
                mailEnabled = $false
                mailNickname = $GuestGroupName -replace " ",""
                securityEnabled = $true
                groupTypes = @("DynamicMembership")
                membershipRule = '(user.userType -eq "Guest")'
                membershipRuleProcessingState = "On"
            }
            $jsonGroup = $groupBody | ConvertTo-Json
            $guestGroup = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups" -Body $jsonGroup -ContentType "application/json"
            Write-Host "   ✅ Created Dynamic Group '$GuestGroupName'" -ForegroundColor Green
        } catch {
            Throw "Failed to create Dynamic Group '$GuestGroupName': $_"
        }
    } else {
        Write-Host "   ℹ️ Dynamic Group '$GuestGroupName' already exists." -ForegroundColor Gray
    }
    $guestGroupId = $guestGroup.id

    # 2. Create Access Review
    $arUri = "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions?`$filter=displayName eq '$ReviewName'"
    $arResponse = Invoke-MgGraphRequest -Method GET -Uri $arUri
    $existing = $arResponse.value | Select-Object -First 1
    
    if (-not $existing) {
        try {
            $startDate = (Get-Date).ToString("yyyy-MM-dd")
            
            $body = @{
                displayName = $ReviewName
                descriptionForAdmins = $ReviewDescription
                descriptionForReviewers = $ReviewDescription
                scope = @{
                    "@odata.type" = "#microsoft.graph.accessReviewQueryScope"
                    query = "/groups/$guestGroupId/transitiveMembers"
                    queryType = "MicrosoftGraph"
                    queryRoot = $null
                }
                reviewers = @(
                    @{
                        query = "/users/$adminId"
                        queryType = "MicrosoftGraph"
                        queryRoot = $null
                    }
                )
                settings = @{
                    mailNotificationsEnabled = $true
                    reminderNotificationsEnabled = $true
                    justificationRequiredOnApproval = $true
                    defaultDecisionEnabled = $true
                    defaultDecision = "Deny"
                    instanceDurationInDays = $ReviewDurationDays
                    recurrence = @{
                        pattern = @{
                            type = "absoluteMonthly"
                            interval = $ReviewIntervalMonths
                        }
                        range = @{
                            type = "noEnd"
                            startDate = $startDate
                        }
                    }
                }
            }

            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions" -Body $body
            Write-Host "   ✅ Created Access Review '$ReviewName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "   ⚠️ Failed to create Access Review: $_"
        }
    } else {
        Write-Host "   ℹ️ Access Review '$ReviewName' already exists." -ForegroundColor Gray
    }

    # 3. Ensure Admin Group Exists
    $adminGroupUri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$AdminGroupName'"
    $adminGroupRes = Invoke-MgGraphRequest -Method GET -Uri $adminGroupUri
    $adminGroup = $adminGroupRes.value | Select-Object -First 1
    
    if (-not $adminGroup) {
        Write-Host "   Creating Admin Group '$AdminGroupName'..." -ForegroundColor Gray
        try {
            $adminGroupBody = @{
                displayName = $AdminGroupName
                description = "Group for Global Administrators Access Review"
                mailEnabled = $false
                mailNickname = $AdminGroupName -replace " ",""
                securityEnabled = $true
            }
            $jsonAdminGroup = $adminGroupBody | ConvertTo-Json
            $adminGroup = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups" -Body $jsonAdminGroup -ContentType "application/json"
            Write-Host "   ✅ Created Admin Group '$AdminGroupName'" -ForegroundColor Green
        } catch {
            Throw "Failed to create Admin Group '$AdminGroupName': $_"
        }
    } else {
        Write-Host "   ℹ️ Admin Group '$AdminGroupName' already exists." -ForegroundColor Gray
    }
    $adminGroupId = $adminGroup.id

    # 4. Create Admin Access Review
    $adminArUri = "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions?`$filter=displayName eq '$AdminReviewName'"
    $adminArResponse = Invoke-MgGraphRequest -Method GET -Uri $adminArUri
    $existingAdminAr = $adminArResponse.value | Select-Object -First 1
    
    if (-not $existingAdminAr) {
        try {
            $startDate = (Get-Date).ToString("yyyy-MM-dd")
            # Re-use adminId from previous step
            
            $adminBody = @{
                displayName = $AdminReviewName
                descriptionForAdmins = $AdminReviewDescription
                descriptionForReviewers = $AdminReviewDescription
                scope = @{
                    "@odata.type" = "#microsoft.graph.accessReviewQueryScope"
                    query = "/groups/$adminGroupId/transitiveMembers"
                    queryType = "MicrosoftGraph"
                    queryRoot = $null
                }
                reviewers = @(
                    @{
                        query = "/users/$adminId"
                        queryType = "MicrosoftGraph"
                        queryRoot = $null
                    }
                )
                settings = @{
                    mailNotificationsEnabled = $true
                    reminderNotificationsEnabled = $true
                    justificationRequiredOnApproval = $true
                    defaultDecisionEnabled = $true
                    defaultDecision = "Deny"
                    instanceDurationInDays = $ReviewDurationDays
                    recurrence = @{
                        pattern = @{
                            type = "absoluteMonthly"
                            interval = $ReviewIntervalMonths
                        }
                        range = @{
                            type = "noEnd"
                            startDate = $startDate
                        }
                    }
                }
            }

            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions" -Body $adminBody
            Write-Host "   ✅ Created Access Review '$AdminReviewName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "   ⚠️ Failed to create Admin Access Review: $_"
        }
    } else {
        Write-Host "   ℹ️ Access Review '$AdminReviewName' already exists." -ForegroundColor Gray
    }
}

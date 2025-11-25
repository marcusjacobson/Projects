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
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🚀 Deploying Access Reviews..." -ForegroundColor Cyan

    $reviewName = "AR-Quarterly-Guests"
    
    # Check if exists
    $arUri = "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions?`$filter=displayName eq '$reviewName'"
    $arResponse = Invoke-MgGraphRequest -Method GET -Uri $arUri
    $existing = $arResponse.value | Select-Object -First 1
    
    if (-not $existing) {
        try {
            $startDate = (Get-Date).ToString("yyyy-MM-dd")
            $adminId = (Get-MgContext).Account
            
            # Need to resolve admin ID if it's a UPN
            if ($adminId -match "@") {
                $uUri = "https://graph.microsoft.com/v1.0/users/$adminId"
                $uRes = Invoke-MgGraphRequest -Method GET -Uri $uUri
                $adminId = $uRes.id
            }

            $body = @{
                displayName = $reviewName
                descriptionForAdmins = "Quarterly review of all guest users"
                descriptionForReviewers = "Quarterly review of all guest users"
                scope = @{
                    "@odata.type" = "#microsoft.graph.accessReviewQueryScope"
                    query = "/users/?`$filter=(userType eq 'Guest')"
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
                    instanceDurationInDays = 14
                    recurrence = @{
                        pattern = @{
                            type = "absoluteMonthly"
                            interval = 3
                        }
                        range = @{
                            type = "noEnd"
                            startDate = $startDate
                        }
                    }
                }
            }

            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions" -Body $body
            Write-Host "   ✅ Created Access Review '$reviewName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "   ⚠️ Failed to create Access Review: $_"
        }
    } else {
        Write-Host "   ℹ️ Access Review '$reviewName' already exists." -ForegroundColor Gray
    }
}

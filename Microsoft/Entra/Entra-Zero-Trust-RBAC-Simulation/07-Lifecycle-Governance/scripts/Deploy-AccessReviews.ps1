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
            $ReviewDurationDays = $jsonParams."Deploy-AccessReviews".reviewDurationDays
            $ReviewIntervalMonths = $jsonParams."Deploy-AccessReviews".reviewIntervalMonths
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Deploying Access Reviews..." -ForegroundColor Cyan

    # Check if exists
    $arUri = "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions?`$filter=displayName eq '$ReviewName'"
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
                displayName = $ReviewName
                descriptionForAdmins = $ReviewDescription
                descriptionForReviewers = $ReviewDescription
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
}

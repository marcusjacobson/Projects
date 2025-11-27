<#
.SYNOPSIS
    Removes Lifecycle Governance configurations.

.DESCRIPTION
    Deletes Access Reviews and Lifecycle Workflows created in this module.
    - Access Review: AR-Quarterly-Guests
    - Lifecycle Workflow: WF-Leaver-Standard

.EXAMPLE
    .\Remove-LifecycleGovernance.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 07-Lifecycle-Governance
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
            $GuestGroupName = $jsonParams."Deploy-AccessReviews".guestGroupName
            $AdminReviewName = $jsonParams."Deploy-AccessReviews".adminReviewName
            $AdminGroupName = $jsonParams."Deploy-AccessReviews".adminGroupName
            $WorkflowName = $jsonParams."Configure-LifecycleWorkflows".workflowName
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Removing Lifecycle Governance Configurations..." -ForegroundColor Cyan

    # 1. Remove Guest Access Review
    Write-Host "   🔍 Checking for Access Review '$ReviewName'..." -ForegroundColor Gray
    try {
        $arUri = "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions?`$filter=displayName eq '$ReviewName'"
        $arResponse = Invoke-MgGraphRequest -Method GET -Uri $arUri
        $review = $arResponse.value | Select-Object -First 1

        if ($review) {
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions/$($review.id)"
            Write-Host "   🗑️ Deleted Access Review '$ReviewName'" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Access Review '$ReviewName' not found." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning "   ❌ Failed to delete Access Review '$ReviewName': $_"
    }

    # 2. Remove Admin Access Review
    Write-Host "   🔍 Checking for Access Review '$AdminReviewName'..." -ForegroundColor Gray
    try {
        $adminArUri = "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions?`$filter=displayName eq '$AdminReviewName'"
        $adminArResponse = Invoke-MgGraphRequest -Method GET -Uri $adminArUri
        $adminReview = $adminArResponse.value | Select-Object -First 1

        if ($adminReview) {
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions/$($adminReview.id)"
            Write-Host "   🗑️ Deleted Access Review '$AdminReviewName'" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Access Review '$AdminReviewName' not found." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning "   ❌ Failed to delete Access Review '$AdminReviewName': $_"
    }

    # 3. Remove Guest Group
    Write-Host "   🔍 Checking for Group '$GuestGroupName'..." -ForegroundColor Gray
    try {
        $gUri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$GuestGroupName'"
        $gResponse = Invoke-MgGraphRequest -Method GET -Uri $gUri
        $guestGroup = $gResponse.value | Select-Object -First 1

        if ($guestGroup) {
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/groups/$($guestGroup.id)"
            Write-Host "   🗑️ Deleted Group '$GuestGroupName'" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Group '$GuestGroupName' not found." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning "   ❌ Failed to delete Group '$GuestGroupName': $_"
    }

    # 4. Remove Admin Group
    Write-Host "   🔍 Checking for Group '$AdminGroupName'..." -ForegroundColor Gray
    try {
        $agUri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$AdminGroupName'"
        $agResponse = Invoke-MgGraphRequest -Method GET -Uri $agUri
        $adminGroup = $agResponse.value | Select-Object -First 1

        if ($adminGroup) {
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/groups/$($adminGroup.id)"
            Write-Host "   🗑️ Deleted Group '$AdminGroupName'" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Group '$AdminGroupName' not found." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning "   ❌ Failed to delete Group '$AdminGroupName': $_"
    }

    # 5. Remove Lifecycle Workflow
    Write-Host "   🔍 Checking for Lifecycle Workflow '$WorkflowName'..." -ForegroundColor Gray
    try {
        $wfUri = "https://graph.microsoft.com/v1.0/identityGovernance/lifecycleWorkflows/workflows?`$filter=displayName eq '$WorkflowName'"
        $wfResponse = Invoke-MgGraphRequest -Method GET -Uri $wfUri
        $workflow = $wfResponse.value | Select-Object -First 1

        if ($workflow) {
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/identityGovernance/lifecycleWorkflows/workflows/$($workflow.id)"
            Write-Host "   🗑️ Deleted Lifecycle Workflow '$WorkflowName'" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Lifecycle Workflow '$WorkflowName' not found." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning "   ❌ Failed to delete Lifecycle Workflow '$WorkflowName': $_"
    }
}

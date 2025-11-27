<#
.SYNOPSIS
    Configures Lifecycle Workflows.

.DESCRIPTION
    Creates a 'Leaver' workflow for offboarding.
    Tasks: Disable User, Remove from Groups.
    Trigger: 7 days before employeeLeaveDateTime.

.EXAMPLE
    .\Configure-LifecycleWorkflows.ps1

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
            
            $WorkflowName = $jsonParams."Configure-LifecycleWorkflows".workflowName
            $WorkflowDescription = $jsonParams."Configure-LifecycleWorkflows".workflowDescription
            $TriggerAttribute = $jsonParams."Configure-LifecycleWorkflows".triggerAttribute
            $ScopeRule = $jsonParams."Configure-LifecycleWorkflows".scopeRule
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    Write-Host "🚀 Configuring Lifecycle Workflows..." -ForegroundColor Cyan

    # 1. Get Task Definitions via REST
    try {
        $tasksUri = "https://graph.microsoft.com/v1.0/identityGovernance/lifecycleWorkflows/taskDefinitions"
        $tasksResponse = Invoke-MgGraphRequest -Method GET -Uri $tasksUri -ErrorAction Stop
        $tasks = $tasksResponse.value
    } catch {
        # Check for 401/403 or specific license messages
        if ($_.Exception.Message -match "Insufficient license" -or $_.Exception.Message -match "Forbidden" -or $_.Exception.Message -match "401" -or $_.Exception.Message -match "403") {
            Write-Warning "   ⚠️ LICENSE REQUIRED: Lifecycle Workflows require an 'Entra ID Governance' license."
            Write-Warning "   ⚠️ Your tenant appears to lack this license (Error: $($_.Exception.Message))."
            Write-Warning "   ⚠️ Skipping Lifecycle Workflow configuration. This is expected if you only have P2."
            return
        } else {
            Throw $_
        }
    }
    
    $disableTask = $tasks | Where-Object { $_.displayName -eq "Disable user account" }
    $removeGroupsTask = $tasks | Where-Object { $_.displayName -eq "Remove user from all groups" }
    $removeLicensesTask = $tasks | Where-Object { $_.displayName -eq "Remove all licenses for user" }
    
    if (-not $disableTask -or -not $removeGroupsTask -or -not $removeLicensesTask) {
        Write-Warning "   ⚠️ Could not find required Task Definitions. Lifecycle Workflows might not be enabled or supported in this tenant."
        return
    }

    # 2. Create Workflow
    $wfUri = "https://graph.microsoft.com/v1.0/identityGovernance/lifecycleWorkflows/workflows?`$filter=displayName eq '$WorkflowName'"
    $wfResponse = Invoke-MgGraphRequest -Method GET -Uri $wfUri
    $existing = $wfResponse.value | Select-Object -First 1
    
    if (-not $existing) {
        try {
            $body = @{
                category = "Leaver"
                displayName = $WorkflowName
                description = $WorkflowDescription
                isEnabled = $true
                isSchedulingEnabled = $true
                executionConditions = @{
                    "@odata.type" = "#microsoft.graph.identityGovernance.triggerAndScopeBasedConditions"
                    scope = @{
                        "@odata.type" = "#microsoft.graph.identityGovernance.ruleBasedSubjectSet"
                        rule = $ScopeRule
                    }
                    trigger = @{
                        "@odata.type" = "#microsoft.graph.identityGovernance.timeBasedAttributeTrigger"
                        timeBasedAttribute = $TriggerAttribute
                        offsetInDays = 0
                    }
                }
                tasks = @(
                    @{
                        taskDefinitionId = $disableTask.id
                        displayName = "Disable Account"
                        description = "Disables the user account"
                        isEnabled = $true
                        continueOnError = $true
                        executionSequence = 1
                        arguments = @()
                    },
                    @{
                        taskDefinitionId = $removeGroupsTask.id
                        displayName = "Remove Groups"
                        description = "Removes user from all groups"
                        isEnabled = $true
                        continueOnError = $true
                        executionSequence = 2
                        arguments = @()
                    },
                    @{
                        taskDefinitionId = $removeLicensesTask.id
                        displayName = "Remove Licenses"
                        description = "Removes all licenses from user"
                        isEnabled = $true
                        continueOnError = $true
                        executionSequence = 3
                        arguments = @()
                    }
                )
            }
            
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/lifecycleWorkflows/workflows" -Body $body
            Write-Host "   ✅ Created Workflow '$WorkflowName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "   ⚠️ Failed to create Workflow: $_"
        }
    } else {
        Write-Host "   ℹ️ Workflow '$WorkflowName' already exists." -ForegroundColor Gray
        Write-Host "   ℹ️ To recreate with updated tasks, please delete the existing workflow first." -ForegroundColor Gray
    }
}

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
    $tasksUri = "https://graph.microsoft.com/v1.0/identityGovernance/lifecycleWorkflows/taskDefinitions"
    $tasksResponse = Invoke-MgGraphRequest -Method GET -Uri $tasksUri
    $tasks = $tasksResponse.value
    
    $disableTask = $tasks | Where-Object { $_.displayName -eq "Disable user account" }
    $removeGroupsTask = $tasks | Where-Object { $_.displayName -eq "Remove user from all groups" }
    
    if (-not $disableTask -or -not $removeGroupsTask) {
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
                    "@odata.type" = "#microsoft.graph.triggerAndScopeBasedConditions"
                    scope = @{
                        "@odata.type" = "#microsoft.graph.subjectSet"
                        rule = $ScopeRule
                    }
                    trigger = @{
                        "@odata.type" = "#microsoft.graph.timeBasedAttributeTrigger"
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
                        order = 1
                        arguments = @()
                    },
                    @{
                        taskDefinitionId = $removeGroupsTask.id
                        displayName = "Remove Groups"
                        description = "Removes user from all groups"
                        isEnabled = $true
                        continueOnError = $true
                        order = 2
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
    }
}

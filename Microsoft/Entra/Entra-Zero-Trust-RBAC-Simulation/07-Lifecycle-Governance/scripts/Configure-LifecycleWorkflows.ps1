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
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🚀 Configuring Lifecycle Workflows..." -ForegroundColor Cyan

    # 1. Get Task Definitions
    # We need "Disable user account" and "Remove user from all groups"
    $tasks = Get-MgIdentityGovernanceLifecycleWorkflowTaskDefinition -All
    
    $disableTask = $tasks | Where-Object { $_.DisplayName -eq "Disable user account" }
    $removeGroupsTask = $tasks | Where-Object { $_.DisplayName -eq "Remove user from all groups" }
    
    if (-not $disableTask -or -not $removeGroupsTask) {
        Write-Warning "   ⚠️ Could not find required Task Definitions. Lifecycle Workflows might not be enabled or supported in this tenant."
        return
    }

    # 2. Create Workflow
    $wfName = "WF-Leaver-Standard"
    $existing = Get-MgIdentityGovernanceLifecycleWorkflow -Filter "DisplayName eq '$wfName'" -ErrorAction SilentlyContinue
    
    if (-not $existing) {
        try {
            $params = @{
                Category = "Leaver"
                DisplayName = $wfName
                Description = "Standard offboarding workflow"
                IsEnabled = $true
                IsSchedulingEnabled = $true
                ExecutionConditions = @{
                    "@odata.type" = "#microsoft.graph.triggerAndScopeBasedConditions"
                    Scope = @{
                        "@odata.type" = "#microsoft.graph.subjectSet"
                        Rule = "(department eq 'Marketing')"
                    }
                    Trigger = @{
                        "@odata.type" = "#microsoft.graph.timeBasedAttributeTrigger"
                        TimeBasedAttribute = "employeeLeaveDateTime"
                        OffsetInDays = 0
                    }
                }
                Tasks = @(
                    @{
                        TaskDefinitionId = $disableTask.Id
                        DisplayName = "Disable Account"
                        Description = "Disables the user account"
                        IsEnabled = $true
                        ContinueOnError = $true
                        Order = 1
                        Arguments = @()
                    },
                    @{
                        TaskDefinitionId = $removeGroupsTask.Id
                        DisplayName = "Remove Groups"
                        Description = "Removes user from all groups"
                        IsEnabled = $true
                        ContinueOnError = $true
                        Order = 2
                        Arguments = @()
                    }
                )
            }
            
            New-MgIdentityGovernanceLifecycleWorkflow -BodyParameter $params
            Write-Host "   ✅ Created Workflow '$wfName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "   ⚠️ Failed to create Workflow: $_"
        }
    } else {
        Write-Host "   ℹ️ Workflow '$wfName' already exists." -ForegroundColor Gray
    }
}

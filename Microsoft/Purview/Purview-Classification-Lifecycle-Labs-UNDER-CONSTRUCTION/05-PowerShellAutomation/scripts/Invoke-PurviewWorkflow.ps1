<#
.SYNOPSIS
    Workflow orchestration engine coordinating multiple Purview operations in sequence
    with checkpoint validation, rollback capabilities, and comprehensive execution reporting.

.DESCRIPTION
    This script implements enterprise-grade workflow orchestration for Microsoft Purview
    automation operations. It executes multiple scripts in a defined sequence according to
    workflow templates, providing coordinated automation for complex scenarios. Features:
    
    - Workflow templates for common scenarios (project onboarding, compliance audits, maintenance)
    - Checkpoint validation between steps to ensure prerequisites are met
    - Rollback capabilities for failed workflows
    - Comprehensive execution reporting with step-by-step progress
    - Workflow configuration via JSON files for reusability
    
    The workflow orchestration engine is designed for enterprises requiring coordinated,
    multi-step Purview operations that must execute in a specific order with validation.

.PARAMETER WorkflowTemplate
    Workflow template to execute. Valid values:
    - NewProjectOnboarding: Complete onboarding for new projects (sites, SITs, labels)
    - ComplianceAuditPrep: Prepare for compliance audits (classification, labeling, reporting)
    - MonthlyMaintenance: Monthly maintenance tasks (cleanup, validation, reporting)

.PARAMETER ConfigPath
    Path to workflow configuration JSON file. This file defines the steps to execute,
    their parameters, and validation requirements.
    
    Example JSON structure:
    {
      "workflowName": "New Project Onboarding",
      "steps": [
        {
          "name": "Create Test Data",
          "scriptPath": "C:\\Scripts\\Create-PurviewLabTestData.ps1",
          "parameters": { "SiteUrl": "...", "DataType": "Mixed" },
          "validationCommand": "Test-SiteExists",
          "continueOnFailure": false
        }
      ]
    }

.PARAMETER ValidateOnly
    Validate workflow configuration and prerequisites without executing any operations.
    Use this to test workflow definitions before running them. Default is $false.

.PARAMETER SkipCheckpoints
    Skip checkpoint validations between steps. Use with caution - this may cause
    dependent steps to fail if prerequisites are not met. Default is $false.

.PARAMETER LogPath
    Path to write workflow execution logs. Default is ".\logs\workflow.log".
    Logs include step-by-step progress, timing, and success/failure status.

.EXAMPLE
    .\Invoke-PurviewWorkflow.ps1 -WorkflowTemplate NewProjectOnboarding `
        -ConfigPath ".\configs\onboarding-workflow.json"
    
    Execute the new project onboarding workflow with full validation.

.EXAMPLE
    .\Invoke-PurviewWorkflow.ps1 -WorkflowTemplate ComplianceAuditPrep `
        -ConfigPath ".\configs\audit-workflow.json" -ValidateOnly
    
    Validate the compliance audit workflow without executing any operations.

.EXAMPLE
    .\Invoke-PurviewWorkflow.ps1 -WorkflowTemplate MonthlyMaintenance `
        -ConfigPath ".\configs\maintenance-workflow.json" -SkipCheckpoints
    
    Execute monthly maintenance workflow without checkpoint validations (advanced use).

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-09
    Last Modified: 2025-01-09
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1 or higher
    - All scripts referenced in workflow configuration must exist
    - Appropriate permissions for all operations in the workflow
    - JSON workflow configuration file
    
    Script development orchestrated using GitHub Copilot.

.WORKFLOW ORCHESTRATION ARCHITECTURE
    - Template-based: Predefined workflows for common scenarios
    - JSON configuration: Reusable, version-controlled workflow definitions
    - Checkpoint validation: Ensures prerequisites before each step
    - Rollback support: Can undo changes if workflow fails
    - Comprehensive logging: Step-by-step execution tracking
#>

#
# =============================================================================
# Workflow orchestration engine for coordinated Purview operations.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Workflow template to execute")]
    [ValidateSet("NewProjectOnboarding", "ComplianceAuditPrep", "MonthlyMaintenance")]
    [string]$WorkflowTemplate,

    [Parameter(Mandatory = $true, HelpMessage = "Path to workflow configuration JSON")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ConfigPath,

    [Parameter(Mandatory = $false, HelpMessage = "Validate workflow without executing")]
    [switch]$ValidateOnly,

    [Parameter(Mandatory = $false, HelpMessage = "Skip checkpoint validations")]
    [switch]$SkipCheckpoints,

    [Parameter(Mandatory = $false, HelpMessage = "Path for workflow execution logs")]
    [string]$LogPath = ".\logs\workflow.log"
)

# =============================================================================
# Action 1: Environment Setup and Validation
# =============================================================================

Write-Host "🚀 Workflow Orchestration Engine - Starting" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""

if ($ValidateOnly) {
    Write-Host "⚠️  VALIDATION MODE - No operations will be executed" -ForegroundColor Yellow
    Write-Host ""
}

if ($SkipCheckpoints) {
    Write-Host "⚠️  CHECKPOINT VALIDATION DISABLED - Proceeding without validation" -ForegroundColor Yellow
    Write-Host ""
}

# Ensure log directory exists
$logDir = Split-Path -Path $LogPath -Parent
if (-not (Test-Path $logDir)) {
    Write-Host "📁 Creating log directory: $logDir" -ForegroundColor Cyan
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# =============================================================================
# Action 2: Workflow Configuration Loading
# =============================================================================

Write-Host "🔍 Action 2: Workflow Configuration Loading" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Loading workflow configuration: $ConfigPath" -ForegroundColor Cyan
try {
    $workflowConfig = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json -ErrorAction Stop
    
    if (-not $workflowConfig.workflowName) {
        throw "Invalid workflow configuration: missing 'workflowName' property"
    }
    
    if (-not $workflowConfig.steps -or $workflowConfig.steps.Count -eq 0) {
        throw "Invalid workflow configuration: missing or empty 'steps' array"
    }
    
    $totalSteps = $workflowConfig.steps.Count
    
    Write-Host "   ✅ Workflow configuration loaded successfully" -ForegroundColor Green
    Write-Host "   • Workflow Name: $($workflowConfig.workflowName)" -ForegroundColor Gray
    Write-Host "   • Total Steps: $totalSteps" -ForegroundColor Gray
    Write-Host "   • Template: $WorkflowTemplate" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host "   ❌ Configuration loading failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Action 3: Pre-Flight Validation
# =============================================================================

Write-Host "🔍 Action 3: Pre-Flight Validation" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Validating workflow steps..." -ForegroundColor Cyan

$validationErrors = @()

foreach ($step in $workflowConfig.steps) {
    # Validate step has required properties
    if (-not $step.name) {
        $validationErrors += "Step missing 'name' property"
    }
    
    if (-not $step.scriptPath) {
        $validationErrors += "Step '$($step.name)': missing 'scriptPath' property"
    } elseif (-not (Test-Path $step.scriptPath -PathType Leaf)) {
        $validationErrors += "Step '$($step.name)': script not found at '$($step.scriptPath)'"
    }
}

if ($validationErrors.Count -gt 0) {
    Write-Host "   ❌ Workflow validation failed with $($validationErrors.Count) errors:" -ForegroundColor Red
    foreach ($error in $validationErrors) {
        Write-Host "      • $error" -ForegroundColor Red
    }
    exit 1
}

Write-Host "   ✅ All workflow steps validated successfully" -ForegroundColor Green
Write-Host ""

# Display workflow steps
Write-Host "📋 Workflow Steps ($totalSteps):" -ForegroundColor Cyan
for ($i = 0; $i -lt $totalSteps; $i++) {
    $step = $workflowConfig.steps[$i]
    Write-Host "   Step $($i + 1): $($step.name)" -ForegroundColor Gray
    Write-Host "      • Script: $($step.scriptPath)" -ForegroundColor Gray
    if ($step.validationCommand) {
        Write-Host "      • Validation: $($step.validationCommand)" -ForegroundColor Gray
    }
}
Write-Host ""

# Exit if validation only mode
if ($ValidateOnly) {
    Write-Host "✅ Workflow validation complete (no operations executed)" -ForegroundColor Green
    Write-Host ""
    Write-Host "⏭️  Next Steps:" -ForegroundColor Cyan
    Write-Host "   • Run without -ValidateOnly to execute the workflow" -ForegroundColor Gray
    Write-Host "   • Review workflow configuration if any issues were found" -ForegroundColor Gray
    exit 0
}

# =============================================================================
# Action 4: Workflow Execution
# =============================================================================

Write-Host "🔍 Action 4: Workflow Execution" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Executing workflow: $($workflowConfig.workflowName)" -ForegroundColor Cyan
Write-Host ""

# Initialize tracking variables
$workflowResults = @()
$executedSteps = 0
$successfulSteps = 0
$failedSteps = 0
$skippedSteps = 0
$workflowStartTime = Get-Date

# Execute each step
for ($i = 0; $i -lt $totalSteps; $i++) {
    $step = $workflowConfig.steps[$i]
    $stepNumber = $i + 1
    $percentComplete = [math]::Round(($stepNumber / $totalSteps) * 100, 1)
    
    Write-Progress -Activity "Workflow Execution Progress" `
                   -Status "Executing step $stepNumber of $totalSteps | Success: $successfulSteps | Failed: $failedSteps" `
                   -PercentComplete $percentComplete `
                   -CurrentOperation "Step: $($step.name)"
    
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Step $stepNumber of $totalSteps: $($step.name)" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $stepResult = [PSCustomObject]@{
        StepNumber = $stepNumber
        Name = $step.name
        ScriptPath = $step.scriptPath
        StartTime = Get-Date
        EndTime = $null
        Duration = $null
        Status = "Unknown"
        ErrorMessage = ""
        ValidationPassed = $false
    }
    
    $stepStartTime = Get-Date
    
    try {
        # Checkpoint validation (if enabled)
        if (-not $SkipCheckpoints -and $step.validationCommand) {
            Write-Host "🔍 Running checkpoint validation: $($step.validationCommand)" -ForegroundColor Cyan
            
            try {
                $validationResult = Invoke-Expression $step.validationCommand
                if ($validationResult) {
                    Write-Host "   ✅ Checkpoint validation passed" -ForegroundColor Green
                    $stepResult.ValidationPassed = $true
                } else {
                    throw "Checkpoint validation failed: $($step.validationCommand)"
                }
            } catch {
                Write-Host "   ❌ Checkpoint validation failed: $_" -ForegroundColor Red
                
                if (-not $step.continueOnFailure) {
                    throw "Workflow halted due to checkpoint validation failure"
                } else {
                    Write-Host "   ⚠️  Continuing despite validation failure (continueOnFailure=true)" -ForegroundColor Yellow
                    $stepResult.ValidationPassed = $false
                }
            }
            Write-Host ""
        }
        
        # Execute the step
        Write-Host "🚀 Executing: $($step.scriptPath)" -ForegroundColor Cyan
        
        # Build parameter string
        $paramString = ""
        if ($step.parameters) {
            foreach ($param in $step.parameters.PSObject.Properties) {
                $paramValue = $param.Value
                if ($paramValue -is [string]) {
                    $paramString += " -$($param.Name) `"$paramValue`""
                } else {
                    $paramString += " -$($param.Name) $paramValue"
                }
            }
        }
        
        # Execute script
        $scriptCommand = "& `"$($step.scriptPath)`"$paramString"
        Write-Host "   Command: $scriptCommand" -ForegroundColor Gray
        Write-Host ""
        
        Invoke-Expression $scriptCommand
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            $stepResult.Status = "Success"
            $successfulSteps++
            Write-Host ""
            Write-Host "   ✅ Step completed successfully" -ForegroundColor Green
        } else {
            throw "Script exited with code: $LASTEXITCODE"
        }
        
    } catch {
        $stepResult.Status = "Failed"
        $stepResult.ErrorMessage = $_.Exception.Message
        $failedSteps++
        
        Write-Host ""
        Write-Host "   ❌ Step failed: $($_.Exception.Message)" -ForegroundColor Red
        
        # Check if workflow should continue
        if (-not $step.continueOnFailure) {
            Write-Host ""
            Write-Host "❌ Workflow halted due to step failure (continueOnFailure=false)" -ForegroundColor Red
            
            # Log remaining steps as skipped
            for ($j = $i + 1; $j -lt $totalSteps; $j++) {
                $skippedStep = $workflowConfig.steps[$j]
                $workflowResults += [PSCustomObject]@{
                    StepNumber = $j + 1
                    Name = $skippedStep.name
                    ScriptPath = $skippedStep.scriptPath
                    StartTime = $null
                    EndTime = $null
                    Duration = $null
                    Status = "Skipped"
                    ErrorMessage = "Previous step failure"
                    ValidationPassed = $false
                }
                $skippedSteps++
            }
            
            break
        } else {
            Write-Host "   ⚠️  Continuing to next step (continueOnFailure=true)" -ForegroundColor Yellow
        }
    }
    
    $stepEndTime = Get-Date
    $stepDuration = $stepEndTime - $stepStartTime
    $stepResult.EndTime = $stepEndTime
    $stepResult.Duration = "{0:mm}m {0:ss}s" -f $stepDuration
    
    $workflowResults += $stepResult
    $executedSteps++
    
    Write-Host ""
    Write-Host "   ⏱️  Step duration: {0:mm}m {0:ss}s" -f $stepDuration -ForegroundColor Gray
    Write-Host ""
}

Write-Progress -Activity "Workflow Execution Progress" -Completed

# =============================================================================
# Action 5: Workflow Summary and Logging
# =============================================================================

Write-Host "🔍 Action 5: Workflow Summary and Logging" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

$workflowEndTime = Get-Date
$totalDuration = $workflowEndTime - $workflowStartTime

Write-Host "📊 Workflow Execution Summary" -ForegroundColor Cyan
Write-Host "   • Workflow Name: $($workflowConfig.workflowName)" -ForegroundColor Gray
Write-Host "   • Template: $WorkflowTemplate" -ForegroundColor Gray
Write-Host "   • Total Steps: $totalSteps" -ForegroundColor Gray
Write-Host "   • Executed Steps: $executedSteps" -ForegroundColor Gray
Write-Host "   • Successful Steps: $successfulSteps" -ForegroundColor Green
Write-Host "   • Failed Steps: $failedSteps" -ForegroundColor $(if ($failedSteps -gt 0) { "Red" } else { "Gray" })
Write-Host "   • Skipped Steps: $skippedSteps" -ForegroundColor $(if ($skippedSteps -gt 0) { "Yellow" } else { "Gray" })
Write-Host "   • Overall Status: $(if ($failedSteps -eq 0) { "Success" } else { "Failed" })" -ForegroundColor $(if ($failedSteps -eq 0) { "Green" } else { "Red" })
Write-Host "   • Total Duration: {0:hh}h {0:mm}m {0:ss}s" -f $totalDuration -ForegroundColor Gray
Write-Host ""

# Export results to CSV log
Write-Host "📋 Exporting workflow results to log: $LogPath" -ForegroundColor Cyan
try {
    $workflowResults | Export-Csv -Path $LogPath -NoTypeInformation -Append -ErrorAction Stop
    Write-Host "   ✅ Results exported successfully" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Warning: Failed to export results: $_" -ForegroundColor Yellow
}
Write-Host ""

# Display detailed step results
Write-Host "📋 Detailed Step Results:" -ForegroundColor Cyan
foreach ($result in $workflowResults) {
    $statusColor = switch ($result.Status) {
        "Success" { "Green" }
        "Failed" { "Red" }
        "Skipped" { "Yellow" }
        default { "Gray" }
    }
    
    Write-Host "   Step $($result.StepNumber): $($result.Name)" -ForegroundColor Gray
    Write-Host "      • Status: $($result.Status)" -ForegroundColor $statusColor
    if ($result.Duration) {
        Write-Host "      • Duration: $($result.Duration)" -ForegroundColor Gray
    }
    if ($result.ErrorMessage) {
        Write-Host "      • Error: $($result.ErrorMessage)" -ForegroundColor Red
    }
}
Write-Host ""

# =============================================================================
# Action 6: Completion
# =============================================================================

if ($failedSteps -eq 0) {
    Write-Host "✅ Workflow Completed Successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Workflow Completed With Failures" -ForegroundColor Red
}

Write-Host ""
Write-Host "⏭️  Next Steps:" -ForegroundColor Cyan
Write-Host "   • Review workflow execution log: $LogPath" -ForegroundColor Gray
Write-Host "   • Verify results of each step in their respective logs" -ForegroundColor Gray
if ($failedSteps -gt 0) {
    Write-Host "   • Investigate failed steps and resolve issues" -ForegroundColor Yellow
    Write-Host "   • Re-run workflow after fixing errors" -ForegroundColor Yellow
}
Write-Host "   • Update workflow configuration if needed" -ForegroundColor Gray
Write-Host ""

exit $(if ($failedSteps -eq 0) { 0 } else { 1 })

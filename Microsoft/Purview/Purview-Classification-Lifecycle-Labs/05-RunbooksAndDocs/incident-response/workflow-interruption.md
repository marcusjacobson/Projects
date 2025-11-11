# Incident Response Runbook: Workflow Interruption

## Document Information

**Severity**: High  
**Estimated Resolution Time**: 30-60 minutes  
**Required Permissions**: Purview Administrator, SharePoint Administrator  
**Last Updated**: 2025-11-11

## Purpose

This runbook provides procedures for recovering from workflow orchestration failures. Use this when workflow scripts fail mid-execution, checkpoint validations fail unexpectedly, or rollback procedures are needed.

## Symptoms

- Workflow stops mid-execution with partial completion.
- Checkpoint validation failures halt workflow progress.
- Steps complete but subsequent steps don't execute.
- Workflow log shows inconsistent or missing step completion.
- Resources left in incomplete state after workflow failure.

**Impact**: Partial configurations may cause inconsistencies, manual intervention required to complete or rollback operations.

## Investigation Steps

### Step 1: Identify Failed Workflow Step

Determine which workflow step failed and why.

```powershell
# Review workflow execution log
Get-Content ".\logs\workflow.log" -Tail 100 | Select-String -Pattern "failed|error" -Context 5,5

# Check workflow result CSV
Import-Csv ".\logs\workflow.log" | Where-Object { $_.Status -eq "Failed" } | Select-Object StepNumber, Name, ErrorMessage
```

### Step 2: Assess Completed Steps

Identify which steps completed successfully before failure.

```powershell
# List successful steps
Import-Csv ".\logs\workflow.log" | Where-Object { $_.Status -eq "Success" } | Select-Object StepNumber, Name, Duration
```

### Step 3: Validate System State

Check if partial execution created inconsistent state.

```powershell
# Example: Check if SITs were created but classification didn't run
Connect-IPPSSession
$customSITs = Get-DlpSensitiveInformationType | Where-Object { $_.Publisher -ne "Microsoft Corporation" }
Write-Host "Custom SITs found: $($customSITs.Count)"

# Check classification log for activity
$classificationActivity = Get-Content ".\logs\classification.log" -Tail 50 | Select-String -Pattern "success|completed"
if ($classificationActivity.Count -eq 0) {
    Write-Warning "No recent classification activity - workflow may have stopped before classification step"
}
```

## Resolution Procedures

### Resolution Step 1: Review and Fix Failed Step

Address the specific issue that caused step failure.

```powershell
# Identify error
$failedSteps = Import-Csv ".\logs\workflow.log" | Where-Object { $_.Status -eq "Failed" }
$failedSteps | ForEach-Object {
    Write-Host "Failed Step: $($_.Name)" -ForegroundColor Red
    Write-Host "  Error: $($_.ErrorMessage)" -ForegroundColor Yellow
    Write-Host "  Script: $($_.ScriptPath)" -ForegroundColor Cyan
}

# Fix the issue (e.g., permissions, missing files, etc.)
# Then test the failed step independently
& $failedSteps[0].ScriptPath
```

### Resolution Step 2: Resume from Checkpoint

Restart workflow from the failed step if safe to do so.

**Modify Workflow Configuration:**

```json
{
  "workflowName": "Resume from Step 3",
  "steps": [
    {
      "name": "Step 3: Classification (Resume)",
      "scriptPath": "C:\\Scripts\\Invoke-BulkClassification.ps1",
      "parameters": { "SiteListCsv": "sites.csv" },
      "continueOnFailure": false
    },
    {
      "name": "Step 4: Label Application",
      "scriptPath": "C:\\Scripts\\Invoke-BulkLabelApplication.ps1",
      "parameters": { "LabelConfigCsv": "labels.csv" }
    }
  ]
}
```

**Execute Resume Workflow:**

```powershell
.\Invoke-PurviewWorkflow.ps1 -WorkflowTemplate Custom -ConfigPath ".\configs\resume-workflow.json"
```

### Resolution Step 3: Rollback Partial Changes (If Needed)

Undo changes made by completed steps if workflow cannot be resumed.

```powershell
# Example: Remove SITs created in Step 2 if workflow must restart from beginning
$sitsToRemove = Get-DlpSensitiveInformationType | Where-Object {
    $_.Publisher -ne "Microsoft Corporation" -and $_.Name -like "*Project*"
}

$sitsToRemove | ForEach-Object {
    Write-Host "Removing SIT: $($_.Name)" -ForegroundColor Yellow
    Remove-DlpSensitiveInformationType -Identity $_.Name -Confirm:$false
}

# Example: Revert label applications from Step 3
# (Typically not needed unless labels were incorrectly applied)
```

### Resolution Step 4: Execute Full Workflow with Skip Checkpoints

If checkpoint validation is causing false failures, temporarily skip validation.

```powershell
# Run workflow without checkpoint validation
.\Invoke-PurviewWorkflow.ps1 `
    -WorkflowTemplate NewProjectOnboarding `
    -ConfigPath ".\configs\onboarding-workflow.json" `
    -SkipCheckpoints
```

**⚠️ Warning**: Only use `-SkipCheckpoints` if you've verified checkpoint failures are false positives.

### Resolution Step 5: Update Workflow Configuration

Improve workflow resilience for future executions.

**Add continueOnFailure for Non-Critical Steps:**

```json
{
  "name": "Generate Report",
  "scriptPath": "C:\\Scripts\\Export-PurviewReport.ps1",
  "parameters": { "ReportType": "Executive" },
  "continueOnFailure": true  // Allow workflow to complete even if reporting fails
}
```

**Add Validation Commands:**

```json
{
  "name": "Create SITs",
  "scriptPath": "C:\\Scripts\\Invoke-BulkSITCreation.ps1",
  "validationCommand": "$null -ne (Get-DlpSensitiveInformationType -Identity 'Project Code')",
  "continueOnFailure": false
}
```

## Verification

**Verification Checklist:**

- [ ] Failed step identified and root cause addressed.
- [ ] Workflow completes successfully (resumed or full restart).
- [ ] All expected resources created (SITs, labels, classifications).
- [ ] No orphaned or incomplete configurations remaining.
- [ ] Workflow log shows all steps completed with Success status.

**Validation Commands:**

```powershell
# Verify workflow completion
$workflowResults = Import-Csv ".\logs\workflow.log"
$successCount = ($workflowResults | Where-Object { $_.Status -eq "Success" }).Count
$failedCount = ($workflowResults | Where-Object { $_.Status -eq "Failed" }).Count
Write-Host "Successful Steps: $successCount | Failed Steps: $failedCount" -ForegroundColor Cyan

# Verify all expected resources exist
Connect-IPPSSession
$expectedSITs = @("Employee Badge ID", "Project Code")  # Customize for your workflow
$existingSITs = Get-DlpSensitiveInformationType | Where-Object { $expectedSITs -contains $_.Name }
Write-Host "Found $($existingSITs.Count) of $($expectedSITs.Count) expected SITs" -ForegroundColor Cyan
```

## Prevention

**Workflow Design Best Practices:**

- Design workflows with clear step boundaries and minimal dependencies.
- Use `continueOnFailure: true` for non-critical steps (reporting, notifications).
- Implement comprehensive checkpoint validation for critical dependencies.
- Keep workflow steps idempotent (safe to run multiple times).

**Testing:**

- Test workflows in non-production environment first.
- Validate each step independently before chaining in workflow.
- Practice rollback procedures during maintenance windows.
- Document known failure scenarios and recovery steps.

**Monitoring:**

- Review workflow logs after each execution.
- Set up alerts for workflow failures.
- Track workflow success rates and common failure points.
- Include workflow status in operational dashboards.

## Escalation Criteria

Escalate if:

- Unable to determine safe rollback procedure.
- Partial execution created data integrity concerns.
- Workflow required for time-sensitive compliance deadline.
- Repeated failures despite fixing identified issues.

**Required Information:**

- Complete workflow configuration JSON.
- Workflow execution log with all steps.
- Error messages from failed steps.
- Current system state (resources created, etc.).

## Related Runbooks

- **Classification Failure**: See `incident-response/classification-failure.md`
- **Permission Denied**: See `incident-response/permission-denied.md`
- **System Validation**: See `health-checks/system-validation.md`

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This runbook is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*

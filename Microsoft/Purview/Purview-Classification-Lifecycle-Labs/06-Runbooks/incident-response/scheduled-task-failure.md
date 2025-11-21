# Incident Response Runbook: Scheduled Task Failure

## Document Information

**Severity**: Medium  
**Estimated Resolution Time**: 20-40 minutes  
**Required Permissions**: Local Administrator (on task scheduler host)  
**Last Updated**: 2025-11-11

## Purpose

This runbook provides procedures for diagnosing and resolving scheduled task failures in Microsoft Purview automation. Use this when scheduled PowerShell tasks fail to execute, complete with errors, or run but produce no results.

## Symptoms

Common indicators of scheduled task issues:

- Scheduled task shows "Last Run Result" with non-zero error code.
- Task executes but PowerShell script doesn't perform expected operations.
- Logs show no activity at scheduled execution time.
- Task appears to run but completes instantly (indicates script didn't execute).
- Email notifications not sent despite task completion.
- Task history shows "The operator or administrator has refused the request (0x800710E0)".

**Impact Assessment**:

- **Service**: Automated operations not executing on schedule.
- **Users**: Classification and labeling updates delayed.
- **Data**: Processing backlog accumulates until resolved.

## Investigation Steps

### Step 1: Check Task Execution History

Review recent task execution attempts and results.

**Using Task Scheduler UI:**

Navigate to task history.

- Open **Task Scheduler** (taskschd.msc).
- Navigate to **Task Scheduler Library**.
- Find and select your Purview task.
- Click **History** tab (enable if disabled).

Review recent execution attempts.

- Look for **Task Started** and **Task Completed** events.
- Check **Last Run Result** code.
- Note **Last Run Time** vs expected schedule.

**Using PowerShell:**

```powershell
# Get task information
$taskName = "Purview Nightly Classification"
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($task) {
    $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName
    
    Write-Host "Task Status Information:" -ForegroundColor Cyan
    Write-Host "  Task Name: $($task.TaskName)" -ForegroundColor Gray
    Write-Host "  State: $($task.State)" -ForegroundColor Gray
    Write-Host "  Last Run Time: $($taskInfo.LastRunTime)" -ForegroundColor Gray
    Write-Host "  Last Result: 0x$([Convert]::ToString($taskInfo.LastTaskResult, 16).PadLeft(8, '0'))" -ForegroundColor Gray
    Write-Host "  Next Run Time: $($taskInfo.NextRunTime)" -ForegroundColor Gray
    Write-Host "  Number of Missed Runs: $($taskInfo.NumberOfMissedRuns)" -ForegroundColor Gray
} else {
    Write-Host "Task '$taskName' not found" -ForegroundColor Red
}
```

**Common Error Codes**:

| Error Code | Meaning | Common Cause |
|------------|---------|--------------|
| 0x0 | Success | Task completed successfully |
| 0x1 | Incorrect function | Script path or parameters invalid |
| 0x800710E0 | Operator refused | Credentials invalid or expired |
| 0x80041301 | Task not scheduled | Task disabled or trigger not set |
| 0xFFFD0000 | Launch failure | PowerShell execution policy block |
| 0xC000013A | Application terminated | Script killed or crashed |

### Step 2: Validate Task Configuration

Check that task is configured correctly.

**Check Task Trigger:**

```powershell
$task = Get-ScheduledTask -TaskName "Purview Nightly Classification"
$task.Triggers | ForEach-Object {
    Write-Host "Trigger Type: $($_.CimClass.CimClassName)" -ForegroundColor Cyan
    Write-Host "  Enabled: $($_.Enabled)" -ForegroundColor Gray
    Write-Host "  Start Boundary: $($_.StartBoundary)" -ForegroundColor Gray
    if ($_.CimClass.CimClassName -eq "MSFT_TaskDailyTrigger") {
        Write-Host "  Days Interval: $($_.DaysInterval)" -ForegroundColor Gray
    }
}
```

**Check Task Action:**

```powershell
$task.Actions | ForEach-Object {
    Write-Host "Action Type: $($_.CimClass.CimClassName)" -ForegroundColor Cyan
    Write-Host "  Execute: $($_.Execute)" -ForegroundColor Gray
    Write-Host "  Arguments: $($_.Arguments)" -ForegroundColor Gray
    Write-Host "  Working Directory: $($_.WorkingDirectory)" -ForegroundColor Gray
}
```

**Check Task Principal (Run As Account):**

```powershell
$task.Principal | ForEach-Object {
    Write-Host "Principal Configuration:" -ForegroundColor Cyan
    Write-Host "  User ID: $($_.UserId)" -ForegroundColor Gray
    Write-Host "  Logon Type: $($_.LogonType)" -ForegroundColor Gray
    Write-Host "  Run Level: $($_.RunLevel)" -ForegroundColor Gray
}
```

### Step 3: Test Script Execution Manually

Verify the PowerShell script works when run manually.

**Run Script in PowerShell:**

```powershell
# Navigate to script directory
Set-Location "C:\Scripts"

# Execute script manually with same parameters as task
.\Invoke-BulkClassification.ps1 -SiteListCsv "C:\Configs\sites.csv" -MaxConcurrent 5

# Check for errors
if ($LASTEXITCODE -eq 0) {
    Write-Host "Script executed successfully (exit code 0)" -ForegroundColor Green
} else {
    Write-Host "Script failed with exit code: $LASTEXITCODE" -ForegroundColor Red
}
```

**Test with Task Context (Run As System):**

```powershell
# Use PsExec to run as SYSTEM account (download from Sysinternals)
# psexec -i -s powershell.exe

# Then run script to test in SYSTEM context
Set-Location "C:\Scripts"
.\Invoke-BulkClassification.ps1 -SiteListCsv "C:\Configs\sites.csv" -MaxConcurrent 5
```

**Expected Result**: Script executes and completes successfully.

If script fails when run manually, issue is with script itself, not task scheduler. See related runbooks.

### Step 4: Review PowerShell Execution Policy

Check if execution policy is blocking script execution.

**Check Execution Policy:**

```powershell
# Check current execution policy
Get-ExecutionPolicy -List

# Expected output should show RemoteSigned or Unrestricted for LocalMachine or CurrentUser
```

**Expected Configuration**:

| Scope | Recommended Policy | Purpose |
|-------|-------------------|---------|
| **LocalMachine** | RemoteSigned | Allow signed scripts and local scripts |
| **CurrentUser** | RemoteSigned | User-level policy |
| **Process** | Bypass | Only for current PowerShell session |

**Check for Group Policy Restrictions:**

```powershell
# This will show effective policy including GPO-enforced settings
Get-ExecutionPolicy -Scope LocalMachine
```

If execution policy is **Restricted** or **AllSigned**, proceed to Resolution Step 3.

### Step 5: Validate Credentials and Permissions

Ensure the task's run-as account has required permissions.

**Test Account Credentials:**

Check if password has expired or changed.

- In Task Scheduler, right-click task → **Properties**.
- Go to **General** tab.
- Note the account under "When running the task, use the following user account".
- Verify account is not disabled or password expired in Active Directory.

**Test Account Permissions:**

```powershell
# Run script with specific credentials
$cred = Get-Credential -UserName "DOMAIN\ServiceAccount" -Message "Enter service account credentials"

Start-Process powershell.exe -Credential $cred -ArgumentList "-File C:\Scripts\Invoke-BulkClassification.ps1 -SiteListCsv C:\Configs\sites.csv" -Wait -NoNewWindow
```

**Expected Result**: Script executes successfully with service account credentials.

## Resolution Procedures

### Resolution Step 1: Fix Task Configuration

Correct any misconfigured task settings.

**Recreate Task with Correct Settings:**

```powershell
# Remove existing task
Unregister-ScheduledTask -TaskName "Purview Nightly Classification" -Confirm:$false

# Recreate with correct configuration using Lab 4 script
.\New-PurviewScheduledTask.ps1 `
    -TaskName "Purview Nightly Classification" `
    -ScriptPath "C:\Scripts\Invoke-BulkClassification.ps1" `
    -Trigger Daily `
    -StartTime "02:00:00" `
    -RunAsUser "DOMAIN\ServiceAccount" `
    -ScriptParameters @{
        SiteListCsv = "C:\Configs\sites.csv"
        MaxConcurrent = 5
        RetryAttempts = 3
    }
```

**Validation:**

```powershell
# Verify task recreated
Get-ScheduledTask -TaskName "Purview Nightly Classification" | Select-Object TaskName, State

# Check next run time
(Get-ScheduledTaskInfo -TaskName "Purview Nightly Classification").NextRunTime
```

### Resolution Step 2: Update Task Credentials

Refresh credentials for tasks using service accounts.

**Using Task Scheduler UI:**

Update credentials in task properties.

- Open **Task Scheduler**.
- Right-click task → **Properties**.
- Go to **General** tab.
- Click **Change User or Group** (if needed to change account).
- Check **Run with highest privileges**.
- Enter new password when prompted.

**Using PowerShell:**

```powershell
# Update task principal with new credentials
$taskName = "Purview Nightly Classification"
$userName = "DOMAIN\ServiceAccount"
$password = Read-Host "Enter password" -AsSecureString

# Create credentials
$cred = New-Object System.Management.Automation.PSCredential($userName, $password)

# Update task
$task = Get-ScheduledTask -TaskName $taskName
$principal = New-ScheduledTaskPrincipal -UserId $userName -LogonType Password -RunLevel Highest
Set-ScheduledTask -TaskName $taskName -Principal $principal -User $userName -Password ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))
```

**Validation:**

```powershell
# Run task immediately to test
Start-ScheduledTask -TaskName "Purview Nightly Classification"

# Wait for completion
Start-Sleep -Seconds 10

# Check result
$taskInfo = Get-ScheduledTaskInfo -TaskName "Purview Nightly Classification"
if ($taskInfo.LastTaskResult -eq 0) {
    Write-Host "Task executed successfully with updated credentials" -ForegroundColor Green
} else {
    Write-Host "Task failed with error code: 0x$([Convert]::ToString($taskInfo.LastTaskResult, 16))" -ForegroundColor Red
}
```

### Resolution Step 3: Set PowerShell Execution Policy

Allow PowerShell scripts to execute in scheduled tasks.

**Set Execution Policy:**

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

# Verify change
Get-ExecutionPolicy -Scope LocalMachine
```

**Expected Output**: RemoteSigned

**Alternative - Bypass Execution Policy in Task Action:**

Modify task action to bypass execution policy for that specific task.

```powershell
$task = Get-ScheduledTask -TaskName "Purview Nightly Classification"

# Update action to include -ExecutionPolicy Bypass
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -NoProfile -File C:\Scripts\Invoke-BulkClassification.ps1 -SiteListCsv C:\Configs\sites.csv -MaxConcurrent 5"

Set-ScheduledTask -TaskName "Purview Nightly Classification" -Action $action
```

**Validation:**

```powershell
# Check updated action
(Get-ScheduledTask -TaskName "Purview Nightly Classification").Actions | Select-Object Execute, Arguments
```

### Resolution Step 4: Fix Script Path and Arguments

Ensure script path uses absolute paths and correct syntax.

**Common Path Issues**:

| Issue | Problem | Solution |
|-------|---------|----------|
| Relative paths | `.\script.ps1` | Use `C:\Scripts\script.ps1` |
| UNC paths | `\\server\share\script.ps1` | Copy to local drive |
| Spaces in paths | `C:\My Scripts\script.ps1` | Use quotes: `"C:\My Scripts\script.ps1"` |
| Missing files | Path doesn't exist | Verify with `Test-Path` |

**Validate and Fix Paths:**

```powershell
# Check if script path exists
$scriptPath = "C:\Scripts\Invoke-BulkClassification.ps1"
if (Test-Path $scriptPath) {
    Write-Host "Script found at: $scriptPath" -ForegroundColor Green
} else {
    Write-Host "Script NOT found at: $scriptPath" -ForegroundColor Red
    # Find correct path
    Get-ChildItem "C:\" -Recurse -Filter "Invoke-BulkClassification.ps1" -ErrorAction SilentlyContinue | Select-Object FullName
}

# Update task with correct path
$task = Get-ScheduledTask -TaskName "Purview Nightly Classification"
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -NoProfile -File `"$scriptPath`" -SiteListCsv `"C:\Configs\sites.csv`" -MaxConcurrent 5" `
    -WorkingDirectory (Split-Path $scriptPath -Parent)

Set-ScheduledTask -TaskName "Purview Nightly Classification" -Action $action
```

**Validation:**

```powershell
# Test task execution
Start-ScheduledTask -TaskName "Purview Nightly Classification"
Start-Sleep -Seconds 15

# Check logs
if (Test-Path "C:\Scripts\logs\classification.log") {
    Get-Content "C:\Scripts\logs\classification.log" -Tail 20
} else {
    Write-Host "Log file not created - script may not be executing" -ForegroundColor Red
}
```

### Resolution Step 5: Enable Task History and Logging

Improve visibility into task execution for future troubleshooting.

**Enable Task History:**

```powershell
# Enable Task Scheduler history (if disabled)
$logName = "Microsoft-Windows-TaskScheduler/Operational"
$log = Get-WinEvent -ListLog $logName
if (-not $log.IsEnabled) {
    Write-Host "Enabling Task Scheduler event log..." -ForegroundColor Cyan
    wevtutil set-log $logName /enabled:true
}
```

**Add Logging to Script:**

Ensure script uses Lab 4 logging framework.

```powershell
# Modify script to include comprehensive logging
$logPath = "C:\Scripts\logs\scheduled-task-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Add to beginning of script
Start-Transcript -Path $logPath -Append

# ... script content ...

# Add to end of script
Stop-Transcript
```

**Configure Email Notifications (Optional):**

```powershell
# Add email notification on task completion
$task = Get-ScheduledTask -TaskName "Purview Nightly Classification"
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 4) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 10)

Set-ScheduledTask -TaskName "Purview Nightly Classification" -Settings $settings
```

**Validation:**

```powershell
# Run task and check for log creation
Start-ScheduledTask -TaskName "Purview Nightly Classification"
Start-Sleep -Seconds 20

# Verify log file created
Get-ChildItem "C:\Scripts\logs\" -Filter "scheduled-task-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
```

## Verification

Confirm scheduled task is working correctly.

**Verification Checklist:**

- [ ] Task executes successfully when started manually.
- [ ] Last Run Result shows 0x0 (success).
- [ ] Script logs show expected operations completed.
- [ ] Task history shows successful completion events.
- [ ] Next Run Time is set correctly for schedule.

**Validation Commands:**

```powershell
# Run complete validation
$taskName = "Purview Nightly Classification"

# Start task
Start-ScheduledTask -TaskName $taskName
Write-Host "Task started. Waiting for completion..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

# Check result
$taskInfo = Get-ScheduledTaskInfo -TaskName $taskName
if ($taskInfo.LastTaskResult -eq 0) {
    Write-Host "✅ Task completed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Task failed with code: 0x$([Convert]::ToString($taskInfo.LastTaskResult, 16))" -ForegroundColor Red
}

# Verify log file created
$latestLog = Get-ChildItem "C:\Scripts\logs\" -Filter "*classification*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latestLog -and (Get-Date).AddMinutes(-5) -lt $latestLog.LastWriteTime) {
    Write-Host "✅ Log file created/updated recently" -ForegroundColor Green
    Write-Host "  Path: $($latestLog.FullName)" -ForegroundColor Gray
} else {
    Write-Host "⚠️  No recent log file found" -ForegroundColor Yellow
}
```

**Expected Result**: All checks pass with success indicators.

## Prevention

Implement these practices to prevent scheduled task failures.

**Task Configuration Standards:**

- Always use absolute paths (never relative paths).
- Include `-ExecutionPolicy Bypass` in PowerShell arguments.
- Set working directory to script location.
- Configure appropriate timeout (4+ hours for large operations).
- Enable task history for troubleshooting.

**Credential Management:**

- Use dedicated service accounts for scheduled tasks (not user accounts).
- Document password expiration dates.
- Set calendar reminders 30 days before password expires.
- Test credential updates in non-production first.

**Monitoring:**

- Schedule weekly review of task execution history.
- Set up email alerts for task failures (if available).
- Include task status in daily health check procedures.
- Log task execution to centralized monitoring system.

**Documentation:**

- Document all scheduled tasks in inventory spreadsheet.
- Include purpose, schedule, dependencies, and owner.
- Maintain runbook for each critical scheduled task.
- Update documentation when tasks are modified.

## Escalation Criteria

Escalate if:

- Task continues failing after all resolution steps completed.
- Issue affects time-sensitive compliance operations.
- Scheduled task system-wide issues suspected (multiple tasks failing).
- Required to change execution policy but Group Policy blocks it.
- Security concerns about granting required permissions.

**Escalation Process:**

Contact Windows system administrators for Task Scheduler issues.
See `escalation/microsoft-support.md` for PowerShell or Purview API issues.

**Required Information:**

- Task name and configuration export.
- Complete error codes and messages.
- Screenshots of task history.
- Script logs showing manual vs scheduled execution.
- Service account information (username only, not password).

## Related Runbooks

- **Daily Health Checks**: See `maintenance/daily-health-checks.md` for proactive task monitoring.
- **Classification Failure**: See `incident-response/classification-failure.md` for script-specific issues.

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This runbook is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*

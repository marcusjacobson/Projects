# Health Check: System Validation

## Document Information

**Frequency**: Weekly (Every Monday)  
**Execution Time**: 20-30 minutes  
**Required Permissions**: Purview Administrator  
**Last Updated**: 2025-11-11

## Purpose

Comprehensive validation of all system components and integrations. Execute weekly to ensure consistent operation and catch degradation early.

## Validation Procedures

### 1. PowerShell Module Health

```powershell
# Validate all required modules are installed and current
$requiredModules = @{
    "PnP.PowerShell" = "1.12.0"
    "ExchangeOnlineManagement" = "3.4.0"
    "Microsoft.Graph" = "2.0.0"
}

foreach ($module in $requiredModules.Keys) {
    $installed = Get-Module -Name $module -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    if ($installed) {
        $minVersion = [Version]$requiredModules[$module]
        if ($installed.Version -ge $minVersion) {
            Write-Host "✅ $module version $($installed.Version)" -ForegroundColor Green
        } else {
            Write-Host "⚠️ $module version $($installed.Version) is below minimum $minVersion" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ $module not installed" -ForegroundColor Red
    }
}
```

### 2. Service Connectivity Testing

```powershell
# Test all service connections
$services = @{
    "SharePoint" = { Connect-PnPOnline -Url "https://yourtenant.sharepoint.com" -Interactive; Get-PnPWeb }
    "Exchange" = { Connect-IPPSSession; Get-DlpSensitiveInformationType -ResultSize 1 }
    "PurviewComplianceCenter" = { Connect-IPPSSession; Get-Label -ResultSize 1 }
}

foreach ($service in $services.Keys) {
    try {
        & $services[$service] | Out-Null
        Write-Host "✅ $service connection successful" -ForegroundColor Green
    } catch {
        Write-Host "❌ $service connection failed: $_" -ForegroundColor Red
    }
}

# Disconnect all sessions
Disconnect-PnPOnline -ErrorAction SilentlyContinue
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
```

### 3. SIT Definition Validation

```powershell
# Validate all custom SITs are active
Connect-IPPSSession

$customSITs = Get-DlpSensitiveInformationType | Where-Object { $_.Publisher -ne "Microsoft Corporation" }

Write-Host "Custom SITs: $($customSITs.Count) found" -ForegroundColor Cyan
$customSITs | ForEach-Object {
    if ($_.State -eq "Active") {
        Write-Host "  ✅ $($_.Name)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $($_.Name) - State: $($_.State)" -ForegroundColor Red
    }
}
```

### 4. Retention Label Policy Check

```powershell
# Validate retention labels and policies
$labels = Get-Label
Write-Host "Retention Labels: $($labels.Count) found" -ForegroundColor Cyan

$policies = Get-LabelPolicy
Write-Host "Label Policies: $($policies.Count) found" -ForegroundColor Cyan

# Check for published labels without policies
$publishedLabels = $labels | Where-Object { $_.ContentType -eq "File, Email" }
foreach ($label in $publishedLabels) {
    $policyAssigned = $policies | Where-Object { $_.Labels -contains $label.Guid }
    if ($policyAssigned) {
        Write-Host "  ✅ $($label.DisplayName)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️ $($label.DisplayName) - No policy assigned" -ForegroundColor Yellow
    }
}
```

### 5. Scheduled Task Status Verification

```powershell
# Verify all Purview scheduled tasks are configured and running
$purviewTasks = Get-ScheduledTask | Where-Object {
    $_.TaskName -like "*Purview*" -or 
    $_.TaskName -like "*Classification*" -or 
    $_.TaskName -like "*Compliance*"
}

Write-Host "Scheduled Tasks: $($purviewTasks.Count) found" -ForegroundColor Cyan

foreach ($task in $purviewTasks) {
    $taskInfo = Get-ScheduledTaskInfo -TaskName $task.TaskName
    $state = $task.State
    $lastResult = $taskInfo.LastTaskResult
    
    $status = if ($lastResult -eq 0 -and $state -eq "Ready") {
        "✅"
    } elseif ($state -eq "Disabled") {
        "⚠️ Disabled"
    } else {
        "❌ Error: 0x$([Convert]::ToString($lastResult, 16))"
    }
    
    Write-Host "  $status $($task.TaskName) (Last run: $($taskInfo.LastRunTime))"
}
```

## Weekly Validation Checklist

- [ ] All PowerShell modules are current and installed.
- [ ] SharePoint, Exchange, and Purview connections successful.
- [ ] All custom SITs are in Active state.
- [ ] All retention labels have assigned policies.
- [ ] Scheduled tasks are enabled and completing successfully.
- [ ] No critical errors in past week's logs.

## Issue Response

Document any failures and refer to appropriate runbooks:

- **Module issues**: Update modules using `Update-Module` cmdlet
- **Connection failures**: See `incident-response/classification-failure.md`
- **SIT issues**: See Lab 2 scripts for SIT management
- **Task failures**: See `incident-response/scheduled-task-failure.md`

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This document is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*

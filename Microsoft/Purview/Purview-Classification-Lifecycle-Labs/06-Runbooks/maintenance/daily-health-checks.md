# Maintenance Procedure: Daily Health Checks

## Document Information

**Frequency**: Daily (Every business day)  
**Execution Time**: 10-15 minutes  
**Required Permissions**: Purview Administrator  
**Last Updated**: 2025-11-11

## Purpose

Daily validation procedures to catch issues early and ensure system health. Execute these checks each morning before business operations begin.

## Health Check Procedures

### 1. Validate PowerShell Module Versions

```powershell
# Check PnP PowerShell
$pnpModule = Get-Module -Name PnP.PowerShell -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
Write-Host "PnP.PowerShell: $($pnpModule.Version) $(if ($pnpModule.Version -ge '1.12.0') { '✅' } else { '⚠️ Update needed' })"

# Check Exchange Online Management
$exoModule = Get-Module -Name ExchangeOnlineManagement -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
Write-Host "ExchangeOnlineManagement: $($exoModule.Version) $(if ($exoModule.Version -ge '3.4.0') { '✅' } else { '⚠️ Update needed' })"
```

### 2. Test Service Connectivity

```powershell
# Test SharePoint connection
try {
    Connect-PnPOnline -Url "https://yourtenant.sharepoint.com" -Interactive -ErrorAction Stop
    Write-Host "✅ SharePoint connection successful" -ForegroundColor Green
    Disconnect-PnPOnline
} catch {
    Write-Host "❌ SharePoint connection failed: $_" -ForegroundColor Red
}

# Test Exchange Online connection
try {
    Connect-IPPSSession -ErrorAction Stop
    $sitCount = (Get-DlpSensitiveInformationType | Measure-Object).Count
    Write-Host "✅ Exchange Online connection successful ($sitCount SITs found)" -ForegroundColor Green
    Disconnect-ExchangeOnline -Confirm:$false
} catch {
    Write-Host "❌ Exchange Online connection failed: $_" -ForegroundColor Red
}
```

### 3. Review Scheduled Task Status

```powershell
# Check all Purview-related scheduled tasks
Get-ScheduledTask | Where-Object { $_.TaskName -like "*Purview*" -or $_.TaskName -like "*Classification*" } | ForEach-Object {
    $taskInfo = Get-ScheduledTaskInfo -TaskName $_.TaskName
    $status = if ($taskInfo.LastTaskResult -eq 0) { "✅" } else { "❌ Error: 0x$([Convert]::ToString($taskInfo.LastTaskResult, 16))" }
    Write-Host "$($_.TaskName): $status (Last run: $($taskInfo.LastRunTime))"
}
```

### 4. Check Log File Growth

```powershell
# Monitor log directory size
$logDir = ".\logs"
$logFiles = Get-ChildItem $logDir -Filter "*.log" -File
$totalSizeMB = ($logFiles | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host "Total log size: $([Math]::Round($totalSizeMB, 2)) MB"
if ($totalSizeMB -gt 100) {
    Write-Host "⚠️ Log directory exceeds 100 MB - consider cleanup" -ForegroundColor Yellow
}

# Check for very large individual files
$logFiles | Where-Object { $_.Length / 1MB -gt 10 } | ForEach-Object {
    Write-Host "⚠️ Large log file: $($_.Name) - $([Math]::Round($_.Length / 1MB, 2)) MB" -ForegroundColor Yellow
}
```

### 5. Quick Classification Test

```powershell
# Run classification on small test site
try {
    .\Invoke-PurviewClassification.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/TestSite" -ErrorAction Stop
    Write-Host "✅ Classification test completed successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Classification test failed: $_" -ForegroundColor Red
}
```

## Daily Health Check Checklist

- [ ] PowerShell modules are current versions.
- [ ] SharePoint Online connection successful.
- [ ] Exchange Online connection successful.
- [ ] All scheduled tasks completed successfully overnight.
- [ ] Log files under 100 MB total size.
- [ ] Classification test completed without errors.

## Issue Response

If any health check fails, refer to appropriate incident response runbook:

- **Connection failures**: Check service health at [portal.office.com/servicestatus](https://portal.office.com/servicestatus)
- **Scheduled task failures**: See `incident-response/scheduled-task-failure.md`
- **Classification failures**: See `incident-response/classification-failure.md`

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This document is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*

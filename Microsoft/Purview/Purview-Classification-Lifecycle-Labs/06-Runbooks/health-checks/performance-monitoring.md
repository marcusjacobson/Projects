# Health Check: Performance Monitoring

## Document Information

**Frequency**: Weekly (with continuous monitoring)  
**Execution Time**: 25-30 minutes  
**Required Permissions**: Purview Administrator  
**Last Updated**: 2025-11-11

## Purpose

Monitor classification system performance, establish baselines, identify trends, and proactively address performance degradation before it impacts operations.

## Performance Monitoring Procedures

### 1. Classification Throughput Analysis

```powershell
# Analyze classification performance over last 7 days
$startDate = (Get-Date).AddDays(-7)
$logFiles = Get-ChildItem ".\logs" -Filter "classification-*.log" | 
    Where-Object { $_.LastWriteTime -gt $startDate }

$performanceData = foreach ($log in $logFiles) {
    $content = Get-Content $log.FullName
    
    # Extract performance metrics from logs
    $content | ForEach-Object {
        if ($_ -match "Processed (\d+) documents in ([\d\.]+) seconds") {
            [PSCustomObject]@{
                Date = $log.LastWriteTime
                Documents = [int]$Matches[1]
                Seconds = [double]$Matches[2]
                DocsPerSecond = [Math]::Round([int]$Matches[1] / [double]$Matches[2], 2)
            }
        }
    }
}

# Calculate weekly statistics
$avgThroughput = ($performanceData | Measure-Object -Property DocsPerSecond -Average).Average
$maxThroughput = ($performanceData | Measure-Object -Property DocsPerSecond -Maximum).Maximum
$minThroughput = ($performanceData | Measure-Object -Property DocsPerSecond -Minimum).Minimum

Write-Host "=== Classification Throughput (Last 7 Days) ===" -ForegroundColor Cyan
Write-Host "Average: $([Math]::Round($avgThroughput, 2)) docs/second" -ForegroundColor Gray
Write-Host "Maximum: $([Math]::Round($maxThroughput, 2)) docs/second" -ForegroundColor Gray
Write-Host "Minimum: $([Math]::Round($minThroughput, 2)) docs/second" -ForegroundColor Gray

# Alert on performance degradation
$historicalBaseline = 5.0 # Adjust based on your baseline
if ($avgThroughput -lt ($historicalBaseline * 0.8)) {
    Write-Host "⚠️ Performance degradation detected: 20% below baseline" -ForegroundColor Yellow
}
```

### 2. API Response Time Monitoring

```powershell
# Test API response times
$apiTests = @{
    "SharePoint Site Access" = { 
        Measure-Command { 
            Connect-PnPOnline -Url "https://yourtenant.sharepoint.com" -Interactive
            Get-PnPWeb | Out-Null
            Disconnect-PnPOnline
        }
    }
    "SIT Retrieval" = {
        Measure-Command {
            Connect-IPPSSession
            Get-DlpSensitiveInformationType -ResultSize 100 | Out-Null
            Disconnect-ExchangeOnline -Confirm:$false
        }
    }
    "Label Retrieval" = {
        Measure-Command {
            Connect-IPPSSession
            Get-Label | Out-Null
            Disconnect-ExchangeOnline -Confirm:$false
        }
    }
}

Write-Host "`n=== API Response Times ===" -ForegroundColor Cyan

$responseMetrics = foreach ($test in $apiTests.Keys) {
    $duration = & $apiTests[$test]
    
    [PSCustomObject]@{
        Test = $test
        ResponseTimeSeconds = [Math]::Round($duration.TotalSeconds, 2)
        Status = if ($duration.TotalSeconds -lt 5) { "✅" } 
                elseif ($duration.TotalSeconds -lt 10) { "⚠️" }
                else { "❌" }
    }
}

$responseMetrics | Format-Table -AutoSize

# Save for trend analysis
$metricsPath = ".\reports\performance-metrics-$(Get-Date -Format 'yyyyMMdd').csv"
$responseMetrics | Export-Csv $metricsPath -NoTypeInformation -Append
```

### 3. Script Execution Trend Analysis

```powershell
# Analyze scheduled task performance trends
$tasks = Get-ScheduledTask | Where-Object { 
    $_.TaskName -like "*Purview*" -or 
    $_.TaskName -like "*Classification*"
}

Write-Host "`n=== Scheduled Task Performance ===" -ForegroundColor Cyan

foreach ($task in $tasks) {
    $info = Get-ScheduledTaskInfo -TaskName $task.TaskName
    
    # Get execution history
    $events = Get-WinEvent -LogName "Microsoft-Windows-TaskScheduler/Operational" -MaxEvents 100 -ErrorAction SilentlyContinue |
        Where-Object { $_.Message -match $task.TaskName }
    
    # Calculate average runtime
    $runtimes = $events | Where-Object { $_.Id -eq 102 } | 
        Select-Object -First 10 |
        ForEach-Object {
            if ($_.Message -match "duration.*?(\d+):(\d+):(\d+)") {
                [TimeSpan]::Parse("$($Matches[1]):$($Matches[2]):$($Matches[3])")
            }
        }
    
    if ($runtimes) {
        $avgRuntime = ($runtimes | Measure-Object -Property TotalMinutes -Average).Average
        Write-Host "$($task.TaskName): Avg runtime $([Math]::Round($avgRuntime, 1)) minutes" -ForegroundColor Gray
    }
}
```

### 4. Resource Utilization Monitoring

```powershell
# Monitor system resources during classification
Write-Host "`n=== System Resource Utilization ===" -ForegroundColor Cyan

# Memory usage
$os = Get-CimInstance Win32_OperatingSystem
$totalMemoryGB = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeMemoryGB = [Math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedMemoryGB = $totalMemoryGB - $freeMemoryGB
$memoryUsagePercent = [Math]::Round(($usedMemoryGB / $totalMemoryGB) * 100, 1)

Write-Host "Memory Usage: $usedMemoryGB GB / $totalMemoryGB GB ($memoryUsagePercent%)" -ForegroundColor Gray
if ($memoryUsagePercent -gt 80) {
    Write-Host "⚠️ High memory usage detected" -ForegroundColor Yellow
}

# Disk space
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$diskFreeGB = [Math]::Round($disk.FreeSpace / 1GB, 2)
$diskTotalGB = [Math]::Round($disk.Size / 1GB, 2)
$diskUsagePercent = [Math]::Round((($diskTotalGB - $diskFreeGB) / $diskTotalGB) * 100, 1)

Write-Host "Disk Usage: $([Math]::Round($diskTotalGB - $diskFreeGB, 2)) GB / $diskTotalGB GB ($diskUsagePercent%)" -ForegroundColor Gray
if ($diskUsagePercent -gt 85) {
    Write-Host "⚠️ Low disk space" -ForegroundColor Yellow
}

# CPU usage (5-minute average)
Write-Host "Collecting CPU usage (30 second average)..." -ForegroundColor Gray
$cpuSamples = Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 30
$avgCPU = ($cpuSamples.CounterSamples | Measure-Object -Property CookedValue -Average).Average
Write-Host "CPU Usage: $([Math]::Round($avgCPU, 1))%" -ForegroundColor Gray
```

### 5. Throttling Incident Tracking

```powershell
# Track API throttling occurrences
Write-Host "`n=== API Throttling Analysis ===" -ForegroundColor Cyan

$throttleEvents = foreach ($log in $logFiles) {
    Get-Content $log.FullName | Where-Object { $_ -match "429|throttle|rate.*limit" }
}

$throttleCount = $throttleEvents.Count
$throttleRate = [Math]::Round(($throttleCount / 7), 1) # Per day average

Write-Host "Total throttling events (7 days): $throttleCount" -ForegroundColor Gray
Write-Host "Average per day: $throttleRate" -ForegroundColor $(if ($throttleRate -gt 10) { "Yellow" } else { "Gray" })

if ($throttleRate -gt 10) {
    Write-Host "⚠️ High throttling rate - consider reducing concurrency" -ForegroundColor Yellow
    Write-Host "   See incident-response/api-throttling.md for guidance" -ForegroundColor Gray
}
```

## Performance Baselines

**Establish and maintain these baseline metrics:**

| Metric | Baseline Target | Warning Threshold | Critical Threshold |
|--------|----------------|-------------------|-------------------|
| Classification Throughput | 5-10 docs/second | <4 docs/second | <2 docs/second |
| API Response Time | <3 seconds | 5-10 seconds | >10 seconds |
| Scheduled Task Runtime | <30 minutes | 30-60 minutes | >60 minutes |
| Memory Usage | <70% | 70-85% | >85% |
| Disk Space Free | >30% | 15-30% | <15% |
| CPU Usage (Average) | <50% | 50-75% | >75% |
| API Throttling Events | <5 per day | 5-15 per day | >15 per day |

## Performance Trending

**Create trend charts using collected data:**

```powershell
# Generate weekly performance trend report
$weeklyData = Import-Csv ".\reports\performance-metrics-*.csv" | 
    Where-Object { [DateTime]$_.Date -gt (Get-Date).AddDays(-30) }

# Group by week
$weeklyTrends = $weeklyData | Group-Object { 
    ([DateTime]$_.Date).ToString("yyyy-ww")
} | ForEach-Object {
    [PSCustomObject]@{
        Week = $_.Name
        AvgThroughput = [Math]::Round(($_.Group | Measure-Object -Property DocsPerSecond -Average).Average, 2)
        AvgResponseTime = [Math]::Round(($_.Group | Measure-Object -Property ResponseTimeSeconds -Average).Average, 2)
    }
}

Write-Host "`n=== 4-Week Performance Trends ===" -ForegroundColor Cyan
$weeklyTrends | Format-Table -AutoSize
```

## Alerting Configuration

**Setup automated alerts for performance issues:**

```powershell
# Email alert for performance degradation
$alertThresholds = @{
    ThroughputMin = 4.0  # docs/second
    ResponseTimeMax = 10  # seconds
    ThrottleRateMax = 10  # per day
}

# Check thresholds and send alerts
if ($avgThroughput -lt $alertThresholds.ThroughputMin -or 
    $avgResponseTime -gt $alertThresholds.ResponseTimeMax -or
    $throttleRate -gt $alertThresholds.ThrottleRateMax) {
    
    # Send email alert (customize with your SMTP settings)
    Send-MailMessage `
        -To "purview-admins@yourdomain.com" `
        -From "purview-monitoring@yourdomain.com" `
        -Subject "⚠️ Purview Performance Alert" `
        -Body "Performance degradation detected. Review weekly report." `
        -SmtpServer "smtp.yourdomain.com"
}
```

## Weekly Performance Checklist

- [ ] Classification throughput measured and within baseline.
- [ ] API response times tested and acceptable.
- [ ] Scheduled task runtimes reviewed for trends.
- [ ] System resource utilization monitored.
- [ ] Throttling incidents tracked and within limits.
- [ ] Performance trends analyzed for degradation.
- [ ] Alerts configured and functioning.
- [ ] Performance report generated and reviewed.

## Issue Response

If performance monitoring reveals issues:

- **Degraded throughput**: Review concurrent processing settings
- **Slow API responses**: Check Microsoft service health, network connectivity
- **High throttling**: See `incident-response/api-throttling.md`
- **Resource constraints**: Consider system upgrades or optimization

## Related Procedures

- **API Throttling**: Incident response for high throttling rates
- **System Validation**: Weekly validation includes performance checks
- **Monthly Validation**: Comprehensive performance baseline establishment

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This document is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*

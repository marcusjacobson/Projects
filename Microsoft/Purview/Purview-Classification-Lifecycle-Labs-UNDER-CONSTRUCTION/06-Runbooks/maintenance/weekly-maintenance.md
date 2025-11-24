# Maintenance Procedure: Weekly Maintenance

## Document Information

**Frequency**: Weekly (Every Sunday evening)  
**Execution Time**: 30-45 minutes  
**Required Permissions**: Purview Administrator  
**Last Updated**: 2025-11-11

## Purpose

Proactive system care and maintenance to optimize performance, prevent issues, and ensure compliance. Execute during off-peak hours to minimize impact.

## Weekly Maintenance Procedures

### 1. Classification Coverage Metrics

```powershell
# Analyze classification coverage across sites
$sites = Get-PnPTenantSite | Where-Object { $_.Template -notlike "*App*" -and $_.IsHubSite -eq $false }

$results = foreach ($site in $sites) {
    try {
        Connect-PnPOnline -Url $site.Url -Interactive
        $lists = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 } # Document libraries
        
        foreach ($list in $lists) {
            $items = Get-PnPListItem -List $list -PageSize 500
            $classifiedCount = ($items | Where-Object { $_["_ComplianceTag"] -ne $null }).Count
            
            [PSCustomObject]@{
                Site = $site.Title
                Library = $list.Title
                TotalDocuments = $items.Count
                ClassifiedDocuments = $classifiedCount
                CoveragePercent = if ($items.Count -gt 0) { [Math]::Round(($classifiedCount / $items.Count) * 100, 2) } else { 0 }
            }
        }
    } catch {
        Write-Warning "Failed to process $($site.Url): $_"
    }
}

# Export results
$resultsPath = ".\reports\classification-coverage-$(Get-Date -Format 'yyyyMMdd').csv"
$results | Export-Csv $resultsPath -NoTypeInformation
Write-Host "✅ Coverage report exported to $resultsPath" -ForegroundColor Green

# Display summary
$avgCoverage = ($results | Measure-Object -Property CoveragePercent -Average).Average
Write-Host "`nAverage classification coverage: $([Math]::Round($avgCoverage, 2))%" -ForegroundColor Cyan

# Identify sites needing attention
$lowCoverage = $results | Where-Object { $_.CoveragePercent -lt 80 -and $_.TotalDocuments -gt 10 }
if ($lowCoverage) {
    Write-Host "`n⚠️ Sites with <80% coverage:" -ForegroundColor Yellow
    $lowCoverage | Format-Table Site, Library, CoveragePercent -AutoSize
}
```

### 2. Error Pattern Analysis

```powershell
# Analyze last 7 days of classification logs
$logFiles = Get-ChildItem ".\logs" -Filter "classification-*.log" | 
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }

$errors = foreach ($log in $logFiles) {
    Get-Content $log.FullName | Where-Object { $_ -match "ERROR|FAILED|Exception" }
}

# Group by error type
$errorGroups = $errors | Group-Object { 
    if ($_ -match "Access.*denied") { "Access Denied" }
    elseif ($_ -match "429|throttl") { "API Throttling" }
    elseif ($_ -match "timeout") { "Timeout" }
    elseif ($_ -match "not found|404") { "Not Found" }
    else { "Other" }
}

Write-Host "`nError patterns (last 7 days):" -ForegroundColor Cyan
$errorGroups | ForEach-Object {
    $percentage = [Math]::Round(($_.Count / $errors.Count) * 100, 1)
    Write-Host "  $($_.Name): $($_.Count) occurrences ($percentage%)" -ForegroundColor Gray
}

# Alert if high error rates
if ($errors.Count -gt 100) {
    Write-Host "`n⚠️ High error count detected: $($errors.Count) errors in past 7 days" -ForegroundColor Yellow
}
```

### 3. SIT Effectiveness Review

```powershell
# Check SIT match rates
Connect-IPPSSession

$customSITs = Get-DlpSensitiveInformationType | Where-Object { $_.Publisher -ne "Microsoft Corporation" }

foreach ($sit in $customSITs) {
    # Get documents classified with this SIT (last 7 days)
    # Note: Actual match data requires DLP policy reports or audit logs
    Write-Host "Reviewing SIT: $($sit.Name)" -ForegroundColor Cyan
    
    # Check if SIT is in use by any labels or policies
    $labels = Get-Label | Where-Object { $_.ApplyContentMarkingFooterText -match $sit.Name }
    if ($labels) {
        Write-Host "  ✅ Used by $($labels.Count) label(s)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️ Not referenced by any labels" -ForegroundColor Yellow
    }
}
```

### 4. Log File Cleanup

```powershell
# Archive old logs (older than 30 days)
$archiveDate = (Get-Date).AddDays(-30)
$oldLogs = Get-ChildItem ".\logs" -Filter "*.log" | Where-Object { $_.LastWriteTime -lt $archiveDate }

if ($oldLogs) {
    $archivePath = ".\logs\archive\$(Get-Date -Format 'yyyy-MM')"
    New-Item -Path $archivePath -ItemType Directory -Force | Out-Null
    
    $oldLogs | ForEach-Object {
        Move-Item $_.FullName -Destination $archivePath
    }
    
    Write-Host "✅ Archived $($oldLogs.Count) old log files" -ForegroundColor Green
}

# Compress archived logs
$archiveDirs = Get-ChildItem ".\logs\archive" -Directory | Where-Object { 
    $_.CreationTime -lt (Get-Date).AddMonths(-1) -and 
    -not (Test-Path "$($_.FullName).zip")
}

foreach ($dir in $archiveDirs) {
    Compress-Archive -Path $dir.FullName -DestinationPath "$($dir.FullName).zip"
    Remove-Item $dir.FullName -Recurse -Force
    Write-Host "✅ Compressed archive: $($dir.Name).zip" -ForegroundColor Green
}
```

### 5. Configuration Backup

```powershell
# Execute weekly configuration backup
.\disaster-recovery\scripts\Backup-PurviewConfiguration.ps1
```

## Weekly Maintenance Checklist

- [ ] Classification coverage metrics collected and analyzed.
- [ ] Error patterns reviewed and documented.
- [ ] SIT effectiveness validated.
- [ ] Low-performing SITs identified for optimization.
- [ ] Log files archived (older than 30 days).
- [ ] Old archives compressed.
- [ ] Configuration backup completed successfully.
- [ ] Weekly report sent to team.

## Trend Analysis

Track these metrics week-over-week:

- Average classification coverage percentage.
- Total error count and error rate.
- API throttling occurrences.
- Most frequently failing sites/libraries.
- SIT match rates (if available).

## Issue Response

If maintenance reveals issues:

- **Coverage below 80%**: Schedule additional classification runs
- **High error rates**: Review error patterns and address root causes
- **SITs not in use**: Consider deprecating or documenting purpose
- **Large log files**: Investigate what's generating excessive logging

## Related Procedures

- **Daily Health Checks**: Maintenance builds on daily checks
- **Configuration Backup**: Weekly backup is part of this procedure
- **Monthly Validation**: More comprehensive review monthly

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This document is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*

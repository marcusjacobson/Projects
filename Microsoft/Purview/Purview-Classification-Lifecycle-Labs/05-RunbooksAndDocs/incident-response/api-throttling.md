# Incident Response Runbook: API Throttling

## Document Information

**Severity**: Medium  
**Estimated Resolution Time**: 15-30 minutes  
**Required Permissions**: None (script modifications only)  
**Last Updated**: 2025-11-11

## Purpose

This runbook provides procedures for diagnosing and resolving API throttling issues in Microsoft Purview operations. Use this when operations fail with 429 (Too Many Requests) errors, scripts experience intermittent timeouts, or bulk operations are slower than expected.

## Symptoms

Common indicators of API throttling:

- HTTP 429 "Too Many Requests" errors in logs.
- PowerShell cmdlets fail intermittently with throttling messages.
- Bulk operations take significantly longer than expected.
- Error messages containing "throttled", "rate limit", or "retry after".
- Operations succeed after waiting and retrying.
- Increased error rates during bulk processing.

**Impact Assessment**:

- **Service**: Operations temporarily blocked or significantly slowed.
- **Users**: Delayed completion of classification and labeling tasks.
- **Data**: No data loss, but processing backlog may accumulate.

## Investigation Steps

### Step 1: Identify Throttling Patterns

Analyze logs to understand throttling frequency and patterns.

**Check Recent Logs for 429 Errors:**

```powershell
# Search all logs for throttling indicators
Get-ChildItem ".\logs\*.log" | ForEach-Object {
    $throttleCount = (Get-Content $_.FullName | Select-String -Pattern "429|throttl|rate limit" -CaseSensitive:$false).Count
    if ($throttleCount -gt 0) {
        Write-Host "$($_.Name): $throttleCount throttling incidents" -ForegroundColor Yellow
    }
}

# Get detailed throttling events with context
Get-Content ".\logs\*.log" | Select-String -Pattern "429|throttl" -Context 2,2
```

**Analyze Throttling Timing:**

```powershell
# Extract timestamps of throttling events
$logs = Get-Content ".\logs\classification.log"
$throttleEvents = $logs | Select-String -Pattern "throttl|429" | ForEach-Object {
    if ($_ -match '(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})') {
        [datetime]$matches[1]
    }
}

# Calculate time between throttle events
if ($throttleEvents.Count -gt 1) {
    $intervals = @()
    for ($i = 1; $i -lt $throttleEvents.Count; $i++) {
        $interval = ($throttleEvents[$i] - $throttleEvents[$i-1]).TotalSeconds
        $intervals += $interval
    }
    $avgInterval = ($intervals | Measure-Object -Average).Average
    Write-Host "Average time between throttle events: $([Math]::Round($avgInterval, 2)) seconds" -ForegroundColor Cyan
}
```

**Common Throttling Patterns**:

| Pattern | Cause | Resolution Approach |
|---------|-------|---------------------|
| Consistent 429 every few seconds | Too high concurrency | Reduce MaxConcurrent parameter |
| Burst of 429s then success | Exceeding burst limits | Add delays between batches |
| 429s during specific times | Peak usage hours | Schedule during off-peak |
| Intermittent 429s | Shared tenant throttling | Implement exponential backoff |

### Step 2: Review Current Operation Concurrency

Check how many simultaneous operations are being attempted.

**Examine Script Parameters:**

```powershell
# Check bulk classification concurrency setting
$scriptContent = Get-Content ".\Invoke-BulkClassification.ps1" -Raw
if ($scriptContent -match 'MaxConcurrent\s*=\s*(\d+)') {
    Write-Host "Current MaxConcurrent setting: $($matches[1])" -ForegroundColor Cyan
}

# Check if script is running
Get-Process -Name pwsh,powershell -ErrorAction SilentlyContinue | Where-Object {
    $_.MainWindowTitle -like "*Bulk*" -or $_.MainWindowTitle -like "*Classification*"
} | Select-Object Id, MainWindowTitle, StartTime
```

**Recommended Concurrency Levels**:

| Operation Type | Recommended Concurrency | Maximum Safe Limit |
|----------------|------------------------|-------------------|
| **Document Classification** | 3-5 | 10 |
| **Site Processing** | 2-3 | 5 |
| **SIT Creation** | 1-2 | 3 |
| **Label Application** | 3-5 | 10 |

### Step 3: Check Microsoft Service Limits

Understand the applicable throttling limits for your operations.

**Common Microsoft 365 API Limits**:

| Service | Limit Type | Value | Time Window |
|---------|-----------|-------|-------------|
| **SharePoint Online** | Requests per app per tenant | 4,800 | 5 minutes |
| **Microsoft Graph** | Requests per app | 2,000 | 10 seconds |
| **Exchange Online** | Concurrent connections | 3 | Per user |
| **Information Protection** | Label operations | 100 | Per minute |

**Reference Documentation:**

- SharePoint: [SharePoint Online throttling](https://learn.microsoft.com/en-us/sharepoint/dev/general-development/how-to-avoid-getting-throttled-or-blocked-in-sharepoint-online)
- Microsoft Graph: [Graph throttling guidance](https://learn.microsoft.com/en-us/graph/throttling)

### Step 4: Analyze Operation Batch Sizes

Review how many items are being processed in each batch.

**Check Current Batch Processing:**

```powershell
# Review site list size
$sites = Import-Csv ".\configs\sites.csv"
Write-Host "Total sites in queue: $($sites.Count)" -ForegroundColor Cyan

# Calculate estimated processing time with current settings
$concurrency = 5  # Current MaxConcurrent setting
$avgTimePerSite = 120  # seconds (2 minutes)
$estimatedMinutes = ($sites.Count / $concurrency * $avgTimePerSite) / 60
Write-Host "Estimated processing time: $([Math]::Round($estimatedMinutes, 1)) minutes" -ForegroundColor Cyan
```

**Optimal Batch Sizes:**

| Content Volume | Recommended Batch Size | Notes |
|----------------|----------------------|-------|
| **Small (<50 docs/site)** | 20-30 sites | Process quickly |
| **Medium (50-500 docs)** | 10-15 sites | Balance speed and stability |
| **Large (>500 docs)** | 5-10 sites | Prevent timeouts |

## Resolution Procedures

### Resolution Step 1: Reduce Operation Concurrency

Lower the number of simultaneous operations to avoid throttling.

**Immediate Action:**

```powershell
# Run bulk classification with reduced concurrency
.\Invoke-BulkClassification.ps1 -SiteListCsv "sites.csv" -MaxConcurrent 2 -RetryAttempts 5

# For very large operations, use single-thread processing
.\Invoke-BulkClassification.ps1 -SiteListCsv "sites.csv" -MaxConcurrent 1
```

**Long-Term Configuration:**

Modify default concurrency in scripts or configuration files.

```powershell
# Update script default
$scriptPath = ".\Invoke-BulkClassification.ps1"
$content = Get-Content $scriptPath -Raw
$content = $content -replace 'MaxConcurrent\s*=\s*\d+', 'MaxConcurrent = 3'
Set-Content -Path $scriptPath -Value $content
```

**Validation:**

Monitor logs for reduced 429 errors.

```powershell
# Count throttle events before and after change
$beforeCount = (Get-Content ".\logs\classification-before.log" | Select-String -Pattern "429").Count
$afterCount = (Get-Content ".\logs\classification.log" | Select-String -Pattern "429").Count
Write-Host "Throttle events - Before: $beforeCount | After: $afterCount" -ForegroundColor Cyan
```

### Resolution Step 2: Implement Exponential Backoff

Add or verify exponential backoff retry logic in scripts.

**Exponential Backoff Pattern (Already in Lab 4 Scripts):**

```powershell
function Invoke-WithRetry {
    param(
        [scriptblock]$Operation,
        [int]$MaxRetries = 5,
        [int]$BaseDelaySeconds = 5
    )
    
    $attempt = 0
    $success = $false
    
    while (-not $success -and $attempt -lt $MaxRetries) {
        try {
            $attempt++
            & $Operation
            $success = $true
            Write-Host "Operation successful on attempt $attempt" -ForegroundColor Green
        } catch {
            if ($_.Exception.Message -like "*429*" -or $_.Exception.Message -like "*throttl*") {
                if ($attempt -lt $MaxRetries) {
                    $waitTime = [Math]::Pow(2, $attempt) * $BaseDelaySeconds  # 10s, 20s, 40s, 80s, 160s
                    Write-Warning "Throttled. Waiting $waitTime seconds before retry $attempt of $MaxRetries"
                    Start-Sleep -Seconds $waitTime
                } else {
                    Write-Error "Max retries reached. Operation failed: $_"
                    throw
                }
            } else {
                # Non-throttling error, don't retry
                Write-Error "Operation failed with non-throttling error: $_"
                throw
            }
        }
    }
}

# Usage example
Invoke-WithRetry -Operation {
    Get-PnPListItem -List "Documents" -PageSize 500
} -MaxRetries 5 -BaseDelaySeconds 5
```

**Validation:**

Test retry logic with intentional throttling scenario.

```powershell
# Verify retry logic activates
.\Invoke-BulkClassification.ps1 -SiteListCsv "large-sites.csv" -MaxConcurrent 10 -RetryAttempts 5

# Check logs for retry messages
Get-Content ".\logs\classification.log" -Tail 50 | Select-String -Pattern "retry|waiting|attempt"
```

### Resolution Step 3: Add Delays Between Batches

Introduce pauses between processing batches to stay under rate limits.

**Batch Processing with Delays:**

```powershell
# Split processing into smaller batches with delays
$allSites = Import-Csv "sites.csv"
$batchSize = 10
$delayBetweenBatches = 120  # 2 minutes

for ($i = 0; $i -lt $allSites.Count; $i += $batchSize) {
    $batch = $allSites[$i..([Math]::Min($i + $batchSize - 1, $allSites.Count - 1))]
    $batchNum = [Math]::Floor($i / $batchSize) + 1
    
    Write-Host "Processing batch $batchNum of $([Math]::Ceiling($allSites.Count / $batchSize))" -ForegroundColor Cyan
    
    # Process current batch
    $batch | Export-Csv "temp-batch.csv" -NoTypeInformation
    .\Invoke-BulkClassification.ps1 -SiteListCsv "temp-batch.csv" -MaxConcurrent 3
    
    # Wait before next batch (except after last batch)
    if ($i + $batchSize -lt $allSites.Count) {
        Write-Host "Waiting $delayBetweenBatches seconds before next batch..." -ForegroundColor Yellow
        Start-Sleep -Seconds $delayBetweenBatches
    }
}

# Cleanup
Remove-Item "temp-batch.csv" -ErrorAction SilentlyContinue
```

**Validation:**

Verify operations complete without throttling.

```powershell
# Check for successful batch completion
Get-Content ".\logs\classification.log" | Select-String -Pattern "batch.*completed|success" | Measure-Object | Select-Object -ExpandProperty Count
```

### Resolution Step 4: Schedule Operations During Off-Peak Hours

Run large bulk operations when tenant usage is lowest.

**Identify Off-Peak Hours:**

Typical off-peak periods:

- **Weeknights**: 10 PM - 6 AM local time.
- **Weekends**: Saturday/Sunday mornings.
- **Holidays**: When most employees are not working.

**Schedule Using Windows Task Scheduler:**

```powershell
# Create scheduled task for off-peak classification
.\New-PurviewScheduledTask.ps1 `
    -TaskName "Nightly Classification" `
    -ScriptPath "C:\Scripts\Invoke-BulkClassification.ps1" `
    -Trigger Daily `
    -StartTime "02:00:00" `
    -ScriptParameters @{
        SiteListCsv = "C:\Configs\sites.csv"
        MaxConcurrent = 5
        RetryAttempts = 5
    }
```

**Validation:**

Verify task is scheduled correctly.

```powershell
# Check scheduled task
Get-ScheduledTask -TaskName "Nightly Classification" | Select-Object TaskName, State, NextRunTime
```

### Resolution Step 5: Optimize API Calls

Reduce unnecessary API calls by caching data and batching requests.

**Implement Caching:**

```powershell
# Cache site metadata to reduce repeated API calls
$siteCache = @{}

function Get-CachedSiteInfo {
    param([string]$SiteUrl)
    
    if (-not $siteCache.ContainsKey($SiteUrl)) {
        Write-Verbose "Fetching site info for $SiteUrl (not in cache)"
        $siteCache[$SiteUrl] = Get-PnPSite -Includes Id, Title, Url
    } else {
        Write-Verbose "Using cached site info for $SiteUrl"
    }
    
    return $siteCache[$SiteUrl]
}
```

**Batch Graph API Requests:**

```powershell
# Instead of individual requests, use batch API
$batchRequests = @()
foreach ($siteUrl in $siteUrls) {
    $batchRequests += @{
        id = $siteUrl
        method = "GET"
        url = "/sites/$siteUrl"
    }
}

# Execute batch (up to 20 requests per batch for Graph API)
$batchSize = 20
for ($i = 0; $i -lt $batchRequests.Count; $i += $batchSize) {
    $batch = $batchRequests[$i..([Math]::Min($i + $batchSize - 1, $batchRequests.Count - 1))]
    # Execute batch request logic here
}
```

**Validation:**

Monitor API call reduction.

```powershell
# Compare API call counts before and after optimization
# (Requires logging of API calls in scripts)
Get-Content ".\logs\classification.log" | Select-String -Pattern "API call|request" | Measure-Object
```

## Verification

Confirm throttling is resolved or significantly reduced.

**Verification Checklist:**

- [ ] 429 errors reduced by >80% in logs.
- [ ] Bulk operations complete without interruption.
- [ ] Script execution time is consistent and predictable.
- [ ] No throttling errors for small test batches.
- [ ] Retry logic activates only occasionally (not every operation).

**Validation Commands:**

```powershell
# Run test batch and monitor for throttling
.\Invoke-BulkClassification.ps1 -SiteListCsv "test-sites.csv" -MaxConcurrent 3

# Check success rate
$log = Get-Content ".\logs\classification.log" -Tail 200
$throttleCount = ($log | Select-String -Pattern "429|throttl").Count
$successCount = ($log | Select-String -Pattern "success|completed").Count
Write-Host "Throttle events: $throttleCount | Successes: $successCount" -ForegroundColor Cyan
Write-Host "Success rate: $([Math]::Round(($successCount / ($successCount + $throttleCount)) * 100, 1))%" -ForegroundColor Cyan
```

**Expected Result**: Throttle events <5% of total operations, success rate >95%.

## Prevention

Implement these practices to prevent throttling.

**Script Configuration Standards:**

- Always use MaxConcurrent parameter (never exceed 10).
- Implement exponential backoff in all API interaction scripts.
- Add delays between large batch operations (minimum 60 seconds).
- Use caching for frequently accessed data.

**Capacity Planning:**

- Document baseline API usage for normal operations.
- Plan large bulk operations for off-peak hours.
- Break very large jobs (>100 sites) into multiple scheduled runs.
- Monitor API usage trends monthly.

**Monitoring and Alerting:**

- Set up alerts when throttle rate exceeds 10% of operations.
- Track and report throttling trends in monthly operational reports.
- Review throttling incidents during team meetings.

**Testing:**

- Test bulk operations in non-production environment first.
- Gradually increase concurrency to find optimal settings.
- Validate retry logic before production use.

## Escalation Criteria

Escalate if:

- Throttling persists after implementing all resolution steps.
- Throttling affects time-sensitive compliance operations.
- API limits have changed without notice (potential service issue).
- Throttling occurs even with single-threaded operations.
- Business requirements cannot be met within throttling constraints.

**Escalation Process:**

See `escalation/microsoft-support.md` for engaging Microsoft Support on API throttling questions.

**Required Information:**

- Tenant ID and app registration IDs.
- Throttling error messages with timestamps.
- Concurrency settings and batch sizes used.
- API call patterns and frequencies.
- Business justification for required throughput.

## Related Runbooks

- **Classification Failure**: See `incident-response/classification-failure.md` for related classification issues.
- **Performance Monitoring**: See `health-checks/performance-monitoring.md` for ongoing throttling tracking.

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This runbook is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*

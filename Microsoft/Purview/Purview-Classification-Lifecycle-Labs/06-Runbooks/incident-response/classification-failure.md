# Incident Response Runbook: Classification Failure

## Document Information

**Severity**: High  
**Estimated Resolution Time**: 30-60 minutes  
**Required Permissions**: SharePoint Site Collection Administrator, Purview Administrator  
**Last Updated**: 2025-11-11

## Purpose

This runbook provides step-by-step procedures for diagnosing and resolving classification failures in Microsoft Purview. Use this when documents fail to classify properly, classification results are inconsistent, or bulk classification operations fail.

## Symptoms

Common indicators of classification failures:

- Documents remain unclassified after running classification scripts.
- Error messages in PowerShell output: "Classification failed" or "Access denied".
- Classification reports show 0% success rate.
- Bulk classification operations timeout or hang.
- Classification labels not visible in SharePoint document libraries.
- Logs show repeated API errors (429, 403, 500).

**Impact Assessment**:

- **Service**: Classification operations halted or degraded.
- **Users**: Cannot rely on automated classification; manual classification required.
- **Data**: Unclassified sensitive information may lack proper protection.

## Investigation Steps

### Step 1: Validate Permissions

Check that the account running classification has proper permissions.

Navigate to SharePoint site and verify permissions.

- Open SharePoint site URL in browser.
- Click **Settings** (gear icon) → **Site permissions**.
- Verify the account appears in **Site Owners** or **Site Members** groups.
- Confirm the account has **Full Control** or **Edit** permissions.

Test permission access with PowerShell.

```powershell
# Connect to SharePoint Online
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/YourSite" -Interactive

# Test if you can list documents
$docs = Get-PnPListItem -List "Documents"
Write-Host "Successfully retrieved $($docs.Count) documents" -ForegroundColor Green
```

**Expected Result**: Command succeeds and returns document count.

If command fails with "Access denied", permissions are insufficient. Proceed to Resolution Step 1.

### Step 2: Review Classification Logs

Examine recent classification logs for error patterns.

```powershell
# Review last 50 lines of classification log
Get-Content ".\logs\classification.log" -Tail 50

# Search for error patterns
Get-Content ".\logs\classification.log" | Select-String -Pattern "error|failed|exception" -CaseSensitive:$false
```

**Common Error Patterns**:

| Error Message | Root Cause | Resolution Step |
|---------------|------------|-----------------|
| "Access is denied" | Insufficient permissions | Resolution Step 1 |
| "429 Too Many Requests" | API throttling | Resolution Step 2 |
| "The operation has timed out" | Network or performance issue | Resolution Step 3 |
| "Object reference not set" | Missing SIT definitions | Resolution Step 4 |

### Step 3: Validate SIT Definitions

Verify that Sensitive Information Types exist and are properly configured.

```powershell
# Connect to Exchange Online
Connect-IPPSSession

# List custom SITs
Get-DlpSensitiveInformationType | Where-Object { $_.Publisher -ne "Microsoft Corporation" } | Select-Object Name, Publisher, State

# Test specific SIT pattern
$sit = Get-DlpSensitiveInformationType -Identity "Your SIT Name"
$sit.LocalizedStrings
```

**Expected Result**: SITs appear with **State = "Active"**.

If no custom SITs found or State is "Disabled", proceed to Resolution Step 4.

### Step 4: Test Classification on Sample Document

Create a simple test to isolate the issue.

```powershell
# Create test file with known pattern
$testContent = "Employee Badge: E123456"
$testFile = "C:\Temp\classification-test.txt"
Set-Content -Path $testFile -Value $testContent

# Upload to SharePoint
Add-PnPFile -Path $testFile -Folder "Shared Documents"

# Wait for classification (may take 5-10 minutes)
Start-Sleep -Seconds 600

# Check if document was classified
$file = Get-PnPFile -Url "Shared Documents/classification-test.txt" -AsListItem
$file.FieldValues
```

**Expected Result**: Document shows classification properties after waiting period.

If classification fails on test document, issue is systemic. Proceed to Resolution Step 5.

### Step 5: Check Service Health

Verify Microsoft Purview service status.

Navigate to Microsoft 365 admin center.

- Go to [admin.microsoft.com](https://admin.microsoft.com).
- Click **Health** → **Service health**.
- Filter for **Microsoft Purview** or **Information Protection**.
- Check for active incidents or advisories.

**Expected Result**: All services show **Healthy** status.

If service issues exist, document incident ID and proceed to Escalation section.

## Resolution Procedures

### Resolution Step 1: Grant Required Permissions

Add the classification account to the appropriate SharePoint groups.

**Using SharePoint UI:**

Navigate to site permissions.

- Open SharePoint site: `https://yourtenant.sharepoint.com/sites/YourSite`.
- Click **Settings** (gear icon) → **Site permissions**.
- Click **Grant permissions** or **Advanced permissions settings**.
- Click **Grant Permissions**.

Add the user or service account.

- Enter the account email address.
- Select permission level: **Full Control** (for classification operations).
- Uncheck "Send an email invitation".
- Click **Share**.

**Using PowerShell:**

```powershell
# Connect to SharePoint site
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/YourSite" -Interactive

# Add user to Site Members group with Edit permissions
Add-PnPGroupMember -LoginName "classification@yourtenant.onmicrosoft.com" -Group "YourSite Members"

# Verify permission added
Get-PnPGroupMember -Group "YourSite Members" | Where-Object { $_.Email -eq "classification@yourtenant.onmicrosoft.com" }
```

**Validation**: Re-run classification script on single document to verify access.

### Resolution Step 2: Handle API Throttling

Implement retry logic and reduce concurrency to avoid throttling.

**Immediate Action - Reduce Concurrency:**

```powershell
# Run bulk classification with reduced concurrency
.\Invoke-BulkClassification.ps1 -SiteListCsv "sites.csv" -MaxConcurrent 2 -RetryAttempts 5
```

**Long-Term Fix - Add Exponential Backoff:**

Modify classification scripts to include exponential backoff (already implemented in Lab 4 scripts).

```powershell
# Example retry logic with exponential backoff
$maxRetries = 5
$retryCount = 0
$success = $false

while (-not $success -and $retryCount -lt $maxRetries) {
    try {
        # Attempt classification operation
        Invoke-PnPWeb -Url $siteUrl
        $success = $true
    } catch {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            $waitTime = [Math]::Pow(2, $retryCount) * 5  # 10s, 20s, 40s, 80s, 160s
            Write-Warning "Throttled. Waiting $waitTime seconds before retry $retryCount of $maxRetries"
            Start-Sleep -Seconds $waitTime
        }
    }
}
```

**Validation**: Monitor logs for reduced throttling errors (429 responses).

### Resolution Step 3: Resolve Timeout Issues

Address network or performance-related timeouts.

**Increase Script Timeout Values:**

```powershell
# Set longer timeout for PnP connection
Connect-PnPOnline -Url $siteUrl -Interactive -RequestTimeout 300000  # 5 minutes
```

**Process Smaller Batches:**

```powershell
# Split large site list into smaller batches
$allSites = Import-Csv "sites.csv"
$batchSize = 10

for ($i = 0; $i -lt $allSites.Count; $i += $batchSize) {
    $batch = $allSites[$i..([Math]::Min($i + $batchSize - 1, $allSites.Count - 1))]
    $batch | Export-Csv "sites-batch-$($i/$batchSize + 1).csv" -NoTypeInformation
    
    # Process each batch separately
    .\Invoke-BulkClassification.ps1 -SiteListCsv "sites-batch-$($i/$batchSize + 1).csv" -MaxConcurrent 3
    
    # Wait between batches
    Start-Sleep -Seconds 60
}
```

**Validation**: Classification operations complete without timeout errors.

### Resolution Step 4: Recreate or Enable SIT Definitions

Fix missing or disabled Sensitive Information Types.

**Check SIT Status:**

```powershell
Connect-IPPSSession

# Find disabled SITs
Get-DlpSensitiveInformationType | Where-Object { $_.State -ne "Active" } | Select-Object Name, State
```

**Enable Disabled SIT:**

```powershell
# Enable specific SIT
Set-DlpSensitiveInformationType -Identity "Your SIT Name" -State Active
```

**Recreate Missing SIT:**

Use Lab 2 scripts to recreate custom SITs from definitions.

```powershell
# Recreate SIT from definition
.\New-CustomSIT.ps1 -Name "Employee Badge ID" -Pattern "\b[E][0-9]{6}\b" -Confidence 85
```

**Validation**: Verify SIT appears as Active.

```powershell
Get-DlpSensitiveInformationType -Identity "Your SIT Name" | Select-Object Name, State, Publisher
```

### Resolution Step 5: Restart Classification Service (If Applicable)

For systemic issues, restart relevant services or connections.

**Clear PowerShell Session:**

```powershell
# Disconnect all sessions
Disconnect-PnPOnline
Disconnect-ExchangeOnline -Confirm:$false

# Clear PowerShell cache
Remove-Module -Name PnP.PowerShell -Force -ErrorAction SilentlyContinue
Remove-Module -Name ExchangeOnlineManagement -Force -ErrorAction SilentlyContinue

# Reimport modules
Import-Module PnP.PowerShell
Import-Module ExchangeOnlineManagement

# Reconnect
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com" -Interactive
Connect-IPPSSession
```

**Validation**: Re-run classification test on sample document.

## Verification

After completing resolution steps, verify the issue is fully resolved.

**Verification Checklist:**

- [ ] Classification script executes without errors.
- [ ] Sample document classifies successfully within 10 minutes.
- [ ] Classification logs show successful operations.
- [ ] No throttling or timeout errors in recent logs.
- [ ] Bulk classification completes for small batch (5-10 sites).

**Validation Command:**

```powershell
# Run classification on test site
.\Invoke-PurviewClassification.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/Test" -DetailedReport

# Check success rate
$log = Get-Content ".\logs\classification.log" -Tail 100
$successCount = ($log | Select-String -Pattern "success" -CaseSensitive:$false).Count
$failCount = ($log | Select-String -Pattern "failed|error" -CaseSensitive:$false).Count
Write-Host "Success: $successCount | Failures: $failCount"
```

**Expected Result**: Success count exceeds 80%, minimal failures.

## Prevention

Implement these practices to prevent recurrence.

**Proactive Monitoring:**

- Schedule daily health checks using Lab 5 health check procedures.
- Monitor classification success rates in weekly reports.
- Set up alerts for elevated error rates (>10% failure rate).

**Permission Management:**

- Document required permissions for classification accounts.
- Implement quarterly permission audits.
- Use dedicated service accounts for automation (not user accounts).

**Throttling Prevention:**

- Always use MaxConcurrent parameter in bulk scripts (limit to 5-10).
- Schedule bulk operations during off-peak hours.
- Implement proper exponential backoff in all scripts.

**Configuration Management:**

- Backup SIT definitions monthly (see disaster-recovery/configuration-backup.md).
- Version control for custom scripts and configurations.
- Document all custom SIT patterns and purposes.

## Escalation Criteria

Escalate to next tier support if:

- Resolution steps don't resolve the issue within 2 hours.
- Microsoft Purview service health shows active incidents.
- Issue affects multiple tenants or sites (potential service issue).
- Data integrity concerns (documents being misclassified).
- Classification has been completely non-functional for >4 hours.

**Escalation Process:**

1. Document all investigation and resolution steps attempted.
2. Collect diagnostic information (logs, error messages, screenshots).
3. Open Microsoft Support case (see escalation/microsoft-support.md).
4. Notify team lead or manager via communication protocol.
5. Update incident ticket with escalation details.

**Required Information for Escalation:**

- Tenant ID and affected site URLs.
- Classification script version and parameters used.
- Complete error messages and stack traces.
- Screenshots of SharePoint permissions.
- Last successful classification timestamp.
- Service health incident ID (if applicable).

## Related Runbooks

- **Permission Denied**: See `incident-response/permission-denied.md` for detailed permission troubleshooting.
- **API Throttling**: See `incident-response/api-throttling.md` for advanced throttling solutions.
- **Daily Health Checks**: See `maintenance/daily-health-checks.md` for proactive validation.

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This runbook is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*

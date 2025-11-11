# Disaster Recovery: Configuration Backup

## Document Information

**Frequency**: Weekly (Automated), On-demand before major changes  
**Execution Time**: 15-20 minutes  
**Required Permissions**: Compliance Administrator  
**Last Updated**: 2025-11-11

## Purpose

Regular backup of Microsoft Purview configurations to enable rapid recovery after incidents, accidental deletions, or configuration corruption.

## Backup Procedures

### 1. Export Custom SIT Definitions

```powershell
# Connect to Exchange Online
Connect-IPPSSession

# Export all custom SITs
$customSITs = Get-DlpSensitiveInformationType | Where-Object { $_.Publisher -ne "Microsoft Corporation" }

$backupDate = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = ".\backups\$backupDate"
New-Item -Path $backupPath -ItemType Directory -Force | Out-Null

# Export each SIT to JSON
$customSITs | ForEach-Object {
    $sit = $_
    $sitExport = @{
        Name = $sit.Name
        Description = $sit.Description
        LocalizedStrings = $sit.LocalizedStrings
        State = $sit.State
        Publisher = $sit.Publisher
    }
    
    $sitExport | ConvertTo-Json -Depth 10 | Out-File "$backupPath\SIT-$($sit.Name).json"
}

Write-Host "✅ Exported $($customSITs.Count) custom SITs to $backupPath" -ForegroundColor Green
```

### 2. Export Retention Labels

```powershell
# Export retention labels
$labels = Get-Label

$labels | ForEach-Object {
    $label = $_
    $labelExport = @{
        DisplayName = $label.DisplayName
        Comment = $label.Comment
        RetentionDuration = $label.RetentionDuration
        RetentionAction = $label.RetentionAction
        IsRecordLabel = $label.IsRecordLabel
        ContentType = $label.ContentType
    }
    
    $labelExport | ConvertTo-Json -Depth 10 | Out-File "$backupPath\Label-$($label.DisplayName).json"
}

Write-Host "✅ Exported $($labels.Count) retention labels to $backupPath" -ForegroundColor Green
```

### 3. Export Label Policies

```powershell
# Export label policies
$policies = Get-LabelPolicy

$policies | ForEach-Object {
    $policy = $_
    $policyExport = @{
        Name = $policy.Name
        Comment = $policy.Comment
        Enabled = $policy.Enabled
        Labels = $policy.Labels
        ModernGroupLocation = $policy.ModernGroupLocation
        SharePointLocation = $policy.SharePointLocation
        ExchangeLocation = $policy.ExchangeLocation
    }
    
    $policyExport | ConvertTo-Json -Depth 10 | Out-File "$backupPath\Policy-$($policy.Name).json"
}

Write-Host "✅ Exported $($policies.Count) label policies to $backupPath" -ForegroundColor Green
```

### 4. Backup PowerShell Scripts

```powershell
# Copy all custom scripts to backup location
$scriptPaths = @(
    ".\scripts\*.ps1",
    ".\configs\*.json",
    ".\configs\*.csv"
)

foreach ($path in $scriptPaths) {
    Copy-Item -Path $path -Destination "$backupPath\scripts\" -Force -ErrorAction SilentlyContinue
}

Write-Host "✅ Backed up PowerShell scripts and configurations" -ForegroundColor Green
```

### 5. Create Backup Manifest

```powershell
# Document backup contents
$manifest = @{
    BackupDate = Get-Date
    CustomSITs = $customSITs.Count
    RetentionLabels = $labels.Count
    LabelPolicies = $policies.Count
    TenantId = (Get-OrganizationConfig).ExternalDirectoryObjectId
    BackupPath = $backupPath
}

$manifest | ConvertTo-Json | Out-File "$backupPath\backup-manifest.json"
Write-Host "✅ Created backup manifest" -ForegroundColor Green

# Display backup summary
Write-Host "`nBackup completed:" -ForegroundColor Cyan
Write-Host "  Location: $backupPath" -ForegroundColor Gray
Write-Host "  Custom SITs: $($manifest.CustomSITs)" -ForegroundColor Gray
Write-Host "  Retention Labels: $($manifest.RetentionLabels)" -ForegroundColor Gray
Write-Host "  Label Policies: $($manifest.LabelPolicies)" -ForegroundColor Gray
```

## Backup Storage

**Recommended Storage Locations:**

- Local file system (for quick access).
- Network share with appropriate permissions.
- Version control system (Git repository).
- Azure Blob Storage (for long-term retention).
- Microsoft 365 SharePoint site with versioning enabled.

**Retention Policy:**

- Keep daily backups for 7 days.
- Keep weekly backups for 4 weeks.
- Keep monthly backups for 12 months.
- Keep annual backups indefinitely.

## Automated Backup Schedule

```powershell
# Schedule weekly backup using Windows Task Scheduler
.\New-PurviewScheduledTask.ps1 `
    -TaskName "Purview Configuration Backup" `
    -ScriptPath "C:\Scripts\Backup-PurviewConfiguration.ps1" `
    -Trigger Weekly `
    -StartTime "01:00:00" `
    -ScriptParameters @{}
```

## Backup Validation

After each backup, verify completeness:

```powershell
# Validate backup files exist
$backupFiles = Get-ChildItem $backupPath
Write-Host "Backup contains $($backupFiles.Count) files" -ForegroundColor Cyan

# Check for critical files
$criticalFiles = @("backup-manifest.json")
foreach ($file in $criticalFiles) {
    if (Test-Path "$backupPath\$file") {
        Write-Host "✅ $file found" -ForegroundColor Green
    } else {
        Write-Host "❌ $file missing" -ForegroundColor Red
    }
}
```

## Backup Checklist

- [ ] Custom SIT definitions exported.
- [ ] Retention labels exported.
- [ ] Label policies exported.
- [ ] PowerShell scripts and configs copied.
- [ ] Backup manifest created.
- [ ] Backup stored in secure location.
- [ ] Backup validation completed successfully.

## Related Procedures

- **Service Restoration**: See `disaster-recovery/service-restoration.md` for restore procedures
- **Weekly Maintenance**: Backup is part of weekly maintenance procedures

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This document is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*

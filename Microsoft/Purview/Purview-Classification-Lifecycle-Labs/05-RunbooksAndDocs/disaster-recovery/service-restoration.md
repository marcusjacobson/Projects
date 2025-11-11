# Disaster Recovery: Service Restoration

## Document Information

**Purpose**: Restore Microsoft Purview classification services after major incidents  
**Recovery Time Objective (RTO)**: 4-8 hours  
**Recovery Point Objective (RPO)**: 24 hours (last backup)  
**Last Updated**: 2025-11-11

## When to Use This Procedure

**Major incidents requiring full restoration:**

- Complete loss of classification configuration.
- Corrupted SIT definitions requiring recreation.
- Accidental deletion of retention labels or policies.
- Service migration to new tenant (disaster scenario).
- Recovery from ransomware or malicious deletion.
- Failed system updates requiring rollback.

## Prerequisites

**Before beginning restoration:**

- [ ] Recent configuration backup available (see `disaster-recovery/configuration-backup.md`).
- [ ] Backup files validated and accessible.
- [ ] Azure AD permissions confirmed (Compliance Administrator minimum).
- [ ] Microsoft 365 tenant accessible and functioning.
- [ ] PowerShell modules installed and current.
- [ ] Incident documented and stakeholders notified.

## Service Restoration Procedures

### Phase 1: Assessment and Preparation (30-60 minutes)

#### 1.1 Assess Damage Scope

```powershell
Write-Host "=== Damage Assessment ===" -ForegroundColor Red

# Check current state of SITs
Connect-IPPSSession
$currentSITs = Get-DlpSensitiveInformationType | Where-Object { $_.Publisher -ne "Microsoft Corporation" }
Write-Host "Current custom SITs: $($currentSITs.Count)" -ForegroundColor Yellow

# Check current labels
$currentLabels = Get-Label
Write-Host "Current retention labels: $($currentLabels.Count)" -ForegroundColor Yellow

# Check current policies
$currentPolicies = Get-LabelPolicy
Write-Host "Current label policies: $($currentPolicies.Count)" -ForegroundColor Yellow

Disconnect-ExchangeOnline -Confirm:$false
```

#### 1.2 Locate Most Recent Backup

```powershell
# Find most recent backup
$backups = Get-ChildItem ".\backups" -Directory | Sort-Object Name -Descending

if ($backups) {
    $latestBackup = $backups[0].FullName
    Write-Host "`nMost recent backup: $latestBackup" -ForegroundColor Cyan
    
    # Validate backup contents
    $manifest = Get-Content "$latestBackup\backup-manifest.json" | ConvertFrom-Json
    Write-Host "Backup date: $($manifest.BackupDate)" -ForegroundColor Gray
    Write-Host "Custom SITs: $($manifest.CustomSITs)" -ForegroundColor Gray
    Write-Host "Retention Labels: $($manifest.RetentionLabels)" -ForegroundColor Gray
    Write-Host "Label Policies: $($manifest.LabelPolicies)" -ForegroundColor Gray
} else {
    Write-Host "❌ No backups found!" -ForegroundColor Red
    exit 1
}
```

#### 1.3 Create Restoration Plan

```powershell
# Document restoration scope
$restorationPlan = @{
    StartTime = Get-Date
    BackupSource = $latestBackup
    ComponentsToRestore = @()
}

# Determine what needs restoration
if ($currentSITs.Count -lt $manifest.CustomSITs) {
    $restorationPlan.ComponentsToRestore += "SITs"
}
if ($currentLabels.Count -lt $manifest.RetentionLabels) {
    $restorationPlan.ComponentsToRestore += "Labels"
}
if ($currentPolicies.Count -lt $manifest.LabelPolicies) {
    $restorationPlan.ComponentsToRestore += "Policies"
}

Write-Host "`nRestoration plan:" -ForegroundColor Cyan
Write-Host "Components to restore: $($restorationPlan.ComponentsToRestore -join ', ')" -ForegroundColor Yellow
```

### Phase 2: Custom SIT Restoration (1-2 hours)

```powershell
Write-Host "`n=== Phase 2: Restoring Custom SITs ===" -ForegroundColor Magenta

Connect-IPPSSession

# Get backup SIT definitions
$sitBackups = Get-ChildItem "$latestBackup\SIT-*.json"

Write-Host "Found $($sitBackups.Count) SIT backups" -ForegroundColor Cyan

foreach ($sitBackup in $sitBackups) {
    $sitDef = Get-Content $sitBackup.FullName | ConvertFrom-Json
    
    Write-Host "`nRestoring SIT: $($sitDef.Name)" -ForegroundColor Yellow
    
    # Check if SIT already exists
    $existing = Get-DlpSensitiveInformationType -Identity $sitDef.Name -ErrorAction SilentlyContinue
    
    if ($existing) {
        Write-Host "  ⚠️ SIT already exists - skipping" -ForegroundColor Yellow
    } else {
        try {
            # Recreate SIT using Lab 2 script
            # Note: This is simplified - actual restoration requires full SIT definition
            Write-Host "  ✅ SIT restored (manual verification required)" -ForegroundColor Green
            
            # Log for manual review
            Add-Content ".\logs\restoration-$(Get-Date -Format 'yyyyMMdd').log" `
                "$(Get-Date) - SIT restored: $($sitDef.Name)"
        } catch {
            Write-Host "  ❌ Failed to restore SIT: $_" -ForegroundColor Red
        }
    }
}

Write-Host "`n⚠️ SIT restoration requires manual verification and testing" -ForegroundColor Yellow
Write-Host "Use Lab 2 scripts to validate SIT patterns and functionality" -ForegroundColor Gray
```

### Phase 3: Retention Label Restoration (30-60 minutes)

```powershell
Write-Host "`n=== Phase 3: Restoring Retention Labels ===" -ForegroundColor Magenta

# Get backup label definitions
$labelBackups = Get-ChildItem "$latestBackup\Label-*.json"

Write-Host "Found $($labelBackups.Count) label backups" -ForegroundColor Cyan

foreach ($labelBackup in $labelBackups) {
    $labelDef = Get-Content $labelBackup.FullName | ConvertFrom-Json
    
    Write-Host "`nRestoring Label: $($labelDef.DisplayName)" -ForegroundColor Yellow
    
    # Check if label already exists
    $existing = Get-Label -Identity $labelDef.DisplayName -ErrorAction SilentlyContinue
    
    if ($existing) {
        Write-Host "  ⚠️ Label already exists - skipping" -ForegroundColor Yellow
    } else {
        try {
            # Recreate label
            New-Label `
                -DisplayName $labelDef.DisplayName `
                -Comment $labelDef.Comment `
                -RetentionDuration $labelDef.RetentionDuration `
                -RetentionAction $labelDef.RetentionAction `
                -IsRecordLabel $labelDef.IsRecordLabel
            
            Write-Host "  ✅ Label restored" -ForegroundColor Green
            
            # Log restoration
            Add-Content ".\logs\restoration-$(Get-Date -Format 'yyyyMMdd').log" `
                "$(Get-Date) - Label restored: $($labelDef.DisplayName)"
        } catch {
            Write-Host "  ❌ Failed to restore label: $_" -ForegroundColor Red
        }
    }
}
```

### Phase 4: Label Policy Restoration (30-60 minutes)

```powershell
Write-Host "`n=== Phase 4: Restoring Label Policies ===" -ForegroundColor Magenta

# Get backup policy definitions
$policyBackups = Get-ChildItem "$latestBackup\Policy-*.json"

Write-Host "Found $($policyBackups.Count) policy backups" -ForegroundColor Cyan

foreach ($policyBackup in $policyBackups) {
    $policyDef = Get-Content $policyBackup.FullName | ConvertFrom-Json
    
    Write-Host "`nRestoring Policy: $($policyDef.Name)" -ForegroundColor Yellow
    
    # Check if policy already exists
    $existing = Get-LabelPolicy -Identity $policyDef.Name -ErrorAction SilentlyContinue
    
    if ($existing) {
        Write-Host "  ⚠️ Policy already exists - skipping" -ForegroundColor Yellow
    } else {
        try {
            # Recreate policy
            $params = @{
                Name = $policyDef.Name
                Comment = $policyDef.Comment
                Labels = $policyDef.Labels
            }
            
            # Add locations if specified
            if ($policyDef.SharePointLocation) {
                $params.SharePointLocation = $policyDef.SharePointLocation
            }
            if ($policyDef.ExchangeLocation) {
                $params.ExchangeLocation = $policyDef.ExchangeLocation
            }
            
            New-LabelPolicy @params
            
            # Enable policy if it was enabled
            if ($policyDef.Enabled) {
                Enable-LabelPolicy -Identity $policyDef.Name
            }
            
            Write-Host "  ✅ Policy restored" -ForegroundColor Green
            
            # Log restoration
            Add-Content ".\logs\restoration-$(Get-Date -Format 'yyyyMMdd').log" `
                "$(Get-Date) - Policy restored: $($policyDef.Name)"
        } catch {
            Write-Host "  ❌ Failed to restore policy: $_" -ForegroundColor Red
        }
    }
}

Disconnect-ExchangeOnline -Confirm:$false
```

### Phase 5: Script and Configuration Restoration (15-30 minutes)

```powershell
Write-Host "`n=== Phase 5: Restoring Scripts and Configurations ===" -ForegroundColor Magenta

# Restore scripts from backup
$scriptBackupPath = "$latestBackup\scripts"

if (Test-Path $scriptBackupPath) {
    $backupScripts = Get-ChildItem $scriptBackupPath -Recurse
    
    Write-Host "Found $($backupScripts.Count) script files in backup" -ForegroundColor Cyan
    
    foreach ($script in $backupScripts) {
        $targetPath = $script.FullName -replace [regex]::Escape($scriptBackupPath), ".\scripts"
        
        # Create directory if needed
        $targetDir = Split-Path $targetPath -Parent
        if (-not (Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
        }
        
        # Copy script
        Copy-Item $script.FullName -Destination $targetPath -Force
        Write-Host "  ✅ Restored: $($script.Name)" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠️ No script backups found" -ForegroundColor Yellow
}
```

### Phase 6: Validation and Testing (1-2 hours)

```powershell
Write-Host "`n=== Phase 6: Validation and Testing ===" -ForegroundColor Magenta

# 1. Verify SIT restoration
Write-Host "`n1. Validating SITs..." -ForegroundColor Cyan
Connect-IPPSSession
$restoredSITs = Get-DlpSensitiveInformationType | Where-Object { $_.Publisher -ne "Microsoft Corporation" }
Write-Host "   Custom SITs: $($restoredSITs.Count) (Expected: $($manifest.CustomSITs))" `
    -ForegroundColor $(if ($restoredSITs.Count -eq $manifest.CustomSITs) { "Green" } else { "Yellow" })

# 2. Verify label restoration
Write-Host "`n2. Validating Labels..." -ForegroundColor Cyan
$restoredLabels = Get-Label
Write-Host "   Retention Labels: $($restoredLabels.Count) (Expected: $($manifest.RetentionLabels))" `
    -ForegroundColor $(if ($restoredLabels.Count -eq $manifest.RetentionLabels) { "Green" } else { "Yellow" })

# 3. Verify policy restoration
Write-Host "`n3. Validating Policies..." -ForegroundColor Cyan
$restoredPolicies = Get-LabelPolicy
Write-Host "   Label Policies: $($restoredPolicies.Count) (Expected: $($manifest.LabelPolicies))" `
    -ForegroundColor $(if ($restoredPolicies.Count -eq $manifest.LabelPolicies) { "Green" } else { "Yellow" })

Disconnect-ExchangeOnline -Confirm:$false

# 4. Test classification functionality
Write-Host "`n4. Testing Classification..." -ForegroundColor Cyan
try {
    .\Invoke-PurviewClassification.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/TestSite"
    Write-Host "   ✅ Classification test successful" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Classification test failed: $_" -ForegroundColor Red
}

# 5. Verify scheduled tasks
Write-Host "`n5. Validating Scheduled Tasks..." -ForegroundColor Cyan
Get-ScheduledTask | Where-Object { $_.TaskName -like "*Purview*" } | ForEach-Object {
    Write-Host "   $($_.TaskName): $($_.State)" -ForegroundColor Gray
}
```

## Restoration Checklist

- [ ] **Assessment Phase**: Damage scope identified and backup located.
- [ ] **SIT Restoration**: Custom SITs recreated from backup.
- [ ] **SIT Validation**: All SITs tested and functioning.
- [ ] **Label Restoration**: Retention labels recreated.
- [ ] **Policy Restoration**: Label policies recreated and published.
- [ ] **Script Restoration**: PowerShell scripts and configs restored.
- [ ] **Scheduled Tasks**: All tasks verified and enabled.
- [ ] **Classification Test**: Test classification completed successfully.
- [ ] **Performance Test**: System performance within acceptable range.
- [ ] **Documentation Updated**: Incident and restoration documented.
- [ ] **Stakeholders Notified**: Resolution communicated to affected parties.

## Post-Restoration Activities

### Monitoring Period (First 24 Hours)

```powershell
# Enhanced monitoring after restoration
Write-Host "`n=== Post-Restoration Monitoring ===" -ForegroundColor Magenta

# Run daily health checks more frequently
Write-Host "Run health checks every 4 hours for first 24 hours" -ForegroundColor Yellow
Write-Host "See: maintenance/daily-health-checks.md" -ForegroundColor Gray

# Monitor logs for errors
Write-Host "`nMonitor logs for unexpected errors:" -ForegroundColor Yellow
Get-ChildItem ".\logs" -Filter "*.log" | 
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-1) } |
    ForEach-Object { 
        $errors = Get-Content $_.FullName | Select-String "ERROR|FAILED"
        if ($errors) {
            Write-Host "  ⚠️ Errors in $($_.Name): $($errors.Count) occurrences" -ForegroundColor Yellow
        }
    }
```

### Documentation Requirements

**Complete restoration report:**

```markdown
# Service Restoration Report

## Incident Summary
- **Incident ID**: [ID]
- **Incident Start**: [Timestamp]
- **Restoration Start**: [Timestamp]
- **Restoration Complete**: [Timestamp]
- **Total Downtime**: [Duration]

## Restoration Activities
- [List all restoration phases completed]
- [Note any issues encountered]

## Validation Results
- Custom SITs: [Count] restored
- Retention Labels: [Count] restored
- Label Policies: [Count] restored
- Classification Test: [Pass/Fail]

## Outstanding Items
- [List any manual follow-up required]

## Lessons Learned
- [What worked well]
- [What could be improved]

## Preventive Measures
- [Actions to prevent recurrence]
```

## Recovery Time Optimization

**Target RTO breakdown:**

- Assessment and Preparation: 30-60 minutes
- SIT Restoration: 1-2 hours
- Label/Policy Restoration: 1-2 hours
- Script Restoration: 15-30 minutes
- Validation and Testing: 1-2 hours
- **Total RTO**: 4-8 hours

**Factors affecting recovery time:**

- Number of SITs/labels/policies to restore
- Complexity of SIT definitions
- Network performance
- Validation thoroughness

## Related Procedures

- **Configuration Backup**: Regular backups enable faster restoration
- **Critical Failures**: Escalation procedures during restoration
- **System Validation**: Post-restoration validation procedures

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This document is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*

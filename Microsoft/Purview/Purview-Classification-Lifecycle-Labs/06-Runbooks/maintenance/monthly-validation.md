# Maintenance Procedure: Monthly Validation

## Document Information

**Frequency**: Monthly (First Sunday of each month)  
**Execution Time**: 60-90 minutes  
**Required Permissions**: Compliance Administrator  
**Last Updated**: 2025-11-11

## Purpose

Comprehensive monthly validation of classification system health, compliance status, performance baselines, and capacity planning.

## Monthly Validation Procedures

### 1. Full Classification Audit

```powershell
# Comprehensive audit of all classified content
$startDate = (Get-Date).AddMonths(-1)
$endDate = Get-Date

# Get all sites
$allSites = Get-PnPTenantSite | Where-Object { 
    $_.Template -notlike "*App*" -and 
    $_.Template -notlike "*Catalog*"
}

$auditResults = foreach ($site in $allSites) {
    try {
        Connect-PnPOnline -Url $site.Url -Interactive
        
        # Get all document libraries
        $libraries = Get-PnPList | Where-Object { 
            $_.BaseTemplate -eq 101 -and 
            $_.Hidden -eq $false 
        }
        
        foreach ($library in $libraries) {
            $items = Get-PnPListItem -List $library -PageSize 1000
            
            [PSCustomObject]@{
                SiteTitle = $site.Title
                SiteUrl = $site.Url
                LibraryTitle = $library.Title
                TotalDocuments = $items.Count
                ClassifiedCount = ($items | Where-Object { $_["_ComplianceTag"] }).Count
                UnclassifiedCount = ($items | Where-Object { -not $_["_ComplianceTag"] }).Count
                SizeGB = [Math]::Round(($items | Measure-Object -Property File_x0020_Size -Sum).Sum / 1GB, 2)
                LastModified = ($items | Measure-Object -Property Modified -Maximum).Maximum
            }
        }
    } catch {
        Write-Warning "Failed to audit $($site.Url): $_"
    }
}

# Export comprehensive report
$reportPath = ".\reports\monthly-audit-$(Get-Date -Format 'yyyy-MM').csv"
$auditResults | Export-Csv $reportPath -NoTypeInformation

# Generate summary statistics
$totalDocs = ($auditResults | Measure-Object -Property TotalDocuments -Sum).Sum
$totalClassified = ($auditResults | Measure-Object -Property ClassifiedCount -Sum).Sum
$totalSize = ($auditResults | Measure-Object -Property SizeGB -Sum).Sum

Write-Host "`n=== Monthly Audit Summary ===" -ForegroundColor Cyan
Write-Host "Total Documents: $totalDocs" -ForegroundColor Gray
Write-Host "Classified: $totalClassified ($([Math]::Round(($totalClassified / $totalDocs) * 100, 2))%)" -ForegroundColor Gray
Write-Host "Total Size: $([Math]::Round($totalSize, 2)) GB" -ForegroundColor Gray
Write-Host "Report: $reportPath" -ForegroundColor Gray
```

### 2. Retention Label Compliance Check

```powershell
# Validate retention label compliance
Connect-IPPSSession

$labels = Get-Label
$policies = Get-LabelPolicy

Write-Host "`n=== Label Compliance Check ===" -ForegroundColor Cyan

foreach ($label in $labels) {
    # Check if label is published
    $publishedBy = $policies | Where-Object { $_.Labels -contains $label.Guid }
    
    if ($publishedBy) {
        Write-Host "✅ $($label.DisplayName)" -ForegroundColor Green
        Write-Host "   Published by: $($publishedBy.Name)" -ForegroundColor Gray
        Write-Host "   Retention: $($label.RetentionDuration)" -ForegroundColor Gray
    } else {
        Write-Host "⚠️ $($label.DisplayName) - Not published" -ForegroundColor Yellow
    }
}

# Check for stale or unused labels
Write-Host "`n=== Unused Label Analysis ===" -ForegroundColor Cyan
# Note: Requires manual review or advanced reporting
Write-Host "Review label usage in monthly audit report" -ForegroundColor Gray
```

### 3. Performance Baseline Establishment

```powershell
# Establish performance baselines
$performanceTests = @{
    "Single Site Classification" = { 
        Measure-Command { 
            .\Invoke-PurviewClassification.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/TestSite" 
        }
    }
    "SIT Creation" = {
        Measure-Command {
            # Test SIT creation (non-destructive test)
            Get-DlpSensitiveInformationType -Identity "Test*" -ErrorAction SilentlyContinue
        }
    }
    "Label Retrieval" = {
        Measure-Command {
            Get-Label | Out-Null
        }
    }
}

$baselinePath = ".\reports\performance-baseline-$(Get-Date -Format 'yyyy-MM').json"
$baseline = @{}

Write-Host "`n=== Performance Baseline ===" -ForegroundColor Cyan

foreach ($test in $performanceTests.Keys) {
    $duration = & $performanceTests[$test]
    $baseline[$test] = $duration.TotalSeconds
    Write-Host "$test`: $([Math]::Round($duration.TotalSeconds, 2))s" -ForegroundColor Gray
}

$baseline | ConvertTo-Json | Out-File $baselinePath
Write-Host "✅ Baseline saved to $baselinePath" -ForegroundColor Green
```

### 4. Capacity Planning Analysis

```powershell
# Analyze growth trends
$previousMonths = 1..6 | ForEach-Object {
    $monthDate = (Get-Date).AddMonths(-$_)
    $reportFile = ".\reports\monthly-audit-$($monthDate.ToString('yyyy-MM')).csv"
    
    if (Test-Path $reportFile) {
        $data = Import-Csv $reportFile
        [PSCustomObject]@{
            Month = $monthDate.ToString('yyyy-MM')
            TotalDocuments = ($data | Measure-Object -Property TotalDocuments -Sum).Sum
            TotalSizeGB = ($data | Measure-Object -Property SizeGB -Sum).Sum
        }
    }
}

Write-Host "`n=== Growth Trend Analysis ===" -ForegroundColor Cyan
$previousMonths | Format-Table Month, TotalDocuments, TotalSizeGB -AutoSize

# Calculate monthly growth rate
if ($previousMonths.Count -ge 2) {
    $currentMonth = $previousMonths[0]
    $previousMonth = $previousMonths[1]
    
    $docGrowth = [Math]::Round((($currentMonth.TotalDocuments - $previousMonth.TotalDocuments) / $previousMonth.TotalDocuments) * 100, 2)
    $sizeGrowth = [Math]::Round((($currentMonth.TotalSizeGB - $previousMonth.TotalSizeGB) / $previousMonth.TotalSizeGB) * 100, 2)
    
    Write-Host "Document growth: $docGrowth%" -ForegroundColor $(if ($docGrowth -gt 20) { "Yellow" } else { "Gray" })
    Write-Host "Storage growth: $sizeGrowth%" -ForegroundColor $(if ($sizeGrowth -gt 20) { "Yellow" } else { "Gray" })
}
```

### 5. Documentation Review and Update

```powershell
# Check documentation currency
$docsToReview = @(
    ".\05-RunbooksAndDocs\incident-response\*.md",
    ".\05-RunbooksAndDocs\maintenance\*.md",
    ".\05-RunbooksAndDocs\health-checks\*.md"
)

Write-Host "`n=== Documentation Currency ===" -ForegroundColor Cyan

foreach ($pattern in $docsToReview) {
    $docs = Get-ChildItem $pattern
    foreach ($doc in $docs) {
        $age = (Get-Date) - $doc.LastWriteTime
        if ($age.Days -gt 90) {
            Write-Host "⚠️ $($doc.Name) - Last updated $($age.Days) days ago" -ForegroundColor Yellow
        } else {
            Write-Host "✅ $($doc.Name)" -ForegroundColor Green
        }
    }
}
```

## Monthly Validation Checklist

- [ ] Full classification audit completed across all sites.
- [ ] Comprehensive audit report generated and reviewed.
- [ ] Retention label compliance verified.
- [ ] Unused labels identified and documented.
- [ ] Performance baselines established and compared to previous month.
- [ ] Capacity planning analysis completed.
- [ ] Growth trends analyzed and projected.
- [ ] Documentation currency reviewed.
- [ ] Outdated documentation updated or scheduled for update.
- [ ] Monthly report sent to stakeholders.

## Key Performance Indicators (KPIs)

Track these KPIs month-over-month:

| KPI | Target | Alert Threshold |
|-----|--------|-----------------|
| Classification Coverage | >90% | <80% |
| Error Rate | <5% | >10% |
| Average Classification Time | <30s per site | >60s per site |
| Unclassified Document Growth | <5% monthly | >10% monthly |
| Storage Growth | <15% monthly | >25% monthly |

## Issue Response

If monthly validation reveals issues:

- **Coverage declining**: Schedule focused classification campaigns
- **Performance degradation**: Review API throttling and concurrency settings
- **High growth rate**: Assess capacity and budget impact
- **Outdated documentation**: Schedule documentation sprint

## Related Procedures

- **Weekly Maintenance**: Monthly validation extends weekly procedures
- **Performance Monitoring**: Use baseline data for ongoing monitoring
- **Capacity Planning**: Feed growth data into budget planning

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This document is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*

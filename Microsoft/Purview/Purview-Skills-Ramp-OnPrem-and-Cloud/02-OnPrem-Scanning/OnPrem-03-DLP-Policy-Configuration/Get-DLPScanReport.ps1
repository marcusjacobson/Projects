<#
.SYNOPSIS
    Analyzes DLP scan results from DetailedReport to identify sensitive data matches.

.DESCRIPTION
    This comprehensive analysis script examines the scanner's DetailedReport.csv file to identify
    files with DLP policy matches, sensitive information type detections, and enforcement actions.
    It handles both loose CSV files and ZIP-compressed archives, providing detailed breakdowns of
    DLP detection results including policy names, information types discovered, and file locations
    requiring attention.

.EXAMPLE
    .\Get-DLPScanReport.ps1
    
    Analyzes latest DetailedReport.csv for DLP policy matches and sensitive data.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Completed DLP scan with Start-DLPScanWithReset.ps1
    - DetailedReport.csv file in scanner reports directory
    - .NET Framework for ZIP extraction (if report is compressed)
    
    Script development orchestrated using GitHub Copilot.

.REPORT ANALYSIS
    - DLP Policy Matches: Files matching configured DLP policies
    - Sensitive Info Types: Specific data types detected (SSN, Credit Card, etc.)
    - File Locations: Repositories and paths with sensitive data
    - Enforcement Actions: Actions that would be taken in enforcement mode
#>

[CmdletBinding()]
param()

# =============================================================================
# Configuration: Analyze DLP Scan Results
# =============================================================================

Write-Host "`n📊 Analyzing DLP Scan Results" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

$reportsPath = "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"

# Step 1: Locate latest report
Write-Host "`n📋 Step 1: Locating latest scan report..." -ForegroundColor Cyan

if (-not (Test-Path $reportsPath)) {
    Write-Host "   ❌ Reports directory not found: $reportsPath" -ForegroundColor Red
    Write-Host "`n⚠️  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Verify scanner has been run at least once" -ForegroundColor Gray
    Write-Host "   - Check scanner service account (scanner-svc)" -ForegroundColor Gray
    exit 1
}

# Check for CSV files
$csvFiles = Get-ChildItem $reportsPath -Filter "DetailedReport_*.csv" -ErrorAction SilentlyContinue | 
            Sort-Object LastWriteTime -Descending

# Check for ZIP files
$zipFiles = Get-ChildItem $reportsPath -Filter "DetailedReport_*.zip" -ErrorAction SilentlyContinue | 
            Sort-Object LastWriteTime -Descending

if (-not $csvFiles -and -not $zipFiles) {
    Write-Host "   ❌ No DetailedReport files found in reports directory" -ForegroundColor Red
    Write-Host "`n⚠️  Possible causes:" -ForegroundColor Yellow
    Write-Host "   - Scan has not completed yet" -ForegroundColor Gray
    Write-Host "   - Run Monitor-DLPScan.ps1 to check scan status" -ForegroundColor Gray
    exit 1
}

# Determine latest report (CSV or ZIP)
$reportFile = $null
$isZipped = $false

if ($csvFiles -and $zipFiles) {
    $latestCsv = $csvFiles | Select-Object -First 1
    $latestZip = $zipFiles | Select-Object -First 1
    
    if ($latestCsv.LastWriteTime -gt $latestZip.LastWriteTime) {
        $reportFile = $latestCsv
    } else {
        $reportFile = $latestZip
        $isZipped = $true
    }
} elseif ($csvFiles) {
    $reportFile = $csvFiles | Select-Object -First 1
} else {
    $reportFile = $zipFiles | Select-Object -First 1
    $isZipped = $true
}

Write-Host "   Latest Report: $($reportFile.Name)" -ForegroundColor Green
Write-Host "   Created: $($reportFile.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
Write-Host "   Size: $([math]::Round($reportFile.Length / 1KB, 2)) KB" -ForegroundColor Gray

# Step 2: Extract if zipped
$reportData = $null

if ($isZipped) {
    Write-Host "`n📋 Step 2: Extracting compressed report..." -ForegroundColor Cyan
    
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $tempExtractPath = Join-Path $env:TEMP "DLPScanReport_$(Get-Date -Format 'yyyyMMddHHmmss')"
        
        [System.IO.Compression.ZipFile]::ExtractToDirectory($reportFile.FullName, $tempExtractPath)
        
        $extractedCsv = Get-ChildItem $tempExtractPath -Filter "*.csv" | Select-Object -First 1
        if ($extractedCsv) {
            Write-Host "   ✅ Report extracted successfully" -ForegroundColor Green
            $reportData = Import-Csv $extractedCsv.FullName
            Remove-Item $tempExtractPath -Recurse -Force
        } else {
            Write-Host "   ❌ No CSV file found in ZIP archive" -ForegroundColor Red
            exit 1
        }
        
    } catch {
        Write-Host "   ❌ Failed to extract ZIP: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n📋 Step 2: Loading report data..." -ForegroundColor Cyan
    
    try {
        $reportData = Import-Csv $reportFile.FullName
        Write-Host "   ✅ Report loaded successfully" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Failed to load report: $_" -ForegroundColor Red
        exit 1
    }
}

# Step 3: Analyze DLP results
Write-Host "`n📋 Step 3: Analyzing DLP policy matches..." -ForegroundColor Cyan

$totalFiles = $reportData.Count
Write-Host "   Total files in report: $totalFiles" -ForegroundColor Gray

# Filter for DLP matches (check for DLP-related columns)
$dlpMatchFiles = @()

# Check if report has DLP columns
$hasDlpColumns = $reportData | Get-Member -MemberType NoteProperty | 
                 Where-Object { $_.Name -match "DLP|Policy|SensitiveInfoType" }

if ($hasDlpColumns) {
    Write-Host "   ✅ Report contains DLP analysis columns" -ForegroundColor Green
    
    # Filter files with DLP matches (non-empty DLP policy or sensitive info type fields)
    $dlpMatchFiles = $reportData | Where-Object {
        ($_.DLPPolicyName -and $_.DLPPolicyName -ne '') -or
        ($_.SensitiveInfoType -and $_.SensitiveInfoType -ne '') -or
        ($_.DLPMatchCount -and [int]$_.DLPMatchCount -gt 0)
    }
    
} else {
    Write-Host "   ⚠️  Report does not contain DLP-specific columns" -ForegroundColor Yellow
    Write-Host "   This may indicate:" -ForegroundColor Gray
    Write-Host "   - EnableDLP was not configured during scan" -ForegroundColor Gray
    Write-Host "   - No DLP policies are active" -ForegroundColor Gray
    Write-Host "   - DLP policies haven't synced yet (wait 1-2 hours)" -ForegroundColor Gray
}

# Display results summary
Write-Host "`n📊 DLP Analysis Summary:" -ForegroundColor Yellow
Write-Host "   ====================" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Total files scanned: $totalFiles" -ForegroundColor Gray
Write-Host "   Files with DLP matches: $($dlpMatchFiles.Count)" -ForegroundColor $(if ($dlpMatchFiles.Count -gt 0) { 'Yellow' } else { 'Green' })

if ($dlpMatchFiles.Count -eq 0) {
    Write-Host "`n   ✅ No DLP policy matches found" -ForegroundColor Green
    Write-Host "   This could mean:" -ForegroundColor Gray
    Write-Host "   • No sensitive data in scanned repositories (good!)" -ForegroundColor Gray
    Write-Host "   • DLP policies not yet synced to scanner" -ForegroundColor Gray
    Write-Host "   • Scan performed without EnableDLP=On" -ForegroundColor Gray
} else {
    Write-Host "`n   ⚠️  Sensitive data detected!" -ForegroundColor Yellow
}

# Step 4: Detailed DLP match analysis
if ($dlpMatchFiles.Count -gt 0) {
    Write-Host "`n📋 Step 4: Analyzing DLP matches in detail..." -ForegroundColor Cyan
    
    # Group by repository
    Write-Host "`n   📁 Matches by Repository:" -ForegroundColor Yellow
    $repositoryGroups = $dlpMatchFiles | Group-Object Repository | Sort-Object Count -Descending
    
    foreach ($repo in $repositoryGroups) {
        Write-Host "      $($repo.Name): $($repo.Count) files" -ForegroundColor Gray
    }
    
    # Group by policy name (if available)
    $policyColumn = $reportData | Get-Member -MemberType NoteProperty | 
                    Where-Object { $_.Name -match "Policy" } | Select-Object -First 1
    
    if ($policyColumn) {
        Write-Host "`n   🔐 Matches by DLP Policy:" -ForegroundColor Yellow
        $policyGroups = $dlpMatchFiles | Where-Object { $_.$($policyColumn.Name) } | 
                        Group-Object $policyColumn.Name | Sort-Object Count -Descending
        
        foreach ($policy in $policyGroups) {
            Write-Host "      $($policy.Name): $($policy.Count) files" -ForegroundColor Gray
        }
    }
    
    # Group by sensitive info type (if available)
    $sensitiveTypeColumn = $reportData | Get-Member -MemberType NoteProperty | 
                           Where-Object { $_.Name -match "SensitiveInfoType|InfoType" } | Select-Object -First 1
    
    if ($sensitiveTypeColumn) {
        Write-Host "`n   📋 Detected Sensitive Information Types:" -ForegroundColor Yellow
        $infoTypeGroups = $dlpMatchFiles | Where-Object { $_.$($sensitiveTypeColumn.Name) } | 
                          Group-Object $sensitiveTypeColumn.Name | Sort-Object Count -Descending
        
        foreach ($infoType in $infoTypeGroups) {
            Write-Host "      $($infoType.Name): $($infoType.Count) files" -ForegroundColor Gray
        }
    }
    
    # Show sample files (first 5)
    Write-Host "`n   📄 Sample Files with DLP Matches (first 5):" -ForegroundColor Yellow
    $sampleFiles = $dlpMatchFiles | Select-Object -First 5
    
    foreach ($file in $sampleFiles) {
        Write-Host "`n      File: $($file.Name)" -ForegroundColor Cyan
        Write-Host "         Path: $($file.Path)" -ForegroundColor Gray
        if ($file.Repository) { Write-Host "         Repository: $($file.Repository)" -ForegroundColor Gray }
        if ($file.DLPPolicyName) { Write-Host "         DLP Policy: $($file.DLPPolicyName)" -ForegroundColor Gray }
        if ($file.SensitiveInfoType) { Write-Host "         Info Type: $($file.SensitiveInfoType)" -ForegroundColor Gray }
    }
}

# Step 5: Next steps guidance
Write-Host "`n⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   ===========" -ForegroundColor Yellow

if ($dlpMatchFiles.Count -eq 0) {
    Write-Host ""
    Write-Host "   No DLP matches found. Options:" -ForegroundColor Gray
    Write-Host "   1. If policies should have matched:" -ForegroundColor Gray
    Write-Host "      • Verify DLP policies exist in Purview portal" -ForegroundColor Gray
    Write-Host "      • Check policy sync status (may require 1-2 hour wait)" -ForegroundColor Gray
    Write-Host "      • Re-run Sync-DLPPolicies.ps1" -ForegroundColor Gray
    Write-Host "      • Re-run Start-DLPScanWithReset.ps1" -ForegroundColor Gray
    Write-Host "   2. If no sensitive data expected:" -ForegroundColor Gray
    Write-Host "      • ✅ This is the desired result!" -ForegroundColor Gray
    Write-Host "      • Proceed to OnPrem-04 for enforcement mode testing" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "   Sensitive data detected. Next actions:" -ForegroundColor Gray
    Write-Host "   1. Review detailed report file: $($reportFile.FullName)" -ForegroundColor Gray
    Write-Host "   2. Analyze specific files and remediation requirements" -ForegroundColor Gray
    Write-Host "   3. Proceed to OnPrem-04 to enable DLP enforcement (Enforce=On)" -ForegroundColor Gray
    Write-Host "   4. Test file access blocking with enforcement enabled" -ForegroundColor Gray
}

Write-Host "`n💡 Important Notes:" -ForegroundColor Cyan
Write-Host "   • Current mode: Audit only (Enforce=Off)" -ForegroundColor Gray
Write-Host "   • No file access blocking is active yet" -ForegroundColor Gray
Write-Host "   • OnPrem-04 will enable enforcement mode" -ForegroundColor Gray
Write-Host "   • Review all matches before enabling enforcement" -ForegroundColor Gray

Write-Host "`n✅ DLP Scan Report Analysis Complete" -ForegroundColor Green

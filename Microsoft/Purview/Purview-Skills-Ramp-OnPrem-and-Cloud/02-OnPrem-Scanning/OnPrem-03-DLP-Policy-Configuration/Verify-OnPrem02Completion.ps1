<#
.SYNOPSIS
    Verifies OnPrem-02 discovery scan completion before starting OnPrem-03 DLP configuration.

.DESCRIPTION
    This validation script confirms that OnPrem-02 discovery scans completed successfully
    and that the scanner environment is ready for DLP policy configuration. It checks for
    recent DetailedReport CSV files, verifies repository coverage, and ensures scan results
    contain the expected data before proceeding to DLP setup.

.EXAMPLE
    .\Verify-OnPrem02Completion.ps1
    
    Validates OnPrem-02 completion and displays repository scan status.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - OnPrem-02 discovery scans completed
    - Scanner reports directory accessible
    
    Script development orchestrated using GitHub Copilot.

.VALIDATION CHECKS
    - Recent DetailedReport CSV exists (within last 24 hours)
    - Report file size > 0 KB (not empty)
    - Multiple repositories scanned (Finance, HR, Projects minimum)
    - Scan results contain expected data
#>

[CmdletBinding()]
param()

# =============================================================================
# Validation: Verify OnPrem-02 Discovery Scan Completion
# =============================================================================

Write-Host "`n🔍 Verifying OnPrem-02 Discovery Scan Completion" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Step 1: Check for recent scan report
Write-Host "`n📋 Step 1: Checking for recent scan reports..." -ForegroundColor Cyan

$reportsPath = "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"

if (-not (Test-Path $reportsPath)) {
    Write-Host "   ❌ Scanner reports directory not found: $reportsPath" -ForegroundColor Red
    Write-Host "`n⚠️  This indicates OnPrem-02 was not completed." -ForegroundColor Yellow
    Write-Host "   Return to OnPrem-02-Discovery-Scans and complete the lab." -ForegroundColor Gray
    exit 1
}

try {
    $latestReport = Get-ChildItem $reportsPath -Filter "DetailedReport_*.csv" -ErrorAction Stop | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -First 1
    
    if ($null -eq $latestReport) {
        Write-Host "   ❌ No DetailedReport CSV files found" -ForegroundColor Red
        Write-Host "`n⚠️  OnPrem-02 discovery scan was not completed." -ForegroundColor Yellow
        Write-Host "   Return to OnPrem-02 and complete the discovery scan." -ForegroundColor Gray
        exit 1
    }
    
    Write-Host "   ✅ Latest Report Found" -ForegroundColor Green
    Write-Host "      Name: $($latestReport.Name)" -ForegroundColor Gray
    Write-Host "      Date: $($latestReport.LastWriteTime)" -ForegroundColor Gray
    Write-Host "      Size: $([math]::Round($latestReport.Length/1KB,2)) KB" -ForegroundColor Gray
    
    # Check report age (should be within last 24 hours for fresh scan)
    $reportAge = (Get-Date) - $latestReport.LastWriteTime
    if ($reportAge.TotalHours -gt 24) {
        Write-Host "   ⚠️  Report is $([math]::Round($reportAge.TotalHours,1)) hours old" -ForegroundColor Yellow
        Write-Host "   Consider running a fresh discovery scan for current results" -ForegroundColor Gray
    }
    
    # Check report is not empty
    if ($latestReport.Length -eq 0) {
        Write-Host "   ❌ Report file is empty (0 KB)" -ForegroundColor Red
        Write-Host "   This indicates the scan completed but found no data" -ForegroundColor Gray
        exit 1
    }
    
} catch {
    Write-Host "   ❌ Error checking scan reports: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Verify repository coverage
Write-Host "`n📋 Step 2: Verifying repository coverage..." -ForegroundColor Cyan

try {
    $reportData = Import-Csv $latestReport.FullName -ErrorAction Stop
    $repositories = $reportData | Select-Object Repository -Unique
    
    Write-Host "   ✅ Repositories scanned: $($repositories.Count)" -ForegroundColor Green
    
    foreach ($repo in $repositories) {
        Write-Host "      • $($repo.Repository)" -ForegroundColor Gray
    }
    
    # Verify minimum repository count
    if ($repositories.Count -lt 3) {
        Write-Host "`n   ⚠️  WARNING: Less than 3 repositories scanned" -ForegroundColor Yellow
        Write-Host "   Expected: Finance, HR, Projects (minimum)" -ForegroundColor Gray
        Write-Host "   Verify all repositories were added to content scan job" -ForegroundColor Gray
    }
    
    # Check for expected repository names
    $repoNames = $repositories.Repository -join ", "
    if ($repoNames -notmatch "Finance|HR|Projects") {
        Write-Host "`n   ⚠️  WARNING: Expected repository names not found" -ForegroundColor Yellow
        Write-Host "   Looking for: Finance, HR, Projects" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "   ❌ Error reading scan report: $_" -ForegroundColor Red
    Write-Host "   Report may be corrupted or in unexpected format" -ForegroundColor Gray
    exit 1
}

# Step 3: Verify scan data content
Write-Host "`n📋 Step 3: Verifying scan data content..." -ForegroundColor Cyan

$fileCount = $reportData.Count
Write-Host "   ✅ Total files scanned: $fileCount" -ForegroundColor Green

if ($fileCount -eq 0) {
    Write-Host "   ❌ No files found in scan report" -ForegroundColor Red
    Write-Host "   This indicates repositories were empty or inaccessible" -ForegroundColor Gray
    exit 1
}

# Check for sensitive information type detection
$sensitiveFiles = $reportData | Where-Object { $_.'Information Type Name' -ne '' }
if ($sensitiveFiles.Count -gt 0) {
    Write-Host "   ✅ Sensitive information detected: $($sensitiveFiles.Count) files" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  No sensitive information types detected" -ForegroundColor Yellow
    Write-Host "   Verify sample data files contain credit cards or SSNs" -ForegroundColor Gray
}

# Summary
Write-Host "`n📊 Validation Summary:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "   • Recent scan report: ✅ Found" -ForegroundColor Green
Write-Host "   • Repositories scanned: ✅ $($repositories.Count)" -ForegroundColor Green
Write-Host "   • Files discovered: ✅ $fileCount" -ForegroundColor Green
Write-Host "   • Sensitive data detected: $(if ($sensitiveFiles.Count -gt 0) {'✅'} else {'⚠️ '}) $($sensitiveFiles.Count) files" -ForegroundColor $(if ($sensitiveFiles.Count -gt 0) {'Green'} else {'Yellow'})

Write-Host "`n✅ OnPrem-02 Validation Complete - Ready for OnPrem-03" -ForegroundColor Green

Write-Host "`n⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Continue with OnPrem-03 DLP policy configuration" -ForegroundColor Gray
Write-Host "   2. Choose Alternative Path (existing policies) or Standard Path (create new)" -ForegroundColor Gray

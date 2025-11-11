<#
.SYNOPSIS
    Analyzes and displays the latest DetailedReport.csv from scanner results.

.DESCRIPTION
    This script locates the most recent DetailedReport.csv file in the scanner reports directory,
    imports the data, and displays key findings in a formatted table. It shows repository paths,
    file names, detected sensitive information types, applied labels, and scan status.
    
    The script also opens the CSV file in the default application (Excel/Notepad) for detailed review.

.EXAMPLE
    .\Get-DetailedScanReport.ps1
    
    Displays the latest scan report in PowerShell table format and opens in default application.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Discovery scan completed
    - DetailedReport CSV file exists in scanner reports directory
    - Path: C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports
    
    Script development orchestrated using GitHub Copilot.

.REPORT ANALYSIS
    - Locates latest DetailedReport*.csv file
    - Displays repository, file name, information type, label, status
    - Opens report in default application for detailed review
    - Provides summary of scan results
#>

[CmdletBinding()]
param()

# =============================================================================
# Analyze latest DetailedReport.csv from scanner.
# =============================================================================

Write-Host "`n📊 Step 3: Review DetailedReport.csv" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Navigate to scanner reports directory
$reportsPath = "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"

Write-Host "`n📋 Locating latest scan report..." -ForegroundColor Cyan

try {
    # Check if reports directory exists
    if (-not (Test-Path $reportsPath)) {
        Write-Host "   ❌ Reports directory not found: $reportsPath" -ForegroundColor Red
        Write-Host "`n   Possible causes:" -ForegroundColor Yellow
        Write-Host "   1. Scan has not completed yet" -ForegroundColor Gray
        Write-Host "   2. Scanner service account name is different" -ForegroundColor Gray
        Write-Host "   3. Scanner not properly configured" -ForegroundColor Gray
        exit 1
    }
    
    # Get latest DetailedReport CSV
    $latestReport = Get-ChildItem -Path $reportsPath -Filter "DetailedReport*.csv" -ErrorAction Stop | 
                    Sort-Object LastWriteTime -Descending | 
                    Select-Object -First 1
    
    if ($null -eq $latestReport) {
        Write-Host "   ❌ No DetailedReport CSV files found" -ForegroundColor Red
        Write-Host "`n   Possible causes:" -ForegroundColor Yellow
        Write-Host "   1. Scan has not completed yet (check with Monitor-ScanProgress.ps1)" -ForegroundColor Gray
        Write-Host "   2. Scan failed to generate report" -ForegroundColor Gray
        exit 1
    }
    
    Write-Host "   ✅ Latest report found" -ForegroundColor Green
    Write-Host "   Report Name: $($latestReport.Name)" -ForegroundColor Gray
    Write-Host "   Report Date: $($latestReport.LastWriteTime)" -ForegroundColor Gray
    Write-Host "   File Size: $([math]::Round($latestReport.Length/1KB, 2)) KB" -ForegroundColor Gray
    
} catch {
    Write-Host "   ❌ Failed to locate report files" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    exit 1
}

# Import and display report data
Write-Host "`n📋 Analyzing scan results..." -ForegroundColor Cyan

try {
    $reportData = Import-Csv $latestReport.FullName -ErrorAction Stop
    
    if ($reportData.Count -eq 0) {
        Write-Host "   ⚠️  Report is empty (0 rows)" -ForegroundColor Yellow
        Write-Host "`n   Possible causes:" -ForegroundColor Yellow
        Write-Host "   1. No files were scanned (check repository accessibility)" -ForegroundColor Gray
        Write-Host "   2. All repositories were skipped (verify UNC paths)" -ForegroundColor Gray
    } else {
        Write-Host "   ✅ Report loaded: $($reportData.Count) total rows" -ForegroundColor Green
        
        Write-Host "`n📊 Scan Results Summary:" -ForegroundColor Yellow
        Write-Host "================================================" -ForegroundColor Yellow
        
        # Display key findings in table format
        $reportData | 
            Select-Object Repository,
                          @{Name='File Name';Expression={$_.'File Name'}},
                          @{Name='Information Type';Expression={$_.'Information Type Name'}},
                          @{Name='Applied Label';Expression={$_.'Applied Label'}},
                          @{Name='Last Modified';Expression={$_.'Last Modified'}},
                          Status |
            Format-Table -AutoSize -Wrap
        
        # Summary statistics
        $successCount = ($reportData | Where-Object {$_.Status -eq 'Success'}).Count
        $sensitiveTypes = $reportData | Where-Object {$_.'Information Type Name'} | 
                         Select-Object -ExpandProperty 'Information Type Name' -Unique
        
        Write-Host "`n📈 Statistics:" -ForegroundColor Cyan
        Write-Host "   Total files scanned: $($reportData.Count)" -ForegroundColor Gray
        Write-Host "   Successful scans: $successCount" -ForegroundColor Gray
        
        if ($sensitiveTypes) {
            Write-Host "   Sensitive information types detected:" -ForegroundColor Gray
            $sensitiveTypes | ForEach-Object {
                Write-Host "   - $_" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   No sensitive information types detected" -ForegroundColor Gray
        }
    }
    
} catch {
    Write-Host "   ❌ Failed to import report data" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    exit 1
}

# Open report in default application
Write-Host "`n📋 Opening report in default application..." -ForegroundColor Cyan
try {
    Start-Process $latestReport.FullName
    Write-Host "   ✅ Report opened" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not open report automatically" -ForegroundColor Yellow
    Write-Host "   Manual path: $($latestReport.FullName)" -ForegroundColor Gray
}

Write-Host "`n✅ Report Analysis Complete" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

Write-Host "`n📚 Report Columns Explained:" -ForegroundColor Cyan
Write-Host "   Repository: UNC path to scanned share" -ForegroundColor Gray
Write-Host "   File Name: Full path to scanned file" -ForegroundColor Gray
Write-Host "   Information Type Name: Sensitive data detected (Credit Card, SSN, etc.)" -ForegroundColor Gray
Write-Host "   Applied Label: Classification label from policy" -ForegroundColor Gray
Write-Host "   Status: Scan operation result (Success, Failed, etc.)" -ForegroundColor Gray

Write-Host "`n⏭️  Optional: Check Activity Explorer (Step 4)" -ForegroundColor Yellow
Write-Host "   Note: Activity Explorer data has 1-2 hour delay" -ForegroundColor Gray
Write-Host "   DetailedReport.csv provides immediate results" -ForegroundColor Gray

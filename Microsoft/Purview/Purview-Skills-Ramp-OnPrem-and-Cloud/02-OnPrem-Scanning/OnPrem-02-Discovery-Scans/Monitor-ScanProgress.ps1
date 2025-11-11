<#
.SYNOPSIS
    Continuously monitors scanner status and displays progress updates.

.DESCRIPTION
    This script provides real-time monitoring of the Purview scanner status, updating every 30 seconds
    to show scan progress including start time, end time, scanned file count, and failed file count.
    
    The continuous monitoring loop helps users track long-running scans without repeatedly
    running Get-AIPScannerStatus manually.

.PARAMETER RefreshInterval
    Number of seconds between status checks. Default is 30 seconds.

.EXAMPLE
    .\Monitor-ScanProgress.ps1
    
    Monitors scan progress with 30-second refresh interval. Press Ctrl+C to exit.

.EXAMPLE
    .\Monitor-ScanProgress.ps1 -RefreshInterval 60
    
    Monitors scan progress with 60-second refresh interval.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Scanner service running
    - Discovery scan initiated (Start-Scan executed)
    
    Script development orchestrated using GitHub Copilot.

.MONITORING METRICS
    - LastScanStartTime: When current scan began
    - LastScanEndTime: When scan completed (null if still running)
    - ScannedFileCount: Number of files scanned so far
    - FailedFileCount: Files that couldn't be scanned
    - SkippedRepositories: Repositories not accessible
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [int]$RefreshInterval = 30
)

# =============================================================================
# Continuously monitor scanner status.
# =============================================================================

Write-Host "`n📊 Step 2: Monitor Scan Progress" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

Write-Host "`n📋 Starting continuous monitoring (updates every $RefreshInterval seconds)" -ForegroundColor Cyan
Write-Host "   Press Ctrl+C to exit monitoring loop" -ForegroundColor Yellow
Write-Host ""

try {
    while ($true) {
        Clear-Host
        
        Write-Host "Scanner Status Check - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
        Write-Host "============================================================" -ForegroundColor Cyan
        
        # Get scanner status
        try {
            $status = Get-AIPScannerStatus
            
            Write-Host "`n📊 Scan Information:" -ForegroundColor Yellow
            Write-Host "   Last Scan Start Time: $($status.LastScanStartTime)" -ForegroundColor Gray
            Write-Host "   Last Scan End Time: $($status.LastScanEndTime)" -ForegroundColor Gray
            
            if ($null -eq $status.LastScanEndTime) {
                Write-Host "   🔄 Scan Status: IN PROGRESS" -ForegroundColor Cyan
            } else {
                Write-Host "   ✅ Scan Status: COMPLETED" -ForegroundColor Green
            }
            
            Write-Host "`n📂 File Statistics:" -ForegroundColor Yellow
            Write-Host "   Scanned File Count: $($status.ScannedFileCount)" -ForegroundColor Gray
            Write-Host "   Failed File Count: $($status.FailedFileCount)" -ForegroundColor Gray
            
            if ($status.SkippedRepositories -and $status.SkippedRepositories.Count -gt 0) {
                Write-Host "`n⚠️  Skipped Repositories:" -ForegroundColor Yellow
                $status.SkippedRepositories | ForEach-Object {
                    Write-Host "   - $_" -ForegroundColor Red
                }
                Write-Host "`n   Troubleshooting: Check UNC paths and permissions" -ForegroundColor Gray
            } else {
                Write-Host "`n✅ No skipped repositories" -ForegroundColor Green
            }
            
            # Check if scan is complete
            if ($null -ne $status.LastScanEndTime) {
                Write-Host "`n✅ Scan completed at: $($status.LastScanEndTime)" -ForegroundColor Green
                Write-Host "`n⏭️  Continue with Step 3: Review DetailedReport.csv" -ForegroundColor Yellow
                Write-Host "   Run Get-DetailedScanReport.ps1 to analyze results" -ForegroundColor Gray
                break
            }
            
        } catch {
            Write-Host "`n❌ Failed to get scanner status" -ForegroundColor Red
            Write-Host "   Error: $_" -ForegroundColor Yellow
        }
        
        Write-Host "`n⏳ Next update in $RefreshInterval seconds..." -ForegroundColor Cyan
        Write-Host "   Press Ctrl+C to exit monitoring" -ForegroundColor Gray
        
        Start-Sleep -Seconds $RefreshInterval
    }
    
} catch {
    Write-Host "`n📋 Monitoring stopped by user" -ForegroundColor Yellow
}

Write-Host "`n✅ Monitoring Complete" -ForegroundColor Green

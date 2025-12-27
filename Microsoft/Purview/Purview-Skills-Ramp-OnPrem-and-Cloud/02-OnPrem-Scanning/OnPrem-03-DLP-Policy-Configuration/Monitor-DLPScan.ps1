<#
.SYNOPSIS
    Monitors DLP-enabled scanner progress with real-time status updates and file counts.

.DESCRIPTION
    This continuous monitoring script tracks the Microsoft Information Protection Scanner during
    DLP policy evaluation. It displays real-time progress including scan status, current repository,
    file counts, and completion estimates. The script runs in a loop until the scan completes or
    the user cancels, providing visibility into the DLP scanning process.

.PARAMETER RefreshInterval
    Time in seconds between status checks. Default is 30 seconds.

.EXAMPLE
    .\Monitor-DLPScan.ps1
    
    Monitors DLP scan with default 30-second refresh interval.

.EXAMPLE
    .\Monitor-DLPScan.ps1 -RefreshInterval 15
    
    Monitors with faster 15-second refresh rate for more frequent updates.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Information Protection Scanner with active DLP scan
    - Scan initiated with Start-DLPScanWithReset.ps1
    
    Script development orchestrated using GitHub Copilot.

.MONITORING FEATURES
    - Real-time scan status tracking
    - Current repository and file count display
    - Automatic refresh with configurable interval
    - Completion detection and summary
    - Ctrl+C to exit monitoring loop
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int]$RefreshInterval = 30
)

# =============================================================================
# Configuration: Monitor DLP Scan Progress
# =============================================================================

Write-Host "`n📊 Monitoring DLP-Enabled Scanner Progress" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   Refresh Interval: $RefreshInterval seconds" -ForegroundColor Gray
Write-Host "   Press Ctrl+C to stop monitoring" -ForegroundColor Gray

$scanStartTime = Get-Date
$iterationCount = 0
$previousScanEndTime = $null

# Get initial scan state to track changes
try {
    $initialStatus = Get-AIPScannerStatus -ErrorAction SilentlyContinue
    $previousScanEndTime = $initialStatus.LastScanEndTime
} catch {
    # Continue anyway - we'll detect scan completion in the loop
}

# Monitoring loop
try {
    while ($true) {
        $iterationCount++
        $currentTime = Get-Date
        $elapsedTime = $currentTime - $scanStartTime
        
        Clear-Host
        
        Write-Host "`n📊 DLP Scanner Status Monitor" -ForegroundColor Cyan
        Write-Host "=============================" -ForegroundColor Cyan
        Write-Host "   Refresh: #$iterationCount" -ForegroundColor Gray
        Write-Host "   Time: $($currentTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
        Write-Host "   Elapsed: $([math]::Floor($elapsedTime.TotalMinutes)) minutes, $($elapsedTime.Seconds) seconds" -ForegroundColor Gray
        
        try {
            $status = Get-AIPScannerStatus -ErrorAction Stop
            
            # Display scan status
            Write-Host "`n🔍 Current Scan Status:" -ForegroundColor Yellow
            Write-Host "   =====================" -ForegroundColor Yellow
            Write-Host "   Last Scan Start: $($status.LastScanStartTime)" -ForegroundColor Gray
            Write-Host "   Last Scan End: $($status.LastScanEndTime)" -ForegroundColor Gray
            
            # Determine if scan is running
            $scanIsRunning = ($null -eq $status.LastScanEndTime) -or 
                             ($status.LastScanStartTime -gt $status.LastScanEndTime)
            
            if ($scanIsRunning) {
                Write-Host "   Status: " -NoNewline
                Write-Host "SCANNING IN PROGRESS" -ForegroundColor Green
            } else {
                Write-Host "   Status: " -NoNewline
                Write-Host "IDLE (Scan Complete)" -ForegroundColor Cyan
            }
            
            # Display repository info
            if ($status.CurrentRepository) {
                Write-Host "`n📁 Current Repository:" -ForegroundColor Yellow
                Write-Host "   $($status.CurrentRepository)" -ForegroundColor Gray
            }
            
            # Display file counts
            Write-Host "`n📊 File Statistics:" -ForegroundColor Yellow
            Write-Host "   =================" -ForegroundColor Yellow
            Write-Host "   Files Scanned: $($status.ScannedFileCount)" -ForegroundColor Gray
            Write-Host "   Failed Files: $($status.FailedFileCount)" -ForegroundColor Gray
            
            if ($status.SkippedRepositories -and $status.SkippedRepositories.Count -gt 0) {
                Write-Host "`n⚠️  Skipped Repositories:" -ForegroundColor Yellow
                $status.SkippedRepositories | ForEach-Object {
                    Write-Host "   - $_" -ForegroundColor Red
                }
            }
            
            # Display DLP-specific info (note: empty values expected for portal-configured scanners)
            Write-Host "`n🔐 DLP Configuration:" -ForegroundColor Yellow
            Write-Host "   ==================" -ForegroundColor Yellow
            
            try {
                $onlineConfig = Get-ScannerConfiguration -ErrorAction SilentlyContinue
                if ($onlineConfig.OnlineConfiguration -eq 'On') {
                    Write-Host "   Mode: Portal-Configured (OnlineConfiguration = On)" -ForegroundColor Gray
                    Write-Host "   💡 DLP settings managed in Purview portal" -ForegroundColor Yellow
                } else {
                    $scannerConfig = Get-ScannerContentScan -ErrorAction SilentlyContinue
                    if ($scannerConfig) {
                        Write-Host "   EnableDLP: $($scannerConfig.EnableDlp)" -ForegroundColor Gray
                        Write-Host "   Enforce: $($scannerConfig.Enforce)" -ForegroundColor Gray
                    }
                }
            } catch {
                Write-Host "   (Configuration not accessible during scan)" -ForegroundColor DarkGray
            }
            
            # Check if a NEW scan has completed (compare end times)
            if (-not $scanIsRunning -and $status.LastScanEndTime -and 
                ($null -eq $previousScanEndTime -or $status.LastScanEndTime -gt $previousScanEndTime)) {
                
                Write-Host "`n✅ Scan Completed!" -ForegroundColor Green
                Write-Host "   ===============" -ForegroundColor Green
                Write-Host "   Completed at: $($status.LastScanEndTime)" -ForegroundColor Gray
                Write-Host "   Total Files Scanned: $($status.ScannedFileCount)" -ForegroundColor Gray
                
                Write-Host "`n📊 Scan Report Location:" -ForegroundColor Yellow
                $reportsPath = "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"
                Write-Host "   $reportsPath" -ForegroundColor Gray
                
                # Check for latest report
                try {
                    $latestReport = Get-ChildItem $reportsPath -Filter "DetailedReport_*.csv" -ErrorAction SilentlyContinue | 
                                    Sort-Object LastWriteTime -Descending | 
                                    Select-Object -First 1
                    
                    if ($latestReport) {
                        Write-Host "`n   Latest Report:" -ForegroundColor Cyan
                        Write-Host "      $($latestReport.Name)" -ForegroundColor Gray
                        Write-Host "      Created: $($latestReport.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
                    }
                } catch {
                    # Ignore report check errors
                }
                
                Write-Host "`n⏭️  Next Steps:" -ForegroundColor Yellow
                Write-Host "   1. Run Get-DLPScanReport.ps1 to analyze DLP detection results" -ForegroundColor Gray
                Write-Host "   2. Review DLP policy matches in DetailedReport.csv" -ForegroundColor Gray
                Write-Host "   3. Proceed to OnPrem-04 for DLP activity monitoring" -ForegroundColor Gray
                
                Write-Host "`n✅ Monitoring Complete" -ForegroundColor Green
                break
            }
            
            # If scan is not running and we're on first iteration, no active scan to monitor
            if (-not $scanIsRunning -and $iterationCount -eq 1) {
                Write-Host "`n💡 No active scan detected." -ForegroundColor Yellow
                Write-Host "   Last scan completed at: $($status.LastScanEndTime)" -ForegroundColor Gray
                Write-Host "`n   To start a new scan, run: Start-DLPScanWithReset.ps1" -ForegroundColor Gray
                Write-Host "`n✅ Monitoring Complete" -ForegroundColor Green
                break
            }
            
            # Only show refresh message if scan is still running
            if ($scanIsRunning) {
                Write-Host "`n⏱️  Next refresh in $RefreshInterval seconds..." -ForegroundColor Gray
                Write-Host "   (Press Ctrl+C to exit monitoring)" -ForegroundColor DarkGray
            }
            
        } catch {
            Write-Host "`n❌ Failed to retrieve scanner status: $_" -ForegroundColor Red
            Write-Host "   Scanner service may not be running" -ForegroundColor Gray
            Write-Host "   Check service status: Get-Service MIPScanner" -ForegroundColor Gray
        }
        
        # Wait before next check (only if scan is running)
        if ($scanIsRunning) {
            Start-Sleep -Seconds $RefreshInterval
        }
    }
} finally {
    # Only show this if interrupted (Ctrl+C), not on normal exit
}

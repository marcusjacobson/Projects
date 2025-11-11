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

# Monitoring loop
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
        
        $statusColor = if ($status.ScanStatus -eq 'Running') { 'Green' } 
                      elseif ($status.ScanStatus -eq 'Idle') { 'Cyan' } 
                      else { 'Yellow' }
        
        Write-Host "   Status: " -NoNewline
        Write-Host $status.ScanStatus -ForegroundColor $statusColor
        
        # Display repository info
        if ($status.CurrentRepository) {
            Write-Host "`n📁 Current Repository:" -ForegroundColor Yellow
            Write-Host "   $($status.CurrentRepository)" -ForegroundColor Gray
        }
        
        # Display file counts
        Write-Host "`n📊 File Statistics:" -ForegroundColor Yellow
        Write-Host "   =================" -ForegroundColor Yellow
        
        if ($null -ne $status.ScannedFiles) {
            Write-Host "   Files Scanned: $($status.ScannedFiles)" -ForegroundColor Gray
        }
        
        if ($null -ne $status.FailedFiles -and $status.FailedFiles -gt 0) {
            Write-Host "   Failed Files: $($status.FailedFiles)" -ForegroundColor Yellow
        }
        
        if ($null -ne $status.SkippedFiles -and $status.SkippedFiles -gt 0) {
            Write-Host "   Skipped Files: $($status.SkippedFiles)" -ForegroundColor Gray
        }
        
        # Display DLP-specific info
        Write-Host "`n🔐 DLP Configuration:" -ForegroundColor Yellow
        Write-Host "   ==================" -ForegroundColor Yellow
        
        try {
            $scannerConfig = Get-ScannerContentScan -ErrorAction SilentlyContinue
            if ($scannerConfig) {
                Write-Host "   EnableDLP: $($scannerConfig.EnableDlp)" -ForegroundColor Gray
                Write-Host "   Enforce: $($scannerConfig.Enforce)" -ForegroundColor Gray
                Write-Host "   RepositoryOwner: $($scannerConfig.RepositoryOwner)" -ForegroundColor Gray
            }
        } catch {
            Write-Host "   (Configuration not accessible during scan)" -ForegroundColor DarkGray
        }
        
        # Check if scan completed
        if ($status.ScanStatus -eq 'Idle') {
            Write-Host "`n✅ Scan Completed!" -ForegroundColor Green
            Write-Host "   ===============" -ForegroundColor Green
            Write-Host ""
            Write-Host "   Total Time: $([math]::Floor($elapsedTime.TotalMinutes)) minutes" -ForegroundColor Gray
            
            if ($null -ne $status.ScannedFiles) {
                Write-Host "   Total Files Scanned: $($status.ScannedFiles)" -ForegroundColor Gray
                
                if ($elapsedTime.TotalSeconds -gt 0) {
                    $filesPerMinute = [math]::Round($status.ScannedFiles / $elapsedTime.TotalMinutes, 2)
                    Write-Host "   Average Rate: $filesPerMinute files/minute" -ForegroundColor Gray
                }
            }
            
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
                    Write-Host "      Size: $([math]::Round($latestReport.Length / 1KB, 2)) KB" -ForegroundColor Gray
                }
            } catch {
                Write-Host "   (Could not check for report file)" -ForegroundColor DarkGray
            }
            
            Write-Host "`n⏭️  Next Steps:" -ForegroundColor Yellow
            Write-Host "   1. Run Get-DLPScanReport.ps1 to analyze DLP detection results" -ForegroundColor Gray
            Write-Host "   2. Review DLP policy matches in DetailedReport.csv" -ForegroundColor Gray
            Write-Host "   3. Check for sensitive information type detections" -ForegroundColor Gray
            Write-Host "   4. Proceed to OnPrem-04 for DLP enforcement validation" -ForegroundColor Gray
            
            break
        }
        
        # If scan is running, show refresh countdown
        if ($status.ScanStatus -eq 'Running') {
            Write-Host "`n⏱️  Next refresh in $RefreshInterval seconds..." -ForegroundColor Gray
            Write-Host "   (Press Ctrl+C to exit monitoring)" -ForegroundColor DarkGray
        }
        
    } catch {
        Write-Host "`n❌ Failed to retrieve scanner status: $_" -ForegroundColor Red
        Write-Host "   Scanner service may not be running" -ForegroundColor Gray
        Write-Host "   Check service status: Get-Service MIPScanner" -ForegroundColor Gray
        break
    }
    
    # Wait before next check
    Start-Sleep -Seconds $RefreshInterval
}

Write-Host "`n✅ Monitoring Complete" -ForegroundColor Green

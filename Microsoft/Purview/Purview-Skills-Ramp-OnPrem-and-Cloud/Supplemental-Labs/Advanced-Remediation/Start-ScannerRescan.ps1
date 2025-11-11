# Restart scanner service
Restart-Service -Name 'MIPScanner'
Start-Sleep -Seconds 60

# Force FULL RESCAN to detect new test files
Start-Scan -Reset

# Monitor progress (Ctrl+C to exit when complete)
while ($true) {
    Clear-Host
    Write-Host "Scanner Status Check - $(Get-Date)" -ForegroundColor Cyan
    Get-AIPScannerStatus
    Start-Sleep -Seconds 30
}

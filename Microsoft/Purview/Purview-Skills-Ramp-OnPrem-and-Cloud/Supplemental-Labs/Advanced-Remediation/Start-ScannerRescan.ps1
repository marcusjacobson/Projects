<#
.SYNOPSIS
    Initiates a full rescan of the Purview Information Protection scanner.

.DESCRIPTION
    This script restarts the MIP Scanner service and triggers a full rescan to ensure
    the latest file changes and test data are detected. It monitors the scanner status
    and provides real-time feedback on the scan progress.
    
    This is a critical step in the remediation workflow to update the scanner's knowledge
    base before analysis and remediation actions.

.PARAMETER None
    This script does not accept parameters.

.EXAMPLE
    .\Start-ScannerRescan.ps1
    
    Restarts the scanner service and begins a full scan.

.NOTES
    File Name      : Start-ScannerRescan.ps1
    Author         : Marcus Jacobson
    Prerequisite   : PowerShell 5.1 or later, AIPScanner module
    Version        : 1.0
    Last Updated   : July 17, 2025
    
    Script development orchestrated using GitHub Copilot.

.SCANNER OPERATIONS
    - Service Restart (MIPScanner)
    - Full Rescan Trigger
    - Status Monitoring
    - Real-time Progress Display
#>
#
# =============================================================================
# Action: Start Scanner Rescan
# =============================================================================

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

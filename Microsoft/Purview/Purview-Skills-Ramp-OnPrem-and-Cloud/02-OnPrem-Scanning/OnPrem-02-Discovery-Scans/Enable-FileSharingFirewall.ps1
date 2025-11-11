<#
.SYNOPSIS
    Enables File and Printer Sharing through Windows Firewall.

.DESCRIPTION
    This script enables the Windows Firewall rules required for File and Printer Sharing,
    allowing the Purview scanner to access SMB file shares on the local machine.
    
    This is typically needed when Test-RepositoryAccess.ps1 shows paths are not accessible.

.EXAMPLE
    .\Enable-FileSharingFirewall.ps1
    
    Enables File and Printer Sharing firewall rules.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Local administrator permissions
    - Windows Firewall service running
    
    Script development orchestrated using GitHub Copilot.

.FIREWALL RULES
    - Enables all "File and Printer Sharing" firewall rules
    - Allows SMB traffic (TCP 445, UDP 137-138, etc.)
    - Required for \\localhost\ and \\COMPUTERNAME\ path access
#>

[CmdletBinding()]
param()

# =============================================================================
# Enable File and Printer Sharing firewall rules.
# =============================================================================

Write-Host "`n🔥 Enabling File and Printer Sharing Firewall Rules" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

try {
    Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing" -ErrorAction Stop
    Write-Host "   ✅ File and Printer Sharing enabled in firewall" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to enable firewall rules" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n⏭️  Re-run Test-RepositoryAccess.ps1 to verify path accessibility" -ForegroundColor Yellow

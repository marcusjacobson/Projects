<#
.SYNOPSIS
    Verifies Azure CLI installation and displays version information.

.DESCRIPTION
    This script checks if Azure CLI (az command) is properly installed and accessible
    from the current PowerShell session. Azure CLI is required for authenticating to
    Azure services and managing Azure resources from the command line.
    
    If Azure CLI is not found, the script provides installation instructions.

.EXAMPLE
    .\Verify-AzureCLI.ps1
    
    Checks Azure CLI installation and displays version information.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Azure CLI 2.0+ installed
    - PowerShell environment PATH updated with Azure CLI location
    
    Installation:
    - Download from: https://aka.ms/installazurecliwindowsx64
    - After installation, close and reopen PowerShell windows
    - Run this script to verify installation
    
    Important Notes:
    - After Azure CLI installation, existing PowerShell sessions must be closed
    - Open new PowerShell window (as Administrator) for PATH to update
    - Azure CLI adds `az` command to system PATH during installation
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Verify Azure CLI installation and version
# =============================================================================

# =============================================================================
# Step 1: Check Azure CLI Command Availability
# =============================================================================

Write-Host "🔍 Step 1: Checking Azure CLI Installation" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

try {
    $azVersion = az --version 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Azure CLI is installed and accessible" -ForegroundColor Green
        
        # Display version information
        Write-Host "`n📊 Azure CLI Version Information:" -ForegroundColor Cyan
        Write-Host $azVersion
        
    } else {
        throw "Azure CLI command failed with exit code: $LASTEXITCODE"
    }
    
} catch {
    Write-Host "   ❌ Azure CLI not found or not accessible" -ForegroundColor Red
    Write-Host "`n📝 Installation Instructions:" -ForegroundColor Yellow
    Write-Host "   1. Download Azure CLI from: https://aka.ms/installazurecliwindowsx64" -ForegroundColor Gray
    Write-Host "   2. Run the MSI installer" -ForegroundColor Gray
    Write-Host "   3. Close this PowerShell window" -ForegroundColor Gray
    Write-Host "   4. Open new PowerShell window as Administrator" -ForegroundColor Gray
    Write-Host "   5. Run this script again to verify" -ForegroundColor Gray
    exit 1
}

# =============================================================================
# Step 2: Reminder About PowerShell Restart
# =============================================================================

Write-Host "`n💡 Important Note:" -ForegroundColor Cyan
Write-Host "   If you just installed Azure CLI, you MUST:" -ForegroundColor Yellow
Write-Host "   - Close all PowerShell windows" -ForegroundColor Yellow
Write-Host "   - Open new PowerShell as Administrator" -ForegroundColor Yellow
Write-Host "   - This ensures PATH environment variable is updated" -ForegroundColor Yellow

Write-Host "`n✅ Azure CLI verification complete" -ForegroundColor Green

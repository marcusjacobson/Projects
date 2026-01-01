<#
.SYNOPSIS
    Connects to Security & Compliance PowerShell using interactive user authentication.

.DESCRIPTION
    This script establishes a session with Security & Compliance PowerShell (IPPS) using 
    interactive user authentication. Includes MSAL assembly detection and WAM broker 
    disable logic to prevent authentication errors.

.EXAMPLE
    . .\Connect-PurviewIPPS.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 3.0.0
    Created: 2025-12-30
    Last Modified: 2025-12-31
    
    Requirements:
    - ExchangeOnlineManagement module
    - Global Administrator or Compliance Administrator role

    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param()

# =============================================================================
# Connect to Security & Compliance PowerShell
# =============================================================================

# Check if already connected
if (Get-Command Get-DlpEdmSchema -ErrorAction SilentlyContinue) {
    Write-Host "✅ Already connected to Security & Compliance PowerShell" -ForegroundColor Green
    return $true
}

Write-Host "📋 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan

# Check if MSAL assemblies are already loaded (indicates we can't disable WAM anymore)
$msalLoaded = [System.AppDomain]::CurrentDomain.GetAssemblies() | 
    Where-Object { $_.FullName -like "*Microsoft.Identity.Client*" } | 
    Select-Object -First 1

if ($msalLoaded) {
    Write-Host "   ⚠️  MSAL assemblies already loaded in this session (WAM broker may be active)" -ForegroundColor Yellow
    Write-Host "   Attempting connection anyway..." -ForegroundColor Gray
}

try {
    # CRITICAL: Disable WAM broker BEFORE loading module (only works if MSAL not already loaded)
    if (-not $msalLoaded) {
        Write-Host "   🔧 Disabling WAM broker authentication..." -ForegroundColor Gray
        Remove-Module ExchangeOnlineManagement -Force -ErrorAction SilentlyContinue
        
        $env:AZURE_IDENTITY_DISABLE_MSALRUNTIME = "1"
        $env:MSAL_DISABLE_WAM = "1"
        [System.Environment]::SetEnvironmentVariable("AZURE_IDENTITY_DISABLE_MSALRUNTIME", "1", [System.EnvironmentVariableTarget]::Process)
        
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
    } else {
        # MSAL already loaded, just ensure module is imported
        if (-not (Get-Module ExchangeOnlineManagement)) {
            Import-Module ExchangeOnlineManagement -ErrorAction Stop
        }
    }
    
    # Connect using browser authentication
    Write-Host "   🌐 Connecting (browser sign-in window will appear)..." -ForegroundColor Gray
    Connect-IPPSSession -ShowBanner:$false -ErrorAction Stop
    
    Write-Host "✅ Successfully connected to Security & Compliance PowerShell" -ForegroundColor Green
    return $true
} catch {
    # Check for specific MSAL runtime error
    if ($_.Exception.Message -match "msalruntime|Unable to load DLL") {
        Write-Warning "MSAL runtime DLL error detected."
        Write-Host "`n📖 This is a known issue with ExchangeOnlineManagement module:" -ForegroundColor Yellow
        Write-Host "   The msalruntime.dll dependency is missing or incompatible.`n" -ForegroundColor Gray
        
        Write-Host "🔧 Recommended Solutions:" -ForegroundColor Cyan
        Write-Host "   1. Close ALL PowerShell windows" -ForegroundColor White
        Write-Host "   2. Open new PowerShell 7 as Administrator" -ForegroundColor White
        Write-Host "   3. Run the script again in the fresh session`n" -ForegroundColor White
        
        Write-Host "   Alternative: Update ExchangeOnlineManagement module:" -ForegroundColor Cyan
        Write-Host "      Update-Module ExchangeOnlineManagement -Force`n" -ForegroundColor Gray
        
        Write-Host "   See Microsoft's troubleshooting guide:" -ForegroundColor Cyan
        Write-Host "      https://aka.ms/msal-net-wam#troubleshooting`n" -ForegroundColor Gray
    } else {
        Write-Warning "Connection failed: $_"
    }
    return $false
}

<#
.SYNOPSIS
    Tests DLP Policies using the Test-DlpPolicies cmdlet.

.DESCRIPTION
    This script connects to Security & Compliance PowerShell and runs a test against
    a provided text string to see which DLP rules match.
    
    Note: Requires ExchangeOnlineManagement module (Connect-IPPSSession).

.PARAMETER TextToTest
    The string to test (e.g., a credit card number).

.EXAMPLE
    .\Test-DlpRules.ps1 -TextToTest "4111 1111 1111 1111"

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2024-05-22
    
    Requirements:
    - ExchangeOnlineManagement module
    - Permissions to run Test-DlpPolicies

    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TextToTest
)

Write-Host "🔌 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan

# Check if already connected
try {
    Get-DlpCompliancePolicy -ErrorAction Stop | Out-Null
    Write-Host "   ✅ Already connected." -ForegroundColor Green
} catch {
    try {
        Connect-IPPSSession -ShowBanner:$false
        Write-Host "   ✅ Connected." -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Failed to connect: $_" -ForegroundColor Red
        exit 1
    }
}

Write-Host "🧪 Testing Text: '$TextToTest'" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

try {
    # Note: Test-DlpPolicies is the cmdlet, but parameters vary by version.
    # Often used: Test-DlpPolicies -TestText ...
    
    $result = Test-DlpPolicies -TestText $TextToTest
    
    if ($result) {
        $result | Format-List
    } else {
        Write-Host "   ⚠️ No matches found." -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Error running test: $_" -ForegroundColor Red
}

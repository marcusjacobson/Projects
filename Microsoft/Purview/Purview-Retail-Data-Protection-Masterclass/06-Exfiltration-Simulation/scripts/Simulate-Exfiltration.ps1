<#
.SYNOPSIS
    Generates a "Honey File" and attempts exfiltration actions to trigger DLP.

.DESCRIPTION
    This script creates a file containing fake credit card numbers ("Honey File").
    It then provides instructions (or attempts automation where possible) to:
    1. Copy to USB (Simulated by copying to a specific drive letter if provided).
    2. Open in Browser (Simulated by launching Edge).
    
    Note: True exfiltration (USB/Cloud) often requires manual user interaction to bypass OS protections or physical media.

.PARAMETER Action
    "Generate" or "Clean".

.PARAMETER UsbDriveLetter
    Optional drive letter (e.g., "E:") to attempt a copy to.

.EXAMPLE
    .\Simulate-Exfiltration.ps1 -Action Generate

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2024-05-22
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Generate", "Clean")]
    [string]$Action,

    [string]$UsbDriveLetter
)

$fileName = "HoneyFile_CC.docx"
$filePath = Join-Path $PSScriptRoot $fileName

if ($Action -eq "Generate") {
    Write-Host "🚀 Generating Honey File..." -ForegroundColor Cyan
    
    # Create a simple text file (DOCX requires Word interop or complex XML, using .txt or .rtf is easier for script, but .docx triggers DLP better)
    # We'll create a .txt file and rename it or just use .txt as DLP scans content.
    # For high fidelity, we'll use a simple text file with CC numbers.
    
    $ccData = @"
CONFIDENTIAL - INTERNAL USE ONLY
Customer Credit Card List

1. 4111 1111 1111 1111 (Visa)
2. 5555 5555 5555 5555 (Mastercard)
3. 3782 822463 10005 (Amex)

DO NOT SHARE EXTERNALLY.
"@
    
    $ccData | Out-File -FilePath "$PSScriptRoot\HoneyFile_CC.txt" -Encoding UTF8
    Write-Host "   ✅ Created '$PSScriptRoot\HoneyFile_CC.txt'" -ForegroundColor Green
    
    Write-Host "📋 Exfiltration Instructions:" -ForegroundColor Cyan
    Write-Host "   1. Try to copy this file to a USB drive." -ForegroundColor White
    Write-Host "   2. Try to attach this file to a personal email (Gmail/Outlook.com)." -ForegroundColor White
    Write-Host "   3. Try to upload this file to Dropbox/Google Drive." -ForegroundColor White
    
    if ($UsbDriveLetter) {
        if (Test-Path $UsbDriveLetter) {
            Write-Host "   ⚡ Attempting copy to USB ($UsbDriveLetter)..." -ForegroundColor Yellow
            Copy-Item "$PSScriptRoot\HoneyFile_CC.txt" -Destination $UsbDriveLetter -Force
            Write-Host "   ℹ️ Check if the copy succeeded or was blocked." -ForegroundColor Cyan
        } else {
            Write-Host "   ⚠️ USB Drive $UsbDriveLetter not found." -ForegroundColor Yellow
        }
    }

} elseif ($Action -eq "Clean") {
    if (Test-Path "$PSScriptRoot\HoneyFile_CC.txt") {
        Remove-Item "$PSScriptRoot\HoneyFile_CC.txt" -Force
        Write-Host "   ✅ Cleaned up honey file." -ForegroundColor Green
    }
}

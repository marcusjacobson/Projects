<#
.SYNOPSIS
    Generates a "Honey File" containing sensitive data to test DLP policies.

.DESCRIPTION
    This script creates a file containing fake credit card numbers ("Honey File").
    You can then test M365 DLP policies by attempting to:
    1. Email the file to external recipients (Exchange DLP).
    2. Share the file externally via OneDrive or SharePoint.
    3. Paste content into Teams chats with external users.
    4. Upload the file to personal cloud storage via browser.
    
    All exfiltration attempts should be blocked or logged by DLP policies.

.PARAMETER Action
    "Generate" or "Clean".

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
    [string]$Action
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
    
    Write-Host "📋 M365 DLP Testing Scenarios:" -ForegroundColor Cyan
    Write-Host "   1. 📧 Email Test: Attach this file to an email sent to an external recipient." -ForegroundColor White
    Write-Host "   2. ☁️ Sharing Test: Share this file externally via OneDrive or SharePoint." -ForegroundColor White
    Write-Host "   3. 💬 Teams Test: Paste file content into a Teams chat with external user." -ForegroundColor White
    Write-Host "   4. 🌐 Browser Test: Upload this file to Dropbox/Google Drive via browser." -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "   ✅ All scenarios should trigger DLP policies and be logged in Activity Explorer." -ForegroundColor Green

} elseif ($Action -eq "Clean") {
    if (Test-Path "$PSScriptRoot\HoneyFile_CC.txt") {
        Remove-Item "$PSScriptRoot\HoneyFile_CC.txt" -Force
        Write-Host "   ✅ Cleaned up honey file." -ForegroundColor Green
    }
}

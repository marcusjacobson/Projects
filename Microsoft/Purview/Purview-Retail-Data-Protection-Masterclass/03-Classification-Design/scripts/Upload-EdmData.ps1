<#
.SYNOPSIS
    Guide and wrapper for uploading EDM Data using the EDM Upload Agent.

.DESCRIPTION
    Exact Data Match (EDM) data upload typically requires the "EDM Upload Agent" tool installed locally
    to hash the data before sending it to Microsoft. This script checks for the agent and provides
    the command to run.

    Prerequisites:
    1. EDM Upload Agent installed.
    2. 'RetailCustomerDB.xml' schema uploaded to Purview.
    3. Data file (CSV) generated.

.PARAMETER DataFilePath
    Path to the CSV data file (e.g., ..\..\02-Data-Foundation\Output\CustomerDB.csv).

.PARAMETER SchemaName
    Name of the schema (Default: RetailCustomerDB).

.EXAMPLE
    .\Upload-EdmData.ps1 -DataFilePath "C:\Temp\CustomerDB.csv"

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2024-05-22
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$DataFilePath,

    [string]$SchemaName = "RetailCustomerDB"
)

Write-Host "🛡️ EDM Data Upload Helper" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

# Check for EDM Upload Agent
$agentPath = "C:\Program Files\Microsoft\EdmUploadAgent\EdmUploadAgent.exe"

if (Test-Path $agentPath) {
    Write-Host "✅ EDM Upload Agent found." -ForegroundColor Green
    
    Write-Host "📋 Command to execute:" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------" -ForegroundColor Gray
    Write-Host "& '$agentPath' /UploadData /DataStoreName $SchemaName /DataFile `"$DataFilePath`" /HashLocation `"C:\Temp\EdmHash`" /Schema `"$PSScriptRoot\RetailCustomerDB.xml`"" -ForegroundColor White
    Write-Host "--------------------------------------------------" -ForegroundColor Gray
    
    Write-Host "⚠️ Note: You must be signed in to the Agent first using: & '$agentPath' /Authorize" -ForegroundColor Yellow
} else {
    Write-Host "❌ EDM Upload Agent NOT found at default location." -ForegroundColor Red
    Write-Host "   Please install it from: https://go.microsoft.com/fwlink/?linkid=2088739" -ForegroundColor Cyan
    Write-Host "   Once installed, run this script again or execute the upload command manually." -ForegroundColor Cyan
}

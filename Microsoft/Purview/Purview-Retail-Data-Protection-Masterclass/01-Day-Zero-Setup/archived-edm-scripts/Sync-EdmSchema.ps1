<#
.SYNOPSIS
    Step 2: Manages the EDM Schema (Sync or Create).
    - Checks if 'RetailCustomerDB' exists in Purview.
    - If YES: Downloads it (Sync) to ensure local XML matches cloud definition.
    - If NO: Generates a new default XML file locally for you to upload.

.DESCRIPTION
    This script resolves the common "Schema does not match definition" error by ensuring
    you are working with the authoritative version of the schema.
    
    REQUIRES:
    - Run as Administrator
    - Interactive User Sign-in (for EDM Agent)

.NOTES
    Author: Marcus Jacobson
    Version: 2.0.0
    Created: 2025-12-28
#>

# 1. Check Admin Privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Error: Administrator privileges required." -ForegroundColor Red
    exit
}

$agentPath = "C:\Program Files\Microsoft\EdmUploadAgent\EdmUploadAgent.exe"
$outputDir = Join-Path $PSScriptRoot "..\Output"
$dataStoreName = "RetailCustomerDB"
$xmlPath = Join-Path $outputDir "$dataStoreName.xml"

# Ensure output directory exists
if (-not (Test-Path $outputDir)) { New-Item -Path $outputDir -ItemType Directory -Force | Out-Null }

Write-Host "☁️ Step 2: EDM Schema Management" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# 2. Connect to Security & Compliance PowerShell
Write-Host "🔐 Connecting to Security & Compliance PowerShell..." -ForegroundColor Yellow

# Check if already connected
try {
    Get-DlpEdmSchema -ErrorAction Stop | Out-Null
    Write-Host "   ✅ Already connected to Security & Compliance PowerShell" -ForegroundColor Green
} catch {
    # Use helper script for connection - script is in project root scripts folder
    $projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $helperScriptPath = Join-Path $projectRoot "scripts\Connect-PurviewIPPS.ps1"
    if (Test-Path $helperScriptPath) {
        . $helperScriptPath
        Write-Host "   ✅ Connected to Security & Compliance PowerShell" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Helper script not found at: $helperScriptPath" -ForegroundColor Red
        exit 1
    }
}

# 3. Check if Schema Exists
Write-Host "`n🔍 Checking for existing schema '$dataStoreName' in cloud..." -ForegroundColor Yellow
$existingSchema = Get-DlpEdmSchema | Where-Object { $_.DataStoreName -eq $dataStoreName }

if ($existingSchema) {
    Write-Host "✅ Schema '$dataStoreName' found in cloud!" -ForegroundColor Green
    
    # Authenticate Agent for Download
    Write-Host "🔐 Authenticating EDM Agent for sync..." -ForegroundColor Yellow
    Push-Location "C:\Program Files\Microsoft\EdmUploadAgent"
    & .\EdmUploadAgent.exe /Authorize
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "⬇️  Downloading schema to ensure local sync..." -ForegroundColor Cyan
        & .\EdmUploadAgent.exe /SaveSchema /DataStoreName $dataStoreName /OutputDir $outputDir
        Write-Host "✅ Local file updated: $xmlPath" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Agent authentication failed. Skipping download." -ForegroundColor Yellow
    }
    Pop-Location
}
else {
    Write-Host "⚠️  Schema '$dataStoreName' not found in cloud." -ForegroundColor Yellow
    Write-Host "⚙️  Generating new default schema locally..." -ForegroundColor Cyan
    
    # EDM Schema: 7 fields (no MembershipType)
    # MembershipType is only in Custom SIT test data (CustomerDB_TestData.csv for Lab 01)
    # Note: maximumNumberOfTokens is required by Upload Agent but rejected by New-DlpEdmSchema
    # We include it in the XML for Upload Agent, but remove it temporarily for PowerShell upload
    $xmlContent = @"
<?xml version="1.0" encoding="utf-8"?>
<EdmSchema xmlns="http://schemas.microsoft.com/office/2018/edm">
  <DataStore name="RetailCustomerDB" description="Customer Database for Retail Operations" version="1" maximumNumberOfTokens="5">
    <Field name="CustomerId" searchable="true" caseInsensitive="true" />
    <Field name="FirstName" searchable="false" caseInsensitive="true" />
    <Field name="LastName" searchable="false" caseInsensitive="true" />
    <Field name="Email" searchable="true" caseInsensitive="true" />
    <Field name="PhoneNumber" searchable="true" caseInsensitive="true" />
    <Field name="CreditCardNumber" searchable="false" caseInsensitive="false" />
    <Field name="LoyaltyId" searchable="true" caseInsensitive="true" />
  </DataStore>
</EdmSchema>
"@
    # Save the full XML (with maximumNumberOfTokens for Upload Agent)
    $xmlContent | Out-File -FilePath $xmlPath -Encoding UTF8
    $resolvedXmlPath = (Resolve-Path $xmlPath).Path
    Write-Host "✅ New schema generated at: $resolvedXmlPath" -ForegroundColor Green
    Write-Host "   📋 7 fields (EDM format): CustomerId, FirstName, LastName, Email, PhoneNumber, CreditCardNumber, LoyaltyId" -ForegroundColor Cyan
    
    # Automated Upload Logic (as per original README)
    # PowerShell cmdlet doesn't support maximumNumberOfTokens, so we remove it temporarily for upload
    Write-Host "🚀 Attempting automated schema upload to Purview..." -ForegroundColor Cyan

    try {
        Write-Host "📤 Uploading schema definition..." -ForegroundColor Cyan
        
        # Strip out maximumNumberOfTokens for PowerShell cmdlet upload
        $xmlForUpload = $xmlContent -replace 'maximumNumberOfTokens="5"', ''
        $tempXmlPath = Join-Path $outputDir "temp_schema.xml"
        $xmlForUpload | Out-File -FilePath $tempXmlPath -Encoding UTF8
        $fileData = [System.IO.File]::ReadAllBytes($tempXmlPath)
        
        # Create the schema
        New-DlpEdmSchema -FileData $fileData -ErrorAction Stop
        
        # Clean up temp file
        Remove-Item $tempXmlPath -Force
        
        Write-Host "✅ Schema '$dataStoreName' successfully created in Purview!" -ForegroundColor Green
        Write-Host "   💡 Local XML includes maximumNumberOfTokens for Upload Agent compatibility" -ForegroundColor Cyan
    }
    catch {
        Write-Host "❌ Automated upload failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "👉 Fallback: Please upload the XML file manually to the Purview Portal." -ForegroundColor Yellow
        Write-Host "   (Purview Portal > Information Protection > Classifiers > EDM classifiers)" -ForegroundColor Cyan
        exit 1
    }
}

Write-Host "`n✅ Step 2 Complete." -ForegroundColor Green
exit 0

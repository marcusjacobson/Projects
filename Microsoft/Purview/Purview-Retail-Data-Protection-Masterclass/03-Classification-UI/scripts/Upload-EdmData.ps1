<#
.SYNOPSIS
    Uploads EDM data for the EDM classifier created in Lab 02.

.DESCRIPTION
    This script uploads customer data from CustomerDB_EDM.csv to the EDM schema
    created by the Purview portal wizard. It hashes the data locally and uploads
    only the hashes to Microsoft Purview for exact data matching.
    
    The script reads the EDM schema name from global-config.json.

.PARAMETER DataFile
    Path to the CustomerDB_EDM.csv file. Defaults to 02-Data-Foundation/Output/CustomerDB_EDM.csv.

.EXAMPLE
    .\Upload-EdmData.ps1
    
    Upload EDM data using schema name from global-config.json.

.EXAMPLE
    .\Upload-EdmData.ps1 -DataFile "C:\Custom\Path\CustomerDB_EDM.csv"
    
    Upload EDM data using a custom file path.

.NOTES
    Author: Marcus Jacobson
    Version: 2.0.0
    Created: 2025-12-31
    Last Modified: 2025-12-31
    
    REQUIREMENTS:
    - Run as Administrator
    - EDM Upload Agent installed
    - User added to EDM_DataUploaders security group
    - Interactive user sign-in (Service Principal not supported)
    - edmSchema.schemaName configured in templates/global-config.json
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$DataFile
)

# =============================================================================
# Action 1: Load Configuration
# =============================================================================

Write-Host "📄 Loading configuration..." -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green

$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$configPath = Join-Path $projectRoot "templates\global-config.json"

if (-not (Test-Path $configPath)) {
    Write-Host "   ❌ Configuration file not found at: $configPath" -ForegroundColor Red
    exit 1
}

try {
    $config = Get-Content $configPath | ConvertFrom-Json
    $SchemaName = $config.edmSchema.schemaName
    
    if (-not $SchemaName) {
        Write-Host "   ❌ EDM schema name not configured in global-config.json" -ForegroundColor Red
        Write-Host "   💡 Add the schema name to templates/global-config.json under edmSchema.schemaName" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "   ✅ Configuration loaded" -ForegroundColor Green
    Write-Host "   📋 EDM Schema Name: $SchemaName" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Failed to load configuration: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Action 2: Validate Prerequisites
# =============================================================================

Write-Host "`n🔍 Validating prerequisites..." -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

# Check Admin Privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "   ❌ Administrator privileges required. Please run PowerShell as Administrator." -ForegroundColor Red
    exit 1
}
Write-Host "   ✅ Administrator privileges confirmed" -ForegroundColor Green

# Validate EDM Upload Agent
$agentPath = "C:\Program Files\Microsoft\EdmUploadAgent\EdmUploadAgent.exe"
if (-not (Test-Path $agentPath)) {
    Write-Host "   ❌ EDM Upload Agent not found at: $agentPath" -ForegroundColor Red
    Write-Host "   💡 Download from: https://go.microsoft.com/fwlink/?linkid=2088639" -ForegroundColor Yellow
    exit 1
}
Write-Host "   ✅ EDM Upload Agent found" -ForegroundColor Green

# =============================================================================
# Action 3: Authenticate with EDM Upload Agent
# =============================================================================

Write-Host "`n🔐 Authenticating with EDM Upload Agent..." -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

Push-Location "C:\Program Files\Microsoft\EdmUploadAgent"

try {
    Write-Host "   🔑 Interactive authentication required" -ForegroundColor Cyan
    Write-Host "   A browser window will open for sign-in...`n" -ForegroundColor Gray
    
    & .\EdmUploadAgent.exe /Authorize
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n   ✅ Authentication successful" -ForegroundColor Green
    } else {
        throw "Authentication failed with exit code: $LASTEXITCODE"
    }
} catch {
    Write-Host "   ❌ Authentication failed: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

# =============================================================================
# Action 4: Locate Data File
# =============================================================================

Write-Host "`n📁 Locating EDM data file..." -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

if (-not $DataFile) {
    # Default path: 02-Data-Foundation/Output/CustomerDB_EDM.csv
    $projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $DataFile = Join-Path $projectRoot "02-Data-Foundation\Output\CustomerDB_EDM.csv"
}

if (-not (Test-Path $DataFile)) {
    Write-Host "   ❌ EDM data file not found at: $DataFile" -ForegroundColor Red
    Write-Host "   💡 Generate the file using: 02-Data-Foundation\scripts\Generate-CustomSitTestData.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "   ✅ Data file located: $(Split-Path $DataFile -Leaf)" -ForegroundColor Green

# Validate CSV structure (should have 7 columns)
$csvHeaders = (Get-Content $DataFile -First 1) -split ','
if ($csvHeaders.Count -ne 7) {
    Write-Host "   ⚠️  Expected 7 columns in CSV, found $($csvHeaders.Count)" -ForegroundColor Yellow
    Write-Host "   Expected: CustomerId,FirstName,LastName,Email,PhoneNumber,CreditCardNumber,LoyaltyId" -ForegroundColor Cyan
    Write-Host "   Found: $($csvHeaders -join ',')" -ForegroundColor Gray
}

# =============================================================================
# Action 5: Download EDM Schema from Cloud
# =============================================================================

Write-Host "`n📥 Downloading EDM schema..." -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

$schemaDir = Join-Path $PSScriptRoot "..\Output\EDMSchemas"
if (-not (Test-Path $schemaDir)) {
    New-Item -Path $schemaDir -ItemType Directory -Force | Out-Null
}

Push-Location "C:\Program Files\Microsoft\EdmUploadAgent"

try {
    & .\EdmUploadAgent.exe /SaveSchema /DataStoreName $SchemaName /OutputDir $schemaDir | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Schema downloaded successfully" -ForegroundColor Green
    } else {
        throw "Schema download failed with exit code: $LASTEXITCODE"
    }
} catch {
    Write-Host "   ❌ Failed to download schema: $_" -ForegroundColor Red
    Write-Host "`n   ⚠️  Schema may not have propagated yet" -ForegroundColor Yellow
    Write-Host "   Wait 10-15 minutes after creating the classifier, then retry" -ForegroundColor Cyan
    Pop-Location
    exit 1
}

Pop-Location

# Locate the downloaded schema file
$schemaFile = Get-ChildItem -Path $schemaDir -Filter "*.xml" | Select-Object -First 1
if (-not $schemaFile) {
    Write-Host "   ❌ Schema file not found in: $schemaDir" -ForegroundColor Red
    exit 1
}
Write-Host "   📋 Schema file: $($schemaFile.Name)" -ForegroundColor Cyan

# =============================================================================
# Action 6: Prepare Hash Directory
# =============================================================================

Write-Host "`n📂 Preparing hash directory..." -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

$hashDir = Join-Path $PSScriptRoot "..\Output\EDMHashes"
if (-not (Test-Path $hashDir)) {
    New-Item -Path $hashDir -ItemType Directory -Force | Out-Null
}
Write-Host "   ✅ Hash directory ready" -ForegroundColor Green

# =============================================================================
# Action 7: Upload EDM Data
# =============================================================================

Write-Host "`n🚀 Uploading EDM data..." -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green
Write-Host "   Schema: $SchemaName" -ForegroundColor Cyan
Write-Host "   Data File: $(Split-Path $DataFile -Leaf)" -ForegroundColor Cyan
Write-Host "   Hash Location: EDMHashes\" -ForegroundColor Cyan

Push-Location "C:\Program Files\Microsoft\EdmUploadAgent"

try {
    # UploadData command handles hashing and uploading in one step
    & .\EdmUploadAgent.exe /UploadData `
        /DataStoreName $SchemaName `
        /DataFile $DataFile `
        /HashLocation $hashDir `
        /Schema $schemaFile.FullName `
        /ColumnSeparator "," `
        /AllowedBadLinesPercentage 5 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n   ✅ Data uploaded successfully!" -ForegroundColor Green
        Write-Host "`n📊 Upload Summary" -ForegroundColor Cyan
        Write-Host "=================" -ForegroundColor Cyan
        Write-Host "   Schema: $SchemaName" -ForegroundColor Green
        Write-Host "   Data File: $(Split-Path $DataFile -Leaf)" -ForegroundColor Green
        Write-Host "   Status: Upload complete" -ForegroundColor Green
        Write-Host "`n   ⏳ Indexing Time: 12-24 hours" -ForegroundColor Yellow
        Write-Host "   💡 Check status: Get-DlpEdmSchema | Where-Object { `$_.DataStore.DataStoreName -eq '$SchemaName' }" -ForegroundColor Cyan
        
        Pop-Location
        exit 0
    } else {
        throw "EDM Upload Agent returned exit code: $LASTEXITCODE"
    }
} catch {
    Write-Host "   ❌ Upload failed: $_" -ForegroundColor Red
    
    # Check for specific error codes
    if ($LASTEXITCODE -eq -2146233088) {
        Write-Host "`n⚠️  Data Already Uploaded" -ForegroundColor Yellow
        Write-Host "=========================" -ForegroundColor Yellow
        Write-Host "   This error typically means data has already been uploaded for this schema." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   🔄 To re-upload data (overwrites existing):" -ForegroundColor Yellow
        Write-Host "   1. Delete existing data store:" -ForegroundColor Cyan
        Write-Host "      .\EdmUploadAgent.exe /DeleteDataStore /DataStoreName $SchemaName" -ForegroundColor White
        Write-Host ""
        Write-Host "   2. Re-run this script:" -ForegroundColor Cyan
        Write-Host "      .\Upload-EdmData.ps1" -ForegroundColor White
        Write-Host ""
        Write-Host "   💡 Or verify upload status:" -ForegroundColor Yellow
        Write-Host "      Get-DlpEdmSchema | Where-Object { `$_.DataStore.DataStoreName -eq '$SchemaName' }" -ForegroundColor White
        Write-Host "      (Check LastModifiedTime to confirm when data was uploaded)" -ForegroundColor Gray
    } else {
        # Provide general troubleshooting guidance
        Write-Host "`n🔍 Troubleshooting Tips:" -ForegroundColor Yellow
        Write-Host "   1. Verify schema has propagated:" -ForegroundColor Cyan
        Write-Host "      .\EdmUploadAgent.exe /GetDataStore" -ForegroundColor White
        Write-Host "      (Should show '$SchemaName' in the list)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "   2. Check authentication status:" -ForegroundColor Cyan
        Write-Host "      Run the script again (authentication is cached)" -ForegroundColor White
        Write-Host ""
        Write-Host "   3. Wait 10-15 minutes for schema propagation, then retry" -ForegroundColor Cyan
    }
    
    Pop-Location
    exit 1
}

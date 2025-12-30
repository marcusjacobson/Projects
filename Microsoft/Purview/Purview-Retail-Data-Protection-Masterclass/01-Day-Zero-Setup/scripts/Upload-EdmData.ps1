<#
.SYNOPSIS
    Step 3: Uploads EDM Data.
    - Generates dummy CSV data.
    - Hashes the data using the Schema.
    - Uploads the Hash to Purview.

.DESCRIPTION
    This script performs the final data upload. It requires the Schema to be perfectly aligned
    (synced) with the cloud definition, otherwise validation will fail.
    
    REQUIRES:
    - Run as Administrator
    - Interactive User Sign-in (for EDM Agent)
    - Schema file (from Step 2)

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
$csvPath = Join-Path $outputDir "CustomerDB.csv"
$xmlPath = Join-Path $outputDir "RetailCustomerDB.xml"
$hashDir = Join-Path $outputDir "Hashes"
$dataStoreName = "RetailCustomerDB"

# Ensure directories
if (-not (Test-Path $outputDir)) { New-Item -Path $outputDir -ItemType Directory -Force | Out-Null }
if (-not (Test-Path $hashDir)) { New-Item -Path $hashDir -ItemType Directory -Force | Out-Null }

Write-Host "🚀 Step 3: EDM Data Upload" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan

# 2. Generate Data (CSV)
Write-Host "📄 Generating dummy data..." -ForegroundColor Yellow
$csvContent = @"
CustomerId,FirstName,LastName,Email,PhoneNumber,CreditCardNumber,LoyaltyId
C001,John,Doe,john.doe@contoso.com,555-0101,1234-5678-9012-3456,L1001
C002,Jane,Smith,jane.smith@contoso.com,555-0102,2345-6789-0123-4567,L1002
C003,Alice,Johnson,alice.j@contoso.com,555-0103,3456-7890-1234-5678,L1003
"@
$csvContent | Out-File -FilePath $csvPath -Encoding UTF8
Write-Host "✅ Data file created: $csvPath" -ForegroundColor Green

# 3. Validate Schema Existence
if (-not (Test-Path $xmlPath)) {
    Write-Host "❌ Schema file not found: $xmlPath" -ForegroundColor Red
    Write-Host "   Please run 'Sync-EdmSchema.ps1' first." -ForegroundColor Yellow
    exit
}

# 4. Authenticate & Upload
Write-Host "`n🔐 Authenticating & Uploading..." -ForegroundColor Yellow
Push-Location "C:\Program Files\Microsoft\EdmUploadAgent"

# UploadData command handles hashing and uploading in one step
& .\EdmUploadAgent.exe /UploadData /DataStoreName $dataStoreName /DataFile $csvPath /HashLocation $hashDir /Schema $xmlPath /ColumnSeparator ","

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Data Uploaded Successfully!" -ForegroundColor Green
    Write-Host "   Indexing may take 12-24 hours." -ForegroundColor Gray
} else {
    Write-Host "`n❌ Upload Failed." -ForegroundColor Red
    Write-Host "   Check the error message above." -ForegroundColor Gray
    Write-Host "   💡 TIP: If you see 'Schema provided is not a valid XML', run '.\Sync-EdmSchema.ps1' again to download the authoritative schema." -ForegroundColor Yellow
}

Pop-Location
Write-Host "`n✅ Step 3 Complete." -ForegroundColor Green

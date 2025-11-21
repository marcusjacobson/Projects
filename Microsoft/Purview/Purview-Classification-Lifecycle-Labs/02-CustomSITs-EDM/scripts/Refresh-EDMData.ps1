<#
.SYNOPSIS
    Refreshes EDM data store with updated employee database.

.DESCRIPTION
    Updates the EDM data store with new employee data (new hires, terminations, corrections).
    The refresh process replaces the existing data completely (not additive).

.PARAMETER DatabasePath
    Path to the updated employee database CSV file.

.PARAMETER DataStoreName
    Name of the EDM data store to refresh.

.PARAMETER ToolsPath
    Directory containing EDMUploadAgent.exe.
    Default: C:\PurviewLabs\Lab2-EDM-Testing\tools

.PARAMETER BackupCurrent
    If specified, backs up current database before refresh.

.EXAMPLE
    .\Refresh-EDMData.ps1 -DatabasePath "C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase_Updated.csv" -DataStoreName "EmployeeDataStore"

.EXAMPLE
    .\Refresh-EDMData.ps1 -DatabasePath "C:\Data\Employees.csv" -DataStoreName "EmployeeDataStore" -BackupCurrent

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    
    Requirements:
    - PowerShell 7.0 or later
    - ExchangeOnlineManagement module
    - EDM_DataUploaders group membership
    - EDMUploadAgent.exe installed
    
    Script development orchestrated using GitHub Copilot.

.REFRESH PROCESS
    - Backup Creation (optional)
    - CSV Validation (structure matches schema)
    - Data Hashing (SHA-256)
    - Purview Upload (replaces existing data)
    - Indexing Wait (30-90 minutes)
#>

#Requires -Version 7.0
#Requires -Modules ExchangeOnlineManagement

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Path to updated employee database CSV")]
    [ValidateScript({
        if (-not (Test-Path $_)) {
            throw "Database file not found: $_"
        }
        if ([System.IO.Path]::GetExtension($_) -ne '.csv') {
            throw "Database file must be a CSV file"
        }
        return $true
    })]
    [string]$DatabasePath,

    [Parameter(Mandatory = $true, HelpMessage = "Name of the EDM data store")]
    [ValidateNotNullOrEmpty()]
    [string]$DataStoreName,

    [Parameter(Mandatory = $false, HelpMessage = "Directory for EDMUploadAgent.exe")]
    [string]$ToolsPath = "C:\PurviewLabs\Lab2-EDM-Testing\tools",

    [Parameter(Mandatory = $false, HelpMessage = "Backup current database before refresh")]
    [switch]$BackupCurrent
)

# Import Shared Utilities Module
$sharedUtilitiesPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "Shared-Utilities\PurviewUtilities.psm1"
if (Test-Path $sharedUtilitiesPath) {
    Import-Module $sharedUtilitiesPath -Force
} else {
    Write-Error "Shared Utilities module not found at: $sharedUtilitiesPath"
    exit 1
}

Write-Host "🔐 Step 1: Authentication" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

try {
    Write-Host "📋 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
    Connect-IPPSSession -WarningAction SilentlyContinue | Out-Null
    Write-Host "   ✅ Connected successfully" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "   ❌ Authentication failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "🔍 Step 2: Verify Current EDM Data Store" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

try {
    $currentSchema = Get-DlpEdmSchema | Where-Object {$_.DataStoreName -eq $DataStoreName} -ErrorAction Stop
    
    Write-Host "   ✅ Current EDM Data Store:" -ForegroundColor Green
    Write-Host "      Name: $($currentSchema.DataStoreName)" -ForegroundColor White
    Write-Host "      Status: $($currentSchema.Status)" -ForegroundColor White
    Write-Host "      Current Records: $($currentSchema.RecordCount)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "   ❌ EDM data store not found: $_" -ForegroundColor Red
    exit 1
}

if ($BackupCurrent) {
    Write-Host "💾 Step 3: Backup Current Database" -ForegroundColor Green
    Write-Host "===================================" -ForegroundColor Green
    
    try {
        $backupDir = Join-Path (Split-Path $DatabasePath -Parent) "backups"
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }
        
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupName = "EmployeeDatabase_Backup_$timestamp.csv"
        $backupPath = Join-Path $backupDir $backupName
        
        Write-Host "   📋 Creating backup..." -ForegroundColor Cyan
        Write-Host "   ℹ️  Note: This backs up the CSV file, not Purview data" -ForegroundColor Yellow
        
        Copy-Item -Path $DatabasePath -Destination $backupPath -Force
        
        Write-Host "   ✅ Backup created: $backupName" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host "   ⚠️  Backup failed: $_" -ForegroundColor Yellow
        Write-Host "   Continuing with refresh..." -ForegroundColor Cyan
        Write-Host ""
    }
}

Write-Host "🔍 Step $(if ($BackupCurrent) {4} else {3}): Validate Updated CSV" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

try {
    $csvData = Import-Csv -Path $DatabasePath -Encoding UTF8
    
    if ($csvData.Count -eq 0) {
        throw "Updated CSV file is empty"
    }
    
    $columns = $csvData[0].PSObject.Properties.Name
    $expectedColumns = @("EmployeeID", "FirstName", "LastName", "Email", "Phone", "SSN", "Department", "HireDate")
    $missingColumns = $expectedColumns | Where-Object { $_ -notin $columns }
    
    if ($missingColumns) {
        throw "CSV is missing required columns: $($missingColumns -join ', ')"
    }
    
    Write-Host "   ✅ CSV validation passed" -ForegroundColor Green
    Write-Host "      New Records: $($csvData.Count)" -ForegroundColor White
    Write-Host "      Current Records: $($currentSchema.RecordCount)" -ForegroundColor White
    Write-Host "      Change: $(if ($csvData.Count -gt $currentSchema.RecordCount) { "+" })$($csvData.Count - $currentSchema.RecordCount)" -ForegroundColor $(if ($csvData.Count -ge $currentSchema.RecordCount) { "Green" } else { "Yellow" })
    Write-Host ""
} catch {
    Write-Host "   ❌ CSV validation failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "🔒 Step $(if ($BackupCurrent) {5} else {4}): Hash and Upload Updated Data" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

$edmAgentPath = Join-Path $ToolsPath "EdmUploadAgent.exe"

if (-not (Test-Path $edmAgentPath)) {
    Write-Host "   ❌ EDMUploadAgent.exe not found: $edmAgentPath" -ForegroundColor Red
    Write-Host "   💡 Run Upload-EDMData.ps1 first to download the tool" -ForegroundColor Cyan
    exit 1
}

try {
    Write-Host "📋 Starting EDM refresh process..." -ForegroundColor Cyan
    Write-Host "   ℹ️  This will replace existing data (not additive)" -ForegroundColor Yellow
    Write-Host "   ℹ️  Process may take 5-15 minutes..." -ForegroundColor Yellow
    Write-Host ""
    
    $arguments = @(
        "/UploadData",
        "/DataStoreName:$DataStoreName",
        "/DataFile:`"$DatabasePath`"",
        "/HashLocation:`"$ToolsPath`""
    )
    
    Write-Host "📋 Phase 1: Data Hashing..." -ForegroundColor Cyan
    $process = Start-Process -FilePath $edmAgentPath -ArgumentList $arguments -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        Write-Host "   ✅ Data hashing completed" -ForegroundColor Green
        Write-Host "   ✅ Upload to Purview completed" -ForegroundColor Green
        Write-Host ""
    } else {
        throw "EDMUploadAgent failed with exit code: $($process.ExitCode)"
    }
} catch {
    Write-Host "   ❌ Data refresh failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "🧹 Step $(if ($BackupCurrent) {6} else {5}): Cleanup" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green

try {
    $hashFiles = Get-ChildItem -Path $ToolsPath -Filter "*.EdmHash" -ErrorAction SilentlyContinue
    
    if ($hashFiles) {
        foreach ($file in $hashFiles) {
            Remove-Item $file.FullName -Force
        }
        Write-Host "   ✅ Hash files removed for security" -ForegroundColor Green
    }
    Write-Host ""
} catch {
    Write-Host "   ⚠️  Could not remove hash files: $_" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "📊 Step $(if ($BackupCurrent) {7} else {6}): Refresh Summary" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

Write-Host "📋 Refresh Results:" -ForegroundColor Cyan
Write-Host "   Data Store: $DataStoreName" -ForegroundColor White
Write-Host "   Previous Records: $($currentSchema.RecordCount)" -ForegroundColor White
Write-Host "   New Records: $($csvData.Count)" -ForegroundColor White
Write-Host "   Status: Refresh Completed" -ForegroundColor Green
Write-Host ""

Write-Host "⏱️  Indexing Timeline:" -ForegroundColor Yellow
Write-Host "   • EDM data refresh is now uploaded" -ForegroundColor White
Write-Host "   • Indexing will take 30-90 minutes" -ForegroundColor White
Write-Host "   • Classifications will use new data after indexing" -ForegroundColor White
Write-Host ""

Write-Host "🎯 Next Steps:" -ForegroundColor Green
Write-Host "   1. Wait 30-90 minutes for indexing to complete" -ForegroundColor White
Write-Host "   2. Verify updated record count:" -ForegroundColor White
Write-Host "      Get-DlpEdmSchema | Where-Object {\$_.DataStoreName -eq '$DataStoreName'}" -ForegroundColor DarkGray
Write-Host "   3. Test classification with new employee data" -ForegroundColor White
Write-Host ""

Write-Host "✅ EDM data refresh completed successfully" -ForegroundColor Green
exit 0

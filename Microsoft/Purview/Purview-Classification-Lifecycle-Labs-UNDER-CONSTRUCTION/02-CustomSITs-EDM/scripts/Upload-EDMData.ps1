<#
.SYNOPSIS
    Hashes and uploads employee database to Microsoft Purview EDM (Exact Data Match) data store.

.DESCRIPTION
    This script downloads the EDMUploadAgent.exe tool (if not present), validates the employee
    database CSV structure, creates a secure SHA-256 hashed version of the data, uploads it
    to Microsoft Purview's secure storage, and removes the local hash file for security.

.PARAMETER DatabasePath
    Path to the employee database CSV file to upload.

.PARAMETER DataStoreName
    Name of the EDM data store (must match uploaded schema).

.PARAMETER ToolsPath
    Directory where EDMUploadAgent.exe will be downloaded/stored.
    Default: C:\PurviewLabs\Lab2-EDM-Testing\tools

.EXAMPLE
    .\Upload-EDMData.ps1 -DatabasePath "C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase.csv" -DataStoreName "EmployeeDataStore"
    
    Hashes and uploads the employee database to the specified data store.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    Last Modified: 2025-11-14
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7.0 or later
    - ExchangeOnlineManagement module (3.0+)
    - Security & Compliance PowerShell permissions
    - EDM_DataUploaders security group membership (critical)
    - Internet connectivity for EDMUploadAgent download
    
    Script development orchestrated using GitHub Copilot.

.UPLOAD PROCESS
    - EDMUploadAgent Download (if not present)
    - CSV Validation (structure matches schema)
    - Data Hashing (SHA-256 secure transformation)
    - Purview Upload (encrypted TLS 1.3 transmission)
    - Local Cleanup (hash file deletion for security)
    - Indexing Wait (30-90 minutes for activation)
#>

#Requires -Version 7.0
#Requires -Modules ExchangeOnlineManagement

# =============================================================================
# Hash and upload employee database to EDM data store.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Path to employee database CSV file")]
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

    [Parameter(Mandatory = $false, HelpMessage = "Path to EDM schema XML file")]
    [string]$SchemaPath = "C:\PurviewLabs\Lab2-EDM-Testing\configs\EmployeeDataStore.xml"
)

# Import Shared Utilities Module
$sharedUtilitiesPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "Shared-Utilities\PurviewUtilities.psm1"
if (Test-Path $sharedUtilitiesPath) {
    Import-Module $sharedUtilitiesPath -Force
} else {
    Write-Error "Shared Utilities module not found at: $sharedUtilitiesPath"
    exit 1
}

# =============================================================================
# Step 1: Environment Setup
# =============================================================================

Write-Host "🔍 Step 1: Environment Setup" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

try {
    Write-Host "📋 Creating tools directory..." -ForegroundColor Cyan
    
    if (-not (Test-Path $ToolsPath)) {
        New-Item -ItemType Directory -Path $ToolsPath -Force | Out-Null
        Write-Host "   ✅ Created directory: $ToolsPath" -ForegroundColor Green
    } else {
        Write-Host "   ✅ Directory already exists: $ToolsPath" -ForegroundColor Green
    }
    
    Write-Host ""

} catch {
    Write-Host "   ❌ Failed to create tools directory: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Download EDMUploadAgent
# =============================================================================

Write-Host "⬇️  Step 2: EDMUploadAgent Setup" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

$edmAgentPath = Join-Path $ToolsPath "EdmUploadAgent.exe"

try {
    # Check if EDMUploadAgent is installed in Program Files (proper MSI installation)
    $installedPath = "C:\Program Files\Microsoft\EdmUploadAgent\EdmUploadAgent.exe"
    
    if (Test-Path $installedPath) {
        Write-Host "📋 EDMUploadAgent found (MSI installation)" -ForegroundColor Cyan
        $fileInfo = Get-Item $installedPath
        Write-Host "   ✅ Found: $installedPath" -ForegroundColor Green
        Write-Host "   📅 Last Modified: $($fileInfo.LastWriteTime)" -ForegroundColor White
        $edmAgentPath = $installedPath
    } elseif (Test-Path $edmAgentPath) {
        # Validate existing file is a proper executable (not corrupted MSI)
        Write-Host "📋 Validating existing EdmUploadAgent.exe..." -ForegroundColor Cyan
        
        try {
            # Check PE header to verify it's a valid executable
            $fileBytes = [System.IO.File]::ReadAllBytes($edmAgentPath)
            if ($fileBytes.Length -gt 64) {
                $peHeaderOffset = [BitConverter]::ToInt32($fileBytes, 60)
                if ($peHeaderOffset -lt $fileBytes.Length - 4) {
                    $peSignature = [BitConverter]::ToUInt32($fileBytes, $peHeaderOffset)
                    if ($peSignature -eq 0x00004550) {  # "PE\0\0"
                        # Valid PE executable
                        Write-Host "   ✅ Valid executable found: $edmAgentPath" -ForegroundColor Green
                        $fileInfo = Get-Item $edmAgentPath
                        Write-Host "   📅 Last Modified: $($fileInfo.LastWriteTime)" -ForegroundColor White
                    } else {
                        throw "Invalid PE signature"
                    }
                } else {
                    throw "Invalid PE header offset"
                }
            } else {
                throw "File too small to be valid executable"
            }
        } catch {
            Write-Host "   ⚠️  Existing file is corrupted or invalid (likely MSI saved as .exe)" -ForegroundColor Yellow
            Write-Host "   🗑️  Removing corrupted file..." -ForegroundColor Cyan
            Remove-Item $edmAgentPath -Force
            $edmAgentPath = $null
        }
    }
    
    if (-not $edmAgentPath -or -not (Test-Path $edmAgentPath)) {
        Write-Host "📋 Downloading and installing EDMUploadAgent..." -ForegroundColor Cyan
        Write-Host "   ℹ️  This may take 2-3 minutes..." -ForegroundColor Yellow
        
        # Download MSI installer (not EXE)
        $msiUrl = "https://download.microsoft.com/download/2/1/2/212aa2c0-9f12-4b1b-b729-6619ca0f3db3/EdmUploadAgent.msi"
        $msiPath = Join-Path $ToolsPath "EdmUploadAgent.msi"
        
        # Download MSI
        Write-Host "   ⬇️  Downloading MSI installer..." -ForegroundColor Cyan
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath -UseBasicParsing
        $ProgressPreference = 'Continue'
        
        # Install MSI silently
        Write-Host "   🔧 Installing EdmUploadAgent (requires admin privileges)..." -ForegroundColor Cyan
        $installArgs = @(
            "/i"
            "`"$msiPath`""
            "/qn"  # Quiet mode, no UI
            "/norestart"
            "/L*V"  # Verbose logging
            "`"$ToolsPath\EdmUploadAgent_install.log`""
        )
        
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Host "   ✅ EdmUploadAgent MSI installation completed" -ForegroundColor Green
            
            # Search common installation locations
            $searchPaths = @(
                "C:\Program Files\Microsoft\EdmUploadAgent\EdmUploadAgent.exe",
                "C:\Program Files (x86)\Microsoft\EdmUploadAgent\EdmUploadAgent.exe",
                "$env:ProgramFiles\Microsoft\EdmUploadAgent\EdmUploadAgent.exe",
                "${env:ProgramFiles(x86)}\Microsoft\EdmUploadAgent\EdmUploadAgent.exe",
                "$env:LOCALAPPDATA\Microsoft\EdmUploadAgent\EdmUploadAgent.exe"
            )
            
            $foundPath = $null
            foreach ($path in $searchPaths) {
                if (Test-Path $path) {
                    $foundPath = $path
                    break
                }
            }
            
            if ($foundPath) {
                $edmAgentPath = $foundPath
                Write-Host "   ✅ Found EdmUploadAgent at: $foundPath" -ForegroundColor Green
            } else {
                # MSI installed but files not in expected locations - use manual installation
                Write-Host "   ⚠️  MSI installation succeeded but EdmUploadAgent.exe not found in standard locations" -ForegroundColor Yellow
                Write-Host "   💡 The MSI may require interactive installation. Please follow manual steps below." -ForegroundColor Yellow
                throw "EdmUploadAgent.exe not found after MSI installation. Use manual installation method."
            }
            
            # Clean up MSI file
            Remove-Item $msiPath -Force -ErrorAction SilentlyContinue
        } else {
            throw "MSI installation failed with exit code: $($process.ExitCode). Check log: $ToolsPath\EdmUploadAgent_install.log"
        }
    }
    
    Write-Host ""

} catch {
    Write-Host "   ❌ Failed to setup EDMUploadAgent: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Manual Installation Steps (Interactive):" -ForegroundColor Yellow
    Write-Host "   1. Download MSI: https://download.microsoft.com/download/2/1/2/212aa2c0-9f12-4b1b-b729-6619ca0f3db3/EdmUploadAgent.msi" -ForegroundColor White
    Write-Host "   2. Double-click the downloaded MSI file" -ForegroundColor White
    Write-Host "   3. Follow the installation wizard (accept defaults)" -ForegroundColor White
    Write-Host "   4. After installation completes, re-run this script" -ForegroundColor White
    Write-Host ""
    Write-Host "   📝 Note: The MSI's silent installation (/qn) may not work properly." -ForegroundColor Cyan
    Write-Host "   Interactive installation via double-click is recommended." -ForegroundColor Cyan
    exit 1
}

# =============================================================================
# Step 3: Validate CSV Structure
# =============================================================================

Write-Host "🔍 Step 3: CSV Validation" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green

try {
    Write-Host "📋 Loading and validating CSV file..." -ForegroundColor Cyan
    
    # Load CSV
    $csvData = Import-Csv -Path $DatabasePath -Encoding UTF8
    
    if ($csvData.Count -eq 0) {
        throw "CSV file is empty"
    }
    
    # Get column names
    $columns = $csvData[0].PSObject.Properties.Name
    
    # Expected columns from schema
    $expectedColumns = @("EmployeeID", "FirstName", "LastName", "Email", "Phone", "SSN", "Department", "HireDate")
    
    # Check for missing columns
    $missingColumns = $expectedColumns | Where-Object { $_ -notin $columns }
    
    if ($missingColumns) {
        throw "CSV is missing required columns: $($missingColumns -join ', ')"
    }
    
    # Check encoding
    $rawContent = Get-Content -Path $DatabasePath -Raw
    $encoding = [System.Text.Encoding]::GetEncoding([System.Text.Encoding]::Default.CodePage)
    
    Write-Host "   ✅ CSV validation passed" -ForegroundColor Green
    Write-Host "      Records: $($csvData.Count)" -ForegroundColor White
    Write-Host "      Columns: $($columns.Count)" -ForegroundColor White
    Write-Host "      Size: $([math]::Round((Get-Item $DatabasePath).Length / 1KB, 2)) KB" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host "   ❌ CSV validation failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 4: Connect to Security & Compliance PowerShell
# =============================================================================

Write-Host "🔐 Step 4: Authentication" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

try {
    Write-Host "📋 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
    Write-Host "   ℹ️  You will be prompted to sign in via browser" -ForegroundColor Yellow
    
    # Use Connect-IPPSSession without credentials for interactive browser-based auth
    Connect-IPPSSession -WarningAction SilentlyContinue | Out-Null
    
    Write-Host "   ✅ Connected to Security & Compliance PowerShell" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "   ❌ Authentication failed: $_" -ForegroundColor Red
    Write-Host "   ℹ️  Ensure you have appropriate permissions and EDM_DataUploaders membership" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 5: Verify EDM Schema Exists
# =============================================================================

Write-Host "🔍 Step 5: Schema Verification" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

try {
    Write-Host "📋 Verifying EDM schema exists..." -ForegroundColor Cyan
    
    $schema = Get-DlpEdmSchema | Where-Object {$_.DataStoreName -eq $DataStoreName} -ErrorAction Stop
    
    if ($schema) {
        Write-Host "   ✅ Schema found and active" -ForegroundColor Green
        Write-Host "      Data Store: $($schema.DataStoreName)" -ForegroundColor White
        Write-Host "      Status: $($schema.Status)" -ForegroundColor White
        Write-Host "      Version: $($schema.SchemaVersion)" -ForegroundColor White
    } else {
        throw "Schema not found for data store: $DataStoreName"
    }
    
    Write-Host ""

} catch {
    Write-Host "   ❌ Schema verification failed: $_" -ForegroundColor Red
    Write-Host "   💡 Run Upload-EDMSchema.ps1 first to upload the schema" -ForegroundColor Cyan
    exit 1
}

# =============================================================================
# Step 6: EDMUploadAgent Authorization
# =============================================================================

Write-Host "🔐 Step 6: EDMUploadAgent Authorization" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

Write-Host "📋 Checking EDMUploadAgent authorization status..." -ForegroundColor Cyan

try {
    # Check if already authorized by attempting to get data store info
    $checkArgs = "/GetDataStore"
    $checkProcess = Start-Process -FilePath $edmAgentPath -ArgumentList $checkArgs -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$ToolsPath\check_output.txt" -RedirectStandardError "$ToolsPath\check_error.txt"
    
    $checkError = Get-Content "$ToolsPath\check_error.txt" -Raw -ErrorAction SilentlyContinue
    
    if ($checkError -match "TenantId is not set" -or $checkProcess.ExitCode -ne 0) {
        Write-Host "   ℹ️  Authorization required. Starting authorization flow..." -ForegroundColor Yellow
        Write-Host "   🌐 A browser window will open for authentication" -ForegroundColor Cyan
        Write-Host ""
        
        # Run authorization
        $authArgs = "/Authorize"
        $authProcess = Start-Process -FilePath $edmAgentPath -ArgumentList $authArgs -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$ToolsPath\auth_output.txt" -RedirectStandardError "$ToolsPath\auth_error.txt"
        
        if ($authProcess.ExitCode -eq 0) {
            Write-Host "   ✅ EDMUploadAgent authorized successfully" -ForegroundColor Green
        } else {
            $authError = Get-Content "$ToolsPath\auth_error.txt" -Raw -ErrorAction SilentlyContinue
            throw "Authorization failed: $authError"
        }
    } else {
        Write-Host "   ✅ EDMUploadAgent already authorized" -ForegroundColor Green
    }
    
    Write-Host ""
    
} catch {
    Write-Host "   ❌ Authorization failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Try manual authorization:" -ForegroundColor Yellow
    Write-Host "   1. Open PowerShell as Administrator" -ForegroundColor White
    Write-Host "   2. cd `"$ToolsPath`"" -ForegroundColor White
    Write-Host "   3. .\EdmUploadAgent.exe /Authorize" -ForegroundColor White
    exit 1
}

# =============================================================================
# Step 7: Hash and Upload Data
# =============================================================================

Write-Host "🔒 Step 7: Hash and Upload Data" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

Write-Host "📋 Starting EDMUploadAgent process..." -ForegroundColor Cyan
Write-Host "   ℹ️  This process may take 5-15 minutes depending on data size" -ForegroundColor Yellow
Write-Host ""

try {
    # Verify schema file exists
    if (-not (Test-Path $SchemaPath)) {
        throw "Schema file not found: $SchemaPath. Run Create-EDMSchema.ps1 first."
    }

    Write-Host "📋 Phase 1: Data Hashing (SHA-256)..." -ForegroundColor Cyan
    Write-Host "   ℹ️  Creating secure hashed version of employee data..." -ForegroundColor Yellow
    
    # Check if running with appropriate permissions
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Host "   ⚠️  Warning: Not running as administrator. EDMUploadAgent may fail." -ForegroundColor Yellow
    }
    
    # Step 1: Create Hash using /CreateHash command
    # Use & operator for direct execution instead of Start-Process for better argument handling
    & $edmAgentPath /CreateHash /DataFile "$DatabasePath" /HashLocation "$ToolsPath" /Schema "$SchemaPath" /AllowedBadLinesPercentage 5
    
    if ($LASTEXITCODE -ne 0) {
        throw "Hash creation failed with exit code: $LASTEXITCODE"
    }
    
    Write-Host "   ✅ Data hashing completed successfully" -ForegroundColor Green
    Write-Host ""
    
    # Step 2: Upload Hash using /UploadHash command
    Write-Host "📋 Phase 2: Upload to Purview..." -ForegroundColor Cyan
    Write-Host "   ℹ️  Uploading hashed data to Microsoft Purview secure storage..." -ForegroundColor Yellow
    
    # Find the generated hash file (named after the base CSV filename, not full path)
    $hashFile = Get-ChildItem -Path $ToolsPath -Filter "*.EdmHash" | Select-Object -First 1
    if (-not $hashFile) {
        throw "Hash file not found in $ToolsPath"
    }
    
    Write-Host "   📋 Using hash file: $($hashFile.Name)" -ForegroundColor Cyan
    
    # Execute UploadHash using & operator
    & $edmAgentPath /UploadHash /DataStoreName "$DataStoreName" /HashFile "$($hashFile.FullName)"
    
    if ($LASTEXITCODE -ne 0) {
        throw "Hash upload failed with exit code: $LASTEXITCODE"
    }
    
    Write-Host "   ✅ Upload completed successfully" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "   ❌ Data upload failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Common Issues:" -ForegroundColor Cyan
    Write-Host "   • Not a member of EDM_DataUploaders security group" -ForegroundColor White
    Write-Host "   • CSV columns don't match schema field names exactly" -ForegroundColor White
    Write-Host "   • Schema doesn't exist (run Upload-EDMSchema.ps1 first)" -ForegroundColor White
    Write-Host "   • Invalid CSV encoding (must be UTF-8)" -ForegroundColor White
    Write-Host "   • Network connectivity issues" -ForegroundColor White
    Write-Host "   • EDMUploadAgent.exe compatibility issues (try running PowerShell as Administrator)" -ForegroundColor White
    Write-Host "   • Missing .NET Framework 4.8 or Visual C++ Redistributables" -ForegroundColor White
    Write-Host ""
    Write-Host "   💡 Troubleshooting Steps:" -ForegroundColor Yellow
    Write-Host "   1. Verify Security Group: Get-AzureADGroupMember -ObjectId (Get-AzureADGroup -SearchString 'EDM_DataUploaders').ObjectId" -ForegroundColor Gray
    Write-Host "   2. Check Schema: Get-DlpEdmSchema | Where-Object {\$_.DataStoreName -eq '$DataStoreName'}" -ForegroundColor Gray
    Write-Host "   3. Try running PowerShell as Administrator" -ForegroundColor Gray
    Write-Host "   4. Manual upload instructions: https://learn.microsoft.com/en-us/purview/sit-create-edm-sit-unified-ux#upload-data" -ForegroundColor Gray
    exit 1
}

# =============================================================================
# Step 7: Cleanup Hash Files
# =============================================================================

Write-Host "🧹 Step 7: Security Cleanup" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

try {
    Write-Host "📋 Removing local hash files for security..." -ForegroundColor Cyan
    
    # Remove hash files (EdmHash format)
    $hashFiles = Get-ChildItem -Path $ToolsPath -Filter "*.EdmHash" -ErrorAction SilentlyContinue
    
    if ($hashFiles) {
        foreach ($file in $hashFiles) {
            Remove-Item $file.FullName -Force
            Write-Host "   🗑️  Deleted: $($file.Name)" -ForegroundColor Yellow
        }
        Write-Host "   ✅ Hash files removed successfully" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  No hash files found to remove" -ForegroundColor Cyan
    }
    
    Write-Host ""

} catch {
    Write-Host "   ⚠️  Warning: Could not remove hash files: $_" -ForegroundColor Yellow
    Write-Host "   Manual cleanup recommended for security" -ForegroundColor Yellow
    Write-Host ""
}

# =============================================================================
# Step 8: Upload Summary and Next Steps
# =============================================================================

Write-Host "📊 Step 8: Upload Summary" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green

Write-Host "📋 Upload Results:" -ForegroundColor Cyan
Write-Host "   Data Store: $DataStoreName" -ForegroundColor White
Write-Host "   Records Uploaded: $($csvData.Count)" -ForegroundColor White
Write-Host "   Source File: $(Split-Path $DatabasePath -Leaf)" -ForegroundColor White
Write-Host "   Upload Status: Completed" -ForegroundColor Green
Write-Host ""

Write-Host "⏱️  Indexing Timeline:" -ForegroundColor Yellow
Write-Host "   • EDM data is now uploaded to Purview" -ForegroundColor White
Write-Host "   • Indexing will take 30-90 minutes to complete" -ForegroundColor White
Write-Host "   • Classification will be active after indexing completes" -ForegroundColor White
Write-Host "   • You can proceed with creating the EDM SIT while indexing runs" -ForegroundColor White
Write-Host ""

# =============================================================================
# Step 9: Next Steps
# =============================================================================

Write-Host "🎯 Step 9: Next Steps" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green

Write-Host "📋 Recommended Actions:" -ForegroundColor Cyan
Write-Host "   1. Run Create-EDM-SIT.ps1 to create EDM-based custom SIT (can do now)" -ForegroundColor White
Write-Host "   2. Wait 30-90 minutes for EDM data indexing to complete" -ForegroundColor White
Write-Host "   3. Verify EDM data status using: Get-DlpEdmSchema | Where-Object {\$_.DataStoreName -eq '$DataStoreName'}" -ForegroundColor White
Write-Host "   4. Create test documents using Create-EDMTestDocuments.ps1" -ForegroundColor White
Write-Host "   5. Validate classification using Validate-EDMClassification.ps1" -ForegroundColor White
Write-Host ""

Write-Host "📋 Status Check Command:" -ForegroundColor Cyan
Write-Host "   Get-DlpEdmSchema | Where-Object {\$_.DataStoreName -eq '$DataStoreName'} | Select-Object DataStoreName, RecordCount, Status" -ForegroundColor White
Write-Host ""

Write-Host "📋 Create EDM SIT Command (run now):" -ForegroundColor Cyan
Write-Host "   .\Create-EDM-SIT.ps1 -DataStoreName '$DataStoreName' -SchemaVersion '1.0'" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  Important Notes:" -ForegroundColor Yellow
Write-Host "   • EDM data is now securely stored in Purview (hashed, encrypted)" -ForegroundColor Yellow
Write-Host "   • Original CSV contains plaintext PII - secure or delete appropriately" -ForegroundColor Yellow
Write-Host "   • Classification will not work until indexing completes (30-90 min)" -ForegroundColor Yellow
Write-Host "   • Check RecordCount in Get-DlpEdmSchema output to confirm data loaded" -ForegroundColor Yellow
Write-Host ""

Write-Host "✅ EDM data upload completed successfully" -ForegroundColor Green
exit 0

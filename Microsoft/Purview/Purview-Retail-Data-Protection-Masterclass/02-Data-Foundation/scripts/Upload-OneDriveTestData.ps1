<#
.SYNOPSIS
    Uploads department-specific test files to OneDrive for Business accounts.

.DESCRIPTION
    This script uploads test files from the data-templates directory to individual user
    OneDrive accounts based on department assignment. Files are organized into department-
    specific folders to enable testing of user-scoped DLP policies and OneDrive-specific
    classification scenarios.

.PARAMETER ConfigPath
    Path to the global-config.json file. Defaults to templates/global-config.json.

.EXAMPLE
    .\Upload-OneDriveTestData.ps1
    
    Uploads department-specific files to all test users' OneDrive accounts.

.EXAMPLE
    .\Upload-OneDriveTestData.ps1 -ConfigPath "C:\custom\config.json"
    
    Uses a custom configuration file for OneDrive uploads.

.NOTES
    Author: Marcus Jacobson
    Version: 1.2.0
    Created: 2025-12-30
    Last Modified: 2025-12-30
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK (Microsoft.Graph.Files, Microsoft.Graph.Users)
    - Service Principal with Files.ReadWrite.All permissions
    - Test files generated in data-templates/ directory
    - Test users with M365 E5 or E5 Compliance licenses
    - OneDrive sites provisioned (users must access OneDrive once at office.com)
    
    Script development orchestrated using GitHub Copilot.

.FILE DISTRIBUTION
    - Finance Department: Credit card files, banking files, financial reports
    - Marketing/Sales Department: Loyalty files, customer profile files
    - IT/Compliance Department: All file types for cross-department testing
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "$PSScriptRoot\..\..\templates\global-config.json"
)

# =============================================================================
# Step 1: Load Configuration and Validate Test Files
# =============================================================================

Write-Host "📤 OneDrive Test Data Upload" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host ""

# Load configuration
if (-not (Test-Path $ConfigPath)) {
    Write-Host "❌ Configuration file not found: $ConfigPath" -ForegroundColor Red
    exit 1
}

try {
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    Write-Host "✅ Configuration loaded from: $ConfigPath" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to parse configuration file: $_" -ForegroundColor Red
    exit 1
}

# Validate testUsers section exists
if (-not $config.testUsers -or $config.testUsers.Count -eq 0) {
    Write-Host "❌ No test users defined in configuration file" -ForegroundColor Red
    Write-Host "   Add a 'testUsers' array to global-config.json with user UPNs" -ForegroundColor Yellow
    exit 1
}

Write-Host "   📋 Found $($config.testUsers.Count) test users" -ForegroundColor Cyan

# Validate data-templates directory exists
$dataTemplatesPath = Join-Path $PSScriptRoot "..\data-templates"
if (-not (Test-Path $dataTemplatesPath)) {
    Write-Host "❌ Data templates directory not found: $dataTemplatesPath" -ForegroundColor Red
    Write-Host "   Run Generate-TestData.ps1 first to create test files" -ForegroundColor Yellow
    exit 1
}

# Get list of test files
$testFiles = Get-ChildItem -Path $dataTemplatesPath -File
if ($testFiles.Count -eq 0) {
    Write-Host "❌ No test files found in: $dataTemplatesPath" -ForegroundColor Red
    Write-Host "   Run Generate-TestData.ps1 first to create test files" -ForegroundColor Yellow
    exit 1
}

Write-Host "   📂 Found $($testFiles.Count) test files in data-templates/" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 2: Connect to Microsoft Graph
# =============================================================================

# Use the centralized connection helper script
$connectScript = Join-Path $PSScriptRoot "..\..\scripts\Connect-PurviewGraph.ps1"

if (-not (Test-Path $connectScript)) {
    Write-Host "❌ Connection helper script not found: $connectScript" -ForegroundColor Red
    Write-Host "   Ensure the project structure is intact" -ForegroundColor Yellow
    exit 1
}

try {
    & $connectScript
    Write-Host ""
} catch {
    Write-Host "❌ Failed to establish Graph connection: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Define Department-Based File Distribution
# =============================================================================

Write-Host "🔍 Step 3: Configuring Department-Based File Distribution" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

# Department-specific file mapping
$fileDistribution = @{
    "Finance" = @(
        "CreditCards-Only.xlsx",
        "Banking-DirectDeposit.xlsx",
        "Payment-Processing-Report.docx",
        "Payment-Processing-Report.pdf",
        "Q4-Financial-Review.pptx",
        "Retail-Financial-Data.xlsx",
        "CustomerDatabase-FULL.xlsx"
    )
    "Marketing" = @(
        "Loyalty-Program-Members.docx",
        "Customer-Profile-Export.docx",
        "Product-Catalog.xlsx",
        "Q1-Sales-Strategy.pptx",
        "CustomerDatabase-FULL.xlsx"
    )
    "Sales" = @(
        "Loyalty-Program-Members.docx",
        "Customer-Profile-Export.docx",
        "Product-Catalog.xlsx",
        "CustomerDatabase-FULL.xlsx"
    )
    "IT" = @(
        "CreditCards-Only.xlsx",
        "SSN-Records.docx",
        "Banking-DirectDeposit.xlsx",
        "Loyalty-Program-Members.docx",
        "Customer-Profile-Export.docx",
        "Payment-Processing-Report.docx",
        "Payment-Processing-Report.pdf",
        "Q4-Financial-Review.pptx",
        "Retail-Financial-Data.xlsx",
        "Product-Catalog.xlsx",
        "Team-Meeting-Notes.docx",
        "Q1-Sales-Strategy.pptx",
        "CustomerDatabase-FULL.xlsx"
    )
    "Compliance" = @(
        "CreditCards-Only.xlsx",
        "SSN-Records.docx",
        "Banking-DirectDeposit.xlsx",
        "Loyalty-Program-Members.docx",
        "Customer-Profile-Export.docx",
        "Payment-Processing-Report.docx",
        "Payment-Processing-Report.pdf",
        "Q4-Financial-Review.pptx",
        "Retail-Financial-Data.xlsx",
        "Product-Catalog.xlsx",
        "Team-Meeting-Notes.docx",
        "Q1-Sales-Strategy.pptx",
        "CustomerDatabase-FULL.xlsx"
    )
    "Default" = @(
        "Team-Meeting-Notes.docx",
        "Product-Catalog.xlsx",
        "Q1-Sales-Strategy.pptx"
    )
}

Write-Host "   ✅ File distribution configured for 6 department types" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 4: Check OneDrive Provisioning Status
# =============================================================================

Write-Host "🔧 Step 4: Checking OneDrive Provisioning Status" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

# Check which users have OneDrive provisioned
$provisionedUsers = @()
$unprovisionedUsers = @()

foreach ($upn in $config.testUsers) {
    try {
        $user = Get-MgUser -UserId $upn -Property Id,DisplayName -ErrorAction Stop
        
        # Try to get user's OneDrive drive with retry logic (Graph API may lag after fresh provisioning)
        $driveFound = $false
        $maxRetries = 3
        $retryDelay = 3
        
        for ($i = 1; $i -le $maxRetries; $i++) {
            try {
                $drive = Get-MgUserDrive -UserId $user.Id -ErrorAction Stop
                Write-Host "   ✅ $upn - OneDrive ready" -ForegroundColor Green
                $provisionedUsers += $upn
                $driveFound = $true
                break
            } catch {
                if ($_.Exception.Message -match "mysite not found|ResourceNotFound") {
                    if ($i -lt $maxRetries) {
                        Write-Host "   🔄 $upn - Checking OneDrive status... (attempt $i/$maxRetries)" -ForegroundColor Cyan
                        Start-Sleep -Seconds $retryDelay
                    } else {
                        Write-Host "   ⚠️  $upn - OneDrive not provisioned (needs first-time access)" -ForegroundColor Yellow
                        $unprovisionedUsers += $upn
                    }
                } else {
                    Write-Host "   ⚠️  $upn - Unable to check status: $($_.Exception.Message)" -ForegroundColor Yellow
                    break
                }
            }
        }
    } catch {
        Write-Host "   ❌ $upn - User not found" -ForegroundColor Red
    }
}

Write-Host ""

if ($unprovisionedUsers.Count -gt 0) {
    Write-Host "   📋 OneDrive Provisioning Required for $($unprovisionedUsers.Count) user(s):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   OneDrive sites are created when users first access OneDrive." -ForegroundColor Gray
    Write-Host "   Quick provisioning steps (30 seconds per user):" -ForegroundColor Gray
    Write-Host ""
    foreach ($upn in $unprovisionedUsers) {
        Write-Host "   • Sign in to https://office.com as $upn" -ForegroundColor Yellow
        Write-Host "     → Click OneDrive icon in app launcher" -ForegroundColor Gray
        Write-Host "     → Wait 30-60 seconds for site creation" -ForegroundColor Gray
        Write-Host ""
    }
    Write-Host "   After provisioning, re-run this script to upload files." -ForegroundColor Cyan
    Write-Host ""
}

Write-Host ""

# =============================================================================
# Step 5: Upload Files to Each User's OneDrive
# =============================================================================

Write-Host "📤 Step 5: Uploading Files to OneDrive Accounts" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

$uploadStats = @{
    UsersProcessed = 0
    TotalFiles = 0
    SuccessfulUploads = 0
    SkippedFiles = 0
    FailedUploads = 0
}

foreach ($upn in $config.testUsers) {
    Write-Host "📤 Processing: $upn" -ForegroundColor Cyan
    
    try {
        # Get user details from Entra ID
        $user = Get-MgUser -UserId $upn -Property Id,DisplayName,Department -ErrorAction Stop
        
        Write-Host "   👤 Display Name: $($user.DisplayName)" -ForegroundColor Gray
        
        $department = $user.Department
        if (-not $department) {
            Write-Host "   ⚠️  Department not set - using default file set" -ForegroundColor Yellow
            $department = "Default"
        } else {
            Write-Host "   🏢 Department: $department" -ForegroundColor Gray
        }
        
        # Get department-specific file list
        $filesToUpload = $fileDistribution[$department]
        if (-not $filesToUpload) {
            Write-Host "   ⚠️  No file mapping for department '$department' - using default" -ForegroundColor Yellow
            $filesToUpload = $fileDistribution["Default"]
        }
        
        # Get user's OneDrive drive
        try {
            $drive = Get-MgUserDrive -UserId $user.Id -ErrorAction Stop
        } catch {
            if ($_.Exception.Message -match "mysite not found|ResourceNotFound") {
                Write-Host "   ⚠️  OneDrive site not yet provisioned" -ForegroundColor Yellow
                Write-Host "      This user needs to access OneDrive once to create their personal site" -ForegroundColor Gray
                Write-Host "      Action: Have user sign in to https://office.com and click OneDrive" -ForegroundColor Cyan
                continue
            } else {
                throw
            }
        }
        
        if (-not $drive) {
            Write-Host "   ❌ OneDrive not available for this user" -ForegroundColor Red
            continue
        }
        
        # Create folder structure: DLP Testing/[Department]
        $folderPath = "DLP Testing/$department"
        Write-Host "   📁 Creating folder: $folderPath" -ForegroundColor Cyan
        
        try {
            # Create "DLP Testing" parent folder first
            $parentFolderBody = @{
                name = "DLP Testing"
                folder = @{}
                "@microsoft.graph.conflictBehavior" = "replace"
            }
            
            # Retry logic for newly provisioned OneDrive (may need a moment to be fully ready)
            $maxRetries = 3
            $retryDelay = 5
            $parentFolderCreated = $false
            
            for ($i = 1; $i -le $maxRetries; $i++) {
                try {
                    $parentFolder = Invoke-MgGraphRequest -Method POST `
                        -Uri "https://graph.microsoft.com/v1.0/users/$($user.Id)/drive/root/children" `
                        -Body ($parentFolderBody | ConvertTo-Json) `
                        -ErrorAction Stop
                    
                    $parentFolderCreated = $true
                    break
                } catch {
                    if ($_.Exception.Message -match "NotFound" -and $i -lt $maxRetries) {
                        Write-Host "      ⏳ OneDrive not fully ready, waiting $retryDelay seconds... (attempt $i/$maxRetries)" -ForegroundColor Yellow
                        Start-Sleep -Seconds $retryDelay
                    } elseif ($_.Exception.Message -match "already exists") {
                        $parentFolderCreated = $true
                        break
                    } else {
                        throw
                    }
                }
            }
            
            if (-not $parentFolderCreated) {
                Write-Host "      ❌ Failed to create parent folder after $maxRetries attempts" -ForegroundColor Red
                Write-Host "      OneDrive may need more time to fully provision. Wait 2-3 minutes and re-run." -ForegroundColor Yellow
                continue
            }
            
            # Create department subfolder
            $subFolderBody = @{
                name = $department
                folder = @{}
                "@microsoft.graph.conflictBehavior" = "replace"
            }
            
            $departmentFolder = Invoke-MgGraphRequest -Method POST `
                -Uri "https://graph.microsoft.com/v1.0/users/$($user.Id)/drive/root:/DLP Testing:/children" `
                -Body ($subFolderBody | ConvertTo-Json) `
                -ErrorAction Stop
            
            Write-Host "      ✅ Folder created" -ForegroundColor Green
        } catch {
            if ($_.Exception.Message -match "already exists") {
                Write-Host "      ✅ Folder already exists" -ForegroundColor Green
            } else {
                Write-Host "      ❌ Failed to create folder: $($_.Exception.Message)" -ForegroundColor Red
                continue
            }
        }
        
        # Upload each file
        $userUploadCount = 0
        foreach ($fileName in $filesToUpload) {
            $sourceFile = Join-Path $dataTemplatesPath $fileName
            
            if (-not (Test-Path $sourceFile)) {
                Write-Host "      ⚠️  File not found: $fileName (skipping)" -ForegroundColor Yellow
                $uploadStats.SkippedFiles++
                continue
            }
            
            try {
                # Read file content
                $fileBytes = [System.IO.File]::ReadAllBytes($sourceFile)
                $fileSize = (Get-Item $sourceFile).Length
                
                # For files under 4MB, use simple upload
                if ($fileSize -lt 4MB) {
                    $uploadUri = "https://graph.microsoft.com/v1.0/users/$($user.Id)/drive/root:/DLP Testing/$department/$($fileName):/content"
                    
                    Invoke-MgGraphRequest -Method PUT `
                        -Uri $uploadUri `
                        -Body $fileBytes `
                        -ContentType "application/octet-stream" `
                        -ErrorAction Stop | Out-Null
                    
                    Write-Host "      ✅ $fileName" -ForegroundColor Green
                    $userUploadCount++
                    $uploadStats.SuccessfulUploads++
                } else {
                    Write-Host "      ⚠️  $fileName is too large for simple upload (use upload session for files > 4MB)" -ForegroundColor Yellow
                    $uploadStats.SkippedFiles++
                }
            } catch {
                $errorMsg = $_.Exception.Message
                Write-Host "      ❌ Failed to upload ${fileName}: $errorMsg" -ForegroundColor Red
                $uploadStats.FailedUploads++
            }
        }
        
        Write-Host "   📊 Uploaded $userUploadCount files to $upn" -ForegroundColor Cyan
        $uploadStats.UsersProcessed++
        $uploadStats.TotalFiles += $userUploadCount
        Write-Host ""
        
    } catch {
        Write-Host "   ❌ Failed to process user: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        continue
    }
}

# =============================================================================
# Step 5: Display Upload Summary
# =============================================================================

Write-Host "📊 OneDrive Upload Summary" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green
Write-Host "   Users Processed:    $($uploadStats.UsersProcessed)" -ForegroundColor Cyan
Write-Host "   ✅ Uploaded:        $($uploadStats.SuccessfulUploads)" -ForegroundColor Green
Write-Host "   ⚠️  Skipped:         $($uploadStats.SkippedFiles)" -ForegroundColor Yellow
Write-Host "   ❌ Failed:          $($uploadStats.FailedUploads)" -ForegroundColor Red
Write-Host ""

if ($uploadStats.SuccessfulUploads -gt 0) {
    Write-Host "✅ OneDrive upload completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Verify files in user OneDrive accounts at office.com" -ForegroundColor Gray
    Write-Host "   2. Wait 24-48 hours for Content Explorer classification" -ForegroundColor Gray
    Write-Host "   3. Run Test-M365Users.ps1 to validate OneDrive provisioning" -ForegroundColor Gray
    Write-Host "   4. Proceed to create Teams environment with New-TeamsEnvironment.ps1" -ForegroundColor Gray
} else {
    Write-Host "⚠️  No files were uploaded successfully" -ForegroundColor Yellow
    Write-Host ""
    
    if ($uploadStats.UsersProcessed -eq 0) {
        Write-Host "🔧 OneDrive Site Provisioning Required:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   The test users' OneDrive sites haven't been provisioned yet." -ForegroundColor Gray
        Write-Host "   OneDrive sites are created when a user accesses OneDrive for the first time." -ForegroundColor Gray
        Write-Host ""
        Write-Host "   📋 Provision OneDrive for each user:" -ForegroundColor Yellow
        Write-Host ""
        foreach ($upn in $config.testUsers) {
            Write-Host "   • Sign in to https://office.com as $upn" -ForegroundColor Cyan
            Write-Host "     → Click the OneDrive app launcher icon" -ForegroundColor Gray
            Write-Host "     → Wait for OneDrive to initialize (takes 30-60 seconds)" -ForegroundColor Gray
            Write-Host ""
        }
        Write-Host "   After all users have accessed OneDrive, re-run this script:" -ForegroundColor Yellow
        Write-Host "   .\Upload-OneDriveTestData.ps1" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host "   Review errors above and ensure:" -ForegroundColor Gray
        Write-Host "   - Test files exist in data-templates/" -ForegroundColor Gray
        Write-Host "   - Users have OneDrive provisioned (sign in to office.com)" -ForegroundColor Gray
        Write-Host "   - Service principal has Files.ReadWrite.All permissions" -ForegroundColor Gray
    }
}

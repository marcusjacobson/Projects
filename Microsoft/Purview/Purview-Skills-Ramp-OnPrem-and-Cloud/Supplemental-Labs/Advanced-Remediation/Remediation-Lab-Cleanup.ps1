<#
.SYNOPSIS
    Complete cleanup script for Advanced OnPrem SIT Analysis lab environment.

.DESCRIPTION
    Removes all test data, CSV outputs, tombstone files, and SharePoint test files
    created during the Advanced OnPrem SIT Analysis lab. This script preserves VM
    configuration, scanner installation, Azure resources, and infrastructure while
    resetting the lab environment for re-execution.
    
    The script includes three main phases:
    - Part 1: On-premises file cleanup (VM)
    - Part 2: SharePoint test files cleanup (Admin Machine)
    - Part 3: Scanner reports cleanup (VM - OPTIONAL)

.EXAMPLE
    .\Remediation-Lab-Cleanup.ps1
    
    Runs the complete cleanup script interactively with prompts for each phase.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-09
    Last Modified: 2025-01-09
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+
    - Administrator or scanner service account privileges for VM cleanup
    - PnP.PowerShell module for SharePoint cleanup
    - Network access to VM (if running SharePoint cleanup remotely)
    
    Script development orchestrated using GitHub Copilot.

.CLEANUP PHASES
    Part 1 (VM): Test data files, tombstones, CSV outputs, Azure Files
    Part 2 (Admin): SharePoint test files via PnP PowerShell
    Part 3 (VM - Optional): Scanner historical reports
#>
#
# =============================================================================
# Advanced OnPrem SIT Analysis Lab - Complete cleanup and environment reset.
# =============================================================================

# ============================================================================
# PART 1: ON-PREMISES FILE CLEANUP (RUN ON VM)
# ============================================================================

Write-Host "`n========== ADVANCED REMEDIATION LAB CLEANUP ==========" -ForegroundColor Magenta
Write-Host "This script removes ALL test data and outputs from the remediation lab." -ForegroundColor Cyan
Write-Host "VM configuration, scanner installation, and Azure resources will be preserved.`n" -ForegroundColor Yellow

# Confirmation prompt
$confirm = Read-Host "⚠️  Proceed with cleanup? This will delete test files, CSV outputs, and tombstones. (yes/no)"

if ($confirm -ne 'yes') {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    return
}

Write-Host "`n🧹 Starting cleanup process...`n" -ForegroundColor Cyan

# Get computer name for UNC paths
$computerName = $env:COMPUTERNAME

# ============================================================================
# PHASE 1: REMOVE TEST DATA FILES
# ============================================================================

Write-Host "========== PHASE 1: TEST DATA FILES ==========" -ForegroundColor Green

$testDataPaths = @(
    "\\$computerName\Projects\RemediationTestData\Step1-SeverityBased",
    "\\$computerName\Projects\RemediationTestData\Step2-DualSource\OnPrem",
    "\\$computerName\Projects\RemediationTestData"
)

foreach ($path in $testDataPaths) {
    if (Test-Path $path) {
        try {
            $fileCount = (Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
            Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
            Write-Host "✅ Removed: $path ($fileCount files)" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to remove $path : $_"
        }
    } else {
        Write-Host "   ⏭️  Skipped: $path (doesn't exist)" -ForegroundColor Gray
    }
}

# ============================================================================
# PHASE 2: REMOVE TOMBSTONE FILES
# ============================================================================

Write-Host "`n========== PHASE 2: TOMBSTONE FILES ==========" -ForegroundColor Green

# Check both local and UNC paths for tombstones
$tombstonePaths = @(
    "C:\Projects",
    "\\$computerName\Projects"
)

$totalTombstonesRemoved = 0

foreach ($searchPath in $tombstonePaths) {
    if (Test-Path $searchPath) {
        try {
            $tombstones = Get-ChildItem -Path $searchPath -Filter "*.DELETED_*.txt" -Recurse -ErrorAction SilentlyContinue
            
            if ($tombstones.Count -gt 0) {
                foreach ($tombstone in $tombstones) {
                    Remove-Item -Path $tombstone.FullName -Force -ErrorAction SilentlyContinue
                }
                $totalTombstonesRemoved += $tombstones.Count
                Write-Host "   Found $($tombstones.Count) tombstone(s) in $searchPath" -ForegroundColor Gray
            }
        } catch {
            Write-Warning "Failed to search $searchPath : $_"
        }
    }
}

if ($totalTombstonesRemoved -gt 0) {
    Write-Host "✅ Removed $totalTombstonesRemoved tombstone files total" -ForegroundColor Green
} else {
    Write-Host "   ⏭️  No tombstone files found" -ForegroundColor Gray
}

# ============================================================================
# PHASE 3: REMOVE CSV OUTPUTS AND REPORTS
# ============================================================================

Write-Host "`n========== PHASE 3: CSV OUTPUTS & REPORTS ==========" -ForegroundColor Green

$outputPath = "C:\PurviewLab"

if (Test-Path $outputPath) {
    try {
        # Legacy Lab05 patterns (from older script versions)
        $legacyCsvFiles = Get-ChildItem -Path $outputPath -Filter "Lab05-*.csv" -ErrorAction SilentlyContinue
        $legacyTxtFiles = Get-ChildItem -Path $outputPath -Filter "Lab05-*.txt" -ErrorAction SilentlyContinue
        
        # Current output file patterns from Advanced-Remediation lab
        $currentCsvFiles = Get-ChildItem -Path $outputPath -Filter "*.csv" -ErrorAction SilentlyContinue | 
            Where-Object { $_.Name -match "^(RemediationPlan|Duplicates|SharePoint-Deletions|ActivityExplorer).*\.csv$" }
        
        $tempUpload = Join-Path $outputPath "Step3-SharePointUpload"
        
        $allFiles = @()
        if ($legacyCsvFiles) { $allFiles += $legacyCsvFiles }
        if ($legacyTxtFiles) { $allFiles += $legacyTxtFiles }
        if ($currentCsvFiles) { $allFiles += $currentCsvFiles }
        
        $totalFiles = $allFiles.Count
        
        # Remove all matched files
        foreach ($file in $allFiles) {
            Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
        }
        
        # Remove temp upload directory
        if (Test-Path $tempUpload) {
            Remove-Item -Path $tempUpload -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        Write-Host "✅ Removed $totalFiles CSV/report files from C:\PurviewLab\" -ForegroundColor Green
        Write-Host "   Note: C:\PurviewLab\ directory preserved for future lab runs" -ForegroundColor Gray
        
    } catch {
        Write-Warning "Failed to remove output files: $_"
    }
} else {
    Write-Host "   ⏭️  C:\PurviewLab\ directory doesn't exist" -ForegroundColor Gray
}

# ============================================================================
# PHASE 4: AZURE FILES CLEANUP (OPTIONAL)
# ============================================================================

Write-Host "`n========== PHASE 4: AZURE FILES CLEANUP ==========" -ForegroundColor Green

$cleanupAzureFiles = Read-Host "Remove Step 2 test files from Azure Files? (yes/no)"

if ($cleanupAzureFiles -eq 'yes') {
    Write-Host "`nHow to find your Azure Files URL:" -ForegroundColor Cyan
    Write-Host "   1. Go to Azure Portal → Storage Account → File shares" -ForegroundColor Gray
    Write-Host "   2. Select your file share → Click 'Properties'" -ForegroundColor Gray
    Write-Host "   3. Copy the URL (e.g., https://[storageaccount].file.core.windows.net/[sharename])`n" -ForegroundColor Gray
    
    $azureFilesUrl = Read-Host "Enter Azure Files URL"
    
    if (-not [string]::IsNullOrWhiteSpace($azureFilesUrl)) {
        # Convert HTTPS URL to UNC path
        # Example: https://stpurviewlab.file.core.windows.net/purview-files → \\stpurviewlab.file.core.windows.net\purview-files
        $cloudPath = $azureFilesUrl -replace '^https://', '\\' -replace '/', '\'
        
        # Append Step2-DualSource subdirectory
        $cloudPath = Join-Path $cloudPath "Step2-DualSource"
        
        Write-Host "   Converted to UNC path: $cloudPath" -ForegroundColor Gray
        
        if (Test-Path $cloudPath) {
            try {
                $cloudFileCount = (Get-ChildItem -Path $cloudPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
                Remove-Item -Path $cloudPath -Recurse -Force -ErrorAction Stop
                Write-Host "✅ Removed Azure Files test data: $cloudPath ($cloudFileCount files)" -ForegroundColor Green
            } catch {
                Write-Warning "Failed to remove Azure Files data: $_"
                Write-Host "   You may need to delete the 'Step2-DualSource' folder manually in Azure Portal" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   ⚠️  Azure Files path not accessible: $cloudPath" -ForegroundColor Yellow
            Write-Host "   Possible reasons:" -ForegroundColor Gray
            Write-Host "      - Azure Files not mounted with storage account key" -ForegroundColor Gray
            Write-Host "      - Network connectivity issues" -ForegroundColor Gray
            Write-Host "      - Path doesn't exist (Step 2 may not have been executed)" -ForegroundColor Gray
            Write-Host "   You can delete the 'Step2-DualSource' folder manually in Azure Portal" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⏭️  No Azure Files URL provided, skipping cleanup" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⏭️  Skipped Azure Files cleanup" -ForegroundColor Gray
}

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host "`n========== CLEANUP SUMMARY ==========" -ForegroundColor Magenta

$summary = @"

✅ REMOVED:
   - Test data files (Step 1, Step 2 on-prem)
   - Tombstone files (*.DELETED_*.txt)
   - CSV outputs (RemediationPlan.csv, Duplicates.csv, etc.)
   - Activity Explorer exports (ActivityExplorer*.csv)
   - SharePoint deletion logs (SharePoint-Deletions.csv)
   - Legacy Lab05-* files (from older script versions)
   - Temp upload directories

✅ PRESERVED:
   - VM configuration and settings
   - Purview scanner installation
   - Azure resources (storage accounts, Key Vault, etc.)
   - C:\PurviewLab\ directory structure
   - Scanner service and configuration
   - Network shares and permissions

⚠️  MANUAL CLEANUP REQUIRED:
   - SharePoint test files (see Part 2 below)
   - Scanner reports in: C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports\
     (Optional: Keep for troubleshooting or remove to start fresh)

🔄 TO RE-RUN LAB:
   1. Execute Step 0 to regenerate test data
   2. Run scanner to detect new files
   3. Execute Steps 1-5 in sequence

"@

Write-Host $summary -ForegroundColor Cyan
Write-Host "✅ On-premises cleanup complete!`n" -ForegroundColor Green

# ============================================================================
# PART 2: SHAREPOINT CLEANUP (RUN ON ADMIN MACHINE)
# ============================================================================

Write-Host "`n========== SHAREPOINT TEST FILES CLEANUP ==========" -ForegroundColor Magenta
Write-Host "Removes test files uploaded during Step 0 and Step 3...`n" -ForegroundColor Cyan

# Check for PnP.PowerShell module
if (-not (Get-Module -Name PnP.PowerShell -ListAvailable)) {
    Write-Warning "PnP.PowerShell module not installed. Install it first:"
    Write-Host "   Install-Module -Name PnP.PowerShell -Scope CurrentUser" -ForegroundColor Yellow
    return
}

# SharePoint connection parameters
$siteUrl = Read-Host "Enter SharePoint site URL (e.g., https://[tenant].sharepoint.com/sites/[YourTestSite])"
$libraryName = Read-Host "Enter document library name (default: 'Sensitive Data Archive')"
if ([string]::IsNullOrWhiteSpace($libraryName)) {
    $libraryName = "Sensitive Data Archive"
}

Write-Host "`nAuthentication method:" -ForegroundColor Cyan
Write-Host "   1. Interactive (browser-based authentication)" -ForegroundColor White
Write-Host "   2. Device Code (for VS Code/SSH/Cloud Shell)" -ForegroundColor White
Write-Host "   3. App Registration (Client ID + Certificate)" -ForegroundColor White
$authMethod = Read-Host "Select authentication method (1, 2, or 3)"

try {
    if ($authMethod -eq "3") {
        # App Registration authentication
        $clientId = Read-Host "Enter App Registration Client ID"
        $tenantId = Read-Host "Enter Tenant ID"
        $certThumbprint = Read-Host "Enter Certificate Thumbprint"
        
        Write-Host "`nConnecting to SharePoint with app registration..." -ForegroundColor Cyan
        Connect-PnPOnline -Url $siteUrl -ClientId $clientId -Tenant $tenantId -Thumbprint $certThumbprint -ErrorAction Stop
    } elseif ($authMethod -eq "2") {
        # Device code authentication (no browser spawning)
        $tenant = Read-Host "Enter your tenant name (e.g., 'contoso' from contoso.onmicrosoft.com)"
        
        Write-Host "`nConnecting to SharePoint with device code authentication..." -ForegroundColor Cyan
        Write-Host "   A code will be displayed below - open https://microsoft.com/devicelogin in a browser and paste the code." -ForegroundColor Gray
        Connect-PnPOnline -Url $siteUrl -DeviceLogin -Tenant $tenant -ErrorAction Stop
    } else {
        # Interactive browser authentication - requires ENTRAID_APP_ID environment variable
        Write-Host "`nSetting up interactive authentication..." -ForegroundColor Cyan
        
        # Check if environment variable already set
        if ([string]::IsNullOrWhiteSpace($env:ENTRAID_APP_ID)) {
            Write-Host "   Interactive authentication requires an Entra ID App Registration Client ID." -ForegroundColor Yellow
            Write-Host "   This is the same app used in Step 3 SharePoint deletion." -ForegroundColor Gray
            $appClientId = Read-Host "   Enter App Registration Client ID (GUID format)"
            
            # Validate Client ID format (GUID)
            if ($appClientId -notmatch '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
                Write-Host "   ❌ ERROR: Invalid Client ID format. Expected GUID format: 12345678-1234-1234-1234-123456789012" -ForegroundColor Red
                throw "Invalid Client ID format"
            }
            
            $env:ENTRAID_APP_ID = $appClientId
            Write-Host "   ✅ OK: Environment variable set: ENTRAID_APP_ID = $appClientId" -ForegroundColor Green
        } else {
            Write-Host "   Using existing ENTRAID_APP_ID: $env:ENTRAID_APP_ID" -ForegroundColor Green
        }
        
        Write-Host "`nConnecting to SharePoint with interactive authentication..." -ForegroundColor Cyan
        Write-Host "   Opening browser for authentication..." -ForegroundColor Gray
        Connect-PnPOnline -Url $siteUrl -Interactive -ErrorAction Stop
    }
    
    Write-Host "✅ Connected to SharePoint: $siteUrl" -ForegroundColor Green
    
    # Get all Step 0/Step 3 test files
    $testFileNames = @(
        "Old_SSN_Records_2019.txt",
        "Credit_Card_Database_2018.txt",
        "Confidential_HR_Data_2020.txt",
        "Recent_Project_Files_2024.txt"
    )
    
    $deletedCount = 0
    $notFoundCount = 0
    
    foreach ($fileName in $testFileNames) {
        try {
            # Find file in library
            $file = Get-PnPFile -Url "$libraryName/$fileName" -AsListItem -ErrorAction SilentlyContinue
            
            if ($file) {
                # Delete file (permanently, not recycle bin)
                Remove-PnPFile -SiteRelativeUrl "$libraryName/$fileName" -Force -ErrorAction Stop
                Write-Host "✅ Deleted: $fileName" -ForegroundColor Green
                $deletedCount++
            } else {
                Write-Host "   ⏭️  Not found: $fileName" -ForegroundColor Gray
                $notFoundCount++
            }
        } catch {
            Write-Warning "Failed to delete $fileName : $_"
        }
    }
    
    Write-Host "`n========== SHAREPOINT CLEANUP SUMMARY ==========" -ForegroundColor Cyan
    Write-Host "Files deleted: $deletedCount" -ForegroundColor Green
    Write-Host "Files not found: $notFoundCount" -ForegroundColor Gray
    Write-Host "`n✅ SharePoint cleanup complete!" -ForegroundColor Green
    
    Disconnect-PnPOnline
    
} catch {
    Write-Error "SharePoint cleanup failed: $_"
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Verify site URL is correct" -ForegroundColor White
    Write-Host "2. Ensure you have Site Collection Admin or Site Owner permissions" -ForegroundColor White
    Write-Host "3. Check document library name spelling" -ForegroundColor White
    Write-Host "4. For Interactive Auth: Verify ENTRAID_APP_ID environment variable is set correctly" -ForegroundColor White
    Write-Host "5. For Interactive Auth: Ensure 'Allow public client flows' is enabled in app settings" -ForegroundColor White
    Write-Host "6. For App Registration: Verify Client ID, Tenant ID, and Certificate Thumbprint" -ForegroundColor White
    Write-Host "7. For App Registration: Ensure app has Sites.FullControl.All permission" -ForegroundColor White
    Write-Host "8. Try Device Code authentication (Option 2) if Interactive fails" -ForegroundColor White
    Write-Host "9. Manual cleanup: Navigate to SharePoint site and delete files manually`n" -ForegroundColor White
}

# ============================================================================
# PART 3: SCANNER REPORTS CLEANUP (OPTIONAL - RUN ON VM)
# ============================================================================

Write-Host "`n========== SCANNER REPORTS CLEANUP (OPTIONAL) ==========" -ForegroundColor Magenta
Write-Host "Removes historical scanner reports to start completely fresh...`n" -ForegroundColor Cyan

$cleanupReports = Read-Host "⚠️  Remove scanner reports? This deletes scan history. (yes/no)"

if ($cleanupReports -eq 'yes') {
    $reportPath = "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"
    
    if (Test-Path $reportPath) {
        try {
            $reportFiles = Get-ChildItem -Path $reportPath -Filter "DetailedReport*.csv" -ErrorAction SilentlyContinue
            $reportCount = $reportFiles.Count
            
            foreach ($report in $reportFiles) {
                Remove-Item -Path $report.FullName -Force -ErrorAction SilentlyContinue
            }
            
            Write-Host "✅ Removed $reportCount scanner report files" -ForegroundColor Green
            Write-Host "   Next scanner run will create fresh reports`n" -ForegroundColor Cyan
            
        } catch {
            Write-Warning "Failed to remove scanner reports: $_"
            Write-Host "   You may need to run this script as scanner service account or Administrator`n" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⏭️  Scanner reports directory not found" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⏭️  Scanner reports preserved for reference`n" -ForegroundColor Gray
}

Write-Host "========== ALL CLEANUP TASKS COMPLETE ==========" -ForegroundColor Magenta
Write-Host "Lab environment reset and ready for re-execution!`n" -ForegroundColor Green

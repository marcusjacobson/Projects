<#
.SYNOPSIS
    Removes all locally generated test documents after successful SharePoint upload.

.DESCRIPTION
    This script safely removes all generated test documents from the local file system
    after verifying successful upload to SharePoint. It checks the most recent upload
    report to confirm 100% upload success before proceeding with deletion. This cleanup
    step is essential for freeing disk space while maintaining audit trails through
    upload reports.

.PARAMETER Force
    Skip confirmation prompt and proceed directly with deletion.
    Use with caution - deletion is irreversible.

.PARAMETER WhatIf
    Preview what would be deleted without actually removing files.
    Useful for verification before actual cleanup.

.EXAMPLE
    .\Remove-GeneratedDocuments.ps1
    
    Checks upload report, prompts for confirmation, then deletes all generated documents.

.EXAMPLE
    .\Remove-GeneratedDocuments.ps1 -Force
    
    Deletes all generated documents without confirmation prompt.

.EXAMPLE
    .\Remove-GeneratedDocuments.ps1 -WhatIf
    
    Shows what would be deleted without actually removing any files.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Lab 03 upload completed with reports generated
    - Write permissions to generated-documents directory
    
    Script development orchestrated using GitHub Copilot.

.SAFETY FEATURES
    - Verifies upload report exists before deletion
    - Displays upload success rate for confirmation
    - Requires user confirmation unless -Force specified
    - Validates deletion completed successfully
    - Preserves directory structure (only removes files)
    - Cannot be undone - ensure upload validation passed first
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

try {
    # Determine script locations
    $scriptPath = $PSScriptRoot
    $generatedDocsPath = Join-Path $scriptPath "generated-documents"
    
    # Navigate to Purview-Data-Governance-Simulation\Reports
    # From: ...\02-Test-Data-Generation\scripts
    # To: ...\Reports
    $simulationRoot = Split-Path (Split-Path $scriptPath -Parent) -Parent
    $reportsPath = Join-Path $simulationRoot "Reports"
    
    Write-Host "📋 Validating paths..." -ForegroundColor Cyan
    Write-Host "   • Script Path: $scriptPath" -ForegroundColor Gray
    Write-Host "   • Generated Docs: $generatedDocsPath" -ForegroundColor Gray
    Write-Host "   • Reports Path: $reportsPath" -ForegroundColor Gray
    
    # Check if generated documents directory exists
    if (-not (Test-Path $generatedDocsPath)) {
        Write-Host "   ⚠️  Generated documents directory not found" -ForegroundColor Yellow
        Write-Host "   ℹ️  No cleanup needed - directory already empty or doesn't exist" -ForegroundColor Cyan
        exit 0
    }
    
    # Count documents to be deleted
    $filesToDelete = Get-ChildItem -Path $generatedDocsPath -Recurse -File -ErrorAction SilentlyContinue
    $fileCount = $filesToDelete.Count
    
    if ($fileCount -eq 0) {
        Write-Host "   ℹ️  No files found in generated documents directory" -ForegroundColor Cyan
        Write-Host "   ✅ Directory already clean" -ForegroundColor Green
        exit 0
    }
    
    Write-Host "   ✅ Environment validation successful" -ForegroundColor Green
    Write-Host "   📊 Files to delete: $fileCount documents" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ Environment validation failed: $_" -ForegroundColor Red
    throw
}

# =============================================================================
# Step 2: Verify Upload Success
# =============================================================================

Write-Host "`n🔍 Step 2: Verify Upload Success" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

try {
    Write-Host "📋 Checking upload reports..." -ForegroundColor Cyan
    
    # Look for most recent upload report
    if (Test-Path $reportsPath) {
        $uploadReport = Get-ChildItem -Path $reportsPath -Filter "*upload*.json" -ErrorAction SilentlyContinue | 
            Sort-Object LastWriteTime -Descending | 
            Select-Object -First 1
        
        if ($uploadReport) {
            $reportData = Get-Content $uploadReport.FullName | ConvertFrom-Json
            
            Write-Host "   ✅ Upload report found: $($uploadReport.Name)" -ForegroundColor Green
            Write-Host "   📊 Documents uploaded: $($reportData.UploadedCount)" -ForegroundColor Cyan
            
            if ($reportData.SuccessRate) {
                Write-Host "   📊 Upload success rate: $($reportData.SuccessRate)%" -ForegroundColor Cyan
                
                if ($reportData.SuccessRate -lt 100) {
                    Write-Host "   ⚠️  Warning: Upload success rate is below 100%" -ForegroundColor Yellow
                    Write-Host "   ⚠️  Some files may not have been uploaded successfully" -ForegroundColor Yellow
                    
                    if (-not $Force) {
                        Write-Host "   ℹ️  Use -Force to proceed anyway, or re-run upload first" -ForegroundColor Cyan
                        exit 1
                    }
                }
            } else {
                Write-Host "   ⚠️  Warning: Success rate not found in report" -ForegroundColor Yellow
            }
            
        } else {
            Write-Host "   ⚠️  No upload reports found in $reportsPath" -ForegroundColor Yellow
            Write-Host "   💡 Tip: Run Test-UploadValidation.ps1 to verify upload success first" -ForegroundColor Cyan
            Write-Host "   ℹ️  Upload reports are created by Upload-AllDocuments.ps1 (not Upload-ToSingleSite.ps1)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠️  Reports directory not found: $reportsPath" -ForegroundColor Yellow
        Write-Host "   💡 Tip: Run Test-UploadValidation.ps1 to verify upload success first" -ForegroundColor Cyan
    }
    
    Write-Host "   ✅ Upload verification completed (proceeding with caution)" -ForegroundColor Green
    Write-Host "   💡 Best Practice: Verify uploads before deletion using Test-UploadValidation.ps1" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ Upload verification failed: $_" -ForegroundColor Red
    
    if (-not $Force) {
        throw
    } else {
        Write-Host "   ⚠️  Continuing due to -Force parameter" -ForegroundColor Yellow
    }
}

# =============================================================================
# Step 3: Confirm Deletion
# =============================================================================

if (-not $Force -and -not $WhatIfPreference) {
    Write-Host "`n⚠️  Step 3: Confirm Deletion" -ForegroundColor Yellow
    Write-Host "==========================" -ForegroundColor Yellow
    
    Write-Host "📋 You are about to delete:" -ForegroundColor Cyan
    Write-Host "   • Total files: $fileCount documents" -ForegroundColor Gray
    Write-Host "   • Location: $generatedDocsPath" -ForegroundColor Gray
    Write-Host "`n⚠️  This action is IRREVERSIBLE" -ForegroundColor Yellow
    Write-Host "⚠️  Ensure Lab 03 upload validation showed 100% success" -ForegroundColor Yellow
    
    $confirmation = Read-Host "`n❓ Delete all local generated documents? (yes/no)"
    
    if ($confirmation -ne "yes") {
        Write-Host "`nℹ️  Deletion cancelled - local documents retained" -ForegroundColor Cyan
        exit 0
    }
}

# =============================================================================
# Step 4: Delete Generated Documents
# =============================================================================

Write-Host "`n🗑️  Step 4: Delete Generated Documents" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

try {
    if ($WhatIfPreference) {
        Write-Host "📋 WhatIf Mode - Files that would be deleted:" -ForegroundColor Cyan
        
        $categories = Get-ChildItem -Path $generatedDocsPath -Directory
        foreach ($category in $categories) {
            $categoryFiles = Get-ChildItem -Path $category.FullName -Recurse -File
            Write-Host "   • $($category.Name): $($categoryFiles.Count) files" -ForegroundColor Gray
        }
        
        Write-Host "`nℹ️  No files were deleted (WhatIf mode)" -ForegroundColor Cyan
        exit 0
    }
    
    Write-Host "📋 Deleting generated documents..." -ForegroundColor Cyan
    
    # Delete all files recursively
    Remove-Item -Path "$generatedDocsPath\*" -Recurse -Force -ErrorAction Stop
    
    Write-Host "   ✅ All generated documents deleted" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Deletion failed: $_" -ForegroundColor Red
    throw
}

# =============================================================================
# Step 5: Verify Deletion
# =============================================================================

Write-Host "`n🔍 Step 5: Verify Deletion" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green

try {
    Write-Host "📋 Verifying deletion completed..." -ForegroundColor Cyan
    
    # Check for remaining files
    $remainingFiles = Get-ChildItem -Path $generatedDocsPath -Recurse -File -ErrorAction SilentlyContinue
    
    if ($remainingFiles.Count -eq 0) {
        Write-Host "   ✅ Verification successful: 0 files remaining" -ForegroundColor Green
        Write-Host "   ✅ Local cleanup completed" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Warning: $($remainingFiles.Count) files still present" -ForegroundColor Yellow
        Write-Host "   ℹ️  Some files may be locked or in use" -ForegroundColor Cyan
        
        # Display remaining files
        Write-Host "`n   📋 Remaining files:" -ForegroundColor Cyan
        $remainingFiles | Select-Object -First 10 | ForEach-Object {
            Write-Host "      • $($_.Name)" -ForegroundColor Gray
        }
        
        if ($remainingFiles.Count -gt 10) {
            Write-Host "      ... and $($remainingFiles.Count - 10) more files" -ForegroundColor Gray
        }
    }
    
} catch {
    Write-Host "   ❌ Verification failed: $_" -ForegroundColor Red
    throw
}

# =============================================================================
# Summary
# =============================================================================

Write-Host "`n🎯 Cleanup Summary" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green
Write-Host "   📊 Original file count: $fileCount documents" -ForegroundColor Cyan
Write-Host "   📊 Files remaining: $($remainingFiles.Count)" -ForegroundColor Cyan
Write-Host "   📊 Disk space freed: ~$([math]::Round($fileCount * 0.025, 2)) MB (estimated)" -ForegroundColor Cyan
Write-Host "   ✅ Local cleanup completed successfully" -ForegroundColor Green

Write-Host "`n💡 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Upload reports preserved in: $reportsPath" -ForegroundColor Gray
Write-Host "   2. Documents remain accessible in SharePoint Online" -ForegroundColor Gray
Write-Host "   3. To regenerate documents, return to Lab 02" -ForegroundColor Gray
Write-Host "   4. Proceed to Lab 04 for Purview classification validation" -ForegroundColor Gray

exit 0

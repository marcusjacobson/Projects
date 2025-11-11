<#
.SYNOPSIS
    Verifies sample test data files were created successfully with correct content and timestamps.

.DESCRIPTION
    This script validates that all three sample test data files were created properly:
    - Checks file existence
    - Verifies files contain expected sensitive information type patterns
    - Validates Phoenix Project file has old timestamp (3+ years)
    - Provides summary report of validation results
    
    This verification ensures the test environment is ready for Purview scanner deployment.

.EXAMPLE
    .\Verify-SampleTestData.ps1
    
    Validates all sample test data files and displays a summary report.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1+ or PowerShell 7+
    - Sample test data files created by Create-SampleTestData.ps1
    - C:\PurviewScanner directory with Finance, HR, and Projects subfolders
    
    Validation Checks:
    - Finance file contains credit card number patterns
    - HR file contains Social Security Number patterns
    - Projects file has timestamp older than 3 years
    - Azure Files Z: drive accessible with sample data
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Verify sample test data files contain detectable sensitive information types
# =============================================================================

Write-Host "`n📊 Validating sample files contain detectable SITs:" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# =============================================================================
# Step 1: Validate Finance File (Credit Cards)
# =============================================================================

Write-Host "`n🔍 Step 1: Checking Finance File" -ForegroundColor Green

# Check Finance file for credit cards
if (Test-Path "C:\PurviewScanner\Finance\CustomerPayments.txt") {
    $financeContent = Get-Content "C:\PurviewScanner\Finance\CustomerPayments.txt" -Raw
    if ($financeContent -match '\d{4}-\d{4}-\d{4}-\d{4}') {
        Write-Host "  ✅ Finance file contains credit card patterns" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Finance file missing credit card patterns" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ Finance file not found" -ForegroundColor Red
}

# =============================================================================
# Step 2: Validate HR File (Social Security Numbers)
# =============================================================================

Write-Host "`n🔍 Step 2: Checking HR File" -ForegroundColor Green

# Check HR file for SSNs
if (Test-Path "C:\PurviewScanner\HR\EmployeeRecords.txt") {
    $hrContent = Get-Content "C:\PurviewScanner\HR\EmployeeRecords.txt" -Raw
    if ($hrContent -match '\d{3}-\d{2}-\d{4}') {
        Write-Host "  ✅ HR file contains SSN patterns" -ForegroundColor Green
    } else {
        Write-Host "  ❌ HR file missing SSN patterns" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ HR file not found" -ForegroundColor Red
}

# =============================================================================
# Step 3: Validate Projects File (Old Timestamp)
# =============================================================================

Write-Host "`n🔍 Step 3: Checking Projects File Timestamp" -ForegroundColor Green

# Check Projects file age
if (Test-Path "C:\PurviewScanner\Projects\PhoenixProject.txt") {
    $projectFile = Get-Item "C:\PurviewScanner\Projects\PhoenixProject.txt"
    $ageYears = ((Get-Date) - $projectFile.LastAccessTime).TotalDays / 365
    if ($ageYears -gt 3) {
        Write-Host "  ✅ Phoenix project file is $([math]::Round($ageYears, 1)) years old" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Phoenix project file is only $([math]::Round($ageYears, 1)) years old (should be 3+)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ❌ Phoenix project file not found" -ForegroundColor Red
}

# =============================================================================
# Step 4: Check Azure Files Share (Optional)
# =============================================================================

Write-Host "`n🔍 Step 4: Checking Azure Files Share" -ForegroundColor Green

# Check Azure Files
if (Test-Path "Z:\CloudMigration.txt") {
    Write-Host "  ✅ Azure Files share accessible with sample data" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Azure Files not mounted or CloudMigration.txt not found" -ForegroundColor Yellow
    Write-Host "     This is OK if you haven't completed Azure Files setup yet" -ForegroundColor Gray
}

# =============================================================================
# Step 5: Validation Summary
# =============================================================================

Write-Host "`n✅ Environment validation complete!`n" -ForegroundColor Cyan

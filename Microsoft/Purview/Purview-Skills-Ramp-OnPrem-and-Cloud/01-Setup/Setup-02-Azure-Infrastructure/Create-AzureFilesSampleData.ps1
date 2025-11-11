<#
.SYNOPSIS
    Creates sample data on Azure Files share for cloud storage scanning scenarios.

.DESCRIPTION
    This script creates a CloudMigration.txt file on the mounted Azure Files share
    (typically Z: drive). This file simulates data stored on cloud storage (Azure Files,
    Nasuni, or other cloud-connected file services) that is accessible via SMB protocol
    from the on-premises scanner.
    
    The file contains cloud migration project information including Azure resource
    details and contact information.

.EXAMPLE
    .\Create-AzureFilesSampleData.ps1
    
    Creates CloudMigration.txt on the Z: drive (Azure Files share).

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1+ or PowerShell 7+
    - Azure Files share mounted as Z: drive
    - Network connectivity to Azure storage account
    
    Prerequisites:
    - Azure Files share created in storage account
    - Connection script from Azure Portal executed
    - Share successfully mounted (verify with Get-PSDrive)
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Create sample data on Azure Files share for cloud storage scanning
# =============================================================================

# =============================================================================
# Step 1: Verify Azure Files Mount
# =============================================================================

Write-Host "🔍 Step 1: Verifying Azure Files Share Mount" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

if (Test-Path "Z:\") {
    Write-Host "   ✅ Z: drive accessible (Azure Files share mounted)" -ForegroundColor Green
} else {
    Write-Host "   ❌ Z: drive not found - Azure Files share not mounted" -ForegroundColor Red
    Write-Host "   Please mount the Azure Files share first using the connection script" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 2: Create Cloud Migration Sample Data
# =============================================================================

Write-Host "`n📋 Step 2: Creating Cloud Migration Sample Data" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

$cloudContent = @"
ACME CORPORATION - CLOUD MIGRATION PROJECT
Cloud Infrastructure Team
Classification: Internal Use Only
Last Modified: $(Get-Date -Format 'yyyy-MM-dd')

MIGRATION PROJECT STATUS

Project Name: Cloud Migration Initiative 2024
Status: Phase 2 - In Progress
Lead: Cloud Operations Team

MIGRATION PHASES:
Phase 1: Assessment & Planning - COMPLETE (2024-Q1)
Phase 2: Pilot Migration - IN PROGRESS (2024-Q3)
Phase 3: Full Production Migration - PENDING (2025-Q1)

AZURE RESOURCE INFORMATION:
Subscription ID: 12345678-1234-1234-1234-123456789abc
Resource Group: rg-prod-migration
Location: East US
Storage Account: stprodmigration001

CONTACT INFORMATION:
Project Manager: cloudops@acme.com
Technical Lead: infrastructure@acme.com
Security Contact: security@acme.com

NOTES:
This file simulates data stored on cloud storage (Azure Files, Nasuni, etc.)
accessible via SMB protocol from on-premises scanner.
"@

try {
    # Write to Azure Files share
    $cloudContent | Out-File -FilePath "Z:\CloudMigration.txt" -Encoding UTF8 -ErrorAction Stop
    
    Write-Host "   ✅ Azure Files share mounted and sample data created" -ForegroundColor Green
    Write-Host "      Drive: Z:\" -ForegroundColor Yellow
    Write-Host "      File: Z:\CloudMigration.txt" -ForegroundColor Yellow
    
} catch {
    Write-Host "   ❌ Failed to create file on Azure Files share: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Verify File Creation
# =============================================================================

Write-Host "`n🔍 Step 3: Verifying File Creation" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

Write-Host "`nFiles on Z: drive:" -ForegroundColor Cyan
Get-ChildItem Z:\ | Format-Table Name, Length, LastWriteTime -AutoSize

Write-Host "`n💡 Verification Tip: You can also verify this file in the Azure Portal:" -ForegroundColor Cyan
Write-Host "   1. Go to portal.azure.com" -ForegroundColor Gray
Write-Host "   2. Navigate to your storage account" -ForegroundColor Gray
Write-Host "   3. Click File shares > purview-files" -ForegroundColor Gray
Write-Host "   4. Verify CloudMigration.txt appears in the file list" -ForegroundColor Gray

Write-Host "`n✅ Azure Files sample data creation complete" -ForegroundColor Green

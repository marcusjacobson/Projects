<#
.SYNOPSIS
    Verifies cleanup of Fabric-Purview Governance Simulation lab resources.

.DESCRIPTION
    This script provides guidance for verifying that all lab resources have been
    properly removed from Microsoft Fabric and Microsoft Purview. It checks for
    Azure CLI availability and provides manual verification steps for both platforms.

.EXAMPLE
    .\Test-Cleanup.ps1
    
    Runs the cleanup verification script with default checks.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-22
    
    Script development orchestrated using GitHub Copilot.
    
    Requirements:
    - Azure CLI (optional, for enhanced verification)
    - Access to Microsoft Fabric portal
    - Access to Microsoft Purview portal
    
    This script is informational and does not perform any destructive operations.

.LINK
    https://learn.microsoft.com/fabric/
    https://learn.microsoft.com/purview/
#>

[CmdletBinding()]
param()

# =============================================================================
# Step 1: Script Header
# =============================================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Fabric-Purview Lab Cleanup Verification" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script helps verify that lab resources have been removed." -ForegroundColor White
Write-Host ""

# =============================================================================
# Step 2: Check Azure CLI
# =============================================================================

Write-Host "[1/4] Checking Azure CLI availability..." -ForegroundColor Yellow

try {
    $azVersion = az --version 2>$null | Select-Object -First 1
    if ($azVersion) {
        Write-Host "   ✅ Azure CLI installed: $azVersion" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Azure CLI not detected (optional for this verification)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Azure CLI not found (optional for this verification)" -ForegroundColor Yellow
}

# =============================================================================
# Step 3: Fabric Workspace Verification
# =============================================================================

Write-Host ""
Write-Host "[2/4] Microsoft Fabric Workspace Verification" -ForegroundColor Yellow
Write-Host ""
Write-Host "   📋 Manual verification required:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   1. Open your browser and navigate to:" -ForegroundColor White
Write-Host "      https://app.fabric.microsoft.com" -ForegroundColor Blue
Write-Host ""
Write-Host "   2. Check that the following workspace is DELETED:" -ForegroundColor White
Write-Host "      • Fabric-Purview-Lab" -ForegroundColor Magenta
Write-Host ""
Write-Host "   3. Verify these items no longer exist:" -ForegroundColor White
Write-Host "      • CustomerDataLakehouse (Lakehouse)" -ForegroundColor White
Write-Host "      • AnalyticsWarehouse (Warehouse)" -ForegroundColor White
Write-Host "      • IoTEventhouse (Eventhouse)" -ForegroundColor White
Write-Host "      • DF_CustomerSegmentation (Dataflow)" -ForegroundColor White
Write-Host "      • Customer Analytics Report (Report)" -ForegroundColor White
Write-Host ""

# =============================================================================
# Step 4: Purview Catalog Verification
# =============================================================================

Write-Host "[3/4] Microsoft Purview Catalog Verification" -ForegroundColor Yellow
Write-Host ""
Write-Host "   📋 Manual verification required:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   1. Open your browser and navigate to:" -ForegroundColor White
Write-Host "      https://purview.microsoft.com" -ForegroundColor Blue
Write-Host ""
Write-Host "   2. Navigate to Data Catalog > Browse" -ForegroundColor White
Write-Host ""
Write-Host "   3. Search for these assets (should be removed after Live View sync):" -ForegroundColor White
Write-Host "      • CustomerDataLakehouse" -ForegroundColor Magenta
Write-Host "      • AnalyticsWarehouse" -ForegroundColor Magenta
Write-Host "      • IoTEventhouse" -ForegroundColor Magenta
Write-Host ""
Write-Host "   4. Verify manual classifications and annotations are removed (if desired)" -ForegroundColor White
Write-Host ""

# =============================================================================
# Step 5: Summary and Next Steps
# =============================================================================

Write-Host "[4/4] Cleanup Summary" -ForegroundColor Yellow
Write-Host ""
Write-Host "   ✅ Verification Checklist:" -ForegroundColor Green
Write-Host ""
Write-Host "   [ ] Fabric workspace 'Fabric-Purview-Lab' is deleted" -ForegroundColor White
Write-Host "   [ ] All workspace items (Lakehouse, Warehouse, etc.) removed" -ForegroundColor White
Write-Host "   [ ] Manual classifications removed (if desired)" -ForegroundColor White
Write-Host "   [ ] Purview catalog updated after Live View sync" -ForegroundColor White
Write-Host ""
Write-Host "   📂 Sample data files are preserved in:" -ForegroundColor Cyan
Write-Host "      data-templates/customers.csv" -ForegroundColor White
Write-Host "      data-templates/transactions.csv" -ForegroundColor White
Write-Host "      data-templates/streaming-events.json" -ForegroundColor White
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Verification Complete" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If all items are confirmed removed, your environment is clean." -ForegroundColor Green
Write-Host "You can re-run the labs by creating a new workspace." -ForegroundColor White
Write-Host ""

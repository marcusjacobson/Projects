<#
.SYNOPSIS
    Checks for existing DLP policies in the tenant before creating new ones.

.DESCRIPTION
    This validation script verifies whether DLP policies already exist in your Microsoft Purview
    tenant. It helps determine whether you should follow the "Alternative Path" (use existing policies)
    or "Standard Path" (create new policies) in OnPrem-03. This is useful when working with a
    recreated scanner environment where tenant-level policies persist but local scanner configuration
    needs updating.

.EXAMPLE
    .\Verify-ExistingDLPPolicy.ps1
    
    Checks tenant for existing DLP policies and displays their status.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 running as Administrator
    - Access to Microsoft Purview compliance portal
    - Appropriate permissions to view DLP policies
    - Web browser access to compliance.microsoft.com
    
    Script development orchestrated using GitHub Copilot.

.POLICY ARCHITECTURE
    - DLP policies are stored at tenant level (cloud-based)
    - Policies persist even when scanner VMs are recreated
    - Scanner needs local configuration to enforce tenant policies
    - This script helps identify which configuration path to follow
#>

[CmdletBinding()]
param()

# =============================================================================
# Validation: Check for Existing DLP Policies
# =============================================================================

Write-Host "`n🔍 Checking for Existing DLP Policies in Tenant" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

Write-Host "`n📋 Policy Architecture Overview:" -ForegroundColor Yellow
Write-Host "   • DLP policies stored at TENANT LEVEL (cloud)" -ForegroundColor Gray
Write-Host "   • Policies persist when scanner VM is recreated" -ForegroundColor Gray
Write-Host "   • Scanner needs local configuration to USE policies" -ForegroundColor Gray

Write-Host "`n🌐 Manual Verification Required:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

Write-Host "`n   This script will guide you through portal verification." -ForegroundColor Yellow
Write-Host "   DLP policies cannot be queried via PowerShell cmdlets directly." -ForegroundColor Gray

# Step 1: Open Purview portal
Write-Host "`n📋 Step 1: Navigate to Purview Portal" -ForegroundColor Cyan

Write-Host "`n   Opening Microsoft Purview compliance portal..." -ForegroundColor Gray
Start-Process "https://purview.microsoft.com"

Write-Host "   ✅ Browser launched" -ForegroundColor Green

# Step 2: Portal navigation instructions
Write-Host "`n📋 Step 2: Check DLP Policies" -ForegroundColor Cyan

Write-Host "`n   In the Purview portal:" -ForegroundColor Yellow
Write-Host "   1. Navigate to: Solutions > Data loss prevention > Policies" -ForegroundColor Gray
Write-Host "   2. Look for policy: 'Lab-OnPrem-Sensitive-Data-Protection'" -ForegroundColor Gray
Write-Host "   3. Check policy Status: 'On' or 'Test mode'" -ForegroundColor Gray
Write-Host "   4. Verify policy Location: 'On-premises repositories'" -ForegroundColor Gray

# Step 3: Expected policy details
Write-Host "`n📊 Expected Policy Details (if exists):" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

Write-Host "`n   Policy Name: Lab-OnPrem-Sensitive-Data-Protection" -ForegroundColor Gray
Write-Host "   Location: On-premises repositories" -ForegroundColor Gray
Write-Host "   Rules: Block-Credit-Card-Access, Audit-SSN-Access" -ForegroundColor Gray
Write-Host "   Status: On (or Test mode)" -ForegroundColor Gray

# User interaction - determine path
Write-Host "`n❓ User Decision Required:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

Write-Host "`n   After checking the portal, answer this question:" -ForegroundColor Cyan

$response = Read-Host "`n   Does the policy 'Lab-OnPrem-Sensitive-Data-Protection' exist? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    Write-Host "`n✅ Policy Found - Use Alternative Path" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    
    Write-Host "`n   Your DLP policies exist from previous setup." -ForegroundColor Yellow
    Write-Host "   The scanner needs local configuration to use them." -ForegroundColor Yellow
    
    Write-Host "`n⏭️  Next Steps (Alternative Path):" -ForegroundColor Cyan
    Write-Host "   1. Run Enable-ScannerDLP.ps1 to configure scanner" -ForegroundColor Gray
    Write-Host "   2. Run Sync-DLPPolicies.ps1 to download policies" -ForegroundColor Gray
    Write-Host "   3. Run Start-DLPScanWithReset.ps1 to test enforcement" -ForegroundColor Gray
    Write-Host "   4. Monitor with Monitor-DLPScan.ps1" -ForegroundColor Gray
    
    Write-Host "`n💡 TIP: Follow the 'Alternative Path' section in OnPrem-03 README" -ForegroundColor Cyan
    
} elseif ($response -eq 'N' -or $response -eq 'n') {
    Write-Host "`n❌ Policy Not Found - Use Standard Path" -ForegroundColor Yellow
    Write-Host "======================================" -ForegroundColor Yellow
    
    Write-Host "`n   You need to create new DLP policies." -ForegroundColor Yellow
    Write-Host "   Follow the portal-based policy creation workflow." -ForegroundColor Yellow
    
    Write-Host "`n⏭️  Next Steps (Standard Path):" -ForegroundColor Cyan
    Write-Host "   1. Follow 'Step-by-Step Instructions' in OnPrem-03 README" -ForegroundColor Gray
    Write-Host "   2. Create DLP policy in Purview portal (portal-based)" -ForegroundColor Gray
    Write-Host "   3. Configure DLP rules and conditions" -ForegroundColor Gray
    Write-Host "   4. Wait 1-2 hours for policy sync" -ForegroundColor Gray
    Write-Host "   5. Enable scanner DLP and run enforcement scan" -ForegroundColor Gray
    
    Write-Host "`n💡 TIP: Policy creation is done through the Purview portal UI" -ForegroundColor Cyan
    Write-Host "   This cannot be automated via PowerShell cmdlets" -ForegroundColor Gray
    
} else {
    Write-Host "`n⚠️  Invalid response. Please run the script again and answer Y or N." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n📚 Additional Resources:" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan
Write-Host "   • DLP policies: https://purview.microsoft.com" -ForegroundColor Gray
Write-Host "   • OnPrem-03 README: Full instructions for both paths" -ForegroundColor Gray

Write-Host "`n✅ Policy Verification Complete" -ForegroundColor Green

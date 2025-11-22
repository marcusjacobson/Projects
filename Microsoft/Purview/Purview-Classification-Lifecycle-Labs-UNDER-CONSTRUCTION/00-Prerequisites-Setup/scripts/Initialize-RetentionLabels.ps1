<#
.SYNOPSIS
    Creates initial retention labels for Purview Classification Labs.

.DESCRIPTION
    This script creates foundational retention labels to trigger the 7-day activation
    period for Lab 4 production deployment. By creating labels early, you enable flexible
    learning paths:
    - Fast completion (2-3 days): Work in simulation mode, understand concepts
    - Production deployment (7+ days): See full label application in action
    
    Creates 3 retention labels with auto-apply policies:
    1. Financial Records - 7 Years (auto-delete after 7 years)
    2. HR Documents - 5 Years (disposition review after 5 years)
    3. General Business - 3 Years (auto-delete after 3 years)
    
    Auto-apply policies link to placeholder SITs from Exercise 3 and start in
    simulation mode for 1-2 day preview period before optional production activation.

.PARAMETER EnableSimulationMode
    Creates auto-apply policies in simulation mode for preview (default: $true).
    After reviewing simulation results, policies can be manually activated for production.

.PARAMETER Verbose
    Show detailed progress during execution.

.EXAMPLE
    .\Initialize-RetentionLabels.ps1 -EnableSimulationMode -Verbose
    
    Creates 3 retention labels with auto-apply policies in simulation mode,
    triggering 1-2 day preview period and up to 7-day production activation timeline.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-13
    Last Modified: 2025-11-13
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - ExchangeOnlineManagement module v3.0+ installed
    - Security & Compliance PowerShell access
    - Compliance Administrator or Global Administrator role
    - Microsoft 365 E5 or E5 Compliance license
    - Placeholder SITs created (Exercise 3)
    
    Script development orchestrated using GitHub Copilot.

.RETENTION LABELS
    1. Financial Records - 7 Years
       - Retention: 7 years from creation date
       - Action: Delete automatically after 7 years
       - Auto-apply: When Contoso Customer Number detected
       - Scope: SharePoint, OneDrive, Exchange
    
    2. HR Documents - 5 Years
       - Retention: 5 years from labeled date
       - Action: Disposition review after 5 years
       - Auto-apply: When Contoso Employee ID detected
       - Scope: SharePoint, OneDrive
    
    3. General Business - 3 Years
       - Retention: 3 years from modification date
       - Action: Delete automatically after 3 years
       - Auto-apply: When Contoso Project Code detected
       - Scope: SharePoint, OneDrive, Exchange
#>

# =============================================================================
# Initial Retention Label Configuration for Purview Classification Labs
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$EnableSimulationMode
)

Write-Host "🏷️  Initial Retention Label Configuration" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Security & Compliance PowerShell Authentication
# =============================================================================

Write-Host "📋 Step 1: Security & Compliance Authentication" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

try {
    Write-Host "🔐 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
    Write-Host "   (Browser window will open for authentication)" -ForegroundColor Yellow
    
    # Connect to Security & Compliance PowerShell
    Connect-IPPSSession
    
    Write-Host "✅ Connected to Security & Compliance successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Security & Compliance authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Verify you have Compliance Administrator or Global Administrator role" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 2: Create Retention Labels
# =============================================================================

Write-Host "`n📋 Step 2: Creating Retention Labels" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

$createdLabels = @()

# Label 1: Financial Records - 7 Years
Write-Host "`n🔸 Creating: Financial Records - 7 Years" -ForegroundColor Cyan

try {
    # Check if label already exists
    $existingLabel = Get-ComplianceTag -Identity "Financial Records - 7 Years" -ErrorAction SilentlyContinue
    
    if ($existingLabel) {
        Write-Host "   ⚠️  'Financial Records - 7 Years' already exists - skipping" -ForegroundColor Yellow
    } else {
        # Create retention label (7 years = 2555 days)
        New-ComplianceTag -Name "Financial Records - 7 Years" `
            -Comment "Retention label for financial records with 7-year retention from creation date. Auto-applied when Contoso Customer Number detected." `
            -RetentionAction Delete `
            -RetentionDuration 2555 `
            -RetentionType CreationAgeInDays
        
        Write-Host "   ✅ Created: Financial Records - 7 Years" -ForegroundColor Green
        Write-Host "      Retention: 7 years from creation date" -ForegroundColor White
        Write-Host "      Action: Delete automatically after 7 years" -ForegroundColor White
        Write-Host "      Scope: SharePoint, OneDrive, Exchange" -ForegroundColor White
        
        $createdLabels += "Financial Records - 7 Years"
    }
} catch {
    Write-Host "   ❌ Failed to create 'Financial Records - 7 Years': $($_.Exception.Message)" -ForegroundColor Red
}

# Label 2: HR Documents - 5 Years
Write-Host "`n🔸 Creating: HR Documents - 5 Years" -ForegroundColor Cyan

try {
    # Check if label already exists
    $existingLabel = Get-ComplianceTag -Identity "HR Documents - 5 Years" -ErrorAction SilentlyContinue
    
    if ($existingLabel) {
        Write-Host "   ⚠️  'HR Documents - 5 Years' already exists - skipping" -ForegroundColor Yellow
    } else {
        # Create retention label (5 years = 1825 days)
        # Note: ReviewerEmail removed - set via portal UI if disposition review needed
        New-ComplianceTag -Name "HR Documents - 5 Years" `
            -Comment "Retention label for HR documents with 5-year retention from labeled date. Disposition review required. Auto-applied when Contoso Employee ID detected." `
            -RetentionAction KeepAndDelete `
            -RetentionDuration 1825 `
            -RetentionType TaggedAgeInDays
        
        Write-Host "   ✅ Created: HR Documents - 5 Years" -ForegroundColor Green
        Write-Host "      Retention: 5 years from labeled date" -ForegroundColor White
        Write-Host "      Action: Disposition review after 5 years" -ForegroundColor White
        Write-Host "      Scope: SharePoint, OneDrive" -ForegroundColor White
        
        $createdLabels += "HR Documents - 5 Years"
    }
} catch {
    Write-Host "   ❌ Failed to create 'HR Documents - 5 Years': $($_.Exception.Message)" -ForegroundColor Red
}

# Label 3: General Business - 3 Years
Write-Host "`n🔸 Creating: General Business - 3 Years" -ForegroundColor Cyan

try {
    # Check if label already exists
    $existingLabel = Get-ComplianceTag -Identity "General Business - 3 Years" -ErrorAction SilentlyContinue
    
    if ($existingLabel) {
        Write-Host "   ⚠️  'General Business - 3 Years' already exists - skipping" -ForegroundColor Yellow
    } else {
        # Create retention label (3 years = 1095 days)
        New-ComplianceTag -Name "General Business - 3 Years" `
            -Comment "Retention label for general business documents with 3-year retention from modification date. Auto-applied when Contoso Project Code detected." `
            -RetentionAction Delete `
            -RetentionDuration 1095 `
            -RetentionType ModificationAgeInDays
        
        Write-Host "   ✅ Created: General Business - 3 Years" -ForegroundColor Green
        Write-Host "      Retention: 3 years from modification date" -ForegroundColor White
        Write-Host "      Action: Delete automatically after 3 years" -ForegroundColor White
        Write-Host "      Scope: SharePoint, OneDrive, Exchange" -ForegroundColor White
        
        $createdLabels += "General Business - 3 Years"
    }
} catch {
    Write-Host "   ❌ Failed to create 'General Business - 3 Years': $($_.Exception.Message)" -ForegroundColor Red
}

# =============================================================================
# Step 3: Create Auto-Apply Policies
# =============================================================================

Write-Host "`n📋 Step 3: Creating Auto-Apply Policies" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

if ($EnableSimulationMode) {
    Write-Host "⚙️  Auto-apply policies will be created in SIMULATION mode" -ForegroundColor Cyan
    Write-Host "   Simulation provides 1-2 day preview before production activation" -ForegroundColor White
} else {
    Write-Host "⚙️  Auto-apply policies will be created in PRODUCTION mode" -ForegroundColor Yellow
    Write-Host "   Production activation takes up to 7 days for full deployment" -ForegroundColor White
}

$createdPolicies = @()

# Policy 1: Auto-Apply Financial Records
Write-Host "`n🔸 Creating: Auto-Apply Financial Records" -ForegroundColor Cyan

try {
    # Check if policy already exists
    $existingPolicy = Get-RetentionCompliancePolicy -Identity "Auto-Apply Financial Records" -DistributionDetail -ErrorAction SilentlyContinue
    
    if ($existingPolicy) {
        Write-Host "   ⚠️  'Auto-Apply Financial Records' policy already exists - skipping" -ForegroundColor Yellow
    } else {
        # Create auto-apply policy
        # Note: Policies are created in disabled state, then enabled after rule creation
        New-RetentionCompliancePolicy -Name "Auto-Apply Financial Records" `
            -Comment "Auto-apply policy for Financial Records label when Contoso Customer Number detected. Enable simulation mode in portal before activating." `
            -ExchangeLocation All `
            -SharePointLocation All `
            -OneDriveLocation All | Out-Null
        
        # Create retention rule with SIT condition
        New-RetentionComplianceRule -Policy "Auto-Apply Financial Records" `
            -Name "Auto-Apply Financial Records Rule" `
            -Comment "Apply Financial Records label when Contoso Customer Number detected" `
            -RetentionComplianceAction Keep `
            -ContentMatchQuery "SensitiveType:`"Contoso Customer Number`"" `
            -ApplyComplianceTag "Financial Records - 7 Years"
        
        # Enable the policy after rule creation
        Set-RetentionCompliancePolicy -Identity "Auto-Apply Financial Records" -Enabled $true
        
        Write-Host "   ✅ Created: Auto-Apply Financial Records" -ForegroundColor Green
        Write-Host "      Trigger: Contoso Customer Number SIT detected" -ForegroundColor White
        Write-Host "      ⚠️  Enable simulation mode via Purview portal before activating" -ForegroundColor Yellow
        Write-Host "      Production: Up to 7 days for full deployment" -ForegroundColor White
        
        $createdPolicies += "Auto-Apply Financial Records"
    }
} catch {
    Write-Host "   ❌ Failed to create policy: $($_.Exception.Message)" -ForegroundColor Red
}

# Policy 2: Auto-Apply HR Documents
Write-Host "`n🔸 Creating: Auto-Apply HR Documents" -ForegroundColor Cyan

try {
    # Check if policy already exists
    $existingPolicy = Get-RetentionCompliancePolicy -Identity "Auto-Apply HR Documents" -DistributionDetail -ErrorAction SilentlyContinue
    
    if ($existingPolicy) {
        Write-Host "   ⚠️  'Auto-Apply HR Documents' policy already exists - skipping" -ForegroundColor Yellow
    } else {
        # Create auto-apply policy
        # Note: Policies are created in disabled state, then enabled after rule creation
        New-RetentionCompliancePolicy -Name "Auto-Apply HR Documents" `
            -Comment "Auto-apply policy for HR Documents label when Contoso Employee ID detected. Enable simulation mode in portal before activating." `
            -SharePointLocation All `
            -OneDriveLocation All | Out-Null
        
        # Create retention rule with SIT condition
        New-RetentionComplianceRule -Policy "Auto-Apply HR Documents" `
            -Name "Auto-Apply HR Documents Rule" `
            -Comment "Apply HR Documents label when Contoso Employee ID detected" `
            -RetentionComplianceAction Keep `
            -ContentMatchQuery "SensitiveType:`"Contoso Employee ID`"" `
            -ApplyComplianceTag "HR Documents - 5 Years"
        
        # Enable the policy after rule creation
        Set-RetentionCompliancePolicy -Identity "Auto-Apply HR Documents" -Enabled $true
        
        Write-Host "   ✅ Created: Auto-Apply HR Documents" -ForegroundColor Green
        Write-Host "      Trigger: Contoso Employee ID SIT detected" -ForegroundColor White
        Write-Host "      ⚠️  Enable simulation mode via Purview portal before activating" -ForegroundColor Yellow
        Write-Host "      Production: Up to 7 days for full deployment" -ForegroundColor White
        
        $createdPolicies += "Auto-Apply HR Documents"
    }
} catch {
    Write-Host "   ❌ Failed to create policy: $($_.Exception.Message)" -ForegroundColor Red
}

# Policy 3: Auto-Apply General Business
Write-Host "`n🔸 Creating: Auto-Apply General Business" -ForegroundColor Cyan

try {
    # Check if policy already exists
    $existingPolicy = Get-RetentionCompliancePolicy -Identity "Auto-Apply General Business" -DistributionDetail -ErrorAction SilentlyContinue
    
    if ($existingPolicy) {
        Write-Host "   ⚠️  'Auto-Apply General Business' policy already exists - skipping" -ForegroundColor Yellow
    } else {
        # Create auto-apply policy
        # Note: Policies are created in disabled state, then enabled after rule creation
        New-RetentionCompliancePolicy -Name "Auto-Apply General Business" `
            -Comment "Auto-apply policy for General Business label when Contoso Project Code detected. Enable simulation mode in portal before activating." `
            -ExchangeLocation All `
            -SharePointLocation All `
            -OneDriveLocation All | Out-Null
        
        # Create retention rule with SIT condition
        New-RetentionComplianceRule -Policy "Auto-Apply General Business" `
            -Name "Auto-Apply General Business Rule" `
            -Comment "Apply General Business label when Contoso Project Code detected" `
            -RetentionComplianceAction Keep `
            -ContentMatchQuery "SensitiveType:`"Contoso Project Code`"" `
            -ApplyComplianceTag "General Business - 3 Years"
        
        # Enable the policy after rule creation
        Set-RetentionCompliancePolicy -Identity "Auto-Apply General Business" -Enabled $true
        
        Write-Host "   ✅ Created: Auto-Apply General Business" -ForegroundColor Green
        Write-Host "      Trigger: Contoso Project Code SIT detected" -ForegroundColor White
        Write-Host "      ⚠️  Enable simulation mode via Purview portal before activating" -ForegroundColor Yellow
        Write-Host "      Production: Up to 7 days for full deployment" -ForegroundColor White
        
        $createdPolicies += "Auto-Apply General Business"
    }
} catch {
    Write-Host "   ❌ Failed to create policy: $($_.Exception.Message)" -ForegroundColor Red
}

# =============================================================================
# Step 4: Validation and Summary
# =============================================================================

Write-Host "`n📋 Step 4: Validation and Summary" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# List all retention labels
Write-Host "`n🔍 Verifying retention labels..." -ForegroundColor Cyan

try {
    $allLabels = Get-ComplianceTag | Where-Object { $_.Name -like "*Years*" }
    
    if ($allLabels) {
        Write-Host "`n✅ Retention labels in Microsoft Purview:" -ForegroundColor Green
        foreach ($label in $allLabels) {
            Write-Host "   • $($label.Name) - $($label.RetentionDuration) days" -ForegroundColor White
        }
    }
} catch {
    Write-Host "⚠️  Could not verify labels: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Disconnect from Security & Compliance
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "`n🎉 Initial Retention Label Configuration Complete!" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""

if ($createdLabels.Count -gt 0) {
    Write-Host "✅ Successfully created $($createdLabels.Count) retention label(s):" -ForegroundColor Green
    foreach ($labelName in $createdLabels) {
        Write-Host "   • $labelName" -ForegroundColor White
    }
}

if ($createdPolicies.Count -gt 0) {
    Write-Host "`n✅ Successfully created $($createdPolicies.Count) auto-apply polic(ies):" -ForegroundColor Green
    foreach ($policyName in $createdPolicies) {
        Write-Host "   • $policyName" -ForegroundColor White
    }
}

Write-Host "`n⏱️  Background Processing Timeline:" -ForegroundColor Cyan

if ($EnableSimulationMode) {
    Write-Host "   1-2 days: Simulation mode results available for review" -ForegroundColor White
    Write-Host "   7 days: Full production label application (if activated)" -ForegroundColor White
} else {
    Write-Host "   7 days: Full production label application" -ForegroundColor White
}

Write-Host "`n💡 Lab 4 Flexibility:" -ForegroundColor Cyan
Write-Host "   - Fast completion (2-3 days): Work in simulation mode, understand concepts" -ForegroundColor White
Write-Host "   - Production deployment (7+ days): See full label application in action" -ForegroundColor White
Write-Host "   - Both paths provide complete learning experience!" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Next Step: Proceed immediately to Lab 1 - Custom SITs (Regex & Keywords)" -ForegroundColor Green
Write-Host "   No waiting required! Background processing continues while you learn." -ForegroundColor White
Write-Host ""
Write-Host "✅ Lab 0 Complete - Ready for Lab 1!" -ForegroundColor Green

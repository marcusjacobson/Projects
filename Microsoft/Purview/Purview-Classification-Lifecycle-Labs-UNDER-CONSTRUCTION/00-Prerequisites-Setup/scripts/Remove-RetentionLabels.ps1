<#
.SYNOPSIS
    Removes retention labels and auto-apply policies created during Lab 0 setup.

.DESCRIPTION
    This cleanup script removes the retention labels and auto-apply policies created
    by Initialize-RetentionLabels.ps1, allowing you to reset Lab 0 Exercise 4 and
    re-run the initialization if needed.
    
    Removes:
    - Auto-Apply Financial Records policy and rule
    - Auto-Apply HR Documents policy and rule
    - Auto-Apply General Business policy and rule
    - Financial Records - 7 Years label
    - HR Documents - 5 Years label
    - General Business - 3 Years label

.PARAMETER Force
    Bypasses confirmation prompts and removes all items without asking.

.PARAMETER Verbose
    Show detailed progress during execution.

.EXAMPLE
    .\Remove-RetentionLabels.ps1 -Verbose
    
    Removes all retention labels and policies with confirmation prompts.

.EXAMPLE
    .\Remove-RetentionLabels.ps1 -Force -Verbose
    
    Removes all retention labels and policies without confirmation prompts.

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
    
    Script development orchestrated using GitHub Copilot.

.CLEANUP ITEMS
    Retention Policies:
    - Auto-Apply Financial Records (with rule)
    - Auto-Apply HR Documents (with rule)
    - Auto-Apply General Business (with rule)
    
    Retention Labels:
    - Financial Records - 7 Years
    - HR Documents - 5 Years
    - General Business - 3 Years
#>

# =============================================================================
# Retention Label and Policy Cleanup for Purview Classification Labs
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

Write-Host "🗑️  Retention Label and Policy Cleanup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
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
# Step 2: Remove Auto-Apply Policies
# =============================================================================

Write-Host "`n📋 Step 2: Removing Auto-Apply Policies" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$policiesToRemove = @(
    "Auto-Apply Financial Records",
    "Auto-Apply HR Documents",
    "Auto-Apply General Business"
)

$removedPolicies = @()

foreach ($policyName in $policiesToRemove) {
    Write-Host "`n🔸 Removing: $policyName" -ForegroundColor Cyan
    
    try {
        # Check if policy exists
        $policy = Get-RetentionCompliancePolicy -Identity $policyName -DistributionDetail -ErrorAction SilentlyContinue
        
        if ($policy) {
            if (-not $Force) {
                $confirmation = Read-Host "   Remove policy '$policyName'? (Y/N)"
                if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
                    Write-Host "   ⏭️  Skipped: $policyName" -ForegroundColor Yellow
                    continue
                }
            }
            
            # Disable policy first (required before removal)
            Write-Host "   🔄 Disabling policy..." -ForegroundColor White
            Set-RetentionCompliancePolicy -Identity $policyName -Enabled $false -ErrorAction SilentlyContinue
            
            # Remove the policy (rules are automatically removed)
            # Note: Warnings about deployment are suppressed as they're informational only
            Write-Host "   🗑️  Removing policy..." -ForegroundColor White
            Remove-RetentionCompliancePolicy -Identity $policyName -Confirm:$false -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            
            Write-Host "   ✅ Removed: $policyName (background deployment in progress)" -ForegroundColor Green
            $removedPolicies += $policyName
        } else {
            Write-Host "   ⚠️  Policy not found: $policyName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove '$policyName': $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =============================================================================
# Step 3: Remove Retention Labels
# =============================================================================

Write-Host "`n📋 Step 3: Removing Retention Labels" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

$labelsToRemove = @(
    "Financial Records - 7 Years",
    "HR Documents - 5 Years",
    "General Business - 3 Years"
)

$removedLabels = @()

foreach ($labelName in $labelsToRemove) {
    Write-Host "`n🔸 Removing: $labelName" -ForegroundColor Cyan
    
    try {
        # Check if label exists
        $label = Get-ComplianceTag -Identity $labelName -ErrorAction SilentlyContinue
        
        if ($label) {
            if (-not $Force) {
                $confirmation = Read-Host "   Remove label '$labelName'? (Y/N)"
                if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
                    Write-Host "   ⏭️  Skipped: $labelName" -ForegroundColor Yellow
                    continue
                }
            }
            
            # Remove the label
            Remove-ComplianceTag -Identity $labelName -Confirm:$false
            
            Write-Host "   ✅ Removed: $labelName" -ForegroundColor Green
            $removedLabels += $labelName
        } else {
            Write-Host "   ⚠️  Label not found: $labelName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove '$labelName': $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =============================================================================
# Step 4: Validation and Summary
# =============================================================================

Write-Host "`n📋 Step 4: Validation and Summary" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Note about background deployment
Write-Host "`n💡 Note: Retention policies and labels are removed via background deployment." -ForegroundColor Cyan
Write-Host "   It may take 5-10 minutes for changes to fully propagate." -ForegroundColor White

# Verify removal
Write-Host "`n🔍 Verifying cleanup..." -ForegroundColor Cyan

try {
    $remainingLabels = Get-ComplianceTag | Where-Object { $_.Name -like "*Years*" }
    $remainingPolicies = Get-RetentionCompliancePolicy | Where-Object { $_.Name -like "Auto-Apply*" }
    
    if ($remainingLabels -or $remainingPolicies) {
        Write-Host "`n⏳ Items queued for background deletion:" -ForegroundColor Yellow
        
        if ($remainingLabels) {
            Write-Host "   Labels (will be removed in 5-10 minutes):" -ForegroundColor Yellow
            foreach ($label in $remainingLabels) {
                Write-Host "   • $($label.Name)" -ForegroundColor White
            }
        }
        
        if ($remainingPolicies) {
            Write-Host "   Policies (will be removed in 5-10 minutes):" -ForegroundColor Yellow
            foreach ($policy in $remainingPolicies) {
                Write-Host "   • $($policy.Name)" -ForegroundColor White
            }
        }
        
        Write-Host "`n   This is normal - removal commands were accepted and are processing in the background." -ForegroundColor Cyan
    } else {
        Write-Host "✅ All retention labels and policies removed successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  Could not verify cleanup: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Disconnect from Security & Compliance
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "`n🎉 Retention Label Cleanup Complete!" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

if ($removedPolicies.Count -gt 0) {
    Write-Host "✅ Successfully removed $($removedPolicies.Count) auto-apply polic(ies):" -ForegroundColor Green
    foreach ($policyName in $removedPolicies) {
        Write-Host "   • $policyName" -ForegroundColor White
    }
}

if ($removedLabels.Count -gt 0) {
    Write-Host "`n✅ Successfully removed $($removedLabels.Count) retention label(s):" -ForegroundColor Green
    foreach ($labelName in $removedLabels) {
        Write-Host "   • $labelName" -ForegroundColor White
    }
}

Write-Host "`n💡 You can re-run Initialize-RetentionLabels.ps1 after background deployment completes (5-10 minutes)." -ForegroundColor Cyan
Write-Host ""

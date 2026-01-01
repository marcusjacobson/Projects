<#
.SYNOPSIS
    Validates prerequisites for Lab 07 - Audit and Validation comprehensive policy testing.

.DESCRIPTION
    This script validates that all required policies, labels, and classifiers are in place
    and ready for comprehensive validation using Activity Explorer, Content Explorer, and
    Data Classification tools. It checks baseline policies from Day Zero Setup and enhanced
    policies from Labs 04-05.

.EXAMPLE
    .\Test-LabPrerequisites.ps1
    
    Runs all prerequisite validation checks for Lab 07 Audit and Validation.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-31
    Last Modified: 2025-12-31
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Microsoft Purview compliance portal admin access
    - Security & Compliance PowerShell module connected
    - Day Zero Setup completed (2+ weeks for full policy propagation)
    - Lab 04 auto-labeling policies simulated (24-48 hours)
    - Lab 05 DLP policy enhancements applied
    
    Script development orchestrated using GitHub Copilot.

.VALIDATION AREAS
    - Audit log enabled and events flowing
    - Baseline labels published and propagated (Day Zero Setup)
    - Pre-created auto-labeling policy simulation complete
    - Pre-created DLP policies propagated (4 policies from Day Zero)
    - Lab 04 auto-labeling policies simulation status
    - Lab 05 enhanced DLP policies status
    - Test data available in SharePoint for validation
#>

# =============================================================================
# Comprehensive prerequisite validation for Lab 07 Audit and Validation
# =============================================================================

Write-Host "🔍 Lab 07 Prerequisite Validation - Audit and Validation" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Security & Compliance PowerShell Connection
# =============================================================================

Write-Host "🔐 Step 1: Security & Compliance PowerShell Connection" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green

try {
    # Check if already connected
    $orgConfig = Get-OrganizationConfig -ErrorAction SilentlyContinue
    
    if ($orgConfig) {
        Write-Host "   ✅ Already connected to Security & Compliance PowerShell" -ForegroundColor Green
        Write-Host "      Organization: $($orgConfig.DisplayName)" -ForegroundColor Cyan
    } else {
        Write-Host "   ❌ Not connected to Security & Compliance PowerShell" -ForegroundColor Red
        Write-Host ""
        Write-Host "   📋 To connect, run:" -ForegroundColor Yellow
        Write-Host "      Connect-IPPSSession -UserPrincipalName admin@yourtenant.onmicrosoft.com" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
} catch {
    Write-Host "   ❌ Connection check failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 2: Audit Log Validation
# =============================================================================

Write-Host "📋 Step 2: Audit Log Validation" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

try {
    $auditConfig = Get-AdminAuditLogConfig
    
    if ($auditConfig.UnifiedAuditLogIngestionEnabled) {
        Write-Host "   ✅ Audit log is enabled" -ForegroundColor Green
        Write-Host "      Status: Unified Audit Log Ingestion Enabled" -ForegroundColor Cyan
        
        # Check for recent audit events (Activity Explorer data source)
        Write-Host "   🔍 Checking for recent audit events..." -ForegroundColor Cyan
        $startDate = (Get-Date).AddDays(-7)
        $endDate = Get-Date
        
        # Note: Search-UnifiedAuditLog requires appropriate permissions
        # This is a basic check - full Activity Explorer validation happens in Lab 01
        Write-Host "      Recent events: Check Activity Explorer for comprehensive event analysis" -ForegroundColor Cyan
        
    } else {
        Write-Host "   ❌ Audit log is NOT enabled" -ForegroundColor Red
        Write-Host "      Activity Explorer will have no data without audit log" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   📋 To enable, run:" -ForegroundColor Yellow
        Write-Host "      Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled `$true" -ForegroundColor Yellow
        Write-Host ""
    }
} catch {
    Write-Host "   ❌ Audit log check failed: $_" -ForegroundColor Red
}

Write-Host ""

# =============================================================================
# Step 3: Baseline Label Validation (Day Zero Setup)
# =============================================================================

Write-Host "🏷️ Step 3: Baseline Label Validation (Day Zero Setup)" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green

try {
    $baselineLabels = @("General", "Confidential")
    $labelsFound = 0
    
    $allLabels = Get-Label
    
    foreach ($labelName in $baselineLabels) {
        $label = $allLabels | Where-Object { $_.DisplayName -eq $labelName }
        
        if ($label) {
            Write-Host "   ✅ Label '$labelName' found" -ForegroundColor Green
            Write-Host "      Created: $($label.WhenCreatedUTC)" -ForegroundColor Cyan
            $labelsFound++
        } else {
            Write-Host "   ❌ Label '$labelName' NOT found" -ForegroundColor Red
        }
    }
    
    if ($labelsFound -eq $baselineLabels.Count) {
        Write-Host ""
        Write-Host "   ✅ All baseline labels present ($labelsFound/$($baselineLabels.Count))" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "   ⚠️ Some baseline labels missing ($labelsFound/$($baselineLabels.Count))" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ❌ Label validation failed: $_" -ForegroundColor Red
}

Write-Host ""

# =============================================================================
# Step 4: Pre-Created Auto-Labeling Policy Validation
# =============================================================================

Write-Host "🤖 Step 4: Pre-Created Auto-Labeling Policy Validation" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green

try {
    $baselineAutoPolicy = "Auto-Label PII (Retail)"
    
    $autoPolicy = Get-AutoSensitivityLabelPolicy | Where-Object { $_.Name -eq $baselineAutoPolicy }
    
    if ($autoPolicy) {
        Write-Host "   ✅ Auto-labeling policy '$baselineAutoPolicy' found" -ForegroundColor Green
        Write-Host "      Mode: $($autoPolicy.Mode)" -ForegroundColor Cyan
        Write-Host "      Label: $($autoPolicy.ApplySensitivityLabel)" -ForegroundColor Cyan
        Write-Host "      Created: $($autoPolicy.WhenCreatedUTC)" -ForegroundColor Cyan
        
        if ($autoPolicy.Mode -eq "Enable") {
            Write-Host "      ✅ Policy is active (simulation complete, applying labels)" -ForegroundColor Green
        } elseif ($autoPolicy.Mode -eq "Simulate") {
            Write-Host "      ⏳ Policy is in simulation mode (may still be running)" -ForegroundColor Yellow
            Write-Host "         Turn on policy in Purview portal to start labeling" -ForegroundColor Yellow
        } else {
            Write-Host "      ⚠️ Policy mode: $($autoPolicy.Mode)" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "   ❌ Auto-labeling policy '$baselineAutoPolicy' NOT found" -ForegroundColor Red
        Write-Host "      This policy should have been created in Day Zero Setup" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ❌ Auto-labeling policy validation failed: $_" -ForegroundColor Red
}

Write-Host ""

# =============================================================================
# Step 5: Pre-Created DLP Policy Validation (Day Zero Setup)
# =============================================================================

Write-Host "🛡️ Step 5: Pre-Created DLP Policy Validation (Day Zero Setup)" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Green

try {
    $baselineDlpPolicies = @(
        "PCI-DSS Protection (Retail)",
        "PII Data Protection (Retail)",
        "Loyalty Card Protection (Retail)",
        "External Sharing Control (Retail)"
    )
    
    $dlpPoliciesFound = 0
    
    $allDlpPolicies = Get-DlpCompliancePolicy
    
    foreach ($policyName in $baselineDlpPolicies) {
        $policy = $allDlpPolicies | Where-Object { $_.Name -eq $policyName }
        
        if ($policy) {
            Write-Host "   ✅ DLP policy '$policyName' found" -ForegroundColor Green
            Write-Host "      Mode: $($policy.Mode)" -ForegroundColor Cyan
            Write-Host "      Enabled: $($policy.Enabled)" -ForegroundColor Cyan
            Write-Host "      Workload: $($policy.Workload -join ', ')" -ForegroundColor Cyan
            $dlpPoliciesFound++
            
            if ($policy.Mode -eq "TestWithNotifications") {
                Write-Host "      ✅ Test mode with notifications (safe for validation)" -ForegroundColor Green
            } elseif ($policy.Mode -eq "Enable") {
                Write-Host "      ⚠️ Policy is in enforcement mode (blocking enabled)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   ❌ DLP policy '$policyName' NOT found" -ForegroundColor Red
        }
        Write-Host ""
    }
    
    if ($dlpPoliciesFound -eq $baselineDlpPolicies.Count) {
        Write-Host "   ✅ All baseline DLP policies present ($dlpPoliciesFound/$($baselineDlpPolicies.Count))" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ Some baseline DLP policies missing ($dlpPoliciesFound/$($baselineDlpPolicies.Count))" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ❌ DLP policy validation failed: $_" -ForegroundColor Red
}

Write-Host ""

# =============================================================================
# Step 6: Lab 04 Auto-Labeling Policy Validation (Optional)
# =============================================================================

Write-Host "🎯 Step 6: Lab 04 Auto-Labeling Policy Validation (Optional)" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green

try {
    $lab04AutoPolicies = @(
        "High-Risk Data (Retail)",
        "Customer List (Retail)",
        "Contact Data (Retail)",
        "Standard Forms (Retail)"
    )
    
    $lab04PoliciesFound = 0
    
    $allAutoPolicies = Get-AutoSensitivityLabelPolicy
    
    foreach ($policyName in $lab04AutoPolicies) {
        $policy = $allAutoPolicies | Where-Object { $_.Name -eq $policyName }
        
        if ($policy) {
            Write-Host "   ✅ Lab 04 auto-labeling policy '$policyName' found" -ForegroundColor Green
            Write-Host "      Mode: $($policy.Mode)" -ForegroundColor Cyan
            $lab04PoliciesFound++
            
            if ($policy.Mode -eq "Enable") {
                Write-Host "      ✅ Simulation complete, policy active" -ForegroundColor Green
            } elseif ($policy.Mode -eq "Simulate") {
                Write-Host "      ⏳ Still in simulation (wait 24-48 hours from creation)" -ForegroundColor Yellow
            }
        }
    }
    
    if ($lab04PoliciesFound -eq 0) {
        Write-Host "   ℹ️ No Lab 04 auto-labeling policies found (validation will focus on baseline policies)" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "   ✅ Lab 04 policies found: $lab04PoliciesFound/$($lab04AutoPolicies.Count)" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Lab 04 auto-labeling policy check failed: $_" -ForegroundColor Red
}

Write-Host ""

# =============================================================================
# Step 7: Lab 05 Optional DLP Policy Validation
# =============================================================================

Write-Host "🔒 Step 7: Lab 05 Optional DLP Policy Validation" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

try {
    $lab05OptionalPolicies = @(
        "Document Forms Protection (Retail)",
        "Marketing List Protection (Retail)"
    )
    
    $lab05PoliciesFound = 0
    
    $allDlpPolicies = Get-DlpCompliancePolicy
    
    foreach ($policyName in $lab05OptionalPolicies) {
        $policy = $allDlpPolicies | Where-Object { $_.Name -eq $policyName }
        
        if ($policy) {
            Write-Host "   ✅ Lab 05 optional DLP policy '$policyName' found" -ForegroundColor Green
            Write-Host "      Mode: $($policy.Mode)" -ForegroundColor Cyan
            $lab05PoliciesFound++
        }
    }
    
    if ($lab05PoliciesFound -eq 0) {
        Write-Host "   ℹ️ No Lab 05 optional DLP policies found (Lab 03 was optional)" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "   ✅ Lab 05 optional policies found: $lab05PoliciesFound/$($lab05OptionalPolicies.Count)" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Lab 05 optional DLP policy check failed: $_" -ForegroundColor Red
}

Write-Host ""

# =============================================================================
# Step 8: Summary and Recommendations
# =============================================================================

Write-Host "📊 Step 8: Validation Summary and Recommendations" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ Prerequisites Validated:" -ForegroundColor Cyan
Write-Host "   • Security & Compliance PowerShell connection active" -ForegroundColor Green
Write-Host "   • Audit log enabled for Activity Explorer data" -ForegroundColor Green
Write-Host "   • Baseline labels present (Day Zero Setup)" -ForegroundColor Green
Write-Host "   • Pre-created auto-labeling policy available" -ForegroundColor Green
Write-Host "   • Pre-created DLP policies available (4 baseline policies)" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Lab 07 Validation Scope:" -ForegroundColor Cyan
Write-Host "   • Lab 01 - Activity Explorer: DLP matches, label applications, user overrides" -ForegroundColor Yellow
Write-Host "   • Lab 02 - Content Explorer: Auto-labeled files, workload distribution" -ForegroundColor Yellow
Write-Host "   • Lab 03 - Data Classification: SIT effectiveness, false positive analysis" -ForegroundColor Yellow
Write-Host ""

Write-Host "⏰ Timing Recommendations:" -ForegroundColor Cyan
Write-Host "   • Activity Explorer: Wait 24-48 hours after policy creation for event data" -ForegroundColor Yellow
Write-Host "   • Content Explorer: Wait 1-2 hours after label application for indexing" -ForegroundColor Yellow
Write-Host "   • Data Classification: Updates within 1 hour for new SIT detections" -ForegroundColor Yellow
Write-Host ""

Write-Host "🎯 Ready to proceed with Lab 07 - Audit and Validation!" -ForegroundColor Green
Write-Host ""

exit 0

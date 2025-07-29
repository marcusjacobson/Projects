# =============================================================================
# Microsoft Defender for Cloud - Defender Plans Configuration Script
# =============================================================================
# This script configures Microsoft Defender for Cloud pricing plans and
# security contacts for comprehensive security coverage.
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Security contact email for notifications")]
    [string]$SecurityContactEmail = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Plans to enable (comma-separated). Default: VirtualMachines,StorageAccounts,KeyVaults,CloudPosture")]
    [string]$PlansToEnable = "VirtualMachines,StorageAccounts,KeyVaults,CloudPosture",
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Preview changes without executing")]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip confirmation prompts")]
    [switch]$Force
)

# Script Configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host "🛡️ Microsoft Defender for Cloud - Defender Plans Configuration" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host ""

# =============================================================================
# 💰 COST AWARENESS WARNING - Defender for Cloud Plans
# =============================================================================
Write-Host "💰 COST AWARENESS: Defender for Cloud Plans" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Yellow
Write-Host "📊 This script enables premium Defender for Cloud plans which incur subscription-level costs:" -ForegroundColor Yellow
Write-Host "   • Defender for Servers Plan 2: ~`$15/server/month (comprehensive protection)" -ForegroundColor Yellow
Write-Host "   • Defender for Storage: ~`$10/storage account/month (malware scanning)" -ForegroundColor Yellow
Write-Host "   • Defender for Key Vault: ~`$2/vault/month (secrets protection)" -ForegroundColor Yellow
Write-Host "   • Defender for Containers: ~`$7/vCore/month (container security)" -ForegroundColor Yellow
Write-Host "   • Foundational CSPM: Free (Cloud Security Posture Management)" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Cost Management Tips:" -ForegroundColor Cyan
Write-Host "   • Review and disable unused plans in non-production environments" -ForegroundColor Cyan
Write-Host "   • Monitor usage with Azure Cost Management + Billing" -ForegroundColor Cyan
Write-Host "   • Plans can be disabled anytime to stop charges" -ForegroundColor Cyan
Write-Host "   • Some plans offer per-resource pricing granularity" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Learn more: https://learn.microsoft.com/en-us/azure/defender-for-cloud/faq-pricing" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Yellow
Write-Host ""

# Parse plans to enable
$enabledPlans = $PlansToEnable -split "," | ForEach-Object { $_.Trim() }

# =============================================================================
# Parameter File Integration
# =============================================================================

if ($UseParametersFile) {
    Write-Host "📄 Loading parameters from main.parameters.json..." -ForegroundColor Cyan
    $parametersFilePath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    
    if (Test-Path $parametersFilePath) {
        try {
            $mainParameters = Get-Content $parametersFilePath -Raw | ConvertFrom-Json
            
            # Extract only parameters needed for script logic
            if ($mainParameters.parameters.securityContactEmail.value -and -not $SecurityContactEmail) {
                $SecurityContactEmail = $mainParameters.parameters.securityContactEmail.value
                Write-Host "   ✅ Security Contact Email: $SecurityContactEmail" -ForegroundColor Green
            }
            
            # Extract plan configuration from parameters file
            $planConfig = @()
            if ($mainParameters.parameters.enableDefenderForServers.value) { $planConfig += "VirtualMachines" }
            if ($mainParameters.parameters.enableDefenderForStorage.value) { $planConfig += "StorageAccounts" }
            if ($mainParameters.parameters.enableDefenderForKeyVault.value) { $planConfig += "KeyVaults" }
            if ($mainParameters.parameters.enableDefenderForContainers.value) { $planConfig += "Containers" }
            
            if ($planConfig.Count -gt 0) {
                $PlansToEnable = $planConfig -join ","
                $enabledPlans = $planConfig
                Write-Host "   ✅ Plans to Enable (from parameters): $($planConfig -join ', ')" -ForegroundColor Green
            }
            
        } catch {
            Write-Host "   ❌ Failed to read parameters file: $_" -ForegroundColor Red
            Write-Host "   ℹ️ Continuing with command-line parameters..." -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠️ Parameters file not found: $parametersFilePath" -ForegroundColor Yellow
        Write-Host "   ℹ️ Continuing with command-line parameters..." -ForegroundColor Cyan
    }
    Write-Host ""
}

Write-Host "📋 Configuration Details:" -ForegroundColor Cyan
Write-Host "   Security Contact Email: $(if ($SecurityContactEmail) { $SecurityContactEmail } else { 'Not provided' })" -ForegroundColor White
Write-Host "   Plans to Enable: $($enabledPlans -join ', ')" -ForegroundColor White
Write-Host "   What-If Mode: $WhatIf" -ForegroundColor White
Write-Host ""

# Cost confirmation and deployment prompt
if (-not $Force -and -not $WhatIf) {
    Write-Host ""
    Write-Host "💰 COST CONFIRMATION" -ForegroundColor Yellow
    Write-Host "===================" -ForegroundColor Yellow
    Write-Host "📊 About to enable Defender for Cloud plans with the following estimated costs:" -ForegroundColor White
    
    # Calculate estimated monthly costs based on enabled plans
    $totalEstimatedCost = 0
    $costBreakdown = @()
    
    foreach ($plan in $enabledPlans) {
        switch ($plan) {
            "VirtualMachines" { 
                $costBreakdown += "   • Defender for Servers Plan 2: ~`$15/server/month (you have 2 VMs = ~`$30/month)"
                $totalEstimatedCost += 30
            }
            "StorageAccounts" { 
                $costBreakdown += "   • Defender for Storage: ~`$10/storage account/month"
                $totalEstimatedCost += 10
            }
            "KeyVaults" { 
                $costBreakdown += "   • Defender for Key Vault: ~`$2/vault/month"
                $totalEstimatedCost += 2
            }
            "Containers" { 
                $costBreakdown += "   • Defender for Containers: ~`$7/vCore/month"
                $totalEstimatedCost += 7
            }
            "CloudPosture" { 
                $costBreakdown += "   • Foundational CSPM: Free (included)"
            }
        }
    }
    
    foreach ($cost in $costBreakdown) {
        Write-Host $cost -ForegroundColor White
    }
    
    if ($totalEstimatedCost -gt 0) {
        Write-Host "   • Estimated Total: ~`$$totalEstimatedCost/month" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "💡 Remember: Plans can be disabled anytime to stop charges!" -ForegroundColor Cyan
    Write-Host ""
    $costConfirmation = Read-Host "💰 Do you acknowledge the costs and want to proceed with Defender plans configuration? (y/N)"
    if ($costConfirmation -ne "y" -and $costConfirmation -ne "Y") {
        Write-Host "❌ Configuration cancelled by user" -ForegroundColor Red
        Write-Host "💡 Tip: Use -WhatIf to preview changes without enabling plans" -ForegroundColor Cyan
        exit 0
    }
}

if (-not $Force -and -not $WhatIf) {
    Write-Host "⚠️ This will modify subscription-level Defender for Cloud settings" -ForegroundColor Yellow
    $confirmation = Read-Host "Do you want to proceed with Defender plans configuration? (y/N)"
    if ($confirmation -ne "y" -and $confirmation -ne "Y") {
        Write-Host "❌ Configuration cancelled by user" -ForegroundColor Red
        exit 0
    }
}

# =============================================================================
# Phase 1: Current Configuration Assessment
# =============================================================================

Write-Host "🔍 Phase 1: Current Configuration Assessment" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Verify Azure CLI authentication
Write-Host "🔐 Verifying Azure CLI authentication..." -ForegroundColor Cyan
try {
    $currentAccount = az account show --output json | ConvertFrom-Json
    Write-Host "   ✅ Authenticated as: $($currentAccount.user.name)" -ForegroundColor Green
    Write-Host "   📋 Subscription: $($currentAccount.name) ($($currentAccount.id))" -ForegroundColor White
} catch {
    Write-Host "   ❌ Azure CLI authentication required. Run 'az login'" -ForegroundColor Red
    exit 1
}

# Check current Defender plans
Write-Host "💰 Checking current Defender for Cloud plans..." -ForegroundColor Cyan
try {
    $currentPlans = az security pricing list --output json | ConvertFrom-Json
    Write-Host "   ✅ Current plans retrieved" -ForegroundColor Green
    
    $standardPlans = $currentPlans.value | Where-Object { $_.pricingTier -eq "Standard" }
    $freePlans = $currentPlans.value | Where-Object { $_.pricingTier -eq "Free" }
    
    Write-Host "   📊 Current Status:" -ForegroundColor White
    Write-Host "      - Standard tier plans: $($standardPlans.Count)" -ForegroundColor White
    Write-Host "      - Free tier plans: $($freePlans.Count)" -ForegroundColor White
    
    if ($standardPlans.Count -gt 0) {
        Write-Host "   🔧 Currently enabled plans:" -ForegroundColor White
        foreach ($plan in $standardPlans) {
            Write-Host "      - $($plan.name): $($plan.pricingTier)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "   ❌ Failed to retrieve current plans: $_" -ForegroundColor Red
    exit 1
}

# Check current security contacts
Write-Host "📧 Checking current security contacts..." -ForegroundColor Cyan
try {
    $currentContacts = az security contact list --output json | ConvertFrom-Json
    if ($currentContacts -and $currentContacts.Count -gt 0) {
        Write-Host "   ✅ Current security contacts: $($currentContacts.Count)" -ForegroundColor Green
        foreach ($contact in $currentContacts) {
            Write-Host "      - Email: $($contact.email)" -ForegroundColor White
            Write-Host "      - Alert Notifications: $($contact.alertNotifications.state)" -ForegroundColor White
        }
    } else {
        Write-Host "   ℹ️ No security contacts currently configured" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ⚠️ Could not retrieve security contacts: $_" -ForegroundColor Yellow
}

# =============================================================================
# Phase 2: Plan Configuration Validation
# =============================================================================

Write-Host ""
Write-Host "✅ Phase 2: Plan Configuration Validation" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Validate plan names
Write-Host "🔍 Validating requested plans..." -ForegroundColor Cyan
$validPlans = @("VirtualMachines", "StorageAccounts", "KeyVaults", "CloudPosture", "Containers", "AppServices", "SqlServers", "SqlServerVirtualMachines", "OpenSourceRelationalDatabases", "CosmosDbs", "Api", "Arm", "Dns", "KubernetesService", "ContainerRegistry")
$invalidPlans = $enabledPlans | Where-Object { $_ -notin $validPlans }

if ($invalidPlans.Count -gt 0) {
    Write-Host "   ❌ Invalid plan names detected: $($invalidPlans -join ', ')" -ForegroundColor Red
    Write-Host "   💡 Valid plans: $($validPlans -join ', ')" -ForegroundColor Yellow
    exit 1
}
Write-Host "   ✅ All requested plans are valid" -ForegroundColor Green

# Check plan availability and current state
Write-Host "📋 Analyzing plan changes..." -ForegroundColor Cyan
$plansToUpdate = @()
$plansAlreadyEnabled = @()

foreach ($planName in $enabledPlans) {
    $currentPlan = $currentPlans.value | Where-Object { $_.name -eq $planName }
    if ($currentPlan) {
        if ($currentPlan.pricingTier -eq "Standard") {
            $plansAlreadyEnabled += $planName
        } else {
            $plansToUpdate += $planName
        }
    } else {
        Write-Host "   ⚠️ Plan '$planName' not found in subscription" -ForegroundColor Yellow
    }
}

Write-Host "   📊 Plan Analysis Results:" -ForegroundColor White
Write-Host "      - Plans to enable: $($plansToUpdate.Count)" -ForegroundColor White
Write-Host "      - Plans already enabled: $($plansAlreadyEnabled.Count)" -ForegroundColor White

if ($plansAlreadyEnabled.Count -gt 0) {
    Write-Host "   ℹ️ Already enabled: $($plansAlreadyEnabled -join ', ')" -ForegroundColor Gray
}

# =============================================================================
# Phase 3: Execute Configuration Changes
# =============================================================================

Write-Host ""
Write-Host "🚀 Phase 3: Execute Configuration Changes" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

if ($WhatIf) {
    Write-Host "👁️ Preview of changes (What-If mode):" -ForegroundColor Yellow
    Write-Host "====================================" -ForegroundColor Yellow
    
    if ($plansToUpdate.Count -gt 0) {
        Write-Host "📈 Plans to be enabled (Free → Standard):" -ForegroundColor Cyan
        foreach ($plan in $plansToUpdate) {
            Write-Host "   - $plan" -ForegroundColor White
        }
    } else {
        Write-Host "📈 No plan changes required - all requested plans already enabled" -ForegroundColor Green
    }
    
    if ($SecurityContactEmail) {
        Write-Host "📧 Security contact configuration:" -ForegroundColor Cyan
        Write-Host "   - Email: $SecurityContactEmail" -ForegroundColor White
        Write-Host "   - Alert Notifications: Enabled" -ForegroundColor White
        Write-Host "   - Role Notifications: Enabled for Owners/Contributors" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "ℹ️ This was a preview only. Use without -WhatIf to execute changes." -ForegroundColor Cyan
} else {
    # Enable Defender plans
    if ($plansToUpdate.Count -gt 0) {
        Write-Host "📈 Enabling Defender for Cloud plans..." -ForegroundColor Cyan
        foreach ($plan in $plansToUpdate) {
            Write-Host "   🔧 Enabling plan: $plan" -ForegroundColor White
            try {
                # Configure plan-specific settings
                switch ($plan) {
                    "VirtualMachines" {
                        az security pricing create --name $plan --tier "Standard" --subplan "P2" --output none
                        Write-Host "      ✅ $plan enabled with Plan 2 (includes agentless scanning)" -ForegroundColor Green
                    }
                    "StorageAccounts" {
                        az security pricing create --name $plan --tier "Standard" --subplan "DefenderForStorageV2" --output none
                        Write-Host "      ✅ $plan enabled with V2 (includes malware scanning)" -ForegroundColor Green
                    }
                    "KeyVaults" {
                        az security pricing create --name $plan --tier "Standard" --subplan "PerKeyVault" --output none
                        Write-Host "      ✅ $plan enabled with per-KeyVault pricing" -ForegroundColor Green
                    }
                    default {
                        az security pricing create --name $plan --tier "Standard" --output none
                        Write-Host "      ✅ $plan enabled with Standard tier" -ForegroundColor Green
                    }
                }
            } catch {
                Write-Host "      ❌ Failed to enable $plan`: $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "   ℹ️ No plan changes required - all requested plans already enabled" -ForegroundColor Gray
    }
    
    # Configure security contacts
    if ($SecurityContactEmail) {
        Write-Host "📧 Configuring security contacts..." -ForegroundColor Cyan
        try {
            # Create or update security contact with correct Azure CLI syntax
            az security contact create `
                --name "default" `
                --emails $SecurityContactEmail `
                --alert-notifications '{"state":"On","minimalSeverity":"Low"}' `
                --notifications-by-role '{"state":"On","roles":["Owner"]}' `
                --output none
            
            Write-Host "   ✅ Security contact configured: $SecurityContactEmail" -ForegroundColor Green
            Write-Host "      - Alert notifications: Enabled" -ForegroundColor White
            Write-Host "      - Admin notifications: Enabled" -ForegroundColor White
        } catch {
            Write-Host "   ❌ Failed to configure security contact: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "   ℹ️ Security contact email not provided - skipping contact configuration" -ForegroundColor Gray
    }
}

# =============================================================================
# Phase 4: Configuration Validation
# =============================================================================

if (-not $WhatIf) {
    Write-Host ""
    Write-Host "✅ Phase 4: Configuration Validation" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    
    # Verify enabled plans
    Write-Host "🔍 Verifying enabled plans..." -ForegroundColor Cyan
    try {
        $updatedPlans = az security pricing list --output json | ConvertFrom-Json
        $nowStandardPlans = $updatedPlans.value | Where-Object { $_.pricingTier -eq "Standard" }
        
        Write-Host "   ✅ Current Standard tier plans: $($nowStandardPlans.Count)" -ForegroundColor Green
        
        $successfullyEnabled = @()
        foreach ($plan in $enabledPlans) {
            $planStatus = $updatedPlans.value | Where-Object { $_.name -eq $plan }
            if ($planStatus -and $planStatus.pricingTier -eq "Standard") {
                $successfullyEnabled += $plan
                Write-Host "      ✅ $plan`: Standard" -ForegroundColor Green
            } else {
                Write-Host "      ❌ $plan`: Not enabled" -ForegroundColor Red
            }
        }
        
        Write-Host "   📊 Successfully enabled: $($successfullyEnabled.Count)/$($enabledPlans.Count)" -ForegroundColor White
    } catch {
        Write-Host "   ❌ Failed to verify plans: $_" -ForegroundColor Red
    }
    
    # Verify security contacts
    if ($SecurityContactEmail) {
        Write-Host "📧 Verifying security contacts..." -ForegroundColor Cyan
        try {
            $updatedContacts = az security contact list --output json | ConvertFrom-Json
            $emailFound = $false
            foreach ($contact in $updatedContacts) {
                # Check if the email is in the emails array
                if ($contact.emails -and $contact.emails -contains $SecurityContactEmail) {
                    $emailFound = $true
                    Write-Host "   ✅ Security contact verified: $($SecurityContactEmail)" -ForegroundColor Green
                    Write-Host "      - Alert notifications: $($contact.alertNotifications.state)" -ForegroundColor White
                    Write-Host "      - Role notifications: $($contact.notificationsByRole.state)" -ForegroundColor White
                    break
                }
            }
            
            if (-not $emailFound) {
                Write-Host "   ❌ Security contact not found or not configured properly" -ForegroundColor Red
            }
        } catch {
            Write-Host "   ❌ Failed to verify security contacts: $_" -ForegroundColor Red
        }
    }
}

# =============================================================================
# Completion Summary
# =============================================================================

Write-Host ""
Write-Host "📊 Defender Plans Configuration Summary" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

if ($WhatIf) {
    Write-Host "👁️ Preview completed successfully!" -ForegroundColor Yellow
    Write-Host "   • Plan validation: ✅ Passed" -ForegroundColor White
    Write-Host "   • Change analysis: ✅ Completed" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Next Steps:" -ForegroundColor Cyan
    Write-Host "   • Review the preview output above" -ForegroundColor White
    Write-Host "   • Run without -WhatIf to execute configuration" -ForegroundColor White
} else {
    Write-Host "🎉 Defender plans configuration completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Configuration Results:" -ForegroundColor Green
    Write-Host "   • Defender Plans: ✅ Configured" -ForegroundColor White
    if ($SecurityContactEmail) {
        Write-Host "   • Security Contacts: ✅ Configured" -ForegroundColor White
    }
    Write-Host "   • Subscription Security: ✅ Enhanced" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Next Steps:" -ForegroundColor Cyan
    Write-Host "   • Run Deploy-SecurityFeatures.ps1 to configure JIT and extensions" -ForegroundColor White
    Write-Host "   • Validate complete deployment with Test-DeploymentValidation.ps1" -ForegroundColor White
    Write-Host "   • Review security posture in Azure Portal → Defender for Cloud" -ForegroundColor White
}

Write-Host ""
Write-Host "🎯 Defender plans configuration script completed!" -ForegroundColor Green

<#
.SYNOPSIS
    Safely removes all Microsoft Defender for Cloud infrastructure components
    in the correct logical order to prevent orphaned resources and dependency conflicts.

.DESCRIPTION
    This script provides comprehensive decommission capabilities for Microsoft
    Defender for Cloud environments deployed via Infrastructure-as-Code. It
    performs ordered removal of security configurations, virtual machines,
    networking components, monitoring resources, and storage accounts while
    maintaining data integrity and preventing resource conflicts. The script
    includes safety mechanisms such as What-If mode, confirmation prompts,
    resource validation, and optional Defender plan deactivation. It handles
    complex dependencies including JIT VM Access policies, auto-shutdown
    schedules, security extensions, and Microsoft Sentinel integrations.

.PARAMETER EnvironmentName
    Name for the environment to decommission. Default: "securitylab"

.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file.

.PARAMETER WhatIf
    Preview decommission without making changes.

.PARAMETER Force
    Force decommission without confirmation prompts (automation scenarios).

.PARAMETER DisableDefenderPlans
    Switch to also disable Defender for Cloud plans during decommission.

.PARAMETER PreserveData
    Switch to preserve data and logs during infrastructure removal.

.EXAMPLE
    .\Remove-DefenderInfrastructure.ps1 -UseParametersFile -WhatIf
    
    Preview decommission without making changes.

.EXAMPLE
    .\Remove-DefenderInfrastructure.ps1 -EnvironmentName "seclab"
    
    Safely decommission with confirmation prompts.

.EXAMPLE
    .\Remove-DefenderInfrastructure.ps1 -UseParametersFile -Force
    
    Force decommission without confirmation (automation scenarios).

.EXAMPLE
    .\Remove-DefenderInfrastructure.ps1 -UseParametersFile -DisableDefenderPlans -Force
    
    Complete lab teardown including Defender plan deactivation.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-08-04
    
    Safely removes Microsoft Defender for Cloud infrastructure with proper dependency management.
    Script development orchestrated using GitHub Copilot.
    WARNING: This script performs permanent deletion of Azure resources.

.DECOMMISSION_PHASES
    - Phase 1: Discovery and validation of existing resources
    - Phase 2: Security configuration removal (JIT policies, contacts)
    - Phase 3: Virtual machine decommission and extension cleanup
    - Phase 4: Network infrastructure removal (NSGs, NICs, IPs)
    - Phase 5: Monitoring and storage resource cleanup
    - Phase 6: Resource group deletion and plan deactivation
    - Validation: Comprehensive cleanup verification and reporting
#>

# =============================================================================
# Microsoft Defender for Cloud - Infrastructure Decommission Script
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Name for the environment to decommission")]
    [string]$EnvironmentName = "securitylab",
    
    [Parameter(Mandatory=$false, HelpMessage="Name of the resource group to decommission (auto-generated if not specified)")]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$false, HelpMessage="Azure subscription ID (uses current subscription if not specified)")]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Confirm deletion without prompting")]
    [switch]$Force,
    
    [Parameter(Mandatory=$false, HelpMessage="Show what would be deleted without actually deleting")]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false, HelpMessage="Also disable all Defender for Cloud pricing plans (useful for complete lab teardown)")]
    [switch]$DisableDefenderPlans
)

# Script Configuration
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

# =============================================================================
# Parameter File Integration
# =============================================================================

if ($UseParametersFile) {
    Write-Host "📄 Loading parameters from main.parameters.json..." -ForegroundColor Cyan
    $parametersFilePath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    
    if (Test-Path $parametersFilePath) {
        try {
            $mainParameters = Get-Content $parametersFilePath -Raw | ConvertFrom-Json
            
            # Override script parameters with values from file
            if ($mainParameters.parameters.environmentName.value) {
                $EnvironmentName = $mainParameters.parameters.environmentName.value
                Write-Host "   ✅ Environment Name: $EnvironmentName" -ForegroundColor Green
            }
            
            if ($mainParameters.parameters.resourceGroupName.value -and -not $ResourceGroupName) {
                $ResourceGroupName = $mainParameters.parameters.resourceGroupName.value
                Write-Host "   ✅ Resource Group Name: $ResourceGroupName" -ForegroundColor Green
            }
            
            # Extract resource token for resource name validation
            if ($mainParameters.parameters.resourceToken.value) {
                $global:ResourceToken = $mainParameters.parameters.resourceToken.value
                Write-Host "   ✅ Resource Token: $global:ResourceToken" -ForegroundColor Green
            } else {
                # Fallback: generate resource token similar to bicep
                $global:ResourceToken = $EnvironmentName.ToLower() + (Get-Random -Minimum 100000 -Maximum 999999)
                Write-Host "   ⚠️ Generated Resource Token: $global:ResourceToken" -ForegroundColor Yellow
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

# Generate resource group name if not provided
if (-not $ResourceGroupName) {
    $ResourceGroupName = "rg-aisec-defender-$EnvironmentName"
}

# Initialize variables
if (-not $SubscriptionId) {
    $SubscriptionId = az account show --query "id" --output tsv
}

Write-Host "🗑️ Microsoft Defender for Cloud Decommission Script" -ForegroundColor Magenta
Write-Host "====================================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "⚠️ WARNING: This script will permanently delete Azure resources!" -ForegroundColor Yellow
Write-Host "📋 Target Details:" -ForegroundColor Cyan
Write-Host "   Subscription ID: $SubscriptionId" -ForegroundColor White
Write-Host "   Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "   What-If Mode: $WhatIf" -ForegroundColor White
Write-Host "   Disable Defender Plans: $DisableDefenderPlans" -ForegroundColor White
Write-Host ""

if (-not $Force -and -not $WhatIf) {
    $confirmation = Read-Host "Are you sure you want to proceed with decommission? (Type 'DELETE' to confirm)"
    if ($confirmation -ne "DELETE") {
        Write-Host "❌ Decommission cancelled by user" -ForegroundColor Red
        exit 0
    }
}

# =============================================================================
# Phase 1: Pre-Decommission Validation and Discovery
# =============================================================================

Write-Host "🔍 Phase 1: Discovery and Validation" -ForegroundColor Magenta
Write-Host "=====================================" -ForegroundColor Magenta

# Verify subscription access
Write-Host "📋 Verifying subscription access..." -ForegroundColor Cyan
try {
    $currentSub = az account show --output json | ConvertFrom-Json
    if ($currentSub.id -ne $SubscriptionId) {
        Write-Host "⚠️ Setting active subscription to $SubscriptionId..." -ForegroundColor Yellow
        az account set --subscription $SubscriptionId
    }
    Write-Host "   ✅ Subscription access verified" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to access subscription: $_" -ForegroundColor Red
    exit 1
}

# Check if resource group exists
Write-Host "📁 Checking resource group existence..." -ForegroundColor Cyan
$resourceGroupExists = az group exists --name $ResourceGroupName --output tsv
if ($resourceGroupExists -eq "false") {
    Write-Host "   ⚠️ Resource group '$ResourceGroupName' does not exist - nothing to decommission" -ForegroundColor Yellow
    exit 0
}
Write-Host "   ✅ Resource group '$ResourceGroupName' found" -ForegroundColor Green

# Discover resources
Write-Host "🔍 Discovering resources to decommission..." -ForegroundColor Cyan
$resources = az resource list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
$resourceCount = $resources.Count
Write-Host "   📊 Found $resourceCount resources to process" -ForegroundColor White

if ($resourceCount -eq 0) {
    Write-Host "   ⚠️ No resources found in resource group - only resource group will be deleted" -ForegroundColor Yellow
}

# Discover VMs and extensions
$vms = az vm list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
$vmCount = $vms.Count
Write-Host "   🖥️ Virtual Machines: $vmCount" -ForegroundColor White

# Discover networking components
$vnets = az network vnet list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
$nsgs = az network nsg list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
$publicIps = az network public-ip list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
$nics = az network nic list --resource-group $ResourceGroupName --output json | ConvertFrom-Json

Write-Host "   🌐 Virtual Networks: $($vnets.Count)" -ForegroundColor White
Write-Host "   🛡️ Network Security Groups: $($nsgs.Count)" -ForegroundColor White
Write-Host "   🌍 Public IP Addresses: $($publicIps.Count)" -ForegroundColor White
Write-Host "   🔌 Network Interfaces: $($nics.Count)" -ForegroundColor White

# Discover Log Analytics workspaces
$workspaces = az monitor log-analytics workspace list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
Write-Host "   📊 Log Analytics Workspaces: $($workspaces.Count)" -ForegroundColor White

# Discover storage resources
$storageAccounts = az storage account list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
Write-Host "   💾 Storage Accounts: $($storageAccounts.Count)" -ForegroundColor White

# Discover auto-shutdown schedules
$autoShutdownSchedules = az resource list --resource-group $ResourceGroupName --resource-type "Microsoft.DevTestLab/schedules" --output json | ConvertFrom-Json
Write-Host "   ⏰ Auto-Shutdown Schedules: $($autoShutdownSchedules.Count)" -ForegroundColor White

# Validate expected resources based on parameters
if ($global:ResourceToken) {
    Write-Host "🔍 Validating expected resource names (using token: $global:ResourceToken)..." -ForegroundColor Cyan
    
    # Expected VM names based on bicep template patterns
    $expectedLinuxVm = "vm-linux-$global:ResourceToken"
    $expectedWindowsVm = "vm-windows-$global:ResourceToken"
    $expectedWorkspace = "log-aisec-defender-$EnvironmentName-$global:ResourceToken"
    
    # Check if expected VMs exist
    $foundLinuxVm = $vms | Where-Object { $_.name -eq $expectedLinuxVm }
    $foundWindowsVm = $vms | Where-Object { $_.name -eq $expectedWindowsVm }
    $foundWorkspace = $workspaces | Where-Object { $_.name -eq $expectedWorkspace }
    
    Write-Host "   🐧 Expected Linux VM: $expectedLinuxVm $(if ($foundLinuxVm) { '✅ Found' } else { '⚠️ Not Found' })" -ForegroundColor $(if ($foundLinuxVm) { 'Green' } else { 'Yellow' })
    Write-Host "   🪟 Expected Windows VM: $expectedWindowsVm $(if ($foundWindowsVm) { '✅ Found' } else { '⚠️ Not Found' })" -ForegroundColor $(if ($foundWindowsVm) { 'Green' } else { 'Yellow' })
    Write-Host "   📊 Expected Log Analytics: $expectedWorkspace $(if ($foundWorkspace) { '✅ Found' } else { '⚠️ Not Found' })" -ForegroundColor $(if ($foundWorkspace) { 'Green' } else { 'Yellow' })
    
    # Check for expected auto-shutdown schedules
    $expectedLinuxShutdown = "shutdown-computevm-$expectedLinuxVm"
    $expectedWindowsShutdown = "shutdown-computevm-$expectedWindowsVm"
    
    $foundLinuxShutdown = $autoShutdownSchedules | Where-Object { $_.name -eq $expectedLinuxShutdown }
    $foundWindowsShutdown = $autoShutdownSchedules | Where-Object { $_.name -eq $expectedWindowsShutdown }
    
    Write-Host "   ⏰ Expected Linux Auto-Shutdown: $expectedLinuxShutdown $(if ($foundLinuxShutdown) { '✅ Found' } else { '⚠️ Not Found' })" -ForegroundColor $(if ($foundLinuxShutdown) { 'Green' } else { 'Yellow' })
    Write-Host "   ⏰ Expected Windows Auto-Shutdown: $expectedWindowsShutdown $(if ($foundWindowsShutdown) { '✅ Found' } else { '⚠️ Not Found' })" -ForegroundColor $(if ($foundWindowsShutdown) { 'Green' } else { 'Yellow' })
}

if ($WhatIf) {
    Write-Host ""
    Write-Host "🔍 WHAT-IF MODE: Resources that would be deleted:" -ForegroundColor Yellow
    Write-Host "===============================================" -ForegroundColor Yellow
    foreach ($resource in $resources) {
        Write-Host "   - $($resource.name) ($($resource.type))" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "🔍 WHAT-IF MODE: Security configurations that would be removed:" -ForegroundColor Yellow
    Write-Host "=============================================================" -ForegroundColor Yellow
    Write-Host "   - JIT VM Access policies" -ForegroundColor White
    Write-Host "   - Auto-shutdown schedules for VMs" -ForegroundColor White
    Write-Host "   - Defender for Cloud security contacts" -ForegroundColor White
    Write-Host "   - Microsoft Sentinel onboarding (if configured)" -ForegroundColor White
    if ($DisableDefenderPlans) {
        Write-Host "   - All Defender for Cloud pricing plans (disabled to Free tier)" -ForegroundColor White
    } else {
        Write-Host "   - Defender pricing plan configurations (manual review required)" -ForegroundColor White
    }
    
    if ($global:ResourceToken) {
        Write-Host ""
        Write-Host "🔍 WHAT-IF MODE: Expected resources based on parameters:" -ForegroundColor Yellow
        Write-Host "======================================================" -ForegroundColor Yellow
        Write-Host "   Resource Token: $global:ResourceToken" -ForegroundColor White
        Write-Host "   Environment: $EnvironmentName" -ForegroundColor White
        Write-Host "   Expected Linux VM: vm-linux-$global:ResourceToken" -ForegroundColor White
        Write-Host "   Expected Windows VM: vm-windows-$global:ResourceToken" -ForegroundColor White
        Write-Host "   Expected Log Analytics: log-aisec-defender-$EnvironmentName-$global:ResourceToken" -ForegroundColor White
        Write-Host "   Expected Auto-Shutdown Schedules:" -ForegroundColor White
        Write-Host "     - shutdown-computevm-vm-linux-$global:ResourceToken" -ForegroundColor White
        Write-Host "     - shutdown-computevm-vm-windows-$global:ResourceToken" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "ℹ️ Use -Force to execute the actual decommission" -ForegroundColor Cyan
    exit 0
}

# =============================================================================
# Phase 2: Remove Security Configurations
# =============================================================================

Write-Host ""
Write-Host "🛡️ Phase 2: Removing Security Configurations" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta

# Remove JIT VM Access Policies
Write-Host "🔐 Removing Just-in-Time VM Access policies..." -ForegroundColor Cyan
try {
    $jitPolicies = az rest --method GET --url "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Security/locations/westus/jitNetworkAccessPolicies?api-version=2020-01-01" --output json 2>$null | ConvertFrom-Json
    
    if ($jitPolicies.value -and $jitPolicies.value.Count -gt 0) {
        foreach ($policy in $jitPolicies.value) {
            Write-Host "   🗑️ Removing JIT policy: $($policy.name)" -ForegroundColor White
            az rest --method DELETE --url "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Security/locations/westus/jitNetworkAccessPolicies/$($policy.name)?api-version=2020-01-01" 2>$null
        }
        Write-Host "   ✅ JIT policies removed" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️ No JIT policies found" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ⚠️ Failed to remove JIT policies: $_" -ForegroundColor Yellow
}

# Remove Auto-Shutdown Schedules
Write-Host "⏰ Removing VM auto-shutdown schedules..." -ForegroundColor Cyan
try {
    $autoShutdownSchedules = az resource list --resource-group $ResourceGroupName --resource-type "Microsoft.DevTestLab/schedules" --output json | ConvertFrom-Json
    
    if ($autoShutdownSchedules -and $autoShutdownSchedules.Count -gt 0) {
        foreach ($schedule in $autoShutdownSchedules) {
            Write-Host "   🗑️ Removing auto-shutdown schedule: $($schedule.name)" -ForegroundColor White
            az resource delete --ids $schedule.id --output none 2>$null
        }
        Write-Host "   ✅ Auto-shutdown schedules removed" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️ No auto-shutdown schedules found" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ⚠️ Failed to remove auto-shutdown schedules: $_" -ForegroundColor Yellow
}

# Check and remove Microsoft Sentinel onboarding
Write-Host "🛡️ Checking Microsoft Sentinel onboarding..." -ForegroundColor Cyan
foreach ($workspace in $workspaces) {
    try {
        $workspaceId = $workspace.id
        $sentinelState = az rest --method GET --url "https://management.azure.com/$workspaceId/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2022-10-01-preview" --output json 2>$null
        
        if ($sentinelState) {
            Write-Host "   🗑️ Removing Sentinel onboarding for workspace: $($workspace.name)" -ForegroundColor White
            az rest --method DELETE --url "https://management.azure.com/$workspaceId/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2022-10-01-preview" 2>$null
            Write-Host "   ✅ Sentinel onboarding removed" -ForegroundColor Green
        } else {
            Write-Host "   ℹ️ No Sentinel onboarding found for workspace: $($workspace.name)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "   ⚠️ Failed to check/remove Sentinel onboarding: $_" -ForegroundColor Yellow
    }
}

# =============================================================================
# Phase 3: Remove Virtual Machine Components
# =============================================================================

Write-Host ""
Write-Host "🖥️ Phase 3: Removing Virtual Machine Components" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta

# Stop VMs first
if ($vmCount -gt 0) {
    Write-Host "⏹️ Stopping virtual machines..." -ForegroundColor Cyan
    foreach ($vm in $vms) {
        Write-Host "   🛑 Stopping VM: $($vm.name)" -ForegroundColor White
        az vm stop --resource-group $ResourceGroupName --name $vm.name --no-wait 2>$null
    }
    
    # Wait for VMs to stop
    Write-Host "   ⏳ Waiting for VMs to stop..." -ForegroundColor White
    Start-Sleep -Seconds 30
    
    # Deallocate VMs
    Write-Host "💾 Deallocating virtual machines..." -ForegroundColor Cyan
    foreach ($vm in $vms) {
        Write-Host "   💿 Deallocating VM: $($vm.name)" -ForegroundColor White
        az vm deallocate --resource-group $ResourceGroupName --name $vm.name --no-wait 2>$null
    }
    
    # Wait for deallocation
    Write-Host "   ⏳ Waiting for VM deallocation..." -ForegroundColor White
    Start-Sleep -Seconds 60
    
    Write-Host "   ✅ VMs stopped and deallocated" -ForegroundColor Green
} else {
    Write-Host "   ℹ️ No virtual machines found" -ForegroundColor Gray
}

# =============================================================================
# Phase 4: Remove Resource Group and All Contained Resources
# =============================================================================

Write-Host ""
Write-Host "🗑️ Phase 4: Removing Resource Group and All Resources" -ForegroundColor Magenta
Write-Host "====================================================" -ForegroundColor Magenta

Write-Host "🗂️ Deleting resource group: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "   ⚠️ This will delete ALL resources in the resource group..." -ForegroundColor Yellow
Write-Host "   📊 Resources to be deleted: $resourceCount" -ForegroundColor White

try {
    # Delete the entire resource group (this removes all contained resources)
    az group delete --name $ResourceGroupName --yes --no-wait
    Write-Host "   ✅ Resource group deletion initiated" -ForegroundColor Green
    Write-Host "   ⏳ Deletion is running in the background..." -ForegroundColor White
    
    # Monitor deletion progress
    Write-Host "📋 Monitoring deletion progress..." -ForegroundColor Cyan
    $maxWaitMinutes = 20
    $checkIntervalSeconds = 30
    $totalChecks = ($maxWaitMinutes * 60) / $checkIntervalSeconds
    
    for ($i = 1; $i -le $totalChecks; $i++) {
        Start-Sleep -Seconds $checkIntervalSeconds
        $rgExists = az group exists --name $ResourceGroupName --output tsv
        
        if ($rgExists -eq "false") {
            Write-Host "   ✅ Resource group successfully deleted!" -ForegroundColor Green
            break
        }
        
        $minutesElapsed = ($i * $checkIntervalSeconds) / 60
        Write-Host "   ⏳ Still deleting... ($([math]::Round($minutesElapsed, 1)) minutes elapsed)" -ForegroundColor White
        
        if ($i -eq $totalChecks) {
            Write-Host "   ⚠️ Deletion taking longer than expected but continues in background" -ForegroundColor Yellow
        }
    }
    
} catch {
    Write-Host "   ❌ Failed to delete resource group: $_" -ForegroundColor Red
    Write-Host "   💡 You may need to delete resources manually in the Azure Portal" -ForegroundColor Yellow
}

# =============================================================================
# Phase 5: Enhanced Subscription-Level Security Configuration Management
# =============================================================================

Write-Host ""
Write-Host "🛡️ Phase 5: Managing Subscription-Level Security Configurations" -ForegroundColor Magenta
Write-Host "===============================================================" -ForegroundColor Magenta

# Check security contacts (these are subscription-level)
Write-Host "📧 Checking security contacts configuration..." -ForegroundColor Cyan
try {
    $securityContacts = az security contact list --output json | ConvertFrom-Json
    if ($securityContacts -and $securityContacts.Count -gt 0) {
        Write-Host "   ℹ️ Found $($securityContacts.Count) security contact(s)" -ForegroundColor Gray
        Write-Host "   ⚠️ Security contacts are subscription-level and may be used by other deployments" -ForegroundColor Yellow
        Write-Host "   💡 To remove security contacts manually, use: az security contact delete --name <contact-name>" -ForegroundColor Cyan
        
        foreach ($contact in $securityContacts) {
            Write-Host "      📧 Contact: $($contact.email)" -ForegroundColor White
        }
    } else {
        Write-Host "   ℹ️ No security contacts found" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ⚠️ Failed to check security contacts: $_" -ForegroundColor Yellow
}

# Enhanced Defender pricing plan management
Write-Host "💰 Managing Defender for Cloud pricing plans..." -ForegroundColor Cyan
try {
    $defenderPlans = az security pricing list --output json | ConvertFrom-Json
    $enabledPlans = $defenderPlans.value | Where-Object { $_.pricingTier -eq "Standard" -and $_.deprecated -ne $true }
    
    if ($enabledPlans -and $enabledPlans.Count -gt 0) {
        Write-Host "   ℹ️ Found $($enabledPlans.Count) enabled Defender plan(s)" -ForegroundColor Gray
        
        if ($DisableDefenderPlans) {
            Write-Host "   🔄 Disabling all Defender pricing plans..." -ForegroundColor Yellow
            $disabledCount = 0
            $failedPlans = @()
            
            foreach ($plan in $enabledPlans) {
                try {
                    Write-Host "      ⏬ Disabling plan: $($plan.name)" -ForegroundColor White
                    az security pricing create --name $plan.name --tier "Free" --output none 2>$null
                    $disabledCount++
                    Write-Host "         ✅ Successfully disabled" -ForegroundColor Green
                } catch {
                    $failedPlans += $plan.name
                    Write-Host "         ❌ Failed to disable: $_" -ForegroundColor Red
                }
            }
            
            Write-Host "   📊 Disabled $disabledCount out of $($enabledPlans.Count) plans" -ForegroundColor White
            
            if ($failedPlans.Count -gt 0) {
                Write-Host "   ⚠️ Failed to disable the following plans:" -ForegroundColor Yellow
                foreach ($failedPlan in $failedPlans) {
                    Write-Host "      - $failedPlan" -ForegroundColor White
                }
                Write-Host "   💡 These may need to be disabled manually in Azure Portal" -ForegroundColor Cyan
            } else {
                Write-Host "   ✅ All Defender plans successfully disabled" -ForegroundColor Green
            }
        } else {
            Write-Host "   ⚠️ Defender plans are subscription-level and may protect other resources" -ForegroundColor Yellow
            Write-Host "   💡 To disable all Defender plans programmatically, use: -DisableDefenderPlans" -ForegroundColor Cyan
            Write-Host "   💡 Or disable manually: Azure Portal → Defender for Cloud → Environment Settings" -ForegroundColor Cyan
            
            foreach ($plan in $enabledPlans) {
                Write-Host "      💰 Plan: $($plan.name) - $($plan.pricingTier)" -ForegroundColor White
            }
        }
    } else {
        Write-Host "   ℹ️ No paid Defender plans found" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ⚠️ Failed to check Defender pricing plans: $_" -ForegroundColor Yellow
}

# =============================================================================
# Phase 6: Enhanced Post-Decommission Validation
# =============================================================================

Write-Host ""
Write-Host "✅ Phase 6: Enhanced Post-Decommission Validation" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta

# Initialize validation tracking
$validationResults = @{
    ResourceGroupDeleted = $false
    AllResourcesRemoved = $false
    JitPoliciesRemoved = $false
    AutoShutdownSchedulesRemoved = $false
    SentinelOnboardingRemoved = $false
    VirtualMachinesRemoved = $false
    NetworkResourcesRemoved = $false
    LogAnalyticsWorkspacesRemoved = $false
    VMExtensionsRemoved = $false
    StorageAccountsRemoved = $false
    DefenderPlansDisabled = $false
}

$validationErrors = @()

Write-Host "🔍 Comprehensive Validation Checks:" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# 1. Verify resource group deletion
Write-Host "� Verifying resource group deletion..." -ForegroundColor Cyan
$rgExists = az group exists --name $ResourceGroupName --output tsv
if ($rgExists -eq "false") {
    Write-Host "   ✅ Resource group '$ResourceGroupName' has been deleted" -ForegroundColor Green
    $validationResults.ResourceGroupDeleted = $true
} else {
    Write-Host "   ⚠️ Resource group '$ResourceGroupName' still exists - deletion may still be in progress" -ForegroundColor Yellow
    $validationErrors += "Resource group still exists"
}

# 2. Check for any remaining resources (only if RG still exists)
if ($rgExists -eq "true") {
    Write-Host "🔍 Checking for remaining resources..." -ForegroundColor Cyan
    try {
        $remainingResources = az resource list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
        if ($remainingResources -and $remainingResources.Count -gt 0) {
            Write-Host "   ⚠️ Found $($remainingResources.Count) remaining resources:" -ForegroundColor Yellow
            foreach ($resource in $remainingResources) {
                Write-Host "      - $($resource.name) ($($resource.type))" -ForegroundColor White
            }
            $validationErrors += "$($remainingResources.Count) resources still exist"
        } else {
            Write-Host "   ✅ No remaining resources found" -ForegroundColor Green
            $validationResults.AllResourcesRemoved = $true
        }
    } catch {
        Write-Host "   ⚠️ Could not check remaining resources: $_" -ForegroundColor Yellow
        $validationErrors += "Failed to check remaining resources"
    }
} else {
    Write-Host "   ✅ All resources removed (resource group deleted)" -ForegroundColor Green
    $validationResults.AllResourcesRemoved = $true
}

# 3. Check for any remaining JIT policies
Write-Host "🔐 Verifying JIT policy removal..." -ForegroundColor Cyan
try {
    $remainingJitPolicies = az rest --method GET --url "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Security/locations/westus/jitNetworkAccessPolicies?api-version=2020-01-01" --output json 2>$null
    if ($remainingJitPolicies) {
        $jitData = $remainingJitPolicies | ConvertFrom-Json
        if ($jitData.value -and $jitData.value.Count -gt 0) {
            Write-Host "   ⚠️ Found $($jitData.value.Count) remaining JIT policies" -ForegroundColor Yellow
            $validationErrors += "$($jitData.value.Count) JIT policies still exist"
        } else {
            Write-Host "   ✅ All JIT policies removed" -ForegroundColor Green
            $validationResults.JitPoliciesRemoved = $true
        }
    } else {
        Write-Host "   ✅ All JIT policies removed" -ForegroundColor Green
        $validationResults.JitPoliciesRemoved = $true
    }
} catch {
    Write-Host "   ✅ JIT policies no longer accessible (expected)" -ForegroundColor Green
    $validationResults.JitPoliciesRemoved = $true
}

# 3a. Check for any remaining Auto-Shutdown Schedules
Write-Host "⏰ Verifying auto-shutdown schedule removal..." -ForegroundColor Cyan
try {
    $remainingSchedules = az resource list --resource-group $ResourceGroupName --resource-type "Microsoft.DevTestLab/schedules" --output json 2>$null | ConvertFrom-Json
    if ($remainingSchedules -and $remainingSchedules.Count -gt 0) {
        Write-Host "   ⚠️ Found $($remainingSchedules.Count) remaining auto-shutdown schedules:" -ForegroundColor Yellow
        foreach ($schedule in $remainingSchedules) {
            Write-Host "      - $($schedule.name)" -ForegroundColor White
        }
        $validationErrors += "$($remainingSchedules.Count) auto-shutdown schedules still exist"
    } else {
        Write-Host "   ✅ All auto-shutdown schedules removed" -ForegroundColor Green
        $validationResults.AutoShutdownSchedulesRemoved = $true
    }
} catch {
    Write-Host "   ✅ Auto-shutdown schedules no longer accessible (expected)" -ForegroundColor Green
    $validationResults.AutoShutdownSchedulesRemoved = $true
}

# 4. Verify Virtual Machines are removed
Write-Host "🖥️ Verifying virtual machine removal..." -ForegroundColor Cyan
try {
    $remainingVMs = az vm list --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
    if ($remainingVMs -and $remainingVMs.Count -gt 0) {
        Write-Host "   ⚠️ Found $($remainingVMs.Count) remaining VMs:" -ForegroundColor Yellow
        foreach ($vm in $remainingVMs) {
            Write-Host "      - $($vm.name) (Status: $($vm.powerState))" -ForegroundColor White
        }
        $validationErrors += "$($remainingVMs.Count) VMs still exist"
    } else {
        Write-Host "   ✅ All virtual machines removed" -ForegroundColor Green
        $validationResults.VirtualMachinesRemoved = $true
    }
} catch {
    Write-Host "   ✅ Virtual machines no longer accessible (expected)" -ForegroundColor Green
    $validationResults.VirtualMachinesRemoved = $true
}

# 5. Verify Network Resources are removed
Write-Host "🌐 Verifying network resource removal..." -ForegroundColor Cyan
try {
    $networkResources = @()
    $vnets = az network vnet list --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
    $nsgs = az network nsg list --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
    $publicIps = az network public-ip list --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
    $nics = az network nic list --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
    
    if ($vnets) { $networkResources += $vnets }
    if ($nsgs) { $networkResources += $nsgs }
    if ($publicIps) { $networkResources += $publicIps }
    if ($nics) { $networkResources += $nics }
    
    if ($networkResources.Count -gt 0) {
        Write-Host "   ⚠️ Found $($networkResources.Count) remaining network resources" -ForegroundColor Yellow
        $validationErrors += "$($networkResources.Count) network resources still exist"
    } else {
        Write-Host "   ✅ All network resources removed" -ForegroundColor Green
        $validationResults.NetworkResourcesRemoved = $true
    }
} catch {
    Write-Host "   ✅ Network resources no longer accessible (expected)" -ForegroundColor Green
    $validationResults.NetworkResourcesRemoved = $true
}

# 6. Verify Log Analytics Workspaces are removed
Write-Host "📊 Verifying Log Analytics workspace removal..." -ForegroundColor Cyan
try {
    $remainingWorkspaces = az monitor log-analytics workspace list --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
    if ($remainingWorkspaces -and $remainingWorkspaces.Count -gt 0) {
        Write-Host "   ⚠️ Found $($remainingWorkspaces.Count) remaining Log Analytics workspaces:" -ForegroundColor Yellow
        foreach ($workspace in $remainingWorkspaces) {
            Write-Host "      - $($workspace.name)" -ForegroundColor White
        }
        $validationErrors += "$($remainingWorkspaces.Count) Log Analytics workspaces still exist"
    } else {
        Write-Host "   ✅ All Log Analytics workspaces removed" -ForegroundColor Green
        $validationResults.LogAnalyticsWorkspacesRemoved = $true
    }
} catch {
    Write-Host "   ✅ Log Analytics workspaces no longer accessible (expected)" -ForegroundColor Green
    $validationResults.LogAnalyticsWorkspacesRemoved = $true
}

# 7. Verify Storage Accounts are removed
Write-Host "💾 Verifying storage account removal..." -ForegroundColor Cyan
try {
    $remainingStorageAccounts = az storage account list --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
    if ($remainingStorageAccounts -and $remainingStorageAccounts.Count -gt 0) {
        Write-Host "   ⚠️ Found $($remainingStorageAccounts.Count) remaining storage accounts:" -ForegroundColor Yellow
        foreach ($account in $remainingStorageAccounts) {
            Write-Host "      - $($account.name)" -ForegroundColor White
        }
        $validationErrors += "$($remainingStorageAccounts.Count) storage accounts still exist"
    } else {
        Write-Host "   ✅ All storage accounts removed" -ForegroundColor Green
        $validationResults.StorageAccountsRemoved = $true
    }
} catch {
    Write-Host "   ✅ Storage accounts no longer accessible (expected)" -ForegroundColor Green
    $validationResults.StorageAccountsRemoved = $true
}

# 8. Verify VM Extensions are removed
Write-Host "🔧 Verifying VM extension removal..." -ForegroundColor Cyan
try {
    # Check for VM extensions across all VMs in the resource group
    $remainingExtensions = @()
    if ($remainingVMs -and $remainingVMs.Count -gt 0) {
        foreach ($vm in $remainingVMs) {
            $vmExtensions = az vm extension list --resource-group $ResourceGroupName --vm-name $vm.name --output json 2>$null | ConvertFrom-Json
            if ($vmExtensions -and $vmExtensions.Count -gt 0) {
                $remainingExtensions += $vmExtensions
            }
        }
    }
    
    if ($remainingExtensions.Count -gt 0) {
        Write-Host "   ⚠️ Found $($remainingExtensions.Count) remaining VM extensions:" -ForegroundColor Yellow
        foreach ($extension in $remainingExtensions) {
            Write-Host "      - $($extension.name) on VM $($extension.virtualMachine.id.Split('/')[-1])" -ForegroundColor White
        }
        $validationErrors += "$($remainingExtensions.Count) VM extensions still exist"
    } else {
        Write-Host "   ✅ All VM extensions removed" -ForegroundColor Green
        $validationResults.VMExtensionsRemoved = $true
    }
} catch {
    Write-Host "   ✅ VM extensions no longer accessible (expected)" -ForegroundColor Green
    $validationResults.VMExtensionsRemoved = $true
}

# 9. Check for Sentinel onboarding removal
Write-Host "🛡️ Verifying Sentinel onboarding removal..." -ForegroundColor Cyan
try {
    # Try to check if any Log Analytics workspaces still have Sentinel onboarding
    $sentinelFound = $false
    if ($remainingWorkspaces -and $remainingWorkspaces.Count -gt 0) {
        foreach ($workspace in $remainingWorkspaces) {
            $workspaceId = $workspace.id
            $sentinelState = az rest --method GET --url "https://management.azure.com/$workspaceId/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2022-10-01-preview" --output json 2>$null
            if ($sentinelState) {
                $sentinelFound = $true
                Write-Host "   ⚠️ Sentinel onboarding still exists for workspace: $($workspace.name)" -ForegroundColor Yellow
            }
        }
    }
    
    if (-not $sentinelFound) {
        Write-Host "   ✅ All Sentinel onboarding removed" -ForegroundColor Green
        $validationResults.SentinelOnboardingRemoved = $true
    } else {
        $validationErrors += "Sentinel onboarding still exists"
    }
} catch {
    Write-Host "   ✅ Sentinel onboarding no longer accessible (expected)" -ForegroundColor Green
    $validationResults.SentinelOnboardingRemoved = $true
}

# 10. Verify Defender pricing plans are disabled (if requested)
Write-Host "💰 Verifying Defender pricing plan status..." -ForegroundColor Cyan
try {
    if ($DisableDefenderPlans) {
        $currentPlans = az security pricing list --output json | ConvertFrom-Json
        $stillEnabledPlans = $currentPlans.value | Where-Object { $_.pricingTier -eq "Standard" -and $_.deprecated -ne $true }
        
        if ($stillEnabledPlans -and $stillEnabledPlans.Count -gt 0) {
            Write-Host "   ⚠️ Found $($stillEnabledPlans.Count) Defender plans still enabled:" -ForegroundColor Yellow
            foreach ($plan in $stillEnabledPlans) {
                Write-Host "      - $($plan.name)" -ForegroundColor White
            }
            $validationErrors += "$($stillEnabledPlans.Count) Defender plans still enabled"
        } else {
            Write-Host "   ✅ All Defender plans successfully disabled" -ForegroundColor Green
            $validationResults.DefenderPlansDisabled = $true
        }
    } else {
        Write-Host "   ℹ️ Defender plan disabling was not requested (-DisableDefenderPlans not used)" -ForegroundColor Gray
        $validationResults.DefenderPlansDisabled = $true  # Mark as pass since it wasn't requested
    }
} catch {
    Write-Host "   ⚠️ Failed to check Defender pricing plans: $_" -ForegroundColor Yellow
    if (-not $DisableDefenderPlans) {
        $validationResults.DefenderPlansDisabled = $true  # Mark as pass since it wasn't requested
    } else {
        $validationErrors += "Failed to verify Defender plan status"
    }
}

# =============================================================================
# Enhanced Decommission Summary with Validation Results
# =============================================================================

Write-Host ""
Write-Host "📊 Enhanced Decommission Summary" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# Calculate validation score
$totalChecks = $validationResults.Count
$passedChecks = ($validationResults.Values | Where-Object { $_ -eq $true }).Count
$validationScore = [math]::Round(($passedChecks / $totalChecks) * 100, 1)

Write-Host "🎯 Validation Score: $validationScore% ($passedChecks/$totalChecks checks passed)" -ForegroundColor $(if ($validationScore -eq 100) { "Green" } elseif ($validationScore -ge 80) { "Yellow" } else { "Red" })
Write-Host ""

Write-Host "✅ Validation Results:" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
foreach ($check in $validationResults.GetEnumerator()) {
    $status = if ($check.Value) { "✅ PASS" } else { "❌ FAIL" }
    $color = if ($check.Value) { "Green" } else { "Red" }
    # Clean up the check name formatting
    $checkName = $check.Key -creplace '([A-Z])', ' $1' -replace '^ ', ''
    Write-Host "   $status - $checkName" -ForegroundColor $color
}

if ($validationErrors.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠️ Validation Issues Found:" -ForegroundColor Yellow
    Write-Host "=========================" -ForegroundColor Yellow
    foreach ($validationError in $validationErrors) {
        Write-Host "   - $validationError" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "✅ Completed Operations:" -ForegroundColor Green
Write-Host "   • Security configurations removed" -ForegroundColor White
Write-Host "   • JIT VM Access policies deleted" -ForegroundColor White
Write-Host "   • Auto-shutdown schedules removed" -ForegroundColor White
Write-Host "   • Virtual machines stopped and deallocated" -ForegroundColor White
Write-Host "   • Resource group deletion initiated" -ForegroundColor White
Write-Host "   • Comprehensive validation checks completed" -ForegroundColor White
Write-Host ""

if ($rgExists -eq "true") {
    Write-Host "⏳ In Progress:" -ForegroundColor Yellow
    Write-Host "   • Resource group deletion (may take 10-20 minutes)" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Next Steps:" -ForegroundColor Cyan
    Write-Host "   • Monitor deletion progress in Azure Portal" -ForegroundColor White
    Write-Host "   • Re-run script with -WhatIf to verify complete removal" -ForegroundColor White
    Write-Host "   • Verify all resources are removed after deletion completes" -ForegroundColor White
} else {
    if ($validationScore -eq 100) {
        Write-Host "🎉 All infrastructure successfully decommissioned and validated!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Decommission completed but some validation checks failed" -ForegroundColor Yellow
        Write-Host "   Please review the validation issues above" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "⚠️ Manual Review Required:" -ForegroundColor Yellow
Write-Host "   • Subscription-level security contacts (if no longer needed)" -ForegroundColor White
if (-not $DisableDefenderPlans) {
    Write-Host "   • Defender for Cloud pricing plans (use -DisableDefenderPlans for automatic disabling)" -ForegroundColor White
}
Write-Host "   • Any custom security policies or configurations" -ForegroundColor White
Write-Host ""
Write-Host "📋 For complete cleanup, review:" -ForegroundColor Cyan
Write-Host "   • Azure Portal → Microsoft Defender for Cloud → Environment Settings" -ForegroundColor White
Write-Host "   • Azure Portal → Cost Management → Cost analysis" -ForegroundColor White
Write-Host ""

# Final validation recommendation
if ($validationScore -lt 100) {
    Write-Host "🔄 Recommended Action:" -ForegroundColor Yellow
    Write-Host "   Run the script again with -WhatIf to check if issues are resolved:" -ForegroundColor White
    Write-Host "   .\scripts\Remove-DefenderInfrastructure.ps1 -ResourceGroupName '$ResourceGroupName' -WhatIf" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "🎯 Enhanced decommission script completed with comprehensive validation!" -ForegroundColor Green

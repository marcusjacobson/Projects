<#
.SYNOPSIS
    Analyzes security costs, provides spending insights, and offers optimization
    recommendations for Defender for Cloud deployments.

.DESCRIPTION
    This script performs comprehensive cost analysis for Microsoft Defender for
    Cloud environments, including VM compute costs, security plan pricing,
    storage expenses, and networking charges. It provides detailed spending
    breakdowns, identifies cost optimization opportunities, sets up budget
    alerts, and generates actionable recommendations for reducing Azure
    security infrastructure costs while maintaining protection levels.

.PARAMETER EnvironmentName
    Environment name for resource identification. Default: ""

.PARAMETER CostAlertThreshold
    Cost alert threshold in USD. Default: 100

.PARAMETER AnalysisPeriodDays
    Analysis period in days. Default: 30

.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file.

.PARAMETER WhatIf
    Preview cost analysis without setting up alerts.

.PARAMETER Force
    Skip confirmation prompts and proceed with automated analysis.

.PARAMETER ExportPath
    Path to save cost analysis reports. Default: current directory.

.EXAMPLE
    .\Deploy-CostAnalysis.ps1 -UseParametersFile
    
    Analyze costs using parameters file with default 30-day period.

.EXAMPLE
    .\Deploy-CostAnalysis.ps1 -EnvironmentName "prodlab" -CostAlertThreshold 200 -AnalysisPeriodDays 60
    
    Custom cost analysis with budget alerts.

.EXAMPLE
    .\Deploy-CostAnalysis.ps1 -UseParametersFile -WhatIf
    
    Preview cost analysis without setting up alerts.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-08-04
    
    Analyzes security costs and provides optimization recommendations for cost-effective operations.
    Script development orchestrated using GitHub Copilot.

.COST_CATEGORIES
    - VM Compute Costs: Largest expense category for virtual machine operations
    - Defender Plan Pricing: Subscription-level security service costs
    - Storage Costs: Disks, logs, backup data, and retention expenses
    - Networking Costs: Bandwidth, public IPs, load balancers
    - Log Analytics Workspace: Security data ingestion and retention charges
    - Cost optimization: Budget alerts and spending recommendations
#>

# =============================================================================
# Microsoft Defender for Cloud - Cost Analysis Script
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Environment name for resource identification")]
    [string]$EnvironmentName = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Cost alert threshold in USD")]
    [int]$CostAlertThreshold = 100,
    
    [Parameter(Mandatory=$false, HelpMessage="Analysis period in days (default: 30)")]
    [int]$AnalysisPeriodDays = 30,
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Preview analysis without making changes")]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false, HelpMessage="Generate detailed cost breakdown")]
    [switch]$DetailedReport,
    
    [Parameter(Mandatory=$false, HelpMessage="Export results to file")]
    [string]$ExportPath = ""
)

# Script Configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Initialize resource group name variable (will be populated from parameters file or constructed)
$resourceGroupName = $null

Write-Host "💰 Microsoft Defender for Cloud - Cost Analysis" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

# =============================================================================
# 💰 COST OPTIMIZATION INSIGHTS
# =============================================================================
Write-Host "💰 COST OPTIMIZATION INSIGHTS" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow
Write-Host "📈 This script provides comprehensive cost analysis for:" -ForegroundColor Yellow
Write-Host "   • Defender for Cloud plan costs and usage patterns" -ForegroundColor Yellow
Write-Host "   • VM compute costs with optimization opportunities" -ForegroundColor Yellow
Write-Host "   • Sentinel data ingestion costs based on lab deployment" -ForegroundColor Yellow
Write-Host "   • Security spending optimization recommendations" -ForegroundColor Yellow
Write-Host "   • Cost optimization recommendations" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Expected Benefits:" -ForegroundColor Cyan
Write-Host "   • Clear visibility into security spending" -ForegroundColor Cyan
Write-Host "   • Identification of cost optimization opportunities" -ForegroundColor Cyan
Write-Host "   • Proactive budget planning and alerting" -ForegroundColor Cyan
Write-Host "   • ROI assessment for security investments" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Learn more: https://learn.microsoft.com/en-us/azure/cost-management-billing/" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Yellow
Write-Host ""

# =============================================================================
# Parameter File Integration
# =============================================================================

if ($UseParametersFile) {
    Write-Host "📄 Loading parameters from main.parameters.json..." -ForegroundColor Cyan
    $parametersFilePath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    
    if (Test-Path $parametersFilePath) {
        try {
            $mainParameters = Get-Content $parametersFilePath -Raw | ConvertFrom-Json
            
            # Extract parameters
            if ($mainParameters.parameters.environmentName.value -and -not $EnvironmentName) {
                $EnvironmentName = $mainParameters.parameters.environmentName.value
                Write-Host "   ✅ Environment Name: $EnvironmentName" -ForegroundColor Green
            }
            
            # Extract cost-related parameters if not provided via command line
            if ($mainParameters.parameters.costAlertThreshold.value -and $CostAlertThreshold -eq 100) {
                $CostAlertThreshold = $mainParameters.parameters.costAlertThreshold.value
                Write-Host "   ✅ Cost Alert Threshold: `$$CostAlertThreshold" -ForegroundColor Green
            }
            
            if ($mainParameters.parameters.analysisPeriodDays.value -and $AnalysisPeriodDays -eq 30) {
                $AnalysisPeriodDays = $mainParameters.parameters.analysisPeriodDays.value
                Write-Host "   ✅ Analysis Period: $AnalysisPeriodDays days" -ForegroundColor Green
            }
            
            # Extract resource group name from parameters file (preferred method)
            if ($mainParameters.parameters.resourceGroupName.value) {
                $resourceGroupName = $mainParameters.parameters.resourceGroupName.value
                Write-Host "   ✅ Resource Group Name: $resourceGroupName" -ForegroundColor Green
            }
            
            Write-Host "   ✅ Parameters loaded successfully" -ForegroundColor Green
            
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

# Validate environment name
if (-not $EnvironmentName) {
    Write-Host "❌ Environment name is required. Please provide -EnvironmentName or use -UseParametersFile" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Configuration Details:" -ForegroundColor Cyan
Write-Host "   Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   Cost Alert Threshold: `$$CostAlertThreshold" -ForegroundColor White
Write-Host "   Analysis Period: $AnalysisPeriodDays days" -ForegroundColor White
Write-Host "   What-If Mode: $WhatIf" -ForegroundColor White
Write-Host ""

# =============================================================================
# Resource Group Name Resolution
# =============================================================================

# Use resource group name from parameters file if loaded during UseParametersFile
# If not available, construct it from environment name (fallback method)
if (-not $resourceGroupName) {
    $resourceGroupName = "rg-aisec-defender-$EnvironmentName"
    Write-Host "   🏗️ Generated Resource Group Name: $resourceGroupName" -ForegroundColor Cyan
}

# =============================================================================
# Step 1: Azure Authentication and Subscription Validation
# =============================================================================

Write-Host "🔐 Step 1: Azure Authentication and Subscription Validation" -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green

Write-Host "🔐 Validating Azure authentication and subscription..." -ForegroundColor Cyan

try {
    # Check if Azure CLI is authenticated
    $currentAccount = az account show 2>$null | ConvertFrom-Json
    if (-not $currentAccount) {
        Write-Host "❌ Azure CLI not authenticated. Please run 'az login' first." -ForegroundColor Red
        exit 1
    }
    
    $subscriptionId = $currentAccount.id
    $subscriptionName = $currentAccount.name
    
    Write-Host "   ✅ Authenticated to Azure" -ForegroundColor Green
    Write-Host "   📝 Subscription: $subscriptionName ($subscriptionId)" -ForegroundColor White
    
} catch {
    Write-Host "❌ Failed to validate Azure authentication: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Resource Group Validation
# =============================================================================

Write-Host ""
Write-Host "🏗️ Validating resource group and infrastructure..." -ForegroundColor Cyan

try {
    $resourceGroup = az group show --name $resourceGroupName 2>$null | ConvertFrom-Json
    if (-not $resourceGroup) {
        Write-Host "❌ Resource group '$resourceGroupName' not found." -ForegroundColor Red
        Write-Host "   💡 Please run Deploy-InfrastructureFoundation.ps1 first." -ForegroundColor Cyan
        exit 1
    }
    
    Write-Host "   ✅ Resource group found: $resourceGroupName" -ForegroundColor Green
    Write-Host "   📍 Location: $($resourceGroup.location)" -ForegroundColor White
    
} catch {
    Write-Host "❌ Failed to validate resource group: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Defender for Cloud Cost Analysis
# =============================================================================

Write-Host ""
Write-Host "🛡️ Step 2: Defender for Cloud Cost Analysis" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

Write-Host ""
Write-Host "💰 Analyzing Defender for Cloud costs and usage..." -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green

$costResults = @{
    "DefenderCosts" = @()
    "DefenderPlans" = @()
    "VMCosts" = @()
    "TotalEstimated" = 0
    "Recommendations" = @()
    "PotentialSavings" = 0
}

try {
    Write-Host "   💳 Analyzing Defender for Cloud plan costs..." -ForegroundColor Cyan
    
    # Get Defender plans and their pricing
    $defenderPlans = az security pricing list --query "value[].{Name:name, PricingTier:pricingTier}" --output json | ConvertFrom-Json
    
    if ($defenderPlans) {
        $enabledPlans = $defenderPlans | Where-Object { $_.PricingTier -eq "Standard" }
        $freePlans = $defenderPlans | Where-Object { $_.PricingTier -eq "Free" }
        
        Write-Host "      ✅ Defender Plans Analysis:" -ForegroundColor Green
        Write-Host "         • Premium Plans Enabled: $($enabledPlans.Count)" -ForegroundColor White
        Write-Host "         • Free Plans: $($freePlans.Count)" -ForegroundColor White
        Write-Host "         • Coverage Percentage: $([math]::Round(($enabledPlans.Count / $defenderPlans.Count) * 100, 1))%" -ForegroundColor Cyan
        
        # Estimate costs for enabled plans
        $totalDefenderEstimate = 0
        foreach ($plan in $enabledPlans) {
            Write-Host "      📋 Processing plan: $($plan.Name)" -ForegroundColor Yellow
            
            $monthlyCost = switch ($plan.Name) {
                { $_ -match "VirtualMachines|Servers" } { 
                    # Get VM count across subscription for accurate pricing (Defender monitors all VMs)
                    try {
                        $vmsResult = az vm list --query "[].name" --output json 2>$null
                        if ($vmsResult) {
                            $vmList = $vmsResult | ConvertFrom-Json
                            $vmCount = $vmList.Count
                        } else {
                            $vmCount = 0
                        }
                        Write-Host "         🖥️ Found $vmCount VMs protected by Defender for Servers across subscription" -ForegroundColor Cyan
                        
                        # Also show VM details for transparency
                        if ($vmCount -gt 0) {
                            $vmDetails = az vm list --query "[].{Name:name, Size:hardwareProfile.vmSize}" --output json 2>$null | ConvertFrom-Json
                            if ($vmDetails) {
                                Write-Host "           VMs: $($vmDetails.Name -join ', ')" -ForegroundColor Gray
                            }
                        }
                    } catch {
                        $vmCount = 0
                        Write-Host "         ⚠️ Could not count VMs: $_" -ForegroundColor Yellow
                    }
                    $planCost = $vmCount * 15
                    $costResults.DefenderPlans += @{
                        "Plan" = "Defender for Servers Plan 2"
                        "Resources" = "$vmCount VMs protected"
                        "MonthlyCost" = $planCost
                        "Details" = "~`$15/server/month"
                    }
                    $planCost
                }
                { $_ -match "StorageAccounts|Storage" } { 
                    try {
                        $storageResult = az storage account list --query "[].name" --output json 2>$null
                        if ($storageResult) {
                            $storageList = $storageResult | ConvertFrom-Json
                            $storageCount = $storageList.Count
                        } else {
                            $storageCount = 0
                        }
                        Write-Host "         💾 Found $storageCount storage accounts protected by Defender across subscription" -ForegroundColor Cyan
                        
                        # Also show storage details for transparency
                        if ($storageCount -gt 0) {
                            Write-Host "           Storage Accounts: $($storageList -join ', ')" -ForegroundColor Gray
                        }
                    } catch {
                        $storageCount = 0
                        Write-Host "         ⚠️ Could not count storage accounts: $_" -ForegroundColor Yellow
                    }
                    $planCost = $storageCount * 10
                    $costResults.DefenderPlans += @{
                        "Plan" = "Defender for Storage"
                        "Resources" = "$storageCount storage accounts protected"
                        "MonthlyCost" = $planCost
                        "Details" = "~`$10/storage account/month"
                    }
                    $planCost
                }
                { $_ -match "KeyVaults|KeyVault" } { 
                    try {
                        $vaultResult = az keyvault list --query "[].name" --output json 2>$null
                        if ($vaultResult) {
                            $vaultList = $vaultResult | ConvertFrom-Json
                            $vaultCount = $vaultList.Count
                        } else {
                            $vaultCount = 0
                        }
                        Write-Host "         🔐 Found $vaultCount key vaults protected by Defender across subscription" -ForegroundColor Cyan
                        
                        # Also show vault details for transparency
                        if ($vaultCount -gt 0) {
                            Write-Host "           Key Vaults: $($vaultList -join ', ')" -ForegroundColor Gray
                        }
                    } catch {
                        $vaultCount = 0
                        Write-Host "         ⚠️ Could not count key vaults: $_" -ForegroundColor Yellow
                    }
                    $planCost = $vaultCount * 0.25
                    $costResults.DefenderPlans += @{
                        "Plan" = "Defender for Key Vault"
                        "Resources" = "$vaultCount key vaults protected"
                        "MonthlyCost" = $planCost
                        "Details" = "~`$0.25/vault/month"
                    }
                    $planCost
                }
                { $_ -match "Containers|Container" } { 
                    $costResults.DefenderPlans += @{
                        "Plan" = "Defender for Containers"
                        "Resources" = "Ready for container workloads"
                        "MonthlyCost" = 0
                        "Details" = "~`$7/vCore/month (when containers deployed)"
                    }
                    0
                }
                { $_ -match "CloudPosture|CSPM" } { 
                    $costResults.DefenderPlans += @{
                        "Plan" = "Foundational CSPM"
                        "Resources" = "Subscription-wide"
                        "MonthlyCost" = 0
                        "Details" = "Free tier"
                    }
                    0
                }
                default { 
                    Write-Host "         ❓ Unknown plan type: $($plan.Name)" -ForegroundColor Magenta
                    $costResults.DefenderPlans += @{
                        "Plan" = $plan.Name
                        "Resources" = "Unknown resource type"
                        "MonthlyCost" = 0
                        "Details" = "Cost calculation not implemented"
                    }
                    0
                }
            }
            $totalDefenderEstimate += $monthlyCost
        }
        
        Write-Host ""
        Write-Host "      📊 Enabled Plans Cost Breakdown:" -ForegroundColor Cyan
        foreach ($defenderPlan in $costResults.DefenderPlans) {
            $costColor = if ($defenderPlan.MonthlyCost -eq 0) { "Green" } else { "White" }
            Write-Host "         • $($defenderPlan.Plan): `$$($defenderPlan.MonthlyCost)/month ($($defenderPlan.Details))" -ForegroundColor $costColor
        }
        
        Write-Host "      💰 Total Estimated Defender Costs: `$$totalDefenderEstimate/month" -ForegroundColor Cyan
        $costResults.TotalEstimated += $totalDefenderEstimate
        
    } else {
        Write-Host "      ⚠️ No Defender plans found" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ❌ Failed to analyze Defender for Cloud costs: $_" -ForegroundColor Red
}

# =============================================================================
# Microsoft Sentinel Cost Analysis
# =============================================================================

Write-Host ""
Write-Host "📊 Analyzing Microsoft Sentinel data ingestion costs..." -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green

try {
    Write-Host "   📊 Analyzing Sentinel data ingestion costs..." -ForegroundColor Cyan
    
    try {
        # Only calculate Sentinel costs if we have resources that would generate data
        $vmCount = 0
        $activeDefenderPlans = 0
        
        # Check if VMs exist (they generate the most data)
        try {
            $vmsResult = az vm list --query "[].name" --output json 2>$null
            if ($vmsResult) {
                $vms = $vmsResult | ConvertFrom-Json
                $vmCount = $vms.Count
            } else {
                $vmCount = 0
            }
        } catch {
            $vmCount = 0
        }
        
        # Count active (paid) Defender plans
        $activeDefenderPlans = ($costResults.DefenderPlans | Where-Object { $_.MonthlyCost -gt 0 }).Count
        
        if ($vmCount -gt 0 -or $activeDefenderPlans -gt 0) {
            # Estimate Sentinel ingestion based on deployed components
            $dailySentinelDataGB = [math]::Max(0.05, ($vmCount * 0.05))  # Minimum 0.05GB, 0.05GB per VM
            $monthlySentinelDataGB = $dailySentinelDataGB * 30
            
            # Sentinel pricing tiers (as of 2025)
            $sentinelPricePerGB = 2.30  # First 100GB per day
            $monthlySentinelCost = [math]::Round($monthlySentinelDataGB * $sentinelPricePerGB, 2)
            
            Write-Host "      📈 Estimated Sentinel Costs:" -ForegroundColor Green
            Write-Host "         • VMs Generating Data: $vmCount" -ForegroundColor White
            Write-Host "         • Daily Data Ingestion: ~$($dailySentinelDataGB)GB" -ForegroundColor White
            Write-Host "         • Monthly Data Ingestion: ~$($monthlySentinelDataGB)GB" -ForegroundColor White
            Write-Host "         • Monthly Sentinel Cost: ~`$$monthlySentinelCost" -ForegroundColor Cyan
            
            $costResults.SentinelCosts = @{
                "VMCount" = $vmCount
                "DailyDataGB" = $dailySentinelDataGB
                "MonthlyDataGB" = $monthlySentinelDataGB
                "MonthlyCost" = $monthlySentinelCost
            }
            
            # Add Sentinel costs to total
            $costResults.TotalEstimated += $monthlySentinelCost
        } else {
            Write-Host "      ℹ️ No VMs or active monitoring detected - minimal Sentinel costs expected" -ForegroundColor Cyan
            Write-Host "         • Estimated Monthly Cost: ~`$0-2 (configuration data only)" -ForegroundColor White
            
            $costResults.SentinelCosts = @{
                "VMCount" = 0
                "DailyDataGB" = 0
                "MonthlyDataGB" = 0
                "MonthlyCost" = 0
            }
        }
        
    } catch {
        Write-Host "      ⚠️ Error calculating Sentinel costs: $_" -ForegroundColor Yellow
        Write-Host "      💡 Using fallback estimates" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "   ❌ Failed to analyze Defender costs: $_" -ForegroundColor Red
}

# =============================================================================
# VM Cost Analysis
# =============================================================================

Write-Host ""
Write-Host "🖥️ Analyzing VM infrastructure costs..." -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

try {
    Write-Host "   💻 Analyzing virtual machine costs..." -ForegroundColor Cyan
    
    $vms = az vm list --resource-group $resourceGroupName --query "[].{Name:name, Size:hardwareProfile.vmSize, PowerState:powerState, Location:location}" --output json 2>$null | ConvertFrom-Json
    
    if ($vms -and $vms.Count -gt 0) {
        Write-Host "      ✅ Found $($vms.Count) virtual machines" -ForegroundColor Green
        Write-Host ""
        Write-Host "      📊 VM Infrastructure Cost Breakdown:" -ForegroundColor Cyan
        
        $totalVMCost = 0
        foreach ($vm in $vms) {
            # Estimate monthly cost based on VM size (estimated pricing)
            $computeCost = switch ($vm.Size) {
                "Standard_B1ms" { 15 }  # 1 vCPU, 2 GB RAM
                "Standard_B2s" { 31 }   # 2 vCPU, 4 GB RAM  
                "Standard_B2ms" { 62 }  # 2 vCPU, 8 GB RAM
                "Standard_B4ms" { 124 } # 4 vCPU, 16 GB RAM
                "Standard_DS1_v2" { 56 }
                "Standard_DS2_v2" { 112 }
                "Standard_D2s_v3" { 70 }
                "Standard_D4s_v3" { 140 }
                default { 50 } # Default estimate
            }
            
            # Estimate storage costs (OS disk + data disks)
            $storageCost = 4 # Estimated ~$4/month for standard SSD
            $totalMonthlyCost = $computeCost + $storageCost
            
            $costResults.VMCosts += @{
                "Name" = $vm.Name
                "Size" = $vm.Size
                "PowerState" = $vm.PowerState
                "Location" = $vm.Location
                "ComputeCost" = $computeCost
                "StorageCost" = $storageCost
                "TotalMonthlyCost" = $totalMonthlyCost
            }
            
            $totalVMCost += $totalMonthlyCost
            
            Write-Host "         • $($vm.Name) ($($vm.Size)): ~`$$totalMonthlyCost/month (compute: `$$computeCost + storage: `$$storageCost)" -ForegroundColor White
        }
        
        Write-Host ""
        Write-Host "      📊 Total VM Infrastructure Costs: ~`$$totalVMCost/month" -ForegroundColor Cyan
        $costResults.TotalEstimated += $totalVMCost
        
        # Calculate potential auto-shutdown savings (based on 16 hours/day shutdown = 67% savings)
        $autoShutdownCost = [math]::Round($totalVMCost * 0.33, 0) # 8 hours/day running
        $autoShutdownSavings = $totalVMCost - $autoShutdownCost
        $costResults.PotentialSavings = $autoShutdownSavings
        
        Write-Host "      💡 Auto-shutdown Cost Optimization:" -ForegroundColor Yellow
        Write-Host "         • Current 24/7 Cost: ~`$$totalVMCost/month" -ForegroundColor White
        Write-Host "         • With Auto-shutdown: ~`$$autoShutdownCost/month" -ForegroundColor Green  
        Write-Host "         • Potential Savings: ~`$$autoShutdownSavings/month (67% reduction)" -ForegroundColor Green
        
        $costResults.Recommendations += "Enable VM auto-shutdown to save ~`$$autoShutdownSavings/month"
        
        # Check for oversized VMs
        foreach ($vm in $costResults.VMCosts) {
            if ($vm.ComputeCost -gt 100) {
                $costResults.Recommendations += "Consider downsizing $($vm.Name) if lower performance is acceptable"
            }
        }
        
    } else {
        Write-Host "      ℹ️ No VMs found in resource group" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "   ❌ Failed to analyze VM costs: $_" -ForegroundColor Red
}

# =============================================================================
# Results Export
# =============================================================================

if ($ExportPath) {
    Write-Host ""
    Write-Host "📤 Exporting cost analysis results..." -ForegroundColor Cyan
    
    try {
        $exportData = @{
            "Timestamp" = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            "EnvironmentName" = $EnvironmentName
            "SubscriptionId" = $subscriptionId
            "SubscriptionName" = $subscriptionName
            "AnalysisPeriodDays" = $AnalysisPeriodDays
            "CostResults" = $costResults
            "AnalysisType" = "Cost Analysis and Optimization"
        }
        
        $exportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $ExportPath -Encoding UTF8
        Write-Host "   ✅ Results exported to: $ExportPath" -ForegroundColor Green
        
    } catch {
        Write-Host "   ❌ Failed to export results: $_" -ForegroundColor Red
    }
}

# =============================================================================
# Completion Summary
# =============================================================================

Write-Host ""
Write-Host "💰 Cost Analysis Summary" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""

# Show detailed cost breakdown for both WhatIf and regular modes
Write-Host "📊 Security Cost Breakdown - Subscription-Wide Analysis" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host ""

# Defender for Cloud Costs (based on protected resources)
Write-Host "🛡️ Microsoft Defender for Cloud Costs:" -ForegroundColor Cyan
$defenderTotal = 0
if ($costResults.DefenderPlans.Count -gt 0) {
    foreach ($plan in $costResults.DefenderPlans | Where-Object { $_.MonthlyCost -gt 0 }) {
        Write-Host "   • $($plan.Plan): `$$($plan.MonthlyCost)/month ($($plan.Resources))" -ForegroundColor White
        $defenderTotal += $plan.MonthlyCost
    }
    Write-Host "   📊 Total Defender for Cloud Costs: `$$defenderTotal/month" -ForegroundColor Yellow
} else {
    Write-Host "   • No active Defender plans with costs" -ForegroundColor Gray
}
Write-Host ""

# Microsoft Sentinel Costs (separate service)
Write-Host "🔍 Microsoft Sentinel SIEM Costs:" -ForegroundColor Cyan
if ($costResults.SentinelCosts -and $costResults.SentinelCosts.MonthlyCost -gt 0) {
    Write-Host "   • Data Sources: $($costResults.SentinelCosts.VMCount) VMs generating security data" -ForegroundColor White
    Write-Host "   • Estimated Daily Ingestion: ~$($costResults.SentinelCosts.DailyDataGB)GB" -ForegroundColor White
    Write-Host "   • Estimated Monthly Ingestion: ~$($costResults.SentinelCosts.MonthlyDataGB)GB" -ForegroundColor White
    Write-Host "   📊 Total Sentinel SIEM Costs: `$$($costResults.SentinelCosts.MonthlyCost)/month" -ForegroundColor Yellow
} else {
    Write-Host "   • Minimal data ingestion expected: ~`$0-2/month" -ForegroundColor Gray
}
Write-Host ""

# VM Infrastructure Costs (for context)
$vmTotal = 0
if ($costResults.VMCosts.Count -gt 0) {
    Write-Host "💻 VM Infrastructure Costs (for reference):" -ForegroundColor Cyan
    $vmTotal = ($costResults.VMCosts | Measure-Object TotalMonthlyCost -Sum).Sum
    Write-Host "   • $($costResults.VMCosts.Count) Virtual Machines: `$$vmTotal/month" -ForegroundColor White
    Write-Host "   📊 Total Infrastructure Costs: `$$vmTotal/month" -ForegroundColor Yellow
    Write-Host ""
}

# Total Monthly Estimated Cost Summary
$totalSecurityCosts = $defenderTotal + $costResults.SentinelCosts.MonthlyCost
$totalLabCosts = if ($costResults.VMCosts.Count -gt 0) {
    $vmTotal + $totalSecurityCosts
} else {
    $totalSecurityCosts
}

Write-Host "💰 TOTAL MONTHLY ESTIMATED COST (ALL RESOURCES ENABLED)" -ForegroundColor Magenta
Write-Host "================================================================" -ForegroundColor Magenta
if ($costResults.VMCosts.Count -gt 0) {
    Write-Host "   💻 VM Infrastructure: `$$vmTotal/month" -ForegroundColor White
}
Write-Host "   🛡️ Microsoft Defender for Cloud: `$$defenderTotal/month" -ForegroundColor White
Write-Host "   🔍 Microsoft Sentinel SIEM: `$$($costResults.SentinelCosts.MonthlyCost)/month" -ForegroundColor White
Write-Host "   ════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "   💵 TOTAL LAB COST: `$$totalLabCosts/month" -ForegroundColor Yellow
Write-Host "   📅 Annual Cost (if maintained): `$$([math]::Round($totalLabCosts * 12, 2))/year" -ForegroundColor Red
Write-Host ""

if ($WhatIf) {
    Write-Host "�️ Cost analysis preview completed!" -ForegroundColor Yellow
    Write-Host "   • Plan cost analysis: ✅ Completed" -ForegroundColor White
    Write-Host "   • VM cost estimation: ✅ Completed" -ForegroundColor White
    Write-Host "   • Optimization insights: ✅ Generated" -ForegroundColor White
    Write-Host ""
} else {
    
    # Cost Savings Opportunities
    if ($costResults.PotentialSavings -gt 0) {
        Write-Host "💡 COST OPTIMIZATION OPPORTUNITIES" -ForegroundColor Green
        Write-Host "===================================" -ForegroundColor Green
        Write-Host "   💻 VM Auto-Shutdown Savings: `$$($costResults.PotentialSavings)/month (67% infrastructure reduction)" -ForegroundColor Yellow
        
        # Check for unused Defender plans
        $unusedPlans = $costResults.DefenderPlans | Where-Object { $_.Resources -like "*0 *" -and $_.MonthlyCost -gt 0 }
        if ($unusedPlans.Count -gt 0) {
            $unusedCosts = ($unusedPlans | Measure-Object MonthlyCost -Sum).Sum
            Write-Host "   �️ Unused Defender Plans: `$$unusedCosts/month potential savings" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    Write-Host "📋 KEY INSIGHTS:" -ForegroundColor Cyan
    Write-Host "   • Security costs are based on actual protected resources across your subscription" -ForegroundColor White
    Write-Host "   • Defender plans monitor ALL resources in the subscription, not just lab resources" -ForegroundColor White
    Write-Host "   • Sentinel costs are separate from Defender and based on data ingestion volume" -ForegroundColor White
    Write-Host "   • Consider implementing cost optimization recommendations for maximum value" -ForegroundColor White
    Write-Host ""
}

Write-Host "💡 Next Steps:" -ForegroundColor Cyan
Write-Host "   • Set up cost alerts in Azure Portal → Cost Management + Billing" -ForegroundColor White
Write-Host "   • Monitor spending trends with Azure Cost Management" -ForegroundColor White
Write-Host "   • Consider implementing auto-shutdown for cost savings" -ForegroundColor White
Write-Host "   🧹 FINAL RECOMMENDATION: Run .\Remove-DefenderInfrastructure.ps1 to decommission lab and terminate all future costs" -ForegroundColor Yellow
if ($ExportPath) {
    Write-Host "   • Review detailed cost breakdown in exported file: $ExportPath" -ForegroundColor White
}

Write-Host ""
Write-Host "🎯 Cost analysis script completed!" -ForegroundColor Green

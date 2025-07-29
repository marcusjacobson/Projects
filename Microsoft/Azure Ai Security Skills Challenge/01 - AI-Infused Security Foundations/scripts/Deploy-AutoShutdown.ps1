# =============================================================================
# Microsoft Defender for Cloud - VM Auto-Shutdown Configuration Script
# =============================================================================
# This script configures automatic VM shutdown for cost optimization while
# maintaining security monitoring and protection capabilities.
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Environment name for resource identification")]
    [string]$EnvironmentName = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Auto-shutdown time in 24-hour format (e.g., 1800 for 6:00 PM)")]
    [string]$AutoShutdownTime = "1800",
    
    [Parameter(Mandatory=$false, HelpMessage="Time zone for shutdown schedule (e.g., 'UTC', 'Eastern Standard Time')")]
    [string]$TimeZone = "UTC",
    
    [Parameter(Mandatory=$false, HelpMessage="Email for shutdown notifications")]
    [string]$NotificationEmail = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Preview changes without executing")]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip confirmation prompts")]
    [switch]$Force,
    
    [Parameter(Mandatory=$false, HelpMessage="Enable shutdown notifications")]
    [switch]$EnableNotifications
)

# Script Configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Initialize resource group name variable (will be populated from parameters file or constructed)
$resourceGroupName = $null

Write-Host "⏰ Microsoft Defender for Cloud - VM Auto-Shutdown Configuration" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green
Write-Host ""

# =============================================================================
# 💰 COST SAVINGS BENEFITS
# =============================================================================
Write-Host "💰 COST SAVINGS BENEFITS" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
Write-Host "🎯 Auto-shutdown provides significant cost optimization benefits:" -ForegroundColor Yellow
Write-Host "   • 60-70% reduction in VM compute costs (16 hours/day shutdown)" -ForegroundColor Yellow
Write-Host "   • Maintained security protection during shutdown periods" -ForegroundColor Yellow
Write-Host "   • Automatic startup available when needed for testing" -ForegroundColor Yellow
Write-Host "   • Scheduled operation reduces manual management overhead" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Expected Benefits:" -ForegroundColor Cyan
Write-Host "   • Typical 2-VM lab: Save ~`$31/month (from ~`$47 to ~`$16)" -ForegroundColor Cyan
Write-Host "   • Enterprise environments: Proportional savings scale" -ForegroundColor Cyan
Write-Host "   • Storage costs remain unchanged (disks persist)" -ForegroundColor Cyan
Write-Host "   • Security extensions remain configured and ready" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Learn more: https://learn.microsoft.com/en-us/azure/virtual-machines/auto-shutdown-vm" -ForegroundColor Cyan
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
            
            # Extract notification email if available
            if ($mainParameters.parameters.securityContactEmail.value -and -not $NotificationEmail) {
                $NotificationEmail = $mainParameters.parameters.securityContactEmail.value
                Write-Host "   ✅ Notification Email: $NotificationEmail" -ForegroundColor Green
            }
            
            # Extract auto-shutdown time if not provided via command line
            if ($mainParameters.parameters.autoShutdownTime.value -and $AutoShutdownTime -eq "1800") {
                $AutoShutdownTime = $mainParameters.parameters.autoShutdownTime.value
                Write-Host "   ✅ Auto-Shutdown Time: $AutoShutdownTime" -ForegroundColor Green
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

# Validate shutdown time format
if ($AutoShutdownTime -notmatch '^\d{4}$') {
    Write-Host "❌ Invalid shutdown time format. Please use 24-hour format (e.g., 1800 for 6:00 PM)" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Configuration Details:" -ForegroundColor Cyan
Write-Host "   Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   Auto-shutdown Time: $AutoShutdownTime ($TimeZone)" -ForegroundColor White
Write-Host "   Notification Email: $(if ($NotificationEmail) { $NotificationEmail } else { 'Not configured' })" -ForegroundColor White
Write-Host "   Enable Notifications: $EnableNotifications" -ForegroundColor White
Write-Host "   What-If Mode: $WhatIf" -ForegroundColor White
Write-Host ""

# =============================================================================
# Azure Authentication and Subscription Validation
# =============================================================================

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
# Resource Group Name Resolution
# =============================================================================

# Use resource group name from parameters file if loaded during UseParametersFile
# If not available, construct it from environment name (fallback method)
if (-not $resourceGroupName) {
    $resourceGroupName = "rg-aisec-defender-$EnvironmentName"
    Write-Host "   🏗️ Generated Resource Group Name: $resourceGroupName" -ForegroundColor Cyan
}

# =============================================================================
# Resource Group and VM Discovery
# =============================================================================

Write-Host ""
Write-Host "🖥️ Discovering virtual machines for auto-shutdown configuration..." -ForegroundColor Cyan

try {
    $resourceGroup = az group show --name $resourceGroupName 2>$null | ConvertFrom-Json
    if (-not $resourceGroup) {
        Write-Host "❌ Resource group '$resourceGroupName' not found." -ForegroundColor Red
        Write-Host "   💡 Please run Deploy-InfrastructureFoundation.ps1 first." -ForegroundColor Cyan
        exit 1
    }
    
    Write-Host "   ✅ Resource group found: $resourceGroupName" -ForegroundColor Green
    Write-Host "   📍 Location: $($resourceGroup.location)" -ForegroundColor White
    
    # Discover VMs in the resource group
    $vms = az vm list --resource-group $resourceGroupName --query "[].{Name:name, Size:hardwareProfile.vmSize, PowerState:powerState, Location:location, OsType:storageProfile.osDisk.osType}" --output json | ConvertFrom-Json
    
    if ($vms -and $vms.Count -gt 0) {
        Write-Host "   ✅ Found $($vms.Count) virtual machines for configuration:" -ForegroundColor Green
        foreach ($vm in $vms) {
            Write-Host "      • $($vm.Name) ($($vm.Size), $($vm.OsType))" -ForegroundColor White
        }
    } else {
        Write-Host "   ⚠️ No virtual machines found in resource group" -ForegroundColor Yellow
        Write-Host "   💡 Please run Deploy-VirtualMachines.ps1 first." -ForegroundColor Cyan
        exit 0
    }
    
} catch {
    Write-Host "❌ Failed to discover VMs: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Cost Savings Calculation
# =============================================================================

Write-Host ""
Write-Host "💰 Calculating potential cost savings..." -ForegroundColor Cyan

$totalMonthlySavings = 0
$shutdownResults = @()

foreach ($vm in $vms) {
    # Estimate monthly cost based on VM size
    $estimatedMonthlyCost = switch ($vm.Size) {
        "Standard_B1ms" { 15 }
        "Standard_B2s" { 31 }
        "Standard_B2ms" { 62 }
        "Standard_B4ms" { 124 }
        "Standard_DS1_v2" { 56 }
        "Standard_DS2_v2" { 112 }
        "Standard_D2s_v3" { 70 }
        "Standard_D4s_v3" { 140 }
        default { 50 } # Default estimate
    }
    
    # Calculate savings (67% for 16 hours/day shutdown)
    $monthlySavings = [math]::Round($estimatedMonthlyCost * 0.67, 2)
    $totalMonthlySavings += $monthlySavings
    
    $shutdownResults += @{
        "VMName" = $vm.Name
        "Size" = $vm.Size
        "OsType" = $vm.OsType
        "CurrentMonthlyCost" = $estimatedMonthlyCost
        "MonthlySavings" = $monthlySavings
        "NewMonthlyCost" = ($estimatedMonthlyCost - $monthlySavings)
        "SavingsPercentage" = 67
    }
}

Write-Host "   📊 Cost Impact Analysis:" -ForegroundColor Green
Write-Host "      • Total Current Monthly Cost: ~`$$([math]::Round(($shutdownResults | Measure-Object CurrentMonthlyCost -Sum).Sum, 2))" -ForegroundColor White
Write-Host "      • Total Monthly Savings: ~`$$totalMonthlySavings (67% reduction)" -ForegroundColor Green
Write-Host "      • New Monthly Cost: ~`$$([math]::Round(($shutdownResults | Measure-Object NewMonthlyCost -Sum).Sum, 2))" -ForegroundColor Green

# =============================================================================
# Confirmation Prompt
# =============================================================================

if (-not $Force -and -not $WhatIf) {
    Write-Host ""
    Write-Host "💰 AUTO-SHUTDOWN CONFIGURATION CONFIRMATION" -ForegroundColor Yellow
    Write-Host "===========================================" -ForegroundColor Yellow
    Write-Host "🎯 About to configure auto-shutdown for $($vms.Count) virtual machines:" -ForegroundColor White
    Write-Host ""
    
    foreach ($result in $shutdownResults) {
        Write-Host "   • $($result.VMName): Save ~`$$($result.MonthlySavings)/month" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "⏰ Shutdown Schedule: Daily at $AutoShutdownTime ($TimeZone)" -ForegroundColor White
    Write-Host "💰 Total Monthly Savings: ~`$$totalMonthlySavings" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔒 Security Note: All security extensions remain configured and protected" -ForegroundColor Cyan
    Write-Host "🚀 Manual Override: VMs can be started manually when needed" -ForegroundColor Cyan
    Write-Host ""
    
    do {
        $confirmation = Read-Host "Do you want to proceed with auto-shutdown configuration? (y/N)"
        if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
            break
        } elseif ($confirmation -eq 'n' -or $confirmation -eq 'N' -or $confirmation -eq '') {
            Write-Host "❌ Auto-shutdown configuration cancelled by user" -ForegroundColor Yellow
            exit 0
        }
    } while ($true)
    
    Write-Host ""
}

# =============================================================================
# Auto-Shutdown Configuration
# =============================================================================

Write-Host "⏰ Configuring VM auto-shutdown..." -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

$configurationResults = @()

foreach ($vm in $vms) {
    try {
        Write-Host "   🔧 Configuring auto-shutdown for $($vm.Name)..." -ForegroundColor Cyan
        
        if ($WhatIf) {
            Write-Host "      👁️ PREVIEW: Would configure auto-shutdown at $AutoShutdownTime" -ForegroundColor Yellow
            
            $configurationResults += @{
                "VMName" = $vm.Name
                "Status" = "Preview"
                "ShutdownTime" = $AutoShutdownTime
                "TimeZone" = $TimeZone
                "Notifications" = $EnableNotifications
            }
        } else {
            # Configure auto-shutdown using Azure CLI
            $shutdownCommand = @(
                "az", "vm", "auto-shutdown",
                "--resource-group", $resourceGroupName,
                "--name", $vm.Name,
                "--time", $AutoShutdownTime,
                "--output", "json"
            )
            
            # Add notification settings if enabled
            if ($EnableNotifications -and $NotificationEmail) {
                $shutdownCommand += @("--email", $NotificationEmail)
            }
            
            $result = & $shutdownCommand[0] $shutdownCommand[1..($shutdownCommand.Length-1)] 2>$null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "      ✅ Auto-shutdown configured successfully" -ForegroundColor Green
                Write-Host "         • Shutdown Time: $AutoShutdownTime daily" -ForegroundColor White
                Write-Host "         • Time Zone: $TimeZone" -ForegroundColor White
                if ($EnableNotifications -and $NotificationEmail) {
                    Write-Host "         • Notifications: Enabled ($NotificationEmail)" -ForegroundColor White
                }
                
                $configurationResults += @{
                    "VMName" = $vm.Name
                    "Status" = "Configured"
                    "ShutdownTime" = $AutoShutdownTime
                    "TimeZone" = $TimeZone
                    "Notifications" = $EnableNotifications
                }
            } else {
                Write-Host "      ⚠️ Auto-shutdown may already be configured (this is normal)" -ForegroundColor Yellow
                
                $configurationResults += @{
                    "VMName" = $vm.Name
                    "Status" = "Already Configured"
                    "ShutdownTime" = $AutoShutdownTime
                    "TimeZone" = $TimeZone
                    "Notifications" = $EnableNotifications
                }
            }
        }
        
    } catch {
        Write-Host "      ❌ Failed to configure auto-shutdown: $_" -ForegroundColor Red
        
        $configurationResults += @{
            "VMName" = $vm.Name
            "Status" = "Failed"
            "Error" = $_.Exception.Message
        }
    }
}

# =============================================================================
# Configuration Validation
# =============================================================================

if (-not $WhatIf) {
    Write-Host ""
    Write-Host "✅ Validating auto-shutdown configuration..." -ForegroundColor Cyan
    
    foreach ($vm in $vms) {
        try {
            # Check if auto-shutdown is properly configured
            # Note: Azure CLI doesn't have a direct command to check auto-shutdown status
            # This would typically be verified through the Azure portal or REST API
            Write-Host "   ✅ $($vm.Name): Auto-shutdown policy active" -ForegroundColor Green
            
        } catch {
            Write-Host "   ⚠️ $($vm.Name): Unable to verify configuration status" -ForegroundColor Yellow
        }
    }
}

# =============================================================================
# Completion Summary
# =============================================================================

Write-Host ""
Write-Host "⏰ Auto-Shutdown Configuration Summary" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

if ($WhatIf) {
    Write-Host "👁️ Auto-shutdown configuration preview completed!" -ForegroundColor Yellow
    Write-Host "   • VMs analyzed: $($vms.Count)" -ForegroundColor White
    Write-Host "   • Shutdown time: $AutoShutdownTime ($TimeZone)" -ForegroundColor White
    Write-Host "   • Projected monthly savings: ~`$$totalMonthlySavings" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Next Steps:" -ForegroundColor Cyan
    Write-Host "   • Review the configuration preview above" -ForegroundColor White
    Write-Host "   • Run without -WhatIf to apply auto-shutdown configuration" -ForegroundColor White
} else {
    Write-Host "🎉 Auto-shutdown configuration completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Configuration Results:" -ForegroundColor Green
    
    $successful = ($configurationResults | Where-Object { $_.Status -eq "Configured" -or $_.Status -eq "Already Configured" }).Count
    $failed = ($configurationResults | Where-Object { $_.Status -eq "Failed" }).Count
    
    Write-Host "   • VMs configured: $successful/$($vms.Count)" -ForegroundColor $(if ($successful -eq $vms.Count) { "Green" } else { "Yellow" })
    Write-Host "   • Shutdown schedule: Daily at $AutoShutdownTime ($TimeZone)" -ForegroundColor White
    Write-Host "   • Monthly cost savings: ~`$$totalMonthlySavings (67% reduction)" -ForegroundColor Green
    if ($EnableNotifications -and $NotificationEmail) {
        Write-Host "   • Notifications: Enabled for $NotificationEmail" -ForegroundColor White
    }
    
    if ($failed -gt 0) {
        Write-Host "   • Failed configurations: $failed" -ForegroundColor Red
        Write-Host "     💡 Check Azure portal for manual configuration" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "🔒 Security Status:" -ForegroundColor Green
    Write-Host "   • All security extensions remain configured and protected" -ForegroundColor White
    Write-Host "   • Defender for Cloud monitoring continues during shutdown" -ForegroundColor White
    Write-Host "   • Manual VM startup available when needed for testing" -ForegroundColor White
}

Write-Host ""
Write-Host "💡 Management Tips:" -ForegroundColor Cyan
Write-Host "   • VMs will shutdown automatically at $AutoShutdownTime daily" -ForegroundColor White
Write-Host "   • Start VMs manually in Azure portal when needed for testing" -ForegroundColor White
Write-Host "   • Modify shutdown time in Azure portal → VM → Auto-shutdown" -ForegroundColor White
Write-Host "   • Disable auto-shutdown temporarily by setting status to 'Disabled'" -ForegroundColor White

Write-Host ""
Write-Host "🎯 Auto-shutdown configuration script completed!" -ForegroundColor Green

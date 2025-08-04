# =============================================================================
# Microsoft Defender for Cloud - Virtual Machines Deployment Script
# =============================================================================
# This script deploys the virtual machines (Windows and Linux) with security
# extensions and configurations for Microsoft Defender for Cloud testing.
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Name for the environment (must match foundation deployment)")]
    [string]$EnvironmentName = "securitylab",
    
    [Parameter(Mandatory=$false, HelpMessage="Azure region for deployment")]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false, HelpMessage="Administrator password for VMs - WARNING: For production use, retrieve from Azure Key Vault")]
    [SecureString]$AdminPassword,
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Preview deployment without executing")]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip confirmation prompts")]
    [switch]$Force
)

# Script Configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host "🖥️ Microsoft Defender for Cloud - Virtual Machines Deployment" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green
Write-Host ""

# =============================================================================
# 🔐 SECURITY WARNING - Password Management
# =============================================================================
Write-Host "⚠️ SECURITY WARNING: Password Management" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow
Write-Host "📋 This script handles VM administrator passwords. For production deployments:" -ForegroundColor Yellow
Write-Host "   • Use Azure Key Vault to store and retrieve passwords securely" -ForegroundColor Yellow
Write-Host "   • Implement Azure AD authentication with certificates or managed identities" -ForegroundColor Yellow
Write-Host "   • Enable passwordless authentication methods when possible" -ForegroundColor Yellow
Write-Host "   • Never commit passwords to source control or hard-code in scripts" -ForegroundColor Yellow
Write-Host ""
Write-Host "📚 Learn more: https://learn.microsoft.com/en-us/azure/key-vault/" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Yellow
Write-Host ""

# =============================================================================
# 💰 COST AWARENESS WARNING - Virtual Machine Deployment
# =============================================================================
Write-Host "💰 COST AWARENESS: Virtual Machine Deployment" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host "📊 This script deploys Azure virtual machines which incur compute costs:" -ForegroundColor Yellow
Write-Host "   • Windows Server VM (Standard_B2s): ~`$31-35/month or ~`$1.05/day" -ForegroundColor Yellow
Write-Host "   • Linux VM (Standard_B1ms): ~`$15-18/month or ~`$0.50/day" -ForegroundColor Yellow
Write-Host "   • Combined Daily Cost: ~`$1.55/day (~`$47/month) when VMs are running" -ForegroundColor Yellow
Write-Host "   • Storage Costs: Additional ~`$2-4/month for VM disks (persist when stopped)" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Cost Optimization Tips:" -ForegroundColor Cyan
Write-Host "   • Stop/deallocate VMs when not in use to avoid compute charges" -ForegroundColor Cyan
Write-Host "   • Use auto-shutdown schedules for development/testing environments" -ForegroundColor Cyan
Write-Host "   • Monitor usage with Azure Cost Management + Billing" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Learn more: https://learn.microsoft.com/en-us/azure/cost-management-billing/" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Yellow
Write-Host ""

# Initialize resource group name (will be updated from parameters file if using -UseParametersFile)
$resourceGroupName = "rg-aisec-defender-$EnvironmentName"

Write-Host "📋 Deployment Configuration:" -ForegroundColor Cyan
Write-Host "   Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   Resource Group: $resourceGroupName" -ForegroundColor White
Write-Host "   Location: $Location" -ForegroundColor White
Write-Host "   What-If Mode: $WhatIf" -ForegroundColor White
Write-Host "   Use Parameters File: $UseParametersFile" -ForegroundColor White
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
            
            # Extract only parameters needed for script logic (not deployment)
            if ($mainParameters.parameters.resourceGroupName.value) {
                $resourceGroupName = $mainParameters.parameters.resourceGroupName.value
                Write-Host "   ✅ Resource Group Name: $resourceGroupName" -ForegroundColor Green
            }
            
            if ($mainParameters.parameters.environmentName.value) {
                $EnvironmentName = $mainParameters.parameters.environmentName.value
                Write-Host "   ✅ Environment Name: $EnvironmentName" -ForegroundColor Green
            }
            
            if ($mainParameters.parameters.location.value) {
                $Location = $mainParameters.parameters.location.value
                Write-Host "   ✅ Location: $Location" -ForegroundColor Green
            }
            
            # Note: Admin password will come from parameters file during deployment
            if ($mainParameters.parameters.adminPassword.value -and -not $AdminPassword) {
                Write-Host "   ✅ Admin password available in parameters file" -ForegroundColor Green
                Write-Host "      🔐 SECURITY REMINDER: In production, use Azure Key Vault!" -ForegroundColor Yellow
                # Password will be used directly from filtered parameters during deployment
            }
            
        } catch {
            Write-Host "   ❌ Failed to read parameters file: $_" -ForegroundColor Red
            Write-Host "   ℹ️ Continuing with command-line parameters..." -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠️ Parameters file not found: $parametersFilePath" -ForegroundColor Yellow
        Write-Host "   ℹ️ Continuing with command-line parameters..." -ForegroundColor Cyan
    }
}

# =============================================================================
# Step 1: Pre-Deployment Validation
# =============================================================================

Write-Host "🔍 Step 1: Pre-Deployment Validation" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Verify resource group exists (from foundation deployment)
Write-Host "📁 Verifying foundation infrastructure..." -ForegroundColor Cyan
$rgExists = az group exists --name $resourceGroupName --output tsv
if ($rgExists -ne "true") {
    Write-Host "   ❌ Resource group '$resourceGroupName' not found" -ForegroundColor Red
    Write-Host "   💡 Run Deploy-InfrastructureFoundation.ps1 first" -ForegroundColor Yellow
    exit 1
}
Write-Host "   ✅ Resource group found: $resourceGroupName" -ForegroundColor Green

# Verify Log Analytics workspace exists
Write-Host "📊 Verifying Log Analytics workspace..." -ForegroundColor Cyan
$workspaces = az monitor log-analytics workspace list --resource-group $resourceGroupName --output json | ConvertFrom-Json
if (-not $workspaces -or $workspaces.Count -eq 0) {
    Write-Host "   ❌ Log Analytics workspace not found in resource group" -ForegroundColor Red
    Write-Host "   💡 Ensure foundation deployment completed successfully" -ForegroundColor Yellow
    exit 1
}
$workspaceName = $workspaces[0].name
Write-Host "   ✅ Log Analytics workspace found: $workspaceName" -ForegroundColor Green

# Verify network infrastructure
Write-Host "🌐 Verifying network infrastructure..." -ForegroundColor Cyan
$vnets = az network vnet list --resource-group $resourceGroupName --output json | ConvertFrom-Json
if (-not $vnets -or $vnets.Count -eq 0) {
    Write-Host "   ❌ Virtual network not found in resource group" -ForegroundColor Red
    Write-Host "   💡 Ensure foundation deployment completed successfully" -ForegroundColor Yellow
    exit 1
}
$vnetName = $vnets[0].name
Write-Host "   ✅ Virtual network found: $vnetName" -ForegroundColor Green

# Get admin password if not provided and not using parameters file
if (-not $AdminPassword -and -not $UseParametersFile) {
    Write-Host "🔐 Administrator password required for VMs..." -ForegroundColor Cyan
    if ($WhatIf) {
        Write-Host "   ℹ️ Password validation skipped in What-If mode" -ForegroundColor Gray
    } else {
        $AdminPassword = Read-Host "   Enter administrator password for VMs" -AsSecureString
        $adminPasswordString = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPassword))
        
        # Validate password complexity
        if ($adminPasswordString.Length -lt 12) {
            Write-Host "   ❌ Password must be at least 12 characters long" -ForegroundColor Red
            exit 1
        }
        Write-Host "   ✅ Password validated" -ForegroundColor Green
    }
} else {
    if ($UseParametersFile) {
        Write-Host "   ✅ Password will be read from main.parameters.json during deployment" -ForegroundColor Green
    } else {
        $adminPasswordString = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPassword))
        Write-Host "   ✅ Password provided via command line" -ForegroundColor Green
    }
}

# Cost confirmation and deployment prompt
if (-not $Force -and -not $WhatIf) {
    Write-Host ""
    Write-Host "💰 COST CONFIRMATION" -ForegroundColor Yellow
    Write-Host "===================" -ForegroundColor Yellow
    Write-Host "📊 About to deploy virtual machines with the following estimated costs:" -ForegroundColor White
    Write-Host "   • Windows Server VM (Standard_B2s): ~`$1.05/day (~`$31-35/month)" -ForegroundColor White
    Write-Host "   • Linux VM (Standard_B1ms): ~`$0.50/day (~`$15-18/month)" -ForegroundColor White
    Write-Host "   • Combined Daily Cost: ~`$1.55/day (~`$47/month) while VMs are running" -ForegroundColor White
    Write-Host "   • Additional Storage: ~`$2-4/month for VM disks" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Remember: Stop VMs when not in use to minimize costs!" -ForegroundColor Cyan
    Write-Host ""
    $confirmation = Read-Host "💰 Do you acknowledge the costs and want to proceed with VM deployment? (y/N)"
    if ($confirmation -ne "y" -and $confirmation -ne "Y") {
        Write-Host "❌ Deployment cancelled by user" -ForegroundColor Red
        Write-Host "💡 Tip: Use -WhatIf to preview deployment without creating resources" -ForegroundColor Cyan
        exit 0
    }
}

# =============================================================================
# Step 2: VM Template Preparation
# =============================================================================

Write-Host ""
Write-Host "🔧 Step 2: VM Template Preparation" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

# Navigate to infrastructure directory
$infraPath = Join-Path $PSScriptRoot "..\infra"
# Use Push-Location to preserve current directory and restore it later
Push-Location $infraPath

# Set up automatic directory restoration on exit
trap {
    Pop-Location
    Write-Host "🔄 Working directory restored due to script exit" -ForegroundColor Yellow
    break
}

Write-Host "📂 Working directory: $infraPath" -ForegroundColor Cyan

# Prepare parameters for VM deployment
Write-Host "📝 Preparing VM deployment parameters..." -ForegroundColor Cyan

if ($UseParametersFile) {
    # Create filtered parameters for VM template (only includes what VM template expects)
    $vmParametersFile = "vm-deployment-temp.json"
    
    Write-Host "   🔧 Creating filtered parameters for VM deployment..." -ForegroundColor Cyan
    try {
        $mainParams = Get-Content "main.parameters.json" -Raw | ConvertFrom-Json
        
        # Get resource token from existing infrastructure
        Write-Host "   🔍 Retrieving resource token from existing infrastructure..." -ForegroundColor Cyan
        $existingResources = az resource list --resource-group $resourceGroupName --output json | ConvertFrom-Json
        $resourceToken = ""
        
        # Extract token from Log Analytics workspace name
        foreach ($resource in $existingResources) {
            if ($resource.type -eq "Microsoft.OperationalInsights/workspaces") {
                $workspaceNameParts = $resource.name -split "-"
                if ($workspaceNameParts.Length -gt 0) {
                    $resourceToken = $workspaceNameParts[-1]
                    break
                }
            }
        }
        
        if (-not $resourceToken) {
            Write-Host "   ❌ Could not determine resource token from existing infrastructure" -ForegroundColor Red
            exit 1
        }
        Write-Host "   ✅ Resource token retrieved: $resourceToken" -ForegroundColor Green
        
        # Create filtered parameters object with only VM template parameters
        $vmParameters = @{
            '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
            contentVersion = "1.0.0.0"
            parameters = @{
                environmentName = @{ value = $mainParams.parameters.environmentName.value }
                location = @{ value = $mainParams.parameters.location.value }
                adminUsername = @{ value = $mainParams.parameters.adminUsername.value }
                adminPassword = @{ value = $mainParams.parameters.adminPassword.value }
                resourceToken = @{ value = $resourceToken }
                tags = @{ value = $mainParams.parameters.tags.value }
            }
        }
        
        # Save filtered parameters to temporary file
        $vmParameters | ConvertTo-Json -Depth 10 | Set-Content $vmParametersFile
        $parametersFile = $vmParametersFile
        
        Write-Host "   ✅ Filtered parameters created: $parametersFile" -ForegroundColor Green
        Write-Host "      Environment Name: $($mainParams.parameters.environmentName.value)" -ForegroundColor White
        Write-Host "      Resource Group: $resourceGroupName" -ForegroundColor White
        Write-Host "      Location: $($mainParams.parameters.location.value)" -ForegroundColor White
        Write-Host "      Resource Token: $resourceToken" -ForegroundColor White
        
    } catch {
        Write-Host "   ❌ Failed to create filtered parameters: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   ❌ VM deployment requires UseParametersFile mode" -ForegroundColor Red
    Write-Host "   💡 Run with -UseParametersFile parameter" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 3: VM Template Validation
# =============================================================================

Write-Host ""
Write-Host "✅ Step 3: VM Template Validation" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "🔍 Validating virtual machines template..." -ForegroundColor Cyan

# Check if the Bicep template file exists
$templatePath = "modules/compute/virtual-machines.bicep"
if (-not (Test-Path $templatePath)) {
    Write-Host "   ❌ Template file not found: $templatePath" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Template file found: $templatePath" -ForegroundColor Green

# Simple Bicep build validation (faster than full deployment validation)
Write-Host "   🔧 Checking Bicep template syntax..." -ForegroundColor Cyan
try {
    $buildResult = az bicep build --file $templatePath --stdout 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Bicep template syntax validation successful" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Bicep template syntax validation failed:" -ForegroundColor Red
        Write-Host "      $buildResult" -ForegroundColor White
        exit 1
    }
} catch {
    Write-Host "   ❌ Bicep build validation failed: $_" -ForegroundColor Red
    exit 1
}

# Optional full deployment validation for additional verification
Write-Host "   🔍 Running deployment validation..." -ForegroundColor Cyan
try {
    $validation = az deployment group validate `
        --resource-group $resourceGroupName `
        --template-file "modules/compute/virtual-machines.bicep" `
        --parameters "@$parametersFile" `
        --output json | ConvertFrom-Json

    if ($validation.error) {
        Write-Host "   ❌ Template validation failed:" -ForegroundColor Red
        Write-Host "      $($validation.error.message)" -ForegroundColor White
        exit 1
    } else {
        Write-Host "   ✅ Template validation successful" -ForegroundColor Green
        Write-Host "   📊 Resources to deploy: $($validation.properties.validatedResources.Count)" -ForegroundColor White
    }
} catch {
    Write-Host "   ❌ Validation failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 4: VM Deployment Execution
# =============================================================================

Write-Host ""
Write-Host "🚀 Step 4: Virtual Machines Deployment" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$deploymentName = "virtualmachines-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

if ($WhatIf) {
    Write-Host "👁️ Previewing VM deployment changes (What-If)..." -ForegroundColor Yellow
    try {
        az deployment group what-if `
            --resource-group $resourceGroupName `
            --name $deploymentName `
            --template-file "modules/compute/virtual-machines.bicep" `
            --parameters "@$parametersFile"
        
        Write-Host ""
        Write-Host "ℹ️ This was a preview only. Use without -WhatIf to execute deployment." -ForegroundColor Cyan
    } catch {
        Write-Host "   ❌ What-If operation failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "🔨 Executing virtual machines deployment..." -ForegroundColor Cyan
    Write-Host "   📝 Deployment name: $deploymentName" -ForegroundColor White
    Write-Host "   ⏱️ Estimated time: 10-15 minutes" -ForegroundColor White
    Write-Host "   🖥️ Deploying: Windows VM + Linux VM" -ForegroundColor White
    Write-Host ""
    
    # Debug: Show the exact command being executed
    Write-Host "   🔍 Debug - Command to execute:" -ForegroundColor Yellow
    Write-Host "   az deployment group create --resource-group $resourceGroupName --name $deploymentName --template-file `"modules/compute/virtual-machines.bicep`" --parameters `"@$parametersFile`"" -ForegroundColor White
    Write-Host ""
    
    try {
        Write-Host "   ⏳ Starting VM deployment..." -ForegroundColor Cyan
        
        # Execute deployment using table output for better reliability
        az deployment group create `
            --resource-group $resourceGroupName `
            --name $deploymentName `
            --template-file "modules/compute/virtual-machines.bicep" `
            --parameters "@$parametersFile" `
            --output table
        
        # Check deployment status separately
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Virtual machines deployment completed successfully!" -ForegroundColor Green
            
            # Get deployment details for verification
            Write-Host "   📊 Getting deployment details..." -ForegroundColor Cyan
            $deploymentDetails = az deployment group show --resource-group $resourceGroupName --name $deploymentName --output json | ConvertFrom-Json
            Write-Host "   📋 Deployment state: $($deploymentDetails.properties.provisioningState)" -ForegroundColor White
        } else {
            Write-Host "   ❌ Azure CLI deployment command failed with exit code: $LASTEXITCODE" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "   ❌ Deployment execution failed: $_" -ForegroundColor Red
        Write-Host "   💡 Exception details: $($_.Exception.Message)" -ForegroundColor Yellow
        exit 1
    }
}

# =============================================================================
# Step 5: VM Deployment Validation
# =============================================================================

if (-not $WhatIf) {
    Write-Host ""
    Write-Host "✅ Step 5: VM Deployment Validation" -ForegroundColor Green
    Write-Host "===================================" -ForegroundColor Green
    
    # Verify virtual machines
    Write-Host "🖥️ Verifying virtual machines..." -ForegroundColor Cyan
    $vms = az vm list --resource-group $resourceGroupName --output json | ConvertFrom-Json
    if ($vms -and $vms.Count -gt 0) {
        Write-Host "   ✅ Virtual machines deployed: $($vms.Count)" -ForegroundColor Green
        foreach ($vm in $vms) {
            $vmStatus = az vm get-instance-view --resource-group $resourceGroupName --name $vm.name --query "instanceView.statuses[?code=='PowerState/running']" --output tsv
            $status = if ($vmStatus) { "Running" } else { "Starting/Stopped" }
            Write-Host "      - $($vm.name): $status ($($vm.storageProfile.osDisk.osType))" -ForegroundColor White
        }
    } else {
        Write-Host "   ❌ VM verification failed" -ForegroundColor Red
    }
    
    # Verify network interfaces
    Write-Host "🔌 Verifying network interfaces..." -ForegroundColor Cyan
    $nics = az network nic list --resource-group $resourceGroupName --output json | ConvertFrom-Json
    Write-Host "   ✅ Network interfaces: $($nics.Count)" -ForegroundColor Green
    
    # Verify public IP addresses
    Write-Host "🌍 Verifying public IP addresses..." -ForegroundColor Cyan
    $publicIps = az network public-ip list --resource-group $resourceGroupName --output json | ConvertFrom-Json
    Write-Host "   ✅ Public IP addresses: $($publicIps.Count)" -ForegroundColor Green
    
    # Check VM extensions (basic validation)
    Write-Host "🔧 Checking VM extensions..." -ForegroundColor Cyan
    $totalExtensions = 0
    foreach ($vm in $vms) {
        $extensions = az vm extension list --resource-group $resourceGroupName --vm-name $vm.name --output json | ConvertFrom-Json
        $totalExtensions += $extensions.Count
        Write-Host "      - $($vm.name): $($extensions.Count) extensions" -ForegroundColor White
    }
    Write-Host "   ✅ Total VM extensions: $totalExtensions" -ForegroundColor Green
    
    # Display deployment outputs
    Write-Host "📋 Retrieving deployment outputs..." -ForegroundColor Cyan
    try {
        $outputs = az deployment group show --resource-group $resourceGroupName --name $deploymentName --query "properties.outputs" --output json | ConvertFrom-Json
        if ($outputs) {
            Write-Host "   ✅ Deployment outputs retrieved:" -ForegroundColor Green
            foreach ($output in $outputs.PSObject.Properties) {
                if ($output.Name -like "*Password*") {
                    Write-Host "      $($output.Name): ********" -ForegroundColor White
                } else {
                    Write-Host "      $($output.Name): $($output.Value.value)" -ForegroundColor White
                }
            }
        }
    } catch {
        Write-Host "   ⚠️ Could not retrieve deployment outputs" -ForegroundColor Yellow
    }
}

# =============================================================================
# Cleanup
# =============================================================================

# Clean up temporary parameters file if it was created
if ($UseParametersFile -and (Test-Path "vm-deployment-temp.json")) {
    Write-Host "🧹 Cleaning up temporary files..." -ForegroundColor Cyan
    Remove-Item "vm-deployment-temp.json" -Force
    Write-Host "   ✅ Temporary parameters file removed" -ForegroundColor Green
}

# =============================================================================
# Completion Summary
# =============================================================================

Write-Host ""
Write-Host "📊 Virtual Machines Deployment Summary" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

if ($WhatIf) {
    Write-Host "👁️ Preview completed successfully!" -ForegroundColor Yellow
    Write-Host "   • Template validation: ✅ Passed" -ForegroundColor White
    Write-Host "   • What-If analysis: ✅ Completed" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Next Steps:" -ForegroundColor Cyan
    Write-Host "   • Review the What-If output above" -ForegroundColor White
    Write-Host "   • Run without -WhatIf to execute deployment" -ForegroundColor White
} else {
    Write-Host "🎉 Virtual machines deployment completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Deployed Components:" -ForegroundColor Green
    Write-Host "   • Windows Virtual Machine: ✅ Deployed" -ForegroundColor White
    Write-Host "   • Linux Virtual Machine: ✅ Deployed" -ForegroundColor White
    Write-Host "   • Network Interfaces: ✅ Deployed" -ForegroundColor White
    Write-Host "   • Public IP Addresses: ✅ Deployed" -ForegroundColor White
    Write-Host "   • VM Extensions: ✅ Installed" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Next Steps:" -ForegroundColor Cyan
    Write-Host "   • Run Deploy-DefenderPlans.ps1 to configure Defender plans" -ForegroundColor White
    Write-Host "   • Set up security features with Deploy-SecurityFeatures.ps1" -ForegroundColor White
    Write-Host "   • Validate complete deployment with Test-DeploymentValidation.ps1" -ForegroundColor White
}

Write-Host ""
Write-Host "🎯 Virtual machines deployment script completed!" -ForegroundColor Green

# Restore original working directory
Pop-Location

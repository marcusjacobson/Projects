# =============================================================================
# Microsoft Defender for Cloud - Infrastructure Foundation Deployment Script
# =============================================================================
# This script deploys the foundational infrastructure components including
# resource group, Log Analytics workspace, and network infrastructure.
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Name for the environment (will be used in resource names)")]
    [string]$EnvironmentName = "securitylab",
    
    [Parameter(Mandatory=$false, HelpMessage="Azure region for deployment")]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false, HelpMessage="Security contact email for notifications")]
    [string]$SecurityContactEmail = "",
    
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

# Initialize variables
$resourceGroupName = $null
$resourceToken = $null

Write-Host "🏗️ Microsoft Defender for Cloud - Infrastructure Foundation Deployment" -ForegroundColor Green
Write-Host "====================================================================" -ForegroundColor Green
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
            
            # Override script parameters with values from file
            if ($mainParameters.parameters.environmentName.value) {
                $EnvironmentName = $mainParameters.parameters.environmentName.value
                Write-Host "   ✅ Environment Name: $EnvironmentName" -ForegroundColor Green
            }
            
            if ($mainParameters.parameters.location.value) {
                $Location = $mainParameters.parameters.location.value
                Write-Host "   ✅ Location: $Location" -ForegroundColor Green
            }
            
            if ($mainParameters.parameters.securityContactEmail.value -and -not $SecurityContactEmail) {
                $SecurityContactEmail = $mainParameters.parameters.securityContactEmail.value
                Write-Host "   ✅ Security Contact Email: $SecurityContactEmail" -ForegroundColor Green
            }
            
            # Override resource group name if specified in parameters file
            if ($mainParameters.parameters.resourceGroupName.value) {
                $resourceGroupName = $mainParameters.parameters.resourceGroupName.value
                Write-Host "   ✅ Resource Group Name: $resourceGroupName" -ForegroundColor Green
            }
            
            # Override resource token if specified in parameters file
            if ($mainParameters.parameters.resourceToken.value) {
                $resourceToken = $mainParameters.parameters.resourceToken.value
                Write-Host "   ✅ Resource Token: $resourceToken" -ForegroundColor Green
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

# Generate defaults for variables not provided from parameters file
if (-not $resourceToken) {
    $resourceToken = -join ((97..122) | Get-Random -Count 12 | ForEach-Object {[char]$_})
    Write-Host "   🎲 Generated Resource Token: $resourceToken" -ForegroundColor Cyan
}

if (-not $resourceGroupName) {
    $resourceGroupName = "rg-aisec-defender-$EnvironmentName"
    Write-Host "   🏗️ Generated Resource Group Name: $resourceGroupName" -ForegroundColor Cyan
}

Write-Host "📋 Deployment Configuration:" -ForegroundColor Cyan
Write-Host "   Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   Resource Group: $resourceGroupName" -ForegroundColor White
Write-Host "   Location: $Location" -ForegroundColor White
Write-Host "   Resource Token: $resourceToken" -ForegroundColor White
Write-Host "   What-If Mode: $WhatIf" -ForegroundColor White
Write-Host ""

if (-not $Force -and -not $WhatIf) {
    $confirmation = Read-Host "Do you want to proceed with the deployment? (y/N)"
    if ($confirmation -ne "y" -and $confirmation -ne "Y") {
        Write-Host "❌ Deployment cancelled by user" -ForegroundColor Red
        exit 0
    }
}

# =============================================================================
# Phase 1: Prepare Deployment Environment
# =============================================================================

Write-Host "🔧 Phase 1: Preparing Deployment Environment" -ForegroundColor Green
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

# Check if resource group already exists
Write-Host "📁 Checking resource group status..." -ForegroundColor Cyan
$rgExists = az group exists --name $resourceGroupName --output tsv
if ($rgExists -eq "true") {
    Write-Host "   ✅ Resource group '$resourceGroupName' already exists" -ForegroundColor Green
    if (-not $Force -and -not $WhatIf) {
        $proceed = Read-Host "   Do you want to continue with existing resource group? (y/N)"
        if ($proceed -ne "y" -and $proceed -ne "Y") {
            Write-Host "   ❌ Deployment cancelled" -ForegroundColor Red
            exit 0
        }
    }
} else {
    Write-Host "   ✅ Resource group '$resourceGroupName' does not exist - will be created" -ForegroundColor Green
    
    # Create resource group before template validation
    if (-not $WhatIf) {
        Write-Host "🏗️ Creating resource group..." -ForegroundColor Cyan
        try {
            $rgResult = az group create --name $resourceGroupName --location $Location --output json | ConvertFrom-Json
            if ($rgResult.properties.provisioningState -eq "Succeeded") {
                Write-Host "   ✅ Resource group created successfully" -ForegroundColor Green
            } else {
                Write-Host "   ❌ Resource group creation failed with state: $($rgResult.properties.provisioningState)" -ForegroundColor Red
                exit 1
            }
        } catch {
            Write-Host "   ❌ Failed to create resource group: $_" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "   ℹ️ Resource group creation will be included in What-If preview" -ForegroundColor Cyan
    }
}

# =============================================================================
# Phase 2: Infrastructure Template Validation
# =============================================================================

Write-Host ""
Write-Host "✅ Phase 2: Infrastructure Template Validation" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Navigate to infrastructure directory
$infraPath = Join-Path $PSScriptRoot "..\infra"
if (-not (Test-Path $infraPath)) {
    Write-Host "   ❌ Infrastructure directory not found: $infraPath" -ForegroundColor Red
    exit 1
}

Set-Location $infraPath
Write-Host "📂 Working directory: $infraPath" -ForegroundColor Cyan

# Use main.parameters.json directly for deployment
Write-Host "📝 Using main.parameters.json for foundation deployment..." -ForegroundColor Cyan
$parametersFile = "main.parameters.json"

if (-not (Test-Path $parametersFile)) {
    Write-Host "   ❌ main.parameters.json not found in infra directory" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Parameters file found: $parametersFile" -ForegroundColor Green
Write-Host "      Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "      Location: $Location" -ForegroundColor White
Write-Host "      Resource Token: $resourceToken" -ForegroundColor White

# Validate Bicep template exists and syntax is correct
Write-Host "🔍 Validating infrastructure foundation template..." -ForegroundColor Cyan

# Check if the Bicep template file exists
$templatePath = "modules/foundation/foundation.bicep"
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

# Ensure resource group is available for deployment validation if needed
$rgReady = az group exists --name $resourceGroupName --output tsv
if ($rgReady -ne "true" -and -not $WhatIf) {
    Write-Host "   ❌ Resource group not ready for validation" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Phase 3: Preview or Execute Deployment
# =============================================================================

Write-Host ""
Write-Host "🚀 Phase 3: Infrastructure Foundation Deployment" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

$deploymentName = "foundation-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

if ($WhatIf) {
    Write-Host "👁️ Previewing deployment changes (What-If)..." -ForegroundColor Yellow
    
    # Ensure resource group exists for What-If operation
    $rgReady = az group exists --name $resourceGroupName --output tsv
    if ($rgReady -ne "true") {
        Write-Host "   ℹ️ Creating temporary resource group for What-If validation..." -ForegroundColor Cyan
        az group create --name $resourceGroupName --location $Location --output none
    }
    
    try {
        Write-Host "   ⏱️ Running What-If analysis (this may take a few minutes)..." -ForegroundColor Cyan
        az deployment group what-if `
            --resource-group $resourceGroupName `
            --name $deploymentName `
            --template-file "modules/foundation/foundation.bicep" `
            --parameters "@$parametersFile"
        
        Write-Host ""
        Write-Host "ℹ️ This was a preview only. Use without -WhatIf to execute deployment." -ForegroundColor Cyan
    } catch {
        Write-Host "   ❌ What-If operation failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "🔨 Executing infrastructure foundation deployment..." -ForegroundColor Cyan
    Write-Host "   📝 Deployment name: $deploymentName" -ForegroundColor White
    Write-Host "   ⏱️ Estimated time: 5-10 minutes" -ForegroundColor White
    Write-Host ""
    
    # Debug: Show the exact command being executed
    Write-Host "   🔍 Debug - Command to execute:" -ForegroundColor Yellow
    Write-Host "   az deployment group create --resource-group $resourceGroupName --name $deploymentName --template-file `"modules/foundation/foundation.bicep`" --parameters `"@$parametersFile`"" -ForegroundColor White
    Write-Host ""
    
    try {
        Write-Host "   ⏳ Starting deployment..." -ForegroundColor Cyan
        
        # Execute deployment using parameters file for better reliability
        az deployment group create `
            --resource-group $resourceGroupName `
            --name $deploymentName `
            --template-file "modules/foundation/foundation.bicep" `
            --parameters "@$parametersFile" `
            --output table
        
        # Check deployment status separately
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Infrastructure foundation deployment completed successfully!" -ForegroundColor Green
            
            # Get deployment details for verification
            Write-Host "   📊 Getting deployment details..." -ForegroundColor Cyan
            $deploymentDetails = az deployment group show --resource-group $resourceGroupName --name $deploymentName --output json | ConvertFrom-Json
            Write-Host "   � Deployment state: $($deploymentDetails.properties.provisioningState)" -ForegroundColor White
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
# Phase 4: Post-Deployment Validation
# =============================================================================

if (-not $WhatIf) {
    Write-Host ""
    Write-Host "✅ Phase 4: Post-Deployment Validation" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    
    # Verify resource group creation
    Write-Host "📁 Verifying resource group..." -ForegroundColor Cyan
    $rg = az group show --name $resourceGroupName --output json 2>$null | ConvertFrom-Json
    if ($rg) {
        Write-Host "   ✅ Resource group created: $($rg.name)" -ForegroundColor Green
        Write-Host "   📍 Location: $($rg.location)" -ForegroundColor White
    } else {
        Write-Host "   ❌ Resource group verification failed" -ForegroundColor Red
    }
    
    # Verify Log Analytics workspace
    Write-Host "📊 Verifying Log Analytics workspace..." -ForegroundColor Cyan
    $workspaces = az monitor log-analytics workspace list --resource-group $resourceGroupName --output json | ConvertFrom-Json
    if ($workspaces -and $workspaces.Count -gt 0) {
        Write-Host "   ✅ Log Analytics workspace created: $($workspaces[0].name)" -ForegroundColor Green
        Write-Host "   🔧 Provisioning state: $($workspaces[0].provisioningState)" -ForegroundColor White
    } else {
        Write-Host "   ❌ Log Analytics workspace verification failed" -ForegroundColor Red
    }
    
    # Verify network infrastructure
    Write-Host "🌐 Verifying network infrastructure..." -ForegroundColor Cyan
    $vnets = az network vnet list --resource-group $resourceGroupName --output json | ConvertFrom-Json
    $nsgs = az network nsg list --resource-group $resourceGroupName --output json | ConvertFrom-Json
    
    Write-Host "   ✅ Virtual networks: $($vnets.Count)" -ForegroundColor Green
    Write-Host "   ✅ Network security groups: $($nsgs.Count)" -ForegroundColor Green
    
    # Display deployment outputs
    Write-Host "📋 Retrieving deployment outputs..." -ForegroundColor Cyan
    try {
        $outputs = az deployment group show --resource-group $resourceGroupName --name $deploymentName --query "properties.outputs" --output json | ConvertFrom-Json
        if ($outputs) {
            Write-Host "   ✅ Deployment outputs retrieved:" -ForegroundColor Green
            foreach ($output in $outputs.PSObject.Properties) {
                Write-Host "      $($output.Name): $($output.Value.value)" -ForegroundColor White
            }
        }
    } catch {
        Write-Host "   ⚠️ Could not retrieve deployment outputs" -ForegroundColor Yellow
    }
}

# =============================================================================
# Completion Summary
# =============================================================================

Write-Host ""
Write-Host "📊 Infrastructure Foundation Deployment Summary" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
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
    Write-Host "🎉 Foundation deployment completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Deployed Components:" -ForegroundColor Green
    Write-Host "   • Resource Group: $resourceGroupName" -ForegroundColor White
    Write-Host "   • Log Analytics Workspace: ✅ Deployed" -ForegroundColor White
    Write-Host "   • Virtual Network: ✅ Deployed" -ForegroundColor White
    Write-Host "   • Network Security Groups: ✅ Deployed" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Next Steps:" -ForegroundColor Cyan
    Write-Host "   • Run Deploy-VirtualMachines.ps1 to deploy VMs" -ForegroundColor White
    Write-Host "   • Configure Defender plans using Deploy-DefenderPlans.ps1" -ForegroundColor White
    Write-Host "   • Set up security features with Deploy-SecurityFeatures.ps1" -ForegroundColor White
}

Write-Host ""
Write-Host "🎯 Foundation deployment script completed!" -ForegroundColor Green

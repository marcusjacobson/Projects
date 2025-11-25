<#
.SYNOPSIS
    Deploys the complete Azure OpenAI + Defender XDR integration workflow with Logic Apps automation.

.DESCRIPTION
    This orchestration script automates the complete deployment of the Azure OpenAI + Defender XDR 
    integration, including app registration, Key Vault security, API connections, and Logic Apps 
    workflow. It builds upon the Week 2 AI foundation to create an enterprise-grade automated 
    security workflow that analyzes security incidents with AI-powered insights and posts structured 
    comments directly to Defender XDR alerts.

    The deployment creates:
    - App Registration with Microsoft Graph Security API permissions
    - Key Vault integration for secure credential management
    - Azure API connections for OpenAI and Table Storage
    - Logic Apps workflow with AI analysis and duplicate prevention
    - Comprehensive testing and validation framework

    Integration Architecture:
    Week 1 (Defender) ← Logic Apps deployment target
    Week 2 (AI) ← OpenAI service and storage account (referenced)

.PARAMETER UseParametersFile
    Uses values from main.parameters.json file for deployment configuration.

.PARAMETER EnvironmentName
    The unique environment name for resource naming (overrides parameters file).

.PARAMETER Location
    The Azure region for resource deployment (overrides parameters file).

.PARAMETER Force
    Skips all confirmation prompts and proceeds with automated deployment.

.PARAMETER WhatIf
    Shows what would be deployed without making any actual changes.

.PARAMETER SkipValidation
    Skips the comprehensive infrastructure validation step for faster deployment.

.EXAMPLE
    .\Deploy-DefenderXDRIntegration.ps1 -UseParametersFile
    
    Deploys the complete integration using configuration from main.parameters.json with interactive prompts.

.EXAMPLE
    .\Deploy-DefenderXDRIntegration.ps1 -UseParametersFile -Force
    
    Fully automated deployment with no user interaction required.

.EXAMPLE
    .\Deploy-DefenderXDRIntegration.ps1 -EnvironmentName "aisec" -Location "East US" -WhatIf
    
    Preview deployment with specific parameters without making changes.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-09-02
    Last Modified: 2025-09-02
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Azure CLI installed and authenticated
    - PowerShell 5.1+ or PowerShell 7+
    - Week 1 Defender for Cloud deployment completed
    - Week 2 AI foundation deployment completed
    - Application Developer role in Entra ID (for app registration)
    - Contributor role on target subscription
    - Security Administrator role (for Microsoft Graph permissions)
    
    Script development orchestrated using GitHub Copilot.

.INTEGRATION PHASES
    Phase 1: Key Vault Foundation (Deploy-KeyVault.ps1)
    Phase 2: App Registration Security (Deploy-AppRegistration.ps1)
    Phase 3: API Connections Setup (Deploy-APIConnections.ps1)
    Phase 4: Logic Apps Workflow (Deploy-LogicAppWorkflow.ps1)
    Phase 5: Integration Validation (Test-DefenderXDRIntegrationValidation.ps1)
#>
#
# =============================================================================
# Deploy complete Azure OpenAI + Defender XDR integration with Logic Apps.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName,
    
    [Parameter(Mandatory = $false)]
    [string]$Location,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipValidation
)

# Set error handling
$ErrorActionPreference = "Stop"

# Track deployment start time
$deploymentStart = Get-Date

# =============================================================================
# Phase 1: Parameter Loading and Environment Validation
# =============================================================================

Write-Host "🚀 Phase 1: Parameter Loading and Environment Validation" -ForegroundColor Magenta
Write-Host "=========================================================" -ForegroundColor Magenta

# Load parameters from file if specified
if ($UseParametersFile) {
    $parametersPath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    if (Test-Path $parametersPath) {
        Write-Host "📄 Loading parameters from: $parametersPath" -ForegroundColor Cyan
        $parametersContent = Get-Content $parametersPath | ConvertFrom-Json
        
        if (-not $EnvironmentName) { $EnvironmentName = $parametersContent.parameters.environmentName.value }
        if (-not $Location) { $Location = $parametersContent.parameters.location.value }
        
        # Load resource group names from parameters file
        $defenderResourceGroupName = $parametersContent.parameters.defenderResourceGroupName.value
        $aiResourceGroupName = $parametersContent.parameters.aiResourceGroupName.value
        
        Write-Host "   ✅ Parameters loaded from file successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Parameters file not found: $parametersPath" -ForegroundColor Red
        exit 1
    }
} else {
    # Validate required parameters when not using parameters file
    if (-not $EnvironmentName -or -not $Location) {
        Write-Host "❌ EnvironmentName and Location are required when not using -UseParametersFile" -ForegroundColor Red
        exit 1
    }
    
    # Derive resource names when not using parameters file
    $defenderResourceGroupName = "rg-$EnvironmentName-defender-$EnvironmentName"
    $aiResourceGroupName = "rg-$EnvironmentName-ai"
}

Write-Host ""
Write-Host "🎯 Defender XDR Integration Configuration:" -ForegroundColor Cyan
Write-Host "   🏷️  Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   📍 Location: $Location" -ForegroundColor White
Write-Host "   🛡️  Defender Resource Group: $defenderResourceGroupName" -ForegroundColor White
Write-Host "   🤖 AI Resource Group: $aiResourceGroupName" -ForegroundColor White

# Validate Azure CLI authentication
Write-Host "🔐 Validating Azure CLI authentication..." -ForegroundColor Cyan
try {
    $account = az account show --output json 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Host "❌ Azure CLI not authenticated. Please run 'az login'" -ForegroundColor Red
        exit 1
    }
    Write-Host "   ✅ Azure CLI authenticated as: $($account.user.name)" -ForegroundColor Green
    Write-Host "   📋 Subscription: $($account.name)" -ForegroundColor White
} catch {
    Write-Host "❌ Failed to verify Azure authentication: $_" -ForegroundColor Red
    exit 1
}

# Validate prerequisite resource groups
Write-Host "📦 Validating prerequisite resource groups..." -ForegroundColor Cyan
try {
    $defenderRG = az group show --name $defenderResourceGroupName --output json 2>$null | ConvertFrom-Json
    if (-not $defenderRG) {
        Write-Host "❌ Defender resource group not found: $defenderResourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please complete Week 1 Defender for Cloud deployment first" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "   ✅ Week 1 Defender resource group validated: $defenderResourceGroupName" -ForegroundColor Green
    
    $aiRG = az group show --name $aiResourceGroupName --output json 2>$null | ConvertFrom-Json
    if (-not $aiRG) {
        Write-Host "❌ AI resource group not found: $aiResourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please complete Week 2 AI foundation deployment first" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "   ✅ Week 2 AI resource group validated: $aiResourceGroupName" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to validate prerequisite resource groups: $_" -ForegroundColor Red
    exit 1
}

if ($WhatIf) {
    Write-Host "👁️ [WHAT-IF MODE] - Preview of planned deployment:" -ForegroundColor Yellow
    Write-Host "   📦 Would deploy to resource groups: $defenderResourceGroupName, $aiResourceGroupName" -ForegroundColor White
    Write-Host "   🔧 Would execute 5 deployment phases with comprehensive validation" -ForegroundColor White
    Write-Host "   ⏱️  Estimated deployment time: 20-30 minutes" -ForegroundColor White
    exit 0
}

# Deployment confirmation unless Force is specified
if (-not $Force) {
    Write-Host ""
    Write-Host "🎯 Ready to Deploy Defender XDR Integration" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "This will deploy the complete Azure OpenAI + Defender XDR integration including:"
    Write-Host "• Key Vault with secure credential storage"
    Write-Host "• App Registration with Microsoft Graph API permissions"
    Write-Host "• API connections for OpenAI and Table Storage"
    Write-Host "• Logic Apps workflow with AI analysis automation"
    Write-Host "• Comprehensive integration testing and validation"
    Write-Host ""
    $confirm = Read-Host "Continue with deployment? [Y/N]"
    if ($confirm -notmatch '^[Yy]') {
        Write-Host "❌ Deployment cancelled by user" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Phase 1 completed successfully" -ForegroundColor Green

# =============================================================================
# Phase 2: Key Vault Foundation Deployment
# =============================================================================

Write-Host ""
Write-Host "🔐 Phase 2: Key Vault Foundation Deployment" -ForegroundColor Magenta
Write-Host "===========================================" -ForegroundColor Magenta

try {
    $scriptPath = Join-Path $PSScriptRoot "Deploy-KeyVault.ps1"
    $params = @{}
    
    if ($UseParametersFile) { $params.UseParametersFile = $true }
    if ($EnvironmentName) { $params.EnvironmentName = $EnvironmentName }
    if ($Location) { $params.Location = $Location }
    
    Write-Host "🚀 Calling script 'Deploy-KeyVault.ps1'..." -ForegroundColor Blue
    & $scriptPath @params
    
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        Write-Host "✅ Script 'Deploy-KeyVault.ps1' completed successfully" -ForegroundColor Blue
        Write-Host "✅ Phase 2 completed successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Script 'Deploy-KeyVault.ps1' failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
        throw "Script exited with code: $LASTEXITCODE"
    }
} catch {
    Write-Host "❌ Phase 2 failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Phase 3: App Registration Security Foundation
# =============================================================================

Write-Host ""
Write-Host "🛡️ Phase 3: App Registration Security Foundation" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta

try {
    $scriptPath = Join-Path $PSScriptRoot "Deploy-AppRegistration.ps1"
    $params = @{}
    
    if ($UseParametersFile) { $params.UseParametersFile = $true }
    if ($EnvironmentName) { $params.EnvironmentName = $EnvironmentName }
    if ($Location) { $params.Location = $Location }
    
    Write-Host "🚀 Calling script 'Deploy-AppRegistration.ps1'..." -ForegroundColor Blue
    & $scriptPath @params
    
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        Write-Host "✅ Script 'Deploy-AppRegistration.ps1' completed successfully" -ForegroundColor Blue
        Write-Host "✅ Phase 3 completed successfully" -ForegroundColor Green
        
        # Wait for app registration and Key Vault secrets to propagate
        Write-Host "⏱️  Waiting for app registration and Key Vault secrets to propagate (30 seconds)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
    } else {
        Write-Host "❌ Script 'Deploy-AppRegistration.ps1' failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
        throw "Script exited with code: $LASTEXITCODE"
    }
} catch {
    Write-Host "❌ Phase 3 failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Phase 4: API Connections Setup
# =============================================================================

Write-Host ""
Write-Host "🔗 Phase 4: API Connections Setup" -ForegroundColor Magenta
Write-Host "==================================" -ForegroundColor Magenta

try {
    $scriptPath = Join-Path $PSScriptRoot "Deploy-APIConnections.ps1"
    $params = @{}
    
    if ($UseParametersFile) { $params.UseParametersFile = $true }
    if ($EnvironmentName) { $params.EnvironmentName = $EnvironmentName }
    if ($Location) { $params.Location = $Location }
    
    Write-Host "🚀 Calling script 'Deploy-APIConnections.ps1'..." -ForegroundColor Blue
    & $scriptPath @params
    
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        Write-Host "✅ Script 'Deploy-APIConnections.ps1' completed successfully" -ForegroundColor Blue
        Write-Host "✅ Phase 4 completed successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Script 'Deploy-APIConnections.ps1' failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
        throw "Script exited with code: $LASTEXITCODE"
    }
} catch {
    Write-Host "❌ Phase 4 failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Phase 5: Logic Apps Workflow Deployment
# =============================================================================

Write-Host ""
Write-Host "⚡ Phase 5: Logic Apps Workflow Deployment" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta

try {
    $scriptPath = Join-Path $PSScriptRoot "Deploy-LogicAppWorkflow.ps1"
    $params = @{}
    
    if ($UseParametersFile) { $params.UseParametersFile = $true }
    if ($EnvironmentName) { $params.EnvironmentName = $EnvironmentName }
    if ($Location) { $params.Location = $Location }
    
    Write-Host "🚀 Calling script 'Deploy-LogicAppWorkflow.ps1'..." -ForegroundColor Blue
    & $scriptPath @params
    
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        Write-Host "✅ Script 'Deploy-LogicAppWorkflow.ps1' completed successfully" -ForegroundColor Blue
        Write-Host "✅ Phase 5 completed successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Script 'Deploy-LogicAppWorkflow.ps1' failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
        throw "Script exited with code: $LASTEXITCODE"
    }
} catch {
    Write-Host "❌ Phase 5 failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Phase 6: Integration Validation and Testing
# =============================================================================

if (-not $SkipValidation) {
    Write-Host ""
    Write-Host "✅ Phase 6: Integration Validation and Testing" -ForegroundColor Magenta
    Write-Host "=============================================" -ForegroundColor Magenta
    
    try {
        $scriptPath = Join-Path $PSScriptRoot "Test-DefenderXDRIntegrationValidation.ps1"
        $params = @{ DetailedReport = $true }
        
        if ($UseParametersFile) { $params.UseParametersFile = $true }
        if ($EnvironmentName) { $params.EnvironmentName = $EnvironmentName }
        if ($Location) { $params.Location = $Location }
        
        Write-Host "🚀 Calling script 'Test-DefenderXDRIntegrationValidation.ps1'..." -ForegroundColor Blue
        & $scriptPath @params
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Script 'Test-DefenderXDRIntegrationValidation.ps1' completed successfully" -ForegroundColor Blue
            Write-Host "✅ Phase 6 completed successfully" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Script 'Test-DefenderXDRIntegrationValidation.ps1' reported validation warnings (exit code: $LASTEXITCODE)" -ForegroundColor Yellow
            Write-Host "💡 Review validation output above for any issues that need attention" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "⚠️ Phase 6 validation encountered issues: $_" -ForegroundColor Yellow
        Write-Host "💡 Deployment may have succeeded but validation identified areas for review" -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "⏭️ Phase 6: Integration Validation Skipped" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Yellow
    Write-Host "💡 Validation skipped as requested. Run Test-DefenderXDRIntegrationValidation.ps1 manually to verify deployment" -ForegroundColor Cyan
}

# =============================================================================
# Deployment Summary and Next Steps
# =============================================================================

Write-Host ""
Write-Host "🎉 Deployment Summary and Next Steps" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

$totalTime = (Get-Date) - $deploymentStart

Write-Host "🎯 Defender XDR Integration Deployment Completed Successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Deployment Summary:" -ForegroundColor Cyan
Write-Host "   🛡️  Target Resource Group: $defenderResourceGroupName" -ForegroundColor White
Write-Host "   🤖 AI Services Resource Group: $aiResourceGroupName" -ForegroundColor White
Write-Host "   📍 Location: $Location" -ForegroundColor White
Write-Host "   ⏱️  Total Deployment Time: $totalTime" -ForegroundColor White
Write-Host ""
Write-Host "🏗️ Infrastructure Deployed:" -ForegroundColor Cyan
Write-Host "   🔐 Key Vault with secure credential storage" -ForegroundColor White
Write-Host "   🛡️  App Registration with Microsoft Graph API permissions" -ForegroundColor White
Write-Host "   🔗 API connections for Azure OpenAI and Table Storage" -ForegroundColor White
Write-Host "   ⚡ Logic Apps workflow with AI analysis automation" -ForegroundColor White
Write-Host "   📊 Integration monitoring and validation framework" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Generate sample security incidents in Microsoft Defender for Cloud" -ForegroundColor White
Write-Host "   2. Wait 5-10 minutes for incidents to propagate to Defender XDR" -ForegroundColor White
Write-Host "   3. Manually trigger Logic App workflow to test AI analysis" -ForegroundColor White
Write-Host "   4. Verify AI comments appear in Defender XDR alert details" -ForegroundColor White
Write-Host "   5. Monitor workflow execution history for any issues" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Manual Testing Commands:" -ForegroundColor Cyan
Write-Host "   # Test the complete integration end-to-end" -ForegroundColor White
Write-Host "   .\Test-DefenderXDRIntegration.ps1 -UseParametersFile -GenerateTestIncidents" -ForegroundColor White
Write-Host ""
Write-Host "   # Trigger Logic App workflow manually" -ForegroundColor White
Write-Host "   .\Invoke-LogicAppTrigger.ps1 -UseParametersFile" -ForegroundColor White
Write-Host ""
Write-Host "📚 Integration Validation:" -ForegroundColor Cyan
if (-not $SkipValidation) {
    Write-Host "   ✅ Comprehensive validation completed - review results above" -ForegroundColor White
} else {
    Write-Host "   ⚠️  Validation was skipped - run Test-DefenderXDRIntegrationValidation.ps1 manually" -ForegroundColor White
}
Write-Host ""
Write-Host "💡 Integration Architecture:" -ForegroundColor Cyan
Write-Host "   • Logic Apps workflow processes Defender XDR incidents every 4 hours" -ForegroundColor White
Write-Host "   • AI analysis generates structured comments on security alerts" -ForegroundColor White
Write-Host "   • Duplicate prevention ensures efficient processing and cost control" -ForegroundColor White
Write-Host "   • All credentials securely managed via Key Vault integration" -ForegroundColor White

Write-Host ""
Write-Host "🎉 Azure OpenAI + Defender XDR integration deployment completed successfully!" -ForegroundColor Green

exit 0

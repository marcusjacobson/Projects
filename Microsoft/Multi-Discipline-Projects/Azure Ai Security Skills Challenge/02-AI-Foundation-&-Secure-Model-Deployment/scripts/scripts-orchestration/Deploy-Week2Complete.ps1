<#
.SYNOPSIS
    Orchestrates the complete Week 2 AI Foundation deployment across modules 02.02 and 02.03.

.DESCRIPTION
    This orchestrator script coordinates the deployment of all Week 2 AI Foundation components
    across modules 02.02 (Storage Account Deployment) and 02.03 (Azure OpenAI Service Deployment).
    It follows the established PowerShell style guide for orchestWrite-Host "✅ Week 2 complete orchestration completed successfully" -ForegroundColor Green
Write-Host "🚀 Ready for AI model customization and prompt template creation" -ForegroundColor Cyantor scripts using "Phase" 
    terminology and provides comprehensive validation, error handling, and deployment
    status tracking for the complete Week 2 learning path.

.PARAMETER EnvironmentName
    Name for the AI environment. Used for resource naming and tagging. Default: "aisec"

.PARAMETER Location
    Azure region for deployment. Default: "East US" (optimal for AI services)

.PARAMETER NotificationEmail
    Email address for cost alerts and budget notifications.

.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file.

.PARAMETER WhatIf
    Preview deployment without making changes.

.PARAMETER Force
    Force deployment without confirmation prompts (automation scenarios).

.PARAMETER SkipValidation
    Skip post-deployment validation testing.

.PARAMETER SkipStorage
    Skip module 02.02 storage foundation deployment.

.PARAMETER SkipOpenAI
    Skip module 02.03 Azure OpenAI service deployment.

.EXAMPLE
    .\Deploy-Week2Complete.ps1 -UseParametersFile
    
    Deploy complete Week 2 AI foundation using parameters file configuration.

.EXAMPLE
    .\Deploy-Week2Complete.ps1 -EnvironmentName "aisec" -Location "East US" -NotificationEmail "admin@company.com"
    
    Deploy with custom parameters.

.EXAMPLE
    .\Deploy-Week2Complete.ps1 -UseParametersFile -WhatIf
    
    Preview deployment without making changes.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-09-04
    Last Modified: 2025-09-04
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Azure CLI installed and authenticated
    - PowerShell 5.1+ or PowerShell 7+
    - Appropriate Azure permissions for resource deployment
    - Azure OpenAI service quota in East US region
    - Storage account creation permissions
    
    Script development orchestrated using GitHub Copilot.

.PHASES
    Phase 1: Module 02.02 - Storage Foundation Deployment (Deploy-StorageFoundation.ps1)
    Phase 2: Module 02.03 - Azure OpenAI Service Deployment (Deploy-OpenAIService.ps1)  
    Phase 3: Comprehensive Validation and Reporting across both modules
#>
#
# =============================================================================
# Week 2 Complete Orchestrator - Coordinates modules 02.02 and 02.03 deployment.
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName,
    
    [Parameter(Mandatory = $false)]
    [string]$Location,
    
    [Parameter(Mandatory = $false)]
    [string]$NotificationEmail,
    
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipValidation,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipStorage,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipOpenAI
)

# =============================================================================
# Script Configuration
# =============================================================================

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Define script paths
$scriptsPath = $PSScriptRoot
$deploymentScriptsPath = Join-Path $scriptsPath "..\scripts-deployment"
$validationScriptsPath = Join-Path $scriptsPath "..\scripts-validation"
$parametersPath = Join-Path $scriptsPath "..\..\infra\main.parameters.json"

# =============================================================================
# Parameters File Loading
# =============================================================================

if ($UseParametersFile) {
    Write-Host "📋 Loading configuration from parameters file..." -ForegroundColor Cyan
    
    if (Test-Path $parametersPath) {
        try {
            $parametersContent = Get-Content $parametersPath | ConvertFrom-Json
            $EnvironmentName = $parametersContent.parameters.environmentName.value
            $Location = $parametersContent.parameters.location.value
            $NotificationEmail = $parametersContent.parameters.notificationEmail.value
            
            Write-Host "   ✅ Parameters loaded successfully" -ForegroundColor Green
            Write-Host "      Environment: $EnvironmentName" -ForegroundColor White
            Write-Host "      Location: $Location" -ForegroundColor White
            Write-Host "      Notification: $NotificationEmail" -ForegroundColor White
        } catch {
            Write-Host "   ❌ Failed to load parameters file: $_" -ForegroundColor Red
            throw "Parameters file loading failed"
        }
    } else {
        Write-Host "   ❌ Parameters file not found: $parametersPath" -ForegroundColor Red
        throw "Parameters file not found"
    }
}

# Validate required parameters
if (-not $EnvironmentName) { $EnvironmentName = "aisec" }
if (-not $Location) { $Location = "East US" }
if (-not $NotificationEmail) {
    if (-not $UseParametersFile) {
        throw "NotificationEmail parameter is required when not using parameters file"
    }
}

# =============================================================================
# Main Orchestration
# =============================================================================

Write-Host "🚀 Week 2 Complete Orchestrator - Modules 02.02 & 02.03 Deployment" -ForegroundColor Magenta
Write-Host "===================================================================" -ForegroundColor Magenta

Write-Host ""
Write-Host "📋 Deployment Configuration:" -ForegroundColor Cyan
Write-Host "   Environment: $EnvironmentName" -ForegroundColor White
Write-Host "   Location: $Location" -ForegroundColor White
Write-Host "   Notification Email: $NotificationEmail" -ForegroundColor White
Write-Host "   Skip Storage: $SkipStorage" -ForegroundColor White
Write-Host "   Skip OpenAI: $SkipOpenAI" -ForegroundColor White
Write-Host "   What If Mode: $WhatIf" -ForegroundColor White

if ($WhatIf) {
    Write-Host ""
    Write-Host "💡 What If Mode - Preview Only" -ForegroundColor Yellow
    Write-Host "   No actual resources will be deployed" -ForegroundColor Yellow
}

# =============================================================================
# Phase 1: Storage Foundation Deployment
# =============================================================================

if (-not $SkipStorage) {
    Write-Host ""
    Write-Host "📋 Phase 1: Module 02.02 - Storage Foundation Deployment" -ForegroundColor Magenta
    Write-Host "=========================================================" -ForegroundColor Magenta
    
    try {
        $storageScriptPath = Join-Path $deploymentScriptsPath "Deploy-StorageFoundation.ps1"
        
        if (-not (Test-Path $storageScriptPath)) {
            throw "Storage deployment script not found: $storageScriptPath"
        }
        
        # Build parameter set for storage deployment
        $storageParams = @{}
        if ($UseParametersFile) {
            $storageParams.Add("UseParametersFile", $true)
        } else {
            $storageParams.Add("EnvironmentName", $EnvironmentName)
            $storageParams.Add("Location", $Location)
            $storageParams.Add("NotificationEmail", $NotificationEmail)
        }
        if ($WhatIf) { $storageParams.Add("WhatIf", $true) }
        if ($Force) { $storageParams.Add("Force", $true) }
        if ($SkipValidation) { $storageParams.Add("SkipValidation", $true) }
        
        Write-Host "🚀 Calling script 'Deploy-StorageFoundation.ps1'..." -ForegroundColor Blue
        & $storageScriptPath @storageParams
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Script 'Deploy-StorageFoundation.ps1' completed successfully" -ForegroundColor Blue
            Write-Host "✅ Phase 1 completed successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Script 'Deploy-StorageFoundation.ps1' failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
            throw "Storage deployment failed with exit code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "❌ Phase 1 failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "📋 Phase 1: Module 02.02 - Storage Foundation Deployment - SKIPPED" -ForegroundColor Magenta
    Write-Host "=================================================================" -ForegroundColor Magenta
    Write-Host "⏭️  Module 02.02 storage deployment skipped per user request" -ForegroundColor Yellow
}

# =============================================================================
# Phase 2: Azure OpenAI Service Deployment
# =============================================================================

if (-not $SkipOpenAI) {
    Write-Host ""
    Write-Host "📋 Phase 2: Module 02.03 - Azure OpenAI Service Deployment" -ForegroundColor Magenta
    Write-Host "==========================================================" -ForegroundColor Magenta
    
    try {
        $openaiScriptPath = Join-Path $deploymentScriptsPath "Deploy-OpenAIService.ps1"
        
        if (-not (Test-Path $openaiScriptPath)) {
            throw "OpenAI deployment script not found: $openaiScriptPath"
        }
        
        # Build parameter set for OpenAI deployment
        $openaiParams = @{}
        if ($UseParametersFile) {
            $openaiParams.Add("UseParametersFile", $true)
        } else {
            $openaiParams.Add("EnvironmentName", $EnvironmentName)
            $openaiParams.Add("Location", $Location)
        }
        if ($WhatIf) { $openaiParams.Add("WhatIf", $true) }
        if ($Force) { $openaiParams.Add("Force", $true) }
        if ($SkipValidation) { $openaiParams.Add("SkipValidation", $true) }
        
        Write-Host "🚀 Calling script 'Deploy-OpenAIService.ps1'..." -ForegroundColor Blue
        & $openaiScriptPath @openaiParams
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Script 'Deploy-OpenAIService.ps1' completed successfully" -ForegroundColor Blue
            Write-Host "✅ Phase 2 completed successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Script 'Deploy-OpenAIService.ps1' failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
            throw "OpenAI deployment failed with exit code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "❌ Phase 2 failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "📋 Phase 2: Module 02.03 - Azure OpenAI Service Deployment - SKIPPED" -ForegroundColor Magenta
    Write-Host "====================================================================" -ForegroundColor Magenta
    Write-Host "⏭️  Module 02.03 OpenAI deployment skipped per user request" -ForegroundColor Yellow
}

# =============================================================================
# Phase 3: Comprehensive Validation and Reporting
# =============================================================================

if (-not $SkipValidation -and -not $WhatIf) {
    Write-Host ""
    Write-Host "📋 Phase 3: Comprehensive Validation and Reporting" -ForegroundColor Magenta
    Write-Host "=================================================" -ForegroundColor Magenta
    
    try {
        # Check for validation scripts
        $storageValidationPath = Join-Path $validationScriptsPath "Test-StorageFoundation.ps1"
        
        if (-not $SkipStorage -and (Test-Path $storageValidationPath)) {
            Write-Host "🔍 Running storage foundation validation..." -ForegroundColor Cyan
            
            $validationParams = @{}
            if ($UseParametersFile) {
                $validationParams.Add("UseParametersFile", $true)
            } else {
                $validationParams.Add("EnvironmentName", $EnvironmentName)
            }
            
            Write-Host "🚀 Calling script 'Test-StorageFoundation.ps1'..." -ForegroundColor Blue
            & $storageValidationPath @validationParams
            
            if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
                Write-Host "✅ Storage validation completed successfully" -ForegroundColor Blue
            } else {
                Write-Host "⚠️  Storage validation completed with warnings (exit code: $LASTEXITCODE)" -ForegroundColor Yellow
            }
        }
        
        Write-Host ""
        Write-Host "📊 Deployment Summary" -ForegroundColor Cyan
        Write-Host "=====================" -ForegroundColor Cyan
        
        # Generate deployment summary
        $deployedComponents = @()
        if (-not $SkipStorage) { $deployedComponents += "✅ Storage Foundation" }
        if (-not $SkipOpenAI) { $deployedComponents += "✅ Azure OpenAI Service" }
        
        if ($deployedComponents.Count -gt 0) {
            Write-Host "Deployed Components:" -ForegroundColor Green
            foreach ($component in $deployedComponents) {
                Write-Host "   $component" -ForegroundColor Green
            }
        }
        
        # Cost estimation
        Write-Host ""
        Write-Host "💰 Estimated Monthly Costs" -ForegroundColor Cyan
        Write-Host "==========================" -ForegroundColor Cyan
        
        $totalCost = 0
        if (-not $SkipStorage) {
            Write-Host "   Storage Account: ~$10-15/month" -ForegroundColor Green
            $totalCost += 12.5
        }
        if (-not $SkipOpenAI) {
            Write-Host "   Azure OpenAI Service: ~$15-30/month" -ForegroundColor Green
            $totalCost += 22.5
        }
        
        Write-Host "   Total Estimated: ~$$totalCost/month" -ForegroundColor Yellow
        
        # Next steps
        Write-Host ""
        Write-Host "🎯 Next Steps" -ForegroundColor Cyan
        Write-Host "=============" -ForegroundColor Cyan
        Write-Host "   1. Configure OpenAI model with security persona" -ForegroundColor Yellow
        Write-Host "   2. Create AI prompt templates for security scenarios" -ForegroundColor Yellow
        Write-Host "   3. Set up comprehensive cost monitoring" -ForegroundColor Yellow
        Write-Host "   4. Prepare for Week 3 automation integration" -ForegroundColor Yellow
        
        Write-Host "✅ Phase 3 completed successfully" -ForegroundColor Green
        
    } catch {
        Write-Host "⚠️  Phase 3 completed with warnings: $_" -ForegroundColor Yellow
        # Don't fail the entire deployment for validation issues
    }
} else {
    Write-Host ""
    Write-Host "📋 Phase 3: Comprehensive Validation and Reporting - SKIPPED" -ForegroundColor Magenta
    Write-Host "=============================================================" -ForegroundColor Magenta
    
    if ($WhatIf) {
        Write-Host "⏭️  Validation skipped in What-If mode" -ForegroundColor Yellow
    } else {
        Write-Host "⏭️  Validation skipped per user request" -ForegroundColor Yellow
    }
}

# =============================================================================
# Completion Summary
# =============================================================================

Write-Host ""
Write-Host "🎉 AI Foundation Orchestration Complete" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

if ($WhatIf) {
    Write-Host "✅ What-If deployment preview completed successfully" -ForegroundColor Green
    Write-Host "💡 Run without -WhatIf to execute actual deployment" -ForegroundColor Yellow
} else {
    Write-Host "✅ Week 2 AI Foundation deployment orchestration completed successfully" -ForegroundColor Green
    Write-Host "🚀 Ready for AI model customization and prompt template creation" -ForegroundColor Cyan
}

Write-Host ""

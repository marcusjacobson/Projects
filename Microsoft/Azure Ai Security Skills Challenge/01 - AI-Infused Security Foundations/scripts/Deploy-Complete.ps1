# =============================================================================
# Microsoft Defender for Cloud - Complete Deployment Orchestrator
# =============================================================================
# This script orchestrates the complete deployment of Microsoft Defender for Cloud
# using all modular scripts in the correct sequence with comprehensive validation.
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Name for the environment")]
    [string]$EnvironmentName = "securitylab",
    
    [Parameter(Mandatory=$false, HelpMessage="Azure region for deployment")]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false, HelpMessage="Security contact email address")]
    [string]$SecurityContactEmail,
    
    [Parameter(Mandatory=$false, HelpMessage="Admin username for VMs")]
    [string]$AdminUsername = "azureadmin",
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Preview all deployments without executing")]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip confirmation prompts")]
    [switch]$Force,
    
    [Parameter(Mandatory=$false, HelpMessage="Deploy only specific phases (1-5)")]
    [int[]]$Phases = @(1,2,3,4,5)
)

# Script Configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host "🚀 Microsoft Defender for Cloud - Complete Deployment Orchestrator" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
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
            
            if ($mainParameters.parameters.adminUsername.value) {
                $AdminUsername = $mainParameters.parameters.adminUsername.value
                Write-Host "   ✅ Admin Username: $AdminUsername" -ForegroundColor Green
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

# Validate script directory
$scriptsPath = $PSScriptRoot
if (-not $scriptsPath) {
    $scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
}

Write-Host "📋 Deployment Configuration:" -ForegroundColor Cyan
Write-Host "   Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   Location: $Location" -ForegroundColor White
Write-Host "   Admin Username: $AdminUsername" -ForegroundColor White
Write-Host "   Security Contact: $(if ($SecurityContactEmail) { $SecurityContactEmail } else { 'Not provided - will prompt' })" -ForegroundColor White
Write-Host "   What-If Mode: $WhatIf" -ForegroundColor White
Write-Host "   Phases to Deploy: $($Phases -join ', ')" -ForegroundColor White
Write-Host "   Scripts Location: $scriptsPath" -ForegroundColor White
Write-Host ""

# Validate required scripts exist
$requiredScripts = @(
    "Deploy-InfrastructureFoundation.ps1",
    "Deploy-VirtualMachines.ps1", 
    "Deploy-DefenderPlans.ps1",
    "Deploy-SecurityFeatures.ps1",
    "Test-DeploymentValidation.ps1"
)

Write-Host "🔍 Validating deployment scripts..." -ForegroundColor Cyan
$missingScripts = @()
foreach ($script in $requiredScripts) {
    $scriptPath = Join-Path $scriptsPath $script
    if (Test-Path $scriptPath) {
        Write-Host "   ✅ Found: $script" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Missing: $script" -ForegroundColor Red
        $missingScripts += $script
    }
}

if ($missingScripts.Count -gt 0) {
    Write-Host ""
    Write-Host "❌ Missing required scripts. Please ensure all deployment scripts are present." -ForegroundColor Red
    Write-Host "   Missing: $($missingScripts -join ', ')" -ForegroundColor Yellow
    exit 1
}

# Prompt for security contact email if not provided
if (-not $SecurityContactEmail -and -not $WhatIf) {
    Write-Host ""
    Write-Host "📧 Security Contact Configuration:" -ForegroundColor Yellow
    $SecurityContactEmail = Read-Host "Enter security contact email address for alerts"
    if (-not $SecurityContactEmail) {
        Write-Host "   ⚠️ No email provided - Defender plans script will prompt later" -ForegroundColor Yellow
    }
}

if (-not $Force -and -not $WhatIf) {
    Write-Host ""
    Write-Host "🎯 Ready to deploy Microsoft Defender for Cloud with the following phases:" -ForegroundColor Yellow
    if (1 -in $Phases) { Write-Host "   📋 Phase 1: Infrastructure Foundation (Resource Group, Log Analytics, VNet, Storage)" -ForegroundColor White }
    if (2 -in $Phases) { Write-Host "   🖥️ Phase 2: Virtual Machines (Windows & Linux VMs with extensions)" -ForegroundColor White }
    if (3 -in $Phases) { Write-Host "   🛡️ Phase 3: Defender Plans (Enable plans and security contacts)" -ForegroundColor White }
    if (4 -in $Phases) { Write-Host "   🔐 Phase 4: Security Features (JIT access, security configuration)" -ForegroundColor White }
    if (5 -in $Phases) { Write-Host "   ✅ Phase 5: Validation (Comprehensive deployment verification)" -ForegroundColor White }
    Write-Host ""
    
    $confirmation = Read-Host "Do you want to proceed with the deployment? (y/N)"
    if ($confirmation -ne "y" -and $confirmation -ne "Y") {
        Write-Host "❌ Deployment cancelled by user" -ForegroundColor Red
        exit 0
    }
}

$deploymentResults = @{
    StartTime = Get-Date
    Phases = @{}
    Overall = @{ Status = "Unknown"; Success = $false }
}

Write-Host ""
Write-Host "🎬 Starting deployment phases..." -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# =============================================================================
# Phase 1: Infrastructure Foundation
# =============================================================================

if (1 -in $Phases) {
    Write-Host ""
    Write-Host "📋 Phase 1: Infrastructure Foundation" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    
    try {
        $scriptPath = Join-Path $scriptsPath "Deploy-InfrastructureFoundation.ps1"
        $params = @{
            EnvironmentName = $EnvironmentName
            Location = $Location
        }
        
        if ($UseParametersFile) { $params.UseParametersFile = $true }
        if ($WhatIf) { $params.WhatIf = $true }
        if ($Force) { $params.Force = $true }
        
        Write-Host "🚀 Executing infrastructure deployment..." -ForegroundColor Cyan
        & $scriptPath @params
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Phase 1 completed successfully" -ForegroundColor Green
            $deploymentResults.Phases["Phase1"] = @{ Status = "Success"; Description = "Infrastructure Foundation" }
        } else {
            throw "Script exited with code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "❌ Phase 1 failed: $_" -ForegroundColor Red
        $deploymentResults.Phases["Phase1"] = @{ Status = "Failed"; Description = "Infrastructure Foundation"; Error = $_ }
        if (-not $Force) {
            Write-Host "🛑 Stopping deployment due to Phase 1 failure" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "⏭️ Skipping Phase 1: Infrastructure Foundation" -ForegroundColor Yellow
}

# =============================================================================
# Phase 2: Virtual Machines
# =============================================================================

if (2 -in $Phases) {
    Write-Host ""
    Write-Host "🖥️ Phase 2: Virtual Machines" -ForegroundColor Green
    Write-Host "============================" -ForegroundColor Green
    
    try {
        $scriptPath = Join-Path $scriptsPath "Deploy-VirtualMachines.ps1"
        $params = @{
            EnvironmentName = $EnvironmentName
            Location = $Location
            AdminUsername = $AdminUsername
        }
        
        if ($UseParametersFile) { $params.UseParametersFile = $true }
        if ($WhatIf) { $params.WhatIf = $true }
        if ($Force) { $params.Force = $true }
        
        Write-Host "🚀 Executing virtual machine deployment..." -ForegroundColor Cyan
        & $scriptPath @params
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Phase 2 completed successfully" -ForegroundColor Green
            $deploymentResults.Phases["Phase2"] = @{ Status = "Success"; Description = "Virtual Machines" }
        } else {
            throw "Script exited with code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "❌ Phase 2 failed: $_" -ForegroundColor Red
        $deploymentResults.Phases["Phase2"] = @{ Status = "Failed"; Description = "Virtual Machines"; Error = $_ }
        if (-not $Force) {
            Write-Host "🛑 Stopping deployment due to Phase 2 failure" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "⏭️ Skipping Phase 2: Virtual Machines" -ForegroundColor Yellow
}

# =============================================================================
# Phase 3: Defender Plans
# =============================================================================

if (3 -in $Phases) {
    Write-Host ""
    Write-Host "🛡️ Phase 3: Defender Plans Configuration" -ForegroundColor Green
    Write-Host "=======================================" -ForegroundColor Green
    
    try {
        $scriptPath = Join-Path $scriptsPath "Deploy-DefenderPlans.ps1"
        $params = @{
            EnvironmentName = $EnvironmentName
        }
        
        if ($SecurityContactEmail) { $params.SecurityContactEmail = $SecurityContactEmail }
        if ($UseParametersFile) { $params.UseParametersFile = $true }
        if ($WhatIf) { $params.WhatIf = $true }
        if ($Force) { $params.Force = $true }
        
        Write-Host "🚀 Executing Defender plans configuration..." -ForegroundColor Cyan
        & $scriptPath @params
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Phase 3 completed successfully" -ForegroundColor Green
            $deploymentResults.Phases["Phase3"] = @{ Status = "Success"; Description = "Defender Plans" }
        } else {
            throw "Script exited with code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "❌ Phase 3 failed: $_" -ForegroundColor Red
        $deploymentResults.Phases["Phase3"] = @{ Status = "Failed"; Description = "Defender Plans"; Error = $_ }
        if (-not $Force) {
            Write-Host "🛑 Stopping deployment due to Phase 3 failure" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "⏭️ Skipping Phase 3: Defender Plans Configuration" -ForegroundColor Yellow
}

# =============================================================================
# Phase 4: Security Features
# =============================================================================

if (4 -in $Phases) {
    Write-Host ""
    Write-Host "🔐 Phase 4: Security Features" -ForegroundColor Green
    Write-Host "=============================" -ForegroundColor Green
    
    try {
        $scriptPath = Join-Path $scriptsPath "Deploy-SecurityFeatures.ps1"
        $params = @{
            EnvironmentName = $EnvironmentName
            Location = $Location
        }
        
        if ($UseParametersFile) { $params.UseParametersFile = $true }
        if ($WhatIf) { $params.WhatIf = $true }
        if ($Force) { $params.Force = $true }
        
        Write-Host "🚀 Executing security features configuration..." -ForegroundColor Cyan
        & $scriptPath @params
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Phase 4 completed successfully" -ForegroundColor Green
            $deploymentResults.Phases["Phase4"] = @{ Status = "Success"; Description = "Security Features" }
        } else {
            throw "Script exited with code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "❌ Phase 4 failed: $_" -ForegroundColor Red
        $deploymentResults.Phases["Phase4"] = @{ Status = "Failed"; Description = "Security Features"; Error = $_ }
        if (-not $Force) {
            Write-Host "🛑 Stopping deployment due to Phase 4 failure" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "⏭️ Skipping Phase 4: Security Features" -ForegroundColor Yellow
}

# =============================================================================
# Phase 5: Deployment Validation
# =============================================================================

if (5 -in $Phases) {
    Write-Host ""
    Write-Host "✅ Phase 5: Deployment Validation" -ForegroundColor Green
    Write-Host "=================================" -ForegroundColor Green
    
    try {
        $scriptPath = Join-Path $scriptsPath "Test-DeploymentValidation.ps1"
        $params = @{
            EnvironmentName = $EnvironmentName
            Location = $Location
            DetailedReport = $true
            ExportResults = $true
        }
        
        if ($UseParametersFile) { $params.UseParametersFile = $true }
        
        Write-Host "🚀 Executing deployment validation..." -ForegroundColor Cyan
        & $scriptPath @params
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Phase 5 completed successfully" -ForegroundColor Green
            $deploymentResults.Phases["Phase5"] = @{ Status = "Success"; Description = "Deployment Validation" }
        } else {
            throw "Script exited with code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "❌ Phase 5 failed: $_" -ForegroundColor Red
        $deploymentResults.Phases["Phase5"] = @{ Status = "Failed"; Description = "Deployment Validation"; Error = $_ }
    }
} else {
    Write-Host "⏭️ Skipping Phase 5: Deployment Validation" -ForegroundColor Yellow
}

# =============================================================================
# Deployment Summary
# =============================================================================

$deploymentResults.EndTime = Get-Date
$deploymentResults.Duration = $deploymentResults.EndTime - $deploymentResults.StartTime

Write-Host ""
Write-Host "📊 Deployment Summary" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""

$successfulPhases = $deploymentResults.Phases.Values | Where-Object { $_.Status -eq "Success" }
$failedPhases = $deploymentResults.Phases.Values | Where-Object { $_.Status -eq "Failed" }

Write-Host "🎯 Overall Status:" -ForegroundColor Cyan
if ($failedPhases.Count -eq 0 -and $successfulPhases.Count -gt 0) {
    Write-Host "   🎉 SUCCESS! All phases completed successfully" -ForegroundColor Green
    $deploymentResults.Overall.Status = "Success"
    $deploymentResults.Overall.Success = $true
} elseif ($failedPhases.Count -gt 0 -and $successfulPhases.Count -gt 0) {
    Write-Host "   ⚠️ PARTIAL SUCCESS - Some phases failed" -ForegroundColor Yellow
    $deploymentResults.Overall.Status = "Partial"
} else {
    Write-Host "   ❌ FAILED - Deployment unsuccessful" -ForegroundColor Red
    $deploymentResults.Overall.Status = "Failed"
}

Write-Host ""
Write-Host "📋 Phase Results:" -ForegroundColor Cyan
foreach ($phase in $deploymentResults.Phases.Keys | Sort-Object) {
    $result = $deploymentResults.Phases[$phase]
    $status = if ($result.Status -eq "Success") { "✅" } else { "❌" }
    Write-Host "   $status $phase`: $($result.Description) - $($result.Status)" -ForegroundColor White
    if ($result.Error) {
        Write-Host "      Error: $($result.Error)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "⏱️ Total Duration: $($deploymentResults.Duration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host ""
    Write-Host "👁️ Preview Mode Summary:" -ForegroundColor Yellow
    Write-Host "   • All phases were previewed successfully" -ForegroundColor White
    Write-Host "   • No actual resources were deployed" -ForegroundColor White
    Write-Host "   • Run without -WhatIf to execute the deployment" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "💡 Next Steps:" -ForegroundColor Yellow
    
    if ($deploymentResults.Overall.Success) {
        Write-Host "   • 🎉 Deployment completed successfully!" -ForegroundColor Green
        Write-Host "   • Visit Azure Portal to explore your Defender for Cloud deployment" -ForegroundColor White
        Write-Host "   • Generate sample alerts: Defender for Cloud → Security alerts → Sample alerts" -ForegroundColor White
        Write-Host "   • Review security recommendations in the portal" -ForegroundColor White
        Write-Host "   • Consider integrating with Microsoft Sentinel for SIEM capabilities" -ForegroundColor White
    } else {
        Write-Host "   • Review failed phases and error messages above" -ForegroundColor White
        Write-Host "   • Run individual scripts to troubleshoot specific issues" -ForegroundColor White
        Write-Host "   • Use -WhatIf mode to preview changes before retry" -ForegroundColor White
        Write-Host "   • Check Azure Portal for partial deployments" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "🎯 Microsoft Defender for Cloud deployment orchestration completed!" -ForegroundColor Green

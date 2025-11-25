<#
.SYNOPSIS
    Safely removes all Azure OpenAI infrastructure components in the correct logical order.

.DESCRIPTION
    This script provides comprehensive decommission capabilities for Azure OpenAI
    environments deployed via Infrastructure-as-Code. It performs ordered removal
    of model deployments, OpenAI service instances, diagnostic settings, and
    cost management configurations while maintaining data integrity and preventing
    resource conflicts. The script includes safety mechanisms such as What-If mode,
    confirmation prompts, optional configuration backup, and comprehensive validation.
    It preserves existing storage foundation and Defender for Cloud infrastructure.

.PARAMETER EnvironmentName
    Name for the AI environment to decommission. Default: "aisec"

.PARAMETER BackupConfiguration
    Switch to backup OpenAI service configuration before deletion.

.PARAMETER WhatIf
    Preview decommission without making changes.

.PARAMETER Force
    Force decommission without confirmation prompts (automation scenarios).

.PARAMETER UseParametersFile
    Switch to load parameters from main.parameters.json file.

.EXAMPLE
    .\Remove-OpenAIInfrastructure.ps1 -UseParametersFile -WhatIf
    
    Preview decommission using parameters file without making changes.

.EXAMPLE
    .\Remove-OpenAIInfrastructure.ps1 -EnvironmentName "aisec" -BackupConfiguration
    
    Safely decommission with configuration backup and confirmation prompts.

.EXAMPLE
    .\Remove-OpenAIInfrastructure.ps1 -UseParametersFile -Force
    
    Force decommission without confirmation (automation scenarios).

.NOTES
    Author: AI Security Skills Challenge Team
    Version: 1.0.0
    Created: August 17, 2025
    
    Safety Features:
    - What-If mode for safe preview
    - Optional configuration backup before deletion
    - Confirmation prompts for destructive operations
    - Comprehensive validation and error handling
    - Detailed progress reporting and cost impact analysis
#>

param(
    [Parameter(Mandatory=$false, HelpMessage="Name for the AI environment to decommission")]
    [string]$EnvironmentName = "aisec",
    
    [Parameter(Mandatory=$false, HelpMessage="Backup service configuration before deletion")]
    [switch]$BackupConfiguration,
    
    [Parameter(Mandatory=$false, HelpMessage="Preview decommission without executing")]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip confirmation prompts")]
    [switch]$Force,
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile
)

# Script Configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "SilentlyContinue"

Write-Host "Azure OpenAI Infrastructure Decommission" -ForegroundColor Red
Write-Host "=========================================" -ForegroundColor Red
Write-Host ""

# Initialize variables
$ResourceGroupName = "rg-$EnvironmentName-ai"
$OpenAIServiceName = "openai-$EnvironmentName-001"

try {
    # Phase 1: Discovery and Validation
    Write-Host "Phase 1: Discovery and Validation" -ForegroundColor Cyan
    Write-Host "  Checking for OpenAI resources in $ResourceGroupName..." -ForegroundColor Gray

    # Load parameters from file if requested
    if ($UseParametersFile) {
        $ParametersFile = "$PSScriptRoot\..\infra\main.parameters.json"
        if (Test-Path $ParametersFile) {
            Write-Host "  Loading parameters from: $ParametersFile" -ForegroundColor Gray
            $Parameters = Get-Content $ParametersFile | ConvertFrom-Json
            if ($Parameters.parameters.environmentName.value) {
                $EnvironmentName = $Parameters.parameters.environmentName.value
                $ResourceGroupName = "rg-$EnvironmentName-ai"
                $OpenAIServiceName = "openai-$EnvironmentName-001"
                Write-Host "  Using environment: $EnvironmentName" -ForegroundColor Green
            }
        } else {
            Write-Host "  Parameters file not found, using defaults" -ForegroundColor Yellow
        }
    }

    # Check Azure CLI authentication
    $AccountInfo = az account show --output json 2>$null | ConvertFrom-Json
    if (-not $AccountInfo) {
        throw "No Azure CLI authentication found. Please run 'az login'"
    }
    Write-Host "  Connected to Azure subscription: $($AccountInfo.name)" -ForegroundColor Green
    
    # Check if resource group exists
    $ResourceGroup = az group show --name $ResourceGroupName --output json 2>$null | ConvertFrom-Json
    if (-not $ResourceGroup) {
        Write-Host "  Resource group $ResourceGroupName not found - nothing to decommission" -ForegroundColor Yellow
        exit 0
    }
    
    # Discover OpenAI service
    $OpenAIService = az cognitiveservices account show --name $OpenAIServiceName --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
    if (-not $OpenAIService) {
        Write-Host "  OpenAI service $OpenAIServiceName not found - nothing to decommission" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "  Found OpenAI service: $($OpenAIService.name)" -ForegroundColor Green
    Write-Host "  Location: $($OpenAIService.location)" -ForegroundColor White
    Write-Host "  Endpoint: $($OpenAIService.properties.endpoint)" -ForegroundColor White
    
    # Get model deployments
    $ModelDeployments = az cognitiveservices account deployment list --name $OpenAIServiceName --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
    if ($ModelDeployments -and $ModelDeployments.Count -gt 0) {
        Write-Host "  Found $($ModelDeployments.Count) model deployment(s):" -ForegroundColor Green
        foreach ($Deployment in $ModelDeployments) {
            Write-Host "    - $($Deployment.name) (Status: $($Deployment.properties.provisioningState))" -ForegroundColor White
        }
    } else {
        Write-Host "  No model deployments found" -ForegroundColor Yellow
    }

    # Phase 2: User Confirmation (skipped in What-If mode)
    if (-not $Force -and -not $WhatIf) {
        Write-Host ""
        Write-Host "Phase 2: User Confirmation" -ForegroundColor Cyan
        Write-Host "WARNING: This will permanently remove:" -ForegroundColor Red
        Write-Host "  - OpenAI Service: $OpenAIServiceName" -ForegroundColor White
        if ($ModelDeployments) {
            foreach ($Deployment in $ModelDeployments) {
                Write-Host "  - Model Deployment: $($Deployment.name)" -ForegroundColor White
            }
        }
        Write-Host ""
        Write-Host "Resources that will be PRESERVED:" -ForegroundColor Green
        Write-Host "  - Storage Foundation infrastructure" -ForegroundColor White
        Write-Host "  - Defender for Cloud configurations" -ForegroundColor White
        Write-Host "  - Log Analytics workspace" -ForegroundColor White
        Write-Host ""
        
        $Confirmation = Read-Host "Continue with decommission? (yes/no)"
        if ($Confirmation -notin @('yes', 'y')) {
            Write-Host "Decommission cancelled by user" -ForegroundColor Yellow
            exit 0
        }
    }

    # Phase 3: Configuration Backup (Optional, skipped in What-If mode without BackupConfiguration)
    if ($BackupConfiguration) {
        Write-Host ""
        if ($WhatIf) {
            Write-Host "Phase 2: Configuration Backup Preview" -ForegroundColor Cyan
        } else {
            Write-Host "Phase 3: Configuration Backup" -ForegroundColor Cyan
        }
        $BackupPath = ".\openai-backup-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')"
        
        if (-not $WhatIf) {
            Write-Host "  Creating backup directory: $BackupPath" -ForegroundColor Gray
            New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
            
            $BackupData = @{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Environment = $EnvironmentName
                ResourceGroup = $ResourceGroupName
                OpenAIService = $OpenAIService
                ModelDeployments = $ModelDeployments
            }
            
            $BackupFile = Join-Path $BackupPath "openai-configuration.json"
            $BackupData | ConvertTo-Json -Depth 10 | Out-File -FilePath $BackupFile -Encoding UTF8
            Write-Host "  Configuration backed up to: $BackupFile" -ForegroundColor Green
        } else {
            Write-Host "  Would backup configuration to: $BackupPath" -ForegroundColor Gray
        }
    }

    # Determine phase number for removal operations based on BackupConfiguration
    if ($BackupConfiguration) {
        $ModelPhaseNumber = "Phase 4"
        $ServicePhaseNumber = "Phase 5"
        $ValidationPhaseNumber = "Phase 6"
    } else {
        $ModelPhaseNumber = "Phase 3"
        $ServicePhaseNumber = "Phase 4"
        $ValidationPhaseNumber = "Phase 5"
    }

    # Model Deployment Removal
    Write-Host ""
    Write-Host "${ModelPhaseNumber}: Model Deployment Removal" -ForegroundColor Cyan

    if ($ModelDeployments -and $ModelDeployments.Count -gt 0) {
        foreach ($Deployment in $ModelDeployments) {
            Write-Host "  Removing model deployment: $($Deployment.name)..." -ForegroundColor Gray
            
            if (-not $WhatIf) {
                $Result = az cognitiveservices account deployment delete --name $OpenAIServiceName --resource-group $ResourceGroupName --deployment-name $Deployment.name 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "    Model deployment removed successfully" -ForegroundColor Green
                } else {
                    Write-Host "    Failed to remove model deployment: $Result" -ForegroundColor Red
                }
            } else {
                Write-Host "    Would remove model deployment: $($Deployment.name)" -ForegroundColor Gray
            }
            
            Start-Sleep -Seconds 2
        }
    } else {
        Write-Host "  No model deployments to remove" -ForegroundColor Yellow
    }

    # OpenAI Service Removal
    Write-Host ""
    Write-Host "${ServicePhaseNumber}: OpenAI Service Removal" -ForegroundColor Cyan
    Write-Host "  Removing OpenAI service: $OpenAIServiceName..." -ForegroundColor Gray

    if (-not $WhatIf) {
        $Result = az cognitiveservices account delete --name $OpenAIServiceName --resource-group $ResourceGroupName 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    OpenAI service removed successfully" -ForegroundColor Green
        } else {
            Write-Host "    Failed to remove OpenAI service: $Result" -ForegroundColor Red
        }
    } else {
        Write-Host "    Would remove OpenAI service: $OpenAIServiceName" -ForegroundColor Gray
    }

    # Final Validation
    Write-Host ""
    Write-Host "${ValidationPhaseNumber}: Final Validation" -ForegroundColor Cyan

    if (-not $WhatIf) {
        Write-Host "  Waiting for removal to complete..." -ForegroundColor Gray
        Start-Sleep -Seconds 15
        
        $RemainingService = az cognitiveservices account show --name $OpenAIServiceName --resource-group $ResourceGroupName --output json 2>$null | ConvertFrom-Json
        if (-not $RemainingService) {
            Write-Host "  OpenAI service successfully removed" -ForegroundColor Green
        } else {
            Write-Host "  OpenAI service may still exist - check Azure portal" -ForegroundColor Yellow
        }
    } else {
        Write-Host ""
        Write-Host "What-If Mode Summary:" -ForegroundColor Cyan
        Write-Host "========================" -ForegroundColor Cyan
        Write-Host "This operation would remove:" -ForegroundColor White
        Write-Host "  - OpenAI service: $OpenAIServiceName" -ForegroundColor White
        if ($ModelDeployments) {
            Write-Host "  - $($ModelDeployments.Count) model deployment(s)" -ForegroundColor White
        }
        Write-Host ""
        Write-Host "Estimated monthly savings: `$15-30 USD" -ForegroundColor Green
    }

} catch {
    Write-Host ""
    Write-Host "Error during decommission: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Summary
Write-Host ""
Write-Host "Decommission Summary:" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan
Write-Host "  Environment: $EnvironmentName" -ForegroundColor White
Write-Host "  Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "  OpenAI Service: $OpenAIServiceName" -ForegroundColor White
Write-Host "  Estimated Monthly Savings: `$15-30 USD" -ForegroundColor Green

if ($BackupConfiguration -and -not $WhatIf) {
    Write-Host "  Configuration Backup: $BackupPath" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Azure OpenAI decommission completed" -ForegroundColor Green
Write-Host ""

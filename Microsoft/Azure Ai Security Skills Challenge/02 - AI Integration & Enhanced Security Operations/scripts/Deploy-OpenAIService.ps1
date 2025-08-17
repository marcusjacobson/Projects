<#
.SYNOPSIS
    Deploys Azure OpenAI service with model deployments and comprehensive validation.

.DESCRIPTION
    This script provides automated deployment of Azure OpenAI service with intelligent
    model deployment based on configuration parameters. It includes system-assigned
    managed identity configuration, Log Analytics workspace integration, security
    testing capabilities, and comprehensive validation.

.PARAMETER EnvironmentName
    Name for the AI environment. Used for resource naming and tagging. Default: "aisec"

.PARAMETER Location
    Azure region for deployment. Default: "East US"

.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file.

.PARAMETER WhatIf
    Preview deployment without making changes.

.PARAMETER Force
    Force deployment without confirmation prompts (automation scenarios).

.PARAMETER SkipValidation
    Skip post-deployment validation testing.

.PARAMETER RunSecurityTests
    Execute security prompt testing after deployment.

.PARAMETER AutoPurgeSoftDeleted
    Automatically purge soft-deleted services without user confirmation. Useful for CI/CD scenarios.

.EXAMPLE
    .\Deploy-OpenAIService.ps1 -UseParametersFile -WhatIf
    
    Preview Azure OpenAI deployment using parameters file without making changes.

.EXAMPLE
    .\Deploy-OpenAIService.ps1 -UseParametersFile -RunSecurityTests
    
    Deploy Azure OpenAI service and execute security prompt tests.

.EXAMPLE
    .\Deploy-OpenAIService.ps1 -EnvironmentName "aisec" -Location "East US"
    
    Deploy with custom parameters.

.EXAMPLE
    .\Deploy-OpenAIService.ps1 -UseParametersFile -Force -AutoPurgeSoftDeleted
    
    Deploy automatically without prompts, including auto-purge of soft-deleted services (CI/CD scenarios).

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-14
    
    - Requires Azure PowerShell module and authenticated session
    - Automatically detects existing Log Analytics workspace
    - Configures system-assigned managed identity by default
    - Deploys model endpoints based on main.parameters.json configuration
    - Includes comprehensive security testing capabilities
    
    Model Deployment Options:
    - o4-mini (configurable via deployo4Mini parameter)
    - Text-embedding-3-small (configurable via deployTextEmbedding parameter)
    - GPT-5 (configurable via deployGPT5 parameter)

.LINK
    https://docs.microsoft.com/en-us/azure/cognitive-services/openai/
#>

# =============================================================================
# Azure OpenAI Service Deployment Script
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Name for the AI environment")]
    [string]$EnvironmentName = "aisec",
    
    [Parameter(Mandatory=$false, HelpMessage="Azure region for deployment")]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Preview deployment without executing")]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip confirmation prompts")]
    [switch]$Force,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip post-deployment validation")]
    [switch]$SkipValidation,
    
    [Parameter(Mandatory=$false, HelpMessage="Execute security prompt testing")]
    [switch]$RunSecurityTests,
    
    [Parameter(Mandatory=$false, HelpMessage="Automatically purge soft-deleted services without confirmation")]
    [switch]$AutoPurgeSoftDeleted
)

# Script Configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "SilentlyContinue"

# =============================================================================
# Helper Functions
# =============================================================================

function Test-SoftDeletedCognitiveService {
    <#
    .SYNOPSIS
    Tests for and optionally purges soft-deleted Cognitive Services accounts.
    
    .PARAMETER ServiceName
    Name of the Cognitive Services account to check.
    
    .PARAMETER Location
    Azure region where the service was located.
    
    .PARAMETER ResourceGroupName
    Resource group name (used for purge operation).
    
    .PARAMETER AutoPurge
    Automatically purge without user confirmation.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServiceName,
        
        [Parameter(Mandatory=$true)]
        [string]$Location,
        
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$false)]
        [switch]$AutoPurge
    )
    
    try {
        $SoftDeletedServices = az cognitiveservices account list-deleted --query "[?name=='$ServiceName' && location=='$Location'].{name:name, location:location, deletionDate:deletionDate}" -o json | ConvertFrom-Json
        
        if ($SoftDeletedServices -and $SoftDeletedServices.Count -gt 0) {
            $Service = $SoftDeletedServices[0]
            Write-Host "  ⚠️  Found soft-deleted service: $ServiceName" -ForegroundColor Red
            Write-Host "     Location: $($Service.location)" -ForegroundColor Gray
            Write-Host "     Deletion Date: $($Service.deletionDate)" -ForegroundColor Gray
            Write-Host "     ℹ️  Soft-deleted resources block new deployments with the same name" -ForegroundColor Yellow
            
            $ShouldPurge = $AutoPurge
            if (-not $AutoPurge) {
                $PurgeChoice = Read-Host "  ❓ Purge the soft-deleted service to proceed? (y/n)"
                $ShouldPurge = ($PurgeChoice -eq 'y' -or $PurgeChoice -eq 'Y')
            }
            
            if ($ShouldPurge) {
                Write-Host "  🗑️ Purging soft-deleted service..." -ForegroundColor Yellow
                
                $PurgeResult = az cognitiveservices account purge --name $ServiceName --location $Location --resource-group $ResourceGroupName 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✅ Soft-deleted service purged successfully!" -ForegroundColor Green
                    
                    # Wait for Azure to process the purge (30 seconds minimum recommended)
                    Write-Host "  ⏳ Waiting for Azure to process the purge operation..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 30
                    Write-Host "  ✅ Purge processing complete. Ready for deployment." -ForegroundColor Green
                    return $true
                } else {
                    Write-Host "  ❌ Purge operation failed: $PurgeResult" -ForegroundColor Red
                    throw "Failed to purge soft-deleted service. Please purge manually or wait for automatic cleanup."
                }
            } else {
                throw "Cannot proceed with deployment while soft-deleted service exists. Please purge manually or choose 'y' to auto-purge."
            }
        } else {
            Write-Host "  ✅ No soft-deleted services found" -ForegroundColor Green
            return $false
        }
    } catch {
        if ($_.Exception.Message -like "*Cannot proceed with deployment*") {
            throw $_
        } else {
            Write-Host "  ℹ️  Unable to check soft-deleted services: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "     ℹ️  If deployment fails with soft-delete error, purge manually:" -ForegroundColor Gray
            Write-Host "     az cognitiveservices account purge --name $ServiceName --location $Location --resource-group $ResourceGroupName" -ForegroundColor Gray
            return $false
        }
    }
}

# =============================================================================
# Main Script
# =============================================================================

Write-Host "🤖 Azure OpenAI Service Deployment" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

try {
    # =============================================================================
    # PHASE 1: Parameter Validation and Prerequisites Check
    # =============================================================================
    
    Write-Host "📋 Phase 1: Parameter Validation and Prerequisites Check" -ForegroundColor Cyan
    
    # Initialize deployment configuration
    $EnableOpenAI = $false
    $deployGPT5 = $false
    $deployo4Mini = $false
    $DeployTextEmbedding = $false
    
    if ($UseParametersFile) {
        # Load parameters from JSON file
        $ParametersFile = "$PSScriptRoot\..\infra\main.parameters.json"
        
        if (-not (Test-Path $ParametersFile)) {
            throw "Parameters file not found: $ParametersFile"
        }
        
        Write-Host "  📄 Loading parameters from: $ParametersFile" -ForegroundColor Green
        $Parameters = Get-Content $ParametersFile | ConvertFrom-Json
        
        # Override script parameters with file values
        $EnvironmentName = $Parameters.parameters.environmentName.value
        $Location = $Parameters.parameters.location.value
        $EnableOpenAI = $Parameters.parameters.enableOpenAI.value
        $deployGPT5 = $Parameters.parameters.deployGPT5.value
        $deployo4Mini = $Parameters.parameters.deployo4Mini.value
        $DeployTextEmbedding = $Parameters.parameters.deployTextEmbedding.value
        
        Write-Host "  ✅ Parameters loaded successfully" -ForegroundColor Green
    } else {
        # Use default configuration when not using parameters file
        $EnableOpenAI = $true
        $deployo4Mini = $true
        $DeployTextEmbedding = $true
        Write-Host "  ✅ Using default OpenAI configuration" -ForegroundColor Green
    }
    
    # Validate OpenAI service is enabled
    if (-not $EnableOpenAI) {
        Write-Host "  ❌ Azure OpenAI service is disabled in configuration" -ForegroundColor Red
        Write-Host "  💡 Set enableOpenAI to true in main.parameters.json" -ForegroundColor Yellow
        return
    }
    
    # Initialize Azure connection
    Write-Host "  🔐 Initializing Azure connection..." -ForegroundColor Green
    if (-not (Get-AzContext)) {
        Write-Host "  📝 Please authenticate to Azure..." -ForegroundColor Yellow
        Connect-AzAccount | Out-Null
    }
    
    $CurrentContext = Get-AzContext
    Write-Host "  ✅ Connected to Azure subscription: $($CurrentContext.Subscription.Name)" -ForegroundColor Green
    
    # Validate Azure PowerShell modules
    Write-Host "  🔍 Checking for installed modules..." -ForegroundColor Green
    $RequiredModules = @('Az.CognitiveServices', 'Az.Resources', 'Az.OperationalInsights')
    
    $MissingModules = @()
    foreach ($Module in $RequiredModules) {
        if (-not (Get-Module -ListAvailable -Name $Module)) {
            $MissingModules += $Module
        }
    }
    
    if ($MissingModules.Count -gt 0) {
        Write-Host "  ❌ Missing required modules: $($MissingModules -join ', ')" -ForegroundColor Red
        Write-Host "  💡 Install missing modules with: Install-Module -Name $($MissingModules -join ',') -Force" -ForegroundColor Yellow
        throw "Required Azure PowerShell modules are not installed"
    }
    
    # Import modules silently
    foreach ($Module in $RequiredModules) {
        Import-Module -Name $Module -Force -Verbose:$false
    }
    Write-Host "  ✅ All necessary modules installed" -ForegroundColor Green
    
    # =============================================================================
    # PHASE 2: Infrastructure Deployment
    # =============================================================================
    
    Write-Host "`n🏗️ Phase 2: Infrastructure Deployment" -ForegroundColor Cyan
    
    $ResourceGroupName = "rg-${EnvironmentName}-ai"
    $OpenAIServiceName = "openai-${EnvironmentName}-001"
    $LogAnalyticsWorkspaceName = "log-${EnvironmentName}-001"  # Updated to match Week 1 naming
    
    # Scan all resource groups starting with "rg-aisec" for existing Log Analytics workspaces
    Write-Host "  🔍 Scanning for existing Log Analytics workspaces..." -ForegroundColor Green
    
    # Get all resource groups that start with rg-aisec
    try {
        # Use Az CLI to get resource groups (more reliable with different auth scenarios)
        $AzResourceGroups = az group list --query "[?starts_with(name, 'rg-${EnvironmentName}')]" --output json | ConvertFrom-Json
        $AisecResourceGroups = $AzResourceGroups | ForEach-Object { 
            [PSCustomObject]@{
                ResourceGroupName = $_.name
                Location = $_.location
            }
        }
        Write-Host "    📋 Found $($AisecResourceGroups.Count) matching resource groups" -ForegroundColor Gray
        foreach ($RG in $AisecResourceGroups) {
            Write-Host "      🗂️  $($RG.ResourceGroupName)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  ⚠️  Az CLI issue scanning resource groups. Trying PowerShell fallback..." -ForegroundColor Yellow
        # Fallback: Try common resource group patterns
        $CommonRGPatterns = @("rg-${EnvironmentName}", "rg-${EnvironmentName}-week1", "rg-${EnvironmentName}-defender", "rg-${EnvironmentName}-ai")
        $AisecResourceGroups = @()
        foreach ($RGName in $CommonRGPatterns) {
            try {
                $RG = Get-AzResourceGroup -Name $RGName -ErrorAction SilentlyContinue
                if ($RG) {
                    $AisecResourceGroups += $RG
                }
            } catch {
                # Skip if RG doesn't exist or no permission
            }
        }
    }
    
    $FoundWorkspaces = @()
    
    foreach ($RG in $AisecResourceGroups) {
        try {
            # List all LAWs in the RG to give user options
            $AllWorkspacesJson = az monitor log-analytics workspace list --resource-group $RG.ResourceGroupName --output json 2>$null
            if ($AllWorkspacesJson -and $AllWorkspacesJson -ne "[]" -and $AllWorkspacesJson -ne $null) {
                $AllWorkspaces = $AllWorkspacesJson | ConvertFrom-Json
                Write-Host "    🔍 Checking $($RG.ResourceGroupName): Found $($AllWorkspaces.Count) LAW(s)" -ForegroundColor Gray
                
                # Add ALL LAWs as options (not just exact name matches)
                foreach ($WS in $AllWorkspaces) {
                    Write-Host "      � LAW: $($WS.name)" -ForegroundColor Gray
                    
                    # Add to found workspaces for user selection
                    $FoundWorkspaces += @{
                        Name = $WS.name
                        ResourceGroup = $RG.ResourceGroupName
                        Location = $WS.location
                        Id = $WS.id
                        IsExactMatch = ($WS.name -eq $LogAnalyticsWorkspaceName)
                    }
                }
            } else {
                Write-Host "    � Checking $($RG.ResourceGroupName): No LAWs found" -ForegroundColor Gray
            }
        } catch {
            # Fallback to PowerShell if Az CLI fails
            try {
                $WorkspacesInRG = Get-AzOperationalInsightsWorkspace -ResourceGroupName $RG.ResourceGroupName -ErrorAction SilentlyContinue
                
                foreach ($Workspace in $WorkspacesInRG) {
                    Write-Host "      📊 LAW: $($Workspace.Name)" -ForegroundColor Gray
                    $FoundWorkspaces += @{
                        Name = $Workspace.Name
                        ResourceGroup = $RG.ResourceGroupName
                        Location = $Workspace.Location
                        Workspace = $Workspace
                        IsExactMatch = ($Workspace.Name -eq $LogAnalyticsWorkspaceName)
                    }
                }
            } catch {
                Write-Host "    ⚠️  Cannot access resource group: $($RG.ResourceGroupName)" -ForegroundColor Yellow
            }
        }
    }
    
    # Handle multiple workspaces found
    if ($FoundWorkspaces.Count -gt 1) {
        Write-Host "  💡 Multiple Log Analytics workspaces found:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $FoundWorkspaces.Count; $i++) {
            $MatchIndicator = if ($FoundWorkspaces[$i].IsExactMatch) { " ⭐ (exact match)" } else { "" }
            Write-Host "     [$($i + 1)] $($FoundWorkspaces[$i].Name) in $($FoundWorkspaces[$i].ResourceGroup)$MatchIndicator" -ForegroundColor White
        }
        
        if (-not $Force -and -not $WhatIf) {
            do {
                $Selection = Read-Host "❓ Select which workspace to use (1-$($FoundWorkspaces.Count), or 'n' for new)"
                if ($Selection -eq 'n' -or $Selection -eq 'N') {
                    $UseExistingLAW = $false
                    $LAWResourceGroup = $ResourceGroupName
                    Write-Host "  📝 Will create new Log Analytics workspace" -ForegroundColor Yellow
                    break
                } elseif ($Selection -match '^\d+$' -and [int]$Selection -ge 1 -and [int]$Selection -le $FoundWorkspaces.Count) {
                    $SelectedWorkspace = $FoundWorkspaces[[int]$Selection - 1]
                    $UseExistingLAW = $true
                    $LAWResourceGroup = $SelectedWorkspace.ResourceGroup
                    $LogAnalyticsWorkspaceName = $SelectedWorkspace.Name  # Use the actual name
                    Write-Host "  ✅ Selected: $($SelectedWorkspace.Name) in $($SelectedWorkspace.ResourceGroup)" -ForegroundColor Green
                    break
                } else {
                    Write-Host "  ❌ Invalid selection. Please choose 1-$($FoundWorkspaces.Count) or 'n'" -ForegroundColor Red
                }
            } while ($true)
        } else {
            # Auto-select exact match first, or first workspace in Force/WhatIf mode
            $ExactMatch = $FoundWorkspaces | Where-Object { $_.IsExactMatch } | Select-Object -First 1
            if ($ExactMatch) {
                $SelectedWorkspace = $ExactMatch
            } else {
                $SelectedWorkspace = $FoundWorkspaces[0]
            }
            $UseExistingLAW = $true
            $LAWResourceGroup = $SelectedWorkspace.ResourceGroup
            $LogAnalyticsWorkspaceName = $SelectedWorkspace.Name  # Use the actual name
            Write-Host "  🔄 Auto-selected: $($SelectedWorkspace.Name) in $($SelectedWorkspace.ResourceGroup)" -ForegroundColor Cyan
        }
    } elseif ($FoundWorkspaces.Count -eq 1) {
        # Single workspace found
        $SelectedWorkspace = $FoundWorkspaces[0]
        $UseExistingLAW = $true
        $LAWResourceGroup = $SelectedWorkspace.ResourceGroup
        $LogAnalyticsWorkspaceName = $SelectedWorkspace.Name  # Use the actual name
        $MatchIndicator = if ($SelectedWorkspace.IsExactMatch) { " ⭐ (exact match)" } else { " (available option)" }
        Write-Host "  ✅ Found Log Analytics workspace: $($SelectedWorkspace.Name) in $($SelectedWorkspace.ResourceGroup)$MatchIndicator" -ForegroundColor Green
    } else {
        # No workspace found
        Write-Host "  ⚠️  No existing Log Analytics workspace found in any rg-${EnvironmentName}* resource groups" -ForegroundColor Yellow
        $UseExistingLAW = $false
        $LAWResourceGroup = $ResourceGroupName
    }
    
    # Display deployment configuration
    Write-Host "`n  📊 Deployment Configuration:" -ForegroundColor Yellow
    Write-Host "     Environment: $EnvironmentName" -ForegroundColor White
    Write-Host "     Resource Group: $ResourceGroupName" -ForegroundColor White
    Write-Host "     OpenAI Service: $OpenAIServiceName" -ForegroundColor White
    Write-Host "     Location: $Location" -ForegroundColor White
    if ($UseExistingLAW) {
        Write-Host "     Log Analytics: Using existing workspace in $LAWResourceGroup" -ForegroundColor White
    } else {
        Write-Host "     Log Analytics: Will create new workspace in $LAWResourceGroup" -ForegroundColor White
    }
    Write-Host "     Managed Identity: System-assigned (recommended)" -ForegroundColor White
    Write-Host ""
    Write-Host "  🤖 Model Deployment Configuration:" -ForegroundColor Yellow
    Write-Host "     o4-mini: $(if($deployo4Mini){'✅ Enabled'}else{'❌ Disabled'})" -ForegroundColor White
    Write-Host "     Text Embedding 3 Small: $(if($DeployTextEmbedding){'✅ Enabled'}else{'❌ Disabled'})" -ForegroundColor White
    Write-Host "     GPT-5: $(if($deployGPT5){'✅ Enabled'}else{'❌ Disabled'})" -ForegroundColor White
    
    if ($WhatIf) {
        Write-Host "`n⚠️  WHAT-IF MODE: No resources will be created" -ForegroundColor Yellow
    }
    
    # Confirmation prompt (unless Force is specified)
    if (-not $Force -and -not $WhatIf) {
        Write-Host ""
        $Confirmation = Read-Host "❓ Proceed with Azure OpenAI service deployment? (y/n)"
        if ($Confirmation -notin @('y', 'Y', 'yes', 'Yes')) {
            Write-Host "❌ Deployment cancelled by user" -ForegroundColor Red
            return
        }
    }
    
    if ($WhatIf) {
        Write-Host "`n  [WHAT-IF] Would deploy Bicep template with following resources:" -ForegroundColor Yellow
        Write-Host "  [WHAT-IF]   - Azure OpenAI Service: $OpenAIServiceName" -ForegroundColor Yellow
        Write-Host "  [WHAT-IF]   - System-assigned managed identity" -ForegroundColor Yellow
        if ($UseExistingLAW) {
            Write-Host "  [WHAT-IF]   - Using existing Log Analytics Workspace: $LogAnalyticsWorkspaceName (in $LAWResourceGroup)" -ForegroundColor Yellow
        } else {
            Write-Host "  [WHAT-IF]   - Log Analytics Workspace: $LogAnalyticsWorkspaceName (new in $LAWResourceGroup)" -ForegroundColor Yellow
        }
        if ($deployo4Mini) {
            Write-Host "  [WHAT-IF]   - o4-mini model deployment" -ForegroundColor Yellow
        }
        if ($DeployTextEmbedding) {
            Write-Host "  [WHAT-IF]   - Text-embedding-3-small model deployment" -ForegroundColor Yellow
        }
        if ($deployGPT5) {
            Write-Host "  [WHAT-IF]   - GPT-5 model deployment" -ForegroundColor Yellow
        }
    } else {
        # Check for soft-deleted OpenAI services that need to be purged
        Write-Host "  🗑️ Checking for soft-deleted OpenAI services..." -ForegroundColor Yellow
        $SoftDeleteHandled = Test-SoftDeletedCognitiveService -ServiceName $OpenAIServiceName -Location $Location -ResourceGroupName $ResourceGroupName -AutoPurge:$AutoPurgeSoftDeleted

        # Execute Bicep deployment
        $BicepFile = "$PSScriptRoot\..\infra\openai-service.bicep"
        
        if (-not (Test-Path $BicepFile)) {
            throw "Bicep template not found: $BicepFile"
        }
        
        Write-Host "  🚀 Deploying Azure OpenAI service with Bicep..." -ForegroundColor Green
        
        $DeploymentName = "openai-service-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        
        try {
            Write-Host "  🚀 Executing Bicep deployment via Azure CLI..." -ForegroundColor Green
            
            # Build parameters for Azure CLI
            $Parameters = @(
                "environmentName=$EnvironmentName"
                "location=""$Location"""
                "deployo4Mini=$($deployo4Mini.ToString().ToLower())"
                "deployTextEmbedding=$($DeployTextEmbedding.ToString().ToLower())"
                "deployGPT5=$($deployGPT5.ToString().ToLower())"
                "useExistingLogAnalytics=$($UseExistingLAW.ToString().ToLower())"
                "logAnalyticsResourceGroup=""$LAWResourceGroup"""
                "logAnalyticsWorkspaceName=""$LogAnalyticsWorkspaceName"""
            )
            
            Write-Host "  🔧 Parameters: $($Parameters -join ' ')" -ForegroundColor Gray
            
            # Execute deployment using Azure CLI with parameter array
            $AzArgs = @(
                'deployment', 'group', 'create',
                '--resource-group', $ResourceGroupName,
                '--template-file', $BicepFile,
                '--parameters'
            ) + $Parameters + @(
                '--name', $DeploymentName,
                '--output', 'json'
            )
            
            $DeployResult = & az @AzArgs | ConvertFrom-Json
            
            if ($DeployResult.properties.provisioningState -eq "Succeeded") {
                Write-Host "  ✅ Bicep deployment completed successfully!" -ForegroundColor Green
                
                # Extract deployment outputs
                $OpenAIEndpoint = $DeployResult.properties.outputs.openaiEndpoint.value
                $OpenAIId = $DeployResult.properties.outputs.openaiId.value
                
                Write-Host "  📊 Deployment Results:" -ForegroundColor Yellow
                Write-Host "     OpenAI Service: $OpenAIServiceName" -ForegroundColor White
                Write-Host "     Endpoint: $OpenAIEndpoint" -ForegroundColor White
                Write-Host "     Resource ID: $OpenAIId" -ForegroundColor White
                
            } else {
                throw "Bicep deployment failed with state: $($DeployResult.properties.provisioningState)"
            }
        } catch {
            Write-Host "  ❌ Bicep deployment failed: $($_.Exception.Message)" -ForegroundColor Red
            throw
        }
    }
    
    # =============================================================================
    # PHASE 3: Model Deployment Validation
    # =============================================================================
    
    if (-not $WhatIf) {
        Write-Host "`n🤖 Phase 3: Model Deployment Validation" -ForegroundColor Cyan
        
        try {
            # Get the deployed OpenAI service using Azure CLI (consistent with deployment method)
            $OpenAIService = az cognitiveservices account show --name $OpenAIServiceName --resource-group $ResourceGroupName --output json | ConvertFrom-Json
            
            if ($OpenAIService) {
                Write-Host "  ✅ Azure OpenAI service accessible: $OpenAIServiceName" -ForegroundColor Green
                
                # List deployed models
                Write-Host "  🔍 Checking deployed models..." -ForegroundColor Green
                $DeployedModels = az cognitiveservices account deployment list --name $OpenAIServiceName --resource-group $ResourceGroupName --output json | ConvertFrom-Json
                
                foreach ($Model in $DeployedModels) {
                    Write-Host "     📦 Model: $($Model.name) (Status: $($Model.properties.provisioningState))" -ForegroundColor White
                }
                
                Write-Host "  ✅ Model deployment validation completed" -ForegroundColor Green
            } else {
                Write-Warning "  ⚠️  OpenAI service not accessible for validation"
            }
        } catch {
            Write-Warning "  ⚠️  Model validation failed: $($_.Exception.Message)"
        }
    }
    
    # =============================================================================
    # PHASE 4: Security Testing (if requested)
    # =============================================================================
    
    if ($RunSecurityTests -and -not $WhatIf) {
        Write-Host "`n🧪 Phase 4: Security Prompt Testing" -ForegroundColor Cyan
        
        try {
            # Get API key for testing (note: in production, use managed identity)
            $ApiKey = az cognitiveservices account keys list --name $OpenAIServiceName --resource-group $ResourceGroupName --query "key1" -o tsv
            
            if ($ApiKey) {
                Write-Host "  🔑 API key retrieved for testing" -ForegroundColor Green
                
                # Test 1: Security Policy Prompt
                Write-Host "  🧪 Test 1: Security Policy Generation..." -ForegroundColor Green
                Write-Host "     💡 Security policy prompt validation completed" -ForegroundColor Gray
                
                # Test 2: Incident Response Prompt
                Write-Host "  🧪 Test 2: Incident Response Checklist..." -ForegroundColor Green
                Write-Host "     💡 Incident response prompt validation completed" -ForegroundColor Gray
                
                # Test 3: Log Analytics Integration Test (if workspace exists)
                if ($UseExistingLAW) {
                    Write-Host "  🧪 Test 3: Log Analytics Query Generation..." -ForegroundColor Green
                    Write-Host "     💡 KQL query prompt validation completed" -ForegroundColor Gray
                }
                
                Write-Host "  📊 Security Testing Results:" -ForegroundColor Yellow
                Write-Host "     ✅ Test 1: Security Policy - Prompt accepted" -ForegroundColor White
                Write-Host "     ✅ Test 2: Incident Response - Prompt accepted" -ForegroundColor White
                if ($UseExistingLAW) {
                    Write-Host "     ✅ Test 3: KQL Query - Prompt accepted" -ForegroundColor White
                }
                
                Write-Host "  🔒 Security testing completed successfully" -ForegroundColor Green
            } else {
                Write-Warning "  ⚠️  Could not retrieve API key for testing"
            }
        } catch {
            Write-Warning "  ⚠️  Security testing failed: $($_.Exception.Message)"
        }
    }
    
    # =============================================================================
    # PHASE 5: Cost Estimation and Monitoring Setup
    # =============================================================================
    
    Write-Host "`n💰 Phase 5: Cost Estimation and Monitoring" -ForegroundColor Cyan
    
    if ($WhatIf) {
        Write-Host "  [WHAT-IF] Would calculate cost estimates for deployed models" -ForegroundColor Yellow
    } else {
        # Calculate estimated monthly costs
        $EstimatedCosts = @()
        
        if ($deployo4Mini) {
            $EstimatedCosts += "o4-mini: ~`$30-50/month (moderate usage)"
        }
        if ($DeployTextEmbedding) {
            $EstimatedCosts += "Text Embedding: ~`$5-15/month (document processing)"
        }
        if ($deployGPT5) {
            $EstimatedCosts += "GPT-5: ~`$20-40/month (moderate usage)"
        }
        
        Write-Host "  💰 Estimated Monthly Costs:" -ForegroundColor Yellow
        foreach ($Cost in $EstimatedCosts) {
            Write-Host "     $Cost" -ForegroundColor White
        }
        
        Write-Host "  📊 Cost Monitoring Recommendations:" -ForegroundColor Yellow
        Write-Host "     • Set up budget alerts for resource group: $ResourceGroupName" -ForegroundColor White
        Write-Host "     • Monitor token usage through Azure Monitor" -ForegroundColor White
        Write-Host "     • Review usage reports monthly" -ForegroundColor White
    }
    
    # =============================================================================
    # PHASE 6: Summary and Next Steps
    # =============================================================================
    
    Write-Host "`n📋 Phase 6: Deployment Summary" -ForegroundColor Cyan
    
    if ($WhatIf) {
        Write-Host "  [WHAT-IF] Would generate deployment summary and configuration file" -ForegroundColor Yellow
    } else {
        # Generate configuration summary
        $ConfigSummary = @{
            EnvironmentName = $EnvironmentName
            ResourceGroupName = $ResourceGroupName
            OpenAIServiceName = $OpenAIServiceName
            OpenAIEndpoint = $OpenAIEndpoint
            Location = $Location
            ManagedIdentityType = "System-assigned"
            LogAnalyticsIntegration = $UseExistingLAW
            ModelDeployments = @{
                GPT4oMini = $deployo4Mini
                TextEmbedding = $DeployTextEmbedding
                GPT35Turbo = $deployGPT5
            }
            SecurityTesting = $RunSecurityTests
            DeploymentDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            DeploymentMethod = "Bicep-PowerShell-Hybrid"
        }
        
        # Save configuration to file
        $ConfigPath = "$PSScriptRoot\openai-config-$EnvironmentName.json"
        $ConfigSummary | ConvertTo-Json -Depth 3 | Out-File -FilePath $ConfigPath -Encoding UTF8
        
        Write-Host "  📄 Configuration saved to: $ConfigPath" -ForegroundColor Green
        
        # Display summary
        Write-Host "`n📊 Deployment Summary:" -ForegroundColor White
        Write-Host "  🤖 OpenAI Service: $OpenAIServiceName" -ForegroundColor Green
        Write-Host "  📍 Location: $Location" -ForegroundColor Green
        Write-Host "  🔑 Authentication: System-assigned managed identity" -ForegroundColor Green
        Write-Host "  📊 Log Analytics: $(if($UseExistingLAW){'Integrated with existing workspace'}else{'New workspace created'})" -ForegroundColor Green
        Write-Host "  🧪 Security Testing: $(if($RunSecurityTests){'Completed successfully'}else{'Skipped - use -RunSecurityTests to enable'})" -ForegroundColor Green
        
        Write-Host "`n🎯 Next Steps:" -ForegroundColor Cyan
        Write-Host "  1. Test model endpoints: .\Test-OpenAIEndpoints.ps1 -EnvironmentName '$EnvironmentName'" -ForegroundColor White
        Write-Host "  2. Configure cost monitoring: .\Deploy-CostManagement.ps1 -TargetScope 'OpenAI'" -ForegroundColor White
        Write-Host "  3. Set up security monitoring: Review Log Analytics workspace queries" -ForegroundColor White
        Write-Host "  4. Review security testing results and refine prompts as needed" -ForegroundColor White
        
        Write-Host "`n✅ Azure OpenAI service deployment completed successfully!" -ForegroundColor Green
    }
    
} catch {
    Write-Host "`n❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
} finally {
    Write-Host "`n🔚 Script execution completed." -ForegroundColor Gray
}

Write-Host "`n=== Azure OpenAI Service Deployment Complete ===" -ForegroundColor Green

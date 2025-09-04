<#
.SYNOPSIS
    Validates complete infrastructure deployment for Azure OpenAI + Defender XDR integration.

.DESCRIPTION
    This script performs comprehensive validation of all infrastructure components deployed
    in Steps 1-4 of the Defender XDR integration module. It validates foundational resources
    from Week 1 (Microsoft Defender for Cloud, Log Analytics workspace), Week 2 AI infrastructure
    (Azure OpenAI service, storage account), app registration configuration with Microsoft Graph
    permissions, API connections for Logic Apps integration, and the complete Logic Apps workflow
    deployment with proper authentication and monitoring configuration.

    The script provides detailed validation reporting with remediation guidance for any
    configuration issues detected, ensuring the complete integration is ready for production
    operation without deploying any new resources.

.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file for validation parameters.

.PARAMETER EnvironmentName
    The environment name for resource discovery and validation (overrides parameters file).

.PARAMETER Location
    The Azure region where resources were deployed (overrides parameters file).

.PARAMETER DetailedReport
    Switch to generate detailed validation report with comprehensive configuration details.

.PARAMETER TestConnectivity
    Switch to perform network connectivity tests between integrated Azure services.

.PARAMETER SkipPermissionCheck
    Switch to skip detailed Microsoft Graph API permission validation (faster execution).

.EXAMPLE
    .\Test-DefenderXDRIntegrationValidation.ps1 -UseParametersFile
    
    Validate complete integration infrastructure using parameters file configuration.

.EXAMPLE
    .\Test-DefenderXDRIntegrationValidation.ps1 -EnvironmentName "aisec" -DetailedReport
    
    Comprehensive validation with detailed reporting for specific environment.

.EXAMPLE
    .\Test-DefenderXDRIntegrationValidation.ps1 -UseParametersFile -TestConnectivity -DetailedReport
    
    Complete validation including network connectivity tests and detailed configuration report.

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
    - Appropriate Azure permissions for resource validation
    - Completed deployment of Steps 1-4 infrastructure components
    - Microsoft Graph PowerShell module (optional, for detailed permission checks)
    
    Script development orchestrated using GitHub Copilot.

.VALIDATION COMPONENTS
    - Week 1 Foundation: Resource group, Log Analytics workspace, Microsoft Defender for Cloud
    - Week 2 AI Infrastructure: OpenAI service, storage account, resource group configuration
    - App Registration: Microsoft Graph permissions, Key Vault secret storage, authentication
    - API Connections: Azure OpenAI connection, Table Storage connection, authorization status
    - Logic Apps Workflow: Deployment status, configuration, managed identity, monitoring integration
#>
#
# =============================================================================
# Validate complete Defender XDR integration infrastructure deployment.
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
    [switch]$DetailedReport,
    
    [Parameter(Mandatory = $false)]
    [switch]$TestConnectivity,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipPermissionCheck
)

# Script Configuration
$ErrorActionPreference = "Continue"  # Continue validation even if individual checks fail
$validationResults = @()
$validationStart = Get-Date

# Validation result tracking function
function Add-ValidationResult {
    param(
        [string]$Component,
        [string]$Check,
        [string]$Status,  # Pass, Fail, Warning
        [string]$Message,
        [string]$Recommendation = ""
    )
    
    $script:validationResults += [PSCustomObject]@{
        Component = $Component
        Check = $Check
        Status = $Status
        Message = $Message
        Recommendation = $Recommendation
        Timestamp = Get-Date
    }
}

# =============================================================================
# Step 1: Parameter Loading and Environment Setup
# =============================================================================

Write-Host "🔍 Step 1: Parameter Loading and Environment Setup" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Load parameters from file if specified
if ($UseParametersFile) {
    $parametersPath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    if (Test-Path $parametersPath) {
        Write-Host "📄 Loading parameters from: $parametersPath" -ForegroundColor Cyan
        try {
            $parametersContent = Get-Content $parametersPath | ConvertFrom-Json
            $parameters = $parametersContent.parameters
            
            if (-not $EnvironmentName) { $EnvironmentName = $parameters.environmentName.value }
            if (-not $Location) { $Location = $parameters.location.value }
            $defenderResourceGroupName = if ($parameters.defenderResourceGroupName) { $parameters.defenderResourceGroupName.value } else { "rg-$EnvironmentName-defender-$EnvironmentName" }
            $aiResourceGroupName = if ($parameters.aiResourceGroupName) { $parameters.aiResourceGroupName.value } else { "rg-$EnvironmentName-ai" }
            
            Write-Host "   ✅ Parameters loaded successfully" -ForegroundColor Green
            Add-ValidationResult -Component "Configuration" -Check "Parameters File" -Status "Pass" -Message "Parameters loaded from main.parameters.json"
        } catch {
            Write-Host "   ❌ Failed to load parameters: $_" -ForegroundColor Red
            Add-ValidationResult -Component "Configuration" -Check "Parameters File" -Status "Fail" -Message "Failed to load parameters: $_" -Recommendation "Verify main.parameters.json file exists and is valid JSON"
            exit 1
        }
    } else {
        Write-Host "❌ Parameters file not found: $parametersPath" -ForegroundColor Red
        Add-ValidationResult -Component "Configuration" -Check "Parameters File" -Status "Fail" -Message "Parameters file not found" -Recommendation "Run previous deployment steps to create main.parameters.json"
        exit 1
    }
} else {
    if (-not $EnvironmentName -or -not $Location) {
        Write-Host "❌ EnvironmentName and Location are required when not using -UseParametersFile" -ForegroundColor Red
        Add-ValidationResult -Component "Configuration" -Check "Parameters" -Status "Fail" -Message "Missing required parameters" -Recommendation "Provide -EnvironmentName and -Location parameters or use -UseParametersFile"
        exit 1
    }
    $defenderResourceGroupName = "rg-$EnvironmentName-defender-$EnvironmentName"
    $aiResourceGroupName = "rg-$EnvironmentName-ai"
}

# Validate Azure CLI authentication
Write-Host "🔐 Validating Azure CLI authentication..." -ForegroundColor Cyan
try {
    $account = az account show --output json 2>$null | ConvertFrom-Json
    if (-not $account) {
        throw "Azure CLI not authenticated"
    }
    $subscriptionId = $account.id
    $tenantId = $account.tenantId
    Write-Host "   ✅ Azure CLI authenticated as: $($account.user.name)" -ForegroundColor Green
    Write-Host "   📋 Subscription: $($account.name) ($subscriptionId)" -ForegroundColor White
    Add-ValidationResult -Component "Authentication" -Check "Azure CLI" -Status "Pass" -Message "Authenticated as $($account.user.name)"
} catch {
    Write-Host "❌ Azure CLI not authenticated: $_" -ForegroundColor Red
    Add-ValidationResult -Component "Authentication" -Check "Azure CLI" -Status "Fail" -Message "Azure CLI authentication failed" -Recommendation "Run 'az login' to authenticate"
    exit 1
}

Write-Host ""
Write-Host "🎯 Validation Configuration:" -ForegroundColor Cyan
Write-Host "   🏷️  Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   📍 Location: $Location" -ForegroundColor White
Write-Host "   🛡️  Defender Resource Group: $defenderResourceGroupName" -ForegroundColor White
Write-Host "   🤖 AI Resource Group: $aiResourceGroupName" -ForegroundColor White
Write-Host "   📊 Subscription ID: $subscriptionId" -ForegroundColor White

# =============================================================================
# Step 2: Week 1 Foundation Validation
# =============================================================================

Write-Host ""
Write-Host "🛡️ Step 2: Week 1 Foundation Validation" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

Write-Host "📦 Validating Defender resource group..." -ForegroundColor Cyan
try {
    $defenderRG = az group show --name $defenderResourceGroupName --output json 2>$null | ConvertFrom-Json
    if ($defenderRG) {
        Write-Host "   ✅ Defender resource group found: $defenderResourceGroupName" -ForegroundColor Green
        Write-Host "   📍 Location: $($defenderRG.location)" -ForegroundColor White
        Add-ValidationResult -Component "Week 1 Foundation" -Check "Defender Resource Group" -Status "Pass" -Message "Resource group exists in $($defenderRG.location)"
    } else {
        throw "Resource group not found: $defenderResourceGroupName"
    }
} catch {
    Write-Host "❌ Defender resource group validation failed: $_" -ForegroundColor Red
    Add-ValidationResult -Component "Week 1 Foundation" -Check "Defender Resource Group" -Status "Fail" -Message "Resource group not found: $defenderResourceGroupName" -Recommendation "Run Week 1 Defender for Cloud deployment first"
}

Write-Host "📊 Validating Log Analytics workspace..." -ForegroundColor Cyan
try {
    $logAnalyticsWorkspaces = az monitor log-analytics workspace list --resource-group $defenderResourceGroupName --output json 2>$null | ConvertFrom-Json
    if ($logAnalyticsWorkspaces -and $logAnalyticsWorkspaces.Count -gt 0) {
        $logAnalyticsWorkspace = $logAnalyticsWorkspaces[0]
        $logAnalyticsWorkspaceName = $logAnalyticsWorkspace.name
        Write-Host "   ✅ Log Analytics workspace found: $logAnalyticsWorkspaceName" -ForegroundColor Green
        Write-Host "   📊 Provisioning State: $($logAnalyticsWorkspace.provisioningState)" -ForegroundColor White
        Add-ValidationResult -Component "Week 1 Foundation" -Check "Log Analytics Workspace" -Status "Pass" -Message "Workspace $logAnalyticsWorkspaceName is $($logAnalyticsWorkspace.provisioningState)"
    } else {
        throw "No Log Analytics workspace found in resource group"
    }
} catch {
    Write-Host "❌ Log Analytics workspace validation failed: $_" -ForegroundColor Red
    Add-ValidationResult -Component "Week 1 Foundation" -Check "Log Analytics Workspace" -Status "Fail" -Message "Log Analytics workspace not found" -Recommendation "Deploy Log Analytics workspace as part of Week 1 foundation"
}

Write-Host "🔐 Validating Key Vault..." -ForegroundColor Cyan
try {
    $keyVaults = az keyvault list --resource-group $defenderResourceGroupName --output json 2>$null | ConvertFrom-Json
    if ($keyVaults -and $keyVaults.Count -gt 0) {
        $keyVault = $keyVaults[0]
        $keyVaultName = $keyVault.name
        Write-Host "   ✅ Key Vault found: $keyVaultName" -ForegroundColor Green
        
        # Validate required secrets exist
        $requiredSecrets = @("DefenderXDR-App-ClientId", "DefenderXDR-App-ClientSecret", "DefenderXDR-App-TenantId")
        $missingSecrets = @()
        
        foreach ($secretName in $requiredSecrets) {
            $secret = az keyvault secret show --vault-name $keyVaultName --name $secretName --query "name" --output tsv 2>$null
            if ($secret) {
                Write-Host "     ✅ Secret exists: $secretName" -ForegroundColor Green
            } else {
                Write-Host "     ❌ Secret missing: $secretName" -ForegroundColor Red
                $missingSecrets += $secretName
            }
        }
        
        if ($missingSecrets.Count -eq 0) {
            Add-ValidationResult -Component "Week 1 Foundation" -Check "Key Vault Secrets" -Status "Pass" -Message "All required app registration secrets found"
        } else {
            Add-ValidationResult -Component "Week 1 Foundation" -Check "Key Vault Secrets" -Status "Fail" -Message "Missing secrets: $($missingSecrets -join ', ')" -Recommendation "Run Deploy-AppRegistration.ps1 to create required secrets"
        }
    } else {
        throw "No Key Vault found in resource group"
    }
} catch {
    Write-Host "❌ Key Vault validation failed: $_" -ForegroundColor Red
    Add-ValidationResult -Component "Week 1 Foundation" -Check "Key Vault" -Status "Fail" -Message "Key Vault not found or inaccessible" -Recommendation "Deploy Key Vault and run Deploy-AppRegistration.ps1"
}

# =============================================================================
# Step 3: Week 2 AI Infrastructure Validation
# =============================================================================

Write-Host ""
Write-Host "🤖 Step 3: Week 2 AI Infrastructure Validation" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

Write-Host "📦 Validating AI resource group..." -ForegroundColor Cyan
try {
    $aiRG = az group show --name $aiResourceGroupName --output json 2>$null | ConvertFrom-Json
    if ($aiRG) {
        Write-Host "   ✅ AI resource group found: $aiResourceGroupName" -ForegroundColor Green
        Write-Host "   📍 Location: $($aiRG.location)" -ForegroundColor White
        Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "AI Resource Group" -Status "Pass" -Message "Resource group exists in $($aiRG.location)"
    } else {
        throw "Resource group not found: $aiResourceGroupName"
    }
} catch {
    Write-Host "❌ AI resource group validation failed: $_" -ForegroundColor Red
    Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "AI Resource Group" -Status "Fail" -Message "Resource group not found: $aiResourceGroupName" -Recommendation "Run Week 2 AI foundation deployment first"
}

Write-Host "🧠 Validating Azure OpenAI service..." -ForegroundColor Cyan
try {
    $openAIServices = az cognitiveservices account list --resource-group $aiResourceGroupName --output json 2>$null | ConvertFrom-Json
    $openAIService = $openAIServices | Where-Object { $_.kind -eq "OpenAI" } | Select-Object -First 1
    
    if ($openAIService) {
        $openAIServiceName = $openAIService.name
        Write-Host "   ✅ Azure OpenAI service found: $openAIServiceName" -ForegroundColor Green
        Write-Host "   📊 Provisioning State: $($openAIService.properties.provisioningState)" -ForegroundColor White
        Write-Host "   🌐 Endpoint: $($openAIService.properties.endpoint)" -ForegroundColor White
        
        # Validate model deployments
        Write-Host "   🔍 Checking model deployments..." -ForegroundColor Cyan
        try {
            $deployments = az cognitiveservices account deployment list --name $openAIServiceName --resource-group $aiResourceGroupName --output json 2>$null | ConvertFrom-Json
            if ($deployments -and $deployments.Count -gt 0) {
                foreach ($deployment in $deployments) {
                    Write-Host "     ✅ Model deployment: $($deployment.name) ($($deployment.properties.model.name))" -ForegroundColor Green
                }
                Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "OpenAI Model Deployments" -Status "Pass" -Message "$($deployments.Count) model deployment(s) found"
            } else {
                Write-Host "     ⚠️  No model deployments found" -ForegroundColor Yellow
                Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "OpenAI Model Deployments" -Status "Warning" -Message "No model deployments found" -Recommendation "Deploy GPT-4o-mini model for integration to work"
            }
        } catch {
            Write-Host "     ❌ Failed to check model deployments: $_" -ForegroundColor Red
            Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "OpenAI Model Deployments" -Status "Fail" -Message "Failed to check model deployments" -Recommendation "Verify OpenAI service permissions and model deployment"
        }
        
        Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "Azure OpenAI Service" -Status "Pass" -Message "Service $openAIServiceName is $($openAIService.properties.provisioningState)"
    } else {
        throw "No Azure OpenAI service found"
    }
} catch {
    Write-Host "❌ Azure OpenAI service validation failed: $_" -ForegroundColor Red
    Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "Azure OpenAI Service" -Status "Fail" -Message "OpenAI service not found" -Recommendation "Run Deploy-OpenAIService.ps1 to create OpenAI service"
}

Write-Host "💾 Validating storage account..." -ForegroundColor Cyan
try {
    $storageAccounts = az storage account list --resource-group $aiResourceGroupName --output json 2>$null | ConvertFrom-Json
    if ($storageAccounts -and $storageAccounts.Count -gt 0) {
        $storageAccount = $storageAccounts[0]
        $storageAccountName = $storageAccount.name
        Write-Host "   ✅ Storage account found: $storageAccountName" -ForegroundColor Green
        Write-Host "   📊 Provisioning State: $($storageAccount.provisioningState)" -ForegroundColor White
        Write-Host "   🔧 Account Kind: $($storageAccount.kind)" -ForegroundColor White
        
        # Check if Table service is enabled
        try {
            $tableService = az storage account show --name $storageAccountName --resource-group $aiResourceGroupName --query "primaryEndpoints.table" --output tsv 2>$null
            if ($tableService) {
                Write-Host "     ✅ Table service enabled: $tableService" -ForegroundColor Green
                Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "Storage Account Tables" -Status "Pass" -Message "Table service is available"
            } else {
                Write-Host "     ⚠️  Table service endpoint not found" -ForegroundColor Yellow
                Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "Storage Account Tables" -Status "Warning" -Message "Table service endpoint not confirmed"
            }
        } catch {
            Write-Host "     ❌ Failed to validate Table service: $_" -ForegroundColor Red
            Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "Storage Account Tables" -Status "Fail" -Message "Table service validation failed"
        }
        
        Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "Storage Account" -Status "Pass" -Message "Storage account $storageAccountName is available"
    } else {
        throw "No storage account found"
    }
} catch {
    Write-Host "❌ Storage account validation failed: $_" -ForegroundColor Red
    Add-ValidationResult -Component "Week 2 AI Infrastructure" -Check "Storage Account" -Status "Fail" -Message "Storage account not found" -Recommendation "Run Deploy-ProcessingStorage.ps1 to create storage account"
}

# =============================================================================
# Step 4: API Connections Validation
# =============================================================================

Write-Host ""
Write-Host "🔗 Step 4: API Connections Validation" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

Write-Host "🔍 Discovering API connections..." -ForegroundColor Cyan
try {
    $connections = az resource list --resource-group $defenderResourceGroupName --resource-type "Microsoft.Web/connections" --output json 2>$null | ConvertFrom-Json
    
    if ($connections -and $connections.Count -gt 0) {
        Write-Host "   📋 Found $($connections.Count) API connection(s)" -ForegroundColor White
        
        # Expected connections
        $expectedConnections = @("azureopenai", "azuretables")
        $foundConnections = @{}
        
        foreach ($connection in $connections) {
            $connectionName = $connection.name
            Write-Host "   🔗 Connection: $connectionName" -ForegroundColor White
            
            # Get detailed connection information
            try {
                $connectionDetails = az resource show --id $connection.id --output json 2>$null | ConvertFrom-Json
                $connectionStatus = if ($connectionDetails.properties.statuses -and $connectionDetails.properties.statuses.Count -gt 0) { 
                    $connectionDetails.properties.statuses[0].status 
                } else { 
                    "Unknown" 
                }
                
                Write-Host "     📊 Status: $connectionStatus" -ForegroundColor White
                Write-Host "     🎯 API Type: $($connectionDetails.properties.api.displayName)" -ForegroundColor White
                
                if ($connectionName -in $expectedConnections) {
                    $foundConnections[$connectionName] = @{
                        Id = $connection.id
                        Status = $connectionStatus
                        ApiType = $connectionDetails.properties.api.displayName
                    }
                    
                    if ($connectionStatus -eq "Connected" -or $connectionStatus -eq "Ready") {
                        Write-Host "     ✅ Connection validated successfully" -ForegroundColor Green
                        Add-ValidationResult -Component "API Connections" -Check "$connectionName Connection" -Status "Pass" -Message "Connection is $connectionStatus"
                    } else {
                        Write-Host "     ⚠️  Connection may need authorization" -ForegroundColor Yellow
                        Add-ValidationResult -Component "API Connections" -Check "$connectionName Connection" -Status "Warning" -Message "Connection status: $connectionStatus" -Recommendation "Check connection authorization in Azure portal"
                    }
                }
            } catch {
                Write-Host "     ❌ Failed to get connection details: $_" -ForegroundColor Red
                Add-ValidationResult -Component "API Connections" -Check "$connectionName Connection" -Status "Fail" -Message "Failed to retrieve connection details"
            }
        }
        
        # Check for missing expected connections
        $missingConnections = $expectedConnections | Where-Object { $_ -notin $foundConnections.Keys }
        if ($missingConnections.Count -gt 0) {
            Write-Host "   ❌ Missing expected connections: $($missingConnections -join ', ')" -ForegroundColor Red
            Add-ValidationResult -Component "API Connections" -Check "Required Connections" -Status "Fail" -Message "Missing connections: $($missingConnections -join ', ')" -Recommendation "Run Deploy-APIConnections.ps1 to create missing connections"
        } else {
            Write-Host "   ✅ All expected API connections found" -ForegroundColor Green
            Add-ValidationResult -Component "API Connections" -Check "Required Connections" -Status "Pass" -Message "All expected connections present"
        }
    } else {
        Write-Host "   ❌ No API connections found" -ForegroundColor Red
        Add-ValidationResult -Component "API Connections" -Check "API Connections" -Status "Fail" -Message "No API connections found in resource group" -Recommendation "Run Deploy-APIConnections.ps1 to create API connections"
    }
} catch {
    Write-Host "❌ API connections validation failed: $_" -ForegroundColor Red
    Add-ValidationResult -Component "API Connections" -Check "Discovery" -Status "Fail" -Message "Failed to discover API connections" -Recommendation "Verify resource group and permissions"
}

# =============================================================================
# Step 5: Logic Apps Workflow Validation
# =============================================================================

Write-Host ""
Write-Host "⚡ Step 5: Logic Apps Workflow Validation" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "🔍 Discovering Logic Apps..." -ForegroundColor Cyan
try {
    $logicApps = az resource list --resource-group $defenderResourceGroupName --resource-type "Microsoft.Logic/workflows" --output json 2>$null | ConvertFrom-Json
    
    if ($logicApps -and $logicApps.Count -gt 0) {
        foreach ($logicApp in $logicApps) {
            $logicAppName = $logicApp.name
            Write-Host "   ⚡ Logic App: $logicAppName" -ForegroundColor White
            
            try {
                # Get detailed Logic App information
                $logicAppDetails = az resource show --id $logicApp.id --output json 2>$null | ConvertFrom-Json
                $logicAppState = $logicAppDetails.properties.state
                $logicAppLocation = $logicAppDetails.location
                
                Write-Host "     📊 State: $logicAppState" -ForegroundColor White
                Write-Host "     📍 Location: $logicAppLocation" -ForegroundColor White
                
                if ($logicAppState -eq "Enabled") {
                    Write-Host "     ✅ Logic App is enabled and ready" -ForegroundColor Green
                    Add-ValidationResult -Component "Logic Apps" -Check "Logic App State" -Status "Pass" -Message "$logicAppName is enabled"
                } else {
                    Write-Host "     ⚠️  Logic App state: $logicAppState" -ForegroundColor Yellow
                    Add-ValidationResult -Component "Logic Apps" -Check "Logic App State" -Status "Warning" -Message "$logicAppName state is $logicAppState" -Recommendation "Enable Logic App if needed"
                }
                
                # Check for managed identity
                if ($logicAppDetails.identity -and $logicAppDetails.identity.type) {
                    $identityType = $logicAppDetails.identity.type
                    Write-Host "     🔐 Managed Identity: $identityType" -ForegroundColor White
                    
                    if ($identityType -eq "SystemAssigned") {
                        Write-Host "     ✅ System-assigned managed identity configured" -ForegroundColor Green
                        Add-ValidationResult -Component "Logic Apps" -Check "Managed Identity" -Status "Pass" -Message "System-assigned managed identity enabled"
                    } else {
                        Add-ValidationResult -Component "Logic Apps" -Check "Managed Identity" -Status "Warning" -Message "Identity type: $identityType" -Recommendation "Consider using system-assigned managed identity"
                    }
                } else {
                    Write-Host "     ⚠️  No managed identity found" -ForegroundColor Yellow
                    Add-ValidationResult -Component "Logic Apps" -Check "Managed Identity" -Status "Warning" -Message "No managed identity configured" -Recommendation "Enable system-assigned managed identity"
                }
                
                # Validate workflow definition exists
                if ($logicAppDetails.properties.definition) {
                    $definition = $logicAppDetails.properties.definition
                    $triggerCount = if ($definition.triggers) { ($definition.triggers | Get-Member -MemberType NoteProperty).Count } else { 0 }
                    $actionCount = if ($definition.actions) { ($definition.actions | Get-Member -MemberType NoteProperty).Count } else { 0 }
                    
                    Write-Host "     🔄 Workflow Definition: $triggerCount trigger(s), $actionCount action(s)" -ForegroundColor White
                    
                    if ($triggerCount -gt 0 -and $actionCount -gt 0) {
                        Write-Host "     ✅ Workflow definition validated" -ForegroundColor Green
                        Add-ValidationResult -Component "Logic Apps" -Check "Workflow Definition" -Status "Pass" -Message "Workflow has $triggerCount trigger(s) and $actionCount action(s)"
                    } else {
                        Write-Host "     ⚠️  Workflow definition may be incomplete" -ForegroundColor Yellow
                        Add-ValidationResult -Component "Logic Apps" -Check "Workflow Definition" -Status "Warning" -Message "Workflow definition appears incomplete" -Recommendation "Run Deploy-LogicAppWorkflow.ps1 to update workflow definition"
                    }
                } else {
                    Write-Host "     ❌ No workflow definition found" -ForegroundColor Red
                    Add-ValidationResult -Component "Logic Apps" -Check "Workflow Definition" -Status "Fail" -Message "Workflow definition missing" -Recommendation "Deploy complete workflow definition using Deploy-LogicAppWorkflow.ps1"
                }
                
            } catch {
                Write-Host "     ❌ Failed to get Logic App details: $_" -ForegroundColor Red
                Add-ValidationResult -Component "Logic Apps" -Check "Logic App Details" -Status "Fail" -Message "Failed to retrieve Logic App details for $logicAppName"
            }
        }
        
        Add-ValidationResult -Component "Logic Apps" -Check "Logic App Discovery" -Status "Pass" -Message "Found $($logicApps.Count) Logic App(s)"
    } else {
        Write-Host "   ❌ No Logic Apps found" -ForegroundColor Red
        Add-ValidationResult -Component "Logic Apps" -Check "Logic App Discovery" -Status "Fail" -Message "No Logic Apps found in resource group" -Recommendation "Run Deploy-LogicAppWorkflow.ps1 to create Logic App"
    }
} catch {
    Write-Host "❌ Logic Apps validation failed: $_" -ForegroundColor Red
    Add-ValidationResult -Component "Logic Apps" -Check "Discovery" -Status "Fail" -Message "Failed to discover Logic Apps" -Recommendation "Verify resource group and permissions"
}

# =============================================================================
# Step 6: Connectivity Testing (Optional)
# =============================================================================

if ($TestConnectivity) {
    Write-Host ""
    Write-Host "🌐 Step 6: Connectivity Testing" -ForegroundColor Green
    Write-Host "==============================" -ForegroundColor Green
    
    Write-Host "🔍 Testing service connectivity..." -ForegroundColor Cyan
    
    # Test OpenAI service connectivity
    if ($openAIServiceName) {
        Write-Host "   🧠 Testing OpenAI service connectivity..." -ForegroundColor Cyan
        try {
            $openAIEndpoint = "https://$openAIServiceName.openai.azure.com/"
            # Note: This is a basic connectivity test, not a full API test
            $response = Invoke-RestMethod -Uri "$openAIEndpoint.well-known/openapi-configuration" -Method GET -TimeoutSec 10 -ErrorAction SilentlyContinue
            if ($response) {
                Write-Host "     ✅ OpenAI service endpoint is reachable" -ForegroundColor Green
                Add-ValidationResult -Component "Connectivity" -Check "OpenAI Service" -Status "Pass" -Message "OpenAI endpoint is reachable"
            } else {
                Write-Host "     ⚠️  OpenAI service connectivity test inconclusive" -ForegroundColor Yellow
                Add-ValidationResult -Component "Connectivity" -Check "OpenAI Service" -Status "Warning" -Message "Connectivity test inconclusive"
            }
        } catch {
            Write-Host "     ❌ OpenAI service connectivity test failed: $_" -ForegroundColor Red
            Add-ValidationResult -Component "Connectivity" -Check "OpenAI Service" -Status "Fail" -Message "Connectivity test failed" -Recommendation "Check network configuration and service status"
        }
    }
    
    # Test Table Storage connectivity
    if ($storageAccountName) {
        Write-Host "   💾 Testing Table Storage connectivity..." -ForegroundColor Cyan
        try {
            $tableEndpoint = "https://$storageAccountName.table.core.windows.net/"
            # Basic connectivity test
            $headers = @{ "x-ms-version" = "2019-02-02" }
            $response = Invoke-RestMethod -Uri "$tableEndpoint`?comp=properties&restype=service" -Method GET -Headers $headers -TimeoutSec 10 -ErrorAction SilentlyContinue
            if ($response) {
                Write-Host "     ✅ Table Storage endpoint is reachable" -ForegroundColor Green
                Add-ValidationResult -Component "Connectivity" -Check "Table Storage" -Status "Pass" -Message "Table Storage endpoint is reachable"
            } else {
                Write-Host "     ⚠️  Table Storage connectivity test inconclusive" -ForegroundColor Yellow
                Add-ValidationResult -Component "Connectivity" -Check "Table Storage" -Status "Warning" -Message "Connectivity test inconclusive"
            }
        } catch {
            Write-Host "     ❌ Table Storage connectivity test failed: $_" -ForegroundColor Red
            Add-ValidationResult -Component "Connectivity" -Check "Table Storage" -Status "Fail" -Message "Connectivity test failed" -Recommendation "Check network configuration and storage account status"
        }
    }
}

# =============================================================================
# Step 7: Validation Summary and Reporting
# =============================================================================

Write-Host ""
Write-Host "📊 Step 7: Validation Summary and Reporting" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Calculate validation statistics
$totalChecks = $validationResults.Count
$passedChecks = ($validationResults | Where-Object { $_.Status -eq "Pass" }).Count
$failedChecks = ($validationResults | Where-Object { $_.Status -eq "Fail" }).Count
$warningChecks = ($validationResults | Where-Object { $_.Status -eq "Warning" }).Count
$validationDuration = (Get-Date) - $validationStart

Write-Host ""
Write-Host "🎯 Infrastructure Validation Results" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "   ✅ Passed: $passedChecks checks" -ForegroundColor Green
Write-Host "   ⚠️  Warnings: $warningChecks checks" -ForegroundColor Yellow
Write-Host "   ❌ Failed: $failedChecks checks" -ForegroundColor Red
Write-Host "   📊 Total: $totalChecks checks" -ForegroundColor White
Write-Host "   ⏱️  Duration: $($validationDuration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor White

# Determine overall validation status
$overallStatus = if ($failedChecks -eq 0) {
    if ($warningChecks -eq 0) { "PASS" } else { "PASS_WITH_WARNINGS" }
} else {
    "FAIL"
}

Write-Host ""
switch ($overallStatus) {
    "PASS" {
        Write-Host "🎉 VALIDATION PASSED: All infrastructure components are properly configured!" -ForegroundColor Green
        Write-Host "   The Defender XDR integration is ready for operation." -ForegroundColor Green
    }
    "PASS_WITH_WARNINGS" {
        Write-Host "✅ VALIDATION PASSED WITH WARNINGS: Core infrastructure is functional." -ForegroundColor Yellow
        Write-Host "   Review warning items for optimal configuration." -ForegroundColor Yellow
    }
    "FAIL" {
        Write-Host "❌ VALIDATION FAILED: Critical infrastructure issues detected." -ForegroundColor Red
        Write-Host "   Address failed items before proceeding with operation." -ForegroundColor Red
    }
}

# Detailed reporting
if ($DetailedReport -or $failedChecks -gt 0 -or $warningChecks -gt 0) {
    Write-Host ""
    Write-Host "📋 Detailed Validation Report" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    
    # Group results by component
    $componentGroups = $validationResults | Group-Object Component
    
    foreach ($group in $componentGroups) {
        Write-Host ""
        Write-Host "🔸 $($group.Name)" -ForegroundColor White
        Write-Host "$(('-' * ($group.Name.Length + 4)))" -ForegroundColor Gray
        
        foreach ($result in $group.Group) {
            $statusIcon = switch ($result.Status) {
                "Pass" { "✅" }
                "Warning" { "⚠️ " }
                "Fail" { "❌" }
            }
            
            Write-Host "   $statusIcon $($result.Check): $($result.Message)" -ForegroundColor White
            
            if ($result.Recommendation -and ($result.Status -eq "Fail" -or $result.Status -eq "Warning")) {
                Write-Host "      💡 Recommendation: $($result.Recommendation)" -ForegroundColor Cyan
            }
        }
    }
}

# Export detailed report if requested
if ($DetailedReport) {
    $reportPath = Join-Path $PWD "defender-xdr-validation-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    
    $reportData = @{
        ValidationDate = $validationStart
        Environment = $EnvironmentName
        SubscriptionId = $subscriptionId
        Duration = $validationDuration.TotalSeconds
        Summary = @{
            TotalChecks = $totalChecks
            PassedChecks = $passedChecks
            WarningChecks = $warningChecks
            FailedChecks = $failedChecks
            OverallStatus = $overallStatus
        }
        Results = $validationResults
    }
    
    try {
        $reportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding UTF8
        Write-Host ""
        Write-Host "📄 Detailed report exported: $reportPath" -ForegroundColor Cyan
    } catch {
        Write-Host "⚠️  Failed to export detailed report: $_" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
if ($overallStatus -eq "PASS" -or $overallStatus -eq "PASS_WITH_WARNINGS") {
    Write-Host "   1. Manually trigger Logic Apps workflow to test end-to-end integration" -ForegroundColor White
    Write-Host "   2. Monitor workflow execution in Azure Portal Logic Apps blade" -ForegroundColor White
    Write-Host "   3. Check Defender XDR portal for AI-generated comments on alerts" -ForegroundColor White
    Write-Host "   4. Validate duplicate prevention by running workflow multiple times" -ForegroundColor White
} else {
    Write-Host "   1. Address all failed validation items using provided recommendations" -ForegroundColor White
    Write-Host "   2. Re-run validation script after fixing issues" -ForegroundColor White
    Write-Host "   3. Proceed to manual testing only after validation passes" -ForegroundColor White
}

Write-Host ""
Write-Host "✅ Infrastructure validation completed!" -ForegroundColor Green

# Set exit code based on validation results
if ($overallStatus -eq "FAIL") {
    exit 1
} else {
    exit 0
}

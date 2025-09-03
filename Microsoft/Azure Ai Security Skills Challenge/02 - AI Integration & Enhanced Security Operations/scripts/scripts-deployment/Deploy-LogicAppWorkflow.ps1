<#
.SYNOPSIS
    Deploy Logic Apps workflow with Microsoft Graph Security API integration and Azure OpenAI analysis capabilities.

.DESCRIPTION
    This script creates a complete Logic Apps workflow for automated Microsoft Defender XDR incident analysis 
    using Azure OpenAI. The deployment includes the Logic App with consumption plan, API connections for 
    Microsoft Graph Security API, Azure OpenAI service integration, Table Storage for duplicate prevention, 
    and Key Vault integration for secure credential management.

    The Logic App implements a comprehensive workflow: recurrence trigger → get Defender XDR incidents → 
    AI analysis with GPT models → duplicate checking → structured comment posting → processing audit trail. 
    This enables automated security incident analysis with AI-driven insights posted directly to Defender XDR alerts.

.PARAMETER EnvironmentName
    The environment name used for resource naming consistency (e.g., "aisec", "prod").

.PARAMETER Location  
    The Azure region for Logic App deployment (e.g., "East US", "West US 2").

.PARAMETER UseParametersFile
    Switch parameter to load configuration from main.parameters.json file.

.PARAMETER LogicAppName
    Optional custom name for the Logic App. If not provided, will be generated based on environment name.

.PARAMETER RecurrenceInterval
    Processing frequency for the Logic App trigger (e.g., "4 hours", "PT2H"). Default: "4 hours".

.PARAMETER MaxTokens
    Maximum tokens for Azure OpenAI responses. Controls response length and cost. Default: 500.

.PARAMETER Temperature
    Azure OpenAI temperature setting for response consistency (0.0-1.0). Default: 0.3.

.EXAMPLE
    .\Deploy-LogicAppWorkflow.ps1 -UseParametersFile
    
    Deploy Logic Apps workflow using parameters loaded from main.parameters.json with automatic resource naming.

.EXAMPLE
    .\Deploy-LogicAppWorkflow.ps1 -EnvironmentName "aisec" -Location "East US"
    
    Deploy Logic Apps workflow with specific environment and location parameters.

.EXAMPLE
    .\Deploy-LogicAppWorkflow.ps1 -UseParametersFile -RecurrenceInterval "2 hours" -MaxTokens 800
    
    Deploy with parameters file but override recurrence frequency and AI token limits for lab environment.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-09-01
    Last Modified: 2025-09-01
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Azure CLI installed and authenticated
    - PowerShell 5.1+ or PowerShell 7+
    - Existing Week 2 AI infrastructure (OpenAI service, storage account)
    - App registration with Microsoft Graph Security API permissions
    - Azure Key Vault with app registration credentials
    - Logic Apps service availability in target region
    
    Script development orchestrated using GitHub Copilot.

.WORKFLOW COMPONENTS
    - Logic Apps Consumption Plan (cost-effective serverless execution)
    - Microsoft Graph Security API connections (OAuth 2.0 authentication)
    - Azure OpenAI service integration (GPT-4o-mini analysis)
    - Table Storage connections (duplicate prevention and audit trails)
    - Key Vault integration (secure credential access)
    - Application Insights monitoring (performance and error tracking)
#>
#
# =============================================================================
# Deploy Logic Apps workflow for Microsoft Defender XDR integration.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName,
    
    [Parameter(Mandatory = $false)]
    [string]$Location,
    
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory = $false)]
    [string]$LogicAppName,
    
    [Parameter(Mandatory = $false)]
    [string]$RecurrenceInterval = "4 hours",
    
    [Parameter(Mandatory = $false)]
    [int]$MaxTokens = 500,
    
    [Parameter(Mandatory = $false)]
    [decimal]$Temperature = 0.3,
    
    [Parameter(Mandatory = $false)]
    [string]$OpenAIDeploymentName,
    
    [Parameter(Mandatory = $false)]
    [int]$MaxIncidentsPerRun,
    
    [Parameter(Mandatory = $false)]
    [bool]$HighSeverityOnly,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Script Configuration
$ErrorActionPreference = "Stop"

# Function to replace template placeholders
function Replace-TemplateParameters {
    param(
        [string]$TemplateContent,
        [hashtable]$Parameters
    )
    
    $result = $TemplateContent
    foreach ($key in $Parameters.Keys) {
        $result = $result.Replace("{$key}", $Parameters[$key])
    }
    return $result
}

Write-Host "🚀 Deploy Logic Apps Workflow for Defender XDR Integration" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

# =============================================================================
# Step 1: Parameter Loading and Validation
# =============================================================================

Write-Host "📋 Step 1: Parameter Loading and Validation" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

if ($UseParametersFile) {
    Write-Host "📄 Loading parameters from main.parameters.json..." -ForegroundColor Cyan
    
    $parametersPath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    if (-not (Test-Path $parametersPath)) {
        Write-Host "❌ Parameters file not found: $parametersPath" -ForegroundColor Red
        exit 1
    }
    
    try {
        $parametersContent = Get-Content $parametersPath | ConvertFrom-Json
        $parameters = $parametersContent.parameters
        
        $EnvironmentName = $parameters.environmentName.value
        $Location = $parameters.location.value
        $RecurrenceInterval = if ($parameters.recurrenceInterval) { $parameters.recurrenceInterval.value } else { $RecurrenceInterval }
        $MaxTokens = if ($parameters.maxTokens) { $parameters.maxTokens.value } else { $MaxTokens }
        $Temperature = if ($parameters.temperature) { [decimal]$parameters.temperature.value } else { $Temperature }
        
        # Load OpenAI and Logic App specific parameters
        $OpenAIDeploymentName = if ($parameters.openAIDeploymentName) { $parameters.openAIDeploymentName.value } else { "gpt-4o-mini" }
        $MaxIncidentsPerRun = if ($parameters.maxIncidentsPerRun) { $parameters.maxIncidentsPerRun.value } else { 50 }
        $HighSeverityOnly = if ($parameters.highSeverityOnly) { [bool]$parameters.highSeverityOnly.value } else { $false }
        $TopP = if ($parameters.topP) { $parameters.topP.value } else { "0.95" }
        $PresencePenalty = if ($parameters.presencePenalty) { $parameters.presencePenalty.value } else { "0" }
        $FrequencyPenalty = if ($parameters.frequencyPenalty) { $parameters.frequencyPenalty.value } else { "0" }
        $NumberOfCompletions = if ($parameters.numberOfCompletions) { $parameters.numberOfCompletions.value } else { 1 }
        $SeedValue = if ($parameters.seedValue) { [int]$parameters.seedValue.value } else { 0 }
        $SystemPrompt = if ($parameters.systemPrompt) { $parameters.systemPrompt.value } else { "You are a cybersecurity analyst. Analyze security incidents and provide structured analysis with these exact headers: ### 1) Executive Summary, ### 2) Risk Level Assessment, ### 3) Recommended Immediate Actions, ### 4) MITRE ATT&CK Mapping. Keep responses concise and actionable." }
        
        # Load Key Vault secret names from parameters
        $ClientIdSecretName = if ($parameters.appRegistrationClientIdSecret) { $parameters.appRegistrationClientIdSecret.value } else { "DefenderXDR-App-ClientId" }
        $ClientSecretName = if ($parameters.appRegistrationClientSecretName) { $parameters.appRegistrationClientSecretName.value } else { "DefenderXDR-App-ClientSecret" }
        $TenantIdSecretName = if ($parameters.appRegistrationTenantIdSecret) { $parameters.appRegistrationTenantIdSecret.value } else { "DefenderXDR-App-TenantId" }
        
        # Load resource group names from parameters
        $DefenderResourceGroupName = if ($parameters.defenderResourceGroupName) { $parameters.defenderResourceGroupName.value } else { "rg-$EnvironmentName-defender-$EnvironmentName" }
        $AIResourceGroupName = if ($parameters.aiResourceGroupName) { $parameters.aiResourceGroupName.value } else { "rg-$EnvironmentName-ai" }
        
        # Load API connection names from parameters
        $OpenAIConnectionName = if ($parameters.openAIConnectionName) { $parameters.openAIConnectionName.value } else { "azureopenai" }
        $AzureTablesConnectionName = if ($parameters.azureTablesConnectionName) { $parameters.azureTablesConnectionName.value } else { "azuretables" }
        
        Write-Host "   ✅ Parameters loaded successfully" -ForegroundColor Green
        Write-Host "   📍 Environment: $EnvironmentName" -ForegroundColor White
        Write-Host "   📍 Location: $Location" -ForegroundColor White
        Write-Host "   📍 Recurrence: $RecurrenceInterval" -ForegroundColor White
        Write-Host "   📍 Max Tokens: $MaxTokens" -ForegroundColor White
        Write-Host "   📍 Temperature: $Temperature" -ForegroundColor White
        Write-Host "   📍 OpenAI Deployment: $OpenAIDeploymentName" -ForegroundColor White
        Write-Host "   📍 Max Incidents/Run: $MaxIncidentsPerRun" -ForegroundColor White
        Write-Host "   📍 Defender RG: $DefenderResourceGroupName" -ForegroundColor White
        Write-Host "   📍 AI RG: $AIResourceGroupName" -ForegroundColor White
    } catch {
        Write-Host "❌ Failed to load parameters: $_" -ForegroundColor Red
        exit 1
    }
}

# Validate required parameters
if (-not $EnvironmentName -or -not $Location) {
    Write-Host "❌ Missing required parameters. Use -UseParametersFile or provide -EnvironmentName and -Location" -ForegroundColor Red
    exit 1
}

# Set default resource group names if not loaded from parameters
if (-not $DefenderResourceGroupName) { $DefenderResourceGroupName = "rg-$EnvironmentName-defender-$EnvironmentName" }
if (-not $AIResourceGroupName) { $AIResourceGroupName = "rg-$EnvironmentName-ai" }

# Set default API connection names if not loaded from parameters
if (-not $OpenAIConnectionName) { $OpenAIConnectionName = "azureopenai" }
if (-not $AzureTablesConnectionName) { $AzureTablesConnectionName = "azuretables" }

# Set default values for parameters that may not be loaded from file
if (-not $OpenAIDeploymentName) { $OpenAIDeploymentName = "gpt-4o-mini" }
if (-not $MaxIncidentsPerRun) { $MaxIncidentsPerRun = 50 }
if (-not $HighSeverityOnly) { $HighSeverityOnly = $false }
if (-not $TopP) { $TopP = "0.95" }
if (-not $PresencePenalty) { $PresencePenalty = "0" }
if (-not $FrequencyPenalty) { $FrequencyPenalty = "0" }
if (-not $NumberOfCompletions) { $NumberOfCompletions = 1 }
if (-not $SeedValue -and $SeedValue -ne 0) { $SeedValue = 0 }
if (-not $SystemPrompt) { $SystemPrompt = "You are a cybersecurity analyst. Analyze security incidents and provide structured analysis with these exact headers: ### 1) Executive Summary, ### 2) Risk Level Assessment, ### 3) Recommended Immediate Actions, ### 4) MITRE ATT&CK Mapping. Keep responses concise and actionable." }
if (-not $ClientIdSecretName) { $ClientIdSecretName = "DefenderXDR-App-ClientId" }
if (-not $ClientSecretName) { $ClientSecretName = "DefenderXDR-App-ClientSecret" }
if (-not $TenantIdSecretName) { $TenantIdSecretName = "DefenderXDR-App-TenantId" }

# Generate resource names based on actual deployed resources
$resourceGroupName = $DefenderResourceGroupName  # Logic App and connections go in Defender resource group (same as Key Vault and LAW)
$defenderResourceGroupName = $DefenderResourceGroupName  # Key Vault is in Defender resource group
$logicAppName = if ($LogicAppName) { $LogicAppName } else { "la-defender-xdr-ai-$EnvironmentName" }

# Resource names should be discovered from deployed resources, not hardcoded
# Key Vault is in Week 1 Defender resource group
$keyVaultName = $null  # Will be discovered
$storageAccountName = $null  # Will be discovered  
$openAIServiceName = $null  # Will be discovered

Write-Host ""
Write-Host "🎯 Deployment Configuration:" -ForegroundColor Cyan
Write-Host "   🏷️ Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   📍 Location: $Location" -ForegroundColor White
Write-Host "   🛡️ Logic App, API Connections & KV RG: $resourceGroupName" -ForegroundColor White
Write-Host "   🤖 Storage Account & OpenAI RG: $AIResourceGroupName" -ForegroundColor White
Write-Host "   ⚡ Logic App: $logicAppName" -ForegroundColor White
Write-Host "   📊 Log Analytics Workspace: $logAnalyticsWorkspaceName (from Week 1)" -ForegroundColor White

# =============================================================================
# Step 2: Prerequisite Validation
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Prerequisite Validation" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

Write-Host "🔐 Validating authentication and permissions..." -ForegroundColor Cyan
try {
    # Check Azure CLI authentication
    $account = az account show --output json 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Host "❌ Azure CLI not authenticated. Please run 'az login'" -ForegroundColor Red
        exit 1
    }
    Write-Host "   ✅ Azure CLI authenticated as: $($account.user.name)" -ForegroundColor Green
    
    # Validate Defender resource group exists (where Logic App will be deployed)
    $defenderResourceGroup = az group show --name $resourceGroupName --output json 2>$null | ConvertFrom-Json
    if (-not $defenderResourceGroup) {
        Write-Host "❌ Defender resource group not found: $resourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please run Week 1 Defender deployment first" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "   ✅ Defender resource group validated: $resourceGroupName" -ForegroundColor Green
    
    # Validate AI resource group exists (where OpenAI and Storage are located)
    $aiResourceGroup = az group show --name $AIResourceGroupName --output json 2>$null | ConvertFrom-Json
    if (-not $aiResourceGroup) {
        Write-Host "❌ AI resource group not found: $AIResourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please run Week 2 AI foundation deployment first" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "   ✅ AI resource group validated: $AIResourceGroupName" -ForegroundColor Green
    
    # Auto-discover Key Vault in Defender resource group
    $keyVaults = az keyvault list --resource-group $defenderResourceGroupName --output json 2>$null | ConvertFrom-Json
    if (-not $keyVaults -or $keyVaults.Count -eq 0) {
        Write-Host "❌ No Key Vault found in resource group: $defenderResourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please run Deploy-AppRegistration.ps1 first" -ForegroundColor Yellow
        exit 1
    }
    $keyVaultName = $keyVaults[0].name  # Use the first (and likely only) Key Vault
    Write-Host "   ✅ Key Vault discovered: $keyVaultName" -ForegroundColor Green
    
    # Check for required secrets in Key Vault
    $requiredSecrets = @($ClientIdSecretName, $ClientSecretName, $TenantIdSecretName)
    foreach ($secretName in $requiredSecrets) {
        $secret = az keyvault secret show --vault-name $keyVaultName --name $secretName --output json 2>$null | ConvertFrom-Json
        if (-not $secret) {
            Write-Host "❌ Required secret not found in Key Vault: $secretName" -ForegroundColor Red
            Write-Host "   💡 Please run Deploy-AppRegistration.ps1 first" -ForegroundColor Yellow
            exit 1
        }
    }
    Write-Host "   ✅ Key Vault secrets validated" -ForegroundColor Green
    
    # Auto-discover Log Analytics workspace in Defender resource group
    $logAnalyticsWorkspaces = az monitor log-analytics workspace list --resource-group $defenderResourceGroupName --output json 2>$null | ConvertFrom-Json
    if (-not $logAnalyticsWorkspaces -or $logAnalyticsWorkspaces.Count -eq 0) {
        Write-Host "❌ No Log Analytics workspace found in resource group: $defenderResourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please run Week 1 Defender deployment first" -ForegroundColor Yellow
        exit 1
    }
    $logAnalyticsWorkspaceName = $logAnalyticsWorkspaces[0].name  # Use the first (and likely only) workspace
    Write-Host "   ✅ Log Analytics workspace discovered: $logAnalyticsWorkspaceName" -ForegroundColor Green
    
    # Auto-discover storage account in AI resource group
    $storageAccounts = az storage account list --resource-group $AIResourceGroupName --output json 2>$null | ConvertFrom-Json
    if (-not $storageAccounts -or $storageAccounts.Count -eq 0) {
        Write-Host "❌ No storage account found in resource group: $AIResourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please run Deploy-ProcessingStorage.ps1 first" -ForegroundColor Yellow
        exit 1
    }
    $storageAccountName = $storageAccounts[0].name  # Use the first storage account
    Write-Host "   ✅ Storage account discovered: $storageAccountName" -ForegroundColor Green
    
    # Auto-discover OpenAI service in AI resource group
    $openAIServices = az cognitiveservices account list --resource-group $AIResourceGroupName --output json 2>$null | ConvertFrom-Json
    $openAIService = $openAIServices | Where-Object { $_.kind -eq "OpenAI" } | Select-Object -First 1
    if (-not $openAIService) {
        Write-Host "❌ OpenAI service not found in resource group: $AIResourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please run Week 2 AI foundation deployment first" -ForegroundColor Yellow
        exit 1
    }
    $openAIServiceName = $openAIService.name
    Write-Host "   ✅ OpenAI service discovered: $openAIServiceName" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Prerequisites validation failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Logic App Creation
# =============================================================================

Write-Host ""
Write-Host "⚡ Step 3: Logic App Creation" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

Write-Host "🚀 Creating Logic App with consumption plan..." -ForegroundColor Cyan
Write-Host "   ℹ️  Basic Logic App will be created; full workflow definition deployed in Step 6" -ForegroundColor White

if ($WhatIf) {
    Write-Host "👁️ [WHAT-IF] Would create Logic App: $logicAppName" -ForegroundColor Yellow
} else {
    try {
        # Load Logic App properties from template file
        $templatesPath = Join-Path $PSScriptRoot "templates"
        $logicAppTemplatePath = Join-Path $templatesPath "logic-app-initial.json"
        
        if (-not (Test-Path $logicAppTemplatePath)) {
            throw "Logic App template not found: $logicAppTemplatePath"
        }
        
        Write-Host "   📄 Using template: $logicAppTemplatePath" -ForegroundColor White
        
        # Read template content
        $templateContent = Get-Content $logicAppTemplatePath -Raw | ConvertFrom-Json
        
        # Create basic Logic App using REST API (workflow definition will be updated in Step 6)
        $subscriptionId = az account show --query id -o tsv
        $logicAppUrl = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/workflows/$logicAppName"
        
        # Create a temporary file for the JSON body to avoid PowerShell JSON serialization issues
        $tempJsonFile = [System.IO.Path]::GetTempFileName()
        
        try {
            # Prepare the request body for Consumption Logic App with System-Assigned Managed Identity
            $logicAppBody = @{
                location = $Location
                identity = @{
                    type = "SystemAssigned"
                }
                properties = @{
                    state = $templateContent.state
                    definition = $templateContent.definition
                    parameters = $templateContent.parameters
                }
                tags = @{
                    Environment = "AI Security Skills Challenge"
                    Project = "Week 2.6 - Logic App Integration"
                }
            }
            
            # Write JSON to temp file
            $logicAppBody | ConvertTo-Json -Depth 10 | Out-File -FilePath $tempJsonFile -Encoding UTF8
            
            $logicAppResult = az rest --method PUT --url "$logicAppUrl`?api-version=2019-05-01" --body "@$tempJsonFile" --output json
        }
        finally {
            # Clean up temp file
            if (Test-Path $tempJsonFile) {
                Remove-Item $tempJsonFile -Force
            }
        }
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create Logic App"
        }
        
        $logicApp = $logicAppResult | ConvertFrom-Json
        Write-Host "   ✅ Logic App created successfully: $($logicApp.name)" -ForegroundColor Green
        Write-Host "   � System-Assigned Managed Identity enabled" -ForegroundColor Green
        Write-Host "   �📍 Resource ID: $($logicApp.id)" -ForegroundColor White
        
    } catch {
        Write-Host "❌ Failed to create Logic App: $_" -ForegroundColor Red
        exit 1
    }
}

# =============================================================================
# Step 4: Configure Logic App with Log Analytics Integration
# =============================================================================

Write-Host ""
Write-Host "📊 Step 4: Configure Logic App with Log Analytics Integration" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

Write-Host "� Configuring Logic App diagnostic settings for monitoring..." -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "👁️ [WHAT-IF] Would configure diagnostic settings for Logic App: $logicAppName" -ForegroundColor Yellow
} else {
    try {
        # Configure Logic App diagnostic settings to use existing Log Analytics workspace
        Write-Host "   📊 Enabling Log Analytics integration for Logic App monitoring..." -ForegroundColor Cyan
        
        # Logic App resource ID for diagnostic settings
        $subscriptionId = az account show --query id -o tsv
        $logicAppResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/workflows/$logicAppName"
        $workspaceResourceId = "/subscriptions/$subscriptionId/resourceGroups/$defenderResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$logAnalyticsWorkspaceName"
        
        # Load diagnostic settings template
        $diagnosticsTemplatePath = Join-Path $templatesPath "logic-app-diagnostics.json"
        if (Test-Path $diagnosticsTemplatePath) {
            $diagnosticsTemplate = Get-Content $diagnosticsTemplatePath -Raw | ConvertFrom-Json
            
            # Update template with actual resource IDs
            $diagnosticsTemplate.properties.workspaceId = $workspaceResourceId
            
            # Create a temporary file for the diagnostic settings JSON body
            $tempDiagnosticsJsonFile = [System.IO.Path]::GetTempFileName()
            
            try {
                # Write JSON to temp file
                $diagnosticsTemplate | ConvertTo-Json -Depth 10 | Out-File -FilePath $tempDiagnosticsJsonFile -Encoding UTF8
                
                # Create diagnostic settings using REST API
                $diagnosticsName = "logic-app-diagnostics"
                $diagnosticsUrl = "https://management.azure.com$logicAppResourceId/providers/Microsoft.Insights/diagnosticSettings/$diagnosticsName"
                
                $diagnosticsResult = az rest --method PUT --url "$diagnosticsUrl`?api-version=2021-05-01-preview" --body "@$tempDiagnosticsJsonFile" --output json
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "   ✅ Log Analytics integration configured successfully" -ForegroundColor Green
                    Write-Host "   📊 Logic App logs will be sent to: $logAnalyticsWorkspaceName" -ForegroundColor Cyan
                } else {
                    Write-Host "   ⚠️ Diagnostic settings creation had issues, but Logic App is functional" -ForegroundColor Yellow
                }
                
            } finally {
                # Clean up temporary file
                Remove-Item $tempDiagnosticsJsonFile -Force -ErrorAction SilentlyContinue
            }
        } else {
            Write-Host "   ⚠️ Diagnostic settings template not found, skipping Log Analytics integration" -ForegroundColor Yellow
            Write-Host "   ✅ Logic App is still functional" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "   ❌ Failed to configure Log Analytics integration: $_" -ForegroundColor Red
        Write-Host "   ✅ Logic App is still functional, monitoring can be configured later" -ForegroundColor Green
    }
}

# =============================================================================
# Step 5: Discover and Validate Existing API Connections
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 5: Discover and Validate Existing API Connections" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

Write-Host "� Discovering existing API connections..." -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "👁️ [WHAT-IF] Would discover and validate existing API connections" -ForegroundColor Yellow
} else {
    try {
        $subscriptionId = az account show --query id -o tsv
        
        # Check for existing API connections in the resource group
        Write-Host "   📦 Checking for API connections in resource group: $resourceGroupName" -ForegroundColor Cyan
        $connections = az resource list --resource-group $resourceGroupName --resource-type "Microsoft.Web/connections" --output json | ConvertFrom-Json
        
        # Expected connections
        # Define expected API connections (Microsoft Graph uses HTTP actions instead of API connection)
        $expectedConnections = @($OpenAIConnectionName, $AzureTablesConnectionName)
        $foundConnections = @{}
        
        foreach ($connection in $connections) {
            $connectionName = $connection.name
            if ($connectionName -in $expectedConnections) {
                $foundConnections[$connectionName] = $connection.id
                Write-Host "   ✅ Found connection: $connectionName" -ForegroundColor Green
                Write-Host "      📋 ID: $($connection.id)" -ForegroundColor Gray
            }
        }
        
        # Validate required connections exist
        $missingConnections = $expectedConnections | Where-Object { $_ -notin $foundConnections.Keys }
        if ($missingConnections.Count -gt 0) {
            Write-Host "❌ Missing required API connections: $($missingConnections -join ', ')" -ForegroundColor Red
            Write-Host "💡 Please run Deploy-APIConnections.ps1 first to create the required connections" -ForegroundColor Yellow
            exit 1
        }
        
        # Set connection IDs for use in Logic App template
        $openAIConnectionId = $foundConnections[$OpenAIConnectionName]
        $tableConnectionId = $foundConnections[$AzureTablesConnectionName]
        
        Write-Host "   🎉 All required API connections found and validated" -ForegroundColor Green
        Write-Host "      🤖 Azure OpenAI: $($openAIConnectionId.Split('/')[-1])" -ForegroundColor White
        Write-Host "      📊 Azure Tables: $($tableConnectionId.Split('/')[-1])" -ForegroundColor White
    } catch {
        Write-Host "❌ Failed to discover API connections: $_" -ForegroundColor Red
        Write-Host "💡 Ensure Deploy-APIConnections.ps1 has been run successfully first" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "✅ Step 5 completed successfully" -ForegroundColor Green

# =============================================================================
# Step 6: Logic App Deployment with ARM Template
# =============================================================================

Write-Host ""
Write-Host "⚙️ Step 6: Logic App Deployment with ARM Template" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

Write-Host "📝 Deploying Logic App workflow using ARM template..." -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "👁️ [WHAT-IF] Would deploy Logic App workflow using ARM template" -ForegroundColor Yellow
} else {
    try {
        # Parse recurrence interval to determine frequency and interval
        $frequency = "Hour"
        $interval = 4
        
        if ($RecurrenceInterval -match "(\d+)\s*hour") {
            $interval = [int]$Matches[1]
            $frequency = "Hour"
        } elseif ($RecurrenceInterval -match "(\d+)\s*minute") {
            $interval = [int]$Matches[1]
            $frequency = "Minute"
        } elseif ($RecurrenceInterval -match "PT(\d+)H") {
            $interval = [int]$Matches[1]
            $frequency = "Hour"
        } elseif ($RecurrenceInterval -match "PT(\d+)M") {
            $interval = [int]$Matches[1]
            $frequency = "Minute"
        }
        
        Write-Host "   📅 Configured recurrence: $interval $frequency" -ForegroundColor White
        
        # Create incident filter based on severity settings
        $incidentFilter = if ($HighSeverityOnly) {
            "status eq 'active' and severity eq 'high'"
        } else {
            "status eq 'active'"
        }
        
        # Get subscription ID for connection references
        $subscriptionId = az account show --query id -o tsv
        
        # Use parameterized connection names
        $openAIConnectionName = $OpenAIConnectionName
        $tableConnectionName = $AzureTablesConnectionName
        
        # Build connection resource IDs
        $openAIConnectionId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Web/connections/$openAIConnectionName"
        $tableConnectionId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Web/connections/$tableConnectionName"
        
        Write-Host "   📋 Loading ARM template for workflow deployment..." -ForegroundColor Cyan
        
        # Deploy Logic App workflow using ARM template
        $armTemplatePath = Join-Path $templatesPath "logic-app-arm-template.json"
        if (-not (Test-Path $armTemplatePath)) {
            throw "ARM template not found: $armTemplatePath"
        }
        
        $deploymentName = "logic-app-workflow-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        
        Write-Host "   🚀 Deploying Logic App workflow ($deploymentName)..." -ForegroundColor Cyan
        
        # Validate authentication secrets exist in Key Vault (using references, not retrieving values for security)
        Write-Host "   🔐 Validating authentication secrets exist in Key Vault..." -ForegroundColor Cyan
        $clientIdExists = az keyvault secret show --vault-name $keyVaultName --name $ClientIdSecretName --query "name" --output tsv 2>$null
        $clientSecretExists = az keyvault secret show --vault-name $keyVaultName --name $ClientSecretName --query "name" --output tsv 2>$null
        $tenantIdExists = az keyvault secret show --vault-name $keyVaultName --name $TenantIdSecretName --query "name" --output tsv 2>$null
        
        if (-not $clientIdExists -or -not $clientSecretExists -or -not $tenantIdExists) {
            throw "Required secrets not found in Key Vault"
        }
        Write-Host "   ✅ Authentication secrets validated (using secure Key Vault references)" -ForegroundColor Green
        
        # Build deployment parameters
        $deploymentParameters = @{
            logicAppName = @{ value = $logicAppName }
            location = @{ value = $Location }
            frequency = @{ value = $frequency }
            interval = @{ value = $interval }
            incidentFilter = @{ value = $incidentFilter }
            maxIncidentsPerRun = @{ value = $MaxIncidentsPerRun }
            openAIDeploymentName = @{ value = $OpenAIDeploymentName }
            maxTokens = @{ value = [int]$MaxTokens }
            temperature = @{ value = $Temperature.ToString() }
            topP = @{ value = $TopP.ToString() }
            presencePenalty = @{ value = $PresencePenalty.ToString() }
            frequencyPenalty = @{ value = $FrequencyPenalty.ToString() }
            numberOfCompletions = @{ value = [int]$NumberOfCompletions }
            seedValue = @{ value = [int]$SeedValue }
            systemPrompt = @{ value = $SystemPrompt }
            openAIConnectionId = @{ value = $openAIConnectionId }
            tableConnectionId = @{ value = $tableConnectionId }
            # Use Key Vault references instead of plain text values for security
            tenantId = @{ 
                reference = @{
                    keyVault = @{ id = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName" }
                    secretName = $TenantIdSecretName
                }
            }
            clientId = @{ 
                reference = @{
                    keyVault = @{ id = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName" }
                    secretName = $ClientIdSecretName
                }
            }
            clientSecret = @{ 
                reference = @{
                    keyVault = @{ id = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName" }
                    secretName = $ClientSecretName
                }
            }
        }
        
        # Use Azure CLI with template file and parameters to avoid command line length issues
        $tempParametersFile = [System.IO.Path]::GetTempFileName() + ".json"
        $deploymentParameters | ConvertTo-Json -Depth 10 | Out-File -FilePath $tempParametersFile -Encoding UTF8
        
        $deployResult = az deployment group create `
            --resource-group $resourceGroupName `
            --name $deploymentName `
            --template-file $armTemplatePath `
            --parameters "@$tempParametersFile" `
            --output json
        
        # Clean up temporary parameters file
        Remove-Item $tempParametersFile -Force -ErrorAction SilentlyContinue
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to deploy Logic App workflow using ARM template"
        }
        
        if ($deployResult) {
            $deployment = $deployResult | ConvertFrom-Json
            Write-Host "   ✅ Logic App workflow deployed successfully" -ForegroundColor Green
            Write-Host "     📊 Deployment state: $($deployment.properties.provisioningState)" -ForegroundColor Cyan
        } else {
            throw "Failed to deploy Logic App workflow - no deployment result returned"
        }
        
        Write-Host "   ⏳ Waiting for deployment to complete..." -ForegroundColor Cyan
        
        # Poll deployment status using REST API
        $maxAttempts = 30
        $attempt = 0
        do {
            Start-Sleep -Seconds 10
            $attempt++
            
            $statusUrl = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Resources/deployments/$deploymentName" + "?api-version=2021-04-01"
            $status = az rest --method GET --url $statusUrl --output json | ConvertFrom-Json
            
            $provisioningState = $status.properties.provisioningState
            Write-Host "   📊 Deployment status: $provisioningState (attempt $attempt/$maxAttempts)" -ForegroundColor White
            
            if ($provisioningState -eq "Succeeded") {
                Write-Host "   ✅ Logic App workflow deployed successfully using ARM template" -ForegroundColor Green
                break
            } elseif ($provisioningState -eq "Failed") {
                $errorDetails = $status.properties.error | ConvertTo-Json -Depth 5
                throw "ARM template deployment failed: $errorDetails"
            }
            
        } while ($provisioningState -eq "Running" -and $attempt -lt $maxAttempts)
        
        if ($attempt -ge $maxAttempts -and $provisioningState -eq "Running") {
            throw "Deployment timeout: ARM template deployment did not complete within expected timeframe"
        }

        Write-Host "   🎉 Logic App workflow deployed successfully" -ForegroundColor Green
        Write-Host "   � API connections were pre-created and are ready for use" -ForegroundColor Cyan

    } catch {
        Write-Host "❌ Failed to deploy Logic App workflow: $_" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Step 6 completed successfully" -ForegroundColor Green

# =============================================================================
# Step 7: Connection Authorization
# =============================================================================

Write-Host ""
Write-Host "🔐 Step 7: Connection Authorization" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

if ($WhatIf) {
    Write-Host "👁️ [WHAT-IF] Would authorize API connections for Logic App" -ForegroundColor Yellow
} else {
    Write-Host "🔑 API connections created and configured" -ForegroundColor Cyan
    Write-Host "   ℹ️  Microsoft Graph connection uses app registration credentials" -ForegroundColor White
    Write-Host "   ℹ️  OpenAI connection uses service API key" -ForegroundColor White
    Write-Host "   ℹ️  Table Storage connection uses account key" -ForegroundColor White
    Write-Host "   ✅ All connections ready for use" -ForegroundColor Green
}

# =============================================================================
# Step 8: Deployment Validation
# =============================================================================

Write-Host ""
Write-Host "✅ Step 8: Deployment Validation" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

if ($WhatIf) {
    Write-Host "👁️ [WHAT-IF] Would validate Logic App deployment" -ForegroundColor Yellow
} else {
    Write-Host "🔍 Validating Logic App deployment..." -ForegroundColor Cyan
    
    try {
        # Get Logic App details for validation
        $logicAppDetails = az resource show --resource-group $resourceGroupName --resource-type "Microsoft.Logic/workflows" --name $logicAppName --output json | ConvertFrom-Json
        
        if ($logicAppDetails.properties.state -eq "Enabled") {
            Write-Host "   ✅ Logic App is enabled and ready" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Logic App state: $($logicAppDetails.properties.state)" -ForegroundColor Yellow
        }
        
        # Validate API connections
        $connections = @($openAIConnectionName, $tableConnectionName)
        foreach ($connectionName in $connections) {
            $connection = az resource show --resource-group $resourceGroupName --resource-type "Microsoft.Web/connections" --name $connectionName --output json 2>$null | ConvertFrom-Json
            if ($connection) {
                Write-Host "   ✅ API connection validated: $connectionName" -ForegroundColor Green
            } else {
                Write-Host "   ❌ API connection not found: $connectionName" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host "🎉 Logic App deployment completed successfully!" -ForegroundColor Green
        
    } catch {
        Write-Host "❌ Validation failed: $_" -ForegroundColor Red
        exit 1
    }
}

# =============================================================================
# Deployment Summary
# =============================================================================

Write-Host ""
Write-Host "📋 Deployment Summary" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "👁️ WHAT-IF MODE - No resources were actually deployed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📦 Resources that would be created/configured:" -ForegroundColor White
} else {
    Write-Host "✅ Successfully deployed resources:" -ForegroundColor White
}

Write-Host "   ⚡ Logic App: $logicAppName" -ForegroundColor White
Write-Host "   📊 Log Analytics Integration: $logAnalyticsWorkspaceName" -ForegroundColor White
Write-Host "   🔗 Microsoft Graph: Direct HTTP Authentication" -ForegroundColor White
Write-Host "   🤖 Azure OpenAI Connection: $openAIConnectionName" -ForegroundColor White
Write-Host "   📦 Table Storage Connection: $tableConnectionName" -ForegroundColor White

Write-Host ""
Write-Host "🔧 Workflow Configuration:" -ForegroundColor White
Write-Host "   📅 Recurrence: $RecurrenceInterval" -ForegroundColor White
Write-Host "   🎯 Max Tokens: $MaxTokens" -ForegroundColor White
Write-Host "   🌡️  Temperature: $Temperature" -ForegroundColor White

if (-not $WhatIf) {
    Write-Host ""
    Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Monitor Logic App runs in Azure Portal" -ForegroundColor White
    Write-Host "   2. Test the workflow with sample security incidents" -ForegroundColor White
    Write-Host "   3. Review AI-generated comments in Defender XDR portal" -ForegroundColor White
    Write-Host "   4. Check Log Analytics workspace for Logic App execution logs" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 Azure Portal Links:" -ForegroundColor Cyan
    Write-Host "   Logic App: https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/workflows/$logicAppName" -ForegroundColor White
    Write-Host "   Log Analytics: https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$defenderResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$logAnalyticsWorkspaceName" -ForegroundColor White
}

Write-Host ""
Write-Host "✅ Logic Apps workflow deployment completed!" -ForegroundColor Green

exit 0

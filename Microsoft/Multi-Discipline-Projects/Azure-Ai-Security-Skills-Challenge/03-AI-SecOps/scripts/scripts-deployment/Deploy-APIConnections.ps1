<#
.SYNOPSIS
    Deploys Azure API connections for Logic Apps integration with Microsoft Graph, Azure OpenAI, and Table Storage.

.DESCRIPTION
    This script creates the API connection resources required by Logic Apps for the Defender XDR integration.
    It establishes connections to Microsoft Graph (for security data), Azure OpenAI (for AI analysis),
    and Azure Table Storage (for duplicate prevention). The connections are deployed to the Week 1
    Defender resource group and configured with proper authentication methods.

.PARAMETER UseParametersFile
    Uses values from main.parameters.json file for deployment configuration.

.PARAMETER EnvironmentName
    The unique environment name for resource naming (overrides parameters file).

.PARAMETER Location
    The Azure region for resource deployment (overrides parameters file).

.EXAMPLE
    .\Deploy-APIConnections.ps1 -UseParametersFile
    
    Creates API connections using configuration from main.parameters.json.

.EXAMPLE
    .\Deploy-APIConnections.ps1 -EnvironmentName "aisec" -Location "East US"
    
    Creates API connections with specific parameters.

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
    - Week 1 Defender for Cloud deployment (resource group and Key Vault)
    - Week 2 AI foundation deployment (OpenAI service and Storage account)
    - App registration deployment completed
    
    Script development orchestrated using GitHub Copilot.

.API CONNECTIONS
    - Azure OpenAI (azureopenai): Connects to GPT-4o-mini model for AI analysis
    - Azure Table Storage (azuretables): Manages duplicate prevention and audit tracking  
    - Microsoft Graph API: Direct HTTP actions in Logic App using app registration credentials
#>
#
# =============================================================================
# Deploy API connections for Logic Apps Defender XDR integration workflow.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName,
    
    [Parameter(Mandatory = $false)]
    [string]$Location
)

# =============================================================================
# Step 1: Parameter Loading and Validation
# =============================================================================

Write-Host "🔗 Step 1: Parameter Loading and Validation" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Track deployment start time
$deploymentStart = Get-Date

# Load parameters from file if specified
if ($UseParametersFile) {
    $parametersPath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    if (Test-Path $parametersPath) {
        Write-Host "📄 Loading parameters from: $parametersPath" -ForegroundColor Cyan
        $parametersContent = Get-Content $parametersPath | ConvertFrom-Json
        
        if (-not $EnvironmentName) { $EnvironmentName = $parametersContent.parameters.environmentName.value }
        if (-not $Location) { $Location = $parametersContent.parameters.location.value }
        $defenderResourceGroupName = $parametersContent.parameters.defenderResourceGroupName.value
        
        # Load API connection names from parameters
        $OpenAIConnectionName = if ($parametersContent.parameters.openAIConnectionName) { $parametersContent.parameters.openAIConnectionName.value } else { "azureopenai" }
        $AzureTablesConnectionName = if ($parametersContent.parameters.azureTablesConnectionName) { $parametersContent.parameters.azureTablesConnectionName.value } else { "azuretables" }
        
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
    $defenderResourceGroupName = "rg-$EnvironmentName-defender-$EnvironmentName"
}

# Set default API connection names if not loaded from parameters
if (-not $OpenAIConnectionName) { $OpenAIConnectionName = "azureopenai" }
if (-not $AzureTablesConnectionName) { $AzureTablesConnectionName = "azuretables" }

# Derive resource names
$resourceGroupName = $defenderResourceGroupName  # Deploy to Week 1 resource group
$AIResourceGroupName = "rg-$EnvironmentName-ai"

Write-Host ""
Write-Host "🎯 API Connections Configuration:" -ForegroundColor Cyan
Write-Host "   🏷️  Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   📍 Location: $Location" -ForegroundColor White
Write-Host "   🛡️  Target Resource Group: $resourceGroupName" -ForegroundColor White
Write-Host "   📦 AI Resource Group: $AIResourceGroupName" -ForegroundColor White

# =============================================================================
# Step 2: Azure Authentication and Resource Validation
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Azure Authentication and Resource Validation" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green

Write-Host "🔐 Validating Azure CLI authentication..." -ForegroundColor Cyan
try {
    $account = az account show --output json 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Host "❌ Azure CLI not authenticated. Please run 'az login'" -ForegroundColor Red
        exit 1
    }
    $subscriptionId = $account.id
    Write-Host "   ✅ Azure CLI authenticated as: $($account.user.name)" -ForegroundColor Green
    Write-Host "   📋 Subscription: $($account.name) ($subscriptionId)" -ForegroundColor White
    
} catch {
    Write-Host "❌ Failed to verify Azure authentication: $_" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Validating required resource groups..." -ForegroundColor Cyan
try {
    # Validate target resource group (Week 1 Defender)
    $targetRG = az group show --name $resourceGroupName --output json 2>$null | ConvertFrom-Json
    if (-not $targetRG) {
        Write-Host "❌ Target resource group not found: $resourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please run Week 1 Defender for Cloud deployment first" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "   ✅ Target resource group validated: $resourceGroupName" -ForegroundColor Green
    
    # Validate AI resource group (Week 2)
    $aiRG = az group show --name $AIResourceGroupName --output json 2>$null | ConvertFrom-Json
    if (-not $aiRG) {
        Write-Host "❌ AI resource group not found: $AIResourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please run Week 2 AI foundation deployment first" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "   ✅ AI resource group validated: $AIResourceGroupName" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Failed to validate resource groups: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Discover Required Services
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Discover Required Services" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

Write-Host "🤖 Discovering Azure OpenAI service..." -ForegroundColor Cyan
try {
    $openAIServices = az resource list --resource-group $AIResourceGroupName --resource-type "Microsoft.CognitiveServices/accounts" --output json | ConvertFrom-Json
    $openAIService = $openAIServices | Where-Object { $_.kind -eq "OpenAI" } | Select-Object -First 1
    
    if (-not $openAIService) {
        Write-Host "❌ No OpenAI service found in resource group: $AIResourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please deploy Week 2 AI foundation first" -ForegroundColor Yellow
        exit 1
    }
    
    $openAIServiceName = $openAIService.name
    $openAIEndpoint = "https://$openAIServiceName.openai.azure.com/"
    Write-Host "   ✅ OpenAI service discovered: $openAIServiceName" -ForegroundColor Green
    Write-Host "   🌐 OpenAI endpoint: $openAIEndpoint" -ForegroundColor White
    
} catch {
    Write-Host "❌ Failed to discover OpenAI service: $_" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Discovering storage account..." -ForegroundColor Cyan
try {
    $storageAccounts = az storage account list --resource-group $AIResourceGroupName --output json | ConvertFrom-Json
    $storageAccount = $storageAccounts | Select-Object -First 1
    
    if (-not $storageAccount) {
        Write-Host "❌ No storage account found in resource group: $AIResourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please deploy Week 2 storage foundation first" -ForegroundColor Yellow
        exit 1
    }
    
    $storageAccountName = $storageAccount.name
    Write-Host "   ✅ Storage account discovered: $storageAccountName" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Failed to discover storage account: $_" -ForegroundColor Red
    exit 1
}

Write-Host "🔐 Discovering Key Vault..." -ForegroundColor Cyan
try {
    $keyVaults = az keyvault list --resource-group $resourceGroupName --output json | ConvertFrom-Json
    $keyVault = $keyVaults | Select-Object -First 1
    
    if (-not $keyVault) {
        Write-Host "❌ No Key Vault found in resource group: $resourceGroupName" -ForegroundColor Red
        Write-Host "   💡 Please run Deploy-AppRegistration.ps1 first to create Key Vault" -ForegroundColor Yellow
        exit 1
    }
    
    $keyVaultName = $keyVault.name
    Write-Host "   ✅ Key Vault discovered: $keyVaultName" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Failed to discover Key Vault: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 4: Create Azure OpenAI API Connection
# =============================================================================

Write-Host ""
Write-Host "🤖 Step 4: Create Azure OpenAI API Connection" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Build Azure OpenAI connection using parameterized name
$openAIConnectionName = $OpenAIConnectionName
$openAIConnectionId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Web/connections/$openAIConnectionName"

Write-Host "🔗 Creating Azure OpenAI connection: $openAIConnectionName" -ForegroundColor Cyan
try {
    # Get OpenAI API key from the OpenAI service
    Write-Host "   🔑 Retrieving OpenAI API key..." -ForegroundColor Cyan
    $openAIKeys = az cognitiveservices account keys list --name $openAIServiceName --resource-group $AIResourceGroupName --output json | ConvertFrom-Json
    $openAIApiKey = $openAIKeys.key1
    
    # Create connection with correct parameters
    $openAIConnectionDef = @{
        location = $Location
        properties = @{
            displayName = $openAIConnectionName
            api = @{
                id = "/subscriptions/$subscriptionId/providers/Microsoft.Web/locations/$Location/managedApis/azureopenai"
            }
            parameterValues = @{
                "azureOpenAIResourceName" = $openAIServiceName
                "azureOpenAIApiKey" = $openAIApiKey
                "azureSearchEndpointUrl" = ""
                "azureSearchApiKey" = ""
            }
            testLinks = @(
                @{
                    requestUri = "$openAIEndpoint/openai/deployments?api-version=2023-05-15"
                    method = "GET"
                }
            )
        }
    } | ConvertTo-Json -Depth 10
    
    # Create the connection using Azure REST API
    $tempDefFile = [System.IO.Path]::GetTempFileName()
    $openAIConnectionDef | Out-File -FilePath $tempDefFile -Encoding UTF8
    
    Write-Host "   🚀 Deploying OpenAI connection..." -ForegroundColor Cyan
    $result = az rest --method PUT --url "$openAIConnectionId`?api-version=2016-06-01" --body "@$tempDefFile" --headers "Content-Type=application/json" --output json
    Remove-Item $tempDefFile -Force -ErrorAction SilentlyContinue
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Azure OpenAI connection created successfully" -ForegroundColor Green
        $connectionResult = $result | ConvertFrom-Json
        Write-Host "   📋 Connection ID: $($connectionResult.id)" -ForegroundColor White
    } else {
        throw "Failed to create OpenAI connection (exit code: $LASTEXITCODE)"
    }
    
} catch {
    Write-Host "❌ Failed to create Azure OpenAI connection: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 5: Create Azure Table Storage API Connection
# =============================================================================

Write-Host ""
Write-Host "📦 Step 5: Create Azure Table Storage API Connection" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

# Build Azure Tables connection using parameterized name
$tableConnectionName = $AzureTablesConnectionName
$tableConnectionId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Web/connections/$tableConnectionName"

Write-Host "🔗 Creating Azure Table Storage connection: $tableConnectionName" -ForegroundColor Cyan
try {
    # Get storage account key
    Write-Host "   🔑 Retrieving storage account key..." -ForegroundColor Cyan
    $storageKeys = az storage account keys list --account-name $storageAccountName --resource-group $AIResourceGroupName --output json | ConvertFrom-Json
    $storageAccountKey = $storageKeys[0].value
    
    $tableConnectionDef = @{
        location = $Location
        properties = @{
            displayName = $tableConnectionName
            api = @{
                id = "/subscriptions/$subscriptionId/providers/Microsoft.Web/locations/$Location/managedApis/azuretables"
            }
            parameterValues = @{
                "storageaccount" = $storageAccountName
                "sharedkey" = $storageAccountKey
            }
            testLinks = @(
                @{
                    requestUri = "https://$storageAccountName.table.core.windows.net/Tables"
                    method = "GET"
                }
            )
        }
    } | ConvertTo-Json -Depth 10
    
    # Create the connection using Azure REST API
    $tempDefFile = [System.IO.Path]::GetTempFileName()
    $tableConnectionDef | Out-File -FilePath $tempDefFile -Encoding UTF8
    
    Write-Host "   🚀 Deploying Table Storage connection..." -ForegroundColor Cyan
    $result = az rest --method PUT --url "$tableConnectionId`?api-version=2016-06-01" --body "@$tempDefFile" --headers "Content-Type=application/json" --output json
    Remove-Item $tempDefFile -Force -ErrorAction SilentlyContinue
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Azure Table Storage connection created successfully" -ForegroundColor Green
        $connectionResult = $result | ConvertFrom-Json
        Write-Host "   📋 Connection ID: $($connectionResult.id)" -ForegroundColor White
    } else {
        throw "Failed to create Table Storage connection (exit code: $LASTEXITCODE)"
    }
    
} catch {
    Write-Host "❌ Failed to create Azure Table Storage connection: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 6: Validate App Registration for Microsoft Graph Access
# =============================================================================

Write-Host ""
Write-Host "✅ Step 6: Validate App Registration for Microsoft Graph Access" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Green

Write-Host "🔑 Validating app registration credentials for Microsoft Graph..." -ForegroundColor Cyan
try {
    # Retrieve app registration details from Key Vault
    Write-Host "   � Retrieving app registration credentials from Key Vault..." -ForegroundColor Cyan
    $clientId = az keyvault secret show --vault-name $keyVaultName --name "DefenderXDR-App-ClientId" --query "value" --output tsv
    $clientSecret = az keyvault secret show --vault-name $keyVaultName --name "DefenderXDR-App-ClientSecret" --query "value" --output tsv
    $tenantId = az keyvault secret show --vault-name $keyVaultName --name "DefenderXDR-App-TenantId" --query "value" --output tsv
    
    if (-not $clientId -or -not $clientSecret -or -not $tenantId) {
        throw "Failed to retrieve app registration credentials from Key Vault"
    }
    
    Write-Host "   ✅ App registration credentials retrieved successfully" -ForegroundColor Green
    Write-Host "   📋 Client ID: $clientId" -ForegroundColor White
    Write-Host "   🏢 Tenant ID: $tenantId" -ForegroundColor White
    Write-Host "   🔐 Client Secret: [Retrieved from Key Vault]" -ForegroundColor White
    
    # Note: Microsoft Graph will be accessed via HTTP actions in Logic App
    Write-Host "   💡 Microsoft Graph will be accessed directly via HTTP actions using these credentials" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Failed to validate app registration for Microsoft Graph: $_" -ForegroundColor Red
    Write-Host "   💡 Ensure Deploy-AppRegistration.ps1 was completed successfully" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 7: Validate API Connections
# =============================================================================

Write-Host ""
Write-Host "✅ Step 7: Validate API Connections" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

Write-Host "🔍 Validating created API connections..." -ForegroundColor Cyan
try {
    $connections = az resource list --resource-group $resourceGroupName --resource-type "Microsoft.Web/connections" --output json | ConvertFrom-Json
    
    $expectedConnections = @("azureopenai", "azuretables")
    $foundConnections = @()
    
    foreach ($connection in $connections) {
        $connectionName = $connection.name
        $foundConnections += $connectionName
        Write-Host "   ✅ Connection found: $connectionName" -ForegroundColor Green
        
        # Test connection status
        $connectionDetails = az resource show --id $connection.id --output json | ConvertFrom-Json
        $connectionStatus = $connectionDetails.properties.statuses[0].status
        Write-Host "     📊 Status: $connectionStatus" -ForegroundColor White
    }
    
    # Check for missing connections
    $missingConnections = $expectedConnections | Where-Object { $_ -notin $foundConnections }
    if ($missingConnections.Count -gt 0) {
        Write-Host "⚠️ Missing connections: $($missingConnections -join ', ')" -ForegroundColor Yellow
    } else {
        Write-Host "   🎉 All API connections created successfully" -ForegroundColor Green
    }
    
} catch {
    Write-Host "❌ Failed to validate API connections: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 8: Deployment Summary and Next Steps
# =============================================================================

Write-Host ""
Write-Host "🎉 Step 8: Deployment Summary and Next Steps" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

Write-Host "✅ API Connections Deployment Completed Successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Deployment Summary:" -ForegroundColor Cyan
Write-Host "   🎯 Resource Group: $resourceGroupName" -ForegroundColor White
Write-Host "   📍 Location: $Location" -ForegroundColor White
Write-Host "   ⏱️  Total Deployment Time: $((Get-Date) - $deploymentStart)" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Created API Connections:" -ForegroundColor Cyan
Write-Host "   🤖 Azure OpenAI: $openAIConnectionName" -ForegroundColor White
Write-Host "   📦 Azure Tables: $tableConnectionName" -ForegroundColor White
Write-Host ""
Write-Host "✅ App Registration Validated:" -ForegroundColor Cyan
Write-Host "   � Microsoft Graph credentials stored in Key Vault: $keyVaultName" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Run Deploy-LogicAppWorkflow.ps1 to deploy the Logic Apps workflow" -ForegroundColor White
Write-Host "   2. The workflow will use API connections + direct HTTP actions for Microsoft Graph" -ForegroundColor White
Write-Host "   3. Test the complete integration with Test-DefenderXDRIntegration.ps1" -ForegroundColor White
Write-Host ""
Write-Host "💡 Connection Architecture:" -ForegroundColor Cyan
Write-Host "   • Two API connections available in: $resourceGroupName" -ForegroundColor White
Write-Host "   • Microsoft Graph accessed via direct HTTP actions with app registration" -ForegroundColor White
Write-Host "   • Authentication handled via API connections and app credentials" -ForegroundColor White

Write-Host ""
Write-Host "🎉 API Connections deployment completed successfully!" -ForegroundColor Green

exit 0

<#
.SYNOPSIS
    Creates Azure Key Vault and stores OpenAI deployment secrets for Defender XDR integration.

.DESCRIPTION
    This script creates an Azure Key Vault in the Week 1 Defender resource group and
    stores essential OpenAI service deployment secrets that will be required for
    Logic Apps integration with Defender XDR.

    Key functionality includes:
    - Creates Azure Key Vault in the existing Defender for Cloud resource group
    - Configures appropriate access policies for the current user
    - Retrieves OpenAI service deployment information automatically
    - Stores OpenAI endpoint URL, API key, and deployment names as Key Vault secrets
    - Validates OpenAI service accessibility and configuration
    - Prepares secure credential storage for subsequent app registration deployment
    - Provides comprehensive error handling and validation

    The Key Vault is created in the same resource group as the Log Analytics Workspace
    from Week 1 Defender for Cloud deployment to maintain infrastructure consistency.

.PARAMETER EnvironmentName
    The environment name used for resource naming (e.g., "aisec").

.PARAMETER Location
    The Azure region for deployment (e.g., "East US").

.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file.

.PARAMETER DefenderResourceGroupName
    The name of the existing Defender resource group where Key Vault will be created.

.PARAMETER AIResourceGroupName
    The name of the AI resource group containing OpenAI service.

.PARAMETER NotificationEmail
    Email address for notifications and administrative contact.

.EXAMPLE
    .\Deploy-KeyVault.ps1 -UseParametersFile
    
    Creates Key Vault and stores OpenAI secrets using configuration from main.parameters.json.

.EXAMPLE
    .\Deploy-KeyVault.ps1 -EnvironmentName "aisec" -Location "East US" -DefenderResourceGroupName "rg-aisec-defender-aisec" -AIResourceGroupName "rg-aisec-ai"
    
    Creates Key Vault with specific parameters for targeted deployment.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-08-31
    Last Modified: 2025-08-31
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Azure CLI installed and authenticated
    - PowerShell 5.1+ or PowerShell 7+
    - Contributor access to Defender and AI resource groups
    - Existing OpenAI service deployment in AI resource group
    - Week 1 Defender for Cloud infrastructure deployed
    
    Script development orchestrated using GitHub Copilot.

.INTEGRATION POINTS
    - Week 1 Defender for Cloud resource group (Key Vault location)
    - Week 2 OpenAI service deployment (secret source)
    - Logic Apps deployment (secret consumer)
    - App registration script (shared Key Vault usage)
#>
#
# =============================================================================
# Key Vault creation and OpenAI secrets storage for Defender XDR integration.
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
    [string]$DefenderResourceGroupName,
    
    [Parameter(Mandatory = $false)]
    [string]$AIResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$NotificationEmail
)

# =============================================================================
# Step 1: Parameter Loading and Environment Setup
# =============================================================================

Write-Host "🔍 Step 1: Parameter Loading and Environment Setup" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

$startTime = Get-Date

# Load parameters from file if specified
if ($UseParametersFile) {
    Write-Host "📋 Loading parameters from main.parameters.json..." -ForegroundColor Cyan
    
    $parametersPath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    if (Test-Path $parametersPath) {
        try {
            $parametersContent = Get-Content $parametersPath | ConvertFrom-Json
            $EnvironmentName = $parametersContent.parameters.environmentName.value
            $Location = $parametersContent.parameters.location.value
            $NotificationEmail = $parametersContent.parameters.notificationEmail.value
            $DefenderResourceGroupName = $parametersContent.parameters.defenderResourceGroupName.value
            $enableKeyVaultIntegration = $parametersContent.parameters.enableKeyVaultIntegration.value
            
            # Derive AI resource group name from environment
            $AIResourceGroupName = "rg-$EnvironmentName-ai"
            
            Write-Host "   ✅ Parameters loaded successfully from file" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ Failed to load parameters file: $_" -ForegroundColor Red
            throw "Parameters file loading failed: $_"
        }
    } else {
        Write-Host "   ❌ Parameters file not found: $parametersPath" -ForegroundColor Red
        throw "Parameters file not found. Please ensure main.parameters.json exists in the infra directory."
    }
}

# Validate required parameters
if (-not $EnvironmentName) {
    throw "EnvironmentName parameter is required. Use -UseParametersFile or provide -EnvironmentName directly."
}
if (-not $Location) {
    throw "Location parameter is required. Use -UseParametersFile or provide -Location directly."
}
if (-not $DefenderResourceGroupName) {
    throw "DefenderResourceGroupName parameter is required."
}

# Set default AI resource group if not provided
if (-not $AIResourceGroupName) {
    $AIResourceGroupName = "rg-$EnvironmentName-ai"
}

Write-Host "   📊 Environment: $EnvironmentName | Location: $Location" -ForegroundColor Cyan
Write-Host "   🛡️  Defender RG: $DefenderResourceGroupName" -ForegroundColor Cyan
Write-Host "   🤖 AI RG: $AIResourceGroupName" -ForegroundColor Cyan

# =============================================================================
# Step 2: Azure Authentication and Subscription Validation
# =============================================================================

Write-Host ""
Write-Host "🔐 Step 2: Azure Authentication and Subscription Validation" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

Write-Host "📋 Validating Azure CLI authentication..." -ForegroundColor Cyan

try {
    $currentAccount = az account show --query "{subscriptionId:id, subscriptionName:name, userPrincipalName:user.name}" -o json | ConvertFrom-Json
    
    if (-not $currentAccount) {
        throw "No active Azure subscription found"
    }
    
    Write-Host "   ✅ Authenticated to Azure successfully" -ForegroundColor Green
    Write-Host "   📊 Subscription: $($currentAccount.subscriptionName)" -ForegroundColor Cyan
    Write-Host "   👤 User: $($currentAccount.userPrincipalName)" -ForegroundColor Cyan
    Write-Host "   🆔 Subscription ID: $($currentAccount.subscriptionId)" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ Azure authentication failed: $_" -ForegroundColor Red
    Write-Host "   💡 Please run 'az login' to authenticate" -ForegroundColor Yellow
    throw "Azure CLI authentication required"
}

# =============================================================================
# Step 3: Resource Group Validation
# =============================================================================

Write-Host ""
Write-Host "📁 Step 3: Resource Group Validation" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Validate Defender resource group
Write-Host "🛡️  Validating Defender resource group..." -ForegroundColor Cyan
try {
    $defenderRG = az group show --name $DefenderResourceGroupName --query "{name:name, location:location}" -o json | ConvertFrom-Json
    Write-Host "   ✅ Defender resource group found: $($defenderRG.name)" -ForegroundColor Green
    Write-Host "   📍 Location: $($defenderRG.location)" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Defender resource group not found: $DefenderResourceGroupName" -ForegroundColor Red
    throw "Defender resource group validation failed. Please ensure Week 1 deployment is complete."
}

# Validate AI resource group
Write-Host "🤖 Validating AI resource group..." -ForegroundColor Cyan
try {
    $aiRG = az group show --name $AIResourceGroupName --query "{name:name, location:location}" -o json | ConvertFrom-Json
    Write-Host "   ✅ AI resource group found: $($aiRG.name)" -ForegroundColor Green
    Write-Host "   📍 Location: $($aiRG.location)" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ AI resource group not found: $AIResourceGroupName" -ForegroundColor Red
    throw "AI resource group validation failed. Please ensure OpenAI deployment is complete."
}

# =============================================================================
# Step 4: OpenAI Service Discovery and Validation
# =============================================================================

Write-Host ""
Write-Host "🤖 Step 4: OpenAI Service Discovery and Validation" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

Write-Host "🔍 Discovering OpenAI services in AI resource group..." -ForegroundColor Cyan

try {
    $openAIServices = az cognitiveservices account list --resource-group $AIResourceGroupName --query "[?kind=='OpenAI']" -o json | ConvertFrom-Json
    
    if (-not $openAIServices -or $openAIServices.Count -eq 0) {
        throw "No OpenAI services found in resource group: $AIResourceGroupName"
    }
    
    $openAIService = $openAIServices[0]  # Use first OpenAI service found
    Write-Host "   ✅ OpenAI service discovered: $($openAIService.name)" -ForegroundColor Green
    Write-Host "   📍 Location: $($openAIService.location)" -ForegroundColor Cyan
    Write-Host "   🎯 SKU: $($openAIService.sku.name)" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ OpenAI service discovery failed: $_" -ForegroundColor Red
    throw "OpenAI service validation failed. Please ensure OpenAI deployment is complete."
}

# Get OpenAI service endpoint and keys
Write-Host "🔑 Retrieving OpenAI service credentials..." -ForegroundColor Cyan
try {
    $openAIEndpoint = az cognitiveservices account show --name $openAIService.name --resource-group $AIResourceGroupName --query "properties.endpoint" -o tsv
    $openAIKeys = az cognitiveservices account keys list --name $openAIService.name --resource-group $AIResourceGroupName -o json | ConvertFrom-Json
    
    if (-not $openAIEndpoint -or -not $openAIKeys.key1) {
        throw "Failed to retrieve OpenAI service credentials"
    }
    
    Write-Host "   ✅ OpenAI credentials retrieved successfully" -ForegroundColor Green
    Write-Host "   🌐 Endpoint: $openAIEndpoint" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ Failed to retrieve OpenAI credentials: $_" -ForegroundColor Red
    throw "OpenAI credential retrieval failed"
}

# Get OpenAI model deployments
Write-Host "📦 Discovering OpenAI model deployments..." -ForegroundColor Cyan
try {
    $deployments = az cognitiveservices account deployment list --name $openAIService.name --resource-group $AIResourceGroupName -o json | ConvertFrom-Json
    
    if (-not $deployments -or $deployments.Count -eq 0) {
        Write-Host "   ⚠️  No model deployments found - this is acceptable for basic setup" -ForegroundColor Yellow
        $deployments = @()
    } else {
        Write-Host "   ✅ Found $($deployments.Count) model deployment(s)" -ForegroundColor Green
        foreach ($deployment in $deployments) {
            Write-Host "   📋 Deployment: $($deployment.name) (Model: $($deployment.properties.model.name))" -ForegroundColor Cyan
        }
    }
    
} catch {
    Write-Host "   ⚠️  Failed to retrieve model deployments: $_" -ForegroundColor Yellow
    Write-Host "   💡 Continuing with service-level credentials only" -ForegroundColor Cyan
    $deployments = @()
}

# =============================================================================
# Step 5: Key Vault Creation
# =============================================================================

Write-Host ""
Write-Host "🔐 Step 5: Key Vault Creation" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

# Generate unique Key Vault name (must be globally unique)
$timestamp = Get-Date -Format "MMdd"
$uniqueKeyVaultName = "kv-$EnvironmentName-xdr-$timestamp"

Write-Host "🏗️  Creating Key Vault for secure credential storage..." -ForegroundColor Cyan
Write-Host "   🔍 Key Vault Name: $uniqueKeyVaultName" -ForegroundColor Cyan
Write-Host "   📁 Resource Group: $DefenderResourceGroupName" -ForegroundColor Cyan
Write-Host "   📍 Location: $Location" -ForegroundColor Cyan

try {
    # Get subscription ID for REST API calls
    $subscriptionId = az account show --query "id" -o tsv
    
    # Check for soft-deleted Key Vault first
    Write-Host "   🔍 Checking for soft-deleted Key Vault..." -ForegroundColor Yellow
    $softDeletedVaults = az keyvault list-deleted --query "[?name=='$uniqueKeyVaultName']" -o json | ConvertFrom-Json
    
    if ($softDeletedVaults -and $softDeletedVaults.Count -gt 0) {
        Write-Host "   🗂️  Found soft-deleted Key Vault: $uniqueKeyVaultName" -ForegroundColor Yellow
        Write-Host "   🔄 Attempting to recover soft-deleted Key Vault..." -ForegroundColor Yellow
        
        try {
            $recoverResult = az keyvault recover --name $uniqueKeyVaultName --location $Location 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   ✅ Key Vault recovered from soft-deleted state successfully" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  Key Vault recovery failed, attempting purge and recreate..." -ForegroundColor Yellow
                Write-Host "   🗑️  Purging soft-deleted Key Vault..." -ForegroundColor Yellow
                $purgeResult = az keyvault purge --name $uniqueKeyVaultName --location $Location 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "   ✅ Soft-deleted Key Vault purged successfully" -ForegroundColor Green
                    Write-Host "   ⏱️  Waiting for purge to complete..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 30
                } else {
                    throw "Failed to purge soft-deleted Key Vault: $purgeResult"
                }
            }
        } catch {
            Write-Host "   ❌ Key Vault recovery/purge failed: $_" -ForegroundColor Red
            throw "Key Vault soft-delete handling failed: $_"
        }
    } else {
        Write-Host "   ✅ No soft-deleted Key Vault found with name: $uniqueKeyVaultName" -ForegroundColor Green
    }
    
    # Check if Key Vault already exists in active state
    Write-Host "   🔍 Checking for existing active Key Vault..." -ForegroundColor Yellow
    $existingVault = az keyvault show --name $uniqueKeyVaultName 2>$null
    
    if ($existingVault) {
        Write-Host "   ✅ Key Vault already exists and is active: $uniqueKeyVaultName" -ForegroundColor Green
    } else {
        # Create Key Vault using REST API
        Write-Host "   🔍 Creating Key Vault via REST API..." -ForegroundColor Cyan
        
        $keyVaultCreateBody = @{
            location = $Location
            properties = @{
                sku = @{
                    family = "A"
                    name = "standard"
                }
                tenantId = (az account show --query "tenantId" -o tsv)
                enabledForTemplateDeployment = $true
                enableRbacAuthorization = $false
                accessPolicies = @()
            }
        } | ConvertTo-Json -Depth 3
        
        # Save request body to temp file for REST API call
        $tempCreateFile = [System.IO.Path]::GetTempFileName()
        $keyVaultCreateBody | Out-File -FilePath $tempCreateFile -Encoding UTF8
        
        $createUrl = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$DefenderResourceGroupName/providers/Microsoft.KeyVault/vaults/$uniqueKeyVaultName" + "?api-version=2023-07-01"
        
        $keyVaultResult = az rest --method PUT --url $createUrl --body "@$tempCreateFile"
        Remove-Item $tempCreateFile -Force
        
        if ($LASTEXITCODE -ne 0) {
            throw "Key Vault creation via REST API failed: $keyVaultResult"
        }
        
        Write-Host "   ✅ Key Vault created successfully via REST API" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Key Vault creation failed: $_" -ForegroundColor Red
    throw "Key Vault deployment failed"
}

# =============================================================================
# Step 6: Access Policy Configuration
# =============================================================================

Write-Host ""
Write-Host "🔒 Step 6: Access Policy Configuration" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

Write-Host "🔐 Configuring Key Vault access policies..." -ForegroundColor Cyan

try {
    # Get current user information for access policy
    $currentUser = az account show --query "user.name" -o tsv
    $currentUserObjectId = az ad user show --id $currentUser --query "id" -o tsv
    Write-Host "   👤 Setting access policy for user: $currentUser..." -ForegroundColor Cyan
    
    # Configure access policy using REST API
    $accessPolicyBody = @{
        properties = @{
            accessPolicies = @(
                @{
                    tenantId = (az account show --query "tenantId" -o tsv)
                    objectId = $currentUserObjectId
                    permissions = @{
                        secrets = @("get", "list", "set", "delete")
                    }
                }
            )
        }
    } | ConvertTo-Json -Depth 5
    
    # Save request body to temp file for REST API call
    $tempPolicyFile = [System.IO.Path]::GetTempFileName()
    $accessPolicyBody | Out-File -FilePath $tempPolicyFile -Encoding UTF8
    
    $policyUrl = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$DefenderResourceGroupName/providers/Microsoft.KeyVault/vaults/$uniqueKeyVaultName/accessPolicies/add?api-version=2023-07-01"
    
    $policyResult = az rest --method PUT --url $policyUrl --body "@$tempPolicyFile"
    Remove-Item $tempPolicyFile -Force
    
    if ($LASTEXITCODE -ne 0) {
        throw "Access policy setting via REST API failed: $policyResult"
    }
    
    Write-Host "   ✅ User access policy configured successfully via REST API" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Access policy configuration failed: $_" -ForegroundColor Red
    throw "Key Vault access policy configuration failed"
}

# =============================================================================
# Step 7: OpenAI Secrets Storage
# =============================================================================

Write-Host ""
Write-Host "🤖 Step 7: OpenAI Secrets Storage" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "📄 Storing OpenAI service credentials as Key Vault secrets..." -ForegroundColor Cyan

try {
    # Store OpenAI service endpoint using REST API
    Write-Host "   🌐 Storing OpenAI endpoint via REST API..." -ForegroundColor Cyan
    $endpointSecretBody = @{
        value = $openAIEndpoint
    } | ConvertTo-Json
    
    $tempEndpointFile = [System.IO.Path]::GetTempFileName()
    $endpointSecretBody | Out-File -FilePath $tempEndpointFile -Encoding UTF8
    
    $endpointSecretUrl = "https://$uniqueKeyVaultName.vault.azure.net/secrets/OpenAI-Service-Endpoint?api-version=7.4"
    $endpointResult = az rest --method PUT --url $endpointSecretUrl --body "@$tempEndpointFile" --resource "https://vault.azure.net"
    Remove-Item $tempEndpointFile -Force
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to store OpenAI endpoint secret via REST API: $endpointResult"
    }
    
    # Store OpenAI API key using REST API
    Write-Host "   🔑 Storing OpenAI API key via REST API..." -ForegroundColor Cyan
    $apiKeySecretBody = @{
        value = $openAIKeys.key1
    } | ConvertTo-Json
    
    $tempApiKeyFile = [System.IO.Path]::GetTempFileName()
    $apiKeySecretBody | Out-File -FilePath $tempApiKeyFile -Encoding UTF8
    
    $apiKeySecretUrl = "https://$uniqueKeyVaultName.vault.azure.net/secrets/OpenAI-Service-APIKey?api-version=7.4"
    $apiKeyResult = az rest --method PUT --url $apiKeySecretUrl --body "@$tempApiKeyFile" --resource "https://vault.azure.net"
    Remove-Item $tempApiKeyFile -Force
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to store OpenAI API key secret via REST API: $apiKeyResult"
    }
    
    # Store OpenAI service name using REST API
    Write-Host "   📋 Storing OpenAI service name via REST API..." -ForegroundColor Cyan
    $serviceNameSecretBody = @{
        value = $openAIService.name
    } | ConvertTo-Json
    
    $tempServiceNameFile = [System.IO.Path]::GetTempFileName()
    $serviceNameSecretBody | Out-File -FilePath $tempServiceNameFile -Encoding UTF8
    
    $serviceNameSecretUrl = "https://$uniqueKeyVaultName.vault.azure.net/secrets/OpenAI-Service-Name?api-version=7.4"
    $serviceNameResult = az rest --method PUT --url $serviceNameSecretUrl --body "@$tempServiceNameFile" --resource "https://vault.azure.net"
    Remove-Item $tempServiceNameFile -Force
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to store OpenAI service name secret via REST API: $serviceNameResult"
    }
    
    # Store OpenAI resource group using REST API
    Write-Host "   📁 Storing OpenAI resource group via REST API..." -ForegroundColor Cyan
    $resourceGroupSecretBody = @{
        value = $AIResourceGroupName
    } | ConvertTo-Json
    
    $tempResourceGroupFile = [System.IO.Path]::GetTempFileName()
    $resourceGroupSecretBody | Out-File -FilePath $tempResourceGroupFile -Encoding UTF8
    
    $resourceGroupSecretUrl = "https://$uniqueKeyVaultName.vault.azure.net/secrets/OpenAI-ResourceGroup?api-version=7.4"
    $resourceGroupResult = az rest --method PUT --url $resourceGroupSecretUrl --body "@$tempResourceGroupFile" --resource "https://vault.azure.net"
    Remove-Item $tempResourceGroupFile -Force
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to store OpenAI resource group secret via REST API: $resourceGroupResult"
    }
    
    Write-Host "   ✅ Core OpenAI secrets stored successfully" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ OpenAI secrets storage failed: $_" -ForegroundColor Red
    throw "OpenAI secrets storage failed"
}

# Store model deployment information if available
if ($deployments -and $deployments.Count -gt 0) {
    Write-Host "📦 Storing model deployment information..." -ForegroundColor Cyan
    
    try {
        # Create deployment names summary
        $deploymentNames = $deployments | ForEach-Object { $_.name }
        $deploymentNamesJson = $deploymentNames | ConvertTo-Json -Compress
        
        # Store deployment names using REST API
        $deploymentNamesSecretBody = @{
            value = $deploymentNamesJson
        } | ConvertTo-Json
        
        $tempDeploymentNamesFile = [System.IO.Path]::GetTempFileName()
        $deploymentNamesSecretBody | Out-File -FilePath $tempDeploymentNamesFile -Encoding UTF8
        
        $deploymentNamesSecretUrl = "https://$uniqueKeyVaultName.vault.azure.net/secrets/OpenAI-Deployment-Names?api-version=7.4"
        $deploymentNamesResult = az rest --method PUT --url $deploymentNamesSecretUrl --body "@$tempDeploymentNamesFile" --resource "https://vault.azure.net"
        Remove-Item $tempDeploymentNamesFile -Force
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to store deployment names via REST API: $deploymentNamesResult"
        }
        
        # Store primary deployment name (first one found) using REST API
        $primaryDeployment = $deployments[0].name
        $primarySecretBody = @{
            value = $primaryDeployment
        } | ConvertTo-Json
        
        $tempPrimaryFile = [System.IO.Path]::GetTempFileName()
        $primarySecretBody | Out-File -FilePath $tempPrimaryFile -Encoding UTF8
        
        $primarySecretUrl = "https://$uniqueKeyVaultName.vault.azure.net/secrets/OpenAI-Primary-Deployment?api-version=7.4"
        $primaryResult = az rest --method PUT --url $primarySecretUrl --body "@$tempPrimaryFile" --resource "https://vault.azure.net"
        Remove-Item $tempPrimaryFile -Force
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to store primary deployment name via REST API: $primaryResult"
        }
        
        Write-Host "   ✅ Model deployment information stored successfully" -ForegroundColor Green
        Write-Host "   📋 Primary deployment: $primaryDeployment" -ForegroundColor Cyan
        
    } catch {
        Write-Host "   ⚠️  Model deployment storage failed: $_" -ForegroundColor Yellow
        Write-Host "   💡 Core OpenAI secrets are still available" -ForegroundColor Cyan
    }
} else {
    Write-Host "📦 No model deployments to store - core service credentials available" -ForegroundColor Cyan
}

# =============================================================================
# Step 8: Key Vault Administrator Permissions Setup
# =============================================================================

Write-Host ""
Write-Host "🔐 Step 8: Key Vault Administrator Permissions Setup" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green

Write-Host "📋 Configuring Key Vault Administrator permissions for current user..." -ForegroundColor Cyan
try {
    $currentUserEmail = az account show --query "user.name" -o tsv
    $subscriptionId = az account show --query "id" -o tsv
    
    if ($currentUserEmail -and $subscriptionId) {
        Write-Host "   👤 Current User: $currentUserEmail" -ForegroundColor Cyan
        Write-Host "   📊 Subscription: $subscriptionId" -ForegroundColor Cyan
        
        # Define Key Vault scope for role assignment
        $keyVaultScope = "/subscriptions/$subscriptionId/resourceGroups/$DefenderResourceGroupName/providers/Microsoft.KeyVault/vaults/$uniqueKeyVaultName"
        
        # Check if Key Vault Administrator role assignment already exists
        Write-Host "   🔍 Checking existing role assignments..." -ForegroundColor Yellow
        $existingAssignment = az role assignment list --assignee $currentUserEmail --scope $keyVaultScope --role "Key Vault Administrator" --query "[].{Role:roleDefinitionName}" -o tsv 2>$null
        
        if ($existingAssignment -and $existingAssignment.Contains("Key Vault Administrator")) {
            Write-Host "   ✅ Key Vault Administrator role already assigned" -ForegroundColor Green
        } else {
            Write-Host "   🔄 Assigning Key Vault Administrator role..." -ForegroundColor Yellow
            $roleAssignResult = az role assignment create --assignee $currentUserEmail --role "Key Vault Administrator" --scope $keyVaultScope 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   ✅ Key Vault Administrator role assigned successfully" -ForegroundColor Green
                Write-Host "   🎯 Enables secret purging for subsequent app registration script" -ForegroundColor Cyan
            } else {
                Write-Host "   ⚠️  Failed to assign Key Vault Administrator role" -ForegroundColor Yellow
                Write-Host "   📋 Error: $roleAssignResult" -ForegroundColor Red
                Write-Host "   💡 Manual role assignment may be required for secret purging" -ForegroundColor Cyan
            }
        }
        
        # Brief pause to allow role assignment to propagate
        Write-Host "   ⏱️  Waiting for role assignment to propagate..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        
    } else {
        throw "Unable to retrieve current user email or subscription ID"
    }
    
} catch {
    Write-Host "   ❌ Key Vault Administrator permission setup failed: $_" -ForegroundColor Red
    Write-Host "   💡 You may need to manually assign Key Vault Administrator role for secret purging" -ForegroundColor Yellow
    Write-Host "   📋 Role: Key Vault Administrator" -ForegroundColor Cyan
    Write-Host "   📋 Scope: Key Vault ($uniqueKeyVaultName)" -ForegroundColor Cyan
}

# =============================================================================
# Step 9: Configuration Summary and Next Steps
# =============================================================================

Write-Host ""
Write-Host "📊 Step 9: Configuration Summary and Next Steps" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

$endTime = Get-Date
$deploymentDuration = [math]::Round(($endTime - $startTime).TotalSeconds, 2)

Write-Host ""
Write-Host "🎉 Key Vault and OpenAI Secrets Deployment Summary" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""
Write-Host "🔐 Key Vault Configuration:" -ForegroundColor Magenta
Write-Host "   • Key Vault Name: $uniqueKeyVaultName" -ForegroundColor White
Write-Host "   • Resource Group: $DefenderResourceGroupName" -ForegroundColor White
Write-Host "   • Location: $Location" -ForegroundColor White
Write-Host ""
Write-Host "🤖 OpenAI Service Integration:" -ForegroundColor Magenta
Write-Host "   • Service Name: $($openAIService.name)" -ForegroundColor White
Write-Host "   • Endpoint: https://****-****-***.openai.azure.com/" -ForegroundColor White
Write-Host "   • Resource Group: $AIResourceGroupName" -ForegroundColor White
Write-Host ""
Write-Host "🔑 Stored Secrets:" -ForegroundColor Magenta
Write-Host "   • OpenAI Service Endpoint: OpenAI-Service-Endpoint" -ForegroundColor White
Write-Host "   • OpenAI API Key: OpenAI-Service-APIKey" -ForegroundColor White
Write-Host "   • OpenAI Service Name: OpenAI-Service-Name" -ForegroundColor White
Write-Host "   • OpenAI Resource Group: OpenAI-ResourceGroup" -ForegroundColor White

if ($deployments -and $deployments.Count -gt 0) {
    Write-Host "   • Model Deployment Names: OpenAI-Deployment-Names" -ForegroundColor White
    Write-Host "   • Primary Deployment: OpenAI-Primary-Deployment" -ForegroundColor White
}

Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run Deploy-AppRegistration.ps1 to create Entra ID app registration" -ForegroundColor White
Write-Host "2. App registration script will use this Key Vault for credential storage" -ForegroundColor White
Write-Host "3. Proceed with Logic Apps deployment using Key Vault secrets" -ForegroundColor White
Write-Host "4. Test end-to-end OpenAI + Defender XDR integration" -ForegroundColor White

Write-Host ""
Write-Host "🎉 Deployment completed successfully in $deploymentDuration seconds" -ForegroundColor Green

Write-Host ""
Write-Host "📋 Script completed successfully" -ForegroundColor Green

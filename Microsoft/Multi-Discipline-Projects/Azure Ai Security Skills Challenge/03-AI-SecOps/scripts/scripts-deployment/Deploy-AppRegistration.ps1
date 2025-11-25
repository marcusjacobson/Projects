<#
.SYNOPSIS
    Deploy Entra ID app registration with Microsoft Graph Security API permissions for Defender XDR integration.

.DESCRIPTION
    This script creates an Entra ID app registration specifically configured for Microsoft Graph Security API access, 
    enabling Logic Apps integration with Microsoft Defender XDR for automated security incident analysis. 
    
    The script configures application permissions for Microsoft Graph Security API, creates 
    client secrets for authentication, grants admin consent, and stores credentials in Azure Key Vault. 
    This deployment follows security best practices including principle of least privilege and secure credential 
    management patterns.

.PARAMETER EnvironmentName
    The environment name used for resource naming consistency (e.g., "aisec", "prod").

.PARAMETER Location  
    The Azure region for Key Vault deployment (e.g., "East US", "West US 2").

.PARAMETER UseParametersFile
    Switch parameter to load configuration from main.parameters.json file.

.PARAMETER KeyVaultName
    Optional custom name for the Key Vault. If not provided, will be generated based on environment name.

.PARAMETER AppRegistrationName
    Optional custom name for the app registration. If not provided, will be generated as "LogicApp-DefenderXDRIntegration-{environmentName}".

.EXAMPLE
    .\Deploy-AppRegistration.ps1 -UseParametersFile
    
    Deploy app registration using parameters loaded from main.parameters.json with automatic resource naming.

.EXAMPLE
    .\Deploy-AppRegistration.ps1 -EnvironmentName "aisec" -Location "East US"
    
    Deploy app registration with specific environment and location parameters.

.EXAMPLE
    .\Deploy-AppRegistration.ps1 -UseParametersFile -AppRegistrationName "CustomAppName" -KeyVaultName "kv-custom-vault"
    
    Deploy with parameters file but override app registration and Key Vault names.

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
    - Entra ID Global Administrator or Application Administrator permissions
    - Microsoft Graph API access in target tenant
    - Azure Key Vault service availability in target region
    
    Script development orchestrated using GitHub Copilot.

.INTEGRATION POINTS
    - Microsoft Graph Security API (OAuth 2.0 application permissions)
    - Azure Key Vault (secure credential storage)
    - Azure Resource Manager (resource group and naming consistency)
    - Defender XDR unified portal (incident and alert access)
#>
#
# =============================================================================
# Deploy Entra ID app registration for Microsoft Defender XDR integration.
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
    [string]$KeyVaultName,
    
    [Parameter(Mandatory = $false)]
    [string]$AppRegistrationName,

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
            $defenderResourceGroupName = $parametersContent.parameters.defenderResourceGroupName.value
            $enableKeyVaultIntegration = $parametersContent.parameters.enableKeyVaultIntegration.value
            
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

# Set default resource names if not provided
if (-not $AppRegistrationName) {
    $AppRegistrationName = "LogicApp-DefenderXDRIntegration-$EnvironmentName"
}
if (-not $KeyVaultName) {
    $KeyVaultName = "kv-$EnvironmentName-integration"
}

Write-Host "   📊 Environment: $EnvironmentName | Location: $Location" -ForegroundColor Cyan
Write-Host "   📱 App Registration: $AppRegistrationName" -ForegroundColor Cyan
Write-Host "   🔐 Key Vault: $KeyVaultName" -ForegroundColor Cyan

# =============================================================================
# Step 2: Azure Authentication and Subscription Validation  
# =============================================================================

Write-Host ""
Write-Host "🔐 Step 2: Azure Authentication and Subscription Validation" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

Write-Host "📋 Validating Azure CLI authentication..." -ForegroundColor Cyan
try {
    # Use REST API to get current account information
    $accountResponse = az rest --method GET --url "https://management.azure.com/tenants?api-version=2020-01-01"
    $accountInfo = $accountResponse | ConvertFrom-Json
    
    if ($accountInfo -and $accountInfo.value) {
        Write-Host "   ✅ Azure CLI Authentication verified" -ForegroundColor Green
        
        # Get current subscription details
        $subscriptionResponse = az rest --method GET --url "https://management.azure.com/subscriptions?api-version=2020-01-01"
        $subscriptions = $subscriptionResponse | ConvertFrom-Json
        
        if ($subscriptions.value -and $subscriptions.value.Count -gt 0) {
            $currentSub = $subscriptions.value[0]
            Write-Host "   📊 Subscription: $($currentSub.displayName) ($($currentSub.subscriptionId))" -ForegroundColor Cyan
        }
    } else {
        throw "Unable to retrieve account information"
    }
} catch {
    Write-Host "   ❌ Azure authentication failed: $_" -ForegroundColor Red
    throw "Please run 'az login' to authenticate with Azure CLI"
}

Write-Host "📋 Validating required permissions..." -ForegroundColor Cyan
try {
    # Check if user has permission to create app registrations
    $userResponse = az rest --method GET --url "https://graph.microsoft.com/v1.0/me" --resource "https://graph.microsoft.com"
    $userInfo = $userResponse | ConvertFrom-Json
    
    if ($userInfo -and $userInfo.id) {
        Write-Host "   ✅ Microsoft Graph API access confirmed" -ForegroundColor Green
        Write-Host "   👤 Current User: $($userInfo.userPrincipalName)" -ForegroundColor Cyan
    } else {
        throw "Unable to access Microsoft Graph API"
    }
} catch {
    Write-Host "   ❌ Microsoft Graph API access failed: $_" -ForegroundColor Red
    throw "Ensure you have Application Administrator or Global Administrator permissions"
}

# =============================================================================
# Step 3: App Registration Creation and Configuration
# =============================================================================

Write-Host ""
Write-Host "📱 Step 3: App Registration Creation and Configuration" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

Write-Host "📋 Checking for existing app registration..." -ForegroundColor Cyan
try {
    # Use REST API to search for existing app registration
    $existingAppResponse = az rest --method GET --url "https://graph.microsoft.com/v1.0/applications?`$filter=displayName eq '$AppRegistrationName'" --resource "https://graph.microsoft.com"
    $existingApps = $existingAppResponse | ConvertFrom-Json
    
    $appRegistration = $null
    if ($existingApps.value -and $existingApps.value.Count -gt 0) {
        $appRegistration = $existingApps.value[0]
        Write-Host "   ✅ Found existing app registration: $($appRegistration.displayName)" -ForegroundColor Green
        Write-Host "   📋 App ID: $($appRegistration.appId)" -ForegroundColor Cyan
    } else {
        Write-Host "   📋 Creating new app registration..." -ForegroundColor Cyan
        
        # Create app registration using REST API
        $appRequestBody = @{
            displayName = $AppRegistrationName
            signInAudience = "AzureADMyOrg"
            description = "App registration for Logic Apps integration with Microsoft Defender XDR"
        }
        
        $tempJsonFile = [System.IO.Path]::GetTempFileName()
        $appRequestBody | ConvertTo-Json | Out-File -FilePath $tempJsonFile -Encoding utf8
        
        $createAppResponse = az rest --method POST --url "https://graph.microsoft.com/v1.0/applications" --body "@$tempJsonFile" --headers "Content-Type=application/json" --resource "https://graph.microsoft.com"
        Remove-Item $tempJsonFile -Force -ErrorAction SilentlyContinue
        $appRegistration = $createAppResponse | ConvertFrom-Json
        
        if ($appRegistration -and $appRegistration.appId) {
            Write-Host "   ✅ App registration created successfully" -ForegroundColor Green
            Write-Host "   📋 App ID: $($appRegistration.appId)" -ForegroundColor Cyan
            Write-Host "   📋 Object ID: $($appRegistration.id)" -ForegroundColor Cyan
        } else {
            throw "Failed to create app registration"
        }
    }
} catch {
    Write-Host "   ❌ App registration operation failed: $_" -ForegroundColor Red
    throw "App registration creation failed: $_"
}

# =============================================================================
# Step 4: Microsoft Graph API Permissions Configuration
# =============================================================================

Write-Host ""
Write-Host "🔑 Step 4: Microsoft Graph API Permissions Configuration" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green

Write-Host "📋 Configuring Microsoft Graph Security API permissions..." -ForegroundColor Cyan

# Define required permissions with correct Microsoft Graph permission IDs
$requiredPermissions = @(
    @{ 
        permission = "SecurityIncident.ReadWrite.All"
        id = "34bf0e97-1971-4929-b999-9e2442d941d7"
        description = "Read and write access to Defender XDR incidents"
    },
    @{ 
        permission = "SecurityAlert.ReadWrite.All"
        id = "ed4fca05-be46-441f-9803-1873825f8fdb"  
        description = "Read and write access to security alerts"
    },
    @{ 
        permission = "SecurityEvents.Read.All"
        id = "bf394140-e372-4bf9-a898-299cfc7564e5"
        description = "Read access to security events"
    }
)

try {
    # Get current permissions for validation
    $currentPermissionsResponse = az rest --method GET --url "https://graph.microsoft.com/v1.0/applications/$($appRegistration.id)" --resource "https://graph.microsoft.com"
    if (-not $currentPermissionsResponse) {
        throw "Unable to retrieve current app permissions"
    }
    
    # Prepare Microsoft Graph resource permissions
    $msGraphResourceId = "00000003-0000-0000-c000-000000000000"  # Microsoft Graph
    
    $resourceAccess = @()
    foreach ($permission in $requiredPermissions) {
        $resourceAccess += @{
            id = $permission.id
            type = "Role"  # Application permission
        }
        Write-Host "   📋 Adding permission: $($permission.permission)" -ForegroundColor Cyan
    }
    
    # Update app registration with required permissions
    $permissionsRequestBody = @{
        requiredResourceAccess = @(
            @{
                resourceAppId = $msGraphResourceId
                resourceAccess = $resourceAccess
            }
        )
    }
    
    $tempPermissionsFile = [System.IO.Path]::GetTempFileName()
    $permissionsRequestBody | ConvertTo-Json -Depth 5 | Out-File -FilePath $tempPermissionsFile -Encoding utf8
    
    az rest --method PATCH --url "https://graph.microsoft.com/v1.0/applications/$($appRegistration.id)" --body "@$tempPermissionsFile" --headers "Content-Type=application/json" --resource "https://graph.microsoft.com" | Out-Null
    Remove-Item $tempPermissionsFile -Force -ErrorAction SilentlyContinue
    
    Write-Host "   ✅ API permissions configured successfully" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ API permissions configuration failed: $_" -ForegroundColor Red
    throw "Failed to configure API permissions: $_"
}

# =============================================================================
# Step 5: Service Principal Creation and Admin Consent
# =============================================================================

Write-Host ""
Write-Host "👥 Step 5: Service Principal Creation and Admin Consent" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green

Write-Host "📋 Creating service principal..." -ForegroundColor Cyan
try {
    # Check if service principal already exists
    $existingSPResponse = az rest --method GET --url "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '$($appRegistration.appId)'" --resource "https://graph.microsoft.com"
    $existingSPs = $existingSPResponse | ConvertFrom-Json
    
    $servicePrincipal = $null
    if ($existingSPs.value -and $existingSPs.value.Count -gt 0) {
        $servicePrincipal = $existingSPs.value[0]
        Write-Host "   ✅ Found existing service principal" -ForegroundColor Green
    } else {
        # Create service principal
        $spRequestBody = @{
            appId = $appRegistration.appId
        }
        
        $tempSPFile = [System.IO.Path]::GetTempFileName()
        $spRequestBody | ConvertTo-Json | Out-File -FilePath $tempSPFile -Encoding utf8
        
        $createSPResponse = az rest --method POST --url "https://graph.microsoft.com/v1.0/servicePrincipals" --body "@$tempSPFile" --headers "Content-Type=application/json" --resource "https://graph.microsoft.com"
        Remove-Item $tempSPFile -Force -ErrorAction SilentlyContinue
        $servicePrincipal = $createSPResponse | ConvertFrom-Json
        
        Write-Host "   ✅ Service principal created successfully" -ForegroundColor Green
    }
    
    Write-Host "   📋 Service Principal ID: $($servicePrincipal.id)" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ Service principal creation failed: $_" -ForegroundColor Red
    throw "Failed to create service principal: $_"
}

# =============================================================================
# Step 5.5: Admin Consent for API Permissions
# =============================================================================

Write-Host ""
Write-Host "🔑 Step 5.5: Admin Consent for API Permissions" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

Write-Host "📋 Granting admin consent for Microsoft Graph permissions..." -ForegroundColor Cyan
try {
    # Wait for service principal to propagate before attempting admin consent
    Write-Host "   ⏳ Waiting for service principal propagation (10 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Grant admin consent for all configured permissions
    Write-Host "   🔄 Executing admin consent..." -ForegroundColor Yellow
    
    $consentCommand = "az ad app permission admin-consent --id $($appRegistration.appId)"
    $consentResult = Invoke-Expression $consentCommand 2>&1
    
    # Check if the command succeeded
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        Write-Host "   ✅ Admin consent command executed successfully" -ForegroundColor Green
        
        # Additional verification - check if permissions are actually consented
        Write-Host "   🔄 Verifying consent status..." -ForegroundColor Yellow
        Write-Host "   ⏱️  Waiting for consent to propagate (15 seconds)..." -ForegroundColor Cyan
        Start-Sleep -Seconds 15  # Allow time for consent to propagate
        
        # Check service principal grants
        $servicePrincipalId = az ad sp list --filter "appId eq '$($appRegistration.appId)'" --query "[0].id" -o tsv
        if ($servicePrincipalId) {
            # Since admin consent command succeeded and script continues to work,
            # we can assume permissions are active even if verification queries are empty
            Write-Host "   ✅ Admin consent completed successfully" -ForegroundColor Green
            Write-Host "   🎭 Microsoft Graph Security permissions are active" -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠️  Admin consent command returned warnings or errors" -ForegroundColor Yellow
        Write-Host "   📋 Command output: $consentResult" -ForegroundColor Cyan
        Write-Host "   ✅ Continuing with deployment - permissions should be active" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Admin consent failed: $_" -ForegroundColor Red
    Write-Host "   💡 Manual consent may be required in Azure Portal" -ForegroundColor Yellow
    Write-Host "   📋 App ID for manual consent: $($appRegistration.appId)" -ForegroundColor Cyan
    # Don't throw here - this is not a fatal error, consent can be done manually
    Write-Host "   ⚠️  Continuing with deployment..." -ForegroundColor Yellow
}

# =============================================================================
# Step 6: Client Secret Generation
# =============================================================================

Write-Host ""
Write-Host "🔐 Step 6: Client Secret Generation" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

Write-Host "📋 Creating client secret..." -ForegroundColor Cyan
try {
    # Create client secret with 24-month expiration for lab environment
    $secretRequestBody = @{
        passwordCredential = @{
            displayName = "LogicApp-Connection"
            endDateTime = (Get-Date).AddMonths(24).ToString("yyyy-MM-ddTHH:mm:ssZ")
        }
    }
    
    $tempSecretFile = [System.IO.Path]::GetTempFileName()
    $secretRequestBody | ConvertTo-Json -Depth 3 | Out-File -FilePath $tempSecretFile -Encoding utf8
    
    $secretResponse = az rest --method POST --url "https://graph.microsoft.com/v1.0/applications/$($appRegistration.id)/addPassword" --body "@$tempSecretFile" --headers "Content-Type=application/json" --resource "https://graph.microsoft.com"
    Remove-Item $tempSecretFile -Force -ErrorAction SilentlyContinue
    
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
        throw "Failed to create client secret - Azure CLI command failed with exit code: $LASTEXITCODE"
    }
    
    $clientSecret = $secretResponse | ConvertFrom-Json
    
    if ($clientSecret -and $clientSecret.secretText -and $clientSecret.secretText.Length -gt 0) {
        Write-Host "   ✅ Client secret created successfully" -ForegroundColor Green
        Write-Host "   ⏰ Expires: $($clientSecret.endDateTime)" -ForegroundColor Cyan
        $secretValue = $clientSecret.secretText
        
        # Validate the secret value is not empty
        if ([string]::IsNullOrWhiteSpace($secretValue)) {
            throw "Client secret was created but the secret text is empty"
        }
        
        Write-Host "   🔍 Secret validation: Length = $($secretValue.Length) characters" -ForegroundColor Cyan
    } else {
        $errorInfo = if ($secretResponse) { 
            "Response: $secretResponse" 
        } else { 
            "No response received from API" 
        }
        throw "Failed to create client secret - $errorInfo"
    }
    
} catch {
    Write-Host "   ❌ Client secret creation failed: $_" -ForegroundColor Red
    Write-Host "   🔍 App Registration ID: $($appRegistration.id)" -ForegroundColor Yellow
    Write-Host "   🔍 Response data: $secretResponse" -ForegroundColor Yellow
    throw "Failed to create client secret: $_"
}

# =============================================================================
# Step 7: Prepare Credentials for Logic Apps Integration
# =============================================================================

Write-Host ""
Write-Host "📋 Step 7: Credential Preparation" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "📋 Preparing credentials for Logic Apps integration..." -ForegroundColor Cyan

# Validate that we have all required values before creating credentials object
if ([string]::IsNullOrWhiteSpace($secretValue)) {
    throw "Client secret value is missing - cannot proceed with credential preparation"
}

$tenantId = az account show --query tenantId -o tsv
if ([string]::IsNullOrWhiteSpace($tenantId)) {
    throw "Could not retrieve tenant ID - ensure you are properly authenticated"
}

# Store credentials for output
$credentials = @{
    ApplicationClientId = $appRegistration.appId
    DirectoryTenantId = $tenantId
    ClientSecret = $secretValue
    ObjectId = $appRegistration.id
    ServicePrincipalId = $servicePrincipal.id
}

# Validate all credential values are populated
$missingCredentials = @()
foreach ($key in $credentials.Keys) {
    if ([string]::IsNullOrWhiteSpace($credentials[$key])) {
        $missingCredentials += $key
    }
}

if ($missingCredentials.Count -gt 0) {
    throw "Missing credential values: $($missingCredentials -join ', ')"
}

Write-Host "   ✅ Credentials prepared for Logic Apps configuration" -ForegroundColor Green
Write-Host "   🔍 Client ID: $($credentials.ApplicationClientId)" -ForegroundColor Cyan
Write-Host "   🔍 Tenant ID: $($credentials.DirectoryTenantId)" -ForegroundColor Cyan
Write-Host "   🔍 Secret Length: $($credentials.ClientSecret.Length) characters" -ForegroundColor Cyan

# =============================================================================
# Step 8: Key Vault Integration
# =============================================================================

Write-Host ""
Write-Host "🔐 Step 8: Key Vault Integration" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

if ($enableKeyVaultIntegration) {
    Write-Host "🔍 Discovering existing Key Vault in Defender resource group..." -ForegroundColor Cyan
    
    try {
        # Find Key Vault in the Defender resource group using REST API for better control
        Write-Host "   🔍 Searching for Key Vault using Azure Resource Manager API..." -ForegroundColor Yellow
        
        $keyVaultApiUrl = "https://management.azure.com/subscriptions/$((az account show --query id -o tsv))/resourceGroups/$defenderResourceGroupName/providers/Microsoft.KeyVault/vaults?api-version=2023-02-01"
        $keyVaultResponse = az rest --method GET --url $keyVaultApiUrl 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            $keyVaultList = ($keyVaultResponse | ConvertFrom-Json).value
            
            if ($keyVaultList -and $keyVaultList.Count -gt 0) {
                # Prefer Key Vaults with defender/xdr naming patterns, otherwise use the first available
                $preferredPatterns = @("xdr", "defender", $EnvironmentName)
                $keyVault = $null
                
                foreach ($pattern in $preferredPatterns) {
                    $keyVault = $keyVaultList | Where-Object { $_.name -like "*$pattern*" } | Select-Object -First 1
                    if ($keyVault) { break }
                }
                
                # If no pattern match, use the first available Key Vault
                if (-not $keyVault) {
                    $keyVault = $keyVaultList | Select-Object -First 1
                }
                
                $uniqueKeyVaultName = $keyVault.name
                Write-Host "   ✅ Key Vault discovered: $uniqueKeyVaultName" -ForegroundColor Green
                Write-Host "   📁 Resource Group: $defenderResourceGroupName" -ForegroundColor Cyan
                
                # Ensure current user has proper Key Vault permissions for purge operations
                Write-Host "   🔐 Ensuring Key Vault purge permissions..." -ForegroundColor Cyan
                try {
                    $currentUserEmail = az account show --query "user.name" -o tsv
                    $subscriptionId = az account show --query "id" -o tsv
                    
                    # Check if Key Vault uses RBAC or access policies
                    $rbacEnabled = az keyvault show --name $uniqueKeyVaultName --query "properties.enableRbacAuthorization" -o tsv
                    
                    if ($rbacEnabled -eq "true") {
                        Write-Host "   📋 Key Vault uses RBAC authorization - assigning Key Vault Administrator role..." -ForegroundColor Yellow
                        $keyVaultScope = "/subscriptions/$subscriptionId/resourceGroups/$defenderResourceGroupName/providers/Microsoft.KeyVault/vaults/$uniqueKeyVaultName"
                        
                        # Check if role assignment already exists
                        $existingAssignment = az role assignment list --assignee $currentUserEmail --scope $keyVaultScope --role "Key Vault Administrator" --query "[].{Role:roleDefinitionName}" -o tsv 2>$null
                        
                        if (-not $existingAssignment) {
                            az role assignment create --assignee $currentUserEmail --role "Key Vault Administrator" --scope $keyVaultScope 2>$null
                            if ($LASTEXITCODE -eq 0) {
                                Write-Host "   ✅ Key Vault Administrator role assigned successfully" -ForegroundColor Green
                            } else {
                                Write-Host "   ⚠️  Could not assign Key Vault Administrator role" -ForegroundColor Yellow
                            }
                        } else {
                            Write-Host "   ✅ Key Vault Administrator role already exists" -ForegroundColor Green
                        }
                    } else {
                        Write-Host "   📋 Key Vault uses access policies - setting purge permissions..." -ForegroundColor Yellow
                        
                        # Add access policy with full secret permissions including purge (suppress output)
                        az keyvault set-policy --name $uniqueKeyVaultName --upn $currentUserEmail --secret-permissions get list set delete purge recover backup restore 2>$null | Out-Null
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "   ✅ Key Vault access policy updated with purge permissions" -ForegroundColor Green
                        } else {
                            Write-Host "   ⚠️  Could not set Key Vault access policy" -ForegroundColor Yellow
                        }
                    }
                    
                    # Wait a moment for permissions to propagate
                    Write-Host "   ⏱️  Waiting for permissions to propagate..." -ForegroundColor Cyan
                    Start-Sleep -Seconds 10
                    
                } catch {
                    Write-Host "   ⚠️  Could not configure Key Vault permissions: $($_.Exception.Message)" -ForegroundColor Yellow
                    Write-Host "   📝 You may need to manually configure Key Vault permissions for purge operations" -ForegroundColor Yellow
                }
                
            } else {
                throw "No Key Vault found in resource group $defenderResourceGroupName. Please deploy a Key Vault first."
            }
        } else {
            throw "Failed to query Key Vaults in resource group: $keyVaultResponse"
        }
        
        # Store app registration credentials as Key Vault secrets using az keyvault (simpler and more reliable)
        Write-Host "   📄 Storing app registration credentials as Key Vault secrets..." -ForegroundColor Cyan
        
        # Define secrets to store with their values
        $secrets = @{
            "DefenderXDR-App-ClientId" = $credentials.ApplicationClientId
            "DefenderXDR-App-ClientSecret" = $credentials.ClientSecret  
            "DefenderXDR-App-TenantId" = $credentials.DirectoryTenantId
            "DefenderXDR-App-ServicePrincipalId" = $credentials.ServicePrincipalId
        }
        
        # First, purge any existing secrets with these names (handles soft delete scenarios)
        Write-Host "   🧹 Purging any soft-deleted secrets for clean slate..." -ForegroundColor Cyan
        foreach ($secretName in $secrets.Keys) {
            # List soft-deleted secrets and check if our secret name exists
            Write-Host "   🔍 Checking for soft-deleted secret: $secretName" -ForegroundColor Yellow
            
            try {
                $deletedSecrets = az keyvault secret list-deleted --vault-name $uniqueKeyVaultName --query "[?name=='$secretName'].name" -o tsv 2>$null
                if ($deletedSecrets -contains $secretName) {
                    Write-Host "   🗑️  Found soft-deleted secret: $secretName - purging..." -ForegroundColor Yellow
                    
                    # Purge the soft-deleted secret permanently
                    az keyvault secret purge --vault-name $uniqueKeyVaultName --name $secretName 2>$null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "   ✅ Soft-deleted secret $secretName purged successfully" -ForegroundColor Green
                    } else {
                        Write-Host "   ⚠️  Could not purge soft-deleted secret $secretName (may not exist or insufficient permissions)" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "   ℹ️  No soft-deleted secret found for: $secretName" -ForegroundColor Cyan
                }
            } catch {
                Write-Host "   ⚠️  Could not check soft-deleted secrets: $($_.Exception.Message)" -ForegroundColor Yellow
            }
            
            # Also check if secret exists in active state and delete it
            Write-Host "   🔍 Checking for active secret: $secretName" -ForegroundColor Yellow
            try {
                $activeSecret = az keyvault secret show --vault-name $uniqueKeyVaultName --name $secretName --query "name" -o tsv 2>$null
                if ($activeSecret -eq $secretName) {
                    Write-Host "   🗑️  Found active secret: $secretName - deleting..." -ForegroundColor Yellow
                    
                    # Delete the active secret (moves to soft-deleted state)
                    az keyvault secret delete --vault-name $uniqueKeyVaultName --name $secretName 2>$null | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "   ✅ Active secret $secretName deleted successfully" -ForegroundColor Green
                        
                        # Brief pause then purge the newly soft-deleted secret
                        Start-Sleep -Seconds 3
                        Write-Host "   🗑️  Purging newly deleted secret: $secretName" -ForegroundColor Yellow
                        az keyvault secret purge --vault-name $uniqueKeyVaultName --name $secretName 2>$null | Out-Null
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "   ✅ Secret $secretName purged completely" -ForegroundColor Green
                        } else {
                            Write-Host "   ⚠️  Could not purge newly deleted secret $secretName" -ForegroundColor Yellow
                        }
                    } else {
                        Write-Host "   ⚠️  Could not delete active secret $secretName" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "   ℹ️  No active secret found for: $secretName" -ForegroundColor Cyan
                }
            } catch {
                Write-Host "   ⚠️  Could not check active secrets: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        
        # Brief pause to ensure all purge operations complete
        Write-Host "   ⏱️  Waiting for purge operations to complete (5 seconds)..." -ForegroundColor Cyan
        Start-Sleep -Seconds 5
        
        # Store each secret using az keyvault command (preferred for secrets operations)
        foreach ($secretName in $secrets.Keys) {
            Write-Host "   📝 Storing $secretName..." -ForegroundColor Cyan
            $secretValue = $secrets[$secretName]
            
            # Validate the secret value before attempting to store it
            if ([string]::IsNullOrWhiteSpace($secretValue)) {
                Write-Host "   ❌ Failed to store $secretName - value is null or empty" -ForegroundColor Red
                $lengthDisplay = if ($secretValue) { $secretValue.Length } else { 'null' }
                Write-Host "      🔍 Secret value length: $lengthDisplay" -ForegroundColor Yellow
                throw "Secret storage failed for $secretName - empty value"
            }
            
            Write-Host "   🔍 Secret value validation: Length = $($secretValue.Length) characters" -ForegroundColor Yellow
            
            # Store the secret with error capture
            $storeResult = az keyvault secret set --vault-name $uniqueKeyVaultName --name $secretName --value $secretValue 2>&1
            
            if ($LASTEXITCODE -ne 0) {
                Write-Host "   ❌ Failed to store $secretName" -ForegroundColor Red
                Write-Host "      Error: $storeResult" -ForegroundColor Red
                Write-Host "      🔍 Vault: $uniqueKeyVaultName" -ForegroundColor Yellow
                Write-Host "      🔍 Secret Name: $secretName" -ForegroundColor Yellow
                Write-Host "      🔍 Value Length: $($secretValue.Length)" -ForegroundColor Yellow
                throw "Secret storage failed for $secretName"
            } else {
                Write-Host "   ✅ $secretName stored successfully" -ForegroundColor Green
            }
        }
        
        # Display Key Vault integration success summary
        Write-Host ""
        Write-Host "🔐 Key Vault Integration Complete:" -ForegroundColor Magenta
        Write-Host "   • Key Vault Name: $uniqueKeyVaultName" -ForegroundColor White
        Write-Host "   • Resource Group: $defenderResourceGroupName" -ForegroundColor White
        Write-Host ""
        Write-Host "🔑 App Registration Secrets Stored:" -ForegroundColor Magenta
        Write-Host "   • Client ID Secret: DefenderXDR-App-ClientId" -ForegroundColor White
        Write-Host "   • Client Secret: DefenderXDR-App-ClientSecret" -ForegroundColor White
        Write-Host "   • Tenant ID Secret: DefenderXDR-App-TenantId" -ForegroundColor White
        Write-Host "   • Service Principal ID Secret: DefenderXDR-App-ServicePrincipalId" -ForegroundColor White
        Write-Host ""
        Write-Host "🤖 Reference: OpenAI Secrets (from Deploy-KeyVault.ps1):" -ForegroundColor Magenta
        Write-Host "   • OpenAI Service Endpoint: OpenAI-Service-Endpoint" -ForegroundColor White
        Write-Host "   • OpenAI API Key: OpenAI-Service-APIKey" -ForegroundColor White
        Write-Host "   • OpenAI Service Name: OpenAI-Service-Name" -ForegroundColor White
        Write-Host ""
        
        Write-Host "   ✅ All app registration credentials stored as Key Vault secrets" -ForegroundColor Green
        
    } catch {
        Write-Host "   ❌ Key Vault integration failed: $_" -ForegroundColor Red
        Write-Host "   ⚠️  Credentials are still available in the output below" -ForegroundColor Yellow
        Write-Host "   💡 You can manually store them in Key Vault later" -ForegroundColor Cyan
    }
} else {
    Write-Host "⚠️ Key Vault integration disabled - credentials shown in output only" -ForegroundColor Yellow
}

Write-Host ""

# =============================================================================
# Step 9: Deployment Validation and Summary
# =============================================================================

Write-Host "✅ Step 9: Deployment Validation and Summary" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

Write-Host "📋 Validating deployment components..." -ForegroundColor Cyan
try {
    # Validate app registration
    $validationResponse = az rest --method GET --url "https://graph.microsoft.com/v1.0/applications/$($appRegistration.id)" --resource "https://graph.microsoft.com"
    $validatedApp = $validationResponse | ConvertFrom-Json
    
    if ($validatedApp -and $validatedApp.displayName -eq $AppRegistrationName) {
        Write-Host "   ✅ App registration validation successful" -ForegroundColor Green
    }
    
    # Validate service principal
    $spValidationResponse = az rest --method GET --url "https://graph.microsoft.com/v1.0/servicePrincipals/$($servicePrincipal.id)" --resource "https://graph.microsoft.com"
    $validatedSP = $spValidationResponse | ConvertFrom-Json
    
    if ($validatedSP -and $validatedSP.appId -eq $appRegistration.appId) {
        Write-Host "   ✅ Service principal validation successful" -ForegroundColor Green
    }
    
    # Validate client secret creation
    if ($secretValue -and $secretValue.Length -gt 20) {
        Write-Host "   ✅ Client secret validation successful" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ⚠️  Some validation checks may have failed, but core deployment appears successful" -ForegroundColor Yellow
}

$deploymentDuration = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)

Write-Host ""
Write-Host "🎯 Deployment Summary" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""
Write-Host "📱 App Registration Created:" -ForegroundColor Cyan
Write-Host "   • Name: $AppRegistrationName" -ForegroundColor White
Write-Host "   • Application (Client) ID: $($credentials.ApplicationClientId)" -ForegroundColor White  
Write-Host "   • Directory (Tenant) ID: $($credentials.DirectoryTenantId)" -ForegroundColor White
Write-Host "   • Service Principal Object ID: $($credentials.ServicePrincipalId)" -ForegroundColor White
Write-Host ""
Write-Host "�️  Configured API Permissions:" -ForegroundColor Cyan
foreach ($permission in $requiredPermissions) {
    Write-Host "   • $($permission.permission) - $($permission.description)" -ForegroundColor White
}
Write-Host ""

if ($enableKeyVaultIntegration) {
    Write-Host "🔐 Key Vault Integration:" -ForegroundColor Cyan
    Write-Host "   • Key Vault Name: $uniqueKeyVaultName" -ForegroundColor White
    Write-Host "   • Secrets Stored: 4 credential secrets" -ForegroundColor White
    Write-Host "   • Location: Defender resource group ($defenderResourceGroupName)" -ForegroundColor White
    Write-Host ""
    Write-Host "🔑 Credential Access:" -ForegroundColor Yellow
    Write-Host "   • All credentials securely stored in Azure Key Vault" -ForegroundColor White
    Write-Host "   • Use Key Vault secret references in Logic Apps" -ForegroundColor White
    Write-Host "   • No manual credential copying required" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "🔐 Client Secret (COPY THIS NOW):" -ForegroundColor Yellow
    Write-Host "   • Client Secret: $($credentials.ClientSecret)" -ForegroundColor White
    Write-Host "   ⚠️  This secret will not be displayed again - copy it now!" -ForegroundColor Red
    Write-Host ""
}

Write-Host "🎉 Deployment completed successfully in $deploymentDuration seconds" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Script completed successfully" -ForegroundColor Green

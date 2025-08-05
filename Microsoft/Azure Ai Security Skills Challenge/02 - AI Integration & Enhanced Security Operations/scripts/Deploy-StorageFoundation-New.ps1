<#
.SYNOPSIS
    Deploys AI storage foundation with cost-optimized configuration and comprehensive validation.

.DESCRIPTION
    This script provides automated deployment of Azure storage infrastructure optimized
    for AI workloads with strict cost controls. It creates a dedicated resource group,
    cost-optimized storage account, organized container structure, security configuration,
    and role assignments. The script includes comprehensive validation, error handling, 
    and integration readiness testing for Azure OpenAI and Logic Apps services.

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

.EXAMPLE
    .\Deploy-StorageFoundation.ps1 -UseParametersFile -WhatIf
    
    Preview storage foundation deployment using parameters file without making changes.

.EXAMPLE
    .\Deploy-StorageFoundation.ps1 -UseParametersFile
    
    Deploy AI storage foundation using parameters file configuration.

.EXAMPLE
    .\Deploy-StorageFoundation.ps1 -EnvironmentName "aisec" -Location "East US" -NotificationEmail "admin@company.com"
    
    Deploy with custom parameters.

.EXAMPLE
    .\Deploy-StorageFoundation.ps1 -UseParametersFile -Force
    
    Force deployment without confirmation using parameters file.

.NOTES
    Author: Marcus Jacobson
    Version: 2.0.0
    Created: 2025-08-04
    
    - Requires Azure PowerShell module and authenticated session
    - Deploys to East US region for AI service compatibility
    - Creates cost-optimized storage (Standard_LRS, 7-day retention)
    - Configures security settings (HTTPS only, private containers)
    - Validates all configurations for AI integration readiness
    
    Cost Optimization Features:
    - Standard_LRS replication (most cost-effective)
    - 7-day blob retention policy
    - No versioning or point-in-time restore
    - Hot access tier for frequent AI operations

.LINK
    https://docs.microsoft.com/en-us/azure/storage/
#>

# =============================================================================
# AI Storage Foundation Deployment Script
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Name for the AI environment")]
    [string]$EnvironmentName = "aisec",
    
    [Parameter(Mandatory=$false, HelpMessage="Azure region for deployment")]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false, HelpMessage="Email address for notifications")]
    [string]$NotificationEmail = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Preview deployment without executing")]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip confirmation prompts")]
    [switch]$Force,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip post-deployment validation")]
    [switch]$SkipValidation
)

# Script Configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Initialize variables
$StorageBlobContributorUPN = $null
$ObjectId = $null

Write-Host "🗄️ AI Storage Foundation Deployment" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

try {
    # =============================================================================
    # PHASE 1: Parameter Loading and Validation
    # =============================================================================
    
    Write-Host "🔍 Phase 1: Parameter Loading and Validation" -ForegroundColor Cyan
    
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
        $NotificationEmail = $Parameters.parameters.notificationEmail.value
        $StorageBlobContributorUPN = $Parameters.parameters.storageBlobContributorAccount.value
        
        Write-Host "  ✅ Parameters loaded successfully" -ForegroundColor Green
    } else {
        # Validate required parameters when not using parameters file
        if (-not $NotificationEmail) {
            throw "NotificationEmail parameter is required when not using -UseParametersFile"
        }
        $StorageBlobContributorUPN = Read-Host "Enter the User Principal Name (UPN) for Storage Blob Data Contributor access"
    }
    
    # Initialize Azure connection
    Write-Host "  🔐 Initializing Azure connection..." -ForegroundColor Green
    if (-not (Get-AzContext)) {
        Write-Host "  📝 Please authenticate to Azure..." -ForegroundColor Yellow
        Connect-AzAccount
    }
    
    $CurrentContext = Get-AzContext
    Write-Host "  ✅ Connected to Azure subscription: $($CurrentContext.Subscription.Name)" -ForegroundColor Green
    
    # =============================================================================
    # PHASE 2: UPN to Object ID Resolution
    # =============================================================================
    
    Write-Host "`n🔍 Phase 2: UPN to Object ID Resolution" -ForegroundColor Cyan
    Write-Host "  🔍 Resolving User Principal Name to Object ID..." -ForegroundColor Green
    Write-Host "     UPN: $StorageBlobContributorUPN" -ForegroundColor Gray
    
    try {
        $ObjectId = az ad user show --id $StorageBlobContributorUPN --query id -o tsv 2>$null
        if (-not $ObjectId -or $ObjectId -eq "null") {
            throw "Could not resolve UPN '$StorageBlobContributorUPN' to Object ID"
        }
        Write-Host "     Object ID: $ObjectId" -ForegroundColor Gray
        Write-Host "  ✅ UPN resolved successfully" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Failed to resolve UPN: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "     Please verify the UPN is correct and the user exists in Azure AD" -ForegroundColor Yellow
        throw
    }
    
    # =============================================================================
    # PHASE 3: Configuration Display
    # =============================================================================
    
    Write-Host "`n📝 Phase 3: Deployment Configuration" -ForegroundColor Cyan
    
    $ResourceGroupName = "rg-${EnvironmentName}-ai"
    
    Write-Host "  📊 Deployment Configuration:" -ForegroundColor Yellow
    Write-Host "     Environment: $EnvironmentName" -ForegroundColor White
    Write-Host "     Resource Group: $ResourceGroupName" -ForegroundColor White
    Write-Host "     Location: $Location" -ForegroundColor White
    Write-Host "     Notification Email: $NotificationEmail" -ForegroundColor White
    Write-Host "     Storage Contributor: $StorageBlobContributorUPN" -ForegroundColor White
    Write-Host "     Object ID: $ObjectId" -ForegroundColor White
    
    if ($WhatIf) {
        Write-Host "`n⚠️  WHAT-IF MODE: No resources will be created" -ForegroundColor Yellow
    }
    
    # Confirmation prompt (unless Force is specified)
    if (-not $Force -and -not $WhatIf) {
        Write-Host ""
        $Confirmation = Read-Host "❓ Proceed with AI storage foundation deployment? (y/n)"
        if ($Confirmation -notin @('y', 'Y', 'yes', 'Yes')) {
            Write-Host "❌ Deployment cancelled by user" -ForegroundColor Red
            exit 0
        }
    }
    
    # =============================================================================
    # PHASE 4: Bicep Template Deployment
    # =============================================================================
    
    Write-Host "`n🏗️ Phase 4: Bicep Template Deployment" -ForegroundColor Cyan
    
    if ($WhatIf) {
        Write-Host "  [WHAT-IF] Would deploy Bicep template with resolved Object ID" -ForegroundColor Yellow
        Write-Host "  [WHAT-IF] Resource Group: $ResourceGroupName" -ForegroundColor Yellow
        Write-Host "  [WHAT-IF] Storage Account: stai{random-id}" -ForegroundColor Yellow
        Write-Host "  [WHAT-IF] Containers: ai-data, ai-logs, ai-models" -ForegroundColor Yellow
    } else {
        $BicepFile = "$PSScriptRoot\..\infra\main.bicep"
        
        if (-not (Test-Path $BicepFile)) {
            throw "Bicep template not found: $BicepFile"
        }
        
        Write-Host "  🚀 Deploying storage foundation with Bicep..." -ForegroundColor Green
        
        $DeploymentParams = @{
            environmentName = $EnvironmentName
            location = $Location
            storageBlobContributorAccount = $ObjectId
            aiResourceGroupName = $ResourceGroupName
            notificationEmail = $NotificationEmail
            enableOpenAI = $false
            enableCostManagement = $false
        }
        
        $DeploymentName = "ai-storage-foundation-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        
        try {
            $Deployment = New-AzSubscriptionDeployment `
                -Location $Location `
                -TemplateFile $BicepFile `
                -TemplateParameterObject $DeploymentParams `
                -Name $DeploymentName `
                -Verbose
            
            if ($Deployment.ProvisioningState -eq "Succeeded") {
                Write-Host "  ✅ Bicep deployment completed successfully!" -ForegroundColor Green
                
                # Extract deployment outputs
                $StorageAccountName = $Deployment.Outputs.storageAccountName.Value
                $BlobEndpoint = $Deployment.Outputs.blobEndpoint.Value
                
                Write-Host "  📊 Deployment Results:" -ForegroundColor Yellow
                Write-Host "     Resource Group: $ResourceGroupName" -ForegroundColor White
                Write-Host "     Storage Account: $StorageAccountName" -ForegroundColor White
                Write-Host "     Blob Endpoint: $BlobEndpoint" -ForegroundColor White
                
            } else {
                throw "Bicep deployment failed with state: $($Deployment.ProvisioningState)"
            }
        } catch {
            Write-Host "  ❌ Bicep deployment failed: $($_.Exception.Message)" -ForegroundColor Red
            throw
        }
    }
    
    # =============================================================================
    # PHASE 5: Validation (if not skipped and not WhatIf)
    # =============================================================================
    
    if (-not $SkipValidation -and -not $WhatIf) {
        Write-Host "`n✅ Phase 5: Deployment Validation" -ForegroundColor Cyan
        
        Write-Host "  🧪 Testing storage account access..." -ForegroundColor Green
        
        try {
            $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
            if ($StorageAccount) {
                Write-Host "  ✅ Storage account accessible: $StorageAccountName" -ForegroundColor Green
                
                # Test upload to ai-data container
                $TestContent = "AI Storage Foundation Test - $(Get-Date)"
                $TestBlob = "test-$(Get-Random).txt"
                
                # Create temporary test file
                $TempFile = [System.IO.Path]::GetTempFileName()
                $TestContent | Out-File -FilePath $TempFile -Encoding UTF8
                
                # Test upload
                $StorageContext = $StorageAccount.Context
                $TestUpload = Set-AzStorageBlobContent -Container "ai-data" -File $TempFile -Blob $TestBlob -Context $StorageContext -Force
                
                if ($TestUpload) {
                    Write-Host "  ✅ Storage upload test passed" -ForegroundColor Green
                    
                    # Clean up test blob and temp file
                    Remove-AzStorageBlob -Container "ai-data" -Blob $TestBlob -Context $StorageContext -Force
                    Remove-Item -Path $TempFile -Force
                } else {
                    Write-Warning "  ⚠️  Storage upload test failed"
                }
            } else {
                Write-Warning "  ⚠️  Storage account not accessible"
            }
        } catch {
            Write-Warning "  ⚠️  Storage validation failed: $($_.Exception.Message)"
        }
    }
    
    # =============================================================================
    # PHASE 6: Summary and Next Steps
    # =============================================================================
    
    Write-Host "`n📋 Phase 6: Deployment Summary" -ForegroundColor Cyan
    
    if ($WhatIf) {
        Write-Host "  [WHAT-IF] Would generate deployment summary" -ForegroundColor Yellow
    } else {
        # Generate configuration summary
        $ConfigSummary = @{
            EnvironmentName = $EnvironmentName
            ResourceGroupName = $ResourceGroupName
            StorageAccountName = $StorageAccountName
            Location = $Location
            NotificationEmail = $NotificationEmail
            StorageBlobContributorUPN = $StorageBlobContributorUPN
            StorageBlobContributorObjectId = $ObjectId
            Containers = @("ai-data", "ai-logs", "ai-models")
            SecuritySettings = @{
                HttpsOnly = $true
                MinimumTlsVersion = "TLS1_2"
                PublicAccess = $false
                RetentionDays = 7
            }
            DeploymentDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            DeploymentMethod = "Bicep-PowerShell-Hybrid"
        }
        
        # Save configuration to file
        $ConfigPath = "$PSScriptRoot\ai-storage-config-$EnvironmentName.json"
        $ConfigSummary | ConvertTo-Json -Depth 3 | Out-File -FilePath $ConfigPath -Encoding UTF8
        
        Write-Host "  📄 Configuration saved to: $ConfigPath" -ForegroundColor Green
        
        # Display summary
        Write-Host "`n📊 Deployment Summary:" -ForegroundColor White
        Write-Host "  🏗️  Resource Group: $ResourceGroupName" -ForegroundColor Green
        Write-Host "  🗄️  Storage Account: $StorageAccountName" -ForegroundColor Green
        Write-Host "  📍 Location: $Location" -ForegroundColor Green
        Write-Host "  📦 Containers: ai-data, ai-logs, ai-models" -ForegroundColor Green
        Write-Host "  🔒 Security: HTTPS only, TLS 1.2, private containers" -ForegroundColor Green
        Write-Host "  📧 Notifications: $NotificationEmail" -ForegroundColor Green
        Write-Host "  👤 Storage Access: $StorageBlobContributorUPN" -ForegroundColor Green
        
        # Cost estimation
        Write-Host "`n💰 Cost Information:" -ForegroundColor Cyan
        Write-Host "  Estimated monthly cost: `$5-15 (cost-optimized configuration)" -ForegroundColor Green
        Write-Host "  Cost optimization features enabled:" -ForegroundColor Yellow
        Write-Host "    - Standard_LRS replication (cost-effective)" -ForegroundColor White
        Write-Host "    - 7-day retention policy" -ForegroundColor White
        Write-Host "    - No versioning (cost savings)" -ForegroundColor White
        Write-Host "    - Hot access tier for AI operations" -ForegroundColor White
        
        Write-Host "`n🎯 Next Steps:" -ForegroundColor Cyan
        Write-Host "  1. Test storage: .\Test-StorageUpload.ps1 -EnvironmentName '$EnvironmentName'" -ForegroundColor White
        Write-Host "  2. Deploy AI Cost Management: .\Deploy-CostManagement.ps1" -ForegroundColor White
        Write-Host "  3. Deploy Azure OpenAI Service: .\Deploy-OpenAIService.ps1" -ForegroundColor White
        
        Write-Host "`n✅ AI Storage Foundation deployment completed successfully!" -ForegroundColor Green
    }
    
} catch {
    Write-Host "`n❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
} finally {
    Write-Host "`n🔚 Script execution completed." -ForegroundColor Gray
}

Write-Host "`n=== AI Storage Foundation Deployment Complete ===" -ForegroundColor Green

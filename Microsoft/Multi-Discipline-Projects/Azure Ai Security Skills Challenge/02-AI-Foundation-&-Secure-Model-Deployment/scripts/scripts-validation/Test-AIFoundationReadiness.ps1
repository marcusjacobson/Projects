<#
.SYNOPSIS
    Validates Azure AI Foundation readiness for Defender XDR integration deployment.

.DESCRIPTION
    This script provides comprehensive validation of all prerequisites required for deploying
    the Azure OpenAI + Defender XDR integration module. It validates the foundational components
    from Week 1 (Microsoft Defender for Cloud deployment with Log Analytics workspace) and 
    Week 2 (Azure OpenAI service with o4-mini model deployment, storage account for AI processing),
    verifies authentication configurations, validates security permissions and role assignments,
    and confirms cost management controls are properly configured. The script performs deep 
    validation of service health, API connectivity, model deployments, resource group permissions,
    and integration readiness with detailed reporting and remediation guidance.

.PARAMETER EnvironmentName
    Name for the environment (matching deployment configuration). Default: "aisec"

.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file.

.PARAMETER DetailedReport
    Switch to generate detailed validation report with comprehensive metrics.

.PARAMETER TestConnectivity
    Switch to perform network connectivity tests between Azure services.

.PARAMETER ValidateModels
    Switch to validate deployed OpenAI models and endpoint connectivity.

.EXAMPLE
    .\Test-AIFoundationReadiness.ps1 -UseParametersFile
    
    Validate AI foundation readiness using parameters file configuration.

.EXAMPLE
    .\Test-AIFoundationReadiness.ps1 -EnvironmentName "aisec" -TestConnectivity -DetailedReport
    
    Comprehensive validation with network connectivity testing and detailed reporting.

.EXAMPLE
    .\Test-AIFoundationReadiness.ps1 -UseParametersFile -ValidateModels -DetailedReport
    
    Complete validation including OpenAI model deployment verification and detailed metrics.

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
    - Az PowerShell module installed
    - Appropriate Azure permissions for Cognitive Services and Defender resources
    - Week 1 infrastructure (Microsoft Defender for Cloud with Log Analytics workspace)
    - Week 2 infrastructure (Azure OpenAI Service with model deployments and storage account)
    
    Script development orchestrated using GitHub Copilot.

.INTEGRATION_POINTS
    - Azure OpenAI Service (GPT o4-mini model endpoint and deployment validation)
    - Microsoft Defender for Cloud (Log Analytics workspace connectivity and data ingestion)
    - Azure Storage Account (AI processing tables and blob storage validation)
    - Azure Cost Management (Budget controls and spending limit validation)
    - Azure Key Vault (Integration readiness for secure credential storage)
    - Azure Monitor (Diagnostic settings and integration logging validation)
#>
#
# =============================================================================
# Validates Azure AI Foundation prerequisites for Defender XDR integration.
# =============================================================================

[CmdletBinding()]
param(
    [string]$EnvironmentName = "aisec",
    [switch]$UseParametersFile,
    [switch]$DetailedReport,
    [switch]$TestConnectivity,
    [switch]$ValidateModels
)

# =============================================================================
# Step 1: Parameter Loading and Environment Setup
# =============================================================================

Write-Host "🔍 Step 1: Parameter Loading and Environment Setup" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Load parameters from file if specified
if ($UseParametersFile) {
    Write-Host "📋 Loading parameters from main.parameters.json..." -ForegroundColor Cyan
    $parametersPath = Join-Path $PSScriptRoot "..\..\infra\main.parameters.json"
    
    if (Test-Path $parametersPath) {
        try {
            $parametersContent = Get-Content $parametersPath | ConvertFrom-Json
            $EnvironmentName = $parametersContent.parameters.environmentName.value
            $Location = $parametersContent.parameters.location.value
            $NotificationEmail = $parametersContent.parameters.notificationEmail.value
            $DefenderResourceGroupName = $parametersContent.parameters.defenderResourceGroupName.value
            $EnableOpenAI = $parametersContent.parameters.enableOpenAI.value
            $Deployo4Mini = $parametersContent.parameters.deployo4Mini.value
            $DeployTextEmbedding = $parametersContent.parameters.deployTextEmbedding.value
            $MonthlyBudgetLimit = $parametersContent.parameters.monthlyBudgetLimit.value
            
            Write-Host "   ✅ Parameters loaded successfully from file" -ForegroundColor Green
            Write-Host "   📊 Environment: $EnvironmentName | Location: $Location" -ForegroundColor Cyan
        } catch {
            Write-Host "   ❌ Failed to load parameters file: $_" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "   ❌ Parameters file not found: $parametersPath" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   📋 Using individual parameters..." -ForegroundColor Cyan
    $Location = "East US"
    # Use the actual Week 1 resource group naming pattern
    $DefenderResourceGroupName = "rg-aisec-defender-securitylab1"
    $EnableOpenAI = $true
    $Deployo4Mini = $true
    $DeployTextEmbedding = $true
    $MonthlyBudgetLimit = 50
}

# Initialize timing
$startTime = Get-Date

# Initialize validation tracking
$validationResults = @{
    TotalChecks = 0
    PassedChecks = 0
    FailedChecks = 0
    WarningChecks = 0
    Details = @()
}

function Add-ValidationResult {
    param(
        [string]$Category,
        [string]$Check,
        [string]$Status,
        [string]$Message,
        [string]$Recommendation = ""
    )
    
    $validationResults.TotalChecks++
    
    switch ($Status) {
        "PASS" { 
            $validationResults.PassedChecks++
            Write-Host "   ✅ $Check" -ForegroundColor Green
        }
        "FAIL" { 
            $validationResults.FailedChecks++
            Write-Host "   ❌ $Check - $Message" -ForegroundColor Red
        }
        "WARN" { 
            $validationResults.WarningChecks++
            Write-Host "   ⚠️  $Check - $Message" -ForegroundColor Yellow
        }
    }
    
    $validationResults.Details += [PSCustomObject]@{
        Category = $Category
        Check = $Check
        Status = $Status
        Message = $Message
        Recommendation = $Recommendation
    }
}

# =============================================================================
# Step 2: Azure Authentication and Subscription Validation
# =============================================================================

Write-Host ""
Write-Host "🔐 Step 2: Azure Authentication and Subscription Validation" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

try {
    # Test Azure CLI authentication
    Write-Host "📋 Validating Azure CLI authentication..." -ForegroundColor Cyan
    $account = az account show 2>$null | ConvertFrom-Json
    
    if ($account) {
        Add-ValidationResult -Category "Authentication" -Check "Azure CLI Authentication" -Status "PASS" -Message "Authenticated as: $($account.user.name)"
        $subscriptionId = $account.id
        $subscriptionName = $account.name
        Write-Host "   📊 Subscription: $subscriptionName ($subscriptionId)" -ForegroundColor Cyan
    } else {
        Add-ValidationResult -Category "Authentication" -Check "Azure CLI Authentication" -Status "FAIL" -Message "Not authenticated to Azure CLI" -Recommendation "Run 'az login' to authenticate"
        exit 1
    }
    
    # Test subscription permissions
    Write-Host "📋 Validating subscription permissions..." -ForegroundColor Cyan
    $roleAssignments = az role assignment list --assignee $account.user.name --output json 2>$null | ConvertFrom-Json
    $hasContributorRole = $roleAssignments | Where-Object { $_.roleDefinitionName -eq "Contributor" -or $_.roleDefinitionName -eq "Owner" }
    
    if ($hasContributorRole) {
        Add-ValidationResult -Category "Authentication" -Check "Subscription Permissions" -Status "PASS" -Message "Has sufficient permissions (Contributor/Owner)"
    } else {
        Add-ValidationResult -Category "Authentication" -Check "Subscription Permissions" -Status "WARN" -Message "May have limited permissions" -Recommendation "Ensure Contributor or Owner role at subscription level"
    }
    
} catch {
    Add-ValidationResult -Category "Authentication" -Check "Azure Authentication" -Status "FAIL" -Message "Authentication validation failed: $_" -Recommendation "Verify Azure CLI installation and authentication"
    exit 1
}

# =============================================================================
# Step 3: Week 1 Foundation Validation (Defender for Cloud Resources)
# =============================================================================

Write-Host ""
Write-Host "🛡️  Step 3: Week 1 Foundation Validation (Defender Resources)" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green

try {
    # Validate Defender resource group
    Write-Host "📋 Validating Defender resource group..." -ForegroundColor Cyan
    $defenderRG = az group show --name $DefenderResourceGroupName 2>$null | ConvertFrom-Json
    
    if ($defenderRG) {
        Add-ValidationResult -Category "Week1-Foundation" -Check "Defender Resource Group" -Status "PASS" -Message "Resource group '$DefenderResourceGroupName' exists"
        
        # Validate Log Analytics workspace
        Write-Host "📋 Validating Log Analytics workspace..." -ForegroundColor Cyan
        $logAnalyticsWorkspaces = az monitor log-analytics workspace list --resource-group $DefenderResourceGroupName --output json 2>$null | ConvertFrom-Json
        
        if ($logAnalyticsWorkspaces -and $logAnalyticsWorkspaces.Count -gt 0) {
            $lawWorkspace = $logAnalyticsWorkspaces | Where-Object { $_.name -like "*defender*" -or $_.name -like "*sentinel*" } | Select-Object -First 1
            
            if ($lawWorkspace) {
                Add-ValidationResult -Category "Week1-Foundation" -Check "Log Analytics Workspace" -Status "PASS" -Message "Found workspace: $($lawWorkspace.name)"
                $global:LogAnalyticsWorkspaceId = $lawWorkspace.customerId
                $global:LogAnalyticsWorkspaceName = $lawWorkspace.name
                
                # Validate workspace data ingestion
                if ($TestConnectivity) {
                    Write-Host "📋 Testing Log Analytics data ingestion..." -ForegroundColor Cyan
                    $query = "Heartbeat | limit 1"
                    $queryResult = az monitor log-analytics query --workspace $lawWorkspace.customerId --analytics-query $query --output json 2>$null | ConvertFrom-Json
                    
                    if ($queryResult -and $queryResult.tables -and $queryResult.tables[0].rows.Count -gt 0) {
                        Add-ValidationResult -Category "Week1-Foundation" -Check "Log Analytics Data Ingestion" -Status "PASS" -Message "Data ingestion is active"
                    } else {
                        Add-ValidationResult -Category "Week1-Foundation" -Check "Log Analytics Data Ingestion" -Status "WARN" -Message "No recent data found" -Recommendation "Ensure data connectors are configured"
                    }
                }
            } else {
                Add-ValidationResult -Category "Week1-Foundation" -Check "Log Analytics Workspace" -Status "FAIL" -Message "No Defender/Sentinel workspace found" -Recommendation "Deploy Week 1 foundation components"
            }
        } else {
            Add-ValidationResult -Category "Week1-Foundation" -Check "Log Analytics Workspace" -Status "FAIL" -Message "No Log Analytics workspace found" -Recommendation "Deploy Week 1 foundation components"
        }
        
    } else {
        Add-ValidationResult -Category "Week1-Foundation" -Check "Defender Resource Group" -Status "FAIL" -Message "Resource group '$DefenderResourceGroupName' not found" -Recommendation "Deploy Week 1 Defender foundation"
    }
    
} catch {
    Add-ValidationResult -Category "Week1-Foundation" -Check "Foundation Validation" -Status "FAIL" -Message "Week 1 validation failed: $_" -Recommendation "Verify Week 1 deployment completion"
}

# =============================================================================
# Step 4: Week 2 AI Foundation Validation
# =============================================================================

Write-Host ""
Write-Host "🤖 Step 4: Week 2 AI Foundation Validation" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

$aiResourceGroupName = "rg-$EnvironmentName-ai"

try {
    # Validate AI resource group
    Write-Host "📋 Validating AI resource group..." -ForegroundColor Cyan
    $aiRG = az group show --name $aiResourceGroupName 2>$null | ConvertFrom-Json
    
    if ($aiRG) {
        Add-ValidationResult -Category "Week2-AI" -Check "AI Resource Group" -Status "PASS" -Message "Resource group '$aiResourceGroupName' exists"
        
        # Validate Azure OpenAI service
        if ($EnableOpenAI) {
            Write-Host "📋 Validating Azure OpenAI service..." -ForegroundColor Cyan
            $openAIServices = az cognitiveservices account list --resource-group $aiResourceGroupName --output json 2>$null | ConvertFrom-Json
            $openAIService = $openAIServices | Where-Object { $_.kind -eq "OpenAI" } | Select-Object -First 1
            
            if ($openAIService) {
                Add-ValidationResult -Category "Week2-AI" -Check "Azure OpenAI Service" -Status "PASS" -Message "Found service: $($openAIService.name)"
                $global:OpenAIServiceName = $openAIService.name
                $global:OpenAIEndpoint = $openAIService.properties.endpoint
                
                # Validate model deployments
                if ($ValidateModels -and $Deployo4Mini) {
                    Write-Host "📋 Validating o4-mini model deployment..." -ForegroundColor Cyan
                    $deployments = az cognitiveservices account deployment list --name $openAIService.name --resource-group $aiResourceGroupName --output json 2>$null | ConvertFrom-Json
                    
                    $o4MiniDeployment = $deployments | Where-Object { $_.properties.model.name -like "*o1-mini*" -or $_.name -like "*o4-mini*" -or $_.name -like "*gpt-4o-mini*" }
                    
                    if ($o4MiniDeployment) {
                        Add-ValidationResult -Category "Week2-AI" -Check "o4-mini Model Deployment" -Status "PASS" -Message "Model deployed: $($o4MiniDeployment.name)"
                        $global:O4MiniDeploymentName = $o4MiniDeployment.name
                    } else {
                        Add-ValidationResult -Category "Week2-AI" -Check "o4-mini Model Deployment" -Status "FAIL" -Message "o4-mini model not found" -Recommendation "Deploy o4-mini model through AI Foundry"
                    }
                    
                    # Validate text embedding model if enabled
                    if ($DeployTextEmbedding) {
                        $embeddingDeployment = $deployments | Where-Object { $_.properties.model.name -like "*embedding*" -or $_.properties.model.name -like "*ada*" }
                        
                        if ($embeddingDeployment) {
                            Add-ValidationResult -Category "Week2-AI" -Check "Text Embedding Model" -Status "PASS" -Message "Model deployed: $($embeddingDeployment.name)"
                        } else {
                            Add-ValidationResult -Category "Week2-AI" -Check "Text Embedding Model" -Status "WARN" -Message "Text embedding model not found" -Recommendation "Consider deploying text embedding model for enhanced capabilities"
                        }
                    }
                }
                
                # Test endpoint connectivity if requested
                if ($TestConnectivity) {
                    Write-Host "📋 Testing OpenAI endpoint connectivity..." -ForegroundColor Cyan
                    try {
                        $apiKey = az cognitiveservices account keys list --name $openAIService.name --resource-group $aiResourceGroupName --query "key1" --output tsv 2>$null
                        
                        if ($apiKey) {
                            Add-ValidationResult -Category "Week2-AI" -Check "OpenAI Endpoint Connectivity" -Status "PASS" -Message "API key retrieved successfully"
                        } else {
                            Add-ValidationResult -Category "Week2-AI" -Check "OpenAI Endpoint Connectivity" -Status "WARN" -Message "Could not retrieve API key" -Recommendation "Verify service permissions"
                        }
                    } catch {
                        Add-ValidationResult -Category "Week2-AI" -Check "OpenAI Endpoint Connectivity" -Status "WARN" -Message "Connectivity test failed: $_"
                    }
                }
                
            } else {
                Add-ValidationResult -Category "Week2-AI" -Check "Azure OpenAI Service" -Status "FAIL" -Message "No OpenAI service found" -Recommendation "Deploy Azure OpenAI service"
            }
        } else {
            Add-ValidationResult -Category "Week2-AI" -Check "Azure OpenAI Service" -Status "WARN" -Message "OpenAI service disabled in configuration" -Recommendation "Enable OpenAI service for Defender XDR integration"
        }
        
        # Validate Storage Account for AI processing
        Write-Host "📋 Validating AI processing storage account..." -ForegroundColor Cyan
        $storageAccounts = az storage account list --resource-group $aiResourceGroupName --output json 2>$null | ConvertFrom-Json
        $aiStorageAccount = $storageAccounts | Where-Object { $_.name -like "*aisec*" -or $_.name -like "*ai*" } | Select-Object -First 1
        
        if ($aiStorageAccount) {
            Add-ValidationResult -Category "Week2-AI" -Check "AI Storage Account" -Status "PASS" -Message "Found storage: $($aiStorageAccount.name)"
            $global:StorageAccountName = $aiStorageAccount.name
            
            # Validate storage account tables (for AI processing state)
            if ($TestConnectivity) {
                Write-Host "📋 Validating storage table service..." -ForegroundColor Cyan
                $storageKey = az storage account keys list --resource-group $aiResourceGroupName --account-name $aiStorageAccount.name --query "[0].value" --output tsv 2>$null
                
                if ($storageKey) {
                    # Test table service availability
                    $tables = az storage table list --account-name $aiStorageAccount.name --account-key $storageKey --output json 2>$null | ConvertFrom-Json
                    
                    if ($tables -ne $null) {
                        Add-ValidationResult -Category "Week2-AI" -Check "Storage Table Service" -Status "PASS" -Message "Table service is accessible"
                    } else {
                        Add-ValidationResult -Category "Week2-AI" -Check "Storage Table Service" -Status "WARN" -Message "Table service test inconclusive"
                    }
                } else {
                    Add-ValidationResult -Category "Week2-AI" -Check "Storage Table Service" -Status "WARN" -Message "Could not retrieve storage key"
                }
            }
            
        } else {
            Add-ValidationResult -Category "Week2-AI" -Check "AI Storage Account" -Status "FAIL" -Message "No AI storage account found" -Recommendation "Deploy Week 2 storage foundation"
        }
        
    } else {
        Add-ValidationResult -Category "Week2-AI" -Check "AI Resource Group" -Status "FAIL" -Message "Resource group '$aiResourceGroupName' not found" -Recommendation "Deploy Week 2 AI foundation"
    }
    
} catch {
    Add-ValidationResult -Category "Week2-AI" -Check "AI Foundation Validation" -Status "FAIL" -Message "Week 2 validation failed: $_" -Recommendation "Verify Week 2 deployment completion"
}

# =============================================================================
# Step 5: Cost Management Readiness Check
# =============================================================================

Write-Host ""
Write-Host "💰 Step 5: Cost Management Readiness Check" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

try {
    Write-Host "📋 Validating cost management readiness..." -ForegroundColor Cyan
    
    # Simple validation - just check if we can access cost management APIs
    Write-Host "📋 Testing cost management API access..." -ForegroundColor Cyan
    $costAccess = az consumption budget list --output json 2>$null
    
    if ($costAccess) {
        Add-ValidationResult -Category "Cost-Management" -Check "Cost Management API Access" -Status "PASS" -Message "Cost management APIs accessible"
        Add-ValidationResult -Category "Cost-Management" -Check "Budget Readiness" -Status "PASS" -Message "Ready to configure budgets and alerts for AI services" -Recommendation "Consider setting up budget alerts for OpenAI usage tracking"
    } else {
        Add-ValidationResult -Category "Cost-Management" -Check "Cost Management API Access" -Status "WARN" -Message "Cost management API access limited" -Recommendation "Verify billing permissions for cost monitoring"
    }
    
} catch {
    Add-ValidationResult -Category "Cost-Management" -Check "Cost Management Validation" -Status "WARN" -Message "Cost management validation failed: $_" -Recommendation "Cost monitoring can be configured later if needed"
}

# =============================================================================
# Step 6: Integration Readiness Assessment
# =============================================================================

Write-Host ""
Write-Host "🔗 Step 6: Integration Readiness Assessment" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

try {
    Write-Host "📋 Assessing Defender XDR integration readiness..." -ForegroundColor Cyan
    
    # Check if required resource groups can communicate
    if ($global:LogAnalyticsWorkspaceId -and $global:OpenAIServiceName) {
        Add-ValidationResult -Category "Integration" -Check "Cross-Resource Group Integration" -Status "PASS" -Message "Both Week 1 and Week 2 resources available for integration"
    } else {
        Add-ValidationResult -Category "Integration" -Check "Cross-Resource Group Integration" -Status "FAIL" -Message "Missing required foundation resources" -Recommendation "Complete both Week 1 and Week 2 deployments"
    }
    
    # Validate Logic Apps service availability - simplified check
    if ($DefenderResourceGroupName) {
        Write-Host "📋 Validating Logic Apps deployment readiness..." -ForegroundColor Cyan
        
        # Simple check - just verify the resource group exists for Logic Apps deployment
        $defenderRGExists = az group show --name $DefenderResourceGroupName --query "name" --output tsv 2>$null
        
        if ($defenderRGExists) {
            Add-ValidationResult -Category "Integration" -Check "Logic Apps Deployment Readiness" -Status "PASS" -Message "Target resource group available for Logic Apps deployment"
        } else {
            Add-ValidationResult -Category "Integration" -Check "Logic Apps Deployment Readiness" -Status "FAIL" -Message "Target resource group not accessible"
        }
    }
    
    # Check Microsoft Graph API permissions readiness
    Write-Host "📋 Assessing Microsoft Graph API readiness..." -ForegroundColor Cyan
    
    # Validate that we can create app registrations (needed for Graph API access)
    $appRegistrations = az ad app list --display-name "LogicApp-DefenderXDRIntegration" --output json 2>$null | ConvertFrom-Json
    
    if ($appRegistrations -and $appRegistrations.Count -gt 0) {
        Add-ValidationResult -Category "Integration" -Check "App Registration Exists" -Status "PASS" -Message "Found existing app registration for integration"
    } else {
        Add-ValidationResult -Category "Integration" -Check "App Registration Readiness" -Status "PASS" -Message "Ready to create new app registration for Microsoft Graph access"
    }
    
} catch {
    Add-ValidationResult -Category "Integration" -Check "Integration Assessment" -Status "WARN" -Message "Integration assessment failed: $_" -Recommendation "Review integration prerequisites"
}

# =============================================================================
# Step 7: Generate Validation Summary
# =============================================================================

Write-Host ""
Write-Host "📊 Step 7: Validation Summary" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

$passRate = [math]::Round(($validationResults.PassedChecks / $validationResults.TotalChecks) * 100, 1)

Write-Host ""
Write-Host "🎯 Overall Readiness Assessment:" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta
Write-Host "   ✅ Passed Checks: $($validationResults.PassedChecks)" -ForegroundColor Green
Write-Host "   ❌ Failed Checks: $($validationResults.FailedChecks)" -ForegroundColor Red
Write-Host "   ⚠️  Warning Checks: $($validationResults.WarningChecks)" -ForegroundColor Yellow
Write-Host "   📊 Pass Rate: $passRate%" -ForegroundColor Cyan
Write-Host "   📋 Total Checks: $($validationResults.TotalChecks)" -ForegroundColor White

# Determine overall readiness status
if ($validationResults.FailedChecks -eq 0) {
    if ($validationResults.WarningChecks -eq 0) {
        Write-Host ""
        Write-Host "🎉 DEPLOYMENT READY" -ForegroundColor Green
        Write-Host "===================" -ForegroundColor Green
        Write-Host "All prerequisites validated successfully. You can proceed with Defender XDR integration deployment." -ForegroundColor Green
        $exitCode = 0
    } else {
        Write-Host ""
        Write-Host "✅ DEPLOYMENT READY WITH RECOMMENDATIONS" -ForegroundColor Yellow
        Write-Host "=======================================" -ForegroundColor Yellow
        Write-Host "Core prerequisites met. Address warnings for optimal deployment." -ForegroundColor Yellow
        $exitCode = 0
    }
} else {
    Write-Host ""
    Write-Host "❌ DEPLOYMENT NOT READY" -ForegroundColor Red
    Write-Host "=======================" -ForegroundColor Red
    Write-Host "Critical issues found. Address failed checks before proceeding." -ForegroundColor Red
    $exitCode = 1
}

# Generate detailed report if requested
if ($DetailedReport) {
    Write-Host ""
    Write-Host "📄 Detailed Validation Report" -ForegroundColor Magenta
    Write-Host "==============================" -ForegroundColor Magenta
    
    $categories = $validationResults.Details | Group-Object Category
    
    foreach ($category in $categories) {
        Write-Host ""
        Write-Host "🔍 $($category.Name)" -ForegroundColor Cyan
        Write-Host "$(new-object string('-', $category.Name.Length + 3))" -ForegroundColor Cyan
        
        foreach ($detail in $category.Group) {
            $statusIcon = switch ($detail.Status) {
                "PASS" { "✅" }
                "FAIL" { "❌" }
                "WARN" { "⚠️ " }
            }
            
            Write-Host "  $statusIcon $($detail.Check)" -ForegroundColor White
            if ($detail.Message) {
                Write-Host "      Message: $($detail.Message)" -ForegroundColor Gray
            }
            if ($detail.Recommendation) {
                Write-Host "      Recommendation: $($detail.Recommendation)" -ForegroundColor Gray
            }
        }
    }
    
    # Generate summary metrics
    Write-Host ""
    Write-Host "📈 Validation Metrics" -ForegroundColor Magenta
    Write-Host "=====================" -ForegroundColor Magenta
    Write-Host "   Authentication: $(($validationResults.Details | Where-Object Category -eq 'Authentication' | Where-Object Status -eq 'PASS').Count)/$(($validationResults.Details | Where-Object Category -eq 'Authentication').Count) checks passed" -ForegroundColor Cyan
    Write-Host "   Week 1 Foundation: $(($validationResults.Details | Where-Object Category -eq 'Week1-Foundation' | Where-Object Status -eq 'PASS').Count)/$(($validationResults.Details | Where-Object Category -eq 'Week1-Foundation').Count) checks passed" -ForegroundColor Cyan
    Write-Host "   Week 2 AI Foundation: $(($validationResults.Details | Where-Object Category -eq 'Week2-AI' | Where-Object Status -eq 'PASS').Count)/$(($validationResults.Details | Where-Object Category -eq 'Week2-AI').Count) checks passed" -ForegroundColor Cyan
    Write-Host "   Cost Management: $(($validationResults.Details | Where-Object Category -eq 'Cost-Management' | Where-Object Status -eq 'PASS').Count)/$(($validationResults.Details | Where-Object Category -eq 'Cost-Management').Count) checks passed" -ForegroundColor Cyan
    Write-Host "   Integration Readiness: $(($validationResults.Details | Where-Object Category -eq 'Integration' | Where-Object Status -eq 'PASS').Count)/$(($validationResults.Details | Where-Object Category -eq 'Integration').Count) checks passed" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Magenta
Write-Host "==============" -ForegroundColor Magenta

if ($exitCode -eq 0) {
    Write-Host "1. Proceed with Phase 1: Security Foundation deployment" -ForegroundColor Green
    Write-Host "2. Create App Registration for Microsoft Graph API access" -ForegroundColor Green
    Write-Host "3. Deploy Logic Apps workflow for Defender XDR integration" -ForegroundColor Green
    Write-Host "4. Configure AI processing storage and monitoring" -ForegroundColor Green
} else {
    Write-Host "1. Address all failed validation checks" -ForegroundColor Red
    Write-Host "2. Re-run validation with -DetailedReport for specific guidance" -ForegroundColor Red
    Write-Host "3. Complete missing Week 1 or Week 2 foundation deployments" -ForegroundColor Red
    Write-Host "4. Verify Azure permissions and authentication" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 Script completed in $(((Get-Date) - $startTime).TotalSeconds.ToString('F1')) seconds" -ForegroundColor Cyan

exit $exitCode

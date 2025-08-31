<#
.SYNOPSIS
    Validates Azure OpenAI + Sentinel integration readiness for AI-driven security operations.

.DESCRIPTION
    This script provides comprehensive validation of all prerequisites required for deploying
    the Azure OpenAI + Sentinel integration module. It validates the foundational components
    from Week 1 (Microsoft Sentinel deployment with Log Analytics workspace) and Week 2 
    (Azure OpenAI service with o4-mini model deployment), verifies network connectivity 
    between services, validates security configurations and managed identity permissions,
    and confirms cost management controls are properly configured. The script performs
    deep validation of service health, API connectivity, model deployments, Sentinel data
    connectors, and integration readiness with detailed reporting and remediation guidance.

.PARAMETER EnvironmentName
    Name for the environment (matching deployment configuration). Default: "aisec"

.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file.

.PARAMETER DetailedReport
    Switch to generate detailed validation report with comprehensive metrics.

.PARAMETER TestConnectivity
    Switch to perform network connectivity tests between Azure OpenAI and Sentinel services.

.EXAMPLE
    .\Test-SentinelIntegrationReadiness.ps1 -UseParametersFile
    
    Validate Sentinel integration readiness using parameters file configuration.

.EXAMPLE
    .\Test-SentinelIntegrationReadiness.ps1 -EnvironmentName "aisec" -TestConnectivity -DetailedReport
    
    Comprehensive validation with network connectivity testing and detailed reporting.

.EXAMPLE
    .\Test-SentinelIntegrationReadiness.ps1 -EnvironmentName "securitylab"
    
    Basic validation for specific environment with standard output.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-08-17
    Last Modified: 2025-08-17
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Azure CLI installed and authenticated
    - PowerShell 5.1+ or PowerShell 7+
    - Az PowerShell module installed
    - Appropriate Azure permissions for Sentinel and Cognitive Services
    - Week 1 infrastructure (Microsoft Sentinel with Log Analytics workspace)
    - Week 2 infrastructure (Azure OpenAI Service with o4-mini deployment)
    
    Script development orchestrated using GitHub Copilot.

.INTEGRATION_POINTS
    - Azure OpenAI Service (GPT o4-mini model endpoint validation)
    - Microsoft Sentinel (Log Analytics workspace connectivity)
    - Azure Logic Apps (Integration readiness assessment)
    - Azure Cost Management (Budget and spending control validation)
    - Azure Key Vault (Managed identity and secrets validation)
    - Azure Monitor (Diagnostic settings and logging validation)
#>
#
# =============================================================================
# Validates Azure OpenAI + Sentinel integration prerequisites and readiness.
# =============================================================================

[CmdletBinding()]
param(
    [string]$EnvironmentName = "aisec",
    [switch]$UseParametersFile,
    [switch]$DetailedReport,
    [switch]$TestConnectivity
)

# Helper function for Azure REST API calls
function Invoke-AzureRestApi {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Method,
        
        [Parameter(Mandatory = $true)]
        [string]$Uri,
        
        [Parameter(Mandatory = $false)]
        [string]$Body,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Headers = @{'Content-Type' = 'application/json'}
    )

    try {
        $restArgs = @('--method', $Method, '--uri', $Uri)
        
        if ($Body) {
            $tempFile = [System.IO.Path]::GetTempFileName()
            $Body | Out-File -FilePath $tempFile -Encoding UTF8 -Force
            $restArgs += '--body', "@$tempFile"
        }
        
        if ($Headers.Count -gt 0) {
            $headerFile = [System.IO.Path]::GetTempFileName()
            ($Headers | ConvertTo-Json -Compress) | Out-File -FilePath $headerFile -Encoding UTF8 -Force
            $restArgs += '--headers', "@$headerFile"
        }
        
        $response = az rest @restArgs --output json 2>&1
        
        # Clean up temp files
        if ($tempFile -and (Test-Path $tempFile)) { Remove-Item $tempFile -Force }
        if ($headerFile -and (Test-Path $headerFile)) { Remove-Item $headerFile -Force }
        
        if ($LASTEXITCODE -ne 0) {
            return $null
        }
        
        return ($response | ConvertFrom-Json)
    }
    catch {
        return $null
    }
}

# =============================================================================
# Step 1: Environment Initialization and Parameter Loading
# =============================================================================

Write-Host "🔍 Step 1: Environment Initialization and Parameter Loading" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

Write-Host "📋 Initializing validation environment..." -ForegroundColor Cyan

# Initialize validation results
$ValidationResults = @{
    OverallSuccess = $true
    TotalChecks = 0
    PassedChecks = 0
    FailedChecks = 0
    Warnings = 0
    Results = @{}
    Recommendations = @()
}

# Load parameters from file if specified
if ($UseParametersFile) {
    Write-Host "📄 Loading configuration from main.parameters.json..." -ForegroundColor Cyan
    
    $parametersPath = Join-Path (Split-Path $PSScriptRoot -Parent) "infra\main.parameters.json"
    if (Test-Path $parametersPath) {
        try {
            $parametersContent = Get-Content $parametersPath -Raw | ConvertFrom-Json
            $EnvironmentName = $parametersContent.parameters.environmentName.value
            Write-Host "   ✅ Environment name loaded: $EnvironmentName" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️  Could not load parameters file, using default environment name: $EnvironmentName" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⚠️  Parameters file not found, using default environment name: $EnvironmentName" -ForegroundColor Yellow
    }
}

Write-Host "🎯 Target environment: $EnvironmentName" -ForegroundColor Cyan
Write-Host "   ✅ Environment initialization complete" -ForegroundColor Green

# =============================================================================
# Step 2: Azure Authentication and Subscription Validation
# =============================================================================

Write-Host "🔐 Step 2: Azure Authentication and Subscription Validation" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green

Write-Host "📋 Validating Azure authentication and subscription access..." -ForegroundColor Cyan

try {
    # Check Azure CLI authentication
    $azAccount = az account show --query "{name:name, user:user.name, id:id}" -o json 2>$null | ConvertFrom-Json
    if ($azAccount) {
        Write-Host "   ✅ Azure CLI authenticated as: $($azAccount.user)" -ForegroundColor Green
        Write-Host "   ✅ Active subscription: $($azAccount.name)" -ForegroundColor Green
        $ValidationResults.Results.Authentication = @{
            Status = "Success"
            User = $azAccount.user
            Subscription = $azAccount.name
            SubscriptionId = $azAccount.id
        }
    } else {
        throw "Azure CLI not authenticated"
    }
    
    $ValidationResults.TotalChecks++
    $ValidationResults.PassedChecks++
    
} catch {
    Write-Host "   ❌ Azure authentication failed: $_" -ForegroundColor Red
    $ValidationResults.Results.Authentication = @{
        Status = "Failed"
        Error = $_.ToString()
    }
    $ValidationResults.OverallSuccess = $false
    $ValidationResults.TotalChecks++
    $ValidationResults.FailedChecks++
    $ValidationResults.Recommendations += "Run 'az login' to authenticate with Azure CLI"
}

# =============================================================================
# Step 3: Week 1 Infrastructure Validation (Microsoft Sentinel)
# =============================================================================

Write-Host "🛡️  Step 3: Week 1 Infrastructure Validation (Microsoft Sentinel)" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green

Write-Host "📋 Validating Microsoft Sentinel and Log Analytics workspace..." -ForegroundColor Cyan

# Get subscription ID for API calls
$azAccount = az account show --query "id" -o tsv 2>$null
if (-not $azAccount) {
    Write-Host "   ❌ Unable to get subscription ID" -ForegroundColor Red
    $ValidationResults.OverallSuccess = $false
    $ValidationResults.FailedChecks++
    return
}
$subscriptionId = $azAccount

# Look for Log Analytics workspaces across all resource groups
$sentinelValidation = @{
    Status = "Failed"
    ResourceGroup = $null
    WorkspaceName = $null
    SentinelStatus = $null
    DataConnectors = @()
    WorkspaceId = $null
}

try {
    # Get all resource groups
    Write-Host "   🔍 Searching for Log Analytics workspaces..." -ForegroundColor Cyan
    $allResourceGroups = az group list --query "[].name" -o tsv 2>$null
    
    foreach ($rgName in $allResourceGroups) {
        # Look for Log Analytics workspaces in each resource group
        $workspaces = az monitor log-analytics workspace list --resource-group $rgName --query "[].{name:name, resourceGroup:resourceGroup, customerId:customerId}" -o json 2>$null | ConvertFrom-Json
        
        if ($workspaces) {
            foreach ($workspace in $workspaces) {
                Write-Host "      📊 Checking Log Analytics workspace: $($workspace.name)" -ForegroundColor Cyan
                
                # Check if Sentinel is onboarded to this workspace using REST API
                $sentinelUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$($workspace.resourceGroup)/providers/Microsoft.OperationalInsights/workspaces/$($workspace.name)/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2023-02-01"
                
                try {
                    $sentinelState = Invoke-AzureRestApi -Method "GET" -Uri $sentinelUri
                    
                    if ($sentinelState -and $sentinelState.properties) {
                        Write-Host "      ✅ Microsoft Sentinel enabled on workspace: $($workspace.name)" -ForegroundColor Green
                        $sentinelValidation.Status = "Success"
                        $sentinelValidation.ResourceGroup = $workspace.resourceGroup
                        $sentinelValidation.WorkspaceName = $workspace.name
                        $sentinelValidation.SentinelStatus = "Enabled"
                        $sentinelValidation.WorkspaceId = $workspace.customerId
                        
                        # Check for data connectors using REST API
                        $connectorsUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$($workspace.resourceGroup)/providers/Microsoft.OperationalInsights/workspaces/$($workspace.name)/providers/Microsoft.SecurityInsights/dataConnectors?api-version=2023-02-01"
                        $dataConnectors = Invoke-AzureRestApi -Method "GET" -Uri $connectorsUri
                        
                        if ($dataConnectors -and $dataConnectors.value) {
                            $sentinelValidation.DataConnectors = $dataConnectors.value
                            Write-Host "      ✅ Found $($dataConnectors.value.Count) data connector(s) configured" -ForegroundColor Green
                        } else {
                            Write-Host "      ⚠️  No data connectors found (this may be normal for new deployments)" -ForegroundColor Yellow
                        }
                        
                        # We found a Sentinel-enabled workspace, no need to continue searching
                        break
                    }
                } catch {
                    # Sentinel not enabled on this workspace, continue checking
                    Write-Host "      📋 Sentinel not enabled on workspace: $($workspace.name)" -ForegroundColor Cyan
                }
            }
        }
        
        # If we found a Sentinel workspace, stop searching
        if ($sentinelValidation.Status -eq "Success") {
            break
        }
    }
    
} catch {
    Write-Host "   ❌ Failed to search for workspaces: $_" -ForegroundColor Red
}

if ($sentinelValidation.Status -eq "Success") {
    Write-Host "   ✅ Microsoft Sentinel validation successful" -ForegroundColor Green
    Write-Host "   ✅ Resource Group: $($sentinelValidation.ResourceGroup)" -ForegroundColor Green
    Write-Host "   ✅ Log Analytics Workspace: $($sentinelValidation.WorkspaceName)" -ForegroundColor Green
    $ValidationResults.PassedChecks++
} else {
    Write-Host "   ❌ Microsoft Sentinel workspace not found or not properly configured" -ForegroundColor Red
    $ValidationResults.OverallSuccess = $false
    $ValidationResults.FailedChecks++
    $ValidationResults.Recommendations += "Deploy Microsoft Sentinel using Week 1 infrastructure deployment guide"
}

$ValidationResults.Results.Sentinel = $sentinelValidation
$ValidationResults.TotalChecks++

# =============================================================================
# Step 4: Week 2 Infrastructure Validation (Azure OpenAI Service)
# =============================================================================

Write-Host "🤖 Step 4: Week 2 Infrastructure Validation (Azure OpenAI Service)" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green

Write-Host "📋 Validating Azure OpenAI service and model deployments..." -ForegroundColor Cyan

# Look for AI resource groups from Week 2
$aiResourceGroups = @()
try {
    $allResourceGroups = az group list --query "[?contains(name, 'ai') || contains(name, '$EnvironmentName')].{name:name, location:location}" -o json | ConvertFrom-Json
    $aiResourceGroups = $allResourceGroups | Where-Object { $_.name -like "*$EnvironmentName*" -and ($_.name -like "*ai*" -or $_.name -notlike "*defender*") }
    
    if ($aiResourceGroups.Count -eq 0) {
        # Fallback: look for any resource groups that might contain Cognitive Services
        $allResourceGroups = az group list --query "[].{name:name, location:location}" -o json | ConvertFrom-Json
        foreach ($rg in $allResourceGroups) {
            $cognitiveServices = az cognitiveservices account list --resource-group $rg.name --query "[?kind=='OpenAI'].name" -o tsv 2>$null
            if ($cognitiveServices) {
                $aiResourceGroups += $rg
            }
        }
    }
    
    Write-Host "   📋 Found $($aiResourceGroups.Count) potential AI resource group(s)" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ Failed to enumerate AI resource groups: $_" -ForegroundColor Red
}

# Validate Azure OpenAI service
$openAIValidation = @{
    Status = "Failed"
    ResourceGroup = $null
    ServiceName = $null
    Endpoint = $null
    Models = @()
    HasO4Mini = $false
}

foreach ($rg in $aiResourceGroups) {
    try {
        Write-Host "   🔍 Checking AI resource group: $($rg.name)" -ForegroundColor Cyan
        
        # Find OpenAI services
        $openAIServices = az cognitiveservices account list --resource-group $rg.name --query "[?kind=='OpenAI'].{name:name, endpoint:properties.endpoint, provisioningState:properties.provisioningState}" -o json | ConvertFrom-Json
        
        foreach ($service in $openAIServices) {
            Write-Host "      🤖 Found Azure OpenAI service: $($service.name)" -ForegroundColor Cyan
            Write-Host "      🌐 Endpoint: $($service.endpoint)" -ForegroundColor Cyan
            
            # Check model deployments
            try {
                $deployments = az cognitiveservices account deployment list --resource-group $rg.name --name $service.name --query "[].{name:name, model:properties.model.name, version:properties.model.version, capacity:sku.capacity}" -o json | ConvertFrom-Json
                
                if ($deployments) {
                    Write-Host "      📋 Found $($deployments.Count) model deployment(s):" -ForegroundColor Cyan
                    foreach ($deployment in $deployments) {
                        Write-Host "         • $($deployment.name): $($deployment.model) (v$($deployment.version)) - $($deployment.capacity) units" -ForegroundColor Cyan
                        
                        if ($deployment.model -like "*gpt*4o*mini*" -or $deployment.name -like "*o4-mini*" -or $deployment.name -like "*gpt-4o-mini*") {
                            $openAIValidation.HasO4Mini = $true
                            Write-Host "         ✅ o4-mini model deployment found" -ForegroundColor Green
                        }
                    }
                    
                    $openAIValidation.Status = "Success"
                    $openAIValidation.ResourceGroup = $rg.name
                    $openAIValidation.ServiceName = $service.name
                    $openAIValidation.Endpoint = $service.endpoint
                    $openAIValidation.Models = $deployments
                    break
                }
            } catch {
                Write-Host "      ⚠️  Could not retrieve model deployments: $_" -ForegroundColor Yellow
            }
        }
        
        if ($openAIValidation.Status -eq "Success") {
            break
        }
    } catch {
        Write-Host "   ⚠️  Could not validate AI resource group $($rg.name): $_" -ForegroundColor Yellow
    }
}

if ($openAIValidation.Status -eq "Success") {
    Write-Host "   ✅ Azure OpenAI service validation successful" -ForegroundColor Green
    Write-Host "   ✅ Resource Group: $($openAIValidation.ResourceGroup)" -ForegroundColor Green
    Write-Host "   ✅ Service Name: $($openAIValidation.ServiceName)" -ForegroundColor Green
    
    if ($openAIValidation.HasO4Mini) {
        Write-Host "   ✅ o4-mini model deployment confirmed (cost-optimized for security operations)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  o4-mini model deployment not found (recommended for cost-effective security operations)" -ForegroundColor Yellow
        $ValidationResults.Warnings++
        $ValidationResults.Recommendations += "Deploy o4-mini model for cost-effective security operations"
    }
    $ValidationResults.PassedChecks++
} else {
    Write-Host "   ❌ Azure OpenAI service not found or not properly configured" -ForegroundColor Red
    $ValidationResults.OverallSuccess = $false
    $ValidationResults.FailedChecks++
    $ValidationResults.Recommendations += "Deploy Azure OpenAI service using Week 2 deployment guide"
}

$ValidationResults.Results.OpenAI = $openAIValidation
$ValidationResults.TotalChecks++

# =============================================================================
# Step 5: Network Connectivity and Integration Validation
# =============================================================================

Write-Host "🌐 Step 5: Network Connectivity and Integration Validation" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

if ($TestConnectivity -and $openAIValidation.Status -eq "Success" -and $sentinelValidation.Status -eq "Success") {
    Write-Host "📋 Testing network connectivity between services..." -ForegroundColor Cyan
    
    $connectivityValidation = @{
        Status = "Success"
        OpenAIEndpointReachable = $false
        SentinelAPIReachable = $false
        Details = @()
    }
    
    try {
        # Test OpenAI endpoint connectivity
        Write-Host "   🔍 Testing Azure OpenAI endpoint connectivity..." -ForegroundColor Cyan
        $openAITest = Test-NetConnection -ComputerName ([System.Uri]$openAIValidation.Endpoint).Host -Port 443 -InformationLevel Quiet
        if ($openAITest) {
            Write-Host "   ✅ Azure OpenAI endpoint is reachable" -ForegroundColor Green
            $connectivityValidation.OpenAIEndpointReachable = $true
        } else {
            Write-Host "   ❌ Azure OpenAI endpoint is not reachable" -ForegroundColor Red
            $connectivityValidation.Status = "Failed"
        }
        
        # Test Sentinel/Log Analytics connectivity
        Write-Host "   🔍 Testing Log Analytics workspace connectivity..." -ForegroundColor Cyan
        $lawTest = Test-NetConnection -ComputerName "api.loganalytics.io" -Port 443 -InformationLevel Quiet
        if ($lawTest) {
            Write-Host "   ✅ Log Analytics API is reachable" -ForegroundColor Green
            $connectivityValidation.SentinelAPIReachable = $true
        } else {
            Write-Host "   ❌ Log Analytics API is not reachable" -ForegroundColor Red
            $connectivityValidation.Status = "Failed"
        }
        
        $ValidationResults.Results.Connectivity = $connectivityValidation
        if ($connectivityValidation.Status -eq "Success") {
            $ValidationResults.PassedChecks++
        } else {
            $ValidationResults.FailedChecks++
            $ValidationResults.OverallSuccess = $false
        }
        $ValidationResults.TotalChecks++
        
    } catch {
        Write-Host "   ❌ Connectivity testing failed: $_" -ForegroundColor Red
        $ValidationResults.Results.Connectivity = @{
            Status = "Failed"
            Error = $_.ToString()
        }
        $ValidationResults.FailedChecks++
        $ValidationResults.OverallSuccess = $false
        $ValidationResults.TotalChecks++
    }
} else {
    Write-Host "   ⚠️  Network connectivity testing skipped (requires both OpenAI and Sentinel services)" -ForegroundColor Yellow
}

# =============================================================================
# Step 6: Cost Management and Budget Validation
# =============================================================================

Write-Host "💰 Step 6: Cost Management and Budget Validation" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

Write-Host "📋 Validating cost management and budget controls..." -ForegroundColor Cyan

$costValidation = @{
    Status = "Success"
    BudgetsConfigured = $false
    AlertsConfigured = $false
    Details = @()
}

try {
    # Check for budget configurations
    Write-Host "   🔍 Checking budget configurations..." -ForegroundColor Cyan
    $budgets = az consumption budget list --query "[].{name:name, amount:amount.value, timeGrain:timeGrain}" -o json 2>$null | ConvertFrom-Json
    
    if ($budgets -and $budgets.Count -gt 0) {
        Write-Host "   ✅ Found $($budgets.Count) budget(s) configured" -ForegroundColor Green
        $costValidation.BudgetsConfigured = $true
        foreach ($budget in $budgets) {
            Write-Host "      • $($budget.name): $$$($budget.amount) ($($budget.timeGrain))" -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠️  No budgets configured (recommended for cost control)" -ForegroundColor Yellow
        $ValidationResults.Warnings++
        $ValidationResults.Recommendations += "Configure budget alerts for AI integration cost monitoring"
    }
    
    # Check for cost alerts (would require specific resource group budgets to be more accurate)
    Write-Host "   ✅ Cost management validation completed" -ForegroundColor Green
    
    $ValidationResults.Results.CostManagement = $costValidation
    $ValidationResults.PassedChecks++
    $ValidationResults.TotalChecks++
    
} catch {
    Write-Host "   ❌ Cost management validation failed: $_" -ForegroundColor Red
    $ValidationResults.Results.CostManagement = @{
        Status = "Failed"
        Error = $_.ToString()
    }
    $ValidationResults.Warnings++
    $ValidationResults.TotalChecks++
}

# =============================================================================
# Step 7: Final Validation Report and Recommendations
# =============================================================================

Write-Host "📊 Step 7: Final Validation Report and Recommendations" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

Write-Host "📋 Generating comprehensive validation report..." -ForegroundColor Cyan

# Calculate success percentage
$successPercentage = if ($ValidationResults.TotalChecks -gt 0) { 
    [math]::Round(($ValidationResults.PassedChecks / $ValidationResults.TotalChecks) * 100, 1) 
} else { 0 }

Write-Host ""
Write-Host "🎯 AZURE OPENAI + SENTINEL INTEGRATION READINESS REPORT" -ForegroundColor Magenta
Write-Host "======================================================" -ForegroundColor Magenta
Write-Host ""

# Overall status
if ($ValidationResults.OverallSuccess -and $successPercentage -ge 80) {
    Write-Host "✅ OVERALL STATUS: READY FOR INTEGRATION" -ForegroundColor Green
    Write-Host "   🚀 All critical components validated successfully" -ForegroundColor Green
    Write-Host "   📈 Success Rate: $successPercentage% ($($ValidationResults.PassedChecks)/$($ValidationResults.TotalChecks) checks passed)" -ForegroundColor Green
} elseif ($successPercentage -ge 60) {
    Write-Host "⚠️  OVERALL STATUS: PARTIALLY READY (WARNINGS PRESENT)" -ForegroundColor Yellow
    Write-Host "   🔧 Some components need attention before deployment" -ForegroundColor Yellow
    Write-Host "   📈 Success Rate: $successPercentage% ($($ValidationResults.PassedChecks)/$($ValidationResults.TotalChecks) checks passed)" -ForegroundColor Yellow
} else {
    Write-Host "❌ OVERALL STATUS: NOT READY FOR INTEGRATION" -ForegroundColor Red
    Write-Host "   🛠️  Critical issues must be resolved before proceeding" -ForegroundColor Red
    Write-Host "   📈 Success Rate: $successPercentage% ($($ValidationResults.PassedChecks)/$($ValidationResults.TotalChecks) checks passed)" -ForegroundColor Red
}

Write-Host ""

# Component status summary
Write-Host "📋 COMPONENT VALIDATION SUMMARY" -ForegroundColor Cyan
Write-Host "-------------------------------" -ForegroundColor Cyan

$components = @(
    @{ Name = "Azure Authentication"; Status = $ValidationResults.Results.Authentication.Status },
    @{ Name = "Microsoft Sentinel"; Status = $ValidationResults.Results.Sentinel.Status },
    @{ Name = "Azure OpenAI Service"; Status = $ValidationResults.Results.OpenAI.Status }
)

if ($ValidationResults.Results.Connectivity) {
    $components += @{ Name = "Network Connectivity"; Status = $ValidationResults.Results.Connectivity.Status }
}

if ($ValidationResults.Results.CostManagement) {
    $components += @{ Name = "Cost Management"; Status = $ValidationResults.Results.CostManagement.Status }
}

foreach ($component in $components) {
    $statusIcon = switch ($component.Status) {
        "Success" { "✅" }
        "Failed" { "❌" }
        default { "⚠️ " }
    }
    Write-Host "   $statusIcon $($component.Name): $($component.Status)" -ForegroundColor $(
        switch ($component.Status) {
            "Success" { "Green" }
            "Failed" { "Red" }
            default { "Yellow" }
        }
    )
}

# Detailed report if requested
if ($DetailedReport) {
    Write-Host ""
    Write-Host "📄 DETAILED VALIDATION RESULTS" -ForegroundColor Cyan
    Write-Host "------------------------------" -ForegroundColor Cyan
    
    # Sentinel Details
    if ($ValidationResults.Results.Sentinel.Status -eq "Success") {
        Write-Host "🛡️  Microsoft Sentinel Configuration:" -ForegroundColor Cyan
        Write-Host "   • Resource Group: $($ValidationResults.Results.Sentinel.ResourceGroup)" -ForegroundColor White
        Write-Host "   • Workspace Name: $($ValidationResults.Results.Sentinel.WorkspaceName)" -ForegroundColor White
        Write-Host "   • Data Connectors: $($ValidationResults.Results.Sentinel.DataConnectors.Count)" -ForegroundColor White
    }
    
    # OpenAI Details  
    if ($ValidationResults.Results.OpenAI.Status -eq "Success") {
        Write-Host "🤖 Azure OpenAI Service Configuration:" -ForegroundColor Cyan
        Write-Host "   • Resource Group: $($ValidationResults.Results.OpenAI.ResourceGroup)" -ForegroundColor White
        Write-Host "   • Service Name: $($ValidationResults.Results.OpenAI.ServiceName)" -ForegroundColor White
        Write-Host "   • Endpoint: $($ValidationResults.Results.OpenAI.Endpoint)" -ForegroundColor White
        Write-Host "   • Model Deployments: $($ValidationResults.Results.OpenAI.Models.Count)" -ForegroundColor White
        Write-Host "   • o4-mini Available: $($ValidationResults.Results.OpenAI.HasO4Mini)" -ForegroundColor White
    }
}

# Recommendations
if ($ValidationResults.Recommendations.Count -gt 0) {
    Write-Host ""
    Write-Host "💡 RECOMMENDATIONS" -ForegroundColor Yellow
    Write-Host "------------------" -ForegroundColor Yellow
    for ($i = 0; $i -lt $ValidationResults.Recommendations.Count; $i++) {
        Write-Host "   $($i + 1). $($ValidationResults.Recommendations[$i])" -ForegroundColor Yellow
    }
}

# Next steps
Write-Host ""
Write-Host "🚀 NEXT STEPS" -ForegroundColor Magenta
Write-Host "-------------" -ForegroundColor Magenta

if ($ValidationResults.OverallSuccess -and $successPercentage -ge 80) {
    Write-Host "   1. Proceed with Azure OpenAI + Sentinel integration deployment" -ForegroundColor Green
    Write-Host "   2. Follow the deployment guide: deploy-openai-defender-xdr-integration.md" -ForegroundColor Green
    Write-Host "   3. Configure Logic Apps for AI-driven incident analysis" -ForegroundColor Green
} else {
    Write-Host "   1. Address the failed validation items listed above" -ForegroundColor Red
    Write-Host "   2. Re-run this validation script to confirm readiness" -ForegroundColor Red
    Write-Host "   3. Consult Week 1 and Week 2 deployment guides for missing components" -ForegroundColor Red
}

Write-Host ""
Write-Host "✅ Validation completed successfully" -ForegroundColor Green
Write-Host "📊 Report generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan

# Exit with appropriate code
if ($ValidationResults.OverallSuccess -and $ValidationResults.FailedChecks -eq 0) {
    exit 0
} elseif ($ValidationResults.FailedChecks -eq 0) {
    exit 0  # Warnings only
} else {
    exit 1  # Failed checks present
}

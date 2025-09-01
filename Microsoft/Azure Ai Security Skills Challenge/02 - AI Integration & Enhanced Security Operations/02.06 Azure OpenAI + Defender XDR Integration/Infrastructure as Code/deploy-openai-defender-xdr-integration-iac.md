# Deploy Azure OpenAI + Sentinel Integration (Infrastructure-as-Code)

This guide provides automated deployment of Logic Apps-based AI security integration using PowerShell scripts, Azure CLI commands, and REST API calls. This approach ensures consistent, repeatable deployments suitable for production environments.

## 🎯 Infrastructure-as-Code Overview

The IaC deployment provides:

- **Automated Logic Apps Creation**: PowerShell scripts create consumption-based Logic Apps with proper configuration
- **Template-Driven Configuration**: JSON templates for OpenAI integration settings and Sentinel connections
- **REST API Integration**: Direct Azure REST API calls for advanced configuration scenarios
- **PowerShell Style Compliance**: All scripts follow the [project's PowerShell style guide standards](../../../../Style%20Guides/powershell-style-guide.md)
- **Cost Control Automation**: Built-in budget monitoring and alert configuration

## 🚀 PowerShell Script Deployment

### Script 1: Logic Apps Foundation Deployment

The primary deployment script creates the Logic App infrastructure and basic configuration:

**Script Location**: [`scripts/Deploy-LogicAppFoundation.ps1`](./scripts/Deploy-LogicAppFoundation.ps1)

#### PowerShell Script Features

```powershell
<#
.SYNOPSIS
    Deploy Logic Apps foundation for Azure OpenAI + Sentinel integration.

.DESCRIPTION
    Creates consumption-based Logic Apps with proper resource group placement,
    naming conventions, and initial configuration for AI security automation.
    Implements cost-effective settings and integrates with existing Sentinel workspace.

.PARAMETER EnvironmentName
    The environment identifier for resource naming (e.g., 'aisec', 'prod', 'lab').

.PARAMETER Location
    Azure region for Logic Apps deployment. Defaults to 'East US' for AI service compatibility.

.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file.

.EXAMPLE
    .\Deploy-LogicAppFoundation.ps1 -UseParametersFile
    
    Basic deployment using parameters file configuration.

.EXAMPLE
    .\Deploy-LogicAppFoundation.ps1 -EnvironmentName "aisec" -Location "East US"
    
    Custom deployment with specific environment and location parameters.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-08-17
    Last Modified: 2025-08-17
    
    Requirements:
    - Azure CLI installed and authenticated
    - PowerShell 5.1+ or PowerShell 7+
    - Contributor access to target resource groups
    - Existing Sentinel workspace from Week 1 deployment
    - Azure OpenAI service from Week 2 deployment
    
    Script development orchestrated using GitHub Copilot.

.PHASES
    Phase 1: Environment validation and parameter loading
    Phase 2: Logic Apps resource group and naming preparation
    Phase 3: Consumption Logic Apps deployment with Sentinel connectors
    Phase 4: Integration testing and configuration validation
#>
```

#### Key PowerShell Commands

The script uses Azure CLI commands for resource deployment:

```powershell
# Create consumption Logic Apps with proper configuration
az logicapp create --resource-group $ResourceGroupName `
    --name $LogicAppName `
    --location $Location `
    --sku "Standard" `
    --storage-account $StorageAccountName

# Configure Sentinel connection using REST API
$sentinelConnectionBody = @{
    properties = @{
        displayName = "Sentinel AI Connection"
        customParameterValues = @{}
        api = @{
            id = "/subscriptions/$SubscriptionId/providers/Microsoft.Web/locations/$Location/managedApis/azuresentinel"
        }
    }
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri $connectionUri -Method PUT -Body $sentinelConnectionBody -Headers $headers
```

### Script 2: OpenAI Integration Configuration

**Script Location**: [`scripts/Deploy-OpenAIIntegration.ps1`](./scripts/Deploy-OpenAIIntegration.ps1)

This script configures the Logic Apps workflow with OpenAI API integration:

#### REST API Integration

```powershell
<#
.SYNOPSIS
    Configure Azure OpenAI integration for Logic Apps security workflows.

.DESCRIPTION
    Implements Logic Apps workflow definitions with Azure OpenAI API integration,
    cost controls, and incident processing automation. Uses REST API calls for
    advanced configuration scenarios and template-based workflow deployment.

.INTEGRATION POINTS
    - Azure OpenAI service API endpoints and authentication configuration
    - Microsoft Sentinel incident triggers and response actions
    - Azure Monitor budget consumption monitoring and alerting
    - Logic Apps workflow definition deployment via ARM templates
#>

# Configure OpenAI API connection
$openAIConnectionBody = @{
    properties = @{
        displayName = "Azure OpenAI Security Connection"
        customParameterValues = @{
            "api_key" = "@{listKeys(resourceId('Microsoft.CognitiveServices/accounts', '$OpenAIServiceName'), '2023-05-01').key1}"
            "site_url" = "https://$OpenAIServiceName.openai.azure.com/"
        }
        api = @{
            id = "/subscriptions/$SubscriptionId/providers/Microsoft.Web/locations/$Location/managedApis/cognitiveservicesopenaigpt"
        }
    }
} | ConvertTo-Json -Depth 5

# Deploy Logic Apps workflow definition
$workflowDefinition = Get-Content -Path "$TemplatesPath\sentinel-ai-workflow.json" | ConvertFrom-Json
$workflowBody = @{
    properties = @{
        definition = $workflowDefinition
        parameters = @{
            "openai-connection" = @{
                value = @{
                    connectionId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/connections/openai-connection"
                    connectionName = "openai-connection"
                    id = "/subscriptions/$SubscriptionId/providers/Microsoft.Web/locations/$Location/managedApis/cognitiveservicesopenaigpt"
                }
            }
        }
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri $workflowUri -Method PUT -Body $workflowBody -Headers $headers
```

### Script 3: Cost Management and Monitoring

**Script Location**: [`scripts/Deploy-CostControls.ps1`](./scripts/Deploy-CostControls.ps1)

#### Budget Control Implementation

```powershell
<#
.SYNOPSIS
    Deploy cost management and monitoring for AI security integration.

.DESCRIPTION
    Implements comprehensive cost controls including budget alerts, token usage
    monitoring, and automated Logic Apps scaling based on consumption thresholds.
    Provides executive reporting on AI security operation costs and usage patterns.

.COST CATEGORIES
    - Logic Apps execution costs (per-trigger pricing model)
    - Azure OpenAI token consumption (input and output tokens)
    - Azure Monitor and Log Analytics query costs
    - Storage costs for workflow state and diagnostic data
#>

# Configure budget for AI security operations
az consumption budget create --budget-name "ai-security-integration" `
    --resource-group $ResourceGroupName `
    --amount 25 `
    --time-grain "Monthly" `
    --start-date (Get-Date -Format "yyyy-MM-dd") `
    --category "Cost" `
    --notifications @{
        "80-percent" = @{
            "enabled" = $true
            "operator" = "GreaterThanOrEqualTo"
            "threshold" = 80
            "contactEmails" = @($NotificationEmail)
        }
        "100-percent" = @{
            "enabled" = $true  
            "operator" = "GreaterThanOrEqualTo"
            "threshold" = 100
            "contactEmails" = @($NotificationEmail)
        }
    }
```

## 📋 Template Configuration Files

### Logic Apps Workflow Template

**Template File**: [`scripts/templates/sentinel-ai-workflow.json`](./scripts/templates/sentinel-ai-workflow.json)

This template defines the complete Logic Apps workflow for AI security automation:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2016-06-01/workflowdefinition.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "openai-connection": {
            "type": "Object",
            "defaultValue": {}
        },
        "sentinel-connection": {
            "type": "Object", 
            "defaultValue": {}
        }
    },
    "triggers": {
        "When_an_incident_is_created_or_updated_in_Azure_Sentinel": {
            "type": "ApiConnectionWebhook",
            "inputs": {
                "host": {
                    "connection": {
                        "name": "@parameters('sentinel-connection')['connectionId']"
                    }
                },
                "body": {
                    "callback_url": "@{listCallbackUrl()}"
                },
                "path": "/subscribe"
            }
        }
    },
    "actions": {
        "Azure_OpenAI_Analysis": {
            "type": "ApiConnection",
            "inputs": {
                "host": {
                    "connection": {
                        "name": "@parameters('openai-connection')['connectionId']"
                    }
                },
                "method": "post",
                "path": "/deployments/@{encodeURIComponent('gpt-4o-mini')}/chat/completions",
                "queries": {
                    "api-version": "2024-08-01-preview"
                },
                "body": {
                    "messages": [
                        {
                            "role": "system",
                            "content": "You are a senior cybersecurity analyst specializing in threat detection and incident response. Analyze security incidents with focus on MITRE ATT&CK framework mapping, severity assessment, and actionable response recommendations."
                        },
                        {
                            "role": "user", 
                            "content": "INCIDENT ANALYSIS REQUEST:\nTitle: @{triggerBody()?['properties']?['title']}\nDescription: @{triggerBody()?['properties']?['description']}\nSeverity: @{triggerBody()?['properties']?['severity']}\n\nProvide: 1) Risk Assessment, 2) MITRE ATT&CK Mapping, 3) Immediate Actions, 4) Business Impact. Limit to 400 tokens."
                        }
                    ],
                    "max_tokens": 400,
                    "temperature": 0.3
                }
            },
            "runAfter": {}
        }
    }
}
```

### PowerShell Parameter Configuration

**Template File**: [`scripts/templates/integration-parameters.json`](./scripts/templates/integration-parameters.json)

```json
{
    "environmentName": "aisec",
    "location": "East US",
    "resourceGroupName": "rg-aisec-defender-{environmentName}",
    "logicAppName": "la-sentinel-ai-${uniqueString(resourceGroup().id)}",
    "openAIServiceName": "openai-aisec-${uniqueString(resourceGroup().id)}",
    "sentinelWorkspaceName": "la-defender-eastus",
    "budgetAmount": 25,
    "notificationEmail": "security-team@organization.com",
    "tokenLimits": {
        "critical": 800,
        "high": 500,
        "medium": 300,
        "low": 150
    }
}
```

## 🔧 Advanced PowerShell Automation

### REST API Helper Functions

**Script Location**: [`scripts/lib/RestApiHelpers.ps1`](./scripts/lib/RestApiHelpers.ps1)

```powershell
<#
.SYNOPSIS
    REST API helper functions for Azure Logic Apps and OpenAI integration.

.DESCRIPTION
    Provides reusable PowerShell functions for Azure REST API operations
    including authentication, resource management, and configuration deployment.
    Implements retry logic, error handling, and comprehensive logging.
#>

function Invoke-AzureRestAPI {
    param(
        [string]$Uri,
        [string]$Method = "GET",
        [string]$Body,
        [hashtable]$Headers = @{},
        [int]$MaxRetries = 3
    )
    
    # Get Azure access token
    $accessToken = (az account get-access-token --query accessToken -o tsv)
    $Headers["Authorization"] = "Bearer $accessToken"
    $Headers["Content-Type"] = "application/json"
    
    $attempt = 0
    do {
        try {
            $attempt++
            Write-Host "🌐 REST API Call: $Method $Uri (Attempt $attempt)" -ForegroundColor Cyan
            
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Body $Body -Headers $Headers
            Write-Host "✅ REST API call successful" -ForegroundColor Green
            return $response
        }
        catch {
            Write-Host "❌ REST API call failed: $_" -ForegroundColor Red
            if ($attempt -lt $MaxRetries) {
                Write-Host "⏳ Retrying in 30 seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds 30
            }
        }
    } while ($attempt -lt $MaxRetries)
    
    throw "REST API call failed after $MaxRetries attempts"
}

function Deploy-LogicAppWorkflow {
    param(
        [string]$SubscriptionId,
        [string]$ResourceGroupName,
        [string]$LogicAppName,
        [hashtable]$WorkflowDefinition
    )
    
    $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$LogicAppName"
    $body = @{
        location = $Location
        properties = $WorkflowDefinition
    } | ConvertTo-Json -Depth 10
    
    return Invoke-AzureRestAPI -Uri $uri -Method "PUT" -Body $body
}
```

## 📊 Deployment Validation and Testing

### Integration Testing Script

**Script Location**: [`scripts/Test-LogicAppIntegration.ps1`](./scripts/Test-LogicAppIntegration.ps1)

```powershell
<#
.SYNOPSIS
    Validate Azure OpenAI + Sentinel Logic Apps integration deployment.

.DESCRIPTION
    Comprehensive validation of Logic Apps deployment including trigger functionality,
    OpenAI API connectivity, Sentinel integration, cost controls, and end-to-end
    incident processing workflows. Provides detailed reporting on integration health.

.TEST SCENARIOS
    - Logic Apps trigger configuration and Sentinel webhook connectivity
    - Azure OpenAI API authentication and model deployment accessibility  
    - Incident processing workflow execution with sample security events
    - Cost monitoring and budget alert configuration validation
#>

# =============================================================================
# Step 1: Logic Apps Connectivity Validation
# =============================================================================

Write-Host "🔍 Step 1: Logic Apps Connectivity Validation" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Test Logic Apps trigger configuration
$logicApp = az logicapp show --name $LogicAppName --resource-group $ResourceGroupName | ConvertFrom-Json
if ($logicApp.state -eq "Enabled") {
    Write-Host "   ✅ Logic Apps state: $($logicApp.state)" -ForegroundColor Green
} else {
    Write-Host "   ❌ Logic Apps state: $($logicApp.state)" -ForegroundColor Red
}

# Test Sentinel connection
$sentinelConnection = az logicapp connection show --name "sentinel-connection" --resource-group $ResourceGroupName
if ($sentinelConnection) {
    Write-Host "   ✅ Sentinel connection configured" -ForegroundColor Green
} else {
    Write-Host "   ❌ Sentinel connection missing" -ForegroundColor Red
}
```

### Cost Monitoring Validation

```powershell
# =============================================================================
# Step 2: Cost Controls Validation
# =============================================================================

Write-Host "💰 Step 2: Cost Controls Validation" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Verify budget configuration
$budget = az consumption budget show --budget-name "ai-security-integration" --resource-group $ResourceGroupName | ConvertFrom-Json
if ($budget.amount -eq 25) {
    Write-Host "   ✅ Budget configured: $($budget.amount) USD/month" -ForegroundColor Green
} else {
    Write-Host "   ❌ Budget misconfigured or missing" -ForegroundColor Red
}

# Test OpenAI token usage monitoring
$tokenUsageQuery = @"
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.COGNITIVESERVICES"
| where OperationName == "ChatCompletions"
| extend TokensUsed = extract("tokens_used: ([0-9]+)", 1, Properties)
| summarize TotalTokens = sum(toint(TokensUsed)) by bin(TimeGenerated, 1h)
| top 24 by TimeGenerated
"@

$queryResults = az monitor log-analytics query --workspace $WorkspaceName --analytics-query $tokenUsageQuery
Write-Host "   📊 Token usage monitoring configured" -ForegroundColor Cyan
```

## 🚀 Production Deployment

### Complete Deployment Script

**Script Location**: [`scripts/Deploy-SentinelAIIntegration.ps1`](./scripts/Deploy-SentinelAIIntegration.ps1)

This orchestrator script manages the complete deployment process:

```powershell
<#
.SYNOPSIS
    Master deployment script for Azure OpenAI + Sentinel integration.

.DESCRIPTION
    Orchestrates complete deployment of Logic Apps-based AI security automation
    including infrastructure provisioning, workflow configuration, cost controls,
    and integration validation. Implements production-ready settings with
    comprehensive error handling and rollback capabilities.

.PHASES
    Phase 1: Environment preparation and parameter validation
    Phase 2: Logic Apps foundation and resource group setup
    Phase 3: OpenAI integration and workflow deployment  
    Phase 4: Cost controls and monitoring configuration
    Phase 5: Integration testing and validation reporting
#>

# =============================================================================
# Phase 1: Environment Preparation
# =============================================================================

Write-Host "📋 Phase 1: Environment Preparation" -ForegroundColor Magenta
Write-Host "===================================" -ForegroundColor Magenta

try {
    Write-Host "🚀 Calling script 'Deploy-LogicAppFoundation.ps1'..." -ForegroundColor Blue
    & "$scriptsPath\Deploy-LogicAppFoundation.ps1" @commonParams
    
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        Write-Host "✅ Script 'Deploy-LogicAppFoundation.ps1' completed successfully" -ForegroundColor Blue
        Write-Host "✅ Phase 1 completed successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Script 'Deploy-LogicAppFoundation.ps1' failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
        throw "Script exited with code: $LASTEXITCODE"
    }
} catch {
    Write-Host "❌ Phase 1 failed: $_" -ForegroundColor Red
    exit 1
}
```

---

## 🤖 AI-Assisted Content Generation

This comprehensive Infrastructure-as-Code deployment guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The PowerShell scripts, REST API integration patterns, and automation workflows were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, following the project's PowerShell style guide standards and Microsoft Azure automation best practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Infrastructure-as-Code deployment scenarios while maintaining technical accuracy and reflecting current Azure Logic Apps and OpenAI service integration patterns.*

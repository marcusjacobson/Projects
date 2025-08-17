// =============================================================================
// Azure OpenAI Service Deployment Template
// =============================================================================
// This template deploys Azure OpenAI service with configurable model deployments,
// system-assigned managed identity, and optional Log Analytics workspace integration.

@description('Environment name for resource naming and tagging')
param environmentName string = 'aisec'

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Deploy o4-mini model endpoint')
param deployo4Mini bool = true

@description('Deploy text-embedding-3-small model endpoint')
param deployTextEmbedding bool = true

@description('Deploy GPT-5 model endpoint')
param deployGPT5 bool = false

@description('Use existing Log Analytics workspace (if available)')
param useExistingLogAnalytics bool = true

@description('Resource group containing the Log Analytics workspace')
param logAnalyticsResourceGroup string = resourceGroup().name

@description('Log Analytics workspace name (will be determined based on environment)')
param logAnalyticsWorkspaceName string = 'log-${environmentName}-001'

@description('Deployment timestamp for tagging')
param deploymentTimestamp string = utcNow('yyyy-MM-dd-HH-mm-ss')

// =============================================================================
// Variables
// =============================================================================

var openAIServiceName = 'openai-${environmentName}-001'

// Model configuration
var gpt4oMiniConfig = {
  name: 'gpt-4o-mini'
  modelName: 'gpt-4o-mini'
  modelVersion: '2024-07-18'
  capacity: 10
}

var textEmbeddingConfig = {
  name: 'text-embedding-3-small'
  modelName: 'text-embedding-3-small'
  modelVersion: '1'
  capacity: 10
}

var gpt35TurboConfig = {
  name: 'gpt-5'
  modelName: 'gpt-5'
  modelVersion: '0125'
  capacity: 10
}

// =============================================================================
// Resources
// =============================================================================

// Log Analytics Workspace (conditional deployment)
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (!useExistingLogAnalytics) {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
  tags: {
    environment: environmentName
    purpose: 'ai-security-monitoring'
    'azd-env-name': environmentName
    deployedBy: 'bicep-template'
    deploymentDate: deploymentTimestamp
  }
}

// Reference to existing Log Analytics workspace (if using existing)
resource existingLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = if (useExistingLogAnalytics) {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsResourceGroup)
}

// Azure OpenAI Service
resource openAIService 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: openAIServiceName
  location: location
  kind: 'OpenAI'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: openAIServiceName
    networkAcls: {
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    restrictOutboundNetworkAccess: false
  }
  tags: {
    environment: environmentName
    purpose: 'ai-security-operations'
    'azd-env-name': environmentName
    deployedBy: 'bicep-template'
    deploymentDate: deploymentTimestamp
  }
}

// o4-mini Model Deployment
resource gpt4oMiniDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = if (deployo4Mini) {
  parent: openAIService
  name: gpt4oMiniConfig.name
  properties: {
    model: {
      format: 'OpenAI'
      name: gpt4oMiniConfig.modelName
      version: gpt4oMiniConfig.modelVersion
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: gpt4oMiniConfig.capacity
  }
}

// Text Embedding Model Deployment
resource textEmbeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = if (deployTextEmbedding) {
  parent: openAIService
  name: textEmbeddingConfig.name
  properties: {
    model: {
      format: 'OpenAI'
      name: textEmbeddingConfig.modelName
      version: textEmbeddingConfig.modelVersion
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: textEmbeddingConfig.capacity
  }
  dependsOn: [
    gpt4oMiniDeployment
  ]
}

// GPT-5 Model Deployment
resource gpt35TurboDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = if (deployGPT5) {
  parent: openAIService
  name: gpt35TurboConfig.name
  properties: {
    model: {
      format: 'OpenAI'
      name: gpt35TurboConfig.modelName
      version: gpt35TurboConfig.modelVersion
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: gpt35TurboConfig.capacity
  }
  dependsOn: [
    textEmbeddingDeployment
  ]
}

// Diagnostic Settings for OpenAI Service (if Log Analytics is available)
resource openAIDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${openAIServiceName}-diagnostics'
  scope: openAIService
  properties: {
    workspaceId: useExistingLogAnalytics ? existingLogAnalyticsWorkspace.id : logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// =============================================================================
// Outputs
// =============================================================================

@description('The name of the deployed Azure OpenAI service')
output openaiServiceName string = openAIService.name

@description('The endpoint URL of the Azure OpenAI service')
output openaiEndpoint string = openAIService.properties.endpoint

@description('The resource ID of the Azure OpenAI service')
output openaiId string = openAIService.id

@description('The principal ID of the system-assigned managed identity')
output openaiPrincipalId string = openAIService.identity.principalId

@description('The resource ID of the Log Analytics workspace')
output logAnalyticsWorkspaceId string = useExistingLogAnalytics ? existingLogAnalyticsWorkspace.id : logAnalyticsWorkspace.id

@description('List of deployed models')
output deployedModels array = [
  deployo4Mini ? {
    name: gpt4oMiniConfig.name
    modelName: gpt4oMiniConfig.modelName
    modelVersion: gpt4oMiniConfig.modelVersion
    endpoint: '${openAIService.properties.endpoint}openai/deployments/${gpt4oMiniConfig.name}/chat/completions?api-version=2024-02-15-preview'
  } : null
  deployTextEmbedding ? {
    name: textEmbeddingConfig.name
    modelName: textEmbeddingConfig.modelName
    modelVersion: textEmbeddingConfig.modelVersion
    endpoint: '${openAIService.properties.endpoint}openai/deployments/${textEmbeddingConfig.name}/embeddings?api-version=2024-02-15-preview'
  } : null
  deployGPT5 ? {
    name: gpt35TurboConfig.name
    modelName: gpt35TurboConfig.modelName
    modelVersion: gpt35TurboConfig.modelVersion
    endpoint: '${openAIService.properties.endpoint}openai/deployments/${gpt35TurboConfig.name}/chat/completions?api-version=2024-02-15-preview'
  } : null
]

@description('Deployment configuration summary')
output deploymentSummary object = {
  environmentName: environmentName
  location: location
  openaiServiceName: openAIService.name
  managedIdentityType: 'SystemAssigned'
  logAnalyticsIntegration: useExistingLogAnalytics ? 'existing' : 'new'
  modelDeployments: {
    gpt4oMini: deployo4Mini
    textEmbedding: deployTextEmbedding
    gpt35Turbo: deployGPT5
  }
  deploymentTimestamp: deploymentTimestamp
}

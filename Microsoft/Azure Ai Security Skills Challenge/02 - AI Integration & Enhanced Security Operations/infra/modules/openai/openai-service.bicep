// Azure OpenAI Service Module
// Deploys cost-effective Azure OpenAI service with flexible model options for lab learning

@description('Location for resource deployment')
param location string

@description('Resource token for unique naming')
param resourceToken string

@description('Resource tags')
param tags object

@description('Azure OpenAI SKU')
@allowed(['F0', 'S0'])
param sku string = 'S0'

@description('Enable diagnostic settings')
param enableDiagnostics bool = true

@description('Deploy GPT-5 model (cost-effective)')
param deployGPT5 bool = true

@description('Deploy o4-mini model (best learning-to-cost ratio)')
param deployo4Mini bool = false

@description('Deploy text embedding model')
param deployTextEmbedding bool = false

// Variables
var openAIServiceName = 'oai-${resourceToken}'
var gpt5DeploymentName = 'gpt-35-turbo'
var o4MiniDeploymentName = 'o4-mini'
var textEmbeddingDeploymentName = 'text-embedding-ada-002'

// Azure OpenAI Service
resource openAIService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAIServiceName
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: openAIServiceName
    publicNetworkAccess: 'Enabled' // Start permissive, tighten in production
    disableLocalAuth: false
  }
}

// GPT-5 deployment (most cost-effective for general AI tasks)
resource gpt5Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = if (deployGPT5) {
  parent: openAIService
  name: gpt5DeploymentName
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: '0613'
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: 10 // Start with minimal capacity for cost control
  }
}

// o4-mini deployment (best learning-to-cost ratio for labs)
resource o4MiniDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = if (deployo4Mini) {
  parent: openAIService
  name: o4MiniDeploymentName
  properties: {
    model: {
      format: 'OpenAI'
      name: 'o4-mini'
      version: '2024-07-18'
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: 10 // Minimal capacity for cost-effective learning
  }
  dependsOn: [
    gpt5Deployment // Deploy sequentially to avoid conflicts
  ]
}

// Text embedding deployment (optional, for advanced scenarios)
resource textEmbeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = if (deployTextEmbedding) {
  parent: openAIService
  name: textEmbeddingDeploymentName
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: '2'
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: 5 // Minimal capacity for embeddings
  }
  dependsOn: [
    gpt5Deployment // Deploy sequentially to avoid conflicts
    o4MiniDeployment
  ]
}

// Diagnostic settings (if enabled)
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: openAIService
  name: 'openai-diagnostics'
  properties: {
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30 // Cost optimization: limited retention
        }
      }
    ]
    logs: [
      {
        category: 'Audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'RequestResponse'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

// Outputs
output openAIServiceName string = openAIService.name
output openAIServiceId string = openAIService.id
output openAIEndpoint string = openAIService.properties.endpoint
output gpt5DeploymentName string = deployGPT5 ? gpt5Deployment.name : ''
output o4MiniDeploymentName string = deployo4Mini ? o4MiniDeployment.name : ''
output textEmbeddingDeploymentName string = deployTextEmbedding ? textEmbeddingDeployment.name : ''
output estimatedMonthlyCost string = 'Models deployed: ${deployGPT5 ? 'GPT-5 (~$10-30/month) ' : ''}${deployo4Mini ? 'o4-mini (~$5-15/month) ' : ''}${deployTextEmbedding ? 'Embeddings (~$1-5/month)' : ''}'

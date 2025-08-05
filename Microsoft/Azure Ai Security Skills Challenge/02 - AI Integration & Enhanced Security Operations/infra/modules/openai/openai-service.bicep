// Azure OpenAI Service Module
// Deploys cost-effective Azure OpenAI service with GPT-3.5-turbo for budget optimization

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

@description('Deploy GPT-3.5-turbo model (cost-effective)')
param deployGPT35Turbo bool = true

@description('Deploy text embedding model')
param deployTextEmbedding bool = false

// Variables
var openAIServiceName = 'oai-${resourceToken}'
var gpt35TurboDeploymentName = 'gpt-35-turbo'
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

// GPT-3.5-turbo deployment (most cost-effective for general AI tasks)
resource gpt35TurboDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = if (deployGPT35Turbo) {
  parent: openAIService
  name: gpt35TurboDeploymentName
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
    gpt35TurboDeployment // Deploy sequentially to avoid conflicts
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
output gpt35TurboDeploymentName string = deployGPT35Turbo ? gpt35TurboDeployment.name : ''
output textEmbeddingDeploymentName string = deployTextEmbedding ? textEmbeddingDeployment.name : ''
output estimatedMonthlyCost string = 'GPT-3.5-turbo: ~$10-30/month (capacity: ${deployGPT35Turbo ? '10 units' : '0'})'

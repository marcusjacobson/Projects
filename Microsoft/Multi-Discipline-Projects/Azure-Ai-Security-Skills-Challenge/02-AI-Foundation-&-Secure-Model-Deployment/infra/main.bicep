// Main Bicep template for AI Infrastructure Foundation
// This template deploys storage foundation and Azure OpenAI service for AI workloads

targetScope = 'subscription'

// Parameters
@description('Environment name for resource naming (e.g., dev, test, prod)')
param environmentName string = 'aisec'

@description('Location for deploying resources')
param location string = 'East US'

@description('User account Object ID for Storage Blob Data Contributor access (resolved by PowerShell script)')
param storageBlobContributorAccount string

@description('Resource group name for AI resources')
param aiResourceGroupName string = 'rg-${environmentName}-ai'

@description('Enable Azure OpenAI service deployment')
param enableOpenAI bool = false

@description('Deploy GPT-5 model')
param deployGPT5 bool = true

@description('Deploy o4-mini model (recommended for labs)')
param deployo4Mini bool = false

@description('Deploy text embedding model')
param deployTextEmbedding bool = false

// Variables
var resourceToken = toLower('${environmentName}${substring(uniqueString(subscription().id), 0, 6)}')
var tags = {
  Environment: environmentName
  Project: 'Azure-AI-Security-Skills-Challenge-Week2'
  DeployedBy: 'Bicep-IaC'
  'azd-env-name': environmentName
  Component: 'AI-Storage-Foundation'
}

// Resource Group for AI resources
resource aiResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: aiResourceGroupName
  location: location
  tags: tags
}

// AI Storage Foundation (always deployed for storage foundation)
module aiStorage 'modules/storage/ai-storage.bicep' = {
  scope: aiResourceGroup
  name: 'aiStorageDeployment'
  params: {
    location: location
    resourceToken: resourceToken
    tags: tags
    storageBlobContributorAccount: storageBlobContributorAccount
  }
}

// Azure OpenAI Service (conditional deployment)
module openAIService 'modules/openai/openai-service.bicep' = if (enableOpenAI) {
  scope: aiResourceGroup
  name: 'openAIServiceDeployment'
  params: {
    location: location
    resourceToken: resourceToken
    tags: tags
    deployGPT5: deployGPT5
    deployo4Mini: deployo4Mini
    deployTextEmbedding: deployTextEmbedding
  }
}

// Outputs - Storage foundation and OpenAI specific
output aiResourceGroupName string = aiResourceGroup.name
output aiResourceGroupId string = aiResourceGroup.id
output storageAccountName string = aiStorage.outputs.storageAccountName
output aiDataContainerName string = aiStorage.outputs.aiDataContainerName
output aiLogsContainerName string = aiStorage.outputs.aiLogsContainerName
output aiModelsContainerName string = aiStorage.outputs.aiModelsContainerName
output blobEndpoint string = aiStorage.outputs.blobEndpoint

output deploymentSummary object = {
  aiResourceGroup: aiResourceGroup.name
  location: location
  storageAccountName: aiStorage.outputs.storageAccountName
  openAIEnabled: enableOpenAI
  estimatedStorageCost: '~$5-10/month for AI storage workloads'
  estimatedOpenAICost: enableOpenAI ? 'Models deployed - check Azure portal for details' : 'OpenAI not deployed'
}

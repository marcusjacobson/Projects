// Main Bicep template for AI Storage Foundation
// This template deploys storage foundation for AI workloads

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

// Outputs - Storage foundation specific
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
  estimatedMonthlyCost: '~$5-10/month for AI storage workloads'
}

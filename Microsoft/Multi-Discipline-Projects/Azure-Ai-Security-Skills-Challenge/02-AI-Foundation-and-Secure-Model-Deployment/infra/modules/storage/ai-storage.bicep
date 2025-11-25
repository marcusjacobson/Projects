// AI Storage Foundation Module
// Deploys storage accounts optimized for AI workloads with cost controls

@description('Location for resource deployment')
param location string

@description('Resource token for unique naming')
param resourceToken string

@description('Resource tags')
param tags object

@description('Enable diagnostic settings')
param enableDiagnostics bool = false

@description('User account to grant Storage Blob Data Contributor access')
param storageBlobContributorAccount string

// Variables
var storageAccountName = 'stai${resourceToken}'
var aiContainerName = 'ai-data'
var logsContainerName = 'ai-logs'
var modelsContainerName = 'ai-models'

// Storage Account for AI workloads
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS' // Cost-effective for AI workloads
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    networkAcls: {
      defaultAction: 'Allow' // Start permissive, tighten in production
      bypass: 'AzureServices'
    }
  }
}

// Blob Service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: false // Cost optimization: disable soft delete for lab environment
    }
    isVersioningEnabled: false // Cost optimization: disable versioning initially
  }
}

// File Service - disable soft delete for cost optimization
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: false // Cost optimization: disable file service soft delete for lab environment
    }
  }
}

// Container for AI data processing
resource aiDataContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: aiContainerName
  properties: {
    publicAccess: 'None'
  }
}

// Container for AI logs and outputs
resource aiLogsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: logsContainerName
  properties: {
    publicAccess: 'None'
  }
}

// Container for AI models (if needed)
resource aiModelsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: modelsContainerName
  properties: {
    publicAccess: 'None'
  }
}

// Diagnostic settings (if enabled) - Metrics only for storage foundation
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: storageAccount
  name: 'ai-storage-diagnostics'
  properties: {
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30 // Cost optimization: limited retention
        }
      }
    ]
  }
}

// Role assignment for Storage Blob Data Contributor
resource storageDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, storageBlobContributorAccount, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    principalId: storageBlobContributorAccount
    principalType: 'User'
  }
}

// Outputs
output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output aiDataContainerName string = aiDataContainer.name
output aiLogsContainerName string = aiLogsContainer.name
output aiModelsContainerName string = aiModelsContainer.name
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob

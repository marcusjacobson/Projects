// Log Analytics workspace for security monitoring and analysis
@description('Name of the Log Analytics workspace')
param workspaceName string

@description('Location for the workspace')
param location string

@description('Resource tags')
param tags object = {}

@description('Workspace retention in days')
param retentionInDays int = 90

@description('Workspace daily quota in GB (-1 for unlimited)')
param dailyQuotaGb int = -1

// Log Analytics Workspace for Defender integration
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Enable security solutions
resource securitySolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'Security(${logAnalyticsWorkspace.name})'
  location: location
  tags: tags
  plan: {
    name: 'Security(${logAnalyticsWorkspace.name})'
    product: 'OMSGallery/Security'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
}

output workspaceId string = logAnalyticsWorkspace.id
output workspaceName string = logAnalyticsWorkspace.name
output customerId string = logAnalyticsWorkspace.properties.customerId

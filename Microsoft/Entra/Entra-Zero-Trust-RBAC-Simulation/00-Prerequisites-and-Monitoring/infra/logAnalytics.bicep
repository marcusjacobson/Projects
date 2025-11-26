@description('The name of the Log Analytics Workspace.')
param workspaceName string

@description('The location of the Log Analytics Workspace.')
param location string

@description('The SKU of the Log Analytics Workspace.')
param sku string = 'PerGB2018'

@description('The retention period in days.')
param retentionInDays int = 90

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
}

output workspaceId string = logAnalyticsWorkspace.id

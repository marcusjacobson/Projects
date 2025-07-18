param location string
param workspaceName string
param retentionInDays int
param sku string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    retentionInDays: retentionInDays
    sku: {
      name: sku
    }
  }
}

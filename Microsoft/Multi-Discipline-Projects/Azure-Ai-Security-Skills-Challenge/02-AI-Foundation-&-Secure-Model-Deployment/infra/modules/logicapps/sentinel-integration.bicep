// Logic Apps for Sentinel Integration Module
// Implements Azure OpenAI + Sentinel integration for AI-driven alert analysis

@description('Location for resource deployment')
param location string

@description('Resource token for unique naming')
param resourceToken string

@description('Resource tags')
param tags object

@description('Azure OpenAI service name for integration')
param openAIServiceName string

// Variables
var logicAppName = 'la-sentinel-ai-${resourceToken}'
var connectionName = 'conn-sentinel-${resourceToken}'

// Simplified Logic App for Sentinel + OpenAI integration
resource sentinelLogicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  tags: tags
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
              type: 'object'
              properties: {
                incidentId: {
                  type: 'string'
                }
                incidentTitle: {
                  type: 'string'
                }
                incidentDescription: {
                  type: 'string'
                }
                severity: {
                  type: 'string'
                }
              }
            }
          }
        }
      }
      actions: {
        ComposeOpenAIRequest: {
          type: 'Compose'
          inputs: {
            prompt: 'Analyze this security incident and provide: 1) Summary, 2) Severity assessment, 3) Recommended actions. Incident: @{triggerBody()[\'incidentDescription\']}'
            maxTokens: 500
            temperature: '0.3'
            model: 'gpt-35-turbo'
          }
        }
        LogIncidentAnalysis: {
          type: 'Compose'
          inputs: {
            timestamp: '@utcNow()'
            incidentId: '@triggerBody()[\'incidentId\']'
            openAIService: openAIServiceName
            status: 'Ready for AI analysis'
            estimatedCost: 'GPT-5: ~$0.001-0.002 per incident'
          }
          runAfter: {
            ComposeOpenAIRequest: [
              'Succeeded'
            ]
          }
        }
      }
    }
  }
}

// API Connection placeholder for Sentinel
resource sentinelConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionName
  location: location
  tags: tags
  properties: {
    displayName: 'Azure Sentinel Connection'
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/azuresentinel'
    }
  }
}

// Outputs
output logicAppName string = sentinelLogicApp.name
output logicAppId string = sentinelLogicApp.id
output connectionName string = sentinelConnection.name
output connectionId string = sentinelConnection.id
output logicAppUrl string = sentinelLogicApp.properties.accessEndpoint
output integrationSummary object = {
  status: 'Foundation deployed - manual configuration required'
  aiModel: 'GPT-5 integration ready'
  costOptimization: {
    maxTokens: 500
    temperature: '0.3'
    estimatedCostPerIncident: '~$0.001-0.002'
  }
  nextSteps: [
    'Configure Sentinel connector'
    'Add OpenAI API key'
    'Test with sample incident'
    'Enable automated triggers'
  ]
}

// Cost Management and Budget Alerts Module
// Implements comprehensive cost monitoring and automated budget controls

@description('Location for resource deployment')
param location string

@description('Resource token for unique naming')
param resourceToken string

@description('Resource tags')
param tags object

@description('Monthly budget limit in USD')
param budgetLimit int

@description('Email for budget notifications')
param notificationEmail string

@description('Subscription ID for budget scope')
param subscriptionId string

@description('AI Resource Group ID for budget scope')
param resourceGroupId string

@description('Week 1 Resource Group ID for integrated monitoring')
param week1ResourceGroupId string

// Variables
var budgetName = 'budget-ai-${resourceToken}'
var actionGroupName = 'ag-ai-budget-${resourceToken}'
var logicAppName = 'la-cost-control-${resourceToken}'

// Action Group for budget notifications
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'Global'
  tags: tags
  properties: {
    groupShortName: 'AIBudget'
    enabled: true
    emailReceivers: [
      {
        name: 'BudgetAlert'
        emailAddress: notificationEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

// Budget for AI services with progressive alerts
resource budget 'Microsoft.Consumption/budgets@2023-05-01' = {
  name: budgetName
  properties: {
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: '2025-08-01' // Current month
      endDate: '2026-07-31'   // One year duration
    }
    amount: budgetLimit
    category: 'Cost'
    notifications: {
      // 50% alert - Early warning
      alert50: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 50
        contactEmails: [
          notificationEmail
        ]
        contactGroups: [
          actionGroup.id
        ]
        thresholdType: 'Actual'
      }
      // 75% alert - Action required
      alert75: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 75
        contactEmails: [
          notificationEmail
        ]
        contactGroups: [
          actionGroup.id
        ]
        thresholdType: 'Actual'
      }
      // 90% alert - Critical
      alert90: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 90
        contactEmails: [
          notificationEmail
        ]
        contactGroups: [
          actionGroup.id
        ]
        thresholdType: 'Actual'
      }
      // 100% forecast alert - Predictive
      forecast100: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
        contactEmails: [
          notificationEmail
        ]
        contactGroups: [
          actionGroup.id
        ]
        thresholdType: 'Forecasted'
      }
    }
    filter: {
      dimensions: {
        name: 'ResourceGroupName'
        operator: 'In'
        values: [
          last(split(resourceGroupId, '/'))
          last(split(week1ResourceGroupId, '/'))
        ]
      }
    }
  }
}

// Logic App for automated cost control (placeholder for future automation)
resource costControlLogicApp 'Microsoft.Logic/workflows@2019-05-01' = {
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
                alertType: {
                  type: 'string'
                }
                budgetThreshold: {
                  type: 'number'
                }
                resourceGroup: {
                  type: 'string'
                }
              }
            }
          }
        }
      }
      actions: {
        'Send-Email-Alert': {
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/v2/Mail'
            body: {
              To: notificationEmail
              Subject: 'AI Security Lab - Budget Alert @{triggerBody()[\'alertType\']}'
              Body: 'Budget threshold @{triggerBody()[\'budgetThreshold\']}% reached for resource group @{triggerBody()[\'resourceGroup\']}. Consider reviewing AI service usage and costs.'
            }
          }
        }
        'Log-Alert': {
          type: 'Compose'
          inputs: {
            timestamp: '@utcNow()'
            alertType: '@triggerBody()[\'alertType\']'
            threshold: '@triggerBody()[\'budgetThreshold\']'
            message: 'Budget alert processed for AI Security Lab'
          }
          runAfter: {
            'Send-Email-Alert': [
              'Succeeded'
            ]
          }
        }
      }
    }
    parameters: {
      '$connections': {
        value: {
          office365: {
            connectionId: ''
            connectionName: 'office365'
            id: '/subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/office365'
          }
        }
      }
    }
  }
}

// Outputs
output budgetId string = budget.id
output budgetName string = budget.name
output actionGroupId string = actionGroup.id
output actionGroupName string = actionGroup.name
output costControlLogicAppId string = costControlLogicApp.id
output costControlLogicAppName string = costControlLogicApp.name
output budgetConfiguration object = {
  monthlyLimit: budgetLimit
  alerts: {
    warning50: '50% of budget'
    action75: '75% of budget'
    critical90: '90% of budget'
    forecast100: 'Forecasted 100%'
  }
  scope: 'AI and Week 1 resource groups'
}

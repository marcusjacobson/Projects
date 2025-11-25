// Main Bicep template for Microsoft Defender for Cloud deployment
// This template orchestrates the deployment of Defender for Cloud with enhanced security features

targetScope = 'subscription'

// Parameters
@description('Environment name for resource naming (e.g., dev, test, prod)')
param environmentName string = 'aisec'

@description('Location for deploying resources')
param location string = 'East US'

@description('Email address for security notifications')
@secure()
param securityContactEmail string

@description('Resource group name for test resources')
param resourceGroupName string = 'rg-${environmentName}-defender-test'

@description('Administrator username for virtual machines')
param adminUsername string = 'azureuser'

@description('Administrator password for virtual machines')
@secure()
param adminPassword string

@description('Enable Defender for Servers Plan 2')
param enableDefenderForServers bool = true

@description('Enable Defender for Storage')
param enableDefenderForStorage bool = true

@description('Enable Defender for Key Vault')
param enableDefenderForKeyVault bool = true

@description('Enable Defender for Containers')
param enableDefenderForContainers bool = true

// Variables
var resourceToken = toLower('${environmentName}${substring(uniqueString(subscription().id), 0, 6)}')
var tags = {
  Environment: environmentName
  Project: 'Azure-AI-Security-Skills-Challenge'
  DeployedBy: 'Bicep-IaC'
  'azd-env-name': environmentName
}

// Resource Group for test resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Log Analytics Workspace for Defender integration
module logAnalytics 'modules/monitoring/log-analytics.bicep' = {
  name: 'deploy-log-analytics'
  scope: resourceGroup
  params: {
    workspaceName: 'law-${environmentName}-${resourceToken}'
    location: location
    tags: tags
  }
}

// Defender for Cloud Pricing Configuration
module defenderPricing 'modules/security/defender-pricing.bicep' = {
  name: 'deploy-defender-pricing'
  scope: subscription()
  params: {
    enableDefenderForServers: enableDefenderForServers
    enableDefenderForStorage: enableDefenderForStorage
    enableDefenderForKeyVault: enableDefenderForKeyVault
    enableDefenderForContainers: enableDefenderForContainers
  }
}

// Security Contacts Configuration
module securityContacts 'modules/security/security-contacts.bicep' = {
  name: 'deploy-security-contacts'
  scope: subscription()
  params: {
    emailAddress: securityContactEmail
  }
  dependsOn: [
    defenderPricing
  ]
}

// Test Virtual Machines for monitoring
module virtualMachines 'modules/compute/virtual-machines.bicep' = {
  name: 'deploy-test-vms'
  scope: resourceGroup
  params: {
    environmentName: environmentName
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    resourceToken: resourceToken
    tags: tags
  }
  dependsOn: [
    logAnalytics
    defenderPricing
  ]
}

// Outputs
output resourceGroupName string = resourceGroup.name
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output windowsVmName string = virtualMachines.outputs.windowsVmName
output linuxVmName string = virtualMachines.outputs.linuxVmName
output deploymentStatus string = 'Microsoft Defender for Cloud deployment completed successfully'

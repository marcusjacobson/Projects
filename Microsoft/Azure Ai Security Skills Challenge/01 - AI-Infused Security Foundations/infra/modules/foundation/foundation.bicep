// Microsoft Defender for Cloud - Infrastructure Foundation Template
// Creates the foundational infrastructure for security monitoring and analysis

targetScope = 'resourceGroup'

@description('Environment name identifier (e.g., securitylab, testlab, demo)')
param environmentName string

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Resource token for unique naming')
param resourceToken string

@description('Tags to apply to all resources')
param tags object = {
  Environment: environmentName
  Purpose: 'Microsoft-Defender-for-Cloud-Lab'
  'azd-env-name': environmentName
  DeployedBy: 'IaC-Modular-Guide'
}

// Variables for consistent naming
var logAnalyticsWorkspaceName = 'log-aisec-defender-${environmentName}-${resourceToken}'
var virtualNetworkName = 'vnet-aisec-defender-${environmentName}-${resourceToken}'
var networkSecurityGroupName = 'nsg-aisec-defender-${environmentName}-${resourceToken}'

// Log Analytics Workspace for security monitoring
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: 5
    }
  }
}

// Network Security Group with baseline security rules
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: networkSecurityGroupName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'DenyAllInbound'
        properties: {
          description: 'Default deny all inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          description: 'Allow Azure Load Balancer health probes'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Virtual Network with security-optimized subnets
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-compute'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
      {
        name: 'subnet-management'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

// Outputs for use by other templates
@description('Resource ID of the Log Analytics workspace')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id

@description('Name of the Log Analytics workspace')
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name

@description('Resource ID of the virtual network')
output virtualNetworkId string = virtualNetwork.id

@description('Name of the virtual network')
output virtualNetworkName string = virtualNetwork.name

@description('Resource ID of the compute subnet')
output computeSubnetId string = virtualNetwork.properties.subnets[0].id

@description('Resource ID of the management subnet')
output managementSubnetId string = virtualNetwork.properties.subnets[1].id

@description('Resource ID of the network security group')
output networkSecurityGroupId string = networkSecurityGroup.id

@description('Name of the network security group')
output networkSecurityGroupName string = networkSecurityGroup.name

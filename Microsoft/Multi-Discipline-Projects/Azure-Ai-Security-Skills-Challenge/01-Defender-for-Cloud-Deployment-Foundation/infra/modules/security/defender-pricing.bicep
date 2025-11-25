// Defender for Cloud pricing configuration
// Enables enhanced security features across subscription

targetScope = 'subscription'

@description('Enable Defender for Servers Plan 2')
param enableDefenderForServers bool = true

@description('Enable Defender for Storage')
param enableDefenderForStorage bool = true

@description('Enable Defender for Key Vault')
param enableDefenderForKeyVault bool = true

@description('Enable Defender for Containers')
param enableDefenderForContainers bool = true

// Defender for Servers (Plan 2 with advanced features)
resource defenderForServers 'Microsoft.Security/pricings@2024-01-01' = if (enableDefenderForServers) {
  name: 'VirtualMachines'
  properties: {
    pricingTier: 'Standard'
    subPlan: 'P2'
    extensions: [
      {
        name: 'AgentlessVmScanning'
        isEnabled: 'True'
        additionalExtensionProperties: {}
      }
      {
        name: 'MdeDesignatedSubscription'
        isEnabled: 'True'
        additionalExtensionProperties: {}
      }
    ]
  }
}

// Defender for Storage (with malware scanning)
resource defenderForStorage 'Microsoft.Security/pricings@2024-01-01' = if (enableDefenderForStorage) {
  name: 'StorageAccounts'
  properties: {
    pricingTier: 'Standard'
    subPlan: 'DefenderForStorageV2'
    extensions: [
      {
        name: 'OnUploadMalwareScanning'
        isEnabled: 'True'
        additionalExtensionProperties: {
          CapGBPerMonthPerStorageAccount: '5000'
        }
      }
      {
        name: 'SensitiveDataDiscovery'
        isEnabled: 'True'
        additionalExtensionProperties: {}
      }
    ]
  }
}

// Defender for Key Vault
resource defenderForKeyVault 'Microsoft.Security/pricings@2024-01-01' = if (enableDefenderForKeyVault) {
  name: 'KeyVaults'
  properties: {
    pricingTier: 'Standard'
  }
}

// Defender for Containers
resource defenderForContainers 'Microsoft.Security/pricings@2024-01-01' = if (enableDefenderForContainers) {
  name: 'Containers'
  properties: {
    pricingTier: 'Standard'
    extensions: [
      {
        name: 'ContainerSensor'
        isEnabled: 'True'
        additionalExtensionProperties: {}
      }
      {
        name: 'AgentlessDiscoveryForKubernetes'
        isEnabled: 'True'
        additionalExtensionProperties: {}
      }
    ]
  }
}

// Defender for Cloud Security Posture Management (Standard tier)
resource defenderCSPM 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'CloudPosture'
  properties: {
    pricingTier: 'Standard'
    extensions: [
      {
        name: 'SensitiveDataDiscovery'
        isEnabled: 'True'
        additionalExtensionProperties: {}
      }
      {
        name: 'AgentlessVmScanning'
        isEnabled: 'True'
        additionalExtensionProperties: {}
      }
    ]
  }
}

output defenderPlansEnabled array = [
  enableDefenderForServers ? 'VirtualMachines' : null
  enableDefenderForStorage ? 'StorageAccounts' : null
  enableDefenderForKeyVault ? 'KeyVaults' : null
  enableDefenderForContainers ? 'Containers' : null
  'CloudPosture'
]

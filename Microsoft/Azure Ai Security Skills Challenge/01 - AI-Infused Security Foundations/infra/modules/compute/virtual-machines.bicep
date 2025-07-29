// Test virtual machines for Defender for Cloud monitoring
@description('Environment name for resource naming')
param environmentName string

@description('Location for resources')
param location string

@description('Administrator username')
param adminUsername string

@description('Administrator password')
@secure()
param adminPassword string

@description('Unique resource token')
param resourceToken string

@description('Resource tags')
param tags object = {}

// Virtual Network for test VMs
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-${environmentName}-${resourceToken}'
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
        name: 'subnet-default'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

// Network Security Group with basic rules
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-${environmentName}-${resourceToken}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSSH'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1001
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Windows Server VM
resource windowsVmNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-vm-windows-${resourceToken}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          publicIPAddress: {
            id: windowsVmPublicIP.id
          }
        }
      }
    ]
  }
}

resource windowsVmPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-vm-windows-${resourceToken}'
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: 'win-${resourceToken}'
    }
  }
  sku: {
    name: 'Standard'
  }
}

resource windowsVm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-windows-${resourceToken}'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: 'vm-windows'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: windowsVmNic.id
        }
      ]
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Linux Ubuntu VM
resource linuxVmNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-vm-linux-${resourceToken}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          publicIPAddress: {
            id: linuxVmPublicIP.id
          }
        }
      }
    ]
  }
}

resource linuxVmPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-vm-linux-${resourceToken}'
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: 'linux-${resourceToken}'
    }
  }
  sku: {
    name: 'Standard'
  }
}

resource linuxVm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-linux-${resourceToken}'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1ms'
    }
    osProfile: {
      computerName: 'vm-linux'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: linuxVmNic.id
        }
      ]
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output windowsVmName string = windowsVm.name
output linuxVmName string = linuxVm.name
output virtualNetworkId string = virtualNetwork.id
output windowsVmPublicIP string = windowsVmPublicIP.properties.ipAddress
output linuxVmPublicIP string = linuxVmPublicIP.properties.ipAddress

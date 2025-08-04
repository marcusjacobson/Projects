// Security contacts configuration for Defender for Cloud notifications
targetScope = 'subscription'

@description('Email address for security notifications')
param emailAddress string

// Configure security contact for notifications
resource securityContact 'Microsoft.Security/securityContacts@2023-12-01-preview' = {
  name: 'default'
  properties: {
    emails: emailAddress
    phone: ''
    isEnabled: true
    notificationsByRole: {
      state: 'On'
      roles: [
        'Owner'
        'Contributor'
        'ServiceAdmin'
      ]
    }
    notificationsSources: [
      {
        sourceType: 'Alert'
        minimalSeverity: 'Medium'
      }
    ]
  }
}

output securityContactEmail string = emailAddress

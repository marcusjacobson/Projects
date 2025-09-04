# Infrastructure as Code (IaC) - AI Foundation & Secure Model Deployment

This folder contains comprehensive Infrastructure as Code templates for deploying AI-driven security operations infrastructure on Azure. The templates use Bicep (Azure Resource Manager) to provide consistent, repeatable deployments with cost optimization, security hardening, and integration capabilities.

## 📋 Infrastructure Overview

### Deployment Architecture

The infrastructure supports a complete AI foundation for security operations, including:

- **Azure Storage Accounts**: Cost-optimized storage for AI data processing and prompt templates.
- **Azure OpenAI Service**: GPT-4o-mini deployment with security-focused model configurations.
- **Azure Key Vault**: Secure credential management for API keys and connection strings.
- **App Registration**: Entra ID integration for Microsoft Graph API access and authentication.
- **Cost Management**: Budget controls, monitoring, and optimization for AI service consumption.
- **Role-Based Access Control**: Comprehensive RBAC configuration for secure AI operations.

### Infrastructure Cost Optimization Features

- **Budget Controls**: Configurable monthly spending limits with automated alerts.
- **Resource Sizing**: Right-sized deployments optimized for learning and lab environments.
- **Lifecycle Management**: Automated policies for cost-effective data retention and archival.
- **Usage Monitoring**: Real-time tracking and optimization recommendations for AI services.

## 📁 Template Organization

### Core Infrastructure Files

| File | Purpose | Description |
|------|---------|-------------|
| **main.bicep** | Master template | Orchestrates complete AI foundation deployment |
| **main.parameters.json** | Configuration parameters | Centralized parameter management for all deployments |

### Modular Template Structure

```text
modules/
├── storage/
│   ├── storageAccount.bicep          # Azure Storage Account with containers
│   └── processingStorage.bicep       # Table Storage for AI workflow processing
├── openai/
│   ├── openaiService.bicep           # Azure OpenAI Service deployment
│   └── modelDeployment.bicep         # GPT-4o-mini model configuration
├── security/
│   ├── keyVault.bicep                # Key Vault for credential management
│   └── appRegistration.bicep         # Entra ID app registration
├── monitoring/
│   ├── budgetAlert.bicep             # Cost management and budget alerts
│   └── costOptimization.bicep        # Usage monitoring and optimization
└── networking/
    └── privateEndpoints.bicep        # Network security and private connectivity
```

## 🔧 Deployment Configuration

### Parameter Management

All deployments use the centralized `main.parameters.json` file for consistent configuration:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environmentName": { "value": "aisec" },
    "location": { "value": "East US" },
    "notificationEmail": { "value": "admin@company.com" },
    "monthlyBudgetLimit": { "value": 150 },
    "enableOpenAI": { "value": true },
    "enableCostManagement": { "value": true }
  }
}
```

### Key Configuration Parameters

| Parameter Category | Key Parameters | Purpose |
|-------------------|----------------|---------|
| **Foundation** | `environmentName`, `location`, `notificationEmail` | Basic deployment configuration |
| **Cost Management** | `monthlyBudgetLimit`, `enableCostAlerts` | Budget controls and monitoring |
| **AI Services** | `enableOpenAI`, `openAIModelCapacity` | OpenAI service configuration |
| **Security** | `enablePrivateEndpoints`, `keyVaultAccessPolicies` | Security hardening settings |
| **Storage** | `storageAccountType`, `enableLifecyclePolicies` | Storage optimization |

## 🚀 Deployment Methods

### Option 1: Automated PowerShell Deployment

**Recommended for production deployments**:

```powershell
# Deploy complete AI foundation using automation scripts
cd "../scripts/scripts-deployment"
.\Deploy-AIFoundation.ps1 -UseParametersFile
```

### Option 2: Direct Bicep Deployment

**For advanced users and custom configurations**:

```bash
# Deploy using Azure CLI
az deployment sub create \
  --location "East US" \
  --template-file "main.bicep" \
  --parameters "@main.parameters.json"
```

### Option 3: Azure Portal Deployment

**For learning and validation purposes**:

1. Navigate to Azure Portal → Deploy a custom template
2. Upload `main.bicep` template file
3. Configure parameters through Portal interface
4. Review and deploy infrastructure

## 🛡️ Security Architecture

### Built-in Security Features

- **Managed Identity Integration**: Passwordless authentication between Azure services.
- **Key Vault Integration**: Centralized secret management with automated rotation.
- **Network Security**: Private endpoints and virtual network integration options.
- **RBAC Configuration**: Least-privilege access control for all resource interactions.
- **Encryption**: Encryption at rest and in transit for all data and communications.

### Role-Based Access Control

The templates automatically configure these RBAC assignments:

| Service | Role | Scope | Purpose |
|---------|------|-------|---------|
| **Storage Account** | Storage Blob Data Contributor | User account | Development and testing access |
| **Storage Account** | Storage Table Data Contributor | Logic Apps identity | AI workflow processing |
| **OpenAI Service** | Cognitive Services OpenAI User | Logic Apps identity | AI model inference |
| **Key Vault** | Key Vault Secrets User | Service principals | Secure credential access |

### Network Security Options

- **Public Access**: Default configuration for learning environments with firewall rules.
- **Private Endpoints**: Optional configuration for production deployments.
- **Virtual Network Integration**: Support for existing network infrastructure.
- **Firewall Rules**: IP-based access restrictions for enhanced security.

## 💰 Cost Management Integration

### Budget Control Implementation

```bicep
resource budgetAlert 'Microsoft.Consumption/budgets@2023-05-01' = {
  name: 'ai-foundation-budget'
  properties: {
    amount: monthlyBudgetLimit
    timeGrain: 'Monthly'
    notifications: {
      'budget-alert-80': {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        contactEmails: [notificationEmail]
      }
    }
  }
}
```

### Template Cost Optimization Features

- **Resource Sizing**: Templates use cost-effective SKUs optimized for learning environments.
- **Lifecycle Policies**: Automated data archival and cleanup to minimize storage costs.
- **Usage Monitoring**: Built-in dashboards and alerts for cost tracking and optimization.
- **Scaling Controls**: Configurable capacity limits to prevent cost overruns.

## 🔄 Template Validation and Testing

### Pre-Deployment Validation

```bash
# Validate Bicep template syntax and configuration
az deployment sub validate \
  --location "East US" \
  --template-file "main.bicep" \
  --parameters "@main.parameters.json"
```

### Post-Deployment Testing

```powershell
# Comprehensive infrastructure validation
cd "../scripts/scripts-validation"
.\Test-AIFoundationReadiness.ps1 -UseParametersFile
```

### Template Quality Assurance

- **Bicep Linting**: Automated code quality checks and best practice enforcement.
- **Parameter Validation**: Type checking and constraint validation for all parameters.
- **Dependency Management**: Proper resource dependency ordering and error handling.
- **Idempotency**: Templates can be safely re-run without causing configuration drift.

## 📊 Monitoring and Observability

### Built-in Monitoring

- **Azure Monitor Integration**: Comprehensive logging and metrics for all deployed resources.
- **Cost Monitoring**: Real-time cost tracking and budget utilization dashboards.
- **Performance Metrics**: AI service usage, storage consumption, and access patterns.
- **Security Monitoring**: Access logs, failed authentication attempts, and security alerts.

### Alert Configuration

The templates configure these automated alerts:

| Alert Type | Threshold | Purpose |
|------------|-----------|---------|
| **Budget Alert** | 80% of monthly limit | Cost control and spending awareness |
| **AI Usage Alert** | High token consumption | Usage monitoring and optimization |
| **Storage Alert** | Storage capacity thresholds | Capacity planning and lifecycle management |
| **Security Alert** | Failed access attempts | Security monitoring and incident detection |

## 🎯 Template Customization

### Environment-Specific Configurations

**Development Environment**:

```json
{
  "environmentName": { "value": "dev" },
  "monthlyBudgetLimit": { "value": 50 },
  "openAIModelCapacity": { "value": 50 },
  "storageAccountType": { "value": "Standard_LRS" }
}
```

**Production Environment**:

```json
{
  "environmentName": { "value": "prod" },
  "monthlyBudgetLimit": { "value": 1000 },
  "openAIModelCapacity": { "value": 500 },
  "storageAccountType": { "value": "Standard_GRS" },
  "enablePrivateEndpoints": { "value": true }
}
```

### Template Extension Guidelines

- **Modular Design**: Add new modules to the `modules/` directory for additional services.
- **Parameter Management**: Extend `main.parameters.json` with new configuration options.
- **Dependency Management**: Ensure proper resource dependencies and deployment ordering.
- **Security Integration**: Maintain security standards and RBAC consistency.

## 🔧 Troubleshooting and Maintenance

### Common Deployment Issues

| Issue | Cause | Resolution |
|-------|-------|-----------|
| **Quota Exceeded** | Insufficient Azure resource quotas | Request quota increase through Azure Support |
| **Permission Denied** | Missing deployment permissions | Verify Contributor/Owner role on subscription |
| **Resource Conflicts** | Existing resources with same names | Update `environmentName` parameter for uniqueness |
| **Template Validation** | Parameter or syntax errors | Use `az deployment sub validate` command |

### Maintenance Best Practices

- **Regular Updates**: Keep Bicep templates updated with latest Azure resource API versions.
- **Parameter Reviews**: Regularly review and optimize parameter configurations.
- **Cost Monitoring**: Monitor spending patterns and adjust budgets as needed.
- **Security Audits**: Regular security reviews and access control validation.

## 📈 Next Steps

### Immediate Actions

1. **Review Parameters**: Customize `main.parameters.json` for your environment requirements.
2. **Choose Deployment Method**: Select appropriate deployment approach based on experience level.
3. **Validate Templates**: Run pre-deployment validation to ensure configuration correctness.
4. **Execute Deployment**: Deploy infrastructure using preferred method with comprehensive testing.

### Post-Deployment Path

1. **Validate Infrastructure**: Run post-deployment validation scripts to confirm successful deployment.
2. **Configure AI Services**: Proceed to model customization and prompt template configuration.
3. **Monitor Performance**: Establish regular monitoring of costs, usage, and performance metrics.
4. **Plan Scaling**: Prepare for expanded AI integration and additional use case deployment.

---

## 🤖 AI-Assisted Content Generation

This comprehensive Infrastructure as Code documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Azure IaC best practices, Bicep template design patterns, and enterprise-grade infrastructure deployment strategies.

*AI tools were used to enhance productivity and ensure comprehensive coverage of infrastructure deployment scenarios while maintaining technical accuracy and reflecting current Azure Resource Manager and Bicep best practices for AI-driven security infrastructure.*

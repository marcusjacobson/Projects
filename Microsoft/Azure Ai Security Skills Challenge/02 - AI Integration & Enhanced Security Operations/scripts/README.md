# AI Integration & Enhanced Security Operations Scripts

This folder contains a comprehensive suite of PowerShell scripts for deploying, configuring, and managing AI-driven security operations with automated cost management and budget controls. Scripts are organized into specialized folders for better maintainability and workflow management.

## � Folder Organization

### 🎬 scripts-orchestration/

| Folder | Purpose | Description |
|--------|---------|-------------|
| **🎬 scripts-orchestration/** | Master Orchestrators | Coordinate multiple deployment phases and components |
| **🏗️ scripts-deployment/** | Component Deployment | Individual deployment scripts for specific services |
| **✅ scripts-validation/** | Testing & Validation | Verify deployments and configurations |
| **🧹 scripts-decommission/** | Cleanup & Removal | Safe infrastructure decommissioning scripts |
| **📚 lib/** | Helper Functions | Shared utilities used across deployment scripts |
| **📄 templates/** | Configuration Templates | ARM template files for various services |


## 🚀 Quick Start

### Complete AI Foundation Deployment

For a full end-to-end AI foundation deployment:

```powershell
# Complete deployment with preview
cd "scripts\scripts-orchestration"
.\Deploy-DefenderXDRIntegration.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com" -WhatIf

# Execute complete AI foundation deployment
cd "scripts\scripts-orchestration"
.\Deploy-DefenderXDRIntegration.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com"
```

### Modular Component Deployment

Deploy individual components for controlled automation:

```powershell
# Deploy AI storage foundation
cd "scripts\scripts-deployment"
.\Deploy-StorageFoundation.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com"

# Deploy cost management and budget controls
cd "scripts\scripts-deployment"
.\Deploy-CostManagement.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com" -BudgetLimit 150
```

## 📁 Available Scripts

### 🎬 Orchestration Scripts (scripts-orchestration/)

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Deploy-DefenderXDRIntegration.ps1** | Complete XDR integration orchestrator | Multi-phase execution, Key Vault management, API connections |

### 🏗️ Foundation Deployment Scripts (scripts-deployment/)

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Deploy-StorageFoundation.ps1** | Deploy AI storage accounts | Cost-optimized storage, containers, lifecycle policies |
| **Deploy-AIFoundation.ps1** | Complete AI foundation deployment | OpenAI service, storage, and monitoring integration |
| **Deploy-OpenAIService.ps1** | Deploy Azure OpenAI service | GPT-4o-mini, cost-effective models, capacity controls |
| **Deploy-KeyVault.ps1** | Secure credential storage | OpenAI secrets, app registration credentials |
| **Deploy-AppRegistration.ps1** | Entra ID app registration | Microsoft Graph permissions, secure authentication |
| **Deploy-APIConnections.ps1** | Logic Apps API connections | OpenAI, Table Storage, Microsoft Graph integration |
| **Deploy-LogicAppWorkflow.ps1** | Logic Apps workflow deployment | ARM template-based, comprehensive AI integration |
| **Deploy-ProcessingStorage.ps1** | Table Storage for duplicate prevention | Processing tracking, audit trails |

### 🤖 AI Integration Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Deploy-SentinelIntegration.ps1** | Logic Apps + Sentinel automation (Legacy) | AI-driven alert analysis, cost-optimized prompts |
| **Deploy-BuiltinAIFeatures.ps1** | Enable AI security features | UEBA, Fusion, Anomaly Detection configuration |

### ✅ Validation & Testing Scripts (scripts-validation/)

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Test-DefenderXDRIntegrationValidation.ps1** | Comprehensive XDR validation | Infrastructure validation, API testing, workflow verification |
| **Test-AIIntegration.ps1** | AI integration validation | Service validation, cost compliance, integration testing |
| **Test-StorageFoundation.ps1** | Storage foundation validation | Container access, security configuration, role assignments |
| **Test-CostCompliance.ps1** | Budget and cost validation | Cost monitoring, budget utilization, optimization recommendations |
| **Test-PromptEffectiveness.ps1** | AI prompt validation | Token usage, response quality, cost per interaction |

### 🧹 Management Scripts (scripts-decommission/)

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Remove-DefenderXDRIntegration.ps1** | Clean XDR integration resources | Safe cleanup, selective removal, comprehensive validation |
| **Remove-OpenAIInfrastructure.ps1** | OpenAI service cleanup | Phase-based removal, cost control, soft-delete handling |
| **Remove-AIInfrastructure.ps1** | Clean AI resources | Safe cleanup, cost control, selective removal |
| **Remove-StorageResourceGroup.ps1** | Storage resource group cleanup | Complete resource group removal, validation |
| **Optimize-AICosts.ps1** | Cost optimization automation | Usage analysis, capacity adjustment, budget optimization |
| **Monitor-AIUsage.ps1** | Real-time AI monitoring | Token tracking, cost analysis, usage patterns |

## 💰 Cost Management Features

### Budget Control Scripts

- **Progressive alerts** at 50%, 75%, 90% of budget
- **Automated notifications** with detailed cost breakdown
- **Service shutdown** capabilities for budget compliance
- **Cost optimization** recommendations and automation

### AI Service Cost Controls

- **GPT-5** deployment (90% cost savings vs GPT-4)
- **Token limits** and prompt optimization
- **Capacity management** with minimal viable units
- **Usage monitoring** and pattern analysis

## 🔧 Helper Functions

### Core Library (`lib/Helper-Functions.ps1`)

Common functions used across all AI integration scripts:

- **Write-AIHeader**: Consistent script headers with environment info
- **Initialize-AzureConnection**: Azure PowerShell connection management
- **Test-StorageDeployment**: Storage account validation
- **Test-OpenAIDeployment**: Azure OpenAI service validation
- **Test-CostManagementDeployment**: Budget and alert validation
- **Invoke-SecurityValidation**: Security configuration checks
- **Get-CostEstimate**: Real-time cost estimation
- **Write-CostSummary**: Budget utilization reporting

## 📋 Template Files

### Configuration Templates (`templates/`)

| Template | Purpose | Configuration |
|----------|---------|---------------|
| **openai-deployment.json** | OpenAI model deployment | GPT-5, capacity settings, cost controls |
| **logic-app-sentinel.json** | Sentinel integration workflow | AI automation, prompt templates, cost optimization |
| **cost-alert-rules.json** | Budget monitoring templates | Progressive alerts, notification settings |

## 🎯 Deployment Patterns

### Phase 1: Foundation & Cost Controls

```powershell
cd "scripts\scripts-deployment"
.\Deploy-StorageFoundation.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com"
cd "scripts\scripts-deployment"
.\Deploy-CostManagement.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com" -BudgetLimit 150
```

### Phase 2: AI Services

```powershell
cd "scripts\scripts-deployment"
.\Deploy-OpenAIService.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com"
cd "scripts\scripts-orchestration"
.\Deploy-DefenderXDRIntegration.ps1 -EnvironmentName "aisec"
```

### Phase 3: Enhanced Features

```powershell
cd "scripts\scripts-deployment"
.\Deploy-BuiltinAIFeatures.ps1 -EnvironmentName "aisec"
cd "scripts\scripts-validation"
.\Test-AIIntegration.ps1 -EnvironmentName "aisec"
```

## 📊 Validation Framework

### Multi-Level Validation

1. **Resource Validation**: Verify all AI services are deployed correctly
2. **Cost Compliance**: Ensure budget adherence and optimization
3. **Security Validation**: Confirm security configurations
4. **Integration Testing**: Validate AI automation workflows
5. **Performance Testing**: Assess prompt effectiveness and token usage

### Validation Scoring

Each validation script provides detailed scoring:

- **Pass/Fail Status** for each component
- **Cost Utilization** percentage and recommendations
- **Security Posture** assessment
- **Integration Readiness** score for advanced features

## 🔍 Troubleshooting

### Common Scenarios

#### AI Service Deployment Fails

```powershell
# Check quotas and regional availability
cd "scripts\scripts-validation"
.\Test-AIIntegration.ps1 -EnvironmentName "aisec" -CheckQuotas
```

#### Budget Exceeded

```powershell
# Optimize costs and adjust capacity
cd "scripts\scripts-decommission"
.\Optimize-AICosts.ps1 -EnvironmentName "aisec" -ReduceCapacity
```

#### Integration Issues

```powershell
# Validate connections and configurations
cd "scripts\scripts-validation"
.\Test-AIIntegration.ps1 -EnvironmentName "aisec" -Verbose
```

## 🔗 Integration with Week 1

These scripts build upon Week 1's Defender for Cloud foundation:

- **Shared resource groups** for cost tracking
- **Integrated monitoring** across security platforms
- **Unified cost management** for complete lab oversight
- **Consistent deployment patterns** and validation frameworks

## 📚 Best Practices

### Script Execution

1. **Always run WhatIf first** to preview changes
2. **Monitor costs continuously** during deployment
3. **Validate each phase** before proceeding
4. **Use consistent environment names** across scripts
5. **Keep notification emails current** for alerts

### Cost Management

1. **Deploy cost controls first** before AI services
2. **Monitor token usage** and optimize prompts
3. **Use minimum viable capacity** for AI services
4. **Regular cost reviews** and optimization
5. **Automated cleanup** of unused resources

---

## 🔗 Related Resources

- [Week 1 Scripts](../../01%20-%20Defender%20for%20Cloud%20Deployment%20Mastery/scripts/) - Foundation deployment scripts
- [AI Integration Guides](../) - Deployment guides and documentation
- [Week 2 Infrastructure](../infra/) - Bicep templates and configurations

---

**📋 Note**: All scripts include comprehensive error handling, validation, and cost monitoring to ensure successful AI integration within budget constraints.

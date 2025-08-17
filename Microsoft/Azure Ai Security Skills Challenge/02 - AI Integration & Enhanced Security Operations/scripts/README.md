# AI Integration & Enhanced Security Operations Scripts

This folder contains a comprehensive suite of PowerShell scripts for deploying, configuring, and managing AI-driven security operations with automated cost management and budget controls.

## 🚀 Quick Start

### Complete AI Foundation Deployment

For a full end-to-end AI foundation deployment:

```powershell
# Complete deployment with preview
.\Deploy-AIFoundation.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com" -WhatIf

# Execute complete AI foundation deployment
.\Deploy-AIFoundation.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com"
```

### Modular Component Deployment

Deploy individual components for controlled automation:

```powershell
# Deploy AI storage foundation
.\Deploy-StorageFoundation.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com"

# Deploy cost management and budget controls
.\Deploy-CostManagement.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com" -BudgetLimit 150
```

## 📁 Available Scripts

### 🎬 Orchestration Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Deploy-AIFoundation.ps1** | Complete AI foundation orchestrator | Multi-phase execution, cost controls, validation |

### 🏗️ Foundation Deployment Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Deploy-StorageFoundation.ps1** | Deploy AI storage accounts | Cost-optimized storage, containers, lifecycle policies |
| **Deploy-CostManagement.ps1** | Configure budget controls | Progressive alerts, automated monitoring, notifications |
| **Deploy-OpenAIService.ps1** | Deploy Azure OpenAI service | GPT-5, cost-effective models, capacity controls |

### 🤖 AI Integration Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Deploy-SentinelIntegration.ps1** | Logic Apps + Sentinel automation | AI-driven alert analysis, cost-optimized prompts |
| **Deploy-BuiltinAIFeatures.ps1** | Enable AI security features | UEBA, Fusion, Anomaly Detection configuration |

### ✅ Validation & Testing Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Test-AIIntegration.ps1** | Comprehensive AI validation | Service validation, cost compliance, integration testing |
| **Test-CostCompliance.ps1** | Budget and cost validation | Cost monitoring, budget utilization, optimization recommendations |
| **Test-PromptEffectiveness.ps1** | AI prompt validation | Token usage, response quality, cost per interaction |

### 🧹 Management Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Remove-AIInfrastructure.ps1** | Clean AI resources | Safe cleanup, cost control, selective removal |
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
.\Deploy-StorageFoundation.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com"
.\Deploy-CostManagement.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com" -BudgetLimit 150
```

### Phase 2: AI Services

```powershell
.\Deploy-OpenAIService.ps1 -EnvironmentName "aisec" -NotificationEmail "admin@company.com"
.\Deploy-SentinelIntegration.ps1 -EnvironmentName "aisec"
```

### Phase 3: Enhanced Features

```powershell
.\Deploy-BuiltinAIFeatures.ps1 -EnvironmentName "aisec"
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
.\Test-AIIntegration.ps1 -EnvironmentName "aisec" -CheckQuotas
```

#### Budget Exceeded

```powershell
# Optimize costs and adjust capacity
.\Optimize-AICosts.ps1 -EnvironmentName "aisec" -ReduceCapacity
```

#### Integration Issues

```powershell
# Validate connections and configurations
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

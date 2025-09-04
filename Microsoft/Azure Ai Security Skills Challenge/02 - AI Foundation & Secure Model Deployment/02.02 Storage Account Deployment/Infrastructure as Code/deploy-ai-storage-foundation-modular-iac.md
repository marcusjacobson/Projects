# Deploy AI Storage Foundation - Modular Infrastructure-as-Code Guide

This guide provides a comprehensive, step-by-step approach to deploying AI storage infrastructure using modular Infrastructure-as-Code practices. This automated approach leverages scripts for consistent, repeatable deployments while maintaining the same learning-focused experience as the portal guide.

## 🎯 Overview

This modular approach follows the same order of operations as the Azure Portal deployment guide, but leverages automated scripts for each phase. This provides:

- **Learning-Focused Experience** - Understand each storage component as you deploy it
- **Flexible Deployment** - Execute phases independently or skip steps as needed
- **Comprehensive Validation** - Multi-phase validation at every deployment step
- **Infrastructure-as-Code Best Practices** - Version-controlled, repeatable deployments

### Core Deployment Steps

This guide follows the same logical progression as manual portal deployment:

1. **Script-Based Foundation Deployment** - Automated storage account and container creation
2. **Cost Management Integration** - Automated budget and alert configuration
3. **Security Configuration Validation** - Verify encryption and access controls
4. **Storage Connectivity Testing** - Automated testing of storage access and integration readiness
5. **Documentation and Handoff** - Generate configuration summaries for AI service integration

---

## 📋 Prerequisites

Before starting, ensure you have:

- An active Azure subscription with Contributor or Owner permissions
- Azure CLI installed and authenticated to your Azure subscription
- PowerShell environment (Windows PowerShell 5.1+ or PowerShell 7+)
- Basic understanding of Azure Bicep and Infrastructure-as-Code concepts
- Week 1 Defender for Cloud foundation already deployed (recommended)

### Environment Setup and Authentication

```powershell
# Verify Azure CLI and authentication
az --version
az account show

# Set your subscription (if you have multiple)
az account set --subscription "Your-Subscription-Name-or-ID"

# Verify permissions
az role assignment list --assignee $(az account show --query user.name -o tsv) --scope /subscriptions/$(az account show --query id -o tsv)
```

**Required Permissions**: Contributor or Owner roles at subscription level.

---

## Step 1: Prepare Configuration Parameters

Configure the deployment parameters for your AI storage foundation.

### 🔧 Update Parameters File

Update the parameters in `infra/main.parameters.json`:

```json
{
  "notificationEmail": {
    "value": "your-email@domain.com"
  },
  "aiResourceGroupName": {
    "value": "rg-aisec-ai"
  },
  "storageAccountPrefix": {
    "value": "stai"
  },
  "enableAIStorage": {
    "value": true
  },
  "enableOpenAI": {
    "value": false
  },
  "enableSentinelIntegration": {
    "value": false
  },
  "budgetAmount": {
    "value": 150
  },
  "storageBudgetAmount": {
    "value": 20
  }
}
```

### 📝 Key Configuration Options

| Parameter | Purpose | Recommended Value |
|-----------|---------|------------------|
| `notificationEmail` | Cost alerts and notifications | Your email address |
| `aiResourceGroupName` | Resource group for AI services | `rg-aisec-ai` |
| `storageAccountPrefix` | Storage account naming prefix | `stai` |
| `enableAIStorage` | Deploy storage foundation | `true` |
| `enableOpenAI` | Deploy OpenAI services | `false` (storage first) |
| `enableSentinelIntegration` | Deploy Sentinel integration | `false` (storage first) |
| `storageBudgetAmount` | Storage-specific budget | `20` (USD/month) |

### 🔍 Storage Architecture Configuration

The Infrastructure-as-Code templates are configured to deploy **Azure Blob Storage** as the primary service for AI workloads:

**Bicep Configuration**: The storage module (`infra/modules/storage/ai-storage.bicep`) deploys:

- **Storage Kind**: `StorageV2` with blob services enabled
- **Primary Service**: Azure Blob Storage optimized for unstructured AI data
- **Access Tier**: `Hot` tier for frequent AI data access
- **Security**: TLS 1.2, HTTPS-only, and disabled public blob access
- **Containers**: Pre-configured containers for `ai-data`, `ai-logs`, and `ai-models`

**Why Blob Storage for AI?**

- **Unstructured Data**: AI datasets, models, and logs are typically unstructured
- **Azure OpenAI Integration**: Native support for Azure OpenAI service connections
- **Cost-Effective**: Hot tier optimized for frequent access patterns in AI workloads
- **Scalability**: Handles large AI datasets and model files efficiently

---

## Step 2: Deploy Storage Foundation Using Scripts

Use the automated PowerShell script for fastest and most reliable deployment.

### ⚡ Automated Script Deployment (Recommended)

Navigate to the scripts directory and run the storage foundation script:

```powershell
# Preview the deployment (What-If mode)
cd "scripts\scripts-deployment"
.\Deploy-StorageFoundation.ps1 -EnvironmentName "aisec" -NotificationEmail "your-email@domain.com" -WhatIf

# Execute the storage foundation deployment
cd "scripts\scripts-deployment"
.\Deploy-StorageFoundation.ps1 -EnvironmentName "aisec" -NotificationEmail "your-email@domain.com"
```

### 🔧 Alternative: Direct Bicep Deployment

If you prefer direct Bicep deployment without the PowerShell wrapper:

#### Using Azure CLI

```bash
# Login to Azure
az login

# Set subscription (replace with your subscription ID)
az account set --subscription "your-subscription-id"

# Deploy only the storage foundation components
az deployment sub create \
  --location "East US" \
  --template-file "infra/main.bicep" \
  --parameters "infra/main.parameters.json" \
  --parameters enableOpenAI=false enableSentinelIntegration=false
```

#### Using Azure PowerShell

```powershell
# Connect to Azure
Connect-AzAccount

# Set subscription context
Set-AzContext -SubscriptionId "your-subscription-id"

# Deploy only the storage foundation components
New-AzSubscriptionDeployment `
  -Location "East US" `
  -TemplateFile "infra/main.bicep" `
  -TemplateParameterFile "infra/main.parameters.json" `
  -enableOpenAI $false `
  -enableSentinelIntegration $false
```

### ⏱️ Deployment Timeline

- **Script preparation**: 30 seconds
- **Resource group creation**: 15 seconds
- **Storage account deployment**: 1-2 minutes
- **Container creation**: 30 seconds
- **Security configuration**: 30 seconds
- **Budget setup**: 45 seconds
- **Validation testing**: 1 minute
- **Total time**: Approximately 4-5 minutes

---

## Step 3: Validate Storage Foundation Deployment

Verify that all components were deployed correctly and are ready for AI integration.

### ✅ Automated Validation

The deployment script includes comprehensive validation. You can also run standalone validation:

```powershell
# Run comprehensive storage validation
.\Test-AIIntegration.ps1 -EnvironmentName "aisec" -ValidationScope "Storage"

# Test storage connectivity and configuration
.\Test-StorageFoundation.ps1 -EnvironmentName "aisec"
```

### 🔍 Manual Verification Steps

#### 1. Verify Resource Group Creation

```bash
# Check resource group deployment
az group show --name "rg-aisec-ai"
```

#### 2. Validate Storage Account Configuration

```bash
# Check storage account deployment and configuration
az storage account show --name "stai{unique-id}" --resource-group "rg-aisec-ai"

# Verify security settings
az storage account show --name "stai{unique-id}" --resource-group "rg-aisec-ai" --query '{httpsTrafficOnlyEnabled:enableHttpsTrafficOnly,minimumTlsVersion:minimumTlsVersion,allowBlobPublicAccess:allowBlobPublicAccess}'
```

#### 3. Validate Container Structure

```bash
# List containers and verify they exist
az storage container list --account-name "stai{unique-id}" --auth-mode login
```

#### 4. Test Storage Access

```bash
# Upload a test file to verify connectivity
echo "AI Storage Foundation Test" > test-ai-storage.txt
az storage blob upload --account-name "stai{unique-id}" --container-name "ai-data" --name "test.txt" --file "test-ai-storage.txt" --auth-mode login

# Clean up test file
az storage blob delete --account-name "stai{unique-id}" --container-name "ai-data" --name "test.txt" --auth-mode login
rm test-ai-storage.txt
```

### 📊 Expected Deployment Results

After successful deployment, you should have:

| Component | Status | Configuration |
|-----------|---------|---------------|
| **Resource Group** | ✅ Created | `rg-aisec-ai` in East US |
| **Storage Account** | ✅ Deployed | Standard_LRS, secure transfer enabled |
| **Containers** | ✅ Created | `ai-data`, `ai-logs`, `ai-models` (private) |
| **Security** | ✅ Configured | HTTPS only, TLS 1.2, no public access |
| **Budget** | ✅ Active | $20/month with progressive alerts |
| **Cost Optimization** | ✅ Applied | 7-day retention, no versioning |

---

## Step 4: Configure Cost Management and Monitoring

Ensure comprehensive cost monitoring is in place for the storage foundation.

### 💰 Budget Validation

The automated script creates budget monitoring. Verify it's working:

```powershell
# Check budget configuration
az consumption budget list --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-aisec-ai"
```

### 📈 Set Up Cost Alerts

If additional cost monitoring is needed:

```powershell
# Run cost management configuration
.\Deploy-CostManagement.ps1 -EnvironmentName "aisec" -BudgetLimit 150 -StorageBudgetLimit 20
```

### 🔍 Monitor Initial Costs

Check that costs are within expected ranges:

```bash
# Check current costs for the AI resource group
az consumption usage list --start-date $(date -d '1 month ago' '+%Y-%m-%d') --end-date $(date '+%Y-%m-%d') --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-aisec-ai"
```

---

## Step 5: Generate Configuration Summary

Document the deployment for integration with AI services.

### 📝 Automated Documentation

The deployment script generates a configuration summary. You can also create one manually:

```powershell
# Generate deployment summary and integration guide
cd "scripts\scripts-validation"
.\Get-AIConfiguration.ps1 -EnvironmentName "aisec" -OutputFormat "Summary"
```

### 📄 Manual Configuration Record

Record these details for AI service integration:

```text
AI Storage Foundation - IaC Deployment Summary
=============================================
Deployment Method: Infrastructure-as-Code (Bicep + PowerShell)
Resource Group: rg-aisec-ai
Storage Account: stai{generated-id}
Region: East US
Containers: ai-data, ai-logs, ai-models
Security: HTTPS only, TLS 1.2, private containers
Budget: $20/month storage + $150/month total AI budget
Alerts: 50%, 75%, 90% thresholds
Deployment Date: {Deployment-Date}
Validation: All tests passed
```

---

## Step 6: Prepare for Next AI Components

Your storage foundation is now ready for AI service integration.

### 🔗 Integration Readiness

Your storage foundation provides:

- **Secure Data Storage**: Private containers with encryption
- **Cost Controls**: Automated budget monitoring and alerts
- **AI Service Ready**: Compatible with Azure OpenAI and Logic Apps
- **Organized Structure**: Dedicated containers for data, logs, and models

### 🎯 Next Deployment Steps

With storage foundation complete, proceed to:

1. **[Deploy Azure OpenAI Service](../../02.03%20Azure%20OpenAI%20Service%20Deployment/Infrastructure%20as%20Code/deploy-azure-openai-service-iac.md)** - Add AI capabilities
2. **[OpenAI Model Customization](../../02.04%20OpenAI%20Model%20Customization/customize-openai-model.md)** - Configure security-focused AI parameters  
3. **[AI Prompt Templates Creation](../../02.05%20AI%20Prompt%20Templates%20Creation/ai-prompt-templates.md)** - Complete Week 2 AI foundation

### 🚀 Quick Next Steps

Continue with the full AI foundation:

```powershell
# Deploy cost management enhancements
.\Deploy-CostManagement.ps1 -EnvironmentName "aisec" -NotificationEmail "your-email@domain.com"

# Preview OpenAI service deployment
.\Deploy-OpenAIService.ps1 -EnvironmentName "aisec" -NotificationEmail "your-email@domain.com" -WhatIf
```

---

## 🛠️ Troubleshooting

### Common Issues and Solutions

**Storage Account Name Conflicts**
```powershell
# The script automatically generates unique names, but if conflicts occur:
.\Deploy-StorageFoundation.ps1 -EnvironmentName "aisec" -StoragePrefix "staialt" -NotificationEmail "your-email@domain.com"
```

**Authentication Errors**
```powershell
# Refresh Azure authentication
az login --use-device-code
Connect-AzAccount
```

**Resource Group Permission Issues**
```bash
# Verify permissions
az role assignment list --assignee $(az account show --query user.name -o tsv) --scope "/subscriptions/$(az account show --query id -o tsv)"
```

**Deployment Validation Failures**
```powershell
# Run detailed diagnostics
.\Test-AIIntegration.ps1 -EnvironmentName "aisec" -ValidationScope "Storage" -Verbose
```

### Script-Specific Troubleshooting

**Script Execution Policy Issues (Windows)**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Module Dependencies**
```powershell
# Install required Azure PowerShell modules
Install-Module -Name Az -Force -AllowClobber
```

### Support Resources

- [Azure Storage Documentation](https://docs.microsoft.com/en-us/azure/storage/)
- [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)

---

**📋 Deployment Status**: After completing this guide, your AI storage foundation is deployed and ready for the next AI integration components. The automated validation ensures all configurations are optimal for AI workloads within your budget constraints.

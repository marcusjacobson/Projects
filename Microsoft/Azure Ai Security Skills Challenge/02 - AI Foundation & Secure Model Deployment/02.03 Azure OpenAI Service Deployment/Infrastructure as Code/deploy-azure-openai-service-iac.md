# Deploy Azure OpenAI Service Using Infrastructure-as-Code

This comprehensive Infrastructure-as-Code guide provides automated deployment of Azure OpenAI Service using Bicep templates and PowerShell automation. This approach enables repeatable, consistent deployments with integrated security controls and cost optimization.

**Use Case**: This guide is ideal for automated deployments, CI/CD pipelines, consistent environment provisioning, and scenarios requiring Infrastructure-as-Code practices with version control and change tracking.

## 🎯 Overview

This Infrastructure-as-Code deployment provides:

- **Automated Deployment**: Consistent, repeatable deployments using Bicep and PowerShell.
- **Cost-Optimized Configuration**: Pre-configured settings for budget-conscious security operations.
- **Integrated Security**: System-assigned managed identity with optional user-assigned identity support.
- **Model Management**: Automated o4-mini deployment with validation testing.
- **Monitoring Integration**: Automatic Log Analytics workspace detection and configuration.
- **Infrastructure Consistency**: Aligned with existing Week 2 storage foundation patterns.

## 📋 Prerequisites

Before starting the deployment, ensure you have:

- **Azure PowerShell**: Version 5.0 or later with Az modules installed.
- **Azure CLI**: Latest version for Bicep template compilation.
- **Active Azure Subscription**: With appropriate permissions to create resources.
- **Contributor Access**: Minimum role required for resource creation and configuration.
- **Existing Storage Foundation**: Week 2 storage foundation deployed in `rg-aisec-ai`.
- **Azure OpenAI Access**: Approved access to Azure OpenAI service (may require application).
- **PowerShell Execution Policy**: Set to allow script execution (RemoteSigned or Unrestricted).

## 💰 Cost Estimation

### Expected Monthly Costs for Learning Lab

| Component | Configuration | Estimated Cost |
|-----------|---------------|----------------|
| **Azure OpenAI Service** | Standard S0 tier | Base: $0/month |
| **o4-mini Model** | 10,000 tokens/day | $2-5/month |
| **text-embedding-3-small** | Standard usage | $0.60/month |
| **Diagnostic Logging** | 30-day retention | $2-5/month |
| **System Managed Identity** | Included | $0/month |
| **Total Monthly Cost** | Basic learning setup | $5-10/month |

## 🏗️ Infrastructure Architecture

### Resource Components

This deployment creates or configures the following Azure resources:

| Resource Type | Purpose | Naming Convention |
|--------------|---------|-------------------|
| **Azure OpenAI** | AI service instance | `openai-aisec-{unique-id}` |
| **Model Deployments** | o4-mini and text-embedding models | `o4-mini-deployment`, `text-embedding-deployment` |
| **Managed Identity** | System-assigned identity for secure access | Auto-generated |
| **Diagnostic Settings** | Logging and monitoring | `openai-diagnostics` |
| **Log Analytics Workspace** | Centralized logging (existing or new) | `log-aisec-{unique-id}` |

### Integration Points

- **Storage Foundation**: Integrates with existing Week 2 storage resources.
- **Resource Group**: Uses existing `rg-aisec-ai` resource group.
- **Monitoring**: Connects to Week 1 Log Analytics workspace if available.
- **Identity Management**: Configures system-assigned managed identity by default.

## 🚀 Infrastructure-as-Code Deployment

### Step 1: Configure Deployment Parameters

The deployment uses the centralized `main.parameters.json` file for configuration consistency with the Week 2 storage foundation.

#### Review Parameters File

Navigate to the `infra` folder and review the parameters file:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environmentName": {
      "value": "aisec"
    },
    "location": {
      "value": "East US"
    },
    "storageBlobContributorAccount": {
      "value": "your-email@domain.com"
    },
    "enableOpenAI": {
      "value": true
    },
    "deployGPT5": {
      "value": false
    },
    "deployo4Mini": {
      "value": true
    },
    "deployTextEmbedding": {
      "value": true
    }
  }
}
```

#### Key Parameters for OpenAI Deployment

- **enableOpenAI**: Set to `true` to deploy Azure OpenAI service.
- **deployo4Mini**: Set to `true` to deploy cost-effective o4-mini model.
- **deployTextEmbedding**: Set to `true` to deploy text embedding model.
- **useSystemManagedIdentity**: Set to `true` for system-assigned managed identity.
- **userAssignedIdentityName**: Leave empty for system identity, or specify user-assigned identity name.

## Step 2: Execute Automated Deployment

### Option 1: Quick Deployment with Default Settings

```powershell
# Navigate to scripts directory
cd ".\scripts\"

# Execute deployment with parameters file
.\Deploy-OpenAIService.ps1 -UseParametersFile
```

#### Option 2: Preview Deployment (What-If Analysis)

```powershell
# Preview deployment without making changes
.\Deploy-OpenAIService.ps1 -UseParametersFile -WhatIf
```

## Step 3: Monitor Deployment and Validate Success

The PowerShell script provides real-time deployment progress and automated validation to ensure successful deployment.

### Deployment Phases and Monitoring

| Phase | Description | Expected Duration |
|-------|-------------|-------------------|
| **Parameter Validation** | Validates input parameters and prerequisites | 1-2 minutes |
| **Resource Group Verification** | Confirms existing storage foundation | 30 seconds |
| **Log Analytics Detection** | Detects existing LAW or creates new | 1-2 minutes |
| **OpenAI Service Deployment** | Deploys Azure OpenAI service | 3-5 minutes |
| **Model Deployments** | Deploys o4-mini and text-embedding models | 2-3 minutes |
| **Security Configuration** | Configures managed identity and permissions | 1-2 minutes |
| **Monitoring Setup** | Configures diagnostic settings | 1 minute |
| **Validation Testing** | Tests model deployment and connectivity | 2-3 minutes |

#### Expected Console Output During Deployment

```text
🚀 Starting Azure OpenAI Service Deployment...
📋 Phase 1: Parameter Validation and Prerequisites Check
✅ Parameters loaded successfully
✅ Connected to Azure subscription: Visual Studio Enterprise Subscription
✅ All necessary modules installed

📋 Phase 2: Infrastructure Deployment
🔍 Scanning for existing Log Analytics workspaces...
    📍 Found LAW 'log-aisec-001' in 'rg-aisec-week1'
    📍 Found LAW 'log-aisec-001' in 'rg-aisec-defender'
⚠️  Multiple Log Analytics workspaces found:
     [1] log-aisec-001 in rg-aisec-week1
     [2] log-aisec-001 in rg-aisec-defender
❓ Select which workspace to use (1-2, or 'n' for new): 1
✅ Selected: log-aisec-001 in rg-aisec-week1
✅ Azure OpenAI service deployment initiated...
⏳ Deployment in progress (3-5 minutes)...
✅ Azure OpenAI service deployed successfully: openai-aisec-001

📋 Phase 3: Model Deployment and Configuration
✅ o4-mini model deployment completed
✅ text-embedding-3-small model deployment completed
✅ System-assigned managed identity configured
✅ Diagnostic settings configured

📋 Phase 4: Validation and Testing
✅ Model connectivity validated
✅ Security prompt testing completed
✅ Log Analytics integration verified
```

### Managed Identity Configuration

#### System-Assigned Managed Identity (Default)

The deployment automatically configures system-assigned managed identity:

- **Automatic Configuration**: Enabled during Azure OpenAI service creation.
- **Security Benefits**: No credential management required.
- **Access Scope**: Scoped to the specific OpenAI resource.
- **Integration Ready**: Configured for storage foundation access.

#### User-Assigned Managed Identity (Optional)

For advanced scenarios requiring user-assigned managed identity, refer to the comprehensive user-assigned identity configuration guide:

**📖 Reference Guide**: [Configure User-Assigned Managed Identity for Azure OpenAI](https://learn.microsoft.com/en-us/azure/cognitive-services/openai/how-to/managed-identity)

**Key Considerations**:

- **Advanced Configuration**: Requires additional Bicep template modifications.
- **Cross-Resource Access**: Useful for shared identity across multiple resources.
- **Custom Permissions**: Enables granular permission control.
- **Enterprise Scenarios**: Recommended for production environments with complex identity requirements.

### Automated Validation Checks

The deployment script performs comprehensive validation:

| Validation Category | Check Description | Success Criteria |
|-------------------|------------------|------------------|
| **Resource Deployment** | Verify OpenAI service creation | Resource status: Succeeded |
| **Model Availability** | Confirm model deployments | Models: Running status |
| **Identity Configuration** | Validate managed identity | System identity: Enabled |
| **Monitoring Setup** | Verify diagnostic settings | Logs flowing to LAW |
| **Security Testing** | Test model access permissions | API calls successful |
| **Cost Configuration** | Verify pricing tier settings | Standard S0 confirmed |

#### Manual Verification Steps (Optional)

1. **Azure Portal Verification**:
   - Navigate to resource group `rg-aisec-ai`.
   - Confirm Azure OpenAI service is listed and running.
   - Verify model deployments in Azure AI Foundry.

2. **Cost Monitoring Verification**:
   - Check Cost Management + Billing for OpenAI resources.
   - Confirm no unexpected charges beyond estimated amounts.

3. **Security Configuration Verification**:
   - Verify managed identity is enabled in the Identity section.
   - Confirm diagnostic settings are configured.

### Deployment Testing

The deployment script includes basic endpoint validation and connectivity testing. However, **comprehensive prompt testing should be performed using Azure AI Foundry** for the most reliable and comprehensive results.

#### PowerShell Script Testing (Basic Validation)

The deployment script can perform basic connectivity testing:

```powershell
# Run deployment with basic security testing
.\Deploy-OpenAIService.ps1 -UseParametersFile -RunSecurityTests

# Or use the dedicated testing script
.\Test-OpenAIEndpoints.ps1 -EnvironmentName "aisec" -TestSecurityPrompts
```

**PowerShell Testing Results:**

- ✅ Endpoint connectivity validation
- ✅ Model deployment verification  
- ✅ API key accessibility confirmation
- ⚠️ **Note**: Actual prompt testing requires manual verification

### Comprehensive Prompt Testing in Azure AI Foundry

**For complete prompt testing and validation, use Azure AI Foundry:**

1. **Access Azure AI Foundry**:
   - Navigate to [Azure AI Foundry](https://ai.azure.com)
   - Sign in with your Azure account
   - Select your OpenAI resource: `openai-aisec-001`

2. **Test Security-Focused Prompts**:

#### Test 1: Threat Analysis Prompt

```text
Prompt: "Analyze this log entry for potential security threats: 'User admin logged in from IP 192.168.1.100 at 03:47 AM, accessed sensitive files, then logged out after 2 minutes.'"

Expected Response Type: Structured threat analysis with risk assessment and recommendations.
```

#### Test 2: Incident Response Prompt

```text
Prompt: "Create a basic incident response checklist for a suspected data breach scenario."

Expected Response Type: Organized checklist with immediate actions and escalation procedures.
```

#### Test 3: Log Analytics Integration Test

```text
Prompt: "Generate a KQL query to find failed login attempts in the last 24 hours."

Expected Response Type: Valid KQL query syntax for Azure Log Analytics.
```

## 📊 Cost Monitoring Summary

### Deployment Cost Impact

The Infrastructure-as-Code deployment provides automatic cost monitoring insights:

| Cost Category | Initial Setup | Monthly Ongoing | Annual Projection |
|--------------|---------------|-----------------|-------------------|
| **OpenAI Service** | $0 | $0 (base tier) | $0 |
| **Model Usage** | $0.02 (testing) | $5-10 | $60-120 |
| **Diagnostic Logging** | $0 | $2-5 | $24-60 |
| **Total Estimated** | $0.02 | $7-15 | $84-180 |

### Cost Optimization Features

- **Automated Model Selection**: Deploys cost-effective o4-mini instead of expensive GPT-5.
- **Usage-Based Pricing**: Standard S0 tier with pay-per-use token model.
- **Efficient Testing**: Minimal token usage during validation testing.
- **Monitoring Integration**: Leverages existing Log Analytics workspace when available.

### Cost Monitoring Recommendations

1. **Set up Budget Alerts**: Configure spending thresholds in Azure Cost Management.
2. **Monitor Token Usage**: Track daily token consumption in Azure AI Foundry.
3. **Review Monthly Costs**: Regular cost analysis in Cost Management + Billing.
4. **Optimize Model Selection**: Use o4-mini for routine tasks, reserve premium models for complex scenarios.

---

## 🛠️ Troubleshooting

### Common Issues and Solutions

#### Azure OpenAI Access Not Approved

```powershell
# Check your OpenAI access status
az cognitiveservices account list --query "[?kind=='OpenAI']" --output table

# Apply for access if needed (manual process)
# Visit: https://aka.ms/oai/access
```

#### Bicep Template Compilation Errors

```powershell
# Verify Bicep CLI installation
az bicep --help

# Install/update Bicep CLI
az bicep upgrade
```

#### Authentication Errors

```powershell
# Refresh Azure authentication
az login --use-device-code
Connect-AzAccount
```

#### Resource Group Permission Issues

```bash
# Verify permissions
az role assignment list --assignee $(az account show --query user.name -o tsv) --scope "/subscriptions/$(az account show --query id -o tsv)" --output table
```

#### Deployment Validation Failures

```powershell
# Run detailed model deployment diagnostics
.\Test-OpenAIEndpoints.ps1 -EnvironmentName "aisec" -TestSecurityPrompts -Verbose
```

#### Model Deployment Quota Issues

```powershell
# Check quota and usage
az cognitiveservices usage list --location "East US"

# Request quota increase if needed (manual process)
# Visit: Azure portal > Cognitive Services > Quotas
```

### Script-Specific Troubleshooting

#### Script Execution Policy Issues (Windows)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### PowerShell Module Issues

```powershell
# Install required modules
Install-Module -Name Az.CognitiveServices -Force -AllowClobber
Install-Module -Name Az.OperationalInsights -Force -AllowClobber
```

---

## 📋 Next Steps and Integration Opportunities

### 🎯 Immediate Next Actions

**Recommended Path**: Complete the remaining Week 2 foundation modules before advancing to automated security operations:

1. **[AI Model Customization](../../02.04%20OpenAI%20Model%20Customization/customize-openai-model.md)** - Configure security-focused AI model parameters.
2. **[AI Prompt Templates](../../02.05%20AI%20Prompt%20Templates%20Creation/ai-prompt-templates.md)** - Create cost-optimized prompt templates for security scenarios.
3. **Week 2 Foundation Validation** - Ensure all AI services are properly configured before Week 3 integration.

### 🚀 Quick Next Steps

Continue building the AI security foundation:

```powershell
# Test deployed models with security prompts
.\Test-OpenAIEndpoints.ps1 -EnvironmentName "aisec" -TestSecurityPrompts -TestEmbeddings

# Configure cost management for OpenAI usage
.\Deploy-CostManagement.ps1 -EnvironmentName "aisec" -TargetScope "OpenAI"

# Preview Sentinel integration deployment
.\Deploy-SentinelIntegration.ps1 -EnvironmentName "aisec" -WhatIf
```

### Advanced Configuration Options

| Configuration Area | Implementation Approach | Learning Value |
|-------------------|-------------------------|----------------|
| **Private Endpoints** | Network security hardening | Production readiness |
| **Custom Role Assignments** | Granular permission control | Security best practices |
| **Multi-Model Deployment** | Additional AI capabilities | Advanced AI integration |
| **Logic Apps Integration** | Automated security workflows | Process automation |

### Integration with Existing Infrastructure

- **Storage Foundation**: Leverage existing storage containers for AI-generated content.
- **Defender for Cloud**: Integrate AI insights with security recommendations.
- **Log Analytics**: Utilize existing monitoring infrastructure for cost optimization.
- **Azure Automation**: Expand automation capabilities with AI-enhanced runbooks.

### Production Deployment Considerations

For production environments, consider these enhancements:

1. **Enhanced Security**: Implement private endpoints and network security groups.
2. **Disaster Recovery**: Configure geo-redundant deployments and backup strategies.
3. **Compliance**: Ensure data residency and regulatory compliance requirements.
4. **Scalability**: Plan for increased token usage and model deployment scaling.

---

## 🔄 Decommissioning and Lab Reset

### Automated Decommission Script ⚡ (Recommended)

For users comfortable with automation, you can quickly and safely remove all Azure OpenAI infrastructure using the provided PowerShell decommission script:

```powershell
# Navigate to scripts directory
cd ".\scripts\"

# Preview decommission without making changes (recommended first step)
.\Remove-OpenAIInfrastructure.ps1 -UseParametersFile -WhatIf

# Execute automated decommission with configuration backup
.\Remove-OpenAIInfrastructure.ps1 -UseParametersFile -BackupConfiguration

# Force decommission without confirmation (automation scenarios)
.\Remove-OpenAIInfrastructure.ps1 -UseParametersFile -Force
```

#### Script Advantages

- **Fast**: Complete decommission in ~1-2 minutes.
- **Comprehensive**: Removes models, service, and configurations in proper order.
- **Safe**: What-If mode and configuration backup options.
- **Cost-effective**: Immediate termination of all OpenAI token charges.
- **Preserves Infrastructure**: Maintains storage foundation and Defender configurations.

**📖 Alternative**: For step-by-step manual decommission through Azure Portal, see the **[Azure OpenAI Decommission Guide](../Decommission/decommission-azure-openai-service.md)**.

## 🤖 AI-Assisted Content Generation

This comprehensive Infrastructure-as-Code deployment guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Infrastructure-as-Code best practices, Azure OpenAI deployment patterns, and security-focused automation approaches.

*AI tools were used to enhance productivity and ensure comprehensive coverage of automated deployment procedures while maintaining technical accuracy and reflecting current Azure Infrastructure-as-Code capabilities and security best practices.*

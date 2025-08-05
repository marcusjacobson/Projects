# Deploy AI Storage Foundation - Infrastructure-as-Code Guide

This guide provides a comprehensive approach to deploying AI storage infrastructure using Infrastructure-as-Code with Azure Bicep templates. This automated approach mirrors the steps from the Azure Portal guide but leverages scripts for consistent, repeatable deployments.

## 🎯 Overview

This automated deployment approach follows the same logical progression as the Azure Portal guide:

- **Simplified Single-Script Deployment** - Deploy complete storage foundation with one command
- **Learning-Focused Experience** - Understand each storage component through clear output
- **Comprehensive Validation** - Built-in testing and validation steps
- **Infrastructure-as-Code Best Practices** - Version-controlled, repeatable deployments

### Core Deployment Steps

This guide mirrors the portal guide structure with four main phases:

1. **Foundation Deployment** - Automated resource group and storage account creation
2. **Permission Configuration** - Automated Storage Blob Data Contributor role assignment
3. **Container Structure** - Pre-configured blob containers for organized AI workload data (ai-data, ai-logs, ai-models)
4. **Storage Validation** - Automated testing of storage access and file upload functionality

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

## Step 1: Foundation Deployment Preparation

Prepare for the deployment of the core storage infrastructure using the simplified Bicep template and PowerShell automation.

### 🔧 Configure Deployment Parameters

The deployment uses the centralized **[`infra/main.parameters.json`](./infra/main.parameters.json)** file for configuration. For this storage foundation deployment, configure the following parameters:

| Parameter | Current Value | What to Change | Purpose |
|-----------|---------------|----------------|---------|
| `storageBlobContributorAccount` | `"user@domain.com"` | **Replace with the admin account User Principal Name (UPN)** | Automatically resolved to Object ID for storage permissions |
| `environmentName` | `"aisec"` | Keep as-is (or customize) | Resource naming prefix |
| `location` | `"East US"` | Keep as-is | Azure region optimized for AI services |

**Template files involved:**

- **Main template**: [`infra/main.bicep`](./infra/main.bicep) - Orchestrates the complete deployment
- **Storage module**: [`infra/modules/storage/ai-storage.bicep`](./infra/modules/storage/ai-storage.bicep) - Deploys storage account and containers  
- **PowerShell deployment**: [`scripts/Deploy-StorageFoundation.ps1`](./scripts/Deploy-StorageFoundation.ps1) - Handles UPN resolution and deployment

### 🔍 Automatic Object ID Resolution

**Simplified Approach**: The deployment now automatically resolves the provided UPN to the required Entra Object ID using Azure CLI within the PowerShell deployment script. This eliminates both manual lookup and complex Bicep deployment scripts.

**How it works**:

1. You provide the UPN in the `storageBlobContributorAccount` parameter
2. The PowerShell script uses Azure CLI to resolve the email to an Object ID
3. The resolved Object ID is passed directly to the Bicep template for role assignment
4. No intermediate deployment scripts or complex Bicep modules required

**Benefits**:

- ✅ No manual Object ID lookup required
- ✅ Uses familiar UPN (email address) format
- ✅ Automatic validation during deployment
- ✅ Error handling if email address is invalid

---

## Step 2: Permission Configuration - Storage Data Access

Deploy the storage foundation with automatic permission configuration using the main Bicep template.

### ⚙️ What Gets Deployed

This simplified deployment creates:

- **Resource Group**: `rg-aisec-ai` for AI storage resources
- **Storage Account**: Unique name with prefix `stai` (e.g., `staiaisecd3f2a1`)
- **Blob Containers**: Pre-configured containers for AI workloads:
  - `ai-data` - Input datasets and raw data
  - `ai-logs` - Application logs and audit trails
  - `ai-models` - Model artifacts and configurations
- **Role Assignment**: Storage Blob Data Contributor permissions for your account
- **Security Settings**: TLS 1.2, HTTPS-only, encryption at rest

### 🔧 PowerShell Script Deployment

Deploy the storage foundation using the PowerShell script with parameters file:

```powershell
# Navigate to the scripts directory
cd "scripts"

# Deploy the storage foundation using parameters file
.\Deploy-StorageFoundation.ps1 -UseParametersFile

# Or preview deployment first (recommended)
.\Deploy-StorageFoundation.ps1 -UseParametersFile -WhatIf
```

The script will automatically:

- Load configuration from `../infra/main.parameters.json`
- Resolve the UPN to Object ID using Azure CLI
- Deploy the Bicep template with the resolved Object ID
- Validate the deployment and test storage access

### ⏱️ Deployment Timeline

- **Resource group creation**: 15 seconds
- **Storage account deployment**: 1-2 minutes  
- **Container creation**: 30 seconds
- **Role assignment**: 30 seconds
- **Total time**: Approximately 2-3 minutes

### 📊 Deployment Output

Upon successful completion, you'll see output similar to:

```bash
{
  "aiResourceGroupName": "rg-aisec-ai",
  "storageAccountName": "staiaisecd3f2a1",
  "aiDataContainerName": "ai-data",
  "aiLogsContainerName": "ai-logs", 
  "aiModelsContainerName": "ai-models",
  "blobEndpoint": "https://staiaisecd3f2a1.blob.core.windows.net/"
}
```


## Step 3: Storage Validation - Test File Upload and Access

Validate that your storage account is properly configured and accessible.

### ✅ Automated Storage Testing

Test storage connectivity and permissions using the PowerShell validation script:

```powershell
# Navigate to the scripts directory
cd "scripts"

# Test storage upload using parameters file (recommended)
.\Test-StorageUpload.ps1 -UseParametersFile

# Or test specific container
.\Test-StorageUpload.ps1 -UseParametersFile -ContainerName "ai-logs"

# Alternative: Manual parameters
.\Test-StorageUpload.ps1 -EnvironmentName "aisec" -ContainerName "ai-data" -TestFilePath "templates\ai-storage-test-upload.txt"
```

### 🔍 Verify Upload Success

The test script will provide output showing:

- Storage account connection status
- File upload success/failure
- Container accessibility confirmation
- Blob endpoint validation

Expected output:

```
✅ Storage Account: stai****** - Connected
✅ Container: ai-data - Accessible (test file uploaded)
✅ Container: ai-logs - Created (empty)
✅ Container: ai-models - Created (empty)
✅ Blob Endpoint: https://stai******.blob.core.windows.net/ - Validated
```

### 🔍 Comprehensive Validation

Run the complete storage foundation validation to verify all components:

```powershell
# Run comprehensive storage validation using parameters file (recommended)
.\Test-StorageFoundation.ps1 -UseParametersFile

# Run basic validation only
.\Test-StorageFoundation.ps1 -UseParametersFile -ValidationScope "Basic"

# Alternative: Manual parameters
.\Test-StorageFoundation.ps1 -EnvironmentName "aisec" -ValidationScope "Complete"
```

This validation script checks:
- Resource group deployment status
- Storage account configuration and security settings
- All container creation and accessibility
- Role assignment verification
- Security configuration validation

### 📊 Expected Validation Results

The validation script will provide detailed output similar to:

```
🔍 AI Storage Foundation Validation Results
==========================================
✅ Resource Group: rg-aisec-ai - Deployed
✅ Storage Account: staiaisecd3f2a1 - Configured
✅ Container: ai-data - Created & Accessible
✅ Container: ai-logs - Created & Accessible  
✅ Container: ai-models - Created & Accessible
✅ Security: HTTPS enforced, TLS 1.2, No public access
✅ Role Assignment: Storage Blob Data Contributor - Applied
✅ Blob Endpoint: https://staiaisecd3f2a1.blob.core.windows.net/ - Active

### 📊 Summary: Complete Storage Foundation

After successful deployment and validation, you should have:

| Component | Status | Configuration |
|-----------|---------|---------------|
| **Resource Group** | ✅ Created | `rg-aisec-ai` in East US |
| **Storage Account** | ✅ Deployed | Standard_LRS, secure transfer enabled |
| **Containers** | ✅ Created | `ai-data`, `ai-logs`, `ai-models` (private) |
| **Security** | ✅ Configured | HTTPS only, TLS 1.2, no public access |
| **Role Assignment** | ✅ Applied | Storage Blob Data Contributor for specified account |
| **Validation** | ✅ Passed | Upload/access testing completed |

**Next**: Your storage foundation is ready for AI service integration.

---

## Step 4: Generate Configuration Summary

Document the deployment for integration with AI services.

### 📝 Automated Documentation

The deployment script generates a configuration summary. You can also create one manually:

```powershell
# Generate deployment summary and integration guide
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
Deployment Date: {Deployment-Date}
Validation: All tests passed
```

---

## Step 5: Prepare for Next AI Components

Your storage foundation is now ready for AI service integration.

### 🔗 Integration Readiness

Your storage foundation provides:

- **Secure Data Storage**: Private containers with encryption
- **AI Service Ready**: Compatible with Azure OpenAI and Logic Apps
- **Organized Structure**: Dedicated containers for data, logs, and models
- **Proper Permissions**: Storage Blob Data Contributor access configured

### 🎯 Next Deployment Steps

With storage foundation complete, proceed to:

1. **[Deploy AI Cost Management](./deploy-ai-cost-management-modular-iac.md)** - Enhanced budget controls and monitoring
2. **[Deploy Azure OpenAI Service](./deploy-azure-openai-service-modular-iac.md)** - Add AI capabilities
3. **[Configure Sentinel Integration](./deploy-openai-sentinel-integration-modular-iac.md)** - Complete AI automation pipeline

---

## �️ Cleanup and Decommissioning

### Quick Lab Cleanup (Recommended for Learning Environment)

For this learning lab, the simplest cleanup approach is to delete the entire resource group:

```powershell
# Navigate to scripts directory
cd "scripts"

# Quick cleanup using parameters file (recommended)
.\Remove-StorageResourceGroup.ps1 -UseParametersFile

# Preview cleanup first (recommended)
.\Remove-StorageResourceGroup.ps1 -UseParametersFile -WhatIf

# Force cleanup without confirmation (automation)
.\Remove-StorageResourceGroup.ps1 -UseParametersFile -Force

# Alternative: Manual environment name
.\Remove-StorageResourceGroup.ps1 -EnvironmentName "aisec"
```

**What this removes:**

- ✅ Storage account and all containers (`ai-data`, `ai-logs`, `ai-models`)
- ✅ All role assignments scoped to the storage account
- ✅ Diagnostic settings and logs
- ✅ Resource group and all contained resources

**What this preserves:**

- ✅ Your subscription-level permissions (Owner/Contributor rights)
- ✅ Week 1 Defender for Cloud infrastructure (separate resource group)
- ✅ Ability to redeploy fresh infrastructure for continued learning

**Script features:**

- Waits for complete deletion (up to 5 minutes)
- Verifies successful removal before completing
- Uses Azure CLI for reliable deletion
- Consistent with project script patterns

- Optional data backup before deletion
- Detailed progress reporting and validation
- Selective preservation options
- What-If mode for safe preview

### Lab Environment Benefits

**Quick Resource Group Deletion** is perfect for this lab because:

- 🚀 **Fast iteration** - Complete cleanup in seconds
- 💰 **Cost control** - Immediate billing stop
- 🔄 **Clean slate** - Ready for fresh deployment or next components
- 📚 **Learning focus** - Spend time on AI integration, not cleanup complexity

---

## �🛠️ Troubleshooting

### Common Issues and Solutions

**Storage Account Name Conflicts**
```powershell
# The script automatically generates unique names, but if conflicts occur:
.\Deploy-StorageFoundation.ps1 -EnvironmentName "aisec" -StoragePrefix "staialt"
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

# Decommission AI Storage Foundation - Lab Reset Guide

## 🎯 Purpose and Scope

This comprehensive decommissioning guide provides a systematic approach to safely remove AI storage infrastructure from your Azure environment and restore your lab to a clean slate. This guide supports **two different decommissioning approaches** based on how you originally deployed the AI storage foundation.

## 🚀 Choose Your Decommissioning Method

### **Method 1: Automated Script Decommissioning** ⚡ (Recommended)

**Use this method if you deployed using:**

- **Modular Infrastructure-as-Code Guide** (`deploy-ai-storage-foundation-modular-iac.md`)
- **PowerShell automation scripts** (`Deploy-StorageFoundation.ps1`)

**✅ Advantages:**

- **Fast**: Complete decommissioning in ~1-2 minutes
- **Comprehensive**: 100% validation with complete resource cleanup
- **Safe**: Automated resource discovery and dependency handling
- **Cost-effective**: Immediate termination of all storage charges
- **Data Protection**: Optional data backup before deletion

**🚀 Quick Start:**

```powershell
# Navigate to the scripts directory
cd "scripts"

# Preview decommission (recommended first step)
.\Remove-AIStorageInfrastructure.ps1 -EnvironmentName "aisec" -WhatIf

# Run the automated decommission script
.\Remove-AIStorageInfrastructure.ps1 -EnvironmentName "aisec" -Force
```

### **Method 2: Manual Portal Decommissioning** 🖱️

**Use this method if you deployed using:**

- **Azure Portal Manual Guide** (`deploy-ai-storage-foundation-azure-portal.md`)
- **Manual configuration through Azure Portal**
- **Step-by-step manual deployment**

**📋 Process:** Follow the detailed [manual decommissioning steps](#manual-portal-decommissioning-steps) below for systematic portal-based removal.

---

## 💡 Why Use This Guide

This decommissioning process serves multiple purposes:

- **Cost Optimization**: Eliminate all AI storage charges to avoid unexpected billing
- **Lab Reset**: Return your Azure environment to a clean state for practicing deployment procedures
- **Resource Cleanup**: Remove all storage accounts, containers, and associated resources
- **Budget Management**: Free up budget allocation for other Week 2 AI components
- **Security**: Ensure no residual data or access configurations remain

---

## Method 1: Automated Script Decommissioning ⚡

### 🚀 Quick Automated Decommission

The fastest way to remove your AI storage infrastructure:

```powershell
# Navigate to the scripts directory
cd "scripts"

# Preview what will be removed (highly recommended)
.\Remove-AIStorageInfrastructure.ps1 -EnvironmentName "aisec" -WhatIf

# Execute complete decommission with data backup option
.\Remove-AIStorageInfrastructure.ps1 -EnvironmentName "aisec" -BackupData -Force

# Alternative: Quick removal without data backup
.\Remove-AIStorageInfrastructure.ps1 -EnvironmentName "aisec" -Force
```

### 📋 Automated Decommission Features

**The script automatically handles:**

- ✅ **Resource Discovery**: Finds all AI storage resources in your environment
- ✅ **Data Backup**: Optional backup of container contents before deletion
- ✅ **Container Cleanup**: Removes all AI containers (ai-data, ai-logs, ai-models)
- ✅ **Storage Account Removal**: Deletes storage accounts and associated resources
- ✅ **Budget Cleanup**: Removes storage-specific budgets and alerts
- ✅ **Resource Group Cleanup**: Optionally removes AI resource group if empty
- ✅ **Cost Validation**: Confirms all charges have been terminated
- ✅ **Completion Report**: Provides summary of removed resources and cost savings

### ⏱️ Automated Timeline

- **Resource discovery**: 30 seconds
- **Data backup** (if enabled): 1-3 minutes depending on data volume
- **Container cleanup**: 30 seconds
- **Storage account removal**: 1 minute
- **Budget and alert cleanup**: 30 seconds
- **Validation and reporting**: 30 seconds
- **Total time**: Approximately 2-5 minutes

---

## Method 2: Manual Portal Decommissioning Steps 🖱️

Follow these steps if you deployed manually through the Azure Portal.

### Step 1: Backup Important Data (Optional)

Before removing resources, backup any important data:

#### Download Container Contents

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Go to **Storage accounts**
3. Select your AI storage account (typically named `stai{unique-id}`)
4. Under **Data storage**, click **Containers**
5. For each container (`ai-data`, `ai-logs`, `ai-models`):
   - Click the container name
   - Select any important blobs
   - Click **Download** to save locally

### Step 2: Remove Storage Containers

Clean up the container structure:

#### Delete AI Containers

1. In your storage account, go to **Data storage** > **Containers**
2. Select the `ai-data` container
3. Click **Delete container**
4. Type the container name to confirm deletion
5. Repeat for `ai-logs` and `ai-models` containers

**Expected Result**: All three AI containers should be deleted

### Step 3: Remove Storage Account

Delete the main storage account:

#### Storage Account Deletion

1. Navigate back to **Storage accounts** in the main portal
2. Select your AI storage account (`stai{unique-id}`)
3. Click **Delete** in the top toolbar
4. In the confirmation dialog:
   - Type the storage account name to confirm
   - Check "I understand this will delete all data"
   - Click **Delete**

**⏱️ Deletion Time**: 2-3 minutes for complete removal

### Step 4: Remove Budget and Cost Alerts

Clean up cost management configurations:

#### Budget Removal

1. Navigate to **Cost Management + Billing**
2. Go to **Cost Management** > **Budgets**
3. Find the AI storage budget (typically named `AI-Storage-Budget-{environment}`)
4. Select the budget and click **Delete**
5. Confirm deletion

#### Alert Cleanup

1. In **Cost Management**, go to **Alerts**
2. Remove any alerts related to AI storage
3. Verify no storage-related notifications remain

### Step 5: Remove Resource Group (Optional)

If the AI resource group is dedicated to storage only:

#### Resource Group Cleanup

1. Navigate to **Resource groups**
2. Select the AI resource group (`rg-{environment}-ai`)
3. Verify it's empty or contains only resources you want to remove
4. Click **Delete resource group**
5. Type the resource group name to confirm
6. Click **Delete**

**⚠️ Warning**: Only delete the resource group if you're sure it doesn't contain other important resources

### Step 6: Verify Complete Removal

Confirm all resources have been removed:

#### Verification Checklist

- ✅ **Storage account deleted**: No longer appears in storage accounts list
- ✅ **Containers removed**: All AI containers (ai-data, ai-logs, ai-models) deleted
- ✅ **Budget removed**: No AI storage budget active
- ✅ **Alerts cleaned**: No storage-related cost alerts
- ✅ **Resource group empty**: AI resource group is empty or removed
- ✅ **Cost verification**: No ongoing storage charges in billing

---

## 🔍 Post-Decommission Validation

### Cost Verification

Confirm that all storage-related charges have stopped:

#### Check Current Costs

1. Navigate to **Cost Management + Billing**
2. Go to **Cost analysis**
3. Filter by resource group: `rg-{environment}-ai`
4. Verify no new charges are being incurred
5. Check that storage account costs have dropped to zero

### Resource Verification

Ensure complete cleanup:

#### Portal Verification

1. **Storage accounts**: Verify AI storage account no longer exists
2. **Resource groups**: Confirm AI resource group is empty or removed
3. **Budgets**: Check that storage budget is deleted
4. **Alerts**: Verify no storage-related alerts remain

#### CLI Verification (Optional)

```bash
# Check for remaining storage accounts
az storage account list --query "[?contains(name, 'stai')]"

# Verify resource group contents
az resource list --resource-group "rg-{environment}-ai"

# Check for remaining budgets
az consumption budget list --scope "/subscriptions/{subscription-id}/resourceGroups/rg-{environment}-ai"
```

---

## 💰 Expected Cost Savings

After successful decommissioning:

### Monthly Cost Elimination

| Component | Previous Cost | After Decommission |
|-----------|---------------|-------------------|
| **Storage Account (LRS)** | $5-10/month | $0 |
| **Operations** | $1-3/month | $0 |
| **Data Transfer** | $0-2/month | $0 |
| **Total Savings** | **$6-15/month** | **$0** |

### Budget Reallocation

The freed budget can be reallocated to:
- **Azure OpenAI services** for actual AI capabilities
- **Logic Apps** for automation workflows
- **Enhanced monitoring** and security features
- **Additional Sentinel integration** components

---

## 🔄 Redeployment Readiness

After successful decommissioning, your environment is ready for:

### Fresh Deployment

- ✅ **Clean slate**: No conflicting resources or configurations
- ✅ **Full budget available**: Complete cost allocation for new deployment
- ✅ **Optimized approach**: Apply lessons learned from previous deployment
- ✅ **Enhanced configuration**: Implement improved settings and configurations

### Next Steps Options

1. **Redeploy with improvements**: Use lessons learned to optimize configuration
2. **Continue to OpenAI**: Skip storage and deploy AI services directly
3. **Full Week 2 restart**: Begin complete AI integration from the beginning
4. **Alternative approach**: Try different deployment method (Portal vs IaC)

---

## 🛠️ Troubleshooting Decommission Issues

### Common Problems and Solutions

**Storage Account Won't Delete**
```
Error: Storage account contains data or has active leases
Solution: Ensure all containers are empty and no services are accessing the storage
```

**Budget Deletion Fails**
```
Error: Budget is referenced by other resources
Solution: Remove all alert rules first, then delete the budget
```

**Resource Group Deletion Blocked**
```
Error: Resource group contains resources
Solution: Verify all resources are removed, check for hidden resources
```

**Automated Script Failures**

```powershell
# Check script permissions
Get-ExecutionPolicy

# Verify Azure connection
Get-AzContext

# Run with detailed logging
.\Remove-AIStorageInfrastructure.ps1 -EnvironmentName "aisec" -Verbose -WhatIf
```

### Support Resources

- [Azure Storage Deletion](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-manage)
- [Resource Group Management](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Cost Management](https://docs.microsoft.com/en-us/azure/cost-management-billing/)

---

## 📋 Decommission Completion Checklist

Mark each item as complete to ensure thorough cleanup:

### Resource Cleanup
- ✅ Storage account `stai{unique-id}` deleted
- ✅ All containers (ai-data, ai-logs, ai-models) removed
- ✅ Resource group `rg-{environment}-ai` cleaned or removed
- ✅ No residual storage resources remain

### Cost Management Cleanup
- ✅ AI storage budget deleted
- ✅ All storage-related cost alerts removed
- ✅ Billing verification shows zero storage charges
- ✅ Budget allocation freed for other components

### Validation Complete
- ✅ Portal verification confirms complete removal
- ✅ CLI verification (if used) shows no remaining resources
- ✅ Cost analysis shows eliminated storage charges
- ✅ Environment ready for fresh deployment

---

**📋 Decommission Status**: After completing this guide, your AI storage foundation is completely removed, costs are eliminated, and your environment is ready for fresh deployment or continuation to other Week 2 components.

**🎯 Next Actions**: You can now proceed with confidence knowing your lab environment is clean and your budget is optimally allocated for the next phase of your AI security integration journey.

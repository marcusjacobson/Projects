# Parameters Configuration Guide

## 🎯 Required Parameters for Week 2 Storage Foundation

The `main.parameters.json` file has been simplified to include only the parameters needed for the current Bicep template. Here's what each parameter does:

### Core Parameters

| Parameter | Type | Purpose | Example |
|-----------|------|---------|---------|
| `environmentName` | string | Prefix for resource naming | `"aisec"` |
| `location` | string | Azure region for deployment | `"East US"` |
| `notificationEmail` | string | Email for cost alerts | `"your-email@domain.com"` |
| `storageBlobContributorAccount` | string | User email for storage permissions | `"your-email@domain.com"` |
| `monthlyBudgetLimit` | integer | Monthly budget in USD | `150` |
| `enableOpenAI` | boolean | Deploy OpenAI service | `false` (storage-only) |
| `enableCostManagement` | boolean | Deploy cost management | `true` |

## 🔍 Automatic Object ID Resolution - No Manual Steps Required!

**New Feature**: The deployment now automatically resolves your email address to the required Azure AD Object ID using a deployment script. **You no longer need to manually find your Object ID!**

### How It Works

1. **You provide your email address** in the `storageBlobContributorAccount` parameter
2. **Deployment script automatically resolves** email to Object ID using Azure REST API
3. **Object ID is automatically used** for Storage Blob Data Contributor role assignment
4. **Validation and error handling** ensures the email address is valid

### Benefits

- ✅ **No manual Object ID lookup required**
- ✅ **Uses familiar email address format**
- ✅ **Automatic validation during deployment**
- ✅ **Error handling if email address is invalid**
- ✅ **Works with any valid Azure AD user email**

### What You Need

Just your email address! The deployment handles the rest automatically.

## 📝 Configuration Steps (Simplified!)

1. **Update main.parameters.json** with your email address:

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
    "notificationEmail": {
      "value": "your-email@domain.com"
    },
    "storageBlobContributorAccount": {
      "value": "your-email@domain.com"
    },
    "monthlyBudgetLimit": {
      "value": 150
    },
    "enableOpenAI": {
      "value": false
    },
    "enableCostManagement": {
      "value": true
    }
  }
}
```

2. **Deploy immediately** - no additional steps required!

## ❌ Removed Parameters

The following parameters were removed because they're not needed for the simplified storage-focused deployment:

- `aiResourceGroupName` - Now calculated from `environmentName`
- `week1ResourceGroupName` - Not used in storage deployment
- `openAISku` - Not relevant when `enableOpenAI = false`
- `enableAIStorage` - Storage is always deployed (no longer conditional)
- `enableSentinelIntegration` - Not used in simplified template

## 🔧 PowerShell Script Compatibility

**Note**: The PowerShell scripts (`Deploy-StorageFoundation.ps1` and `Deploy-AIFoundation.ps1`) may still reference some of the removed parameters. They work by passing parameters directly to the Bicep template, bypassing the parameters file for dynamic values.

### Storage Foundation Deployment

For storage-only deployment, use the IaC guide approach:

```bash
az deployment sub create \
  --location "East US" \
  --template-file "main.bicep" \
  --parameters "@main.parameters.json"
```

### AI Foundation Deployment

For complete AI foundation (when ready), use the PowerShell script:

```powershell
.\Deploy-AIFoundation.ps1 -EnvironmentName "aisec" -NotificationEmail "your-email@domain.com"
```

## ✅ Validation

To verify your configuration is correct:

1. **Bicep Validation**:
   ```bash
   az deployment sub validate \
     --location "East US" \
     --template-file "main.bicep" \
     --parameters "@main.parameters.json"
   ```

2. **Email Address Verification** (during deployment):
   The deployment script automatically validates your email address and provides clear error messages if it cannot be resolved to an Object ID.

## 🚨 Important Notes

- **Email Format**: Must be a valid Azure AD user email (UPN format)
- **Automatic Resolution**: Object ID is resolved automatically during deployment
- **Regional Consistency**: Keep `"East US"` for AI service compatibility
- **Budget Alignment**: Ensure `monthlyBudgetLimit` matches your actual budget
- **Error Handling**: Clear error messages if email cannot be resolved

---

*This configuration supports the simplified single-script deployment approach for Week 2 AI Security Skills Challenge.*

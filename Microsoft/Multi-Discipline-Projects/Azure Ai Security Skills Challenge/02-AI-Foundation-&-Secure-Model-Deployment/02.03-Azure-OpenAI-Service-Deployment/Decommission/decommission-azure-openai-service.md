# Decommission Azure OpenAI Service

This comprehensive decommissioning guide provides a systematic approach to safely remove Azure OpenAI Service resources while preserving your existing storage foundation and other Week 2 infrastructure components. This guide follows the proper order of operations to avoid dependency issues and ensure complete cleanup.

**Use Case**: This guide is ideal when you want to reset your Azure OpenAI learning experience, eliminate ongoing token costs, or clean up after completing the AI integration phase while maintaining your storage foundation for future learning paths.

## 🚀 Choose Your Decommissioning Method

### Method 1: Automated Script Decommissioning ⚡ (Advanced Users)

**Use this method if you are comfortable with PowerShell automation and prefer fast, comprehensive decommissioning:**

#### Advantages

- **Fast**: Complete decommissioning in ~1-2 minutes.
- **Comprehensive**: 100% validation with complete resource cleanup.
- **Safe**: Automated resource discovery and dependency handling.
- **Cost-effective**: Immediate termination of all OpenAI token charges.
- **Configuration Backup**: Optional backup before deletion.

#### Quick Start

```powershell
# Navigate to the scripts directory
cd "scripts\scripts-decommission"

# Preview decommission (recommended first step)
.\Remove-OpenAIInfrastructure.ps1 -UseParametersFile -WhatIf

# Run the automated decommission script
.\Remove-OpenAIInfrastructure.ps1 -UseParametersFile -Force
```

### Method 2: Manual Portal Decommissioning 🖱️

**Use this method if you prefer step-by-step guidance through the Azure Portal:**

**📋 Process:** Follow the detailed **manual decommissioning steps** below for systematic portal-based removal.

---

## 🎯 Decommissioning Overview

This systematic decommissioning process will remove:

- **Model Deployments**: All deployed AI models (o4-mini, GPT-5, text-embedding-3-small).
- **Azure OpenAI Service**: Complete service instance with all configurations.
- **Monitoring Resources**: Diagnostic settings and Log Analytics workspace (optional).
- **Security Configurations**: Role assignments and API keys specific to OpenAI.
- **Cost Management**: OpenAI-specific budget alerts and monitoring rules.

**Resources Preserved**: Storage foundation, Defender for Cloud configurations, and core resource group infrastructure remain intact.

## 📋 Prerequisites

Before starting the decommissioning process, ensure you have:

- **Azure Portal Access**: With sufficient permissions to delete resources.
- **Resource Deletion Rights**: Minimum **Contributor** role on the resource group.
- **Active Azure Session**: Valid authentication to Azure Portal and subscription.
- **Backup Awareness**: Understanding that this process permanently removes OpenAI resources.
- **Integration Impact**: Confirmation that no active integrations depend on OpenAI service.
- **Cost Impact Understanding**: Awareness that decommissioning stops all ongoing OpenAI token charges.

## 💰 Cost Impact Assessment

### Immediate Cost Savings

| Component | Current Monthly Cost | Post-Decommissioning |
|-----------|---------------------|---------------------|
| **o4-mini Model** | $2-5/month | $0 |
| **GPT-5 Model** (if deployed) | $10-15/month | $0 |
| **text-embedding-3-small** | $0.60/month | $0 |
| **Diagnostic Logging** | $2-5/month | $0* |
| **Total OpenAI Costs** | $5-25/month | $0 |

*Log Analytics workspace may be preserved for other services

### Resources That Continue Incurring Costs

- **Storage Foundation**: Storage account from Week 2 ($1-3/month).
- **Defender for Cloud**: Week 1 security configurations (varies by plan).
- **Log Analytics Workspace**: If used by other services (varies by retention).

## 🛑 Step-by-Step Decommissioning Process

### Step 1: Verify Current OpenAI Resources

Before beginning the decommissioning process, identify all OpenAI-related resources that need to be removed.

#### Inventory OpenAI Resources

- Navigate to [portal.azure.com](https://portal.azure.com).
- Sign in with your Azure credentials.
- Navigate to **Resource groups** and select `rg-aisec-ai`.
- Identify the following OpenAI-related resources:
  - **Azure OpenAI service** (typically named `openai-aisec-{unique-id}`).
  - **Log Analytics workspace** (if created specifically for OpenAI).

#### Document Current Configuration

Create a quick inventory for future reference:

- **OpenAI Service Name**: Record the exact name for verification.
- **Model Deployments**: Note which models are currently deployed.
- **Resource Group**: Confirm it's `rg-aisec-ai` (Week 2 resource group).
- **Region**: Verify the deployment region (should be **East US**).

### Step 2: Remove Model Deployments

**Critical First Step**: Model deployments must be removed before deleting the OpenAI service to avoid dependency issues and ensure proper cleanup.

#### Access Model Deployments

- Navigate to your Azure OpenAI service in the Azure Portal.
- Click **Explore Azure AI Foundry Portal** or navigate directly to [ai.azure.com](https://ai.azure.com).
- In Azure AI Foundry, navigate to **Shared resources** → **Deployments**.

#### Delete Model Deployments

For each deployed model (o4-mini, GPT-5, text-embedding-3-small):

- Select the deployment from the list.
- Click the **Delete** button.
- Click **Delete** to confirm removal.
- Wait for the deletion status to show **Succeeded** before proceeding to the next model.

Confirm no remaining model deployments are listed for your OpenAI resource that were connected with this project.

### Step 3: Disable managed identities

If you configured service principals or managed identities for OpenAI access:

- Navigate to **Identity** in the Azure OpenAI service.
- Under **System assigned**, set **Status** to **Off** if enabled.
- Click **Save** to disable system-assigned managed identity.

#### Remove User-Assigned Managed Identity (Optional)

If you created a user-assigned managed identity during deployment:

- Still in the **Identity** section, click the **User assigned** tab.
- For each user-assigned managed identity listed:
  - Click the **X** or **Remove** button next to the identity.
  - In the confirmation dialog, click **Yes** to remove the association.
  - **Note**: This only removes the association; the identity resource itself remains in your resource group.
- To completely delete the user-assigned managed identity resource:
  - Navigate to your resource group `rg-aisec-ai`.
  - Find the managed identity resource (typically named like `id-aisec-{unique-id}`).
  - Select the managed identity resource.
  - Click **Delete** at the top of the resource overview.
  - Type **DELETE** in the confirmation field and click **Delete**.

### Step 4: Remove Role Assignments

Clean up all role assignments created during the OpenAI deployment process.

#### Remove User Role Assignments

**Important**: Only remove role assignments that were manually assigned to specific users during the OpenAI setup process. Do not remove system-managed role assignments, service principal assignments from other Azure services, or inherited permissions from resource group or subscription levels.

- In the Azure Portal, navigate to your Azure OpenAI service.
- Click **Access control (IAM)** in the left navigation.
- Select the **Role assignments** tab.
- For each role assignment related to OpenAI access:
  - Select the checkbox next to the role assignment.
  - Click **Remove** at the top of the assignments list.
  - In the confirmation dialog, click **Yes** to confirm removal.
  - Wait for the **Successfully removed role assignment** notification.

#### Common Role Assignments to Remove

Consider removing the following manual role assignments if they exist:

- **Cognitive Services OpenAI User**: Standard user access for OpenAI operations.
- **Cognitive Services OpenAI Contributor**: Administrative access for OpenAI management.
- **Cognitive Services User**: General cognitive services access.
- **Azure AI Developer**: Newer role for AI service development access.
- **Contributor**: If assigned specifically for OpenAI resource management.

### Step 5: Disable Monitoring and Logging

Remove diagnostic settings and logging configurations before deleting the main service.

#### Remove Diagnostic Settings

- In the Azure Portal, navigate to your Azure OpenAI service.
- In the left navigation, under **Monitoring**, click **Diagnostic settings**.
- For each diagnostic setting configured:
  - Click **Edit setting** to open its configuration.
  - At the top of the configuration pane, click **Delete**.
  - In the confirmation dialog, click **Yes** to confirm deletion.
  - Wait for the **Successfully deleted diagnostic setting** notification.

### Step 6: Delete Azure OpenAI Service

With all dependencies removed, you can now safely delete the main Azure OpenAI service.

#### Final Verification Before Deletion

- Confirm all model deployments are removed.
- Verify all diagnostic settings are disabled.
- Ensure no active integrations are using the OpenAI service.
- Record any configuration details you might need for future reference.

#### Delete the OpenAI Service

- In the Azure Portal, navigate to your Azure OpenAI service.
- Click **Overview** in the left navigation.
- At the top of the page, click **Delete**.
- In the **Delete resource** dialog:
  - Read the warning about permanent deletion.
  - Type **DELETE** in the confirmation field.
  - Optionally, select **Apply force delete** if you want to skip dependency checks.
  - Click **Delete** to permanently remove the service.
- Monitor the deletion progress in the **Notifications** panel (bell icon).
- Wait for the **Successfully deleted resource** notification before proceeding.

### Step 7: Clean Up Log Analytics Workspace (Optional)

**Important Decision Point**: If the Log Analytics workspace was created specifically for OpenAI monitoring, you may choose to delete it. If it's shared with other services (like Defender for Cloud), preserve it.

If you created a Log Analytics workspace specifically for OpenAI monitoring, you can delete it to eliminate additional costs.

#### Determine if Workspace Should Be Deleted

##### Preserve the Workspace If

- It's shared with Defender for Cloud or other services.
- You plan to redeploy OpenAI services in the future.
- Other Week 2 resources are using it for monitoring.

##### Delete the Workspace If

- It was created specifically for OpenAI monitoring.
- No other services are sending logs to this workspace.
- You confirmed in Step 5 that only OpenAI logs are present.

##### Delete Log Analytics Workspace

If you decide to delete the workspace:

- Navigate to your Log Analytics workspace in the Azure Portal.
- Click **Overview** in the left navigation.
- At the top of the page, click **Delete**.
- In the **Delete workspace** dialog:
  - Read the warning about data loss and billing implications.
  - Type **DELETE** in the confirmation field.
  - Click **Delete** to permanently remove the workspace.
- Wait for the **Successfully deleted workspace** notification.
- **Note**: Workspace deletion may take several minutes to complete fully.

### Step 8: Verify Complete Decommissioning

#### Decommissioning Verification Checklist

| Resource Type | Verification Method | Expected Result |
|---------------|-------------------|-----------------|
| **Azure OpenAI Service** | Check resource group `rg-aisec-ai` | Resource no longer listed |
| **Model Deployments** | Access Azure AI Foundry | No deployments visible |
| **API Endpoints** | Test API calls | Authentication errors returned |
| **Role Assignments** | Check IAM on deleted service | OpenAI-specific roles removed |
| **Diagnostic Settings** | Verify monitoring configs | All OpenAI logging disabled |
| **Budget Alerts** | Check Cost Management | OpenAI-specific budgets removed |
| **Cost Charges** | Review billing | No OpenAI token charges appearing |

#### Preserved Resources Checklist

- [ ] **Storage Foundation**: Storage account and containers preserved.
- [ ] **Resource Group**: `rg-aisec-ai` contains only storage resources.
- [ ] **Storage Budget**: General storage monitoring budget active.
- [ ] **Access Policies**: Storage-related security configurations intact.

#### Integration Impact Summary

| Service Category | Impact Level | Status |
|-----------------|-------------|--------|
| **Storage Foundation** | None | Continues operating normally |
| **Defender for Cloud** | None | Week 1 configurations remain active |
| **Custom Applications** | High | Applications using OpenAI APIs will fail |
| **Logic Apps/Power Automate** | High | OpenAI connectors require reconfiguration |

## 🔄 Future Considerations

### Redeployment Options

If you need to redeploy Azure OpenAI in the future:

- **Resource Naming**: Use same pattern (`openai-aisec-{unique-id}`).
- **Resource Group**: Continue using `rg-aisec-ai` for consistency.
- **Region**: Maintain **East US** for resource proximity.
- **Advantage**: Storage foundation remains intact for faster setup.

### Cost Impact Summary

| Savings Category | Monthly | Annual |
|-----------------|---------|---------|
| **Token Usage** | $5-25 | $60-300 |
| **Diagnostic Logging** | $2-5 | $24-60 |
| **Total Savings** | $7-30 | $84-360 |

### Alternative Approaches

| Approach | Cost Savings | Use Case |
|----------|-------------|----------|
| **Model Removal Only** | High | Preserve service configuration |
| **Partial Decommissioning** | Medium | Keep o4-mini, remove GPT-5 |
| **Complete Deletion** | Maximum | Full cleanup and reset |

### Security & Compliance Notes

- **Data Privacy**: All model interactions permanently removed from Microsoft infrastructure.
- **Credentials**: API keys and managed identities invalidated.
- **Audit Trail**: Activity logs preserved for governance requirements.

## 🤖 AI-Assisted Content Generation

This comprehensive decommissioning guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, leveraging GitHub Copilot's capabilities to ensure accuracy, completeness, and adherence to Microsoft Azure best practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Azure OpenAI decommissioning procedures while maintaining technical accuracy and reflecting current Azure service capabilities and cost optimization strategies.*

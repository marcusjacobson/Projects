# Deploy AI Storage Foundation via Azure Portal - Step-by-Step Guide

This guide provides a comprehensive, step-by-step approach to deploying AI storage infrastructure using the Azure Portal. This manual approach helps you understand each component of the AI storage architecture before progressing to automated deployments.

## 🎯 Overview

This Azure Portal approach provides:

- **Learning-Focused Experience** - Understand each storage component as you deploy it manually.
- **Portal-Based Deployment** - Hands-on experience with Azure Portal interfaces and workflows.
- **Cost-Optimized Configuration** - Manual verification of cost settings for budget compliance.
- **Foundation for AI Services** - Storage foundation required before deploying Azure OpenAI and Logic Apps.

### Core Deployment Steps

This guide follows a streamlined approach for AI storage foundation:

1. **Create Storage Account** - Complete portal-based deployment with all configuration tabs
2. **Create Containers** - Organized container structure for AI data management
3. **Cost Management** - Budget alerts and monitoring setup
4. **Validation & Testing** - Verify deployment and document configuration

## 📋 Prerequisites

Before starting, ensure you have:

- An active Azure subscription with Contributor or Owner permissions.
- Access to the Azure Portal.
- Basic understanding of Azure storage concepts.
- Week 1 Defender for Cloud foundation already deployed (recommended).

**Required Permissions**: Contributor or Owner roles at subscription level.

---

## Step 1: Create Storage Account

Deploy a complete storage account for AI workloads using the Azure Portal's guided workflow.

### 🚀 Start Storage Account Creation

1. Navigate to [https://portal.azure.com](https://portal.azure.com)
2. Sign in with your Azure account credentials
3. In the Azure Portal search bar, type **Storage accounts**
4. Click **Storage accounts** from the search results
5. Click **+ Create** to start the deployment wizard

### 📋 Basics Tab Configuration

Configure the fundamental settings for your AI storage account:

| Setting | Value | Purpose |
|---------|--------|---------|
| **Subscription** | Your M365 Developer Subscription | Primary Azure subscription |
| **Resource Group** | `rg-aisec-ai` | *Create new* - Dedicated group for AI services |
| **Storage Account Name** | `stai{unique-id}` | Must be globally unique (e.g., stai2025aug04) |
| **Region** | `East US` | Optimal region for AI service availability |
| **Primary service** | `Azure Blob Storage` | **Primary service for AI data storage and processing** |
| **Performance** | `Standard` | Cost-effective for AI workloads |
| **Redundancy** | `Locally-redundant storage (LRS)` | Most cost-effective option for lab |

**💡 Storage Name Tips:**

- Use your initials + date: `staimj20250804`
- Use random numbers: `stai847392`
- Storage names must be 3-24 characters, lowercase letters and numbers only.

### 🔧 Advanced Tab Configuration

Click **Next: Advanced** to configure security and optimization settings:

#### Security Settings

| Setting | Value | Purpose |
|---------|--------|---------|
| **Require secure transfer for REST API operations** | ✅ **Enable** | Forces HTTPS for all AI data transfers |
| **Allow enabling anonymous access on individual containers** | ❌ **Disable** | Prevents accidental data exposure |
| **Enable storage account key access** | ✅ **Enable** | Required for some AI services |
| **Default to Microsoft Entra authorization in the Azure portal** | ✅ **Enable** | Use modern authentication |
| **Minimum TLS version** | **Version 1.2** | Ensures modern encryption standards |
| **Permitted scope for copy operations (preview)** | **Default** | Standard copy operations |

#### Blob Storage Settings

| Setting | Value | Purpose |
|---------|--------|---------|
| **Enable hierarchical namespace** | ❌ **Disable** | Not needed for basic AI blob storage |
| **Enable SFTP** | ❌ **Disable** | Not needed for AI workloads |
| **Enable network file system v3** | ❌ **Disable** | Not needed for AI workloads |
| **Allow cross-tenant replication** | ✅ **Enable** (default) | Keep default for lab flexibility |
| **Access tier** | **Hot** | Optimized for frequently accessed AI data |

### 🌐 Networking Tab Configuration

Click **Next: Networking** to configure network access settings:

**💡 Recommended: Use Default Settings** for AI service compatibility

| Setting | Value | Purpose |
|---------|--------|---------|
| **Network access** | `Enable public access from all networks` | Recommended for this lab for simplicity |
| **Private endpoint** | `none` | Cost-effective and sufficient for this lab |
| **Routing preference** | `Microsoft network routing` | Optimal performance for Azure AI services |

**🎯 Why Default Networking for AI Labs?**

- **Lab Simplicity**: Azure OpenAI and Logic Apps support private endpoints but require additional configuration
- **Learning-Focused**: Simplified troubleshooting without network restrictions
- **Cost Optimization**: Avoids ~$7-15/month private endpoint charges
- **Security**: Maintained through access keys, RBAC, and TLS encryption

### 🛡️ Data Protection Tab Configuration

Click **Next: Data protection** to configure backup and recovery settings:

#### 💡 Recovery Settings for lab environment

| Setting | Value | Purpose |
|---------|--------|---------|
| **Enable point-in-time restore** | ❌ **Disable** | Not needed for lab scenarios |
| **Enable soft delete for blobs** | ❌ **Disable initially** | Reduce costs for lab environment |
| **Enable soft delete for containers** | ❌ **Disable initially** | Reduce costs for lab environment |
| **Enable versioning for blobs** | ❌ **Disable initially** | Minimize storage costs |

**Note**: Soft delete protects against accidental data deletion by retaining deleted blobs/containers for a specified period (default 7 days), but this adds storage costs and complexity for lab environments. These data protection settings can be enabled post-deployment for production scenarios where data recovery is critical.

#### 📊 Tracking Settings for lab environment

| Setting | Value | Purpose |
|---------|--------|---------|
| **Enable versioning for blobs** | ❌ **Disable initially** | Prevents additional storage costs from version management |
| **Enable blob change feed** | ❌ **Disable initially** | Avoids change tracking overhead and storage costs |

**🎯 Why Disable Tracking Features for AI Labs?**

- **Versioning Costs**: Every blob write creates a new version, potentially doubling storage costs for active AI workloads
- **Change Feed Overhead**: Creates additional storage containers ($blobchangefeed) with detailed audit logs
- **Lab Simplicity**: AI experiments benefit from straightforward storage without version complexity
- **Cost Control**: These features can significantly increase storage bills for active AI data processing

#### 🔐 Access Control Settings for lab environment

| Setting | Value | Purpose |
|---------|--------|---------|
| **Enable version-level immutability support** | ❌ **Disable** | Not needed for lab scenarios and requires versioning |

**💡 Immutability Context**: Version-level immutability is designed for regulatory compliance (SEC 17a-4, FINRA) and requires blob versioning to be enabled. For AI labs focused on experimentation and learning, this adds unnecessary complexity and costs.

### 🔒 Encryption Tab Configuration

Click **Next: Encryption** to configure data encryption settings:

| Setting | Value | Purpose |
|---------|--------|---------|
| **Encryption type** | `Microsoft-managed keys` | Simplified key management for lab |
| **Enable support for customer-managed keys** | `Blobs and files only` | Default setting sufficient for AI workloads |
| **Enable infrastructure encryption** | ❌ **Disable** | Additional cost not needed for lab |

### 🔍 Review + Create

Click **Next: Review + create** to validate and deploy:

1. **Review all settings** to ensure they match the specifications above
2. **Verify estimated cost** is within budget expectations (should be $4-11/month)
3. **Check validation status** - ensure all validations pass
4. Click **Create** to deploy the storage account

### ⏱️ Deployment Timeline

- **Deployment time**: 1-2 minutes
- **Status updates**: Monitor the notification bell for progress
- **Completion**: Wait for **Your deployment is complete** message
- Click **Go to resource** when deployment completes.

---

## Step 2: Create Containers

Set up organized containers for AI data management within your deployed storage account.

### 🚀 Navigate to Container Management

1. In your storage account, navigate to **Data storage** → **Containers** in the left menu
2. You should see an empty container list
3. We'll create three containers for organized AI data management

### 📦 Create AI Data Containers

**💡 Advanced Settings Guidance**: When creating each container, you'll see an Advanced section with optional encryption and immutability settings. For this lab environment, leave all advanced settings as default to avoid additional costs and complexity.

**🔐 Why Default Advanced Settings for AI Labs?**

- **Encryption Scopes**: Designed for multi-tenant scenarios with additional monthly billing (minimum 30 days)
- **Version-level Immutability**: Requires versioning (which we disabled for cost optimization) and regulatory compliance features
- **Account-level Security**: Default encryption and access controls provide sufficient security for lab environments

#### Container 1: AI Data Processing

1. Click **+ Add container**
2. **Name**: `ai-data`
3. **Public access level**: **Private (no anonymous access)**
4. **Advanced settings**: Leave all settings as default (recommended for lab environment)
5. Click **Create**

#### Container 2: AI Operation Logs

1. Click **+ Add container**
2. **Name**: `ai-logs`
3. **Public access level**: **Private (no anonymous access)**
4. **Advanced settings**: Leave all settings as default (recommended for lab environment)
5. Click **Create**

#### Container 3: AI Model Storage

1. Click **+ Add container**
2. **Name**: `ai-models`
3. **Public access level**: **Private (no anonymous access)**
4. **Advanced settings**: Leave all settings as default (recommended for lab environment)
5. Click **Create**

### 📊 Container Overview

After creation, you should see:

| Container Name | Purpose | Access Level | Status |
|----------------|---------|--------------|--------|
| `ai-data` | AI data processing and analysis | Private | ✅ Created |
| `ai-logs` | AI operation logs and diagnostics | Private | ✅ Created |
| `ai-models` | AI model storage and versioning | Private | ✅ Created |

### 🔑 Access Key Retrieval

While in your storage account, collect the connection information needed for AI services:

1. Navigate to **Security + networking** → **Access keys**
2. Note the following for later AI service integration:
   - **Storage account name**: `stai{your-unique-id}`
   - **Key1**: Click **Show** and copy the key (store securely)
   - **Connection string**: Click **Show** and copy for application configuration

**🔒 Security Note**: Store these credentials securely and never commit them to source control.

---

## Step 3: Cost Awareness

Understanding storage costs and planning for budget monitoring.

### 💰 Storage Cost Overview

Monitor these cost components for your AI storage foundation:

| Component | Estimated Monthly Cost | Description |
|-----------|----------------------|-------------|
| **Storage (LRS, Hot)** | $3-8 | Depending on data volume |
| **Operations** | $1-2 | Read/write operations |
| **Data Transfer** | $0-1 | Minimal for lab usage |
| **Total Estimate** | **$4-11/month** | Conservative estimate for lab usage |

### 📊 Cost Management Setup

**⏰ Budget Setup Timing**: Due to Azure Cost Management's 24-48 hour latency for recognizing new resource groups, budget configuration should be performed **at the end of Week 2** when all resources have generated cost data.

**🔗 Complete Budget Guide**: For comprehensive budget setup with alerts and monitoring, see **[Configure AI Cost Management & Budgets](./configure-ai-cost-management-budgets.md)**.

### � Immediate Cost Controls

While waiting for budget setup, implement these immediate cost controls:

1. **Monitor Usage**: Check **Cost Analysis** daily for the first week
2. **Resource Cleanup**: Remove any test resources after validation
3. **Access Pattern Review**: Ensure containers are set to **Private** access only
4. **Data Lifecycle**: Plan data retention policies for logs and temporary files

---

## Step 4: Validation & Testing

Verify your storage foundation is properly configured and ready for AI integration.

### 🔐 Prerequisites: Storage Data Access Permissions

Before testing storage connectivity, ensure you have the necessary data-level permissions. **Subscription Owner** role provides management access but not automatic data access to storage blobs.

#### Grant Storage Blob Data Contributor Role

1. In your storage account, navigate to **Access Control (IAM)** in the left menu
2. Click **+ Add** → **Add role assignment**
3. **Role tab**:
   - Search for and select **Storage Blob Data Contributor**
   - Click **Next**
4. **Members tab**:
   - **Assign access to**: **User, group, or service principal**
   - Click **+ Select members**
   - Search for and select your user account
   - Click **Select**
   - Click **Next**
5. **Review + assign tab**:
   - Review the assignment details
   - Click **Review + assign**

**💡 Why This Permission is Needed:**

- **Subscription Owner**: Provides management plane access (create/delete resources)
- **Storage Blob Data Contributor**: Provides data plane access (read/write blob data)
- **Separation of Concerns**: Azure separates resource management from data access for security

#### Wait for Permission Propagation

- **Wait 2-3 minutes** for the role assignment to propagate.
- **Refresh your browser** or sign out/in if permission errors persist.

### ✅ Storage Account Validation

#### Test Storage Connectivity

1. Navigate back to your storage account
2. Go to **Data storage** → **Containers**
3. Click on the `ai-data` container
4. Click **Upload** to test access
5. Upload a small test file (create a simple .txt file)
6. Verify the upload completes successfully
7. Delete the test file to clean up

**🚨 If Upload Still Fails:**

- Verify the **Storage Blob Data Contributor** role was assigned correctly.
- Try using **Access keys** method: In the container, click **Switch to access key** at the top of the page.
- Wait additional 5-10 minutes for Azure AD propagation in some regions.

#### Verify Security Configuration

Check that security settings are properly applied:

1. From the main storage account menu, navigate to **Settings** → **Configuration**
   - **Secure transfer required**: Should be **Enabled**
   - **Allow Blob anonymous access**: Should be **Disabled**
   - **Minimum TLS version**: Should be **Version 1.2**

2. Navigate to **Data storage** → **Containers**
   - All containers should show **Private** access level

### 📋 Deployment Checklist

Mark each item as complete:

- ✅ Resource group `rg-aisec-ai` created.
- ✅ Storage account `stai{unique-id}` deployed successfully.
- ✅ Security settings configured (HTTPS, TLS 1.2, no public access).
- ✅ Networking configured for AI service compatibility.
- ✅ Three containers created (`ai-data`, `ai-logs`, `ai-models`).
- ✅ Access keys retrieved and stored securely.
- ✅ Cost awareness documented and monitoring planned.
- ✅ Storage connectivity tested successfully.
- 📋 **Budget setup scheduled** for end of Week 2 (see [Cost Management Guide](./configure-ai-cost-management-budgets.md)).

### 📝 Configuration Summary

Record these details for AI service integration:

```text
AI Storage Foundation - Deployment Summary
==========================================
Resource Group: rg-aisec-ai
Storage Account: stai{your-unique-id}
Region: East US
Containers: ai-data, ai-logs, ai-models
Expected Monthly Cost: $4-11 (storage only)
Access Keys: Securely stored
Deployment Date: [Today's Date]
Budget Setup: Scheduled for end of Week 2
```

### 🔗 Integration Ready

Your storage foundation is now ready for:

- **Azure OpenAI service** connection.
- **Logic Apps** integration for AI automation.
- **AI data processing** workflows.
- **Cost-optimized** AI operations.

---

## 🔗 Next Steps

After successful storage deployment:

1. **[Deploy Azure OpenAI Service](./deploy-azure-openai-service.md)** - Add AI capabilities
2. **[Configure Logic Apps Integration](./deploy-logic-apps-ai-automation.md)** - AI automation workflows
3. **[Deploy Defender XDR Integration](./deploy-openai-defender-xdr-integration.md)** - Complete AI security pipeline

### 📅 End of Week 2 Tasks

Complete these tasks at the end of Week 2 after all resources have been active for 24-48 hours:

1. **[Configure AI Cost Management & Budgets](./configure-ai-cost-management-budgets.md)** - Comprehensive budget setup and monitoring

---

## 🛠️ Troubleshooting

### Common Issues

#### Storage Account Name Already Exists

- Storage account names must be globally unique across all Azure.
- Try adding more unique characters: `stai` + `your-initials` + `MMDD` + `random-digits`.

#### Access Denied Errors

- Verify Contributor or Owner access to the subscription.
- Check you're signed in with the correct Azure account.
- Ensure resource group creation permissions.

#### Container Creation Fails

- Verify storage account deployment completed successfully.
- Check that blob service is enabled (default).
- Refresh the portal and try again.

#### Storage Data Access Errors

**Symptoms**: **You do not have permissions to list the data using your user account with Microsoft Entra ID** when uploading files

**Root Cause**: Subscription Owner role provides resource management access but not data-level access to storage blobs

**Solution**:

1. Navigate to **Access Control (IAM)** in your storage account.
2. Add role assignment: **Storage Blob Data Contributor** to your user account.
3. Wait 2-3 minutes for permission propagation.
4. Refresh browser or try **Switch to access key** option in container upload.

### Support Resources

- [Azure Storage Documentation](https://docs.microsoft.com/en-us/azure/storage/)
- [Storage Security Best Practices](https://docs.microsoft.com/en-us/azure/storage/common/storage-security-guide)
- [Cost Management Documentation](https://docs.microsoft.com/en-us/azure/cost-management-billing/)

---

**📋 Deployment Status**: After completing this guide, your AI storage foundation is deployed and ready for the next AI integration components.

---

## 🤖 AI-Assisted Content Generation

This comprehensive deployment guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Azure Portal interface accuracy, cost optimization strategies, and real-world permission requirements for AI storage foundations.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Azure Storage deployment while maintaining technical accuracy and reflecting Azure best practices for AI workloads.*

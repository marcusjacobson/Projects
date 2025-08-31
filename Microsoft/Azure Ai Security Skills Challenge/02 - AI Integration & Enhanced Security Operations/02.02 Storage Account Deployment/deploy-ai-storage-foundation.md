# Deploy AI Storage Foundation

This guide covers deploying storage accounts optimized for AI workloads with comprehensive cost controls. Storage is the foundational requirement for Week 2 AI integration before deploying any AI services.

## 🎯 Overview

The AI storage foundation provides:

- **Optimized Storage Accounts**: Cost-effective storage for AI data processing, model storage, and logging
- **Security Configuration**: Private containers with encryption and access controls
- **Cost Management**: Lifecycle policies and retention settings for budget optimization
- **Integration Ready**: Configured for seamless integration with Azure OpenAI and Logic Apps

## 💰 Cost Optimization Features

- **Standard_LRS**: Most cost-effective replication for lab environments
- **Hot Access Tier**: Optimized for frequent AI workload access
- **Short Retention**: 7-day retention for cost optimization
- **No Versioning**: Disabled to minimize storage costs
- **Lifecycle Policies**: Automated cleanup of temporary AI processing data

## � Choose Your Deployment Method

### **Method 1: Azure Portal Deployment** 🖱️ (Learning-Focused)

**Best for:**

- Understanding each storage component as you configure it
- Learning Azure Portal interfaces and workflows
- Manual verification of cost settings and security configurations
- Educational scenarios where you want to see each step

📖 **[Follow the complete Azure Portal guide](./deploy-ai-storage-foundation-azure-portal.md)**

### **Method 2: Infrastructure-as-Code Deployment** ⚡ (Production-Ready)

**Best for:**

- Repeatable, consistent deployments
- Automation and scripting scenarios  
- Version-controlled infrastructure management
- Faster deployment with comprehensive validation

📖 **[Follow the complete Infrastructure-as-Code guide](./deploy-ai-storage-foundation-modular-iac.md)**

---

## 🔍 Cost Monitoring

### Expected Monthly Costs

| Component | Estimated Cost | Description |
|-----------|----------------|-------------|
| **Storage Account (LRS)** | $5-10/month | Depending on data volume |
| **Operations** | $1-3/month | Read/write operations |
| **Data Transfer** | $0-2/month | Minimal for lab usage |
| **Total Estimate** | **$6-15/month** | Well within budget |

### Cost Alerts

Both deployment methods automatically configure:

- Budget monitoring at resource group level
- Email alerts at 50%, 75%, and 90% thresholds
- Cost recommendations and optimization suggestions

## 🔗 Next Steps

After successful storage deployment:

1. **[Deploy AI Cost Management](./deploy-ai-cost-management.md)** - Set up comprehensive budget controls
2. **[Deploy Azure OpenAI Service](./deploy-azure-openai-service.md)** - Add AI capabilities
3. **Continue to Sentinel Integration** - Complete the AI automation pipeline

## 🧹 Cleanup and Decommission

When you're ready to remove the AI storage infrastructure:

📖 **[Follow the complete decommission guide](./decommission-ai-storage-foundation.md)**

The decommission guide provides both automated script-based cleanup and manual portal-based removal procedures.

---

**📋 Deployment Status**: Choose your preferred deployment method above and follow the corresponding detailed guide for complete step-by-step instructions.

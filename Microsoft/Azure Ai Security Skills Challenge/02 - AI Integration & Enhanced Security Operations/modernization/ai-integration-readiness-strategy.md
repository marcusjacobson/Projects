# Week 1 Completion: AI Integration Readiness Strategy

This document provides focused activities to prepare your validated Defender for Cloud deployments for AI integration in Week 2.

## 🎯 Prerequisites

**✅ Infrastructure Deployment Complete:**

Your infrastructure should be deployed through one of these methods:

- **Automated Scripts** (Recommended): `.\Deploy-Complete.ps1 -UseParametersFile`
- **Manual Portal Deployment**: Individual components deployed via Azure Portal
- **Partial Automation**: Mix of scripted and manual deployment

**🎯 AI Readiness Objective:**

Prepare your validated Defender for Cloud foundation specifically for Week 2 AI service integration, focusing on East US deployment with full UEBA support.

## 🔧 Portal-Only Deployment Setup

> **📝 Note:** This section is **only required** if you deployed your infrastructure manually through Azure Portal and haven't set up Azure CLI authentication yet. If you used our automated scripts (`Deploy-Complete.ps1`), skip to the [Quick Start](#-quick-start-automated-validation) section.

If you deployed infrastructure manually through Azure Portal, you'll need to set up Azure CLI for the validation script:

### Step 1: Install Azure CLI (if needed)

```powershell
# Check if Azure CLI is installed
az --version

# If not installed, download from: https://aka.ms/installazurecli
```

### Step 2: Authenticate to Azure

```powershell
# Login to Azure (will open browser for authentication)
az login

# Verify you're connected to the correct subscription
az account show --query "{name:name, id:id}" --output table

# If needed, set the correct subscription
az account set --subscription "your-subscription-id"
```

### Step 3: Identify Your Resource Information

```powershell
# Find your Defender for Cloud resource group
az group list --query "[?contains(name, 'defender') || contains(name, 'aisec') || contains(name, 'security')].{Name:name, Location:location}" --output table

# List resources in your security resource group (replace with your actual name)
az resource list --resource-group "your-resource-group-name" --query "[].{Name:name, Type:type, Location:location}" --output table

# Find your Log Analytics workspace (needed for Sentinel)
az monitor log-analytics workspace list --query "[?contains(name, 'sentinel') || contains(name, 'security') || contains(name, 'defender')].{Name:name, ResourceGroup:resourceGroup, Location:location}" --output table
```

## 🚀 Quick Start: Automated Validation

For automated validation of your AI readiness, use the comprehensive PowerShell scripts:

```powershell
# Step 1: Enable Sentinel AI features for Week 2
.\scripts\Deploy-SentinelAIFeatures.ps1 -UseParametersFile -DetailedOutput

# Step 2: Run AI Integration Readiness validation
.\scripts\Test-AIIntegrationReadiness.ps1 -UseParametersFile -DetailedReport

# Expected Result: "READY for Week 2 AI Integration" with 100% completion score
```

These scripts perform all the infrastructure, security, and AI readiness checks automatically and provide structured readiness reports.

## 🤖 AI Integration Readiness Validation

### Expected Script Output

When you run `Test-AIIntegrationReadiness.ps1`, you should see:

```powershell
🎯 AI Integration Readiness Assessment
=====================================
✅ Step 1: Infrastructure Foundation (4/4 Complete)
   • Resource Group: Found
   • Log Analytics Workspace: Active
   • Virtual Network: Configured
   • Virtual Machines: Running (2 VMs)

✅ Step 2: Security Foundation (3/3 Complete)
   • Defender Plans: Enabled (VirtualMachines, Storage, KeyVault, Containers)
   • Security Contacts: Configured
   • JIT VM Access: Active

✅ Step 3: AI Service Availability (2/2 Complete)
   • Azure OpenAI: Available in East US
   • Network Connectivity: Confirmed

✅ Step 4: Week 2 Infrastructure Planning (2/2 Complete)
   • Primary Region: East US
   • Cost Estimate: ~$50/month

✅ Step 5: Week 2 AI Integration Prerequisites (2/2 Complete)
   • Defender Foundation: Validated
   • Sentinel Workspace: Available
   • AI Features: Ready for configuration

🎉 FINAL SCORE: 5/5 (100%)
🚀 STATUS: READY for Week 2 AI Integration
📍 LOCATION: East US (Full AI Support)
```

## 🔍 Troubleshooting Common Issues

If the script shows less than 100% readiness, here are common solutions:

### Issue 1: Script Authentication Errors

**Problem:** `Test-AIIntegrationReadiness.ps1` fails with authentication errors.

**Solution:**

```powershell
# Re-authenticate to Azure
Disconnect-AzAccount
Connect-AzAccount

# Verify subscription context
Get-AzContext

# Set correct subscription if needed
Set-AzContext -SubscriptionId "your-subscription-id"
```

### Issue 2: Infrastructure Not Found

**Problem:** Script reports missing resource group, Log Analytics workspace, or VMs.

**Solution:** Deploy or complete your infrastructure first:

```powershell
# Deploy complete infrastructure
.\Deploy-Complete.ps1 -UseParametersFile

# Or deploy components individually
.\Deploy-InfrastructureFoundation.ps1 -UseParametersFile
.\Deploy-VirtualMachines.ps1 -UseParametersFile
```

### Issue 3: Missing UEBA Features

**Problem:** UEBA not available in your region.

**Solution:** Validate you're deployed in East US (done automatically by our scripts):

```powershell
# Check current deployment region
az group show --name $resourceGroupName --query "location" --output tsv

# If not in East US, consider redeployment with our scripts:
# .\Remove-DefenderInfrastructure.ps1 -UseParametersFile -Force
# (Update main.parameters.json location to "eastus")
# .\Deploy-Complete.ps1 -UseParametersFile
```

### Issue 4: Sentinel Data Connector Issues

**Problem:** Sentinel shows connection errors or orphaned states.

**Solution:** Our `Deploy-Sentinel.ps1` script automatically handles this:

```powershell
# Run Sentinel deployment with automatic cleanup
.\Deploy-Sentinel.ps1 -UseParametersFile

# The script will automatically detect and clean orphaned onboarding states
# Look for: "No existing onboarding state found - proceeding with fresh enablement"
```

### Issue 5: Security Foundation Incomplete

**Problem:** Missing Defender plans or security contacts.

**Solution:** Enable security features:

```powershell
# Deploy security features
.\Deploy-SecurityFeatures.ps1 -UseParametersFile
```

## 🎯 Week 2 Preparation Checklist

Before starting Week 2 AI integration activities, ensure:

- [ ] **Infrastructure Status:** `Test-AIIntegrationReadiness.ps1` shows 100% readiness
- [ ] **Sentinel AI Features:** Run `Deploy-SentinelAIFeatures.ps1` and follow manual configuration guidance
- [ ] **Regional Compliance:** Deployed in East US with UEBA support
- [ ] **Defender Plans:** All critical plans enabled (VMs, Storage, KeyVault, Containers)
- [ ] **Sentinel Foundation:** Workspace enabled with working data connectors
- [ ] **Network Connectivity:** AI service endpoints accessible
- [ ] **Quota Availability:** Azure OpenAI and Cognitive Services quotas confirmed
- [ ] **Authentication:** Azure CLI and PowerShell modules working correctly

## 📋 Expected Week 2 Readiness Profile

After successful completion, your environment will have:

### ✅ Security Foundation

- **Defender for Cloud:** Enhanced security posture across VMs, Storage, KeyVault, Containers
- **Just-in-Time VM Access:** Configured for secure administrative access
- **Security Contacts:** Configured for alert notifications
- **Compliance Monitoring:** Microsoft Cloud Security Benchmark tracking

### ✅ Sentinel AI Platform

- **Log Analytics Workspace:** Centralized security data collection
- **Sentinel Workspace:** Enabled with AI-powered threat detection
- **Data Connectors:** Ready for Azure security data ingestion
- **AI Features Enabled:** Fusion, Anomaly Detection, UEBA (East US specific)

### ✅ AI Integration Ready

- **Regional Placement:** East US deployment for full AI feature support
- **Network Connectivity:** Validated endpoints for Azure OpenAI and Cognitive Services
- **Resource Naming:** Consistent convention for AI resource deployment
- **Quota Validation:** Confirmed availability for Week 2 AI service creation

### ✅ Cost Optimization

- **Auto-shutdown:** VM automatic shutdown configured for cost savings
- **Resource Monitoring:** Monthly cost tracking and analysis
- **Efficient Sizing:** Right-sized resources for learning environment

## 🚀 Next Steps

1. **Week 2 Preparation:** Your infrastructure is now ready for AI security service integration
2. **Continuous Monitoring:** Use `Test-FinalLabValidation.ps1` for ongoing health checks
3. **Documentation:** Keep deployment parameters for consistent AI resource naming
4. **Cleanup Planning:** Use `Remove-DefenderInfrastructure.ps1` when lab is complete

**🎉 Congratulations!** Your Defender for Cloud foundation is optimized and ready for advanced AI security integration in Week 2.

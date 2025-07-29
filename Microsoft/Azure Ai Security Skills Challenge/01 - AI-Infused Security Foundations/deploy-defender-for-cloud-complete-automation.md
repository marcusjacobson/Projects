# Deploy Microsoft Defender for Cloud - Complete Automation Guide

This guide provides a streamlined approach to deploying Microsoft Defender for Cloud using a single automated script, followed by essential portal-only configurations and optional lab teardown.

## 🎯 Overview

This guide focuses on **speed and simplicity** - deploy a complete Microsoft Defender for Cloud environment with one command, then configure the few features that require Azure Portal interaction.

### What You'll Deploy

- **Complete Infrastructure** - Resource groups, VMs, networking, and Log Analytics workspace
- **Defender for Cloud Plans** - Servers, Storage, Key Vault, and Containers protection
- **Security Features** - Just-in-Time VM Access, agentless scanning, and endpoint protection
- **Monitoring Setup** - Security contacts, notifications, and compliance standards

### Timeline

- **Automated Deployment**: 15-20 minutes
- **Portal Configuration**: 5-10 minutes  
- **Total Time**: 25-30 minutes

---

## 📋 Prerequisites

Before starting, ensure you have:

- An active Azure subscription with Owner or Contributor permissions
- Azure CLI installed and authenticated to your Azure subscription
- PowerShell environment (Windows PowerShell 5.1+ or PowerShell 7+)
- Basic understanding of Azure security concepts

### Quick Environment Setup

```powershell
# Verify Azure CLI and authentication
az --version
az account show

# Set your subscription (if you have multiple)
az account set --subscription "Your-Subscription-Name-or-ID"

# Verify permissions
az role assignment list --assignee $(az account show --query user.name --output tsv) --scope "/subscriptions/$(az account show --query id --output tsv)" --output table
```

**Required Permissions**: Owner, Contributor, or Security Admin roles at subscription level.

---

## 🚀 Complete Automated Deployment

### Deploy Everything with One Command

```powershell
# Deploy the complete Microsoft Defender for Cloud environment
.\scripts\Deploy-Complete.ps1 -EnvironmentName "securitylab" -SecurityContactEmail "admin@yourcompany.com" -Location "East US"
```

### Script Parameters

**Required Parameters:**
- `-EnvironmentName`: Unique identifier for your lab (e.g., "securitylab", "testlab")
- `-SecurityContactEmail`: Email address for security notifications
- `-Location`: Azure region (e.g., "East US", "West US 2", "West Europe")

**Optional Parameters:**
- `-WhatIf`: Preview all changes without executing (recommended first run)
- `-Verbose`: Enable detailed logging output

### What This Deploys

The complete script automatically deploys and configures:

#### **Infrastructure Foundation**
- ✅ Resource Group with proper naming and tagging
- ✅ Log Analytics Workspace for security monitoring
- ✅ Virtual Network and Network Security Groups
- ✅ Windows Server 2022 VM with Defender for Endpoint
- ✅ Ubuntu Linux VM with Defender for Endpoint

#### **Security Configuration**
- ✅ Defender for Servers Plan 2 (agentless scanning)
- ✅ Defender for Storage with malware scanning
- ✅ Defender for Key Vault protection
- ✅ Defender for Containers security
- ✅ Security contact email notifications
- ✅ Just-in-Time VM Access policies

#### **Monitoring and Compliance**
- ✅ Security recommendations and secure score
- ✅ Microsoft Cloud Security Benchmark (MCSB)
- ✅ Alert severity and notification settings
- ✅ Comprehensive validation and health checks

### Expected Deployment Time

- **Infrastructure**: 8-10 minutes
- **Security Configuration**: 3-5 minutes
- **VM Extensions and Policies**: 4-6 minutes
- **Total**: 15-20 minutes

### Monitoring Deployment Progress

The script provides real-time progress updates:
- **Phase 1**: Infrastructure Foundation (Resource Group, Log Analytics, Networking)
- **Phase 2**: Virtual Machine Deployment (Windows and Linux VMs)
- **Phase 3**: Defender Plans Configuration (Security plans and contacts)
- **Phase 4**: Security Features (JIT VM Access and advanced protection)
- **Phase 5**: Comprehensive Validation (Health checks and reporting)

---

## 🌐 Portal-Only Configurations

After the automated deployment completes, configure these features that require Azure Portal interaction:

### 1. File Integrity Monitoring

**Why Portal-Only:** Complex workspace integration requires interactive validation.

**Configuration Steps:**
1. Navigate to **Defender for Cloud** → **Environment settings** → Your subscription
2. Click **Defender plans** → **Servers** → **Settings**
3. Toggle **File Integrity Monitoring** to **On**
4. **Configuration panel automatically appears**
5. **Workspace Configuration**: Select the Log Analytics workspace (created by script)
6. **Use default recommendations**: ✅ **Recommended** - provides comprehensive coverage
7. Click **Continue** to save configuration

**Expected Result**: FIM monitors system files, registry keys, and configuration changes using modern agentless scanning.

### 2. Microsoft Sentinel Integration

**Automated Option (Recommended):** Use PowerShell script for Sentinel enablement, then portal for data connector.

**Automated Sentinel Enablement:**

```powershell
# Enable Sentinel on the deployed Log Analytics workspace
.\scripts\Deploy-Sentinel.ps1 -UseParametersFile
```

**Portal-Based Data Connector Configuration:**
1. Navigate to **Microsoft Sentinel** → Select your workspace
2. Go to **Content management** → **Content hub**
3. Search for and install **Microsoft Defender for Cloud** solution
4. Configure the **Tenant-based Microsoft Defender for Cloud** data connector
5. Verify connector status shows **Connected**

**Expected Result**: Defender for Cloud alerts flow into Sentinel for advanced SIEM capabilities with automated workspace setup.

### 3. Sample Alert Generation and Testing

**Why Portal-Only:** Interactive plan selection and validation required.

**Configuration Steps:**
1. Navigate to **Defender for Cloud** → **Security alerts**
2. Click **Sample alerts** in the toolbar
3. Select your subscription from dropdown
4. Select relevant Defender plans to test:
   - **Defender for Servers**: VM threat detection
   - **Defender for Storage**: Storage threat detection
   - **Defender for Containers**: Container security alerts
5. Click **Create sample alerts**

**Expected Result**: Sample alerts appear within 2-5 minutes and trigger email notifications.

---

## ✅ Deployment Validation

### Automated Validation

The deployment script includes comprehensive validation, but you can run additional checks:

```powershell
# Run comprehensive validation with detailed reporting
.\scripts\Test-DeploymentValidation.ps1 -EnvironmentName "securitylab" -DetailedReport -ExportResults
```

### Manual Verification (Azure Portal)

**Quick Portal Checks:**
1. **Defender for Cloud Overview** - Verify all plans show as enabled
2. **Virtual Machine Inventory** - Check VMs appear with protection status
3. **Security Recommendations** - Review active security findings
4. **Compliance Dashboard** - Monitor MCSB compliance status

**Expected Results:**
- **Coverage Percentage**: ~22% (CSPM + Servers plans enabled)
- **Protected VMs**: 2 VMs showing active monitoring
- **Security Score**: Initial baseline score calculation
- **Active Recommendations**: Security findings for remediation

### CLI Verification Commands

```powershell
# Verify Defender plans are enabled
az security pricing list --query "value[].{Name:name, PricingTier:pricingTier}" --output table

# Check security contacts configuration
az security contact list --query "[].{Email:email, AlertNotifications:alertNotifications.state}" --output table

# Verify VM protection status
az vm list --resource-group "rg-aisec-defender-securitylab" --query "[].{Name:name, PowerState:powerState}" --output table
```

---

## 📊 Cost Management

### Expected Monthly Costs (July 2025 Pricing)

**Core Security Services:**
- **Defender for Servers Plan 2**: ~$15 USD/server/month (2 VMs = $30/month)
- **Defender for Storage**: ~$0.02 USD/GB + $0.50/million transactions
- **Defender for Key Vault**: ~$0.02 USD/operation (typically under $5/month)
- **Defender for Containers**: ~$7 USD/node/month (minimal for test environment)

**Infrastructure Costs:**
- **Virtual Machines**: ~$30-40 USD/month each (Standard_B2s size)
- **Log Analytics**: ~$2.76 USD/GB ingested (500MB/day free with Defender for Servers)

**Total Estimated Cost**: $35-50 USD/month for security features + $60-80 USD/month for VMs if running continuously.

### Cost Optimization

**Immediate Cost Savings:**
```powershell
# Configure auto-shutdown for VMs (6:00 PM daily)
$resourceGroup = "rg-aisec-defender-securitylab"
$windowsVm = az vm list --resource-group $resourceGroup --query "[?contains(name, 'windows')].name" --output tsv
$linuxVm = az vm list --resource-group $resourceGroup --query "[?contains(name, 'linux')].name" --output tsv

az vm auto-shutdown --resource-group $resourceGroup --name $windowsVm --time "1800"
az vm auto-shutdown --resource-group $resourceGroup --name $linuxVm --time "1800"
```

**Cost Monitoring:**
1. Navigate to **Cost Management** → **Cost analysis** in Azure Portal
2. Filter by your resource group to track lab spending
3. Set up cost alerts for unexpected increases

---

## 🔧 Troubleshooting

### Common Issues

#### Deployment Failures

**Permission Issues:**
```powershell
# Verify required permissions
az role assignment list --assignee $(az account show --query user.name --output tsv) --scope "/subscriptions/$(az account show --query id --output tsv)"
```
**Solution**: Ensure you have Owner, Contributor, or Security Admin roles.

**Resource Naming Conflicts:**
**Error**: `The domain name label is invalid or reserved`
**Solution**: Use a more unique `-EnvironmentName` parameter (e.g., add your initials or date).

**Quota Limitations:**
```powershell
# Check VM quota in your region
az vm list-usage --location "East US" --output table
```
**Solution**: Choose a different region or request quota increase.

#### Configuration Issues

**No Security Alerts Appearing:**
1. Verify Defender plans are in Standard tier (not Free)
2. Wait 24-48 hours for initial data collection
3. Generate sample alerts via Azure Portal

**Agentless Scanning Not Active:**
1. Confirm Defender for Servers Plan 2 is enabled
2. Check VM status in Asset Inventory
3. Allow 24-48 hours for initial scan completion

---

## 🧹 Lab Decommissioning

When you're ready to remove the test environment:

### Complete Lab Teardown

```powershell
# Remove all resources and Defender plans
.\scripts\Remove-DefenderInfrastructure.ps1 -EnvironmentName "securitylab" -DisableDefenderPlans -Force
```

### Safe Decommission with Preview

```powershell
# Preview what will be deleted
.\scripts\Remove-DefenderInfrastructure.ps1 -EnvironmentName "securitylab" -WhatIf

# Execute with confirmation prompts
.\scripts\Remove-DefenderInfrastructure.ps1 -EnvironmentName "securitylab" -DisableDefenderPlans
```

### Decommission Features

**What Gets Removed:**
- ✅ **Complete Resource Cleanup** - All VMs, networking, and storage
- ✅ **Security Configuration Cleanup** - JIT policies and security contacts
- ✅ **Defender Plan Management** - Optionally disable all pricing plans
- ✅ **Validation Reporting** - Comprehensive removal verification

**Important Notes:**
- Use `-DisableDefenderPlans` for complete lab reset
- Without this flag, Defender plans remain active for other resources
- Decommission typically takes 10-15 minutes
- Validation provides detailed success/failure reporting

---

## 📚 Next Steps

### Immediate Actions

1. **Explore Security Recommendations** - Review findings in Defender for Cloud
2. **Test Alert Investigation** - Generate sample alerts and practice investigation
3. **Configure Compliance Standards** - Enable additional standards as needed
4. **Set Up Cost Monitoring** - Configure alerts for spending management

### Advanced Learning

1. **Microsoft Sentinel Integration** - Explore SIEM capabilities
2. **Custom Security Policies** - Create organization-specific policies
3. **Automated Response** - Implement Logic Apps for incident response
4. **Multi-Subscription Management** - Scale to enterprise environments

### Learning Resources

- **[Microsoft Defender for Cloud Learning Path](https://learn.microsoft.com/en-us/training/browse/?products=azure-defender)**
- **[Azure Security Documentation](https://learn.microsoft.com/en-us/azure/security/)**
- **[Security Best Practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns)**

---

## 🔗 Related Guides

- **[Deploy via Azure Portal](./deploy-defender-for-cloud-azure-portal.md)** - Manual deployment for learning
- **[Modular IaC Deployment](./deploy-defender-for-cloud-modular-iac.md)** - Phase-by-phase Infrastructure-as-Code approach
- **[Decommission Guide](./decommission-defender-for-cloud.md)** - Detailed teardown procedures

---

**📸 [Microsoft Defender for Cloud Documentation](https://learn.microsoft.com/en-us/azure/defender-for-cloud/)**

---

## 🛡️ Security Best Practices

### Lab Environment Security

- **Unique Environment Names** - Use distinct identifiers for multiple labs
- **Cost Controls** - Implement auto-shutdown and monitoring
- **Access Management** - Use least privilege principles
- **Regular Cleanup** - Remove unused test environments

### Production Considerations

- **Phased Rollout** - Start with non-production subscriptions
- **Policy Customization** - Adapt security policies to organizational needs
- **Integration Planning** - Consider existing security tools and workflows
- **Change Management** - Document and communicate security changes

This complete automation guide provides the fastest path to a functional Microsoft Defender for Cloud environment while maintaining security best practices and cost control.
